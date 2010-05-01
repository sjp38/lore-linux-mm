Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 722AD6004C0
	for <linux-mm@kvack.org>; Sat,  1 May 2010 10:34:22 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 046/100] c/r: dump anonymous- and file-mapped- shared memory
Date: Sat,  1 May 2010 10:15:28 -0400
Message-Id: <1272723382-19470-47-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Matt Helsley <matthltc@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@cs.columbia.edu>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
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

During restore, the bulk of the work is in ckpt_read_vma(), which has
been refactored: the part that create the suitable 'struct file *' for
the mapping is now larger and moved to a separate function. What's
left is to read the VMA description, get the file pointer, create the
mapping, and proceed to read the contents in.

Both anonymous shared VMAs that have been read earlier (as indicated
by a look up to objhash) and file-mapped shared VMAs are skipped.
Anonymous shared VMAs seen for the first time have their contents read
in directly to the backing inode, as indexed by the page numbers (as
opposed to virtual addresses).

Changelog[v21]:
  - Replace __initcall() with late_initcall()
  - Merge shmem dump/restore into a single patch
  - [Serge Hallyn] s390: Register inode checkpoint ops in a separate
	__initcall since we don't need to be in the early init paths.
	Also fixes a bug on s390 where CKPT_OBJ_INODE wouldn't get
	registered because of early return predicated on hashdist.
Changelog[v19-rc3]:
  - Rebase to kernel 2.6.33
Changelog[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
Changelog[v18]:
  - Mark the backing file as visited at chekcpoint

Cc: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 fs/inode.c                     |   26 +++++
 include/linux/checkpoint.h     |   21 +++-
 include/linux/checkpoint_hdr.h |   12 +++
 include/linux/mm.h             |    2 +
 kernel/checkpoint/objhash.c    |    2 +
 mm/checkpoint.c                |  209 +++++++++++++++++++++++++++++++++-------
 mm/filemap.c                   |   52 ++++++++++-
 mm/mmap.c                      |    2 +-
 mm/shmem.c                     |   84 ++++++++++++++++
 9 files changed, 368 insertions(+), 42 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 407bf39..3496c51 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -25,6 +25,7 @@
 #include <linux/mount.h>
 #include <linux/async.h>
 #include <linux/posix_acl.h>
+#include <linux/checkpoint.h>
 
 /*
  * This is needed for the following functions:
@@ -1560,6 +1561,31 @@ void __init inode_init_early(void)
 		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int obj_inode_grab(void *ptr)
+{
+	return igrab((struct inode *) ptr) ? 0 : -EBADF;
+}
+
+static void obj_inode_drop(void *ptr, int lastref)
+{
+	iput((struct inode *) ptr);
+}
+
+static const struct ckpt_obj_ops ckpt_obj_inode_ops = {
+	.obj_name = "INODE",
+	.obj_type = CKPT_OBJ_INODE,
+	.ref_drop = obj_inode_drop,
+	.ref_grab = obj_inode_grab,
+};
+
+static int __init inode_checkpoint_init(void)
+{
+	return register_checkpoint_obj(&ckpt_obj_inode_ops);
+}
+late_initcall(inode_checkpoint_init);
+#endif
+
 void __init inode_init(void)
 {
 	int loop;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index c9efeb3..24ad717 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -190,26 +190,35 @@ extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
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
 
 extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
 
+extern unsigned long generic_vma_restore(struct mm_struct *mm,
+					 struct file *file,
+					 struct ckpt_hdr_vma *h);
+
 extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			       struct file *file, struct ckpt_hdr_vma *h);
 
+extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
+
 
-#define CKPT_VMA_NOT_SUPPORTED					\
-	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB |		\
-	 VM_NONLINEAR | VM_PFNMAP | VM_RESERVED | VM_NORESERVE	\
-	 | VM_HUGETLB | VM_NONLINEAR | VM_MAPPED_COPY |		\
-	 VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
+#define CKPT_VMA_NOT_SUPPORTED						\
+	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
+	 VM_RESERVED | VM_NORESERVE | VM_HUGETLB | VM_NONLINEAR |	\
+	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
 static inline int ckpt_validate_errno(int errno)
 {
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f2c67ee..86cab42 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -131,6 +131,8 @@ struct ckpt_hdr_objref {
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
 #define CKPT_OBJ_IGNORE CKPT_OBJ_IGNORE
+	CKPT_OBJ_INODE,
+#define CKPT_OBJ_INODE CKPT_OBJ_INODE
 	CKPT_OBJ_FILE_TABLE,
 #define CKPT_OBJ_FILE_TABLE CKPT_OBJ_FILE_TABLE
 	CKPT_OBJ_FILE,
@@ -224,6 +226,7 @@ struct ckpt_hdr_task {
 /* task's shared resources */
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
+
 	__s32 files_objref;
 	__s32 mm_objref;
 } __attribute__((aligned(8)));
