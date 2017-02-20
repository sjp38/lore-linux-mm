Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 399126B0390
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 05:49:41 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d185so164005724pgc.2
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 02:49:41 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h69si18191268pgc.108.2017.02.20.02.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 02:49:40 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 5/5] mm: convert mm_struct.mm_count from atomic_t to refcount_t
Date: Mon, 20 Feb 2017 12:49:14 +0200
Message-Id: <1487587754-10610-6-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
References: <1487587754-10610-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>, Hans Liljestrand <ishkamiel@gmail.com>, Kees Cook <keescook@chromium.org>, David Windsor <dwindsor@gmail.com>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 arch/x86/kernel/tboot.c                  | 2 +-
 drivers/firmware/efi/arm-runtime.c       | 2 +-
 drivers/gpu/drm/amd/amdkfd/kfd_process.c | 2 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c  | 1 -
 fs/proc/base.c                           | 8 --------
 fs/userfaultfd.c                         | 3 +--
 include/linux/mm_types.h                 | 2 +-
 include/linux/sched.h                    | 6 +++---
 kernel/fork.c                            | 2 +-
 mm/debug.c                               | 2 +-
 mm/init-mm.c                             | 2 +-
 mm/mmu_notifier.c                        | 6 +++---
 12 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index 39aaca5..fdbae72 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -103,7 +103,7 @@ static struct mm_struct tboot_mm = {
 	.mm_rb          = RB_ROOT,
 	.pgd            = swapper_pg_dir,
 	.mm_users       = REFCOUNT_INIT(2),
-	.mm_count       = ATOMIC_INIT(1),
+	.mm_count       = REFCOUNT_INIT(1),
 	.mmap_sem       = __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist         = LIST_HEAD_INIT(init_mm.mmlist),
diff --git a/drivers/firmware/efi/arm-runtime.c b/drivers/firmware/efi/arm-runtime.c
index 23e41f9..f0571f2 100644
--- a/drivers/firmware/efi/arm-runtime.c
+++ b/drivers/firmware/efi/arm-runtime.c
@@ -33,7 +33,7 @@ extern u64 efi_system_table;
 static struct mm_struct efi_mm = {
 	.mm_rb			= RB_ROOT,
 	.mm_users		= REFCOUNT_INIT(2),
-	.mm_count		= ATOMIC_INIT(1),
+	.mm_count		= REFCOUNT_INIT(1),
 	.mmap_sem		= __RWSEM_INITIALIZER(efi_mm.mmap_sem),
 	.page_table_lock	= __SPIN_LOCK_UNLOCKED(efi_mm.page_table_lock),
 	.mmlist			= LIST_HEAD_INIT(efi_mm.mmlist),
diff --git a/drivers/gpu/drm/amd/amdkfd/kfd_process.c b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
index ca5f2aa..d86ceec 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -204,7 +204,7 @@ static void kfd_process_destroy_delayed(struct rcu_head *rcu)
 	BUG_ON(!kfd_process_wq);
 
 	p = container_of(rcu, struct kfd_process, rcu);
-	BUG_ON(atomic_read(&p->mm->mm_count) <= 0);
+	BUG_ON(refcount_read(&p->mm->mm_count) == 0);
 
 	mmdrop(p->mm);
 
diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 0115989..68fb396 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -335,7 +335,6 @@ i915_gem_userptr_init__mm_struct(struct drm_i915_gem_object *obj)
 
 		mm->mm = current->mm;
 		mmgrab(current->mm);
-
 		mm->mn = NULL;
 
 		/* Protected by dev_priv->mm_lock */
diff --git a/fs/proc/base.c b/fs/proc/base.c
index a75dca3..445b259 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -921,11 +921,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 		return -ENOMEM;
 
 	ret = 0;
-<<<<<<< e5c2d109eae88b7c203d396dfaeb284f95f6ffe5
 	if (!mmget_not_zero(mm))
-=======
-	if (!refcount_inc_not_zero(&mm->mm_users))
->>>>>>> mm: convert mm_struct.mm_users from atomic_t to refcount_t
 		goto free;
 
 	down_read(&mm->mmap_sem);
@@ -1068,11 +1064,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		if (p) {
 			if (refcount_read(&p->mm->mm_users) > 1) {
 				mm = p->mm;
-<<<<<<< e5c2d109eae88b7c203d396dfaeb284f95f6ffe5
 				mmgrab(mm);
-=======
-				refcount_inc(&mm->mm_count);
->>>>>>> mm: convert mm_struct.mm_users from atomic_t to refcount_t
 			}
 			task_unlock(p);
 		}
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 3c421d0..1fd19ac 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -613,7 +613,7 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 		ctx->features = octx->features;
 		ctx->released = false;
 		ctx->mm = vma->vm_mm;
-		atomic_inc(&ctx->mm->mm_count);
+		mmgrab(ctx->mm);
 
 		userfaultfd_ctx_get(octx);
 		fctx->orig = octx;
@@ -1848,7 +1848,6 @@ static struct file *userfaultfd_file_create(int flags)
 	ctx->mm = current->mm;
 	/* prevent the mm struct to be freed */
 	mmgrab(ctx->mm);
-
 	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
 				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
 	if (IS_ERR(file)) {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index af260d6..6445c58 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -427,7 +427,7 @@ struct mm_struct {
 	 * Use mmgrab()/mmdrop() to modify. When this drops to 0, the
 	 * &struct mm_struct is freed.
 	 */
-	atomic_t mm_count;
+	refcount_t mm_count;
 
 	atomic_long_t nr_ptes;			/* PTE page table pages */
 #if CONFIG_PGTABLE_LEVELS > 2
diff --git a/include/linux/sched.h b/include/linux/sched.h
index c21682c..41a2e52 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2924,14 +2924,14 @@ extern struct mm_struct * mm_alloc(void);
  */
 static inline void mmgrab(struct mm_struct *mm)
 {
-	atomic_inc(&mm->mm_count);
+	refcount_inc(&mm->mm_count);
 }
 
 /* mmdrop drops the mm and the page tables */
 extern void __mmdrop(struct mm_struct *);
 static inline void mmdrop(struct mm_struct *mm)
 {
-	if (unlikely(atomic_dec_and_test(&mm->mm_count)))
+	if (unlikely(refcount_dec_and_test(&mm->mm_count)))
 		__mmdrop(mm);
 }
 
@@ -2943,7 +2943,7 @@ static inline void mmdrop_async_fn(struct work_struct *work)
 
 static inline void mmdrop_async(struct mm_struct *mm)
 {
-	if (unlikely(atomic_dec_and_test(&mm->mm_count))) {
+	if (unlikely(refcount_dec_and_test(&mm->mm_count))) {
 		INIT_WORK(&mm->async_put_work, mmdrop_async_fn);
 		schedule_work(&mm->async_put_work);
 	}
diff --git a/kernel/fork.c b/kernel/fork.c
index 60ff801..31c887c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -760,7 +760,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm->mm_rb = RB_ROOT;
 	mm->vmacache_seqnum = 0;
 	refcount_set(&mm->mm_users, 1);
-	atomic_set(&mm->mm_count, 1);
+	refcount_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
diff --git a/mm/debug.c b/mm/debug.c
index 0866505..eebbd15 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -135,7 +135,7 @@ void dump_mm(const struct mm_struct *mm)
 #endif
 		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end,
 		mm->pgd, refcount_read(&mm->mm_users),
-		atomic_read(&mm->mm_count),
+		refcount_read(&mm->mm_count),
 		atomic_long_read((atomic_long_t *)&mm->nr_ptes),
 		mm_nr_pmds((struct mm_struct *)mm),
 		mm->map_count,
diff --git a/mm/init-mm.c b/mm/init-mm.c
index 6927a72..8de5267 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -18,7 +18,7 @@ struct mm_struct init_mm = {
 	.mm_rb		= RB_ROOT,
 	.pgd		= swapper_pg_dir,
 	.mm_users	= REFCOUNT_INIT(2),
-	.mm_count	= ATOMIC_INIT(1),
+	.mm_count	= REFCOUNT_INIT(1),
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index d8c11e1..d179083 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -348,7 +348,7 @@ void __mmu_notifier_mm_destroy(struct mm_struct *mm)
  */
 void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+	BUG_ON(refcount_read(&mm->mm_count) <= 0);
 
 	if (!hlist_unhashed(&mn->hlist)) {
 		/*
@@ -381,7 +381,7 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 	 */
 	synchronize_srcu(&srcu);
 
-	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+	BUG_ON(refcount_read(&mm->mm_count) <= 0);
 
 	mmdrop(mm);
 }
@@ -401,7 +401,7 @@ void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
 	hlist_del_init_rcu(&mn->hlist);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
-	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+	BUG_ON(refcount_read(&mm->mm_count) <= 0);
 	mmdrop(mm);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
