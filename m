Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 975AC6B0088
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:42 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 38/80] c/r: restore memory address space (private memory)
Date: Wed, 23 Sep 2009 19:51:18 -0400
Message-Id: <1253749920-18673-39-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Restoring the memory address space begins with nuking the existing one
of the current process, and then reading the vma state and contents.
Call do_mmap_pgoffset() for each vma and then read in the data.

Changelog[v17]:
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
---
 arch/x86/include/asm/ldt.h     |    7 +
 arch/x86/mm/checkpoint.c       |   64 ++++++
 checkpoint/memory.c            |  472 ++++++++++++++++++++++++++++++++++++++++
 checkpoint/objhash.c           |    1 +
 checkpoint/process.c           |    3 +
 checkpoint/restart.c           |    4 +
 fs/exec.c                      |    2 +-
 include/linux/checkpoint.h     |    7 +
 include/linux/checkpoint_hdr.h |    2 +-
 include/linux/mm.h             |   13 +
 mm/filemap.c                   |   19 ++
 mm/mmap.c                      |   23 ++-
 12 files changed, 614 insertions(+), 3 deletions(-)

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
diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 83ed047..9dd8e12 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -13,6 +13,7 @@
 
 #include <asm/desc.h>
 #include <asm/i387.h>
+#include <asm/elf.h>
 
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
@@ -560,3 +561,66 @@ int restore_read_header_arch(struct ckpt_ctx *ctx)
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
index d19d627..6a0dfaf 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -15,6 +15,9 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/file.h>
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
 #include <linux/pagemap.h>
 #include <linux/mm_types.h>
 #include <linux/proc_fs.h>
@@ -695,3 +698,472 @@ int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t)
 
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
+static int restore_read_page(struct ckpt_ctx *ctx, struct page *page, void *p)
+{
+	void *ptr;
+	int ret;
+
+	ret = ckpt_kread(ctx, p, PAGE_SIZE);
+	if (ret < 0)
+		return ret;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(ptr, p, PAGE_SIZE);
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
+	char *buf;
+	int i, ret = 0;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	down_read(&mm->mmap_sem);
+	list_for_each_entry_reverse(pgarr, &ctx->pgarr_list, list) {
+		vaddrs = pgarr->vaddrs;
+		for (i = 0; i < pgarr->nr_used; i++) {
+			struct page *page;
+
+			_ckpt_debug(CKPT_DPAGE, "got page %#lx\n", vaddrs[i]);
+			ret = get_user_pages(current, mm, vaddrs[i],
+					     1, 1, 1, &page, NULL);
+			if (ret < 0)
+				goto out;
+
+			ret = restore_read_page(ctx, page, buf);
+			page_cache_release(page);
+
+			if (ret < 0)
+				goto out;
+		}
+	}
+
+ out:
+	up_read(&mm->mmap_sem);
+	kfree(buf);
+	return 0;
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
+static int destroy_mm(struct mm_struct *mm)
+{
+	struct vm_area_struct *vmnext = mm->mmap;
+	struct vm_area_struct *vma;
+	int ret;
+
+	while (vmnext) {
+		vma = vmnext;
+		vmnext = vmnext->vm_next;
+		ret = do_munmap(mm, vma->vm_start, vma->vm_end-vma->vm_start);
+		if (ret < 0) {
+			pr_warning("c/r: failed do_munmap (%d)\n", ret);
+			return ret;
+		}
+	}
+	return 0;
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
+
+	ret = _ckpt_read_buffer(ctx, mm->saved_auxv, sizeof(mm->saved_auxv));
+	up_write(&mm->mmap_sem);
+	if (ret < 0)
+		goto out;
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
index 4c207c3..734be3a 100644
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
index 3d0eb36..1788a39 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -373,6 +373,9 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
 
+	ret = restore_obj_mm(ctx, h->mm_objref);
+	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
+
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 73db44a..6183074 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -373,11 +373,15 @@ int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
 static int check_kernel_const(struct ckpt_const *h)
 {
 	struct task_struct *tsk;
+	struct mm_struct *mm;
 	struct new_utsname *uts;
 
 	/* task */
 	if (h->task_comm_len != sizeof(tsk->comm))
 		return -EINVAL;
+	/* mm */
+	if (h->mm_saved_auxv_len != sizeof(mm->saved_auxv))
+		return -EINVAL;
 	/* uts */
 	if (h->uts_release_len != sizeof(uts->release))
 		return -EINVAL;
diff --git a/fs/exec.c b/fs/exec.c
index 172ceb6..c8436a7 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -695,7 +695,7 @@ int kernel_read(struct file *file, loff_t offset,
 
 EXPORT_SYMBOL(kernel_read);
 
-static int exec_mmap(struct mm_struct *mm)
+int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct * old_mm, *active_mm;
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 70d9506..cb13e8f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -136,6 +136,7 @@ extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
 extern int restore_cpu(struct ckpt_ctx *ctx);
+extern int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
 extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
@@ -176,9 +177,15 @@ extern int private_vma_checkpoint(struct ckpt_ctx *ctx,
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
index f29f87a..097d2e2 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -250,7 +250,7 @@ struct ckpt_hdr_mm {
 	__u64 arg_start, arg_end, env_start, env_end;
 } __attribute__((aligned(8)));
 
-/* vma subtypes */
+/* vma subtypes - index into restore_vma_dispatch[] */
 enum vma_type {
 	CKPT_VMA_IGNORE = 0,
 	CKPT_VMA_VDSO,		/* special vdso vma */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d5f9889..0d0c46b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1148,6 +1148,9 @@ extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
 extern unsigned long do_brk(unsigned long, unsigned long);
 
+/* fs/exec.c */
+extern int exec_mmap(struct mm_struct *mm);
+
 /* filemap.c */
 extern unsigned long page_unuse(struct page *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
@@ -1166,6 +1169,16 @@ extern int filemap_checkpoint(struct ckpt_ctx *, struct vm_area_struct *);
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
index 72ba805..ef7205b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1668,6 +1668,25 @@ int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 
 	return private_vma_checkpoint(ctx, vma, CKPT_VMA_FILE, vma_objref);
 }
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
 #endif /* CONFIG_CHECKPOINT */
 
 struct vm_operations_struct generic_file_vm_ops = {
diff --git a/mm/mmap.c b/mm/mmap.c
index 7415a61..3be4678 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2110,7 +2110,7 @@ void exit_mmap(struct mm_struct *mm)
 	tlb = tlb_gather_mmu(mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = vma ? unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL) : 0;
 	vm_unacct_memory(nr_accounted);
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
@@ -2269,6 +2269,14 @@ static void special_mapping_close(struct vm_area_struct *vma)
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
@@ -2290,6 +2298,19 @@ static int special_mapping_checkpoint(struct ckpt_ctx *ctx,
 
 	return generic_vma_checkpoint(ctx, vma, CKPT_VMA_VDSO, 0);
 }
+
+int special_mapping_restore(struct ckpt_ctx *ctx,
+			    struct mm_struct *mm,
+			    struct ckpt_hdr_vma *h)
+{
+	/*
+	 * FIX:
+	 * Currently, we only handle VDSO/vsyscall special handling.
+	 * Even that, is very basic - call arch_setup_additional_pages
+	 * requiring the same mapping (start address) as before.
+	 */
+	return arch_setup_additional_pages(NULL, h->vm_start, 0);
+}
 #endif /* CONFIG_CHECKPOINT */
 
 static struct vm_operations_struct special_mapping_vmops = {
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
