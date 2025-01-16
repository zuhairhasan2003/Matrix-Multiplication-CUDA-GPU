
#include<cuda_runtime.h>
#include<stdio.h>
#include<stdlib.h>

__global__ void MatMul(int* mat1, int* mat2, int* ansMat, int row1, int col1row2, int col2)
{
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;


    if (row < row1 && col < col2)
    {
        int sum = 0;
        for (int k = 0; k < col1row2; k++)
        {
            sum += mat1[row * col1row2 + k] * mat2[col2 * k + col];
        }
        ansMat[row * col2 + col] = sum;
    }
}

void InitMatrix(int*, int, int);
void DisplayMatrix(int*, int, int);

int main()
{
    int row1 = 500;
    int col1 = 900;
    int* mat1 = (int*)malloc((row1 * col1) * sizeof(int));
    InitMatrix(mat1, row1, col1);


    int row2 = 900;
    int col2 = 500;
    int* mat2 = (int*)malloc((row2 * col2) * sizeof(int));
    InitMatrix(mat2, row2, col2);

    int ansMatRow = row1;
    int ansMatCol = col2;
    int* ansMat = (int*)malloc((ansMatCol * ansMatRow) * sizeof(int));

    int* d_mat1;
    int* d_mat2;
    int* d_ansMat;

    cudaMalloc((void**)&d_mat1, row1 * col1 * sizeof(int));
    cudaMalloc((void**)&d_mat2, row2 * col2 * sizeof(int));
    cudaMalloc((void**)&d_ansMat, ansMatCol * ansMatRow * sizeof(int));

    cudaMemcpy(d_mat1, mat1, (row1 * col1 * sizeof(int)), cudaMemcpyHostToDevice);
    cudaMemcpy(d_mat2, mat2, (row2 * col2 * sizeof(int)), cudaMemcpyHostToDevice);

    dim3 blockDim(16, 16);
    dim3 gridDim(col2 / blockDim.x + 1, row1 / blockDim.y + 1);

    MatMul << <gridDim, blockDim >> > (d_mat1, d_mat2, d_ansMat, row1, col1, col2);
    cudaDeviceSynchronize();

    cudaMemcpy(ansMat, d_ansMat, (row1 * col2 * sizeof(int)), cudaMemcpyDeviceToHost);

    //DisplayMatrix(mat1, row1, col1);
    //printf("\n");
    //DisplayMatrix(mat2, row2, col2);
    //printf("\n");
    //DisplayMatrix(ansMat, ansMatRow, ansMatCol);


    return 0;
}

void InitMatrix(int* mat, int row, int col)
{
    for (int i = 0; i < row; i++)
    {
        for (int j = 0; j < col; j++)
        {
            mat[(i * col) + j] = rand() % 5;
        }
    }
}

void DisplayMatrix(int* mat, int row, int col)
{
    for (int i = 0; i < row; i++)
    {
        printf("[  ");
        for (int j = 0; j < col; j++)
        {
            printf("%d   ", mat[(i * col) + j]);
        }
        printf("]\n");
    }
}
