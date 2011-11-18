Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A6D036B006E
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:23:03 -0500 (EST)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH v2 1/3] mm: more intensive memory corruption debug
Date: Fri, 18 Nov 2011 17:25:05 +0100
Message-Id: <1321633507-13614-1-git-send-email-sgruszka@redhat.com>
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

When kernel is compiled with CONFIG_DEBUG_PAGEALLOC,
debug_guardpage_minorder defines the minimum order used by the page
allocator to grant a request. The requested size will be returned with
the remaining pages used as guard pages.

v1 -> v2:
 - change "corrupt" name to guard page
 - document disability to debug memory corruption happened at bus level
 - document max order limitation
 - add comments about adding/removing guard pages from buddy allocator
 - do not change types in expand()

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 Documentation/kernel-parameters.txt |   18 ++++++++
 include/linux/mm.h                  |   17 ++++++++
 include/linux/page-debug-flags.h    |    4 +-
 mm/Kconfig.debug                    |    5 ++
 mm/page_alloc.c                     |   75 ++++++++++++++++++++++++++++++++---
 5 files changed, 112 insertions(+), 7 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index a0c5c5f..92e2076 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -623,6 +623,24 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	no_debug_objects
 			[KNL] Disable object debugging
 
+	debug_guardpage_minorder=
+			[KNL] When CONFIG_DEBUG_PAGEALLOC is set, this
+			parameter allows control order of pages that will be
+			intentionally kept free (and hence protected) by buddy
+			allocator. Bigger value increase probability of
+			catching random memory corruption, but reduce amount
+			of memory for normal system use. Maximum possible
+			value is MAX_ORDER/2. Setting this parameter to 1 or 2,
+			should be enough to identify most random memory
+			corruption problems caused by bugs in kernel/drivers
+			code when CPU write to (or read from) random memory
+			location. Note that there exist class of memory
+			corruptions problems caused by buggy H/W or F/W or by
+			drivers badly programing DMA (basically when memory is
+			written at bus level and CPU MMU is bypassed), which
+			are not detectable by CONFIG_DEBUG_PAGEALLOC, hence this
+			option would not help tracking down these problems too.
+
 	debugpat	[X86] Enable PAT debugging
 
 	decnet.addr=	[HW,NET]
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0a22db1..90c3f69 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1617,5 +1617,22 @@ extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned int pages_per_huge_page);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
+extern unsigned int _debug_guardpage_minorder;
+
+static inline unsigned int debug_guardpage_minorder(void)
+{
+	return _debug_guardpage_minorder;
+}
+
+static inline bool page_is_guard(struct page *page)
+{
+	return test_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
+}
+#else
+static inline unsigned int debug_guardpage_minorder(void) { return 0; }
+static inline bool page_is_guard(struct page *page) { return false; }
+#endif /* CONFIG_DEBUG_PAGEALLOC */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/page-debug-flags.h b/include/linux/page-debug-flags.h
index b0638fd..22691f6 100644
--- a/include/linux/page-debug-flags.h
+++ b/include/linux/page-debug-flags.h
@@ -13,6 +13,7 @@
 
 enum page_debug_flags {
 	PAGE_DEBUG_FLAG_POISON,		/* Page is poisoned */
+	PAGE_DEBUG_FLAG_GUARD,
 };
 
 /*
@@ -21,7 +22,8 @@ enum page_debug_flags {
  */
 
 #ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
-#if !defined(CONFIG_PAGE_POISONING) \
+#if !defined(CONFIG_PAGE_POISONING) && \
+    !defined(CONFIG_PAGE_GUARD) \
 /* && !defined(CONFIG_PAGE_DEBUG_SOMETHING_ELSE) && ... */
 #error WANT_PAGE_DEBUG_FLAGS is turned on with no debug features!
 #endif
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 8b1a477..4b24432 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -4,6 +4,7 @@ config DEBUG_PAGEALLOC
 	depends on !HIBERNATION || ARCH_SUPPORTS_DEBUG_PAGEALLOC && !PPC && !SPARC
 	depends on !KMEMCHECK
 	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	select PAGE_GUARD if ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	---help---
 	  Unmap pages from the kernel linear mapping after free_pages().
 	  This results in a large slowdown, but helps to find certain types
