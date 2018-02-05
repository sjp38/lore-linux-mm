Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28FF46B0006
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:23 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id x2so10027179plv.16
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k23-v6si6325729pli.490.2018.02.04.17.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:05 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 21/64] mm: teach drop/take_all_locks() about range locking
Date: Mon,  5 Feb 2018 02:27:11 +0100
Message-Id: <20180205012754.23615-22-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

And use the mm locking helpers. No changes in semantics.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/mm.h |  6 ++++--
 mm/mmap.c          | 12 +++++++-----
 mm/mmu_notifier.c  |  9 +++++----
 3 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fc4e7fdc3e76..0b9867e8a35d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2198,8 +2198,10 @@ static inline int check_data_rlimit(unsigned long rlim,
 	return 0;
 }
 
-extern int mm_take_all_locks(struct mm_struct *mm);
-extern void mm_drop_all_locks(struct mm_struct *mm);
+extern int mm_take_all_locks(struct mm_struct *mm,
+			     struct range_lock *mmrange);
+extern void mm_drop_all_locks(struct mm_struct *mm,
+			      struct range_lock *mmrange);
 
 extern void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file);
 extern struct file *get_mm_exe_file(struct mm_struct *mm);
diff --git a/mm/mmap.c b/mm/mmap.c
index f61d49cb791e..8f0eb88a5d5e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3461,12 +3461,13 @@ static void vm_lock_mapping(struct mm_struct *mm, struct address_space *mapping)
  *
  * mm_take_all_locks() can fail if it's interrupted by signals.
  */
-int mm_take_all_locks(struct mm_struct *mm)
+int mm_take_all_locks(struct mm_struct *mm,
+		      struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm, mmrange));
 
 	mutex_lock(&mm_all_locks_mutex);
 
@@ -3497,7 +3498,7 @@ int mm_take_all_locks(struct mm_struct *mm)
 	return 0;
 
 out_unlock:
-	mm_drop_all_locks(mm);
+	mm_drop_all_locks(mm, mmrange);
 	return -EINTR;
 }
 
@@ -3541,12 +3542,13 @@ static void vm_unlock_mapping(struct address_space *mapping)
  * The mmap_sem cannot be released by the caller until
  * mm_drop_all_locks() returns.
  */
-void mm_drop_all_locks(struct mm_struct *mm)
+void mm_drop_all_locks(struct mm_struct *mm,
+		       struct range_lock *mmrange)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
 
-	BUG_ON(down_read_trylock(&mm->mmap_sem));
+	BUG_ON(mm_read_trylock(mm, mmrange));
 	BUG_ON(!mutex_is_locked(&mm_all_locks_mutex));
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 3e8a1a10607e..da99c01b8149 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -274,6 +274,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 {
 	struct mmu_notifier_mm *mmu_notifier_mm;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
@@ -283,8 +284,8 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		goto out;
 
 	if (take_mmap_sem)
-		down_write(&mm->mmap_sem);
-	ret = mm_take_all_locks(mm);
+	        mm_write_lock(mm, &mmrange);
+	ret = mm_take_all_locks(mm, &mmrange);
 	if (unlikely(ret))
 		goto out_clean;
 
@@ -309,10 +310,10 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
-	mm_drop_all_locks(mm);
+	mm_drop_all_locks(mm, &mmrange);
 out_clean:
 	if (take_mmap_sem)
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 	kfree(mmu_notifier_mm);
 out:
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
