Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E87D06B0055
	for <linux-mm@kvack.org>; Thu, 21 May 2009 03:44:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4L7jMHi011964
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 May 2009 16:45:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 628BF45DE52
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:45:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B5EC45DE51
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:45:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 126821DB8040
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:45:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A8B0B1DB8038
	for <linux-mm@kvack.org>; Thu, 21 May 2009 16:45:18 +0900 (JST)
Date: Thu, 21 May 2009 16:43:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/2] synchrouns swap freeing without trylock.
Message-Id: <20090521164346.d188b38f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

While unmap/exiting, zap_page_range() is called and pages on page tables
and swp_entries on it are freed.

But At unmapping, all codes are under preepmt_disable and we can't call
functions which may sleep. (because of tlb_xxxx functions.)

By this limitation, free_swap_and_cache() called by zap_pte_range() uses
trylock() and this creates race-window between other swap ops. At last,
memcg has to handle this kind of "not used but exists as cache" swap entries.

This patch tries to remove trylock() for freeing SwapCache under
zap_page_range(). At freeing swap entry in page table,
"If there are no other refernce than swap cache", the function remember it
into stale_swap_buffer and free it later after exiting preempt disable state.


Maybe there are some more points to be cleaned up.
(And this patch is a little larger than I expected...)
Any comments are welcome.
Comments like "you need more explanation here." is helpful.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    8 ++
 mm/fremap.c          |   26 +++++++-
 mm/memory.c          |  126 ++++++++++++++++++++++++++++++++++++++---
 mm/shmem.c           |   27 +++++++-
 mm/swap_state.c      |   16 ++++-
 mm/swapfile.c        |  154 +++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 336 insertions(+), 21 deletions(-)

Index: mmotm-2.6.30-May17/mm/fremap.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/fremap.c
+++ mmotm-2.6.30-May17/mm/fremap.c
@@ -24,7 +24,7 @@
 #include "internal.h"
 
 static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long addr, pte_t *ptep)
+		    unsigned long addr, pte_t *ptep, swp_entry_t *swp)
 {
 	pte_t pte = *ptep;
 
@@ -43,8 +43,15 @@ static void zap_pte(struct mm_struct *mm
 			dec_mm_counter(mm, file_rss);
 		}
 	} else {
-		if (!pte_file(pte))
-			free_swap_and_cache(pte_to_swp_entry(pte));
+		if (!pte_file(pte)) {
+			if (free_swap_and_check(pte_to_swp_entry(pte)) == 1) {
+				/*
+				 * This swap entry has a swap cache and it can
+				 * be freed.
+				 */
+				*swp = pte_to_swp_entry(pte);
+			}
+		}
 		pte_clear_not_present_full(mm, addr, ptep, 0);
 	}
 }
@@ -59,13 +66,15 @@ static int install_file_pte(struct mm_st
 	int err = -ENOMEM;
 	pte_t *pte;
 	spinlock_t *ptl;
+	swp_entry_t swp;
 
+	swp.val = ~0UL;
 	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
 		goto out;
 
 	if (!pte_none(*pte))
-		zap_pte(mm, vma, addr, pte);
+		zap_pte(mm, vma, addr, pte, &swp);
 
 	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
 	/*
@@ -77,6 +86,15 @@ static int install_file_pte(struct mm_st
 	 */
 	pte_unmap_unlock(pte, ptl);
 	err = 0;
+	if (swp.val != ~0UL) {
+		struct page *page;
+
+		page = find_get_page(&swapper_space, swp.val);
+		lock_page(page);
+		try_to_free_swap(page);
+		unlock_page(page);
+		page_cache_release(page);
+	}
 out:
 	return err;
 }
Index: mmotm-2.6.30-May17/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May17.orig/include/linux/swap.h
+++ mmotm-2.6.30-May17/include/linux/swap.h
@@ -291,6 +291,7 @@ extern int add_to_swap(struct page *);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
 extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
+extern void delete_from_swap_cache_keep_swap(struct page *);
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
 extern struct page *lookup_swap_cache(swp_entry_t);
@@ -314,6 +315,9 @@ extern int swap_duplicate(swp_entry_t, i
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t, int);
 extern int free_swap_and_cache(swp_entry_t);
