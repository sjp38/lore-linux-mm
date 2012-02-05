Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 55B4D6B13F0
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 11:29:22 -0500 (EST)
Received: by wera13 with SMTP id a13so5084268wer.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 08:29:19 -0800 (PST)
From: sagig@mellanox.com
Subject: [PATCH RFC V1] mm: convert rcu_read_lock() to srcu_read_lock(), thus allowing to sleep in callbacks
Date: Sun,  5 Feb 2012 18:29:12 +0200
Message-Id: <4f2eae5e.e951b40a.3aa3.5ddc@mx.google.com>
In-Reply-To: <y>
References: <y>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: ogerlitz@mellanox.com, gleb@redhat.com, oren@mellanox.com, linux-mm@kvack.org

Now that anon_vma lock and i_mmap_mutex are both sleepable mutex, it is possible to schedule inside invalidation callbacks
(such as invalidate_page, invalidate_range_start/end and change_pte) .
This is essential for a scheduling HW sync in RDMA drivers which apply on demand paging methods.

Signed-off-by: sagi grimberg <sagig@mellanox.co.il>
---
 changes from V0:
 1. srcu_struct should be shared and not allocated in each callback - removed from callbacks
 2. added srcu_struct under mmu_notifier_mm
 3. init_srcu_struct when creating mmu_notifier_mm
 4. srcu_cleanup when destroying mmu_notifier_mm

 include/linux/mmu_notifier.h |    3 +++
 mm/mmu_notifier.c            |   23 +++++++++++++++--------
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 1d1b1e1..f3d6f30 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/mm_types.h>
+#include <linux/srcu.h>
 
 struct mmu_notifier;
 struct mmu_notifier_ops;
@@ -21,6 +22,8 @@ struct mmu_notifier_mm {
 	struct hlist_head list;
 	/* to serialize the list modifications and hlist_unhashed */
 	spinlock_t lock;
+	/* to enable sleeping in callbacks */
+	struct srcu_struct srcu;
 };
 
 struct mmu_notifier_ops {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 9a611d3..3d4f007 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -123,10 +123,11 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 			       pte_t pte)
 {
+	int idx;
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 
-	rcu_read_lock();
+	idx = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->change_pte)
 			mn->ops->change_pte(mn, mm, address, pte);
@@ -137,49 +138,52 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 		else if (mn->ops->invalidate_page)
 			mn->ops->invalidate_page(mn, mm, address);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, idx);
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
+	int idx;
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 
-	rcu_read_lock();
+	idx = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
 			mn->ops->invalidate_page(mn, mm, address);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, idx);
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
+	int idx;
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 
-	rcu_read_lock();
+	idx = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
 			mn->ops->invalidate_range_start(mn, mm, start, end);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, idx);
 }
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
+	int idx;
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 
-	rcu_read_lock();
+	idx = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
 			mn->ops->invalidate_range_end(mn, mm, start, end);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, idx);
 }
 
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
@@ -204,6 +208,8 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 
 	if (!mm_has_notifiers(mm)) {
 		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
+		if (init_srcu_struct(&mmu_notifier_mm->srcu))
+			goto out_cleanup;
 		spin_lock_init(&mmu_notifier_mm->lock);
 		mm->mmu_notifier_mm = mmu_notifier_mm;
 		mmu_notifier_mm = NULL;
@@ -266,6 +272,7 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_register);
 void __mmu_notifier_mm_destroy(struct mm_struct *mm)
 {
 	BUG_ON(!hlist_empty(&mm->mmu_notifier_mm->list));
+	cleanup_srcu_struct(&mm->mmu_notifier_mm->srcu);
 	kfree(mm->mmu_notifier_mm);
 	mm->mmu_notifier_mm = LIST_POISON1; /* debug */
 }
-- 
1.7.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
