Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 0D5106B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 14:01:48 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mm: mmu_notifier: have mmu_notifiers use a global SRCU so they may safely schedule
Date: Thu, 23 Aug 2012 20:01:15 +0200
Message-Id: <1345744875-26224-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345744875-26224-1-git-send-email-aarcange@redhat.com>
References: <1345744875-26224-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Sagi Grimberg <sagig@mellanox.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Haggai Eran <haggaie@mellanox.com>

From: Sagi Grimberg <sagig@mellanox.co.il>

With an RCU based mmu_notifier implementation, any callout to
mmu_notifier_invalidate_range_start,
mmu_notifier_invalidate_range_end, or mmu_notifier_invalidate_page
would not be allowed to call schedule as that could potentially allow
a modification to the mmu_notifier structure while it is currently
being used.

Since srcu allocs 4 machine words per instance per cpu, we may endup
with memory exhaustion if we use srcu per mm. so all mms will share a
global srcu.  Note that during large mmu_notifier activity exit &
unregister paths might hang for longer periods, but it is tolerable
for current mmu_notifier clients.

Signed-off-by: Sagi Grimberg <sagig@mellanox.co.il>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mmu_notifier.h |    1 +
 mm/mmu_notifier.c            |   73 +++++++++++++++++++++++++++--------------
 2 files changed, 49 insertions(+), 25 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 6f32b2b..4b7183e 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/mm_types.h>
+#include <linux/srcu.h>
 
 struct mmu_notifier;
 struct mmu_notifier_ops;
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 862b608..35ff447 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -14,10 +14,14 @@
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/err.h>
+#include <linux/srcu.h>
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 
+/* global SRCU for all MMs */
+struct srcu_struct srcu;
+
 /*
  * This function can't run concurrently against mmu_notifier_register
  * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
@@ -25,8 +29,8 @@
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
@@ -34,12 +38,13 @@ void __mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int id;
 
 	/*
 	 * RCU here will block mmu_notifier_unregister until
 	 * ->release returns.
 	 */
-	rcu_read_lock();
+	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist)
 		/*
 		 * if ->release runs before mmu_notifier_unregister it
@@ -50,7 +55,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-	rcu_read_unlock();
+	srcu_read_unlock(&srcu, id);
 
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
@@ -68,7 +73,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	/*
-	 * synchronize_rcu here prevents mmu_notifier_release to
+	 * synchronize_srcu here prevents mmu_notifier_release to
 	 * return to exit_mmap (which would proceed freeing all pages
 	 * in the mm) until the ->release method returns, if it was
 	 * invoked by mmu_notifier_unregister.
@@ -76,7 +81,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	 * The mmu_notifier_mm can't go away from under us because one
 	 * mm_count is hold by exit_mmap.
 	 */
-	synchronize_rcu();
+	synchronize_srcu(&srcu);
 }
 
 /*
@@ -89,14 +94,14 @@ int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int young = 0;
+	int young = 0, id;
 
-	rcu_read_lock();
+	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->clear_flush_young)
 			young |= mn->ops->clear_flush_young(mn, mm, address);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&srcu, id);
 
 	return young;
 }
@@ -106,9 +111,9 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int young = 0;
+	int young = 0, id;
 
-	rcu_read_lock();
+	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->test_young) {
 			young = mn->ops->test_young(mn, mm, address);
@@ -116,7 +121,7 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 				break;
 		}
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&srcu, id);
 
 	return young;
 }
@@ -126,8 +131,9 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int id;
 
-	rcu_read_lock();
+	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->change_pte)
 			mn->ops->change_pte(mn, mm, address, pte);
@@ -138,7 +144,7 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 		else if (mn->ops->invalidate_page)
 			mn->ops->invalidate_page(mn, mm, address);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
@@ -146,13 +152,14 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int id;
 
-	rcu_read_lock();
+	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
 			mn->ops->invalidate_page(mn, mm, address);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
@@ -160,13 +167,14 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int id;
 
-	rcu_read_lock();
+	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
 			mn->ops->invalidate_range_start(mn, mm, start, end);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
@@ -174,13 +182,14 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	int id;
 
-	rcu_read_lock();
+	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
 			mn->ops->invalidate_range_end(mn, mm, start, end);
 	}
-	rcu_read_unlock();
+	srcu_read_unlock(&srcu, id);
 }
 
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
@@ -192,6 +201,12 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
+	/*
+	* Verify that mmu_notifier_init() already run and the global srcu is
+	* initialized.
+	*/
+	BUG_ON(!srcu.per_cpu_ref);
+
 	ret = -ENOMEM;
 	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
 	if (unlikely(!mmu_notifier_mm))
@@ -274,8 +289,8 @@ void __mmu_notifier_mm_destroy(struct mm_struct *mm)
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
@@ -290,8 +305,9 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 		 * RCU here will force exit_mmap to wait ->release to finish
 		 * before freeing the pages.
 		 */
-		rcu_read_lock();
+		int id;
 
+		id = srcu_read_lock(&srcu);
 		/*
 		 * exit_mmap will block in mmu_notifier_release to
 		 * guarantee ->release is called before freeing the
@@ -299,7 +315,7 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-		rcu_read_unlock();
+		srcu_read_unlock(&srcu, id);
 
 		spin_lock(&mm->mmu_notifier_mm->lock);
 		hlist_del_rcu(&mn->hlist);
@@ -310,10 +326,17 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 	 * Wait any running method to finish, of course including
 	 * ->release if it was run by mmu_notifier_relase instead of us.
 	 */
-	synchronize_rcu();
+	synchronize_srcu(&srcu);
 
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
 	mmdrop(mm);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
+
+static int __init mmu_notifier_init(void)
+{
+	return init_srcu_struct(&srcu);
+}
+
+module_init(mmu_notifier_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
