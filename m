Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6UIxk1v022633
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 14:59:46 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6UIxeCl138244
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 12:59:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6UIxZbb000667
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 12:59:39 -0600
Subject: [RFC][PATCH] kernel-based memory checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 30 Jul 2008 11:59:30 -0700
Message-Id: <20080730185930.C9B4D879@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

The following is the necessary code to checkpoint and restart a
single process's memory, with no shared memory.  This is a
portion of patches posted to the containers@lists.osdl.org list.
If you want to play with this, you can get the rest of the code
there.

At the containers mini-conference before OLS, the consensus among
all the stakeholders was that doing checkpoint/restart in the kernel
as much as possible was the best approach.  With this approach, the
kernel will export a relatively opaque 'blob' of data to userspace
which can then be handed to the new kernel at restore time.  This
is different from what's been described at the kernel summit in
previous years, so I'm mostly forwarding this to let people know of
this change in direction.

The 'blob' will contain copies of select portions of kernel
structures such as vmas and mm_structs.  It will also contain
copies of the actual memory that the process uses.  Any changes
in this blob's format between kernel revisions can be handled by
an in-userspace conversion program.

This is a similar approach to virtually all of the commercial
checkpoint/restart products out there, as well as the research
project Zap.

Sorry about the C++ comments, please ignore them for now. :)

Notes on the dump format:

For each vma, there is a 'struct cr_vma'; if the vma is file-mapped,
it will be followed by the file name.  The cr_vma->npages will tell
how many pages were dumped for this vma.  Then it will be followed
by the actual data: first a dump of the addresses of all dumped
pages (npages entries) followed by a dump of the contents of all
dumped pages (npages pages). Then will come the next vma and so on.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---

 linux-2.6.git-dave/ckpt/Makefile     |    2 
 linux-2.6.git-dave/ckpt/checkpoint.c |    6 
 linux-2.6.git-dave/ckpt/ckpt_hdr.h   |   28 ++
 linux-2.6.git-dave/ckpt/ckpt_mem.c   |  421 +++++++++++++++++++++++++++++++++++
 linux-2.6.git-dave/ckpt/ckpt_mem.h   |   32 ++
 linux-2.6.git-dave/ckpt/restart.c    |    6 
 linux-2.6.git-dave/ckpt/rstr_mem.c   |  415 ++++++++++++++++++++++++++++++++++
 linux-2.6.git-dave/ckpt/sys.c        |    8 
 8 files changed, 907 insertions(+), 11 deletions(-)

