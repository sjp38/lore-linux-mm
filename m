Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B1F2560023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:15:02 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 42/96] c/r: dump memory address space (private memory)
Date: Wed, 17 Mar 2010 12:08:30 -0400
Message-Id: <1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-42-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

For each vma, there is a 'struct ckpt_vma'; Then comes the actual
contents, in one or more chunk: each chunk begins with a header that
specifies how many pages it holds, then the virtual addresses of all
the dumped pages in that chunk, followed by the actual contents of all
dumped pages. A header with zero number of pages marks the end of the
contents.  Then comes the next vma and so on.

To checkpoint a vma, call the ops->checkpoint() method of that vma.
Normally the per-vma function will invoke generic_vma_checkpoint()
which first writes the vma description, followed by the specific
logic to dump the contents of the pages.

Currently for private mapped memory we save the pathname of the file
that is mapped (restart will use it to re-open it and then map it).
Later we change that to reference a file object.

Changelog[v19-rc]:
  - [Serge Hallyn] Checkpoint saved_auxv as u64s
Changelog[v19-rc3]:
  - Separate __get_dirty_page() into its own patch
  - Export filemap_checkpoint()
  - [Serge Hallyn] Disallow checkpoint of tasks with aio requests
  - Fix compilation failure when !CONFIG_CHEKCPOINT (regression)
Changelog[v19-rc2]:
  - Expose page write functions
  - Take mmap_sem() around vma_fill_pgarr() (fix regression)
  - Move consider_private_page() to mm/memory.c:__get_dirty_page()
