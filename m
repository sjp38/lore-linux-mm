Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D346990010D
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 23:31:44 -0400 (EDT)
Message-Id: <20110430033018.169293004@intel.com>
Date: Sat, 30 Apr 2011 11:22:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/3] readahead: trigger mmap sequential readahead on PG_readahead
References: <20110430032243.355805181@intel.com>
Content-Disposition: inline; filename=readahead-no-mmap-prev_pos.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Li Shaohua <shaohua.li@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Previously the mmap sequential readahead is triggered by updating
ra->prev_pos on each page fault and compare it with current page offset.

It costs dirtying the cache line on each _minor_ page fault.  So remove
the ra->prev_pos recording, and instead tag PG_readahead to trigger the
possible sequential readahead. It's not only more simple, but also will
work more reliably and reduce cache line bouncing on concurrent page
faults on shared struct file.

Tested-by: Tim Chen <tim.c.chen@intel.com>
Reported-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- linux-next.orig/mm/filemap.c	2011-04-23 16:52:21.000000000 +0800
+++ linux-next/mm/filemap.c	2011-04-24 09:59:08.000000000 +0800
@@ -1531,8 +1531,7 @@ static void do_sync_mmap_readahead(struc
 	if (!ra->ra_pages)
 		return;
 
-	if (VM_SequentialReadHint(vma) ||
-			offset - 1 == (ra->prev_pos >> PAGE_CACHE_SHIFT)) {
+	if (VM_SequentialReadHint(vma)) {
 		page_cache_sync_readahead(mapping, ra, file, offset,
 					  ra->ra_pages);
 		return;
@@ -1555,7 +1554,7 @@ static void do_sync_mmap_readahead(struc
 	ra_pages = max_sane_readahead(ra->ra_pages);
 	ra->start = max_t(long, 0, offset - ra_pages / 2);
 	ra->size = ra_pages;
-	ra->async_size = 0;
+	ra->async_size = ra_pages / 4;
 	ra_submit(ra, mapping, file);
 }
 
@@ -1661,7 +1660,6 @@ retry_find:
 		return VM_FAULT_SIGBUS;
 	}
 
-	ra->prev_pos = (loff_t)offset << PAGE_CACHE_SHIFT;
 	vmf->page = page;
 	return ret | VM_FAULT_LOCKED;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
