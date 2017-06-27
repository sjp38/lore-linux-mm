Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40F956B0311
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:49:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z10so24165639pff.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:49:13 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z61si1983895plb.173.2017.06.27.04.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 04:49:12 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 5/5] mm: convert mm_struct.mm_count from atomic_t to refcount_t
Date: Tue, 27 Jun 2017 14:48:47 +0300
Message-Id: <1498564127-11097-6-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1498564127-11097-1-git-send-email-elena.reshetova@intel.com>
References: <1498564127-11097-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, keescook@chromium.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>, Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>

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
 arch/blackfin/mach-common/smp.c          | 2 +-
 arch/x86/kernel/tboot.c                  | 2 +-
 drivers/firmware/efi/arm-runtime.c       | 2 +-
 drivers/gpu/drm/amd/amdkfd/kfd_process.c | 2 +-
 fs/proc/task_nommu.c                     | 4 ++--
 fs/userfaultfd.c                         | 3 +--
 include/linux/mm_types.h                 | 2 +-
 include/linux/sched/mm.h                 | 6 +++---
 kernel/fork.c                            | 2 +-
 mm/debug.c                               | 2 +-
 mm/init-mm.c                             | 2 +-
 mm/mmu_notifier.c                        | 6 +++---
 12 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/arch/blackfin/mach-common/smp.c b/arch/blackfin/mach-common/smp.c
index ed69b4f..f288f66 100644
--- a/arch/blackfin/mach-common/smp.c
+++ b/arch/blackfin/mach-common/smp.c
@@ -424,7 +424,7 @@ void cpu_die(void)
 	(void)cpu_report_death();
 
 	refcount_dec(&init_mm.mm_users);
-	atomic_dec(&init_mm.mm_count);
+	refcount_dec(&init_mm.mm_count);
 
 	local_irq_disable();
 	platform_cpu_die();
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
index a9c41e2..24aeaef 100644
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
index 84d1ffd..ba63d26 100644
--- a/drivers/gpu/drm/amd/amdkfd/kfd_process.c
+++ b/drivers/gpu/drm/amd/amdkfd/kfd_process.c
@@ -205,7 +205,7 @@ static void kfd_process_destroy_delayed(struct rcu_head *rcu)
 	BUG_ON(!kfd_process_wq);
 
 	p = container_of(rcu, struct kfd_process, rcu);
-	BUG_ON(atomic_read(&p->mm->mm_count) <= 0);
+	BUG_ON(refcount_read(&p->mm->mm_count) == 0);
 
 	mmdrop(p->mm);
 
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index e969e79..eea6b91 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -38,7 +38,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 			size = vma->vm_end - vma->vm_start;
 		}
 
-		if (atomic_read(&mm->mm_count) > 1 ||
+		if (refcount_read(&mm->mm_count) > 1 ||
 		    vma->vm_flags & VM_MAYSHARE) {
 			sbytes += size;
 		} else {
@@ -48,7 +48,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		}
 	}
 
-	if (atomic_read(&mm->mm_count) > 1)
+	if (refcount_read(&mm->mm_count) > 1)
 		sbytes += kobjsize(mm);
 	else
 		bytes += kobjsize(mm);
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f7555fc..a5d5015 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -624,7 +624,7 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
 		ctx->features = octx->features;
 		ctx->released = false;
 		ctx->mm = vma->vm_mm;
-		atomic_inc(&ctx->mm->mm_count);
+		mmgrab(ctx->mm);
 
 		userfaultfd_ctx_get(octx);
 		fctx->orig = octx;
@@ -1826,7 +1826,6 @@ static struct file *userfaultfd_file_create(int flags)
 	ctx->mm = current->mm;
 	/* prevent the mm struct to be freed */
 	mmgrab(ctx->mm);
-
 	file = anon_inode_getfile("[userfaultfd]", &userfaultfd_fops, ctx,
 				  O_RDWR | (flags & UFFD_SHARED_FCNTL_FLAGS));
 	if (IS_ERR(file)) {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e87b5fe..a29f66d 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -390,7 +390,7 @@ struct mm_struct {
 	 * Use mmgrab()/mmdrop() to modify. When this drops to 0, the
 	 * &struct mm_struct is freed.
 	 */
-	atomic_t mm_count;
+	refcount_t mm_count;
 
 	atomic_long_t nr_ptes;			/* PTE page table pages */
 #if CONFIG_PGTABLE_LEVELS > 2
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 1a15aa9d1..5e80e9e 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -31,14 +31,14 @@ extern struct mm_struct * mm_alloc(void);
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
 
@@ -50,7 +50,7 @@ static inline void mmdrop_async_fn(struct work_struct *work)
 
 static inline void mmdrop_async(struct mm_struct *mm)
 {
-	if (unlikely(atomic_dec_and_test(&mm->mm_count))) {
+	if (unlikely(refcount_dec_and_test(&mm->mm_count))) {
 		INIT_WORK(&mm->async_put_work, mmdrop_async_fn);
 		schedule_work(&mm->async_put_work);
 	}
diff --git a/kernel/fork.c b/kernel/fork.c
index 3bbfe0e..0334742 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -770,7 +770,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
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
index b8c3dda..21fae87 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -349,7 +349,7 @@ void __mmu_notifier_mm_destroy(struct mm_struct *mm)
  */
 void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+	BUG_ON(refcount_read(&mm->mm_count) == 0);
 
 	if (!hlist_unhashed(&mn->hlist)) {
 		/*
@@ -382,7 +382,7 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 	 */
 	synchronize_srcu(&srcu);
 
-	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+	BUG_ON(refcount_read(&mm->mm_count) == 0);
 
 	mmdrop(mm);
 }
@@ -402,7 +402,7 @@ void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
 	hlist_del_init_rcu(&mn->hlist);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
-	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+	BUG_ON(refcount_read(&mm->mm_count) == 0);
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
