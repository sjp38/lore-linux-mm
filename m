Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 56D956B0222
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:14:49 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 43/96] c/r: restore memory address space (private memory)
Date: Wed, 17 Mar 2010 12:08:31 -0400
Message-Id: <1268842164-5590-44-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-43-git-send-email-orenl@cs.columbia.edu>
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
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Restoring the memory address space begins with nuking the existing one
of the current process, and then reading the vma state and contents.
Call do_mmap_pgoffset() for each vma and then read in the data.

Changelog[v20]:
  - Only use arch_setup_additional_pages() if supported by arch
Changelog[v19]:
  - [Serge Hallyn] do_munmap(): remove unused local vars
  - [Serge Hallyn] Checkpoint saved_auxv as u64s
Changelog[v19-rc3]:
  - [Serge Hallyn] move destroy_mm into mmap.c and remove size check
  - [Serge Hallyn] fill vdso (syscall32_setup_pages) for TIF_IA32/x86_64
  - Do not hold mmap_sem when reading memory pages on restart
Changelog[v19-rc2]:
  - Expose page write functions
  - [Serge Hallyn] Fix return value of read_pages_contents()
Changelog[v18]:
  - Tighten checks on supported vma to checkpoint or restart
Changelog[v17]:
  - Restore mm->{flags,def_flags,saved_auxv}
  - Fix bogus warning in do_restore_mm()
Changelog[v16]:
  - Restore mm->exe_file
Changelog[v14]:
  - Introduce per vma-type restore() function
  - Merge restart code into same file as checkpoint (memory.c)
  - Compare saved 'vdso' field of mm_context with current value
  - Check whether calls to ckpt_hbuf_get() fail
  - Discard field 'h->parent'
  - Revert change to pr_debug(), back to ckpt_debug()
Changelog[v13]:
  - Avoid access to hh->vma_type after the header is freed
  - Test for no vma's in exit_mmap() before calling unmap_vma() (or it
    may crash if restart fails after having removed all vma's)
Changelog[v12]:
  - Replace obsolete ckpt_debug() with pr_debug()
Changelog[v9]:
  - Introduce ckpt_ctx_checkpoint() for checkpoint-specific ctx setup
Changelog[v7]:
  - Fix argument given to kunmap_atomic() in memory dump/restore