@@ -322,6 +325,12 @@ enum vma_type {
 #define CKPT_VMA_ANON CKPT_VMA_ANON
 	CKPT_VMA_FILE,		/* private mapped file */
 #define CKPT_VMA_FILE CKPT_VMA_FILE
+	CKPT_VMA_SHM_ANON,	/* shared anonymous */
+#define CKPT_VMA_SHM_ANON CKPT_VMA_SHM_ANON
+	CKPT_VMA_SHM_ANON_SKIP,	/* shared anonymous (skip contents) */
+#define CKPT_VMA_SHM_ANON_SKIP CKPT_VMA_SHM_ANON_SKIP
+	CKPT_VMA_SHM_FILE,	/* shared mapped file, only msync */
+#define CKPT_VMA_SHM_FILE CKPT_VMA_SHM_FILE
 	CKPT_VMA_MAX
 #define CKPT_VMA_MAX CKPT_VMA_MAX
 };
@@ -331,6 +340,9 @@ struct ckpt_hdr_vma {
 	struct ckpt_hdr h;
 	__u32 vma_type;
 	__s32 vma_objref;	/* objref of backing file */
+	__s32 ino_objref;	/* objref of shared segment */
+	__u32 _padding;
+	__u64 ino_size;		/* size of shared segment */
 
 	__u64 vm_start;
 	__u64 vm_end;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5ebb781..31520e5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1331,6 +1331,8 @@ extern int filemap_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			   struct ckpt_hdr_vma *hh);
 extern int special_mapping_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 				   struct ckpt_hdr_vma *hh);
+extern int shmem_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			 struct ckpt_hdr_vma *hh);
 #endif
 
 /* readahead.c */
