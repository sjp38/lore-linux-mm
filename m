Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD3B900002
	for <linux-mm@kvack.org>; Thu, 26 Jun 2014 22:11:08 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so3926746pbc.31
        for <linux-mm@kvack.org>; Thu, 26 Jun 2014 19:11:08 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id xi3si12179369pab.111.2014.06.26.19.11.06
        for <linux-mm@kvack.org>;
        Thu, 26 Jun 2014 19:11:07 -0700 (PDT)
Message-ID: <53ACD20B.2030601@cn.fujitsu.com>
Date: Fri, 27 Jun 2014 10:08:11 +0800
From: Xiaoguang Wang <wangxg.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Corruption with O_DIRECT and unaligned user buffers
Content-Type: multipart/mixed;
	boundary="------------020305080509070701090509"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, chrubis@suse.cz

--------------020305080509070701090509
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

Hi maintainers,

In August 2008, there was a discussion about 'Corruption with O_DIRECT and unaligned user buffers',
please have a look at this url: http://thread.gmane.org/gmane.linux.file-systems/27358

The attached test program written by Tim has been added to LTP, please see this below url:
https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/io/direct_io/dma_thread_diotest.c


Now I tested this program in kernel 3.16.0-rc1+, it seems that the date corruption still exists. Meanwhile
there is also such a section in open(2)'s manpage warning that O_DIRECT I/Os should never be run
concurrently with the fork(2) system call. Please see below section:

    O_DIRECT I/Os should never be run concurrently with the fork(2) system call, if the memory buffer
    is a private mapping (i.e., any mapping created with the mmap(2) MAP_PRIVATE flag; this includes
    memory allocated on the heap and statically allocated buffers).  Any such I/Os, whether  submitted
    via an asynchronous I/O interface or from another thread in the process, should be completed before
    fork(2) is called.  Failure to do so can result in data corruption and undefined behavior in parent
    and child processes.  This restriction does not apply when the memory buffer for  the  O_DIRECT
    I/Os  was  created  using shmat(2) or mmap(2) with the MAP_SHARED flag.  Nor does this restriction
    apply when the memory buffer has been advised as MADV_DONTFORK with madvise(2), ensuring that it will
    not be available to the child after fork(2).

Hmm, so I'd like to know whether you have some plans to fix this bug, or this is not considered as a
bug, it's just a programming specification that we should avoid doing fork() while we are having O_DIRECT
file operation with non-page aligned IO, thanks.

Steps to run this attached program:
1. ./dma_thread  # create temp files
2. ./dma_thread -a 512 -w 8 $ alignment is 512 and create 8 threads.


Regards,
Xiaoguang Wang

--------------020305080509070701090509
Content-Type: text/x-csrc; name="dma_thread.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="dma_thread.c"

/* compile with 'gcc -g -o dma_thread dma_thread.c -lpthread' */

#define _GNU_SOURCE 1

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <memory.h>
#include <pthread.h>
#include <getopt.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>

#define FILESIZE (12*1024*1024) 
#define READSIZE  (1024*1024)

#define FILENAME    "test_%.04d.tmp"
#define FILECOUNT   100
#define MIN_WORKERS 2
#define MAX_WORKERS 256
#define PAGE_SIZE   4096

#define true	1
#define false	0

typedef int bool;

bool	done	= false;
int	workers = 2;

#define PATTERN (0xfa)

static void
usage (void)
{
    fprintf(stderr, "\nUsage: dma_thread [-h | -a <alignment> [ -w <workers>]\n"
		    "\nWith no arguments, generate test files and exit.\n"
		    "-h Display this help and exit.\n"
		    "-a align read buffer to offset <alignment>.\n"
		    "-w number of worker threads, 2 (default) to 256,\n"
		    "   defaults to number of cores.\n\n"

		    "Run first with no arguments to generate files.\n"
		    "Then run with -a <alignment> = 512  or 0. \n");
}

typedef struct {
    pthread_t	    tid;
    int		    worker_number;
    int		    fd;
    int		    offset;
    int		    length;
    int		    pattern;
    unsigned char  *buffer;
} worker_t;


void *worker_thread(void * arg)
{
    int		    bytes_read;
    int		    i,k;
    worker_t	   *worker  = (worker_t *) arg;
    int		    offset  = worker->offset;
    int		    fd	    = worker->fd;
    unsigned char  *buffer  = worker->buffer;
    int		    pattern = worker->pattern;
    int		    length  = worker->length;
    
    if (lseek(fd, offset, SEEK_SET) < 0) {
	fprintf(stderr, "Failed to lseek to %d on fd %d: %s.\n", 
			offset, fd, strerror(errno));
	exit(1);
    }

    bytes_read = read(fd, buffer, length);
    if (bytes_read != length) {
	fprintf(stderr, "read failed on fd %d: bytes_read %d, %s\n", 
			fd, bytes_read, strerror(errno));
	exit(1);
    }

    /* Corruption check */
    for (i = 0; i < length; i++) {
	if (buffer[i] != pattern) {
	    printf("Bad data at 0x%.06x: %p, \n", i, buffer + i);
	    printf("Data dump starting at 0x%.06x:\n", i - 8);
	    printf("Expect 0x%x followed by 0x%x:\n",
		    pattern, PATTERN);

	    for (k = 0; k < 16; k++) {
		printf("%02x ", buffer[i - 8 + k]);
		if (k == 7) {
		    printf("\n");
		}       
	    }

	    printf("\n");
	    abort();
	}
    }

    return 0;
}

