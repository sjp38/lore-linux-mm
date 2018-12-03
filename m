Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF6D6B6A5E
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 12:13:10 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id m128so9348696itd.3
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 09:13:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s204sor6098417iod.16.2018.12.03.09.13.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 09:13:07 -0800 (PST)
From: Vineeth Remanan Pillai <vpillai@digitalocean.com>
Subject: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
Date: Mon,  3 Dec 2018 17:09:34 +0000
Message-Id: <20181203170934.16512-2-vpillai@digitalocean.com>
In-Reply-To: <20181203170934.16512-1-vpillai@digitalocean.com>
References: <20181203170934.16512-1-vpillai@digitalocean.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Vineeth Remanan Pillai <vpillai@digitalocean.com>, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

This patch was initially posted by Kelley(kelleynnn@gmail.com).
Reposting the patch with all review comments addressed and with minor
modifications and optimizations. Tests were rerun and commit message
updated with new results.

The function try_to_unuse() is of quadratic complexity, with a lot of
wasted effort. It unuses swap entries one by one, potentially iterating
over all the page tables for all the processes in the system for each
one.

This new proposed implementation of try_to_unuse simplifies its
complexity to linear. It iterates over the system's mms once, unusing
all the affected entries as it walks each set of page tables. It also
makes similar changes to shmem_unuse.

Improvement

swapoff was called on a swap partition containing about 6G of data, in a
VM(8cpu, 16G RAM), and calls to unuse_pte_range() were counted.

Present implementation....about 1200M calls(8min, avg 80% cpu util).
Prototype.................about  9.0K calls(3min, avg 5% cpu util).

Details

In shmem_unuse(), iterate over the shmem_swaplist and, for each
shmem_inode_info that contains a swap entry, pass it to
shmem_unuse_inode(), along with the swap type. In shmem_unuse_inode(),
iterate over its associated xarray, and store the index and value of each
swap entry in an array for passing to shmem_swapin_page() outside
of the RCU critical section.

In try_to_unuse(), instead of iterating over the entries in the type and
unusing them one by one, perhaps walking all the page tables for all the
processes for each one, iterate over the mmlist, making one pass. Pass
each mm to unuse_mm() to begin its page table walk, and during the walk,
unuse all the ptes that have backing store in the swap type received by
try_to_unuse(). After the walk, check the type for orphaned swap entries
with find_next_to_unuse(), and remove them from the swap cache. If
find_next_to_unuse() starts over at the beginning of the type, repeat
the check of the shmem_swaplist and the walk a maximum of three times.

Change unuse_mm() and the intervening walk functions down to
unuse_pte_range() to take the type as a parameter, and to iterate over
their entire range, calling the next function down on every iteration.
In unuse_pte_range(), make a swap entry from each pte in the range using
the passed in type. If it has backing store in the type, call
swapin_readahead() to retrieve the page and pass it to unuse_pte().

Pass the count of pages_to_unuse down the page table walks in
try_to_unuse(), and return from the walk when the desired number of pages
has been swapped back in.

Change in v3
 - Addressed review comments
 - Refactored out swap-in logic from shmem_getpage_fp
Changes in v2
 - Updated patch to use Xarray instead of radix tree

Signed-off-by: Vineeth Remanan Pillai <vpillai@digitalocean.com>
Signed-off-by: Kelley Nielsen <kelleynnn@gmail.com>
CC: Rik van Riel <riel@surriel.com>
---
 include/linux/shmem_fs.h |   2 +-
 mm/shmem.c               | 218 ++++++++++-----------
 mm/swapfile.c            | 413 +++++++++++++++------------------------
 3 files changed, 260 insertions(+), 373 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index f155dc607112..1dd02592bb53 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -72,7 +72,7 @@ extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
