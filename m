Date: Sat, 14 Oct 2006 07:59:56 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] shmem: don't zero full-page writes
Message-ID: <20061014055956.GA6014@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Just while looking at the peripheral code around the pagecache deadlocks
problem, I noticed we might be able to speed up shmem a bit. This patch
isn't well tested when shmem goes into swap, but before wasting more time on
it I just wanted to see if there is a fundamental reason why we're not doing
this?

--
Don't zero out newly allocated tmpfs pages if we're about to write a full
page to them anyway, and also don't bother to read them in from swap.
Increases aligned write bandwidth by about 30% for 4M writes to shmfs
in RAM, and about 7% for 4K writes. Not tested with swap backed shm yet;
the improvement will be much larger but it should be much less common.

Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -81,6 +81,7 @@ enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
 	SGP_WRITE,	/* may exceed i_size, may allocate page */
+	SGP_WRITE_FULL,	/* same as SGP_WRITE, full page write */
 	SGP_FAULT,	/* same as SGP_CACHE, return with page locked */
 };
 
@@ -348,7 +349,7 @@ static swp_entry_t *shmem_swp_alloc(stru
 	struct page *page = NULL;
 	swp_entry_t *entry;
 
-	if (sgp != SGP_WRITE &&
+	if (sgp != SGP_WRITE && sgp != SGP_WRITE_FULL &&
 	    ((loff_t) index << PAGE_CACHE_SHIFT) >= i_size_read(inode))
 		return ERR_PTR(-EINVAL);
 
@@ -381,7 +382,7 @@ static swp_entry_t *shmem_swp_alloc(stru
 			shmem_free_blocks(inode, 1);
 			return ERR_PTR(-ENOMEM);
 		}
-		if (sgp != SGP_WRITE &&
+		if (sgp != SGP_WRITE && sgp != SGP_WRITE_FULL &&
 		    ((loff_t) index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
 			entry = ERR_PTR(-EINVAL);
 			break;
@@ -976,7 +977,7 @@ shmem_alloc_page(gfp_t gfp, struct shmem
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
 	pvma.vm_pgoff = idx;
 	pvma.vm_end = PAGE_SIZE;
-	page = alloc_page_vma(gfp | __GFP_ZERO, &pvma, 0);
+	page = alloc_page_vma(gfp, &pvma, 0);
 	mpol_free(pvma.vm_policy);
 	return page;
 }
@@ -996,10 +997,30 @@ shmem_swapin(struct shmem_inode_info *in
 static inline struct page *
 shmem_alloc_page(gfp_t gfp,struct shmem_inode_info *info, unsigned long idx)
 {
-	return alloc_page(gfp | __GFP_ZERO);
+	return alloc_page(gfp);
 }
 #endif
 
+static inline int
+shmem_acct_page(struct inode *inode, struct shmem_inode_info *info)
+{
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+
+	if (sbinfo->max_blocks) {
+		spin_lock(&sbinfo->stat_lock);
+		if (sbinfo->free_blocks == 0 ||
+		    shmem_acct_block(info->flags)) {
+			spin_unlock(&sbinfo->stat_lock);
+			return -ENOSPC;
+		}
+		sbinfo->free_blocks--;
+		inode->i_blocks += BLOCKS_PER_PAGE;
+		spin_unlock(&sbinfo->stat_lock);
+	} else if (shmem_acct_block(info->flags)) {
+		return -ENOSPC;
+	}
+	return 0;
+}
 /*
  * shmem_getpage - either get the page from swap or allocate a new one
  *
@@ -1012,12 +1033,13 @@ static int shmem_getpage(struct inode *i
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	struct shmem_sb_info *sbinfo;
+	struct page *cache = NULL;
 	struct page *filepage = *pagep;
 	struct page *swappage;
 	swp_entry_t *entry;
 	swp_entry_t swap;
 	int error;
+	int free_swap;
 
 	if (idx >= SHMEM_MAX_INDEX)
 		return -EFBIG;
@@ -1034,10 +1056,26 @@ static int shmem_getpage(struct inode *i
 	 * and may need to be copied from the swappage read in.
 	 */
 repeat:
+	free_swap = 0;
 	if (!filepage)
 		filepage = find_lock_page(mapping, idx);
-	if (filepage && PageUptodate(filepage))
-		goto done;
+	if (filepage) {
+		if (PageUptodate(filepage) || sgp == SGP_WRITE_FULL)
+			goto done;
+	} else if (sgp != SGP_QUICK && sgp != SGP_READ) {
+		gfp_t gfp = mapping_gfp_mask(mapping);
+		if (sgp != SGP_WRITE_FULL)
+			gfp |= __GFP_ZERO;
+		cache = shmem_alloc_page(mapping_gfp_mask(mapping), info, idx);
+		if (sgp != SGP_WRITE_FULL) {
+			flush_dcache_page(filepage);
+			SetPageUptodate(filepage); /* could be non-atomic */
+		}
+
+		if (!cache)
+			return -ENOMEM;
+	}
+
 	error = 0;
 	if (sgp == SGP_QUICK)
 		goto failed;
@@ -1056,6 +1094,12 @@ repeat:
 		/* Look it up and read it in.. */
 		swappage = lookup_swap_cache(swap);
 		if (!swappage) {
+			if (sgp == SGP_WRITE_FULL) {
+				/* May throw away the backing swap */
+				free_swap = 1;
+				goto not_swap_backed;
+			}
+
 			shmem_swp_unmap(entry);
 			/* here we actually do the io */
 			if (type && *type == VM_FAULT_MINOR) {
@@ -1154,63 +1198,38 @@ repeat:
 		spin_unlock(&info->lock);
 	} else {
 		shmem_swp_unmap(entry);
-		sbinfo = SHMEM_SB(inode->i_sb);
-		if (sbinfo->max_blocks) {
-			spin_lock(&sbinfo->stat_lock);
-			if (sbinfo->free_blocks == 0 ||
-			    shmem_acct_block(info->flags)) {
-				spin_unlock(&sbinfo->stat_lock);
-				spin_unlock(&info->lock);
-				error = -ENOSPC;
-				goto failed;
-			}
-			sbinfo->free_blocks--;
-			inode->i_blocks += BLOCKS_PER_PAGE;
-			spin_unlock(&sbinfo->stat_lock);
-		} else if (shmem_acct_block(info->flags)) {
+		error = shmem_acct_page(inode, info);
+		if (error) {
 			spin_unlock(&info->lock);
-			error = -ENOSPC;
 			goto failed;
 		}
 
 		if (!filepage) {
-			spin_unlock(&info->lock);
-			filepage = shmem_alloc_page(mapping_gfp_mask(mapping),
-						    info,
-						    idx);
-			if (!filepage) {
-				shmem_unacct_blocks(info->flags, 1);
-				shmem_free_blocks(inode, 1);
-				error = -ENOMEM;
-				goto failed;
-			}
-
-			spin_lock(&info->lock);
-			entry = shmem_swp_alloc(info, idx, sgp);
-			if (IS_ERR(entry))
-				error = PTR_ERR(entry);
-			else {
-				swap = *entry;
-				shmem_swp_unmap(entry);
-			}
-			if (error || swap.val || 0 != add_to_page_cache_lru(
-					filepage, mapping, idx, GFP_ATOMIC)) {
+not_swap_backed:
+			BUG_ON(!cache);
+			filepage = cache;
+			if (add_to_page_cache_lru(filepage, mapping,
+							idx, GFP_ATOMIC)) {
+				if (free_swap)
+					shmem_swp_unmap(entry);
 				spin_unlock(&info->lock);
-				page_cache_release(filepage);
 				shmem_unacct_blocks(info->flags, 1);
 				shmem_free_blocks(inode, 1);
 				filepage = NULL;
-				if (error)
-					goto failed;
 				goto repeat;
 			}
+			cache = NULL;
 			info->flags |= SHMEM_PAGEIN;
 		}
 
 		info->alloced++;
+		if (free_swap) {
+			shmem_swp_set(info, entry, 0);
+			shmem_swp_unmap(entry);
+		}
 		spin_unlock(&info->lock);
-		flush_dcache_page(filepage);
-		SetPageUptodate(filepage);
+		if (free_swap)
+			swap_free(swap);
 	}
 done:
 	if (*pagep != filepage) {
@@ -1219,14 +1238,20 @@ done:
 			unlock_page(filepage);
 
 	}
-	return 0;
+
+	error = 0;
+out:
+	if (cache)
+		page_cache_release(cache);
+
+	return error;
 
 failed:
 	if (*pagep != filepage) {
 		unlock_page(filepage);
 		page_cache_release(filepage);
 	}
-	return error;
+	goto out;
 }
 
 struct page *shmem_fault(struct vm_area_struct *vma, struct fault_data *fdata)
@@ -1379,7 +1404,9 @@ static int
 shmem_prepare_write(struct file *file, struct page *page, unsigned offset, unsigned to)
 {
 	struct inode *inode = page->mapping->host;
-	return shmem_getpage(inode, page->index, &page, SGP_WRITE, NULL);
+	enum sgp_type sgp = (to - offset == PAGE_CACHE_SIZE) ?
+						SGP_WRITE_FULL : SGP_WRITE;
+	return shmem_getpage(inode, page->index, &page, sgp, NULL);
 }
 
 static ssize_t
@@ -1412,8 +1439,10 @@ shmem_file_write(struct file *file, cons
 	inode->i_ctime = inode->i_mtime = CURRENT_TIME;
 
 	do {
+		volatile unsigned char dummy;
 		struct page *page = NULL;
 		unsigned long bytes, index, offset;
+		enum sgp_type sgp;
 		char *kaddr;
 		int left;
 
@@ -1429,26 +1458,19 @@ shmem_file_write(struct file *file, cons
 		 * But it still may be a good idea to prefault below.
 		 */
 
-		err = shmem_getpage(inode, index, &page, SGP_WRITE, NULL);
+		sgp = (bytes == PAGE_CACHE_SIZE) ?  SGP_WRITE_FULL : SGP_WRITE;
+retry:
+		__get_user(dummy, buf);
+		__get_user(dummy, buf + bytes - 1);
+		err = shmem_getpage(inode, index, &page, sgp, NULL);
 		if (err)
 			break;
 
-		left = bytes;
-		if (PageHighMem(page)) {
-			volatile unsigned char dummy;
-			__get_user(dummy, buf);
-			__get_user(dummy, buf + bytes - 1);
-
-			kaddr = kmap_atomic(page, KM_USER0);
-			left = __copy_from_user_inatomic(kaddr + offset,
-							buf, bytes);
-			kunmap_atomic(kaddr, KM_USER0);
-		}
-		if (left) {
-			kaddr = kmap(page);
-			left = __copy_from_user(kaddr + offset, buf, bytes);
-			kunmap(page);
-		}
+		kaddr = kmap_atomic(page, KM_USER0);
+		left = __copy_from_user_inatomic(kaddr + offset, buf, bytes);
+		kunmap_atomic(kaddr, KM_USER0);
+		if (left)
+			goto retry;
 
 		written += bytes;
 		count -= bytes;
@@ -1458,6 +1480,8 @@ shmem_file_write(struct file *file, cons
 			i_size_write(inode, pos);
 
 		flush_dcache_page(page);
+		if (sgp == SGP_WRITE_FULL)
+			SetPageUptodate(page);
 		set_page_dirty(page);
 		mark_page_accessed(page);
 		page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
