Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 493AD6B007E
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 08:36:59 -0400 (EDT)
From: Sagi Grimberg <sagig@mellanox.co.il>
Subject: [PATCH] mmu_notifier: have mmu_notifiers use SRCU so they may safely schedule
Date: Wed,  4 Apr 2012 15:36:26 +0300
Message-Id: <1333542986-24045-1-git-send-email-sagig@mellanox.co.il>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ogerlitz@mellanox.com, aarcange@redhat.com, Robin Holt <holt@sgi.com>

With an RCU based mmu_notifier implementation, any callout to mmu_notifier_invalidate_range_start, mmu_notifier_invalidate_range_end,
or mmu_notifier_invalidate_page would not be allowed to call schedule as that could potentially allow a modification to the mmu_notifier structure while it is currently being used.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Robin Holt <holt@sgi.com>
---
 include/linux/mmu_notifier.h |    3 ++
 mm/mmu_notifier.c            |   70 +++++++++++++++++++++++++----------------
 2 files changed, 46 insertions(+), 27 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 1d1b1e1..23c3c86 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/mm_types.h>
+#include <linux/srcu.h>
 
 struct mmu_notifier;
 struct mmu_notifier_ops;
@@ -19,6 +20,8 @@ struct mmu_notifier_ops;
 struct mmu_notifier_mm {
 	/* all mmu notifiers registerd in this mm are queued in this list */
 	struct hlist_head list;
+	/* srcu structure for this mm */
+	struct srcu_struct srcu;
 	/* to serialize the list modifications and hlist_unhashed */
 	spinlock_t lock;
 };
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 9a611d3..10703ca 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -14,6 +14,7 @@
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/err.h>
+#include <linux/srcu.h>
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -25,14 +26,15 @@
  * in parallel despite there being no task using this mm any more,
  * through the vmas outside of the exit_mmap context, such as with
  * vmtruncate. This serializes against mmu_notifier_unregister with
- * the mmu_notifier_mm->lock in addition to RCU and it serializes
- * against the other mmu notifiers with RCU. struct mmu_notifier_mm
+ * the mmu_notifier_mm->lock in addition to SRCU and it serializes
+ * against the other mmu notifiers with SRCU. struct mmu_notifier_mm
  * can't go away from under us as exit_mmap holds an mm_count pin
  * itself.
  */
 void __mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
+	int srcu;
 
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
@@ -47,10 +49,10 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 */
 		hlist_del_init_rcu(&mn->hlist);
 		/*
-		 * RCU here will block mmu_notifier_unregister until
+		 * SRCU here will block mmu_notifier_unregister until
 		 * ->release returns.
 		 */
-		rcu_read_lock();
+		srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 		spin_unlock(&mm->mmu_notifier_mm->lock);
 		/*
 		 * if ->release runs before mmu_notifier_unregister it
@@ -61,13 +63,13 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-		rcu_read_unlock();
+		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 		spin_lock(&mm->mmu_notifier_mm->lock);
 	}
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	/*
-	 * synchronize_rcu here prevents mmu_notifier_release to
+	 * synchronize_srcu here prevents mmu_notifier_release to
 	 * return to exit_mmap (which would proceed freeing all pages
 	 * in the mm) until the ->release method returns, if it was
 	 * invoked by mmu_notifier_unregister.
@@ -75,7 +77,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	 * The mmu_notifier_mm can't go away from under us because one
 	 * mm_count is hold by exit_mmap.
 	 */
-	synchronize_rcu();
+	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
 }
 
 /*
@@ -88,14 +90,14 @@ int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int young = 0;
+	int young = 0, srcu;
 
-	rcu_read_lock();
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->clear_flush_young)
 			young |= mn->ops->clear_flush_young(mn, mm, address);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 
 	return young;
 }
@@ -105,9 +107,9 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int young = 0;
+	int young = 0, srcu;
 
-	rcu_read_lock();
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->test_young) {
 			young = mn->ops->test_young(mn, mm, address);
@@ -115,7 +117,7 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 				break;
 		}
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 
 	return young;
 }
@@ -125,8 +127,9 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int srcu;
 
-	rcu_read_lock();
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->change_pte)
 			mn->ops->change_pte(mn, mm, address, pte);
@@ -137,7 +140,7 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 		else if (mn->ops->invalidate_page)
 			mn->ops->invalidate_page(mn, mm, address);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
@@ -145,13 +148,14 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int srcu;
 
-	rcu_read_lock();
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
 			mn->ops->invalidate_page(mn, mm, address);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
@@ -159,13 +163,14 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int srcu;
 
-	rcu_read_lock();
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
 			mn->ops->invalidate_range_start(mn, mm, start, end);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 }
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
@@ -173,13 +178,14 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int srcu;
 
-	rcu_read_lock();
+	srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
 			mn->ops->invalidate_range_end(mn, mm, start, end);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 }
 
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
@@ -196,6 +202,10 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	if (unlikely(!mmu_notifier_mm))
 		goto out;
 
+	ret = init_srcu_struct(&mmu_notifier_mm->srcu);
+	if (unlikely(ret))
+		goto out_kfree;
+
 	if (take_mmap_sem)
 		down_write(&mm->mmap_sem);
 	ret = mm_take_all_locks(mm);
@@ -226,6 +236,9 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 out_cleanup:
 	if (take_mmap_sem)
 		up_write(&mm->mmap_sem);
+	if (mmu_notifier_mm)
+		cleanup_srcu_struct(&mmu_notifier_mm->srcu);
+out_kfree:
 	/* kfree() does nothing if mmu_notifier_mm is NULL */
 	kfree(mmu_notifier_mm);
 out:
@@ -266,6 +279,7 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_register);
 void __mmu_notifier_mm_destroy(struct mm_struct *mm)
 {
 	BUG_ON(!hlist_empty(&mm->mmu_notifier_mm->list));
+	cleanup_srcu_struct(&mm->mmu_notifier_mm->srcu);
 	kfree(mm->mmu_notifier_mm);
 	mm->mmu_notifier_mm = LIST_POISON1; /* debug */
 }
@@ -273,8 +287,8 @@ void __mmu_notifier_mm_destroy(struct mm_struct *mm)
 /*
  * This releases the mm_count pin automatically and frees the mm
  * structure if it was the last user of it. It serializes against
- * running mmu notifiers with RCU and against mmu_notifier_unregister
- * with the unregister lock + RCU. All sptes must be dropped before
+ * running mmu notifiers with SRCU and against mmu_notifier_unregister
+ * with the unregister lock + SRCU. All sptes must be dropped before
  * calling mmu_notifier_unregister. ->release or any other notifier
  * method may be invoked concurrently with mmu_notifier_unregister,
  * and only after mmu_notifier_unregister returned we're guaranteed
@@ -286,13 +300,15 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	if (!hlist_unhashed(&mn->hlist)) {
+		int srcu;
+
 		hlist_del_rcu(&mn->hlist);
 
 		/*
-		 * RCU here will force exit_mmap to wait ->release to finish
+		 * SRCU here will force exit_mmap to wait ->release to finish
 		 * before freeing the pages.
 		 */
-		rcu_read_lock();
+		srcu = srcu_read_lock(&mm->mmu_notifier_mm->srcu);
 		spin_unlock(&mm->mmu_notifier_mm->lock);
 		/*
 		 * exit_mmap will block in mmu_notifier_release to
@@ -301,7 +317,7 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-		rcu_read_unlock();
+		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 	} else
 		spin_unlock(&mm->mmu_notifier_mm->lock);
 
@@ -309,7 +325,7 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
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
