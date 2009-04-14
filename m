Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BAFC45F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 02:19:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E6JQCI029864
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 15:19:26 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ECBA45DE51
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:19:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E0E9145DD79
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:19:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B41D9E38003
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:19:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A1751DB8041
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:19:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v3 3/6] nfs, direct-io: fix fork vs direct-io race on nfs
In-Reply-To: <20090414151204.C647.A69D9226@jp.fujitsu.com>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
Message-Id: <20090414151806.C650.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 15:19:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] nfs, direct-io: fix fork vs direct-io race on nfs

After fs/diorect-io.c fix, following testcase still fail on nfs running.
it's because nfs has own specific diorct-io implementation.

========== dma_thread.c =======
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
========== dma_thread.c =======


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/direct.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

Index: b/fs/nfs/direct.c
===================================================================
--- a/fs/nfs/direct.c	2009-04-13 00:22:32.000000000 +0900
+++ b/fs/nfs/direct.c	2009-04-13 01:03:35.000000000 +0900
@@ -85,6 +85,8 @@ struct nfs_direct_req {
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
 	struct nfs_writeverf	verf;		/* unstable write verifier */
+
+	struct mm_struct	*mm;		/* for fork() exclusive */
 };
 
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq, struct inode *inode);
@@ -164,6 +166,7 @@ static inline struct nfs_direct_req *nfs
 	dreq->count = 0;
 	dreq->error = 0;
 	dreq->flags = 0;
+	dreq->mm = NULL;
 
 	return dreq;
 }
@@ -216,6 +219,10 @@ static void nfs_direct_complete(struct n
 			res = (long) dreq->count;
 		aio_complete(dreq->iocb, res, 0);
 	}
+	if (dreq->mm) {
+		up_read_non_owner(&dreq->mm->mm_pinned_sem);
+		mmdrop(dreq->mm);
+	}
 	complete_all(&dreq->completion);
 
 	nfs_direct_req_release(dreq);
@@ -306,10 +313,8 @@ static ssize_t nfs_direct_read_schedule_
 		if (unlikely(!data))
 			break;
 
-		down_read(&current->mm->mmap_sem);
-		result = get_user_pages(current, current->mm, user_addr,
-					data->npages, 1, 0, data->pagevec, NULL);
-		up_read(&current->mm->mmap_sem);
+		result = get_user_pages_fast(user_addr, data->npages, 1,
+					     data->pagevec);
 		if (result < 0) {
 			nfs_readdata_release(data);
 			break;
@@ -383,8 +388,12 @@ static ssize_t nfs_direct_read_schedule_
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
 	unsigned long seg;
+	struct mm_struct *mm;
 
 	get_dreq(dreq);
+	mm = dreq->mm = current->mm;
+	atomic_inc(&mm->mm_count);
+	down_read_non_owner(&mm->mm_pinned_sem);
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
