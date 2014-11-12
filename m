Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C0FE66B00B4
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 21:57:29 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id v10so11136683pde.8
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 18:57:29 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id df5si21652340pbc.40.2014.11.11.18.57.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 18:57:27 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id v10so11284117pde.4
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 18:57:26 -0800 (PST)
Date: Tue, 11 Nov 2014 18:57:24 -0800
From: Kelley Nielsen <kelleynnn@gmail.com>
Subject: [RFC v6 1/2] mm: prototype: rid swapoff of quadratic complexity
Message-ID: <20141112025724.GA7443@kelleynnn-virtual-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@surriel.com, riel@redhat.com, opw-kernel@googlegroups.com, hughd@google.com, akpm@linux-foundation.org, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

Changes since v5:
* Make multiple orphan checking passes at the end of try_to_unuse
* Remove pages from swapcache if we hold the only reference in
* unuse_pte_range

>8----------------------------------------------------------8<

The function try_to_unuse() is of quadratic complexity, with a lot of
wasted effort. It unuses swap entries one by one, potentially iterating
over all the page tables for all the processes in the system for each
one.

This new proposed implementation of try_to_unuse simplifies its
complexity to linear. It iterates over the system's mms once, unusing
all the affected entries as it walks each set of page tables. It also
makes similar changes to shmem_unuse.

Improvement

Time took by swapoff on a swap partition containing about 240M of data,
with about 1.1G free memory and about 520M swap available. Swap
partition was on a laptop with a hard disk drive (not SSD).

Present implementation....about 13.8s
Prototype.................about  5.5s

Details

In shmem_unuse, iterate over the shmem_swaplist and, for each
shmem_inode_info that contains a swap entry, pass it to shmem_unuse_inode,
along with the swap type. In shmem_unuse_inode, iterate over its associated
radix tree, and store the index of each exceptional entry in an array for
passing to shmem_getpage_gfp outside of the RCU critical section.

In try_to_unuse, instead of iterating over the entries in the type and
unusing them one by one, perhaps walking all the page tables for all the
processes for each one, iterate over the mmlist, making one pass. Pass
each mm to unuse_mm to begin its page table walk, and during the walk,
unuse all the ptes that have backing store in the swap type received by
try_to_unuse. After the walk, check the type for orphaned swap entries
with find_next_to_unuse, and remove them from the swap cache.

Change unuse_mm and the intervening walk functions down to unuse_pte_range
to take the type as a parameter, and to iterate over their entire range,
calling the next function down on every iteration. In unuse_pte_range,
make a swap entry from each pte in the range using the passed in type.
If it has backing store in the type, call swapin_readahead to retrieve
the page, and then pass this page to unuse_pte.

TODO

* Handle count of unused pages for frontswap.

Signed-off-by: Kelley Nielsen <kelleynnn@gmail.com>
---
 include/linux/shmem_fs.h |   2 +-
 mm/shmem.c               | 190 +++++++++++------------
 mm/swapfile.c            | 394 +++++++++++++++++------------------------------
 3 files changed, 230 insertions(+), 356 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 50777b5..f0cd6c9 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -58,7 +58,7 @@ extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
-extern int shmem_unuse(swp_entry_t entry, struct page *page);
+extern int shmem_unuse(unsigned int type);
 
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)
diff --git a/mm/shmem.c b/mm/shmem.c
index 185836b..2a7179c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -614,132 +614,116 @@ static void shmem_evict_inode(struct inode *inode)
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
+	struct address_space *mapping = inode->i_mapping;
+	void **slot = NULL;
+	struct radix_tree_iter iter;
+	struct page *pagep;
 	gfp_t gfp;
 	int error = 0;
