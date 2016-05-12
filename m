Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCE5382963
	for <linux-mm@kvack.org>; Thu, 12 May 2016 11:50:01 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 203so152393638pfy.2
        for <linux-mm@kvack.org>; Thu, 12 May 2016 08:50:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ae8si18334767pac.110.2016.05.12.08.41.51
        for <linux-mm@kvack.org>;
        Thu, 12 May 2016 08:41:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv8 29/32] shmem: make shmem_inode_info::lock irq-safe
Date: Thu, 12 May 2016 18:41:09 +0300
Message-Id: <1463067672-134698-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to need to call shmem_charge() under tree_lock to get
accoutning right on collapse of small tmpfs pages into a huge one.

The problem is that tree_lock is irq-safe and lockdep is not happy, that
we take irq-unsafe lock under irq-safe[1].

Let's convert the lock to irq-safe.

[1] https://gist.github.com/kiryl/80c0149e03ed35dfaf26628b8e03cdbc
---
 ipc/shm.c  |  4 ++--
 mm/shmem.c | 50 ++++++++++++++++++++++++++------------------------
 2 files changed, 28 insertions(+), 26 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index b1ed484eeda1..6eb6f0416b70 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -766,10 +766,10 @@ static void shm_add_rss_swap(struct shmid_kernel *shp,
 	} else {
 #ifdef CONFIG_SHMEM
 		struct shmem_inode_info *info = SHMEM_I(inode);
-		spin_lock(&info->lock);
+		spin_lock_irq(&info->lock);
 		*rss_add += inode->i_mapping->nrpages;
 		*swp_add += info->swapped;
-		spin_unlock(&info->lock);
+		spin_unlock_irq(&info->lock);
 #else
 		*rss_add += inode->i_mapping->nrpages;
 #endif
diff --git a/mm/shmem.c b/mm/shmem.c
index 872d658d37c0..17339c12b48f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -258,14 +258,15 @@ bool shmem_charge(struct inode *inode, long pages)
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	unsigned long flags;
 
 	if (shmem_acct_block(info->flags, pages))
 		return false;
-	spin_lock(&info->lock);
+	spin_lock_irqsave(&info->lock, flags);
 	info->alloced += pages;
 	inode->i_blocks += pages * BLOCKS_PER_PAGE;
 	shmem_recalc_inode(inode);
-	spin_unlock(&info->lock);
+	spin_unlock_irqrestore(&info->lock, flags);
 	inode->i_mapping->nrpages += pages;
 
 	if (!sbinfo->max_blocks)
@@ -273,10 +274,10 @@ bool shmem_charge(struct inode *inode, long pages)
 	if (percpu_counter_compare(&sbinfo->used_blocks,
 				sbinfo->max_blocks - pages) > 0) {
 		inode->i_mapping->nrpages -= pages;
-		spin_lock(&info->lock);
+		spin_lock_irqsave(&info->lock, flags);
 		info->alloced -= pages;
 		shmem_recalc_inode(inode);
-		spin_unlock(&info->lock);
+		spin_unlock_irqrestore(&info->lock, flags);
 
 		return false;
 	}
@@ -288,12 +289,13 @@ void shmem_uncharge(struct inode *inode, long pages)
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	unsigned long flags;
 
-	spin_lock(&info->lock);
+	spin_lock_irqsave(&info->lock, flags);
 	info->alloced -= pages;
 	inode->i_blocks -= pages * BLOCKS_PER_PAGE;
 	shmem_recalc_inode(inode);
-	spin_unlock(&info->lock);
+	spin_unlock_irqrestore(&info->lock, flags);
 
 	if (sbinfo->max_blocks)
 		percpu_counter_sub(&sbinfo->used_blocks, pages);
@@ -818,10 +820,10 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		index++;
 	}
 
-	spin_lock(&info->lock);
+	spin_lock_irq(&info->lock);
 	info->swapped -= nr_swaps_freed;
 	shmem_recalc_inode(inode);
