Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6516B037C
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:15 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p20so87180669pfj.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:15 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id h6si4989333plk.799.2017.08.07.00.14.13
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:14 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 13/14] lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
Date: Mon,  7 Aug 2017 16:13:00 +0900
Message-Id: <1502089981-21272-14-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

CONFIG_LOCKDEP_PAGELOCK needs to keep lockdep_map_cross per page. Since
it's a debug feature, it's preferred to keep it in struct page_ext than
struct page. Move it to struct page_ext.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/mm_types.h   |  4 ---
 include/linux/page-flags.h | 19 +++++++++++--
 include/linux/page_ext.h   |  4 +++
 include/linux/pagemap.h    | 28 ++++++++++++++++---
 lib/Kconfig.debug          |  1 +
 mm/filemap.c               | 69 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |  3 --
 mm/page_ext.c              |  4 +++
 8 files changed, 118 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f1e3dba..ac3121c 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -220,10 +220,6 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
-
-#ifdef CONFIG_LOCKDEP_PAGELOCK
-	struct lockdep_map_cross map;
-#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index b793342..879dd0d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -374,28 +374,41 @@ static __always_inline int PageSwapCache(struct page *page)
 
 #ifdef CONFIG_LOCKDEP_PAGELOCK
 #include <linux/lockdep.h>
+#include <linux/page_ext.h>
 
 TESTPAGEFLAG(Locked, locked, PF_NO_TAIL)
 
 static __always_inline void __SetPageLocked(struct page *page)
 {
+	struct page_ext *e;
+
 	__set_bit(PG_locked, &PF_NO_TAIL(page, 1)->flags);
 
 	page = compound_head(page);
-	lock_acquire_exclusive((struct lockdep_map *)&page->map, 0, 1, NULL, _RET_IP_);
+	e = lookup_page_ext(page);
+	if (unlikely(!e))
+		return;
+
+	lock_acquire_exclusive((struct lockdep_map *)&e->map, 0, 1, NULL, _RET_IP_);
 }
 
 static __always_inline void __ClearPageLocked(struct page *page)
 {
+	struct page_ext *e;
+
 	__clear_bit(PG_locked, &PF_NO_TAIL(page, 1)->flags);
 
 	page = compound_head(page);
+	e = lookup_page_ext(page);
+	if (unlikely(!e))
+		return;
+
 	/*
 	 * lock_commit_crosslock() is necessary for crosslock
 	 * when the lock is released, before lock_release().
 	 */
-	lock_commit_crosslock((struct lockdep_map *)&page->map);
-	lock_release((struct lockdep_map *)&page->map, 0, _RET_IP_);
+	lock_commit_crosslock((struct lockdep_map *)&e->map);
+	lock_release((struct lockdep_map *)&e->map, 0, _RET_IP_);
 }
 #else
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 9298c39..d1c52c8c 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -44,6 +44,10 @@ enum page_ext_flags {
  */
 struct page_ext {
 	unsigned long flags;
+
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+	struct lockdep_map_cross map;
+#endif
 };
 
 extern void pgdat_page_ext_init(struct pglist_data *pgdat);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 9f448c6..b75b8bc 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -16,6 +16,7 @@
 #include <linux/hugetlb_inline.h>
 #ifdef CONFIG_LOCKDEP_PAGELOCK
 #include <linux/lockdep.h>
+#include <linux/page_ext.h>
 #endif
 
 /*
@@ -454,28 +455,47 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 }
 
 #ifdef CONFIG_LOCKDEP_PAGELOCK
+extern struct page_ext_operations lockdep_pagelock_ops;
+
 #define lock_page_init(p)						\
 do {									\
 	static struct lock_class_key __key;				\
-	lockdep_init_map_crosslock((struct lockdep_map *)&(p)->map,	\
+	struct page_ext *e = lookup_page_ext(p);		\
+								\
+	if (unlikely(!e))					\
+		break;						\
+								\
+	lockdep_init_map_crosslock((struct lockdep_map *)&(e)->map,	\
 			"(PG_locked)" #p, &__key, 0);			\
 } while (0)
 
 static inline void lock_page_acquire(struct page *page, int try)
 {
+	struct page_ext *e;
+
 	page = compound_head(page);
-	lock_acquire_exclusive((struct lockdep_map *)&page->map, 0,
+	e = lookup_page_ext(page);
+	if (unlikely(!e))
+		return;
+
+	lock_acquire_exclusive((struct lockdep_map *)&e->map, 0,
 			       try, NULL, _RET_IP_);
 }
 
 static inline void lock_page_release(struct page *page)
 {
+	struct page_ext *e;
+
 	page = compound_head(page);
+	e = lookup_page_ext(page);
+	if (unlikely(!e))
+		return;
+
 	/*
 	 * lock_commit_crosslock() is necessary for crosslocks.
 	 */
-	lock_commit_crosslock((struct lockdep_map *)&page->map);
-	lock_release((struct lockdep_map *)&page->map, 0, _RET_IP_);
+	lock_commit_crosslock((struct lockdep_map *)&e->map);
+	lock_release((struct lockdep_map *)&e->map, 0, _RET_IP_);
 }
 #else
 static inline void lock_page_init(struct page *page) {}
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 99b5f76..3a890fb 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1096,6 +1096,7 @@ config LOCKDEP_COMPLETE
 config LOCKDEP_PAGELOCK
 	bool "Lock debugging: allow PG_locked lock to use deadlock detector"
 	select LOCKDEP_CROSSRELEASE
