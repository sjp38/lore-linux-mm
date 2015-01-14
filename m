Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 928C66B006C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 11:52:04 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so11568783pab.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:52:04 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id au1si31326076pbc.117.2015.01.14.08.52.01
        for <linux-mm@kvack.org>;
        Wed, 14 Jan 2015 08:52:02 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: account pmd page tables to the process
Date: Wed, 14 Jan 2015 18:51:56 +0200
Message-Id: <1421254316-190596-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Dave noticed that unprivileged process can allocate significant amount
of memory -- >500 MiB on x86_64 -- and stay unnoticed by oom-killer and
memory cgroup. The trick is to allocate a lot of PMD page tables. Linux
kernel doesn't account PMD tables to the process, only PTE.

The use-cases below use few tricks to allocate a lot of PMD page tables
while keeping VmRSS and VmPTE low. oom_score for the process will be 0.

	#include <errno.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <sys/mman.h>
	#include <sys/prctl.h>

	#define PUD_SIZE (1UL << 30)
	#define PMD_SIZE (1UL << 21)

	#define NR_PUD 130000

	int main(void)
	{
		char *addr = NULL;
		unsigned long i;

		prctl(PR_SET_THP_DISABLE);
		for (i = 0; i < NR_PUD ; i++) {
			addr = mmap(addr + PUD_SIZE, PUD_SIZE, PROT_WRITE|PROT_READ,
					MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
			if (addr == MAP_FAILED) {
				perror("mmap");
				break;
			}
			*addr = 'x';
			munmap(addr, PMD_SIZE);
			mmap(addr, PMD_SIZE, PROT_WRITE|PROT_READ,
					MAP_ANONYMOUS|MAP_PRIVATE|MAP_FIXED, -1, 0);
			if (addr == MAP_FAILED)
				perror("re-mmap"), exit(1);
		}
		printf("PID %d consumed %lu KiB in PMD page tables\n",
				getpid(), i * 4096 >> 10);
		return pause();
	}

The patch addresses the issue by account PMD tables to the process the
same way we account PTE.

The main place where PMD tables is accounted is __pmd_alloc() and
free_pmd_range(). But there're few corner cases:

 - HugeTLB can share PMD page tables. The patch handles by accounting
   the table to all processes who share it.

 - x86 PAE pre-allocates few PMD tables on fork.

 - Architectures with FIRST_USER_ADDRESS > 0. We need to adjust sanity
   check on exit(2).

Accounting only happens on configuration where PMD page table's level is
present (PMD is not folded). As with nr_ptes we use per-mm counter. The
counter value is used to calculate baseline for badness score by
oom-killer.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 v2:
  - use separate counter for pmd page table;

---
 Documentation/sysctl/vm.txt | 12 ++++++------
 arch/x86/mm/pgtable.c       | 13 ++++++++-----
 fs/proc/task_mmu.c          |  9 ++++++---
 include/linux/mm.h          | 24 ++++++++++++++++++++++++
 include/linux/mm_types.h    |  5 ++++-
 kernel/fork.c               |  3 +++
 mm/debug.c                  |  3 ++-
 mm/hugetlb.c                |  8 ++++++--
 mm/memory.c                 |  2 ++
 mm/mmap.c                   |  4 +++-
 mm/oom_kill.c               |  9 +++++----
 11 files changed, 69 insertions(+), 23 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 4415aa915681..e9c706e4627a 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -555,12 +555,12 @@ this is causing problems for your system/application.
 
 oom_dump_tasks
 
-Enables a system-wide task dump (excluding kernel threads) to be
-produced when the kernel performs an OOM-killing and includes such
-information as pid, uid, tgid, vm size, rss, nr_ptes, swapents,
-oom_score_adj score, and name.  This is helpful to determine why the
-OOM killer was invoked, to identify the rogue task that caused it,
-and to determine why the OOM killer chose the task it did to kill.
+Enables a system-wide task dump (excluding kernel threads) to be produced
+when the kernel performs an OOM-killing and includes such information as
+pid, uid, tgid, vm size, rss, nr_ptes, nr_pmds, swapents, oom_score_adj
+score, and name.  This is helpful to determine why the OOM killer was
+invoked, to identify the rogue task that caused it, and to determine why
+the OOM killer chose the task it did to kill.
 
 If this is set to zero, this information is suppressed.  On very
 large systems with thousands of tasks it may not be feasible to dump
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 6fb6927f9e76..a7d36de0bd30 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -190,7 +190,7 @@ void pud_populate(struct mm_struct *mm, pud_t *pudp, pmd_t *pmd)
 
 #endif	/* CONFIG_X86_PAE */
 
-static void free_pmds(pmd_t *pmds[])
+static void free_pmds(struct mm_struct *mm, pmd_t *pmds[])
 {
 	int i;
 
@@ -198,10 +198,11 @@ static void free_pmds(pmd_t *pmds[])
 		if (pmds[i]) {
 			pgtable_pmd_page_dtor(virt_to_page(pmds[i]));
 			free_page((unsigned long)pmds[i]);
+			mm_dec_nr_pmds(mm);
 		}
 }
 
-static int preallocate_pmds(pmd_t *pmds[])
+static int preallocate_pmds(struct mm_struct *mm, pmd_t *pmds[])
 {
 	int i;
 	bool failed = false;
@@ -215,11 +216,13 @@ static int preallocate_pmds(pmd_t *pmds[])
 			pmd = NULL;
 			failed = true;
 		}
+		if (pmd)
+			mm_inc_nr_pmds(mm);
 		pmds[i] = pmd;
 	}
 
 	if (failed) {
-		free_pmds(pmds);
+		free_pmds(mm, pmds);
 		return -ENOMEM;
 	}
 
