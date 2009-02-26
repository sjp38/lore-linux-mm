Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EF7526B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 17:24:44 -0500 (EST)
Received: by fxm18 with SMTP id 18so819290fxm.38
        for <linux-mm@kvack.org>; Thu, 26 Feb 2009 14:24:32 -0800 (PST)
Date: Fri, 27 Feb 2009 01:31:12 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090226223112.GA2939@x200.localdomain>
References: <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226162755.GB1456@x200.localdomain> <20090226173302.GB29439@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090226173302.GB29439@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 26, 2009 at 06:33:02PM +0100, Ingo Molnar wrote:
> 
> * Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > Regarding interactions of C/R with other code:
> > 
> > 1. trivia
> > 1a. field in some datastructure is removed
> > 
> > 	technically, compilation breaks
> > 
> > 	Need to decide what to do -- from trivial compile fix
> > 	by removing code to ignoring some fields in dump image.
> > 
> > 1b. field is added
> > 
> > 	This is likely to happen silently, so maintainers
> > 	will have to keep an eye on critical data structures
> > 	and general big changes in core kernel.
> > 
> > 	Need to decide what to do with new field --
> > 	anything from 'doesn't matter' to 'yeah, needs C/R part'
> > 	with dump format change.
> > 
> > 2. non-trivia
> > 2a. standalone subsystem added (say, network protocol)
> > 
> >     If submitter sends C/R part -- excellent.
> >     If he doesn't, well, don't forget to add tiny bit of check
> > 	and abort if said subsystem is in use.
> > 
> > 2b. massacre inside some subsystem (say, struct cred introduction)
> > 
> > 	Likely, C/R non-trivially breaks both in compilation and
> > 	in working, requires non-trivial changes in algorithms and in
> > 	C/R dump image.
> > 
> > For some very core data structures dump file images should be made
> > fatter than needed to more future-proof, like
> > a) statistics in u64 regardless of in-kernel width.
> > b) ->vm_flags in image should be at least u64 and bits made append-only
> > 	so dump format would survive flags addition, removal and
> > 	renumbering.
> > and so on.
> > 
> > 
> > 
> > So I guess, at first C/R maintainers will take care of all of 
> > these issues with default policy being 'return -E, implement 
> > C/R later', but, ideally, C/R will have same rights as other 
> > kernel subsystem, so people will make non-trivial changes in 
> > C/R as they make their own non-trivial changes.
> > 
> > If last statement isn't acceptable, in-kernel C/R is likely 
> > doomed from the start (especially given lack of in-kernel 
> > testsuite).
> 
> Well, given the fact that OpenVZ has followed such upstream 
> changes for years successfully, there's precedent that it's 
> possible to do it and stay sane.
> 
> If C/R is bitrotting will it be blamed on the maintainer who 
> broke it, or on C/R maintainers?

Eventually, I hope, on patch submitter. In reality, people will have
little intuition with C/R so telling them to fix it is not right.

> Do we have a good, fast and thin vector along which we can quickly
> tag Kconfig spaces (or even runtime flags) that are known
> (or discovered) to be C/R unsafe?

Good -- yes, fast -- yes, Kconfig -- no, because config option turned on
doesn't application uses it.

See cr_dump_cred(), cr_check_cred(), cr_check_* for what is easy to do
to prevent C/R and invisible breakage.

See check in cr_collect_mm() where refcounts are compared to prevent
C/R where root cause is unknown.

> Is there any automated test that could discover C/R breakage via 
> brute force?

So far I'm relying on BUILD_BUG_ON(), but I probably don't understand
what you're asking.

> All that matters in such cases is to get the "you  broke stuff"
> information as soon as possible. If it comes at an early stage
> developers can generally just fix stuff. If it comes in late,
> close to some release, people become more argumentative and might
> attack C/R instead of fixing the code.

I hope for 'make test' but this is unrealistic right now
(read: lack of manpower :-)

> I think the main question is: will we ever find ourselves in the 
> future saying that "C/R sucks, nobody but a small minority uses 
> it, wish we had never merged it"? I think the likelyhood of that 
> is very low. I think the current OpenVZ stuff already looks very 
> useful, and i dont think we've realized (let alone explored) all 
> the possibilities yet.

This is collecting and start of dumping part of cleaned up OpenVZ C/R
implementation, FYI.

 arch/x86/include/asm/unistd_32.h   |    2 
 arch/x86/kernel/syscall_table_32.S |    2 
 include/linux/Kbuild               |    1 
 include/linux/cr.h                 |   56 ++++++
 include/linux/ipc_namespace.h      |    3 
 include/linux/syscalls.h           |    5 
 init/Kconfig                       |    2 
 kernel/Makefile                    |    1 
 kernel/cr/Kconfig                  |   11 +
 kernel/cr/Makefile                 |    8 
 kernel/cr/cpt-cred.c               |  115 +++++++++++++
 kernel/cr/cpt-fs.c                 |  122 +++++++++++++
 kernel/cr/cpt-mm.c                 |  134 +++++++++++++++
 kernel/cr/cpt-ns.c                 |  324 +++++++++++++++++++++++++++++++++++++
 kernel/cr/cpt-signal.c             |  121 +++++++++++++
 kernel/cr/cpt-sys.c                |  228 ++++++++++++++++++++++++++
 kernel/cr/cr-ctx.c                 |  141 ++++++++++++++++
 kernel/cr/cr.h                     |   61 ++++++
 kernel/cr/rst-sys.c                |    9 +
 kernel/sys_ni.c                    |    3 
 20 files changed, 1349 insertions(+)

diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index f2bba78..9504ede 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -338,6 +338,8 @@
 #define __NR_dup3		330
 #define __NR_pipe2		331
 #define __NR_inotify_init1	332
+#define __NR_checkpoint		333
+#define __NR_restore		334
 
 #ifdef __KERNEL__
 
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index e2e86a0..9f8c398 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -332,3 +332,5 @@ ENTRY(sys_call_table)
 	.long sys_dup3			/* 330 */
 	.long sys_pipe2
 	.long sys_inotify_init1
+	.long sys_checkpoint
+	.long sys_restart
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index b97cdc5..113d257 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -50,6 +50,7 @@ header-y += coff.h
 header-y += comstats.h
 header-y += const.h
 header-y += cgroupstats.h
+header-y += cr.h
 header-y += cramfs_fs.h
 header-y += cycx_cfm.h
 header-y += dlmconstants.h
diff --git a/include/linux/cr.h b/include/linux/cr.h
new file mode 100644
index 0000000..33fddd9
--- /dev/null
+++ b/include/linux/cr.h
@@ -0,0 +1,56 @@
+#ifndef __INCLUDE_LINUX_CR_H
+#define __INCLUDE_LINUX_CR_H
+
+#include <linux/types.h>
+
+struct cr_header {
+	/* Immutable part except version bumps. */
+#define CR_HEADER_MAGIC	"LinuxC/R"
+	__u8	cr_signature[8];
+#define CR_IMAGE_VERSION	1
+	__le64	cr_image_version;
+
+	/* Mutable part. */
+	__u8	cr_uts_release[64];	/* Give distro kernels a chance. */
+#define CR_ARCH_X86_32	1
+	__le32	cr_arch;
+};
+
+struct cr_object_header {
+#define CR_OBJ_UTS_NS	1
+#define CR_OBJ_CRED	2
+	__u32	cr_type;	/* object type */
+	__u32	cr_len;		/* object length in bytes including header */
+};
+
+#define cr_type	cr_hdr.cr_type
+#define cr_len	cr_hdr.cr_len
+
+struct cr_image_uts_ns {
+	struct cr_object_header cr_hdr;
+
+	__u8	cr_sysname[64];
+	__u8	cr_nodename[64];
+	__u8	cr_release[64];
+	__u8	cr_version[64];
+	__u8	cr_machine[64];
+	__u8	cr_domainname[64];
+};
+
+struct cr_image_cred {
+	struct cr_object_header cr_hdr;
+
+	__u32	cr_uid;
+	__u32	cr_gid;
+	__u32	cr_suid;
+	__u32	cr_sgid;
+	__u32	cr_euid;
+	__u32	cr_egid;
+	__u32	cr_fsuid;
+	__u32	cr_fsgid;
+	__u64	cr_cap_inheritable;
+	__u64	cr_cap_permitted;
+	__u64	cr_cap_effective;
+	__u64	cr_cap_bset;
+};
+#endif
diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
index ea330f9..87a8053 100644
--- a/include/linux/ipc_namespace.h
+++ b/include/linux/ipc_namespace.h
@@ -3,9 +3,12 @@
 
 #include <linux/err.h>
 #include <linux/idr.h>
+#include <linux/kref.h>
 #include <linux/rwsem.h>
 #include <linux/notifier.h>
 
+struct kern_ipc_perm;
+
 /*
  * ipc namespace events
  */
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index f9f900c..fac8fa9 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -692,6 +692,11 @@ asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 asmlinkage long sys_pipe2(int __user *, int);
 asmlinkage long sys_pipe(int __user *);
 
+#ifdef CONFIG_CR
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
+asmlinkage long sys_restart(int fd, unsigned long flags);
+#endif
+
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
 #endif
diff --git a/init/Kconfig b/init/Kconfig
index f068071..1b69c64 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -540,6 +540,8 @@ config CGROUP_MEM_RES_CTLR_SWAP
 
 endif # CGROUPS
 
+source "kernel/cr/Kconfig"
+
 config MM_OWNER
 	bool
 
diff --git a/kernel/Makefile b/kernel/Makefile
index e4791b3..71f9c68 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -93,6 +93,7 @@ obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) += dma-coherent.o
 obj-$(CONFIG_FUNCTION_TRACER) += trace/
 obj-$(CONFIG_TRACING) += trace/
 obj-$(CONFIG_SMP) += sched_cpupri.o
