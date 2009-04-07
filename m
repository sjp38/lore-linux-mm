From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 14/14] readahead: record mmap read-around states in file_ra_state
Date: Tue, 07 Apr 2009 19:50:53 +0800
Message-ID: <20090407115235.345682017@intel.com>
References: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2AE5D5F0003
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:52 -0400 (EDT)
Content-Disposition: inline; filename=readahead-mmap-readaround-use-ra_submit.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

Mmap read-around now shares the same code style and data structure
with readahead code.

This also removes do_page_cache_readahead().
Its last user, mmap read-around, has been changed to call ra_submit().

The no-readahead-if-congested logic is dumped by the way.
Users will be pretty sensitive about the slow loading of executables.
So it's unfavorable to disabled mmap read-around on a congested queue.

Cc: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Fengguang Wu <wfg@mail.ustc.edu.cn>
---
 include/linux/mm.h |    5 +++--
 mm/filemap.c       |   12 +++++++-----
 mm/readahead.c     |   23 ++---------------------
 3 files changed, 12 insertions(+), 28 deletions(-)

--- mm.orig/mm/filemap.c
+++ mm/mm/filemap.c
@@ -1556,13 +1556,15 @@ static void do_sync_mmap_readahead(struc
 	if (ra->mmap_miss > MMAP_LOTSAMISS)
 		return;
 
+	/*
+	 * mmap read-around
+	 */
 	ra_pages = max_sane_readahead(ra->ra_pages);
 	if (ra_pages) {
-		pgoff_t start = 0;
-
-		if (offset > ra_pages / 2)
-			start = offset - ra_pages / 2;
-		do_page_cache_readahead(mapping, file, start, ra_pages);
+		ra->start = max_t(long, 0, offset - ra_pages/2);
+		ra->size = ra_pages;
+		ra->async_size = 0;
+		ra_submit(ra, mapping, file);
 	}
 }
 
--- mm.orig/include/linux/mm.h
+++ mm/include/linux/mm.h
@@ -1183,8 +1183,6 @@ void task_dirty_inc(struct task_struct *
 #define VM_MAX_READAHEAD	128	/* kbytes */
 #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
 
-int do_page_cache_readahead(struct address_space *mapping, struct file *filp,
-			pgoff_t offset, unsigned long nr_to_read);
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 			pgoff_t offset, unsigned long nr_to_read);
 
@@ -1202,6 +1200,9 @@ void page_cache_async_readahead(struct a
 				unsigned long size);
 
 unsigned long max_sane_readahead(unsigned long nr);
+unsigned long ra_submit(struct file_ra_state *ra,
+		        struct address_space *mapping,
+			struct file *filp);
 
 /* Do stack extension */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);
--- mm.orig/mm/readahead.c
+++ mm/mm/readahead.c
@@ -146,15 +146,12 @@ out:
 }
 
 /*
- * do_page_cache_readahead actually reads a chunk of disk.  It allocates all
+ * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates all
  * the pages first, then submits them all for I/O. This avoids the very bad
  * behaviour which would occur if page allocations are causing VM writeback.
  * We really don't want to intermingle reads and writes like that.
  *
  * Returns the number of pages requested, or the maximum amount of I/O allowed.
- *
- * do_page_cache_readahead() returns -1 if it encountered request queue
- * congestion.
  */
 static int
 __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
@@ -245,22 +242,6 @@ int force_page_cache_readahead(struct ad
 }
 
 /*
- * This version skips the IO if the queue is read-congested, and will tell the
- * block layer to abandon the readahead if request allocation would block.
- *
- * force_page_cache_readahead() will ignore queue congestion and will block on
- * request queues.
- */
-int do_page_cache_readahead(struct address_space *mapping, struct file *filp,
-			pgoff_t offset, unsigned long nr_to_read)
-{
-	if (bdi_read_congested(mapping->backing_dev_info))
-		return -1;
-
-	return __do_page_cache_readahead(mapping, filp, offset, nr_to_read, 0);
-}
-
-/*
  * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
  * sensible upper limit.
  */
@@ -285,7 +266,7 @@ subsys_initcall(readahead_init);
 /*
  * Submit IO for the read-ahead request in file_ra_state.
  */
-static unsigned long ra_submit(struct file_ra_state *ra,
+unsigned long ra_submit(struct file_ra_state *ra,
 		       struct address_space *mapping, struct file *filp)
 {
 	int actual;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