-
-	radswap = swp_to_radix_entry(swap);
-	index = radix_tree_locate_item(&mapping->page_tree, radswap);
-	if (index == -1)
-		return -EAGAIN;	/* tell shmem_unuse we found nothing */
-
-	/*
-	 * Move _head_ to start search for next from here.
-	 * But be careful: shmem_evict_inode checks list_empty without taking
-	 * mutex, and there's an instant in list_move_tail when info->swaplist
-	 * would appear empty, if it were the only one on shmem_swaplist.
-	 */
-	if (shmem_swaplist.next != &info->swaplist)
-		list_move_tail(&shmem_swaplist, &info->swaplist);
-
+	struct page *page;
+	pgoff_t index;
+	pgoff_t indices[PAGEVEC_SIZE];
+	int i;
+	int entries = 0;
+	swp_entry_t entry;
+	unsigned int stype;
+	pgoff_t start = 0;
 	gfp = mapping_gfp_mask(mapping);
-	if (shmem_should_replace_page(*pagep, gfp)) {
-		mutex_unlock(&shmem_swaplist_mutex);
-		error = shmem_replace_page(pagep, gfp, info, index);
-		mutex_lock(&shmem_swaplist_mutex);
-		/*
-		 * We needed to drop mutex to make that restrictive page
-		 * allocation, but the inode might have been freed while we
-		 * dropped it: although a racing shmem_evict_inode() cannot
-		 * complete without emptying the radix_tree, our page lock
-		 * on this swapcache page is not enough to prevent that -
-		 * free_swap_and_cache() of our swap entry will only
-		 * trylock_page(), removing swap from radix_tree whatever.
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
 
-	/*
-	 * We rely on shmem_swaplist_mutex, not only to protect the swaplist,
-	 * but also to hold up shmem_evict_inode(): so inode cannot be freed
-	 * beneath us (pagelock doesn't help until the page is in pagecache).
-	 */
-	if (!error)
-		error = shmem_add_to_page_cache(*pagep, mapping, index,
-						radswap);
-	if (error != -ENOMEM) {
-		/*
-		 * Truncation and eviction use free_swap_and_cache(), which
-		 * only does trylock page: if we raced, best clean up here.
-		 */
-		delete_from_swap_cache(*pagep);
-		set_page_dirty(*pagep);
-		if (!error) {
-			spin_lock(&info->lock);
-			info->swapped--;
-			spin_unlock(&info->lock);
-			swap_free(swap);
+repeat:
+	rcu_read_lock();
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		index = iter.index;
+		page = radix_tree_deref_slot(slot);
+		if (unlikely(!page))
+			continue;
+		if (radix_tree_exceptional_entry(page)) {
+			entry = radix_to_swp_entry(page);
+			stype = swp_type(entry);
+			if (stype == type) {
+				indices[entries] = iter.index;
+				entries++;
+				if (entries == PAGEVEC_SIZE)
+					break;
+			}
+		}
+	}
+	rcu_read_unlock();
+	for (i = 0; i < entries; i++) {
+		error = shmem_getpage_gfp(inode, indices[i], &pagep,
+				SGP_CACHE, gfp, NULL);
+		if (error == 0) {
+			unlock_page(pagep);
+			page_cache_release(pagep);
 		}
+		if (error == -ENOMEM)
+			goto out;
 	}
+	if (slot != NULL) {
+		entries = 0;
+		start = iter.index;
+		goto repeat;
+	}
+out:
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
 	struct shmem_inode_info *info;
-	struct mem_cgroup *memcg;
+	struct inode *inode;
+	struct inode *prev_inode = NULL;
+	struct list_head *p;
+	struct list_head *next;
 	int error = 0;
 
-	/*
-	 * There's a faint possibility that swap page was replaced before
-	 * caller locked it: caller will come back later with the right page.
-	 */
-	if (unlikely(!PageSwapCache(page) || page_private(page) != swap.val))
-		goto out;
+	if (list_empty(&shmem_swaplist))
+		return 0;
 
+	mutex_lock(&shmem_swaplist_mutex);
+	p = &shmem_swaplist;
 	/*
-	 * Charge page using GFP_KERNEL while we can wait, before taking
-	 * the shmem_swaplist_mutex which might hold up shmem_writepage().
-	 * Charged back to the user (not to caller) when swap account is used.
+	 * The extra refcount on the inode is necessary to safely dereference
+	 * p->next after re-acquiring the lock. New shmem inodes with swap
+	 * get added to the end of the list and we will scan them all.
 	 */
-	error = mem_cgroup_try_charge(page, current->mm, GFP_KERNEL, &memcg);
-	if (error)
-		goto out;
-	/* No radix_tree_preload: swap entry keeps a place for page in tree */
-	error = -EAGAIN;
-
-	mutex_lock(&shmem_swaplist_mutex);
-	list_for_each_safe(this, next, &shmem_swaplist) {
-		info = list_entry(this, struct shmem_inode_info, swaplist);
+	while (!error && (p = p->next) != &shmem_swaplist) {
+		info = list_entry(p, struct shmem_inode_info, swaplist);
+		inode = igrab(&info->vfs_inode);
+		if (!inode)
+			continue;
+		mutex_unlock(&shmem_swaplist_mutex);
+		if (prev_inode)
+			iput(prev_inode);
 		if (info->swapped)
-			error = shmem_unuse_inode(info, swap, &page);
-		else
-			list_del_init(&info->swaplist);
+			error = shmem_unuse_inode(inode, type);
 		cond_resched();
-		if (error != -EAGAIN)
+		prev_inode = inode;
+		if (error)
 			break;
-		/* found nothing in this: move on to search the next */
+		mutex_lock(&shmem_swaplist_mutex);
+	}
+	mutex_unlock(&shmem_swaplist_mutex);
+
+	if (prev_inode)
+		iput(prev_inode);
+
+	/* Remove now swapless inodes from the swaplist. */
+	mutex_lock(&shmem_swaplist_mutex);
+	list_for_each_safe(p, next, &shmem_swaplist) {
+		info = list_entry(p, struct shmem_inode_info, swaplist);
+		if (!info->swapped)
+			list_del_init(&info->swaplist);
 	}
 	mutex_unlock(&shmem_swaplist_mutex);
 
-	if (error) {
-		if (error != -ENOMEM)
-			error = 0;
-		mem_cgroup_cancel_charge(page, memcg);
-	} else
-		mem_cgroup_commit_charge(page, memcg, true);
-out:
-	unlock_page(page);
-	page_cache_release(page);
 	return error;
 }
 
@@ -1109,7 +1093,7 @@ repeat:
 		}
 		if (!PageUptodate(page)) {
 			error = -EIO;
-			goto failed;
+
 		}
 		wait_on_page_writeback(page);
 
@@ -3287,7 +3271,7 @@ int __init shmem_init(void)
 	return 0;
 }
 
