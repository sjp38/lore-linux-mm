Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D14D6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 02:47:01 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p5A6ktxR031210
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 23:46:55 -0700
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by kpbe18.cbf.corp.google.com with ESMTP id p5A6kms5013291
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 23:46:53 -0700
Received: by pwj4 with SMTP id 4so1208294pwj.30
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 23:46:53 -0700 (PDT)
Date: Thu, 9 Jun 2011 23:46:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH v2 6/7] tmpfs: simplify filepage/swappage
In-Reply-To: <alpine.LSU.2.00.1106091539140.2200@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106092345090.12180@sister.anvils>
References: <alpine.LSU.2.00.1106091529060.2200@sister.anvils> <alpine.LSU.2.00.1106091539140.2200@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

We can now simplify shmem_getpage_gfp(): there is no longer a dilemma
of filepage passed in via shmem_readpage(), then swappage found, which
must then be copied over to it.

Although at first it's tempting to replace the **pagep arg by returning
struct page *, that makes a mess of IS_ERR_OR_NULL(page)s in all the
callers, so leave as is.

Insert BUG_ON(!PageUptodate) when we find and lock page: some of the
complication came from uninitialized pages inserted into filecache
prior to readpage; but now we're in control, and only release pagelock
on filecache once it's uptodate (if an error occurs in reading back
from swap, the page remains in swapcache, never moved to filecache).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |  237 +++++++++++++++++++++++----------------------------
 1 file changed, 108 insertions(+), 129 deletions(-)