Changelog[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
  - Do not hold mmap_sem while checkpointing vma's
Changelog[v18]:
  - Tighten checks on supported vma to checkpoint or restart
  - Add a few more ckpt_write_err()s
  - [Serge Hallyn] Export filemap_checkpoint() (used later for ext4)
  - Use ckpt_collect_file() instead of ckpt_obj_collect() for files
  - In collect_mm() use retval from ckpt_obj_collect() to test for
    first-time-object
Changelog[v17]:
  - Only collect sub-objects of mm_struct once
  - Save mm->{flags,def_flags,saved_auxv}
Changelog[v16]:
  - Precede vaddrs/pages with a buffer header
  - Checkpoint mm->exe_file
  - Handle shared task->mm
Changelog[v14]:
  - Modify the ops->checkpoint method to be much more powerful
  - Improve support for VDSO (with special_mapping checkpoint callback)
  - Save new field 'vdso' in mm_context
  - Revert change to pr_debug(), back to ckpt_debug()
  - Check whether calls to ckpt_hbuf_get() fail
  - Discard field 'h->parent'
Changelog[v13]:
  - pgprot_t is an abstract type; use the proper accessor (fix for
    64-bit powerpc (Nathan Lynch <ntl@pobox.com>)
Changelog[v12]:
  - Hide pgarr management inside ckpt_private_vma_fill_pgarr()
  - Fix management of pgarr chain reset and alloc/expand: keep empty
    pgarr in a pool chain
  - Replace obsolete ckpt_debug() with pr_debug()
Changelog[v11]:
  - Copy contents of 'init->fs->root' instead of pointing to them.
  - Add missing test for VM_MAYSHARE when dumping memory
Changelog[v10]:
  - Acquire dcache_lock around call to __d_path() in ckpt_fill_name()
Changelog[v9]:
  - Introduce ckpt_ctx_checkpoint() for checkpoint-specific ctx setup
  - Test if __d_path() changes mnt/dentry (when crossing filesystem
    namespace boundary). for now ckpt_fill_fname() fails the checkpoint.
Changelog[v7]:
  - Fix argument given to kunmap_atomic() in memory dump/restore
Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (even though it's not really needed)
Changelog[v5]:
  - Improve memory dump code (following Dave Hansen's comments)
  - Change dump format (and code) to allow chunks of <vaddrs, pages>
    instead of one long list of each
  - Fix use of follow_page() to avoid faulting in non-present pages
Changelog[v4]:
  - Use standard list_... for ckpt_pgarr

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 arch/x86/include/asm/checkpoint_hdr.h |    9 +
 arch/x86/kernel/checkpoint.c          |   31 ++
 checkpoint/Makefile                   |    3 +-
 checkpoint/checkpoint.c               |    2 +
 checkpoint/memory.c                   |  723 +++++++++++++++++++++++++++++++++
 checkpoint/objhash.c                  |   25 ++
 checkpoint/process.c                  |   12 +
 checkpoint/sys.c                      |    9 +
 fs/aio.c                              |   17 +
 include/linux/aio.h                   |    2 +
 include/linux/checkpoint.h            |   28 ++
 include/linux/checkpoint_hdr.h        |   62 +++
 include/linux/checkpoint_types.h      |    7 +
 include/linux/mm.h                    |    5 +
 mm/filemap.c                          |   28 ++
 mm/mmap.c                             |   30 ++
 16 files changed, 992 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/memory.c

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 6f600dd..292bf50 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -48,6 +48,8 @@
 enum {
 	CKPT_HDR_CPU_FPU = 201,
 #define CKPT_HDR_CPU_FPU CKPT_HDR_CPU_FPU
+	CKPT_HDR_MM_CONTEXT_LDT,
+#define CKPT_HDR_MM_CONTEXT_LDT CKPT_HDR_MM_CONTEXT_LDT
 };
 
 struct ckpt_hdr_header_arch {
@@ -115,4 +117,11 @@ struct ckpt_hdr_cpu {
 #define CKPT_X86_SEG_TLS	0x4000	/* 0100 0000 0000 00xx */
 #define CKPT_X86_SEG_LDT	0x8000	/* 100x xxxx xxxx xxxx */
 
+struct ckpt_hdr_mm_context {
+	struct ckpt_hdr h;
+	__u64 vdso;
+	__u32 ldt_entry_size;
+	__u32 nldt;
+} __attribute__((aligned(8)));
+
 #endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
index 53b7e66..dec824c 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -208,6 +208,37 @@ int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* dump the mm->context state */
+int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (!h)
+		return -ENOMEM;
+
+	mutex_lock(&mm->context.lock);
+
+	h->vdso = (unsigned long) mm->context.vdso;
+	h->ldt_entry_size = LDT_ENTRY_SIZE;
+	h->nldt = mm->context.size;
+
+	ckpt_debug("nldt %d vdso %#llx\n", h->nldt, h->vdso);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj_type(ctx, mm->context.ldt,
+				  mm->context.size * LDT_ENTRY_SIZE,
+				  CKPT_HDR_MM_CONTEXT_LDT);
+ out:
+	mutex_unlock(&mm->context.lock);
+	return ret;
+}
+
 /**************************************************************************
  * Restart
  */
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 1d0c058..f56a7d6 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -8,4 +8,5 @@ obj-$(CONFIG_CHECKPOINT) += \
 	checkpoint.o \
 	restart.o \
 	process.o \
-	files.o
+	files.o \
+	memory.o
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 2bc2495..fd88d5f 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -110,6 +110,8 @@ static void fill_kernel_const(struct ckpt_const *h)
 
 	/* task */
 	h->task_comm_len = sizeof(tsk->comm);
+	/* mm->saved_auxv size */
+	h->at_vector_size = AT_VECTOR_SIZE;
 	/* uts */
 	h->uts_release_len = sizeof(uts->release);
 	h->uts_version_len = sizeof(uts->version);
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
new file mode 100644
index 0000000..e82d240
--- /dev/null
+++ b/checkpoint/memory.c
@@ -0,0 +1,723 @@
+/*
+ *  Checkpoint/restart memory contents
+ *
+ *  Copyright (C) 2008-2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DMEM
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/file.h>
+#include <linux/aio.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+#include <linux/proc_fs.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/*
+ * page-array chains: each ckpt_pgarr describes a set of <struct page *,vaddr>
+ * tuples (where vaddr is the virtual address of a page in a particular mm).
+ * Specifically, we use separate arrays so that all vaddrs can be written
+ * and read at once.
+ */
+
+struct ckpt_pgarr {
+	unsigned long *vaddrs;
+	struct page **pages;
+	unsigned int nr_used;
+	struct list_head list;
+};
+
+#define CKPT_PGARR_TOTAL  (PAGE_SIZE / sizeof(void *))
+#define CKPT_PGARR_BATCH  (16 * CKPT_PGARR_TOTAL)
+
+static inline int pgarr_is_full(struct ckpt_pgarr *pgarr)
+{
+	return (pgarr->nr_used == CKPT_PGARR_TOTAL);
+}
+
+static inline int pgarr_nr_free(struct ckpt_pgarr *pgarr)
+{
+	return CKPT_PGARR_TOTAL - pgarr->nr_used;
+}
+
+/*
+ * utilities to alloc, free, and handle 'struct ckpt_pgarr' (page-arrays)
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
+static inline struct ckpt_pgarr *pgarr_first(struct ckpt_ctx *ctx)
+{
+	if (list_empty(&ctx->pgarr_list))
+		return NULL;
+	return list_first_entry(&ctx->pgarr_list, struct ckpt_pgarr, list);
+}
+
+/* return (and detach) first empty page-array in the pool, if exists */
+static inline struct ckpt_pgarr *pgarr_from_pool(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pgarr *pgarr;
+
+	if (list_empty(&ctx->pgarr_pool))
+		return NULL;
+	pgarr = list_first_entry(&ctx->pgarr_pool, struct ckpt_pgarr, list);
+	list_del(&pgarr->list);
+	return pgarr;
+}
+
+/* release pages referenced by a page-array */
+static void pgarr_release_pages(struct ckpt_pgarr *pgarr)
+{
+	ckpt_debug("total pages %d\n", pgarr->nr_used);
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
+static void pgarr_free_one(struct ckpt_pgarr *pgarr)
+{
+	pgarr_release_pages(pgarr);
+	kfree(pgarr->pages);
+	kfree(pgarr->vaddrs);
+	kfree(pgarr);
+}
+
+/* free the chains of page-arrays (populated and empty pool) */
+void ckpt_pgarr_free(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pgarr *pgarr, *tmp;
+
+	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_list, list) {
+		list_del(&pgarr->list);
+		pgarr_free_one(pgarr);
+	}
+
+	list_for_each_entry_safe(pgarr, tmp, &ctx->pgarr_pool, list) {
+		list_del(&pgarr->list);
+		pgarr_free_one(pgarr);
+	}
+}
+
+/* allocate a single page-array object */
+static struct ckpt_pgarr *pgarr_alloc_one(unsigned long flags)
+{
+	struct ckpt_pgarr *pgarr;
+
+	pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL);
+	if (!pgarr)
+		return NULL;
+	pgarr->vaddrs = kmalloc(CKPT_PGARR_TOTAL * sizeof(unsigned long),
+				GFP_KERNEL);
+	if (!pgarr->vaddrs)
+		goto nomem;
+
+	/* pgarr->pages is needed only for checkpoint */
+	if (flags & CKPT_CTX_CHECKPOINT) {
+		pgarr->pages = kmalloc(CKPT_PGARR_TOTAL *
+				       sizeof(struct page *), GFP_KERNEL);
+		if (!pgarr->pages)
+			goto nomem;
+	}
+
+	return pgarr;
+ nomem:
+	pgarr_free_one(pgarr);
+	return NULL;
+}
+
+/* pgarr_current - return the next available page-array in the chain
+ * @ctx: checkpoint context
+ *
+ * Returns the first page-array in the list that has space. Otherwise,
+ * try the next page-array after the last non-empty one, and move it to
+ * the front of the chain. Extends the list if none has space.
+ */
+static struct ckpt_pgarr *pgarr_current(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pgarr *pgarr;
+
+	pgarr = pgarr_first(ctx);
+	if (pgarr && !pgarr_is_full(pgarr))
+		return pgarr;
+
+	pgarr = pgarr_from_pool(ctx);
+	if (!pgarr)
+		pgarr = pgarr_alloc_one(ctx->kflags);
+	if (!pgarr)
+		return NULL;
+
+	list_add(&pgarr->list, &ctx->pgarr_list);
+	return pgarr;
+}
+
+/* reset the page-array chain (dropping page references if necessary) */
+static void pgarr_reset_all(struct ckpt_ctx *ctx)
+{
+	struct ckpt_pgarr *pgarr;
+
+	list_for_each_entry(pgarr, &ctx->pgarr_list, list)
+		pgarr_release_pages(pgarr);
+	list_splice_init(&ctx->pgarr_list, &ctx->pgarr_pool);
+}
+
+/**************************************************************************
+ * Checkpoint
+ *
+ * Checkpoint is outside the context of the checkpointee, so one cannot
+ * simply read pages from user-space. Instead, we scan the address space
+ * of the target to cherry-pick pages of interest. Selected pages are
+ * enlisted in a page-array chain (attached to the checkpoint context).
+ * To save their contents, each page is mapped to kernel memory and then
+ * dumped to the file descriptor.
+ */
+
+/**
+ * consider_private_page - return page pointer for dirty pages
+ * @vma - target vma
+ * @addr - page address
+ *
+ * Looks up the page that correspond to the address in the vma, and
+ * returns the page if it was modified (and grabs a reference to it),
+ * or otherwise returns NULL (or error).
+ */
+static struct page *consider_private_page(struct vm_area_struct *vma,
+					  unsigned long addr)
+{
+	return __get_dirty_page(vma, addr);
+}
+
+/**
+ * vma_fill_pgarr - fill a page-array with addr/page tuples
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ * @start - start address (updated)
+ *
+ * Returns the number of pages collected
+ */
+static int vma_fill_pgarr(struct ckpt_ctx *ctx,
+			  struct vm_area_struct *vma,
+			  unsigned long *start)
+{
+	unsigned long end = vma->vm_end;
+	unsigned long addr = *start;
+	struct ckpt_pgarr *pgarr;
+	int nr_used;
+	int cnt = 0;
+
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	if (vma)
+		down_read(&vma->vm_mm->mmap_sem);
+	do {
+		pgarr = pgarr_current(ctx);
+		if (!pgarr) {
+			cnt = -ENOMEM;
+			goto out;
+		}
+
+		nr_used = pgarr->nr_used;
+
+		while (addr < end) {
+			struct page *page;
+
+			page = consider_private_page(vma, addr);
+			if (IS_ERR(page)) {
+				cnt = PTR_ERR(page);
+				goto out;
+			}
+
+			if (page) {
+				_ckpt_debug(CKPT_DPAGE,
+					    "got page %#lx\n", addr);
+				pgarr->pages[pgarr->nr_used] = page;
+				pgarr->vaddrs[pgarr->nr_used] = addr;
+				pgarr->nr_used++;
+			}
+
+			addr += PAGE_SIZE;
+
+			if (pgarr_is_full(pgarr))
+				break;
+		}
+
+		cnt += pgarr->nr_used - nr_used;
+
+	} while ((cnt < CKPT_PGARR_BATCH) && (addr < end));
+ out:
+	if (vma)
+		up_read(&vma->vm_mm->mmap_sem);
+	*start = addr;
+	return cnt;
+}
+
+/* dump contents of a pages: use kmap_atomic() to avoid TLB flush */
+int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page)
+{
+	void *ptr;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(ctx->scratch_page, ptr, PAGE_SIZE);
+	kunmap_atomic(ptr, KM_USER1);
+
+	return ckpt_kwrite(ctx, ctx->scratch_page, PAGE_SIZE);
+}
+
+/**
+ * vma_dump_pages - dump pages listed in the ctx page-array chain
+ * @ctx - checkpoint context
+ * @total - total number of pages
+ *
+ * First dump all virtual addresses, followed by the contents of all pages
+ */
+static int vma_dump_pages(struct ckpt_ctx *ctx, int total)
+{
+	struct ckpt_pgarr *pgarr;
+	int i, ret = 0;
+
+	if (!total)
+		return 0;
+
+	i =  total * (sizeof(unsigned long) + PAGE_SIZE);
+	ret = ckpt_write_obj_type(ctx, NULL, i, CKPT_HDR_BUFFER);
+	if (ret < 0)
+		return ret;
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		ret = ckpt_kwrite(ctx, pgarr->vaddrs,
+				  pgarr->nr_used * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+	}
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		for (i = 0; i < pgarr->nr_used; i++) {
+			ret = checkpoint_dump_page(ctx, pgarr->pages[i]);
+			if (ret < 0)
+				return ret;
+		}
+	}
+
+	return ret;
+}
+
+/**
+ * checkpoint_memory_contents - dump contents of a VMA with private memory
+ * @ctx - checkpoint context
+ * @vma - vma to scan
+ *
+ * Collect lists of pages that needs to be dumped, and corresponding
+ * virtual addresses into ctx->pgarr_list page-array chain. Then dump
+ * the addresses, followed by the page contents.
+ */
+static int checkpoint_memory_contents(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma)
+{
+	struct ckpt_hdr_pgarr *h;
+	unsigned long addr, end;
+	int cnt, ret;
+
+	addr = vma->vm_start;
+	end = vma->vm_end;
+
+	/*
+	 * Work iteratively, collecting and dumping at most CKPT_PGARR_BATCH
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
+	 * After dumping the entire contents, conclude with a header that
+	 * specifies 0 pages to mark the end of the contents.
+	 */
+
+	while (addr < end) {
+		cnt = vma_fill_pgarr(ctx, vma, inode, &addr, end);
+		if (cnt == 0)
+			break;
+		else if (cnt < 0)
+			return cnt;
+
+		ckpt_debug("collected %d pages\n", cnt);
+
+		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
+		if (!h)
+			return -ENOMEM;
+
+		h->nr_pages = cnt;
+		ret = ckpt_write_obj(ctx, &h->h);
+		ckpt_hdr_put(ctx, h);
+		if (ret < 0)
+			return ret;
+
+		ret = vma_dump_pages(ctx, cnt);
+		if (ret < 0)
+			return ret;
+
+		pgarr_reset_all(ctx);
+	}
+
+	/* mark end of contents with header saying "0" pages */
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
+	if (!h)
+		return -ENOMEM;
+	h->nr_pages = 0;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/**
+ * generic_vma_checkpoint - dump metadata of vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ * @vma_objref: vma objref
+ */
+int generic_vma_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma,
+			   enum vma_type type, int vma_objref)
+{
+	struct ckpt_hdr_vma *h;
+	int ret;
+
+	ckpt_debug("vma %#lx-%#lx flags %#lx type %d\n",
+		 vma->vm_start, vma->vm_end, vma->vm_flags, type);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_VMA);
+	if (!h)
+		return -ENOMEM;
+
+	h->vma_type = type;
+	h->vma_objref = vma_objref;
+	h->vm_start = vma->vm_start;
+	h->vm_end = vma->vm_end;
+	h->vm_page_prot = pgprot_val(vma->vm_page_prot);
+	h->vm_flags = vma->vm_flags;
+	h->vm_pgoff = vma->vm_pgoff;
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
+/**
+ * private_vma_checkpoint - dump contents of private (anon, file) vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ * @type: vma type
+ * @vma_objref: vma objref
+ */
+int private_vma_checkpoint(struct ckpt_ctx *ctx,
+			   struct vm_area_struct *vma,
+			   enum vma_type type, int vma_objref)
+{
+	int ret;
+
+	BUG_ON(vma->vm_flags & (VM_SHARED | VM_MAYSHARE));
+
+	ret = generic_vma_checkpoint(ctx, vma, type, vma_objref);
+	if (ret < 0)
+		goto out;
+	ret = checkpoint_memory_contents(ctx, vma);
+ out:
+	return ret;
+}
+
+/**
+ * anonymous_checkpoint - dump contents of private-anonymous vma
+ * @ctx: checkpoint context
+ * @vma: vma object
+ */
+static int anonymous_checkpoint(struct ckpt_ctx *ctx,
+				struct vm_area_struct *vma)
+{
+	/* should be private anonymous ... verify that this is the case */
+	BUG_ON(vma->vm_flags & VM_MAYSHARE);
+	BUG_ON(vma->vm_file);
+
+	return private_vma_checkpoint(ctx, vma, CKPT_VMA_ANON, 0);
+}
+
+static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct vm_area_struct *vma, *next;
+	int map_count = 0;
+	int ret = 0;
+
+	vma = kzalloc(sizeof(*vma), GFP_KERNEL);
+	if (!vma)
+		return -ENOMEM;
+
+	/*
+	 * Must not hold mm->mmap_sem when writing to image file, so
+	 * can't simply traverse the vma list. Instead, use find_vma()
+	 * to get the @next and make a local "copy" of it.
+	 */
+	while (1) {
+		down_read(&mm->mmap_sem);
+		next = find_vma(mm, vma->vm_end);
+		if (!next) {
+			up_read(&mm->mmap_sem);
+			break;
+		}
+		if (vma->vm_file)
+			fput(vma->vm_file);
+		*vma = *next;
+		if (vma->vm_file)
+			get_file(vma->vm_file);
+		up_read(&mm->mmap_sem);
+
+		map_count++;
+
+		ckpt_debug("vma %#lx-%#lx flags %#lx\n",
+			 vma->vm_start, vma->vm_end, vma->vm_flags);
+
+		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+			ckpt_err(ctx, -ENOSYS, "%(T)vma: bad flags (%#lx)\n",
+					vma->vm_flags);
+			ret = -ENOSYS;
+			break;
+		}
+
+		if (!vma->vm_ops)
+			ret = anonymous_checkpoint(ctx, vma);
+		else if (vma->vm_ops->checkpoint)
+			ret = (*vma->vm_ops->checkpoint)(ctx, vma);
+		else
+			ret = -ENOSYS;
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "%(T)vma: failed\n");
+			break;
+		}
+		/*
+		 * The file was collected, but not always checkpointed;
+		 * be safe and mark as visited to appease leak detection
+		 */
+		if (vma->vm_file && !(ctx->uflags & CHECKPOINT_SUBTREE)) {
+			ret = ckpt_obj_visit(ctx, vma->vm_file, CKPT_OBJ_FILE);
+			if (ret < 0)
+				break;
+		}
+	}
+
+	if (vma->vm_file)
+		fput(vma->vm_file);
+
+	kfree(vma);
+
+	return ret < 0 ? ret : map_count;
+}
+
+#define CKPT_AT_SZ (AT_VECTOR_SIZE * sizeof(u64))
+/*
+ * We always write saved_auxv out as an array of u64s, though it is
+ * an array of u32s on 32-bit arch.
+ */
+static int ckpt_write_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	int i, ret;
+	u64 *buf = kzalloc(CKPT_AT_SZ, GFP_KERNEL);
+
+	if (!buf)
+		return -ENOMEM;
+	for (i = 0; i < AT_VECTOR_SIZE; i++)
+		buf[i] = mm->saved_auxv[i];
+	ret = ckpt_write_buffer(ctx, buf, CKPT_AT_SZ);
+	kfree(buf);
+	return ret;
+}
+
+static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm *h;
+	struct file *exe_file = NULL;
+	int ret;
+
+	if (check_for_outstanding_aio(mm)) {
+		ckpt_err(ctx, -EBUSY, "(%T)Outstanding aio\n");
+		return -EBUSY;
+	}
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_MM);
+	if (!h)
+		return -ENOMEM;
+
+	down_read(&mm->mmap_sem);
+
+	h->flags = mm->flags;
+	h->def_flags = mm->def_flags;
+
+	h->start_code = mm->start_code;
+	h->end_code = mm->end_code;
+	h->start_data = mm->start_data;
+	h->end_data = mm->end_data;
+	h->start_brk = mm->start_brk;
+	h->brk = mm->brk;
+	h->start_stack = mm->start_stack;
+	h->arg_start = mm->arg_start;
+	h->arg_end = mm->arg_end;
+	h->env_start = mm->env_start;
+	h->env_end = mm->env_end;
+
+	h->map_count = mm->map_count;
+
+	if (mm->exe_file) {  /* checkpoint the ->exe_file */
+		exe_file = mm->exe_file;
+		get_file(exe_file);
+	}
+
+	/*
+	 * Drop mm->mmap_sem before writing data to checkpoint image
+	 * to avoid reverse locking order (inode must come before mm).
+	 */
+	up_read(&mm->mmap_sem);
+
+	if (exe_file) {
+		h->exe_objref = checkpoint_obj(ctx, exe_file, CKPT_OBJ_FILE);
+		if (h->exe_objref < 0) {
+			ret = h->exe_objref;
+			goto out;
+		}
+	}
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_auxv(ctx, mm);
+	if (ret < 0)
+		return ret;
+
+	ret = checkpoint_vmas(ctx, mm);
+	if (ret != h->map_count && ret >= 0)
+		ret = -EBUSY; /* checkpoint mm leak */
+	if (ret < 0)
+		goto out;
+
+	ret = checkpoint_mm_context(ctx, mm);
+ out:
+	if (exe_file)
+		fput(exe_file);
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr)
+{
+	return do_checkpoint_mm(ctx, (struct mm_struct *) ptr);
+}
+
+int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct mm_struct *mm;
+	int objref;
+
+	mm = get_task_mm(t);
+	objref = checkpoint_obj(ctx, mm, CKPT_OBJ_MM);
+	mmput(mm);
+
+	return objref;
+}
+
+/***********************************************************************
+ * Collect
+ */
+
+static int collect_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+	struct file *file;
+	int ret;
+
+	/* if already exists (ret == 0), nothing to do */
+	ret = ckpt_obj_collect(ctx, mm, CKPT_OBJ_MM);
+	if (ret <= 0)
+		return ret;
+
+	/* if first time for this mm (ret > 0), proceed inside */
+	down_read(&mm->mmap_sem);
+	if (mm->exe_file) {
+		ret = ckpt_collect_file(ctx, mm->exe_file);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "%(T)mm: collect exe_file\n");
+			goto out;
+		}
+	}
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		file = vma->vm_file;
+		if (!file)
+			continue;
+		ret = ckpt_collect_file(ctx, file);
+		if (ret < 0) {
+			ckpt_err(ctx, ret, "%(T)mm: collect vm_file\n");
+			break;
+		}
+	}
+ out:
+	up_read(&mm->mmap_sem);
+	return ret;
+
+}
+
+int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	mm = get_task_mm(t);
+	ret = collect_mm(ctx, mm);
+	mmput(mm);
+
+	return ret;
+}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index cacc4c7..16bb6cb 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -96,6 +96,22 @@ static int obj_file_users(void *ptr)
 	return atomic_long_read(&((struct file *) ptr)->f_count);
 }
 