diff -puN ckpt/checkpoint.c~memory_part ckpt/checkpoint.c
--- linux-2.6.git/ckpt/checkpoint.c~memory_part	2008-07-30 11:51:00.000000000 -0700
+++ linux-2.6.git-dave/ckpt/checkpoint.c	2008-07-30 11:51:00.000000000 -0700
@@ -333,9 +333,9 @@ static int cr_write_task(struct cr_ctx *
 
 	ret = cr_write_task_struct(ctx, t);
 	CR_PRINTK("ret (task_struct) %d\n", ret);
-//	if (!ret)
-//		ret = cr_write_mm(ctx, t);
-//	CR_PRINTK("ret (mm) %d\n", ret);
+	if (!ret)
+		ret = cr_write_mm(ctx, t);
+	CR_PRINTK("ret (mm) %d\n", ret);
 	if (!ret)
 		ret = cr_write_thread(ctx, t);
 	CR_PRINTK("ret (thread) %d\n", ret);
diff -puN /dev/null ckpt/ckpt_mem.c
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/ckpt_mem.c	2008-07-30 11:51:00.000000000 -0700
@@ -0,0 +1,421 @@
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
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+
+#if defined(CONFIG_X86)
+#include <asm/ldt.h>
+#endif
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+#include "ckpt_mem.h"
+
+/*
+ * utilities to alloc, free, and handle 'struct cr_pgarr'
+ * (common to ckpt_mem.c and rstr_mem.c)
+ */
+
+#define CR_ORDER_PGARR  0
+#define CR_PGARR_TOTAL  ((PAGE_SIZE << CR_ORDER_PGARR) / sizeof(void *))
+
+/* release pages referenced by a page-array */
+void _cr_pgarr_release(struct cr_ctx *ctx, struct cr_pgarr *pgarr)
+{
+	int n;
+
+	/* only checkpoint keeps references to pages */
+	if (ctx->flags & CR_CTX_CKPT) {
+		CR_PRINTK("release pages (nused %d)\n", pgarr->nused);
+		for (n = pgarr->nused; n--; )
+			page_cache_release(pgarr->pages[n]);
+	}
+	pgarr->nused = 0;
+	pgarr->nleft = CR_PGARR_TOTAL;
+}
+
+/* release pages referenced by chain of page-arrays */
+void cr_pgarr_release(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next)
+		_cr_pgarr_release(ctx, pgarr);
+}
+
+/* free a chain of page-arrays */
+void cr_pgarr_free(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr, *pgnxt;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgnxt) {
+		_cr_pgarr_release(ctx, pgarr);
+		free_pages((unsigned long) ctx->pgarr->addrs, CR_ORDER_PGARR);
+		free_pages((unsigned long) ctx->pgarr->pages, CR_ORDER_PGARR);
+		pgnxt = pgarr->next;
+		kfree(pgarr);
+	}
+}
+
+/* allocate and add a new page-array to chain */
+struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx, struct cr_pgarr **pgnew)
+{
+	struct cr_pgarr *pgarr = ctx->pgcur;
+
+	if (pgarr && pgarr->next) {
+		ctx->pgcur = pgarr->next;
+		return pgarr->next;
+	}
+
+	if ((pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL))) {
+		pgarr->nused = 0;
+		pgarr->nleft = CR_PGARR_TOTAL;
+		pgarr->addrs = (unsigned long *)
+			__get_free_pages(GFP_KERNEL, CR_ORDER_PGARR);
+		pgarr->pages = (struct page **)
+			__get_free_pages(GFP_KERNEL, CR_ORDER_PGARR);
+		if (likely(pgarr->addrs && pgarr->pages)) {
+			*pgnew = pgarr;
+			ctx->pgcur = pgarr;
+			return pgarr;
+		} else if (pgarr->addrs)
+			free_pages((unsigned long) pgarr->addrs,
+				   CR_ORDER_PGARR);
+		kfree(pgarr);
+	}
+
+	return NULL;
+}
+
+/* return current page-array (and allocate if needed) */
+struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr = ctx->pgcur;
+
+	if (unlikely(!pgarr->nleft))
+		pgarr = cr_pgarr_alloc(ctx, &pgarr->next);
+	return pgarr;
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
+/**
+ * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
+ * @ctx - checkpoint context
+ * @pgarr - page-array to fill
+ * @vma - vma to scan
+ * @start - start address (updated)
+ */
+static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
+			     struct vm_area_struct *vma, unsigned long *start)
+{
+	unsigned long end = vma->vm_end;
+	unsigned long addr = *start;
+	struct page **pagep;
+	unsigned long *addrp;
+	int cow, nr, ret = 0;
+
+	nr = pgarr->nleft;
+	pagep = &pgarr->pages[pgarr->nused];
+	addrp = &pgarr->addrs[pgarr->nused];
+	cow = !!vma->vm_file;
+
+	while (addr < end) {
+		struct page *page;
+
+		/* simplified version of get_user_pages(): already have vma,
+		* only need FOLL_TOUCH, and (for now) ignore fault stats */
+
+		cond_resched();
+		while (!(page = follow_page(vma, addr, FOLL_TOUCH))) {
+			ret = handle_mm_fault(vma->vm_mm, vma, addr, 0);
+			if (ret & VM_FAULT_ERROR) {
+				if (ret & VM_FAULT_OOM)
+					ret = -ENOMEM;
+				else if (ret & VM_FAULT_SIGBUS)
+					ret = -EFAULT;
+				else
+					BUG();
+				break;
+			}
+			cond_resched();
+		}
+
+		if (IS_ERR(page)) {
+			ret = PTR_ERR(page);
+			break;
+		}
+
+		if (page == ZERO_PAGE(0))
+			page = NULL;	/* zero page: ignore */
+		else if (cow && page_mapping(page) != NULL)
+			page = NULL;	/* clean cow: ignore */
+		else {
+			get_page(page);
+			*(addrp++) = addr;
+			*(pagep++) = page;
+			if (--nr == 0) {
+				addr += PAGE_SIZE;
+				break;
+			}
+		}
+
+		addr += PAGE_SIZE;
+	}
+
+	if (unlikely(ret < 0)) {
+		nr = pgarr->nleft - nr;
+		while (nr--)
+			page_cache_release(*(--pagep));
+		return ret;
+	}
+
+	*start = addr;
+	return (pgarr->nleft - nr);
+}
+
+/**
+ * cr_vma_scan_pages - scan vma for pages that will need to be dumped
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ *
+ * a list of addr/page tuples is kept in ctx->pgarr page-array chain
+ */
+static int cr_vma_scan_pages(struct cr_ctx *ctx, struct vm_area_struct *vma)
+{
+	unsigned long addr = vma->vm_start;
+	unsigned long end = vma->vm_end;
+	struct cr_pgarr *pgarr;
+	int nr, total = 0;
+
+	while (addr < end) {
+		if (!(pgarr = cr_pgarr_prep(ctx)))
+			return -ENOMEM;
+		if ((nr = cr_vma_fill_pgarr(ctx, pgarr, vma, &addr)) < 0)
+			return nr;
+		pgarr->nleft -= nr;
+		pgarr->nused += nr;
+		total += nr;
+	}
+
+	CR_PRINTK("total %d\n", total);
+	return total;
+}
+
+/**
+ * cr_vma_dump_pages - dump pages listed in the ctx page-array chain
+ * @ctx - checkpoint context
+ * @total - total number of pages
+ */
+static int cr_vma_dump_pages(struct cr_ctx *ctx, int total)
+{
+	struct cr_pgarr *pgarr;
+	int ret;
+
+	if (!total)
+		return 0;
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next) {
+		ret = cr_kwrite(ctx, pgarr->addrs,
+			       pgarr->nused * sizeof(*pgarr->addrs));
+		if (ret < 0)
+			return ret;
+	}
+
+	for (pgarr = ctx->pgarr; pgarr; pgarr = pgarr->next) {
+		struct page **pages = pgarr->pages;
+		int nr = pgarr->nused;
+		void *ptr;
+
+		while (nr--) {
+			ptr = kmap(*pages);
+			ret = cr_kwrite(ctx, ptr, PAGE_SIZE);
+			kunmap(*pages);
+			if (ret < 0)
+				return ret;
+			pages++;
+		}
+	}
+
+	return total;
+}
+
+static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
+{
+	struct cr_hdr h;
+	struct cr_hdr_vma *hh = ctx->tbuf;
+	char *fname = NULL;
+	int how, nr, ret;
+
+	h.type = CR_HDR_VMA;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
+
+	hh->vm_start = vma->vm_start;
+	hh->vm_end = vma->vm_end;
+	hh->vm_page_prot = vma->vm_page_prot.pgprot;
+	hh->vm_flags = vma->vm_flags;
+	hh->vm_pgoff = vma->vm_pgoff;
+
+	if (vma->vm_flags & (VM_SHARED | VM_IO | VM_HUGETLB | VM_NONLINEAR)) {
+		printk(KERN_WARNING "CR: unknown VMA %#lx\n", vma->vm_flags);
+		return -ETXTBSY;
+	}
+
+	/* by default assume anon memory */
+	how = CR_VMA_ANON;
+
+	/* if there is a backing file, assume private-mapped */
+	/* (NEED: check if the file is unlinked) */
+	if (vma->vm_file) {
+		nr = PAGE_SIZE;
+		fname = cr_get_fname(&vma->vm_file->f_path,
+				     ctx->vfsroot, ctx->tbuf, &nr);
+		if (IS_ERR(fname))
+			return PTR_ERR(fname);
+		hh->namelen = nr;
+		how = CR_VMA_FILE;
+	} else
+		hh->namelen = 0;
+
+	hh->how = how;
+
+	/*
+	 * it seems redundant now, but we do it in 3 steps for because:
+	 * first, the logic is simpler when we how many pages before
+	 * dumping them; second, a future optimization will defer the
+	 * writeout (dump, and free) to a later step; in which case all
+	 * the pages to be dumped will be aggregated on the checkpoint ctx
+	 */
+
+	/* (1) scan: scan through the PTEs of the vma, both to count the
+	 * pages to dump, and make those pages COW. keep the list of pages
+	 * (and a reference to each page) on the checkpoint ctx */
+	nr = cr_vma_scan_pages(ctx, vma);
+	if (nr < 0) {
+		cr_put_fname(ctx->tbuf, fname, PAGE_SIZE);
+		return nr;
+	}
+
+	hh->npages = nr;
+	ret = cr_write_obj(ctx, &h, hh);
+
+	if (!ret && hh->namelen)
+		ret = cr_write_str(ctx, fname, hh->namelen);
+
+	cr_put_fname(ctx->tbuf, fname, PAGE_SIZE);
+
+	if (ret < 0)
+		return ret;
+
+	/* (2) dump: write out the addresses of all pages in the list (on
+	 * the checkpoint ctx) followed by the contents of all pages */
+	ret = cr_vma_dump_pages(ctx, nr);
+
+	/* (3) free: free the extra references to the pages in the list */
+	cr_pgarr_release(ctx);
+
+	return ret;
+}
+
+#if defined(CONFIG_X86)
+static int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm_context *hh = ctx->tbuf;
+	int ret;
+
+	h.type = CR_HDR_MM_CONTEXT;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
+
+	mutex_lock(&mm->context.lock);
+
+	hh->ldt_entry_size = LDT_ENTRY_SIZE;
+	hh->nldt = mm->context.size;
+
+	CR_PRINTK("nldt %d\n", hh->nldt);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		return ret;
+
+	ret = cr_kwrite(ctx, mm->context.ldt, hh->nldt * LDT_ENTRY_SIZE);
+
+	mutex_unlock(&mm->context.lock);
+
+	return ret;
+}
+#endif
+
+int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
+{
+	struct cr_hdr h;
+	struct cr_hdr_mm *hh = ctx->tbuf;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int ret;
+
+	h.type = CR_HDR_MM;
+	h.len = sizeof(*hh);
+	h.id = ctx->pid;
+
+	mm = get_task_mm(t);
+
+	hh->tag = 1;	/* non-zero will mean first time encounter */
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
+	if (ret < 0)
+		goto out;
+
+	/* write the vma's */
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if ((ret = cr_write_vma(ctx, vma)) < 0)
+			break;
+	}
+	up_read(&mm->mmap_sem);
+
+	if (ret < 0)
+		goto out;
+
+	ret = cr_write_mm_context(ctx, mm);
+
+ out:
+	mmput(mm);
+	return ret;
+}
diff -puN /dev/null ckpt/ckpt_mem.h
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/ckpt_mem.h	2008-07-30 11:51:00.000000000 -0700
@@ -0,0 +1,32 @@
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
+/* page-array chains: each pgarr hols a list of <addr,page> tuples */
+struct cr_pgarr {
+	unsigned long *addrs;
+	struct page **pages;
+	struct cr_pgarr *next;
+	unsigned short nleft;
+	unsigned short nused;
+};
+
+/* vma subtypes */
+enum {
+	CR_VMA_ANON = 1,
+	CR_VMA_FILE
+};
+
+extern void _cr_pgarr_release(struct cr_ctx *ctx, struct cr_pgarr *pgarr);
+extern void cr_pgarr_release(struct cr_ctx *ctx);
+extern void cr_pgarr_free(struct cr_ctx *ctx);
+extern struct cr_pgarr *cr_pgarr_alloc(struct cr_ctx *ctx, struct cr_pgarr **pgnew);
+extern struct cr_pgarr *cr_pgarr_prep(struct cr_ctx *ctx);
diff -puN ckpt/Makefile~memory_part ckpt/Makefile
--- linux-2.6.git/ckpt/Makefile~memory_part	2008-07-30 11:51:00.000000000 -0700
+++ linux-2.6.git-dave/ckpt/Makefile	2008-07-30 11:51:00.000000000 -0700
@@ -1 +1 @@
-obj-y += sys.o checkpoint.o restart.o
+obj-y += sys.o checkpoint.o restart.o ckpt_mem.o rstr_mem.o
diff -puN ckpt/restart.c~memory_part ckpt/restart.c
--- linux-2.6.git/ckpt/restart.c~memory_part	2008-07-30 11:51:00.000000000 -0700
+++ linux-2.6.git-dave/ckpt/restart.c	2008-07-30 11:51:00.000000000 -0700
@@ -301,9 +301,9 @@ static int cr_read_task(struct cr_ctx *c
 
 	ret = cr_read_task_struct(ctx);
 	CR_PRINTK("ret (task_struct) %d\n", ret);
-//	if (!ret)
-//		ret = cr_read_mm(ctx);
-//	CR_PRINTK("ret (mm) %d\n", ret);
+	if (!ret)
+		ret = cr_read_mm(ctx);
+	CR_PRINTK("ret (mm) %d\n", ret);
 	if (!ret)
 		ret = cr_read_thread(ctx);
 	CR_PRINTK("ret (thread) %d\n", ret);
diff -puN /dev/null ckpt/rstr_mem.c
--- /dev/null	2007-04-11 11:48:27.000000000 -0700
+++ linux-2.6.git-dave/ckpt/rstr_mem.c	2008-07-30 11:51:00.000000000 -0700
@@ -0,0 +1,415 @@
+/*
+ *  Restart memory contents
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <asm/unistd.h>
+
+#include <linux/sched.h>
+#include <linux/fcntl.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/mm_types.h>
+#include <linux/mman.h>
+#include <linux/mm.h>
+#include <linux/err.h>
+#include <asm/cacheflush.h>
+
+#if defined(CONFIG_X86)
+#include <asm/desc.h>
+#include <asm/ldt.h>
+#endif
+
+#include "ckpt.h"
+#include "ckpt_hdr.h"
+#include "ckpt_mem.h"
+
+/*
+ * Unlike checkpoint, restart is executed in the context of each restarting
+ * process: vma regions are restored via a call to mmap(), and the data is
+ * read in directly to the address space of the current process
+ */
+
+/**
+ * cr_vma_read_pages_addr - read addresses of pages to page-array chain
+ * @ctx - restart context
+ * @npages - number of pages
+ */
+static int cr_vma_read_pages_addr(struct cr_ctx *ctx, int npages)
+{
+	struct cr_pgarr *pgarr;
+	int nr, ret;
+
+	while (npages) {
+		if (!(pgarr = cr_pgarr_prep(ctx)))
+			return -ENOMEM;
+		nr = min(npages, (int) pgarr->nleft);
+		ret = cr_kread(ctx, pgarr->addrs, nr * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+		pgarr->nleft -= nr;
+		pgarr->nused += nr;
+		npages -= nr;
+	}
+	return 0;
+}
+
+/**
+ * cr_vma_read_pages_data - read in data of pages in page-array chain
+ * @ctx - restart context
+ * @npages - number of pages
+ */
+static int cr_vma_read_pages_data(struct cr_ctx *ctx, int npages)
+{
+	struct cr_pgarr *pgarr;
+	unsigned long *addrs;
+	int nr, ret;
+
+	for (pgarr = ctx->pgarr; npages; pgarr = pgarr->next) {
+		addrs = pgarr->addrs;
+		nr = pgarr->nused;
+		npages -= nr;
+		while (nr--) {
+			ret = cr_uread(ctx, (void *) *(addrs++), PAGE_SIZE);
+			if (ret < 0)
+				return ret;
+		}
+	}
+
+	return 0;
+}
+
+/* change the protection of an address range to be writable/non-writable.
+ * this is useful when restoring the memory of a read-only vma */
+static int cr_vma_writable(struct mm_struct *mm, unsigned long start,
+			   unsigned long end, int writable)
+{
+	struct vm_area_struct *vma, *prev;
+	unsigned long flags = 0;
+	int ret = -EINVAL;
+
+	CR_PRINTK("vma %#lx-%#lx writable %d\n", start, end, writable);
+
+	down_write(&mm->mmap_sem);
+	vma = find_vma_prev(mm, start, &prev);
+	if (unlikely(!vma || vma->vm_start > end || vma->vm_end < start))
+		goto out;
+	if (writable && !(vma->vm_flags & VM_WRITE))
+		flags = vma->vm_flags | VM_WRITE;
+	else if (!writable && (vma->vm_flags & VM_WRITE))
+		flags = vma->vm_flags & ~VM_WRITE;
+	CR_PRINTK("flags %#lx\n", flags);
+	if (flags)
+		ret = mprotect_fixup(vma, &prev, vma->vm_start,
+				     vma->vm_end, flags);
+ out:
+	up_write(&mm->mmap_sem);
+	return ret;
+}
+
+/**
+ * cr_vma_read_pages - read in pages for to restore a vma
+ * @ctx - restart context
+ * @cr_vma - vma descriptor from restart
+ */
+static int cr_vma_read_pages(struct cr_ctx *ctx, struct cr_hdr_vma *cr_vma)
+{
+	struct mm_struct *mm = current->mm;
+	int ret = 0;
+
+	if (!cr_vma->npages)
+		return 0;
+
+	/* in the unlikely case that this vma is read-only */
+	if (!(cr_vma->vm_flags & VM_WRITE))
+		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 1);
+
+	if (!ret)
+		ret = cr_vma_read_pages_addr(ctx, cr_vma->npages);
+	if (!ret)
+		ret = cr_vma_read_pages_data(ctx, cr_vma->npages);
+	if (ret < 0)
+		return ret;
+
+	cr_pgarr_release(ctx);	/* reset page-array chain */
+
+	/* restore original protection for this vma */
+	if (!(cr_vma->vm_flags & VM_WRITE))
+		ret = cr_vma_writable(mm, cr_vma->vm_start, cr_vma->vm_end, 0);
+
+	return ret;
+}
+
+/**
+ * cr_calc_map_prot_bits - convert vm_flags to mmap protection
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long cr_calc_map_prot_bits(unsigned long orig_vm_flags)
+{
+	unsigned long vm_prot = 0;
+
+	if (orig_vm_flags & VM_READ)
+		vm_prot |= PROT_READ;
+	if (orig_vm_flags & VM_WRITE)
+		vm_prot |= PROT_WRITE;
+	if (orig_vm_flags & VM_EXEC)
+		vm_prot |= PROT_EXEC;
+	if (orig_vm_flags & PROT_SEM)   /* only (?) with IPC-SHM  */
+		vm_prot |= PROT_SEM;
+
+	return vm_prot;
+}
+
+/**
+ * cr_calc_map_flags_bits - convert vm_flags to mmap flags
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long cr_calc_map_flags_bits(unsigned long orig_vm_flags)
+{
+	unsigned long vm_flags = 0;
+
+	vm_flags = MAP_FIXED;
+	if (orig_vm_flags & VM_GROWSDOWN)
+		vm_flags |= MAP_GROWSDOWN;
+	if (orig_vm_flags & VM_DENYWRITE)
+		vm_flags |= MAP_DENYWRITE;
+	if (orig_vm_flags & VM_EXECUTABLE)
+		vm_flags |= MAP_EXECUTABLE;
+	if (orig_vm_flags & VM_MAYSHARE)
+		vm_flags |= MAP_SHARED;
+	else
+		vm_flags |= MAP_PRIVATE;
+
+	return vm_flags;
+}
+
+static int cr_read_vma(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	struct cr_hdr_vma *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	unsigned long vm_size, vm_flags, vm_prot, vm_pgoff;
+	unsigned long addr;
+	unsigned long flags;
+	struct file *file = NULL;
+	char *fname = NULL;
+	int ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
+	if (ret < 0)
+		return ret;
+
+	CR_PRINTK("vma %#lx-%#lx npages %d namelen %d\n",
+		  (unsigned long) hh->vm_start, (unsigned long) hh->vm_end,
+		  (int) hh->npages, (int) hh->namelen);
+
+	if (hh->vm_end < hh->vm_start)
+		return -EINVAL;
+	if (hh->npages < 0 || hh->namelen < 0)
+		return -EINVAL;
+
+	vm_size = hh->vm_end - hh->vm_start;
+	vm_prot = cr_calc_map_prot_bits(hh->vm_flags);
+	vm_flags = cr_calc_map_flags_bits(hh->vm_flags);
+	vm_pgoff = hh->vm_pgoff;
+
+	if (hh->namelen) {
+		fname = ctx->tbuf;
+		ret = cr_read_str(ctx, fname, PAGE_SIZE);
+		if (ret < 0)
+			return ret;
+	}
+
+	CR_PRINTK("vma fname '%s' how %d\n", fname, hh->how);
+
+	switch (hh->how) {
+
+	case CR_VMA_ANON:		/* anonymous private mapping */
+		if (hh->namelen)
+			return -EINVAL;
+		/* vm_pgoff for anonymous mapping is the "global" page
+		   offset (namely from addr 0x0), so we force a zero */
+		vm_pgoff = 0;
+		break;
+
+	case CR_VMA_FILE:		/* private mapping from a file */
+		if (!hh->namelen)
+			return -EINVAL;
+		/* O_RDWR only needed if both (VM_WRITE|VM_SHARED) are set */
+		flags = hh->vm_flags & (VM_WRITE | VM_SHARED);
+		flags = (flags == (VM_WRITE | VM_SHARED) ? O_RDWR : O_RDONLY);
+		file = filp_open(fname, flags, 0);
+		if (IS_ERR(file))
+			return PTR_ERR(file);
+		break;
+
+	default:
+		return -EINVAL;
+
+	}
+
+	addr = do_mmap_pgoff(file, (unsigned long) hh->vm_start,
+			     vm_size, vm_prot, vm_flags, vm_pgoff);
+	CR_PRINTK("vma size %#lx prot %#lx flags %#lx pgoff %#lx => %#lx\n",
+		  vm_size, vm_prot, vm_flags, vm_pgoff, addr);
+
+	/* the file (if opened) is now referenced by the vma */
+	if (file)
+		filp_close(file, NULL);
+
+	if (IS_ERR((void*) addr))
+		return (PTR_ERR((void *) addr));
+
+	/*
+	 * CR_VMA_ANON: read in memory as is
+	 * CR_VMA_FILE: read in memory as is
+	 * (more to follow ...)
+	 */
+
+	switch (hh->how) {
+	case CR_VMA_ANON:
+	case CR_VMA_FILE:
+		/* standard case: read the data into the memory */
+		ret = cr_vma_read_pages(ctx, hh);
+		break;
+	}
+
+	if (ret < 0)
+		return ret;
+
+	if (vm_prot & PROT_EXEC)
+		flush_icache_range(hh->vm_start, hh->vm_end);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	CR_PRINTK("vma retval %d\n", ret);
+	return 0;
+}
+
+#if defined(CONFIG_X86)
+
+extern asmlinkage int sys_modify_ldt(int func, void __user *ptr, unsigned long bytecount);
+
+static int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm)
+{
+	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int n, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
+	if (ret < 0)
+		return ret;
+
+	CR_PRINTK("nldt %d\n", hh->nldt);
+
+	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE)
+		return -EINVAL;
+
+	/* to utilize the syscall modify_ldt() we first convert the data
+	 * in the checkpoint image from 'struct desc_struct' to 'struct
+	 * user_desc' with reverse logic of inclue/asm/desc.h:fill_ldt() */
+
+	for (n = 0; n < hh->nldt; n++) {
+		struct user_desc info;
+		struct desc_struct desc;
+		mm_segment_t old_fs;
+
+		ret = cr_kread(ctx, &desc, LDT_ENTRY_SIZE);
+		if (ret < 0)
+			return ret;
+
+		info.entry_number = n;
+		info.base_addr = desc.base0 | (desc.base1 << 16);
+		info.limit = desc.limit0;
+		info.seg_32bit = desc.d;
+		info.contents = desc.type >> 2;
+		info.read_exec_only = (desc.type >> 1) ^ 1;
+		info.limit_in_pages = desc.g;
+		info.seg_not_present = desc.p ^ 1;
+		info.useable = desc.avl;
+
+		old_fs = get_fs();
+		set_fs(get_ds());
+		ret = sys_modify_ldt(1, &info, sizeof(info));
+		set_fs(old_fs);
+
+		if (ret < 0)
+			return ret;
+	}
+
+	load_LDT(&mm->context);
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return 0;
+}
+#endif
+
+static int cr_destroy_mm(struct mm_struct *mm)
+{
+	struct vm_area_struct *vmnext = mm->mmap;
+	struct vm_area_struct *vma;
+	int ret;
+
+	while (vmnext) {
+		vma = vmnext;
+		vmnext = vmnext->vm_next;
+		ret = do_munmap(mm, vma->vm_start, vma->vm_end-vma->vm_start);
+		if (ret < 0)
+			return ret;
+	}
+	return 0;
+}
+
+int cr_read_mm(struct cr_ctx *ctx)
+{
+	struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct mm_struct *mm;
+	int nr, ret;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM);
+	if (ret < 0)
+		return ret;
+
+	CR_PRINTK("map_count %d\n", hh->map_count);
+
+	/* XXX need more sanity checks */
+	if (hh->start_code > hh->end_code ||
+	    hh->start_data > hh->end_data || hh->map_count < 0)
+		return -EINVAL;
+
+	mm = current->mm;
+
+	/* point of no return -- destruct current mm */
+	down_write(&mm->mmap_sem);
+	ret = cr_destroy_mm(mm);
+	up_write(&mm->mmap_sem);
+
+	if (ret < 0)
+		return ret;
+
+	mm->start_code = hh->start_code;
+	mm->end_code = hh->end_code;
+	mm->start_data = hh->start_data;
+	mm->end_data = hh->end_data;
+	mm->start_brk = hh->start_brk;
+	mm->brk = hh->brk;
+	mm->start_stack = hh->start_stack;
+	mm->arg_start = hh->arg_start;
+	mm->arg_end = hh->arg_end;
+	mm->env_start = hh->env_start;
+	mm->env_end = hh->env_end;
+
+	/* FIX: need also mm->flags */
+
+	for (nr = hh->map_count; nr; nr--) {
+		ret = cr_read_vma(ctx, mm);
+		if (ret < 0)
+			return ret;
+	}
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	return cr_read_mm_context(ctx, mm);
+}
diff -puN ckpt/sys.c~memory_part ckpt/sys.c
--- linux-2.6.git/ckpt/sys.c~memory_part	2008-07-30 11:51:00.000000000 -0700
+++ linux-2.6.git-dave/ckpt/sys.c	2008-07-30 11:51:00.000000000 -0700
@@ -15,7 +15,7 @@
 #include <linux/capability.h>
 
 #include "ckpt.h"
