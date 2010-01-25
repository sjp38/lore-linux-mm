Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 625E36B009C
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 17:37:17 -0500 (EST)
Date: Mon, 25 Jan 2010 14:36:35 -0800
From: Chris Frost <frost@cs.ucla.edu>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
Message-ID: <20100125223635.GC2822@frostnet.net>
References: <20100120215536.GN27212@frostnet.net> <20100121054734.GC24236@localhost> <20100123040348.GC30844@frostnet.net> <20100123102222.GA6943@localhost> <20100125094228.f7ca1430.kamezawa.hiroyu@jp.fujitsu.com> <20100125024544.GA16462@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100125024544.GA16462@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

I changed Wu's patch to add a PageLRU() guard that I believe is required
and optimized zone lock acquisition to only unlock and lock at zone changes.
This optimization seems to provide a 10-20% system time improvement for
some of my GIMP benchmarks and no improvement for other benchmarks.

I agree that the remove and add lru list entry code looks correct.
putback_lru_page() has to worry about a page's evictable status
changing, but I think this code does not because it holds the page
zone lock.

Wu removed the ClearPageReadahead(page) call on in-core pages that
Kamezawa's change added. This removal, not making this call, looks
ok to me.

Thanks Wu and Kamezawa.


What's next?

---
readahead: retain inactive lru pages to be accessed soon
From: Chris Frost <frost@cs.ucla.edu>

Ensure that cached pages in the inactive list are not prematurely evicted;
move such pages to lru head when they are covered by
- in-kernel heuristic readahead
- an posix_fadvise(POSIX_FADV_WILLNEED) hint from an application

Before this patch, pages already in core may be evicted before the
pages covered by the same prefetch scan but that were not yet in core.
Many small read requests may be forced on the disk because of this behavior.

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
 readahead.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/mm/readahead.c b/mm/readahead.c
index aa1aa23..c1d67ab 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -9,7 +9,9 @@
 
 #include <linux/kernel.h>
 #include <linux/fs.h>
+#include <linux/memcontrol.h>
 #include <linux/mm.h>
+#include <linux/mm_inline.h>
 #include <linux/module.h>
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
@@ -133,6 +135,43 @@ out:
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
+	struct zone *locked_zone = NULL;
+
+	for (i = 0; i < len; i++) {
+		page = find_get_page(mapping, index + i);
+		if (!page)
+			continue;
+		zone = page_zone(page);
+		if (zone != locked_zone) {
+			if (locked_zone)
+				spin_unlock_irq(&locked_zone->lru_lock);
+			locked_zone = zone;
+			spin_lock_irq(&locked_zone->lru_lock);
+		}
+		if (!PageActive(page) && !PageUnevictable(page) &&
+		    PageLRU(page)) {
+			int lru = page_lru_base_type(page);
+
+			del_page_from_lru_list(zone, page, lru);
+			add_page_to_lru_list(zone, page, lru);
+		}
+		put_page(page);
+	}
+	if (locked_zone)
+		spin_unlock_irq(&locked_zone->lru_lock);
+}
+
+/*
  * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates all
  * the pages first, then submits them all for I/O. This avoids the very bad
  * behaviour which would occur if page allocations are causing VM writeback.
@@ -184,6 +223,14 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
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
Chris Frost
http://www.frostnet.net/chris/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
