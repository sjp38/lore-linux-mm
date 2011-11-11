Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 943126B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 07:35:38 -0500 (EST)
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 2/4] mm: more intensive memory corruption debug
Date: Fri, 11 Nov 2011 13:36:32 +0100
Message-Id: <1321014994-2426-2-git-send-email-sgruszka@redhat.com>
In-Reply-To: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
References: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
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

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 Documentation/kernel-parameters.txt |    9 ++++
 include/linux/mm.h                  |   11 +++++
 include/linux/page-debug-flags.h    |    4 +-
 mm/Kconfig.debug                    |    1 +
 mm/page_alloc.c                     |   74 +++++++++++++++++++++++++++++++----
 5 files changed, 90 insertions(+), 9 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index a0c5c5f..cbfa533 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -567,6 +567,15 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			/proc/<pid>/coredump_filter.
 			See also Documentation/filesystems/proc.txt.
 
+	corrupt_dbg=	[KNL] When CONFIG_DEBUG_PAGEALLOC is set, this
+			parameter allows control order of pages that will be
+			intentionally kept free (and hence protected) by buddy
+			allocator. Bigger value increase probability of
+			catching random memory corruption, but reduce amount
+			of memory for normal system use. Setting this
+			parameter to 1 or 2, should be enough to identify most
+			random memory corruption problems.
+
 	cpuidle.off=1	[CPU_IDLE]
 			disable the cpuidle sub-system
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0a22db1..4de55df 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1617,5 +1617,16 @@ extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned int pages_per_huge_page);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
+extern unsigned int _corrupt_dbg;
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
index 9dd443d..de25c82 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -57,6 +57,7 @@
 #include <linux/ftrace_event.h>
 #include <linux/memcontrol.h>
 #include <linux/prefetch.h>
+#include <linux/page-debug-flags.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -403,6 +404,44 @@ static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)
 		clear_highpage(page + i);
 }
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
+unsigned int _corrupt_dbg;
+
+static int __init corrupt_dbg_setup(char *buf)
+{
+	unsigned long res;
+
+	if (kstrtoul(buf, 10, &res) < 0 ||  res > MAX_ORDER / 2) {
+		printk(KERN_ERR "Bad corrupt_dbg value\n");
+		return 0;
+	}
+	_corrupt_dbg = res;
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
@@ -460,6 +499,11 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
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
@@ -518,9 +562,15 @@ static inline void __free_one_page(struct page *page,
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
@@ -736,7 +786,7 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
  * -- wli
  */
 static inline void expand(struct zone *zone, struct page *page,
-	int low, int high, struct free_area *area,
+	unsigned int low, unsigned int high, struct free_area *area,
 	int migratetype)
 {
 	unsigned long size = 1 << high;
@@ -746,9 +796,16 @@ static inline void expand(struct zone *zone, struct page *page,
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
 
@@ -1756,7 +1813,8 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 {
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
