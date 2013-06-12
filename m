Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 9B9F46B003C
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 00:23:26 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc8so9279207pbc.18
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 21:23:25 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 7/8] vrange: Add method to purge volatile ranges
Date: Tue, 11 Jun 2013 21:22:50 -0700
Message-Id: <1371010971-15647-8-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch adds discarding function to purge volatile ranges under
memory pressure. Logic is as following:

1. Memory pressure happens
2. VM start to reclaim pages
3. Check the page is in volatile range.
4. If so, zap the page from the process's page table.
   (By semantic vrange(2), we should mark it with another one to
    make page fault when you try to access the address. It will
    be introduced later patch)
5. If page is unmapped from all processes, discard it instead of swapping.

This patch does not address the case where there is no swap, which
keeps anonymous pages from being aged off the LRUs. Minchan has
additional patches that add support for purging anonymous pages

XXX: First pass at file purging. Seems to work, but is likely broken
and needs close review.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dgiani@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[jstultz: Reworked to add purging of file pages, commit log tweaks]
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/rmap.h   |  12 +-
 include/linux/swap.h   |   1 +
 include/linux/vrange.h |   7 ++
 mm/ksm.c               |   2 +-
 mm/rmap.c              |  30 +++--
 mm/swapfile.c          |  36 ++++++
 mm/vmscan.c            |  16 ++-
 mm/vrange.c            | 332 +++++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 420 insertions(+), 16 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 6dacb93..6432dfb 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -83,6 +83,8 @@ enum ttu_flags {
 };
 
 #ifdef CONFIG_MMU
+unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
+
 static inline void get_anon_vma(struct anon_vma *anon_vma)
 {
 	atomic_inc(&anon_vma->refcount);
@@ -182,9 +184,11 @@ static inline void page_dup_rmap(struct page *page)
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+			struct mem_cgroup *memcg, unsigned long *vm_flags,
+			int *is_vrange);
 int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
+	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags,
+	int *is_vrange);
 
 #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
 
@@ -249,9 +253,11 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *memcg,
-				  unsigned long *vm_flags)
+				  unsigned long *vm_flags,
+				  int *is_vrange)
 {
 	*vm_flags = 0;
+	*is_vrange = 0;
 	return 0;
 }
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1701ce4..5907936 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -383,6 +383,7 @@ extern int swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
 extern void swap_free(swp_entry_t);
 extern void swapcache_free(swp_entry_t, struct page *page);
+extern int __free_swap_and_cache(swp_entry_t);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index a97ac25..cbb609a 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -37,6 +37,10 @@ extern int vrange_clear(struct vrange_root *vroot,
 extern void vrange_root_cleanup(struct vrange_root *vroot);
 extern int vrange_fork(struct mm_struct *new,
 					struct mm_struct *old);
+int discard_vpage(struct page *page);
+bool vrange_address(struct mm_struct *mm, unsigned long start,
+			unsigned long end);
+
 #else
 
 static inline void vrange_init(void) {};
@@ -47,5 +51,8 @@ static inline int vrange_fork(struct mm_struct *new, struct mm_struct *old)
 	return 0;
 }
 
+static inline bool vrange_address(struct mm_struct *mm, unsigned long start,
+		unsigned long end) { return false; };
+static inline int discard_vpage(struct page *page) { return 0 };
 #endif
 #endif /* _LINIUX_VRANGE_H */
diff --git a/mm/ksm.c b/mm/ksm.c
index b6afe0c..debc20c 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1932,7 +1932,7 @@ again:
 				continue;
 
 			referenced += page_referenced_one(page, vma,
-				rmap_item->address, &mapcount, vm_flags);
+				rmap_item->address, &mapcount, vm_flags, NULL);
 			if (!search_new_forks || !mapcount)
 				break;
 		}
diff --git a/mm/rmap.c b/mm/rmap.c
index 6280da8..5522522 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -57,6 +57,8 @@
 #include <linux/migrate.h>
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
+#include <linux/vrange.h>
+#include <linux/rmap.h>
 
 #include <asm/tlbflush.h>
 
@@ -523,8 +525,7 @@ __vma_address(struct page *page, struct vm_area_struct *vma)
 	return vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 }
 
-inline unsigned long
-vma_address(struct page *page, struct vm_area_struct *vma)
+unsigned long vma_address(struct page *page, struct vm_area_struct *vma)
 {
 	unsigned long address = __vma_address(page, vma);
 
@@ -662,7 +663,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
  */
 int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+			unsigned long *vm_flags, int *is_vrange)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int referenced = 0;
@@ -724,6 +725,9 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 				referenced++;
 		}
 		pte_unmap_unlock(pte, ptl);
+		if (is_vrange &&
+			vrange_address(mm, address, address + PAGE_SIZE - 1))
+			*is_vrange = 1;
 	}
 
 	(*mapcount)--;
