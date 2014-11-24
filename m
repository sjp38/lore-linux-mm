Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 17518800CA
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 03:12:49 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so8940802pac.8
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 00:12:48 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id v15si20552059pdi.10.2014.11.24.00.12.41
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 00:12:43 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 2/8] mm/debug-pagealloc: prepare boottime configurable on/off
Date: Mon, 24 Nov 2014 17:15:20 +0900
Message-Id: <1416816926-7756-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Until now, debug-pagealloc needs extra flags in struct page, so we need
to recompile whole source code when we decide to use it. This is really
painful, because it takes some time to recompile and sometimes rebuild is
not possible due to third party module depending on struct page.
So, we can't use this good feature in many cases.

Now, we have the page extension feature that allows us to insert
extra flags to outside of struct page. This gets rid of third party module
issue mentioned above. And, this allows us to determine if we need extra
memory for this page extension in boottime. With these property, we can
avoid using debug-pagealloc in boottime with low computational overhead
in the kernel built with CONFIG_DEBUG_PAGEALLOC. This will help our
development process greatly.

This patch is the preparation step to achive above goal. debug-pagealloc
originally uses extra field of struct page, but, after this patch, it
will use field of struct page_ext. Because memory for page_ext is
allocated later than initialization of page allocator in CONFIG_SPARSEMEM,
we should disable debug-pagealloc feature temporarily until initialization
of page_ext. This patch implements this.

v2: fix compile error on CONFIG_PAGE_POISONING

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mm.h               |   19 ++++++++++++++++++-
 include/linux/mm_types.h         |    4 ----
 include/linux/page-debug-flags.h |   32 --------------------------------
 include/linux/page_ext.h         |   15 +++++++++++++++
 mm/Kconfig.debug                 |    1 +
 mm/debug-pagealloc.c             |   37 +++++++++++++++++++++++++++++++++----
 mm/page_alloc.c                  |   38 +++++++++++++++++++++++++++++++++++---
 mm/page_ext.c                    |    4 ++++
 8 files changed, 106 insertions(+), 44 deletions(-)
 delete mode 100644 include/linux/page-debug-flags.h

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b922a16..5a8d4d4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -19,6 +19,7 @@
 #include <linux/bit_spinlock.h>
 #include <linux/shrinker.h>
 #include <linux/resource.h>
+#include <linux/page_ext.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -2149,20 +2150,36 @@ extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned int pages_per_huge_page);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
+extern struct page_ext_operations debug_guardpage_ops;
+extern struct page_ext_operations page_poisoning_ops;
+
 #ifdef CONFIG_DEBUG_PAGEALLOC
 extern unsigned int _debug_guardpage_minorder;
+extern bool _debug_guardpage_enabled;
 
 static inline unsigned int debug_guardpage_minorder(void)
 {
 	return _debug_guardpage_minorder;
 }
 
+static inline bool debug_guardpage_enabled(void)
+{
+	return _debug_guardpage_enabled;
+}
+
 static inline bool page_is_guard(struct page *page)
 {
-	return test_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
+	struct page_ext *page_ext;
+
+	if (!debug_guardpage_enabled())
+		return false;
+
+	page_ext = lookup_page_ext(page);
+	return test_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
 }
 #else
 static inline unsigned int debug_guardpage_minorder(void) { return 0; }
+static inline bool debug_guardpage_enabled(void) { return false; }
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 33a8acf..c7b22e7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -10,7 +10,6 @@
 #include <linux/rwsem.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
-#include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
 #include <asm/page.h>