-extern int shmem_unuse(swp_entry_t entry, struct page *page);
+extern int shmem_unuse(unsigned int type);
 
 extern unsigned long shmem_swap_usage(struct vm_area_struct *vma);
 extern unsigned long shmem_partial_swap_usage(struct address_space *mapping,
diff --git a/mm/shmem.c b/mm/shmem.c
index 035ea2c10f54..404f7b785fce 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1093,159 +1093,143 @@ static void shmem_evict_inode(struct inode *inode)
 	clear_inode(inode);
 }
 
-static unsigned long find_swap_entry(struct xarray *xa, void *item)
+static int shmem_find_swap_entries(struct address_space *mapping,
+				   pgoff_t start, unsigned int nr_entries,
+				   struct page **entries, pgoff_t *indices)
 {
-	XA_STATE(xas, xa, 0);
-	unsigned int checked = 0;
-	void *entry;
+	XA_STATE(xas, &mapping->i_pages, start);
+	struct page *page;
+	unsigned int ret = 0;
+
+	if (!nr_entries)
+		return 0;
 
 	rcu_read_lock();
-	xas_for_each(&xas, entry, ULONG_MAX) {
-		if (xas_retry(&xas, entry))
+	xas_for_each(&xas, page, ULONG_MAX) {
+		if (xas_retry(&xas, page))
 			continue;
-		if (entry == item)
-			break;
-		checked++;
-		if ((checked % XA_CHECK_SCHED) != 0)
+
+		if (!xa_is_value(page))
 			continue;
-		xas_pause(&xas);
-		cond_resched_rcu();
+
+		indices[ret] = xas.xa_index;
+		entries[ret] = page;
+
+		if (need_resched()) {
+			xas_pause(&xas);
+			cond_resched_rcu();
+		}
+		if (++ret == nr_entries)
+			break;
 	}
 	rcu_read_unlock();
 
-	return entry ? xas.xa_index : -1;
+	return ret;
+}
+
+static int shmem_unuse_swap_entries(struct inode *inode, struct pagevec pvec,
+				    pgoff_t *indices)
+{
+	int i = 0;
+	int error = 0;
+	struct address_space *mapping = inode->i_mapping;
+
+	for (i = 0; i < pvec.nr; i++) {
+		struct page *page = pvec.pages[i];
+
+		if (!xa_is_value(page))
+			continue;
+		error = shmem_swapin_page(inode, indices[i],
+					  &page, SGP_CACHE,
+					  mapping_gfp_mask(mapping),
+					  NULL, NULL);
+		if (error == 0) {
+			unlock_page(page);
+			put_page(page);
+		}
+		if (error == -ENOMEM)
+			break;
+	}
+	return error;
 }
 
 /*
  * If swap found in inode, free it and move page from swapcache to filecache.
  */
-static int shmem_unuse_inode(struct shmem_inode_info *info,
-			     swp_entry_t swap, struct page **pagep)
+static int shmem_unuse_inode(struct inode *inode, unsigned int type)
 {
-	struct address_space *mapping = info->vfs_inode.i_mapping;
-	void *radswap;
-	pgoff_t index;
-	gfp_t gfp;
+	struct address_space *mapping = inode->i_mapping;
+	pgoff_t start = 0;
+	struct pagevec pvec;
+	pgoff_t indices[PAGEVEC_SIZE];
 	int error = 0;
 
-	radswap = swp_to_radix_entry(swap);
-	index = find_swap_entry(&mapping->i_pages, radswap);
-	if (index == -1)
-		return -EAGAIN;	/* tell shmem_unuse we found nothing */
+	pagevec_init(&pvec);
+	do {
+		pvec.nr = shmem_find_swap_entries(mapping, start, PAGEVEC_SIZE,
+						  pvec.pages, indices);
+		if (pvec.nr == 0)
+			break;
 
-	/*
-	 * Move _head_ to start search for next from here.
-	 * But be careful: shmem_evict_inode checks list_empty without taking
-	 * mutex, and there's an instant in list_move_tail when info->swaplist
-	 * would appear empty, if it were the only one on shmem_swaplist.
-	 */
-	if (shmem_swaplist.next != &info->swaplist)
-		list_move_tail(&shmem_swaplist, &info->swaplist);
+		error = shmem_unuse_swap_entries(inode, pvec, indices);
+		if (error == -ENOMEM)
+			break;
 
-	gfp = mapping_gfp_mask(mapping);
-	if (shmem_should_replace_page(*pagep, gfp)) {
-		mutex_unlock(&shmem_swaplist_mutex);
-		error = shmem_replace_page(pagep, gfp, info, index);
-		mutex_lock(&shmem_swaplist_mutex);
-		/*
-		 * We needed to drop mutex to make that restrictive page
-		 * allocation, but the inode might have been freed while we
-		 * dropped it: although a racing shmem_evict_inode() cannot
-		 * complete without emptying the page cache, our page lock
-		 * on this swapcache page is not enough to prevent that -
-		 * free_swap_and_cache() of our swap entry will only
-		 * trylock_page(), removing swap from page cache whatever.
-		 *
-		 * We must not proceed to shmem_add_to_page_cache() if the
-		 * inode has been freed, but of course we cannot rely on
-		 * inode or mapping or info to check that.  However, we can
-		 * safely check if our swap entry is still in use (and here
-		 * it can't have got reused for another page): if it's still
-		 * in use, then the inode cannot have been freed yet, and we
-		 * can safely proceed (if it's no longer in use, that tells
-		 * nothing about the inode, but we don't need to unuse swap).
-		 */
-		if (!page_swapcount(*pagep))
-			error = -ENOENT;
-	}
+		start = indices[pvec.nr - 1];
+	} while (true);
 
-	/*
-	 * We rely on shmem_swaplist_mutex, not only to protect the swaplist,
-	 * but also to hold up shmem_evict_inode(): so inode cannot be freed
-	 * beneath us (pagelock doesn't help until the page is in pagecache).
-	 */
-	if (!error)
-		error = shmem_add_to_page_cache(*pagep, mapping, index,
-						radswap, gfp);
-	if (error != -ENOMEM) {
-		/*
-		 * Truncation and eviction use free_swap_and_cache(), which
-		 * only does trylock page: if we raced, best clean up here.
-		 */
-		delete_from_swap_cache(*pagep);
-		set_page_dirty(*pagep);
-		if (!error) {
-			spin_lock_irq(&info->lock);
-			info->swapped--;
-			spin_unlock_irq(&info->lock);
-			swap_free(swap);
-		}
-	}
 	return error;
 }
 
 /*
- * Search through swapped inodes to find and replace swap by page.
+ * Read all the shared memory data that resides in the swap
+ * device 'type' back into memory, so the swap device can be
+ * unused.
  */
-int shmem_unuse(swp_entry_t swap, struct page *page)
+int shmem_unuse(unsigned int type)
 {
-	struct list_head *this, *next;
-	struct shmem_inode_info *info;
-	struct mem_cgroup *memcg;
+	struct shmem_inode_info *info, *next;
+	struct inode *inode;
+	struct inode *prev_inode = NULL;
 	int error = 0;
 
-	/*
-	 * There's a faint possibility that swap page was replaced before
-	 * caller locked it: caller will come back later with the right page.
-	 */
-	if (unlikely(!PageSwapCache(page) || page_private(page) != swap.val))
-		goto out;
+	if (list_empty(&shmem_swaplist))
+		return 0;
+
+	mutex_lock(&shmem_swaplist_mutex);
 
 	/*
-	 * Charge page using GFP_KERNEL while we can wait, before taking
-	 * the shmem_swaplist_mutex which might hold up shmem_writepage().
-	 * Charged back to the user (not to caller) when swap account is used.
+	 * The extra refcount on the inode is necessary to safely dereference
+	 * p->next after re-acquiring the lock. New shmem inodes with swap
+	 * get added to the end of the list and we will scan them all.
 	 */
-	error = mem_cgroup_try_charge_delay(page, current->mm, GFP_KERNEL,
-					    &memcg, false);
-	if (error)
-		goto out;
-	/* No memory allocation: swap entry occupies the slot for the page */
-	error = -EAGAIN;
+	list_for_each_entry_safe(info, next, &shmem_swaplist, swaplist) {
+		if (!info->swapped) {
+			list_del_init(&info->swaplist);
+			continue;
+		}
 
-	mutex_lock(&shmem_swaplist_mutex);
-	list_for_each_safe(this, next, &shmem_swaplist) {
-		info = list_entry(this, struct shmem_inode_info, swaplist);
-		if (info->swapped)
-			error = shmem_unuse_inode(info, swap, &page);
-		else
+		inode = igrab(&info->vfs_inode);
+		if (!inode)
+			continue;
+
+		mutex_unlock(&shmem_swaplist_mutex);
+		if (prev_inode)
+			iput(prev_inode);
+		error = shmem_unuse_inode(inode, type);
+		if (!info->swapped)
 			list_del_init(&info->swaplist);
 		cond_resched();
-		if (error != -EAGAIN)
+		prev_inode = inode;
+		mutex_lock(&shmem_swaplist_mutex);
+		if (error)
 			break;
-		/* found nothing in this: move on to search the next */
 	}
 	mutex_unlock(&shmem_swaplist_mutex);
 
-	if (error) {
-		if (error != -ENOMEM)
-			error = 0;
-		mem_cgroup_cancel_charge(page, memcg, false);
-	} else
-		mem_cgroup_commit_charge(page, memcg, true, false);
-out:
-	unlock_page(page);
-	put_page(page);
+	if (prev_inode)
+		iput(prev_inode);
+
 	return error;
 }
 
@@ -3882,7 +3866,7 @@ int __init shmem_init(void)
 	return 0;
 }
 
-int shmem_unuse(swp_entry_t swap, struct page *page)
+int shmem_unuse(unsigned int type)
 {
 	return 0;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8688ae65ef58..6656353f1e23 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1798,45 +1798,86 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	return ret;
 }
 
+/*
+ * unuse_pte can return 1. Use a unique return value in this
+ * context to denote requested frontswap pages are unused.
+ */
+#define FRONTSWAP_PAGES_UNUSED 2
 static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+			unsigned long addr, unsigned long end,
+			unsigned int type,
+			unsigned long *fs_pages_to_unuse)
 {
-	pte_t swp_pte = swp_entry_to_pte(entry);
+	struct page *page;
+	swp_entry_t entry;
 	pte_t *pte;
+	struct swap_info_struct *si;
+	unsigned long offset;
 	int ret = 0;
+	volatile unsigned char *swap_map;
 
-	/*
-	 * We don't actually need pte lock while scanning for swp_pte: since
-	 * we hold page lock and mmap_sem, swp_pte cannot be inserted into the
-	 * page table while we're scanning; though it could get zapped, and on
-	 * some architectures (e.g. x86_32 with PAE) we might catch a glimpse
-	 * of unmatched parts which look like swp_pte, so unuse_pte must
-	 * recheck under pte lock.  Scanning without pte lock lets it be
-	 * preemptable whenever CONFIG_PREEMPT but not CONFIG_HIGHPTE.
-	 */
+	si = swap_info[type];
 	pte = pte_offset_map(pmd, addr);
 	do {
-		/*
-		 * swapoff spends a _lot_ of time in this loop!
-		 * Test inline before going to call unuse_pte.
-		 */
-		if (unlikely(pte_same_as_swp(*pte, swp_pte))) {
-			pte_unmap(pte);
-			ret = unuse_pte(vma, pmd, addr, entry, page);
-			if (ret)
+		struct vm_fault vmf;
+
+		if (!is_swap_pte(*pte))
+			continue;
+
+		entry = pte_to_swp_entry(*pte);
+		if (swp_type(entry) != type)
+			continue;
+
+		offset = swp_offset(entry);
+		if ((*fs_pages_to_unuse > 0) && (!frontswap_test(si, offset)))
+			continue;
+
+		pte_unmap(pte);
+		swap_map = &si->swap_map[offset];
+		vmf.vma = vma;
+		vmf.address = addr;
+		page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE, &vmf);
+		if (!page) {
+			if (*swap_map == 0 || *swap_map == SWAP_MAP_BAD)
+				goto try_next;
+			return -ENOMEM;
+		}
+
+		lock_page(page);
+		wait_on_page_writeback(page);
+		ret = unuse_pte(vma, pmd, addr, entry, page);
+		if (ret < 0) {
+			unlock_page(page);
+			put_page(page);
+			goto out;
+		}
+
+		if (PageSwapCache(page) && (swap_count(*swap_map) == 0))
+			delete_from_swap_cache(compound_head(page));
+
+		SetPageDirty(page);
+		unlock_page(page);
+		put_page(page);
+
+		if (*fs_pages_to_unuse > 0) {
+			if (!--(*fs_pages_to_unuse)) {
+				ret = FRONTSWAP_PAGES_UNUSED;
 				goto out;
-			pte = pte_offset_map(pmd, addr);
+			}
 		}
+try_next:
+		pte = pte_offset_map(pmd, addr);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap(pte - 1);
+
 out:
 	return ret;
 }
 
 static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+				unsigned int type,
+				unsigned long *fs_pages_to_unuse)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -1848,8 +1889,9 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
-		ret = unuse_pte_range(vma, pmd, addr, next, entry, page);
-		if (ret)
+		ret = unuse_pte_range(vma, pmd, addr, next, type,
+				      fs_pages_to_unuse);
+		if (ret < 0 || ret == FRONTSWAP_PAGES_UNUSED)
 			return ret;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
