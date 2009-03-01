Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4AEEC6B005A
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 20:26:26 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so756623fgg.4
        for <linux-mm@kvack.org>; Sat, 28 Feb 2009 17:26:21 -0800 (PST)
Date: Sun, 1 Mar 2009 04:33:04 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090301013304.GA2428@x200.localdomain>
References: <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226162755.GB1456@x200.localdomain> <20090226173302.GB29439@elte.hu> <20090226223112.GA2939@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090226223112.GA2939@x200.localdomain>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, mpm@selenic.com, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 01:31:12AM +0300, Alexey Dobriyan wrote:
> This is collecting and start of dumping part of cleaned up OpenVZ C/R
> implementation, FYI.

OK, here is second version which shows what to do with shared objects
(cr_dump_nsproxy(), cr_dump_task_struct()), introduced more checks
(still no unlinked files) and dumps some more information including
structures connections (cr_pos_*)

Dumping pids in under thinking because in OpenVZ pids are saved as
numbers due to CLONE_NEWPID is not allowed in container. In presense
of multiple CLONE_NEWPID levels this must present a big problem. Looks
like there is now way to not dump pids as separate object.

As result, struct cr_image_pid is variable-sized, don't know how this will
play later.

Also, pid refcount check for external pointers is busted right now,
because /proc inode pins struct pid, so there is almost always refcount
vs ->o_count mismatch.

