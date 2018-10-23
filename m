Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3C1096B000A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 08:27:54 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id f2-v6so633782ybo.1
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 05:27:54 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c186-v6si622250ybb.302.2018.10.23.05.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 05:27:52 -0700 (PDT)
Date: Tue, 23 Oct 2018 05:27:38 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V6 00/21] swap: Swapout/swapin THP in one piece
Message-ID: <20181023122738.a5j2vk554tsx4f6i@ca-dmjordan1.us.oracle.com>
References: <20181010071924.18767-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010071924.18767-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Wed, Oct 10, 2018 at 03:19:03PM +0800, Huang Ying wrote:
> And for all, Any comment is welcome!
> 
> This patchset is based on the 2018-10-3 head of mmotm/master.

There seems to be some infrequent memory corruption with THPs that have been
swapped out: page contents differ after swapin.

Reproducer at the bottom.  Part of some tests I'm writing, had to separate it a
little hack-ily.  Basically it writes the word offset _at_ each word offset in
a memory blob, tries to push it to swap, and verifies the offset is the same
after swapin.

I ran with THP enabled=always.  THP swapin_enabled could be always or never, it
happened with both.  Every time swapping occurred, a single THP-sized chunk in
the middle of the blob had different offsets.  Example:

** > word corruption gap
** corruption detected 14929920 bytes in (got 15179776, expected 14929920) **
** corruption detected 14929928 bytes in (got 15179784, expected 14929928) **
** corruption detected 14929936 bytes in (got 15179792, expected 14929936) **
...pattern continues...
** corruption detected 17027048 bytes in (got 15179752, expected 17027048) **
** corruption detected 17027056 bytes in (got 15179760, expected 17027056) **
** corruption detected 17027064 bytes in (got 15179768, expected 17027064) **
100.0% of memory was swapped out at mincore time
0.00305% of pages were corrupted (first corrupt word 14929920, last corrupt word 17027064)

The problem goes away with THP enabled=never, and I don't see it on 2018-10-3
mmotm/master with THP enabled=always.

The server had an NVMe swap device and ~760G memory over two nodes, and the
program was always run like this:  swap-verify -s $((64 * 2**30))

The kernels had one extra patch, Alexander Duyck's
"dma-direct: Fix return value of dma_direct_supported", which was required to
get them to build.

---------------------------------------8<---------------------------------------

/*
 * swap-verify.c - helper to verify contents of swapped out pages
 *
 * Daniel Jordan <daniel.m.jordan@oracle.com>
 */

#define _GNU_SOURCE
#include <getopt.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>

#define TEST_SUCCESS	0
#define TEST_FAIL	1
#define TEST_SKIP	2

static void usagedie(int exitcode)
{
	fprintf(stderr, "usage: swap-verify\n"
			"    -h                show this message\n"
			"    -s bytes\n");
	exit(exitcode);
}

int main(int argc, char **argv)
{
	int c, pgsize;
	char *pages;
	unsigned char *mincore_vec;
	size_t i, j, nr_pages_swapped, nr_pages_corrupted;
	size_t bytes = 1ul << 30;	/* default 1G */
	ssize_t bytes_read;
	size_t first_corrupt_word, last_corrupt_word, prev_corrupt_word;

	while ((c = getopt(argc, argv, "hs:")) != -1) {
		switch (c) {
		case 'h':
			usagedie(0);
			break;
		case 's':
			bytes = strtoul(optarg, NULL, 10);
			break;
		default:
			fprintf(stderr, "unrecognized option %c\n", c);
			exit(TEST_SKIP);
		}
	}

	pgsize = getpagesize();

	if ((mincore_vec = calloc(bytes / pgsize, 1)) == NULL) {
		perror("calloc");
		exit(TEST_SKIP);
	}

	if ((pages = mmap(NULL, bytes, PROT_READ | PROT_WRITE,
			  MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)) == MAP_FAILED) {
		perror("mmap");
		exit(TEST_SKIP);
	}

	/* Fill pages with a "random" pattern. */
	for (i = 0; i < bytes; i += sizeof(unsigned long))
		*(unsigned long *)(pages + i) = i;

	/* Now fill memory, trying to push the pages just allocated to swap. */
	system("./use-mem-total");

	/* Is the memory swapped out? */
	if (mincore(pages, bytes, mincore_vec) == -1) {
		perror("mincore");
		exit(TEST_SKIP);
	}

	nr_pages_swapped = 0;
	nr_pages_corrupted = 0;
	first_corrupt_word = bytes;
	last_corrupt_word = 0;
	prev_corrupt_word = bytes;
	for (i = 0; i < bytes; i += pgsize) {
		bool page_corrupt = false;
		if (mincore_vec[i / pgsize] & 1) {
			/* Resident, don't bother checking. */
			continue;
		}
		++nr_pages_swapped;
		for (j = i; j < i + pgsize; j += sizeof(unsigned long)) {
			unsigned long val = *(unsigned long *)(pages + j);
			if (val != j) {
				if (!page_corrupt)
					++nr_pages_corrupted;
				page_corrupt = true;
				if (j - prev_corrupt_word != sizeof(unsigned long))
					fprintf(stderr, "** > word corruption gap\n");
				if (j % (1ul << 21) == 0)
					fprintf(stderr, "-- THP boundary\n");
				if (j < first_corrupt_word)
					first_corrupt_word = j;
				if (j > last_corrupt_word)
					last_corrupt_word = j;
				fprintf(stderr, "** corruption detected %lu "
					"bytes in (got %lu, expected %lu) **\n",
					j, val, j);
				prev_corrupt_word = j;
			}
		}
	}
	fprintf(stderr, "%.1f%% of memory was swapped out at mincore time\n",
	       ((double)nr_pages_swapped / (bytes / pgsize)) * 100);

	if (nr_pages_corrupted) {
		fprintf(stderr, "%.5f%% of pages were corrupted (first corrupt "
			"word %lu, last corrupt word %lu)\n",
			((double)nr_pages_corrupted / (bytes / pgsize)) * 100,
			first_corrupt_word, last_corrupt_word);
	} else {
		fprintf(stderr, "no memory corruption detected\n");
	}
	return (nr_pages_corrupted) ? TEST_FAIL : TEST_SUCCESS;
}

---------------------------------------8<---------------------------------------

#!/usr/bin/env bash
#
# use-mem-total
#
# Helper that allocates MemTotal and exits immediately.  Useful for causing
# swapping of previously allocated memory.

# XXX fix paths
source /path/to/vm-scalability/hw_vars

/path/to/usemem --thread $nr_task --step $pagesize -q --repeat 4 \
	$(( mem * 11 / 10 / nr_task )) > /dev/null

---------------------------------------8<---------------------------------------
