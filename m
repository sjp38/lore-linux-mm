Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4E7326004A5
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 14:56:36 -0500 (EST)
Message-Id: <20100128195633.998332000@alcatraz.americas.sgi.com>
Date: Thu, 28 Jan 2010 13:56:28 -0600
From: Robin Holt <holt@sgi.com>
Subject: [RFP 1/3] srcu
References: <20100128195627.373584000@alcatraz.americas.sgi.com>
Content-Disposition: inline; filename=mmu_notifier_srcu_v1
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <andrea@qumranet.com>

This converts rcu into a per-mm srcu to allow all mmu notifier methods to
schedule.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Cc: Jack Steiner <steiner@sgi.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org
---

 include/linux/mmu_notifier.h |    3 ++
 include/linux/srcu.h         |    2 +
 mm/mmu_notifier.c            |   59 ++++++++++++++++++++++++++-----------------
 3 files changed, 42 insertions(+), 22 deletions(-)
Index: mmu_notifiers_sleepable_v1/include/linux/mmu_notifier.h
===================================================================
--- mmu_notifiers_sleepable_v1.orig/include/linux/mmu_notifier.h	2010-01-28 10:36:39.000000000 -0600
+++ mmu_notifiers_sleepable_v1/include/linux/mmu_notifier.h	2010-01-28 10:39:10.000000000 -0600
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
Index: mmu_notifiers_sleepable_v1/include/linux/srcu.h
===================================================================
--- mmu_notifiers_sleepable_v1.orig/include/linux/srcu.h	2010-01-28 10:36:39.000000000 -0600
+++ mmu_notifiers_sleepable_v1/include/linux/srcu.h	2010-01-28 10:39:10.000000000 -0600
@@ -27,6 +27,8 @@
 #ifndef _LINUX_SRCU_H
 #define _LINUX_SRCU_H
 
+#include <linux/mutex.h>
+
 struct srcu_struct_array {
 	int c[2];
 };
Index: mmu_notifiers_sleepable_v1/mm/mmu_notifier.c
===================================================================
--- mmu_notifiers_sleepable_v1.orig/mm/mmu_notifier.c	2010-01-28 10:36:40.000000000 -0600
+++ mmu_notifiers_sleepable_v1/mm/mmu_notifier.c	2010-01-28 10:39:10.000000000 -0600
@@ -14,6 +14,7 @@
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/err.h>
+#include <linux/srcu.h>
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
 
@@ -24,14 +25,15 @@
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
@@ -46,10 +48,10 @@ void __mmu_notifier_release(struct mm_st
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
@@ -60,13 +62,13 @@ void __mmu_notifier_release(struct mm_st
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
@@ -74,7 +76,7 @@ void __mmu_notifier_release(struct mm_st
 	 * The mmu_notifier_mm can't go away from under us because one
 	 * mm_count is hold by exit_mmap.
 	 */
-	synchronize_rcu();
+	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
 }
 
 /*
@@ -87,14 +89,14 @@ int __mmu_notifier_clear_flush_young(str
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
@@ -124,13 +126,14 @@ void __mmu_notifier_invalidate_page(stru
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
@@ -138,13 +141,14 @@ void __mmu_notifier_invalidate_range_sta
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
@@ -152,13 +156,14 @@ void __mmu_notifier_invalidate_range_end
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
@@ -175,6 +180,10 @@ static int do_mmu_notifier_register(stru
 	if (unlikely(!mmu_notifier_mm))
 		goto out;
 
+	ret = init_srcu_struct(&mmu_notifier_mm->srcu);
+	if (unlikely(ret))
+		goto out_kfree;
+
 	if (take_mmap_sem)
 		down_write(&mm->mmap_sem);
 	ret = mm_take_all_locks(mm);
@@ -205,6 +214,9 @@ static int do_mmu_notifier_register(stru
 out_cleanup:
 	if (take_mmap_sem)
 		up_write(&mm->mmap_sem);
+	if (mmu_notifier_mm)
+		cleanup_srcu_struct(&mmu_notifier_mm->srcu);
+out_kfree:
 	/* kfree() does nothing if mmu_notifier_mm is NULL */
 	kfree(mmu_notifier_mm);
 out:
@@ -245,6 +257,7 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_registe
 void __mmu_notifier_mm_destroy(struct mm_struct *mm)
 {
 	BUG_ON(!hlist_empty(&mm->mmu_notifier_mm->list));
+	cleanup_srcu_struct(&mm->mmu_notifier_mm->srcu);
 	kfree(mm->mmu_notifier_mm);
 	mm->mmu_notifier_mm = LIST_POISON1; /* debug */
 }
@@ -252,8 +265,8 @@ void __mmu_notifier_mm_destroy(struct mm
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
@@ -265,13 +278,15 @@ void mmu_notifier_unregister(struct mmu_
 
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
@@ -280,7 +295,7 @@ void mmu_notifier_unregister(struct mmu_
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-		rcu_read_unlock();
+		srcu_read_unlock(&mm->mmu_notifier_mm->srcu, srcu);
 	} else
 		spin_unlock(&mm->mmu_notifier_mm->lock);
 
@@ -288,7 +303,7 @@ void mmu_notifier_unregister(struct mmu_
 	 * Wait any running method to finish, of course including
 	 * ->release if it was run by mmu_notifier_relase instead of us.
 	 */
-	synchronize_rcu();
+	synchronize_srcu(&mm->mmu_notifier_mm->srcu);
 
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
