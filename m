Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C9A3A5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 02:25:32 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E6PsRI022731
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 15:25:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A1C1A45DE52
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:25:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FAA945DE4F
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:25:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C6A81DB805B
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:25:54 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ECC6A1DB803C
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:25:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 2/6] mm, directio: fix fork vs direct-io race (read(2) side IOW gup(write) side)
In-Reply-To: <20090414151652.C64D.A69D9226@jp.fujitsu.com>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <20090414151652.C64D.A69D9226@jp.fujitsu.com>
Message-Id: <20090414152500.C65F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 15:25:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Zach Brown <zach.brown@oracle.com>, Andy Grover <andy.grover@oracle.com>
List-ID: <linux-mm.kvack.org>


Oops, I forgot some cc. resend it.

> Subject: [PATCH] mm, directio: fix fork vs direct-io race
> 
> 
> ChangeLog:
> V2 -> V3
>    o remove early decow logic
> 
> V1 -> V2
>    o add dio+aio logic
> 
> ===============================================
> 
> Currently, following testcase is failed.
> 
> & dma_thread -a 512 -w 40
> 
> ========== dma_thread.c =======
> /* compile with 'gcc -g -o dma_thread dma_thread.c -lpthread' */
> 
> #define _GNU_SOURCE 1
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <memory.h>
> #include <pthread.h>
> #include <getopt.h>
> #include <errno.h>
> #include <sys/types.h>
> #include <sys/wait.h>
> 
> #define FILESIZE (12*1024*1024) 
> #define READSIZE  (1024*1024)
> 
> #define FILENAME    "test_%.04d.tmp"
> #define FILECOUNT   100
> #define MIN_WORKERS 2
> #define MAX_WORKERS 256
> #define PAGE_SIZE   4096
> 
> #define true	1
> #define false	0
> 
> typedef int bool;
> 
> bool	done	= false;
> int	workers = 2;
> 
> #define PATTERN (0xfa)
> 
> static void
> usage (void)
> {
>     fprintf(stderr, "\nUsage: dma_thread [-h | -a <alignment> [ -w <workers>]\n"
> 		    "\nWith no arguments, generate test files and exit.\n"
> 		    "-h Display this help and exit.\n"
> 		    "-a align read buffer to offset <alignment>.\n"
> 		    "-w number of worker threads, 2 (default) to 256,\n"
> 		    "   defaults to number of cores.\n\n"
> 
> 		    "Run first with no arguments to generate files.\n"
> 		    "Then run with -a <alignment> = 512  or 0. \n");
> }
> 
> typedef struct {
>     pthread_t	    tid;
>     int		    worker_number;
>     int		    fd;
>     int		    offset;
>     int		    length;
>     int		    pattern;
>     unsigned char  *buffer;
> } worker_t;
> 
> 
> void *worker_thread(void * arg)
> {
>     int		    bytes_read;
>     int		    i,k;
>     worker_t	   *worker  = (worker_t *) arg;
>     int		    offset  = worker->offset;
>     int		    fd	    = worker->fd;
>     unsigned char  *buffer  = worker->buffer;
>     int		    pattern = worker->pattern;
>     int		    length  = worker->length;
>     
>     if (lseek(fd, offset, SEEK_SET) < 0) {
> 	fprintf(stderr, "Failed to lseek to %d on fd %d: %s.\n", 
> 			offset, fd, strerror(errno));
> 	exit(1);
>     }
> 
>     bytes_read = read(fd, buffer, length);
>     if (bytes_read != length) {
> 	fprintf(stderr, "read failed on fd %d: bytes_read %d, %s\n", 
> 			fd, bytes_read, strerror(errno));
> 	exit(1);
>     }
> 
>     /* Corruption check */
>     for (i = 0; i < length; i++) {
> 	if (buffer[i] != pattern) {
> 	    printf("Bad data at 0x%.06x: %p, \n", i, buffer + i);
> 	    printf("Data dump starting at 0x%.06x:\n", i - 8);
> 	    printf("Expect 0x%x followed by 0x%x:\n",
> 		    pattern, PATTERN);
> 
> 	    for (k = 0; k < 16; k++) {
> 		printf("%02x ", buffer[i - 8 + k]);
> 		if (k == 7) {
> 		    printf("\n");
> 		}       
> 	    }
> 
> 	    printf("\n");
> 	    abort();
> 	}
>     }
> 
>     return 0;
> }
> 
> void *fork_thread (void *arg) 
> {
>     pid_t pid;
> 
>     while (!done) {
> 	pid = fork();
> 	if (pid == 0) {
> 	    exit(0);
> 	} else if (pid < 0) {
> 	    fprintf(stderr, "Failed to fork child.\n");
> 	    exit(1);
> 	} 
> 	waitpid(pid, NULL, 0 );
> 	usleep(100);
>     }
> 
>     return NULL;
> 
> }
> 
> int main(int argc, char *argv[])
> {
>     unsigned char  *buffer = NULL;
>     char	    filename[1024];
>     int		    fd;
>     bool	    dowrite = true;
>     pthread_t	    fork_tid;
>     int		    c, n, j;
>     worker_t	   *worker;
>     int		    align = 0;
>     int		    offset, rc;
> 
>     workers = sysconf(_SC_NPROCESSORS_ONLN);
> 
>     while ((c = getopt(argc, argv, "a:hw:")) != -1) {
> 	switch (c) {
> 	case 'a':
> 	    align = atoi(optarg);
> 	    if (align < 0 || align > PAGE_SIZE) {
> 		printf("Bad alignment %d.\n", align);
> 		exit(1);
> 	    }
> 	    dowrite = false;
> 	    break;
> 
> 	case 'h':
> 	    usage();
> 	    exit(0);
> 	    break;
> 
> 	case 'w':
> 	    workers = atoi(optarg);
> 	    if (workers < MIN_WORKERS || workers > MAX_WORKERS) {
> 		fprintf(stderr, "Worker count %d not between "
> 				"%d and %d, inclusive.\n",
> 				workers, MIN_WORKERS, MAX_WORKERS);
> 		usage();
> 		exit(1);
> 	    }
> 	    dowrite = false;
> 	    break;
> 
> 	default:
> 	    usage();
> 	    exit(1);
> 	}
>     }
> 
>     if (argc > 1 && (optind < argc)) {
> 	fprintf(stderr, "Bad command line.\n");
> 	usage();
> 	exit(1);
>     }
> 
>     if (dowrite) {
> 
> 	buffer = malloc(FILESIZE);
> 	if (buffer == NULL) {
> 	    fprintf(stderr, "Failed to malloc write buffer.\n");
> 	    exit(1);
> 	}
> 
> 	for (n = 1; n <= FILECOUNT; n++) {
> 	    sprintf(filename, FILENAME, n);
> 	    fd = open(filename, O_RDWR|O_CREAT|O_TRUNC, 0666);
> 	    if (fd < 0) {
> 		printf("create failed(%s): %s.\n", filename, strerror(errno));
> 		exit(1);
> 	    }
> 	    memset(buffer, n, FILESIZE);
> 	    printf("Writing file %s.\n", filename);
> 	    if (write(fd, buffer, FILESIZE) != FILESIZE) {
> 		printf("write failed (%s)\n", filename);
> 	    }
> 
> 	    close(fd);
> 	    fd = -1;
> 	}
> 
> 	free(buffer);
> 	buffer = NULL;
> 
> 	printf("done\n");
> 	exit(0);
>     }
> 
>     printf("Using %d workers.\n", workers);
> 
>     worker = malloc(workers * sizeof(worker_t));
>     if (worker == NULL) {
> 	fprintf(stderr, "Failed to malloc worker array.\n");
> 	exit(1);
>     }
> 
>     for (j = 0; j < workers; j++) {
> 	worker[j].worker_number = j;
>     }
> 
>     printf("Using alignment %d.\n", align);
>     
>     posix_memalign((void *)&buffer, PAGE_SIZE, READSIZE+ align);
>     printf("Read buffer: %p.\n", buffer);
>     for (n = 1; n <= FILECOUNT; n++) {
> 
> 	sprintf(filename, FILENAME, n);
> 	for (j = 0; j < workers; j++) {
> 	    if ((worker[j].fd = open(filename,  O_RDONLY|O_DIRECT)) < 0) {
> 		fprintf(stderr, "Failed to open %s: %s.\n",
> 				filename, strerror(errno));
> 		exit(1);
> 	    }
> 
> 	    worker[j].pattern = n;
> 	}
> 
> 	printf("Reading file %d.\n", n);
> 
> 	for (offset = 0; offset < FILESIZE; offset += READSIZE) {
> 	    memset(buffer, PATTERN, READSIZE + align);
> 	    for (j = 0; j < workers; j++) {
> 		worker[j].offset = offset + j * PAGE_SIZE;
> 		worker[j].buffer = buffer + align + j * PAGE_SIZE;
> 		worker[j].length = PAGE_SIZE;
> 	    }
> 	    /* The final worker reads whatever is left over. */
> 	    worker[workers - 1].length = READSIZE - PAGE_SIZE * (workers - 1);
> 
> 	    done = 0;
> 
> 	    rc = pthread_create(&fork_tid, NULL, fork_thread, NULL);
> 	    if (rc != 0) {
> 		fprintf(stderr, "Can't create fork thread: %s.\n", 
> 				strerror(rc));
> 		exit(1);
> 	    }
> 
> 	    for (j = 0; j < workers; j++) {
> 		rc = pthread_create(&worker[j].tid, 
> 				    NULL, 
> 				    worker_thread, 
> 				    worker + j);
> 		if (rc != 0) {
> 		    fprintf(stderr, "Can't create worker thread %d: %s.\n", 
> 				    j, strerror(rc));
> 		    exit(1);
> 		}
> 	    }
> 
> 	    for (j = 0; j < workers; j++) {
> 		rc = pthread_join(worker[j].tid, NULL);
> 		if (rc != 0) {
> 		    fprintf(stderr, "Failed to join worker thread %d: %s.\n",
> 				    j, strerror(rc));
> 		    exit(1);
> 		}
> 	    }
> 
> 	    /* Let the fork thread know it's ok to exit */
> 	    done = 1;
> 
> 	    rc = pthread_join(fork_tid, NULL);
> 	    if (rc != 0) {
> 		fprintf(stderr, "Failed to join fork thread: %s.\n",
> 				strerror(rc));
> 		exit(1);
> 	    }
> 	}
> 
> 	/* Close the fd's for the next file. */
> 	for (j = 0; j < workers; j++) {
> 	    close(worker[j].fd);
> 	}
>     }
> 
>     return 0;
> }
> ========== dma_thread.c =======
> 
> Because following scenario happend.
> 
>    CPU0            CPU1                       CPU2                note
>   (fork thread)    (worker thread1)           (worker thread2)
> ==========================================================================================
>                    read()
>                    | get_user_pages()
>                    |
>   fork             |                                              inc map_count and wprotect
>                    |
>                    |                         read()
>                    |                         | get_user_pages()   COW break, CPU2 get copyed page,
>                    |                         |                    but CPU1 still point to original page.
>                    |                         |                    then the result of CPU1 transfer will be lost.
>                    v                         |
>                                              |
>                                              |
>                                              v
> 
> 
> Actually, get_user_pages() (and get_user_pages_fast()) don't provide any pinning operation.
> Caller must prevent fork in critical section.
> access_process_vm() explain standard fork protection way, it use mmap_sem.
> 
> but, mmap_sem is very easy contended lock. it cause large performance regression to DirectIO.
> Then, this patch introduce new lock for another fork prevent mechanism.
> Almost application don't fork while DirectIO in progress, then mm_pinned_sem doesn't contend in almost case.
> 
> 
> Also, this patch fix following aio+dio testcase.
> 
> ========== forkscrew.c ========
> /*
>  * Copyright 2009, Red Hat, Inc.
>  *
>  * Author: Jeff Moyer <jmoyer@redhat.com>
>  *
>  * This program attempts to expose a race between O_DIRECT I/O and the fork()
>  * path in a multi-threaded program.  In order to reliably reproduce the
>  * problem, it is best to perform a dd from the device under test to /dev/null
>  * as this makes the read I/O slow enough to orchestrate the problem.
>  *
>  * Running:  ./forkscrew
>  *
>  * It is expected that a file name "data" exists in the current working
>  * directory, and that its contents are something other than 0x2a.  A simple
>  * dd if=/dev/zero of=data bs=1M count=1 should be sufficient.
>  */
> #define _GNU_SOURCE 1
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <errno.h>
> #include <sys/types.h>
> #include <sys/wait.h>
> 
> #include <pthread.h>
> #include <libaio.h>
> 
> pthread_cond_t worker_cond = PTHREAD_COND_INITIALIZER;
> pthread_mutex_t worker_mutex = PTHREAD_MUTEX_INITIALIZER;
> pthread_cond_t fork_cond = PTHREAD_COND_INITIALIZER;
> pthread_mutex_t fork_mutex = PTHREAD_MUTEX_INITIALIZER;
> 
> char *buffer;
> int fd;
> 
> /* pattern filled into the in-memory buffer */
> #define PATTERN		0x2a  // '*'
> 
> void
> usage(void)
> {
> 	fprintf(stderr,
> 		"\nUsage: forkscrew\n"
> 		"it is expected that a file named \"data\" is the current\n"
> 		"working directory.  It should be at least 3*pagesize in size\n"
> 		);
> }
> 
> void
> dump_buffer(char *buf, int len)
> {
> 	int i;
> 	int last_off, last_val;
> 
> 	last_off = -1;
> 	last_val = -1;
> 
> 	for (i = 0; i < len; i++) {
> 		if (last_off < 0) {
> 			last_off = i;
> 			last_val = buf[i];
> 			continue;
> 		}
> 
> 		if (buf[i] != last_val) {
> 			printf("%d - %d: %d\n", last_off, i - 1, last_val);
> 			last_off = i;
> 			last_val = buf[i];
> 		}
> 	}
> 
> 	if (last_off != len - 1)
> 		printf("%d - %d: %d\n", last_off, i-1, last_val);
> }
> 
> int
> check_buffer(char *bufp, int len, int pattern)
> {
> 	int i;
> 
> 	for (i = 0; i < len; i++) {
> 		if (bufp[i] == pattern)
> 			return 1;
> 	}
> 	return 0;
> }
> 
> void *
> forker_thread(void *arg)
> {
> 	pthread_mutex_lock(&fork_mutex);
> 	pthread_cond_signal(&fork_cond);
> 	pthread_cond_wait(&fork_cond, &fork_mutex);
> 	switch (fork()) {
> 	case 0:
> 		sleep(1);
> 		printf("child dumping buffer:\n");
> 		dump_buffer(buffer + 512, 2*getpagesize());
> 		exit(0);
> 	case -1:
> 		perror("fork");
> 		exit(1);
> 	default:
> 		break;
> 	}
> 	pthread_cond_signal(&fork_cond);
> 	pthread_mutex_unlock(&fork_mutex);
> 
> 	wait(NULL);
> 	return (void *)0;
> }
> 
> void *
> worker(void *arg)
> {
> 	int first = (int)arg;
> 	char *bufp;
> 	int pagesize = getpagesize();
> 	int ret;
> 	int corrupted = 0;
> 
> 	if (first) {
> 		io_context_t aioctx;
> 		struct io_event event;
> 		struct iocb *iocb = malloc(sizeof *iocb);
> 		if (!iocb) {
> 			perror("malloc");
> 			exit(1);
> 		}
> 		memset(&aioctx, 0, sizeof(aioctx));
> 		ret = io_setup(1, &aioctx);
> 		if (ret != 0) {
> 			errno = -ret;
> 			perror("io_setup");
> 			exit(1);
> 		}
> 		bufp = buffer + 512;
> 		io_prep_pread(iocb, fd, bufp, pagesize, 0);
> 
> 		/* submit the I/O */
> 		io_submit(aioctx, 1, &iocb);
> 
> 		/* tell the fork thread to run */
> 		pthread_mutex_lock(&fork_mutex);
> 		pthread_cond_signal(&fork_cond);
> 
> 		/* wait for the fork to happen */
> 		pthread_cond_wait(&fork_cond, &fork_mutex);
> 		pthread_mutex_unlock(&fork_mutex);
> 
> 		/* release the other worker to issue I/O */
> 		pthread_mutex_lock(&worker_mutex);
> 		pthread_cond_signal(&worker_cond);
> 		pthread_mutex_unlock(&worker_mutex);
> 
> 		ret = io_getevents(aioctx, 1, 1, &event, NULL);
> 		if (ret != 1) {
> 			errno = -ret;
> 			perror("io_getevents");
> 			exit(1);
> 		}
> 		if (event.res != pagesize) {
> 			errno = -event.res;
> 			perror("read error");
> 			exit(1);
> 		}
> 
> 		io_destroy(aioctx);
> 
> 		/* check buffer, should be corrupt */
> 		if (check_buffer(bufp, pagesize, PATTERN)) {
> 			printf("worker 0 failed check\n");
> 			dump_buffer(bufp, pagesize);
> 			corrupted = 1;
> 		}
> 
> 	} else {
> 
> 		bufp = buffer + 512 + pagesize;
> 
> 		pthread_mutex_lock(&worker_mutex);
> 		pthread_cond_signal(&worker_cond); /* tell main we're ready */
> 		/* wait for the first I/O and the fork */
> 		pthread_cond_wait(&worker_cond, &worker_mutex);
> 		pthread_mutex_unlock(&worker_mutex);
> 
> 		/* submit overlapping I/O */
> 		ret = read(fd, bufp, pagesize);
> 		if (ret != pagesize) {
> 			perror("read");
> 			exit(1);
> 		}
> 		/* check buffer, should be fine */
> 		if (check_buffer(bufp, pagesize, PATTERN)) {
> 			printf("worker 1 failed check -- abnormal\n");
> 			dump_buffer(bufp, pagesize);
> 			corrupted = 1;
> 		}
> 	}
> 
> 	return (void *)corrupted;
> }
> 
> int
> main(int argc, char **argv)
> {
> 	pthread_t workers[2];
> 	pthread_t forker;
> 	int ret, rc = 0;
> 	void *thread_ret;
> 	int pagesize = getpagesize();
> 
> 	fd = open("data", O_DIRECT|O_RDONLY);
> 	if (fd < 0) {
> 		perror("open");
> 		exit(1);
> 	}
> 
> 	ret = posix_memalign(&buffer, pagesize, 3 * pagesize);
> 	if (ret != 0) {
> 		errno = ret;
> 		perror("posix_memalign");
> 		exit(1);
> 	}
> 	memset(buffer, PATTERN, 3*pagesize);
> 
> 	pthread_mutex_lock(&fork_mutex);
> 	ret = pthread_create(&forker, NULL, forker_thread, NULL);
> 	pthread_cond_wait(&fork_cond, &fork_mutex);
> 	pthread_mutex_unlock(&fork_mutex);
> 
> 	pthread_mutex_lock(&worker_mutex);
> 	ret |= pthread_create(&workers[0], NULL, worker, (void *)0);
> 	if (ret) {
> 		perror("pthread_create");
> 		exit(1);
> 	}
> 	pthread_cond_wait(&worker_cond, &worker_mutex);
> 	pthread_mutex_unlock(&worker_mutex);
> 
> 	ret = pthread_create(&workers[1], NULL, worker, (void *)1);
> 	if (ret != 0) {
> 		perror("pthread_create");
> 		exit(1);
> 	}
> 
> 	pthread_join(forker, NULL);
> 	pthread_join(workers[0], &thread_ret);
> 	if (thread_ret != 0)
> 		rc = 1;
> 	pthread_join(workers[1], &thread_ret);
> 	if (thread_ret != 0)
> 		rc = 1;
> 
> 	if (rc != 0) {
> 		printf("parent dumping full buffer\n");
> 		dump_buffer(buffer + 512, 2 * pagesize);
> 	}
> 
> 	close(fd);
> 	free(buffer);
> 	exit(rc);
> }
> ========== forkscrew.c ========
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Sugessted-by: Linus Torvalds <torvalds@osdl.org>
> Cc: Hugh Dickins <hugh@veritas.com>
> Cc: Andrew Morton <akpm@osdl.org>
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Zach Brown <zach.brown@oracle.com>
> Cc: Andy Grover <andy.grover@oracle.com>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  fs/direct-io.c            |   16 ++++++++++++++++
>  include/linux/init_task.h |    1 +
>  include/linux/mm_types.h  |    6 ++++++
>  kernel/fork.c             |    3 +++
>  4 files changed, 26 insertions(+)
> 
> Index: b/fs/direct-io.c
> ===================================================================
> --- a/fs/direct-io.c	2009-04-13 00:24:01.000000000 +0900
> +++ b/fs/direct-io.c	2009-04-13 01:36:37.000000000 +0900
> @@ -131,6 +131,9 @@ struct dio {
>  	int is_async;			/* is IO async ? */
>  	int io_error;			/* IO error in completion path */
>  	ssize_t result;                 /* IO result */
> +
> +	/* fork exclusive stuff */
> +	struct mm_struct *mm;
>  };
>  
>  /*
> @@ -244,6 +247,12 @@ static int dio_complete(struct dio *dio,
>  		/* lockdep: non-owner release */
>  		up_read_non_owner(&dio->inode->i_alloc_sem);
>  
> +	if (dio->rw == READ) {
> +		BUG_ON(!dio->mm);
> +		up_read_non_owner(&dio->mm->mm_pinned_sem);
> +		mmdrop(dio->mm);
> +	}
> +
>  	if (ret == 0)
>  		ret = dio->page_errors;
>  	if (ret == 0)
> @@ -942,6 +951,7 @@ direct_io_worker(int rw, struct kiocb *i
>  	ssize_t ret = 0;
>  	ssize_t ret2;
>  	size_t bytes;
> +	struct mm_struct *mm;
>  
>  	dio->inode = inode;
>  	dio->rw = rw;
> @@ -960,6 +970,12 @@ direct_io_worker(int rw, struct kiocb *i
>  	spin_lock_init(&dio->bio_lock);
>  	dio->refcount = 1;
>  
> +	if (rw == READ) {
> +		mm = dio->mm = current->mm;
> +		atomic_inc(&mm->mm_count);
> +		down_read_non_owner(&mm->mm_pinned_sem);
> +	}
> +
>  	/*
>  	 * In case of non-aligned buffers, we may need 2 more
>  	 * pages since we need to zero out first and last block.
> Index: b/include/linux/init_task.h
> ===================================================================
> --- a/include/linux/init_task.h	2009-04-13 00:24:01.000000000 +0900
> +++ b/include/linux/init_task.h	2009-04-13 00:24:32.000000000 +0900
> @@ -37,6 +37,7 @@ extern struct fs_struct init_fs;
>  	.page_table_lock =  __SPIN_LOCK_UNLOCKED(name.page_table_lock),	\
>  	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
>  	.cpu_vm_mask	= CPU_MASK_ALL,				\
> +	.mm_pinned_sem	= __RWSEM_INITIALIZER(name.mm_pinned_sem), \
>  }
>  
>  #define INIT_SIGNALS(sig) {						\
> Index: b/include/linux/mm_types.h
> ===================================================================
> --- a/include/linux/mm_types.h	2009-04-13 00:24:01.000000000 +0900
> +++ b/include/linux/mm_types.h	2009-04-13 00:24:32.000000000 +0900
> @@ -274,6 +274,12 @@ struct mm_struct {
>  #ifdef CONFIG_MMU_NOTIFIER
>  	struct mmu_notifier_mm *mmu_notifier_mm;
>  #endif
> +
> +	/*
> +	 * if there are on-flight directio or similar pinning action,
> +	 * COW cause memory corruption. the sem protect it by preventing fork.
> +	 */
> +	struct rw_semaphore mm_pinned_sem;
>  };
>  
>  /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
> Index: b/kernel/fork.c
> ===================================================================
> --- a/kernel/fork.c	2009-04-13 00:24:01.000000000 +0900
> +++ b/kernel/fork.c	2009-04-13 00:24:32.000000000 +0900
> @@ -266,6 +266,7 @@ static int dup_mmap(struct mm_struct *mm
>  	unsigned long charge;
>  	struct mempolicy *pol;
>  
> +	down_write(&oldmm->mm_pinned_sem);
>  	down_write(&oldmm->mmap_sem);
>  	flush_cache_dup_mm(oldmm);
>  	/*
> @@ -368,6 +369,7 @@ out:
>  	up_write(&mm->mmap_sem);
>  	flush_tlb_mm(oldmm);
>  	up_write(&oldmm->mmap_sem);
> +	up_write(&oldmm->mm_pinned_sem);
>  	return retval;
>  fail_nomem_policy:
>  	kmem_cache_free(vm_area_cachep, tmp);
> @@ -431,6 +433,7 @@ static struct mm_struct * mm_init(struct
>  	mm->free_area_cache = TASK_UNMAPPED_BASE;
>  	mm->cached_hole_size = ~0UL;
>  	mm_init_owner(mm, p);
> +	init_rwsem(&mm->mm_pinned_sem);
>  
>  	if (likely(!mm_alloc_pgd(mm))) {
>  		mm->def_flags = 0;
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
