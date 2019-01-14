Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0A6F8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:37:49 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id k133so9737010ite.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:37:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b82sor1239921itb.10.2019.01.14.07.37.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 07:37:47 -0800 (PST)
From: Vineeth Remanan Pillai <vpillai@digitalocean.com>
Subject: [PATCH v4 1/2] mm: Refactor swap-in logic out of shmem_getpage_gfp
Date: Mon, 14 Jan 2019 15:31:28 +0000
Message-Id: <20190114153129.4852-1-vpillai@digitalocean.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Vineeth Remanan Pillai <vpillai@digitalocean.com>, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

swap-in logic could be reused independently without rest of the logic
in shmem_getpage_gfp. So lets refactor it out as an independent
function.

Signed-off-by: Vineeth Remanan Pillai <vpillai@digitalocean.com>
---
 mm/shmem.c | 449 +++++++++++++++++++++++++++++------------------------
 1 file changed, 244 insertions(+), 205 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 6ece1e2fe76e..7cd7ee69f670 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -123,6 +123,10 @@ static unsigned long shmem_default_max_inodes(void)
 static bool shmem_should_replace_page(struct page *page, gfp_t gfp);
 static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 				struct shmem_inode_info *info, pgoff_t index);
+static int shmem_swapin_page(struct inode *inode, pgoff_t index,
+			     struct page **pagep, enum sgp_type sgp,
+			     gfp_t gfp, struct vm_area_struct *vma,
+			     vm_fault_t *fault_type);
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp,
 		gfp_t gfp, struct vm_area_struct *vma,
@@ -1575,6 +1579,116 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	return error;
 }
 