Changelog[v6]:
  - Balance all calls to ckpt_hbuf_get() with matching ckpt_hbuf_put()
    (even though it's not really needed)
Changelog[v5]:
  - Improve memory restore code (following Dave Hansen's comments)
  - Change dump format (and code) to allow chunks of <vaddrs, pages>
    instead of one long list of each
  - Memory restore now maps user pages explicitly to copy data into them,
    instead of reading directly to user space; got rid of mprotect_fixup()
Changelog[v4]:
  - Use standard list_... for ckpt_pgarr

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 arch/x86/include/asm/ldt.h     |    7 +
 arch/x86/kernel/checkpoint.c   |   64 ++++++
 checkpoint/memory.c            |  476 ++++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c           |    1 +
 checkpoint/process.c           |    3 +
 checkpoint/restart.c           |    3 +
 fs/exec.c                      |    2 +-
 include/linux/checkpoint.h     |    8 +
 include/linux/checkpoint_hdr.h |    2 +-
 include/linux/mm.h             |   14 ++
 mm/filemap.c                   |   23 ++-
 mm/mmap.c                      |   77 ++++++-
 12 files changed, 669 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/ldt.h b/arch/x86/include/asm/ldt.h
index 46727eb..f2845f9 100644
--- a/arch/x86/include/asm/ldt.h
+++ b/arch/x86/include/asm/ldt.h
@@ -37,4 +37,11 @@ struct user_desc {
 #define MODIFY_LDT_CONTENTS_CODE	2
 
 #endif /* !__ASSEMBLY__ */
+
+#ifdef __KERNEL__
+#include <linux/linkage.h>
+asmlinkage int sys_modify_ldt(int func, void __user *ptr,
+			      unsigned long bytecount);
+#endif
+
 #endif /* _ASM_X86_LDT_H */
diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
index dec824c..cf86b7a 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -13,6 +13,7 @@
 
 #include <asm/desc.h>
 #include <asm/i387.h>
+#include <asm/elf.h>
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -465,3 +466,66 @@ int restore_read_header_arch(struct ckpt_ctx *ctx)
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
+
+int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_mm_context *h;
+	unsigned int n;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM_CONTEXT);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("nldt %d vdso %#lx (%p)\n",
+		 h->nldt, (unsigned long) h->vdso, mm->context.vdso);
+
+	ret = -EINVAL;
+	if (h->vdso != (unsigned long) mm->context.vdso)
+		goto out;
+	if (h->ldt_entry_size != LDT_ENTRY_SIZE)
+		goto out;
+
+	ret = _ckpt_read_obj_type(ctx, NULL,
+				  h->nldt * LDT_ENTRY_SIZE,
+				  CKPT_HDR_MM_CONTEXT_LDT);
+	if (ret < 0)
+		goto out;
+
+	/*
+	 * to utilize the syscall modify_ldt() we first convert the data
+	 * in the checkpoint image from 'struct desc_struct' to 'struct
+	 * user_desc' with reverse logic of include/asm/desc.h:fill_ldt()
+	 */
+	for (n = 0; n < h->nldt; n++) {
+		struct user_desc info;
+		struct desc_struct desc;
+		mm_segment_t old_fs;
+
+		ret = ckpt_kread(ctx, &desc, LDT_ENTRY_SIZE);
+		if (ret < 0)
+			break;
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
+		ret = sys_modify_ldt(1, (struct user_desc __user *) &info,
+				     sizeof(info));
+		set_fs(old_fs);
+
+		if (ret < 0)
+			break;
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index e82d240..3016521 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -16,6 +16,9 @@
 #include <linux/slab.h>
 #include <linux/file.h>
 #include <linux/aio.h>
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/mm_types.h>
 #include <linux/proc_fs.h>
@@ -721,3 +724,476 @@ int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	return ret;
 }
+
+/***********************************************************************
+ * Restart
+ *
+ * Unlike checkpoint, restart is executed in the context of each restarting
+ * process: vma regions are restored via a call to mmap(), and the data is
+ * read into the address space of the current process.
+ */
+
+/**
+ * read_pages_vaddrs - read addresses of pages to page-array chain
+ * @ctx - restart context
+ * @nr_pages - number of address to read
+ */
+static int read_pages_vaddrs(struct ckpt_ctx *ctx, unsigned long nr_pages)
+{
+	struct ckpt_pgarr *pgarr;
+	unsigned long *vaddrp;
+	int nr, ret;
+
+	while (nr_pages) {
+		pgarr = pgarr_current(ctx);
+		if (!pgarr)
+			return -ENOMEM;
+		nr = pgarr_nr_free(pgarr);
+		if (nr > nr_pages)
+			nr = nr_pages;
+		vaddrp = &pgarr->vaddrs[pgarr->nr_used];
+		ret = ckpt_kread(ctx, vaddrp, nr * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+		pgarr->nr_used += nr;
+		nr_pages -= nr;
+	}
+	return 0;
+}
+
+int restore_read_page(struct ckpt_ctx *ctx, struct page *page)
+{
+	void *ptr;
+	int ret;
+
+	ret = ckpt_kread(ctx, ctx->scratch_page, PAGE_SIZE);
+	if (ret < 0)
+		return ret;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(ptr, ctx->scratch_page, PAGE_SIZE);
+	kunmap_atomic(ptr, KM_USER1);
+
+	return 0;
+}
+
+/**
+ * read_pages_contents - read in data of pages in page-array chain
+ * @ctx - restart context
+ */
+static int read_pages_contents(struct ckpt_ctx *ctx)
+{
+	struct mm_struct *mm = current->mm;
+	struct ckpt_pgarr *pgarr;
+	unsigned long *vaddrs;
+	int i, ret = 0;
+
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		vaddrs = pgarr->vaddrs;
+		for (i = 0; i < pgarr->nr_used; i++) {
+			struct page *page;
+
+			/* TODO: do in chunks to reduce mmap_sem overhead */
+			_ckpt_debug(CKPT_DPAGE, "got page %#lx\n", vaddrs[i]);
+			down_read(&current->mm->mmap_sem);
+			ret = get_user_pages(current, mm, vaddrs[i],
+					     1, 1, 1, &page, NULL);
+			up_read(&current->mm->mmap_sem);
+			if (ret < 0)
+				return ret;
+
+			ret = restore_read_page(ctx, page);
+			page_cache_release(page);
+
+			if (ret < 0)
+				return ret;
+		}
+	}
+	return ret;
+}
+
+/**
+ * restore_memory_contents - restore contents of a VMA with private memory
+ * @ctx - restart context
+ *
+ * Reads a header that specifies how many pages will follow, then reads
+ * a list of virtual addresses into ctx->pgarr_list page-array chain,
+ * followed by the actual contents of the corresponding pages. Iterates
+ * these steps until reaching a header specifying "0" pages, which marks
+ * the end of the contents.
+ */
+static int restore_memory_contents(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_pgarr *h;
+	unsigned long nr_pages;
+	int len, ret = 0;
+
+	while (1) {
+		h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_PGARR);
+		if (IS_ERR(h))
+			break;
+
+		ckpt_debug("total pages %ld\n", (unsigned long) h->nr_pages);
+
+		nr_pages = h->nr_pages;
+		ckpt_hdr_put(ctx, h);
+
+		if (!nr_pages)
+			break;
+
+		len = nr_pages * (sizeof(unsigned long) + PAGE_SIZE);
+		ret = _ckpt_read_buffer(ctx, NULL, len);
+		if (ret < 0)
+			break;
+
+		ret = read_pages_vaddrs(ctx, nr_pages);
+		if (ret < 0)
+			break;
+		ret = read_pages_contents(ctx);
+		if (ret < 0)
+			break;
+		pgarr_reset_all(ctx);
+	}
+
+	return ret;
+}
+
+/**
+ * calc_map_prot_bits - convert vm_flags to mmap protection
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long calc_map_prot_bits(unsigned long orig_vm_flags)
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
+ * calc_map_flags_bits - convert vm_flags to mmap flags
+ * orig_vm_flags: source vm_flags
+ */
+static unsigned long calc_map_flags_bits(unsigned long orig_vm_flags)
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
+/**
+ * generic_vma_restore - restore a vma
+ * @mm - address space
+ * @file - file to map (NULL for anonymous)
+ * @h - vma header data
+ */
+static unsigned long generic_vma_restore(struct mm_struct *mm,
+					 struct file *file,
+					 struct ckpt_hdr_vma *h)
+{
+	unsigned long vm_size, vm_start, vm_flags, vm_prot, vm_pgoff;
+	unsigned long addr;
+
+	if (h->vm_end < h->vm_start)
+		return -EINVAL;
+	if (h->vma_objref < 0)
+		return -EINVAL;
+
+	vm_start = h->vm_start;
+	vm_pgoff = h->vm_pgoff;
+	vm_size = h->vm_end - h->vm_start;
+	vm_prot = calc_map_prot_bits(h->vm_flags);
+	vm_flags = calc_map_flags_bits(h->vm_flags);
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap_pgoff(file, vm_start, vm_size,
+			     vm_prot, vm_flags, vm_pgoff);
+	up_write(&mm->mmap_sem);
+	ckpt_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
+		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
+
+	return addr;
+}
+
+/**
+ * private_vma_restore - read vma data, recreate it and read contents
+ * @ctx: checkpoint context
+ * @mm: memory address space
+ * @file: file to use for mapping
+ * @h - vma header data
+ */
+int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			struct file *file, struct ckpt_hdr_vma *h)
+{
+	unsigned long addr;
+
+	if (h->vm_flags & (VM_SHARED | VM_MAYSHARE))
+		return -EINVAL;
+
+	addr = generic_vma_restore(mm, file, h);
+	if (IS_ERR((void *) addr))
+		return PTR_ERR((void *) addr);
+
+	return restore_memory_contents(ctx);
+}
+
+/**
+ * anon_private_restore - read vma data, recreate it and read contents
+ * @ctx: checkpoint context
+ * @mm: memory address space
+ * @h - vma header data
+ */
+static int anon_private_restore(struct ckpt_ctx *ctx,
+				     struct mm_struct *mm,
+				     struct ckpt_hdr_vma *h)
+{
+	/*
+	 * vm_pgoff for anonymous mapping is the "global" page
+	 * offset (namely from addr 0x0), so we force a zero
+	 */
+	h->vm_pgoff = 0;
+
+	return private_vma_restore(ctx, mm, NULL, h);
+}
+
+/* callbacks to restore vma per its type: */
+struct restore_vma_ops {
+	char *vma_name;
+	enum vma_type vma_type;
+	int (*restore) (struct ckpt_ctx *ctx,
+			struct mm_struct *mm,
+			struct ckpt_hdr_vma *ptr);
+};
+
+static struct restore_vma_ops restore_vma_ops[] = {
+	/* ignored vma */
+	{
+		.vma_name = "IGNORE",
+		.vma_type = CKPT_VMA_IGNORE,
+		.restore = NULL,
+	},
+	/* special mapping (vdso) */
+	{
+		.vma_name = "VDSO",
+		.vma_type = CKPT_VMA_VDSO,
+		.restore = special_mapping_restore,
+	},
+	/* anonymous private */
+	{
+		.vma_name = "ANON PRIVATE",
+		.vma_type = CKPT_VMA_ANON,
+		.restore = anon_private_restore,
+	},
+	/* file-mapped private */
+	{
+		.vma_name = "FILE PRIVATE",
+		.vma_type = CKPT_VMA_FILE,
+		.restore = filemap_restore,
+	},
+};
+
+/**
+ * restore_vma - read vma data, recreate it and read contents
+ * @ctx: checkpoint context
+ * @mm: memory address space
+ */
+static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	struct ckpt_hdr_vma *h;
+	struct restore_vma_ops *ops;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_VMA);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ckpt_debug("vma %#lx-%#lx flags %#lx type %d vmaref %d\n",
+		   (unsigned long) h->vm_start, (unsigned long) h->vm_end,
+		   (unsigned long) h->vm_flags, (int) h->vma_type,
+		   (int) h->vma_objref);
+
+	ret = -EINVAL;
+	if (h->vm_end < h->vm_start)
+		goto out;
+	if (h->vma_objref < 0)
+		goto out;
+	if (h->vma_type >= CKPT_VMA_MAX)
+		goto out;
+	if (h->vm_flags & CKPT_VMA_NOT_SUPPORTED)
+		return -ENOSYS;
+
+	ops = &restore_vma_ops[h->vma_type];
+
+	/* make sure we don't change this accidentally */
+	BUG_ON(ops->vma_type != h->vma_type);
+
+	if (ops->restore) {
+		ckpt_debug("vma type %s\n", ops->vma_name);
+		ret = ops->restore(ctx, mm, h);
+	} else {
+		ckpt_debug("vma ignored\n");
+		ret = 0;
+	}
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
+static int ckpt_read_auxv(struct ckpt_ctx *ctx, struct mm_struct *mm)
+{
+	int i, ret;
+	u64 *buf = kmalloc(CKPT_AT_SZ, GFP_KERNEL);
+
+	if (!buf)
+		return -ENOMEM;
+	ret = _ckpt_read_buffer(ctx, buf, CKPT_AT_SZ);
+	if (ret < 0)
+		goto out;
+
+	ret = -E2BIG;
+	for (i = 0; i < AT_VECTOR_SIZE; i++)
+		if (buf[i] > (u64) ULONG_MAX)
+			goto out;
+
+	for (i = 0; i < AT_VECTOR_SIZE - 1; i++)
+		mm->saved_auxv[i] = buf[i];
+	/* sanitize the input: force AT_NULL in last entry  */
+	mm->saved_auxv[AT_VECTOR_SIZE - 1] = AT_NULL;
+
+	ret = 0;
+ out:
+	kfree(buf);
+	return ret;
+}
+
+static struct mm_struct *do_restore_mm(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_mm *h;
+	struct mm_struct *mm = NULL;
+	struct file *file;
+	unsigned int nr;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM);
+	if (IS_ERR(h))
+		return (struct mm_struct *) h;
+
+	ckpt_debug("map_count %d\n", h->map_count);
+
+	/* XXX need more sanity checks */
+
+	ret = -EINVAL;
+	if ((h->start_code > h->end_code) ||
+	    (h->start_data > h->end_data))
+		goto out;
+	if (h->exe_objref < 0)
+		goto out;
+	if (h->def_flags & ~VM_LOCKED)
+		goto out;
+	if (h->flags & ~(MMF_DUMP_FILTER_MASK |
+			 ((1 << MMF_DUMP_FILTER_BITS) - 1)))
+		goto out;
+
+	mm = current->mm;
+
+	/* point of no return -- destruct current mm */
+	down_write(&mm->mmap_sem);
+	ret = destroy_mm(mm);
+	if (ret < 0) {
+		up_write(&mm->mmap_sem);
+		goto out;
+	}
+
+	mm->flags = h->flags;
+	mm->def_flags = h->def_flags;
+
+	mm->start_code = h->start_code;
+	mm->end_code = h->end_code;
+	mm->start_data = h->start_data;
+	mm->end_data = h->end_data;
+	mm->start_brk = h->start_brk;
+	mm->brk = h->brk;
+	mm->start_stack = h->start_stack;
+	mm->arg_start = h->arg_start;
+	mm->arg_end = h->arg_end;
+	mm->env_start = h->env_start;
+	mm->env_end = h->env_end;
+
+	/* restore the ->exe_file */
+	if (h->exe_objref) {
+		file = ckpt_obj_fetch(ctx, h->exe_objref, CKPT_OBJ_FILE);
+		if (IS_ERR(file)) {
+			up_write(&mm->mmap_sem);
+			ret = PTR_ERR(file);
+			goto out;
+		}
+		set_mm_exe_file(mm, file);
+	}
+	up_write(&mm->mmap_sem);
+
+	ret = ckpt_read_auxv(ctx, mm);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Error restoring auxv\n");
+		goto out;
+	}
+
+	for (nr = h->map_count; nr; nr--) {
+		ret = restore_vma(ctx, mm);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = restore_mm_context(ctx, mm);
+ out:
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ERR_PTR(ret);
+	/* restore_obj() expect an extra reference */
+	atomic_inc(&mm->mm_users);
+	return mm;
+}
+
+void *restore_mm(struct ckpt_ctx *ctx)
+{
+	return (void *) do_restore_mm(ctx);
+}
+
+int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref)
+{
+	struct mm_struct *mm;
+	int ret;
+
+	mm = ckpt_obj_fetch(ctx, mm_objref, CKPT_OBJ_MM);
+	if (IS_ERR(mm))
+		return PTR_ERR(mm);
+
+	if (mm == current->mm)
+		return 0;
+
+	ret = exec_mmap(mm);
+	if (ret < 0)
+		return ret;
+
+	atomic_inc(&mm->mm_users);
+	return 0;
+}
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 16bb6cb..3243bb4 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -148,6 +148,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.ref_grab = obj_mm_grab,
 		.ref_users = obj_mm_users,
 		.checkpoint = checkpoint_mm,