void *fork_thread (void *arg) 
{
    pid_t pid;

    while (!done) {
	pid = fork();
	if (pid == 0) {
	    exit(0);
	} else if (pid < 0) {
	    fprintf(stderr, "Failed to fork child.\n");
	    exit(1);
	} 
	waitpid(pid, NULL, 0 );
	usleep(100);
    }

    return NULL;

}

int main(int argc, char *argv[])
{
    unsigned char  *buffer = NULL;
    char	    filename[1024];
    int		    fd;
    bool	    dowrite = true;
    pthread_t	    fork_tid;
    int		    c, n, j;
    worker_t	   *worker;
    int		    align = 0;
    int		    offset, rc;

    workers = sysconf(_SC_NPROCESSORS_ONLN);

    while ((c = getopt(argc, argv, "a:hw:")) != -1) {
	switch (c) {
	case 'a':
	    align = atoi(optarg);
	    if (align < 0 || align > PAGE_SIZE) {
		printf("Bad alignment %d.\n", align);
		exit(1);
	    }
	    dowrite = false;
	    break;

	case 'h':
	    usage();
	    exit(0);
	    break;

	case 'w':
	    workers = atoi(optarg);
	    if (workers < MIN_WORKERS || workers > MAX_WORKERS) {
		fprintf(stderr, "Worker count %d not between "
				"%d and %d, inclusive.\n",
				workers, MIN_WORKERS, MAX_WORKERS);
		usage();
		exit(1);
	    }
	    dowrite = false;
	    break;

	default:
	    usage();
	    exit(1);
	}
    }

    if (argc > 1 && (optind < argc)) {
	fprintf(stderr, "Bad command line.\n");
	usage();
	exit(1);
    }

    if (dowrite) {

	buffer = malloc(FILESIZE);
	if (buffer == NULL) {
	    fprintf(stderr, "Failed to malloc write buffer.\n");
	    exit(1);
	}

	for (n = 1; n <= FILECOUNT; n++) {
	    sprintf(filename, FILENAME, n);
	    fd = open(filename, O_RDWR|O_CREAT|O_TRUNC, 0666);
	    if (fd < 0) {
		printf("create failed(%s): %s.\n", filename, strerror(errno));
		exit(1);
	    }
	    memset(buffer, n, FILESIZE);
	    printf("Writing file %s.\n", filename);
	    if (write(fd, buffer, FILESIZE) != FILESIZE) {
		printf("write failed (%s)\n", filename);
	    }

	    close(fd);
	    fd = -1;
	}

	free(buffer);
	buffer = NULL;

	printf("done\n");
	exit(0);
    }

    printf("Using %d workers.\n", workers);

    worker = malloc(workers * sizeof(worker_t));
    if (worker == NULL) {
	fprintf(stderr, "Failed to malloc worker array.\n");
	exit(1);
    }

    for (j = 0; j < workers; j++) {
	worker[j].worker_number = j;
    }

    printf("Using alignment %d.\n", align);
    
    posix_memalign((void *)&buffer, PAGE_SIZE, READSIZE+ align);
    printf("Read buffer: %p.\n", buffer);
    for (n = 1; n <= FILECOUNT; n++) {

	sprintf(filename, FILENAME, n);
	for (j = 0; j < workers; j++) {
	    if ((worker[j].fd = open(filename,  O_RDONLY|O_DIRECT)) < 0) {
		fprintf(stderr, "Failed to open %s: %s.\n",
				filename, strerror(errno));
		exit(1);
	    }

	    worker[j].pattern = n;
	}

	printf("Reading file %d.\n", n);

	for (offset = 0; offset < FILESIZE; offset += READSIZE) {
	    memset(buffer, PATTERN, READSIZE + align);
	    for (j = 0; j < workers; j++) {
		worker[j].offset = offset + j * PAGE_SIZE;
		worker[j].buffer = buffer + align + j * PAGE_SIZE;
		worker[j].length = PAGE_SIZE;
	    }
	    /* The final worker reads whatever is left over. */
	    worker[workers - 1].length = READSIZE - PAGE_SIZE * (workers - 1);

	    done = 0;

	    rc = pthread_create(&fork_tid, NULL, fork_thread, NULL);
	    if (rc != 0) {
		fprintf(stderr, "Can't create fork thread: %s.\n", 
				strerror(rc));
		exit(1);
	    }

	    for (j = 0; j < workers; j++) {
		rc = pthread_create(&worker[j].tid, 
				    NULL, 
				    worker_thread, 
				    worker + j);
		if (rc != 0) {
		    fprintf(stderr, "Can't create worker thread %d: %s.\n", 
				    j, strerror(rc));
		    exit(1);
		}
	    }

	    for (j = 0; j < workers; j++) {
		rc = pthread_join(worker[j].tid, NULL);
		if (rc != 0) {
		    fprintf(stderr, "Failed to join worker thread %d: %s.\n",
				    j, strerror(rc));
		    exit(1);
		}
	    }

	    /* Let the fork thread know it's ok to exit */
	    done = 1;

	    rc = pthread_join(fork_tid, NULL);
	    if (rc != 0) {
		fprintf(stderr, "Failed to join fork thread: %s.\n",
				strerror(rc));
		exit(1);
	    }
	}

	/* Close the fd's for the next file. */
	for (j = 0; j < workers; j++) {
	    close(worker[j].fd);
	}
    }

    return 0;
}

--------------020305080509070701090509--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