+static int obj_mm_grab(void *ptr)
+{
+	atomic_inc(&((struct mm_struct *) ptr)->mm_users);
+	return 0;
+}
+
+static void obj_mm_drop(void *ptr, int lastref)
+{
+	mmput((struct mm_struct *) ptr);
+}
+
+static int obj_mm_users(void *ptr)
+{
+	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
+}
+
 static struct ckpt_obj_ops ckpt_obj_ops[] = {
 	/* ignored object */
 	{
@@ -124,6 +140,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_file,
 		.restore = restore_file,
 	},
+	/* mm object */
+	{
+		.obj_name = "MM",
+		.obj_type = CKPT_OBJ_MM,
+		.ref_drop = obj_mm_drop,
+		.ref_grab = obj_mm_grab,
+		.ref_users = obj_mm_users,
+		.checkpoint = checkpoint_mm,
+	},
 };
 
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index 23e0296..cc858c3 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -108,6 +108,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
 	int files_objref;
+	int mm_objref;
 	int ret;
 
 	files_objref = checkpoint_obj_file_table(ctx, t);
@@ -117,10 +118,18 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 		return files_objref;
 	}
 
+	mm_objref = checkpoint_obj_mm(ctx, t);
+	ckpt_debug("mm: objref %d\n", mm_objref);
+	if (mm_objref < 0) {
+		ckpt_err(ctx, mm_objref, "%(T)mm_struct\n");
+		return mm_objref;
+	}
+
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
 	if (!h)
 		return -ENOMEM;
 	h->files_objref = files_objref;
