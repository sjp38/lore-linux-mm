Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFAD56B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 06:07:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y77so37642467pfd.2
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 03:07:00 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k188si838200pgc.384.2017.10.06.03.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 03:06:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 1/2] mm: Introduce wrappers to access mm->nr_ptes
Date: Fri,  6 Oct 2017 13:06:50 +0300
Message-Id: <20171006100651.44742-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's add wrappers for ->nr_ptes with the same interface as for nr_pmd
and nr_pud.

The patch also makes nr_ptes accounting dependent onto CONFIG_MMU.
Page table accounting doesn't make sense if you don't have page tables.

It's preparation for consolidation of page-table counters in mm_struct.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/arm/mm/pgd.c           |  2 +-
 arch/sparc/mm/hugetlbpage.c |  2 +-
 arch/unicore32/mm/pgd.c     |  2 +-
 fs/proc/task_mmu.c          |  2 +-
 include/linux/mm.h          | 32 ++++++++++++++++++++++++++++++++
 include/linux/mm_types.h    |  2 ++
 kernel/fork.c               |  6 +++---
 mm/debug.c                  |  2 +-
 mm/huge_memory.c            | 10 +++++-----
 mm/khugepaged.c             |  2 +-
 mm/memory.c                 |  8 ++++----
 mm/oom_kill.c               |  5 ++---
 12 files changed, 54 insertions(+), 21 deletions(-)

diff --git a/arch/arm/mm/pgd.c b/arch/arm/mm/pgd.c
index c1c1a5c67da1..61e281cb29fb 100644
--- a/arch/arm/mm/pgd.c
+++ b/arch/arm/mm/pgd.c
@@ -141,7 +141,7 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd_base)
 	pte = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
 	pte_free(mm, pte);
-	atomic_long_dec(&mm->nr_ptes);
+	mm_dec_nr_ptes(mm);
 no_pmd:
 	pud_clear(pud);
 	pmd_free(mm, pmd);
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index fd0d85808828..29fa5967b7d2 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -396,7 +396,7 @@ static void hugetlb_free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
 
 	pmd_clear(pmd);
 	pte_free_tlb(tlb, token, addr);
-	atomic_long_dec(&tlb->mm->nr_ptes);
+	mm_dec_nr_ptes(tlb->mm);
 }
 
 static void hugetlb_free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
diff --git a/arch/unicore32/mm/pgd.c b/arch/unicore32/mm/pgd.c
index c572a28c76c9..a830a300aaa1 100644
--- a/arch/unicore32/mm/pgd.c
+++ b/arch/unicore32/mm/pgd.c
@@ -97,7 +97,7 @@ void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd)
 	pte = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
 	pte_free(mm, pte);
-	atomic_long_dec(&mm->nr_ptes);
+	mm_dec_nr_ptes(mm);
 	pmd_free(mm, pmd);
 	mm_dec_nr_pmds(mm);
 free:
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 627de66204bd..84c262d5197a 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -49,7 +49,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
 	text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK)) >> 10;
 	lib = (mm->exec_vm << (PAGE_SHIFT-10)) - text;
 	swap = get_mm_counter(mm, MM_SWAPENTS);
-	ptes = PTRS_PER_PTE * sizeof(pte_t) * atomic_long_read(&mm->nr_ptes);
+	ptes = PTRS_PER_PTE * sizeof(pte_t) * mm_nr_ptes(mm);
 	pmds = PTRS_PER_PMD * sizeof(pmd_t) * mm_nr_pmds(mm);
 	puds = PTRS_PER_PUD * sizeof(pud_t) * mm_nr_puds(mm);
 	seq_printf(m,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5125c51c9c35..e185dcdc5183 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1679,6 +1679,38 @@ static inline void mm_dec_nr_pmds(struct mm_struct *mm)
 }
 #endif
 
+#ifdef CONFIG_MMU
+static inline void mm_nr_ptes_init(struct mm_struct *mm)
+{
+	atomic_long_set(&mm->nr_ptes, 0);
+}
+
+static inline unsigned long mm_nr_ptes(const struct mm_struct *mm)
+{
+	return atomic_long_read(&mm->nr_ptes);
+}
+
+static inline void mm_inc_nr_ptes(struct mm_struct *mm)
+{
+	atomic_long_inc(&mm->nr_ptes);
+}
+
+static inline void mm_dec_nr_ptes(struct mm_struct *mm)
+{
+	atomic_long_dec(&mm->nr_ptes);
+}
+#else
+static inline void mm_nr_ptes_init(struct mm_struct *mm) {}
+
+static inline unsigned long mm_nr_ptes(const struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline void mm_inc_nr_ptes(struct mm_struct *mm) {}
+static inline void mm_dec_nr_ptes(struct mm_struct *mm) {}
+#endif
+
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address);
 int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6c8c2bb9e5a1..95d0eefe1f4a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -398,7 +398,9 @@ struct mm_struct {
 	 */
 	atomic_t mm_count;
 
+#ifdef CONFIG_MMU
 	atomic_long_t nr_ptes;			/* PTE page table pages */
+#endif
 #if CONFIG_PGTABLE_LEVELS > 2
 	atomic_long_t nr_pmds;			/* PMD page table pages */
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index 5624918154db..d466181902cf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -813,7 +813,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
-	atomic_long_set(&mm->nr_ptes, 0);
+	mm_nr_ptes_init(mm);
 	mm_nr_pmds_init(mm);
 	mm_nr_puds_init(mm);
 	mm->map_count = 0;
@@ -869,9 +869,9 @@ static void check_mm(struct mm_struct *mm)
 					  "mm:%p idx:%d val:%ld\n", mm, i, x);
 	}
 
