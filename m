Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 23CAF6B007E
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 03:13:29 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n677uMru028673
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Jul 2009 16:56:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D652445DE55
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:56:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A151845DE4E
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:56:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D3A21DB805D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:56:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 191081DB8043
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 16:56:21 +0900 (JST)
Date: Tue, 7 Jul 2009 16:54:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/4] use ZERO_PAGE for READ fault in regular anonymous
 mapping
Message-Id: <20090707165438.e397cf69.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch makes vm_normal_page() ruturn NULL if it founds zero page.
If the caller must handle zero page, it should check zero_pte() before/after
calling vm_normal_page().

In summary,
 - vm_normal_page() returns NULL if it finds ZERO_PAGE.
 - As old ages, mapped ZERO_PAGE is counted as file_rss under mm struct.
 - Read access by get_user_pages() can returns ZERO_PAGE.
   This behavior is the same to the old ZERO_PAGE's behavior.
   But has some troubles now. this problem will be handled in the next patch
   in series.

Changelog: v1->v2
 - making use of pte_zero() rather than modify vm_normal_page too much.
 - don't handle (VM_PFNMAP | VM_FIXEDMAP) pages.
 - splitted get_user_pages(READ) workaround  into other patch.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c |   10 ++++++
 mm/fremap.c        |    3 ++
 mm/memory.c        |   78 +++++++++++++++++++++++++++++++++++++++++++++--------
 mm/mempolicy.c     |   11 ++-----
 mm/rmap.c          |    2 -
 5 files changed, 83 insertions(+), 21 deletions(-)

Index: zeropage-trial/mm/memory.c
===================================================================
--- zeropage-trial.orig/mm/memory.c
+++ zeropage-trial/mm/memory.c
@@ -490,6 +490,7 @@ static inline int is_cow_mapping(unsigne
  * advantage is that we don't have to follow the strict linearity rule of
  * PFNMAP mappings in order to support COWable mappings.
  *
+ * vm_normal_page() returns NULL if ZERO_PAGE founds.
  */
 #ifdef __HAVE_ARCH_PTE_SPECIAL
 # define HAVE_PTE_SPECIAL 1
@@ -527,11 +528,12 @@ struct page *vm_normal_page(struct vm_ar
 	}
 
 check_pfn:
+	if (unlikely(pte_zero(pte)))
+		return NULL;
 	if (unlikely(pfn > highest_memmap_pfn)) {
 		print_bad_pte(vma, addr, pte, NULL);
 		return NULL;
 	}
-
 	/*
 	 * NOTE! We still have PageReserved() pages in the page tables.
 	 * eg. VDSO mappings can cause them to exist.
@@ -605,7 +607,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
 		get_page(page);
 		page_dup_rmap(page, vma, addr);
 		rss[!!PageAnon(page)]++;
-	}
+	} else if (pte_zero(pte))
+		rss[1]++;
 
 out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
@@ -813,6 +816,8 @@ static unsigned long zap_pte_range(struc
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
 			tlb_remove_tlb_entry(tlb, pte, addr);
+			if (pte_zero(ptent))
+				file_rss--;
 			if (unlikely(!page))
 				continue;
 			if (unlikely(details) && details->nonlinear_vma
@@ -1149,9 +1154,13 @@ struct page *follow_page(struct vm_area_
 		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;
-	page = vm_normal_page(vma, address, pte);
-	if (unlikely(!page))
-		goto bad_page;
+
+	if (likely(!pte_zero(pte))) {
+		page = vm_normal_page(vma, address, pte);
+		if (unlikely(!page))
+			goto bad_page;
+	} else
+		page = ZERO_PAGE(0);
 
 	if (flags & FOLL_GET)
 		get_page(page);
@@ -1164,7 +1173,8 @@ struct page *follow_page(struct vm_area_
 		 * is needed to avoid losing the dirty bit: it is easier to use
 		 * mark_page_accessed().
 		 */
-		mark_page_accessed(page);
+		if (!pte_zero(pte))
+			mark_page_accessed(page);
 	}
 unlock:
 	pte_unmap_unlock(ptep, ptl);
@@ -1267,7 +1277,12 @@ int __get_user_pages(struct task_struct 
 				return i ? : -EFAULT;
 			}
 			if (pages) {
-				struct page *page = vm_normal_page(gate_vma, start, *pte);
+				struct page *page;
+				if (!pte_zero(*pte))
+					page = vm_normal_page(gate_vma,
+							      start, *pte);
+				else
+					page = ZERO_PAGE(page);
 				pages[i] = page;
 				if (page)
 					get_page(page);
@@ -1960,6 +1975,13 @@ static int do_wp_page(struct mm_struct *
 	int reuse = 0, ret = 0;
 	int page_mkwrite = 0;
 	struct page *dirty_page = NULL;
+	gfp_t gfpflags = GFP_HIGHUSER_MOVABLE;
+
+	if (pte_zero(orig_pte)) {
+		gfpflags |= __GFP_ZERO;
+		old_page = NULL;
+		goto gotten;
+	}
 
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page) {
@@ -2082,7 +2104,7 @@ gotten:
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 	VM_BUG_ON(old_page == ZERO_PAGE(0));
-	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	new_page = alloc_page_vma(gfpflags, vma, address);
 	if (!new_page)
 		goto oom;
 	/*
@@ -2094,7 +2116,9 @@ gotten:
 		clear_page_mlock(old_page);
 		unlock_page(old_page);
 	}
-	cow_user_page(new_page, old_page, address, vma);
+	/* If zeropage COW, page is already cleared */
+	if (!pte_zero(orig_pte))
+		cow_user_page(new_page, old_page, address, vma);
 	__SetPageUptodate(new_page);
 
 	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
@@ -2110,8 +2134,11 @@ gotten:
 				dec_mm_counter(mm, file_rss);
 				inc_mm_counter(mm, anon_rss);
 			}
-		} else
+		} else {
+			if (pte_zero(orig_pte))
+				dec_mm_counter(mm, file_rss);
 			inc_mm_counter(mm, anon_rss);
+		}
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2618,6 +2645,32 @@ out_page:
 	return ret;
 }
 