+		.restore = restore_mm,
 	},
 };
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index cc858c3..91999ee 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -372,6 +372,9 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
 
+	ret = restore_obj_mm(ctx, h->mm_objref);
+	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
+
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index d33b18a..325d03a 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -563,6 +563,9 @@ static int check_kernel_const(struct ckpt_const *h)
 	/* task */
 	if (h->task_comm_len != sizeof(tsk->comm))
 		return -EINVAL;
+	/* mm->saved_auxv size */
+	if (h->at_vector_size != AT_VECTOR_SIZE)
+		return -EINVAL;
 	/* uts */
 	if (h->uts_release_len != sizeof(uts->release))
 		return -EINVAL;
diff --git a/fs/exec.c b/fs/exec.c
index cce6bbd..ed3b98a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -710,7 +710,7 @@ int kernel_read(struct file *file, loff_t offset,
 
 EXPORT_SYMBOL(kernel_read);
 
-static int exec_mmap(struct mm_struct *mm)
+int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct * old_mm, *active_mm;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 2f050ef..0b47f46 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -84,6 +84,7 @@ extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
 
 extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
+extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
 
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
@@ -157,6 +158,7 @@ extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
 extern int restore_cpu(struct ckpt_ctx *ctx);
+extern int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
 extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
@@ -197,9 +199,15 @@ extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
 				  int vma_objref);
 
 extern int checkpoint_obj_mm(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
 
 extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr);
