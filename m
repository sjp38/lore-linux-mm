Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9GIENjU011107
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:14:23 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9GIEN0J034616
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:14:23 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9GIEMq2002985
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:14:22 -0400
Subject: [PATCH 4/9] Dump memory address space
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 16 Oct 2008 11:14:19 -0700
References: <20081016181414.934C4FCC@kernel>
In-Reply-To: <20081016181414.934C4FCC@kernel>
Message-Id: <20081016181419.0E85AD01@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, containers <containers@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Serge E. Hallyn" <serue@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Oren Laadan <orenl@cs.columbia.edu>

For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
it will be followed by the file name. Then comes the actual contents,
in one or more chunk: each chunk begins with a header that specifies
how many pages it holds, then the virtual addresses of all the dumped
pages in that chunk, followed by the actual contents of all dumped
pages. A header with zero number of pages marks the end of the contents.
Then comes the next VMA and so on.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/x86/mm/checkpoint.c         |   31 +
 linux-2.6.git-dave/arch/x86/mm/restart.c            |    1 
 linux-2.6.git-dave/checkpoint/Makefile              |    3 
 linux-2.6.git-dave/checkpoint/checkpoint.c          |   53 ++
 linux-2.6.git-dave/checkpoint/checkpoint_arch.h     |    2 
 linux-2.6.git-dave/checkpoint/checkpoint_mem.h      |   41 +
 linux-2.6.git-dave/checkpoint/ckpt_mem.c            |  500 ++++++++++++++++++++
 linux-2.6.git-dave/checkpoint/sys.c                 |   16 
 linux-2.6.git-dave/include/asm-x86/checkpoint_hdr.h |    5 
 linux-2.6.git-dave/include/linux/checkpoint.h       |   12 
 linux-2.6.git-dave/include/linux/checkpoint_hdr.h   |   32 +
 11 files changed, 695 insertions(+), 1 deletion(-)

diff -puN arch/x86/mm/checkpoint.c~v6_PATCH_4_9_Dump_memory_address_space arch/x86/mm/checkpoint.c
--- linux-2.6.git/arch/x86/mm/checkpoint.c~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/arch/x86/mm/checkpoint.c	2008-10-16 10:53:36.000000000 -0700
@@ -196,3 +196,34 @@ int cr_write_cpu(struct cr_ctx *ctx, str
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
 }
+
+/* dump the mm->context state */
+int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int ret;
+
+	h.type = CR_HDR_MM_CONTEXT;
+	h.len = sizeof(*hh);
+	h.parent = parent;
+
+	mutex_lock(&mm->context.lock);
+
+	hh->ldt_entry_size = LDT_ENTRY_SIZE;
+	hh->nldt = mm->context.size;
+
+	cr_debug("nldt %d\n", hh->nldt);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		goto out;
+
+	ret = cr_kwrite(ctx, mm->context.ldt,
+			mm->context.size * LDT_ENTRY_SIZE);
+
+ out:
+	mutex_unlock(&mm->context.lock);
+	return ret;
+}
diff -puN arch/x86/mm/restart.c~v6_PATCH_4_9_Dump_memory_address_space arch/x86/mm/restart.c
--- linux-2.6.git/arch/x86/mm/restart.c~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/arch/x86/mm/restart.c	2008-10-16 10:53:36.000000000 -0700
@@ -8,6 +8,7 @@
  *  distribution for more details.
  */
 
+#include <linux/unistd.h>
 #include <asm/desc.h>
 #include <asm/i387.h>
 
diff -puN checkpoint/checkpoint_arch.h~v6_PATCH_4_9_Dump_memory_address_space checkpoint/checkpoint_arch.h
--- linux-2.6.git/checkpoint/checkpoint_arch.h~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/checkpoint_arch.h	2008-10-16 10:53:36.000000000 -0700
@@ -2,6 +2,8 @@
 
 extern int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
+extern int cr_write_mm_context(struct cr_ctx *ctx,
+			       struct mm_struct *mm, int parent);
 
 extern int cr_read_thread(struct cr_ctx *ctx);
 extern int cr_read_cpu(struct cr_ctx *ctx);
