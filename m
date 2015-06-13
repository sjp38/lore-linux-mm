Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 311356B0038
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:33 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so34969461wib.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:32 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id em11si7841403wid.106.2015.06.13.02.49.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:31 -0700 (PDT)
Received: by wiga1 with SMTP id a1so34786548wig.0
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:30 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 00/12, v2] x86/mm: Implement lockless pgd_alloc()/pgd_free()
Date: Sat, 13 Jun 2015 11:49:03 +0200
Message-Id: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

The purpose of this series is:

  Waiman Long reported 'pgd_lock' contention on high CPU count systems and proposed
  moving pgd_lock on a separate cacheline to eliminate false sharing and to reduce
  some of the lock bouncing overhead.

  I think we can do much better: this series eliminates the pgd_list and makes
  pgd_alloc()/pgd_free() lockless.

This is the -v2 submission that addresses all feedback received so far, it
fixes bugs and cleans up details. There's a v1->v2 interdiff attached
further below: most of the changes relate to locking the task before looking
at tsk->mm.

The series is also available in -tip:master for easy testing:

  git git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

It's not applied to any visible topic tree yet. (Its sha1 is bc40a788fc63
if you want to test it without pending non-x86 bits in -tip.)

Thanks,

    Ingo

====================>
Ingo Molnar (12):
  x86/mm/pat: Don't free PGD entries on memory unmap
  x86/mm/hotplug: Remove pgd_list use from the memory hotplug code
  x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()
  x86/mm/hotplug: Simplify sync_global_pgds()
  mm: Introduce arch_pgd_init_late()
  x86/mm: Enable and use the arch_pgd_init_late() method
  x86/virt/guest/xen: Remove use of pgd_list from the Xen guest code
  x86/mm: Remove pgd_list use from vmalloc_sync_all()
  x86/mm/pat/32: Remove pgd_list use from the PAT code
  x86/mm: Make pgd_alloc()/pgd_free() lockless
  x86/mm: Remove pgd_list leftovers
  x86/mm: Simplify pgd_alloc()

 arch/Kconfig                      |   9 ++++
 arch/x86/Kconfig                  |   1 +
 arch/x86/include/asm/pgtable.h    |   3 --
 arch/x86/include/asm/pgtable_64.h |   3 +-
 arch/x86/mm/fault.c               |  31 +++++++++-----
 arch/x86/mm/init_64.c             |  80 ++++++++++++-----------------------
 arch/x86/mm/pageattr.c            |  41 +++++++++---------
 arch/x86/mm/pgtable.c             | 131 ++++++++++++++++++++++++++++++----------------------------
 arch/x86/xen/mmu.c                |  51 +++++++++++++++++------
 fs/exec.c                         |   3 ++
 include/linux/mm.h                |   6 +++
 kernel/fork.c                     |  16 +++++++
 12 files changed, 209 insertions(+), 166 deletions(-)

-v1 => -v2 interdiff:
====

 arch/x86/mm/fault.c    | 17 +++++++++++------
 arch/x86/mm/init_64.c  | 23 ++++++++++++-----------
 arch/x86/mm/pageattr.c | 27 ++++++++++++++-------------
 arch/x86/mm/pgtable.c  | 22 ++++++++++++----------
 arch/x86/xen/mmu.c     | 47 +++++++++++++++++++++++++----------------------
 fs/exec.c              |  2 +-
 include/linux/mm.h     |  4 ++--
 kernel/fork.c          |  4 ++--
 8 files changed, 79 insertions(+), 67 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index bebdd97f888b..14b39c3511fd 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -237,28 +237,33 @@ void vmalloc_sync_all(void)
 
 		struct task_struct *g, *p;
 
-		rcu_read_lock();
-		spin_lock(&pgd_lock);
+		spin_lock(&pgd_lock); /* Implies rcu_read_lock(): */
 
 		for_each_process_thread(g, p) {
+			struct mm_struct *mm;
 			spinlock_t *pgt_lock;
 			pmd_t *pmd_ret;
 
-			if (!p->mm)
+			task_lock(p);
+			mm = p->mm;
+			if (!mm) {
+				task_unlock(p);
 				continue;
+			}
 
 			/* The pgt_lock is only used on Xen: */
-			pgt_lock = &p->mm->page_table_lock;
+			pgt_lock = &mm->page_table_lock;
 			spin_lock(pgt_lock);
-			pmd_ret = vmalloc_sync_one(p->mm->pgd, address);
+			pmd_ret = vmalloc_sync_one(mm->pgd, address);
 			spin_unlock(pgt_lock);
 
+			task_unlock(p);
+
 			if (!pmd_ret)
 				break;
 		}
 
 		spin_unlock(&pgd_lock);
