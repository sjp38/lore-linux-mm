Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 338E66B0070
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 14:14:34 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id i57so2402085yha.7
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:14:34 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id x47si8838475yhd.120.2015.01.13.11.14.32
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 11:14:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: rename mm->nr_ptes to mm->nr_pgtables
Date: Tue, 13 Jan 2015 21:14:15 +0200
Message-Id: <1421176456-21796-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1421176456-21796-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We're going to account pmd page tables too. Let's rename mm->nr_pgtables
to something more generic.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/sysctl/vm.txt |  2 +-
 fs/proc/task_mmu.c          |  2 +-
 include/linux/mm_types.h    |  2 +-
 kernel/fork.c               |  2 +-
 mm/debug.c                  |  4 ++--
 mm/huge_memory.c            | 10 +++++-----
 mm/memory.c                 |  4 ++--
 mm/mmap.c                   |  2 +-
 mm/oom_kill.c               |  8 ++++----
 9 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 4415aa915681..0211a58ee6c3 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -557,7 +557,7 @@ oom_dump_tasks
 
 Enables a system-wide task dump (excluding kernel threads) to be
 produced when the kernel performs an OOM-killing and includes such
-information as pid, uid, tgid, vm size, rss, nr_ptes, swapents,
+information as pid, uid, tgid, vm size, rss, nr_pgtables, swapents,
 oom_score_adj score, and name.  This is helpful to determine why the
 OOM killer was invoked, to identify the rogue task that caused it,
 and to determine why the OOM killer chose the task it did to kill.
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8faae6fed085..6121cca220cb 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -64,7 +64,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
 		(PTRS_PER_PTE * sizeof(pte_t) *
-		 atomic_long_read(&mm->nr_ptes)) >> 10,
+		 atomic_long_read(&mm->nr_pgtables)) >> 10,
 		swap << (PAGE_SHIFT-10));
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 20ff2105b564..106be259a3ea 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -363,7 +363,7 @@ struct mm_struct {
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
-	atomic_long_t nr_ptes;			/* Page table pages */
+	atomic_long_t nr_pgtables;		/* Page table pages */
 	int map_count;				/* number of VMAs */
 
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
diff --git a/kernel/fork.c b/kernel/fork.c
index b379d9abddc7..d7d00cac1f66 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -554,7 +554,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
-	atomic_long_set(&mm->nr_ptes, 0);
+	atomic_long_set(&mm->nr_pgtables, 0);
 	mm->map_count = 0;
 	mm->locked_vm = 0;
 	mm->pinned_vm = 0;
diff --git a/mm/debug.c b/mm/debug.c
index d69cb5a7ba9a..229d3cba5677 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -173,7 +173,7 @@ void dump_mm(const struct mm_struct *mm)
 		"get_unmapped_area %p\n"
 #endif
 		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
-		"pgd %p mm_users %d mm_count %d nr_ptes %lu map_count %d\n"
+		"pgd %p mm_users %d mm_count %d nr_pgtables %lu map_count %d\n"
 		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
 		"pinned_vm %lx shared_vm %lx exec_vm %lx stack_vm %lx\n"
 		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
@@ -205,7 +205,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end,
 		mm->pgd, atomic_read(&mm->mm_users),
 		atomic_read(&mm->mm_count),
-		atomic_long_read((atomic_long_t *)&mm->nr_ptes),
+		atomic_long_read((atomic_long_t *)&mm->nr_pgtables),
 		mm->map_count,
 		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
 		mm->pinned_vm, mm->shared_vm, mm->exec_vm, mm->stack_vm,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b29c48708b89..6ad66bc4da88 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -749,7 +749,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 		set_pmd_at(mm, haddr, pmd, entry);
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
-		atomic_long_inc(&mm->nr_ptes);
+		atomic_long_inc(&mm->nr_pgtables);
 		spin_unlock(ptl);
 	}
 