+extern int free_swap_and_check(swp_entry_t);
+extern void free_swap_batch(int, swp_entry_t *);
+extern int try_free_swap_and_cache_atomic(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct swap_info_struct *, pgoff_t);
@@ -382,6 +386,10 @@ static inline void show_swap_cache_info(
 #define free_swap_and_cache(swp)	is_migration_entry(swp)
 #define swap_duplicate(swp)		is_migration_entry(swp)
 
+static inline void swap_free_batch(int swaps, swp_entry_t *swaps)
+{
+}
+
 static inline void swap_free(swp_entry_t swp)
 {
 }
Index: mmotm-2.6.30-May17/mm/memory.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/memory.c
+++ mmotm-2.6.30-May17/mm/memory.c
@@ -758,10 +758,84 @@ int copy_page_range(struct mm_struct *ds
 	return ret;
 }
 
+
+/*
+ * Because we are under preempt_disable (see tlb_xxx functions), we can't call
+ * lcok_page() etc..which may sleep. At freeing swap, gatering swp_entry
+ * which seems of-no-use but has swap cache to this struct and remove them
+ * in batch. Because the condition to gather swp_entry to this bix is
+ * - There is no other swap reference. &&
+ * - There is a swap cache. &&
+ * - Page table entry was "Not Present"
+ * The number of entries which is caught in this is very small.
+ */
+#define NR_SWAP_FREE_BATCH		(63)
+struct stale_swap_buffer {
+	int nr;
+	swp_entry_t ents[NR_SWAP_FREE_BATCH];
+};
+
+#ifdef CONFIG_SWAP
+static inline void push_swap_ssb(struct stale_swap_buffer *ssb, swp_entry_t ent)
+{
+	if (!ssb)
+		return;
+	ssb->ents[ssb->nr++] = ent;
+}
+
+static inline int ssb_full(struct stale_swap_buffer *ssb)
+{
+	if (!ssb)
+		return 0;
+	return ssb->nr == NR_SWAP_FREE_BATCH;
+}
+
+static void free_stale_swaps(struct stale_swap_buffer *ssb)
+{
+	if (!ssb || !ssb->nr)
+		return;
+	free_swap_batch(ssb->nr, ssb->ents);
+	ssb->nr = 0;
+}
+
+static struct stale_swap_buffer *alloc_ssb(void)
+{
+	/*
+	 * Considering the case zap_xxx can be called as a result of OOM,
+	 * gfp_mask here should be GFP_ATOMIC. Even if we fails to allocate,
+	 * global LRU can find and remove stale swap caches in such case.
+	 */
+	return kzalloc(sizeof(struct stale_swap_buffer), GFP_ATOMIC);
+}
+static inline void free_ssb(struct stale_swap_buffer *ssb)
+{
+	kfree(ssb);
+}
+#else
+static inline void push_swap_ssb(struct stale_swap_buffer *ssb, swp_entry_t ent)
+{
+}
+static inline int ssb_full(struct stale_swap_buufer *ssb)
+{
+	return 0;
+}
+static inline void free_stale_swaps(struct stale_swap_buffer *ssb)
+{
+}
+static inline struct stale_swap_buffer *alloc_ssb(void)
+{
+	return NULL;
+}
+static inline void free_ssb(struct stale_swap_buffer *ssb)
+{
+}
+#endif
+
 static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				long *zap_work, struct zap_details *details,
+				struct stale_swap_buffer *ssb)
 {
 	struct mm_struct *mm = tlb->mm;
 	pte_t *pte;
@@ -837,8 +911,17 @@ static unsigned long zap_pte_range(struc
 		if (pte_file(ptent)) {
 			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
 				print_bad_pte(vma, addr, ptent, NULL);
-		} else if
-		  (unlikely(!free_swap_and_cache(pte_to_swp_entry(ptent))))
+		} else if (likely(ssb)) {
+			int ret = free_swap_and_check(pte_to_swp_entry(ptent));
+			if (unlikely(!ret))
+				print_bad_pte(vma, addr, ptent, NULL);
+			if (ret == 1) {
+				push_swap_ssb(ssb, pte_to_swp_entry(ptent));
+				/* need to free swaps ? */
+				if (ssb_full(ssb))
+					*zap_work = 0;
+			}
+		} else if (free_swap_and_cache(pte_to_swp_entry(ptent)))
 			print_bad_pte(vma, addr, ptent, NULL);
 		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
 	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
@@ -853,7 +936,8 @@ static unsigned long zap_pte_range(struc
 static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				long *zap_work, struct zap_details *details,
+				struct stale_swap_buffer *ssb)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -866,7 +950,7 @@ static inline unsigned long zap_pmd_rang
 			continue;
 		}
 		next = zap_pte_range(tlb, vma, pmd, addr, next,
-						zap_work, details);
+						zap_work, details, ssb);
 	} while (pmd++, addr = next, (addr != end && *zap_work > 0));
 
 	return addr;