diff -puN checkpoint/checkpoint.c~v6_PATCH_4_9_Dump_memory_address_space checkpoint/checkpoint.c
--- linux-2.6.git/checkpoint/checkpoint.c~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/checkpoint.c	2008-10-16 10:53:36.000000000 -0700
@@ -55,6 +55,55 @@ int cr_write_string(struct cr_ctx *ctx, 
 	return cr_write_obj(ctx, &h, str);
 }
 
+/**
+ * cr_fill_fname - return pathname of a given file
+ * @path: path name
+ * @root: relative root
+ * @buf: buffer for pathname
+ * @n: buffer length (in) and pathname length (out)
+ */
+static char *
+cr_fill_fname(struct path *path, struct path *root, char *buf, int *n)
+{
+	char *fname;
+
+	BUG_ON(!buf);
+	fname = __d_path(path, root, buf, *n);
+	if (!IS_ERR(fname))
+		*n = (buf + (*n) - fname);
+	return fname;
+}
+
+/**
+ * cr_write_fname - write a file name
+ * @ctx: checkpoint context
+ * @path: path name
+ * @root: relative root
+ */
+int cr_write_fname(struct cr_ctx *ctx, struct path *path, struct path *root)
+{
+	struct cr_hdr h;
+	char *buf, *fname;
+	int ret, flen;
+
+	flen = PATH_MAX;
+	buf = kmalloc(flen, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	fname = cr_fill_fname(path, root, buf, &flen);
+	if (!IS_ERR(fname)) {
+		h.type = CR_HDR_FNAME;
+		h.len = flen;
+		h.parent = 0;
+		ret = cr_write_obj(ctx, &h, fname);
+	} else
+		ret = PTR_ERR(fname);
+
+	kfree(buf);
+	return ret;
+}
+
 /* write the checkpoint header */
 static int cr_write_head(struct cr_ctx *ctx)
 {
@@ -150,6 +199,10 @@ static int cr_write_task(struct cr_ctx *
 	cr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_write_mm(ctx, t);
+	cr_debug("memory: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_write_thread(ctx, t);
 	cr_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff -puN /dev/null checkpoint/checkpoint_mem.h
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/checkpoint_mem.h	2008-10-16 10:53:36.000000000 -0700
@@ -0,0 +1,41 @@
+#ifndef _CHECKPOINT_CKPT_MEM_H_
+#define _CHECKPOINT_CKPT_MEM_H_
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/mm_types.h>
+
+/*
+ * page-array chains: each cr_pgarr describes a set of <strcut page *,vaddr>
+ * tuples (where vaddr is the virtual address of a page in a particular mm).
+ * Specifically, we use separate arrays so that all vaddrs can be written
+ * and read at once.
+ */
+
+struct cr_pgarr {
+	unsigned long *vaddrs;
+	struct page **pages;
+	unsigned int nr_used;
+	struct list_head list;
+};
+
+#define CR_PGARR_TOTAL  (PAGE_SIZE / sizeof(void *))
+#define CR_PGARR_CHUNK  (4 * CR_PGARR_TOTAL)
+
+extern void cr_pgarr_free(struct cr_ctx *ctx);
+extern struct cr_pgarr *cr_pgarr_current(struct cr_ctx *ctx);
+extern void cr_pgarr_reset_all(struct cr_ctx *ctx);
+
+static inline int cr_pgarr_is_full(struct cr_pgarr *pgarr)
+{
+	return (pgarr->nr_used == CR_PGARR_TOTAL);
+}
+
+#endif /* _CHECKPOINT_CKPT_MEM_H_ */
diff -puN /dev/null checkpoint/ckpt_mem.c
--- /dev/null	2008-09-02 09:40:19.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/ckpt_mem.c	2008-10-16 10:53:36.000000000 -0700
@@ -0,0 +1,500 @@
+/*
+ *  Checkpoint memory contents
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include "checkpoint_arch.h"
+#include "checkpoint_mem.h"
+
+/*
+ * utilities to alloc, free, and handle 'struct cr_pgarr' (page-arrays)
+ * (common to ckpt_mem.c and rstr_mem.c).
+ *
+ * The checkpoint context structure has two members for page-arrays:
+ *   ctx->pgarr_list: list head of the page-array chain
+ *
+ * During checkpoint (and restart) the chain tracks the dirty pages (page
+ * pointer and virtual address) of each MM. For a particular MM, these are
+ * always added to the head of the page-array chain (ctx->pgarr_list).
+ * This "current" page-array advances as necessary, and new page-array
+ * descriptors are allocated on-demand. Before the next chunk of pages,
+ * the chain is reset but not freed (that is, dereference page pointers).
+ */
+
+/* return first page-array in the chain */
+static inline struct cr_pgarr *cr_pgarr_first(struct cr_ctx *ctx)
+{
+	if (list_empty(&ctx->pgarr_list))
+		return NULL;
+	return list_first_entry(&ctx->pgarr_list, struct cr_pgarr, list);
+}
+
+/* release pages referenced by a page-array */
+static void cr_pgarr_release_pages(struct cr_pgarr *pgarr)
+{
+	int i;
+
+	cr_debug("nr_used %d\n", pgarr->nr_used);
+	/*
+	 * although both checkpoint and restart use 'nr_used', we only
+	 * collect pages during checkpoint; in restart we simply return
+	 */
+	if (!pgarr->pages)
+		return;
+	for (i = pgarr->nr_used; i--; /**/)
+		page_cache_release(pgarr->pages[i]);
+}
+
+/* free a single page-array object */
+static void cr_pgarr_free_one(struct cr_pgarr *pgarr)
+{
+	cr_pgarr_release_pages(pgarr);
+	kfree(pgarr->pages);
+	kfree(pgarr->vaddrs);
+	kfree(pgarr);
+}
+
+/* free a chain of page-arrays */
+void cr_pgarr_free(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr, *tmp;
+
+	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_list, list) {
+		list_del(&pgarr->list);
+		cr_pgarr_free_one(pgarr);
+	}
+}
+
+/* allocate a single page-array object */
+static struct cr_pgarr *cr_pgarr_alloc_one(unsigned long flags)
+{
+	struct cr_pgarr *pgarr;
+
+	pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL);
+	if (!pgarr)
+		return NULL;
+
+	pgarr->vaddrs = kmalloc(CR_PGARR_TOTAL * sizeof(unsigned long),
+				GFP_KERNEL);
+	if (!pgarr->vaddrs)
+		goto nomem;
+
+	/* pgarr->pages is needed only for checkpoint */
+	if (flags & CR_CTX_CKPT) {
+		pgarr->pages = kmalloc(CR_PGARR_TOTAL * sizeof(struct page *),
+				       GFP_KERNEL);
+		if (!pgarr->pages)
+			goto nomem;
+	}
+
+	return pgarr;
+
+ nomem:
+	cr_pgarr_free_one(pgarr);
+	return NULL;
+}
+
+/* cr_pgarr_current - return the next available page-array in the chain
+ * @ctx: checkpoint context
+ *
+ * Returns the first page-array in the list that has space. Extends the
+ * list if none has space.
+ */
+struct cr_pgarr *cr_pgarr_current(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr;
+
+	pgarr = cr_pgarr_first(ctx);
+	if (pgarr && !cr_pgarr_is_full(pgarr))
+		goto out;
+	pgarr = cr_pgarr_alloc_one(ctx->flags);
+	if (!pgarr)
+		goto out;
+	list_add(&pgarr->list, &ctx->pgarr_list);
+ out:
+	return pgarr;
+}
+
+/* reset the page-array chain (dropping page references if necessary) */
+void cr_pgarr_reset_all(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr;
+
+	list_for_each_entry(pgarr, &ctx->pgarr_list, list) {
+		cr_pgarr_release_pages(pgarr);
+		pgarr->nr_used = 0;
+	}
+}
+
+/*
+ * Checkpoint is outside the context of the checkpointee, so one cannot
+ * simply read pages from user-space. Instead, we scan the address space
+ * of the target to cherry-pick pages of interest. Selected pages are
+ * enlisted in a page-array chain (attached to the checkpoint context).
+ * To save their contents, each page is mapped to kernel memory and then
+ * dumped to the file descriptor.
+ */
+
+
+/**
+ * cr_private_follow_page - return page pointer for dirty pages
+ * @vma - target vma
+ * @addr - page address
+ *
+ * Looks up the page that correspond to the address in the vma, and
+ * returns the page if it was modified (and grabs a reference to it),
+ * or otherwise returns NULL (or error).
+ *
+ * This function should _only_ called for private vma's.
+ */
+static struct page *
+cr_private_follow_page(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct page *page;
+
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	/*
+	 * simplified version of get_user_pages(): already have vma,
+	 * only need FOLL_ANON, and (for now) ignore fault stats.
+	 *
+	 * follow_page() will return NULL if the page is not present
+	 * (swapped), ZERO_PAGE(0) if the pte wasn't allocated, and
+	 * the actual page pointer otherwise.
+	 *
+	 * FIXME: consolidate with get_user_pages()
+	 */
+
+	cond_resched();
+	while (!(page = follow_page(vma, addr, FOLL_ANON | FOLL_GET))) {
+		int ret;
+
+		/* the page is swapped out - bring it in (optimize ?) */
+		ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
+		if (ret & VM_FAULT_ERROR) {
+			if (ret & VM_FAULT_OOM)
+				return ERR_PTR(-ENOMEM);
+			else if (ret & VM_FAULT_SIGBUS)
+				return ERR_PTR(-EFAULT);
+			else
+				BUG();
+			break;
+		}
+		cond_resched();
+	}
+
+	if (IS_ERR(page))
+		return page;
+
+	/*
+	 * We only care about dirty pages: either non-zero page, or
+	 * file-backed (copy-on-write) that were touched. For the latter,
+	 * the page_mapping() will be unset because it will no longer be
+	 * mapped to the original file  after having been modified.
+	 */
+	if (page == ZERO_PAGE(0)) {
+		/* this is the zero page: ignore */
+		page_cache_release(page);
+		page = NULL;
+	} else if (vma->vm_file && (page_mapping(page) != NULL)) {
+		/* file backed clean cow: ignore */
+		page_cache_release(page);
+		page = NULL;
+	}
+
+	return page;
+}
+
+/**
+ * cr_private_vma_fill_pgarr - fill a page-array with addr/page tuples
+ * @ctx - checkpoint context
+ * @pgarr - page-array to fill
+ * @vma - vma to scan
+ * @start - start address (updated)
+ *
+ * Returns the number of pages collected
+ */
+static int
+cr_private_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
+			  struct vm_area_struct *vma, unsigned long *start)
+{
+	unsigned long end = vma->vm_end;
+	unsigned long addr = *start;
+	int orig_used = pgarr->nr_used;
+
+	/* this function is only for private memory (anon or file-mapped) */
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	while (addr < end) {
+		struct page *page;
+
+		page = cr_private_follow_page(vma, addr);
+		if (IS_ERR(page))
+			return PTR_ERR(page);
+
+		if (page) {
+			pgarr->pages[pgarr->nr_used] = page;
+			pgarr->vaddrs[pgarr->nr_used] = addr;
+			pgarr->nr_used++;
+		}
+
+		addr += PAGE_SIZE;
+
+		if (cr_pgarr_is_full(pgarr))
+			break;
+	}
+
+	*start = addr;
+	return pgarr->nr_used - orig_used;
+}
+
+/* dump contents of a pages: use kmap_atomic() to avoid TLB flush */
+static int cr_page_write(struct cr_ctx *ctx, struct page *page, char *buf)
+{
+	void *ptr;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(buf, ptr, PAGE_SIZE);
+	kunmap_atomic(page, KM_USER1);
+
+	return cr_kwrite(ctx, buf, PAGE_SIZE);
+}
+
+/**
+ * cr_vma_dump_pages - dump pages listed in the ctx page-array chain
+ * @ctx - checkpoint context
+ * @total - total number of pages
+ *
+ * First dump all virtual addresses, followed by the contents of all pages
+ */
+static int cr_vma_dump_pages(struct cr_ctx *ctx, int total)
+{
+	struct cr_pgarr *pgarr;
+	char *buf;
+	int i, ret = 0;
+
+	if (!total)
+		return 0;
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		ret = cr_kwrite(ctx, pgarr->vaddrs,
+				pgarr->nr_used * sizeof(*pgarr->vaddrs));
+		if (ret < 0)
+			return ret;
+	}
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		for (i = 0; i < pgarr->nr_used; i++) {
+			ret = cr_page_write(ctx, pgarr->pages[i], buf);
+			if (ret < 0)
+				goto out;
+		}
+	}
+
+ out:
+	kfree(buf);
+	return ret;
+}
+
+/**
+ * cr_write_private_vma_contents - dump contents of a VMA with private memory
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ *
+ * Collect lists of pages that needs to be dumped, and corresponding
+ * virtual addresses into ctx->pgarr_list page-array chain. Then dump
+ * the addresses, followed by the page contents.
+ */
+static int
+cr_write_private_vma_contents(struct cr_ctx *ctx, struct vm_area_struct *vma)
+{
+	struct cr_hdr h;
+	struct cr_hdr_pgarr *hh;
+	unsigned long addr = vma->vm_start;
+	struct cr_pgarr *pgarr;
+	unsigned long cnt = 0;
+	int ret;
+
+	/*
+	 * Work iteratively, collecting and dumping at most CR_PGARR_CHUNK
+	 * in each round. Each iterations is divided into two steps:
+	 *
+	 * (1) scan: scan through the PTEs of the vma to collect the pages
+	 * to dump (later we'll also make them COW), while keeping a list
+	 * of pages and their corresponding addresses on ctx->pgarr_list.
+	 *
+	 * (2) dump: write out a header specifying how many pages, followed
+	 * by the addresses of all pages in ctx->pgarr_list, followed by
+	 * the actual contents of all pages. (Then, release the references
+	 * to the pages and reset the page-array chain).
+	 *
+	 * (This split makes the logic simpler by first counting the pages
+	 * that need saving. More importantly, it allows for a future
+	 * optimization that will reduce application downtime by deferring
+	 * the actual write-out of the data to after the application is
+	 * allowed to resume execution).
+	 *
+	 * After dumpting the entire contents, conclude with a header that
+	 * specifies 0 pages to mark the end of the contents.
+	 */
+
+	h.type = CR_HDR_PGARR;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	while (addr < vma->vm_end) {
+		pgarr = cr_pgarr_current(ctx);
+		if (!pgarr)
+			return -ENOMEM;
+		ret = cr_private_vma_fill_pgarr(ctx, pgarr, vma, &addr);
+		if (ret < 0)
+			return ret;
+		cnt += ret;
+
+		/* did we complete a chunk, or is this the last chunk ? */
+		if (cnt >= CR_PGARR_CHUNK || (cnt && addr == vma->vm_end)) {
+			hh = cr_hbuf_get(ctx, sizeof(*hh));
+			hh->nr_pages = cnt;
+			ret = cr_write_obj(ctx, &h, hh);
+			cr_hbuf_put(ctx, sizeof(*hh));
+			if (ret < 0)
+				return ret;
+
+			ret = cr_vma_dump_pages(ctx, cnt);
+			if (ret < 0)
+				return ret;
+
+			cr_pgarr_reset_all(ctx);
+		}
+	}
+
+	/* mark end of contents with header saying "0" pages */
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	hh->nr_pages = 0;
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return ret;
+}
+
+static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
+{
+	struct cr_hdr h;
+	struct cr_hdr_vma *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int vma_type, ret;
+
+	h.type = CR_HDR_VMA;
+	h.len = sizeof(*hh);
+	h.parent = 0;
+
+	hh->vm_start = vma->vm_start;
+	hh->vm_end = vma->vm_end;
+	hh->vm_page_prot = vma->vm_page_prot.pgprot;
+	hh->vm_flags = vma->vm_flags;
+	hh->vm_pgoff = vma->vm_pgoff;
+
+	if (vma->vm_flags & (VM_SHARED | VM_IO | VM_HUGETLB | VM_NONLINEAR)) {
+		pr_warning("CR: unsupported VMA %#lx\n", vma->vm_flags);
+		cr_hbuf_put(ctx, sizeof(*hh));
+		return -ENOSYS;
+	}
+
+	/* by default assume anon memory */
+	vma_type = CR_VMA_ANON;
+
+	/*
+	 * if there is a backing file, assume private-mapped
+	 * (FIXME: check if the file is unlinked)
+	 */
+	if (vma->vm_file)
+		vma_type = CR_VMA_FILE;
+
+	hh->vma_type = vma_type;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	/* save the file name, if relevant */
+	if (vma->vm_file) {
+		ret = cr_write_fname(ctx, &vma->vm_file->f_path, ctx->vfsroot);
+		if (ret < 0)
+			return ret;
+	}
+
+	return cr_write_private_vma_contents(ctx, vma);
+}
+
+int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int objref, ret;
+
+	h.type = CR_HDR_MM;
+	h.len = sizeof(*hh);
+	h.parent = task_pid_vnr(t);
+
+	mm = get_task_mm(t);
+
+	objref = 0;	/* will be meaningful with multiple processes */
+	hh->objref = objref;
+
+	down_read(&mm->mmap_sem);
+
+	hh->start_code = mm->start_code;
+	hh->end_code = mm->end_code;
+	hh->start_data = mm->start_data;
+	hh->end_data = mm->end_data;
+	hh->start_brk = mm->start_brk;
+	hh->brk = mm->brk;
+	hh->start_stack = mm->start_stack;
+	hh->arg_start = mm->arg_start;
+	hh->arg_end = mm->arg_end;
+	hh->env_start = mm->env_start;
+	hh->env_end = mm->env_end;
+
+	hh->map_count = mm->map_count;
+
+	/* FIX: need also mm->flags */
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		goto out;
+
+	/* write the vma's */
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		ret = cr_write_vma(ctx, vma);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = cr_write_mm_context(ctx, mm, objref);
+
+ out:
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+	return ret;
+}
diff -puN checkpoint/Makefile~v6_PATCH_4_9_Dump_memory_address_space checkpoint/Makefile
--- linux-2.6.git/checkpoint/Makefile~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/Makefile	2008-10-16 10:53:36.000000000 -0700
@@ -2,4 +2,5 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
+		ckpt_mem.o
diff -puN checkpoint/sys.c~v6_PATCH_4_9_Dump_memory_address_space checkpoint/sys.c
--- linux-2.6.git/checkpoint/sys.c~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/sys.c	2008-10-16 10:53:36.000000000 -0700
@@ -16,6 +16,8 @@
 #include <linux/capability.h>
 #include <linux/checkpoint.h>
 