-int shmem_unuse(swp_entry_t swap, struct page *page)
+int shmem_unuse(unsigned int type)
 {
 	return 0;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8798b2e..966862c 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1146,34 +1146,72 @@ out_nolock:
 
 static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+				unsigned int type)
 {
-	pte_t swp_pte = swp_entry_to_pte(entry);
+	struct page *page;
+	swp_entry_t entry;
+	unsigned int found_type;
 	pte_t *pte;
+	struct swap_info_struct *si;
+	volatile unsigned char *swap_map;
+	unsigned char swcount;
+	unsigned long offset;
 	int ret = 0;
 
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
+		if (is_swap_pte(*pte)) {
+			entry = pte_to_swp_entry(*pte);
+			found_type = swp_type(entry);
+			offset = swp_offset(entry);
+		} else
+			continue;
+		if (found_type != type)
+			continue;
+
+		swap_map = &si->swap_map[offset];
+		if (!swap_count(*swap_map))
+			continue;
+		swcount = *swap_map;
+
+		pte_unmap(pte);
+		page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE,
+				vma, addr);
+		if (!page) {
+			if (!swcount || swcount == SWAP_MAP_BAD)
+				goto try_next;
+			return -ENOMEM;
+		}
 		/*
-		 * swapoff spends a _lot_ of time in this loop!
-		 * Test inline before going to call unuse_pte.
+		 * Wait for and lock page.  When do_swap_page races with
+		 * try_to_unuse, do_swap_page can handle the fault much
+		 * faster than try_to_unuse can locate the entry.  This
+		 * apparently redundant "wait_on_page_locked" lets try_to_unuse
+		 * defer to do_swap_page in such a case - in some tests,
+		 * do_swap_page and try_to_unuse repeatedly compete.
 		 */
