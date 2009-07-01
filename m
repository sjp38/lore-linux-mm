Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 60C106B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 05:57:55 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n619xh64006089
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Jul 2009 18:59:43 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B94745DE4E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 18:59:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C9B245DD72
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 18:59:43 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FF88E08006
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 18:59:43 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 02B8AE08001
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 18:59:43 +0900 (JST)
Date: Wed, 1 Jul 2009 18:57:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] ZERO PAGE again
Message-Id: <20090701185759.18634360.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

ZERO PAGE was removed in 2.6.24 (=> http://lkml.org/lkml/2007/10/9/112)
and I had no objections.

In these days, at user support jobs, I noticed a few of customers
are making use of ZERO_PAGE intentionally...brutal mmap and scan, etc. They are
using RHEL4-5(before 2.6.18) then they don't notice that ZERO_PAGE
is gone, yet.
yes, I can say  "ZERO PAGE is gone" to them in next generation distro.

Recently, a question comes to lkml (http://lkml.org/lkml/2009/6/4/383

Maybe there are some users of ZERO_PAGE other than my customers.
So, can't we use ZERO_PAGE again ?

IIUC, the problem of ZERO_PAGE was
  - reference count cache ping-pong
  - complicated handling.
  - the behavior page-fault-twice can make applications slow.

This patch is a trial to de-refcounted ZERO_PAGE.
Any comments are welcome. I'm sorry for digging grave...

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

IIUC, ZERO_PAGE was removed in 2.6.24 because
 * refcounting against ZERO_PAGE makes performance bad
 * de-refcouning patch for ZERO_PAGE tend to be complicated and ugly.

Very long time since 2.6.24 but there are still questions to ZERO PAGE
and I find a few of my cousotmer expects ZERO_PAGE recently.

This one is a trial for re-introduce ZERO PAGE. This patch modifies
vm_normal_page(vma, address, pte) as
 * vm_normal_page(vma, address, pte, zeropage)
zeropage is a bool pointer. If ZERO_PAGE is found, vm_normal_page returns
NULL but *zeropage is set to true.

This patch doesn't modify get_user_page()/get_user_page_fast()'s page_count 
handling.  Then, ZERO_PAGE()'s refcnt can be modified when it's accessed
via gup. And, this patch doesn't have zeromap_page_range() used in /dev/zero.

mlock() uses get_user_pages() for scanning address space and finding pages.
It should handle zero page (after this.)
I think all other cases are covered as far as they use vm_normal_page().

I wonder....get_user_page() should return NULL if the page is zero page ?

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/task_mmu.c |   16 +++++++-
 include/linux/mm.h |    2 -
 mm/fremap.c        |    6 ++-
 mm/memory.c        |  103 +++++++++++++++++++++++++++++++++++++++++++++--------
 mm/mempolicy.c     |    7 ++-
 mm/mlock.c         |    7 +++
 mm/rmap.c          |    6 ++-
 7 files changed, 125 insertions(+), 22 deletions(-)

Index: mmotm-2.6.31-Jun25/mm/memory.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/mm/memory.c
+++ mmotm-2.6.31-Jun25/mm/memory.c
@@ -482,14 +482,16 @@ static inline int is_cow_mapping(unsigne
  * advantage is that we don't have to follow the strict linearity rule of
  * PFNMAP mappings in order to support COWable mappings.
  *
+ * If we found ZERO_PAGE, NULL is retuned and an argument "zeropage" is set
+ * to true.
  */
 #ifdef __HAVE_ARCH_PTE_SPECIAL
 # define HAVE_PTE_SPECIAL 1
 #else
 # define HAVE_PTE_SPECIAL 0
 #endif
-struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-				pte_t pte)
+static struct page *
+__vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
 	unsigned long pfn = pte_pfn(pte);
 
@@ -532,6 +534,21 @@ out:
 	return pfn_to_page(pfn);
 }
 
+struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
+			    pte_t pte, bool *zeropage)
+{
+	struct page *page;
+
+	*zeropage = false;
+	page = __vm_normal_page(vma, addr, pte);
+	if (page == ZERO_PAGE(0)) {
+		*zeropage = true;
+		return NULL;
+	}
+	return page;
+}
+
+
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
@@ -546,6 +563,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
 	struct page *page;
