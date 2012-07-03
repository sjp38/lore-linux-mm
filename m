Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id EAB846B0089
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 15:44:37 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [PATCH 2/2 v5][rfc] tmpfs: interleave the starting node of /dev/shmem
Date: Tue,  3 Jul 2012 14:44:35 -0500
Message-Id: <1341344675-17534-3-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1341344675-17534-2-git-send-email-nzimmer@sgi.com>
References: <1341344675-17534-1-git-send-email-nzimmer@sgi.com>
 <1341344675-17534-2-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Nathan Zimmer <nzimmer@sgi.com>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

The tmpfs superblock grants an offset for each inode as they are created. Each
inode then uses that offset to provide a preferred first node for its interleave
in the newly provided shmem_interleave.

Cc: Christoph Lameter <cl@linux.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
---
 include/linux/mm.h       |    7 +++++++
 include/linux/shmem_fs.h |    3 +++
 mm/mempolicy.c           |    4 ++++
 mm/shmem.c               |   17 +++++++++++++++++
 4 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b36d08c..651109e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -238,6 +238,13 @@ struct vm_operations_struct {
 	 */
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
+
+	/*
+	 * If the policy is interleave allow the vma to suggest a node.
+	 */
+	unsigned long (*interleave)(struct vm_area_struct *vma,
+					unsigned long addr);
+
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index bef2cf0..6995556 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -17,6 +17,7 @@ struct shmem_inode_info {
 		char		*symlink;	/* unswappable short symlink */
 	};
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
+	unsigned long           node_offset;	/* bias for interleaved nodes */
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct list_head	xattr_list;	/* list of shmem_xattr */
 	struct inode		vfs_inode;
@@ -32,6 +33,8 @@ struct shmem_sb_info {
 	kgid_t gid;		    /* Mount gid for root directory */
 	umode_t mode;		    /* Mount mode for root directory */
 	struct mempolicy *mpol;     /* default memory policy for mappings */
+	unsigned long next_pref_node;
+			 /* next interleave bias to suggest for inodes */
 };
 
 static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1d771e4..e2cbe9e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1663,6 +1663,10 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
 {
 	if (vma) {
 		unsigned long off;
+		if (vma->vm_ops && vma->vm_ops->interleave) {
+			off = vma->vm_ops->interleave(vma, addr);
+			return offset_il_node(pol, vma, off);
+		}
 
 		/*
 		 * for small pages, there is no difference between
diff --git a/mm/shmem.c b/mm/shmem.c
index d073252..e569338 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -922,6 +922,7 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 	pvma.vm_start = 0;
 	pvma.vm_pgoff = index;
 	pvma.vm_policy = spol;
+	pvma.vm_private_data = (void *) info->node_offset;
 	if (pvma.vm_policy)
 		pvma.vm_ops = &shmem_vm_ops;
 	else
@@ -938,6 +939,7 @@ static struct page *shmem_alloc_page(gfp_t gfp,
 	pvma.vm_start = 0;
 	pvma.vm_pgoff = index;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+	pvma.vm_private_data = (void *) info->node_offset;
 	if (pvma.vm_policy)
 		pvma.vm_ops = &shmem_vm_ops;
 	else
@@ -1314,6 +1316,19 @@ static struct mempolicy *shmem_get_policy(struct vm_area_struct *vma,
 	index = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 	return mpol_shared_policy_lookup(&SHMEM_I(inode)->policy, index);
 }
+
+static unsigned long shmem_interleave(struct vm_area_struct *vma,
+					unsigned long addr)
+{
+	unsigned long offset;
+
+	/* Use the vm_files prefered node as the initial offset. */
+	offset = (unsigned long *) vma->vm_private_data;
+
+	offset += ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
+	return offset;
+}
 #endif
 
 int shmem_lock(struct file *file, int lock, struct user_struct *user)
@@ -1386,6 +1401,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
 			inode->i_fop = &shmem_file_operations;
 			mpol_shared_policy_init(&info->policy,
 						 shmem_get_sbmpol(sbinfo));
+			info->node_offset = ++(sbinfo->next_pref_node);
 			break;
 		case S_IFDIR:
 			inc_nlink(inode);
@@ -2871,6 +2887,7 @@ static const struct super_operations shmem_ops = {
 static const struct vm_operations_struct shmem_vm_ops = {
 	.fault		= shmem_fault,
 #ifdef CONFIG_NUMA
+	.interleave	= shmem_interleave,
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
-- 
1.6.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