-		if (unlikely(maybe_same_pte(*pte, swp_pte))) {
-			pte_unmap(pte);
-			ret = unuse_pte(vma, pmd, addr, entry, page);
-			if (ret)
-				goto out;
-			pte = pte_offset_map(pmd, addr);
+		wait_on_page_locked(page);
+		wait_on_page_writeback(page);
+		lock_page(page);
+		wait_on_page_writeback(page);
+		ret = unuse_pte(vma, pmd, addr, entry, page);
+		if (ret < 0) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto out;
 		}
+
+		if (PageSwapCache(page) && (swap_count(*swap_map) == 0)) {
+			wait_on_page_writeback(page);
+			delete_from_swap_cache(page);
+		}
+
+		SetPageDirty(page);
+		unlock_page(page);
+		page_cache_release(page);
+try_next:
+		pte = pte_offset_map(pmd, addr);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap(pte - 1);
 out:
@@ -1182,7 +1220,7 @@ out:
 
 static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+				unsigned int type)
 {
 	pmd_t *pmd;
 	unsigned long next;
@@ -1193,8 +1231,8 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
-		ret = unuse_pte_range(vma, pmd, addr, next, entry, page);
-		if (ret)
+		ret = unuse_pte_range(vma, pmd, addr, next, type);
+		if (ret < 0)
 			return ret;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
@@ -1202,7 +1240,7 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 
 static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
-				swp_entry_t entry, struct page *page)
+				unsigned int type)
 {
 	pud_t *pud;
 	unsigned long next;
@@ -1213,65 +1251,50 @@ static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		ret = unuse_pmd_range(vma, pud, addr, next, entry, page);
-		if (ret)
+		ret = unuse_pmd_range(vma, pud, addr, next, type);
+		if (ret < 0)
 			return ret;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_vma(struct vm_area_struct *vma,
-				swp_entry_t entry, struct page *page)
+static int unuse_vma(struct vm_area_struct *vma, unsigned int type)
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
-		ret = unuse_pud_range(vma, pgd, addr, next, entry, page);
-		if (ret)
+		ret = unuse_pud_range(vma, pgd, addr, next, type);
+		if (ret < 0)
 			return ret;
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_mm(struct mm_struct *mm,
-				swp_entry_t entry, struct page *page)
+static int unuse_mm(struct mm_struct *mm, unsigned int type)
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
+			ret = unuse_vma(vma, type);
+			if (ret)
+				break;
+		}
 	}
 	up_read(&mm->mmap_sem);
-	return (ret < 0)? ret: 0;
+
+	return ret;
 }
 
 /*
@@ -1319,234 +1342,101 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
 	return i;
 }
 
-/*
- * We completely avoid races by reading each swap page in advance,
- * and then search for the process using it.  All the necessary
- * page table adjustments can then be made atomically.
- *
- * if the boolean frontswap is true, only unuse pages_to_unuse pages;
- * pages_to_unuse==0 means all pages; ignored if frontswap is false
- */
+/* TODO: frontswap */
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
-	atomic_inc(&init_mm.mm_users);
+retry:
+	retval = shmem_unuse(type);
+	if (retval)
+		goto out;
 