@@ -1857,7 +1899,8 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 
 static inline int unuse_pud_range(struct vm_area_struct *vma, p4d_t *p4d,
 				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+				unsigned int type,
+				unsigned long *fs_pages_to_unuse)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -1868,8 +1911,9 @@ static inline int unuse_pud_range(struct vm_area_struct *vma, p4d_t *p4d,
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		ret = unuse_pmd_range(vma, pud, addr, next, entry, page);
-		if (ret)
+		ret = unuse_pmd_range(vma, pud, addr, next, type,
+				      fs_pages_to_unuse);
+		if (ret < 0 || ret == FRONTSWAP_PAGES_UNUSED)
 			return ret;
 	} while (pud++, addr = next, addr != end);
 	return 0;
@@ -1877,7 +1921,8 @@ static inline int unuse_pud_range(struct vm_area_struct *vma, p4d_t *p4d,
 
 static inline int unuse_p4d_range(struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+				unsigned int type,
+				unsigned long *fs_pages_to_unuse)
 {
 	p4d_t *p4d;
 	unsigned long next;
@@ -1888,66 +1933,54 @@ static inline int unuse_p4d_range(struct vm_area_struct *vma, pgd_t *pgd,
 		next = p4d_addr_end(addr, end);
 		if (p4d_none_or_clear_bad(p4d))
 			continue;
-		ret = unuse_pud_range(vma, p4d, addr, next, entry, page);
-		if (ret)
+		ret = unuse_pud_range(vma, p4d, addr, next, type,
+				      fs_pages_to_unuse);
+		if (ret < 0 || ret == FRONTSWAP_PAGES_UNUSED)
 			return ret;
 	} while (p4d++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_vma(struct vm_area_struct *vma,
-				swp_entry_t entry, struct page *page)
+static int unuse_vma(struct vm_area_struct *vma, unsigned int type,
+		     unsigned long *fs_pages_to_unuse)
 {
 	pgd_t *pgd;
 	unsigned long addr, end, next;
 	int ret;
 
-	if (page_anon_vma(page)) {
-		addr = page_address_in_vma(page, vma);
-		if (addr == -EFAULT)
-			return 0;
-		else
-			end = addr + PAGE_SIZE;
-	} else {
-		addr = vma->vm_start;
-		end = vma->vm_end;
-	}
+	addr = vma->vm_start;
+	end = vma->vm_end;
 
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		ret = unuse_p4d_range(vma, pgd, addr, next, entry, page);
-		if (ret)
+		ret = unuse_p4d_range(vma, pgd, addr, next, type,
+				      fs_pages_to_unuse);
+		if (ret < 0 || ret == FRONTSWAP_PAGES_UNUSED)
 			return ret;
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_mm(struct mm_struct *mm,
-				swp_entry_t entry, struct page *page)
+static int unuse_mm(struct mm_struct *mm, unsigned int type,
+		    unsigned long *fs_pages_to_unuse)
 {
 	struct vm_area_struct *vma;
 	int ret = 0;
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		/*
-		 * Activate page so shrink_inactive_list is unlikely to unmap
-		 * its ptes while lock is dropped, so swapoff can make progress.
-		 */
-		activate_page(page);
-		unlock_page(page);
-		down_read(&mm->mmap_sem);
-		lock_page(page);
-	}
+	down_read(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
-			break;
+		if (vma->anon_vma) {
+			ret = unuse_vma(vma, type, fs_pages_to_unuse);
+			if (ret < 0 || ret == FRONTSWAP_PAGES_UNUSED)
+				break;
+		}
 		cond_resched();
 	}
 	up_read(&mm->mmap_sem);
-	return (ret < 0)? ret: 0;
+	return ret;
 }
 
 /*
@@ -1993,234 +2026,104 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
 }
 
 /*
- * We completely avoid races by reading each swap page in advance,
- * and then search for the process using it.  All the necessary
- * page table adjustments can then be made atomically.
- *
- * if the boolean frontswap is true, only unuse pages_to_unuse pages;
+ * If the boolean frontswap is true, only unuse pages_to_unuse pages;
  * pages_to_unuse==0 means all pages; ignored if frontswap is false
  */
+#define MAX_RETRIES 3
 int try_to_unuse(unsigned int type, bool frontswap,
 		 unsigned long pages_to_unuse)
 {
+	struct mm_struct *prev_mm;
+	struct mm_struct *mm;
+	struct list_head *p;
+	int retval = 0;
 	struct swap_info_struct *si = swap_info[type];
-	struct mm_struct *start_mm;
-	volatile unsigned char *swap_map; /* swap_map is accessed without
-					   * locking. Mark it as volatile
-					   * to prevent compiler doing
-					   * something odd.
-					   */
-	unsigned char swcount;
 	struct page *page;
 	swp_entry_t entry;
 	unsigned int i = 0;
-	int retval = 0;
+	unsigned int oldi = 0;
+	int retries = 0;
 
-	/*
-	 * When searching mms for an entry, a good strategy is to
-	 * start at the first mm we freed the previous entry from
-	 * (though actually we don't notice whether we or coincidence
-	 * freed the entry).  Initialize this start_mm with a hold.
-	 *
-	 * A simpler strategy would be to start at the last mm we
-	 * freed the previous entry from; but that would take less
-	 * advantage of mmlist ordering, which clusters forked mms
-	 * together, child after parent.  If we race with dup_mmap(), we
-	 * prefer to resolve parent before child, lest we miss entries
-	 * duplicated after we scanned child: using last mm would invert
-	 * that.
-	 */
-	start_mm = &init_mm;
-	mmget(&init_mm);
+	if (!frontswap)
+		pages_to_unuse = 0;
 
-	/*
-	 * Keep on scanning until all entries have gone.  Usually,
-	 * one pass through swap_map is enough, but not necessarily:
-	 * there are races when an instance of an entry might be missed.
-	 */
-	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
+retry:
+	retval = shmem_unuse(type);
+	if (retval)
+		goto out;
+
+	prev_mm = &init_mm;
+	mmget(prev_mm);
+
+	spin_lock(&mmlist_lock);
+	p = &init_mm.mmlist;
+	while (!retval && (p = p->next) != &init_mm.mmlist) {
 		if (signal_pending(current)) {
 			retval = -EINTR;
 			break;
 		}
 
-		/*
-		 * Get a page for the entry, using the existing swap
-		 * cache page if there is one.  Otherwise, get a clean
-		 * page and read the swap into it.
-		 */
-		swap_map = &si->swap_map[i];
-		entry = swp_entry(type, i);
-		page = read_swap_cache_async(entry,
-					GFP_HIGHUSER_MOVABLE, NULL, 0, false);
-		if (!page) {
-			/*
-			 * Either swap_duplicate() failed because entry
-			 * has been freed independently, and will not be
-			 * reused since sys_swapoff() already disabled
-			 * allocation from here, or alloc_page() failed.
-			 */
-			swcount = *swap_map;
-			/*
-			 * We don't hold lock here, so the swap entry could be
-			 * SWAP_MAP_BAD (when the cluster is discarding).
-			 * Instead of fail out, We can just skip the swap
-			 * entry because swapoff will wait for discarding
-			 * finish anyway.
-			 */
-			if (!swcount || swcount == SWAP_MAP_BAD)
-				continue;
-			retval = -ENOMEM;
-			break;
-		}
+		mm = list_entry(p, struct mm_struct, mmlist);
+		if (!mmget_not_zero(mm))
+			continue;
+		spin_unlock(&mmlist_lock);
+		mmput(prev_mm);
+		prev_mm = mm;
+		retval = unuse_mm(mm, type, &pages_to_unuse);
 
 		/*
-		 * Don't hold on to start_mm if it looks like exiting.
+		 * Make sure that we aren't completely killing
+		 * interactive performance.
 		 */
-		if (atomic_read(&start_mm->mm_users) == 1) {
-			mmput(start_mm);
-			start_mm = &init_mm;
-			mmget(&init_mm);
-		}
+		cond_resched();
+		spin_lock(&mmlist_lock);
+	}
+	spin_unlock(&mmlist_lock);
 
-		/*
-		 * Wait for and lock page.  When do_swap_page races with
-		 * try_to_unuse, do_swap_page can handle the fault much
-		 * faster than try_to_unuse can locate the entry.  This
-		 * apparently redundant "wait_on_page_locked" lets try_to_unuse
-		 * defer to do_swap_page in such a case - in some tests,
-		 * do_swap_page and try_to_unuse repeatedly compete.
-		 */
-		wait_on_page_locked(page);
-		wait_on_page_writeback(page);
-		lock_page(page);
-		wait_on_page_writeback(page);
+	mmput(prev_mm);
+	if (retval) {
+		if (retval == FRONTSWAP_PAGES_UNUSED)
+			retval = 0;
+		goto out;
+	}
 
+	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		/*
-		 * Remove all references to entry.
+		 * under global memory pressure, swap entries
+		 * can be reinserted back into process space
+		 * after the mmlist loop above passes over them.
+		 * This loop will then repeat fruitlessly,
+		 * reading in from swap and deleting from swapcache,
+		 * but doing nothing to actually free up the swap.
+		 * In this case, go over the mmlist loop again.
 		 */
-		swcount = *swap_map;
-		if (swap_count(swcount) == SWAP_MAP_SHMEM) {
-			retval = shmem_unuse(entry, page);
-			/* page has already been unlocked and released */
-			if (retval < 0)
-				break;
-			continue;
-		}
-		if (swap_count(swcount) && start_mm != &init_mm)
-			retval = unuse_mm(start_mm, entry, page);
-
-		if (swap_count(*swap_map)) {
-			int set_start_mm = (*swap_map >= swcount);
-			struct list_head *p = &start_mm->mmlist;
-			struct mm_struct *new_start_mm = start_mm;
-			struct mm_struct *prev_mm = start_mm;
-			struct mm_struct *mm;
-
-			mmget(new_start_mm);
-			mmget(prev_mm);
-			spin_lock(&mmlist_lock);
-			while (swap_count(*swap_map) && !retval &&
-					(p = p->next) != &start_mm->mmlist) {
-				mm = list_entry(p, struct mm_struct, mmlist);
-				if (!mmget_not_zero(mm))
-					continue;
-				spin_unlock(&mmlist_lock);
-				mmput(prev_mm);
-				prev_mm = mm;
-
-				cond_resched();
-
-				swcount = *swap_map;
-				if (!swap_count(swcount)) /* any usage ? */
-					;
-				else if (mm == &init_mm)
-					set_start_mm = 1;
-				else
-					retval = unuse_mm(mm, entry, page);
-
-				if (set_start_mm && *swap_map < swcount) {
-					mmput(new_start_mm);
-					mmget(mm);
-					new_start_mm = mm;
-					set_start_mm = 0;
-				}
-				spin_lock(&mmlist_lock);
+		if (i < oldi) {
+			retries++;
+			if (retries > MAX_RETRIES) {
+				retval = -EBUSY;
+				goto out;
 			}
-			spin_unlock(&mmlist_lock);
-			mmput(prev_mm);
-			mmput(start_mm);
-			start_mm = new_start_mm;
-		}
-		if (retval) {
-			unlock_page(page);
-			put_page(page);
-			break;
-		}
-
-		/*
-		 * If a reference remains (rare), we would like to leave
-		 * the page in the swap cache; but try_to_unmap could
-		 * then re-duplicate the entry once we drop page lock,
-		 * so we might loop indefinitely; also, that page could
-		 * not be swapped out to other storage meanwhile.  So:
-		 * delete from cache even if there's another reference,
-		 * after ensuring that the data has been saved to disk -
-		 * since if the reference remains (rarer), it will be
-		 * read from disk into another page.  Splitting into two
-		 * pages would be incorrect if swap supported "shared
-		 * private" pages, but they are handled by tmpfs files.
-		 *
-		 * Given how unuse_vma() targets one particular offset
-		 * in an anon_vma, once the anon_vma has been determined,
-		 * this splitting happens to be just what is needed to
-		 * handle where KSM pages have been swapped out: re-reading
-		 * is unnecessarily slow, but we can fix that later on.
-		 */
-		if (swap_count(*swap_map) &&
-		     PageDirty(page) && PageSwapCache(page)) {
-			struct writeback_control wbc = {
-				.sync_mode = WB_SYNC_NONE,
-			};
-
-			swap_writepage(compound_head(page), &wbc);
-			lock_page(page);
-			wait_on_page_writeback(page);
+			goto retry;
 		}
+		entry = swp_entry(type, i);
+		page = find_get_page(swap_address_space(entry), entry.val);
+		if (!page)
+			continue;
 
 		/*
 		 * It is conceivable that a racing task removed this page from
-		 * swap cache just before we acquired the page lock at the top,
-		 * or while we dropped it in unuse_mm().  The page might even
-		 * be back in swap cache on another swap area: that we must not
-		 * delete, since it may not have been written out to swap yet.
-		 */
-		if (PageSwapCache(page) &&
-		    likely(page_private(page) == entry.val) &&
-		    !page_swapped(page))
-			delete_from_swap_cache(compound_head(page));
-
-		/*
-		 * So we could skip searching mms once swap count went
-		 * to 1, we did not mark any present ptes as dirty: must
-		 * mark page dirty so shrink_page_list will preserve it.
+		 * swap cache just before we acquired the page lock. The page
+		 * might even be back in swap cache on another swap area.  But
+		 * that is okay, try_to_free_swap() only removes stale pages.
 		 */
-		SetPageDirty(page);
+		lock_page(page);
+		wait_on_page_writeback(page);
+		try_to_free_swap(page);
 		unlock_page(page);
 		put_page(page);
-
-		/*
-		 * Make sure that we aren't completely killing
-		 * interactive performance.
-		 */
-		cond_resched();
-		if (frontswap && pages_to_unuse > 0) {
-			if (!--pages_to_unuse)
-				break;
-		}
+		oldi = i;
 	}
-
-	mmput(start_mm);
+out:
 	return retval;
 }
 
-- 
2.17.1