+extern void *restore_mm(struct ckpt_ctx *ctx);
+
+extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			       struct file *file, struct ckpt_hdr_vma *h);
+
 
 #define CKPT_VMA_NOT_SUPPORTED					\
 	(VM_SHARED | VM_MAYSHARE | VM_IO | VM_HUGETLB |		\
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b3dc6fa..0687b61 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -307,7 +307,7 @@ struct ckpt_hdr_mm {
 	__u64 arg_start, arg_end, env_start, env_end;
 } __attribute__((aligned(8)));
 
-/* vma subtypes */
+/* vma subtypes - index into restore_vma_dispatch[] */
 enum vma_type {
 	CKPT_VMA_IGNORE = 0,
 #define CKPT_VMA_IGNORE CKPT_VMA_IGNORE
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef3e6b4..bdeb0b5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1176,9 +1176,13 @@ out:
 }
 
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
+extern int destroy_mm(struct mm_struct *);
 
 extern unsigned long do_brk(unsigned long, unsigned long);
 
+/* fs/exec.c */
+extern int exec_mmap(struct mm_struct *mm);
+
 /* filemap.c */
 extern unsigned long page_unuse(struct page *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
@@ -1197,6 +1201,16 @@ extern int filemap_checkpoint(struct ckpt_ctx *, struct vm_area_struct *);
 int write_one_page(struct page *page, int wait);
 void task_dirty_inc(struct task_struct *tsk);
 
+
+/* checkpoint/restart */
+#ifdef CONFIG_CHECKPOINT
+struct ckpt_hdr_vma;
+extern int filemap_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			   struct ckpt_hdr_vma *hh);
+extern int special_mapping_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+				   struct ckpt_hdr_vma *hh);
+#endif
+
 /* readahead.c */
 #define VM_MAX_READAHEAD	128	/* kbytes */
 #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
