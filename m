Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id EC4849C0002
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 07:26:13 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 2/9] mm: convert mm->nr_ptes to atomic_t
Date: Mon, 16 Sep 2013 14:25:33 +0300
Message-Id: <1379330740-5602-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With split page table lock for PMD level we can't hold
mm->page_table_lock while updating nr_ptes.

Let's convert it to atomic_t to avoid races.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/proc/task_mmu.c       |  4 ++--
 include/linux/mm_types.h |  2 +-
 kernel/fork.c            |  2 +-
 mm/huge_memory.c         | 10 +++++-----
 mm/memory.c              |  4 ++--
 mm/mmap.c                |  3 ++-
 mm/oom_kill.c            |  6 +++---
 7 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7366e9d..8e124ac 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -52,7 +52,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		"VmStk:\t%8lu kB\n"
 		"VmExe:\t%8lu kB\n"
 		"VmLib:\t%8lu kB\n"
-		"VmPTE:\t%8lu kB\n"
+		"VmPTE:\t%8zd kB\n"
 		"VmSwap:\t%8lu kB\n",
 		hiwater_vm << (PAGE_SHIFT-10),
 		total_vm << (PAGE_SHIFT-10),
@@ -62,7 +62,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 		total_rss << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
-		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10,
+		(PTRS_PER_PTE*sizeof(pte_t)*atomic_read(&mm->nr_ptes)) >> 10,
 		swap << (PAGE_SHIFT-10));
 }
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c6af00c..b17a909 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -338,6 +338,7 @@ struct mm_struct {
 	pgd_t * pgd;
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
+	atomic_t nr_ptes;			/* Page table pages */
 	int map_count;				/* number of VMAs */
 
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
@@ -359,7 +360,6 @@ struct mm_struct {
 	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
 	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
 	unsigned long def_flags;
-	unsigned long nr_ptes;		/* Page table pages */
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
diff --git a/kernel/fork.c b/kernel/fork.c
index 81ccb4f..4c8b986 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -532,7 +532,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	mm->flags = (current->mm) ?
 		(current->mm->flags & MMF_INIT_MASK) : default_dump_filter;
 	mm->core_state = NULL;
-	mm->nr_ptes = 0;
+	atomic_set(&mm->nr_ptes, 0);
 	memset(&mm->rss_stat, 0, sizeof(mm->rss_stat));
 	spin_lock_init(&mm->page_table_lock);
 	mm_init_aio(mm);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7489884..bbd41a2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -737,7 +737,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 		set_pmd_at(mm, haddr, pmd, entry);
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
-		mm->nr_ptes++;
+		atomic_inc(&mm->nr_ptes);
 		spin_unlock(&mm->page_table_lock);
 	}
 
@@ -778,7 +778,7 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	entry = pmd_mkhuge(entry);
 	pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
-	mm->nr_ptes++;
+	atomic_inc(&mm->nr_ptes);
 	return true;
 }
 
@@ -903,7 +903,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
 	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
-	dst_mm->nr_ptes++;
+	atomic_inc(&dst_mm->nr_ptes);
 
 	ret = 0;
 out_unlock:
@@ -1358,7 +1358,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
 		if (is_huge_zero_pmd(orig_pmd)) {
-			tlb->mm->nr_ptes--;
+			atomic_dec(&tlb->mm->nr_ptes);
 			spin_unlock(&tlb->mm->page_table_lock);
 			put_huge_zero_page();
 		} else {
@@ -1367,7 +1367,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			VM_BUG_ON(page_mapcount(page) < 0);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON(!PageHead(page));
-			tlb->mm->nr_ptes--;
+			atomic_dec(&tlb->mm->nr_ptes);
 			spin_unlock(&tlb->mm->page_table_lock);
 			tlb_remove_page(tlb, page);
 		}
diff --git a/mm/memory.c b/mm/memory.c
index ca00039..1046396 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -382,7 +382,7 @@ static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
 	pgtable_t token = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
 	pte_free_tlb(tlb, token, addr);
-	tlb->mm->nr_ptes--;
+	atomic_dec(&tlb->mm->nr_ptes);
 }
 
 static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
@@ -575,7 +575,7 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_lock(&mm->page_table_lock);
 	wait_split_huge_page = 0;
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
-		mm->nr_ptes++;
+		atomic_inc(&mm->nr_ptes);
 		pmd_populate(mm, pmd, new);
 		new = NULL;
 	} else if (unlikely(pmd_trans_splitting(*pmd)))
diff --git a/mm/mmap.c b/mm/mmap.c
index 9d54851..1d0efbc 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2726,7 +2726,8 @@ void exit_mmap(struct mm_struct *mm)
 	}
 	vm_unacct_memory(nr_accounted);
 
-	WARN_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
+	WARN_ON(atomic_read(&mm->nr_ptes) >
+			(FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 314e9d2..7ab394e 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -161,7 +161,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + p->mm->nr_ptes +
+	points = get_mm_rss(p->mm) + atomic_read(&p->mm->nr_ptes) +
 		 get_mm_counter(p->mm, MM_SWAPENTS);
 	task_unlock(p);
 
@@ -364,10 +364,10 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
 			continue;
 		}
 
-		pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu         %5hd %s\n",
+		pr_info("[%5d] %5d %5d %8lu %8lu %7d %8lu         %5hd %s\n",
 			task->pid, from_kuid(&init_user_ns, task_uid(task)),
 			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-			task->mm->nr_ptes,
+			atomic_read(&task->mm->nr_ptes),
 			get_mm_counter(task->mm, MM_SWAPENTS),
 			task->signal->oom_score_adj, task->comm);
 		task_unlock(task);
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
