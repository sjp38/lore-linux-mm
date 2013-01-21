Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 302EE6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 06:57:34 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id go11so395181lbb.36
        for <linux-mm@kvack.org>; Mon, 21 Jan 2013 03:57:32 -0800 (PST)
Subject: [PATCH RFC] mm/mmu_notifier: get rid of srcu-based synchronization
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 21 Jan 2013 15:57:28 +0400
Message-ID: <20130121115728.23204.60931.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

This patch removes srcu-based protection from mmu-notitifier and collects all
synchronization in mmu_notifier_unregister()/mmu_notifier_release().

All mmu notifier methods are called either under mmap_sem or under one of rmap
locks: root anon vma lock or inode mmaping lock. Because they always operates in
particular vma and caller must protect it somehow. Thus we can use mmap_sem and
rmap locks for waiting for all currently running mmu-notifier methods.

This patch adds new helper function: mm_synchronize_all_locks(). This function
acquires and releases all rmap locks one by one, it much faster than sequence
mm_take_all_locks() - mm_drop_all_locks(). mm_synchronize_all_locks() needs only
mmap_sem read-lock, but caller must lock mmap_sem for write at least once to
synchronize with the rest operations which are protected with mmap_sem read-lock.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
---
 include/linux/mm.h           |    1 
 include/linux/mmu_notifier.h |    1 
 mm/mmap.c                    |   26 ++++++++++++
 mm/mmu_notifier.c            |   91 ++++++++++++++----------------------------
 4 files changed, 57 insertions(+), 62 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 66e2f7c..86cf9f3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1461,6 +1461,7 @@ extern void exit_mmap(struct mm_struct *);
 
 extern int mm_take_all_locks(struct mm_struct *mm);
 extern void mm_drop_all_locks(struct mm_struct *mm);
+extern void mm_synchronize_all_locks(struct mm_struct *mm);
 
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index bc823c4..fa55d89 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -4,7 +4,6 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/mm_types.h>
-#include <linux/srcu.h>
 
 struct mmu_notifier;
 struct mmu_notifier_ops;
diff --git a/mm/mmap.c b/mm/mmap.c
index 0fb6805..89e884e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3043,6 +3043,32 @@ void mm_drop_all_locks(struct mm_struct *mm)
 }
 
 /*
+ * This function waits for all running pte operations which are protected with
+ * rmap locks like try_to_unmap(). To wait for rest operations like page-faults
+ * which runs under mmap_sem caller must lock mmap_sem for write at least once.
+ * This function itself requires only mmap_sem locked for read.
+ */
+void mm_synchronize_all_locks(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+
+	BUG_ON(down_write_trylock(&mm->mmap_sem));
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if (vma->anon_vma) {
+			anon_vma_lock_write(vma->anon_vma);
+			anon_vma_unlock_write(vma->anon_vma);
+		}
+		if (vma->vm_file && vma->vm_file->f_mapping) {
+			struct address_space *mapping = vma->vm_file->f_mapping;
+
+			mutex_lock(&mapping->i_mmap_mutex);
+			mutex_unlock(&mapping->i_mmap_mutex);
+		}
+	}
+}
+
+/*
  * initialise the VMA slab
  */
 void __init mmap_init(void)
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 8a5ac8c..6b77a9f 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -14,37 +14,31 @@
 #include <linux/export.h>
 #include <linux/mm.h>
 #include <linux/err.h>
-#include <linux/srcu.h>
-#include <linux/rcupdate.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 
-/* global SRCU for all MMs */
-static struct srcu_struct srcu;
-
 /*
  * This function can't run concurrently against mmu_notifier_register
  * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
  * runs with mm_users == 0. Other tasks may still invoke mmu notifiers
  * in parallel despite there being no task using this mm any more,
  * through the vmas outside of the exit_mmap context, such as with
- * vmtruncate. This serializes against mmu_notifier_unregister with
- * the mmu_notifier_mm->lock in addition to SRCU and it serializes
- * against the other mmu notifiers with SRCU. struct mmu_notifier_mm
- * can't go away from under us as exit_mmap holds an mm_count pin
- * itself.
+ * unmap_mapping_range(). This serializes against mmu_notifier_unregister()
+ * and other mmu notifiers with the mm->mmap_sem and the mmu_notifier_mm->lock.
+ * struct mmu_notifier_mm can't go away from under us as exit_mmap holds
+ * an mm_count pin itself.
  */
 void __mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int id;
 
 	/*
-	 * SRCU here will block mmu_notifier_unregister until
-	 * ->release returns.
+	 * Block mmu_notifier_unregister() until ->release returns
+	 * and synchronize with concurrent page-faults.
 	 */
