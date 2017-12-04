Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 883926B0253
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 00:16:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n6so12073521pfg.19
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 21:16:49 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w2si8843439pgc.754.2017.12.03.21.16.47
        for <linux-mm@kvack.org>;
        Sun, 03 Dec 2017 21:16:48 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 3/4] lockdep: Move data of CONFIG_LOCKDEP_PAGELOCK from page to page_ext
Date: Mon,  4 Dec 2017 14:16:22 +0900
Message-Id: <1512364583-26070-4-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
References: <1512364583-26070-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org, akpm@linux-foundation.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com, jack@suse.cz, jlayton@redhat.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, npiggin@gmail.com, rgoldwyn@suse.com, vbabka@suse.cz, mhocko@suse.com, pombredanne@nexb.com, vinmenon@codeaurora.org, gregkh@linuxfoundation.org

CONFIG_LOCKDEP_PAGELOCK needs to keep lockdep_map_cross per page. Since
it's a debug feature, it's preferred to keep it in struct page_ext
rather than struct page. Move it to struct page_ext.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 include/linux/mm_types.h   |  4 ---
 include/linux/page-flags.h | 19 ++++++++--
 include/linux/pagemap.h    | 36 +++++++++++++++----
 lib/Kconfig.debug          |  1 +
 mm/filemap.c               | 87 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |  3 --
 mm/page_ext.c              |  4 +++
 7 files changed, 138 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 263b861..bc52a4a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -222,10 +222,6 @@ struct page {
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
index 108d2dd..32ae372 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -375,28 +375,41 @@ static __always_inline int PageSwapCache(struct page *page)
 
 #ifdef CONFIG_LOCKDEP_PAGELOCK
 #include <linux/lockdep.h>
+extern struct lockdep_map *get_page_map(struct page *p);
 
 TESTPAGEFLAG(Locked, locked, PF_NO_TAIL)
 
 static __always_inline void __SetPageLocked(struct page *page)
 {
+	struct lockdep_map *m;
+
 	__set_bit(PG_locked, &PF_NO_TAIL(page, 1)->flags);
 
 	page = compound_head(page);
-	lock_acquire_exclusive((struct lockdep_map *)&page->map, 0, 1, NULL, _RET_IP_);
+	m = get_page_map(page);
+	if (unlikely(!m))
+		return;
+
+	lock_acquire_exclusive(m, 0, 1, NULL, _RET_IP_);
 }
 
 static __always_inline void __ClearPageLocked(struct page *page)
 {
+	struct lockdep_map *m;
+
 	__clear_bit(PG_locked, &PF_NO_TAIL(page, 1)->flags);
 
 	page = compound_head(page);
+	m = get_page_map(page);
+	if (unlikely(!m))
+		return;
+
 	/*
 	 * lock_commit_crosslock() is necessary for crosslock
 	 * when the lock is released, before lock_release().
 	 */
-	lock_commit_crosslock((struct lockdep_map *)&page->map);
-	lock_release((struct lockdep_map *)&page->map, 0, _RET_IP_);
+	lock_commit_crosslock(m);
+	lock_release(m, 0, _RET_IP_);
 }
 #else
 __PAGEFLAG(Locked, locked, PF_NO_TAIL)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 35b4f67..6722ef7 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -17,6 +17,7 @@
 #include <linux/hugetlb_inline.h>
 #ifdef CONFIG_LOCKDEP_PAGELOCK
 #include <linux/lockdep.h>
+#include <linux/page_ext.h>
 #endif
 
 /*
@@ -461,34 +462,57 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 }
 
 #ifdef CONFIG_LOCKDEP_PAGELOCK
+extern struct page_ext_operations lockdep_pagelock_ops;
+extern struct lockdep_map *get_page_map(struct page *page);
+
 #define lock_page_init(p)						\
 do {									\
 	static struct lock_class_key __key;				\
-	lockdep_init_map_crosslock((struct lockdep_map *)&(p)->map,	\
-			"(PG_locked)" #p, &__key, 0);			\
+	struct lockdep_map *m = get_page_map(p);			\
+									\
+	if (unlikely(!m))						\
+		break;							\
+									\
+	lockdep_init_map_crosslock(m, "(PG_locked)" #p, &__key, 0);	\
 } while (0)
 
 static inline void lock_page_acquire(struct page *page, int try)
 {
+	struct lockdep_map *m;
+
 	page = compound_head(page);
-	lock_acquire_exclusive((struct lockdep_map *)&page->map, 0,
-			       try, NULL, _RET_IP_);
+	m = get_page_map(page);
+	if (unlikely(!m))
+		return;
+
+	lock_acquire_exclusive(m, 0, try, NULL, _RET_IP_);
 }
 
 static inline void lock_page_release(struct page *page)
 {
+	struct lockdep_map *m;
+
 	page = compound_head(page);
+	m = get_page_map(page);
+	if (unlikely(!m))
+		return;
+
 	/*
 	 * lock_commit_crosslock() is necessary for crosslocks.
 	 */
-	lock_commit_crosslock((struct lockdep_map *)&page->map);
-	lock_release((struct lockdep_map *)&page->map, 0, _RET_IP_);
+	lock_commit_crosslock(m);
+	lock_release(m, 0, _RET_IP_);
 }
 #else
 static inline void lock_page_init(struct page *page) {}
 static inline void lock_page_free(struct page *page) {}
 static inline void lock_page_acquire(struct page *page, int try) {}
 static inline void lock_page_release(struct page *page) {}
+
+static inline struct lockdep_map *get_page_map(struct page *page)
+{
+	return NULL;
+}
 #endif
 
 extern void __lock_page(struct page *page);
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 2e8c679..45fdb3a 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1182,6 +1182,7 @@ config LOCKDEP_COMPLETIONS
 
 config LOCKDEP_PAGELOCK
 	bool
+	select PAGE_EXTENSION
 	help
 	 PG_locked lock is a kind of crosslock. Using crossrelease feature,
 	 PG_locked lock can work with lockdep.
diff --git a/mm/filemap.c b/mm/filemap.c
index 870d442..34251fb 100644
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
@@ -1226,6 +1229,90 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 	}
 }
 
+#ifdef CONFIG_LOCKDEP_PAGELOCK
+
+static bool need_lockdep_pagelock(void)
+{
+	return true;
+}
+
+static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
+{
+	struct page *page;
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
+		lock_page_init(page);
+
+		if (get_page_map(page))
+			count++;
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
+	.size = sizeof(struct lockdep_map_cross),
+	.need = need_lockdep_pagelock,
+	.init = init_lockdep_pagelock,
+};
+
+/*
+ * Even though we reserved a space sized of struct lockdep_map_cross,
+ * we only return it as struct lockdep_map, because a full instance of
+ * lockdep_map_cross is only for lockdep cross-release internal.
+ */
+struct lockdep_map *get_page_map(struct page *p)
+{
+	struct page_ext *e;
+
+	e = lookup_page_ext(p);
+	if (!e)
+		return NULL;
+
+	return (void *)e + lockdep_pagelock_ops.offset;
+}
+#endif
+
 /**
  * page_cache_next_hole - find the next hole (not-present entry)
  * @mapping: mapping
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8436b28..77e4d3c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5371,9 +5371,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		} else {
 			__init_single_pfn(pfn, zone, nid);
 		}
-#ifdef CONFIG_LOCKDEP_PAGELOCK
-		lock_page_init(pfn_to_page(pfn));
-#endif
 	}
 }
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 4f0367d..63ae336 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -8,6 +8,7 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
+#include <linux/pagemap.h>
 
 /*
  * struct page extension
@@ -66,6 +67,9 @@
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