+/*
+ * Swap in the page pointed to by *pagep.
+ * Caller has to make sure that *pagep contains a valid swapped page.
+ * Returns 0 and the page in pagep if success. On failure, returns the
+ * the error code and NULL in *pagep.
+ */
+static int shmem_swapin_page(struct inode *inode, pgoff_t index,
+			     struct page **pagep, enum sgp_type sgp,
+			     gfp_t gfp, struct vm_area_struct *vma,
+			     vm_fault_t *fault_type)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct mm_struct *charge_mm = vma ? vma->vm_mm : current->mm;
+	struct mem_cgroup *memcg;
+	struct page *page;
+	swp_entry_t swap;
+	int error;
+
+	VM_BUG_ON(!*pagep || !xa_is_value(*pagep));
+	swap = radix_to_swp_entry(*pagep);
+	*pagep = NULL;
+
+	/* Look it up and read it in.. */
+	page = lookup_swap_cache(swap, NULL, 0);
+	if (!page) {
+		/* Or update major stats only when swapin succeeds?? */
+		if (fault_type) {
+			*fault_type |= VM_FAULT_MAJOR;
+			count_vm_event(PGMAJFAULT);
+			count_memcg_event_mm(charge_mm, PGMAJFAULT);
+		}
+		/* Here we actually start the io */
+		page = shmem_swapin(swap, gfp, info, index);
+		if (!page) {
+			error = -ENOMEM;
+			goto failed;
+		}
+	}
+
+	/* We have to do this with page locked to prevent races */
+	lock_page(page);
+	if (!PageSwapCache(page) || page_private(page) != swap.val ||
+	    !shmem_confirm_swap(mapping, index, swap)) {
+		error = -EEXIST;
+		goto unlock;
+	}
+	if (!PageUptodate(page)) {
+		error = -EIO;
+		goto failed;
+	}
+	wait_on_page_writeback(page);
+
+	if (shmem_should_replace_page(page, gfp)) {
+		error = shmem_replace_page(&page, gfp, info, index);
+		if (error)
+			goto failed;
+	}
+
+	error = mem_cgroup_try_charge_delay(page, charge_mm, gfp, &memcg,
+					    false);
+	if (!error) {
+		error = shmem_add_to_page_cache(page, mapping, index,
+						swp_to_radix_entry(swap), gfp);
+		/*
+		 * We already confirmed swap under page lock, and make
+		 * no memory allocation here, so usually no possibility
+		 * of error; but free_swap_and_cache() only trylocks a
+		 * page, so it is just possible that the entry has been
+		 * truncated or holepunched since swap was confirmed.
+		 * shmem_undo_range() will have done some of the
+		 * unaccounting, now delete_from_swap_cache() will do
+		 * the rest.
+		 */
+		if (error) {
+			mem_cgroup_cancel_charge(page, memcg, false);
+			delete_from_swap_cache(page);
+		}
+	}
+	if (error)
+		goto failed;
+
+	mem_cgroup_commit_charge(page, memcg, true, false);
+
+	spin_lock_irq(&info->lock);
+	info->swapped--;
+	shmem_recalc_inode(inode);
+	spin_unlock_irq(&info->lock);
+
+	if (sgp == SGP_WRITE)
+		mark_page_accessed(page);
+
+	delete_from_swap_cache(page);
+	set_page_dirty(page);
+	swap_free(swap);
+
+	*pagep = page;
+	return 0;
+failed:
+	if (!shmem_confirm_swap(mapping, index, swap))
+		error = -EEXIST;
+unlock:
+	if (page) {
+		unlock_page(page);
+		put_page(page);
+	}
+
+	return error;
+}
+
 /*
  * shmem_getpage_gfp - find page in cache, or get from swap, or allocate
  *
@@ -1596,7 +1710,6 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct mm_struct *charge_mm;
 	struct mem_cgroup *memcg;
 	struct page *page;
-	swp_entry_t swap;
 	enum sgp_type sgp_huge = sgp;
 	pgoff_t hindex = index;
 	int error;
@@ -1608,17 +1721,23 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	if (sgp == SGP_NOHUGE || sgp == SGP_HUGE)
 		sgp = SGP_CACHE;
 repeat:
-	swap.val = 0;
+	if (sgp <= SGP_CACHE &&
+	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
+		return -EINVAL;
+	}
+
+	sbinfo = SHMEM_SB(inode->i_sb);
+	charge_mm = vma ? vma->vm_mm : current->mm;
+
 	page = find_lock_entry(mapping, index);
 	if (xa_is_value(page)) {
-		swap = radix_to_swp_entry(page);
-		page = NULL;
-	}
+		error = shmem_swapin_page(inode, index, &page,
+					  sgp, gfp, vma, fault_type);
+		if (error == -EEXIST)
+			goto repeat;
 
-	if (sgp <= SGP_CACHE &&
-	    ((loff_t)index << PAGE_SHIFT) >= i_size_read(inode)) {
-		error = -EINVAL;
-		goto unlock;
+		*pagep = page;
+		return error;
 	}
 
 	if (page && sgp == SGP_WRITE)
@@ -1632,7 +1751,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		put_page(page);
 		page = NULL;
 	}
-	if (page || (sgp == SGP_READ && !swap.val)) {
+	if (page || sgp == SGP_READ) {
 		*pagep = page;
 		return 0;
 	}
@@ -1641,215 +1760,138 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	 * Fast cache lookup did not find it:
 	 * bring it back from swap or allocate.
 	 */
