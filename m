Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id AA2CC6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 16:28:59 -0400 (EDT)
Date: Mon, 2 Jul 2012 15:28:57 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [PATCH 2/2 v4][rfc] tmpfs: interleave the starting node of
	/dev/shmem
Message-ID: <20120702202857.GB15696@gulag1.americas.sgi.com>
References: <20120702202635.GA20284@gulag1.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120702202635.GA20284@gulag1.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, Hugh Dickins <hughd@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

The tmpfs superblock grants an offset for each inode as they are created. Each
inode then uses that offset to provide a preferred first node for its interleave
in the shmem_interleave.


Cc: Christoph Lameter <cl@linux.com>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Nathan T Zimmer <nzimmer@sgi.com>
---

 include/linux/mm.h       |    6 ++++++
 include/linux/shmem_fs.h |    2 ++
 mm/mempolicy.c           |    4 ++++
 mm/shmem.c               |   14 ++++++++++++++
 4 files changed, 26 insertions(+), 0 deletions(-)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2012-07-02 10:38:25.090169183 -0500
+++ linux/include/linux/mm.h	2012-07-02 10:38:30.714072182 -0500
@@ -238,6 +238,12 @@ struct vm_operations_struct {
 	 */
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
+
+	/*
+	 * If the policy is interleave allow the vma to suggest a node.
+	 */
+	unsigned long (*interleave)( struct vm_area_struct *vma, unsigned long addr);
+
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,
 		const nodemask_t *to, unsigned long flags);
 #endif
Index: linux/include/linux/shmem_fs.h
===================================================================
--- linux.orig/include/linux/shmem_fs.h	2012-07-02 10:38:25.090169183 -0500
+++ linux/include/linux/shmem_fs.h	2012-07-02 10:38:30.714072182 -0500
@@ -17,6 +17,7 @@ struct shmem_inode_info {
 		char		*symlink;	/* unswappable short symlink */
 	};
 	struct shared_policy	policy;		/* NUMA memory alloc policy */
+	unsigned long           node_offset;	/* bias for interleaved nodes */
 	struct list_head	swaplist;	/* chain of maybes on swap */
 	struct list_head	xattr_list;	/* list of shmem_xattr */
 	struct inode		vfs_inode;
@@ -32,6 +33,7 @@ struct shmem_sb_info {
 	kgid_t gid;		    /* Mount gid for root directory */
 	umode_t mode;		    /* Mount mode for root directory */
 	struct mempolicy *mpol;     /* default memory policy for mappings */
+	unsigned long next_pref_node;  /* next interleave bias to suggest for inodes */
 };
 
 static inline struct shmem_inode_info *SHMEM_I(struct inode *inode)
Index: linux/mm/mempolicy.c
===================================================================
--- linux.orig/mm/mempolicy.c	2012-07-02 10:38:25.090169183 -0500
+++ linux/mm/mempolicy.c	2012-07-02 10:38:30.738071768 -0500
@@ -1663,6 +1663,10 @@ static inline unsigned interleave_nid(st
 {
 	if (vma) {
 		unsigned long off;
+		if (vma->vm_ops && vma->vm_ops->interleave) {
+			off = vma->vm_ops->interleave( vma, addr );
+			return offset_il_node(pol, vma, off );
+		}
 
 		/*
 		 * for small pages, there is no difference between
Index: linux/mm/shmem.c
===================================================================
--- linux.orig/mm/shmem.c	2012-07-02 10:38:25.090169183 -0500
+++ linux/mm/shmem.c	2012-07-02 10:40:44.635767155 -0500
@@ -922,6 +922,7 @@ static struct page *shmem_swapin(swp_ent
 	pvma.vm_start = 0;
 	pvma.vm_pgoff = index;
 	pvma.vm_policy = spol;
+	pvma.vm_private_data = (void*)info->node_offset;
 	if( pvma.vm_policy )
 		pvma.vm_ops = &shmem_vm_ops;
 	else
@@ -938,6 +939,7 @@ static struct page *shmem_alloc_page(gfp
 	pvma.vm_start = 0;
 	pvma.vm_pgoff = index;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+	pvma.vm_private_data = (void*)info->node_offset;
 	if( pvma.vm_policy )
 		pvma.vm_ops = &shmem_vm_ops;
 	else
@@ -1314,6 +1316,18 @@ static struct mempolicy *shmem_get_polic
 	index = ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 	return mpol_shared_policy_lookup(&SHMEM_I(inode)->policy, index);
 }
+
+static unsigned long shmem_interleave( struct vm_area_struct *vma, unsigned long addr)
+{
+	unsigned offset;
+
+	// Use the vm_files prefered node as the initial offset
+	offset = (unsigned long)vma->vm_private_data;
+
+	offset += ((addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
+	return offset;
+}
 #endif
 
 int shmem_lock(struct file *file, int lock, struct user_struct *user)
@@ -2871,6 +2885,7 @@ static const struct super_operations shm
 static const struct vm_operations_struct shmem_vm_ops = {
 	.fault		= shmem_fault,
 #ifdef CONFIG_NUMA
+	.interleave	= shmem_interleave,
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
