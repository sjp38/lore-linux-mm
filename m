Date: Mon, 22 Sep 2008 08:58:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] hugetlbfs: add llseek method
Message-ID: <20080922075853.GA5905@csn.ul.ie>
References: <20080908174634.GC19912@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080908174634.GC19912@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/09/08 19:46), Christoph Hellwig didst pronounce:
> Hugetlbfs currently doesn't set a llseek method for regular files, which
> means it will fall back to default_llseek.  This means no one can seek
> beyond 2 Gigabytes.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

I am probably missing something embarassingly simple. My reading of this
description made me assume lseek64() must be broken so why does the following
test not fail?

/*
 * This test program writes numbers throughout a large hugetlb-backed file
 * and checks if lseek64 can be used to read beyond the 2GB file boundary.
 * mmap() is used to write the file as the write method is not supported on
 * hugetlbfs. To test the program
 * 1. mount -t hugetlbfs none /mnt
 * 2. echo NR_HUGE > /proc/sys/vm/nr_hugepages
 * 3. gcc -g -Wall hugetlbfs-llseek-test.c -o hugetlbfs-llseek-test && ./hugetlbfs-llseek-test
 *
 * where NR_HUGE would be 16 on POWER, 64 with 4M huge pagesize and 128 with
 * 2MB huge pagesize
 */
#define _LARGEFILE64_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>

#define FILE_NAME "/mnt/hugepagefile"
#define QGB (256UL*1024UL*1024UL)
#define NR_QGB 16
#define MAP_LENGTH (16UL*1024*1024)
#define PROTECTION (PROT_READ | PROT_WRITE)

/* Only ia64 requires this */
#ifdef __ia64__
#define ADDR (void *)(0x8000000000000000UL)
#define FLAGS (MAP_SHARED | MAP_FIXED | MAP_NORESERVE)
#else
#define ADDR (void *)(0x0UL)
#define FLAGS (MAP_SHARED)
#endif

int main(int argc, char **argv)
{
	char *addr;
	int fd, i;

	/*
	 * Open a hugetlbfs-backed file and then unlink it so we can exit
	 * and have the file automatically cleared up
	 */
	printf("Opening file " FILE_NAME "\n");
	fd = open(FILE_NAME, O_CREAT | O_RDWR, 0755);
	if (fd < 0) {
		perror("Open failed");
		exit(1);
	}
	unlink(FILE_NAME);

	/* Write a known value every quarter gigabyte of the file */
	printf("Attemping write mmap: ");
	for (i = 0; i < NR_QGB; i++) {
		off_t offset = i * QGB;

		addr = mmap(ADDR, MAP_LENGTH, PROTECTION, FLAGS, fd, offset);
		if (addr == MAP_FAILED) {
			printf("FAIL mmap %d\n", i);
			perror("mmap");
			exit(-1);
		}
		*addr = i;
		munmap(addr, MAP_LENGTH);
	}
	printf(" PASS\n");

	/* Attempt to read the values back using lseek64 */
	printf("Attemping read seek: ");
	for (i = 0; i < NR_QGB; i++) {
		char val = 0;
		off64_t offset = i * QGB;

		printf("%d ", i);
		if (lseek64(fd, offset, SEEK_SET) != offset) {
			printf("FAIL seek %llu\n", offset);
			perror("lseek");
			exit(-1);
		}

		if (read(fd, &val, 1) == -1 || val != i) {
			printf("FAIL read %d != %d\n", val, i);
			perror("read");
			exit(-1);
		}

	}
	printf("\nTest passed successfully\n");

	close(fd);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