@@ -186,9 +185,6 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
-#ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
-	unsigned long debug_flags;	/* Use atomic bitops on this */
-#endif
 
 #ifdef CONFIG_KMEMCHECK
 	/*
diff --git a/include/linux/page-debug-flags.h b/include/linux/page-debug-flags.h
deleted file mode 100644
index 22691f61..0000000
--- a/include/linux/page-debug-flags.h
+++ /dev/null
@@ -1,32 +0,0 @@
-#ifndef LINUX_PAGE_DEBUG_FLAGS_H
-#define  LINUX_PAGE_DEBUG_FLAGS_H
-
-/*
- * page->debug_flags bits:
- *
- * PAGE_DEBUG_FLAG_POISON is set for poisoned pages. This is used to
- * implement generic debug pagealloc feature. The pages are filled with
- * poison patterns and set this flag after free_pages(). The poisoned
- * pages are verified whether the patterns are not corrupted and clear
- * the flag before alloc_pages().
- */
-
-enum page_debug_flags {
-	PAGE_DEBUG_FLAG_POISON,		/* Page is poisoned */
-	PAGE_DEBUG_FLAG_GUARD,
-};
-
-/*
- * Ensure that CONFIG_WANT_PAGE_DEBUG_FLAGS reliably
- * gets turned off when no debug features are enabling it!
- */
-
-#ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
-#if !defined(CONFIG_PAGE_POISONING) && \
-    !defined(CONFIG_PAGE_GUARD) \
-/* && !defined(CONFIG_PAGE_DEBUG_SOMETHING_ELSE) && ... */
-#error WANT_PAGE_DEBUG_FLAGS is turned on with no debug features!
-#endif
-#endif /* CONFIG_WANT_PAGE_DEBUG_FLAGS */
-
-#endif /* LINUX_PAGE_DEBUG_FLAGS_H */
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 2ccc8b4..61c0f05 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -10,6 +10,21 @@ struct page_ext_operations {
 #ifdef CONFIG_PAGE_EXTENSION
 
 /*
+ * page_ext->flags bits:
+ *
+ * PAGE_EXT_DEBUG_POISON is set for poisoned pages. This is used to
+ * implement generic debug pagealloc feature. The pages are filled with
+ * poison patterns and set this flag after free_pages(). The poisoned
+ * pages are verified whether the patterns are not corrupted and clear
+ * the flag before alloc_pages().
+ */
+
+enum page_ext_flags {
+	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
+	PAGE_EXT_DEBUG_GUARD,
+};
+
+/*
  * Page Extension can be considered as an extended mem_map.
  * A page_ext page is associated with every page descriptor. The
  * page_ext helps us add more information about the page.
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 1ba81c7..56badfc 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -12,6 +12,7 @@ config DEBUG_PAGEALLOC
 	depends on DEBUG_KERNEL
 	depends on !HIBERNATION || ARCH_SUPPORTS_DEBUG_PAGEALLOC && !PPC && !SPARC
 	depends on !KMEMCHECK
+	select PAGE_EXTENSION
 	select PAGE_POISONING if !ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	select PAGE_GUARD if ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	---help---
diff --git a/mm/debug-pagealloc.c b/mm/debug-pagealloc.c
index 789ff70..0072f2c 100644
--- a/mm/debug-pagealloc.c
+++ b/mm/debug-pagealloc.c
@@ -2,23 +2,49 @@
 #include <linux/string.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
-#include <linux/page-debug-flags.h>
+#include <linux/page_ext.h>
 #include <linux/poison.h>
 #include <linux/ratelimit.h>
 
+static bool page_poisoning_enabled __read_mostly;
+
+static bool need_page_poisoning(void)
+{
+	return true;
+}
+
+static void init_page_poisoning(void)
+{
+	page_poisoning_enabled = true;
+}
+
+struct page_ext_operations page_poisoning_ops = {
+	.need = need_page_poisoning,
+	.init = init_page_poisoning,
+};
+
 static inline void set_page_poison(struct page *page)
 {
-	__set_bit(PAGE_DEBUG_FLAG_POISON, &page->debug_flags);
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	__set_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
 }
 
 static inline void clear_page_poison(struct page *page)
 {
-	__clear_bit(PAGE_DEBUG_FLAG_POISON, &page->debug_flags);
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	__clear_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
 }
 
 static inline bool page_poison(struct page *page)
 {
-	return test_bit(PAGE_DEBUG_FLAG_POISON, &page->debug_flags);
+	struct page_ext *page_ext;
+
+	page_ext = lookup_page_ext(page);
+	return test_bit(PAGE_EXT_DEBUG_POISON, &page_ext->flags);
 }
 
 static void poison_page(struct page *page)
@@ -95,6 +121,9 @@ static void unpoison_pages(struct page *page, int n)
 
 void kernel_map_pages(struct page *page, int numpages, int enable)
 {
+	if (!page_poisoning_enabled)
+		return;
+
 	if (enable)
 		unpoison_pages(page, numpages);
 	else
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c91f449..7534733 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -56,7 +56,7 @@
 #include <linux/prefetch.h>
 #include <linux/mm_inline.h>
 #include <linux/migrate.h>
-#include <linux/page-debug-flags.h>
+#include <linux/page_ext.h>
 #include <linux/hugetlb.h>
 #include <linux/sched/rt.h>
 
@@ -426,6 +426,22 @@ static inline void prep_zero_page(struct page *page, unsigned int order,
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 unsigned int _debug_guardpage_minorder;
+bool _debug_guardpage_enabled __read_mostly;
+
+static bool need_debug_guardpage(void)
+{
+	return true;
+}
+
+static void init_debug_guardpage(void)
+{
+	_debug_guardpage_enabled = true;
+}
+
+struct page_ext_operations debug_guardpage_ops = {
+	.need = need_debug_guardpage,
+	.init = init_debug_guardpage,
+};
 
 static int __init debug_guardpage_minorder_setup(char *buf)
 {
@@ -444,7 +460,14 @@ __setup("debug_guardpage_minorder=", debug_guardpage_minorder_setup);
 static inline void set_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype)
 {
-	__set_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
+	struct page_ext *page_ext;
+
+	if (!debug_guardpage_enabled())
+		return;
+
+	page_ext = lookup_page_ext(page);
+	__set_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
+
 	INIT_LIST_HEAD(&page->lru);
 	set_page_private(page, order);
 	/* Guard pages are not available for any usage */
@@ -454,12 +477,20 @@ static inline void set_page_guard(struct zone *zone, struct page *page,
 static inline void clear_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype)
 {
-	__clear_bit(PAGE_DEBUG_FLAG_GUARD, &page->debug_flags);
+	struct page_ext *page_ext;
+
+	if (!debug_guardpage_enabled())
+		return;
+
+	page_ext = lookup_page_ext(page);
+	__clear_bit(PAGE_EXT_DEBUG_GUARD, &page_ext->flags);
+
 	set_page_private(page, 0);
 	if (!is_migrate_isolate(migratetype))
 		__mod_zone_freepage_state(zone, (1 << order), migratetype);
 }
 #else
+struct page_ext_operations debug_guardpage_ops = { NULL, };
 static inline void set_page_guard(struct zone *zone, struct page *page,
 				unsigned int order, int migratetype) {}
 static inline void clear_page_guard(struct zone *zone, struct page *page,
@@ -870,6 +901,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		VM_BUG_ON_PAGE(bad_range(zone, &page[size]), &page[size]);
 
 		if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) &&
+			debug_guardpage_enabled() &&
 			high < debug_guardpage_minorder()) {
 			/*
 			 * Mark as guard pages (or page), that will allow to
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 8b3a97a..ede4d1e 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -51,6 +51,10 @@
  */
 
 static struct page_ext_operations *page_ext_ops[] = {
+	&debug_guardpage_ops,
+#ifdef CONFIG_PAGE_POISONING
+	&page_poisoning_ops,
+#endif
 };
 
 static unsigned long total_usage;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
