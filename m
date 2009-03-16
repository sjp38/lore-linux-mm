Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4630D6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 09:57:26 -0400 (EDT)
Date: Mon, 16 Mar 2009 14:56:54 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090316135654.GA17949@random.random>
References: <20090311170611.GA2079@elte.hu> <200903140309.39777.nickpiggin@yahoo.com.au> <20090313193416.GG27823@random.random> <200903141559.12484.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200903141559.12484.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 14, 2009 at 03:59:11PM +1100, Nick Piggin wrote:
> It does touch gup-fast, but it just adds one branch and no barrier in the

My question is what trick to you use to stop gup-fast from returning
the page mapped read-write by the pte if gup-fast doesn't take any
lock whatsoever, it doesn't set any bit in any page or vma, and it
doesn't recheck the pte is still viable after having set any bit on
page or vmas, and you still don't send a flood of ipis from fork fast
path (no race case).

> case the page is de-cowed (and would be able to work with hugepages with
> the get_page_multiple still I think although I haven't done hugepage
> implementation yet).

Yes let's ignore hugetlb for now, I fixed hugetlb too but that can be
left for later.

> Possibly that's the right way to go. Depends if it is in the slightest
> performance critical. If not, I would just let do_wp_page do the work
> to avoid a little bit of logic, but either way is not a big deal to me.

