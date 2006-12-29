Received: from sd0112e0.au.ibm.com (d23rh903.au.ibm.com [202.81.18.201])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kBTAMmht308100
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:22:48 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0112e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBTACWE7085848
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:12:35 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBTA920j019171
	for <linux-mm@kvack.org>; Fri, 29 Dec 2006 21:09:03 +1100
From: Balbir Singh <balbir@in.ibm.com>
Date: Fri, 29 Dec 2006 15:39:00 +0530
Message-Id: <20061229100900.13860.21399.sendpatchset@balbir.in.ibm.com>
In-Reply-To: <20061229100839.13860.15525.sendpatchset@balbir.in.ibm.com>
References: <20061229100839.13860.15525.sendpatchset@balbir.in.ibm.com>
Subject: [RFC][PATCH 2/3] Move RSS accounting to page_xxxx_rmap() functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com, akpm@osdl.org, andyw@uk.ibm.com
Cc: linux-mm@kvack.org, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>


The accounting of RSS is moved from several places to the rmap functions
page_add_anon_rmap(), page_add_new_anon_rmap(), page_add_file_rmap()
and page_remove_rmap().



Signed-off-by: Balbir Singh <balbir@in.ibm.com>
---

 fs/exec.c            |    1 -
 include/linux/rmap.h |    8 ++++++--
 mm/filemap_xip.c     |    1 -
 mm/fremap.c          |   10 ++++------
 mm/memory.c          |   50 ++++++++++----------------------------------------
 mm/migrate.c         |    2 +-
 mm/rmap.c            |   17 ++++++++++-------
 mm/swapfile.c        |    1 -
 8 files changed, 31 insertions(+), 59 deletions(-)