diff --git a/mm/filemap.c b/mm/filemap.c
index 85998c5..f53223f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1611,9 +1611,28 @@ int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 	return private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE, vma_objref);
 }
 EXPORT_SYMBOL(filemap_checkpoint);
-#else
+
+int filemap_restore(struct ckpt_ctx *ctx,
+		    struct mm_struct *mm,
+		    struct ckpt_hdr_vma *h)
+{
+	struct file *file;
+	int ret;
+
+	if (h->vma_type == CKPT_VMA_FILE &&
+	    (h->vm_flags & (VM_SHARED | VM_MAYSHARE)))
+		return -EINVAL;
+
+	file = ckpt_obj_fetch(ctx, h->vma_objref, CKPT_OBJ_FILE);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+
+	ret = private_vma_restore(ctx, mm, file, h);
+	return ret;
+}
+#else /* !CONFIG_CHECKPOINT */
 #define filemap_checkpoint NULL
-#endif /* CONFIG_CHECKPOINT */
+#endif
 
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
diff --git a/mm/mmap.c b/mm/mmap.c
index 3fac497..6573e51 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1934,14 +1934,11 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  * work.  This now handles partial unmappings.
  * Jeremy Fitzhardinge <jeremy@goop.org>
  */
-int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+int do_munmap_nocheck(struct mm_struct *mm, unsigned long start, size_t len)
 {
 	unsigned long end;
 	struct vm_area_struct *vma, *prev, *last;
 
-	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
-		return -EINVAL;
-
 	if ((len = PAGE_ALIGN(len)) == 0)
 		return -EINVAL;
 
@@ -2015,8 +2012,39 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 	return 0;
 }
 
