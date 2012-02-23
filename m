Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 051156B0107
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 08:53:27 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so1365307bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 05:53:27 -0800 (PST)
Subject: [PATCH v3 20/21] mm: split zone->lru_lock
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 17:53:23 +0400
Message-ID: <20120223135323.12988.1605.stgit@zurg>
In-Reply-To: <20120223133728.12988.5432.stgit@zurg>
References: <20120223133728.12988.5432.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

Looks like all ready for splitting zone->lru_lock into per-lruvec pieces.

lruvec locking loop protected with rcu, actually there is irq-disabling instead
of rcu_read_lock(). Memory controller already releases its lru-vectors after
syncronize_rcu() in cgroup_diput(). Probably it should be replaced with synchronize_sched()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mmzone.h |    3 +-
 mm/compaction.c        |    2 +
 mm/internal.h          |   66 +++++++++++++++++++++++++-----------------------
 mm/page_alloc.c        |    2 +
 mm/swap.c              |    2 +
 5 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2e3a298..9880150 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -304,6 +304,8 @@ struct zone_reclaim_stat {
 };
 
 struct lruvec {
+	spinlock_t		lru_lock;
+
 	struct list_head	pages_lru[NR_LRU_LISTS];
 	unsigned long		pages_count[NR_LRU_COUNTERS];
 
@@ -386,7 +388,6 @@ struct zone {
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
-	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
 	unsigned long		pages_scanned;	   /* since last reclaim */
diff --git a/mm/compaction.c b/mm/compaction.c
index fa74cbe..8661bb58 100644
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
index 6dd2e70..9a9fd53 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -15,27 +15,27 @@
 
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
@@ -46,37 +46,39 @@ static inline void wait_lruvec_unlock(struct lruvec *lruvec)
 static inline struct lruvec *__relock_page_lruvec(struct lruvec *locked_lruvec,
 						  struct page *page)
 {
-	/* Currenyly only one lru_lock per-zone */
-	return page_lruvec(page);
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
 }
 
 static inline struct lruvec *relock_page_lruvec_irq(struct lruvec *lruvec,
 						    struct page *page)
 {
-	struct zone *zone = page_zone(page);
-
 	if (!lruvec) {
-		spin_lock_irq(&zone->lru_lock);
-	} else if (zone != lruvec_zone(lruvec)) {
-		unlock_lruvec_irq(lruvec);
-		spin_lock_irq(&zone->lru_lock);
+		local_irq_disable();
+		lruvec = page_lruvec(page);
+		spin_lock(&lruvec->lru_lock);
 	}
-	return page_lruvec(page);
+	return __relock_page_lruvec(lruvec, page);
 }
 
 static inline struct lruvec *relock_page_lruvec(struct lruvec *lruvec,
 						struct page *page,
 						unsigned long *flags)
 {
-	struct zone *zone = page_zone(page);
-
 	if (!lruvec) {
-		spin_lock_irqsave(&zone->lru_lock, *flags);
-	} else if (zone != lruvec_zone(lruvec)) {
-		unlock_lruvec(lruvec, flags);
-		spin_lock_irqsave(&zone->lru_lock, *flags);
+		local_irq_save(*flags);
+		lruvec = page_lruvec(page);
+		spin_lock(&lruvec->lru_lock);
 	}
-	return page_lruvec(page);
+	return __relock_page_lruvec(lruvec, page);
 }
 
 /*
@@ -87,22 +89,24 @@ static inline struct lruvec *relock_page_lruvec(struct lruvec *lruvec,
 static inline bool __lock_page_lruvec_irq(struct lruvec **lruvec,
 					  struct page *page)
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
+		*lruvec = __relock_page_lruvec(*lruvec, page);
+		if (PageLRU(page))
 			ret = true;
-		} else
-			*lruvec = &zone->lruvec;
 	}
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -110,7 +114,7 @@ static inline bool __lock_page_lruvec_irq(struct lruvec **lruvec,
 /* Wait for lruvec unlock before locking other lruvec for the same page */
 static inline void __wait_lruvec_unlock(struct lruvec *lruvec)
 {
-	/* Currently only one lru_lock per-zone */
+	wait_lruvec_unlock(lruvec);
 }
 
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ab42446..beadcc9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4294,6 +4294,7 @@ void init_zone_lruvec(struct zone *zone, struct lruvec *lruvec)
 	enum lru_list lru;
 
 	memset(lruvec, 0, sizeof(struct lruvec));
+	spin_lock_init(&lruvec->lru_lock);
 	for_each_lru(lru)
 		INIT_LIST_HEAD(&lruvec->pages_lru[lru]);
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
@@ -4369,7 +4370,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 #endif
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
-		spin_lock_init(&zone->lru_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
diff --git a/mm/swap.c b/mm/swap.c
index 998c71c..8156181 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -700,7 +700,7 @@ void lru_add_page_tail(struct lruvec *lruvec,
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
