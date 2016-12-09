Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8C16B0272
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:38 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so16917073pgx.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:38 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id c68si32060070pfj.98.2016.12.08.21.16.36
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:37 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 14/15] lockdep: Move data used in CONFIG_LOCKDEP_PAGELOCK from page to page_ext
Date: Fri,  9 Dec 2016 14:12:10 +0900
Message-Id: <1481260331-360-15-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

CONFIG_LOCKDEP_PAGELOCK is keeping data, with which lockdep can check
and detect deadlock by page lock, e.g. lockdep_map and cross_lock in
struct page. But move it to page_ext since it's a debug feature so it's
preferred to keep it in struct page_ext than struct page.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/mm_types.h   |  5 ----
 include/linux/page-flags.h | 19 ++++++++++--
 include/linux/page_ext.h   |  5 ++++
 include/linux/pagemap.h    | 28 +++++++++++++++---
 lib/Kconfig.debug          |  1 +
 mm/filemap.c               | 72 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |  3 --
 mm/page_ext.c              |  4 +++
 8 files changed, 122 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 87db0ac..6558e12 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -224,11 +224,6 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
-
-#ifdef CONFIG_LOCKDEP_PAGELOCK
-	struct lockdep_map map;
-	struct cross_lock xlock;
-#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e28f232..9f677ff 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -352,28 +352,41 @@ PAGEFLAG(Idle, idle, PF_ANY)
 
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
-	lock_acquire_exclusive(&page->map, 0, 1, NULL, _RET_IP_);
+	e = lookup_page_ext(page);
+	if (unlikely(!e))
+		return;
+
+	lock_acquire_exclusive(&e->map, 0, 1, NULL, _RET_IP_);
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
-	lock_commit_crosslock(&page->map);
-	lock_release(&page->map, 0, _RET_IP_);
+	lock_commit_crosslock(&e->map);
+	lock_release(&e->map, 0, _RET_IP_);
 }
 #else
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index e1fe7cf..f84e9be 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -48,6 +48,11 @@ struct page_ext {
 	int last_migrate_reason;
 	unsigned long trace_entries[8];
 #endif
+
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+	struct lockdep_map map;
+	struct cross_lock xlock;
+#endif
 };
 
 extern void pgdat_page_ext_init(struct pglist_data *pgdat);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index dbe7adf..79174ad 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -16,6 +16,7 @@
 #include <linux/hugetlb_inline.h>
 #ifdef CONFIG_LOCKDEP_PAGELOCK
 #include <linux/lockdep.h>
+#include <linux/page_ext.h>
 #endif
 
 /*
@@ -417,28 +418,47 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 }
 
 #ifdef CONFIG_LOCKDEP_PAGELOCK
+extern struct page_ext_operations lockdep_pagelock_ops;
+
 #define lock_page_init(p)					\
 do {								\
 	static struct lock_class_key __key;			\
-	lockdep_init_map_crosslock(&(p)->map, &(p)->xlock,	\
+	struct page_ext *e = lookup_page_ext(p);		\
+								\
+	if (unlikely(!e))					\
+		break;						\
+								\
+	lockdep_init_map_crosslock(&(e)->map, &(e)->xlock,	\
 			"(PG_locked)" #p, &__key, 0);		\
 } while (0)
 
 static inline void lock_page_acquire(struct page *page, int try)
 {
+	struct page_ext *e;
+
 	page = compound_head(page);
-	lock_acquire_exclusive(&page->map, 0, try, NULL, _RET_IP_);
+	e = lookup_page_ext(page);
+	if (unlikely(!e))
+		return;
+
+	lock_acquire_exclusive(&e->map, 0, try, NULL, _RET_IP_);
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
 	 * lock_commit_crosslock() is necessary for crosslock
 	 * when the lock is released, before lock_release().
 	 */
-	lock_commit_crosslock(&page->map);
-	lock_release(&page->map, 0, _RET_IP_);
+	lock_commit_crosslock(&e->map);
+	lock_release(&e->map, 0, _RET_IP_);
 }
 #else
 static inline void lock_page_init(struct page *page) {}
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 1926435..9c6dc15 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1051,6 +1051,7 @@ config LOCKDEP_COMPLETE
 config LOCKDEP_PAGELOCK
 	bool "Lock debugging: allow PG_locked lock to use deadlock detector"
 	select LOCKDEP_CROSSRELEASE
+	select PAGE_EXTENSION
 	default n
 	help
 	 PG_locked lock is a kind of crosslock. Using crossrelease feature,
diff --git a/mm/filemap.c b/mm/filemap.c
index e1f60fd..a6a52a4 100644
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
@@ -955,6 +958,75 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
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
index 0adc46c..8b3e134 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5225,9 +5225,6 @@ not_early:
 		} else {
 			__init_single_pfn(pfn, zone, nid);
 		}
-#ifdef CONFIG_LOCKDEP_PAGELOCK
-		lock_page_init(pfn_to_page(pfn));
-#endif
 	}
 }
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 44a4c02..54f7027 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -7,6 +7,7 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
+#include <linux/pagemap.h>
 
 /*
  * struct page extension
@@ -63,6 +64,9 @@ static struct page_ext_operations *page_ext_ops[] = {
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