+	bool zerocheck;
 
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
@@ -592,12 +610,13 @@ copy_one_pte(struct mm_struct *dst_mm, s
 		pte = pte_mkclean(pte);
 	pte = pte_mkold(pte);
 
-	page = vm_normal_page(vma, addr, pte);
+	page = vm_normal_page(vma, addr, pte, &zerocheck);
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page, vma, addr);
 		rss[!!PageAnon(page)]++;
-	}
+	} else if (zerocheck)/* no refcnt, no rmap, but increase file rss */
+		rss[0]++;
 
 out_set_pte:
 	set_pte_at(dst_mm, addr, dst_pte, pte);
@@ -768,6 +787,7 @@ static unsigned long zap_pte_range(struc
 	spinlock_t *ptl;
 	int file_rss = 0;
 	int anon_rss = 0;
+	bool zc;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -783,7 +803,7 @@ static unsigned long zap_pte_range(struc
 		if (pte_present(ptent)) {
 			struct page *page;
 
-			page = vm_normal_page(vma, addr, ptent);
+			page = vm_normal_page(vma, addr, ptent, &zc);
 			if (unlikely(details) && page) {
 				/*
 				 * unmap_shared_mapping_pages() wants to
@@ -805,6 +825,11 @@ static unsigned long zap_pte_range(struc
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
 							tlb->fullmm);
 			tlb_remove_tlb_entry(tlb, pte, addr);
+
+			if (unlikely(zc)) {
+				file_rss--;
+				continue;
+			}
 			if (unlikely(!page))
 				continue;
 			if (unlikely(details) && details->nonlinear_vma
@@ -1100,6 +1125,7 @@ struct page *follow_page(struct vm_area_
 	spinlock_t *ptl;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
+	bool zc;
 
 	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
 	if (!IS_ERR(page)) {
@@ -1141,9 +1167,11 @@ struct page *follow_page(struct vm_area_
 		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;
-	page = vm_normal_page(vma, address, pte);
-	if (unlikely(!page))
+	page = vm_normal_page(vma, address, pte, &zc);
+	if (unlikely(!page && !zc))
 		goto bad_page;
+	if (zc)
+		page = ZERO_PAGE(0);
 
 	if (flags & FOLL_GET)
 		get_page(page);
@@ -1156,7 +1184,8 @@ struct page *follow_page(struct vm_area_
 		 * is needed to avoid losing the dirty bit: it is easier to use
 		 * mark_page_accessed().
 		 */
-		mark_page_accessed(page);
+		if (!zc)
+			mark_page_accessed(page);
 	}
 unlock:
 	pte_unmap_unlock(ptep, ptl);
@@ -1259,7 +1288,12 @@ int __get_user_pages(struct task_struct 
 				return i ? : -EFAULT;
 			}
 			if (pages) {
-				struct page *page = vm_normal_page(gate_vma, start, *pte);
+				bool zc;
+				struct page *page;
+				page = vm_normal_page(gate_vma, start,
+						      *pte, &zc);
+				if (zc)
+					page = ZERO_PAGE(0);
 				pages[i] = page;
 				if (page)
 					get_page(page);
@@ -1954,8 +1988,16 @@ static int do_wp_page(struct mm_struct *
 	int reuse = 0, ret = 0;
 	int page_mkwrite = 0;
 	struct page *dirty_page = NULL;
+	bool zc;
+	gfp_t gfpflags = GFP_HIGHUSER_MOVABLE;
 
-	old_page = vm_normal_page(vma, address, orig_pte);
+	old_page = vm_normal_page(vma, address, orig_pte, &zc);
+	/* If zero page, we don't have to copy...*/
+	if (unlikely(zc)) {
+		/* zc == true but oldpage is null under here */
+		gfpflags |= __GFP_ZERO;
+		goto gotten;
+	}
 	if (!old_page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case
@@ -2075,8 +2117,8 @@ gotten:
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
-	VM_BUG_ON(old_page == ZERO_PAGE(0));
-	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+
+	new_page = alloc_page_vma(gfpflags, vma, address);
 	if (!new_page)
 		goto oom;
 	/*
@@ -2088,7 +2130,8 @@ gotten:
 		clear_page_mlock(old_page);
 		unlock_page(old_page);
 	}
-	cow_user_page(new_page, old_page, address, vma);
+	if (!zc)
+		cow_user_page(new_page, old_page, address, vma);
 	__SetPageUptodate(new_page);
 
 	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
@@ -2104,8 +2147,11 @@ gotten:
 				dec_mm_counter(mm, file_rss);
 				inc_mm_counter(mm, anon_rss);
 			}
-		} else
+		} else {
+			if (zc)
+				dec_mm_counter(mm, file_rss);
 			inc_mm_counter(mm, anon_rss);
+		}
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2612,6 +2658,31 @@ out_page:
 	return ret;
 }
 
+static int anon_map_zeropage(struct mm_struct *mm, struct vm_area_struct *vma,
+			     pmd_t *pmd, unsigned long address)
+{
+	struct page *page;
+	spinlock_t *ptl;
+	pte_t entry;
+	pte_t *page_table;
+	int ret = 1;
+
+	page = ZERO_PAGE(0);
+	entry = mk_pte(page, vma->vm_page_prot);
+	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (!pte_none(*page_table))
+		goto out_unlock;
+	inc_mm_counter(mm, file_rss);
+	set_pte_at(mm, address, page_table, entry);
+	/* No need to invalidate entry...it was not present here. */
+	update_mmu_cache(vma, address, entry);
+	ret = 0;
+out_unlock:
+	pte_unmap_unlock(page_table, ptl);
+	return ret;
+}
+
+
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
@@ -2630,6 +2701,10 @@ static int do_anonymous_page(struct mm_s
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
+	if (unlikely(!(flags & FAULT_FLAG_WRITE))) {
+		if (!anon_map_zeropage(mm, vma, pmd, address))
+			return 0;
+	}
 	page = alloc_zeroed_user_highpage_movable(vma, address);
 	if (!page)
 		goto oom;
Index: mmotm-2.6.31-Jun25/mm/fremap.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/mm/fremap.c
+++ mmotm-2.6.31-Jun25/mm/fremap.c
@@ -27,13 +27,14 @@ static void zap_pte(struct mm_struct *mm
 			unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = *ptep;
+	bool zc;
 
 	if (pte_present(pte)) {
 		struct page *page;
 
 		flush_cache_page(vma, addr, pte_pfn(pte));
 		pte = ptep_clear_flush(vma, addr, ptep);
-		page = vm_normal_page(vma, addr, pte);
+		page = vm_normal_page(vma, addr, pte, &zc);
 		if (page) {
 			if (pte_dirty(pte))
 				set_page_dirty(page);
@@ -41,6 +42,9 @@ static void zap_pte(struct mm_struct *mm
 			page_cache_release(page);
 			update_hiwater_rss(mm);
 			dec_mm_counter(mm, file_rss);
+		} else if (zc) {
+			update_hiwater_rss(mm);
+			dec_mm_counter(mm, file_rss);
 		}
 	} else {
 		if (!pte_file(pte))
Index: mmotm-2.6.31-Jun25/mm/rmap.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/mm/rmap.c
+++ mmotm-2.6.31-Jun25/mm/rmap.c
@@ -941,9 +941,13 @@ static int try_to_unmap_cluster(unsigned
 	update_hiwater_rss(mm);
 
 	for (; address < end; pte++, address += PAGE_SIZE) {
+		bool zc;
+
 		if (!pte_present(*pte))
 			continue;
-		page = vm_normal_page(vma, address, *pte);
+		page = vm_normal_page(vma, address, *pte, &zc);
+		if (zc)
+			continue;
 		BUG_ON(!page || PageAnon(page));
 
 		if (locked_vma) {
Index: mmotm-2.6.31-Jun25/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.31-Jun25/fs/proc/task_mmu.c
@@ -347,6 +347,7 @@ static int smaps_pte_range(pmd_t *pmd, u
 	spinlock_t *ptl;
 	struct page *page;
 	int mapcount;
+	bool zc;
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
@@ -362,7 +363,13 @@ static int smaps_pte_range(pmd_t *pmd, u
 
 		mss->resident += PAGE_SIZE;
 
-		page = vm_normal_page(vma, addr, ptent);
+		page = vm_normal_page(vma, addr, ptent, &zc);
+		if (zc) {
+			if (pte_young(ptent))
+				mss->referenced += PAGE_SIZE;
+			mss->shared_clean += PAGE_SIZE;
+			/* don't increase mss->pss */
+		}
 		if (!page)
 			continue;
 
@@ -463,6 +470,7 @@ static int clear_refs_pte_range(pmd_t *p
 	pte_t *pte, ptent;
 	spinlock_t *ptl;
 	struct page *page;
+	bool zc;
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
@@ -470,7 +478,11 @@ static int clear_refs_pte_range(pmd_t *p
 		if (!pte_present(ptent))
 			continue;
 
-		page = vm_normal_page(vma, addr, ptent);
+		page = vm_normal_page(vma, addr, ptent, &zc);
+		if (zc) {
+			ptep_test_and_clear_young(vma, addr, pte);
+			continue;
+		}
 		if (!page)
 			continue;
 
Index: mmotm-2.6.31-Jun25/mm/mempolicy.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/mm/mempolicy.c
+++ mmotm-2.6.31-Jun25/mm/mempolicy.c
@@ -401,16 +401,17 @@ static int check_pte_range(struct vm_are
 	do {
 		struct page *page;
 		int nid;
+		bool zc;
 
 		if (!pte_present(*pte))
 			continue;
-		page = vm_normal_page(vma, addr, *pte);
+		page = vm_normal_page(vma, addr, *pte, &zc);
 		if (!page)
 			continue;
 		/*
 		 * The check for PageReserved here is important to avoid
-		 * handling zero pages and other pages that may have been
-		 * marked special by the system.
+		 * handling pages that may have been marked special by the
+		 * system.
 		 *
 		 * If the PageReserved would not be checked here then f.e.
 		 * the location of the zero page could have an influence
Index: mmotm-2.6.31-Jun25/include/linux/mm.h
===================================================================
--- mmotm-2.6.31-Jun25.orig/include/linux/mm.h
+++ mmotm-2.6.31-Jun25/include/linux/mm.h
@@ -753,7 +753,7 @@ struct zap_details {
 };
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
-		pte_t pte);
+			    pte_t pte, bool *zeropage);
 
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
Index: mmotm-2.6.31-Jun25/mm/mlock.c
===================================================================
--- mmotm-2.6.31-Jun25.orig/mm/mlock.c
+++ mmotm-2.6.31-Jun25/mm/mlock.c
@@ -220,6 +220,13 @@ static long __mlock_vma_pages_range(stru
 		for (i = 0; i < ret; i++) {
 			struct page *page = pages[i];
 
+			/* we don't lock zero page...*/
+			if (page == ZERO_PAGE(0)) {
+				put_page(page);
+				addr += PAGE_SIZE;
+				nr_pages--;
+				continue;
+			}
 			lock_page(page);
 			/*
 			 * Because we lock page here and migration is blocked

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
