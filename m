Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 644B66B00B4
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:17 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 18/43] c/r: restore anonymous- and file-mapped- shared memory
Date: Wed, 27 May 2009 13:32:44 -0400
Message-Id: <1243445589-32388-19-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
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
---
 checkpoint/memory.c        |   66 ++++++++++++++++++++++++++++++++-----------
 include/linux/checkpoint.h |    6 ++++
 include/linux/mm.h         |    2 +
 mm/filemap.c               |   13 ++++++++-
 mm/shmem.c                 |   49 ++++++++++++++++++++++++++++++++
 5 files changed, 118 insertions(+), 18 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 2b73abc..c163b76 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -785,13 +785,36 @@ static int restore_read_page(struct ckpt_ctx *ctx, struct page *page, void *p)
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
 	char *buf;
@@ -801,17 +824,22 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
 	if (!buf)
 		return -ENOMEM;
 
-	down_read(&mm->mmap_sem);
+	down_read(&current->mm->mmap_sem);
 	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
 		vaddrs = pgarr->vaddrs;
 		for (i = 0; i < pgarr->nr_used; i++) {
 			struct page *page;
 
 			_ckpt_debug(CKPT_DPAGE, "got page %#lx\n", vaddrs[i]);
-			ret = get_user_pages(current, mm, vaddrs[i],
-					     1, 1, 1, &page, NULL);
-			if (ret < 0)
+			if (inode)
+				page = bring_shared_page(vaddrs[i], inode);
+			else
+				page = bring_private_page(vaddrs[i]);
+
+			if (IS_ERR(page)) {
+				ret = PTR_ERR(page);
 				goto out;
+			}
 
 			ret = restore_read_page(ctx, page, buf);
 			page_cache_release(page);
@@ -822,14 +850,15 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
 	}
 
  out:
-	up_read(&mm->mmap_sem);
+	up_read(&current->mm->mmap_sem);
 	kfree(buf);
 	return 0;
 }
 
 /**
- * restore_memory_contents - restore contents of a VMA with private memory
+ * restore_memory_contents - restore contents of a memory region
  * @ctx - restart context
+ * @inode - backing inode
  *
  * Reads a header that specifies how many pages will follow, then reads
  * a list of virtual addresses into ctx->pgarr_list page-array chain,
@@ -837,7 +866,7 @@ static int read_pages_contents(struct ckpt_ctx *ctx)
  * these steps until reaching a header specifying "0" pages, which marks
  * the end of the contents.
  */
-static int restore_memory_contents(struct ckpt_ctx *ctx)
+int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode)
 {
 	struct ckpt_hdr_pgarr *h;
 	unsigned long nr_pages;
@@ -864,7 +893,7 @@ static int restore_memory_contents(struct ckpt_ctx *ctx)
 		ret = read_pages_vaddrs(ctx, nr_pages);
 		if (ret < 0)
 			break;
-		ret = read_pages_contents(ctx);
+		ret = read_pages_contents(ctx, inode);
 		if (ret < 0)
 			break;
 		pgarr_reset_all(ctx);
@@ -922,9 +951,9 @@ static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
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
@@ -971,7 +1000,7 @@ int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	if (IS_ERR((void *) addr))
 		return PTR_ERR((void *) addr);
 
-	return restore_memory_contents(ctx);
+	return restore_memory_contents(ctx, NULL);
 }
 
 /**
@@ -1031,16 +1060,19 @@ static struct restore_vma_ops restore_vma_ops[] = {
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
 
@@ -1059,15 +1091,15 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
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
index 18b4941..169aa70 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -106,9 +106,15 @@ extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
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
index 53e916a..c8e8972 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1203,6 +1203,8 @@ extern int filemap_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			   struct ckpt_hdr_vma *hh);
 extern int special_mapping_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 				   struct ckpt_hdr_vma *hh);
+extern int shmem_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			 struct ckpt_hdr_vma *hh);
 #endif
 
 /* readahead.c */
diff --git a/mm/filemap.c b/mm/filemap.c
index 0d28481..d669395 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1691,17 +1691,28 @@ int filemap_restore(struct ckpt_ctx *ctx,
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
 #endif /* CONFIG_CHECKPOINT */
diff --git a/mm/shmem.c b/mm/shmem.c
index d349c10..829eefa 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2409,6 +2409,55 @@ static int shmem_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 
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
+	file = ckpt_obj_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
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
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
