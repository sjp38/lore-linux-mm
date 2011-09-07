Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 565D66B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 10:11:19 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p87DiWpX025126
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 09:44:32 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p87E9Jk0215298
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 10:09:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p87E9Gom009242
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 10:09:19 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH v2 0/3] staging: zcache: xcfmalloc support
Date: Wed,  7 Sep 2011 09:09:04 -0500
Message-Id: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: dan.magenheimer@oracle.com, ngupta@vflare.org, cascardo@holoscopio.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, linux-mm@kvack.org, rcj@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, brking@linux.vnet.ibm.com, Seth Jennings <sjenning@linux.vnet.ibm.com>

Changelog:
v2: fix bug in find_remove_block()
    fix whitespace warning at EOF

This patchset introduces a new memory allocator for persistent
pages for zcache.  The current allocator is xvmalloc.  xvmalloc
has two notable limitations:
* High (up to 50%) external fragmentation on allocation sets > PAGE_SIZE/2
* No compaction support which reduces page reclaimation

xcfmalloc seeks to fix these issues by using scatter-gather model that
allows for cross-page allocations and relocatable data blocks.

In tests, with pages that only compress to 75% of their original
size, xvmalloc had an effective compression (pages stored / pages used by the
compressed memory pool) of ~95% (~20% lost to fragmentation). Almost nothing
was gained by the compression in this case. xcfmalloc had an effective
compression of ~77% (about ~2% lost to fragmentation and metadata overhead).

xcfmalloc uses the same locking scheme as xvmalloc; a single pool-level
spinlock.  This can lead to some contention.  However, in my tests on a 4
way SMP system, the contention was minimal (200 contentions out of 600k
aquisitions).  The locking scheme may be able to be improved in the future.
In tests, xcfmalloc and xvmalloc had identical throughputs.

While the xcfmalloc design lends itself to compaction, this is not yet
implemented.  Support will be added in a follow-on patch.

Based on 3.1-rc4.

=== xvmalloc vs xcfmalloc ===
Here are some comparison metrics vs xvmalloc.  The tests were done on
a 32-bit system in a a cgroup with a memory.limit_in_bytes of 256MB.
I ran a program that allocates 512MB, one 4k page a time.  The pages
can be filled with zeros or text depending on the command arguments.
The text is english text that has an average compression ratio, using 
lzo1x, of 75% with little deviation.  zv_max_mean_zsize and zv_max_zsize are
both set to 3584 (7 * PAGE_SIZE / 8).

xvmalloc
		curr_pages	zv_page_count	effective compression
zero filled	65859		1269		1.93%
text (75%)	65925		65892		99.95%

xcfmalloc (descriptors are 24 bytes, 170 per 4k page)
		curr_pages	zv_page_count	zv_desc_count	effective compression
zero filled	65845		2068		65858		3.72% (+1.79)
text (75%)	65965		50848		114980		78.11% (-21.84)

This shows that xvmalloc is 1.79 points better on zero filled pages.
This is because xcfmalloc has higher internal fragmentation because
the block sizes aren't as granular as xvmalloc.  This contributes
to 1.21 points of the delta. xcfmalloc also has block descriptors,
which contributes to the remaining 0.58 points.

It also shows that xcfmalloc is 21.84 points better on text filled 
pages. This is because of xcfmalloc allocations can span different
pages which greatly reduces external fragmentation compared to xvmalloc.

I did some quick tests with "time" using the same program and the
timings are very close (3 run average, little deviation):

xvmalloc:
zero filled	0m0.852s
text (75%)	0m14.415s

xcfmalloc:
zero filled	0m0.870s
text (75%)	0m15.089s

I suspect that the small decrease in throughput is due to the
extra memcpy in xcfmalloc.  However, these timing, more than 
anything, demonstrate that the throughput is GREATLY effected
by the compressibility of the data.

In all cases, all swapped pages where captured by frontswap with
no put failures.

Seth Jennings (3):
  staging: zcache: xcfmalloc memory allocator for zcache
  staging: zcache: replace xvmalloc with xcfmalloc
  staging: zcache: add zv_page_count and zv_desc_count

 drivers/staging/zcache/Makefile      |    2 +-
 drivers/staging/zcache/xcfmalloc.c   |  652 ++++++++++++++++++++++++++++++++++
 drivers/staging/zcache/xcfmalloc.h   |   28 ++
 drivers/staging/zcache/zcache-main.c |  154 ++++++---
 4 files changed, 789 insertions(+), 47 deletions(-)
 create mode 100644 drivers/staging/zcache/xcfmalloc.c
 create mode 100644 drivers/staging/zcache/xcfmalloc.h

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