-	id = srcu_read_lock(&srcu);
+	down_write(&mm->mmap_sem);
+
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist)
 		/*
 		 * if ->release runs before mmu_notifier_unregister it
@@ -55,7 +49,6 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-	srcu_read_unlock(&srcu, id);
 
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
@@ -73,15 +66,19 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	/*
-	 * synchronize_srcu here prevents mmu_notifier_release to
+	 * locked mm->mmap_sem here prevents mmu_notifier_release to
 	 * return to exit_mmap (which would proceed freeing all pages
 	 * in the mm) until the ->release method returns, if it was
 	 * invoked by mmu_notifier_unregister.
 	 *
 	 * The mmu_notifier_mm can't go away from under us because one
 	 * mm_count is hold by exit_mmap.
+	 *
+	 * Explicit synchronization with mmu notifier methods isn't
+	 * required because exit_mmap() calls free_pgtables() after us,
+	 * which locks/unlocks all locks like mm_synchronize_all_locks().
 	 */
-	synchronize_srcu(&srcu);
+	up_write(&mm->mmap_sem);
 }
 
 /*
@@ -94,14 +91,12 @@ int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int young = 0, id;
+	int young = 0;
 
-	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->clear_flush_young)
 			young |= mn->ops->clear_flush_young(mn, mm, address);
 	}
-	srcu_read_unlock(&srcu, id);
 
 	return young;
 }
@@ -111,9 +106,8 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int young = 0, id;
+	int young = 0;
 
-	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->test_young) {
 			young = mn->ops->test_young(mn, mm, address);
@@ -121,7 +115,6 @@ int __mmu_notifier_test_young(struct mm_struct *mm,
 				break;
 		}
 	}
-	srcu_read_unlock(&srcu, id);
 
 	return young;
 }
@@ -131,14 +124,11 @@ void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int id;
 
-	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->change_pte)
 			mn->ops->change_pte(mn, mm, address, pte);
 	}
-	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
@@ -146,14 +136,11 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int id;
 
-	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_page)
 			mn->ops->invalidate_page(mn, mm, address);
 	}
-	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
@@ -161,14 +148,11 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int id;
 
-	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
 			mn->ops->invalidate_range_start(mn, mm, start, end);
 	}
-	srcu_read_unlock(&srcu, id);
 }
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
@@ -176,14 +160,11 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
-	int id;
 
-	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_end)
 			mn->ops->invalidate_range_end(mn, mm, start, end);
 	}
-	srcu_read_unlock(&srcu, id);
 }
 
 static int do_mmu_notifier_register(struct mmu_notifier *mn,
@@ -195,12 +176,6 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
-	/*
-	 * Verify that mmu_notifier_init() already run and the global srcu is
-	 * initialized.
-	 */
-	BUG_ON(!srcu.per_cpu_ref);
-
 	ret = -ENOMEM;
 	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
 	if (unlikely(!mmu_notifier_mm))
@@ -283,8 +258,8 @@ void __mmu_notifier_mm_destroy(struct mm_struct *mm)
 /*
  * This releases the mm_count pin automatically and frees the mm
  * structure if it was the last user of it. It serializes against
- * running mmu notifiers with SRCU and against mmu_notifier_unregister
- * with the unregister lock + SRCU. All sptes must be dropped before
+ * mmu_notifier_unregister() with mmap_sem and agaings mmu notifiers
+ * with the mmap_sem + rmap locks. All sptes must be dropped before
  * calling mmu_notifier_unregister. ->release or any other notifier
  * method may be invoked concurrently with mmu_notifier_unregister,
  * and only after mmu_notifier_unregister returned we're guaranteed
@@ -294,14 +269,12 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
-	if (!hlist_unhashed(&mn->hlist)) {
-		/*
-		 * SRCU here will force exit_mmap to wait ->release to finish
-		 * before freeing the pages.
-		 */
-		int id;
+	/*
+	 * Synchronize with concurrent mmu_notifier_release() and page-faults.
+	 */
+	down_write(&mm->mmap_sem);
 
-		id = srcu_read_lock(&srcu);
+	if (!hlist_unhashed(&mn->hlist)) {
 		/*
 		 * exit_mmap will block in mmu_notifier_release to
 		 * guarantee ->release is called before freeing the
@@ -309,28 +282,24 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-		srcu_read_unlock(&srcu, id);
 
 		spin_lock(&mm->mmu_notifier_mm->lock);
 		hlist_del_rcu(&mn->hlist);
 		spin_unlock(&mm->mmu_notifier_mm->lock);
 	}
 
+	downgrade_write(&mm->mmap_sem);
 	/*
-	 * Wait any running method to finish, of course including
-	 * ->release if it was run by mmu_notifier_relase instead of us.
+	 * Wait any running method to finish. All such operations are protected
+	 * either with mm->mmap_sem like handle_pte_fault() or with rmap locks
+	 * like try_to_unmap(). They need one of these locks to protect vma/pte
+	 * area where they operates.
 	 */
-	synchronize_srcu(&srcu);
+	mm_synchronize_all_locks(mm);
+	up_read(&mm->mmap_sem);
 
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
 	mmdrop(mm);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
-
-static int __init mmu_notifier_init(void)
-{
-	return init_srcu_struct(&srcu);
-}
-
-module_init(mmu_notifier_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
