Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6EEF56B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:56:18 -0500 (EST)
Date: Wed, 20 Jan 2010 13:55:36 -0800
From: Chris Frost <frost@cs.ucla.edu>
Subject: [PATCH] mm/readahead.c: update the LRU positions of in-core pages,
	too
Message-ID: <20100120215536.GN27212@frostnet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

This patch changes readahead to move pages that are already in memory and
in the inactive list to the top of the list. This mirrors the behavior
of non-in-core pages. The position of pages already in the active list
remains unchanged.

The behavior without this patch (leaving in-core pages untouched) means
that pages already in core may be evicted before prefetched pages. Many
small read requests may be forced on the disk because of this behavior.
In particular, note that this behavior means that a system call
posix_fadvise(... POSIX_FADV_WILLNEED) on an in-core page has no effect,
even if that page is the next vitim on the inactive list.

This change helps address the performance problems we encountered
while modifying SQLite and the GIMP to use large file prefetches.
Overall these prefetching techniques improved the runtime of large
benchmarks by 10-17x for these applications. More in the publication
_Reducing Seek Overhead with Application-Directed Prefetching_ in
USENIX ATC 2009 and at http://libprefetch.cs.ucla.edu/.

Signed-off-by: Chris Frost <frost@cs.ucla.edu>
Signed-off-by: Steve VanDeBogart <vandebo@cs.ucla.edu>
---

The sparse checker produces this warning which I believe is ok, but
I do not know how to convince sparse of this:
	mm/readahead.c:144:9: warning: context imbalance in 'retain_pages' - different lock contexts for basic block

 mm/readahead.c |   58 +++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 47 insertions(+), 11 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index aa1aa23..4559563 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -10,6 +10,8 @@
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/memcontrol.h>
+#include <linux/mm_inline.h>
 #include <linux/module.h>
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
@@ -132,6 +134,33 @@ out:
 	return ret;
 }
 
+static void retain_pages(struct pagevec *vec)
+{
+	struct zone *lockedzone = NULL;
+	struct zone *zone;
+	struct page *page;
+	int i;
+
+	for (i = 0; i < pagevec_count(vec); i++) {
+		page = vec->pages[i];
+		zone = page_zone(page);
+		if (zone != lockedzone) {
+			if (lockedzone != NULL)
+				spin_unlock_irq(&lockedzone->lru_lock);
+			lockedzone = zone;
+			spin_lock_irq(&lockedzone->lru_lock);
+		}
+		if (PageLRU(page) && !PageActive(page)) {
+			del_page_from_lru_list(zone, page, LRU_INACTIVE_FILE);
+			add_page_to_lru_list(zone, page, LRU_INACTIVE_FILE);
+		}
+		page_cache_release(page);
+	}
+	if (lockedzone != NULL)
+		spin_unlock_irq(&lockedzone->lru_lock);
+	pagevec_reinit(vec);
+}
+
 /*
  * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates all
  * the pages first, then submits them all for I/O. This avoids the very bad
@@ -147,6 +176,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 {
 	struct inode *inode = mapping->host;
 	struct page *page;
+	struct pagevec retain_vec;
 	unsigned long end_index;	/* The last page we want to read */
 	LIST_HEAD(page_pool);
 	int page_idx;
@@ -157,6 +187,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		goto out;
 
 	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+	pagevec_init(&retain_vec, 0);
 
 	/*
 	 * Preallocate as many pages as we will need.
@@ -170,19 +201,24 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		rcu_read_unlock();
-		if (page)
-			continue;
-
-		page = page_cache_alloc_cold(mapping);
-		if (!page)
-			break;
-		page->index = page_offset;
-		list_add(&page->lru, &page_pool);
-		if (page_idx == nr_to_read - lookahead_size)
-			SetPageReadahead(page);
-		ret++;
+		if (page) {
+			page_cache_get(page);
+			if (!pagevec_add(&retain_vec, page))
+				retain_pages(&retain_vec);
+		} else {
+			page = page_cache_alloc_cold(mapping);
+			if (!page)
+				break;
+			page->index = page_offset;
+			list_add(&page->lru, &page_pool);
+			if (page_idx == nr_to_read - lookahead_size)
+				SetPageReadahead(page);
+			ret++;
+		}
 	}
 
+	retain_pages(&retain_vec);
+
 	/*
 	 * Now start the IO.  We ignore I/O errors - if the page is not
 	 * uptodate then the caller will launch readpage again, and
-- 
1.5.4.3

-- 
Chris Frost
http://www.frostnet.net/chris/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