+static int do_anon_zeromap(struct mm_struct *mm, struct vm_area_struct *vma,
+			   pmd_t *pmd, unsigned long address)
+{
+	spinlock_t *ptl;
+	pte_t entry;
+	pte_t *page_table;
+	int ret = 1;
+	/*
+	 * only usual lenear objrmap-vma can use zeropage. see vm_normal_page().
+	 */
+	if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
+		return ret;
+
+	entry = mk_pte(ZERO_PAGE(0), vma->vm_page_prot);
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_none(*page_table))
+		goto out_unlock;
+	inc_mm_counter(mm, file_rss);
+	set_pte_at(mm, address, page_table, entry);
+	update_mmu_cache(vma, address, entry);
+	ret = 0;
+out_unlock:
+	pte_unmap_unlock(page_table, ptl);
+	return ret;
+}
+
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
@@ -2631,9 +2684,12 @@ static int do_anonymous_page(struct mm_s
 	spinlock_t *ptl;
 	pte_t entry;
 
-	/* Allocate our own private page. */
 	pte_unmap(page_table);
 
+	if (unlikely(!(flags & FAULT_FLAG_WRITE)))
+		if (!do_anon_zeromap(mm, vma, pmd, address))
+			return 0;
+	/* Allocate our own private page */
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 	page = alloc_zeroed_user_highpage_movable(vma, address);
Index: zeropage-trial/mm/fremap.c
===================================================================
--- zeropage-trial.orig/mm/fremap.c
+++ zeropage-trial/mm/fremap.c
@@ -41,6 +41,9 @@ static void zap_pte(struct mm_struct *mm
 			page_cache_release(page);
 			update_hiwater_rss(mm);
 			dec_mm_counter(mm, file_rss);
+		} else if (pte_zero(pte)) {
+			update_hiwater_rss(mm);
+			dec_mm_counter(mm, file_rss);
 		}
 	} else {
 		if (!pte_file(pte))
Index: zeropage-trial/mm/rmap.c
===================================================================
--- zeropage-trial.orig/mm/rmap.c
+++ zeropage-trial/mm/rmap.c
@@ -941,7 +941,7 @@ static int try_to_unmap_cluster(unsigned
 	update_hiwater_rss(mm);
 
 	for (; address < end; pte++, address += PAGE_SIZE) {
-		if (!pte_present(*pte))
+		if (!pte_present(*pte) || pte_zero(*pte))
 			continue;
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
Index: zeropage-trial/fs/proc/task_mmu.c
===================================================================
--- zeropage-trial.orig/fs/proc/task_mmu.c
+++ zeropage-trial/fs/proc/task_mmu.c
@@ -342,7 +342,11 @@ static int smaps_pte_range(pmd_t *pmd, u
 			continue;
 
 		mss->resident += PAGE_SIZE;
-
+		if (pte_zero(ptent)) {
+			mss->shared_clean += PAGE_SIZE;
+			/* pss can be considered to be 0 */
+			continue;
+		}
 		page = vm_normal_page(vma, addr, ptent);
 		if (!page)
 			continue;
@@ -451,6 +455,10 @@ static int clear_refs_pte_range(pmd_t *p
 		if (!pte_present(ptent))
 			continue;
 
+		if (pte_zero(ptent)) {
+			ptep_test_and_clear_young(vma, addr, pte);
+			continue;
+		}
 		page = vm_normal_page(vma, addr, ptent);
 		if (!page)
 			continue;
Index: zeropage-trial/mm/mempolicy.c
===================================================================
--- zeropage-trial.orig/mm/mempolicy.c
+++ zeropage-trial/mm/mempolicy.c
@@ -404,19 +404,14 @@ static int check_pte_range(struct vm_are
 
 		if (!pte_present(*pte))
 			continue;
+		/* zero page will retrun NULL here.*/
 		page = vm_normal_page(vma, addr, *pte);
 		if (!page)
 			continue;
 		/*
 		 * The check for PageReserved here is important to avoid
-		 * handling zero pages and other pages that may have been
-		 * marked special by the system.
-		 *
-		 * If the PageReserved would not be checked here then f.e.
-		 * the location of the zero page could have an influence
-		 * on MPOL_MF_STRICT, zero pages would be counted for
-		 * the per node stats, and there would be useless attempts
-		 * to put zero pages on the migration list.
+		 * handling pages that may have been marked special by the
+		 * system.
 		 */
 		if (PageReserved(page))
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