fork is less performance critical than do_wp_page, still in fork
microbenchmark no slowdown is measured with the patch. Before I
introduced PG_gup there were false positives triggered by the pagevec
temporary pins, that was measurable, after PG_gup the fast path is
unaffected (I've still to measure gup-fast slowdown in setting PG_gup
but I'm rather optimistic that you're understimating the cost of
walking 4 layers of pagetables compared to a locked op on a l1
exclusive cacheline, so I think it'll be lost in the noise). I think
the big thing of gup-fast is primarly in not having to search vmas,
and in turn to take any shared lock like mmap_sem/PT lock and to scale
on a page level with just a get-page being the troublesome cacheline.

> One side of the race is direct IO read writing to fork child page.
> The other side of the race is fork child page write leaking into
> the direct IO.
> 
> My patch solves both sides by de-cowing *any* COW page before it
> may be returned from get_user_pages (for read or write).

I see what you mean now. If you read the comment of my patch you'll
see I explicitly intended that only people writing into memory with
gup was troublesome here. Like you point out, using gup for _reading_
from memory is troublesome as well if child writes to those
pages. This is kind of a lower problem because the major issue is that
fork is enough to generate memory corruption even if the child isn't
touching those pages. The reverse race requires the child to write to
those pages so I guess it never triggered in real life apps. But
nevertheless I totally agree if we fix the write-to-memory-with-gup
we've to fix the read-from-memory-with-gup.

Below I updated my patch and relative commit header to fix the reverse
race too. However I had to enlarge the buffer to 40M to reproduce with
your testcase because my HD was too fast otherwise.

----------
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: fork-o_direct-race

Think a thread writing constantly to the last 512bytes of a page,
while another thread read and writes to/from the first 512bytes of the
page. We can lose O_DIRECT reads (or any other get_user_pages write=1
I/O not just bio/O_DIRECT), the very moment we mark any pte
wrprotected because a third unrelated thread forks off a child.

This fixes it by copying the anon page (instead of sharing it) within
fork, if there can be any direct I/O in flight to the page. That takes
care of O_DIRECT reads (writes to memory, read from disk). Checking
the page_count under the PT lock guarantees no get_user_pages could be
running under us because if somebody wants to write to the page, it
has to break any cow first and that requires taking the PT lock in
follow_page before increasing the page count. We are also guaranteed
mapcount is 1 if fork is writeprotecting the pte so the PT lock is
enough to serialize against get_user_pages->get_page.

Another problem are the O_DIRECT writes to disk, if the parent touches
a shared anon page before the child, the child do_wp_page will
takeover the anon page and map it read-write despite it was under
direct-io from the parent thread pool. This requires de-cowing the
pages in gup more aggressively (i.e. setting FOLL_WRITE temporarily on
anon pages to de-cow them, and always assume write=1 for hugetlb
follow_page version).

gup-fast is taken care of without flushing the smp-tlb for every
parent-pte wrprotected, by wrprotecting the pte before checking the
page count vs mapcount. gup-fast will then re-check that the pte is
still available in write mode after having increased the page count,
so solving the race without a flood of IPIs in fork.

The COW triggered inside fork will run while the parent pte is
readonly to provide as usual the per-page atomic copy from parent to
child during fork. However timings will be altered by having to copy
the pages that might be under O_DIRECT.

Once this race is fixed, the testcase instead of showing corruption is
capable of triggering a glibc NPTL race condition where fork_pre_cow
is copying internal the nptl stack list in anonymous memory while some
parent thread may be modifying it, which results in userland deadlock
when the fork-child tries to free the stacks before returning from
fork. We are flushing the tlb after wrprotecting the pte that maps the
anon page if we take the fork_pre_cow path, so we should be providing
per-page atomic copy from parent to child. The race indeed can trigger
also without this patch and without fork_pre_Cow and to trigger it the
wrprotect event must happen exactly in the middle of a
list_add/list_del instruction run by some NPLT thread that is mangling
over the stack list while fork runs. Some preliminary NPTL fix for
this race exposed by this fix, is happening on glibc repository but I
think it'd be better off to use a smart lock capable of jumping in and
out of signal handler and not to go out of order rcu style which
sounds too complex.

The pagevec code calls get_page while the page is sitting in the
pagevec (before it becomes PageLRU) and doing so it can generate false
positives, so to avoid slowing down fork all the time even for pages
that could never possibly be under O_DIRECT write=1, the PG_gup
bitflag is added, this eliminates most overhead of the fix in fork.

I had to add src_vma/dst_vma to use proper ->mm pointers, and in the case of
track_pfn_vma_copy PAT code, this is fixing a bug, because previously vma was
the dst_vma, while track_pfn_vma_copy has to run on the src_vma (the dst_vma in
that place is guaranteed to have zero ptes instantiated/allocated).

There are two testcases that reproduces the bug and they reproduce the bug both
for regular anon pages and using the libhugetlbfs and hugepages too. Patch
works for both. The glibc race is also eventually reproducible both using anon
pages and hugepages with the dma_thread testcase (the forkscrew testcases isn't
capable of reproducing the nptl race condition in fork).

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

========== forkscrew.c ========
/*
 * Copyright 2009, Red Hat, Inc.
 *
 * Author: Jeff Moyer <jmoyer@redhat.com>
 *
 * This program attempts to expose a race between O_DIRECT I/O and the fork()
 * path in a multi-threaded program.  In order to reliably reproduce the
 * problem, it is best to perform a dd from the device under test to /dev/null
 * as this makes the read I/O slow enough to orchestrate the problem.
 *
 * Running:  ./forkscrew
 *
 * It is expected that a file name "data" exists in the current working
 * directory, and that its contents are something other than 0x2a.  A simple
 * dd if=/dev/zero of=data bs=1M count=1 should be sufficient.
 */
#define _GNU_SOURCE 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <pthread.h>
#include <libaio.h>

pthread_cond_t worker_cond = PTHREAD_COND_INITIALIZER;
pthread_mutex_t worker_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t fork_cond = PTHREAD_COND_INITIALIZER;
pthread_mutex_t fork_mutex = PTHREAD_MUTEX_INITIALIZER;

char *buffer;
int fd;

/* pattern filled into the in-memory buffer */
#define PATTERN		0x2a  // '*'

void
usage(void)
{
	fprintf(stderr,
		"\nUsage: forkscrew\n"
		"it is expected that a file named \"data\" is the current\n"
		"working directory.  It should be at least 3*pagesize in size\n"
		);
}

void
dump_buffer(char *buf, int len)
{
	int i;
	int last_off, last_val;

	last_off = -1;
	last_val = -1;

	for (i = 0; i < len; i++) {
		if (last_off < 0) {
			last_off = i;
			last_val = buf[i];
			continue;
		}

		if (buf[i] != last_val) {
			printf("%d - %d: %d\n", last_off, i - 1, last_val);
			last_off = i;
			last_val = buf[i];
		}
	}

	if (last_off != len - 1)
		printf("%d - %d: %d\n", last_off, i-1, last_val);
}

int
check_buffer(char *bufp, int len, int pattern)
{
	int i;

	for (i = 0; i < len; i++) {
		if (bufp[i] == pattern)
			return 1;
	}
	return 0;
}

void *
forker_thread(void *arg)
{
	pthread_mutex_lock(&fork_mutex);
	pthread_cond_signal(&fork_cond);
	pthread_cond_wait(&fork_cond, &fork_mutex);
	switch (fork()) {
	case 0:
		sleep(1);
		printf("child dumping buffer:\n");
		dump_buffer(buffer + 512, 2*getpagesize());
		exit(0);
	case -1:
		perror("fork");
		exit(1);
	default:
		break;
	}
	pthread_cond_signal(&fork_cond);
	pthread_mutex_unlock(&fork_mutex);

	wait(NULL);
	return (void *)0;
}

void *
worker(void *arg)
{
	int first = (int)arg;
	char *bufp;
	int pagesize = getpagesize();
	int ret;
	int corrupted = 0;

	if (first) {
		io_context_t aioctx;
		struct io_event event;
		struct iocb *iocb = malloc(sizeof *iocb);
		if (!iocb) {
			perror("malloc");
			exit(1);
		}
		memset(&aioctx, 0, sizeof(aioctx));
		ret = io_setup(1, &aioctx);
		if (ret != 0) {
			errno = -ret;
			perror("io_setup");
			exit(1);
		}
		bufp = buffer + 512;
		io_prep_pread(iocb, fd, bufp, pagesize, 0);

		/* submit the I/O */
		io_submit(aioctx, 1, &iocb);

		/* tell the fork thread to run */
		pthread_mutex_lock(&fork_mutex);
		pthread_cond_signal(&fork_cond);

		/* wait for the fork to happen */
		pthread_cond_wait(&fork_cond, &fork_mutex);
		pthread_mutex_unlock(&fork_mutex);

		/* release the other worker to issue I/O */
		pthread_mutex_lock(&worker_mutex);
		pthread_cond_signal(&worker_cond);
		pthread_mutex_unlock(&worker_mutex);

		ret = io_getevents(aioctx, 1, 1, &event, NULL);
		if (ret != 1) {
			errno = -ret;
			perror("io_getevents");
			exit(1);
		}
		if (event.res != pagesize) {
			errno = -event.res;
			perror("read error");
			exit(1);
		}

		io_destroy(aioctx);

		/* check buffer, should be corrupt */
		if (check_buffer(bufp, pagesize, PATTERN)) {
			printf("worker 0 failed check\n");
			dump_buffer(bufp, pagesize);
			corrupted = 1;
		}

	} else {

		bufp = buffer + 512 + pagesize;

		pthread_mutex_lock(&worker_mutex);
		pthread_cond_signal(&worker_cond); /* tell main we're ready */
		/* wait for the first I/O and the fork */
		pthread_cond_wait(&worker_cond, &worker_mutex);
		pthread_mutex_unlock(&worker_mutex);

		/* submit overlapping I/O */
		ret = read(fd, bufp, pagesize);
		if (ret != pagesize) {
			perror("read");
			exit(1);
		}
		/* check buffer, should be fine */
		if (check_buffer(bufp, pagesize, PATTERN)) {
			printf("worker 1 failed check -- abnormal\n");
			dump_buffer(bufp, pagesize);
			corrupted = 1;
		}
	}

	return (void *)corrupted;
}

int
main(int argc, char **argv)
{
	pthread_t workers[2];
	pthread_t forker;
	int ret, rc = 0;
	void *thread_ret;
	int pagesize = getpagesize();

	fd = open("data", O_DIRECT|O_RDONLY);
	if (fd < 0) {
		perror("open");
		exit(1);
	}

	ret = posix_memalign(&buffer, pagesize, 3 * pagesize);
	if (ret != 0) {
		errno = ret;
		perror("posix_memalign");
		exit(1);
	}
	memset(buffer, PATTERN, 3*pagesize);

	pthread_mutex_lock(&fork_mutex);
	ret = pthread_create(&forker, NULL, forker_thread, NULL);
	pthread_cond_wait(&fork_cond, &fork_mutex);
	pthread_mutex_unlock(&fork_mutex);

	pthread_mutex_lock(&worker_mutex);
	ret |= pthread_create(&workers[0], NULL, worker, (void *)0);
	if (ret) {
		perror("pthread_create");
		exit(1);
	}
	pthread_cond_wait(&worker_cond, &worker_mutex);
	pthread_mutex_unlock(&worker_mutex);

	ret = pthread_create(&workers[1], NULL, worker, (void *)1);
	if (ret != 0) {
		perror("pthread_create");
		exit(1);
	}

	pthread_join(forker, NULL);
	pthread_join(workers[0], &thread_ret);
	if (thread_ret != 0)
		rc = 1;
	pthread_join(workers[1], &thread_ret);
	if (thread_ret != 0)
		rc = 1;

	if (rc != 0) {
		printf("parent dumping full buffer\n");
		dump_buffer(buffer + 512, 2 * pagesize);
	}

	close(fd);
	free(buffer);
	exit(rc);
}
========== forkscrew.c ========

========== forkscrewreverse.c ========
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

#define FILESIZE (40*1024*1024) 
#define BUFSIZE  (40*1024*1024)

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static const char *filename = "file.dat";
static int fd;
static void *buffer;
#define PAGE_SIZE   4096

static void store(void)
{
	int i;

	if (usleep(50*1000) == -1)
		perror("usleep"), exit(1);

	printf("child storing\n"); fflush(stdout);
	for (i = 0; i < BUFSIZE; i++)
		((char *)buffer)[i] = 0xff;

	_exit(0);
}

static void *writer(void *arg)
{
	int i;

	if (pthread_mutex_lock(&lock) == -1)
		perror("pthread_mutex_lock"), exit(1);

	printf("thread writing\n"); fflush(stdout);
	for (i = 0; i < FILESIZE / BUFSIZE; i++) {
		size_t count = BUFSIZE;
		ssize_t ret;

		do {
			ret = write(fd, buffer, count);
			if (ret == -1) {
				if (errno != EINTR)
					perror("write"), exit(1);
				ret = 0;
			}
			count -= ret;
		} while (count);
	}
	printf("thread writing done\n"); fflush(stdout);

	if (pthread_mutex_unlock(&lock) == -1)
		perror("pthread_mutex_lock"), exit(1);

	return NULL;
}

int main(int argc, char *argv[])
{
	int i;
	int status;
	pthread_t writer_thread;
	pid_t store_proc;

	posix_memalign(&buffer, PAGE_SIZE, BUFSIZE);
	printf("Write buffer: %p.\n", buffer);

	for (i = 0; i < BUFSIZE; i++)
		((char *)buffer)[i] = 0x00;

	fd = open(filename, O_RDWR|O_DIRECT);
	if (fd == -1)
		perror("open"), exit(1);

	if (pthread_mutex_lock(&lock) == -1)
		perror("pthread_mutex_lock"), exit(1);

	if (pthread_create(&writer_thread, NULL, writer, NULL) == -1)
		perror("pthred_create"), exit(1);

	store_proc = fork();
	if (store_proc == -1)
		perror("fork"), exit(1);
	if (!store_proc)
		store();

	if (pthread_mutex_unlock(&lock) == -1)
		perror("pthread_mutex_lock"), exit(1);

	if (usleep(10*1000) == -1)
		perror("usleep"), exit(1);

	printf("parent storing\n"); fflush(stdout);
	for (i = 0; i < BUFSIZE; i++)
		((char *)buffer)[i] = 0x11;

	do {
		pid_t w;
		w = waitpid(store_proc, &status, WUNTRACED | WCONTINUED);
		if (w == -1)
			perror("waitpid"), exit(1);
	} while (!WIFEXITED(status) && !WIFSIGNALED(status));

	if (pthread_join(writer_thread, NULL) == -1)
		perror("pthread_join"), exit(1);

	exit(0);
}
========== forkscrewreverse.c ========

Normally I test with "dma_thread -a 512 -w 40".

To reproduce or verify the fix with hugepages run it like this:

LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ../test/dma_thread -a 512 -w 40
LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ./forkscrew
LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ./forkscrewreverse

This is a fixed version of original patch from Nick Piggin.

KSM has the same problem of fork and it also checks the page_count
after a ptep_clear_flush_notify (the _flush sending smp-tlb-flush
stops gup-fast so it doesn't depend on the above gup-fast changes that
allows fork not to flush the smp-tlb at every pte wrprotected, and the
_notify ensure all secondary ptes are zapped and any page-pin released
for mmu-notifier subsystems that take page pins like currently KVM).

BTW, I guess it's pure luck ENOSPC != VM_FAULT_OOM in hugetlb.c,
mixing -errno with -VM_FAULT_* is total breakage that will have to be
cleaned up (either don't use -ENOSPC, or use -ENOMEM instead of
VM_FAULT_OOM), I didn't address it in this patch as it's unrelated.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

Removed mtk.manpages@gmail.com, linux-man@vger.kernel.org from
previous CC list.

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -89,6 +89,26 @@ static noinline int gup_pte_range(pmd_t 
 		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
 		page = pte_page(pte);
 		get_page(page);
+		if (PageAnon(page)) {
+			if (!PageGUP(page))
+				SetPageGUP(page);
+			smp_mb();
+			/*
+			 * Fork doesn't want to flush the smp-tlb for
+			 * every pte that it marks readonly but newly
+			 * created shared anon pages cannot have
+			 * direct-io going to them, so check if fork
+			 * made the page shared before we taken the
+			 * page pin.
+			 * de-cow to make direct read from memory safe.
+			 */
+			if ((pte_flags(gup_get_pte(ptep)) &
+			     (mask | _PAGE_SPECIAL)) != (mask|_PAGE_RW)) {
+				put_page(page);
+				pte_unmap(ptep);
+				return 0;
+			}
+		}
 		pages[*nr] = page;
 		(*nr)++;
 
@@ -98,24 +118,16 @@ static noinline int gup_pte_range(pmd_t 
 	return 1;
 }
 
-static inline void get_head_page_multiple(struct page *page, int nr)
-{
-	VM_BUG_ON(page != compound_head(page));
-	VM_BUG_ON(page_count(page) == 0);
-	atomic_add(nr, &page->_count);
-}
-
-static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
+static noinline int gup_huge_pmd(pmd_t *pmdp, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
 {
 	unsigned long mask;
-	pte_t pte = *(pte_t *)&pmd;
+	pte_t pte = *(pte_t *)pmdp;
 	struct page *head, *page;
 	int refs;
 
-	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
+	/* de-cow to make direct read from memory safe */
+	mask = _PAGE_PRESENT|_PAGE_USER|_PAGE_RW;
 	if ((pte_flags(pte) & mask) != mask)
 		return 0;
 	/* hugepages are never "special" */
@@ -127,12 +139,21 @@ static noinline int gup_huge_pmd(pmd_t p
 	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
 	do {
 		VM_BUG_ON(compound_head(page) != head);
+		get_page(head);
+		if (!PageGUP(head))
+			SetPageGUP(head);
+		smp_mb();
+		if ((pte_flags(*(pte_t *)pmdp) & mask) != mask) {
+			put_page(page);
+			return 0;
+		}
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
-	get_head_page_multiple(head, refs);
+	VM_BUG_ON(page_count(head) == 0);
+	VM_BUG_ON(head != compound_head(head));
 
 	return 1;
 }
@@ -151,7 +172,7 @@ static int gup_pmd_range(pud_t pud, unsi
 		if (pmd_none(pmd))
 			return 0;
 		if (unlikely(pmd_large(pmd))) {
-			if (!gup_huge_pmd(pmd, addr, next, write, pages, nr))
+			if (!gup_huge_pmd(pmdp, addr, next, pages, nr))
 				return 0;
 		} else {
 			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
@@ -162,17 +183,16 @@ static int gup_pmd_range(pud_t pud, unsi
 	return 1;
 }
 
-static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
+static noinline int gup_huge_pud(pud_t *pudp, unsigned long addr,
+		unsigned long end, struct page **pages, int *nr)
 {
 	unsigned long mask;
-	pte_t pte = *(pte_t *)&pud;
+	pte_t pte = *(pte_t *)pudp;
 	struct page *head, *page;
 	int refs;
 
-	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
+	/* de-cow to make direct read from memory safe */
+	mask = _PAGE_PRESENT|_PAGE_USER|_PAGE_RW;
 	if ((pte_flags(pte) & mask) != mask)
 		return 0;
 	/* hugepages are never "special" */
@@ -184,12 +204,21 @@ static noinline int gup_huge_pud(pud_t p
 	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 	do {
 		VM_BUG_ON(compound_head(page) != head);
+		get_page(head);
+		if (!PageGUP(head))
+			SetPageGUP(head);
+		smp_mb();
+		if ((pte_flags(*(pte_t *)pudp) & mask) != mask) {
+			put_page(page);
+			return 0;
+		}
 		pages[*nr] = page;
 		(*nr)++;
 		page++;
 		refs++;
 	} while (addr += PAGE_SIZE, addr != end);
-	get_head_page_multiple(head, refs);
+	VM_BUG_ON(page_count(head) == 0);
+	VM_BUG_ON(head != compound_head(head));
 
 	return 1;
 }
@@ -208,7 +237,7 @@ static int gup_pud_range(pgd_t pgd, unsi
 		if (pud_none(pud))
 			return 0;
 		if (unlikely(pud_large(pud))) {
-			if (!gup_huge_pud(pud, addr, next, write, pages, nr))
+			if (!gup_huge_pud(pudp, addr, next, pages, nr))
 				return 0;
 		} else {
 			if (!gup_pmd_range(pud, addr, next, write, pages, nr))
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -20,8 +20,8 @@ int hugetlb_sysctl_handler(struct ctl_ta
 int hugetlb_sysctl_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int hugetlb_overcommit_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
 int hugetlb_treat_movable_handler(struct ctl_table *, int, struct file *, void __user *, size_t *, loff_t *);
-int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
-int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int, int);
+int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *, struct vm_area_struct *);
+int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int);
 void unmap_hugepage_range(struct vm_area_struct *,
 			unsigned long, unsigned long, struct page *);
 void __unmap_hugepage_range(struct vm_area_struct *,
@@ -75,9 +75,9 @@ static inline unsigned long hugetlb_tota
 	return 0;
 }
 
-#define follow_hugetlb_page(m,v,p,vs,a,b,i,w)	({ BUG(); 0; })
+#define follow_hugetlb_page(m,v,p,vs,a,b,i)	({ BUG(); 0; })
 #define follow_huge_addr(mm, addr, write)	ERR_PTR(-EINVAL)
-#define copy_hugetlb_page_range(src, dst, vma)	({ BUG(); 0; })
+#define copy_hugetlb_page_range(src, dst, dst_vma, src_vma)	({ BUG(); 0; })
 #define hugetlb_prefault(mapping, vma)		({ BUG(); 0; })
 #define unmap_hugepage_range(vma, start, end, page)	BUG()
 static inline void hugetlb_report_meminfo(struct seq_file *m)
diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -789,7 +789,8 @@ void free_pgd_range(struct mmu_gather *t
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
-			struct vm_area_struct *vma);
+		    struct vm_area_struct *dst_vma,
+		    struct vm_area_struct *src_vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
@@ -1238,7 +1239,7 @@ int vm_insert_mixed(struct vm_area_struc
 			unsigned long pfn);
 
 struct page *follow_page(struct vm_area_struct *, unsigned long address,
-			unsigned int foll_flags);
+			unsigned int *foll_flags);
 #define FOLL_WRITE	0x01	/* check pte is writable */
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -101,6 +101,7 @@ enum pageflags {
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	PG_uncached,		/* Page has been mapped as uncached */
 #endif
+	PG_gup,
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -195,6 +196,7 @@ PAGEFLAG(Private, private) __CLEARPAGEFL
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
+PAGEFLAG(GUP, gup) __CLEARPAGEFLAG(GUP, gup)
 
 __PAGEFLAG(SlobPage, slob_page)
 __PAGEFLAG(SlobFree, slob_free)
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -353,7 +353,7 @@ static int dup_mmap(struct mm_struct *mm
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		retval = copy_page_range(mm, oldmm, mpnt);
+		retval = copy_page_range(mm, oldmm, tmp, mpnt);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1695,20 +1695,37 @@ static void set_huge_ptep_writable(struc
 	}
 }
 
+/* Return the pagecache page at a given address within a VMA */
+static struct page *hugetlbfs_pagecache_page(struct hstate *h,
+			struct vm_area_struct *vma, unsigned long address)
+{
+	struct address_space *mapping;
+	pgoff_t idx;
+
+	mapping = vma->vm_file->f_mapping;
+	idx = vma_hugecache_offset(h, vma, address);
+
+	return find_lock_page(mapping, idx);
+}
+
+static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
+		       unsigned long address, pte_t *ptep, pte_t pte,
+		       struct page *pagecache_page);
 
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
-			    struct vm_area_struct *vma)
+			    struct vm_area_struct *dst_vma,
+			    struct vm_area_struct *src_vma)
 {
-	pte_t *src_pte, *dst_pte, entry;
+	pte_t *src_pte, *dst_pte, entry, orig_entry;
 	struct page *ptepage;
 	unsigned long addr;
-	int cow;
-	struct hstate *h = hstate_vma(vma);
+	int cow, forcecow, oom;
+	struct hstate *h = hstate_vma(src_vma);
 	unsigned long sz = huge_page_size(h);
 
-	cow = (vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
+	cow = (src_vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 
-	for (addr = vma->vm_start; addr < vma->vm_end; addr += sz) {
+	for (addr = src_vma->vm_start; addr < src_vma->vm_end; addr += sz) {
 		src_pte = huge_pte_offset(src, addr);
 		if (!src_pte)
 			continue;
@@ -1720,22 +1737,76 @@ int copy_hugetlb_page_range(struct mm_st
 		if (dst_pte == src_pte)
 			continue;
 
+		oom = 0;
 		spin_lock(&dst->page_table_lock);
 		spin_lock_nested(&src->page_table_lock, SINGLE_DEPTH_NESTING);
-		if (!huge_pte_none(huge_ptep_get(src_pte))) {
-			if (cow)
-				huge_ptep_set_wrprotect(src, addr, src_pte);
-			entry = huge_ptep_get(src_pte);
+		orig_entry = entry = huge_ptep_get(src_pte);
+		forcecow = 0;
+		if (!huge_pte_none(entry)) {
 			ptepage = pte_page(entry);
 			get_page(ptepage);
+			if (cow && pte_write(entry)) {
+				huge_ptep_set_wrprotect(src, addr, src_pte);
+				smp_mb();
+				if (PageGUP(ptepage))
+					forcecow = 1;
+				entry = huge_ptep_get(src_pte);
+			}
 			set_huge_pte_at(dst, addr, dst_pte, entry);
 		}
 		spin_unlock(&src->page_table_lock);
+		if (forcecow) {
+			if (unlikely(vma_needs_reservation(h, dst_vma, addr)
+				     < 0))
+				oom = 1;
+			else {
+				struct page *pg;
+				int cow_ret;
+				spin_unlock(&dst->page_table_lock);
+				/* force atomic copy from parent to child */
+				flush_tlb_range(src_vma, addr, addr+sz);
+				/*
+				 * Can use hstate from src_vma and src_vma
+				 * because the hugetlbfs pagecache will
+				 * be the same for both src_vma and dst_vma.
+				 */
+				pg = hugetlbfs_pagecache_page(h,
+							      src_vma,
+							      addr);
+				spin_lock_nested(&dst->page_table_lock,
+						 SINGLE_DEPTH_NESTING);
+				cow_ret = hugetlb_cow(dst, dst_vma, addr,
+						      dst_pte, entry,
+						      pg);
+				/*
+				 * We hold mmap_sem in write mode and
+				 * the VM doesn't know about hugepages
+				 * so the src_pte/dst_pte can't change
+				 * from under us even without both
+				 * page_table_lock hold the whole time.
+				 */
+				BUG_ON(!pte_same(huge_ptep_get(src_pte),
+						 entry));
+				set_huge_pte_at(src, addr,
+						src_pte,
+						orig_entry);
+				if (cow_ret)
+					oom = 1;
+			}
+		}
 		spin_unlock(&dst->page_table_lock);
+		if (oom)
+			goto nomem;
 	}
 	return 0;
 
 nomem:
+	/*
+	 * Want this to also be able to return -ENOSPC? Then stop the
+	 * mess of mixing -VM_FAULT_ and -ENOSPC retvals and be
+	 * consistent returning -ENOMEM instead of -VM_FAULT_OOM in
+	 * alloc_huge_page.
+	 */
 	return -ENOMEM;
 }
 
@@ -1943,19 +2014,6 @@ retry_avoidcopy:
 	return 0;
 }
 
-/* Return the pagecache page at a given address within a VMA */
-static struct page *hugetlbfs_pagecache_page(struct hstate *h,
-			struct vm_area_struct *vma, unsigned long address)
-{
-	struct address_space *mapping;
-	pgoff_t idx;
-
-	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
-
-	return find_lock_page(mapping, idx);
-}
-
 static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, pte_t *ptep, int write_access)
 {
@@ -2160,8 +2218,7 @@ static int huge_zeropage_ok(pte_t *ptep,
 
 int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			struct page **pages, struct vm_area_struct **vmas,
-			unsigned long *position, int *length, int i,
-			int write)
+			unsigned long *position, int *length, int i)
 {
 	unsigned long pfn_offset;
 	unsigned long vaddr = *position;
@@ -2181,16 +2238,16 @@ int follow_hugetlb_page(struct mm_struct
 		 * first, for the page indexing below to work.
 		 */
 		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
-		if (huge_zeropage_ok(pte, write, shared))
+		if (huge_zeropage_ok(pte, 1, shared))
 			zeropage_ok = 1;
 
 		if (!pte ||
 		    (huge_pte_none(huge_ptep_get(pte)) && !zeropage_ok) ||
-		    (write && !pte_write(huge_ptep_get(pte)))) {
+		    !pte_write(huge_ptep_get(pte))) {
 			int ret;
 
 			spin_unlock(&mm->page_table_lock);
-			ret = hugetlb_fault(mm, vma, vaddr, write);
+			ret = hugetlb_fault(mm, vma, vaddr, 1);
 			spin_lock(&mm->page_table_lock);
 			if (!(ret & VM_FAULT_ERROR))
 				continue;
@@ -2207,8 +2264,11 @@ same_page:
 		if (pages) {
 			if (zeropage_ok)
 				pages[i] = ZERO_PAGE(0);
-			else
+			else {
 				pages[i] = mem_map_offset(page, pfn_offset);
+				if (!PageGUP(page))
+					SetPageGUP(page);
+			}
 			get_page(pages[i]);
 		}
 
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -538,14 +538,16 @@ out:
  * covered by this vma.
  */
 
-static inline void
+static inline int
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
+		pte_t *dst_pte, pte_t *src_pte,
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
 		unsigned long addr, int *rss)
 {
-	unsigned long vm_flags = vma->vm_flags;
+	unsigned long vm_flags = src_vma->vm_flags;
 	pte_t pte = *src_pte;
 	struct page *page;
+	int forcecow = 0;
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
@@ -576,15 +578,6 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	}
 
 	/*
-	 * If it's a COW mapping, write protect it both
-	 * in the parent and the child
-	 */
-	if (is_cow_mapping(vm_flags)) {
-		ptep_set_wrprotect(src_mm, addr, src_pte);
-		pte = pte_wrprotect(pte);
-	}
-
-	/*
 	 * If it's a shared mapping, mark it clean in
 	 * the child
 	 */
@@ -592,27 +585,87 @@ copy_one_pte(struct mm_struct *dst_mm, s
 		pte = pte_mkclean(pte);
 	pte = pte_mkold(pte);
 
-	page = vm_normal_page(vma, addr, pte);
+	/*
+	 * If it's a COW mapping, write protect it both
+	 * in the parent and the child.
+	 */
+	if (is_cow_mapping(vm_flags) && pte_write(pte)) {
+		/*
+		 * Serialization against gup-fast happens by
+		 * wrprotecting the pte and checking the PG_gup flag
+		 * and the number of page pins after that. If gup-fast
+		 * boosts the page_count after we checked it, it will
+		 * also take the slow path because it will find the
+		 * pte wrprotected.
+		 */
+		ptep_set_wrprotect(src_mm, addr, src_pte);
+	}
+
+	page = vm_normal_page(src_vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page, vma, addr);
+		page_dup_rmap(page, dst_vma, addr);
+		if (is_cow_mapping(vm_flags) && pte_write(pte) &&
+		    PageAnon(page)) {
+			smp_mb();
+			if (PageGUP(page)) {
+				if (unlikely(!trylock_page(page)))
+					forcecow = 1;
+				else {
+					BUG_ON(page_mapcount(page) != 2);
+					if (unlikely(page_count(page) !=
+						     page_mapcount(page)
+						     + !!PageSwapCache(page)))
+						forcecow = 1;
+					unlock_page(page);
+				}
+			}
+		}
 		rss[!!PageAnon(page)]++;
+	}
+
+	if (is_cow_mapping(vm_flags) && pte_write(pte)) {
+		pte = pte_wrprotect(pte);
+		if (forcecow) {
+			/* force atomic copy from parent to child */
+			flush_tlb_page(src_vma, addr);
+			/*
+			 * Don't set the dst_pte here to be
+			 * safer, as fork_pre_cow might return
+			 * -EAGAIN and restart.
+			 */
+			goto out;
+		}
 	}
 
 out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
+out:
+	return forcecow;
 }
 
+static int fork_pre_cow(struct mm_struct *dst_mm,
+			struct mm_struct *src_mm,
+			struct vm_area_struct *dst_vma,
+			struct vm_area_struct *src_vma,
+			unsigned long address,
+			pte_t **dst_ptep, pte_t **src_ptep,
+			spinlock_t **dst_ptlp, spinlock_t **src_ptlp,
+			pmd_t *dst_pmd, pmd_t *src_pmd);
+
 static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
+		pmd_t *dst_pmd, pmd_t *src_pmd,
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
 		unsigned long addr, unsigned long end)
 {
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
 	int rss[2];
+	int forcecow;
 
 again:
+	forcecow = 0;
 	rss[1] = rss[0] = 0;
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
@@ -623,6 +676,9 @@ again:
 	arch_enter_lazy_mmu_mode();
 
 	do {
+		if (forcecow)
+			break;
+
 		/*
 		 * We are holding two locks at this point - either of them
 		 * could generate latencies in another task on another CPU.
@@ -637,9 +693,38 @@ again:
 			progress++;
 			continue;
 		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		forcecow = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
+					dst_vma, src_vma, addr, rss);
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
+
+	if (unlikely(forcecow)) {
+		pte_t *_src_pte = src_pte-1, *_dst_pte = dst_pte-1;
+		/*
+		 * Try to COW the child page as direct I/O is working
+		 * on the parent page, and so we've to mark the parent
+		 * pte read-write before dropping the PT lock and
+		 * mmap_sem to avoid the page to be cowed in the
+		 * parent and any direct I/O to get lost.
+		 */
+		forcecow = fork_pre_cow(dst_mm, src_mm,
+					dst_vma, src_vma,
+					addr-PAGE_SIZE,
+					&_dst_pte, &_src_pte,
+					&dst_ptl, &src_ptl,
+					dst_pmd, src_pmd);
+		src_pte = _src_pte + 1;
+		dst_pte = _dst_pte + 1;
+		/* after the page copy set the parent pte writeable again */
+		set_pte_at(src_mm, addr-PAGE_SIZE, src_pte-1,
+			   pte_mkwrite(*(src_pte-1)));
+		if (unlikely(forcecow == -EAGAIN)) {
+			dst_pte--;
+			src_pte--;
+			addr -= PAGE_SIZE;
+			rss[1]--;
+		}
+	}
 
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
@@ -647,13 +732,16 @@ again:
 	add_mm_rss(dst_mm, rss[0], rss[1]);
 	pte_unmap_unlock(dst_pte - 1, dst_ptl);
 	cond_resched();
+	if (unlikely(forcecow == -ENOMEM))
+		return -ENOMEM;
 	if (addr != end)
 		goto again;
 	return 0;
 }
 
 static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
+		pud_t *dst_pud, pud_t *src_pud,
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
 		unsigned long addr, unsigned long end)
 {
 	pmd_t *src_pmd, *dst_pmd;
@@ -668,14 +756,15 @@ static inline int copy_pmd_range(struct 
 		if (pmd_none_or_clear_bad(src_pmd))
 			continue;
 		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
+				   dst_vma, src_vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
 	return 0;
 }
 
 static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
+		pgd_t *dst_pgd, pgd_t *src_pgd,
+		struct vm_area_struct *dst_vma, struct vm_area_struct *src_vma,
 		unsigned long addr, unsigned long end)
 {
 	pud_t *src_pud, *dst_pud;
@@ -690,19 +779,20 @@ static inline int copy_pud_range(struct 
 		if (pud_none_or_clear_bad(src_pud))
 			continue;
 		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
+				   dst_vma, src_vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pud++, src_pud++, addr = next, addr != end);
 	return 0;
 }
 
 int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		struct vm_area_struct *vma)
+		    struct vm_area_struct *dst_vma,
+		    struct vm_area_struct *src_vma)
 {
 	pgd_t *src_pgd, *dst_pgd;
 	unsigned long next;
-	unsigned long addr = vma->vm_start;
-	unsigned long end = vma->vm_end;
+	unsigned long addr = src_vma->vm_start;
+	unsigned long end = src_vma->vm_end;
 	int ret;
 
 	/*
@@ -711,20 +801,21 @@ int copy_page_range(struct mm_struct *ds
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
-	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
-		if (!vma->anon_vma)
+	if (!(src_vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
+		if (!src_vma->anon_vma)
 			return 0;
 	}
 
-	if (is_vm_hugetlb_page(vma))
-		return copy_hugetlb_page_range(dst_mm, src_mm, vma);
+	if (is_vm_hugetlb_page(src_vma))
+		return copy_hugetlb_page_range(dst_mm, src_mm,
+					       dst_vma, src_vma);
 
-	if (unlikely(is_pfn_mapping(vma))) {
+	if (unlikely(is_pfn_mapping(src_vma))) {
 		/*
 		 * We do not free on error cases below as remove_vma
 		 * gets called on error from higher level routine
 		 */
-		ret = track_pfn_vma_copy(vma);
+		ret = track_pfn_vma_copy(src_vma);
 		if (ret)
 			return ret;
 	}
@@ -735,7 +826,7 @@ int copy_page_range(struct mm_struct *ds
 	 * parent mm. And a permission downgrade will only happen if
 	 * is_cow_mapping() returns true.
 	 */
-	if (is_cow_mapping(vma->vm_flags))
+	if (is_cow_mapping(src_vma->vm_flags))
 		mmu_notifier_invalidate_range_start(src_mm, addr, end);
 
 	ret = 0;
@@ -746,15 +837,15 @@ int copy_page_range(struct mm_struct *ds
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
 		if (unlikely(copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-					    vma, addr, next))) {
+					    dst_vma, src_vma, addr, next))) {
 			ret = -ENOMEM;
 			break;
 		}
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
-	if (is_cow_mapping(vma->vm_flags))
+	if (is_cow_mapping(src_vma->vm_flags))
 		mmu_notifier_invalidate_range_end(src_mm,
-						  vma->vm_start, end);
+						  src_vma->vm_start, end);
 	return ret;
 }
 
@@ -1091,7 +1182,7 @@ EXPORT_SYMBOL_GPL(zap_vma_ptes);
  * Do a quick page-table lookup for a single page.
  */
 struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
-			unsigned int flags)
+			unsigned int *flagsp)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -1100,6 +1191,7 @@ struct page *follow_page(struct vm_area_
 	spinlock_t *ptl;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
+	unsigned long flags = *flagsp;
 
 	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
 	if (!IS_ERR(page)) {
@@ -1145,8 +1237,19 @@ struct page *follow_page(struct vm_area_
 	if (unlikely(!page))
 		goto bad_page;
 
-	if (flags & FOLL_GET)
+	if (flags & FOLL_GET) {
+		if (PageAnon(page)) {
+			/* de-cow to make direct read from memory safe */
+			if (!pte_write(pte)) {
+				page = NULL;
+				*flagsp |= FOLL_WRITE;
+				goto unlock;
+			}
+			if (!PageGUP(page))
+				SetPageGUP(page);
+		}
 		get_page(page);
+	}
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
@@ -1275,7 +1378,7 @@ int __get_user_pages(struct task_struct 
 
 		if (is_vm_hugetlb_page(vma)) {
 			i = follow_hugetlb_page(mm, vma, pages, vmas,
-						&start, &len, i, write);
+						&start, &len, i);
 			continue;
 		}
 
@@ -1303,7 +1406,7 @@ int __get_user_pages(struct task_struct 
 				foll_flags |= FOLL_WRITE;
 
 			cond_resched();
-			while (!(page = follow_page(vma, start, foll_flags))) {
+			while (!(page = follow_page(vma, start, &foll_flags))) {
 				int ret;
 				ret = handle_mm_fault(mm, vma, start,
 						foll_flags & FOLL_WRITE);
@@ -1865,6 +1968,81 @@ static inline void cow_user_page(struct 
 		flush_dcache_page(dst);
 	} else
 		copy_user_highpage(dst, src, va, vma);
+}
+
+static int fork_pre_cow(struct mm_struct *dst_mm,
+			struct mm_struct *src_mm,
+			struct vm_area_struct *dst_vma,
+			struct vm_area_struct *src_vma,
+			unsigned long address,
+			pte_t **dst_ptep, pte_t **src_ptep,
+			spinlock_t **dst_ptlp, spinlock_t **src_ptlp,
+			pmd_t *dst_pmd, pmd_t *src_pmd)
+{
+	pte_t _src_pte, _dst_pte;
+	struct page *old_page, *new_page;
+
+	_src_pte = **src_ptep;
+	_dst_pte = **dst_ptep;
+	old_page = vm_normal_page(src_vma, address, **src_ptep);
+	BUG_ON(!old_page);
+	get_page(old_page);
+	arch_leave_lazy_mmu_mode();
+	spin_unlock(*src_ptlp);
+	pte_unmap_nested(*src_ptep);
+	pte_unmap_unlock(*dst_ptep, *dst_ptlp);
+
+	new_page = alloc_page_vma(GFP_HIGHUSER, dst_vma, address);
+	if (unlikely(!new_page)) {
+		*dst_ptep = pte_offset_map_lock(dst_mm, dst_pmd, address,
+						dst_ptlp);
+		*src_ptep = pte_offset_map_nested(src_pmd, address);
+		*src_ptlp = pte_lockptr(src_mm, src_pmd);
+		spin_lock_nested(*src_ptlp, SINGLE_DEPTH_NESTING);
+		arch_enter_lazy_mmu_mode();
+		return -ENOMEM;
+	}
+	cow_user_page(new_page, old_page, address, dst_vma);
+
+	*dst_ptep = pte_offset_map_lock(dst_mm, dst_pmd, address, dst_ptlp);
+	*src_ptep = pte_offset_map_nested(src_pmd, address);
+	*src_ptlp = pte_lockptr(src_mm, src_pmd);
+	spin_lock_nested(*src_ptlp, SINGLE_DEPTH_NESTING);
+	arch_enter_lazy_mmu_mode();
+
+	/*
+	 * src pte can unmapped by the VM from under us after dropping
+	 * the src_ptlp but it can't be cowed from under us as fork
+	 * holds the mmap_sem in write mode.
+	 */
+	if (!pte_same(**src_ptep, _src_pte))
+		goto eagain;
+	if (!pte_same(**dst_ptep, _dst_pte))
+		goto eagain;
+
+	page_remove_rmap(old_page);
+	page_cache_release(old_page);
+	page_cache_release(old_page);
+
+	__SetPageUptodate(new_page);
+	flush_cache_page(src_vma, address, pte_pfn(**src_ptep));
+	_dst_pte = mk_pte(new_page, dst_vma->vm_page_prot);
+	_dst_pte = maybe_mkwrite(pte_mkdirty(_dst_pte), dst_vma);
+	page_add_new_anon_rmap(new_page, dst_vma, address);
+	set_pte_at(dst_mm, address, *dst_ptep, _dst_pte);
+	update_mmu_cache(dst_vma, address, _dst_pte);
+	return 0;
+
+eagain:
+	page_cache_release(old_page);
+	page_cache_release(new_page);
+	/*
+	 * Later we'll repeat the copy of this pte, so here we've to
+	 * undo the mapcount and page count taken in copy_one_pte.
+	 */
+	page_remove_rmap(old_page);
+	page_cache_release(old_page);
+	return -EAGAIN;
 }
 
 /*
diff --git a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -64,6 +64,8 @@ static void put_compound_page(struct pag
 	if (put_page_testzero(page)) {
 		compound_page_dtor *dtor;
 
+		if (PageGUP(page))
+			__ClearPageGUP(page);
 		dtor = get_compound_page_dtor(page);
 		(*dtor)(page);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