-	/*
-	 * Keep on scanning until all entries have gone.  Usually,
-	 * one pass through swap_map is enough, but not necessarily:
-	 * there are races when an instance of an entry might be missed.
-	 */
-	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
+	prev_mm = &init_mm;
+	atomic_inc(&prev_mm->mm_users);
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
-					GFP_HIGHUSER_MOVABLE, NULL, 0);
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
-
-		/*
-		 * Don't hold on to start_mm if it looks like exiting.
-		 */
-		if (atomic_read(&start_mm->mm_users) == 1) {
-			mmput(start_mm);
-			start_mm = &init_mm;
-			atomic_inc(&init_mm.mm_users);
-		}
+		mm = list_entry(p, struct mm_struct, mmlist);
+		if (!atomic_inc_not_zero(&mm->mm_users))
+			continue;
+		spin_unlock(&mmlist_lock);
+		mmput(prev_mm);
+		prev_mm = mm;
 
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
+		retval = unuse_mm(mm, type);
+		if (retval)
+			goto out_put;
 
 		/*
-		 * Remove all references to entry.
+		 * Make sure that we aren't completely killing
+		 * interactive performance.
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
-			atomic_inc(&new_start_mm->mm_users);
-			atomic_inc(&prev_mm->mm_users);
-			spin_lock(&mmlist_lock);
-			while (swap_count(*swap_map) && !retval &&
-					(p = p->next) != &start_mm->mmlist) {
-				mm = list_entry(p, struct mm_struct, mmlist);
-				if (!atomic_inc_not_zero(&mm->mm_users))
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
-					atomic_inc(&mm->mm_users);
-					new_start_mm = mm;
-					set_start_mm = 0;
-				}
-				spin_lock(&mmlist_lock);
-			}
-			spin_unlock(&mmlist_lock);
-			mmput(prev_mm);
-			mmput(start_mm);
-			start_mm = new_start_mm;
-		}
-		if (retval) {
-			unlock_page(page);
-			page_cache_release(page);
-			break;
-		}
+		cond_resched();
+		spin_lock(&mmlist_lock);
+	}
+	spin_unlock(&mmlist_lock);
 
+out_put:
+	mmput(prev_mm);
+	if (retval)
+		goto out;
+	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		/*
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
+		 * under global memory pressure, swap entries
+		 * can be reinserted back into process space
+		 * after the mmlist loop above passes over them.
+		 * This loop will then repeat fruitlessly,
+		 * reading in from swap and deleting from swapcache,
+		 * but doing nothing to actually free up the swap.
+		 * In this case, go over the mmlist loop again.
 		 */
-		if (swap_count(*swap_map) &&
-		     PageDirty(page) && PageSwapCache(page)) {
-			struct writeback_control wbc = {
-				.sync_mode = WB_SYNC_NONE,
-			};
-
-			swap_writepage(page, &wbc);
-			lock_page(page);
-			wait_on_page_writeback(page);
+		if (i < oldi) {
+			retries++;
+			if (retries > MAX_RETRIES)
+				goto out;
+			goto retry;
 		}
-
+		entry = swp_entry(type, i);
+		page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
+				NULL, 0);
+		if (!page)
+			continue;
 		/*
 		 * It is conceivable that a racing task removed this page from
-		 * swap cache just before we acquired the page lock at the top,
-		 * or while we dropped it in unuse_mm().  The page might even
-		 * be back in swap cache on another swap area: that we must not
-		 * delete, since it may not have been written out to swap yet.
+		 * swap cache just before we acquired the page lock. The page
+		 * might even be back in swap cache on another swap area; that
+		 * we must not delete, since it may not have been written
+		 * out to swap yet.
 		 */
+		lock_page(page);
 		if (PageSwapCache(page) &&
-		    likely(page_private(page) == entry.val))
+		    likely(page_private(page) == entry.val)) {
+			wait_on_page_writeback(page);
 			delete_from_swap_cache(page);
-
-		/*
-		 * So we could skip searching mms once swap count went
-		 * to 1, we did not mark any present ptes as dirty: must
-		 * mark page dirty so shrink_page_list will preserve it.
-		 */
-		SetPageDirty(page);
+		}
 		unlock_page(page);
 		page_cache_release(page);
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
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
