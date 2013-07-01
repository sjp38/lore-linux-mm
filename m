Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 450E76B005C
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:19 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 12/13] mm: shmem: introduce shmem_insert_page
Date: Mon, 1 Jul 2013 15:57:47 +0400
Message-ID: <edc161ad4ad9799c4b0c40163787bdb03a0386a4.1372582756.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

The function inserts a memory page to a shmem file under an arbitrary
offset. If there is something at the specified offset (page or swap),
the function fails.

The function will be sued by the next patch.
---
 include/linux/shmem_fs.h |    3 ++
 mm/shmem.c               |   68 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 30aa0dc..da63308 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -62,4 +62,7 @@ static inline struct page *shmem_read_mapping_page(
 					mapping_gfp_mask(mapping));
 }
 
+extern int shmem_insert_page(struct inode *inode,
+		pgoff_t index, struct page *page, bool on_lru);
+
 #endif
diff --git a/mm/shmem.c b/mm/shmem.c
index 1c44af7..71fac31 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -328,6 +328,74 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	BUG_ON(error);
 }
 
+int shmem_insert_page(struct inode *inode,
+		pgoff_t index, struct page *page, bool on_lru)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	gfp_t gfp = mapping_gfp_mask(mapping);
+	int err;
+
+	if (index > (MAX_LFS_FILESIZE >> PAGE_CACHE_SHIFT))
+		return -EFBIG;
+
+	err = -ENOSPC;
+	if (shmem_acct_block(info->flags))
+		goto out;
+	if (sbinfo->max_blocks) {
+		if (percpu_counter_compare(&sbinfo->used_blocks,
+					   sbinfo->max_blocks) >= 0)
+			goto out_unacct;
+		percpu_counter_inc(&sbinfo->used_blocks);
+	}
+
+	if (!on_lru) {
+		SetPageSwapBacked(page);
+		__set_page_locked(page);
+	} else
+		lock_page(page);
+
+	err = mem_cgroup_cache_charge(page, current->mm,
+				      gfp & GFP_RECLAIM_MASK);
+	if (err)
+		goto out_unlock;
+	err = radix_tree_preload(gfp & GFP_RECLAIM_MASK);
+	if (!err) {
+		err = shmem_add_to_page_cache(page, mapping, index, gfp, NULL);
+		radix_tree_preload_end();
+	}
+	if (err)
+		goto out_uncharge;
+
+	if (!on_lru)
+		lru_cache_add_anon(page);
+
+	spin_lock(&info->lock);
+	info->alloced++;
+	inode->i_blocks += BLOCKS_PER_PAGE;
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+
+	flush_dcache_page(page);
+	SetPageUptodate(page);
+	set_page_dirty(page);
+
+	unlock_page(page);
+	return 0;
+
+out_uncharge:
+	mem_cgroup_uncharge_cache_page(page);
+out_unlock:
+	unlock_page(page);
+	if (sbinfo->max_blocks)
+		percpu_counter_add(&sbinfo->used_blocks, -1);
+out_unacct:
+	shmem_unacct_blocks(info->flags, 1);
+out:
+	return err;
+}
+
 /*
  * Like find_get_pages, but collecting swap entries as well as pages.
  */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
