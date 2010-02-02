From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/11] readahead: retain inactive lru pages to be accessed soon
Date: Tue, 02 Feb 2010 23:28:40 +0800
Message-ID: <20100202153316.936832492@intel.com>
References: <20100202152835.683907822@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1NcKlg-0003kV-Cz
	for glkm-linux-mm-2@m.gmane.org; Tue, 02 Feb 2010 16:34:20 +0100
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C01FE6B0071
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 10:34:16 -0500 (EST)
Content-Disposition: inline; filename=readahead-retain-pages-find_get_page.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Chris Frost <frost@cs.ucla.edu>, Steve VanDeBogart <vandebo@cs.ucla.edu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

From: Chris Frost <frost@cs.ucla.edu>

Ensure that cached pages in the inactive list are not prematurely evicted;
move such pages to lru head when they are covered by
- in-kernel heuristic readahead
- an posix_fadvise(POSIX_FADV_WILLNEED) hint from an application

Before this patch, pages already in core may be evicted before the
pages covered by the same prefetch scan but that were not yet in core.
Many small read requests may be forced on the disk because of this
behavior.

In particular, posix_fadvise(... POSIX_FADV_WILLNEED) on an in-core page
has no effect on the page's location in the LRU list, even if it is the
next victim on the inactive list.

This change helps address the performance problems we encountered
while modifying SQLite and the GIMP to use large file prefetching.
Overall these prefetching techniques improved the runtime of large
benchmarks by 10-17x for these applications. More in the publication
_Reducing Seek Overhead with Application-Directed Prefetching_ in
USENIX ATC 2009 and at http://libprefetch.cs.ucla.edu/.

Signed-off-by: Chris Frost <frost@cs.ucla.edu>
Signed-off-by: Steve VanDeBogart <vandebo@cs.ucla.edu>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/readahead.c |   44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

--- linux.orig/mm/readahead.c	2010-02-01 10:18:57.000000000 +0800
+++ linux/mm/readahead.c	2010-02-01 10:20:51.000000000 +0800
@@ -9,7 +9,9 @@
 
 #include <linux/kernel.h>
 #include <linux/fs.h>
+#include <linux/memcontrol.h>
 #include <linux/mm.h>
+#include <linux/mm_inline.h>
 #include <linux/module.h>
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
@@ -133,6 +135,40 @@ out:
 }
 
 /*
+ * The file range is expected to be accessed in near future.  Move pages
+ * (possibly in inactive lru tail) to lru head, so that they are retained
+ * in memory for some reasonable time.
+ */
+static void retain_inactive_pages(struct address_space *mapping,
+				  pgoff_t index, int len)
+{
+	int i;
+	struct page *page;
+	struct zone *zone;
+
+	for (i = 0; i < len; i++) {
+		page = find_get_page(mapping, index + i);
+		if (!page)
+			continue;
+
+		zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+
+		if (PageLRU(page) &&
+		    !PageActive(page) &&
+		    !PageUnevictable(page)) {
+			int lru = page_lru_base_type(page);
+
+			del_page_from_lru_list(zone, page, lru);
+			add_page_to_lru_list(zone, page, lru);
+		}
+
+		spin_unlock_irq(&zone->lru_lock);
+		put_page(page);
+	}
+}
+
+/*
  * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates all
  * the pages first, then submits them all for I/O. This avoids the very bad
  * behaviour which would occur if page allocations are causing VM writeback.
@@ -184,6 +220,14 @@ __do_page_cache_readahead(struct address
 	}
 
 	/*
+	 * Normally readahead will auto stop on cached segments, so we won't
+	 * hit many cached pages. If it does happen, bring the inactive pages
+	 * adjecent to the newly prefetched ones(if any).
+	 */
+	if (ret < nr_to_read)
+		retain_inactive_pages(mapping, offset, page_idx);
+
+	/*
 	 * Now start the IO.  We ignore I/O errors - if the page is not
 	 * uptodate then the caller will launch readpage again, and
 	 * will then handle the error.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
