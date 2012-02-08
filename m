Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 8A4D56B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 08:56:07 -0500 (EST)
Received: by wera13 with SMTP id a13so504388wer.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 05:56:05 -0800 (PST)
From: Sagi Grimberg <sagig@mellanox.com>
Subject: [PATCH V3] mm: convert rcu_read_lock() to srcu_read_lock(), thus allowing to sleep in callbacks
Date: Wed,  8 Feb 2012 15:55:43 +0200
Message-Id: <1328709344-6058-1-git-send-email-sagig@mellanox.co.il>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: aarcange@redhat.com, ogrelitz@mellanox.com

Now that anon_vma lock and i_mmap_mutex are both sleepable mutex, it is possible to schedule inside invalidation callbacks
(such as invalidate_page, invalidate_range_start/end and change_pte) .
This is essential for a scheduling HW sync in RDMA drivers which apply on demand paging methods.

Signed-off-by: Sagi Grimberg <sagig@mellanox.co.il>
---
 changes from V2:
 - fixed error path srcu cleanup

 include/linux/mmu_notifier.h |    3 +++
 mm/mmu_notifier.c            |   37 ++++++++++++++++++++++++-------------
 2 files changed, 27 insertions(+), 13 deletions(-)

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
index 9a611d3..42c7a6c 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -67,7 +67,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	/*
-	 * synchronize_rcu here prevents mmu_notifier_release to
+	 * synchronize_srcu here prevents mmu_notifier_release to
 	 * return to exit_mmap (which would proceed freeing all pages
 	 * in the mm) until the ->release method returns, if it was
 	 * invoked by mmu_notifier_unregister.
@@ -75,7 +75,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	 * The mmu_notifier_mm can't go away from under us because one
 	 * mm_count is hold by exit_mmap.
 	 */
-	synchronize_rcu();
+	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
 }
 
 /*
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
@@ -196,6 +200,9 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	if (unlikely(!mmu_notifier_mm))
 		goto out;
 
+	if (init_srcu_struct(&mmu_notifier_mm->srcu))
+		goto out_cleanup;
+
 	if (take_mmap_sem)
 		down_write(&mm->mmap_sem);
 	ret = mm_take_all_locks(mm);
@@ -226,8 +233,11 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 out_cleanup:
 	if (take_mmap_sem)
 		up_write(&mm->mmap_sem);
-	/* kfree() does nothing if mmu_notifier_mm is NULL */
-	kfree(mmu_notifier_mm);
+
+	if (mm->mmu_notifier_mm) {
+		cleanup_srcu_struct(&mmu_notifier_mm->srcu);
+		kfree(mmu_notifier_mm);
+	}
 out:
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 	return ret;
@@ -266,6 +276,7 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_register);
 void __mmu_notifier_mm_destroy(struct mm_struct *mm)
 {
 	BUG_ON(!hlist_empty(&mm->mmu_notifier_mm->list));
+	cleanup_srcu_struct(&mm->mmu_notifier_mm->srcu);
 	kfree(mm->mmu_notifier_mm);
 	mm->mmu_notifier_mm = LIST_POISON1; /* debug */
 }
@@ -309,7 +320,7 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 	 * Wait any running method to finish, of course including
 	 * ->release if it was run by mmu_notifier_relase instead of us.
 	 */
-	synchronize_rcu();
+	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
 
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
-- 
1.7.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