+#include "checkpoint_mem.h"
+
 /*
  * helpers to write/read to/from the image file descriptor
  *
@@ -161,6 +163,11 @@ void cr_ctx_free(struct cr_ctx *ctx)
 
 	kfree(ctx->hbuf);
 
+	if (ctx->vfsroot)
+		path_put(ctx->vfsroot);
+
+	cr_pgarr_free(ctx);
+
 	kfree(ctx);
 }
 
@@ -184,6 +191,15 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, i
 		return ERR_PTR(-ENOMEM);
 	}
 
+	/*
+	 * assume checkpointer is in container's root vfs
+	 * FIXME: this works for now, but will change with real containers
+	 */
+	ctx->vfsroot = &current->fs->root;
+	path_get(ctx->vfsroot);
+
+	INIT_LIST_HEAD(&ctx->pgarr_list);
+
 	ctx->pid = pid;
 	ctx->flags = flags;
 
diff -puN include/asm-x86/checkpoint_hdr.h~v6_PATCH_4_9_Dump_memory_address_space include/asm-x86/checkpoint_hdr.h
--- linux-2.6.git/include/asm-x86/checkpoint_hdr.h~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/include/asm-x86/checkpoint_hdr.h	2008-10-16 10:53:36.000000000 -0700
@@ -69,4 +69,9 @@ struct cr_hdr_cpu {
 
 } __attribute__((aligned(8)));
 
