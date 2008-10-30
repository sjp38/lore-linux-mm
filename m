From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v8][PATCH 07/12] Restore memory address space
Date: Thu, 30 Oct 2008 09:51:10 -0400
Message-Id: <1225374675-22850-8-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
References: <1225374675-22850-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Restoring the memory address space begins with nuking the existing one
of the current process, and then reading the VMA state and contents.
Call do_mmap_pgoffset() for each VMA and then read in the data.

Changelog[v7]:
  - Fix argument given to kunmap_atomic() in memory dump/restore

Changelog[v6]:
  - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
    (even though it's not really needed)

Changelog[v5]:
  - Improve memory restore code (following Dave Hansen's comments)
  - Change dump format (and code) to allow chunks of <vaddrs, pages>
    instead of one long list of each
  - Memory restore now maps user pages explicitly to copy data into them,
    instead of reading directly to user space; got rid of mprotect_fixup()

Changelog[v4]:
  - Use standard list_... for cr_pgarr


Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 arch/x86/mm/restart.c            |   64 ++++++-
 checkpoint/Makefile              |    2 +-
 checkpoint/checkpoint_arch.h     |    2 +
 checkpoint/checkpoint_mem.h      |    5 +
 checkpoint/restart.c             |   42 ++++
 checkpoint/rstr_mem.c            |  384 ++++++++++++++++++++++++++++++++++++++
 include/asm-x86/checkpoint_hdr.h |    4 +
 include/linux/checkpoint.h       |    3 +
 8 files changed, 503 insertions(+), 3 deletions(-)
 create mode 100644 checkpoint/rstr_mem.c

diff --git a/arch/x86/mm/restart.c b/arch/x86/mm/restart.c
index bc2a502..aeae29f 100644
--- a/arch/x86/mm/restart.c
+++ b/arch/x86/mm/restart.c
@@ -53,8 +53,10 @@ int cr_read_thread(struct cr_ctx *ctx)
 
 		size = sizeof(*desc) * GDT_ENTRY_TLS_ENTRIES;
 		desc = kmalloc(size, GFP_KERNEL);
-		if (!desc)
-			return -ENOMEM;
+		if (!desc) {
+			ret = -ENOMEM;
+			goto out;
+		}
 
 		ret = cr_kread(ctx, desc, size);
 		if (ret >= 0) {
@@ -193,3 +195,61 @@ int cr_read_cpu(struct cr_ctx *ctx)
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
 }
+
+int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int parent)
+{
+	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	int n, rparent, ret = -EINVAL;
+
+	rparent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM_CONTEXT);
+	cr_debug("parent %d rparent %d nldt %d\n", parent, rparent, hh->nldt);
+	if (rparent < 0) {
+		ret = rparent;
+		goto out;
+	}
+	if (rparent != parent)
+		goto out;
+
+	if (hh->nldt < 0 || hh->ldt_entry_size != LDT_ENTRY_SIZE)
+		goto out;
+
+	/*
+	 * to utilize the syscall modify_ldt() we first convert the data
+	 * in the checkpoint image from 'struct desc_struct' to 'struct
+	 * user_desc' with reverse logic of include/asm/desc.h:fill_ldt()
+	 */
+
+	for (n = 0; n < hh->nldt; n++) {
+		struct user_desc info;
+		struct desc_struct desc;
+		mm_segment_t old_fs;
+
+		ret = cr_kread(ctx, &desc, LDT_ENTRY_SIZE);
+		if (ret < 0)
+			goto out;
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
+			goto out;
+	}
+
+	ret = 0;
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 3a0df6d..ac35033 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_CHECKPOINT_RESTART) += sys.o checkpoint.o restart.o \
-		ckpt_mem.o
+		ckpt_mem.o rstr_mem.o
diff --git a/checkpoint/checkpoint_arch.h b/checkpoint/checkpoint_arch.h
index 7da4ad0..018a72e 100644
--- a/checkpoint/checkpoint_arch.h
+++ b/checkpoint/checkpoint_arch.h
@@ -7,3 +7,5 @@ extern int cr_write_mm_context(struct cr_ctx *ctx,
 
 extern int cr_read_thread(struct cr_ctx *ctx);
 extern int cr_read_cpu(struct cr_ctx *ctx);
+extern int cr_read_mm_context(struct cr_ctx *ctx,
+			      struct mm_struct *mm, int parent);
diff --git a/checkpoint/checkpoint_mem.h b/checkpoint/checkpoint_mem.h
index 85546f4..85a5cf3 100644
--- a/checkpoint/checkpoint_mem.h
+++ b/checkpoint/checkpoint_mem.h
@@ -38,4 +38,9 @@ static inline int cr_pgarr_is_full(struct cr_pgarr *pgarr)
 	return (pgarr->nr_used == CR_PGARR_TOTAL);
 }
 