-	spin_unlock(&info->lock);
+	spin_unlock_irq(&info->lock);
 }
 
 void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
@@ -838,9 +840,9 @@ static int shmem_getattr(struct vfsmount *mnt, struct dentry *dentry,
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
 	if (info->alloced - info->swapped != inode->i_mapping->nrpages) {
-		spin_lock(&info->lock);
+		spin_lock_irq(&info->lock);
 		shmem_recalc_inode(inode);
-		spin_unlock(&info->lock);
+		spin_unlock_irq(&info->lock);
 	}
 	generic_fillattr(inode, stat);
 	return 0;
@@ -984,9 +986,9 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 		delete_from_swap_cache(*pagep);
 		set_page_dirty(*pagep);
 		if (!error) {
-			spin_lock(&info->lock);
+			spin_lock_irq(&info->lock);
 			info->swapped--;
-			spin_unlock(&info->lock);
+			spin_unlock_irq(&info->lock);
 			swap_free(swap);
 		}
 	}
@@ -1134,10 +1136,10 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 		list_add_tail(&info->swaplist, &shmem_swaplist);
 
 	if (add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
-		spin_lock(&info->lock);
+		spin_lock_irq(&info->lock);
 		shmem_recalc_inode(inode);
 		info->swapped++;
-		spin_unlock(&info->lock);
+		spin_unlock_irq(&info->lock);
 
 		swap_shmem_alloc(swap);
 		shmem_delete_from_page_cache(page, swp_to_radix_entry(swap));
@@ -1523,10 +1525,10 @@ repeat:
 
 		mem_cgroup_commit_charge(page, memcg, true, false);
 
-		spin_lock(&info->lock);
+		spin_lock_irq(&info->lock);
 		info->swapped--;
 		shmem_recalc_inode(inode);
-		spin_unlock(&info->lock);
+		spin_unlock_irq(&info->lock);
 
 		if (sgp == SGP_WRITE)
 			mark_page_accessed(page);
@@ -1603,11 +1605,11 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
 				PageTransHuge(page));
 		lru_cache_add_anon(page);
 
-		spin_lock(&info->lock);
+		spin_lock_irq(&info->lock);
 		info->alloced += 1 << compound_order(page);
 		inode->i_blocks += BLOCKS_PER_PAGE << compound_order(page);
 		shmem_recalc_inode(inode);
-		spin_unlock(&info->lock);
+		spin_unlock_irq(&info->lock);
 		alloced = true;
 
 		/*
@@ -1639,9 +1641,9 @@ clear:
 		if (alloced) {
 			ClearPageDirty(page);
 			delete_from_page_cache(page);
-			spin_lock(&info->lock);
+			spin_lock_irq(&info->lock);
 			shmem_recalc_inode(inode);
-			spin_unlock(&info->lock);
+			spin_unlock_irq(&info->lock);
 		}
 		error = -EINVAL;
 		goto unlock;
@@ -1673,9 +1675,9 @@ unlock:
 	}
 	if (error == -ENOSPC && !once++) {
 		info = SHMEM_I(inode);
-		spin_lock(&info->lock);
+		spin_lock_irq(&info->lock);
 		shmem_recalc_inode(inode);
-		spin_unlock(&info->lock);
+		spin_unlock_irq(&info->lock);
 		goto repeat;
 	}
 	if (error == -EEXIST)	/* from above or from radix_tree_insert */
@@ -1874,7 +1876,7 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 	struct shmem_inode_info *info = SHMEM_I(inode);
 	int retval = -ENOMEM;
 
-	spin_lock(&info->lock);
+	spin_lock_irq(&info->lock);
 	if (lock && !(info->flags & VM_LOCKED)) {
 		if (!user_shm_lock(inode->i_size, user))
 			goto out_nomem;
@@ -1889,7 +1891,7 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 	retval = 0;
 
 out_nomem:
-	spin_unlock(&info->lock);
+	spin_unlock_irq(&info->lock);
 	return retval;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