+int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
+{
+	if ((start & ~PAGE_MASK) || start > TASK_SIZE || len > TASK_SIZE-start)
+		return -EINVAL;
+
+	return do_munmap_nocheck(mm, start, len);
+}
+
 EXPORT_SYMBOL(do_munmap);
 
+/*
+ * called with mm->mmap-sem held
+ * only called from checkpoint/memory.c:restore_mm()
+ */
+int destroy_mm(struct mm_struct *mm)
+{
+	struct vm_area_struct *vmnext = mm->mmap;
+	struct vm_area_struct *vma;
+	int ret;
+
+	while (vmnext) {
+		vma = vmnext;
+		vmnext = vmnext->vm_next;
+		ret = do_munmap_nocheck(mm, vma->vm_start,
+					vma->vm_end-vma->vm_start);
+		if (ret < 0) {
+			pr_warning("%s: failed munmap (%d)\n", __func__, ret);
+			return ret;
+		}
+	}
+	return 0;
+}
+
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
 	int ret;
@@ -2172,7 +2200,7 @@ void exit_mmap(struct mm_struct *mm)
 	tlb = tlb_gather_mmu(mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = vma ? unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL) : 0;
 	vm_unacct_memory(nr_accounted);
 
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
@@ -2332,6 +2360,14 @@ static void special_mapping_close(struct vm_area_struct *vma)
 }
 
 #ifdef CONFIG_CHECKPOINT