+	h->mm_objref = mm_objref;
 	ret = ckpt_write_obj(ctx, &h->h);
 	ckpt_hdr_put(ctx, h);
 
@@ -277,6 +286,9 @@ int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	int ret;
 
 	ret = ckpt_collect_file_table(ctx, t);
+	if (ret < 0)
+		return ret;
+	ret = ckpt_collect_mm(ctx, t);
 
 	return ret;
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 30b8004..bd09749 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -216,6 +216,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	ckpt_obj_hash_free(ctx);
 	path_put(&ctx->root_fs_path);
+	ckpt_pgarr_free(ctx);
 
 	if (ctx->tasks_arr)
 		task_arr_free(ctx);
@@ -227,6 +228,8 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->root_freezer)
 		put_task_struct(ctx->root_freezer);
 
+	free_page((unsigned long) ctx->scratch_page);
+
 	kfree(ctx->pids_arr);
 
 	kfree(ctx);
@@ -247,6 +250,8 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->ktime_begin = ktime_get();
 
 	atomic_set(&ctx->refcount, 0);
+	INIT_LIST_HEAD(&ctx->pgarr_list);
+	INIT_LIST_HEAD(&ctx->pgarr_pool);
 	init_waitqueue_head(&ctx->waitq);
 	init_completion(&ctx->complete);
 