--- linux.orig/mm/shmem.c	2011-06-09 23:17:08.000000000 -0700
+++ linux/mm/shmem.c	2011-06-09 23:31:44.056402814 -0700
@@ -1246,41 +1246,47 @@ static int shmem_getpage_gfp(struct inod
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	struct shmem_sb_info *sbinfo;
-	struct page *filepage;
-	struct page *swappage;
+	struct page *page;
 	struct page *prealloc_page = NULL;
 	swp_entry_t *entry;
 	swp_entry_t swap;
 	int error;
+	int ret;
 
 	if (idx >= SHMEM_MAX_INDEX)
 		return -EFBIG;
 repeat:
-	filepage = find_lock_page(mapping, idx);
-	if (filepage && PageUptodate(filepage))
-		goto done;
-	if (!filepage) {
+	page = find_lock_page(mapping, idx);
+	if (page) {
 		/*
-		 * Try to preload while we can wait, to not make a habit of
-		 * draining atomic reserves; but don't latch on to this cpu.
+		 * Once we can get the page lock, it must be uptodate:
+		 * if there were an error in reading back from swap,
+		 * the page would not be inserted into the filecache.
 		 */
-		error = radix_tree_preload(gfp & GFP_RECLAIM_MASK);
-		if (error)
-			goto failed;
-		radix_tree_preload_end();
-		if (sgp != SGP_READ && !prealloc_page) {
-			prealloc_page = shmem_alloc_page(gfp, info, idx);
-			if (prealloc_page) {
-				SetPageSwapBacked(prealloc_page);
-				if (mem_cgroup_cache_charge(prealloc_page,
-						current->mm, GFP_KERNEL)) {
-					page_cache_release(prealloc_page);
-					prealloc_page = NULL;
-				}
+		BUG_ON(!PageUptodate(page));
+		goto done;
+	}
+
+	/*
+	 * Try to preload while we can wait, to not make a habit of
+	 * draining atomic reserves; but don't latch on to this cpu.
+	 */
+	error = radix_tree_preload(gfp & GFP_RECLAIM_MASK);
+	if (error)
+		goto out;
+	radix_tree_preload_end();
+
+	if (sgp != SGP_READ && !prealloc_page) {
+		prealloc_page = shmem_alloc_page(gfp, info, idx);
+		if (prealloc_page) {
+			SetPageSwapBacked(prealloc_page);
+			if (mem_cgroup_cache_charge(prealloc_page,
+					current->mm, GFP_KERNEL)) {
+				page_cache_release(prealloc_page);
+				prealloc_page = NULL;
 			}
 		}
 	}
-	error = 0;
 
 	spin_lock(&info->lock);
 	shmem_recalc_inode(inode);
@@ -1288,21 +1294,21 @@ repeat:
 	if (IS_ERR(entry)) {
 		spin_unlock(&info->lock);
 		error = PTR_ERR(entry);
-		goto failed;
+		goto out;
 	}
 	swap = *entry;
 
 	if (swap.val) {
 		/* Look it up and read it in.. */
-		swappage = lookup_swap_cache(swap);
-		if (!swappage) {
+		page = lookup_swap_cache(swap);
+		if (!page) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			/* here we actually do the io */
 			if (fault_type)
 				*fault_type |= VM_FAULT_MAJOR;
-			swappage = shmem_swapin(swap, gfp, info, idx);
-			if (!swappage) {
+			page = shmem_swapin(swap, gfp, info, idx);
+			if (!page) {
 				spin_lock(&info->lock);
 				entry = shmem_swp_alloc(info, idx, sgp, gfp);
 				if (IS_ERR(entry))
@@ -1314,62 +1320,42 @@ repeat:
 				}
 				spin_unlock(&info->lock);
 				if (error)
-					goto failed;
+					goto out;
 				goto repeat;
 			}
-			wait_on_page_locked(swappage);
-			page_cache_release(swappage);
+			wait_on_page_locked(page);
+			page_cache_release(page);
 			goto repeat;
 		}
 
 		/* We have to do this with page locked to prevent races */
-		if (!trylock_page(swappage)) {
+		if (!trylock_page(page)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
-			wait_on_page_locked(swappage);
-			page_cache_release(swappage);
+			wait_on_page_locked(page);
+			page_cache_release(page);
 			goto repeat;
 		}
-		if (PageWriteback(swappage)) {
+		if (PageWriteback(page)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
-			wait_on_page_writeback(swappage);
-			unlock_page(swappage);
-			page_cache_release(swappage);
+			wait_on_page_writeback(page);
+			unlock_page(page);
+			page_cache_release(page);
 			goto repeat;
 		}
-		if (!PageUptodate(swappage)) {
+		if (!PageUptodate(page)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
-			unlock_page(swappage);
-			page_cache_release(swappage);
+			unlock_page(page);
+			page_cache_release(page);
 			error = -EIO;
-			goto failed;
+			goto out;
 		}
 
-		if (filepage) {
-			shmem_swp_set(info, entry, 0);
-			shmem_swp_unmap(entry);
-			delete_from_swap_cache(swappage);
-			spin_unlock(&info->lock);
-			copy_highpage(filepage, swappage);
-			unlock_page(swappage);
-			page_cache_release(swappage);
-			flush_dcache_page(filepage);
-			SetPageUptodate(filepage);
-			set_page_dirty(filepage);
-			swap_free(swap);
-		} else if (!(error = add_to_page_cache_locked(swappage, mapping,
-					idx, GFP_NOWAIT))) {
-			info->flags |= SHMEM_PAGEIN;
-			shmem_swp_set(info, entry, 0);
-			shmem_swp_unmap(entry);
-			delete_from_swap_cache(swappage);
-			spin_unlock(&info->lock);
-			filepage = swappage;
-			set_page_dirty(filepage);
-			swap_free(swap);
-		} else {
+		error = add_to_page_cache_locked(page, mapping,
+						 idx, GFP_NOWAIT);
+		if (error) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			if (error == -ENOMEM) {
@@ -1378,28 +1364,33 @@ repeat:
 				 * call memcg's OOM if needed.
 				 */
 				error = mem_cgroup_shmem_charge_fallback(
-								swappage,
-								current->mm,
-								gfp);
+						page, current->mm, gfp);
 				if (error) {
-					unlock_page(swappage);
-					page_cache_release(swappage);
-					goto failed;
+					unlock_page(page);
+					page_cache_release(page);
+					goto out;
 				}
 			}
-			unlock_page(swappage);
-			page_cache_release(swappage);
+			unlock_page(page);
+			page_cache_release(page);
 			goto repeat;
 		}
-	} else if (sgp == SGP_READ && !filepage) {
+
+		info->flags |= SHMEM_PAGEIN;
+		shmem_swp_set(info, entry, 0);
+		shmem_swp_unmap(entry);
+		delete_from_swap_cache(page);
+		spin_unlock(&info->lock);
+		set_page_dirty(page);
+		swap_free(swap);
+
+	} else if (sgp == SGP_READ) {
 		shmem_swp_unmap(entry);
-		filepage = find_get_page(mapping, idx);
-		if (filepage &&
-		    (!PageUptodate(filepage) || !trylock_page(filepage))) {
+		page = find_get_page(mapping, idx);
+		if (page && !trylock_page(page)) {
 			spin_unlock(&info->lock);
-			wait_on_page_locked(filepage);
-			page_cache_release(filepage);
-			filepage = NULL;
+			wait_on_page_locked(page);
+			page_cache_release(page);
 			goto repeat;
 		}
 		spin_unlock(&info->lock);
@@ -1417,56 +1408,52 @@ repeat:
 		} else if (shmem_acct_block(info->flags))
 			goto nospace;
 
-		if (!filepage) {
-			int ret;
-
-			filepage = prealloc_page;
-			prealloc_page = NULL;
+		page = prealloc_page;
+		prealloc_page = NULL;
 
-			entry = shmem_swp_alloc(info, idx, sgp, gfp);
-			if (IS_ERR(entry))
-				error = PTR_ERR(entry);
-			else {
-				swap = *entry;
-				shmem_swp_unmap(entry);
-			}
-			ret = error || swap.val;
-			if (ret)
-				mem_cgroup_uncharge_cache_page(filepage);
-			else
-				ret = add_to_page_cache_lru(filepage, mapping,
+		entry = shmem_swp_alloc(info, idx, sgp, gfp);
+		if (IS_ERR(entry))
+			error = PTR_ERR(entry);
+		else {
+			swap = *entry;
+			shmem_swp_unmap(entry);
+		}
+		ret = error || swap.val;
+		if (ret)
+			mem_cgroup_uncharge_cache_page(page);
+		else
+			ret = add_to_page_cache_lru(page, mapping,
 						idx, GFP_NOWAIT);
-			/*
-			 * At add_to_page_cache_lru() failure, uncharge will
-			 * be done automatically.
-			 */
-			if (ret) {
-				shmem_unacct_blocks(info->flags, 1);
-				shmem_free_blocks(inode, 1);
-				spin_unlock(&info->lock);
-				page_cache_release(filepage);
-				filepage = NULL;
-				if (error)
-					goto failed;
-				goto repeat;
-			}
-			info->flags |= SHMEM_PAGEIN;
+		/*
+		 * At add_to_page_cache_lru() failure,
+		 * uncharge will be done automatically.
+		 */
+		if (ret) {
+			shmem_unacct_blocks(info->flags, 1);
+			shmem_free_blocks(inode, 1);
+			spin_unlock(&info->lock);
+			page_cache_release(page);
+			if (error)
+				goto out;
+			goto repeat;
 		}
 
+		info->flags |= SHMEM_PAGEIN;
 		info->alloced++;
 		spin_unlock(&info->lock);
-		clear_highpage(filepage);
-		flush_dcache_page(filepage);
-		SetPageUptodate(filepage);
+		clear_highpage(page);
+		flush_dcache_page(page);
+		SetPageUptodate(page);
 		if (sgp == SGP_DIRTY)
-			set_page_dirty(filepage);
+			set_page_dirty(page);
+
 	} else {
 		spin_unlock(&info->lock);
 		error = -ENOMEM;
 		goto out;
 	}
 done:
-	*pagep = filepage;
+	*pagep = page;
 	error = 0;
 out:
 	if (prealloc_page) {
@@ -1482,21 +1469,13 @@ nospace:
 	 * but must also avoid reporting a spurious ENOSPC while working on a
 	 * full tmpfs.
 	 */
-	if (!filepage) {
-		struct page *page = find_get_page(mapping, idx);
-		if (page) {
-			spin_unlock(&info->lock);
-			page_cache_release(page);
-			goto repeat;
-		}
-	}
+	page = find_get_page(mapping, idx);
 	spin_unlock(&info->lock);
-	error = -ENOSPC;
-failed:
-	if (filepage) {
-		unlock_page(filepage);
-		page_cache_release(filepage);
+	if (page) {
+		page_cache_release(page);
+		goto repeat;
 	}
+	error = -ENOSPC;
 	goto out;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