-		rcu_read_unlock();
 	}
 }
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 730560c4873e..dcb2f45caf0e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -171,28 +171,28 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		const pgd_t *pgd_ref = pgd_offset_k(address);
 		struct task_struct *g, *p;
 
-		/*
-		 * When this function is called after memory hot remove,
-		 * pgd_none() already returns true, but only the reference
-		 * kernel PGD has been cleared, not the process PGDs.
-		 *
-		 * So clear the affected entries in every process PGD as well:
-		 */
+		/* Only sync (potentially) newly added PGD entries: */
 		if (pgd_none(*pgd_ref))
 			continue;
 
-		spin_lock(&pgd_lock);
+		spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
 
 		for_each_process_thread(g, p) {
+			struct mm_struct *mm;
 			pgd_t *pgd;
 			spinlock_t *pgt_lock;
 
-			if (!p->mm)
+			task_lock(p);
+			mm = p->mm;
+			if (!mm) {
+				task_unlock(p);
 				continue;
-			pgd = p->mm->pgd;
+			}
+
+			pgd = mm->pgd;
 
 			/* The pgt_lock is only used by Xen: */
-			pgt_lock = &p->mm->page_table_lock;
+			pgt_lock = &mm->page_table_lock;
 			spin_lock(pgt_lock);
 
 			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
@@ -202,6 +202,7 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 				set_pgd(pgd, *pgd_ref);
 
 			spin_unlock(pgt_lock);
+			task_unlock(p);
 		}
 		spin_unlock(&pgd_lock);
 	}
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 93c134fdb398..4ff6a1808f1d 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -440,29 +440,30 @@ static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte)
 	if (!SHARED_KERNEL_PMD) {
 		struct task_struct *g, *p;
 
-		rcu_read_lock();
+		/* We are holding pgd_lock, which implies rcu_read_lock(): */
 
 		for_each_process_thread(g, p) {
+			struct mm_struct *mm;
 			spinlock_t *pgt_lock;
 			pgd_t *pgd;
 			pud_t *pud;
 			pmd_t *pmd;
 
-			if (!p->mm)
-				continue;
+			task_lock(p);
+			mm = p->mm;
+			if (mm) {
+				pgt_lock = &mm->page_table_lock;
+				spin_lock(pgt_lock);
 
-			pgt_lock = &p->mm->page_table_lock;
-			spin_lock(pgt_lock);
+				pgd = mm->pgd + pgd_index(address);
+				pud = pud_offset(pgd, address);
+				pmd = pmd_offset(pud, address);
+				set_pte_atomic((pte_t *)pmd, pte);
 
-			pgd = p->mm->pgd + pgd_index(address);
-			pud = pud_offset(pgd, address);
-			pmd = pmd_offset(pud, address);
-			set_pte_atomic((pte_t *)pmd, pte);
-
-			spin_unlock(pgt_lock);
+				spin_unlock(pgt_lock);
+			}
+			task_unlock(p);
 		}
-
-		rcu_read_unlock();
 	}
 #endif
 }
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index b1bd35f452ef..d7d341e57e33 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -348,15 +348,17 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
  * at the highest, PGD level. Thus any other task extending it
  * will first update the reference PGD, then modify the task PGDs.
  */
-void arch_pgd_init_late(struct mm_struct *mm, pgd_t *pgd)
+void arch_pgd_init_late(struct mm_struct *mm)
 {
 	/*
-	 * This is called after a new MM has been made visible
-	 * in fork() or exec().
+	 * This function is called after a new MM has been made visible
+	 * in fork() or exec() via:
+	 *
+	 *   tsk->mm = mm;
 	 *
 	 * This barrier makes sure the MM is visible to new RCU
-	 * walkers before we initialize it, so that we don't miss
-	 * updates:
+	 * walkers before we initialize the pagetables below, so that
+	 * we don't miss updates:
 	 */
 	smp_wmb();
 
@@ -365,12 +367,12 @@ void arch_pgd_init_late(struct mm_struct *mm, pgd_t *pgd)
 	 * ptes in non-PAE, or shared PMD in PAE), then just copy the
 	 * references from swapper_pg_dir:
 	 */
