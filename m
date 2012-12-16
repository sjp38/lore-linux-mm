Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id E79576B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 22:35:54 -0500 (EST)
Date: Sun, 16 Dec 2012 03:35:49 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216033549.GA30446@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121215223448.08272fd5@pyramind.ukuu.org.uk>
 <20121216002549.GA19402@dcvr.yhbt.net>
 <20121216030302.GI9806@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216030302.GI9806@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Dave Chinner <david@fromorbit.com> wrote:
> On Sun, Dec 16, 2012 at 12:25:49AM +0000, Eric Wong wrote:
> > Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > > On Sat, 15 Dec 2012 00:54:48 +0000
> > > Eric Wong <normalperson@yhbt.net> wrote:
> > > 
> > > > Applications streaming large files may want to reduce disk spinups and
> > > > I/O latency by performing large amounts of readahead up front
> > > 
> > > How does it compare benchmark wise with a user thread or using the
> > > readahead() call ?
> > 
> > Very well.
> > 
> > My main concern is for the speed of the initial pread()/read() call
> > after open().
> > 
> > Setting EARLY_EXIT means my test program _exit()s immediately after the
> > first pread().  In my test program (below), I wait for the background
> > thread to become ready before open() so I would not take overhead from
> > pthread_create() into account.
> > 
> > RA=1 uses a pthread + readahead()
> > Not setting RA uses fadvise (with my patch)
> 
> And if you don't use fadvise/readahead at all?

Sorry for the confusion.  I believe my other reply to you summarized
what I wanted to say in my commit message and also reply to Alan.

I want all the following things:

- I want the first read to be fast.
- I want to read the whole file eventually (probably slowly,
  as processing takes a while).
- I want to let my disk spin down for as long as possible.

This could also be a use case for an audio/video player.

> You're not timing how long the first pread() takes at all. You're
> timing the entire set of operations, including cloning a thread and
> for the readahead(2) call and messages to be passed back and forth
> through the eventfd interface to read the entire file.

You're right, I screwed up the measurement.  Using clock_gettime(),
there's hardly a difference between the approaches and I can't
get consistent timings between them.

So no, there's no difference that matters between the approaches.
But I think doing this in the kernel is easier for userspace users.

---------------------------------- 8<----------------------------
/* gcc -O2 -Wall -lpthread -lrt -o first_read first_read.c */
#define _GNU_SOURCE
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <assert.h>
#include <sched.h>
#include <sys/eventfd.h>
#include <time.h>

static int efd1;
static int efd2;

static void clock_diff(struct timespec *a, const struct timespec *b)
{
        a->tv_sec -= b->tv_sec;
        a->tv_nsec -= b->tv_nsec;
        if (a->tv_nsec < 0) {
                --a->tv_sec;
                a->tv_nsec += 1000000000;
        }
}

static void * start_ra(void *unused)
{
	struct stat st;
	eventfd_t val;
	int fd;

	/* tell parent to open() */
	assert(eventfd_write(efd1, 1) == 0);

	/* wait for parent to tell us fd is ready */
	assert(eventfd_read(efd2, &val) == 0);
	fd = (int)val;

	assert(fstat(fd, &st) == 0);
	assert(readahead(fd, 0, st.st_size) == 0);

	return NULL;
}

int main(int argc, char *argv[])
{
	char buf[16384];
	pthread_t thr;
	int fd;
	struct timespec start;
	struct timespec finish;
	char *do_ra = getenv("RA");

	if (argc != 2) {
		fprintf(stderr, "Usage: strace -T %s LARGE_FILE\n", argv[0]);
		return 1;
	}

	if (do_ra) {
		eventfd_t val;
		efd1 = eventfd(0, 0);
		efd2 = eventfd(0, 0);
		assert(efd1 >= 0 && efd2 >= 0 && "eventfd failed");
		assert(pthread_create(&thr, NULL, start_ra, NULL) == 0);

		/* wait for child thread to spawn */
		assert(eventfd_read(efd1, &val) == 0);
	}

	fd = open(argv[1], O_RDONLY);
	assert(fd >= 0 && "open failed");

	assert(clock_gettime(CLOCK_MONOTONIC, &start) == 0);

	if (do_ra) {
		/* wake up the child thread, give it a chance to run */
		assert(eventfd_write(efd2, fd) == 0);
		sched_yield();
	} else
		assert(posix_fadvise(fd, 0, 0, POSIX_FADV_WILLNEED) == 0);

	assert(pread(fd, buf, sizeof(buf), 0) == sizeof(buf));
	assert(clock_gettime(CLOCK_MONOTONIC, &finish) == 0);
	clock_diff(&finish, &start);
	fprintf(stderr, "elapsed: %lu.%09lu\n", finish.tv_sec, finish.tv_nsec);

	if (getenv("FULL_READ")) {
		ssize_t r;
		do {
			r = read(fd, buf, sizeof(buf));
		} while (r > 0);
		assert(r == 0 && "EOF not reached");
	}

	if (getenv("EXIT_EARLY"))
		_exit(0);

	if (do_ra) {
		assert(pthread_join(thr, NULL) == 0);
		assert(close(efd1) == 0);
		assert(close(efd2) == 0);
	}

	assert(close(fd) == 0);

	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