-	sbinfo = SHMEM_SB(inode->i_sb);
-	charge_mm = vma ? vma->vm_mm : current->mm;
-
-	if (swap.val) {
-		/* Look it up and read it in.. */
-		page = lookup_swap_cache(swap, NULL, 0);
-		if (!page) {
-			/* Or update major stats only when swapin succeeds?? */
-			if (fault_type) {
-				*fault_type |= VM_FAULT_MAJOR;
-				count_vm_event(PGMAJFAULT);
-				count_memcg_event_mm(charge_mm, PGMAJFAULT);
-			}
-			/* Here we actually start the io */
-			page = shmem_swapin(swap, gfp, info, index);
-			if (!page) {
-				error = -ENOMEM;
-				goto failed;
-			}
-		}
-
-		/* We have to do this with page locked to prevent races */
-		lock_page(page);
-		if (!PageSwapCache(page) || page_private(page) != swap.val ||
-		    !shmem_confirm_swap(mapping, index, swap)) {
-			error = -EEXIST;	/* try again */
-			goto unlock;
-		}
-		if (!PageUptodate(page)) {
-			error = -EIO;
-			goto failed;
-		}
-		wait_on_page_writeback(page);
-
-		if (shmem_should_replace_page(page, gfp)) {
-			error = shmem_replace_page(&page, gfp, info, index);
-			if (error)
-				goto failed;
-		}
 
-		error = mem_cgroup_try_charge_delay(page, charge_mm, gfp, &memcg,
-				false);
-		if (!error) {
-			error = shmem_add_to_page_cache(page, mapping, index,
-						swp_to_radix_entry(swap), gfp);
-			/*
-			 * We already confirmed swap under page lock, and make
-			 * no memory allocation here, so usually no possibility
-			 * of error; but free_swap_and_cache() only trylocks a
-			 * page, so it is just possible that the entry has been
-			 * truncated or holepunched since swap was confirmed.
-			 * shmem_undo_range() will have done some of the
-			 * unaccounting, now delete_from_swap_cache() will do
-			 * the rest.
-			 * Reset swap.val? No, leave it so "failed" goes back to
-			 * "repeat": reading a hole and writing should succeed.
-			 */
-			if (error) {
-				mem_cgroup_cancel_charge(page, memcg, false);
-				delete_from_swap_cache(page);
-			}
-		}
-		if (error)
-			goto failed;
-
-		mem_cgroup_commit_charge(page, memcg, true, false);
-
-		spin_lock_irq(&info->lock);
-		info->swapped--;
-		shmem_recalc_inode(inode);
-		spin_unlock_irq(&info->lock);
-
-		if (sgp == SGP_WRITE)
-			mark_page_accessed(page);
-
-		delete_from_swap_cache(page);
-		set_page_dirty(page);
-		swap_free(swap);
-
-	} else {
-		if (vma && userfaultfd_missing(vma)) {
-			*fault_type = handle_userfault(vmf, VM_UFFD_MISSING);
-			return 0;
-		}
+	if (vma && userfaultfd_missing(vma)) {
+		*fault_type = handle_userfault(vmf, VM_UFFD_MISSING);
+		return 0;
+	}
 
-		/* shmem_symlink() */
-		if (mapping->a_ops != &shmem_aops)
-			goto alloc_nohuge;
-		if (shmem_huge == SHMEM_HUGE_DENY || sgp_huge == SGP_NOHUGE)
-			goto alloc_nohuge;
-		if (shmem_huge == SHMEM_HUGE_FORCE)
+	/* shmem_symlink() */
+	if (mapping->a_ops != &shmem_aops)
+		goto alloc_nohuge;
+	if (shmem_huge == SHMEM_HUGE_DENY || sgp_huge == SGP_NOHUGE)
+		goto alloc_nohuge;
+	if (shmem_huge == SHMEM_HUGE_FORCE)
+		goto alloc_huge;
+	switch (sbinfo->huge) {
+		loff_t i_size;
+		pgoff_t off;
+	case SHMEM_HUGE_NEVER:
+		goto alloc_nohuge;
+	case SHMEM_HUGE_WITHIN_SIZE:
+		off = round_up(index, HPAGE_PMD_NR);
+		i_size = round_up(i_size_read(inode), PAGE_SIZE);
+		if (i_size >= HPAGE_PMD_SIZE &&
+		    i_size >> PAGE_SHIFT >= off)
 			goto alloc_huge;
-		switch (sbinfo->huge) {
-			loff_t i_size;
-			pgoff_t off;
-		case SHMEM_HUGE_NEVER:
-			goto alloc_nohuge;
-		case SHMEM_HUGE_WITHIN_SIZE:
-			off = round_up(index, HPAGE_PMD_NR);
-			i_size = round_up(i_size_read(inode), PAGE_SIZE);
-			if (i_size >= HPAGE_PMD_SIZE &&
-					i_size >> PAGE_SHIFT >= off)
-				goto alloc_huge;
-			/* fallthrough */
-		case SHMEM_HUGE_ADVISE:
-			if (sgp_huge == SGP_HUGE)
-				goto alloc_huge;
-			/* TODO: implement fadvise() hints */
-			goto alloc_nohuge;
-		}
+		/* fallthrough */
+	case SHMEM_HUGE_ADVISE:
+		if (sgp_huge == SGP_HUGE)
+			goto alloc_huge;
+		/* TODO: implement fadvise() hints */
+		goto alloc_nohuge;
+	}
 
 alloc_huge:
-		page = shmem_alloc_and_acct_page(gfp, inode, index, true);
-		if (IS_ERR(page)) {
-alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, inode,
-					index, false);
-		}
-		if (IS_ERR(page)) {
-			int retry = 5;
-			error = PTR_ERR(page);
-			page = NULL;
-			if (error != -ENOSPC)
-				goto failed;
-			/*
-			 * Try to reclaim some spece by splitting a huge page
-			 * beyond i_size on the filesystem.
-			 */
-			while (retry--) {
-				int ret;
-				ret = shmem_unused_huge_shrink(sbinfo, NULL, 1);
-				if (ret == SHRINK_STOP)
-					break;
-				if (ret)
-					goto alloc_nohuge;
-			}
-			goto failed;
-		}
-
-		if (PageTransHuge(page))
-			hindex = round_down(index, HPAGE_PMD_NR);
-		else
-			hindex = index;
+	page = shmem_alloc_and_acct_page(gfp, inode, index, true);
+	if (IS_ERR(page)) {
+alloc_nohuge:
+		page = shmem_alloc_and_acct_page(gfp, inode,
+						 index, false);
+	}
+	if (IS_ERR(page)) {
+		int retry = 5;
 
-		if (sgp == SGP_WRITE)
-			__SetPageReferenced(page);
+		error = PTR_ERR(page);
+		page = NULL;
+		if (error != -ENOSPC)
+			goto unlock;
+		/*
+		 * Try to reclaim some space by splitting a huge page
+		 * beyond i_size on the filesystem.
+		 */
+		while (retry--) {
+			int ret;
 
-		error = mem_cgroup_try_charge_delay(page, charge_mm, gfp, &memcg,
-				PageTransHuge(page));
-		if (error)
-			goto unacct;
-		error = shmem_add_to_page_cache(page, mapping, hindex,
-						NULL, gfp & GFP_RECLAIM_MASK);
-		if (error) {
-			mem_cgroup_cancel_charge(page, memcg,
-					PageTransHuge(page));
-			goto unacct;
+			ret = shmem_unused_huge_shrink(sbinfo, NULL, 1);
+			if (ret == SHRINK_STOP)
+				break;
+			if (ret)
+				goto alloc_nohuge;
 		}
-		mem_cgroup_commit_charge(page, memcg, false,
-				PageTransHuge(page));
-		lru_cache_add_anon(page);
+		goto unlock;
+	}
 
-		spin_lock_irq(&info->lock);
-		info->alloced += 1 << compound_order(page);
-		inode->i_blocks += BLOCKS_PER_PAGE << compound_order(page);
-		shmem_recalc_inode(inode);
-		spin_unlock_irq(&info->lock);
-		alloced = true;
+	if (PageTransHuge(page))
+		hindex = round_down(index, HPAGE_PMD_NR);
+	else
+		hindex = index;
 
-		if (PageTransHuge(page) &&
-				DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE) <
-				hindex + HPAGE_PMD_NR - 1) {
-			/*
-			 * Part of the huge page is beyond i_size: subject
-			 * to shrink under memory pressure.
-			 */
-			spin_lock(&sbinfo->shrinklist_lock);
-			/*
-			 * _careful to defend against unlocked access to
-			 * ->shrink_list in shmem_unused_huge_shrink()
-			 */
-			if (list_empty_careful(&info->shrinklist)) {
-				list_add_tail(&info->shrinklist,
-						&sbinfo->shrinklist);
-				sbinfo->shrinklist_len++;
-			}
-			spin_unlock(&sbinfo->shrinklist_lock);
-		}
+	if (sgp == SGP_WRITE)
+		__SetPageReferenced(page);
+
+	error = mem_cgroup_try_charge_delay(page, charge_mm, gfp, &memcg,
+					    PageTransHuge(page));
+	if (error)
+		goto unacct;
+	error = shmem_add_to_page_cache(page, mapping, hindex,
+					NULL, gfp & GFP_RECLAIM_MASK);
+	if (error) {
+		mem_cgroup_cancel_charge(page, memcg,
+					 PageTransHuge(page));
+		goto unacct;
+	}
+	mem_cgroup_commit_charge(page, memcg, false,
+				 PageTransHuge(page));
+	lru_cache_add_anon(page);
+
+	spin_lock_irq(&info->lock);
+	info->alloced += 1 << compound_order(page);
+	inode->i_blocks += BLOCKS_PER_PAGE << compound_order(page);
+	shmem_recalc_inode(inode);
+	spin_unlock_irq(&info->lock);
+	alloced = true;
 