@@ -283,7 +286,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 
 	mm->pgd = pgd;
 
-	if (preallocate_pmds(pmds) != 0)
+	if (preallocate_pmds(mm, pmds) != 0)
 		goto out_free_pgd;
 
 	if (paravirt_pgd_alloc(mm) != 0)
@@ -304,7 +307,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	return pgd;
 
 out_free_pmds:
-	free_pmds(pmds);
+	free_pmds(mm, pmds);
 out_free_pgd:
 	free_page((unsigned long)pgd);
 out:
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8faae6fed085..07c8f8a3b9fc 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -21,7 +21,7 @@
 
 void task_mem(struct seq_file *m, struct mm_struct *mm)
 {
-	unsigned long data, text, lib, swap;
+	unsigned long data, text, lib, swap, ptes, pmds;
 	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
 
 	/*
@@ -42,6 +42,8 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
 	swap = get_mm_counter(mm, MM_SWAPENTS);
+	ptes = PTRS_PER_PTE * sizeof(pte_t) * atomic_long_read(&mm->nr_ptes);
+	pmds = PTRS_PER_PMD * sizeof(pmd_t) * mm_nr_pmds(mm);
 	seq_printf(m,
 		"VmPeak:\t%8lu kB\n"
 		"VmSize:\t%8lu kB\n"
@@ -54,6 +56,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmExe:\t%8lu kB\n"
 		"VmLib:\t%8lu kB\n"
 		"VmPTE:\t%8lu kB\n"
+		"VmPMD:\t%8lu kB\n"
 		"VmSwap:\t%8lu kB\n",
 		hiwater_vm << (PAGE_SHIFT-10),
 		total_vm << (PAGE_SHIFT-10),
@@ -63,8 +66,8 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		total_rss << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
-		(PTRS_PER_PTE * sizeof(pte_t) *
-		 atomic_long_read(&mm->nr_ptes)) >> 10,
+		ptes >> 10,
+		pmds >> 10,
 		swap << (PAGE_SHIFT-10));
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3b829b82e226..d3a030c48133 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1409,8 +1409,32 @@ static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
 {
 	return 0;
 }
+
+static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline void mm_inc_nr_pmds(struct mm_struct *mm) {}
+static inline void mm_dec_nr_pmds(struct mm_struct *mm) {}
+
 #else
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
+
+static inline unsigned long mm_nr_pmds(struct mm_struct *mm)
+{
+	return atomic_long_read(&mm->nr_pmds);
+}
+
+static inline void mm_inc_nr_pmds(struct mm_struct *mm)
+{
+	atomic_long_inc(&mm->nr_pmds);
+}
+
+static inline void mm_dec_nr_pmds(struct mm_struct *mm)
+{
+	atomic_long_dec(&mm->nr_pmds);
+}
 #endif
 
 int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 20ff2105b564..79cdf6f5c746 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -363,7 +363,10 @@ struct mm_struct {
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
-	atomic_long_t nr_ptes;			/* Page table pages */
+	atomic_long_t nr_ptes;			/* PTE page table pages */
+#ifndef __PAGETABLE_PMD_FOLDED
+	atomic_long_t nr_pmds;			/* PMD page table pages */
+#endif
 	int map_count;				/* number of VMAs */
 
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
diff --git a/kernel/fork.c b/kernel/fork.c
index b379d9abddc7..c99098c52641 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -555,6 +555,9 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
 	atomic_long_set(&mm->nr_ptes, 0);
+#ifndef __PAGETABLE_PMD_FOLDED
+	atomic_long_set(&mm->nr_pmds, 0);
+#endif
 	mm->map_count = 0;
 	mm->locked_vm = 0;
 	mm->pinned_vm = 0;
diff --git a/mm/debug.c b/mm/debug.c
index d69cb5a7ba9a..3eb3ac2fcee7 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -173,7 +173,7 @@ void dump_mm(const struct mm_struct *mm)
 		"get_unmapped_area %p\n"
 #endif
 		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
-		"pgd %p mm_users %d mm_count %d nr_ptes %lu map_count %d\n"
+		"pgd %p mm_users %d mm_count %d nr_ptes %lu nr_pmds %lu map_count %d\n"
 		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
 		"pinned_vm %lx shared_vm %lx exec_vm %lx stack_vm %lx\n"
 		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
@@ -206,6 +206,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm->pgd, atomic_read(&mm->mm_users),
 		atomic_read(&mm->mm_count),
 		atomic_long_read((atomic_long_t *)&mm->nr_ptes),
+		mm_nr_pmds((struct mm_struct *)mm),
 		mm->map_count,
 		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
 		mm->pinned_vm, mm->shared_vm, mm->exec_vm, mm->stack_vm,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index be0e5d0db5ec..0d28c123f517 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3558,6 +3558,7 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 		if (saddr) {
 			spte = huge_pte_offset(svma->vm_mm, saddr);
 			if (spte) {
+				mm_inc_nr_pmds(mm);
 				get_page(virt_to_page(spte));
 				break;
 			}
@@ -3569,11 +3570,13 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 
 	ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
 	spin_lock(ptl);
-	if (pud_none(*pud))
+	if (pud_none(*pud)) {
 		pud_populate(mm, pud,
 				(pmd_t *)((unsigned long)spte & PAGE_MASK));
-	else
+	} else {
 		put_page(virt_to_page(spte));
+		mm_inc_nr_pmds(mm);
+	}
 	spin_unlock(ptl);
 out:
 	pte = (pte_t *)pmd_alloc(mm, pud, addr);
@@ -3604,6 +3607,7 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 
 	pud_clear(pud);
 	put_page(virt_to_page(ptep));
+	mm_dec_nr_pmds(mm);
 	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
 	return 1;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 5afb6d89ac96..b89bc23267aa 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -428,6 +428,7 @@ static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
 	pmd = pmd_offset(pud, start);
 	pud_clear(pud);
 	pmd_free_tlb(tlb, pmd, start);
+	mm_dec_nr_pmds(tlb->mm);
 }
 
 static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
@@ -3321,6 +3322,7 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 	smp_wmb(); /* See comment in __pte_alloc */
 
 	spin_lock(&mm->page_table_lock);
+	mm_inc_nr_pmds(mm);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
 		pmd_free(mm, new);
diff --git a/mm/mmap.c b/mm/mmap.c
index 14d84666e8ba..6a7d36d133fb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2853,7 +2853,9 @@ void exit_mmap(struct mm_struct *mm)
 	vm_unacct_memory(nr_accounted);
 
 	WARN_ON(atomic_long_read(&mm->nr_ptes) >
-			(FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
+			round_up(FIRST_USER_ADDRESS, PMD_SIZE) >> PMD_SHIFT);
+	WARN_ON(mm_nr_pmds(mm) >
+			round_up(FIRST_USER_ADDRESS, PUD_SIZE) >> PUD_SHIFT);
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 294493a7ae4b..74ef5494d15a 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -169,8 +169,8 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + atomic_long_read(&p->mm->nr_ptes) +
-		 get_mm_counter(p->mm, MM_SWAPENTS);
+	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
+		atomic_long_read(&p->mm->nr_ptes) + mm_nr_pmds(p->mm);
 	task_unlock(p);
 
 	/*
@@ -353,7 +353,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	struct task_struct *p;
 	struct task_struct *task;
 
-	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name\n");
+	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name\n");
 	rcu_read_lock();
 	for_each_process(p) {
 		if (oom_unkillable_task(p, memcg, nodemask))
@@ -369,10 +369,11 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 			continue;
 		}
 
-		pr_info("[%5d] %5d %5d %8lu %8lu %7ld %8lu         %5hd %s\n",
+		pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n",
 			task->pid, from_kuid(&init_user_ns, task_uid(task)),
 			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
 			atomic_long_read(&task->mm->nr_ptes),
+			mm_nr_pmds(task->mm),
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
