Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 21DE86B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:41:51 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hi2so290733wib.2
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:41:50 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id f18si9934424wic.90.2014.10.20.15.41.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 15:41:49 -0700 (PDT)
Message-Id: <20141020222841.302891540@infradead.org>
Date: Mon, 20 Oct 2014 23:56:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 2/6] mm: Prepare for FAULT_FLAG_SPECULATIVE
References: <20141020215633.717315139@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-mm-pte_map_lock.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

When speculating faults (without holding mmap_sem) we need to validate
that the vma against which we loaded pages is still valid when we're
ready to install the new PTE.

Therefore, replace the pte_offset_map_lock() calls that (re)take the
PTL with pte_map_lock() which can fail in case we find the VMA changed
since we started the fault.

Instead of passing around the endless list of function arguments,
replace the lot with a single structure so we can change context
without endless function signature changes.

XXX: split this patch into two parts, the first which introduces
fault_env and the second doing the pte_map_lock bit.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/linux/mm.h |   17 -
 mm/memory.c        |  522 +++++++++++++++++++++++++++++------------------------
 2 files changed, 297 insertions(+), 242 deletions(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -187,14 +187,15 @@ extern unsigned int kobjsize(const void
  */
 extern pgprot_t protection_map[16];
 
-#define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
-#define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
-#define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
-#define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
-#define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
-#define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
-#define FAULT_FLAG_TRIED	0x40	/* second try */
-#define FAULT_FLAG_USER		0x80	/* The fault originated in userspace */
+#define FAULT_FLAG_WRITE	0x001	/* Fault was a write access */
+#define FAULT_FLAG_NONLINEAR	0x002	/* Fault was via a nonlinear mapping */
+#define FAULT_FLAG_MKWRITE	0x004	/* Fault was mkwrite of existing pte */
+#define FAULT_FLAG_ALLOW_RETRY	0x008	/* Retry fault if blocking */
+#define FAULT_FLAG_RETRY_NOWAIT	0x010	/* Don't drop mmap_sem and wait when retrying */
+#define FAULT_FLAG_KILLABLE	0x020	/* The fault task is in SIGKILL killable region */
+#define FAULT_FLAG_TRIED	0x040	/* second try */
+#define FAULT_FLAG_USER		0x080	/* The fault originated in userspace */
+#define FAULT_FLAG_SPECULATIVE	0x100	/* Speculative fault, not holding mmap_sem */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1993,6 +1993,23 @@ static int do_page_mkwrite(struct vm_are
 	return ret;
 }
 
+struct fault_env {
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	unsigned long address;
+	pmd_t *pmd;
+	pte_t *pte;
+	pte_t entry;
+	spinlock_t *ptl;
+	unsigned int flags;
+};
+
+static bool pte_map_lock(struct fault_env *fe)
+{
+	fe->pte = pte_offset_map_lock(fe->mm, fe->pmd, fe->address, &fe->ptl);
+	return true;
+}
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -2011,9 +2028,7 @@ static int do_page_mkwrite(struct vm_are
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte)
+static int do_wp_page(struct fault_env *fe)
 	__releases(ptl)
 {
 	struct page *old_page, *new_page = NULL;
@@ -2025,7 +2040,7 @@ static int do_wp_page(struct mm_struct *
 	unsigned long mmun_end = 0;	/* For mmu_notifiers */
 	struct mem_cgroup *memcg;
 
-	old_page = vm_normal_page(vma, address, orig_pte);
+	old_page = vm_normal_page(fe->vma, fe->address, fe->entry);
 	if (!old_page) {
 		/*
 		 * VM_MIXEDMAP !pfn_valid() case
@@ -2034,7 +2049,7 @@ static int do_wp_page(struct mm_struct *
 		 * Just mark the pages writable as we can't do any dirty
 		 * accounting on raw pfn maps.
 		 */
-		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+		if ((fe->vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
 			goto reuse;
 		goto gotten;
@@ -2047,14 +2062,20 @@ static int do_wp_page(struct mm_struct *
 	if (PageAnon(old_page) && !PageKsm(old_page)) {
 		if (!trylock_page(old_page)) {
 			page_cache_get(old_page);
-			pte_unmap_unlock(page_table, ptl);
+			pte_unmap_unlock(fe->pte, fe->ptl);
 			lock_page(old_page);
-			page_table = pte_offset_map_lock(mm, pmd, address,
-							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
+
+			if (!pte_map_lock(fe)) {
+				unlock_page(old_page);
+				ret |= VM_FAULT_RETRY;
+				goto err;
+			}
+
+			if (!pte_same(*fe->pte, fe->entry)) {
 				unlock_page(old_page);
 				goto unlock;
 			}
+
 			page_cache_release(old_page);
 		}
 		if (reuse_swap_page(old_page)) {
@@ -2063,37 +2084,44 @@ static int do_wp_page(struct mm_struct *
 			 * the rmap code will not search our parent or siblings.
 			 * Protected against the rmap code by the page lock.
 			 */
-			page_move_anon_rmap(old_page, vma, address);
+			page_move_anon_rmap(old_page, fe->vma, fe->address);
 			unlock_page(old_page);
 			goto reuse;
 		}
 		unlock_page(old_page);
-	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
+	} else if (unlikely((fe->vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {
 		/*
 		 * Only catch write-faults on shared writable pages,
 		 * read-only shared pages can get COWed by
 		 * get_user_pages(.write=1, .force=1).
 		 */
-		if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+		if (fe->vma->vm_ops && fe->vma->vm_ops->page_mkwrite) {
 			int tmp;
+
 			page_cache_get(old_page);
-			pte_unmap_unlock(page_table, ptl);
-			tmp = do_page_mkwrite(vma, old_page, address);
+			pte_unmap_unlock(fe->pte, fe->ptl);
+			tmp = do_page_mkwrite(fe->vma, old_page, fe->address);
 			if (unlikely(!tmp || (tmp &
 					(VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 				page_cache_release(old_page);
 				return tmp;
 			}
+
 			/*
 			 * Since we dropped the lock we need to revalidate
 			 * the PTE as someone else may have changed it.  If
 			 * they did, we just return, as we can count on the
 			 * MMU to tell us if they didn't also make it writable.
 			 */
-			page_table = pte_offset_map_lock(mm, pmd, address,
-							 &ptl);
-			if (!pte_same(*page_table, orig_pte)) {
+
+			if (!pte_map_lock(fe)) {
+				unlock_page(old_page);
+				ret |= VM_FAULT_RETRY;
+				goto err;
+			}
+
+			if (!pte_same(*fe->pte, fe->entry)) {
 				unlock_page(old_page);
 				goto unlock;
 			}
@@ -2112,12 +2140,12 @@ static int do_wp_page(struct mm_struct *
 		if (old_page)
 			page_cpupid_xchg_last(old_page, (1 << LAST_CPUPID_SHIFT) - 1);
 
-		flush_cache_page(vma, address, pte_pfn(orig_pte));
-		entry = pte_mkyoung(orig_pte);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		if (ptep_set_access_flags(vma, address, page_table, entry,1))
-			update_mmu_cache(vma, address, page_table);
-		pte_unmap_unlock(page_table, ptl);
+		flush_cache_page(fe->vma, fe->address, pte_pfn(fe->entry));
+		entry = pte_mkyoung(fe->entry);
+		entry = maybe_mkwrite(pte_mkdirty(entry), fe->vma);
+		if (ptep_set_access_flags(fe->vma, fe->address, fe->pte, entry, 1))
+			update_mmu_cache(fe->vma, fe->address, fe->pte);
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		ret |= VM_FAULT_WRITE;
 
 		if (!dirty_page)
@@ -2135,8 +2163,8 @@ static int do_wp_page(struct mm_struct *
 			wait_on_page_locked(dirty_page);
 			set_page_dirty_balance(dirty_page);
 			/* file_update_time outside page_lock */
-			if (vma->vm_file)
-				file_update_time(vma->vm_file);
+			if (fe->vma->vm_file)
+				file_update_time(fe->vma->vm_file);
 		}
 		put_page(dirty_page);
 		if (page_mkwrite) {
@@ -2145,7 +2173,7 @@ static int do_wp_page(struct mm_struct *
 			set_page_dirty(dirty_page);
 			unlock_page(dirty_page);
 			page_cache_release(dirty_page);
-			if (mapping)	{
+			if (mapping) {
 				/*
 				 * Some device drivers do not set page.mapping
 				 * but still dirty their pages
@@ -2162,62 +2190,68 @@ static int do_wp_page(struct mm_struct *
 	 */
 	page_cache_get(old_page);
 gotten:
-	pte_unmap_unlock(page_table, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 
-	if (unlikely(anon_vma_prepare(vma)))
+	if (unlikely(anon_vma_prepare(fe->vma)))
 		goto oom;
 
-	if (is_zero_pfn(pte_pfn(orig_pte))) {
-		new_page = alloc_zeroed_user_highpage_movable(vma, address);
+	if (is_zero_pfn(pte_pfn(fe->entry))) {
+		new_page = alloc_zeroed_user_highpage_movable(fe->vma, fe->address);
 		if (!new_page)
 			goto oom;
 	} else {
-		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, fe->vma, fe->address);
 		if (!new_page)
 			goto oom;
-		cow_user_page(new_page, old_page, address, vma);
+		cow_user_page(new_page, old_page, fe->address, fe->vma);
 	}
 	__SetPageUptodate(new_page);
 
-	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg))
+	if (mem_cgroup_try_charge(new_page, fe->mm, GFP_KERNEL, &memcg))
 		goto oom_free_new;
 
-	mmun_start  = address & PAGE_MASK;
+	mmun_start  = fe->address & PAGE_MASK;
 	mmun_end    = mmun_start + PAGE_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+	mmu_notifier_invalidate_range_start(fe->mm, mmun_start, mmun_end);
 
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (likely(pte_same(*page_table, orig_pte))) {
+	if (!pte_map_lock(fe)) {
+		mem_cgroup_cancel_charge(new_page, memcg);
+		page_cache_release(new_page);
+		ret |= VM_FAULT_RETRY;
+		goto err;
+	}
+
+	if (likely(pte_same(*fe->pte, fe->entry))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
-				dec_mm_counter_fast(mm, MM_FILEPAGES);
-				inc_mm_counter_fast(mm, MM_ANONPAGES);
+				dec_mm_counter_fast(fe->mm, MM_FILEPAGES);
+				inc_mm_counter_fast(fe->mm, MM_ANONPAGES);
 			}
 		} else
-			inc_mm_counter_fast(mm, MM_ANONPAGES);
-		flush_cache_page(vma, address, pte_pfn(orig_pte));
-		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			inc_mm_counter_fast(fe->mm, MM_ANONPAGES);
+		flush_cache_page(fe->vma, fe->address, pte_pfn(fe->entry));
+		entry = mk_pte(new_page, fe->vma->vm_page_prot);
+		entry = maybe_mkwrite(pte_mkdirty(entry), fe->vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush(vma, address, page_table);
-		page_add_new_anon_rmap(new_page, vma, address);
+		ptep_clear_flush(fe->vma, fe->address, fe->pte);
+		page_add_new_anon_rmap(new_page, fe->vma, fe->address);
 		mem_cgroup_commit_charge(new_page, memcg, false);
-		lru_cache_add_active_or_unevictable(new_page, vma);
+		lru_cache_add_active_or_unevictable(new_page, fe->vma);
 		/*
 		 * We call the notify macro here because, when using secondary
 		 * mmu page tables (such as kvm shadow page tables), we want the
 		 * new page to be mapped directly into the secondary page table.
 		 */
-		set_pte_at_notify(mm, address, page_table, entry);
-		update_mmu_cache(vma, address, page_table);
+		set_pte_at_notify(fe->mm, fe->address, fe->pte, entry);
+		update_mmu_cache(fe->vma, fe->address, fe->pte);
 		if (old_page) {
 			/*
 			 * Only after switching the pte to the new page may
@@ -2253,15 +2287,16 @@ static int do_wp_page(struct mm_struct *
 	if (new_page)
 		page_cache_release(new_page);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	if (mmun_end > mmun_start)
-		mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
+		mmu_notifier_invalidate_range_end(fe->mm, mmun_start, mmun_end);
+err:
 	if (old_page) {
 		/*
 		 * Don't let another task, with possibly unlocked vma,
 		 * keep the mlocked page.
 		 */
-		if ((ret & VM_FAULT_WRITE) && (vma->vm_flags & VM_LOCKED)) {
+		if ((ret & VM_FAULT_WRITE) && (fe->vma->vm_flags & VM_LOCKED)) {
 			lock_page(old_page);	/* LRU manipulation */
 			munlock_vma_page(old_page);
 			unlock_page(old_page);
@@ -2269,6 +2304,7 @@ static int do_wp_page(struct mm_struct *
 		page_cache_release(old_page);
 	}
 	return ret;
+
 oom_free_new:
 	page_cache_release(new_page);
 oom:
@@ -2381,27 +2417,24 @@ EXPORT_SYMBOL(unmap_mapping_range);
  * We return with the mmap_sem locked or unlocked in the same cases
  * as does filemap_fault().
  */
-static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+static int do_swap_page(struct fault_env *fe)
 {
-	spinlock_t *ptl;
 	struct page *page, *swapcache;
 	struct mem_cgroup *memcg;
 	swp_entry_t entry;
-	pte_t *page_table, pte;
+	pte_t pte;
 	int locked;
 	int exclusive = 0;
 	int ret = 0;
 
-	entry = pte_to_swp_entry(orig_pte);
+	entry = pte_to_swp_entry(fe->entry);
 	if (unlikely(non_swap_entry(entry))) {
 		if (is_migration_entry(entry)) {
-			migration_entry_wait(mm, pmd, address);
+			migration_entry_wait(fe->mm, fe->pmd, fe->address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
 		} else {
-			print_bad_pte(vma, address, orig_pte, NULL);
+			print_bad_pte(fe->vma, fe->address, fe->entry, NULL);
 			ret = VM_FAULT_SIGBUS;
 		}
 		goto out;
@@ -2410,14 +2443,16 @@ static int do_swap_page(struct mm_struct
 	page = lookup_swap_cache(entry);
 	if (!page) {
 		page = swapin_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vma, address);
+				GFP_HIGHUSER_MOVABLE, fe->vma, fe->address);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-			if (likely(pte_same(*page_table, orig_pte)))
+			if (!pte_map_lock(fe))
+				return VM_FAULT_RETRY;
+
+			if (likely(pte_same(*fe->pte, fe->entry)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 			goto unlock;
@@ -2426,7 +2461,7 @@ static int do_swap_page(struct mm_struct
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
-		mem_cgroup_count_vm_event(mm, PGMAJFAULT);
+		mem_cgroup_count_vm_event(fe->mm, PGMAJFAULT);
 	} else if (PageHWPoison(page)) {
 		/*
 		 * hwpoisoned dirty swapcache pages are kept for killing
@@ -2439,7 +2474,7 @@ static int do_swap_page(struct mm_struct
 	}
 
 	swapcache = page;
-	locked = lock_page_or_retry(page, mm, flags);
+	locked = lock_page_or_retry(page, fe->mm, fe->flags);
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
 	if (!locked) {
@@ -2456,14 +2491,14 @@ static int do_swap_page(struct mm_struct
 	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
 		goto out_page;
 
-	page = ksm_might_need_to_copy(page, vma, address);
+	page = ksm_might_need_to_copy(page, fe->vma, fe->address);
 	if (unlikely(!page)) {
 		ret = VM_FAULT_OOM;
 		page = swapcache;
 		goto out_page;
 	}
 
-	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg)) {
+	if (mem_cgroup_try_charge(page, fe->mm, GFP_KERNEL, &memcg)) {
 		ret = VM_FAULT_OOM;
 		goto out_page;
 	}
@@ -2471,8 +2506,12 @@ static int do_swap_page(struct mm_struct
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*page_table, orig_pte)))
+	if (!pte_map_lock(fe)) {
+		ret = VM_FAULT_RETRY;
+		goto out_charge;
+	}
+
+	if (unlikely(!pte_same(*fe->pte, fe->entry)))
 		goto out_nomap;
 
 	if (unlikely(!PageUptodate(page))) {
@@ -2490,30 +2529,30 @@ static int do_swap_page(struct mm_struct
 	 * must be called after the swap_free(), or it will never succeed.
 	 */
 
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	dec_mm_counter_fast(mm, MM_SWAPENTS);
-	pte = mk_pte(page, vma->vm_page_prot);
-	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
-		flags &= ~FAULT_FLAG_WRITE;
+	inc_mm_counter_fast(fe->mm, MM_ANONPAGES);
+	dec_mm_counter_fast(fe->mm, MM_SWAPENTS);
+	pte = mk_pte(page, fe->vma->vm_page_prot);
+	if ((fe->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
+		pte = maybe_mkwrite(pte_mkdirty(pte), fe->vma);
+		fe->flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = 1;
 	}
-	flush_icache_page(vma, page);
-	if (pte_swp_soft_dirty(orig_pte))
+	flush_icache_page(fe->vma, page);
+	if (pte_swp_soft_dirty(fe->entry))
 		pte = pte_mksoft_dirty(pte);
-	set_pte_at(mm, address, page_table, pte);
+	set_pte_at(fe->mm, fe->address, fe->pte, pte);
 	if (page == swapcache) {
-		do_page_add_anon_rmap(page, vma, address, exclusive);
+		do_page_add_anon_rmap(page, fe->vma, fe->address, exclusive);
 		mem_cgroup_commit_charge(page, memcg, true);
 	} else { /* ksm created a completely new copy */
-		page_add_new_anon_rmap(page, vma, address);
+		page_add_new_anon_rmap(page, fe->vma, fe->address);
 		mem_cgroup_commit_charge(page, memcg, false);
-		lru_cache_add_active_or_unevictable(page, vma);
+		lru_cache_add_active_or_unevictable(page, fe->vma);
 	}
 
 	swap_free(entry);
-	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+	if (vm_swap_full() || (fe->vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
 	if (page != swapcache) {
@@ -2529,22 +2568,23 @@ static int do_swap_page(struct mm_struct
 		page_cache_release(swapcache);
 	}
 
-	if (flags & FAULT_FLAG_WRITE) {
-		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
+	if (fe->flags & FAULT_FLAG_WRITE) {
+		ret |= do_wp_page(fe);
 		if (ret & VM_FAULT_ERROR)
 			ret &= VM_FAULT_ERROR;
 		goto out;
 	}
 
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, address, page_table);
+	update_mmu_cache(fe->vma, fe->address, fe->pte);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 out:
 	return ret;
 out_nomap:
+	pte_unmap_unlock(fe->pte, fe->ptl);
+out_charge:
 	mem_cgroup_cancel_charge(page, memcg);
-	pte_unmap_unlock(page_table, ptl);
 out_page:
 	unlock_page(page);
 out_release:
@@ -2595,33 +2635,34 @@ static inline int check_stack_guard_page
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		unsigned int flags)
+static int do_anonymous_page(struct fault_env *fe)
 {
 	struct mem_cgroup *memcg;
 	struct page *page;
-	spinlock_t *ptl;
-	pte_t entry, *page_table;
+	pte_t entry;
 
 	/* Check if we need to add a guard page to the stack */
-	if (check_stack_guard_page(vma, address) < 0)
+	if (check_stack_guard_page(fe->vma, fe->address) < 0)
 		return VM_FAULT_SIGBUS;
 
 	/* Use the zero-page for reads */
-	if (!(flags & FAULT_FLAG_WRITE)) {
-		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
-						vma->vm_page_prot));
-		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-		if (!pte_none(*page_table))
+	if (!(fe->flags & FAULT_FLAG_WRITE)) {
+		entry = pte_mkspecial(pfn_pte(my_zero_pfn(fe->address),
+					fe->vma->vm_page_prot));
+
+		if (!pte_map_lock(fe))
+			return VM_FAULT_RETRY;
+
+		if (!pte_none(*fe->pte))
 			goto unlock;
+
 		goto setpte;
 	}
 
 	/* Allocate our own private page. */
-	if (unlikely(anon_vma_prepare(vma)))
+	if (unlikely(anon_vma_prepare(fe->vma)))
 		goto oom;
-	page = alloc_zeroed_user_highpage_movable(vma, address);
+	page = alloc_zeroed_user_highpage_movable(fe->vma, fe->address);
 	if (!page)
 		goto oom;
 	/*
@@ -2631,28 +2672,33 @@ static int do_anonymous_page(struct mm_s
 	 */
 	__SetPageUptodate(page);
 
-	if (mem_cgroup_try_charge(page, mm, GFP_KERNEL, &memcg))
+	if (mem_cgroup_try_charge(page, fe->mm, GFP_KERNEL, &memcg))
 		goto oom_free_page;
 
-	entry = mk_pte(page, vma->vm_page_prot);
-	if (vma->vm_flags & VM_WRITE)
+	entry = mk_pte(page, fe->vma->vm_page_prot);
+	if (fe->vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_none(*page_table))
+	if (!pte_map_lock(fe)) {
+		mem_cgroup_cancel_charge(page, memcg);
+		page_cache_release(page);
+		return VM_FAULT_RETRY;
+	}
+
+	if (!pte_none(*fe->pte))
 		goto release;
 
-	inc_mm_counter_fast(mm, MM_ANONPAGES);
-	page_add_new_anon_rmap(page, vma, address);
+	inc_mm_counter_fast(fe->mm, MM_ANONPAGES);
+	page_add_new_anon_rmap(page, fe->vma, fe->address);
 	mem_cgroup_commit_charge(page, memcg, false);
-	lru_cache_add_active_or_unevictable(page, vma);
+	lru_cache_add_active_or_unevictable(page, fe->vma);
 setpte:
-	set_pte_at(mm, address, page_table, entry);
+	set_pte_at(fe->mm, fe->address, fe->pte, entry);
 
 	/* No need to invalidate - it was non-present before */
-	update_mmu_cache(vma, address, page_table);
+	update_mmu_cache(fe->vma, fe->address, fe->pte);
 unlock:
-	pte_unmap_unlock(page_table, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	return 0;
 release:
 	mem_cgroup_cancel_charge(page, memcg);
@@ -2688,7 +2734,7 @@ static int __do_fault(struct vm_area_str
 		if (ret & VM_FAULT_LOCKED)
 			unlock_page(vmf.page);
 		page_cache_release(vmf.page);
-		return VM_FAULT_HWPOISON;
+		return ret | VM_FAULT_HWPOISON;
 	}
 
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
@@ -2846,13 +2892,9 @@ static void do_fault_around(struct vm_ar
 	vma->vm_ops->map_pages(vma, &vmf);
 }
 
-static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+static int do_read_fault(struct fault_env *fe, pgoff_t pgoff)
 {
 	struct page *fault_page;
-	spinlock_t *ptl;
-	pte_t *pte;
 	int ret = 0;
 
 	/*
@@ -2860,73 +2902,86 @@ static int do_read_fault(struct mm_struc
 	 * if page by the offset is not ready to be mapped (cold cache or
 	 * something).
 	 */
-	if (vma->vm_ops->map_pages && !(flags & FAULT_FLAG_NONLINEAR) &&
+	if (fe->vma->vm_ops->map_pages && !(fe->flags & FAULT_FLAG_NONLINEAR) &&
 	    fault_around_bytes >> PAGE_SHIFT > 1) {
-		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-		do_fault_around(vma, address, pte, pgoff, flags);
-		if (!pte_same(*pte, orig_pte))
+
+		if (!pte_map_lock(fe))
+			return VM_FAULT_RETRY;
+
+		do_fault_around(fe->vma, fe->address, fe->pte, pgoff, fe->flags);
+		if (!pte_same(*fe->pte, fe->entry))
 			goto unlock_out;
-		pte_unmap_unlock(pte, ptl);
+
+		pte_unmap_unlock(fe->pte, fe->ptl);
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(fe->vma, fe->address, pgoff, fe->flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	if (!pte_map_lock(fe)) {
+		unlock_page(fault_page);
+		page_cache_release(fault_page);
+		return VM_FAULT_RETRY;
+	}
+
+	if (unlikely(!pte_same(*fe->pte, fe->entry))) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		unlock_page(fault_page);
 		page_cache_release(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, false, false);
+
+	do_set_pte(fe->vma, fe->address, fault_page, fe->pte, false, false);
 	unlock_page(fault_page);
 unlock_out:
-	pte_unmap_unlock(pte, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	return ret;
 }
 
-static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+static int do_cow_fault(struct fault_env *fe, pgoff_t pgoff)
 {
 	struct page *fault_page, *new_page;
 	struct mem_cgroup *memcg;
-	spinlock_t *ptl;
-	pte_t *pte;
 	int ret;
 
-	if (unlikely(anon_vma_prepare(vma)))
+	if (unlikely(anon_vma_prepare(fe->vma)))
 		return VM_FAULT_OOM;
 
-	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, fe->vma, fe->address);
 	if (!new_page)
 		return VM_FAULT_OOM;
 
-	if (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg)) {
+	if (mem_cgroup_try_charge(new_page, fe->mm, GFP_KERNEL, &memcg)) {
 		page_cache_release(new_page);
 		return VM_FAULT_OOM;
 	}
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(fe->vma, fe->address, pgoff, fe->flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		goto uncharge_out;
 
-	copy_user_highpage(new_page, fault_page, address, vma);
+	copy_user_highpage(new_page, fault_page, fe->address, fe->vma);
 	__SetPageUptodate(new_page);
 
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	if (!pte_map_lock(fe)) {
+		unlock_page(fault_page);
+		page_cache_release(fault_page);
+		ret |= VM_FAULT_RETRY;
+		goto uncharge_out;
+	}
+
+	if (unlikely(!pte_same(*fe->pte, fe->entry))) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		unlock_page(fault_page);
 		page_cache_release(fault_page);
 		goto uncharge_out;
 	}
-	do_set_pte(vma, address, new_page, pte, true, true);
+
+	do_set_pte(fe->vma, fe->address, new_page, fe->pte, true, true);
 	mem_cgroup_commit_charge(new_page, memcg, false);
-	lru_cache_add_active_or_unevictable(new_page, vma);
-	pte_unmap_unlock(pte, ptl);
+	lru_cache_add_active_or_unevictable(new_page, fe->vma);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	unlock_page(fault_page);
 	page_cache_release(fault_page);
 	return ret;
@@ -2936,18 +2991,14 @@ static int do_cow_fault(struct mm_struct
 	return ret;
 }
 
-static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+static int do_shared_fault(struct fault_env *fe, pgoff_t pgoff)
 {
 	struct page *fault_page;
 	struct address_space *mapping;
-	spinlock_t *ptl;
-	pte_t *pte;
 	int dirtied = 0;
 	int ret, tmp;
 
-	ret = __do_fault(vma, address, pgoff, flags, &fault_page);
+	ret = __do_fault(fe->vma, fe->address, pgoff, fe->flags, &fault_page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
@@ -2955,31 +3006,35 @@ static int do_shared_fault(struct mm_str
 	 * Check if the backing address space wants to know that the page is
 	 * about to become writable
 	 */
-	if (vma->vm_ops->page_mkwrite) {
+	if (fe->vma->vm_ops->page_mkwrite) {
 		unlock_page(fault_page);
-		tmp = do_page_mkwrite(vma, fault_page, address);
-		if (unlikely(!tmp ||
-				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+		tmp = do_page_mkwrite(fe->vma, fault_page, fe->address);
+		if (unlikely(!tmp || (tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
 			page_cache_release(fault_page);
 			return tmp;
 		}
 	}
 
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, orig_pte))) {
-		pte_unmap_unlock(pte, ptl);
+	if (!pte_map_lock(fe)) {
+		unlock_page(fault_page);
+		page_cache_release(fault_page);
+		return ret | VM_FAULT_RETRY;
+	}
+
+	if (unlikely(!pte_same(*fe->pte, fe->entry))) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		unlock_page(fault_page);
 		page_cache_release(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, true, false);
-	pte_unmap_unlock(pte, ptl);
+	do_set_pte(fe->vma, fe->address, fault_page, fe->pte, true, false);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 
 	if (set_page_dirty(fault_page))
 		dirtied = 1;
 	mapping = fault_page->mapping;
 	unlock_page(fault_page);
-	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
+	if ((dirtied || fe->vma->vm_ops->page_mkwrite) && mapping) {
 		/*
 		 * Some device drivers do not set page.mapping but still
 		 * dirty their pages
@@ -2988,8 +3043,8 @@ static int do_shared_fault(struct mm_str
 	}
 
 	/* file_update_time outside page_lock */
-	if (vma->vm_file && !vma->vm_ops->page_mkwrite)
-		file_update_time(vma->vm_file);
+	if (fe->vma->vm_file && !fe->vma->vm_ops->page_mkwrite)
+		file_update_time(fe->vma->vm_file);
 
 	return ret;
 }
@@ -3000,20 +3055,16 @@ static int do_shared_fault(struct mm_str
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
-{
-	pgoff_t pgoff = (((address & PAGE_MASK)
-			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-
-	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+static int do_linear_fault(struct fault_env *fe)
+{
+	pgoff_t pgoff = (((fe->address & PAGE_MASK) -
+			 fe->vma->vm_start) >> PAGE_SHIFT) + fe->vma->vm_pgoff;
+
+	if (!(fe->flags & FAULT_FLAG_WRITE))
+		return do_read_fault(fe, pgoff);
+	if (!(fe->vma->vm_flags & VM_SHARED))
+		return do_cow_fault(fe, pgoff);
+	return do_shared_fault(fe, pgoff);
 }
 
 /*
@@ -3027,30 +3078,26 @@ static int do_linear_fault(struct mm_str
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
+static int do_nonlinear_fault(struct fault_env *fe)
 {
 	pgoff_t pgoff;
 
-	flags |= FAULT_FLAG_NONLINEAR;
+	fe->flags |= FAULT_FLAG_NONLINEAR;
 
-	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
+	if (unlikely(!(fe->vma->vm_flags & VM_NONLINEAR))) {
 		/*
 		 * Page table corrupted: show pte and kill process.
 		 */
-		print_bad_pte(vma, address, orig_pte, NULL);
+		print_bad_pte(fe->vma, fe->address, fe->entry, NULL);
 		return VM_FAULT_SIGBUS;
 	}
 
-	pgoff = pte_to_pgoff(orig_pte);
-	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	pgoff = pte_to_pgoff(fe->entry);
+	if (!(fe->flags & FAULT_FLAG_WRITE))
+		return do_read_fault(fe, pgoff);
+	if (!(fe->vma->vm_flags & VM_SHARED))
+		return do_cow_fault(fe, pgoff);
+	return do_shared_fault(fe, pgoff);
 }
 
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
@@ -3068,17 +3115,16 @@ static int numa_migrate_prep(struct page
 	return mpol_misplaced(page, vma, addr);
 }
 
-static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		   unsigned long addr, pte_t pte, pmd_t *pmd)
+static int do_numa_page(struct fault_env *fe)
 {
 	struct page *page = NULL;
-	spinlock_t *ptl;
 	int page_nid = -1;
 	int last_cpupid;
 	int target_nid;
 	bool migrated = false;
 	int flags = 0;
-	pte_t *ptep;
+	int ret = 0;
+	pte_t entry;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3089,19 +3135,23 @@ static int do_numa_page(struct mm_struct
 	* the _PAGE_NUMA bit and it is not really expected that there
 	* would be concurrent hardware modifications to the PTE.
 	*/
-	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	if (unlikely(!pte_same(*ptep, pte))) {
-		pte_unmap_unlock(ptep, ptl);
+	if (!pte_map_lock(fe)) {
+		ret |= VM_FAULT_RETRY;
+		goto out;
+	}
+
+	if (unlikely(!pte_same(*fe->pte, fe->entry))) {
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		goto out;
 	}
 
-	pte = pte_mknonnuma(pte);
-	set_pte_at(mm, addr, ptep, pte);
-	update_mmu_cache(vma, addr, ptep);
+	entry = pte_mknonnuma(fe->entry);
+	set_pte_at(fe->mm, fe->address, fe->pte, entry);
+	update_mmu_cache(fe->vma, fe->address, fe->pte);
 
-	page = vm_normal_page(vma, addr, pte);
+	page = vm_normal_page(fe->vma, fe->address, entry);
 	if (!page) {
-		pte_unmap_unlock(ptep, ptl);
+		pte_unmap_unlock(fe->pte, fe->ptl);
 		return 0;
 	}
 	BUG_ON(is_zero_pfn(page_to_pfn(page)));
@@ -3111,27 +3161,28 @@ static int do_numa_page(struct mm_struct
 	 * in general, RO pages shouldn't hurt as much anyway since
 	 * they can be in shared cache state.
 	 */
-	if (!pte_write(pte))
+	if (!pte_write(entry))
 		flags |= TNF_NO_GROUP;
 
 	/*
 	 * Flag if the page is shared between multiple address spaces. This
 	 * is later used when determining whether to group tasks together
 	 */
-	if (page_mapcount(page) > 1 && (vma->vm_flags & VM_SHARED))
+	if (page_mapcount(page) > 1 && (fe->vma->vm_flags & VM_SHARED))
 		flags |= TNF_SHARED;
 
 	last_cpupid = page_cpupid_last(page);
 	page_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, addr, page_nid, &flags);
-	pte_unmap_unlock(ptep, ptl);
+	target_nid = numa_migrate_prep(page, fe->vma, fe->address, page_nid, &flags);
+	pte_unmap_unlock(fe->pte, fe->ptl);
+
 	if (target_nid == -1) {
 		put_page(page);
 		goto out;
 	}
 
 	/* Migrate to the requested node */
-	migrated = migrate_misplaced_page(page, vma, target_nid);
+	migrated = migrate_misplaced_page(page, fe->vma, target_nid);
 	if (migrated) {
 		page_nid = target_nid;
 		flags |= TNF_MIGRATED;
@@ -3159,45 +3210,38 @@ static int do_numa_page(struct mm_struct
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int handle_pte_fault(struct mm_struct *mm,
-		     struct vm_area_struct *vma, unsigned long address,
-		     pte_t entry, pmd_t *pmd, unsigned int flags)
+static int handle_pte_fault(struct fault_env *fe)
 {
-	spinlock_t *ptl;
-	pte_t *pte;
+	pte_t entry = fe->entry;
 
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
-			if (vma->vm_ops) {
-				if (likely(vma->vm_ops->fault))
-					return do_linear_fault(mm, vma, address,
-						pmd, flags, entry);
+			if (fe->vma->vm_ops) {
+				if (likely(fe->vma->vm_ops->fault))
+					return do_linear_fault(fe);
 			}
-			return do_anonymous_page(mm, vma, address,
-						 pmd, flags);
+			return do_anonymous_page(fe);
 		}
 		if (pte_file(entry))
-			return do_nonlinear_fault(mm, vma, address,
-					pmd, flags, entry);
-		return do_swap_page(mm, vma, address,
-					pmd, flags, entry);
+			return do_nonlinear_fault(fe);
+		return do_swap_page(fe);
 	}
 
 	if (pte_numa(entry))
-		return do_numa_page(mm, vma, address, entry, pmd);
-
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (unlikely(!pte_same(*pte, entry)))
+		return do_numa_page(fe);
+	if (!pte_map_lock(fe))
+		return VM_FAULT_RETRY;
+	if (unlikely(!pte_same(*fe->pte, entry)))
 		goto unlock;
-	if (flags & FAULT_FLAG_WRITE) {
+	if (fe->flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
-			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, entry);
+			return do_wp_page(fe);
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	if (ptep_set_access_flags(vma, address, pte, entry, flags & FAULT_FLAG_WRITE)) {
-		update_mmu_cache(vma, address, pte);
+	if (ptep_set_access_flags(fe->vma, fe->address, fe->pte,
+				entry, fe->flags & FAULT_FLAG_WRITE)) {
+		update_mmu_cache(fe->vma, fe->address, fe->pte);
 	} else {
 		/*
 		 * This is needed only for protection faults but the arch code
@@ -3205,11 +3249,11 @@ static int handle_pte_fault(struct mm_st
 		 * This still avoids useless tlb flushes for .text page faults
 		 * with threads.
 		 */
-		if (flags & FAULT_FLAG_WRITE)
-			flush_tlb_fix_spurious_fault(vma, address);
+		if (fe->flags & FAULT_FLAG_WRITE)
+			flush_tlb_fix_spurious_fault(fe->vma, fe->address);
 	}
 unlock:
-	pte_unmap_unlock(pte, ptl);
+	pte_unmap_unlock(fe->pte, fe->ptl);
 	return 0;
 }
 
@@ -3222,6 +3266,7 @@ static int handle_pte_fault(struct mm_st
 static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			     unsigned long address, unsigned int flags)
 {
+	struct fault_env fe;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -3298,7 +3343,16 @@ static int __handle_mm_fault(struct mm_s
 	entry = ACCESS_ONCE(*pte);
 	pte_unmap(pte);
 
-	return handle_pte_fault(mm, vma, address, entry, pmd, flags);
+	fe = (struct fault_env) {
+		.mm = mm,
+		.vma = vma,
+		.address = address,
+		.entry = entry,
+		.pmd = pmd,
+		.flags = flags,
+	};
+
+	return handle_pte_fault(&fe);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
