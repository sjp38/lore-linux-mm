Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 510FB6B0088
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 11:15:44 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH 17/19] c/r: dump memory address space (private memory)
Date: Tue, 14 Dec 2010 08:15:05 -0800
Message-Id: <1292343307-7870-17-git-send-email-danms@us.ibm.com>
In-Reply-To: <1292343307-7870-1-git-send-email-danms@us.ibm.com>
References: <1292343307-7870-1-git-send-email-danms@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: danms@us.ibm.com
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

From: Oren Laadan <orenl@cs.columbia.edu>

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

Restoring the memory address space begins with nuking the existing one
of the current process, and then reading the vma state and contents.
Call do_mmap_pgoffset() for each vma and then read in the data.

Changelog[37rc2]:
  - [Dan Smith] Stripped out collect bits
Changelog[v21]:
  - Do not include checkpoint_hdr.h explicitly
  - Replace __initcall() with late_initcall()
  - Merge mm dump/restore into a single patch
  - Put file_ops->checkpoint under CONFIG_CHECKPOINT
Changelog[v20]:
  - Only use arch_setup_additional_pages() if supported by arch
Changelog[v19]:
  - [Serge Hallyn] Checkpoint saved_auxv as u64s
  - [Serge Hallyn] do_munmap(): remove unused local vars
Changelog[v19-rc3]:
  - Separate __get_dirty_page() into its own patch
  - Export filemap_checkpoint()
  - [Serge Hallyn] Disallow checkpoint of tasks with aio requests
  - Fix compilation failure when !CONFIG_CHEKCPOINT (regression)
  - [Serge Hallyn] move destroy_mm into mmap.c and remove size check
  - [Serge Hallyn] fill vdso (syscall32_setup_pages) for TIF_IA32/x86_64
  - Do not hold mmap_sem when reading memory pages on restart
Changelog[v19-rc2]:
  - Expose page write functions
  - Take mmap_sem() around vma_fill_pgarr() (fix regression)
  - Move consider_private_page() to mm/memory.c:__get_dirty_page()
  - Expose page write functions
  - [Serge Hallyn] Fix return value of read_pages_contents()
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
  - Tighten checks on supported vma to checkpoint or restart
Changelog[v17]:
  - Only collect sub-objects of mm_struct once
  - Save mm->{flags,def_flags,saved_auxv}
  - Restore mm->{flags,def_flags,saved_auxv}
  - Fix bogus warning in do_restore_mm()
Changelog[v16]:
  - Precede vaddrs/pages with a buffer header
  - Checkpoint mm->exe_file
  - Handle shared task->mm
  - Restore mm->exe_file
Changelog[v14]:
  - Modify the ops->checkpoint method to be much more powerful
  - Improve support for VDSO (with special_mapping checkpoint callback)
  - Save new field 'vdso' in mm_context
  - Revert change to pr_debug(), back to ckpt_debug()
  - Check whether calls to ckpt_hbuf_get() fail
  - Discard field 'h->parent'
  - Introduce per vma-type restore() function
  - Merge restart code into same file as checkpoint (memory.c)
  - Compare saved 'vdso' field of mm_context with current value
