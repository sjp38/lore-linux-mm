Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEAA6B005C
	for <linux-mm@kvack.org>; Mon, 29 Dec 2008 04:17:53 -0500 (EST)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v12][PATCH 06/14] Dump memory address space
Date: Mon, 29 Dec 2008 04:16:19 -0500
Message-Id: <1230542187-10434-7-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu>
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Waychison <mikew@google.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
it will be followed by the file name. Then comes the actual contents,
in one or more chunk: each chunk begins with a header that specifies
how many pages it holds, then the virtual addresses of all the dumped
pages in that chunk, followed by the actual contents of all dumped
pages. A header with zero number of pages marks the end of the contents.
Then comes the next VMA and so on.

Changelog[v12]:
  - Hide pgarr management inside cr_private_vma_fill_pgarr()
  - Fix management of pgarr chain reset and alloc/expand: keep empty
    pgarr in a pool chain
  - Replace obsolete cr_debug() with pr_debug()

Changelog[v11]:
  - Copy contents of 'init->fs->root' instead of pointing to them.
  - Add missing test for VM_MAYSHARE when dumping memory

Changelog[v10]:
  - Acquire dcache_lock around call to __d_path() in cr_fill_name()

Changelog[v9]:
  - Introduce cr_ctx_checkpoint() for checkpoint-specific ctx setup
  - Test if __d_path() changes mnt/dentry (when crossing filesystem
    namespace boundary). for now cr_fill_fname() fails the checkpoint.

Changelog[v7]:
  - Fix argument given to kunmap_atomic() in memory dump/restore