-//include "ckpt_mem.h"
+#include "ckpt_mem.h"
 
 /*
  * helpers to write/read to/from the image file descriptor
@@ -119,7 +119,7 @@ void cr_ctx_free(struct cr_ctx *ctx)
 	if (ctx->vfsroot)
 		path_put(ctx->vfsroot);
 
-	//cr_pgarr_free(ctx);
+	cr_pgarr_free(ctx);
 
 	free_pages((unsigned long) ctx->tbuf, CR_ORDER_TBUF);
 	free_pages((unsigned long) ctx->hbuf, CR_ORDER_HBUF);
@@ -140,8 +140,8 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, s
 	if (!ctx->tbuf || !ctx->hbuf)
 		goto nomem;
 
-	//if (!cr_pgarr_alloc(ctx, &ctx->pgarr))
-	//	goto nomem;
+	if (!cr_pgarr_alloc(ctx, &ctx->pgarr))
+		goto nomem;
 
 	ctx->pid = pid;
 	ctx->flags = flags;
diff -puN ckpt/ckpt_hdr.h~memory_part ckpt/ckpt_hdr.h
--- linux-2.6.git/ckpt/ckpt_hdr.h~memory_part	2008-07-30 11:51:03.000000000 -0700
+++ linux-2.6.git-dave/ckpt/ckpt_hdr.h	2008-07-30 11:51:08.000000000 -0700
@@ -113,3 +113,31 @@ struct cr_hdr_cpu {
 	union thread_xstate xstate;	/* i387 */
 };
 #endif
+
+struct cr_hdr_mm {
+	__u32 tag;	/* sharing identifier */
+	__u64 start_code, end_code, start_data, end_data;
+	__u64 start_brk, brk, start_stack;
+	__u64 arg_start, arg_end, env_start, env_end;
+	__s16 map_count;
+};
+
+#if defined(CONFIG_X86)
+struct cr_hdr_mm_context {
+	__s16 ldt_entry_size;
+	__s16 nldt;
+};
+#endif
+
+struct cr_hdr_vma {
+	__u32 how;
+
+	__u64 vm_start;
+	__u64 vm_end;
+	__u64 vm_page_prot;
+	__u64 vm_flags;
+	__u64 vm_pgoff;
+
+	__s16 npages;
+	__s16 namelen;
+};
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