+	select PAGE_EXTENSION
 	default n
 	help
 	 PG_locked lock is a kind of crosslock. Using crossrelease feature,
diff --git a/mm/filemap.c b/mm/filemap.c
index 0d83bf0..6372bd8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -36,6 +36,9 @@
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
 #include <linux/rmap.h>
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#include <linux/page_ext.h>
+#endif
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -1210,6 +1213,72 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 	}
 }
 
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+static bool need_lockdep_pagelock(void) { return true; }
+
+static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
+{
+	struct page *page;
+	struct page_ext *page_ext;
+	unsigned long pfn = zone->zone_start_pfn;
+	unsigned long end_pfn = pfn + zone->spanned_pages;
+	unsigned long count = 0;
+
+	for (; pfn < end_pfn; pfn++) {
+		if (!pfn_valid(pfn)) {
+			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
+			continue;
+		}
+
+		if (!pfn_valid_within(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+
+		if (page_zone(page) != zone)
+			continue;
+
+		page_ext = lookup_page_ext(page);
+		if (unlikely(!page_ext))
+			continue;
+
+		lock_page_init(page);
+		count++;
+	}
+
+	pr_info("Node %d, zone %8s: lockdep pagelock found early allocated %lu pages\n",
+		pgdat->node_id, zone->name, count);
+}
+
+static void init_zones_in_node(pg_data_t *pgdat)
+{
+	struct zone *zone;
+	struct zone *node_zones = pgdat->node_zones;
+	unsigned long flags;
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		if (!populated_zone(zone))
+			continue;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		init_pages_in_zone(pgdat, zone);
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+}
+
+static void init_lockdep_pagelock(void)
+{
+	pg_data_t *pgdat;
+	for_each_online_pgdat(pgdat)
+		init_zones_in_node(pgdat);
+}
+
+struct page_ext_operations lockdep_pagelock_ops = {
+	.need = need_lockdep_pagelock,
+	.init = init_lockdep_pagelock,
+};
+#endif
+
 /**
  * page_cache_next_hole - find the next hole (not-present entry)
  * @mapping: mapping
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2cbf412..6d30e91 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5406,9 +5406,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		} else {
 			__init_single_pfn(pfn, zone, nid);
 		}
-#ifdef CONFIG_LOCKDEP_PAGELOCK
-		lock_page_init(pfn_to_page(pfn));
-#endif
 	}
 }
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 88ccc044..2ac1fb1 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -7,6 +7,7 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
+#include <linux/pagemap.h>
 
 /*
  * struct page extension
@@ -65,6 +66,9 @@
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	&page_idle_ops,
 #endif
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+	&lockdep_pagelock_ops,
+#endif
 };
 
 static unsigned long total_usage;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
