Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 612D88D0009
	for <linux-mm@kvack.org>; Mon, 14 May 2012 07:58:36 -0400 (EDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ehrhardt@linux.vnet.ibm.com>;
	Mon, 14 May 2012 12:58:34 +0100
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4EBwW3g2506836
	for <linux-mm@kvack.org>; Mon, 14 May 2012 12:58:32 +0100
Received: from d06av06.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4EBwWaM026206
	for <linux-mm@kvack.org>; Mon, 14 May 2012 05:58:32 -0600
From: ehrhardt@linux.vnet.ibm.com
Subject: [PATCH 1/2] swap: allow swap readahead to be merged
Date: Mon, 14 May 2012 13:58:28 +0200
Message-Id: <1336996709-8304-2-git-send-email-ehrhardt@linux.vnet.ibm.com>
In-Reply-To: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
References: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: axboe@kernel.dk, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

Swap readahead works fine, but the I/O to disk is almost always done in page
size requests, despite the fact that readahead submits 1<<page-cluster pages
at a time.
On older kernels the old per device plugging behavior might have captured
this and merged the requests, but currently all comes down to much more I/Os
than required.

On a single device this might not be an issue, but as soon as a server runs
on shared san resources savin I/Os not only improves swapin throughput but
also provides a lower resource utilization.

With a load running KVM in a lot of memory overcommitment (the hot memory
is 1.5 times the host memory) swapping throughput improves significantly
and the lead feels more responsive as well as achieves more throughput.

In a test setup with 16 swap disks running blocktrace on one of those disks
shows the improved merging:
Prior:
Reads Queued:     560,888,    2,243MiB  Writes Queued:     226,242,  904,968KiB
Read Dispatches:  544,701,    2,243MiB  Write Dispatches:  159,318,  904,968KiB
Reads Requeued:         0               Writes Requeued:         0
Reads Completed:  544,716,    2,243MiB  Writes Completed:  159,321,  904,980KiB
Read Merges:       16,187,   64,748KiB  Write Merges:       61,744,  246,976KiB
IO unplugs:       149,614               Timer unplugs:       2,940

With the patch:
Reads Queued:     734,315,    2,937MiB  Writes Queued:     300,188,    1,200MiB
Read Dispatches:  214,972,    2,937MiB  Write Dispatches:  215,176,    1,200MiB
Reads Requeued:         0               Writes Requeued:         0
Reads Completed:  214,971,    2,937MiB  Writes Completed:  215,177,    1,200MiB
Read Merges:      519,343,    2,077MiB  Write Merges:       73,325,  293,300KiB
IO unplugs:       337,130               Timer unplugs:      11,184

Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
---
 mm/swap_state.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 4c5ff7f..c85b559 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/backing-dev.h>
+#include <linux/blkdev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
 #include <linux/page_cgroup.h>
@@ -376,6 +377,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	unsigned long offset = swp_offset(entry);
 	unsigned long start_offset, end_offset;
 	unsigned long mask = (1UL << page_cluster) - 1;
+	struct blk_plug plug;
 
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
@@ -383,6 +385,7 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	if (!start_offset)	/* First page is swap header. */
 		start_offset++;
 
+	blk_start_plug(&plug);
 	for (offset = start_offset; offset <= end_offset ; offset++) {
 		/* Ok, do the async read-ahead now */
 		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
@@ -391,6 +394,8 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			continue;
 		page_cache_release(page);
 	}
+	blk_finish_plug(&plug);
+
 	lru_add_drain();	/* Push any new pages onto the LRU now */
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