-	if (atomic_long_read(&mm->nr_ptes))
+	if (mm_nr_ptes(mm))
 		pr_alert("BUG: non-zero nr_ptes on freeing mm: %ld\n",
-				atomic_long_read(&mm->nr_ptes));
+				mm_nr_ptes(mm));
 	if (mm_nr_pmds(mm))
 		pr_alert("BUG: non-zero nr_pmds on freeing mm: %ld\n",
 				mm_nr_pmds(mm));
diff --git a/mm/debug.c b/mm/debug.c
index afccb2565269..177326818d24 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -135,7 +135,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end,
 		mm->pgd, atomic_read(&mm->mm_users),
 		atomic_read(&mm->mm_count),
-		atomic_long_read((atomic_long_t *)&mm->nr_ptes),
+		mm_nr_ptes(mm),
 		mm_nr_pmds(mm),
 		mm_nr_puds(mm),
 		mm->map_count,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 269b5df58543..c037d3d34950 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -606,7 +606,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 		pgtable_trans_huge_deposit(vma->vm_mm, vmf->pmd, pgtable);
 		set_pmd_at(vma->vm_mm, haddr, vmf->pmd, entry);
 		add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
-		atomic_long_inc(&vma->vm_mm->nr_ptes);
+		mm_inc_nr_ptes(vma->vm_mm);
 		spin_unlock(vmf->ptl);
 		count_vm_event(THP_FAULT_ALLOC);
 	}
@@ -662,7 +662,7 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	if (pgtable)
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
 	set_pmd_at(mm, haddr, pmd, entry);
-	atomic_long_inc(&mm->nr_ptes);
+	mm_inc_nr_ptes(mm);
 	return true;
 }
 
@@ -747,7 +747,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 
 	if (pgtable) {
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
-		atomic_long_inc(&mm->nr_ptes);
+		mm_inc_nr_ptes(mm);
 	}
 
 	set_pmd_at(mm, addr, pmd, entry);
@@ -975,7 +975,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	get_page(src_page);
 	page_dup_rmap(src_page, true);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
-	atomic_long_inc(&dst_mm->nr_ptes);
+	mm_inc_nr_ptes(dst_mm);
 	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
@@ -1675,7 +1675,7 @@ static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pte_free(mm, pgtable);
-	atomic_long_dec(&mm->nr_ptes);
+	mm_dec_nr_ptes(mm);
 }
 
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index c01f177a1120..9e36fe8857d9 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1269,7 +1269,7 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
 			_pmd = pmdp_collapse_flush(vma, addr, pmd);
 			spin_unlock(ptl);
 			up_write(&vma->vm_mm->mmap_sem);
-			atomic_long_dec(&vma->vm_mm->nr_ptes);
+			mm_dec_nr_ptes(vma->vm_mm);
 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
 		}
 	}
diff --git a/mm/memory.c b/mm/memory.c
index 291d4984b417..c443456dbd02 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -438,7 +438,7 @@ static void free_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
 	pgtable_t token = pmd_pgtable(*pmd);
 	pmd_clear(pmd);
 	pte_free_tlb(tlb, token, addr);
-	atomic_long_dec(&tlb->mm->nr_ptes);
+	mm_dec_nr_ptes(tlb->mm);
 }
 
 static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
@@ -666,7 +666,7 @@ int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 
 	ptl = pmd_lock(mm, pmd);
 	if (likely(pmd_none(*pmd))) {	/* Has another populated it ? */
-		atomic_long_inc(&mm->nr_ptes);
+		mm_inc_nr_ptes(mm);
 		pmd_populate(mm, pmd, new);
 		new = NULL;
 	}
@@ -3213,7 +3213,7 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
 			goto map_pte;
 		}
 
-		atomic_long_inc(&vma->vm_mm->nr_ptes);
+		mm_inc_nr_ptes(vma->vm_mm);
 		pmd_populate(vma->vm_mm, vmf->pmd, vmf->prealloc_pte);
 		spin_unlock(vmf->ptl);
 		vmf->prealloc_pte = NULL;
@@ -3272,7 +3272,7 @@ static void deposit_prealloc_pte(struct vm_fault *vmf)
 	 * We are going to consume the prealloc table,
 	 * count that as nr_ptes.
 	 */
-	atomic_long_inc(&vma->vm_mm->nr_ptes);
+	mm_inc_nr_ptes(vma->vm_mm);
 	vmf->prealloc_pte = NULL;
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4bee6968885d..851a0eec2624 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -200,8 +200,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * task's rss, pagetable and swap space use.
 	 */
 	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		atomic_long_read(&p->mm->nr_ptes) + mm_nr_pmds(p->mm) +
-		mm_nr_puds(p->mm);
+		mm_nr_ptes(p->mm) + mm_nr_pmds(p->mm) + mm_nr_puds(p->mm);
 	task_unlock(p);
 
 	/*
@@ -396,7 +395,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 		pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %7ld %8lu         %5hd %s\n",
 			task->pid, from_kuid(&init_user_ns, task_uid(task)),
 			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-			atomic_long_read(&task->mm->nr_ptes),
+			mm_nr_ptes(task->mm),
 			mm_nr_pmds(task->mm),
 			mm_nr_puds(task->mm),
 			get_mm_counter(task->mm, MM_SWAPENTS),
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