-	if (CONFIG_PGTABLE_LEVELS == 2 ||
+	if ( CONFIG_PGTABLE_LEVELS == 2 ||
 	    (CONFIG_PGTABLE_LEVELS == 3 && SHARED_KERNEL_PMD) ||
-	    CONFIG_PGTABLE_LEVELS == 4) {
+	     CONFIG_PGTABLE_LEVELS == 4) {
 
 		pgd_t *pgd_src = swapper_pg_dir + KERNEL_PGD_BOUNDARY;
-		pgd_t *pgd_dst =            pgd + KERNEL_PGD_BOUNDARY;
+		pgd_t *pgd_dst =        mm->pgd + KERNEL_PGD_BOUNDARY;
 		int i;
 
 		for (i = 0; i < KERNEL_PGD_PTRS; i++, pgd_src++, pgd_dst++) {
@@ -387,8 +389,8 @@ void arch_pgd_init_late(struct mm_struct *mm, pgd_t *pgd)
 			 * it won't change from under us. Parallel updates (new
 			 * allocations) will modify our (already visible) PGD:
 			 */
-			if (pgd_val(*pgd_src))
-				WRITE_ONCE(*pgd_dst, *pgd_src);
+			if (!pgd_none(*pgd_src))
+				set_pgd(pgd_dst, *pgd_src);
 		}
 	}
 }
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 87a8354435f8..70a3df5b0b54 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -855,27 +855,28 @@ void xen_mm_pin_all(void)
 {
 	struct task_struct *g, *p;
 
-	rcu_read_lock();
-	spin_lock(&pgd_lock);
+	spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
 
 	for_each_process_thread(g, p) {
+		struct mm_struct *mm;
 		struct page *page;
 		pgd_t *pgd;
 
-		if (!p->mm)
-			continue;
-
-		pgd = p->mm->pgd;
-		page = virt_to_page(pgd);
+		task_lock(p);
+		mm = p->mm;
+		if (mm) {
+			pgd = mm->pgd;
+			page = virt_to_page(pgd);
 
-		if (!PagePinned(page)) {
-			__xen_pgd_pin(&init_mm, pgd);
-			SetPageSavePinned(page);
+			if (!PagePinned(page)) {
+				__xen_pgd_pin(&init_mm, pgd);
+				SetPageSavePinned(page);
+			}
 		}
+		task_unlock(p);
 	}
 
 	spin_unlock(&pgd_lock);
-	rcu_read_unlock();
 }
 
 /*
@@ -980,24 +981,26 @@ void xen_mm_unpin_all(void)
 {
 	struct task_struct *g, *p;
 
-	rcu_read_lock();
-	spin_lock(&pgd_lock);
+	spin_lock(&pgd_lock); /* Implies rcu_read_lock() for the task list iteration: */
 
 	for_each_process_thread(g, p) {
+		struct mm_struct *mm;
 		struct page *page;
 		pgd_t *pgd;
 
-		if (!p->mm)
-			continue;
-
-		pgd = p->mm->pgd;
-		page = virt_to_page(pgd);
+		task_lock(p);
+		mm = p->mm;
+		if (mm) {
+			pgd = mm->pgd;
+			page = virt_to_page(pgd);
 
-		if (PageSavePinned(page)) {
-			BUG_ON(!PagePinned(page));
-			__xen_pgd_unpin(&init_mm, pgd);
-			ClearPageSavePinned(page);
+			if (PageSavePinned(page)) {
+				BUG_ON(!PagePinned(page));
+				__xen_pgd_unpin(&init_mm, pgd);
+				ClearPageSavePinned(page);
+			}
 		}
+		task_unlock(p);
 	}
 
 	spin_unlock(&pgd_lock);
diff --git a/fs/exec.c b/fs/exec.c
index c1d213c64fda..4ce1383d5bba 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -862,7 +862,7 @@ static int exec_mmap(struct mm_struct *mm)
 	active_mm = tsk->active_mm;
 
 	tsk->mm = mm;
-	arch_pgd_init_late(mm, mm->pgd);
+	arch_pgd_init_late(mm);
 
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 35d887d2b038..a3edc839e431 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1135,9 +1135,9 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 			void *buf, int len, int write);
 
 #ifdef CONFIG_ARCH_HAS_PGD_INIT_LATE
-void arch_pgd_init_late(struct mm_struct *mm, pgd_t *pgd);
+void arch_pgd_init_late(struct mm_struct *mm);
 #else
-static inline void arch_pgd_init_late(struct mm_struct *mm, pgd_t *pgd) { }
+static inline void arch_pgd_init_late(struct mm_struct *mm) { }
 #endif
 
 static inline void unmap_shared_mapping_range(struct address_space *mapping,
diff --git a/kernel/fork.c b/kernel/fork.c
index 1f83ceca6c6c..cfa84971fb52 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1605,8 +1605,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	 * NOTE: any user-space parts of the PGD are already initialized
 	 *       and must not be clobbered.
 	 */
-	if (p->mm != current->mm)
-		arch_pgd_init_late(p->mm, p->mm->pgd);
+	if (!(clone_flags & CLONE_VM))
+		arch_pgd_init_late(p->mm);
 
 	proc_fork_connector(p);
 	cgroup_post_fork(p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