+static inline int cr_pgarr_nr_free(struct cr_pgarr *pgarr)
+{
+	return CR_PGARR_TOTAL - pgarr->nr_used;
+}
+
 #endif /* _CHECKPOINT_CKPT_MEM_H_ */
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 766e381..f4d87ba 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -78,6 +78,44 @@ int cr_read_string(struct cr_ctx *ctx, void *str, int len)
 	return cr_read_obj_type(ctx, str, len, CR_HDR_STRING);
 }
 
+/**
+ * cr_read_fname - read a file name
+ * @ctx: checkpoint context
+ * @fname: buffer
+ * @n: buffer length
+ */
+int cr_read_fname(struct cr_ctx *ctx, void *fname, int flen)
+{
+	return cr_read_obj_type(ctx, fname, flen, CR_HDR_FNAME);
+}
+
+/**
+ * cr_read_open_fname - read a file name and open a file
+ * @ctx: checkpoint context
+ * @flags: file flags
+ * @mode: file mode
+ */
+struct file *cr_read_open_fname(struct cr_ctx *ctx, int flags, int mode)
+{
+	struct file *file;
+	char *fname;
+	int ret;
+
+	fname = kmalloc(PATH_MAX, GFP_KERNEL);
+	if (!fname)
+		return ERR_PTR(-ENOMEM);
+
+	ret = cr_read_fname(ctx, fname, PATH_MAX);
+	cr_debug("fname '%s' flags %#x mode %#x\n", fname, flags, mode);
+	if (ret >= 0)
+		file = filp_open(fname, flags, mode);
+	else
+		file = ERR_PTR(ret);
+
+	kfree(fname);
+	return file;
+}
+
 /* read the checkpoint header */
 static int cr_read_head(struct cr_ctx *ctx)
 {
@@ -177,6 +215,10 @@ static int cr_read_task(struct cr_ctx *ctx)
 	cr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = cr_read_mm(ctx);
+	cr_debug("memory: ret %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = cr_read_thread(ctx);
 	cr_debug("thread: ret %d\n", ret);
 	if (ret < 0)
diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
new file mode 100644
index 0000000..062e56e
--- /dev/null
+++ b/checkpoint/rstr_mem.c
@@ -0,0 +1,384 @@
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
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/fcntl.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+#include <linux/mm_types.h>
+#include <linux/mman.h>
+#include <linux/mm.h>
+#include <linux/err.h>
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+#include "checkpoint_arch.h"
+#include "checkpoint_mem.h"
+
+/*
+ * Unlike checkpoint, restart is executed in the context of each restarting
+ * process: vma regions are restored via a call to mmap(), and the data is
+ * read into the address space of the current process.
+ */
+
+
+/**
+ * cr_read_pages_vaddrs - read addresses of pages to page-array chain
+ * @ctx - restart context
+ * @nr_pages - number of address to read
+ */
+static int cr_read_pages_vaddrs(struct cr_ctx *ctx, unsigned long nr_pages)
+{
+	struct cr_pgarr *pgarr;
+	unsigned long *vaddrp;
+	int nr, ret;
+
+	while (nr_pages) {
+		pgarr = cr_pgarr_current(ctx);
+		if (!pgarr)
+			return -ENOMEM;
+		nr = cr_pgarr_nr_free(pgarr);
+		if (nr > nr_pages)
+			nr = nr_pages;
+		vaddrp = &pgarr->vaddrs[pgarr->nr_used];
+		ret = cr_kread(ctx, vaddrp, nr * sizeof(unsigned long));
+		if (ret < 0)
+			return ret;
+		pgarr->nr_used += nr;
+		nr_pages -= nr;
+	}
+	return 0;
+}
+
+static int cr_page_read(struct cr_ctx *ctx, struct page *page, char *buf)
+{
+	void *ptr;
+	int ret;
+
+	ret = cr_kread(ctx, buf, PAGE_SIZE);
+	if (ret < 0)
+		return ret;
+
+	ptr = kmap_atomic(page, KM_USER1);
+	memcpy(ptr, buf, PAGE_SIZE);
+	kunmap_atomic(ptr, KM_USER1);
+
+	return 0;
+}
+
+/**
+ * cr_read_pages_contents - read in data of pages in page-array chain
+ * @ctx - restart context
+ */
+static int cr_read_pages_contents(struct cr_ctx *ctx)
+{
+	struct mm_struct *mm = current->mm;
+	struct cr_pgarr *pgarr;
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
+			ret = get_user_pages(current, mm, vaddrs[i],
+					     1, 1, 1, &page, NULL);
+			if (ret < 0)
+				goto out;
+
+			ret = cr_page_read(ctx, page, buf);
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
+ * cr_read_private_vma_contents - restore contents of a VMA with private memory
+ * @ctx - restart context
+ *
+ * Reads a header that specifies how many pages will follow, then reads
+ * a list of virtual addresses into ctx->pgarr_list page-array chain,
+ * followed by the actual contents of the corresponding pages. Iterates
+ * these steps until reaching a header specifying "0" pages, which marks
+ * the end of the contents.
+ */
+static int cr_read_private_vma_contents(struct cr_ctx *ctx)
+{
+	struct cr_hdr_pgarr *hh;
+	unsigned long nr_pages;
+	int parent, ret = 0;
+
+	while (1) {
+		hh = cr_hbuf_get(ctx, sizeof(*hh));
+		parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_PGARR);
+		if (parent != 0) {
+			if (parent < 0)
+				ret = parent;
+			else
+				ret = -EINVAL;
+			cr_hbuf_put(ctx, sizeof(*hh));
+			break;
+		}
+
+		cr_debug("nr_pages %ld\n", (unsigned long) hh->nr_pages);
+
+		nr_pages = hh->nr_pages;
+		cr_hbuf_put(ctx, sizeof(*hh));
+
+		if (!nr_pages)
+			break;
+
+		ret = cr_read_pages_vaddrs(ctx, nr_pages);
+		if (ret < 0)
+			break;
+		ret = cr_read_pages_contents(ctx);
+		if (ret < 0)
+			break;
+		cr_pgarr_reset_all(ctx);
+	}
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
+	unsigned long vm_size, vm_start, vm_flags, vm_prot, vm_pgoff;
+	unsigned long addr;
+	struct file *file = NULL;
+	int parent, ret = -EINVAL;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_VMA);
+	if (parent < 0) {
+		ret = parent;
+		goto err;
+	} else if (parent != 0)
+		goto err;
+
+	cr_debug("vma %#lx-%#lx type %d\n", (unsigned long) hh->vm_start,
+		 (unsigned long) hh->vm_end, (int) hh->vma_type);
+
+	if (hh->vm_end < hh->vm_start)
+		goto err;
+
+	vm_start = hh->vm_start;
+	vm_pgoff = hh->vm_pgoff;
+	vm_size = hh->vm_end - hh->vm_start;
+	vm_prot = cr_calc_map_prot_bits(hh->vm_flags);
+	vm_flags = cr_calc_map_flags_bits(hh->vm_flags);
+
+	switch (hh->vma_type) {
+
+	case CR_VMA_ANON:		/* anonymous private mapping */
+		if (vm_flags & VM_SHARED)
+			goto err;
+		/*
+		 * vm_pgoff for anonymous mapping is the "global" page
+		 * offset (namely from addr 0x0), so we force a zero
+		 */
+		vm_pgoff = 0;
+		break;
+
+	case CR_VMA_FILE:		/* private mapping from a file */
+		if (vm_flags & VM_SHARED)
+			goto err;
+		/*
+		 * for private mapping using 'read-only' is sufficient
+		 */
+		file = cr_read_open_fname(ctx, O_RDONLY, 0);
+		if (IS_ERR(file)) {
+			ret = PTR_ERR(file);
+			goto err;
+		}
+		break;
+
+	default:
+		goto err;
+
+	}
+
+	cr_hbuf_put(ctx, sizeof(*hh));
+
+	down_write(&mm->mmap_sem);
+	addr = do_mmap_pgoff(file, vm_start, vm_size,
+			     vm_prot, vm_flags, vm_pgoff);
+	up_write(&mm->mmap_sem);
+	cr_debug("size %#lx prot %#lx flag %#lx pgoff %#lx => %#lx\n",
+		 vm_size, vm_prot, vm_flags, vm_pgoff, addr);
+
+	/* the file (if opened) is now referenced by the vma */
+	if (file)
+		filp_close(file, NULL);
+
+	if (IS_ERR((void *) addr))
+		return PTR_ERR((void *) addr);
+
+	/*
+	 * CR_VMA_ANON: read in memory as is
+	 * CR_VMA_FILE: read in memory as is
+	 * (more to follow ...)
+	 */
+
+	switch (hh->vma_type) {
+	case CR_VMA_ANON:
+	case CR_VMA_FILE:
+		/* standard case: read the data into the memory */
+		ret = cr_read_private_vma_contents(ctx);
+		break;
+	}
+
+	if (ret < 0)
+		return ret;
+
+	cr_debug("vma retval %d\n", ret);
+	return 0;
+
+ err:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
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
+		if (ret < 0) {
+			pr_debug("C/R: restart failed do_munmap (%d)\n", ret);
+			return ret;
+		}
+	}
+	return 0;
+}
+
+int cr_read_mm(struct cr_ctx *ctx)
+{
+	struct cr_hdr_mm *hh = cr_hbuf_get(ctx, sizeof(*hh));
+	struct mm_struct *mm;
+	int nr, parent, ret;
+
+	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_MM);
+	if (parent < 0) {
+		ret = parent;
+		goto out;
+	}
+
+	ret = -EINVAL;
+#if 0	/* activate when containers are used */
+	if (parent != task_pid_vnr(current))
+		goto out;
+#endif
+	cr_debug("map_count %d\n", hh->map_count);
+
+	/* XXX need more sanity checks */
+	if (hh->start_code > hh->end_code ||
+	    hh->start_data > hh->end_data || hh->map_count < 0)
+		goto out;
+
+	mm = current->mm;
+
+	/* point of no return -- destruct current mm */
+	down_write(&mm->mmap_sem);
+	ret = cr_destroy_mm(mm);
+	if (ret < 0) {
+		up_write(&mm->mmap_sem);
+		goto out;
+	}
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
+	up_write(&mm->mmap_sem);
+
+	/* FIX: need also mm->flags */
+
+	for (nr = hh->map_count; nr; nr--) {
+		ret = cr_read_vma(ctx, mm);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = cr_read_mm_context(ctx, mm, hh->objref);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
diff --git a/include/asm-x86/checkpoint_hdr.h b/include/asm-x86/checkpoint_hdr.h
index 6bc61ac..f8eee6a 100644
--- a/include/asm-x86/checkpoint_hdr.h
+++ b/include/asm-x86/checkpoint_hdr.h
@@ -74,4 +74,8 @@ struct cr_hdr_mm_context {
 	__s16 nldt;
 } __attribute__((aligned(8)));
 
+
+/* misc prototypes from kernel (not defined elsewhere) */
+asmlinkage int sys_modify_ldt(int func, void __user *ptr, unsigned long bytecount);
+
 #endif /* __ASM_X86_CKPT_HDR__H */
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 70ef22f..3563bce 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -55,6 +55,9 @@ extern int cr_write_fname(struct cr_ctx *ctx,
 extern int cr_read_obj(struct cr_ctx *ctx, struct cr_hdr *h, void *buf, int n);
 extern int cr_read_obj_type(struct cr_ctx *ctx, void *buf, int n, int type);
 extern int cr_read_string(struct cr_ctx *ctx, void *str, int len);
+extern int cr_read_fname(struct cr_ctx *ctx, void *fname, int n);
+extern struct file *cr_read_open_fname(struct cr_ctx *ctx,
+				       int flags, int mode);
 
 extern int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t);
 extern int cr_read_mm(struct cr_ctx *ctx);
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
