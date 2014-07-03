Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id ED1736B0038
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 08:49:28 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id e16so123284lan.30
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 05:49:28 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ad3si48753409lbc.1.2014.07.03.05.49.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 05:49:28 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 3/5] shmem: pass inode to shmem_acct_* methods
Date: Thu, 3 Jul 2014 16:48:19 +0400
Message-ID: <97f6b1bcaaced427b124df4d765387ceb6b58e7d.1404383187.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404383187.git.vdavydov@parallels.com>
References: <cover.1404383187.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

This will be used by the next patch.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/shmem.c |   59 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 34 insertions(+), 25 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index f484c276e994..4e28eb1222cd 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -136,16 +136,20 @@ static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
  * (unless MAP_NORESERVE and sysctl_overcommit_memory <= 1),
  * consistent with the pre-accounting of private mappings ...
  */
-static inline int shmem_acct_size(unsigned long flags, loff_t size)
+static inline int shmem_acct_size(struct inode *inode)
 {
-	return (flags & VM_NORESERVE) ?
-		0 : security_vm_enough_memory_mm(current->mm, VM_ACCT(size));
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	return (info->flags & VM_NORESERVE) ?
+		0 : security_vm_enough_memory_mm(current->mm, VM_ACCT(inode->i_size));
 }
 
-static inline void shmem_unacct_size(unsigned long flags, loff_t size)
+static inline void shmem_unacct_size(struct inode *inode)
 {
-	if (!(flags & VM_NORESERVE))
-		vm_unacct_memory(VM_ACCT(size));
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	if (!(info->flags & VM_NORESERVE))
+		vm_unacct_memory(VM_ACCT(inode->i_size));
 }
 
 /*
@@ -154,15 +158,19 @@ static inline void shmem_unacct_size(unsigned long flags, loff_t size)
  * shmem_getpage reports shmem_acct_block failure as -ENOSPC not -ENOMEM,
  * so that a failure on a sparse tmpfs mapping will give SIGBUS not OOM.
  */
-static inline int shmem_acct_block(unsigned long flags)
+static inline int shmem_acct_block(struct inode *inode)
 {
-	return (flags & VM_NORESERVE) ?
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	return (info->flags & VM_NORESERVE) ?
 		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_CACHE_SIZE)) : 0;
 }
 
-static inline void shmem_unacct_blocks(unsigned long flags, long pages)
+static inline void shmem_unacct_blocks(struct inode *inode, long pages)
 {
-	if (flags & VM_NORESERVE)
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	if (info->flags & VM_NORESERVE)
 		vm_unacct_memory(pages * VM_ACCT(PAGE_CACHE_SIZE));
 }
 
@@ -231,7 +239,7 @@ static void shmem_recalc_inode(struct inode *inode)
 			percpu_counter_add(&sbinfo->used_blocks, -freed);
 		info->alloced -= freed;
 		inode->i_blocks -= freed * BLOCKS_PER_PAGE;
-		shmem_unacct_blocks(info->flags, freed);
+		shmem_unacct_blocks(inode, freed);
 	}
 }
 
@@ -565,7 +573,7 @@ static void shmem_evict_inode(struct inode *inode)
 	struct shmem_inode_info *info = SHMEM_I(inode);
 
 	if (inode->i_mapping->a_ops == &shmem_aops) {
-		shmem_unacct_size(info->flags, inode->i_size);
+		shmem_unacct_size(inode);
 		inode->i_size = 0;
 		shmem_truncate_range(inode, 0, (loff_t)-1);
 		if (!list_empty(&info->swaplist)) {
@@ -1113,7 +1121,7 @@ repeat:
 		swap_free(swap);
 
 	} else {
-		if (shmem_acct_block(info->flags)) {
+		if (shmem_acct_block(inode)) {
 			error = -ENOSPC;
 			goto failed;
 		}
@@ -1205,7 +1213,7 @@ decused:
 	if (sbinfo->max_blocks)
 		percpu_counter_add(&sbinfo->used_blocks, -1);
 unacct:
-	shmem_unacct_blocks(info->flags, 1);
+	shmem_unacct_blocks(inode, 1);
 failed:
 	if (swap.val && error != -EINVAL &&
 	    !shmem_confirm_swap(mapping, index, swap))
@@ -2810,8 +2818,8 @@ EXPORT_SYMBOL_GPL(shmem_truncate_range);
 #define shmem_vm_ops				generic_file_vm_ops
 #define shmem_file_operations			ramfs_file_operations
 #define shmem_get_inode(sb, dir, mode, dev, flags)	ramfs_get_inode(sb, dir, mode, dev)
-#define shmem_acct_size(flags, size)		0
-#define shmem_unacct_size(flags, size)		do {} while (0)
+#define shmem_acct_size(inode)			0
+#define shmem_unacct_size(inode)		do {} while (0)
 
 #endif /* CONFIG_SHMEM */
 
@@ -2836,17 +2844,13 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 	if (size < 0 || size > MAX_LFS_FILESIZE)
 		return ERR_PTR(-EINVAL);
 
-	if (shmem_acct_size(flags, size))
-		return ERR_PTR(-ENOMEM);
-
-	res = ERR_PTR(-ENOMEM);
 	this.name = name;
 	this.len = strlen(name);
 	this.hash = 0; /* will go */
 	sb = shm_mnt->mnt_sb;
 	path.dentry = d_alloc_pseudo(sb, &this);
 	if (!path.dentry)
-		goto put_memory;
+		return ERR_PTR(-ENOMEM);
 	d_set_d_op(path.dentry, &anon_ops);
 	path.mnt = mntget(shm_mnt);
 
@@ -2859,21 +2863,26 @@ static struct file *__shmem_file_setup(const char *name, loff_t size,
 	d_instantiate(path.dentry, inode);
 	inode->i_size = size;
 	clear_nlink(inode);	/* It is unlinked */
+
+	res = ERR_PTR(-ENOMEM);
+	if (shmem_acct_size(inode))
+		goto put_dentry;
+
 	res = ERR_PTR(ramfs_nommu_expand_for_mapping(inode, size));
 	if (IS_ERR(res))
-		goto put_dentry;
+		goto put_memory;
 
 	res = alloc_file(&path, FMODE_WRITE | FMODE_READ,
 		  &shmem_file_operations);
 	if (IS_ERR(res))
-		goto put_dentry;
+		goto put_memory;
 
 	return res;
 
+put_memory:
+	shmem_unacct_size(inode);
 put_dentry:
 	path_put(&path);
-put_memory:
-	shmem_unacct_size(flags, size);
 	return res;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
