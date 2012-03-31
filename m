Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id DF1016B004D
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 10:10:26 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 2/2] huge-memory: Use fast mm counters for transparent huge pages
Date: Sat, 31 Mar 2012 07:09:57 -0700
Message-Id: <1333202997-19550-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1333202997-19550-1-git-send-email-andi@firstfloor.org>
References: <1333202997-19550-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tim.c.chen@linux.intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, aarcange@redhat.com

From: Andi Kleen <ak@linux.intel.com>

We found that the mm struct anon page counter cache line is much hotter
with transparent huge pages compared to small pages.

Small pages use a special fast counter mechanism in task_struct, but huge pages
didn't.  The huge pages are larger than the normal 64 entry threshold for the
fast counter, so it cannot be directly used. Use a new special counter for huge
pages to handle them efficiently.

Any users just calculate the correct total.

The only special case is transferring the large page count to small pages
when splitting. I put it somewhat arbitarily into the tricky split
sequence. Some review on this part is appreciated.

[An alternative would be to not do that, but that could lead to
negative counters. These should still give the correct result]

Contains a fix for a problem found by Andrea in review.

Cc: aarcange@redhat.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 fs/proc/task_mmu.c       |    3 ++-
 include/linux/mm.h       |    3 ++-
 include/linux/mm_types.h |    1 +
 mm/huge_memory.c         |   16 ++++++++++++----
 mm/oom_kill.c            |    3 ++-
 5 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 7dcd2a2..0c261e9 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -78,7 +78,8 @@ unsigned long task_statm(struct mm_struct *mm,
 	*text = (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAGE_MASK))
 								>> PAGE_SHIFT;
 	*data = mm->total_vm - mm->shared_vm;
-	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES);
+	*resident = *shared + get_mm_counter(mm, MM_ANONPAGES) + 
+		get_mm_counter(mm, MM_ANONPAGES_HUGE) * HPAGE_PMD_NR;
 	return mm->total_vm;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad8d314..26b281b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1100,7 +1100,8 @@ static inline void dec_mm_counter(struct mm_struct *mm, int member)
 static inline unsigned long get_mm_rss(struct mm_struct *mm)
 {
 	return get_mm_counter(mm, MM_FILEPAGES) +
-		get_mm_counter(mm, MM_ANONPAGES);
+		get_mm_counter(mm, MM_ANONPAGES) +
+		get_mm_counter(mm, MM_ANONPAGES_HUGE) * HPAGE_PMD_NR;
 }
 
 static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..4078b31 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -268,6 +268,7 @@ struct core_state {
 enum {
 	MM_FILEPAGES,
 	MM_ANONPAGES,
+	MM_ANONPAGES_HUGE,
 	MM_SWAPENTS,
 	NR_MM_COUNTERS
 };
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 91d3efb..b02abee 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -670,7 +670,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		page_add_new_anon_rmap(page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		prepare_pmd_huge_pte(pgtable, mm);
-		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		inc_mm_counter_fast(mm, MM_ANONPAGES_HUGE);
 		spin_unlock(&mm->page_table_lock);
 	}
 
@@ -783,7 +783,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	VM_BUG_ON(!PageHead(src_page));
 	get_page(src_page);
 	page_dup_rmap(src_page);
-	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+	inc_mm_counter_fast(dst_mm, MM_ANONPAGES_HUGE);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
@@ -1045,7 +1045,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			dec_mm_counter_fast(tlb->mm, MM_ANONPAGES_HUGE);
 			VM_BUG_ON(!PageHead(page));
 			spin_unlock(&tlb->mm->page_table_lock);
 			tlb_remove_page(tlb, page);
@@ -1410,6 +1410,13 @@ static int __split_huge_page_map(struct page *page,
 	}
 	spin_unlock(&mm->page_table_lock);
 
+	/* 
+	 * Update per mm counters. This is slightly non atomic, but shouldn't
+	 * be a problem.
+	 */ 
+	dec_mm_counter_fast(mm, MM_ANONPAGES_HUGE);
+	add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+
 	return ret;
 }
 
@@ -1803,13 +1810,13 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 
 		if (pte_none(pteval)) {
 			clear_user_highpage(page, address);
-			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
 		} else {
 			src_page = pte_page(pteval);
 			copy_user_highpage(page, src_page, address, vma);
 			VM_BUG_ON(page_mapcount(src_page) != 1);
 			VM_BUG_ON(page_count(src_page) != 2);
 			release_pte_page(src_page);
+			dec_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 			/*
 			 * ptl mostly unnecessary, but preempt has to
 			 * be disabled to update the per-cpu stats
@@ -1829,6 +1836,7 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 		address += PAGE_SIZE;
 		page++;
 	}
+	add_mm_counter_fast(vma->vm_mm, MM_ANONPAGES_HUGE);
 }
 
 static void collapse_huge_page(struct mm_struct *mm,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 2958fd8..343a48d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -448,7 +448,8 @@ static int oom_kill_task(struct task_struct *p)
 
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(p), p->comm, K(p->mm->total_vm),
-		K(get_mm_counter(p->mm, MM_ANONPAGES)),
+	       K(get_mm_counter(p->mm, MM_ANONPAGES) + 
+		 get_mm_counter(p->mm, MM_ANONPAGES_HUGE) * HPAGE_PMD_NR),
 		K(get_mm_counter(p->mm, MM_FILEPAGES)));
 	task_unlock(p);
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
