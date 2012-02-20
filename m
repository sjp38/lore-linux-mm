Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 68AB46B0102
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:24:01 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:24:00 -0800 (PST)
Subject: [PATCH v2 22/22] mm: split zone->lru_lock
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:23:57 +0400
Message-ID: <20120220172357.22196.67636.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks like all ready for splitting zone->lru_lock into per-lruvec pieces.

lruvec locking loop protected with rcu. Memory controller already releases its
lru-vectors via rcu, lru-vectors embedded into zones never released.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mmzone.h |    2 -
 mm/compaction.c        |    2 -
 mm/internal.h          |  100 ++++++++++++++++++++++++++++++------------------
 mm/memcontrol.c        |    1 
 mm/page_alloc.c        |    2 -
 mm/swap.c              |    2 -
 6 files changed, 68 insertions(+), 41 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9fd82b1..56995db 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -301,6 +301,7 @@ struct lruvec {
 	struct pglist_data	*node;
 	struct zone		*zone;
 #endif
+	spinlock_t		lru_lock;
 	struct list_head	pages_lru[NR_LRU_LISTS];
 	unsigned long		pages_count[NR_LRU_LISTS];
 
@@ -378,7 +379,6 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
 	unsigned long		pages_scanned;	   /* since last reclaim */
diff --git a/mm/compaction.c b/mm/compaction.c
index 1e89165..3fbb958 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -306,7 +306,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			lruvec = NULL;
 		}
 		if (need_resched() ||
-		    (lruvec && spin_is_contended(&zone->lru_lock))) {
+		    (lruvec && spin_is_contended(&lruvec->lru_lock))) {
 			if (lruvec)
 				unlock_lruvec_irq(lruvec);
 			lruvec = NULL;
diff --git a/mm/internal.h b/mm/internal.h
index a1a3206..110d653 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -15,76 +15,98 @@
 
 static inline void lock_lruvec(struct lruvec *lruvec, unsigned long *flags)
 {
-	spin_lock_irqsave(&lruvec_zone(lruvec)->lru_lock, *flags);
+	spin_lock_irqsave(&lruvec->lru_lock, *flags);
 }
 
 static inline void lock_lruvec_irq(struct lruvec *lruvec)
 {
-	spin_lock_irq(&lruvec_zone(lruvec)->lru_lock);
+	spin_lock_irq(&lruvec->lru_lock);
 }
 
 static inline void unlock_lruvec(struct lruvec *lruvec, unsigned long *flags)
 {
-	spin_unlock_irqrestore(&lruvec_zone(lruvec)->lru_lock, *flags);
+	spin_unlock_irqrestore(&lruvec->lru_lock, *flags);
 }
 
 static inline void unlock_lruvec_irq(struct lruvec *lruvec)
 {
-	spin_unlock_irq(&lruvec_zone(lruvec)->lru_lock);
+	spin_unlock_irq(&lruvec->lru_lock);
 }
 
 static inline void wait_lruvec_unlock(struct lruvec *lruvec)
 {
-	spin_unlock_wait(&lruvec_zone(lruvec)->lru_lock);
+	spin_unlock_wait(&lruvec->lru_lock);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 /* Dynamic page to lruvec mapping */
 
+/* protected with rcu, interrupts disabled, locked_lruvec != NULL */
+static inline struct lruvec *__catch_page_lruvec(struct lruvec *locked_lruvec,
+						 struct page *page)
+{
+	struct lruvec *lruvec;
+
+	do {
+		lruvec = page_lruvec(page);
+		if (likely(lruvec == locked_lruvec))
+			return lruvec;
+		spin_unlock(&locked_lruvec->lru_lock);
+		spin_lock(&lruvec->lru_lock);
+		locked_lruvec = lruvec;
+	} while (1);
+}
+
 static inline struct lruvec *lock_page_lruvec(struct page *page,
 					      unsigned long *flags)
 {
-	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
 
-	spin_lock_irqsave(&zone->lru_lock, *flags);
-	return page_lruvec(page);
+	rcu_read_lock();
+	lruvec = page_lruvec(page);
+	lock_lruvec(lruvec, flags);
+	lruvec = __catch_page_lruvec(lruvec, page);
+	rcu_read_unlock();
+	return lruvec;
 }
 
 static inline struct lruvec *lock_page_lruvec_irq(struct page *page)
 {
-	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
 
-	spin_lock_irq(&zone->lru_lock);
-	return page_lruvec(page);
+	rcu_read_lock();
+	lruvec = page_lruvec(page);
+	lock_lruvec_irq(lruvec);
+	lruvec = __catch_page_lruvec(lruvec, page);
+	rcu_read_unlock();
+	return lruvec;
 }
 
 static inline struct lruvec *relock_page_lruvec(struct lruvec *lruvec,
 						struct page *page,
 						unsigned long *flags)
 {
-	struct zone *zone = page_zone(page);
-
-	if (!lruvec || zone != lruvec_zone(lruvec)) {
-		if (lruvec)
-			unlock_lruvec(lruvec, flags);
-		lruvec = lock_page_lruvec(page, flags);
+	rcu_read_lock();
+	if (!lruvec) {
+		lruvec = page_lruvec(page);
+		lock_lruvec(lruvec, flags);
 	}
-
+	lruvec = __catch_page_lruvec(lruvec, page);
+	rcu_read_unlock();
 	return lruvec;
 }
 
 static inline struct lruvec *relock_page_lruvec_irq(struct lruvec *lruvec,
 						    struct page *page)
 {
-	struct zone *zone = page_zone(page);
-
-	if (!lruvec || zone != lruvec_zone(lruvec)) {
-		if (lruvec)
-			unlock_lruvec_irq(lruvec);
-		lruvec = lock_page_lruvec_irq(page);
+	rcu_read_lock();
+	if (!lruvec) {
+		lruvec = page_lruvec(page);
+		lock_lruvec_irq(lruvec);
 	}
-
+	lruvec = __catch_page_lruvec(lruvec, page);
+	rcu_read_unlock();
 	return lruvec;
 }
 
@@ -92,8 +114,10 @@ static inline struct lruvec *relock_page_lruvec_irq(struct lruvec *lruvec,
 static inline struct lruvec *__relock_page_lruvec(struct lruvec *lruvec,
 						  struct page *page)
 {
-	/* Currenyly only one lruvec per-zone */
-	return page_lruvec(page);
+	rcu_read_lock();
+	lruvec = __catch_page_lruvec(lruvec, page);
+	rcu_read_unlock();
+	return lruvec;
 }
 
 /*
@@ -104,22 +128,24 @@ static inline struct lruvec *__relock_page_lruvec(struct lruvec *lruvec,
  */
 static inline bool catch_page_lruvec(struct lruvec **lruvec, struct page *page)
 {
-	struct zone *zone;
 	bool ret = false;
 
+	rcu_read_lock();
+	/*
+	 * If we see there PageLRU(), it means page has valid lruvec link.
+	 * We need protect whole operation with single rcu-interval, otherwise
+	 * lruvec which hold this LRU sign can run out before we secure it.
+	 */
 	if (PageLRU(page)) {
 		if (!*lruvec) {
-			zone = page_zone(page);
-			spin_lock_irq(&zone->lru_lock);
-		} else
-			zone = lruvec_zone(*lruvec);
-
-		if (PageLRU(page)) {
 			*lruvec = page_lruvec(page);
+			lock_lruvec_irq(*lruvec);
+		}
+		*lruvec = __catch_page_lruvec(*lruvec, page);
+		if (PageLRU(page))
 			ret = true;
-		} else
-			*lruvec = &zone->lruvec;
 	}
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -127,7 +153,7 @@ static inline bool catch_page_lruvec(struct lruvec **lruvec, struct page *page)
 /* Wait for lruvec unlock before locking other lruvec for the same page */
 static inline void __wait_lruvec_unlock(struct lruvec *lruvec)
 {
-	/* Currently only one lruvec per-zone */
+	wait_lruvec_unlock(lruvec);
 }
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index eb024c1..d0ca9d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4648,6 +4648,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 			INIT_LIST_HEAD(&mz->lruvec.pages_lru[lru]);
 			mz->lruvec.pages_count[lru] = 0;
 		}
+		spin_lock_init(&mz->lruvec.lru_lock);
 		mz->lruvec.node = NODE_DATA(node);
 		mz->lruvec.zone = &NODE_DATA(node)->node_zones[zone];
 		mz->usage_in_excess = 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 72263e4..c258024 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4357,7 +4357,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
+		spin_lock_init(&zone->lruvec.lru_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
diff --git a/mm/swap.c b/mm/swap.c
index 9e81df3..43866d7 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -694,7 +694,7 @@ void lru_add_page_tail(struct lruvec *lruvec,
 	VM_BUG_ON(!PageHead(page));
 	VM_BUG_ON(PageCompound(page_tail));
 	VM_BUG_ON(PageLRU(page_tail));
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&lruvec_zone(lruvec)->lru_lock));
+	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&lruvec->lru_lock));
 
 	SetPageLRU(page_tail);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
