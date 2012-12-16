Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 6D4156B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 19:25:50 -0500 (EST)
Date: Sun, 16 Dec 2012 00:25:49 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216002549.GA19402@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121215223448.08272fd5@pyramind.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121215223448.08272fd5@pyramind.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> On Sat, 15 Dec 2012 00:54:48 +0000
> Eric Wong <normalperson@yhbt.net> wrote:
> 
> > Applications streaming large files may want to reduce disk spinups and
> > I/O latency by performing large amounts of readahead up front
> 
> How does it compare benchmark wise with a user thread or using the
> readahead() call ?

Very well.

My main concern is for the speed of the initial pread()/read() call
after open().

Setting EARLY_EXIT means my test program _exit()s immediately after the
first pread().  In my test program (below), I wait for the background
thread to become ready before open() so I would not take overhead from
pthread_create() into account.

RA=1 uses a pthread + readahead()
Not setting RA uses fadvise (with my patch)

# readahead + pthread.
$ EARLY_EXIT=1 RA=1 time  ./first_read 1G
0.00user 0.05system 0:01.37elapsed 3%CPU (0avgtext+0avgdata 600maxresident)k
0inputs+0outputs (1major+187minor)pagefaults 0swaps

# patched fadvise
$ EARLY_EXIT=1 time ./first_read 1G
0.00user 0.00system 0:00.01elapsed 0%CPU (0avgtext+0avgdata 564maxresident)k
0inputs+0outputs (1major+178minor)pagefaults 0swaps

Perhaps I screwed up my readahead() + threads path badly, but there
seems to be a huge benefit in using fadvise with my patch.  I'm not sure
why readahead() + thread does so badly, even...

Even if I badly screwed up my use of readahead(), the benefit of my
patch spares others from screwing up when using threads+readahead() :)

FULL_READ
---------
While full, fast reads are not my target use case, there's no noticeable
regression here, either.  Results for doing a full, fast read on the file
are closer and fluctuate more between runs.

# readahead + pthread.
$ FULL_READ=1 EARLY_EXIT=1 RA=1 time ./first_read 1G
0.01user 1.10system 0:09.24elapsed 12%CPU (0avgtext+0avgdata 596maxresident)k
0inputs+0outputs (1major+186minor)pagefaults 0swaps

# patched fadvise
FULL_READ=1 EARLY_EXIT=1 time ./first_read 1G
0.01user 1.04system 0:09.22elapsed 11%CPU (0avgtext+0avgdata 564maxresident)k
0inputs+0outputs (1major+178minor)pagefaults 0swaps

--------------------------------- 8< ------------------------------
/* gcc -O2 -Wall -lpthread -o first_read first_read.c */
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

static int efd1;
static int efd2;

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

	if (do_ra) {
		/* wake up the child thread, give it a chance to run */
		assert(eventfd_write(efd2, fd) == 0);
		sched_yield();
	} else
		assert(posix_fadvise(fd, 0, 0, POSIX_FADV_WILLNEED) == 0);

	assert(pread(fd, buf, sizeof(buf), 0) == sizeof(buf));

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
--------------------------------- 8< ------------------------------

Thanks for your interest in this!

-- 
Eric Wong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