+	if (PageTransHuge(page) &&
+	    DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE) <
+			hindex + HPAGE_PMD_NR - 1) {
 		/*
-		 * Let SGP_FALLOC use the SGP_WRITE optimization on a new page.
+		 * Part of the huge page is beyond i_size: subject
+		 * to shrink under memory pressure.
 		 */
-		if (sgp == SGP_FALLOC)
-			sgp = SGP_WRITE;
-clear:
+		spin_lock(&sbinfo->shrinklist_lock);
 		/*
-		 * Let SGP_WRITE caller clear ends if write does not fill page;
-		 * but SGP_FALLOC on a page fallocated earlier must initialize
-		 * it now, lest undo on failure cancel our earlier guarantee.
+		 * _careful to defend against unlocked access to
+		 * ->shrink_list in shmem_unused_huge_shrink()
 		 */
-		if (sgp != SGP_WRITE && !PageUptodate(page)) {
-			struct page *head = compound_head(page);
-			int i;
+		if (list_empty_careful(&info->shrinklist)) {
+			list_add_tail(&info->shrinklist,
+				      &sbinfo->shrinklist);
+			sbinfo->shrinklist_len++;
+		}
+		spin_unlock(&sbinfo->shrinklist_lock);
+	}
 
-			for (i = 0; i < (1 << compound_order(head)); i++) {
-				clear_highpage(head + i);
-				flush_dcache_page(head + i);
-			}
-			SetPageUptodate(head);
+	/*
+	 * Let SGP_FALLOC use the SGP_WRITE optimization on a new page.
+	 */
+	if (sgp == SGP_FALLOC)
+		sgp = SGP_WRITE;
+clear:
+	/*
+	 * Let SGP_WRITE caller clear ends if write does not fill page;
+	 * but SGP_FALLOC on a page fallocated earlier must initialize
+	 * it now, lest undo on failure cancel our earlier guarantee.
+	 */
+	if (sgp != SGP_WRITE && !PageUptodate(page)) {
+		struct page *head = compound_head(page);
+		int i;
+
+		for (i = 0; i < (1 << compound_order(head)); i++) {
+			clear_highpage(head + i);
+			flush_dcache_page(head + i);
 		}
+		SetPageUptodate(head);
 	}
 
 	/* Perhaps the file has been truncated since we checked */
@@ -1879,9 +1921,6 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, inode,
 		put_page(page);
 		goto alloc_nohuge;
 	}
-failed:
-	if (swap.val && !shmem_confirm_swap(mapping, index, swap))
-		error = -EEXIST;
 unlock:
 	if (page) {
 		unlock_page(page);
-- 
2.17.1