diff --git a/kernel/checkpoint/objhash.c b/kernel/checkpoint/objhash.c
index 75bf2da..1d78dbf 100644
--- a/kernel/checkpoint/objhash.c
+++ b/kernel/checkpoint/objhash.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/hash.h>
+#include <linux/file.h>
 #include <linux/checkpoint.h>
 
 struct ckpt_obj {
@@ -45,6 +46,7 @@ static const struct ckpt_obj_ops ckpt_obj_ignored_ops = {
 	.ref_grab = NULL,
 };
 
+/* objects array */
 static const struct ckpt_obj_ops *ckpt_obj_ops[CKPT_OBJ_MAX] = {
 	[CKPT_OBJ_IGNORE] = &ckpt_obj_ignored_ops,
 };
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
index d53025b..6d71180 100644
--- a/mm/checkpoint.c
+++ b/mm/checkpoint.c
@@ -22,6 +22,7 @@
 #include <linux/pagemap.h>
 #include <linux/mm_types.h>
 #include <linux/proc_fs.h>
+#include <linux/swap.h>
 #include <linux/checkpoint.h>
 
 /*
@@ -227,6 +228,54 @@ static struct page *consider_private_page(struct vm_area_struct *vma,
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
@@ -235,16 +284,15 @@ static struct page *consider_private_page(struct vm_area_struct *vma,
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
 
-	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+	BUG_ON(inode && vma);
 
 	if (vma)
 		down_read(&vma->vm_mm->mmap_sem);
@@ -260,7 +308,11 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 		while (addr < end) {
 			struct page *page;
 
-			page = consider_private_page(vma, addr);
+			if (vma)
+				page = consider_private_page(vma, addr);
+			else
+				page = consider_shared_page(inode, addr);
+
 			if (IS_ERR(page)) {
 				cnt = PTR_ERR(page);
 				goto out;
@@ -274,7 +326,10 @@ static int vma_fill_pgarr(struct ckpt_ctx *ctx,
 				pgarr->nr_used++;
 			}
 
-			addr += PAGE_SIZE;
+			if (vma)
+				addr += PAGE_SIZE;
+			else
+				addr++;
 
 			if (pgarr_is_full(pgarr))
 				break;
@@ -341,23 +396,32 @@ static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
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
@@ -383,7 +447,7 @@ static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 	 */
 
 	while (addr < end) {
-		cnt = vma_fill_pgarr(ctx, vma, &addr);
+		cnt = vma_fill_pgarr(ctx, vma, inode, &addr, end);
 		if (cnt == 0)
 			break;
 		else if (cnt < 0)
@@ -427,7 +491,7 @@ static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
  * @vma_objref: vma objref
  */
 int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
-			   enum vma_type type, int vma_objref)
+			   enum vma_type type, int vma_objref, int ino_objref)
 {
 	struct ckpt_hdr_vma *h;
 	int ret;
@@ -441,6 +505,13 @@ int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
 
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
@@ -468,10 +539,37 @@ int private_vma_checkpoint(struct ckpt_ctx *ctx,
 
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
@@ -772,16 +870,39 @@ int restore_read_page(struct ckpt_ctx *ctx, struct page *page)
 	return 0;
 }
 
+static struct page *bring_private_page(unsigned long addr)
+{
+	struct page *page;
+	int ret;
+
+	ret = get_user_pages(current, current->mm, addr, 1, 1, 1, &page, NULL);
+	if (ret < 0)
+		page = ERR_PTR(ret);
+	return page;
+}
+
+static struct page *bring_shared_page(unsigned long idx, struct inode *ino)
+{
+	struct page *page = NULL;
+	int ret;
+
+	ret = shmem_getpage(ino, idx, &page, SGP_WRITE, NULL);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	if (page)
+		unlock_page(page);
+	return page;
+}
+
 /**
  * read_pages_contents - read in data of pages in page-array chain
  * @ctx - restart context
  */
-static int read_pages_contents(struct ckpt_ctx *ctx)
+static int read_pages_contents(struct ckpt_ctx *ctx, struct inode *inode)
 {
-	struct mm_struct *mm = current->mm;
 	struct ckpt_pgarr *pgarr;
 	unsigned long *vaddrs;
-	int i, ret = 0;
+	int i, ret;
 
 	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		vaddrs = pgarr->vaddrs;
@@ -791,11 +912,14 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
 			/* TODO: do in chunks to reduce mmap_sem overhead */
 			_ckpt_debug(CKPT_DPAGE, "got page %#lx\n", vaddrs[i]);
 			down_read(&current->mm->mmap_sem);
-			ret = get_user_pages(current, mm, vaddrs[i],
-					     1, 1, 1, &page, NULL);
+			if (inode)
+				page = bring_shared_page(vaddrs[i], inode);
+			else
+				page = bring_private_page(vaddrs[i]);
 			up_read(&current->mm->mmap_sem);
-			if (ret < 0)
-				return ret;
+
+			if (IS_ERR(page))
+				return PTR_ERR(page);
 
 			ret = restore_read_page(ctx, page);
 			page_cache_release(page);
@@ -804,12 +928,13 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
 				return ret;
 		}
 	}
-	return ret;
+	return 0;
 }
 
 /**
- * restore_memory_contents - restore contents of a VMA with private memory
+ * restore_memory_contents - restore contents of a memory region
  * @ctx - restart context
+ * @inode - backing inode
  *
  * Reads a header that specifies how many pages will follow, then reads
  * a list of virtual addresses into ctx->pgarr_list page-array chain,
@@ -817,7 +942,7 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
  * these steps until reaching a header specifying "0" pages, which marks
  * the end of the contents.
  */
