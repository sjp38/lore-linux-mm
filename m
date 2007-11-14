Message-Id: <20071114201528.514434000@chello.nl>
References: <20071114200136.009242000@chello.nl>
Date: Wed, 14 Nov 2007 21:01:39 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 3/3] nfs: use ->mmap_prepare() to avoid an AB-BA deadlock
Content-Disposition: inline; filename=mmap_prepare_nfs.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Normal locking order is:

  i_mutex
    mmap_sem

However NFS's ->mmap hook, which is called under mmap_sem, can take i_mutex.
Avoid this potential deadlock by doing the work that requires i_mutex from
the new ->mmap_prepare().

[ Is this sufficient, or does it introduce a race? ]

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/file.c |   25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

Index: linux-2.6/fs/nfs/file.c
===================================================================
--- linux-2.6.orig/fs/nfs/file.c
+++ linux-2.6/fs/nfs/file.c
@@ -41,6 +41,9 @@
 static int nfs_file_open(struct inode *, struct file *);
 static int nfs_file_release(struct inode *, struct file *);
 static loff_t nfs_file_llseek(struct file *file, loff_t offset, int origin);
+static int
+nfs_file_mmap_prepare(struct file * file, unsigned long len,
+		unsigned long prot, unsigned long flags, unsigned long pgoff);
 static int  nfs_file_mmap(struct file *, struct vm_area_struct *);
 static ssize_t nfs_file_splice_read(struct file *filp, loff_t *ppos,
 					struct pipe_inode_info *pipe,
@@ -64,6 +67,7 @@ const struct file_operations nfs_file_op
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
 	.aio_write	= nfs_file_write,
+	.mmap_prepare	= nfs_file_mmap_prepare,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs_file_open,
 	.flush		= nfs_file_flush,
@@ -270,7 +274,8 @@ nfs_file_splice_read(struct file *filp, 
 }
 
 static int
-nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
+nfs_file_mmap_prepare(struct file * file, unsigned long len,
+		unsigned long prot, unsigned long flags, unsigned long pgoff)
 {
 	struct dentry *dentry = file->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
@@ -279,13 +284,17 @@ nfs_file_mmap(struct file * file, struct
 	dfprintk(VFS, "nfs: mmap(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
-	status = nfs_revalidate_mapping(inode, file->f_mapping);
-	if (!status) {
-		vma->vm_ops = &nfs_file_vm_ops;
-		vma->vm_flags |= VM_CAN_NONLINEAR;
-		file_accessed(file);
-	}
-	return status;
+	return nfs_revalidate_mapping(inode, file->f_mapping);
+}
+
+static int
+nfs_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	vma->vm_ops = &nfs_file_vm_ops;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
+	file_accessed(file);
+
+	return 0;
 }
 
 /*

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
