Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF3360036C
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:15:39 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 49/96] c/r: restore anonymous- and file-mapped- shared memory
Date: Wed, 17 Mar 2010 12:08:37 -0400
Message-Id: <1268842164-5590-50-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-33-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-34-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-35-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-36-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-37-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-38-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-39-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-40-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-41-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-45-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-46-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-47-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-48-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-49-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

The bulk of the work is in ckpt_read_vma(), which has been refactored:
the part that create the suitable 'struct file *' for the mapping is
now larger and moved to a separate function. What's left is to read
the VMA description, get the file pointer, create the mapping, and
proceed to read the contents in.

Both anonymous shared VMAs that have been read earlier (as indicated
by a look up to objhash) and file-mapped shared VMAs are skipped.
Anonymous shared VMAs seen for the first time have their contents
read in directly to the backing inode, as indexed by the page numbers
(as opposed to virtual addresses).

Changelog[v14]:
  - Introduce patch

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/memory.c        |   66 ++++++++++++++++++++++++++++++++------------
 include/linux/checkpoint.h |    6 ++++
 include/linux/mm.h         |    2 +
 mm/filemap.c               |   13 ++++++++-
 mm/shmem.c                 |   49 ++++++++++++++++++++++++++++++++
 5 files changed, 117 insertions(+), 19 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 0fe3b38..b56124e 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -875,16 +875,39 @@ int restore_read_page(struct ckpt_ctx *ctx, struct page *page)
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
@@ -894,11 +917,14 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
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
@@ -907,12 +933,13 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
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
@@ -920,7 +947,7 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
  * these steps until reaching a header specifying "0" pages, which marks
  * the end of the contents.
  */
-static int restore_memory_contents(struct ckpt_ctx *ctx)
+int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long nr_pages;
@@ -947,7 +974,7 @@ static int restore_memory_contents(struct ckpt_ctx *ctx)
 		ret = read_pages_vaddrs(ctx, nr_pages);
 		if (ret < 0)
 			break;
-		ret = read_pages_contents(ctx);
+		ret = read_pages_contents(ctx, inode);
 		if (ret < 0)
 			break;
 		pgarr_reset_all(ctx);
@@ -1005,9 +1032,9 @@ static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
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
@@ -1052,7 +1079,7 @@ int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	if (IS_ERR((void *) addr))
 		return PTR_ERR((void *) addr);
 
-	return restore_memory_contents(ctx);
+	return restore_memory_contents(ctx, NULL);
 }
 
 /**
@@ -1112,16 +1139,19 @@ static struct restore_vma_ops restore_vma_ops[] = {
 	{
 		.vma_name = "ANON SHARED",
 		.vma_type = CKPT_VMA_SHM_ANON,
+		.restore = shmem_restore,
 	},
 	/* anonymous shared (skipped) */
 	{
 		.vma_name = "ANON SHARED (skip)",
 		.vma_type = CKPT_VMA_SHM_ANON_SKIP,
+		.restore = shmem_restore,
 	},
 	/* file-mapped shared */
 	{
 		.vma_name = "FILE SHARED",
 		.vma_type = CKPT_VMA_SHM_FILE,
+		.restore = filemap_restore,
 	},
 };
 
@@ -1140,15 +1170,15 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
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
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 68696b8..de17f9b 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -209,9 +209,15 @@ extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr);
 extern void *restore_mm(struct ckpt_ctx *ctx);
 
+extern unsigned long generic_vma_restore(struct mm_struct *mm,
+					 struct file *file,
+					 struct ckpt_hdr_vma *h);
+
 extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			       struct file *file, struct ckpt_hdr_vma *h);
 
+extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
+
 
 #define CKPT_VMA_NOT_SUPPORTED						\
 	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b37a9f1..210d8e3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1220,6 +1220,8 @@ extern int filemap_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			   struct ckpt_hdr_vma *hh);
 extern int special_mapping_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 				   struct ckpt_hdr_vma *hh);
+extern int shmem_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			 struct ckpt_hdr_vma *hh);
 #endif
 
 /* readahead.c */
diff --git a/mm/filemap.c b/mm/filemap.c
index 5b7f169..4ea28e6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1654,17 +1654,28 @@ int filemap_restore(struct ckpt_ctx *ctx,
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
 #else /* !CONFIG_CHECKPOINT */
diff --git a/mm/shmem.c b/mm/shmem.c
index bf5993c..31fd5c7 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2423,6 +2423,55 @@ static int shmem_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 
 	return shmem_vma_checkpoint(ctx, vma, vma_type, ino_objref);
 }
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
 #endif /* CONFIG_CHECKPOINT */
 
 static void init_once(void *foo)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