-static int restore_memory_contents(struct ckpt_ctx *ctx)
+int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long nr_pages;
@@ -844,7 +969,7 @@ static int restore_memory_contents(struct ckpt_ctx *ctx)
 		ret = read_pages_vaddrs(ctx, nr_pages);
 		if (ret < 0)
 			break;
-		ret = read_pages_contents(ctx);
+		ret = read_pages_contents(ctx, inode);
 		if (ret < 0)
 			break;
 		pgarr_reset_all(ctx);
@@ -902,9 +1027,9 @@ static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
  * @file - file to map (NULL for anonymous)
  * @h - vma header data
  */
-static unsigned long generic_vma_restore(struct mm_struct *mm,
-					 struct file *file,
-					 struct ckpt_hdr_vma *h)
+unsigned long generic_vma_restore(struct mm_struct *mm,
+				  struct file *file,
+				  struct ckpt_hdr_vma *h)
 {
 	unsigned long vm_size, vm_start, vm_flags, vm_prot, vm_pgoff;
 	unsigned long addr;
@@ -949,7 +1074,7 @@ int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	if (IS_ERR((void *) addr))
 		return PTR_ERR((void *) addr);
 
-	return restore_memory_contents(ctx);
+	return restore_memory_contents(ctx, NULL);
 }
 
 /**
@@ -1005,6 +1130,24 @@ static struct restore_vma_ops restore_vma_ops[] = {
 		.vma_type = CKPT_VMA_FILE,
 		.restore = filemap_restore,
 	},
+	/* anonymous shared */
+	{
+		.vma_name = "ANON SHARED",
+		.vma_type = CKPT_VMA_SHM_ANON,
+		.restore = shmem_restore,
+	},
+	/* anonymous shared (skipped) */
+	{
+		.vma_name = "ANON SHARED (skip)",
+		.vma_type = CKPT_VMA_SHM_ANON_SKIP,
+		.restore = shmem_restore,
+	},
+	/* file-mapped shared */
+	{
+		.vma_name = "FILE SHARED",
+		.vma_type = CKPT_VMA_SHM_FILE,
+		.restore = filemap_restore,
+	},
 };
 
 /**
@@ -1022,15 +1165,15 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	if (IS_ERR(h))
 		return PTR_ERR(h);
 
-	ckpt_debug("vma %#lx-%#lx flags %#lx type %d vmaref %d\n",
+	ckpt_debug("vma %#lx-%#lx flags %#lx type %d vmaref %d inoref %d\n",
 		   (unsigned long) h->vm_start, (unsigned long) h->vm_end,
 		   (unsigned long) h->vm_flags, (int) h->vma_type,
-		   (int) h->vma_objref);
+		   (int) h->vma_objref, (int) h->ino_objref);
 
 	ret = -EINVAL;
 	if (h->vm_end < h->vm_start)
 		goto out;
-	if (h->vma_objref < 0)
+	if (h->vma_objref < 0 || h->ino_objref < 0)
 		goto out;
 	if (h->vma_type >= CKPT_VMA_MAX)
 		goto out;
diff --git a/mm/filemap.c b/mm/filemap.c
index 24d4c54..3d6c497 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1596,6 +1596,8 @@ int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 {
 	struct file *file = vma->vm_file;
 	int vma_objref;
+	int ino_objref;
+	int first, ret;
 
 	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
 		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
@@ -1608,7 +1610,42 @@ int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
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
 EXPORT_SYMBOL(filemap_checkpoint);
 
@@ -1617,17 +1654,28 @@ int filemap_restore(struct ckpt_ctx *ctx,
 		    struct ckpt_hdr_vma *h)
 {
 	struct file *file;
+	unsigned long addr;
 	int ret;
 
 	if (h->vma_type == CKPT_VMA_FILE &&
 	    (h->vm_flags & (VM_SHARED | VM_MAYSHARE)))
 		return -EINVAL;
+	if (h->vma_type == CKPT_VMA_SHM_FILE &&
+	    !(h->vm_flags & (VM_SHARED | VM_MAYSHARE)))
+		return -EINVAL;
 
 	file = ckpt_obj_fetch(ctx, h->vma_objref, CKPT_OBJ_FILE);
 	if (IS_ERR(file))
 		return PTR_ERR(file);
 
-	ret = private_vma_restore(ctx, mm, file, h);
+	if (h->vma_type == CKPT_VMA_FILE) {
+		/* private mapped file */
+		ret = private_vma_restore(ctx, mm, file, h);
+	} else {
+		/* shared mapped file */
+		addr = generic_vma_restore(mm, file, h);
+		ret = (IS_ERR((void *) addr) ? PTR_ERR((void *) addr) : 0);
+	}
 	return ret;
 }
 #endif
