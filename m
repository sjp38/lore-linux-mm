Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 4FF0C6B00F1
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:06 -0400 (EDT)
Message-Id: <20120316144241.682156918@chello.nl>
Date: Fri, 16 Mar 2012 15:40:52 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 24/26] mm, mpol: Implement numa_group RSS accounting
References: <20120316144028.036474157@chello.nl>
Content-Disposition: inline; filename=numa-rss.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

Somewhat invasive, add another call next to every
{add,dec}_mm_counter() that takes a vma argument instead.

Should we fold and do a single call taking both mm and vma?

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/filemap_xip.c |    1 +
 mm/fremap.c      |    2 ++
 mm/huge_memory.c |    4 ++++
 mm/memory.c      |   26 ++++++++++++++++++++------
 mm/rmap.c        |   14 +++++++++++---
 mm/swapfile.c    |    2 ++
 6 files changed, 40 insertions(+), 9 deletions(-)
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -196,6 +196,7 @@ __xip_unmap (struct address_space * mapp
 			pteval = ptep_clear_flush_notify(vma, address, pte);
 			page_remove_rmap(page);
 			dec_mm_counter(mm, MM_FILEPAGES);
+			numa_add_vma_counter(vma, MM_FILEPAGES, -1);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
+#include <linux/mempolicy.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -40,6 +41,7 @@ static void zap_pte(struct mm_struct *mm
 			page_cache_release(page);
 			update_hiwater_rss(mm);
 			dec_mm_counter(mm, MM_FILEPAGES);
+			numa_add_vma_counter(vma, MM_FILEPAGES, -1);
 		}
 	} else {
 		if (!pte_file(pte))
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -672,6 +672,7 @@ static int __do_huge_pmd_anonymous_page(
 		prepare_pmd_huge_pte(pgtable, mm);
 		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		mm->nr_ptes++;
+		numa_add_vma_counter(vma, MM_ANONPAGES, HPAGE_PMD_NR);
 		spin_unlock(&mm->page_table_lock);
 	}
 
@@ -785,6 +786,7 @@ int copy_huge_pmd(struct mm_struct *dst_
 	get_page(src_page);
 	page_dup_rmap(src_page);
 	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+	numa_add_vma_counter(vma, MM_ANONPAGES, HPAGE_PMD_NR);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
@@ -1047,6 +1049,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
 			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			numa_add_vma_counter(vma, MM_ANONPAGES, -HPAGE_PMD_NR);
 			VM_BUG_ON(!PageHead(page));
 			tlb->mm->nr_ptes--;
 			spin_unlock(&tlb->mm->page_table_lock);
@@ -1805,6 +1808,7 @@ static void __collapse_huge_page_copy(pt
 		if (pte_none(pteval)) {
 			clear_user_highpage(page, address);
 			add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
+			numa_add_vma_counter(vma, MM_ANONPAGES, 1);
 		} else {
 			src_page = pte_page(pteval);
 			copy_user_highpage(page, src_page, address, vma);
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -657,15 +657,19 @@ static inline void init_rss_vec(int *rss
 	memset(rss, 0, sizeof(int) * NR_MM_COUNTERS);
 }
 
-static inline void add_mm_rss_vec(struct mm_struct *mm, int *rss)
+static inline
+void add_mm_rss_vec(struct mm_struct *mm, struct vm_area_struct *vma, int *rss)
 {
 	int i;
 
 	if (current->mm == mm)
 		sync_mm_rss(current, mm);
-	for (i = 0; i < NR_MM_COUNTERS; i++)
-		if (rss[i])
+	for (i = 0; i < NR_MM_COUNTERS; i++) {
+		if (rss[i]) {
 			add_mm_counter(mm, i, rss[i]);
+			numa_add_vma_counter(vma, i, rss[i]);
+		}
+	}
 }
 
 /*
@@ -983,7 +987,7 @@ int copy_pte_range(struct mm_struct *dst
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap(orig_src_pte);
-	add_mm_rss_vec(dst_mm, rss);
+	add_mm_rss_vec(dst_mm, vma, rss);
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
@@ -1217,7 +1221,7 @@ static unsigned long zap_pte_range(struc
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 
-	add_mm_rss_vec(mm, rss);
+	add_mm_rss_vec(mm, vma, rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(start_pte, ptl);
 
@@ -2024,6 +2028,7 @@ static int insert_page(struct vm_area_st
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
 	inc_mm_counter_fast(mm, MM_FILEPAGES);
+	numa_add_vma_counter(vma, MM_FILEPAGES, 1);
 	page_add_file_rmap(page);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
@@ -2680,9 +2685,13 @@ static int do_wp_page(struct mm_struct *
 			if (!PageAnon(old_page)) {
 				dec_mm_counter_fast(mm, MM_FILEPAGES);
 				inc_mm_counter_fast(mm, MM_ANONPAGES);
+				numa_add_vma_counter(vma, MM_FILEPAGES, -1);
+				numa_add_vma_counter(vma, MM_ANONPAGES, 1);
 			}
-		} else
+		} else {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
+			numa_add_vma_counter(vma, MM_ANONPAGES, 1);
+		}
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -3006,6 +3015,8 @@ static int do_swap_page(struct mm_struct
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	dec_mm_counter_fast(mm, MM_SWAPENTS);
+	numa_add_vma_counter(vma, MM_ANONPAGES, 1);
+	numa_add_vma_counter(vma, MM_SWAPENTS, -1);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -3146,6 +3157,7 @@ static int do_anonymous_page(struct mm_s
 		goto release;
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
+	numa_add_vma_counter(vma, MM_ANONPAGES, 1);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:
 	set_pte_at(mm, address, page_table, entry);
@@ -3301,9 +3313,11 @@ static int __do_fault(struct mm_struct *
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (anon) {
 			inc_mm_counter_fast(mm, MM_ANONPAGES);
+			numa_add_vma_counter(vma, MM_ANONPAGES, 1);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter_fast(mm, MM_FILEPAGES);
+			numa_add_vma_counter(vma, MM_FILEPAGES, 1);
 			page_add_file_rmap(page);
 			if (flags & FAULT_FLAG_WRITE) {
 				dirty_page = page;
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1255,10 +1255,13 @@ int try_to_unmap_one(struct page *page,
 	update_hiwater_rss(mm);
 
 	if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWPOISON)) {
-		if (PageAnon(page))
+		if (PageAnon(page)) {
 			dec_mm_counter(mm, MM_ANONPAGES);
-		else
+			numa_add_vma_counter(vma, MM_ANONPAGES, -1);
+		} else {
 			dec_mm_counter(mm, MM_FILEPAGES);
+			numa_add_vma_counter(vma, MM_FILEPAGES, -1);
+		}
 		set_pte_at(mm, address, pte,
 				swp_entry_to_pte(make_hwpoison_entry(page)));
 	} else if (PageAnon(page)) {
@@ -1282,6 +1285,8 @@ int try_to_unmap_one(struct page *page,
 			}
 			dec_mm_counter(mm, MM_ANONPAGES);
 			inc_mm_counter(mm, MM_SWAPENTS);
+			numa_add_vma_counter(vma, MM_ANONPAGES, -1);
+			numa_add_vma_counter(vma, MM_SWAPENTS, 1);
 		} else if (PAGE_MIGRATION) {
 			/*
 			 * Store the pfn of the page in a special migration
@@ -1299,8 +1304,10 @@ int try_to_unmap_one(struct page *page,
 		swp_entry_t entry;
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
-	} else
+	} else {
 		dec_mm_counter(mm, MM_FILEPAGES);
+		numa_add_vma_counter(vma, MM_FILEPAGES, -1);
+	}
 
 	page_remove_rmap(page);
 	page_cache_release(page);
@@ -1440,6 +1447,7 @@ static int try_to_unmap_cluster(unsigned
 		page_remove_rmap(page);
 		page_cache_release(page);
 		dec_mm_counter(mm, MM_FILEPAGES);
+		numa_add_vma_counter(vma, MM_FILEPAGES, -1);
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -881,6 +881,8 @@ static int unuse_pte(struct vm_area_stru
 
 	dec_mm_counter(vma->vm_mm, MM_SWAPENTS);
 	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
+	numa_add_vma_counter(vma, MM_SWAPENTS, -1);
+	numa_add_vma_counter(vma, MM_ANONPAGES, 1);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