+obj-$(CONFIG_CR) += cr/
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan@linuxcare.com.au>, the -fno-omit-frame-pointer is
diff --git a/kernel/cr/Kconfig b/kernel/cr/Kconfig
new file mode 100644
index 0000000..bebef29
--- /dev/null
+++ b/kernel/cr/Kconfig
@@ -0,0 +1,11 @@
+config CR
+	bool "Container checkpoint/restart"
+	depends on IPC_NS || (SYSVIPC = n)
+	depends on NET_NS || (NET = n)
+	depends on PID_NS
+	depends on USER_NS
+	depends on UTS_NS
+	select FREEZER
+	depends on X86_32
+	help
+	  Container checkpoint/restart
diff --git a/kernel/cr/Makefile b/kernel/cr/Makefile
new file mode 100644
index 0000000..dc3dd49
--- /dev/null
+++ b/kernel/cr/Makefile
@@ -0,0 +1,8 @@
+obj-$(CONFIG_CR) += cr.o
+cr-y := cr-ctx.o
+cr-y += cpt-sys.o rst-sys.o
+cr-y += cpt-cred.o
+cr-y += cpt-fs.o
+cr-y += cpt-mm.o
+cr-y += cpt-ns.o
+cr-y += cpt-signal.o
diff --git a/kernel/cr/cpt-cred.c b/kernel/cr/cpt-cred.c
new file mode 100644
index 0000000..cdd1036
--- /dev/null
+++ b/kernel/cr/cpt-cred.c
@@ -0,0 +1,115 @@
+#include <linux/cr.h>
+#include <linux/cred.h>
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include "cr.h"
+
+int cr_dump_cred(struct cr_context *ctx, struct cred *cred)
+{
+	struct cr_image_cred *i;
+
+	printk("%s: dump cred %p\n", __func__, cred);
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	i->cr_type = CR_OBJ_CRED;
+	i->cr_len = sizeof(*i);
+
+	i->cr_uid = cred->uid;
+	i->cr_gid = cred->gid;
+	i->cr_suid = cred->suid;
+	i->cr_sgid = cred->sgid;
+	i->cr_euid = cred->euid;
+	i->cr_egid = cred->egid;
+	i->cr_fsuid = cred->fsuid;
+	i->cr_fsgid = cred->fsgid;
+	BUILD_BUG_ON(sizeof(cred->cap_inheritable) != 8);
+	memcpy(&i->cr_cap_inheritable, &cred->cap_inheritable, 8);
+	memcpy(&i->cr_cap_permitted, &cred->cap_permitted, 8);
+	memcpy(&i->cr_cap_effective, &cred->cap_effective, 8);
+	memcpy(&i->cr_cap_bset, &cred->cap_bset, 8);
+
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+
+	kfree(i);
+	return 0;
+}
+
+static int cr_check_cred(struct cred *cred)
+{
+	if (cred->securebits)
+		return -EINVAL;
+#ifdef CONFIG_KEYS
+	if (cred->thread_keyring || cred->request_key_auth || cred->tgcred)
+		return -EINVAL;
+#endif
+#ifdef CONFIG_SECURITY
+	if (cred->security)
+		return -EINVAL;
+#endif
+	return 0;
+}
+
+static int __cr_collect_cred(struct cr_context *ctx, struct cred *cred)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_cred) {
+		if (obj->o_obj == cred) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(cred);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_cred);
+	printk("%s: collect cred %p\n", __func__, cred);
+	return 0;
+}
+
+int cr_collect_cred(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_task_struct) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = cr_check_cred((struct cred *)tsk->real_cred);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_cred(ctx, (struct cred *)tsk->real_cred);
+		if (rv < 0)
+			return rv;
+		rv = cr_check_cred((struct cred *)tsk->cred);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_cred(ctx, (struct cred *)tsk->cred);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_file) {
+		struct file *file = obj->o_obj;
+
+		rv = cr_check_cred((struct cred *)file->f_cred);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_cred(ctx, (struct cred *)file->f_cred);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_cred) {
+		struct cred *cred = obj->o_obj;
+		unsigned int cnt = atomic_read(&cred->usage);
+
+		if (obj->o_count != cnt) {
+			printk("%s: cred %p has external references %u:%u\n", __func__, cred, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
diff --git a/kernel/cr/cpt-fs.c b/kernel/cr/cpt-fs.c
new file mode 100644
index 0000000..3fd6d0d
--- /dev/null
+++ b/kernel/cr/cpt-fs.c
@@ -0,0 +1,122 @@
+#include <linux/fdtable.h>
+#include <linux/fs.h>
+#include <linux/list.h>
+#include <linux/sched.h>
+#include "cr.h"
+
+static int cr_check_file(struct file *file)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+
+	switch (inode->i_mode & S_IFMT) {
+	case S_IFREG:
+	case S_IFDIR:
+		/* Likely on-disk filesystem. */
+		/* FIXME: FUSE, NFS, other networking filesystems */
+		if (inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV)
+			return 0;
+		break;
+	case S_IFBLK:
+		break;
+	case S_IFCHR:
+		break;
+	case S_IFIFO:
+		break;
+	case S_IFSOCK:
+		break;
+	case S_IFLNK:
+		/* One can't open symlink. */
+		BUG();
+	}
+	printk("%s: can't checkpoint file %p, ->f_op = %pS\n", __func__, file, file->f_op);
+	return -EINVAL;
+}
+
+int __cr_collect_file(struct cr_context *ctx, struct file *file)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_file) {
+		if (obj->o_obj == file) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(file);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_file);
+	printk("%s: collect file %p\n", __func__, file);
+	return 0;
+}
+
+static int __cr_collect_files_struct(struct cr_context *ctx, struct files_struct *fs)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_files_struct) {
+		if (obj->o_obj == fs) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(fs);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_files_struct);
+	printk("%s: collect files_struct %p\n", __func__, fs);
+	return 0;
+}
+
+int cr_collect_files_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_task_struct) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = __cr_collect_files_struct(ctx, tsk->files);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_files_struct) {
+		struct files_struct *fs = obj->o_obj;
+		unsigned int cnt = atomic_read(&fs->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: files_struct %p has external references %u:%u\n", __func__, fs, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	for_each_cr_object(ctx, obj, cr_files_struct) {
+		struct files_struct *fs = obj->o_obj;
+		int fd;
+
+		for (fd = 0; fd < files_fdtable(fs)->max_fds; fd++) {
+			struct file *file;
+
+			file = fcheck_files(fs, fd);
+			if (file) {
+				rv = cr_check_file(file);
+				if (rv < 0)
+					return rv;
+				rv = __cr_collect_file(ctx, file);
+				if (rv < 0)
+					return rv;
+			}
+		}
+	}
+	for_each_cr_object(ctx, obj, cr_file) {
+		struct file *file = obj->o_obj;
+		unsigned long cnt = atomic_long_read(&file->f_count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: file %p/%pS has external references %u:%lu\n", __func__, file, file->f_op, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
diff --git a/kernel/cr/cpt-mm.c b/kernel/cr/cpt-mm.c
new file mode 100644
index 0000000..e7e1ff0
--- /dev/null
+++ b/kernel/cr/cpt-mm.c
@@ -0,0 +1,134 @@
+#include <linux/mm.h>
+#include <linux/mmu_notifier.h>
+#include <linux/sched.h>
+#include "cr.h"
+
+static int cr_check_vma(struct vm_area_struct *vma)
+{
+	unsigned long flags = vma->vm_flags;
+
+	printk("%s: vma = %p, ->vm_flags = 0x%lx\n", __func__, vma, flags);
+	/* Flags, we know and love. */
+	flags &= ~VM_READ;
+	flags &= ~VM_WRITE;
+	flags &= ~VM_EXEC;
+	flags &= ~VM_MAYREAD;
+	flags &= ~VM_MAYWRITE;
+	flags &= ~VM_MAYEXEC;
+	flags &= ~VM_GROWSDOWN;
+	flags &= ~VM_DENYWRITE;
+	flags &= ~VM_EXECUTABLE;
+	flags &= ~VM_DONTEXPAND;
+	flags &= ~VM_ACCOUNT;
+	flags &= ~VM_ALWAYSDUMP;
+	flags &= ~VM_CAN_NONLINEAR;
+	/* Flags, we don't know and don't love. */
+	if (flags) {
+		printk("%s: vma = %p, unknown ->vm_flags 0x%lx\n", __func__, vma, flags);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int cr_check_mm(struct mm_struct *mm, struct task_struct *tsk)
+{
+	if (!mm)
+		return -EINVAL;
+	down_read(&mm->mmap_sem);
+	if (mm->core_state) {
+		up_read(&mm->mmap_sem);
+		return -EINVAL;
+	}
+	up_read(&mm->mmap_sem);
+#ifdef CONFIG_AIO
+	spin_lock(&mm->ioctx_lock);
+	if (!hlist_empty(&mm->ioctx_list)) {
+		spin_unlock(&mm->ioctx_lock);
+		return -EINVAL;
+	}
+	spin_unlock(&mm->ioctx_lock);
+#endif
+#ifdef CONFIG_MM_OWNER
+	if (mm->owner != tsk)
+		return -EINVAL;
+#endif
+#ifdef CONFIG_MMU_NOTIFIER
+	down_read(&mm->mmap_sem);
+	if (mm_has_notifiers(mm)) {
+		up_read(&mm->mmap_sem);
+		return -EINVAL;
+	}
+	up_read(&mm->mmap_sem);
+#endif
+	return 0;
+}
+
+static int __cr_collect_mm(struct cr_context *ctx, struct mm_struct *mm)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_mm_struct) {
+		if (obj->o_obj == mm) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(mm);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_mm_struct);
+	printk("%s: collect mm_struct %p\n", __func__, mm);
+	return 0;
+}
+
+int cr_collect_mm(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_task_struct) {
+		struct task_struct *tsk = obj->o_obj;
+		struct mm_struct *mm = tsk->mm;
+
+		rv = cr_check_mm(mm, tsk);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_mm(ctx, mm);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_mm_struct) {
+		struct mm_struct *mm = obj->o_obj;
+		unsigned int cnt = atomic_read(&mm->mm_users);
+
+		if (obj->o_count != cnt) {
+			printk("%s: mm_struct %p has external references %u:%u\n", __func__, mm, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	for_each_cr_object(ctx, obj, cr_mm_struct) {
+		struct mm_struct *mm = obj->o_obj;
+		struct vm_area_struct *vma;
+
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			rv = cr_check_vma(vma);
+			if (rv < 0)
+				return rv;
+			if (vma->vm_file) {
+				rv = __cr_collect_file(ctx, vma->vm_file);
+				if (rv < 0)
+					return rv;
+			}
+		}
+#ifdef CONFIG_PROC_FS
+		if (mm->exe_file) {
+			rv = __cr_collect_file(ctx, mm->exe_file);
+			if (rv < 0)
+				return rv;
+		}
+#endif
+	}
+	return 0;
+}
diff --git a/kernel/cr/cpt-ns.c b/kernel/cr/cpt-ns.c
new file mode 100644
index 0000000..0cbf964
--- /dev/null
+++ b/kernel/cr/cpt-ns.c
@@ -0,0 +1,324 @@
+#include <linux/cr.h>
+#include <linux/ipc_namespace.h>
+#include <linux/kref.h>
+#include <linux/nsproxy.h>
+#include <linux/mnt_namespace.h>
+#include <linux/pid_namespace.h>
+#include <linux/utsname.h>
+#include <net/net_namespace.h>
+#include "cr.h"
+
+int cr_dump_uts_ns(struct cr_context *ctx, struct uts_namespace *uts_ns)
+{
+	struct cr_image_uts_ns *i;
+
+	printk("%s: dump uts_ns %p\n", __func__, uts_ns);
+
+	i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (!i)
+		return -ENOMEM;
+	i->cr_type = CR_OBJ_UTS_NS;
+	i->cr_len = sizeof(*i);
+
+	strncpy((char *)i->cr_sysname, (const char *)uts_ns->name.sysname, 64);
+	strncpy((char *)i->cr_nodename, (const char *)uts_ns->name.nodename, 64);
+	strncpy((char *)i->cr_release, (const char *)uts_ns->name.release, 64);
+	strncpy((char *)i->cr_version, (const char *)uts_ns->name.version, 64);
+	strncpy((char *)i->cr_machine, (const char *)uts_ns->name.machine, 64);
+	strncpy((char *)i->cr_domainname, (const char *)uts_ns->name.domainname, 64);
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_uts_ns(struct cr_context *ctx, struct uts_namespace *uts_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_uts_ns) {
+		if (obj->o_obj == uts_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(uts_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_uts_ns);
+	printk("%s: collect uts_ns %p\n", __func__, uts_ns);
+	return 0;
+}
+
+static int cr_collect_uts_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_nsproxy) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_uts_ns(ctx, nsproxy->uts_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_uts_ns) {
+		struct uts_namespace *uts_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&uts_ns->kref.refcount);
+
+		if (obj->o_count != cnt) {
+			printk("%s: uts_ns %p has external references %u:%u\n", __func__, uts_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+#ifdef CONFIG_SYSVIPC
+static int __cr_collect_ipc_ns(struct cr_context *ctx, struct ipc_namespace *ipc_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_ipc_ns) {
+		if (obj->o_obj == ipc_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(ipc_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_ipc_ns);
+	printk("%s: collect ipc_ns %p\n", __func__, ipc_ns);
+	return 0;
+}
+
+static int cr_collect_ipc_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_nsproxy) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_ipc_ns(ctx, nsproxy->ipc_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_ipc_ns) {
+		struct ipc_namespace *ipc_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&ipc_ns->kref.refcount);
+
+		if (obj->o_count != cnt) {
+			printk("%s: ipc_ns %p has external references %u:%u\n", __func__, ipc_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+#else
+static int cr_collect_ipc_ns(struct cr_context *ctx)
+{
+	return 0;
+}
+#endif
+
+static int __cr_collect_mnt_ns(struct cr_context *ctx, struct mnt_namespace *mnt_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_mnt_ns) {
+		if (obj->o_obj == mnt_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(mnt_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_mnt_ns);
+	printk("%s: collect mnt_ns %p\n", __func__, mnt_ns);
+	return 0;
+}
+
+static int cr_collect_mnt_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_nsproxy) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_mnt_ns(ctx, nsproxy->mnt_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_mnt_ns) {
+		struct mnt_namespace *mnt_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&mnt_ns->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: mnt_ns %p has external references %u:%u\n", __func__, mnt_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int __cr_collect_pid_ns(struct cr_context *ctx, struct pid_namespace *pid_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_pid_ns) {
+		if (obj->o_obj == pid_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(pid_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_pid_ns);
+	printk("%s: collect pid_ns %p\n", __func__, pid_ns);
+	return 0;
+}
+
+static int cr_collect_pid_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_nsproxy) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_pid_ns(ctx, nsproxy->pid_ns);
+		if (rv < 0)
+			return rv;
+	}
+	/*
+	 * FIXME: check for external pid_ns references
+	 * 1. struct pid pins pid_ns
+	 * 2. struct pid_namespace pins pid_ns, but only parent one
+	 */
+	return 0;
+}
+
+#ifdef CONFIG_NET
+static int __cr_collect_net_ns(struct cr_context *ctx, struct net *net_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_net_ns) {
+		if (obj->o_obj == net_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(net_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_net_ns);
+	printk("%s: collect net_ns %p\n", __func__, net_ns);
+	return 0;
+}
+
+static int cr_collect_net_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_nsproxy) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_net_ns(ctx, nsproxy->net_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_net_ns) {
+		struct net *net_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&net_ns->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: net_ns %p has external references %u:%u\n", __func__, net_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+#else
+static int cr_collect_net_ns(struct cr_context *ctx)
+{
+	return 0;
+}
+#endif
+
+static int __cr_collect_nsproxy(struct cr_context *ctx, struct nsproxy *nsproxy)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_nsproxy) {
+		if (obj->o_obj == nsproxy) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(nsproxy);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_nsproxy);
+	printk("%s: collect nsproxy %p\n", __func__, nsproxy);
+	return 0;
+}
+
+int cr_collect_nsproxy(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_task_struct) {
+		struct task_struct *tsk = obj->o_obj;
+		struct nsproxy *nsproxy;
+
+		rcu_read_lock();
+		nsproxy = task_nsproxy(tsk);
+		rcu_read_unlock();
+		if (!nsproxy)
+			return -EAGAIN;
+
+		rv = __cr_collect_nsproxy(ctx, nsproxy);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_nsproxy) {
+		struct nsproxy *nsproxy = obj->o_obj;
+		unsigned int cnt = atomic_read(&nsproxy->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: nsproxy %p has external references %u:%u\n", __func__, nsproxy, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	rv = cr_collect_uts_ns(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_ipc_ns(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_mnt_ns(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_pid_ns(ctx);
+	if (rv < 0)
+		return rv;
+	rv = cr_collect_net_ns(ctx);
+	if (rv < 0)
+		return rv;
+	return 0;
+}
diff --git a/kernel/cr/cpt-signal.c b/kernel/cr/cpt-signal.c
new file mode 100644
index 0000000..cb074f5
--- /dev/null
+++ b/kernel/cr/cpt-signal.c
@@ -0,0 +1,121 @@
+#include <linux/sched.h>
+#include <linux/wait.h>
+#include "cr.h"
+
+static int cr_check_signal(struct signal_struct *signal)
+{
+	if (!signal)
+		return -EINVAL;
+	if (!list_empty(&signal->posix_timers))
+		return -EINVAL;
+#ifdef CONFIG_KEYS
+	if (signal->session_keyring || signal->process_keyring)
+		return -EINVAL;
+#endif
+	return 0;
+}
+
+static int __cr_collect_signal(struct cr_context *ctx, struct signal_struct *signal)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_signal) {
+		if (obj->o_obj == signal) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(signal);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_signal);
+	printk("%s: collect signal_struct %p\n", __func__, signal);
+	return 0;
+}
+
+int cr_collect_signal(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_task_struct) {
+		struct task_struct *tsk = obj->o_obj;
+		struct signal_struct *signal = tsk->signal;
+
+		rv = cr_check_signal(signal);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_signal(ctx, signal);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_signal) {
+		struct signal_struct *signal = obj->o_obj;
+		unsigned int cnt = atomic_read(&signal->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: signal_struct %p has external references %u:%u\n", __func__, signal, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+static int cr_check_sighand(struct sighand_struct *sighand)
+{
+	if (!sighand)
+		return -EINVAL;
+#ifdef CONFIG_SIGNALFD
+	if (waitqueue_active(&sighand->signalfd_wqh))
+		return -EINVAL;
+#endif
+	return 0;
+}
+
+static int __cr_collect_sighand(struct cr_context *ctx, struct sighand_struct *sighand)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_sighand) {
+		if (obj->o_obj == sighand) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(sighand);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_sighand);
+	printk("%s: collect sighand_struct %p\n", __func__, sighand);
+	return 0;
+}
+
+int cr_collect_sighand(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, cr_task_struct) {
+		struct task_struct *tsk = obj->o_obj;
+		struct sighand_struct *sighand = tsk->sighand;
+
+		rv = cr_check_sighand(sighand);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_sighand(ctx, sighand);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_sighand) {
+		struct sighand_struct *sighand = obj->o_obj;
+		unsigned int cnt = atomic_read(&sighand->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: sighand_struct %p has external references %u:%u\n", __func__, sighand, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
diff --git a/kernel/cr/cpt-sys.c b/kernel/cr/cpt-sys.c
new file mode 100644
index 0000000..27d3678
--- /dev/null
+++ b/kernel/cr/cpt-sys.c
@@ -0,0 +1,228 @@
+#include <linux/capability.h>
+#include <linux/cr.h>
+#include <linux/file.h>
+#include <linux/freezer.h>
+#include <linux/fs.h>
+#include <linux/nsproxy.h>
+#include <linux/pid_namespace.h>
+#include <linux/rcupdate.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+#include <linux/utsname.h>
+#include "cr.h"
+
+/* 'tsk' is child of 'parent' in some generation. */
+static int child_of(struct task_struct *parent, struct task_struct *tsk)
+{
+	struct task_struct *tmp = tsk;
+
+	while (tmp != &init_task) {
+		if (tmp == parent)
+			return 1;
+		tmp = tmp->real_parent;
+	}
+	/* In case 'parent' is 'init_task'. */
+	return tmp == parent;
+}
+
+static int cr_freeze_tasks(struct task_struct *init_tsk)
+{
+	struct task_struct *tmp, *tsk;
+
+	read_lock(&tasklist_lock);
+	do_each_thread(tmp, tsk) {
+		if (child_of(init_tsk, tsk)) {
+			if (!freeze_task(tsk, 1)) {
+				printk("%s: freezing '%s' failed\n", __func__, tsk->comm);
+				read_unlock(&tasklist_lock);
+				return -EBUSY;
+			}
+		}
+	} while_each_thread(tmp, tsk);
+	read_unlock(&tasklist_lock);
+	return 0;
+}
+
+static void cr_thaw_tasks(struct task_struct *init_tsk)
+{
+	struct task_struct *tmp, *tsk;
+
+	read_lock(&tasklist_lock);
+	do_each_thread(tmp, tsk) {
+		if (child_of(init_tsk, tsk))
+			thaw_process(tsk);
+	} while_each_thread(tmp, tsk);
+	read_unlock(&tasklist_lock);
+}
+
+static int __cr_collect_task(struct cr_context *ctx, struct task_struct *tsk)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, cr_task_struct) {
+		BUG_ON(obj->o_obj == tsk);
+	}
+
+	obj = cr_object_create(tsk);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_task_struct);
+	get_task_struct(tsk);
+	printk("%s: collect task %p/%s\n", __func__, tsk, tsk->comm);
+	return 0;
+}
+
+static int cr_collect_tasks(struct cr_context *ctx, struct task_struct *init_tsk)
+{
+	struct cr_object *obj;
+	int rv;
+
+	rv = __cr_collect_task(ctx, init_tsk);
+	if (rv < 0)
+		return rv;
+
+	for_each_cr_object(ctx, obj, cr_task_struct) {
+		struct task_struct *tsk = obj->o_obj, *child;
+
+		/* Collect threads. */
+		if (thread_group_leader(tsk)) {
+			struct task_struct *thread = tsk;
+
+			while ((thread = next_thread(thread)) != tsk) {
+				rv = __cr_collect_task(ctx, thread);
+				if (rv < 0)
+					return rv;
+			}
+		}
+
+		/* Collect children. */
+		list_for_each_entry(child, &tsk->children, sibling) {
+			rv = __cr_collect_task(ctx, child);
+			if (rv < 0)
+				return rv;
+		}
+	}
+	return 0;
+}
+
+static void cr_dump_header(struct cr_context *ctx)
+{
+	struct cr_header hdr;
+
+	memset(&hdr, 0, sizeof(struct cr_header));
+	hdr.cr_signature[0] = 'L';
+	hdr.cr_signature[1] = 'i';
+	hdr.cr_signature[2] = 'n';
+	hdr.cr_signature[3] = 'u';
+	hdr.cr_signature[4] = 'x';
+	hdr.cr_signature[5] = 'C';
+	hdr.cr_signature[6] = '/';
+	hdr.cr_signature[7] = 'R';
+	hdr.cr_image_version = cpu_to_le64(CR_IMAGE_VERSION);
+	strncpy((char *)&hdr.cr_uts_release, (const char *)init_uts_ns.name.release, 64);
+#ifdef CONFIG_X86_32
+	hdr.cr_arch = cpu_to_le32(CR_ARCH_X86_32);
+#endif
+	cr_write(ctx, &hdr, sizeof(struct cr_header));
+	cr_align(ctx);
+}
+
+static int cr_dump(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	cr_dump_header(ctx);
+
+	for_each_cr_object(ctx, obj, cr_uts_ns) {
+		rv = cr_dump_uts_ns(ctx, obj->o_obj);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, cr_cred) {
+		rv = cr_dump_cred(ctx, obj->o_obj);
+		if (rv < 0)
+			return 0;
+	}
+	return 0;
+}
+
+SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
+{
+	struct cr_context *ctx;
+	struct file *file;
+	struct task_struct *init_tsk = NULL, *tsk;
+	int rv = 0;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	file = fget(fd);
+	if (!file)
+		return -EBADF;
+	if (!(file->f_mode & FMODE_WRITE))
+		return -EBADF;
+	if (!file->f_op || !file->f_op->write)
+		return -EINVAL;
+
+	rcu_read_lock();
+	tsk = find_task_by_vpid(pid);
+	if (tsk) {
+		init_tsk = task_nsproxy(tsk)->pid_ns->child_reaper;
+		get_task_struct(init_tsk);
+	}
+	rcu_read_unlock();
+	if (!init_tsk) {
+		rv = -ESRCH;
+		goto out_no_init_tsk;
+	}
+
+	ctx = cr_context_create(init_tsk, file);
+	if (!ctx) {
+		rv = -ENOMEM;
+		goto out_ctx_alloc;
+	}
+
+	rv = cr_freeze_tasks(init_tsk);
+	if (rv < 0)
+		goto out_freeze;
+	rv = cr_collect_tasks(ctx, init_tsk);
+	if (rv < 0)
+		goto out_collect_tasks;
+	rv = cr_collect_nsproxy(ctx);
+	if (rv < 0)
+		goto out_collect_nsproxy;
+	rv = cr_collect_mm(ctx);
+	if (rv < 0)
+		goto out_collect_mm;
+	rv = cr_collect_files_struct(ctx);
+	if (rv < 0)
+		goto out_collect_files_struct;
+	/* After tasks and after files. */
+	rv = cr_collect_cred(ctx);
+	if (rv < 0)
+		goto out_collect_cred;
+	rv = cr_collect_signal(ctx);
+	if (rv < 0)
+		goto out_collect_signal;
+	rv = cr_collect_sighand(ctx);
+	if (rv < 0)
+		goto out_collect_sighand;
+
+	rv = cr_dump(ctx);
+
+out_collect_sighand:
+out_collect_signal:
+out_collect_cred:
+out_collect_files_struct:
+out_collect_mm:
+out_collect_nsproxy:
+out_collect_tasks:
+	cr_thaw_tasks(init_tsk);
+out_freeze:
+	cr_context_destroy(ctx);
+out_ctx_alloc:
+	put_task_struct(init_tsk);
+out_no_init_tsk:
+	fput(file);
+	return rv;
+}
diff --git a/kernel/cr/cr-ctx.c b/kernel/cr/cr-ctx.c
new file mode 100644
index 0000000..b203c89
--- /dev/null
+++ b/kernel/cr/cr-ctx.c
@@ -0,0 +1,141 @@
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/nsproxy.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <asm/processor.h>
+#include <asm/uaccess.h>
+#include "cr.h"
+
+void cr_write(struct cr_context *ctx, const void *buf, size_t count)
+{
+	struct file *file = ctx->cr_dump_file;
+	mm_segment_t old_fs;
+	ssize_t rv;
+
+	if (ctx->cr_write_error)
+		return;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+	rv = file->f_op->write(file, (const char __user *)buf, count, &file->f_pos);
+	set_fs(old_fs);
+	if (rv != count)
+		ctx->cr_write_error = (rv < 0) ? rv : -EIO;
+}
+
+void cr_align(struct cr_context *ctx)
+{
+	struct file *file = ctx->cr_dump_file;
+
+	file->f_pos = ALIGN(file->f_pos, 8);
+}
+
+struct cr_object *cr_object_create(void *data)
+{
+	struct cr_object *obj;
+
+	obj = kmalloc(sizeof(struct cr_object), GFP_KERNEL);
+	if (obj) {
+		obj->o_count = 1;
+		obj->o_obj = data;
+	}
+	return obj;
+}
+
+struct cr_context *cr_context_create(struct task_struct *tsk, struct file *file)
+{
+	struct cr_context *ctx;
+
+	ctx = kmalloc(sizeof(struct cr_context), GFP_KERNEL);
+	if (ctx) {
+		ctx->cr_init_tsk = tsk;
+		ctx->cr_dump_file = file;
+		ctx->cr_write_error = 0;
+
+		INIT_LIST_HEAD(&ctx->cr_task_struct);
+		INIT_LIST_HEAD(&ctx->cr_nsproxy);
+		INIT_LIST_HEAD(&ctx->cr_uts_ns);
+#ifdef CONFIG_SYSVIPC
+		INIT_LIST_HEAD(&ctx->cr_ipc_ns);
+#endif
+		INIT_LIST_HEAD(&ctx->cr_mnt_ns);
+		INIT_LIST_HEAD(&ctx->cr_pid_ns);
+#ifdef CONFIG_NET
+		INIT_LIST_HEAD(&ctx->cr_net_ns);
+#endif
+		INIT_LIST_HEAD(&ctx->cr_mm_struct);
+		INIT_LIST_HEAD(&ctx->cr_files_struct);
+		INIT_LIST_HEAD(&ctx->cr_file);
+		INIT_LIST_HEAD(&ctx->cr_cred);
+		INIT_LIST_HEAD(&ctx->cr_signal);
+		INIT_LIST_HEAD(&ctx->cr_sighand);
+	}
+	return ctx;
+}
+
+void cr_context_destroy(struct cr_context *ctx)
+{
+	struct cr_object *obj, *tmp;
+
+	for_each_cr_object_safe(ctx, obj, tmp, cr_sighand) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	for_each_cr_object_safe(ctx, obj, tmp, cr_signal) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	for_each_cr_object_safe(ctx, obj, tmp, cr_cred) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	for_each_cr_object_safe(ctx, obj, tmp, cr_file) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	for_each_cr_object_safe(ctx, obj, tmp, cr_files_struct) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	for_each_cr_object_safe(ctx, obj, tmp, cr_mm_struct) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+#ifdef CONFIG_NET
+	for_each_cr_object_safe(ctx, obj, tmp, cr_net_ns) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+#endif
+	for_each_cr_object_safe(ctx, obj, tmp, cr_pid_ns) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	for_each_cr_object_safe(ctx, obj, tmp, cr_mnt_ns) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+#ifdef CONFIG_SYSVIPC
+	for_each_cr_object_safe(ctx, obj, tmp, cr_ipc_ns) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+#endif
+	for_each_cr_object_safe(ctx, obj, tmp, cr_uts_ns) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	for_each_cr_object_safe(ctx, obj, tmp, cr_nsproxy) {
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	for_each_cr_object_safe(ctx, obj, tmp, cr_task_struct) {
+		struct task_struct *tsk = obj->o_obj;
+
+		put_task_struct(tsk);
+		list_del(&obj->o_list);
+		cr_object_destroy(obj);
+	}
+	kfree(ctx);
+}
diff --git a/kernel/cr/cr.h b/kernel/cr/cr.h
new file mode 100644
index 0000000..73a9fd9
--- /dev/null
+++ b/kernel/cr/cr.h
@@ -0,0 +1,61 @@
+#ifndef __CR_H
+#define __CR_H
+
+struct cr_object {
+	struct list_head	o_list;	/* entry in ->cr_* lists */
+	void			*o_obj;	/* pointer to object being collected/dumped */
+	unsigned int		o_count;/* number of references from collected objects */
+};
+
+struct cr_context {
+	struct task_struct	*cr_init_tsk;
+	struct file		*cr_dump_file;
+	int			cr_write_error;
+
+	struct list_head	cr_task_struct;
+	struct list_head	cr_nsproxy;
+	struct list_head	cr_uts_ns;
+#ifdef CONFIG_SYSVIPC
+	struct list_head	cr_ipc_ns;
+#endif
+	struct list_head	cr_mnt_ns;
+	struct list_head	cr_pid_ns;
+#ifdef CONFIG_NET
+	struct list_head	cr_net_ns;
+#endif
+	struct list_head	cr_mm_struct;
+	struct list_head	cr_files_struct;
+	struct list_head	cr_file;
+	struct list_head	cr_cred;
+	struct list_head	cr_signal;
+	struct list_head	cr_sighand;
+};
+
+#define for_each_cr_object(ctx, obj, lh)		\
+	list_for_each_entry(obj, &ctx->lh, o_list)
+#define for_each_cr_object_safe(ctx, obj, tmp, lh)	\
+	list_for_each_entry_safe(obj, tmp, &ctx->lh, o_list)
+
+struct cr_object *cr_object_create(void *data);
+static inline void cr_object_destroy(struct cr_object *obj)
+{
+	kfree(obj);
+}
+
+struct cr_context *cr_context_create(struct task_struct *tsk, struct file *file);
+void cr_context_destroy(struct cr_context *ctx);
+
+int cr_collect_nsproxy(struct cr_context *ctx);
+int cr_collect_cred(struct cr_context *ctx);
+int cr_collect_signal(struct cr_context *ctx);
+int cr_collect_sighand(struct cr_context *ctx);
+int cr_collect_mm(struct cr_context *ctx);
+int __cr_collect_file(struct cr_context *ctx, struct file *file);
+int cr_collect_files_struct(struct cr_context *ctx);
+
+void cr_write(struct cr_context *ctx, const void *buf, size_t count);
+void cr_align(struct cr_context *ctx);
+
+int cr_dump_uts_ns(struct cr_context *ctx, struct uts_namespace *uts_ns);
+int cr_dump_cred(struct cr_context *ctx, struct cred *cred);
+#endif
diff --git a/kernel/cr/rst-sys.c b/kernel/cr/rst-sys.c
new file mode 100644
index 0000000..35c3d15
--- /dev/null
+++ b/kernel/cr/rst-sys.c
@@ -0,0 +1,9 @@
+#include <linux/capability.h>
+#include <linux/syscalls.h>
+
+SYSCALL_DEFINE2(restart, int, fd, unsigned long, flags)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	return -ENOSYS;
+}
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 27dad29..da4fbf6 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -175,3 +175,6 @@ cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+
+cond_syscall(sys_checkpoint);
+cond_syscall(sys_restart);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
