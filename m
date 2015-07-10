Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 68E739003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:09:44 -0400 (EDT)
Received: by igrv9 with SMTP id v9so20484865igr.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:09:44 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id j1si232851igx.6.2015.07.10.13.09.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 13:09:43 -0700 (PDT)
Received: by igrv9 with SMTP id v9so20484722igr.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:09:43 -0700 (PDT)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] shmem: recalculate file inode when fstat
Date: Fri, 10 Jul 2015 13:09:37 -0700
Message-Id: <1436558977-31712-1-git-send-email-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

Shmem uses shmem_recalc_inode to update i_blocks when it allocates
page, undoes range or swaps. But mm can drop clean page without
notifying shmem. This makes fstat sometimes return out-of-date
block size.

The problem can be partially solved when we add
inode_operations->getattr which calls shmem_recalc_inode to update
i_blocks for fstat.

shmem_recalc_inode also updates counter used by statfs and
vm_committed_as. For them the situation is not changed. They still
suffer from the discrepancy after dropping clean page and before
the function is called by aforementioned triggers.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/shmem.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 4caf8ed..37e7933 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -542,6 +542,21 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 }
 EXPORT_SYMBOL_GPL(shmem_truncate_range);
 
+static int shmem_getattr(struct vfsmount *mnt, struct dentry *dentry,
+			 struct kstat *stat)
+{
+	struct inode *inode = dentry->d_inode;
+	struct shmem_inode_info *info = SHMEM_I(inode);
+
+	spin_lock(&info->lock);
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+
+	generic_fillattr(inode, stat);
+
+	return 0;
+}
+
 static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 {
 	struct inode *inode = d_inode(dentry);
@@ -3122,6 +3137,7 @@ static const struct file_operations shmem_file_operations = {
 };
 
 static const struct inode_operations shmem_inode_operations = {
+	.getattr	= shmem_getattr,
 	.setattr	= shmem_setattr,
 #ifdef CONFIG_TMPFS_XATTR
 	.setxattr	= shmem_setxattr,
-- 
2.4.3.573.g4eafbef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