@@ -782,7 +782,7 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	entry = pmd_mkhuge(entry);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
-	atomic_long_inc(&mm->nr_ptes);
+	atomic_long_inc(&mm->nr_pgtables);
 	return true;
 }
 
@@ -905,7 +905,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
 	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
-	atomic_long_inc(&dst_mm->nr_ptes);
+	atomic_long_inc(&dst_mm->nr_pgtables);
 
 	ret = 0;
 out_unlock:
@@ -1429,7 +1429,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
 		if (is_huge_zero_pmd(orig_pmd)) {
-			atomic_long_dec(&tlb->mm->nr_ptes);
+			atomic_long_dec(&tlb->mm->nr_pgtables);
 			spin_unlock(ptl);
 			put_huge_zero_page();
 		} else {
@@ -1438,7 +1438,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON_PAGE(!PageHead(page), page);
-			atomic_long_dec(&tlb->mm->nr_ptes);
+			atomic_long_dec(&tlb->mm->nr_pgtables);
 			spin_unlock(ptl);
 			tlb_remove_page(tlb, page);
 		}
diff --git a/mm/memory.c b/mm/memory.c
index 5afb6d89ac96..2f9ee3089c20 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -394,7 +394,7 @@ static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
 	pgtable_t token = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
 	pte_free_tlb(tlb, token, addr);
-	atomic_long_dec(&tlb->mm->nr_ptes);
+	atomic_long_dec(&tlb->mm->nr_pgtables);
 }
 
 static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
@@ -586,7 +586,7 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	ptl = pmd_lock(mm, pmd);
 	wait_split_huge_page = 0;
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
-		atomic_long_inc(&mm->nr_ptes);
+		atomic_long_inc(&mm->nr_pgtables);
 		pmd_populate(mm, pmd, new);
 		new = NULL;
 	} else if (unlikely(pmd_trans_splitting(*pmd)))
diff --git a/mm/mmap.c b/mm/mmap.c
index 14d84666e8ba..3c591112263d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2852,7 +2852,7 @@ void exit_mmap(struct mm_struct *mm)
 	}
 	vm_unacct_memory(nr_accounted);
 
-	WARN_ON(atomic_long_read(&mm->nr_ptes) >
+	WARN_ON(atomic_long_read(&mm->nr_pgtables) >
 			(FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 294493a7ae4b..d121ee7fa357 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -169,7 +169,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + atomic_long_read(&p->mm->nr_ptes) +
+	points = get_mm_rss(p->mm) + atomic_long_read(&p->mm->nr_pgtables) +
 		 get_mm_counter(p->mm, MM_SWAPENTS);
 	task_unlock(p);
 
@@ -345,7 +345,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
  * Dumps the current memory state of all eligible tasks.  Tasks not in the same
  * memcg, not in the same cpuset, or bound to a disjoint set of mempolicy nodes
  * are not shown.
- * State information includes task's pid, uid, tgid, vm size, rss, nr_ptes,
+ * State information includes task's pid, uid, tgid, vm size, rss, nr_pgtables,
  * swapents, oom_score_adj value, and name.
  */
 static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -353,7 +353,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	struct task_struct *p;
 	struct task_struct *task;
 
-	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name\n");
+	pr_info("[ pid ]   uid  tgid total_vm      rss nr_pgtables swapents oom_score_adj name\n");
 	rcu_read_lock();
 	for_each_process(p) {
 		if (oom_unkillable_task(p, memcg, nodemask))
@@ -372,7 +372,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 		pr_info("[%5d] %5d %5d %8lu %8lu %7ld %8lu         %5hd %s\n",
 			task->pid, from_kuid(&init_user_ns, task_uid(task)),
 			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-			atomic_long_read(&task->mm->nr_ptes),
+			atomic_long_read(&task->mm->nr_pgtables),
 			get_mm_counter(task->mm, MM_SWAPENTS),
 			task->signal->oom_score_adj, task->comm);
 		task_unlock(task);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
