Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 593A46B002F
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 10:25:50 -0400 (EDT)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC 1/3 repost to correct ML] mm: more intensive memory corruption debug
Date: Mon, 17 Oct 2011 16:24:44 +0200
Message-Id: <1318861486-3942-1-git-send-email-sgruszka@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>, Stanislaw Gruszka <sgruszka@redhat.com>

With CONFIG_DEBUG_PAGEALLOC configured, cpu will generate exception on
access (read,write) to not allocated page, what allow to catch code
which corrupt memory. However kernel is trying to maximalise memory
usage, hence there is usually not much free pages in the system and
buggy code usually corrupt some crucial data.

This patch change buddy allocator to keep more free/protected pages
and interlace free/protected and allocated pages to increase probability
of catch a corruption.

When kernel is compiled with CONFIG_DEBUG_PAGEALLOC, corrupt_dbg
parameter is available to specify page order that should be kept free.

I.e:

* corrupt_dbg=1:
  - order=0 allocation will result of 1 page allocated and 1 consecutive
    page protected
  - order > 0 allocations are not affected
* corrupt_dbg=2
  - order=0 allocation will result 1 allocated page and 3 consecutive
    pages protected
  - order=1 allocation will result 2 allocated pages and 2 consecutive
    pages protected
  - order > 1 allocations are not affected
* and so on

Probably only practical usage is corrupt_dbg=1, as long someone is not
really desperate by memory corruption bug and have huge amount of RAM.

Patch should not cause any executable code change when kernel is
compiled without CONFIG_DEBUG_PAGEALLOC, but I did not check that yet.

There some issues with patch:

- With corrupt_dbg=1 I expect /proc/buddyinfo will always show 0-order
  allocation count equal to 0, however this is not true, sometimes this
  value shows 1, I'm not able to explain that.

- When dropping caches system may hang on:

  RIP: 0010:[<ffffffff81266337>]  [<ffffffff81266337>] radix_tree_gang_lookup_slot+0x47/0xf0
  Call Trace:
    [<ffffffff8111ecd0>] find_get_pages+0x70/0x1b0
    [<ffffffff8111ec60>] ? find_get_pages_contig+0x180/0x180
    [<ffffffff811297b2>] pagevec_lookup+0x22/0x30
    [<ffffffff8112b404>] invalidate_mapping_pages+0x84/0x1e0
    [<ffffffff811ab797>] drop_pagecache_sb+0xb7/0xf0

 Not sure if this is problem of my patch, or pagevec_lookup has some
 corner case problem.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 include/linux/mm.h               |   12 ++++++
 include/linux/page-debug-flags.h |    4 ++-
 mm/Kconfig.debug                 |    1 +
 mm/page_alloc.c                  |   69 +++++++++++++++++++++++++++++++++----
 4 files changed, 77 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7438071..17e3658 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1627,5 +1627,17 @@ extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned int pages_per_huge_page);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
+extern unsigned int _corrupt_dbg;
+
+
+static inline unsigned int corrupt_dbg(void)
+{
+	return _corrupt_dbg;
+}
+#else
+static inline unsigned int corrupt_dbg(void) { return 0; }
+#endif /* CONFIG_DEBUG_PAGEALLOC */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/page-debug-flags.h b/include/linux/page-debug-flags.h
index b0638fd..f63c905 100644
--- a/include/linux/page-debug-flags.h
+++ b/include/linux/page-debug-flags.h
@@ -13,6 +13,7 @@
 
 enum page_debug_flags {
 	PAGE_DEBUG_FLAG_POISON,		/* Page is poisoned */
+	PAGE_DEBUG_FLAG_CORRUPT,
 };
 
 /*
@@ -21,7 +22,8 @@ enum page_debug_flags {
  */
 
 #ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