@@ -875,7 +959,8 @@ static inline unsigned long zap_pmd_rang
 static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				long *zap_work, struct zap_details *details,
+				struct stale_swap_buffer *ssb)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -888,7 +973,7 @@ static inline unsigned long zap_pud_rang
 			continue;
 		}
 		next = zap_pmd_range(tlb, vma, pud, addr, next,
-						zap_work, details);
+						zap_work, details, ssb);
 	} while (pud++, addr = next, (addr != end && *zap_work > 0));
 
 	return addr;
@@ -897,7 +982,8 @@ static inline unsigned long zap_pud_rang
 static unsigned long unmap_page_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma,
 				unsigned long addr, unsigned long end,
-				long *zap_work, struct zap_details *details)
+				long *zap_work, struct zap_details *details,
+				struct stale_swap_buffer *ssb)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -915,7 +1001,7 @@ static unsigned long unmap_page_range(st
 			continue;
 		}
 		next = zap_pud_range(tlb, vma, pgd, addr, next,
-						zap_work, details);
+						zap_work, details, ssb);
 	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
 	tlb_end_vma(tlb, vma);
 
@@ -967,6 +1053,15 @@ unsigned long unmap_vmas(struct mmu_gath
 	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
 	int fullmm = (*tlbp)->fullmm;
 	struct mm_struct *mm = vma->vm_mm;
+	struct stale_swap_buffer *ssb = NULL;
+
+	/*
+	 * At freeing gatherd stale swap, we may sleep.In that case, we can't
+	 * handle spinlock_break. But, If !details, we don't free swap entry.
+	 * (see zap_pte_range())
+	 */
+	if (!i_mmap_lock)
+		ssb = alloc_ssb();
 
 	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
 	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
@@ -1012,7 +1107,7 @@ unsigned long unmap_vmas(struct mmu_gath
 				start = end;
 			} else
 				start = unmap_page_range(*tlbp, vma,
-						start, end, &zap_work, details);
+					 start, end, &zap_work, details, ssb);
 
 			if (zap_work > 0) {
 				BUG_ON(start != end);
@@ -1021,13 +1116,15 @@ unsigned long unmap_vmas(struct mmu_gath
 
 			tlb_finish_mmu(*tlbp, tlb_start, start);
 
-			if (need_resched() ||
+			if (need_resched() || ssb_full(ssb) ||
 				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
 				if (i_mmap_lock) {
 					*tlbp = NULL;
 					goto out;
 				}
 				cond_resched();
+				/* This call may sleep */
+				free_stale_swaps(ssb);
 			}
 
 			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
@@ -1037,6 +1134,13 @@ unsigned long unmap_vmas(struct mmu_gath
 	}
 out:
 	mmu_notifier_invalidate_range_end(mm, start_addr, end_addr);
+	/* there is stale swap cache. We may sleep and release per-cpu.*/
+	if (ssb && ssb->nr) {
+		tlb_finish_mmu(*tlbp, tlb_start, start);
+		free_stale_swaps(ssb);
+		*tlbp = tlb_gather_mmu(mm, fullmm);
+	}
+	free_ssb(ssb);
 	return start;	/* which is now the end (or restart) address */
 }
 
Index: mmotm-2.6.30-May17/mm/shmem.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/shmem.c
+++ mmotm-2.6.30-May17/mm/shmem.c
@@ -466,14 +466,22 @@ static swp_entry_t *shmem_swp_alloc(stru
  * @edir:       pointer after last entry of the directory
  * @punch_lock: pointer to spinlock when needed for the holepunch case
  */
+#define SWAP_FREE_BATCH (16)
 static int shmem_free_swp(swp_entry_t *dir, swp_entry_t *edir,
 						spinlock_t *punch_lock)
 {
 	spinlock_t *punch_unlock = NULL;
+	spinlock_t *punch_lock_saved = punch_lock;
 	swp_entry_t *ptr;
+	swp_entry_t swp[SWAP_FREE_BATCH];
 	int freed = 0;
+	int swaps;
 
-	for (ptr = dir; ptr < edir; ptr++) {
+	ptr = dir;
+again:
+	swaps = 0;
+	punch_lock = punch_lock_saved;
+	for (; swaps < SWAP_FREE_BATCH && ptr < edir; ptr++) {
 		if (ptr->val) {
 			if (unlikely(punch_lock)) {
 				punch_unlock = punch_lock;
@@ -482,13 +490,21 @@ static int shmem_free_swp(swp_entry_t *d
 				if (!ptr->val)
 					continue;
 			}
-			free_swap_and_cache(*ptr);
+			if (free_swap_and_check(*ptr) == 1)
+				swp[swaps++] = *ptr;
 			*ptr = (swp_entry_t){0};
 			freed++;
 		}
 	}
 	if (punch_unlock)
 		spin_unlock(punch_unlock);
+
+	if (swaps) {
+		/* Drop swap caches if we can */
+		free_swap_batch(swaps, swp);
+		if (ptr < edir)
+			goto again;
+	}
 	return freed;
 }
 
@@ -1065,8 +1081,10 @@ static int shmem_writepage(struct page *
 		/*
 		 * The more uptodate page coming down from a stacked
 		 * writepage should replace our old swappage.
+		 * But we can do only trylock on this. so call try_free.
 		 */
-		free_swap_and_cache(*entry);
+		if (try_free_swap_and_cache_atomic(*entry))
+			goto unmap_unlock;
 		shmem_swp_set(info, entry, 0);
 	}
 	shmem_recalc_inode(inode);
@@ -1093,11 +1111,12 @@ static int shmem_writepage(struct page *
 		}
 		return 0;
 	}
-
+unmap_unlock:
 	shmem_swp_unmap(entry);
 unlock:
 	spin_unlock(&info->lock);
 	swap_free(swap, SWAP_CACHE);
+
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)
Index: mmotm-2.6.30-May17/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swapfile.c
+++ mmotm-2.6.30-May17/mm/swapfile.c
@@ -582,6 +582,7 @@ int try_to_free_swap(struct page *page)
 /*
  * Free the swap entry like above, but also try to
  * free the page cache entry if it is the last user.
+ * Because this uses trylock, "entry" may not be freed.
  */
 int free_swap_and_cache(swp_entry_t entry)
 {
@@ -618,6 +619,159 @@ int free_swap_and_cache(swp_entry_t entr
 	return p != NULL;
 }
 
+/*
+ * Free the swap entry like above, but
+ * returns 1 if swap entry has swap cache and ready to be freed.
+ * returns 2 if swap has other references.
+ */
+int free_swap_and_check(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+	int ret = 0;
+
+	if (is_migration_entry(entry))
+		return 2;
+
+	p = swap_info_get(entry);
+	if (!p)
+		return ret;
+	if (swap_entry_free(p, entry, SWAP_MAP) == 1)
+		ret = 1;
+	else
+		ret = 2;
+	spin_unlock(&swap_lock);
+
+	return ret;
+}
+
+/*
+ * The caller must guarantee that no other one don:t increase SWAP_MAP
+ * reference at this call. This function frees a swap cache and a swap entry
+ * with guarantee that
+ *   - free swap cache and entry only when refcnt goes down to 0.
+ * returns 0 if success. returns 1 if busy.
+ */
+int try_free_swap_and_cache_atomic(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+	struct page *page;
+	int count, cache_released = 0;
+
+	page = find_get_page(&swapper_space, entry.val);
+	if (page) {
+		if (!trylock_page(page)) {
+			page_cache_release(page);
+			return 1;
+		}
+		/* Under contention ? */
+		if (!PageSwapCache(page) || PageWriteback(page)) {
+			unlock_page(page);
+			page_cache_release(page);
+			return 1;
+		}
+		count = page_swapcount(page);
+		if (count != 2) { /* SWAP_CACHE + SWAP_MAP */
+			/*
+			 * seems to have another reference. So, the caller
+			 * failed to guarantee "no extra refence" to swap.
+			 */
+			unlock_page(page);
+			page_cache_release(page);
+			return 1;
+		}
+		/* This delete_from_swap_cache doesn't drop SWAP_CACHE ref */
+		delete_from_swap_cache_keep_swap(page);
+		SetPageDirty(page);
+		unlock_page(page);
+		page_cache_release(page);
+		cache_released = 1;
+		p = swap_info_get(entry);
+	} else {
+		p = swap_info_get(entry);
+		count = p->swap_map[swp_offset(entry)];
+		if (count > 2) {
+			/*
+			 * seems to have another reference. So, the caller
+			 * failed to guarantee "no extra refence" to swap.
+			 */
+			spin_unlock(&swap_lock);
+			return 1;
+		}
+	}
+	/* Drop all refs at once */
+	swap_entry_free(p, entry, SWAP_MAP);
+	/*
+	 * Free SwapCache reference at last (this prevents to create new
+	 * swap cache to this entry).
+	 */
+	if (cache_released)
+		swap_entry_free(p, entry, SWAP_CACHE);
+	spin_unlock(&swap_lock);
+	return 0;
+}
+
+
+/*
+ * Free swap cache in syncronous way.
+ */
+#ifdef CONFIG_CGROUP_MEM_RES_CTRL
+static int check_and_wait_swap_free(swp_entry_t entry)
+{
+	int count = 0;
+	struct swap_info_struct *p;
+
+	p = swap_info_get(entry);
+	if (!p)
+		return 0;
+	count = p->swap_map[swp_offset(entry)];
+	spin_unlock(&swap_lock);
+	if (count == 1) {
+		/*
+		 * in the race window of readahead.(we'll wait in lock_page,
+		 * anyway. So, its ok to do congestion wait here.
+		 */
+		congestion_wait(READ, HZ/10);
+		return 1;
+	}
+	/*
+	 * This means there are another references to this swap.
+	 * or swap is already freed. Do nothing more.
+	 */
+	return 0;
+}
+#else
+static int check_and_wait_swap_free(swp_entry_t entry)
+{
+	return 0;
+}
+#endif
+
+/*
+ * This function is used with free_swap_and_check(). When free_swap_and_check()
+ * returns 1, there are no refence to the swap_entry and we only need to free
+ * swap cache. This function is for freeing SwapCache, not swap.
+ */
+void free_swap_batch(int swaps, swp_entry_t *ents)
+{
+	int i;
+	struct page *page;
+	swp_entry_t entry;
+
+	for (i = 0; i < swaps; i++) {
+		entry = ents[i];
+redo:
+		page = find_get_page(&swapper_space, entry.val);
+		if (likely(page)) {
+			lock_page(page);
+			/* try_to_free_swap does all necessary checks. */
+			try_to_free_swap(page);
+			unlock_page(page);
+			page_cache_release(page);
+		} else if (check_and_wait_swap_free(entry))
+				goto redo;
+	}
+}
+
 #ifdef CONFIG_HIBERNATION
 /*
  * Find the swap type that corresponds to given device (if any).
Index: mmotm-2.6.30-May17/mm/swap_state.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swap_state.c
+++ mmotm-2.6.30-May17/mm/swap_state.c
@@ -178,7 +178,7 @@ int add_to_swap(struct page *page)
  * It will never put the page into the free list,
  * the caller has a reference on the page.
  */
-void delete_from_swap_cache(struct page *page)
+static void delete_from_swap_cache_internal(struct page *page, int freeswap)
 {
 	swp_entry_t entry;
 
@@ -189,10 +189,22 @@ void delete_from_swap_cache(struct page 
 	spin_unlock_irq(&swapper_space.tree_lock);
 
 	mem_cgroup_uncharge_swapcache(page, entry);
-	swap_free(entry, SWAP_CACHE);
+	if (freeswap)
+		swap_free(entry, SWAP_CACHE);
 	page_cache_release(page);
 }
 
+void delete_from_swap_cache(struct page *page)
+{
+	delete_from_swap_cache_internal(page, 1);
+}
+
+void delete_from_swap_cache_keep_swap(struct page *page)
+{
+	delete_from_swap_cache_internal(page, 0);
+}
+
+
 /* 
  * If we are the only user, then try to free up the swap cache. 
  * 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
