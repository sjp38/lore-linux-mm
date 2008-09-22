Date: Mon, 22 Sep 2008 19:56:25 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] hugetlbfs: add llseek method
Message-ID: <20080922185624.GA26551@csn.ul.ie>
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

I took another look at this as it was pointed out to me by apw that this
might be a SEEK_CUR vs SEEK_SET thing and also whether lseek() was the
key. To use lseek though, the large file defines had to be used or it failed
whether your patch was applied or not. The error as you'd expect is lseek()
complaining that the type was too small.

At the face of it, the patch seems sensible but it works whether it is set
or not so clearly I'm still missing something. The second test I tried is
below. In the unlikely event it makes a difference, I was testing on qemu
for i386.

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
#define _FILE_OFFSET_BITS 64
#define _LARGEFILE64_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>

#define FILE_NAME "/mnt/hugepagefile"
#define QGB (256UL*1024UL*1024UL)
#define NR_QGB 15
#define MAP_LENGTH (16UL*1024*1024)
#define PROTECTION (PROT_READ | PROT_WRITE)

/* Only ia64 requires this */
#ifdef __ia64__
#define ADDR (void *)(0x8000000000000000UL)
#define FLAGS (MAP_SHARED | MAP_FIXED)
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
	 * and have the file cleared up
	 */
	printf("Opening file " FILE_NAME "\n");
	fd = open(FILE_NAME, O_CREAT | O_RDWR | O_LARGEFILE, 0755);
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
		off_t offset = (i + 1) * QGB;
		off_t ret;

		printf("%d ", i);
		if (read(fd, &val, 1) == -1 || val != i) {
			printf("FAIL read %d != %d\n", val, i);
			perror("read");
			exit(-1);
		}

		ret = lseek(fd, QGB - 1, SEEK_CUR);
		if (ret != offset) {
			printf("FAIL seek %llu != %llu\n", offset, ret);
			perror("lseek");
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
