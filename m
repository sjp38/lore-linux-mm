Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5491C6B0047
	for <linux-mm@kvack.org>; Sun, 24 Jan 2010 21:45:52 -0500 (EST)
Date: Mon, 25 Jan 2010 10:45:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
Message-ID: <20100125024544.GA16462@localhost>
References: <20100120215536.GN27212@frostnet.net> <20100121054734.GC24236@localhost> <20100123040348.GC30844@frostnet.net> <20100123102222.GA6943@localhost> <20100125094228.f7ca1430.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20100125094228.f7ca1430.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Chris Frost <frost@CS.UCLA.EDU>, Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 24, 2010 at 05:42:28PM -0700, KAMEZAWA Hiroyuki wrote:
> On Sat, 23 Jan 2010 18:22:22 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Why do you think mem_cgroup shall be notified here? As me understand
> > it, mem_cgroup should only care about page addition/removal.
> > 
> No. memcg maintains its LRU list in synchronous way with global LRU.
> So, I think it's better to call usual LRU handler calls as Chris does.

Ah right, thanks for the reminder!

> And...for maintainance, I like following code rather than your direct code.
> Because you mention " Not expected to happen frequently."

Yup, won't be frequent for in-kernel readahead and for _sane_ fadvise() users :)

> void find_isolate_inactive_page(struct address_space *mapping,  pgoff_t index, int len)
> {
> 	int i = 0;
> 	struct list_head *list;
> 
> 	for (i = 0; i < len; i++)
> 		page = find_get_page(mapping, index + i);
> 		if (!page)
> 			continue;
> 		zone = page_zone(page);
> 		spin_lock_irq(&zone->lru_lock); /* you can optimize this if you want */

I don't care to optimize.  Chris?

> 		/* isolate_lru_page() doesn't handle the type of list, so call __isolate_lru_page */
> 		if (__isolate_lru_page(page, ISOLATE_INACTIVE, 1)

__isolate_lru_page() didn't actually take off page from lru, hence at
least the accounting will be wrong. I'll just use Chris'
del_page_from_lru_list()/add_page_to_lru_list() pare.

> 			continue;
> 		spin_unlock_irq(&zone->lru_lock);
> 		ClearPageReadahead(page);
> 		putback_lru_page(page);
> 	}
> }
> 
> Please feel free to do as you want but please takeing care of memcg' lru management.

OK, thanks.

I updated the patch with your signs pre-added.
Please ack or optimize..

Thanks,
Fengguang
---
readahead: retain inactive lru pages to be accessed soon

From: Chris Frost <frost@cs.ucla.edu>

Make sure the cached pages in inactive list won't be evicted too soon,
by moving them back to lru head, when they are covered by
- in-kernel heuristic readahead
- posix_fadvise(POSIX_FADV_WILLNEED) hint from applications

Before patch, pages already in core may be evicted before prefetched
pages. Many small read requests may be forced on the disk because of
this behavior.

In particular, posix_fadvise(... POSIX_FADV_WILLNEED) on an in-core page
has no effect, even if that page is the next victim on the inactive list.

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
 mm/readahead.c |   39 +++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c    |    1 -
 2 files changed, 39 insertions(+), 1 deletion(-)

--- linux-mm.orig/mm/readahead.c	2010-01-25 09:17:31.000000000 +0800
+++ linux-mm/mm/readahead.c	2010-01-25 10:40:12.000000000 +0800
@@ -9,7 +9,9 @@
 
 #include <linux/kernel.h>
 #include <linux/fs.h>
+#include <linux/memcontrol.h>
 #include <linux/mm.h>
+#include <linux/mm_inline.h>
 #include <linux/module.h>
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
@@ -133,6 +135,35 @@ out:
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
+		zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		if (!PageActive(page) && !PageUnevictable(page)) {
+			int lru = page_lru_base_type(page);
+
+			del_page_from_lru_list(zone, page, lru);
+			add_page_to_lru_list(zone, page, lru);
+		}
+		spin_unlock_irq(&zone->lru_lock);
+		put_page(page);
+	}
+}
+
+/*
  * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates all
  * the pages first, then submits them all for I/O. This avoids the very bad
  * behaviour which would occur if page allocations are causing VM writeback.
@@ -184,6 +215,14 @@ __do_page_cache_readahead(struct address
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
--- linux-mm.orig/mm/vmscan.c	2010-01-25 08:58:40.000000000 +0800
+++ linux-mm/mm/vmscan.c	2010-01-25 09:17:27.000000000 +0800
@@ -2892,4 +2892,3 @@ void scan_unevictable_unregister_node(st
 {
 	sysdev_remove_file(&node->sysdev, &attr_scan_unevictable_pages);
 }
-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