+struct cr_hdr_mm_context {
+	__s16 ldt_entry_size;
+	__s16 nldt;
+} __attribute__((aligned(8)));
+
 #endif /* __ASM_X86_CKPT_HDR__H */
diff -puN include/linux/checkpoint.h~v6_PATCH_4_9_Dump_memory_address_space include/linux/checkpoint.h
--- linux-2.6.git/include/linux/checkpoint.h~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/include/linux/checkpoint.h	2008-10-16 10:53:36.000000000 -0700
@@ -10,6 +10,9 @@
  *  distribution for more details.
  */
 
+#include <linux/path.h>
+#include <linux/fs.h>
+
 #define CR_VERSION  1
 
 struct cr_ctx {
@@ -24,6 +27,10 @@ struct cr_ctx {
 
 	void *hbuf;		/* temporary buffer for headers */
 	int hpos;		/* position in headers buffer */
+
+	struct list_head pgarr_list;	/* page array to dump VMA contents */
+
+	struct path *vfsroot;	/* container root (FIXME) */
 };
 
 /* cr_ctx: flags */
@@ -42,11 +49,16 @@ struct cr_hdr;
 
 extern int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
 extern int cr_write_string(struct cr_ctx *ctx, char *str, int len);
+extern int cr_write_fname(struct cr_ctx *ctx,
+			  struct path *path, struct path *root);
 
 extern int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
 extern int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
 extern int cr_read_string(struct cr_ctx *ctx, void *str, int len);
 
+extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
+extern int cr_read_mm(struct cr_ctx *ctx);
+
 extern int do_checkpoint(struct cr_ctx *ctx);
 extern int do_restart(struct cr_ctx *ctx);
 
diff -puN include/linux/checkpoint_hdr.h~v6_PATCH_4_9_Dump_memory_address_space include/linux/checkpoint_hdr.h
--- linux-2.6.git/include/linux/checkpoint_hdr.h~v6_PATCH_4_9_Dump_memory_address_space	2008-10-16 10:53:36.000000000 -0700
+++ linux-2.6.git-dave/include/linux/checkpoint_hdr.h	2008-10-16 10:53:36.000000000 -0700
@@ -32,6 +32,7 @@ struct cr_hdr {
 enum {
 	CR_HDR_HEAD = 1,
 	CR_HDR_STRING,
+	CR_HDR_FNAME,
 
 	CR_HDR_TASK = 101,
 	CR_HDR_THREAD,
@@ -39,6 +40,7 @@ enum {
 
 	CR_HDR_MM = 201,
 	CR_HDR_VMA,
+	CR_HDR_PGARR,
 	CR_HDR_MM_CONTEXT,
 
 	CR_HDR_TAIL = 5001
@@ -73,4 +75,34 @@ struct cr_hdr_task {
 	__s32 task_comm_len;
 } __attribute__((aligned(8)));
 
+struct cr_hdr_mm {
+	__u32 objref;		/* identifier for shared objects */
+	__u32 map_count;
+
+	__u64 start_code, end_code, start_data, end_data;
+	__u64 start_brk, brk, start_stack;
+	__u64 arg_start, arg_end, env_start, env_end;
+} __attribute__((aligned(8)));
+
+/* vma subtypes */
+enum vm_type {
+	CR_VMA_ANON = 1,
+	CR_VMA_FILE
+};
+
+struct cr_hdr_vma {
+	__u32 vma_type;
+	__u32 _padding;
+
+	__u64 vm_start;
+	__u64 vm_end;
+	__u64 vm_page_prot;
+	__u64 vm_flags;
+	__u64 vm_pgoff;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_pgarr {
+	__u64 nr_pages;		/* number of pages to saved */
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