@@ -736,7 +740,8 @@ out:
 
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags,
+				int *is_vrange)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -761,7 +766,7 @@ static int page_referenced_anon(struct page *page,
 		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 			continue;
 		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
+					&mapcount, vm_flags, is_vrange);
 		if (!mapcount)
 			break;
 	}
@@ -785,7 +790,9 @@ static int page_referenced_anon(struct page *page,
  */
 static int page_referenced_file(struct page *page,
 				struct mem_cgroup *memcg,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags,
+				int *is_vrange)
+
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -826,7 +833,8 @@ static int page_referenced_file(struct page *page,
 		if (memcg && !mm_match_cgroup(vma->vm_mm, memcg))
 			continue;
 		referenced += page_referenced_one(page, vma, address,
-						  &mapcount, vm_flags);
+							&mapcount, vm_flags,
+							is_vrange);
 		if (!mapcount)
 			break;
 	}
@@ -841,6 +849,7 @@ static int page_referenced_file(struct page *page,
  * @is_locked: caller holds lock on the page
  * @memcg: target memory cgroup
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @is_vrange: the page in vrange of some process
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
@@ -848,7 +857,8 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *memcg,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags,
+		    int *is_vrange)
 {
 	int referenced = 0;
 	int we_locked = 0;
@@ -867,10 +877,10 @@ int page_referenced(struct page *page,
 								vm_flags);
 		else if (PageAnon(page))
 			referenced += page_referenced_anon(page, memcg,
-								vm_flags);
+							vm_flags, is_vrange);
 		else if (page->mapping)
 			referenced += page_referenced_file(page, memcg,
-								vm_flags);
+							vm_flags, is_vrange);
 		if (we_locked)
 			unlock_page(page);
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6c340d9..d41c63f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -734,6 +734,42 @@ int try_to_free_swap(struct page *page)
 }
 
 /*
+ * It's almost same with free_swap_and_cache except page is already
+ * locked.
+ */
+int __free_swap_and_cache(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+	struct page *page = NULL;
+
+	if (non_swap_entry(entry))
+		return 1;
+
+	p = swap_info_get(entry);
+	if (p) {
+		if (swap_entry_free(p, entry, 1) == SWAP_HAS_CACHE) {
+			page = find_get_page(swap_address_space(entry),
+						entry.val);
+		}
+		spin_unlock(&swap_lock);
+	}
+
+	if (page) {
+		/*
+		 * Not mapped elsewhere, or swap space full? Free it!
+		 * Also recheck PageSwapCache now page is locked (above).
+		 */
+		if (PageSwapCache(page) && !PageWriteback(page) &&
+				(!page_mapped(page) || vm_swap_full())) {
+			delete_from_swap_cache(page);
+			SetPageDirty(page);
+		}
+		page_cache_release(page);
+	}
+	return p != NULL;
+}
+
+/*
  * Free the swap entry like above, but also try to
  * free the page cache entry if it is the last user.
  */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..c75e0ac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -43,6 +43,7 @@
 #include <linux/sysctl.h>
 #include <linux/oom.h>
 #include <linux/prefetch.h>
+#include <linux/vrange.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -611,6 +612,7 @@ enum page_references {
 	PAGEREF_RECLAIM,
 	PAGEREF_RECLAIM_CLEAN,
 	PAGEREF_KEEP,
+	PAGEREF_DISCARD,
 	PAGEREF_ACTIVATE,
 };
 