@@ -278,6 +283,10 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (!ctx->files_deferq)
 		goto err;
 
+	ctx->scratch_page = (void *) __get_free_page(GFP_KERNEL);
+	if (!ctx->scratch_page)
+		goto err;
+
 	atomic_inc(&ctx->refcount);
 	return ctx;
  err:
diff --git a/fs/aio.c b/fs/aio.c
index 1cf12b3..b3e1532 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1806,3 +1806,20 @@ SYSCALL_DEFINE5(io_getevents, aio_context_t, ctx_id,
 	asmlinkage_protect(5, ret, ctx_id, min_nr, nr, events, timeout);
 	return ret;
 }
+
+int check_for_outstanding_aio(struct mm_struct *mm)
+{
+	struct kioctx *ctx;
+	struct hlist_node *n;
+	int ret = 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(ctx, n, &mm->ioctx_list, list) {
+		if (!ctx->dead) {
+			ret = -EBUSY;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return ret;
+}
diff --git a/include/linux/aio.h b/include/linux/aio.h
index 811dbb3..e0b1808 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -212,6 +212,7 @@ extern void kick_iocb(struct kiocb *iocb);
 extern int aio_complete(struct kiocb *iocb, long res, long res2);
 struct mm_struct;
 extern void exit_aio(struct mm_struct *mm);
+extern int check_for_outstanding_aio(struct mm_struct *mm);
 #else
 static inline ssize_t wait_on_sync_kiocb(struct kiocb *iocb) { return 0; }
 static inline int aio_put_req(struct kiocb *iocb) { return 0; }
@@ -219,6 +220,7 @@ static inline void kick_iocb(struct kiocb *iocb) { }
 static inline int aio_complete(struct kiocb *iocb, long res, long res2) { return 0; }
 struct mm_struct;
 static inline void exit_aio(struct mm_struct *mm) { }
+static inline int check_for_outstanding_aio(struct mm_struct *mm) { return 0; }
 #endif /* CONFIG_AIO */
 
 static inline struct kiocb *list_kiocb(struct list_head *h)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 749f30c..2f050ef 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -83,6 +83,8 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
 
+extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
@@ -150,6 +152,7 @@ extern int restore_task(struct ckpt_ctx *ctx);
 extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
 extern int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
 extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
@@ -181,6 +184,29 @@ extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
 extern int restore_file_common(struct ckpt_ctx *ctx, struct file *file,
 			       struct ckpt_hdr_file *h);
 
+/* memory */
+extern void ckpt_pgarr_free(struct ckpt_ctx *ctx);
+
+extern int generic_vma_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  enum vma_type type,
+				  int vma_objref);
+extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
+				  struct vm_area_struct *vma,
+				  enum vma_type type,
+				  int vma_objref);
+
+extern int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t);
+
+extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr);
+
+#define CKPT_VMA_NOT_SUPPORTED					\
+	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB |		\
+	 VM_NONLINEAR | VM_PFNMAP | VM_RESERVED | VM_NORESERVE	\
+	 | VM_HUGETLB | VM_NONLINEAR | VM_MAPPED_COPY |		\
+	 VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
@@ -192,6 +218,8 @@ static inline int ckpt_validate_errno(int errno)
 #define CKPT_DRW	0x4		/* image read/write */
 #define CKPT_DOBJ	0x8		/* shared objects */
 #define CKPT_DFILE	0x10		/* files and filesystem */