No restore yet. ;-)



 arch/x86/include/asm/unistd_32.h   |    2 
 arch/x86/kernel/syscall_table_32.S |    2 
 include/linux/Kbuild               |    1 
 include/linux/cr.h                 |  169 +++++++++++++
 include/linux/ipc_namespace.h      |    3 
 include/linux/syscalls.h           |    5 
 init/Kconfig                       |    2 
 kernel/Makefile                    |    1 
 kernel/cr/Kconfig                  |   11 
 kernel/cr/Makefile                 |    9 
 kernel/cr/cpt-cred.c               |  114 +++++++++
 kernel/cr/cpt-fs.c                 |  248 ++++++++++++++++++++
 kernel/cr/cpt-mm.c                 |  152 ++++++++++++
 kernel/cr/cpt-ns.c                 |  451 +++++++++++++++++++++++++++++++++++++
 kernel/cr/cpt-signal.c             |  166 +++++++++++++
 kernel/cr/cpt-sys.c                |  258 +++++++++++++++++++++
 kernel/cr/cpt-task.c               |  176 ++++++++++++++
 kernel/cr/cr-ctx.c                 |  102 ++++++++
 kernel/cr/cr.h                     |  104 ++++++++
 kernel/cr/rst-sys.c                |    9 
 kernel/sys_ni.c                    |    3 
 21 files changed, 1988 insertions(+)

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
index 0000000..a761e4c
--- /dev/null
+++ b/include/linux/cr.h
@@ -0,0 +1,169 @@
+#ifndef __INCLUDE_LINUX_CR_H
+#define __INCLUDE_LINUX_CR_H
+
+#include <linux/types.h>
+
+#define CR_POS_UNDEF	(~0ULL)
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
+#define CR_OBJ_TASK_STRUCT	1
+#define CR_OBJ_NSPROXY		2
+#define CR_OBJ_UTS_NS		3
+#define CR_OBJ_IPC_NS		4
+#define CR_OBJ_MNT_NS		5
+#define CR_OBJ_PID_NS		6
+#define CR_OBJ_NET_NS		7
+#define CR_OBJ_MM_STRUCT	8
+#define CR_OBJ_SIGNAL_STRUCT	9
+#define CR_OBJ_SIGHAND_STRUCT	10
+#define CR_OBJ_FS_STRUCT	11
+#define CR_OBJ_FILES_STRUCT	12
+#define CR_OBJ_FILE		13
+#define CR_OBJ_CRED		14
+#define CR_OBJ_PID		15
+	__u32	cr_type;	/* object type */
+	__u32	cr_len;		/* object length in bytes including header */
+};
+
+/*
+ * 1. struct cr_object_header MUST start object's image.
+ * 2. Every member SHOULD start with 'cr_' prefix.
+ * 3. Every member which refers to position of another object image in
+ *    a dumpfile MUST be __u64 and SHOULD additionally use 'pos_' prefix.
+ * 4. Size and layout of every object type image MUST be the same on all
+ *    architectures.
+ */
+
+struct cr_image_task_struct {
+	struct cr_object_header cr_hdr;
+
+	__u64	cr_pos_real_cred;
+	__u64	cr_pos_cred;
+	__u8	cr_comm[16];
+	__u64	cr_pos_mm_struct;
+	__u64	cr_pos_pids[3];
+	__u64	cr_pos_fs;
+	__u64	cr_pos_files;
+	__u64	cr_pos_nsproxy;
+	__u64	cr_pos_signal;
+	__u64	cr_pos_sighand;
+};
+
+struct cr_image_nsproxy {
+	struct cr_object_header cr_hdr;
+
+	__u64	cr_pos_uts_ns;
+	__u64	cr_pos_ipc_ns;	/* CR_POS_UNDEF if CONFIG_SYSVIPC=n */
+	__u64	cr_pos_mnt_ns;
+	__u64	cr_pos_pid_ns;
+	__u64	cr_pos_net_ns;	/* CR_POS_UNDEF if CONFIG_NET=n */
+};
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
+struct cr_image_ipc_ns {
+	struct cr_object_header cr_hdr;
+};
+
+struct cr_image_mnt_ns {
+	struct cr_object_header cr_hdr;
+};
+
+struct cr_image_pid_ns {
+	struct cr_object_header cr_hdr;
+
+	__u32	cr_level;
+	__u32	cr_last_pid;
+};
+
+struct cr_image_net_ns {
+	struct cr_object_header cr_hdr;
+};
+
+struct cr_image_mm_struct {
+	struct cr_object_header cr_hdr;
+};
+
+struct cr_image_signal_struct {
+	struct cr_object_header cr_hdr;
+
+	struct {
+		__u64	cr_rlim_cur;
+		__u64	cr_rlim_max;
+	} cr_rlim[16];
+};
+
+struct cr_image_sighand_struct {
+	struct cr_object_header cr_hdr;
+};
+
+struct cr_image_fs_struct {
+	struct cr_object_header cr_hdr;
+
+	__u32	cr_umask;
+};
+
+struct cr_image_files_struct {
+	struct cr_object_header cr_hdr;
+};
+
+struct cr_image_file {
+	struct cr_object_header cr_hdr;
+
+	__u32	cr_f_flags;
+	__u32	_;
+	__u64	cr_f_pos;
+	__u64	cr_pos_f_owner_pid;
+	__u32	cr_f_owner_pid_type;
+	__u32	cr_f_owner_uid;
+	__u32	cr_f_owner_euid;
+	__u32	cr_f_owner_signum;
+	__u64	cr_pos_f_cred;
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
+
+struct cr_image_pid {
+	struct cr_object_header cr_hdr;
+
+	__u32	cr_level;
+	__u32	cr_nr[1];	/* cr_nr[cr_level + 1] */
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
index 0000000..1033425
--- /dev/null
+++ b/kernel/cr/Makefile
@@ -0,0 +1,9 @@
+obj-$(CONFIG_CR) += cr.o
+cr-y := cr-ctx.o
+cr-y += cpt-sys.o rst-sys.o
+cr-y += cpt-cred.o
+cr-y += cpt-fs.o
+cr-y += cpt-mm.o
+cr-y += cpt-ns.o
+cr-y += cpt-signal.o
+cr-y += cpt-task.o
diff --git a/kernel/cr/cpt-cred.c b/kernel/cr/cpt-cred.c
new file mode 100644
index 0000000..d071988
--- /dev/null
+++ b/kernel/cr/cpt-cred.c
@@ -0,0 +1,114 @@
+#include <linux/cr.h>
+#include <linux/cred.h>
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include "cr.h"
+
+int cr_dump_cred(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct cred *cred = obj->o_obj;
+	struct cr_image_cred *i;
+
+	printk("%s: dump cred %p\n", __func__, cred);
+
+	i = cr_prepare_image(CR_OBJ_CRED, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
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
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
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
+	for_each_cr_object(ctx, obj, CR_CTX_CRED) {
+		if (obj->o_obj == cred) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(cred);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_CRED]);
+	printk("%s: collect cred %p\n", __func__, cred);
+	return 0;
+}
+
+int cr_collect_cred(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
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
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		struct file *file = obj->o_obj;
+
+		rv = cr_check_cred((struct cred *)file->f_cred);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_cred(ctx, (struct cred *)file->f_cred);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_CRED) {
+		struct cred *cred = obj->o_obj;
+		unsigned int cnt = atomic_read(&cred->usage);
+
+		if (obj->o_count != cnt) {
+			printk("%s: cred %p has external references %lu:%u\n", __func__, cred, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
diff --git a/kernel/cr/cpt-fs.c b/kernel/cr/cpt-fs.c
new file mode 100644
index 0000000..b8ef0dd
--- /dev/null
+++ b/kernel/cr/cpt-fs.c
@@ -0,0 +1,248 @@
+#include <linux/cr.h>
+#include <linux/fdtable.h>
+#include <linux/fs.h>
+#include <linux/list.h>
+#include <linux/sched.h>
+#include "cr.h"
+
+int cr_dump_file(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct file *file = obj->o_obj;
+	struct cr_object *tmp;
+	struct cr_image_file *i;
+
+	printk("%s: dump file %p\n", __func__, file);
+
+	i = cr_prepare_image(CR_OBJ_FILE, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_f_flags = file->f_flags;
+	i->cr_f_pos = file->f_pos;
+	if (file->f_owner.pid) {
+		tmp = cr_find_obj_by_ptr(ctx, file->f_owner.pid, CR_CTX_PID);
+		i->cr_pos_f_owner_pid = tmp->o_pos;
+	} else
+		i->cr_pos_f_owner_pid = CR_POS_UNDEF;
+	i->cr_f_owner_pid_type = file->f_owner.pid_type;
+	i->cr_f_owner_uid = file->f_owner.uid;
+	i->cr_f_owner_euid = file->f_owner.euid;
+	i->cr_f_owner_signum = file->f_owner.signum;
+	tmp = cr_find_obj_by_ptr(ctx, file->f_cred, CR_CTX_CRED);
+	i->cr_pos_f_cred = tmp->o_pos;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int cr_check_file(struct file *file)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+
+#ifdef CONFIG_SECURITY
+	if (file->f_security)
+		return -EINVAL;
+#endif
+	spin_lock(&file->f_ep_lock);
+	if (!list_empty(&file->f_ep_links)) {
+		spin_unlock(&file->f_ep_lock);
+		return -EINVAL;
+	}
+	spin_unlock(&file->f_ep_lock);
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
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		if (obj->o_obj == file) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(file);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_FILE]);
+	printk("%s: collect file %p\n", __func__, file);
+	return 0;
+}
+
+int cr_dump_files_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct files_struct *files = obj->o_obj;
+	struct cr_image_files_struct *i;
+
+	printk("%s: dump files_struct %p\n", __func__, files);
+
+	i = cr_prepare_image(CR_OBJ_FILES_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_files_struct(struct cr_context *ctx, struct files_struct *files)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_FILES_STRUCT) {
+		if (obj->o_obj == files) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(files);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_FILES_STRUCT]);
+	printk("%s: collect files_struct %p\n", __func__, files);
+	return 0;
+}
+
+int cr_collect_files_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = __cr_collect_files_struct(ctx, tsk->files);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILES_STRUCT) {
+		struct files_struct *files = obj->o_obj;
+		unsigned int cnt = atomic_read(&files->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: files_struct %p has external references %lu:%u\n", __func__, files, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILES_STRUCT) {
+		struct files_struct *files = obj->o_obj;
+		int fd;
+
+		for (fd = 0; fd < files_fdtable(files)->max_fds; fd++) {
+			struct file *file;
+
+			file = fcheck_files(files, fd);
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
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		struct file *file = obj->o_obj;
+		unsigned long cnt = atomic_long_read(&file->f_count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: file %p/%pS has external references %lu:%lu\n", __func__, file, file->f_op, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+int cr_dump_fs_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct fs_struct *fs = obj->o_obj;
+	struct cr_image_fs_struct *i;
+
+	printk("%s: dump fs_struct %p\n", __func__, fs);
+
+	i = cr_prepare_image(CR_OBJ_FS_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_umask = fs->umask;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_fs_struct(struct cr_context *ctx, struct fs_struct *fs)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_FS_STRUCT) {
+		if (obj->o_obj == fs) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(fs);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_FS_STRUCT]);
+	printk("%s: collect fs_struct %p\n", __func__, fs);
+	return 0;
+}
+
+int cr_collect_fs_struct(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+
+		rv = __cr_collect_fs_struct(ctx, tsk->fs);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FS_STRUCT) {
+		struct fs_struct *fs = obj->o_obj;
+		unsigned int cnt = atomic_read(&fs->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: fs_struct %p has external references %lu:%u\n", __func__, fs, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
diff --git a/kernel/cr/cpt-mm.c b/kernel/cr/cpt-mm.c
new file mode 100644
index 0000000..830f180
--- /dev/null
+++ b/kernel/cr/cpt-mm.c
@@ -0,0 +1,152 @@
+#include <linux/cr.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/mmu_notifier.h>
+#include <linux/sched.h>
+#include "cr.h"
+
+static int cr_check_vma(struct vm_area_struct *vma)
+{
+	unsigned long flags = vma->vm_flags;
+
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
+	return 0;
+}
+
+int cr_dump_mm_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct mm_struct *mm = obj->o_obj;
+	struct cr_image_mm_struct *i;
+
+	printk("%s: dump mm_struct %p\n", __func__, mm);
+
+	i = cr_prepare_image(CR_OBJ_MM_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
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
+	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
+		if (obj->o_obj == mm) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(mm);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_MM_STRUCT]);
+	printk("%s: collect mm_struct %p\n", __func__, mm);
+	return 0;
+}
+
+int cr_collect_mm(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
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
+	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
+		struct mm_struct *mm = obj->o_obj;
+		unsigned int cnt = atomic_read(&mm->mm_users);
+
+		if (obj->o_count != cnt) {
+			printk("%s: mm_struct %p has external references %lu:%u\n", __func__, mm, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
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
index 0000000..07dd1f4
--- /dev/null
+++ b/kernel/cr/cpt-ns.c
@@ -0,0 +1,451 @@
+#include <linux/cr.h>
+#include <linux/fs.h>
+#include <linux/ipc_namespace.h>
+#include <linux/kref.h>
+#include <linux/nsproxy.h>
+#include <linux/mnt_namespace.h>
+#include <linux/pid_namespace.h>
+#include <linux/utsname.h>
+#include <net/net_namespace.h>
+#include "cr.h"
+
+int cr_dump_uts_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct uts_namespace *uts_ns = obj->o_obj;
+	struct cr_image_uts_ns *i;
+
+	printk("%s: dump uts_ns %p\n", __func__, uts_ns);
+
+	i = cr_prepare_image(CR_OBJ_UTS_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	strncpy((char *)i->cr_sysname, (const char *)uts_ns->name.sysname, 64);
+	strncpy((char *)i->cr_nodename, (const char *)uts_ns->name.nodename, 64);
+	strncpy((char *)i->cr_release, (const char *)uts_ns->name.release, 64);
+	strncpy((char *)i->cr_version, (const char *)uts_ns->name.version, 64);
+	strncpy((char *)i->cr_machine, (const char *)uts_ns->name.machine, 64);
+	strncpy((char *)i->cr_domainname, (const char *)uts_ns->name.domainname, 64);
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_uts_ns(struct cr_context *ctx, struct uts_namespace *uts_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_UTS_NS) {
+		if (obj->o_obj == uts_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(uts_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_UTS_NS]);
+	printk("%s: collect uts_ns %p\n", __func__, uts_ns);
+	return 0;
+}
+
+static int cr_collect_uts_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_uts_ns(ctx, nsproxy->uts_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_UTS_NS) {
+		struct uts_namespace *uts_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&uts_ns->kref.refcount);
+
+		if (obj->o_count != cnt) {
+			printk("%s: uts_ns %p has external references %lu:%u\n", __func__, uts_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+#ifdef CONFIG_SYSVIPC
+int cr_dump_ipc_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct ipc_namespace *ipc_ns = obj->o_obj;
+	struct cr_image_ipc_ns *i;
+
+	printk("%s: dump ipc_ns %p\n", __func__, ipc_ns);
+
+	i = cr_prepare_image(CR_OBJ_IPC_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_ipc_ns(struct cr_context *ctx, struct ipc_namespace *ipc_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_IPC_NS) {
+		if (obj->o_obj == ipc_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(ipc_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_IPC_NS]);
+	printk("%s: collect ipc_ns %p\n", __func__, ipc_ns);
+	return 0;
+}
+
+static int cr_collect_ipc_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_ipc_ns(ctx, nsproxy->ipc_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_IPC_NS) {
+		struct ipc_namespace *ipc_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&ipc_ns->kref.refcount);
+
+		if (obj->o_count != cnt) {
+			printk("%s: ipc_ns %p has external references %lu:%u\n", __func__, ipc_ns, obj->o_count, cnt);
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
+int cr_dump_mnt_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct mnt_namespace *mnt_ns = obj->o_obj;
+	struct cr_image_mnt_ns *i;
+
+	printk("%s: dump mnt_ns %p\n", __func__, mnt_ns);
+
+	i = cr_prepare_image(CR_OBJ_MNT_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_mnt_ns(struct cr_context *ctx, struct mnt_namespace *mnt_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_MNT_NS) {
+		if (obj->o_obj == mnt_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(mnt_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_MNT_NS]);
+	printk("%s: collect mnt_ns %p\n", __func__, mnt_ns);
+	return 0;
+}
+
+static int cr_collect_mnt_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_mnt_ns(ctx, nsproxy->mnt_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_MNT_NS) {
+		struct mnt_namespace *mnt_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&mnt_ns->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: mnt_ns %p has external references %lu:%u\n", __func__, mnt_ns, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+int cr_dump_pid_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct pid_namespace *pid_ns = obj->o_obj;
+	struct cr_image_pid_ns *i;
+
+	printk("%s: dump pid_ns %p\n", __func__, pid_ns);
+
+	i = cr_prepare_image(CR_OBJ_PID_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	i->cr_level = pid_ns->level;
+	i->cr_last_pid = pid_ns->last_pid;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int cr_check_pid_ns(struct pid_namespace *pid_ns)
+{
+#ifdef CONFIG_BSD_PROCESS_ACCT
+	if (pid_ns->bacct)
+		return -EINVAL;
+#endif
+	return 0;
+}
+
+static int __cr_collect_pid_ns(struct cr_context *ctx, struct pid_namespace *pid_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_PID_NS) {
+		if (obj->o_obj == pid_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(pid_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_PID_NS]);
+	printk("%s: collect pid_ns %p\n", __func__, pid_ns);
+	return 0;
+}
+
+static int cr_collect_pid_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+		struct pid_namespace *pid_ns = nsproxy->pid_ns;
+
+		rv = cr_check_pid_ns(pid_ns);
+		if (rv < 0)
+			return rv;
+		rv = __cr_collect_pid_ns(ctx, pid_ns);
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
+int cr_dump_net_ns(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct net *net = obj->o_obj;
+	struct cr_image_net_ns *i;
+
+	printk("%s: dump net_ns %p\n", __func__, net);
+
+	i = cr_prepare_image(CR_OBJ_NET_NS, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_net_ns(struct cr_context *ctx, struct net *net_ns)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NET_NS) {
+		if (obj->o_obj == net_ns) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(net_ns);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_NET_NS]);
+	printk("%s: collect net_ns %p\n", __func__, net_ns);
+	return 0;
+}
+
+static int cr_collect_net_ns(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+
+		rv = __cr_collect_net_ns(ctx, nsproxy->net_ns);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_NET_NS) {
+		struct net *net_ns = obj->o_obj;
+		unsigned int cnt = atomic_read(&net_ns->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: net_ns %p has external references %lu:%u\n", __func__, net_ns, obj->o_count, cnt);
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
+int cr_dump_nsproxy(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct nsproxy *nsproxy = obj->o_obj;
+	struct cr_object *tmp;
+	struct cr_image_nsproxy	*i;
+
+	printk("%s: dump nsproxy %p\n", __func__, nsproxy);
+
+	i = cr_prepare_image(CR_OBJ_NSPROXY, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->uts_ns, CR_CTX_UTS_NS);
+	i->cr_pos_uts_ns = tmp->o_pos;
+#ifdef CONFIG_SYSVIPC
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->ipc_ns, CR_CTX_IPC_NS);
+	i->cr_pos_ipc_ns = tmp->o_pos;
+#else
+	i->cr_pos = CR_POS_UNDEF;
+#endif
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->mnt_ns, CR_CTX_MNT_NS);
+	i->cr_pos_mnt_ns = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->pid_ns, CR_CTX_PID_NS);
+	i->cr_pos_pid_ns = tmp->o_pos;
+#ifdef CONFIG_NET
+	tmp = cr_find_obj_by_ptr(ctx, nsproxy->net_ns, CR_CTX_NET_NS);
+	i->cr_pos_net_ns = tmp->o_pos;
+#else
+	i->cr_pos_net_ns = CR_POS_UNDEF;
+#endif
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_nsproxy(struct cr_context *ctx, struct nsproxy *nsproxy)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		if (obj->o_obj == nsproxy) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(nsproxy);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_NSPROXY]);
+	printk("%s: collect nsproxy %p\n", __func__, nsproxy);
+	return 0;
+}
+
+int cr_collect_nsproxy(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
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
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		struct nsproxy *nsproxy = obj->o_obj;
+		unsigned int cnt = atomic_read(&nsproxy->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: nsproxy %p has external references %lu:%u\n", __func__, nsproxy, obj->o_count, cnt);
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
index 0000000..32a5bd7
--- /dev/null
+++ b/kernel/cr/cpt-signal.c
@@ -0,0 +1,166 @@
+#include <linux/cr.h>
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include <linux/wait.h>
+#include "cr.h"
+
+int cr_dump_signal_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct signal_struct *signal = obj->o_obj;
+	struct cr_image_signal_struct *i;
+	int n;
+
+	printk("%s: dump signal_struct %p\n", __func__, signal);
+
+	i = cr_prepare_image(CR_OBJ_SIGNAL_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	BUILD_BUG_ON(RLIM_NLIMITS != 16);
+	for (n = 0; n < RLIM_NLIMITS; n++) {
+		i->cr_rlim[n].cr_rlim_cur = signal->rlim[n].rlim_cur;
+		i->cr_rlim[n].cr_rlim_max = signal->rlim[n].rlim_max;
+	}
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
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
+	for_each_cr_object(ctx, obj, CR_CTX_SIGNAL_STRUCT) {
+		if (obj->o_obj == signal) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(signal);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_SIGNAL_STRUCT]);
+	printk("%s: collect signal_struct %p\n", __func__, signal);
+	return 0;
+}
+
+int cr_collect_signal(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
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
+	for_each_cr_object(ctx, obj, CR_CTX_SIGNAL_STRUCT) {
+		struct signal_struct *signal = obj->o_obj;
+		unsigned int cnt = atomic_read(&signal->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: signal_struct %p has external references %lu:%u\n", __func__, signal, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+
+int cr_dump_sighand_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct sighand_struct *sighand = obj->o_obj;
+	struct cr_image_sighand_struct *i;
+
+	printk("%s: dump sighand_struct %p\n", __func__, sighand);
+
+	i = cr_prepare_image(CR_OBJ_SIGHAND_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
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
+	for_each_cr_object(ctx, obj, CR_CTX_SIGHAND_STRUCT) {
+		if (obj->o_obj == sighand) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(sighand);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_SIGHAND_STRUCT]);
+	printk("%s: collect sighand_struct %p\n", __func__, sighand);
+	return 0;
+}
+
+int cr_collect_sighand(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
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
+	for_each_cr_object(ctx, obj, CR_CTX_SIGHAND_STRUCT) {
+		struct sighand_struct *sighand = obj->o_obj;
+		unsigned int cnt = atomic_read(&sighand->count);
+
+		if (obj->o_count != cnt) {
+			printk("%s: sighand_struct %p has external references %lu:%u\n", __func__, sighand, obj->o_count, cnt);
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
diff --git a/kernel/cr/cpt-sys.c b/kernel/cr/cpt-sys.c
new file mode 100644
index 0000000..6d32243
--- /dev/null
+++ b/kernel/cr/cpt-sys.c
@@ -0,0 +1,258 @@
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
+	for_each_cr_object(ctx, obj, CR_CTX_PID) {
+		rv = cr_dump_pid(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+
+	for_each_cr_object(ctx, obj, CR_CTX_CRED) {
+		rv = cr_dump_cred(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		rv = cr_dump_file(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILES_STRUCT) {
+		rv = cr_dump_files_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FS_STRUCT) {
+		rv = cr_dump_fs_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_UTS_NS) {
+		rv = cr_dump_uts_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+#ifdef CONFIG_SYSVIPC
+	for_each_cr_object(ctx, obj, CR_CTX_IPC_NS) {
+		rv = cr_dump_ipc_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+#endif
+	for_each_cr_object(ctx, obj, CR_CTX_MNT_NS) {
+		rv = cr_dump_mnt_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_PID_NS) {
+		rv = cr_dump_pid_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+#ifdef CONFIG_NET
+	for_each_cr_object(ctx, obj, CR_CTX_NET_NS) {
+		rv = cr_dump_net_ns(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+#endif
+	for_each_cr_object(ctx, obj, CR_CTX_SIGHAND_STRUCT) {
+		rv = cr_dump_sighand_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_SIGNAL_STRUCT) {
+		rv = cr_dump_signal_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_MM_STRUCT) {
+		rv = cr_dump_mm_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	/* After all namespaces. */
+	for_each_cr_object(ctx, obj, CR_CTX_NSPROXY) {
+		rv = cr_dump_nsproxy(ctx, obj);
+		if (rv < 0)
+			return rv;
+	}
+	/* After nsproxies. */
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		rv = cr_dump_task_struct(ctx, obj);
+		if (rv < 0)
+			return rv;
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
+	rv = cr_collect_fs_struct(ctx);
+	if (rv < 0)
+		goto out_collect_fs_struct;
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
+	rv = cr_collect_pid(ctx);
+	if (rv < 0)
+		goto out_collect_pid;
+
+	rv = cr_dump(ctx);
+
+out_collect_pid:
+out_collect_sighand:
+out_collect_signal:
+out_collect_cred:
+out_collect_fs_struct:
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
diff --git a/kernel/cr/cpt-task.c b/kernel/cr/cpt-task.c
new file mode 100644
index 0000000..f4274ba
--- /dev/null
+++ b/kernel/cr/cpt-task.c
@@ -0,0 +1,176 @@
+#include <linux/cr.h>
+#include <linux/fs.h>
+#include <linux/pid.h>
+#include <linux/sched.h>
+#include "cr.h"
+
+int cr_dump_pid(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct pid *pid = obj->o_obj;
+	struct cr_image_pid *i;
+	size_t image_len;
+	unsigned int level;
+
+	printk("%s: dump pid %p\n", __func__, pid);
+
+	/* FIXME pid numbers for levels below level of init_tsk are irrelevant */
+	image_len = sizeof(*i) + pid->level * sizeof(__u32);
+
+	i = cr_prepare_image(CR_OBJ_PID, image_len);
+	if (!i)
+		return -ENOMEM;
+
+	for (level = 0; level <= pid->level; level++)
+		i->cr_nr[level] = pid->numbers[level].nr;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, image_len);
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_pid(struct cr_context *ctx, struct pid *pid)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_PID) {
+		if (obj->o_obj == pid) {
+			obj->o_count++;
+			return 0;
+		}
+	}
+
+	obj = cr_object_create(pid);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_PID]);
+	printk("%s: collect pid %p\n", __func__, pid);
+	return 0;
+}
+
+int cr_collect_pid(struct cr_context *ctx)
+{
+	struct cr_object *obj;
+	int rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		struct task_struct *tsk = obj->o_obj;
+		int i;
+
+		printk("%s: tsk = %p/%s, ->group_leader = %p/%s\n", __func__, tsk, tsk->comm, tsk->group_leader, tsk->group_leader->comm);
+		for (i = 0; i < PIDTYPE_MAX; i++) {
+			struct pid *pid = tsk->pids[i].pid;
+
+			rv = __cr_collect_pid(ctx, pid);
+			if (rv < 0)
+				return rv;
+		}
+	}
+	for_each_cr_object(ctx, obj, CR_CTX_FILE) {
+		struct file *file = obj->o_obj;
+		struct pid *pid = file->f_owner.pid;
+
+		if (pid) {
+			rv = __cr_collect_pid(ctx, pid);
+			if (rv < 0)
+				return rv;
+		}
+	}
+	/* FIXME pid refcount check should account references from proc inodes */
+	return 0;
+}
+
+int cr_dump_task_struct(struct cr_context *ctx, struct cr_object *obj)
+{
+	struct task_struct *tsk = obj->o_obj;
+	struct cr_object *tmp;
+	struct cr_image_task_struct *i;
+	int n;
+
+	printk("%s: dump task_struct %p\n", __func__, tsk);
+
+	i = cr_prepare_image(CR_OBJ_TASK_STRUCT, sizeof(*i));
+	if (!i)
+		return -ENOMEM;
+
+	tmp = cr_find_obj_by_ptr(ctx, tsk->mm, CR_CTX_MM_STRUCT);
+	i->cr_pos_mm_struct = tmp->o_pos;
+	BUILD_BUG_ON(PIDTYPE_MAX != 3);
+	for (n = 0; n < PIDTYPE_MAX; n++) {
+		tmp = cr_find_obj_by_ptr(ctx, tsk->pids[n].pid, CR_CTX_PID);
+		i->cr_pos_pids[n] = tmp->o_pos;
+	}
+	tmp = cr_find_obj_by_ptr(ctx, tsk->real_cred, CR_CTX_CRED);
+	i->cr_pos_real_cred = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->cred, CR_CTX_CRED);
+	i->cr_pos_cred = tmp->o_pos;
+	BUILD_BUG_ON(TASK_COMM_LEN != 16);
+	strncpy((char *)i->cr_comm, (const char *)tsk->comm, 16);
+	tmp = cr_find_obj_by_ptr(ctx, tsk->fs, CR_CTX_FS_STRUCT);
+	i->cr_pos_fs = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->files, CR_CTX_FILES_STRUCT);
+	i->cr_pos_files = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->nsproxy, CR_CTX_NSPROXY);
+	i->cr_pos_nsproxy = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->signal, CR_CTX_SIGNAL_STRUCT);
+	i->cr_pos_signal = tmp->o_pos;
+	tmp = cr_find_obj_by_ptr(ctx, tsk->sighand, CR_CTX_SIGHAND_STRUCT);
+	i->cr_pos_sighand = tmp->o_pos;
+
+	obj->o_pos = ctx->cr_dump_file->f_pos;
+	cr_write(ctx, i, sizeof(*i));
+	cr_align(ctx);
+	kfree(i);
+	return 0;
+}
+
+static int __cr_collect_task(struct cr_context *ctx, struct task_struct *tsk)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
+		/* task_struct is never shared. */
+		BUG_ON(obj->o_obj == tsk);
+	}
+
+	obj = cr_object_create(tsk);
+	if (!obj)
+		return -ENOMEM;
+	list_add_tail(&obj->o_list, &ctx->cr_obj[CR_CTX_TASK_STRUCT]);
+	printk("%s: collect task %p/%s\n", __func__, tsk, tsk->comm);
+	return 0;
+}
+
+int cr_collect_tasks(struct cr_context *ctx, struct task_struct *init_tsk)
+{
+	struct cr_object *obj;
+	int rv;
+
+	rv = __cr_collect_task(ctx, init_tsk);
+	if (rv < 0)
+		return rv;
+
+	for_each_cr_object(ctx, obj, CR_CTX_TASK_STRUCT) {
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
diff --git a/kernel/cr/cr-ctx.c b/kernel/cr/cr-ctx.c
new file mode 100644
index 0000000..2385d20
--- /dev/null
+++ b/kernel/cr/cr-ctx.c
@@ -0,0 +1,102 @@
+#include <linux/cr.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/nsproxy.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <asm/processor.h>
+#include <asm/uaccess.h>
+#include "cr.h"
+
+void *cr_prepare_image(unsigned int type, size_t len)
+{
+	void *p;
+
+	p = kzalloc(len, GFP_KERNEL);
+	if (p) {
+		/* Any image must start with header. */
+		struct cr_object_header *cr_hdr = p;
+
+		cr_hdr->cr_type = type;
+		cr_hdr->cr_len = len;
+	}
+	return p;
+}
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
+		int i;
+
+		ctx->cr_init_tsk = tsk;
+		ctx->cr_dump_file = file;
+		ctx->cr_write_error = 0;
+		for (i = 0; i < NR_CR_CTX_TYPES; i++)
+			INIT_LIST_HEAD(&ctx->cr_obj[i]);
+	}
+	return ctx;
+}
+
+void cr_context_destroy(struct cr_context *ctx)
+{
+	struct cr_object *obj, *tmp;
+	int i;
+
+	for (i = 0; i < NR_CR_CTX_TYPES; i++) {
+		for_each_cr_object_safe(ctx, obj, tmp, i) {
+			list_del(&obj->o_list);
+			cr_object_destroy(obj);
+		}
+	}
+	kfree(ctx);
+}
+
+struct cr_object *cr_find_obj_by_ptr(struct cr_context *ctx, const void *ptr, enum cr_context_obj_type type)
+{
+	struct cr_object *obj;
+
+	for_each_cr_object(ctx, obj, type) {
+		if (obj->o_obj == ptr)
+			return obj;
+	}
+	BUG();
+}
diff --git a/kernel/cr/cr.h b/kernel/cr/cr.h
new file mode 100644
index 0000000..526f24e
--- /dev/null
+++ b/kernel/cr/cr.h
@@ -0,0 +1,104 @@
+#ifndef __CR_H
+#define __CR_H
+#include <linux/list.h>
+
+struct ipc_namespace;
+struct mnt_namespace;
+struct net;
+
+struct cr_object {
+	/* entry in ->cr_* lists */
+	struct list_head	o_list;
+	/* number of references from collected objects */
+	unsigned long		o_count;
+	/* position in dumpfile, or CR_POS_UNDEF if not yet dumped */
+	loff_t			o_pos;
+	/* pointer to object being collected/dumped */
+	void			*o_obj;
+};
+
+/* Not visible to userspace! */
+enum cr_context_obj_type {
+	CR_CTX_TASK_STRUCT,
+	CR_CTX_NSPROXY,
+	CR_CTX_UTS_NS,
+#ifdef CONFIG_SYSVIPC
+	CR_CTX_IPC_NS,
+#endif
+	CR_CTX_MNT_NS,
+	CR_CTX_PID_NS,
+#ifdef CONFIG_NET
+	CR_CTX_NET_NS,
+#endif
+	CR_CTX_MM_STRUCT,
+	CR_CTX_FS_STRUCT,
+	CR_CTX_FILES_STRUCT,
+	CR_CTX_FILE,
+	CR_CTX_CRED,
+	CR_CTX_SIGNAL_STRUCT,
+	CR_CTX_SIGHAND_STRUCT,
+	CR_CTX_PID,
+
+	NR_CR_CTX_TYPES
+};
+
+struct cr_context {
+	struct task_struct	*cr_init_tsk;
+	struct file		*cr_dump_file;
+	int			cr_write_error;
+	struct list_head	cr_obj[NR_CR_CTX_TYPES];
+};
+
+#define for_each_cr_object(ctx, obj, type)				\
+	list_for_each_entry(obj, &ctx->cr_obj[type], o_list)
+#define for_each_cr_object_safe(ctx, obj, tmp, type)			\
+	list_for_each_entry_safe(obj, tmp, &ctx->cr_obj[type], o_list)
+struct cr_object *cr_find_obj_by_ptr(struct cr_context *ctx, const void *ptr, enum cr_context_obj_type type);
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
+int cr_collect_tasks(struct cr_context *ctx, struct task_struct *init_tsk);
+
+int cr_collect_nsproxy(struct cr_context *ctx);
+int cr_collect_cred(struct cr_context *ctx);
+int cr_collect_pid(struct cr_context *ctx);
+int cr_collect_signal(struct cr_context *ctx);
+int cr_collect_sighand(struct cr_context *ctx);
+int cr_collect_mm(struct cr_context *ctx);
+int cr_collect_signal_struct(struct cr_context *ctx);
+int __cr_collect_file(struct cr_context *ctx, struct file *file);
+int cr_collect_files_struct(struct cr_context *ctx);
+int cr_collect_fs_struct(struct cr_context *ctx);
+
+void cr_write(struct cr_context *ctx, const void *buf, size_t count);
+void cr_align(struct cr_context *ctx);
+
+void *cr_prepare_image(unsigned int type, size_t len);
+
+int cr_dump_task_struct(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_nsproxy(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_uts_ns(struct cr_context *ctx, struct cr_object *obj);
+#ifdef CONFIG_SYSVIPC
+int cr_dump_ipc_ns(struct cr_context *ctx, struct cr_object *obj);
+#endif
+int cr_dump_mnt_ns(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_pid_ns(struct cr_context *ctx, struct cr_object *obj);
+#ifdef CONFIG_NET
+int cr_dump_net_ns(struct cr_context *ctx, struct cr_object *obj);
+#endif
+int cr_dump_mm_struct(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_signal_struct(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_sighand_struct(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_fs_struct(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_files_struct(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_file(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_cred(struct cr_context *ctx, struct cr_object *obj);
+int cr_dump_pid(struct cr_context *ctx, struct cr_object *obj);
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
