Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69C248E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 10:59:34 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i11-v6so10267670wrr.10
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 07:59:34 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k191-v6si1926670wmd.18.2018.09.14.07.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 14 Sep 2018 07:59:32 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/2] mm/swap: Add pagevec locking
Date: Fri, 14 Sep 2018 16:59:23 +0200
Message-Id: <20180914145924.22055-2-bigeasy@linutronix.de>
In-Reply-To: <20180914145924.22055-1-bigeasy@linutronix.de>
References: <20180914145924.22055-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, Vlastimil Babka <vbabka@suse.cz>, frederic@kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

From: Thomas Gleixner <tglx@linutronix.de>

The locking of struct pagevec is done by disabling preemption. In case
the struct has be accessed form interrupt context then interrupts are
disabled. This means the struct can only be accessed locally from the
CPU. There is also no lockdep coverage which would scream during if it
accessed from wrong context.

Create struct swap_pagevec which contains of a pagevec member and a
spin_lock_t. Before the struct is accessed the spin_lock has to be
acquired instead of using preempt_disable(). Since the struct is used
CPU-locally there is no spinning on the lock but the lock is acquired
immediately. If the struct is accessed from interrupt context,
spin_lock_irqsave() is used.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[bigeasy: +commit message]
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 mm/compaction.c |   7 +--
 mm/swap.c       | 145 +++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 115 insertions(+), 37 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index faca45ebe62df..569823e381081 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1652,15 +1652,14 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 		 * would succeed.
 		 */
 		if (cc->order > 0 && cc->last_migrated_pfn) {
-			int cpu;
 			unsigned long current_block_start =
 				block_start_pfn(cc->migrate_pfn, cc->order);
 
 			if (cc->last_migrated_pfn < current_block_start) {
-				cpu = get_cpu();
-				lru_add_drain_cpu(cpu);
+				lru_add_drain();
+				preempt_disable();
 				drain_local_pages(zone);
-				put_cpu();
+				preempt_enable();
 				/* No more flushing until we migrate again */
 				cc->last_migrated_pfn = 0;
 			}
diff --git a/mm/swap.c b/mm/swap.c
index 26fc9b5f1b6c1..17702ee5bf81c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -44,14 +44,71 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
-static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
-static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
+struct swap_pagevec {
+	spinlock_t	lock;
+	struct pagevec	pvec;
+};
+
+#define DEFINE_PER_CPU_PAGEVEC(lvar)				\
+	DEFINE_PER_CPU(struct swap_pagevec, lvar) = {		\
+		.lock = __SPIN_LOCK_UNLOCKED((lvar).lock) }
+
+static DEFINE_PER_CPU_PAGEVEC(lru_add_pvec);
+static DEFINE_PER_CPU_PAGEVEC(lru_rotate_pvecs);
+static DEFINE_PER_CPU_PAGEVEC(lru_deactivate_file_pvecs);
+static DEFINE_PER_CPU_PAGEVEC(lru_lazyfree_pvecs);
 #ifdef CONFIG_SMP
-static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
+static DEFINE_PER_CPU_PAGEVEC(activate_page_pvecs);
 #endif
 
+static inline
+struct swap_pagevec *lock_swap_pvec(struct swap_pagevec __percpu *p)
+{
+	struct swap_pagevec *swpvec = raw_cpu_ptr(p);
+
+	spin_lock(&swpvec->lock);
+	return swpvec;
+}
+
+static inline struct swap_pagevec *
+lock_swap_pvec_cpu(struct swap_pagevec __percpu *p, int cpu)
+{
+	struct swap_pagevec *swpvec = per_cpu_ptr(p, cpu);
+
+	spin_lock(&swpvec->lock);
+	return swpvec;
+}
+
+static inline struct swap_pagevec *
+lock_swap_pvec_irqsave(struct swap_pagevec __percpu *p, unsigned long *flags)
+{
+	struct swap_pagevec *swpvec = raw_cpu_ptr(p);
+
+	spin_lock_irqsave(&swpvec->lock, (*flags));
+	return swpvec;
+}
+
+static inline struct swap_pagevec *
+lock_swap_pvec_cpu_irqsave(struct swap_pagevec __percpu *p, int cpu,
+			   unsigned long *flags)
+{
+	struct swap_pagevec *swpvec = per_cpu_ptr(p, cpu);
+
+	spin_lock_irqsave(&swpvec->lock, *flags);
+	return swpvec;
+}
+
+static inline void unlock_swap_pvec(struct swap_pagevec *swpvec)
+{
+	spin_unlock(&swpvec->lock);
+}
+
+static inline void
+unlock_swap_pvec_irqrestore(struct swap_pagevec *swpvec, unsigned long flags)
+{
+	spin_unlock_irqrestore(&swpvec->lock, flags);
+}
+
 /*
  * This path almost never happens for VM activity - pages are normally
  * freed via pagevecs.  But it gets used by networking.
@@ -249,15 +306,17 @@ void rotate_reclaimable_page(struct page *page)
 {
 	if (!PageLocked(page) && !PageDirty(page) &&
 	    !PageUnevictable(page) && PageLRU(page)) {
+		struct swap_pagevec *swpvec;
 		struct pagevec *pvec;
 		unsigned long flags;
 
 		get_page(page);
-		local_irq_save(flags);
-		pvec = this_cpu_ptr(&lru_rotate_pvecs);
+
+		swpvec = lock_swap_pvec_irqsave(&lru_rotate_pvecs, &flags);
+		pvec = &swpvec->pvec;
 		if (!pagevec_add(pvec, page) || PageCompound(page))
 			pagevec_move_tail(pvec);
-		local_irq_restore(flags);
+		unlock_swap_pvec_irqrestore(swpvec, flags);
 	}
 }
 
@@ -292,27 +351,32 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 #ifdef CONFIG_SMP
 static void activate_page_drain(int cpu)
 {
-	struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
+	struct swap_pagevec *swpvec = lock_swap_pvec(&activate_page_pvecs);
+	struct pagevec *pvec = &swpvec->pvec;
 
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, __activate_page, NULL);
+	unlock_swap_pvec(swpvec);
 }
 
 static bool need_activate_page_drain(int cpu)
 {
-	return pagevec_count(&per_cpu(activate_page_pvecs, cpu)) != 0;
+	return pagevec_count(per_cpu_ptr(&activate_page_pvecs.pvec, cpu)) != 0;
 }
 
 void activate_page(struct page *page)
 {
 	page = compound_head(page);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
-		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
+		struct swap_pagevec *swpvec;
+		struct pagevec *pvec;
 
 		get_page(page);
+		swpvec = lock_swap_pvec(&activate_page_pvecs);
+		pvec = &swpvec->pvec;
 		if (!pagevec_add(pvec, page) || PageCompound(page))
 			pagevec_lru_move_fn(pvec, __activate_page, NULL);
-		put_cpu_var(activate_page_pvecs);
+		unlock_swap_pvec(swpvec);
 	}
 }
 
@@ -339,7 +403,8 @@ void activate_page(struct page *page)
 
 static void __lru_cache_activate_page(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
+	struct swap_pagevec *swpvec = lock_swap_pvec(&lru_add_pvec);
+	struct pagevec *pvec = &swpvec->pvec;
 	int i;
 
 	/*
@@ -361,7 +426,7 @@ static void __lru_cache_activate_page(struct page *page)
 		}
 	}
 
-	put_cpu_var(lru_add_pvec);
+	unlock_swap_pvec(swpvec);
 }
 
 /*
@@ -403,12 +468,13 @@ EXPORT_SYMBOL(mark_page_accessed);
 
 static void __lru_cache_add(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
+	struct swap_pagevec *swpvec = lock_swap_pvec(&lru_add_pvec);
+	struct pagevec *pvec = &swpvec->pvec;
 
 	get_page(page);
 	if (!pagevec_add(pvec, page) || PageCompound(page))
 		__pagevec_lru_add(pvec);
-	put_cpu_var(lru_add_pvec);
+	unlock_swap_pvec(swpvec);
 }
 
 /**
@@ -576,28 +642,34 @@ static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
  */
 void lru_add_drain_cpu(int cpu)
 {
-	struct pagevec *pvec = &per_cpu(lru_add_pvec, cpu);
+	struct swap_pagevec *swpvec = lock_swap_pvec_cpu(&lru_add_pvec, cpu);
+	struct pagevec *pvec = &swpvec->pvec;
+	unsigned long flags;
 
 	if (pagevec_count(pvec))
 		__pagevec_lru_add(pvec);
+	unlock_swap_pvec(swpvec);
 
-	pvec = &per_cpu(lru_rotate_pvecs, cpu);
+	swpvec = lock_swap_pvec_cpu_irqsave(&lru_rotate_pvecs, cpu, &flags);
+	pvec = &swpvec->pvec;
 	if (pagevec_count(pvec)) {
-		unsigned long flags;
 
 		/* No harm done if a racing interrupt already did this */
-		local_irq_save(flags);
 		pagevec_move_tail(pvec);
-		local_irq_restore(flags);
 	}
+	unlock_swap_pvec_irqrestore(swpvec, flags);
 
-	pvec = &per_cpu(lru_deactivate_file_pvecs, cpu);
+	swpvec = lock_swap_pvec_cpu(&lru_deactivate_file_pvecs, cpu);
+	pvec = &swpvec->pvec;
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
+	unlock_swap_pvec(swpvec);
 
-	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
+	swpvec = lock_swap_pvec_cpu(&lru_lazyfree_pvecs, cpu);
+	pvec = &swpvec->pvec;
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
+	unlock_swap_pvec(swpvec);
 
 	activate_page_drain(cpu);
 }
@@ -612,6 +684,9 @@ void lru_add_drain_cpu(int cpu)
  */
 void deactivate_file_page(struct page *page)
 {
+	struct swap_pagevec *swpvec;
+	struct pagevec *pvec;
+
 	/*
 	 * In a workload with many unevictable page such as mprotect,
 	 * unevictable page deactivation for accelerating reclaim is pointless.
@@ -620,11 +695,12 @@ void deactivate_file_page(struct page *page)
 		return;
 
 	if (likely(get_page_unless_zero(page))) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactivate_file_pvecs);
+		swpvec = lock_swap_pvec(&lru_deactivate_file_pvecs);
+		pvec = &swpvec->pvec;
 
 		if (!pagevec_add(pvec, page) || PageCompound(page))
 			pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
-		put_cpu_var(lru_deactivate_file_pvecs);
+		unlock_swap_pvec(swpvec);
 	}
 }
 
@@ -637,21 +713,24 @@ void deactivate_file_page(struct page *page)
  */
 void mark_page_lazyfree(struct page *page)
 {
+	struct swap_pagevec *swpvec;
+	struct pagevec *pvec;
+
 	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
 	    !PageSwapCache(page) && !PageUnevictable(page)) {
-		struct pagevec *pvec = &get_cpu_var(lru_lazyfree_pvecs);
+		swpvec = lock_swap_pvec(&lru_lazyfree_pvecs);
+		pvec = &swpvec->pvec;
 
 		get_page(page);
 		if (!pagevec_add(pvec, page) || PageCompound(page))
 			pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
-		put_cpu_var(lru_lazyfree_pvecs);
+		unlock_swap_pvec(swpvec);
 	}
 }
 
 void lru_add_drain(void)
 {
-	lru_add_drain_cpu(get_cpu());
-	put_cpu();
+	lru_add_drain_cpu(raw_smp_processor_id());
 }
 
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
@@ -687,10 +766,10 @@ void lru_add_drain_all(void)
 	for_each_online_cpu(cpu) {
 		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
 
-		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
+		if (pagevec_count(&per_cpu(lru_add_pvec.pvec, cpu)) ||
+		    pagevec_count(&per_cpu(lru_rotate_pvecs.pvec, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs.pvec, cpu)) ||
+		    pagevec_count(&per_cpu(lru_lazyfree_pvecs.pvec, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			queue_work_on(cpu, mm_percpu_wq, work);
-- 
2.19.0