+/*
+ * FIX:
+ *   - checkpoint vdso pages (once per distinct vdso is enough)
+ *   - check for compatilibility between saved and current vdso
+ *   - accommodate for dynamic kernel data in vdso page
+ *
+ * Current, we require COMPAT_VDSO which somewhat mitigates the issue
+ */
 static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
 				      struct vm_area_struct *vma)
 {
@@ -2353,9 +2389,36 @@ static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
 
 	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0);
 }
-#else
+
+int special_mapping_restore(struct ckpt_ctx *ctx,
+			    struct mm_struct *mm,
+			    struct ckpt_hdr_vma *h)
+{
+	int ret = 0;
+
+	/*
+	 * FIX:
+	 * Currently, we only handle VDSO/vsyscall special handling.
+	 * Even that, is very basic - call arch_setup_additional_pages
+	 * requiring the same mapping (start address) as before.
+	 */
+
+	BUG_ON(h->vma_type != CKPT_VMA_VDSO);
+
+#ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
+#if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
+	if (test_thread_flag(TIF_IA32))
+		ret = syscall32_setup_pages(NULL, h->vm_start, 0);
+	else
+#endif
+	ret = arch_setup_additional_pages(NULL, h->vm_start, 0);
+#endif
+
+	return ret;
+}
+#else /* !CONFIG_CHECKPOINT */
 #define special_mapping_checkpoint NULL
-#endif /* CONFIG_CHECKPOINT */
+#endif
 
 static const struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