+#define CKPT_DMEM	0x20		/* memory state */
+#define CKPT_DPAGE	0x40		/* memory pages */
 
 #define CKPT_DDEFAULT	0xffff		/* default debug level */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 3222545..b3dc6fa 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -91,6 +91,15 @@ enum {
 	CKPT_HDR_FILE,
 #define CKPT_HDR_FILE CKPT_HDR_FILE
 
+	CKPT_HDR_MM = 401,
+#define CKPT_HDR_MM CKPT_HDR_MM
+	CKPT_HDR_VMA,
+#define CKPT_HDR_VMA CKPT_HDR_VMA
+	CKPT_HDR_PGARR,
+#define CKPT_HDR_PGARR CKPT_HDR_PGARR
+	CKPT_HDR_MM_CONTEXT,
+#define CKPT_HDR_MM_CONTEXT CKPT_HDR_MM_CONTEXT
+
 	CKPT_HDR_TAIL = 9001,
 #define CKPT_HDR_TAIL CKPT_HDR_TAIL
 
@@ -121,6 +130,8 @@ enum obj_type {
 #define CKPT_OBJ_FILE_TABLE CKPT_OBJ_FILE_TABLE
 	CKPT_OBJ_FILE,
 #define CKPT_OBJ_FILE CKPT_OBJ_FILE
+	CKPT_OBJ_MM,
+#define CKPT_OBJ_MM CKPT_OBJ_MM
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -129,6 +140,8 @@ enum obj_type {
 struct ckpt_const {
 	/* task */
 	__u16 task_comm_len;
+	/* mm */
+	__u16 at_vector_size;
 	/* uts */
 	__u16 uts_release_len;
 	__u16 uts_version_len;
@@ -207,6 +220,7 @@ struct ckpt_hdr_task {
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
 	__s32 files_objref;
+	__s32 mm_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
@@ -279,4 +293,52 @@ struct ckpt_hdr_file_generic {
 	struct ckpt_hdr_file common;
 } __attribute__((aligned(8)));
 
+/* memory layout */
+struct ckpt_hdr_mm {
+	struct ckpt_hdr h;
+	__u32 map_count;
+	__s32 exe_objref;
+
+	__u64 def_flags;
+	__u64 flags;
+
+	__u64 start_code, end_code, start_data, end_data;
+	__u64 start_brk, brk, start_stack;
+	__u64 arg_start, arg_end, env_start, env_end;
+} __attribute__((aligned(8)));
+
+/* vma subtypes */
+enum vma_type {
+	CKPT_VMA_IGNORE = 0,
+#define CKPT_VMA_IGNORE CKPT_VMA_IGNORE
+	CKPT_VMA_VDSO,		/* special vdso vma */
+#define CKPT_VMA_VDSO CKPT_VMA_VDSO
+	CKPT_VMA_ANON,		/* private anonymous */
+#define CKPT_VMA_ANON CKPT_VMA_ANON
+	CKPT_VMA_FILE,		/* private mapped file */
+#define CKPT_VMA_FILE CKPT_VMA_FILE
+	CKPT_VMA_MAX
+#define CKPT_VMA_MAX CKPT_VMA_MAX
+};
+
+/* vma descriptor */
+struct ckpt_hdr_vma {
+	struct ckpt_hdr h;
+	__u32 vma_type;
+	__s32 vma_objref;	/* objref of backing file */
+
+	__u64 vm_start;
+	__u64 vm_end;
+	__u64 vm_page_prot;
+	__u64 vm_flags;
+	__u64 vm_pgoff;
+} __attribute__((aligned(8)));
+
+/* page array */
+struct ckpt_hdr_pgarr {
+	struct ckpt_hdr h;
+	__u64 nr_pages;		/* number of pages to saved */
+} __attribute__((aligned(8)));
+
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index aae6755..192dd86 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -15,6 +15,8 @@
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
 #include <linux/list.h>
+#include <linux/sched.h>
+#include <linux/nsproxy.h>
 #include <linux/path.h>
 #include <linux/fs.h>
 #include <linux/ktime.h>
@@ -52,6 +54,11 @@ struct ckpt_ctx {
 	int errno;		/* errno that caused failure */
 	struct completion errno_sync;	/* protect errno setting */
 
+	struct list_head pgarr_list;	/* page array to dump VMA contents */
+	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
+
+	void *scratch_page;             /* scratch buffer for page I/O */
+
 	/* [multi-process checkpoint] */
 	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
 	int nr_tasks;                   /* size of tasks array */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a93f4dc..ef3e6b4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1188,6 +1188,11 @@ extern void truncate_inode_pages_range(struct address_space *,
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
 
+#ifdef CONFIG_CHECKPOINT
+/* generic vm_area_ops exported for mapped files checkpoint */
+extern int filemap_checkpoint(struct ckpt_ctx *, struct vm_area_struct *);
+#endif
+
 /* mm/page-writeback.c */
 int write_one_page(struct page *page, int wait);
 void task_dirty_inc(struct task_struct *tsk);
diff --git a/mm/filemap.c b/mm/filemap.c
index 698ea80..85998c5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -34,6 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <linux/checkpoint.h>
 #include "internal.h"
 
 /*
@@ -1590,8 +1591,35 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
+#ifdef CONFIG_CHECKPOINT
+int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
+{
+	struct file *file = vma->vm_file;
+	int vma_objref;
+
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
+		pr_warning("c/r: unsupported VMA %#lx\n", vma->vm_flags);
+		return -ENOSYS;
+	}
+
+	BUG_ON(!file);
+
+	vma_objref = checkpoint_obj(ctx, file, CKPT_OBJ_FILE);
+	if (vma_objref < 0)
+		return vma_objref;
+
+	return private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE, vma_objref);
+}
+EXPORT_SYMBOL(filemap_checkpoint);
+#else
+#define filemap_checkpoint NULL
+#endif /* CONFIG_CHECKPOINT */
+
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= filemap_checkpoint,
+#endif
 };
 
 /* This is used for a general mmap of a disk file */
diff --git a/mm/mmap.c b/mm/mmap.c
index ee22989..3fac497 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -28,6 +28,7 @@
 #include <linux/rmap.h>
 #include <linux/mmu_notifier.h>
 #include <linux/perf_event.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2330,9 +2331,38 @@ static void special_mapping_close(struct vm_area_struct *vma)
 {
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
+				      struct vm_area_struct *vma)
+{
+	const char *name;
+
+	/*
+	 * FIX:
+	 * Currently, we only handle VDSO/vsyscall special handling.
+	 * Even that, is very basic - we just skip the contents and
+	 * hope for the best in terms of compatilibity upon restart.
+	 */
+
+	if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED)
+		return -ENOSYS;
+
+	name = arch_vma_name(vma);
+	if (!name || strcmp(name, "[vdso]"))
+		return -ENOSYS;
+
+	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0);
+}
+#else
+#define special_mapping_checkpoint NULL
+#endif /* CONFIG_CHECKPOINT */
+
 static const struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
 	.fault = special_mapping_fault,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint = special_mapping_checkpoint,
+#endif
 };
 
 /*
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
