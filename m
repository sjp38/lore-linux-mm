Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 36F3E9000C2
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:51:07 -0400 (EDT)
Message-Id: <20110426094859.334469737@intel.com>
Date: Tue, 26 Apr 2011 17:43:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/3] readahead: return early when readahead is disabled
References: <20110426094352.030753173@intel.com>
Content-Disposition: inline; filename=readahead-early-abort-mmap-around.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Li Shaohua <shaohua.li@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Reduce readahead overheads by returning early in
do_sync_mmap_readahead().

tmpfs has ra_pages=0 and it can page fault really fast
(not constraint by IO if not swapping).

Tested-by: Tim Chen <tim.c.chen@intel.com>
Reported-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- linux-next.orig/mm/filemap.c	2011-04-23 08:56:59.000000000 +0800
+++ linux-next/mm/filemap.c	2011-04-23 09:01:44.000000000 +0800
@@ -1528,6 +1528,8 @@ static void do_sync_mmap_readahead(struc
 	/* If we don't want any read-ahead, don't bother */
 	if (VM_RandomReadHint(vma))
 		return;
+	if (!ra->ra_pages)
+		return;
 
 	if (VM_SequentialReadHint(vma) ||
 			offset - 1 == (ra->prev_pos >> PAGE_CACHE_SHIFT)) {
@@ -1550,12 +1552,10 @@ static void do_sync_mmap_readahead(struc
 	 * mmap read-around
 	 */
 	ra_pages = max_sane_readahead(ra->ra_pages);
-	if (ra_pages) {
-		ra->start = max_t(long, 0, offset - ra_pages/2);
-		ra->size = ra_pages;
-		ra->async_size = 0;
-		ra_submit(ra, mapping, file);
-	}
+	ra->start = max_t(long, 0, offset - ra_pages / 2);
+	ra->size = ra_pages;
+	ra->async_size = 0;
+	ra_submit(ra, mapping, file);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
