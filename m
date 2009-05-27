Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 87CF76B00A3
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:07 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 17/43] c/r: dump anonymous- and file-mapped- shared memory
Date: Wed, 27 May 2009 13:32:43 -0400
Message-Id: <1243445589-32388-18-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

We now handle anonymous and file-mapped shared memory. Support for IPC
shared memory requires support for IPC first. We extend ckpt_write_vma()
to detect shared memory VMAs and handle it separately than private
memory.

There is not much to do for file-mapped shared memory, except to force
msync() on the region to ensure that the file system is consistent
with the checkpoint image. Use our internal type CKPT_VMA_SHM_FILE.

Anonymous shared memory is always backed by inode in shmem filesystem.
We use that inode to look up the VMA in the objhash and register it if
not found (on first encounter). In this case, the type of the VMA is
CKPT_VMA_SHM_ANON, and we dump the contents. On the other hand, if it is
found there, we must have already saved it before, so we change the
type to CKPT_VMA_SHM_ANON_SKIP and skip it.

To dump the contents of a shmem VMA, we loop through the pages of the
inode in the shmem filesystem, and dump the contents of each dirty
(allocated) page - unallocated pages must be clean.

Note that we save the original size of a shmem VMA because it may have
been re-mapped partially. The format itself remains like with private
VMAs, except that instead of addresses we record _indices_ (page nr)
into the backing inode.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/memory.c            |  143 +++++++++++++++++++++++++++++++++++----
 checkpoint/objhash.c           |   29 ++++++++
 include/linux/checkpoint.h     |   15 +++--
 include/linux/checkpoint_hdr.h |    8 ++
 mm/filemap.c                   |   39 +++++++++++-
 mm/mmap.c                      |    2 +-
 mm/shmem.c                     |   33 +++++++++
 7 files changed, 246 insertions(+), 23 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 99bafaa..2b73abc 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -21,6 +21,7 @@
 #include <linux/pagemap.h>
 #include <linux/mm_types.h>
 #include <linux/proc_fs.h>
+#include <linux/swap.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -281,6 +282,54 @@ static struct page *consider_private_page(struct vm_area_struct *vma,
 }
 
 /**
+ * consider_shared_page - return page pointer for dirty pages
+ * @ino - inode of shmem object
+ * @idx - page index in shmem object
+ *
+ * Looks up the page that corresponds to the index in the shmem object,
+ * and returns the page if it was modified (and grabs a reference to it),
+ * or otherwise returns NULL (or error).
+ */
+static struct page *consider_shared_page(struct inode *ino, unsigned long idx)
+{
+	struct page *page = NULL;
+	int ret;
+
+	/*
+	 * Inspired by do_shmem_file_read(): very simplified version.
+	 *
+	 * FIXME: consolidate with do_shmem_file_read()
+	 */
+
+	ret = shmem_getpage(ino, idx, &page, SGP_READ, NULL);
+	if (ret < 0)
+		return ERR_PTR(ret);
+
+	/*
+	 * Only care about dirty pages; shmem_getpage() only returns
+	 * pages that have been allocated, so they must be dirty. The
+	 * pages returned are locked and referenced.
+	 */
+
+	if (page) {
+		unlock_page(page);
+		/*
+		 * If users can be writing to this page using arbitrary
+		 * virtual addresses, take care about potential aliasing
+		 * before reading the page on the kernel side.
+		 */
+		if (mapping_writably_mapped(ino->i_mapping))
+			flush_dcache_page(page);
+		/*
+		 * Mark the page accessed if we read the beginning.
+		 */
+		mark_page_accessed(page);
+	}
+
+	return page;
+}
+
+/**
  * vma_fill_pgarr - fill a page-array with addr/page tuples
  * @ctx - checkpoint context
  * @vma - vma to scan
@@ -289,17 +338,16 @@ static struct page *consider_private_page(struct vm_area_struct *vma,
  * Returns the number of pages collected
  */
 static int vma_fill_pgarr(struct ckpt_ctx *ctx,
-			  struct vm_area_struct *vma,
-			  unsigned long *start)
+			  struct vm_area_struct *vma, struct inode *inode,
+			  unsigned long *start, unsigned long end)
 {
-	unsigned long end = vma->vm_end;
 	unsigned long addr = *start;
 	struct ckpt_pgarr *pgarr;
 	int nr_used;
 	int cnt = 0;
 
 	/* this function is only for private memory (anon or file-mapped) */
-	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+	BUG_ON(inode && vma);
 
 	do {
 		pgarr = pgarr_current(ctx);
@@ -311,7 +359,11 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 		while (addr < end) {
 			struct page *page;
 
-			page = consider_private_page(vma, addr);
+			if (vma)
+				page = consider_private_page(vma, addr);
+			else
+				page = consider_shared_page(inode, addr);
+
 			if (IS_ERR(page))
 				return PTR_ERR(page);
 
@@ -323,7 +375,10 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 				pgarr->nr_used++;
 			}
 
-			addr += PAGE_SIZE;
+			if (vma)
+				addr += PAGE_SIZE;
+			else
+				addr++;
 
 			if (pgarr_is_full(pgarr))
 				break;
@@ -395,23 +450,32 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
 }
 
 /**
- * checkpoint_memory_contents - dump contents of a VMA with private memory
+ * checkpoint_memory_contents - dump contents of a memory region
  * @ctx - checkpoint context
- * @vma - vma to scan
+ * @vma - vma to scan (--or--)
+ * @inode - inode to scan
  *
  * Collect lists of pages that needs to be dumped, and corresponding
  * virtual addresses into ctx->pgarr_list page-array chain. Then dump
  * the addresses, followed by the page contents.
  */
 static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
-				      struct vm_area_struct *vma)
+				      struct vm_area_struct *vma,
+				      struct inode *inode)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long addr, end;
 	int cnt, ret;
 
