Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3482B900234
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 09:49:43 -0400 (EDT)
From: Andrea Righi <andrea@betterlinux.com>
Subject: [PATCH v3 1/2] mm: introduce __invalidate_mapping_pages()
Date: Fri, 24 Jun 2011 15:49:09 +0200
Message-Id: <1308923350-7932-2-git-send-email-andrea@betterlinux.com>
In-Reply-To: <1308923350-7932-1-git-send-email-andrea@betterlinux.com>
References: <1308923350-7932-1-git-send-email-andrea@betterlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@mit.edu>, Shaohua Li <shaohua.li@intel.com>, =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This new function accepts an additional parameter respect to the old
invalidate_mapping_pages() that allows to specify when we want to apply
an aggressive policy to drop file cache pages or when we just want to
reduce cache eligibility.

The new prototype is the following:

 unsigned long __invalidate_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t end, bool force)

When force is true pages are always dropped if possible. When force is
false inactive pages are dropped and active pages are moved to the
inactive list.

This can be used to apply different levels of page cache invalidation
(e.g, by fadvise).

The old invalidate_mapping_pages() behavior can be mapped to
__invalidate_mapping_pages(..., true) using a C-preprocessor macro.

Signed-off-by: Andrea Righi <andrea@betterlinux.com>
---
 include/linux/fs.h |    7 +++++--
 mm/swap.c          |    2 +-
 mm/truncate.c      |   40 ++++++++++++++++++++++++++++++----------
 3 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 6e73e2e..33beefe 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2149,8 +2149,11 @@ extern int check_disk_change(struct block_device *);
 extern int __invalidate_device(struct block_device *, bool);
 extern int invalidate_partition(struct gendisk *, int);
 #endif
-unsigned long invalidate_mapping_pages(struct address_space *mapping,
-					pgoff_t start, pgoff_t end);
+
+#define invalidate_mapping_pages(__mapping, __start, __end)	\
+		__invalidate_mapping_pages(__mapping, __start, __end, true)
+unsigned long __invalidate_mapping_pages(struct address_space *mapping,
+					pgoff_t start, pgoff_t end, bool force);
 
 static inline void invalidate_remote_inode(struct inode *inode)
 {
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..a8fe6ac 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -413,7 +413,7 @@ void add_page_to_unevictable_list(struct page *page)
  * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
  * 3. inactive, mapped page -> none
  * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
- * 5. inactive, clean -> inactive, tail
+ * 5. [in]active, clean -> inactive, tail
  * 6. Others -> none
  *
  * In 4, why it moves inactive's head, the VM expects the page would
diff --git a/mm/truncate.c b/mm/truncate.c
index 3a29a61..90f3a97 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -312,20 +312,27 @@ void truncate_inode_pages(struct address_space *mapping, loff_t lstart)
 EXPORT_SYMBOL(truncate_inode_pages);
 
 /**
- * invalidate_mapping_pages - Invalidate all the unlocked pages of one inode
+ * __invalidate_mapping_pages - Invalidate all the unlocked pages of one inode
  * @mapping: the address_space which holds the pages to invalidate
  * @start: the offset 'from' which to invalidate
  * @end: the offset 'to' which to invalidate (inclusive)
+ * @force: always drop pages when true (otherwise, reduce cache eligibility)
  *
  * This function only removes the unlocked pages, if you want to
  * remove all the pages of one inode, you must call truncate_inode_pages.
  *
- * invalidate_mapping_pages() will not block on IO activity. It will not
- * invalidate pages which are dirty, locked, under writeback or mapped into
- * pagetables.
+ * The @force parameter can be used to apply a more aggressive policy (when
+ * true) that will always drop pages from page cache when possible, or to just
+ * reduce cache eligibility (when false). In the last case active pages will be
+ * moved to the tail of the inactive list by deactivate_page(); inactive pages
+ * will be dropped in both cases.
+ *
+ * __invalidate_mapping_pages() will not block on IO activity. It will not
+ * invalidate pages which are dirty, locked, under writeback, mapped into
+ * pagetables, or on active lru when @force is false.
  */
-unsigned long invalidate_mapping_pages(struct address_space *mapping,
-		pgoff_t start, pgoff_t end)
+unsigned long __invalidate_mapping_pages(struct address_space *mapping,
+		pgoff_t start, pgoff_t end, bool force)
 {
 	struct pagevec pvec;
 	pgoff_t next = start;
@@ -356,11 +363,24 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			next++;
 			if (lock_failed)
 				continue;
-
-			ret = invalidate_inode_page(page);
+			/*
+			 * Invalidation of active page is rather aggressive as
+			 * we can't make sure it's not a working set of other
+			 * processes.
+			 *
+			 * When force is false, deactivate_page() would move
+			 * active page into inactive's tail so the page will
+			 * have a chance to activate again if other processes
+			 * touch it.
+			 */
+			if (!force && PageActive(page))
+				ret = 0;
+			else
+				ret = invalidate_inode_page(page);
 			unlock_page(page);
 			/*
-			 * Invalidation is a hint that the page is no longer
+			 * Invalidation of an inactive page (or any page when
+			 * force is true) is a hint that the page is no longer
 			 * of interest and try to speed up its reclaim.
 			 */
 			if (!ret)
@@ -375,7 +395,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	}
 	return count;
 }
-EXPORT_SYMBOL(invalidate_mapping_pages);
+EXPORT_SYMBOL(__invalidate_mapping_pages);
 
 /*
  * This is like invalidate_complete_page(), except it ignores the page's
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