diff -puN include/linux/rmap.h~move-accounting-to-rmap include/linux/rmap.h
--- linux-2.6.20-rc2/include/linux/rmap.h~move-accounting-to-rmap	2006-12-29 14:48:28.000000000 +0530
+++ linux-2.6.20-rc2-balbir/include/linux/rmap.h	2006-12-29 14:48:28.000000000 +0530
@@ -89,7 +89,7 @@ void __anon_vma_link(struct vm_area_stru
  */
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
-void page_add_file_rmap(struct page *);
+void page_add_file_rmap(struct page *, struct mm_struct *);
 void page_remove_rmap(struct page *, struct vm_area_struct *);
 
 /**
@@ -99,10 +99,14 @@ void page_remove_rmap(struct page *, str
  * For copy_page_range only: minimal extract from page_add_rmap,
  * avoiding unnecessary tests (already checked) so it's quicker.
  */
-static inline void page_dup_rmap(struct page *page)
+static inline void page_dup_rmap(struct page *page, struct mm_struct *mm)
 {
 	page_map_lock(page);
 	page_mapcount_inc(page);
+	if (PageAnon(page))
+		inc_mm_counter(mm, anon_rss);
+	else
+		inc_mm_counter(mm, file_rss);
 	page_map_unlock(page);
 }
 
diff -puN mm/rmap.c~move-accounting-to-rmap mm/rmap.c
--- linux-2.6.20-rc2/mm/rmap.c~move-accounting-to-rmap	2006-12-29 14:48:28.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/rmap.c	2006-12-29 14:48:28.000000000 +0530
@@ -544,6 +544,7 @@ void page_add_anon_rmap(struct page *pag
 	page_map_lock(page);
 	if (page_mapcount_inc_and_test(page))
 		__page_set_anon_rmap(page, vma, address);
+	inc_mm_counter(vma->vm_mm, anon_rss);
 	page_map_unlock(page);
 }
 
@@ -562,6 +563,7 @@ void page_add_new_anon_rmap(struct page 
 	page_map_lock(page);
 	page_mapcount_set(page, 0); /* elevate count by 1 (starts at -1) */
 	__page_set_anon_rmap(page, vma, address);
+	inc_mm_counter(vma->vm_mm, anon_rss);
 	page_map_unlock(page);
 }
 
@@ -571,11 +573,12 @@ void page_add_new_anon_rmap(struct page 
  *
  * The caller needs to hold the pte lock.
  */
-void page_add_file_rmap(struct page *page)
+void page_add_file_rmap(struct page *page, struct mm_struct *mm)
 {
 	page_map_lock(page);
 	if (page_mapcount_inc_and_test(page))
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
+	inc_mm_counter(mm, file_rss);
 	page_map_unlock(page);
 }
 
@@ -587,6 +590,7 @@ void page_add_file_rmap(struct page *pag
  */
 void page_remove_rmap(struct page *page, struct vm_area_struct *vma)
 {
+	int anon = PageAnon(page);
 	page_map_lock(page);
 	if (page_mapcount_add_negative(-1, page)) {
 		if (unlikely(page_mapcount(page) < 0)) {
@@ -615,8 +619,12 @@ void page_remove_rmap(struct page *page,
 		if (page_test_and_clear_dirty(page))
 			set_page_dirty(page);
 		__dec_zone_page_state(page,
-				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
+				anon ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
+	if (anon)
+		dec_mm_counter(vma->vm_mm, anon_rss);
+	else
+		dec_mm_counter(vma->vm_mm, file_rss);
 	page_map_unlock(page);
 }
 
@@ -679,7 +687,6 @@ static int try_to_unmap_one(struct page 
 					list_add(&mm->mmlist, &init_mm.mmlist);
 				spin_unlock(&mmlist_lock);
 			}
-			dec_mm_counter(mm, anon_rss);
 #ifdef CONFIG_MIGRATION
 		} else {
 			/*
@@ -700,10 +707,7 @@ static int try_to_unmap_one(struct page 
 		swp_entry_t entry;
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
-	} else
 #endif
-		dec_mm_counter(mm, file_rss);
-
 
 	page_remove_rmap(page, vma);
 	page_cache_release(page);
@@ -797,7 +801,6 @@ static void try_to_unmap_cluster(unsigne
 
 		page_remove_rmap(page, vma);
 		page_cache_release(page);
-		dec_mm_counter(mm, file_rss);
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
diff -puN fs/exec.c~move-accounting-to-rmap fs/exec.c
--- linux-2.6.20-rc2/fs/exec.c~move-accounting-to-rmap	2006-12-29 14:48:28.000000000 +0530
+++ linux-2.6.20-rc2-balbir/fs/exec.c	2006-12-29 14:48:28.000000000 +0530
@@ -321,7 +321,6 @@ void install_arg_page(struct vm_area_str
 		pte_unmap_unlock(pte, ptl);
 		goto out;
 	}
-	inc_mm_counter(mm, anon_rss);
 	lru_cache_add_active(page);
 	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
diff -puN mm/mremap.c~move-accounting-to-rmap mm/mremap.c
diff -puN mm/memory.c~move-accounting-to-rmap mm/memory.c
--- linux-2.6.20-rc2/mm/memory.c~move-accounting-to-rmap	2006-12-29 14:48:28.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/memory.c	2006-12-29 14:48:28.000000000 +0530
@@ -335,14 +335,6 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	return 0;
 }
 
-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
-{
-	if (file_rss)
-		add_mm_counter(mm, file_rss, file_rss);
-	if (anon_rss)
-		add_mm_counter(mm, anon_rss, anon_rss);
-}
-
 /*
  * This function is called to print an error when a bad pte
  * is found. For example, we might have a PFN-mapped pte in
@@ -427,7 +419,7 @@ struct page *vm_normal_page(struct vm_ar
 static inline void
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
-		unsigned long addr, int *rss)
+		unsigned long addr)
 {
 	unsigned long vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
@@ -481,8 +473,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page);
-		rss[!!PageAnon(page)]++;
+		page_dup_rmap(page, dst_mm);
 	}
 
 out_set_pte:
@@ -496,10 +487,8 @@ static int copy_pte_range(struct mm_stru
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
 	int progress = 0;
-	int rss[2];
 
 again:
-	rss[1] = rss[0] = 0;
 	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
 	if (!dst_pte)
 		return -ENOMEM;
@@ -524,14 +513,13 @@ again:
 			progress++;
 			continue;
 		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr);
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
 	arch_leave_lazy_mmu_mode();
 	spin_unlock(src_ptl);
 	pte_unmap_nested(src_pte - 1);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
 	pte_unmap_unlock(dst_pte - 1, dst_ptl);
 	cond_resched();
 	if (addr != end)
@@ -626,8 +614,6 @@ static unsigned long zap_pte_range(struc
 	struct mm_struct *mm = tlb->mm;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int file_rss = 0;
-	int anon_rss = 0;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -672,14 +658,11 @@ static unsigned long zap_pte_range(struc
 						addr) != page->index)
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
-			if (PageAnon(page))
-				anon_rss--;
-			else {
+			if (!PageAnon(page)) {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent))
 					mark_page_accessed(page);
-				file_rss--;
 			}
 			page_remove_rmap(page, vma);
 			tlb_remove_page(tlb, page);
@@ -696,7 +679,6 @@ static unsigned long zap_pte_range(struc
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
 
-	add_mm_rss(mm, file_rss, anon_rss);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 
@@ -1126,8 +1108,7 @@ static int zeromap_pte_range(struct mm_s
 			break;
 		}
 		page_cache_get(page);
-		page_add_file_rmap(page);
-		inc_mm_counter(mm, file_rss);
+		page_add_file_rmap(page, mm);
 		set_pte_at(mm, addr, pte, zero_pte);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
@@ -1233,8 +1214,7 @@ static int insert_page(struct mm_struct 
 
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
-	inc_mm_counter(mm, file_rss);
-	page_add_file_rmap(page);
+	page_add_file_rmap(page, mm);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
 	retval = 0;
@@ -1585,14 +1565,9 @@ gotten:
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (likely(pte_same(*page_table, orig_pte))) {
-		if (old_page) {
+		if (old_page)
 			page_remove_rmap(old_page, vma);
-			if (!PageAnon(old_page)) {
-				dec_mm_counter(mm, file_rss);
-				inc_mm_counter(mm, anon_rss);
-			}
-		} else
-			inc_mm_counter(mm, anon_rss);
+
 		flush_cache_page(vma, address, pte_pfn(orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
@@ -2038,7 +2013,6 @@ static int do_swap_page(struct mm_struct
 
 	/* The page isn't present yet, go ahead with the fault. */
 
-	inc_mm_counter(mm, anon_rss);
 	pte = mk_pte(page, vma->vm_page_prot);
 	if (write_access && can_share_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
@@ -2104,7 +2078,6 @@ static int do_anonymous_page(struct mm_s
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto release;
-		inc_mm_counter(mm, anon_rss);
 		lru_cache_add_active(page);
 		page_add_new_anon_rmap(page, vma, address);
 	} else {
@@ -2117,8 +2090,7 @@ static int do_anonymous_page(struct mm_s
 		spin_lock(ptl);
 		if (!pte_none(*page_table))
 			goto release;
-		inc_mm_counter(mm, file_rss);
-		page_add_file_rmap(page);
+		page_add_file_rmap(page, mm);
 	}
 
 	set_pte_at(mm, address, page_table, entry);
@@ -2251,12 +2223,10 @@ retry:
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
-			inc_mm_counter(mm, anon_rss);
 			lru_cache_add_active(new_page);
 			page_add_new_anon_rmap(new_page, vma, address);
 		} else {
-			inc_mm_counter(mm, file_rss);
-			page_add_file_rmap(new_page);
+			page_add_file_rmap(new_page, mm);
 			if (write_access) {
 				dirty_page = new_page;
 				get_page(dirty_page);
diff -puN mm/swapfile.c~move-accounting-to-rmap mm/swapfile.c
--- linux-2.6.20-rc2/mm/swapfile.c~move-accounting-to-rmap	2006-12-29 14:48:28.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/swapfile.c	2006-12-29 14:48:28.000000000 +0530
@@ -503,7 +503,6 @@ unsigned int count_swap_pages(int type, 
 static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
 		unsigned long addr, swp_entry_t entry, struct page *page)
 {
-	inc_mm_counter(vma->vm_mm, anon_rss);
 	get_page(page);
 	set_pte_at(vma->vm_mm, addr, pte,
 		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
diff -puN mm/filemap_xip.c~move-accounting-to-rmap mm/filemap_xip.c
--- linux-2.6.20-rc2/mm/filemap_xip.c~move-accounting-to-rmap	2006-12-29 14:48:28.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/filemap_xip.c	2006-12-29 14:48:28.000000000 +0530
@@ -190,7 +190,6 @@ __xip_unmap (struct address_space * mapp
 			flush_cache_page(vma, address, pte_pfn(*pte));
 			pteval = ptep_clear_flush(vma, address, pte);
 			page_remove_rmap(page, vma);
-			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
 			page_cache_release(page);
diff -puN mm/fremap.c~move-accounting-to-rmap mm/fremap.c
--- linux-2.6.20-rc2/mm/fremap.c~move-accounting-to-rmap	2006-12-29 14:48:28.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/fremap.c	2006-12-29 14:48:28.000000000 +0530
@@ -75,13 +75,13 @@ int install_page(struct mm_struct *mm, s
 	if (page_mapcount(page) > INT_MAX/2)
 		goto unlock;
 
-	if (pte_none(*pte) || !zap_pte(mm, vma, addr, pte))
-		inc_mm_counter(mm, file_rss);
+	if (!pte_none(*pte))
+		zap_pte(mm, vma, addr, pte);
 
 	flush_icache_page(vma, page);
 	pte_val = mk_pte(page, prot);
 	set_pte_at(mm, addr, pte, pte_val);
-	page_add_file_rmap(page);
+	page_add_file_rmap(page, mm);
 	update_mmu_cache(vma, addr, pte_val);
 	lazy_mmu_prot_update(pte_val);
 	err = 0;
@@ -107,10 +107,8 @@ int install_file_pte(struct mm_struct *m
 	if (!pte)
 		goto out;
 
-	if (!pte_none(*pte) && zap_pte(mm, vma, addr, pte)) {
+	if (!pte_none(*pte) && zap_pte(mm, vma, addr, pte))
 		update_hiwater_rss(mm);
-		dec_mm_counter(mm, file_rss);
-	}
 
 	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
 	/*
diff -puN mm/migrate.c~move-accounting-to-rmap mm/migrate.c
--- linux-2.6.20-rc2/mm/migrate.c~move-accounting-to-rmap	2006-12-29 14:48:28.000000000 +0530
+++ linux-2.6.20-rc2-balbir/mm/migrate.c	2006-12-29 14:48:28.000000000 +0530
@@ -177,7 +177,7 @@ static void remove_migration_pte(struct 
 	if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr);
 	else
-		page_add_file_rmap(new);
+		page_add_file_rmap(new, mm);
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, pte);
_

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