diff --git a/mm/mmap.c b/mm/mmap.c
index 9d4891f..ddbe589 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2471,7 +2471,7 @@ static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
 	if (!name || strcmp(name, "[vdso]"))
 		return -ENOSYS;
 
-	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0);
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0, 0);
 }
 
 int special_mapping_restore(struct ckpt_ctx *ctx,
diff --git a/mm/shmem.c b/mm/shmem.c
index d93c394..1f361a6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -29,6 +29,7 @@
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/swap.h>
+#include <linux/checkpoint.h>
 
 static struct vfsmount *shm_mnt;
 
@@ -2393,6 +2394,86 @@ static void shmem_destroy_inode(struct inode *inode)
 	kmem_cache_free(shmem_inode_cachep, SHMEM_I(inode));
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int shmem_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	enum vma_type vma_type;
+	int ino_objref;
+	int ret, first;
+
+	/* should be private anonymous ... verify that this is the case */
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		return -ENOSYS;
+	}
+
+	BUG_ON(!vma->vm_file);
+
+	/* we collected the file but we don't checkpoint it per-se */
+	ret = ckpt_obj_visit(ctx, vma->vm_file, CKPT_OBJ_FILE);
+	if (ret < 0)
+		return ret;
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
+
+int shmem_restore(struct ckpt_ctx *ctx,
+		  struct mm_struct *mm, struct ckpt_hdr_vma *h)
+{
+	unsigned long addr;
+	struct file *file;
+	int ret = 0;
+
+	file = ckpt_obj_try_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
+	if (PTR_ERR(file) == -EINVAL)
+		file = NULL;
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	/* if file is NULL, this is the premiere - create and insert */
+	if (!file) {
+		if (h->vma_type != CKPT_VMA_SHM_ANON)
+			return -EINVAL;
+		/*
+		 * in theory could pass NULL to mmap and let it create
+		 * the file. But, if 'shm_size != vm_end - vm_start',
+		 * or if 'vm_pgoff != 0', then the vma reflects only a
+		 * portion of the shm object and we need to "manually"
+		 * create the full shm object.
+		 */
+		file = shmem_file_setup("/dev/zero", h->ino_size, h->vm_flags);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+		ret = ckpt_obj_insert(ctx, file, h->ino_objref, CKPT_OBJ_FILE);
+		if (ret < 0)
+			goto out;
+	} else {
+		if (h->vma_type != CKPT_VMA_SHM_ANON_SKIP)
+			return -EINVAL;
+		/* Already need fput() for the file above; keep path simple */
+		get_file(file);
+	}
+
+	addr = generic_vma_restore(mm, file, h);
+	if (IS_ERR((void *) addr))
+		return PTR_ERR((void *) addr);
+
+	if (h->vma_type == CKPT_VMA_SHM_ANON)
+		ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
+ out:
+	fput(file);
+	return ret;
+}
+
+#endif /* CONFIG_CHECKPOINT */
+
 static void init_once(void *foo)
 {
 	struct shmem_inode_info *p = (struct shmem_inode_info *) foo;
@@ -2505,6 +2586,9 @@ static const struct vm_operations_struct shmem_vm_ops = {
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
 #endif
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= shmem_checkpoint,
+#endif
 };
 
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