@@ -22,3 +23,7 @@ config WANT_PAGE_DEBUG_FLAGS
 config PAGE_POISONING
 	bool
 	select WANT_PAGE_DEBUG_FLAGS
+
+config PAGE_GUARD
+	bool
+	select WANT_PAGE_DEBUG_FLAGS
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..16e4f8e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -57,6 +57,7 @@
 #include <linux/ftrace_event.h>
 #include <linux/memcontrol.h>
 #include <linux/prefetch.h>
+#include <linux/page-debug-flags.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -403,6 +404,37 @@ static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
 		clear_highpage(page + i);
 }
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
+unsigned int _debug_guardpage_minorder;
+
+static int __init debug_guardpage_minorder_setup(char *buf)
+{
+	unsigned long res;
+
+	if (kstrtoul(buf, 10, &res) < 0 ||  res > MAX_ORDER / 2) {
+		printk(KERN_ERR "Bad debug_guardpage_minorder value\n");
+		return 0;
+	}
+	_debug_guardpage_minorder = res;
+	printk(KERN_INFO "Setting debug_guardpage_minorder to %lu\n", res);
+	return 0;
+}
+__setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
+
+static inline void set_page_guard_flg(struct page *page)
+{
+	__set_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
+}
+
+static inline void clear_page_guard_flg(struct page *page)
+{
+	__clear_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
+}
+#else
+static inline void set_page_guard_flg(struct page *page) { }
+static inline void clear_page_guard_flg(struct page *page) { }
+#endif
+
 static inline void set_page_order(struct page *page, int order)
 {
 	set_page_private(page, order);
@@ -460,6 +492,11 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	if (page_zone_id(page) != page_zone_id(buddy))
 		return 0;
 
+	if (page_is_guard(buddy) && page_order(buddy) == order) {
+		VM_BUG_ON(page_count(buddy) != 0);
+		return 1;
+	}
+
 	if (PageBuddy(buddy) && page_order(buddy) == order) {
 		VM_BUG_ON(page_count(buddy) != 0);
 		return 1;
@@ -516,11 +553,19 @@ static inline void __free_one_page(struct page *page,
 		buddy = page + (buddy_idx - page_idx);
 		if (!page_is_buddy(page, buddy, order))
 			break;
-
-		/* Our buddy is free, merge with it and move up one order. */
-		list_del(&buddy->lru);
-		zone->free_area[order].nr_free--;
-		rmv_page_order(buddy);
+		/*
+		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
+		 * merge with it and move up one order.
+		 */
+		if (page_is_guard(buddy)) {
+			clear_page_guard_flg(buddy);
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
@@ -746,6 +791,23 @@ static inline void expand(struct zone *zone, struct page *page,
 		high--;
 		size >>= 1;
 		VM_BUG_ON(bad_range(zone, &page[size]));
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+		if (high < debug_guardpage_minorder()) {
+			/*
+			 * Mark as guard pages (or page), that will allow to
+			 * merge back to allocator when buddy will be freed.
+			 * Corresponding page table entries will not be touched,
+			 * pages will stay not present in virtual address space
+			 */
+			INIT_LIST_HEAD(&page[size].lru);
+			set_page_guard_flg(&page[size]);
+			set_page_private(&page[size], high);
+			/* Guard pages are not available for any usage */
+			__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << high));
+			continue;
+		}
+#endif
 		list_add(&page[size].lru, &area->free_list[migratetype]);
 		area->nr_free++;
 		set_page_order(&page[size], high);
@@ -1756,7 +1818,8 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 {
 	unsigned int filter = SHOW_MEM_FILTER_NODES;
 
-	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
+	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
+	    debug_guardpage_minorder() > 0)
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
