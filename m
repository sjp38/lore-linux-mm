Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4CA6B0271
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:18:00 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 75so16298495pgf.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:18:00 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o32si233478pld.41.2017.01.18.05.17.58
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:17:58 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 12/13] lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
Date: Wed, 18 Jan 2017 22:17:38 +0900
Message-Id: <1484745459-2055-13-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

CONFIG_LOCKDEP_PAGELOCK needs to keep lockdep_map_cross per page, to
work with lockdep. Since it's a debug feature, it's preferred to keep
it in struct page_ext than struct page. Move it to struct page_ext.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/mm_types.h   |  4 ---
 include/linux/page-flags.h | 19 ++++++++++--
 include/linux/page_ext.h   |  4 +++
 include/linux/pagemap.h    | 28 +++++++++++++++---
 lib/Kconfig.debug          |  1 +
 mm/filemap.c               | 72 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |  3 --
 mm/page_ext.c              |  4 +++
 8 files changed, 121 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 06adfa2..a6c7133 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -225,10 +225,6 @@ struct page {
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
index 9d5f79d..cca33f5 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -355,28 +355,41 @@ static __always_inline int PageCompound(struct page *page)
 
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
index a3ecec1..e38a5c8 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -16,6 +16,7 @@
 #include <linux/hugetlb_inline.h>
 #ifdef CONFIG_LOCKDEP_PAGELOCK
 #include <linux/lockdep.h>
+#include <linux/page_ext.h>
 #endif
 
 /*
@@ -436,28 +437,47 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
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
index 69364d0..0b3118b 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1066,6 +1066,7 @@ config LOCKDEP_COMPLETE
 config LOCKDEP_PAGELOCK
 	bool "Lock debugging: allow PG_locked lock to use deadlock detector"
 	select LOCKDEP_CROSSRELEASE
+	select PAGE_EXTENSION
 	default n
 	help
 	 PG_locked lock is a kind of crosslock. Using crossrelease feature,
diff --git a/mm/filemap.c b/mm/filemap.c
index d439cc7..03d669f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -35,6 +35,9 @@
 #include <linux/memcontrol.h>
 #include <linux/cleancache.h>
 #include <linux/rmap.h>
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+#include <linux/page_ext.h>
+#endif
 #include "internal.h"
 
 #define CREATE_TRACE_POINTS
@@ -986,6 +989,75 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
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
+		if (PageReserved(page))
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
index 36d5f9e..6de9440 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5063,9 +5063,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		} else {
 			__init_single_pfn(pfn, zone, nid);
 		}
-#ifdef CONFIG_LOCKDEP_PAGELOCK
-		lock_page_init(pfn_to_page(pfn));
-#endif
 	}
 }
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 121dcff..023ac65 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -7,6 +7,7 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
+#include <linux/pagemap.h>
 
 /*
  * struct page extension
@@ -68,6 +69,9 @@
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
