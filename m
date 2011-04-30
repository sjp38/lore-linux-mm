From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/3] readahead: return early when readahead is disabled
Date: Sat, 30 Apr 2011 11:22:44 +0800
Message-ID: <20110430033017.923224207__43528.2211787582$1304134360$gmane$org@intel.com>
References: <20110430032243.355805181@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=readahead-early-abort-mmap-around.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Li Shaohua <shaohua.li@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

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