-	addr = vma->vm_start;
-	end = vma->vm_end;
+	BUG_ON(vma && inode);
+
+	if (vma) {
+		addr = vma->vm_start;
+		end = vma->vm_end;
+	} else {
+		addr = 0;
+		end = PAGE_ALIGN(i_size_read(inode)) >> PAGE_CACHE_SHIFT;
+	}
 
 	/*
 	 * Work iteratively, collecting and dumping at most CKPT_PGARR_BATCH
@@ -437,7 +501,7 @@ static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 	 */
 
 	while (addr < end) {
-		cnt = vma_fill_pgarr(ctx, vma, &addr);
+		cnt = vma_fill_pgarr(ctx, vma, inode, &addr, end);
 		if (cnt == 0)
 			break;
 		else if (cnt < 0)
@@ -481,7 +545,7 @@ static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
  * @vma_objref: vma objref
  */
 int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
-			   enum vma_type type, int vma_objref)
+			   enum vma_type type, int vma_objref, int ino_objref)
 {
 	struct ckpt_hdr_vma *h;
 	int ret;
@@ -500,6 +564,13 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
 
 	h->vma_type = type;
 	h->vma_objref = vma_objref;
+	h->ino_objref = ino_objref;
+
+	if (vma->vm_file)
+		h->ino_size = i_size_read(vma->vm_file->f_dentry->d_inode);
+	else
+		h->ino_size = 0;
+
 	h->vm_start = vma->vm_start;
 	h->vm_end = vma->vm_end;
 	h->vm_page_prot = pgprot_val(vma->vm_page_prot);
@@ -527,10 +598,37 @@ int private_vma_checkpoint(struct ckpt_ctx *ctx,
 
 	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
 
-	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref);
+	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref, 0);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_memory_contents(ctx, vma, NULL);
+ out:
+	return ret;
+}
+
+/**
+ * shmem_vma_checkpoint - dump contents of private (anon, file) vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ * @objref: vma object id
+ */
+int shmem_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
+			 enum vma_type type, int ino_objref)
+{
+	struct file *file = vma->vm_file;
+	int ret;
+
+	ckpt_debug("type %d, ino_ref %d\n", type, ino_objref);
+	BUG_ON(!(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)));
+	BUG_ON(!file);
+
+	ret = generic_vma_checkpoint(ctx, vma, type, 0, ino_objref);
 	if (ret < 0)
 		goto out;
-	ret = checkpoint_memory_contents(ctx, vma);
+	if (type == CKPT_VMA_SHM_ANON_SKIP)
+		goto out;
+	ret = checkpoint_memory_contents(ctx, NULL, file->f_dentry->d_inode);
  out:
 	return ret;
 }