-#if !defined(CONFIG_PAGE_POISONING) \
+#if !defined(CONFIG_PAGE_POISONING) && \
+    !defined(CONFIG_DEBUG_PAGEALLOC) \
 /* && !defined(CONFIG_PAGE_DEBUG_SOMETHING_ELSE) && ... */
 #error WANT_PAGE_DEBUG_FLAGS is turned on with no debug features!
 #endif
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 8b1a477..3c554f0 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -4,6 +4,7 @@ config DEBUG_PAGEALLOC
 	depends on !HIBERNATION || ARCH_SUPPORTS_DEBUG_PAGEALLOC && !PPC && !SPARC
 	depends on !KMEMCHECK
 	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	select WANT_PAGE_DEBUG_FLAGS
 	---help---
 	  Unmap pages from the kernel linear mapping after free_pages().
 	  This results in a large slowdown, but helps to find certain types
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..8d18ae4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -57,6 +57,7 @@
 #include <linux/ftrace_event.h>
 #include <linux/memcontrol.h>
 #include <linux/prefetch.h>
+#include <linux/page-debug-flags.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -402,6 +403,39 @@ static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
 		clear_highpage(page + i);
 }
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
+unsigned int _corrupt_dbg;
+
+static int __init corrupt_dbg_setup(char *buf)
+{
+	_corrupt_dbg = simple_strtoul(buf, &buf, 10);
+	/* FIXME: check range ? */
+	printk(KERN_INFO "Setting corrupt debug order to %d\n", _corrupt_dbg);
+	return 0;
+}
+__setup("corrupt_dbg=", corrupt_dbg_setup);
+
+static inline void set_page_corrupt_dbg(struct page *page)
+{
+	__set_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
+}
+
+static inline void clear_page_corrupt_dbg(struct page *page)
+{
+	__clear_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
+}
+
+static inline bool page_is_corrupt_dbg(struct page *page)
+{
+	return test_bit(PAGE_DEBUG_FLAG_CORRUPT, &page->debug_flags);
+}
+
+#else
+static inline void set_page_corrupt_dbg(struct page *page) { }
+static inline void clear_page_corrupt_dbg(struct page *page) { }
+static inline bool page_is_corrupt_dbg(struct page *page) { return false; }
+#endif
+
 static inline void set_page_order(struct page *page, int order)
 {
 	set_page_private(page, order);
@@ -459,6 +493,11 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	if (page_zone_id(page) != page_zone_id(buddy))
 		return 0;
 
+	if (page_is_corrupt_dbg(buddy) && page_order(buddy) == order) {
+		VM_BUG_ON(page_count(buddy) != 0);
+		return 1;
+	}
+
 	if (PageBuddy(buddy) && page_order(buddy) == order) {
 		VM_BUG_ON(page_count(buddy) != 0);
 		return 1;
@@ -517,9 +556,15 @@ static inline void __free_one_page(struct page *page,
 			break;
 
 		/* Our buddy is free, merge with it and move up one order. */
-		list_del(&buddy->lru);
-		zone->free_area[order].nr_free--;
-		rmv_page_order(buddy);
+		if (page_is_corrupt_dbg(buddy)) {
+			clear_page_corrupt_dbg(buddy);
+			set_page_private(page, 0);
+			__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
+		} else {
+			list_del(&buddy->lru);
+			zone->free_area[order].nr_free--;
+			rmv_page_order(buddy);
+		}
 		combined_idx = buddy_idx & page_idx;
 		page = page + (combined_idx - page_idx);
 		page_idx = combined_idx;
@@ -735,7 +780,7 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
  * -- wli
  */
 static inline void expand(struct zone *zone, struct page *page,
-	int low, int high, struct free_area *area,
+	unsigned int low, unsigned int high, struct free_area *area,
 	int migratetype)
 {
 	unsigned long size = 1 << high;
@@ -745,9 +790,16 @@ static inline void expand(struct zone *zone, struct page *page,
 		high--;
 		size >>= 1;
 		VM_BUG_ON(bad_range(zone, &page[size]));
-		list_add(&page[size].lru, &area->free_list[migratetype]);
-		area->nr_free++;
-		set_page_order(&page[size], high);
+		if (high < corrupt_dbg()) {
+			INIT_LIST_HEAD(&page[size].lru);
+			set_page_corrupt_dbg(&page[size]);
+			set_page_private(&page[size], high);
+			__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << high));
+		} else {
+			set_page_order(&page[size], high);
+			list_add(&page[size].lru, &area->free_list[migratetype]);
+			area->nr_free++;
+		}
 	}
 }
 
@@ -1756,7 +1808,8 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 	va_list args;
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 
-	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
+	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
+	    corrupt_dbg() > 0)
 		return;
 
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
