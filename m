Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 832D76B003D
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 18:30:35 -0500 (EST)
Date: Mon, 23 Feb 2009 23:30:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Message-ID: <20090223233030.GA26562@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-21-git-send-email-mel@csn.ul.ie> <20090223013723.1d8f11c1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090223013723.1d8f11c1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 01:37:23AM -0800, Andrew Morton wrote:
> On Sun, 22 Feb 2009 23:17:29 +0000 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Currently an effort is made to determine if a page is hot or cold when
> > it is being freed so that cache hot pages can be allocated to callers if
> > possible. However, the reasoning used whether to mark something hot or
> > cold is a bit spurious. A profile run of kernbench showed that "cold"
> > pages were never freed so it either doesn't happen generally or is so
> > rare, it's barely measurable.
> > 
> > It's dubious as to whether pages are being correctly marked hot and cold
> > anyway. Things like page cache and pages being truncated are are considered
> > "hot" but there is no guarantee that these pages have been recently used
> > and are cache hot. Pages being reclaimed from the LRU are considered
> > cold which is logical because they cannot have been referenced recently
> > but if the system is reclaiming pages, then we have entered allocator
> > slowpaths and are not going to notice any potential performance boost
> > because a "hot" page was freed.
> > 
> > This patch just deletes the concept of freeing hot or cold pages and
> > just frees them all as hot.
> > 
> 
> Well yes.  We waffled for months over whether to merge that code originally.
> 
> What tipped the balance was a dopey microbenchmark which I wrote which
> sat in a loop extending (via write()) and then truncating the same file
> by 32 kbytes (or thereabouts).  Its performance was increased by a lot
> (2x or more, iirc) and no actual regressions were demonstrable, so we
> merged it.
> 
> Could you check that please?  I'd suggest trying various values of 32k,
> too.
> 

I dug around the archives but hadn't much luck finding the original
discussion. I saw some results from around the 2.5.40-mm timeframe that talked
about ~60% difference with this benchmark (http://lkml.org/lkml/2002/10/6/174)
but didn't find the source. The more solid benchmark reports was
https://lwn.net/Articles/14761/ where you talked about 1-2% kernel compile
improvements, good SpecWEB and a big hike on performance with SDET.

It's not clearcut. I tried reproducing your original benchmark rather than
whinging about not finding yours :) . The source is below so maybe you can
tell me if it's equivalent? I only ran it on one CPU which also may be a
factor. The results were

    size      with   without difference
      64  0.216033  0.558803 -158.67%
     128  0.158551  0.150673   4.97%
     256  0.153240  0.153488  -0.16%
     512  0.156502  0.158769  -1.45%
    1024  0.162146  0.163302  -0.71%
    2048  0.167001  0.169573  -1.54%
    4096  0.175376  0.178882  -2.00%
    8192  0.237618  0.243385  -2.43%
   16384  0.735053  0.351040  52.24%
   32768  0.524731  0.583863 -11.27%
   65536  1.149310  1.227855  -6.83%
  131072  2.160248  2.084981   3.48%
  262144  3.858264  4.046389  -4.88%
  524288  8.228358  8.259957  -0.38%
 1048576 16.228190 16.288308  -0.37%

with    == Using hot/cold information to place pages at the front or end of
        the freelist
without == Consider all pages being freed as hot

The results are a bit all over the place but mostly negative but nowhere near
60% of a difference so the benchmark might be wrong. Oddly, 64 shows massive
regressions but 16384 shows massive improvements. With profiling enabled, it's

      64  0.214873  0.196666   8.47%
     128  0.166807  0.162612   2.51%
     256  0.170776  0.161861   5.22%
     512  0.175772  0.164903   6.18%
    1024  0.178835  0.168695   5.67%
    2048  0.183769  0.174317   5.14%
    4096  0.191877  0.183343   4.45%
    8192  0.262511  0.254148   3.19%
   16384  0.388201  0.371461   4.31%
   32768  0.655402  0.611528   6.69%
   65536  1.325445  1.193961   9.92%
  131072  2.218135  2.209091   0.41%
  262144  4.117233  4.116681   0.01%
  524288  8.514915  8.590700  -0.89%
 1048576 16.657330 16.708367  -0.31%

Almost the opposite with steady improvements almost all the way through.

With the patch applied, we are still using hot/cold information on the
allocation side so I'm somewhat surprised the patch even makes much of a
difference. I'd have expected the pages being freed to be mostly hot.

Kernbench was no help figuring this out either.

with:    Elapsed: 74.1625s User: 253.85s System: 27.1s CPU: 378.5%
without: Elapsed: 74.0525s User: 252.9s System: 27.3675s CPU: 378.25%

Improvements on elapsed and user time but a regression on system time.

The issue is sufficiently cloudy that I'm just going to drop the patch
for now. Hopefully the rest of the patchset is more clear-cut. I'll pick
it up again at a later time.

Here is the microbenchmark I used

Thanks.

/*
 * write-truncate.c
 * Microbenchmark that tests the speed of write/truncate of small files.
 * 
 * Suggested by Andrew Morton
 * Written by Mel Gorman 2009
 */
#include <stdio.h>
#include <limits.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/time.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

#define TESTFILE "./write-truncate-testfile.dat"
#define ITERATIONS 10000
#define STARTSIZE 32
#define SIZES 15

#ifndef MIN
#define MIN(x,y) ((x)<(y)?(x):(y))
#endif
#ifndef MAX
#define MAX(x,y) ((x)>(y)?(x):(y))
#endif

double whattime()
{
        struct timeval tp;
        int i;

	if (gettimeofday(&tp,NULL) == -1) {
		perror("gettimeofday");
		exit(EXIT_FAILURE);
	}

        return ( (double) tp.tv_sec + (double) tp.tv_usec * 1.e-6 );
}

int main(void)
{
	int fd;
	int bufsize, sizes, iteration;
	char *buf;
	double t;

	/* Create test file */
	fd = open(TESTFILE, O_RDWR|O_CREAT|O_EXCL);
	if (fd == -1) {
		perror("open");
		exit(EXIT_FAILURE);
	}

	/* Unlink now for cleanup */
	if (unlink(TESTFILE) == -1) {
		perror("unlinke");
		exit(EXIT_FAILURE);
	}

	/* Go through a series of sizes */
	bufsize = STARTSIZE;
	for (sizes = 1; sizes <= SIZES; sizes++) {
		bufsize *= 2;
		buf = malloc(bufsize);
		if (buf == NULL) {
			printf("ERROR: Malloc failed\n");
			exit(EXIT_FAILURE);
		}
		memset(buf, 0xE0, bufsize);

		t = whattime();
		for (iteration = 0; iteration < ITERATIONS; iteration++) {
			size_t written = 0, thiswrite;
			
			while (written != bufsize) {
				thiswrite = write(fd, buf, bufsize);
				if (thiswrite == -1) {
					perror("write");
					exit(EXIT_FAILURE);
				}
				written += thiswrite;
			}

			if (ftruncate(fd, 0) == -1) {
				perror("ftruncate");
				exit(EXIT_FAILURE);
			}

			if (lseek(fd, 0, SEEK_SET) != 0) {
				perror("lseek");
				exit(EXIT_FAILURE);
			}
		}
		t = whattime() - t;
		free(buf);

		printf("%d %f\n", bufsize, t);
	}

	if (close(fd) == -1) {
		perror("close");
		exit(EXIT_FAILURE);
	}

	exit(EXIT_SUCCESS);
}
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