@@ -929,6 +1027,21 @@ static struct restore_vma_ops restore_vma_ops[] = {
 		.vma_type = CKPT_VMA_FILE,
 		.restore = filemap_restore,
 	},
+	/* anonymous shared */
+	{
+		.vma_name = "ANON SHARED",
+		.vma_type = CKPT_VMA_SHM_ANON,
+	},
+	/* anonymous shared (skipped) */
+	{
+		.vma_name = "ANON SHARED (skip)",
+		.vma_type = CKPT_VMA_SHM_ANON_SKIP,
+	},
+	/* file-mapped shared */
+	{
+		.vma_name = "FILE SHARED",
+		.vma_type = CKPT_VMA_SHM_FILE,
+	},
 };
 
 /**
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 79325d9..ff9388d 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -43,6 +43,16 @@ struct ckpt_obj_hash {
 	int next_free_objref;
 };
 
+int checkpoint_bad(struct ckpt_ctx *ctx, void *ptr)
+{
+	BUG();
+}
+
+void *restore_bad(struct ckpt_ctx *ctx)
+{
+	return ERR_PTR(-EINVAL);
+}
+
 /* helper grab/drop functions: */
 
 static void obj_no_drop(void *ptr)
@@ -55,6 +65,16 @@ static int obj_no_grab(void *ptr)
 	return 0;
 }
 
+static int obj_inode_grab(void *ptr)
+{
+	return igrab((struct inode *) ptr) ? 0 : -EBADF;
+}
+
+static void obj_inode_drop(void *ptr)
+{
+	iput((struct inode *) ptr);
+}
+
 static int obj_file_table_grab(void *ptr)
 {
 	atomic_inc(&((struct files_struct *) ptr)->count);
@@ -96,6 +116,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_drop = obj_no_drop,
 		.ref_grab = obj_no_grab,
 	},
+	/* inode object */
+	{
+		.obj_name = "INODE",
+		.obj_type = CKPT_OBJ_INODE,
+		.ref_drop = obj_inode_drop,
+		.ref_grab = obj_inode_grab,
+		.checkpoint = checkpoint_bad,	/* no c/r at inode level */
+		.restore = restore_bad,		/* no c/r at inode level */
+	},
 	/* files_struct object */
 	{
 		.obj_name = "FILE_TABLE",
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index a22eb65..18b4941 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -91,11 +91,15 @@ extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
 extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
 				  struct vm_area_struct *vma,
 				  enum vma_type type,
-				  int vma_objref);
+				  int vma_objref, int ino_objref);
 extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
 				  struct vm_area_struct *vma,
 				  enum vma_type type,
 				  int vma_objref);
+extern int shmem_vma_checkpoint(struct ckpt_ctx *ctx,
+				struct vm_area_struct *vma,
+				enum vma_type type,
+				int ino_objref);
 
 extern int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