@@ -619,9 +621,10 @@ static enum page_references page_check_references(struct page *page,
 {
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
+	int is_vrange = 0;
 
 	referenced_ptes = page_referenced(page, 1, sc->target_mem_cgroup,
-					  &vm_flags);
+					  &vm_flags, &is_vrange);
 	referenced_page = TestClearPageReferenced(page);
 
 	/*
@@ -631,6 +634,12 @@ static enum page_references page_check_references(struct page *page,
 	if (vm_flags & VM_LOCKED)
 		return PAGEREF_RECLAIM;
 
+	/*
+	 * Bail out if the page is in vrange and try to discard.
+	 */
+	if (is_vrange)
+		return PAGEREF_DISCARD;
+
 	if (referenced_ptes) {
 		if (PageSwapBacked(page))
 			return PAGEREF_ACTIVATE;
@@ -769,6 +778,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto activate_locked;
 		case PAGEREF_KEEP:
 			goto keep_locked;
+		case PAGEREF_DISCARD:
+			if (discard_vpage(page))
+				goto free_it;
 		case PAGEREF_RECLAIM:
 		case PAGEREF_RECLAIM_CLEAN:
 			; /* try to reclaim the page below */
@@ -1497,7 +1509,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
 		}
 
 		if (page_referenced(page, 0, sc->target_mem_cgroup,
-				    &vm_flags)) {
+				    &vm_flags, NULL)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
diff --git a/mm/vrange.c b/mm/vrange.c
index 5278939..1c8c447 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -6,6 +6,13 @@
 #include <linux/slab.h>
 #include <linux/mman.h>
 #include <linux/syscalls.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/hugetlb.h>
+#include "internal.h"
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/mmu_notifier.h>
 
 static struct kmem_cache *vrange_cachep;
 
@@ -364,3 +371,328 @@ SYSCALL_DEFINE4(vrange, unsigned long, start,
 out:
 	return ret;
 }
+
+
+static bool __vrange_address(struct vrange_root *vroot,
+			unsigned long start, unsigned long end)
+{
+	struct interval_tree_node *node;
+
+	node = interval_tree_iter_first(&vroot->v_rb, start, end);
+	return node ? true : false;
+}
+
+bool vrange_address(struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	struct vrange_root *vroot;
+	unsigned long vstart_idx, vend_idx;
+	struct vm_area_struct *vma;
+	bool ret;
+
+	vma = find_vma(mm, start);
+	if (vma->vm_file && (vma->vm_flags & VM_SHARED)) {
+		vroot = &vma->vm_file->f_mapping->vroot;
+		vstart_idx = vma->vm_pgoff + start - vma->vm_start;
+		vend_idx = vma->vm_pgoff + end - vma->vm_start;
+	} else {
+		vroot = &mm->vroot;
+		vstart_idx = start;
+		vend_idx = end;
+	}
+
+	vrange_lock(vroot);
+	ret = __vrange_address(vroot, vstart_idx, vend_idx);
+	vrange_unlock(vroot);
+	return ret;
+}
+
+static pte_t *__vpage_check_address(struct page *page,
+		struct mm_struct *mm, unsigned long address, spinlock_t **ptlp)
+{
+	pmd_t *pmd;
+	pte_t *pte;
+	spinlock_t *ptl;
+	bool present;
+
+	/* TODO : look into tlbfs */
+	if (unlikely(PageHuge(page)))
+		return NULL;
+
+	pmd = mm_find_pmd(mm, address);
+	if (!pmd)
+		return NULL;
+	/*
+	 * TODO : Support THP
+	 */
+	if (pmd_trans_huge(*pmd))
+		return NULL;
+
+	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (pte_none(*pte))
+		goto out;
+
+	present = pte_present(*pte);
+	if (present && page_to_pfn(page) != pte_pfn(*pte))
+		goto out;
+	else if (present) {
+		*ptlp = ptl;
+		return pte;
+	} else {
+		swp_entry_t entry = { .val = page_private(page) };
+
+		VM_BUG_ON(non_swap_entry(entry));
+		if (entry.val != pte_to_swp_entry(*pte).val)
+			goto out;
+		*ptlp = ptl;
+		return pte;
+	}
+out:
+	pte_unmap_unlock(pte, ptl);
+	return NULL;
+}
+
+/*
+ * This functions checks @page is matched with pte's encoded one
+ * which could be a page or swap slot.
+ */
+static inline pte_t *vpage_check_address(struct page *page,
+		struct mm_struct *mm, unsigned long address,
+		spinlock_t **ptlp)
+{
+	pte_t *ptep;
+	__cond_lock(*ptlp, ptep = __vpage_check_address(page,
+				mm, address, ptlp));
+	return ptep;
+}
+
+static void __vrange_purge(struct vrange_root *vroot,
+		unsigned long start, unsigned long end)
+{
+	struct vrange *range;
+	struct interval_tree_node *node;
+
+	node = interval_tree_iter_first(&vroot->v_rb, start, end);
+	while (node) {
+		range = container_of(node, struct vrange, node);
+		range->purged = true;
+		node = interval_tree_iter_next(node, start, end);
+	}
+}
+
+int try_to_discard_one(struct vrange_root *vroot, struct page *page,
+			struct vm_area_struct *vma, unsigned long address)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *pte;
+	pte_t pteval;
+	spinlock_t *ptl;
+	int ret = 0;
+	bool present;
+
+	VM_BUG_ON(!PageLocked(page));
+
+	vrange_lock(vroot);
+	pte = vpage_check_address(page, mm, address, &ptl);
+	if (!pte)
+		goto out;
+
+	if (vma->vm_flags & VM_LOCKED) {
+		pte_unmap_unlock(pte, ptl);
+		goto out;
+	}
+
+	present = pte_present(*pte);
+	flush_cache_page(vma, address, page_to_pfn(page));
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	update_hiwater_rss(mm);
+	if (PageAnon(page))
+		dec_mm_counter(mm, MM_ANONPAGES);
+	else
+		dec_mm_counter(mm, MM_FILEPAGES);
+
+	page_remove_rmap(page);
+	page_cache_release(page);
+	if (!present) {
+		swp_entry_t entry = pte_to_swp_entry(*pte);
+		dec_mm_counter(mm, MM_SWAPENTS);
+		if (unlikely(!__free_swap_and_cache(entry)))
+			BUG_ON(1);
+	}
+
+	pte_unmap_unlock(pte, ptl);
+	mmu_notifier_invalidate_page(mm, address);
+	ret = 1;
+
+	if (!PageAnon(page)) /* switch to file offset) */
+		address = vma->vm_pgoff + address - vma->vm_start;
+
+	__vrange_purge(vroot, address, address + PAGE_SIZE - 1);
+
+out:
+	vrange_unlock(vroot);
+	return ret;
+}
+
+static int try_to_discard_anon_vpage(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	struct anon_vma_chain *avc;
+	pgoff_t pgoff;
+	struct vm_area_struct *vma;
+	struct mm_struct *mm;
+	struct vrange_root *vroot;
+
+	unsigned long address;
+	bool ret = 0;
+
+	anon_vma = page_lock_anon_vma_read(page);
+	if (!anon_vma)
+		return ret;
+
+	pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		pte_t *pte;
+		spinlock_t *ptl;
+
+		vma = avc->vma;
+		mm = vma->vm_mm;
+		vroot = &mm->vroot;
+		address = vma_address(page, vma);
+
+		vrange_lock(vroot);
+		/*
+		 * We can't use page_check_address because it doesn't check
+		 * swap entry of the page table. We need the check because
+		 * we have to make sure atomicity of shared vrange.
+		 * It means all vranges which are shared a page should be
+		 * purged if a page in a process is purged.
+		 */
+		pte = vpage_check_address(page, mm, address, &ptl);
+		if (!pte) {
+			vrange_unlock(vroot);
+			continue;
+		}
+
+		if (vma->vm_flags & VM_LOCKED) {
+			pte_unmap_unlock(pte, ptl);
+			vrange_unlock(vroot);
+			goto out;
+		}
+
+		pte_unmap_unlock(pte, ptl);
+		if (!__vrange_address(vroot, address,
+					address + PAGE_SIZE - 1)) {
+			vrange_unlock(vroot);
+			goto out;
+		}
+
+		vrange_unlock(vroot);
+	}
+
+	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
+		vma = avc->vma;
+		mm = vma->vm_mm;
+		vroot = &mm->vroot;
+		address = vma_address(page, vma);
+		if (!try_to_discard_one(vroot, page, vma, address))
+			goto out;
+	}
+
+	ret = 1;
+out:
+	page_unlock_anon_vma_read(anon_vma);
+	return ret;
+}
+
+
+
+static int try_to_discard_file_vpage(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	bool ret = 0;
+
+	mutex_lock(&mapping->i_mmap_mutex);
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long address = vma_address(page, vma);
+		struct mm_struct *mm = vma->vm_mm;
+		struct vrange_root *vroot = &mapping->vroot;
+		pte_t *pte;
+		spinlock_t *ptl;
+		long vstart_idx;
+
+
+		vstart_idx = vma->vm_pgoff + address - vma->vm_start;
+
+		vrange_lock(vroot);
+		/*
+		 * We can't use page_check_address because it doesn't check
+		 * swap entry of the page table. We need the check because
+		 * we have to make sure atomicity of shared vrange.
+		 * It means all vranges which are shared a page should be
+		 * purged if a page in a process is purged.
+		 */
+		pte = vpage_check_address(page, mm, address, &ptl);
+		if (!pte) {
+			vrange_unlock(vroot);
+			continue;
+		}
+
+		if (vma->vm_flags & VM_LOCKED) {
+			pte_unmap_unlock(pte, ptl);
+			vrange_unlock(vroot);
+			goto out;
+		}
+
+		pte_unmap_unlock(pte, ptl);
+		if (!__vrange_address(vroot, vstart_idx,
+					vstart_idx + PAGE_SIZE - 1)) {
+			vrange_unlock(vroot);
+			goto out;
+		}
+
+		vrange_unlock(vroot);
+	}
+
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		unsigned long address = vma_address(page, vma);
+		struct vrange_root *vroot = &mapping->vroot;
+
+		if (!try_to_discard_one(vroot, page, vma, address))
+			goto out;
+	}
+
+	ret = 1;
+out:
+	mutex_unlock(&mapping->i_mmap_mutex);
+	return ret;
+}
+
+static int try_to_discard_vpage(struct page *page)
+{
+	if (PageAnon(page))
+		return try_to_discard_anon_vpage(page);
+	return try_to_discard_file_vpage(page);
+}
+
+int discard_vpage(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(PageLRU(page));
+
+	if (try_to_discard_vpage(page)) {
+		if (PageSwapCache(page))
+			try_to_free_swap(page);
+
+		if (page_freeze_refs(page, 1)) {
+			unlock_page(page);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