Changelog[v13]:
  - pgprot_t is an abstract type; use the proper accessor (fix for
    64-bit powerpc (Nathan Lynch <ntl@pobox.com>)
  - Avoid access to hh->vma_type after the header is freed (restart)
  - Test for no vma's in exit_mmap() before calling unmap_vma() (or
    it may crash if restart fails after having removed all vma's)
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
  - Memory restore now maps user pages explicitly to copy data into them,
    instead of reading directly to user space; got rid of mprotect_fixup()
Changelog[v4]:
  - Use standard list_... for ckpt_pgarr

Cc: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 arch/x86/include/asm/checkpoint_hdr.h |    9 +
 arch/x86/include/asm/ldt.h            |    7 +
 arch/x86/kernel/checkpoint.c          |   95 +++
 fs/aio.c                              |   17 +
 fs/exec.c                             |    2 +-
 include/linux/aio.h                   |    2 +
 include/linux/checkpoint.h            |   34 +
 include/linux/checkpoint_hdr.h        |   62 ++
 include/linux/checkpoint_types.h      |   21 +
 include/linux/mm.h                    |   19 +
 kernel/checkpoint/checkpoint.c        |    2 +
 kernel/checkpoint/process.c           |   12 +
 kernel/checkpoint/restart.c           |    3 +
 kernel/checkpoint/sys.c               |   17 +
 mm/Makefile                           |    6 +
 mm/checkpoint.c                       | 1159 +++++++++++++++++++++++++++++++++
 mm/filemap.c                          |   45 ++
 mm/mmap.c                             |  101 +++-
 18 files changed, 1607 insertions(+), 6 deletions(-)
 create mode 100644 mm/checkpoint.c

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index e6cfc99..b41854c 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -44,6 +44,8 @@
 enum {
 	CKPT_HDR_CPU_FPU = 201,
 #define CKPT_HDR_CPU_FPU CKPT_HDR_CPU_FPU
+	CKPT_HDR_MM_CONTEXT_LDT,
+#define CKPT_HDR_MM_CONTEXT_LDT CKPT_HDR_MM_CONTEXT_LDT
 };
 
 struct ckpt_hdr_header_arch {
@@ -109,4 +111,11 @@ struct ckpt_hdr_cpu {
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
index 38018cc..d446039 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -13,6 +13,7 @@
 
 #include <asm/desc.h>
 #include <asm/i387.h>
+#include <asm/elf.h>
 
 #include <linux/checkpoint.h>
 
@@ -206,6 +207,37 @@ int checkpoint_write_header_arch(struct ckpt_ctx *ctx)
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
@@ -416,3 +448,66 @@ int restore_read_header_arch(struct ckpt_ctx *ctx)
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
diff --git a/fs/aio.c b/fs/aio.c
index 8c8f6c5..7d4f0d9 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1847,3 +1847,20 @@ SYSCALL_DEFINE5(io_getevents, aio_context_t, ctx_id,
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
diff --git a/fs/exec.c b/fs/exec.c
index 5d7a67b..95ae8de 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -796,7 +796,7 @@ ssize_t kernel_write(struct file *file, loff_t offset,
 
 EXPORT_SYMBOL(kernel_write);
 
-static int exec_mmap(struct mm_struct *mm)
+int exec_mmap(struct mm_struct *mm)
 {
 	struct task_struct *tsk;
 	struct mm_struct * old_mm, *active_mm;
diff --git a/include/linux/aio.h b/include/linux/aio.h
index 7a8db41..1ee35a7 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -214,6 +214,7 @@ struct mm_struct;
 extern void exit_aio(struct mm_struct *mm);
 extern long do_io_submit(aio_context_t ctx_id, long nr,
 			 struct iocb __user *__user *iocbpp, bool compat);
+extern int check_for_outstanding_aio(struct mm_struct *mm);
 #else
 static inline ssize_t wait_on_sync_kiocb(struct kiocb *iocb) { return 0; }
 static inline int aio_put_req(struct kiocb *iocb) { return 0; }
@@ -224,6 +225,7 @@ static inline void exit_aio(struct mm_struct *mm) { }
 static inline long do_io_submit(aio_context_t ctx_id, long nr,
 				struct iocb __user * __user *iocbpp,
 				bool compat) { return 0; }
+static inline int check_for_outstanding_aio(struct mm_struct *mm) { return 0; }
 #endif /* CONFIG_AIO */
 
 static inline struct kiocb *list_kiocb(struct list_head *h)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8c7bc87..48b45a8 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -66,6 +66,9 @@ extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
 extern char *ckpt_fill_fname(struct path *path, struct path *root,
 			     char *buf, int *len);
 
+extern int checkpoint_dump_page(struct ckpt_ctx *ctx, struct page *page);
+extern int restore_read_page(struct ckpt_ctx *ctx, struct page *page);
+
 /* ckpt kflags */
 #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
 	set_bit(__kflag##_BIT, &(__ctx)->kflags)
@@ -122,10 +125,12 @@ extern int restore_task(struct ckpt_ctx *ctx);
 extern int checkpoint_write_header_arch(struct ckpt_ctx *ctx);
 extern int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t);
 extern int checkpoint_cpu(struct ckpt_ctx *ctx, struct task_struct *t);
+extern int checkpoint_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
 extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
 extern int restore_cpu(struct ckpt_ctx *ctx);
+extern int restore_mm_context(struct ckpt_ctx *ctx, struct mm_struct *mm);
 
 extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
 				    struct task_struct *t);
@@ -149,6 +154,33 @@ extern int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
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
+extern int restore_obj_mm(struct ckpt_ctx *ctx, int mm_objref);
+
+extern int ckpt_collect_mm(struct ckpt_ctx *ctx, struct task_struct *t);
+
+extern int private_vma_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
+			       struct file *file, struct ckpt_hdr_vma *h);
+
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
@@ -160,6 +192,8 @@ static inline int ckpt_validate_errno(int errno)
 #define CKPT_DRW	0x4		/* image read/write */
 #define CKPT_DOBJ	0x8		/* shared objects */
 #define CKPT_DFILE	0x10		/* files and filesystem */
+#define CKPT_DMEM	0x20		/* memory state */
+#define CKPT_DPAGE	0x40		/* memory pages */
 
 #define CKPT_DDEFAULT	0xffff		/* default debug level */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 2090d73..869ce7c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -94,6 +94,15 @@ enum {
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
 
@@ -122,6 +131,8 @@ enum obj_type {
 #define CKPT_OBJ_FILE_TABLE CKPT_OBJ_FILE_TABLE
 	CKPT_OBJ_FILE,
 #define CKPT_OBJ_FILE CKPT_OBJ_FILE
+	CKPT_OBJ_MM,
+#define CKPT_OBJ_MM CKPT_OBJ_MM
 	CKPT_OBJ_MAX
 #define CKPT_OBJ_MAX CKPT_OBJ_MAX
 };
@@ -130,6 +141,8 @@ enum obj_type {
 struct ckpt_const {
 	/* task */
 	__u16 task_comm_len;
+	/* mm */
+	__u16 at_vector_size;
 	/* uts */
 	__u16 uts_release_len;
 	__u16 uts_version_len;
@@ -188,6 +201,7 @@ struct ckpt_hdr_task {
 struct ckpt_hdr_task_objs {
 	struct ckpt_hdr h;
 	__s32 files_objref;
+	__s32 mm_objref;
 } __attribute__((aligned(8)));
 
 /* restart blocks */
@@ -260,4 +274,52 @@ struct ckpt_hdr_file_generic {
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
+/* vma subtypes - index into restore_vma_dispatch[] */
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
index 56f90de..6f6dd36 100644
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
 
@@ -46,6 +48,25 @@ struct ckpt_ctx {
 
 	int errno;		/* errno that caused failure */
 
+	struct completion errno_sync;	/* protect errno setting */
+
+	struct list_head pgarr_list;	/* page array to dump VMA contents */
+	struct list_head pgarr_pool;	/* pool of empty page arrays chain */
+
+	void *scratch_page;             /* scratch buffer for page I/O */
+
+	/* [multi-process checkpoint] */
+	struct task_struct **tasks_arr; /* array of all tasks [checkpoint] */
+	int nr_tasks;                   /* size of tasks array */
+
+	/* [multi-process restart] */
+	struct ckpt_pids *pids_arr;	/* array of all pids [restart] */
+	int nr_pids;			/* size of pids array */
+	atomic_t nr_total;		/* total tasks count */
+	int active_pid;			/* (next) position in pids array */
+	struct completion complete;	/* container root and other tasks on */
+	wait_queue_head_t waitq;	/* start, end, and restart ordering */
+
 #define CKPT_MSG_LEN 1024
 	char fmt[CKPT_MSG_LEN];
 	char msg[CKPT_MSG_LEN];
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2211a15..bde9d6e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1324,9 +1324,13 @@ out:
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
@@ -1336,10 +1340,25 @@ extern void truncate_inode_pages_range(struct address_space *,
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
diff --git a/kernel/checkpoint/checkpoint.c b/kernel/checkpoint/checkpoint.c
index 158345d..0a44d13 100644
--- a/kernel/checkpoint/checkpoint.c
+++ b/kernel/checkpoint/checkpoint.c
@@ -109,6 +109,8 @@ static void fill_kernel_const(struct ckpt_const *h)
 
 	/* task */
 	h->task_comm_len = sizeof(tsk->comm);
+	/* mm->saved_auxv size */
+	h->at_vector_size = AT_VECTOR_SIZE;
 	/* uts */
 	h->uts_release_len = sizeof(uts->release);
 	h->uts_version_len = sizeof(uts->version);
diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
index b766dd8..ba4a8e9 100644
--- a/kernel/checkpoint/process.c
+++ b/kernel/checkpoint/process.c
@@ -51,6 +51,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	struct ckpt_hdr_task_objs *h;
 	int files_objref;
+	int mm_objref;
 	int ret;
 
 	files_objref = checkpoint_obj_file_table(ctx, t);
@@ -60,10 +61,18 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
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
 
@@ -137,6 +146,9 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
 	ret = restore_obj_file_table(ctx, h->files_objref);
 	ckpt_debug("file_table: ret %d (%p)\n", ret, current->files);
 
+	ret = restore_obj_mm(ctx, h->mm_objref);
+	ckpt_debug("mm: ret %d (%p)\n", ret, current->mm);
+
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 25cc5e9..c4c4aaa 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -400,6 +400,9 @@ static int check_kernel_const(struct ckpt_const *h)
 	/* task */
 	if (h->task_comm_len != sizeof(tsk->comm))
 		return -EINVAL;
+	/* mm->saved_auxv size */
+	if (h->at_vector_size != AT_VECTOR_SIZE)
+		return -EINVAL;
 	/* uts */
 	if (h->uts_release_len != sizeof(uts->release))
 		return -EINVAL;
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index be915b5..de3db0c 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -172,6 +172,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 
 	ckpt_obj_hash_free(ctx);
 	path_put(&ctx->root_fs_path);
+	ckpt_pgarr_free(ctx);
 
 	if (ctx->root_nsproxy)
 		put_nsproxy(ctx->root_nsproxy);
@@ -180,6 +181,10 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
 	if (ctx->root_freezer)
 		put_task_struct(ctx->root_freezer);
 
+	free_page((unsigned long) ctx->scratch_page);
+
+	kfree(ctx->pids_arr);
+
 	kfree(ctx);
 }
 
@@ -196,6 +201,14 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	ctx->uflags = uflags;
 	ctx->kflags = kflags;
 
+	atomic_set(&ctx->refcount, 0);
+	INIT_LIST_HEAD(&ctx->pgarr_list);
+	INIT_LIST_HEAD(&ctx->pgarr_pool);
+	init_waitqueue_head(&ctx->waitq);
+	init_completion(&ctx->complete);
+
+	init_completion(&ctx->errno_sync);
+
 	mutex_init(&ctx->msg_mutex);
 
 	err = -EBADF;
@@ -217,6 +230,10 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 	if (!ctx->files_deferq)
 		goto err;
 
+	ctx->scratch_page = (void *) __get_free_page(GFP_KERNEL);
+	if (!ctx->scratch_page)
+		goto err;
+
 	atomic_inc(&ctx->refcount);
 	return ctx;
  err:
diff --git a/mm/Makefile b/mm/Makefile
index f73f75a..effb215 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -36,6 +36,12 @@ obj-$(CONFIG_FAILSLAB) += failslab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
+ifdef CONFIG_SMP
+obj-y += percpu.o
+else
+obj-y += percpu_up.o
+endif
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
diff --git a/mm/checkpoint.c b/mm/checkpoint.c
new file mode 100644
index 0000000..8ff6ea1
--- /dev/null
+++ b/mm/checkpoint.c
@@ -0,0 +1,1159 @@
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
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+#include <linux/proc_fs.h>
+#include <linux/checkpoint.h>
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
+		cnt = vma_fill_pgarr(ctx, vma, &addr);
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
+static int checkpoint_mm(struct ckpt_ctx *ctx, void *ptr)
+{
+	struct mm_struct *mm = ptr;
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
+static void *restore_mm(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_mm *h;
+	struct mm_struct *mm = NULL;
+	struct file *file;
+	unsigned int nr;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_MM);
+	if (IS_ERR(h))
+		return (void *) h;
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
+	return (void *)mm;
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
+
+/*
+ * mm-related checkpoint objects
+ */
+
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
+/* mm object */
+static const struct ckpt_obj_ops ckpt_obj_mm_ops = {
+	.obj_name = "MM",
+	.obj_type = CKPT_OBJ_MM,
+	.ref_drop = obj_mm_drop,
+	.ref_grab = obj_mm_grab,
+	.checkpoint = checkpoint_mm,
+	.restore = restore_mm,
+};
+
+static int __init checkpoint_register_mm(void)
+{
+	return register_checkpoint_obj(&ckpt_obj_mm_ops);
+}
+late_initcall(checkpoint_register_mm);
diff --git a/mm/filemap.c b/mm/filemap.c
index ea89840..ee9281e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -34,6 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <linux/checkpoint.h>
 #include "internal.h"
 
 /*
@@ -1644,8 +1645,52 @@ page_not_uptodate:
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
+#endif
+
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+#ifdef CONFIG_CHECKPOINT
+	.checkpoint	= filemap_checkpoint,
+#endif
 };
 
 /* This is used for a general mmap of a disk file */
diff --git a/mm/mmap.c b/mm/mmap.c
index b179abb..48e10af 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -29,6 +29,7 @@
 #include <linux/mmu_notifier.h>
 #include <linux/perf_event.h>
 #include <linux/audit.h>
+#include <linux/checkpoint.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2038,14 +2039,11 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
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
 
@@ -2119,8 +2117,39 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
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
@@ -2278,7 +2307,7 @@ void exit_mmap(struct mm_struct *mm)
 	tlb = tlb_gather_mmu(mm, 1);
 	/* update_hiwater_rss(mm) here? but nobody should be looking */
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
+	end = vma ? unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL) : 0;
 	vm_unacct_memory(nr_accounted);
 
 	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
@@ -2444,9 +2473,71 @@ static void special_mapping_close(struct vm_area_struct *vma)
 {
 }
 
+#ifdef CONFIG_CHECKPOINT
+/*
+ * FIX:
+ *   - checkpoint vdso pages (once per distinct vdso is enough)
+ *   - check for compatilibility between saved and current vdso
+ *   - accommodate for dynamic kernel data in vdso page
+ *
+ * Current, we require COMPAT_VDSO which somewhat mitigates the issue
+ */
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
+#endif
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
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