@@ -106,11 +110,10 @@ extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			       struct file *file, struct ckpt_hdr_vma *h);
 
 
-#define CKPT_VMA_NOT_SUPPORTED					\
-	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB |		\
-	 VM_NONLINEAR | VM_PFNMAP | VM_RESERVED | VM_NORESERVE	\
-	 | VM_HUGETLB | VM_NONLINEAR | VM_MAPPED_COPY |		\
-	 VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
+#define CKPT_VMA_NOT_SUPPORTED						\
+	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
+	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
+	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
 
 /* debugging flags */
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 671dcab..6ab3c8b 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -83,6 +83,7 @@ struct ckpt_hdr_objref {
 /* shared objects types */
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
+	CKPT_OBJ_INODE,
 	CKPT_OBJ_FILE_TABLE,
 	CKPT_OBJ_FILE,
 	CKPT_OBJ_MM,
@@ -138,6 +139,7 @@ struct ckpt_hdr_task {
 /* task's shared resources */
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
+
 	__s32 files_objref;
 	__s32 mm_objref;
 } __attribute__((aligned(8)));
@@ -194,6 +196,9 @@ enum vma_type {
 	CKPT_VMA_VDSO,		/* special vdso vma */
 	CKPT_VMA_ANON,		/* private anonymous */
 	CKPT_VMA_FILE,		/* private mapped file */
+	CKPT_VMA_SHM_ANON,	/* shared anonymous */
+	CKPT_VMA_SHM_ANON_SKIP,	/* shared anonymous (skip contents) */
+	CKPT_VMA_SHM_FILE,	/* shared mapped file, only msync */
 	CKPT_VMA_MAX
 };
 
@@ -202,6 +207,9 @@ struct ckpt_hdr_vma {
 	struct ckpt_hdr h;
 	__u32 vma_type;
 	__s32 vma_objref;	/* objref of backing file */
+	__s32 ino_objref;	/* objref of shared segment */
+	__u32 _padding;
+	__u64 ino_size;		/* size of shared segment */
 
 	__u64 vm_start;
 	__u64 vm_end;
diff --git a/mm/filemap.c b/mm/filemap.c
index 86da5d5..0d28481 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1634,6 +1634,8 @@ static int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 {
 	struct file *file = vma->vm_file;
 	int vma_objref;
+	int ino_objref;
+	int first, ret;
 
 	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
 		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
@@ -1646,7 +1648,42 @@ static int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 	if (vma_objref < 0)
 		return vma_objref;
 
-	return private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE, vma_objref);
+	if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE)) {
+		/*
+		 * Citing mmap(2): "Updates to the mapping are visible
+		 * to other processes that map this file, and are
+		 * carried through to the underlying file. The file
+		 * may not actually be updated until msync(2) or
+		 * munmap(2) is called"
+		 *
+		 * Citing msync(2): "Without use of this call there is
+		 * no guarantee that changes are written back before
+		 * munmap(2) is called."
+		 *
+		 * Force msync for region of shared mapped files, to
+		 * ensure that that the file system is consistent with
+		 * the checkpoint image.  (inspired by sys_msync).
+		 */
+
+		ino_objref = ckpt_obj_lookup_add(ctx, file->f_dentry->d_inode,
+					       CKPT_OBJ_INODE, &first);
+		if (ino_objref < 0)
+			return ino_objref;
+
+		if (first) {
+			ret = vfs_fsync(file, file->f_path.dentry, 0);
+			if (ret < 0)
+				return ret;
+		}
+
+		ret = generic_vma_checkpoint(ctx, vma, CKPT_VMA_SHM_FILE,
+					     vma_objref, ino_objref);
+	} else {
+		ret = private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE,
+					     vma_objref);
+	}
+
+	return ret;
 }
 
 int filemap_restore(struct ckpt_ctx *ctx,
diff --git a/mm/mmap.c b/mm/mmap.c
index e8e9124..0820a9b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2296,7 +2296,7 @@ static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
 	if (!name || strcmp(name, "[vdso]"))
 		return -ENOSYS;
 
-	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0);
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0, 0);
 }
 
 int special_mapping_restore(struct ckpt_ctx *ctx,
diff --git a/mm/shmem.c b/mm/shmem.c
index f260336..d349c10 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -31,6 +31,10 @@
 #include <linux/swap.h>
 #include <linux/ima.h>
 
+#include <linux/checkpoint_types.h>
+#include <linux/checkpoint_hdr.h>
+#include <linux/checkpoint.h>
+
 static struct vfsmount *shm_mnt;
 
 #ifdef CONFIG_SHMEM
@@ -2381,6 +2385,32 @@ static void shmem_destroy_inode(struct inode *inode)
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int shmem_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	enum vma_type vma_type;
+	int ino_objref;
+	int first;
+
+	/* should be private anonymous ... verify that this is the case */
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		return -ENOSYS;
+	}
+
+	BUG_ON(!vma->vm_file);
+
+	ino_objref = ckpt_obj_lookup_add(ctx, vma->vm_file->f_dentry->d_inode,
+					 CKPT_OBJ_INODE, &first);
+	if (ino_objref < 0)
+		return ino_objref;
+
+	vma_type = (first ? CKPT_VMA_SHM_ANON : CKPT_VMA_SHM_ANON_SKIP);
+
+	return shmem_vma_checkpoint(ctx, vma, vma_type, ino_objref);
+}
+#endif /* CONFIG_CHECKPOINT */
+
 static void init_once(void *foo)
 {
 	struct shmem_inode_info *p = (struct shmem_inode_info *) foo;
@@ -2496,6 +2526,9 @@ static struct vm_operations_struct shmem_vm_ops = {
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= shmem_checkpoint,
+#endif
 };
 
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