Changelog[v6]:
  - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
    (even though it's not really needed)

Changelog[v5]:
  - Improve memory dump code (following Dave Hansen's comments)
  - Change dump format (and code) to allow chunks of <vaddrs, pages>
    instead of one long list of each
  - Fix use of follow_page() to avoid faulting in non-present pages

Changelog[v4]:
  - Use standard list_... for cr_pgarr

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 arch/x86/include/asm/checkpoint_hdr.h |    5 +
 arch/x86/mm/checkpoint.c              |   31 ++
 checkpoint/Makefile                   |    3 +-
 checkpoint/checkpoint.c               |   88 ++++++
 checkpoint/checkpoint_arch.h          |    2 +
 checkpoint/checkpoint_mem.h           |   41 +++
 checkpoint/ckpt_mem.c                 |  541 +++++++++++++++++++++++++++++++++
 checkpoint/sys.c                      |   11 +
 include/linux/checkpoint.h            |   13 +
 include/linux/checkpoint_hdr.h        |   32 ++
 10 files changed, 766 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/checkpoint_mem.h
 create mode 100644 checkpoint/ckpt_mem.c

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index f966e70..eb95705 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -97,4 +97,9 @@ struct cr_hdr_cpu {
 	/* thread_xstate contents follow (if used_math) */
 } __attribute__((aligned(8)));
 
+struct cr_hdr_mm_context {
+	__s16 ldt_entry_size;
+	__s16 nldt;
+} __attribute__((aligned(8)));
+
 #endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 243a15c..50bde9a 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -234,3 +234,34 @@ int cr_write_head_arch(struct cr_ctx *ctx)
 
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
+	pr_debug("nldt %d\n", hh->nldt);
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
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index d2df68c..3a0df6d 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -2,4 +2,5 @@
 # Makefile for linux checkpoint/restart.
 #
 
-obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o
+obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
+		ckpt_mem.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 9c5430d..5c47184 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -13,6 +13,7 @@
 #include <linux/time.h>
 #include <linux/fs.h>
 #include <linux/file.h>
+#include <linux/fdtable.h>
 #include <linux/dcache.h>
 #include <linux/mount.h>
 #include <linux/utsname.h>
@@ -75,6 +76,66 @@ int cr_write_string(struct cr_ctx *ctx, char *str, int len)
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
+	struct path tmp = *root;
+	char *fname;
+
+	BUG_ON(!buf);
+	spin_lock(&dcache_lock);
+	fname = __d_path(path, &tmp, buf, *n);
+	spin_unlock(&dcache_lock);
+	if (!IS_ERR(fname))
+		*n = (buf + (*n) - fname);
+	/*
+	 * FIXME: if __d_path() changed these, it must have stepped out of
+	 * init's namespace. Since currently we require a unified namespace
+	 * within the container: simply fail.
+	 */
+	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
+		fname = ERR_PTR(-EBADF);
+
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
@@ -168,6 +229,10 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 	pr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_write_mm(ctx, t);
+	pr_debug("memory: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_write_thread(ctx, t);
 	pr_debug("thread: ret %d\n", ret);
 	if (ret < 0)
@@ -178,10 +243,33 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 	return ret;
 }
 
+static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
+{
+	struct fs_struct *fs;
+
+	ctx->root_pid = pid;
+
+	/*
+	 * assume checkpointer is in container's root vfs
+	 * FIXME: this works for now, but will change with real containers
+	 */
+
+	fs = current->fs;
+	read_lock(&fs->lock);
+	ctx->fs_mnt = fs->root;
+	path_get(&ctx->fs_mnt);
+	read_unlock(&fs->lock);
+
+	return 0;
+}
+
 int do_checkpoint(struct cr_ctx *ctx, pid_t pid)
 {
 	int ret;
 
+	ret = cr_ctx_checkpoint(ctx, pid);
+	if (ret < 0)
+		goto out;
 	ret = cr_write_head(ctx);
 	if (ret < 0)
 		goto out;
diff --git a/checkpoint/checkpoint_arch.h b/checkpoint/checkpoint_arch.h
index ada1369..f06c7eb 100644
--- a/checkpoint/checkpoint_arch.h
+++ b/checkpoint/checkpoint_arch.h
@@ -3,6 +3,8 @@
 extern int cr_write_head_arch(struct cr_ctx *ctx);
 extern int cr_write_thread(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_write_cpu(struct cr_ctx *ctx, struct task_struct *t);
+extern int cr_write_mm_context(struct cr_ctx *ctx,
+			       struct mm_struct *mm, int parent);
 
 extern int cr_read_head_arch(struct cr_ctx *ctx);
 extern int cr_read_thread(struct cr_ctx *ctx);
diff --git a/checkpoint/checkpoint_mem.h b/checkpoint/checkpoint_mem.h
new file mode 100644
index 0000000..3e48bc4
--- /dev/null
+++ b/checkpoint/checkpoint_mem.h
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
+ * page-array chains: each cr_pgarr describes a set of <struct page *,vaddr>
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
diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
new file mode 100644
index 0000000..ccb14c7
--- /dev/null
+++ b/checkpoint/ckpt_mem.c
@@ -0,0 +1,541 @@
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
+ *   ctx->pgarr_list: list head of populated page-array chain
+ *   ctx->pgarr_pool: list head of empty page-array pool chain
+ *
+ * During checkpoint (and restart) the chain tracks the dirty pages (page
+ * pointer and virtual address) of each MM. For a particular MM, these are
+ * always added to the head of the page-array chain (ctx->pgarr_list).
+ * Before the next chunk of pages, the chain is reset (by dereferencing
+ * all pages) but not freed; instead, empty descsriptors are kept in pool.
+ *
+ * The head of the chain page-array ("current") advances as necessary. When
+ * it gets full, a new page-array descriptor is pushed in front of it. The
+ * new descriptor is taken from first empty descriptor (if one exists, for
+ * instance, after a chain reset), or allocated on-demand.
+ *
+ * When dumping the data, the chain is traversed in reverse order.
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
+/* return (and detach) first empty page-array in the pool, if exists */
+static inline struct cr_pgarr *cr_pgarr_from_pool(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr;
+
+	if (list_empty(&ctx->pgarr_pool))
+		return NULL;
+	pgarr = list_first_entry(&ctx->pgarr_pool, struct cr_pgarr, list);
+	list_del(&pgarr->list);
+	return pgarr;
+}
+
+/* release pages referenced by a page-array */
+static void cr_pgarr_release_pages(struct cr_pgarr *pgarr)
+{
+	pr_debug("nr_used %d\n", pgarr->nr_used);
+	/*
+	 * both checkpoint and restart use 'nr_used', however we only
+	 * collect pages during checkpoint; in restart we simply return
+	 * because pgarr->pages remains NULL.
+	 */
+	if (pgarr->pages) {
+		struct page **pages = pgarr->pages;
+		int nr = pgarr->nr_used;
+
+		while (nr--)
+			page_cache_release(pages[nr]);
+	}
+
+	pgarr->nr_used = 0;
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
+/* free the chains of page-arrays (populated and empty pool) */
+void cr_pgarr_free(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr, *tmp;
+
+	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_list, list) {
+		list_del(&pgarr->list);
+		cr_pgarr_free_one(pgarr);
+	}
+
+	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_pool, list) {
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
+ * Returns the first page-array in the list that has space. Otherwise,
+ * try the next page-array after the last non-empty one, and move it to
+ * the front of the chain. Extends the list if none has space.
+ */
+struct cr_pgarr *cr_pgarr_current(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr;
+
+	pgarr = cr_pgarr_first(ctx);
+	if (pgarr && !cr_pgarr_is_full(pgarr))
+		return pgarr;
+
+	pgarr = cr_pgarr_from_pool(ctx);
+	if (!pgarr)
+		pgarr = cr_pgarr_alloc_one(ctx->flags);
+	if (!pgarr)
+		return NULL;
+
+	list_add(&pgarr->list, &ctx->pgarr_list);
+	return pgarr;
+}
+
+/* reset the page-array chain (dropping page references if necessary) */
+void cr_pgarr_reset_all(struct cr_ctx *ctx)
+{
+	struct cr_pgarr *pgarr;
+
+	list_for_each_entry(pgarr, &ctx->pgarr_list, list)
+		cr_pgarr_release_pages(pgarr);
+	list_splice_init(&ctx->pgarr_list, &ctx->pgarr_pool);
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
+cr_consider_private_page(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct page *page;
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
+	 * Only care about dirty pages: either anonymous non-zero pages,
+	 * or file-backed COW (copy-on-write) pages that were modified.
+	 * A clean COW page is not interesting because its contents are
+	 * identical to the backing file; ignore such pages.
+	 * A file-backed broken COW is identified by its page_mapping()
+	 * being unset (NULL) because the page will no longer be mapped
+	 * to the original file after having been modified.
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
+ * @vma - vma to scan
+ * @start - start address (updated)
+ *
+ * Returns the number of pages collected
+ */
+static int
+cr_private_vma_fill_pgarr(struct cr_ctx *ctx, struct vm_area_struct *vma,
+			  unsigned long *start)
+{
+	unsigned long end = vma->vm_end;
+	unsigned long addr = *start;
+	struct cr_pgarr *pgarr;
+	int nr_used;
+	int cnt = 0;
+
+	/* this function is only for private memory (anon or file-mapped) */
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	do {
+		pgarr = cr_pgarr_current(ctx);
+		if (!pgarr)
+			return -ENOMEM;
+
+		nr_used = pgarr->nr_used;
+
+		while (addr < end) {
+			struct page *page;
+
+			page = cr_consider_private_page(vma, addr);
+			if (IS_ERR(page))
+				return PTR_ERR(page);
+
+			if (page) {
+				pgarr->pages[pgarr->nr_used] = page;
+				pgarr->vaddrs[pgarr->nr_used] = addr;
+				pgarr->nr_used++;
+			}
+
+			addr += PAGE_SIZE;
+
+			if (cr_pgarr_is_full(pgarr))
+				break;
+		}
+
+		cnt += pgarr->nr_used - nr_used;
+
+	} while ((cnt < CR_PGARR_CHUNK) && (addr < end));
+
+	*start = addr;
+	return cnt;
+}
+
+/* dump contents of a pages: use kmap_atomic() to avoid TLB flush */
+static int cr_page_write(struct cr_ctx *ctx, struct page *page, char *buf)
+{
+	void *ptr;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(buf, ptr, PAGE_SIZE);
+	kunmap_atomic(ptr, KM_USER1);
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
+	void *buf;
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
+	buf = (void *) __get_free_page(GFP_KERNEL);
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
+	free_page((unsigned long) buf);
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
+	int cnt, ret;
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
+		cnt = cr_private_vma_fill_pgarr(ctx, vma, &addr);
+		if (cnt == 0)
+			break;
+		else if (cnt < 0)
+			return cnt;
+
+		hh = cr_hbuf_get(ctx, sizeof(*hh));
+		hh->nr_pages = cnt;
+		ret = cr_write_obj(ctx, &h, hh);
+		cr_hbuf_put(ctx, sizeof(*hh));
+		if (ret < 0)
+			return ret;
+
+		ret = cr_vma_dump_pages(ctx, cnt);
+		if (ret < 0)
+			return ret;
+
+		cr_pgarr_reset_all(ctx);
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
+#define CR_BAD_VM_FLAGS  \
+	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB | VM_NONLINEAR)
+
+	if (vma->vm_flags & CR_BAD_VM_FLAGS) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
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
+	/* save the file name */
+	/* FIXME: files should be deposited and sought in the objhash */
+	if (vma->vm_file) {
+		ret = cr_write_fname(ctx, &vma->vm_file->f_path, &ctx->fs_mnt);
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
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 76e2553..b5242fe 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -16,6 +16,8 @@
 #include <linux/capability.h>
 #include <linux/checkpoint.h>
 
+#include "checkpoint_mem.h"
+
 /*
  * Helpers to write(read) from(to) kernel space to(from) the checkpoint
  * image file descriptor (similar to how a core-dump is performed).
@@ -153,7 +155,13 @@ static void cr_ctx_free(struct cr_ctx *ctx)
 {
 	if (ctx->file)
 		fput(ctx->file);
+
 	kfree(ctx->hbuf);
+
+	path_put(&ctx->fs_mnt);		/* safe with NULL pointers */
+
+	cr_pgarr_free(ctx);
+
 	kfree(ctx);
 }
 
@@ -168,6 +176,9 @@ static struct cr_ctx *cr_ctx_alloc(int fd, unsigned long flags)
 
 	ctx->flags = flags;
 
+	INIT_LIST_HEAD(&ctx->pgarr_list);
+	INIT_LIST_HEAD(&ctx->pgarr_pool);
+
 	err = -EBADF;
 	ctx->file = fget(fd);
 	if (!ctx->file)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 65a2cbf..f8187ba 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,6 +10,9 @@
  *  distribution for more details.
  */
 
+#include <linux/path.h>
+#include <linux/fs.h>
+
 #define CR_VERSION  1
 
 struct cr_ctx {
@@ -25,6 +28,11 @@ struct cr_ctx {
 
 	void *hbuf;		/* temporary buffer for headers */
 	int hpos;		/* position in headers buffer */
+
+	struct list_head pgarr_list;	/* page array to dump VMA contents */
+	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
+
+	struct path fs_mnt;	/* container root (FIXME) */
 };
 
 /* cr_ctx: flags */
@@ -42,6 +50,8 @@ struct cr_hdr;
 extern int cr_write_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf);
 extern int cr_write_buffer(struct cr_ctx *ctx, void *buf, int len);
 extern int cr_write_string(struct cr_ctx *ctx, char *str, int len);
+extern int cr_write_fname(struct cr_ctx *ctx,
+			  struct path *path, struct path *root);
 
 extern int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
 extern int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int len, int type);
@@ -50,7 +60,10 @@ extern int cr_read_buffer(struct cr_ctx *ctx, void *buf, int *len);
 extern int cr_read_string(struct cr_ctx *ctx, char *str, int len);
 
 extern int do_checkpoint(struct cr_ctx *ctx, pid_t pid);
+extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
+
 extern int do_restart(struct cr_ctx *ctx, pid_t pid);
+extern int cr_read_mm(struct cr_ctx *ctx);
 
 #ifdef pr_fmt
 #undef pr_fmt
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 3efd009..f3997da 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -43,6 +43,7 @@ enum {
 	CR_HDR_HEAD_ARCH,
 	CR_HDR_BUFFER,
 	CR_HDR_STRING,
+	CR_HDR_FNAME,
 
 	CR_HDR_TASK = 101,
 	CR_HDR_THREAD,
@@ -50,6 +51,7 @@ enum {
 
 	CR_HDR_MM = 201,
 	CR_HDR_VMA,
+	CR_HDR_PGARR,
 	CR_HDR_MM_CONTEXT,
 
 	CR_HDR_TAIL = 5001
@@ -84,4 +86,34 @@ struct cr_hdr_task {
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
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
