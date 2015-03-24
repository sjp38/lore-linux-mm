Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id A782B900015
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 09:12:48 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so221149207pdb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 06:12:48 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [2001:200:0:8803::53])
        by mx.google.com with ESMTPS id z3si3673613pas.11.2015.03.24.06.12.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 06:12:46 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [RFC PATCH 08/11] lib: other kernel glue layer code
Date: Tue, 24 Mar 2015 22:10:39 +0900
Message-Id: <1427202642-1716-9-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Jhristoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Mathieu Lacage <mathieu.lacage@gmail.com>, Christoph Paasch <christoph.paasch@gmail.com>

These files are used to provide the same function calls so that other
network stack code keeps untouched.

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Signed-off-by: Christoph Paasch <christoph.paasch@gmail.com>
---
 arch/lib/cred.c     |  16 +++
 arch/lib/dcache.c   |  93 +++++++++++++++
 arch/lib/filemap.c  |  27 +++++
 arch/lib/fs.c       | 287 ++++++++++++++++++++++++++++++++++++++++++++
 arch/lib/glue.c     | 336 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 arch/lib/inode.c    | 146 +++++++++++++++++++++++
 arch/lib/modules.c  |  36 ++++++
 arch/lib/pid.c      |  29 +++++
 arch/lib/print.c    |  56 +++++++++
 arch/lib/proc.c     | 164 +++++++++++++++++++++++++
 arch/lib/random.c   |  53 +++++++++
 arch/lib/security.c |  45 +++++++
 arch/lib/seq.c      | 122 +++++++++++++++++++
 arch/lib/splice.c   |  20 ++++
 arch/lib/super.c    | 210 ++++++++++++++++++++++++++++++++
 arch/lib/sysfs.c    |  83 +++++++++++++
 arch/lib/vmscan.c   |  26 ++++
 17 files changed, 1749 insertions(+)
 create mode 100644 arch/lib/cred.c
 create mode 100644 arch/lib/dcache.c
 create mode 100644 arch/lib/filemap.c
 create mode 100644 arch/lib/fs.c
 create mode 100644 arch/lib/glue.c
 create mode 100644 arch/lib/inode.c
 create mode 100644 arch/lib/modules.c
 create mode 100644 arch/lib/pid.c
 create mode 100644 arch/lib/print.c
 create mode 100644 arch/lib/proc.c
 create mode 100644 arch/lib/random.c
 create mode 100644 arch/lib/security.c
 create mode 100644 arch/lib/seq.c
 create mode 100644 arch/lib/splice.c
 create mode 100644 arch/lib/super.c
 create mode 100644 arch/lib/sysfs.c
 create mode 100644 arch/lib/vmscan.c

diff --git a/arch/lib/cred.c b/arch/lib/cred.c
new file mode 100644
index 0000000..50e37cc5
--- /dev/null
+++ b/arch/lib/cred.c
@@ -0,0 +1,16 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/cred.h>
+void __put_cred(struct cred *cred)
+{
+}
+struct cred *prepare_creds(void)
+{
+	return 0;
+}
diff --git a/arch/lib/dcache.c b/arch/lib/dcache.c
new file mode 100644
index 0000000..a007c20
--- /dev/null
+++ b/arch/lib/dcache.c
@@ -0,0 +1,93 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include <linux/fs.h>
+#include <linux/dcache.h>
+#include <linux/slab.h>
+#include "sim-assert.h"
+
+static struct kmem_cache *dentry_cache __read_mostly;
+struct kmem_cache *names_cachep __read_mostly;
+
+/**
+ * __d_alloc	-	allocate a dcache entry
+ * @sb: filesystem it will belong to
+ * @name: qstr of the name
+ *
+ * Allocates a dentry. It returns %NULL if there is insufficient memory
+ * available. On a success the dentry is returned. The name passed in is
+ * copied and the copy passed in may be reused after this call.
+ */
+struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
+{
+	struct dentry *dentry;
+	unsigned char *dname;
+
+	dentry = kmalloc(sizeof(struct dentry), GFP_KERNEL);
+	if (!dentry)
+		return NULL;
+
+	if (name->len > DNAME_INLINE_LEN - 1) {
+		dname = kmalloc(name->len + 1, GFP_KERNEL);
+		if (!dname) {
+			kmem_cache_free(dentry_cache, dentry);
+			return NULL;
+		}
+	} else
+		dname = dentry->d_iname;
+	dentry->d_name.name = dname;
+
+	dentry->d_name.len = name->len;
+	dentry->d_name.hash = name->hash;
+	memcpy(dname, name->name, name->len);
+	dname[name->len] = 0;
+
+	dentry->d_lockref.count = 1;
+	dentry->d_flags = 0;
+	spin_lock_init(&dentry->d_lock);
+	seqcount_init(&dentry->d_seq);
+	dentry->d_inode = NULL;
+	dentry->d_parent = dentry;
+	dentry->d_sb = sb;
+	dentry->d_op = NULL;
+	dentry->d_fsdata = NULL;
+	INIT_HLIST_BL_NODE(&dentry->d_hash);
+	INIT_LIST_HEAD(&dentry->d_lru);
+	INIT_LIST_HEAD(&dentry->d_subdirs);
+	INIT_HLIST_NODE(&dentry->d_u.d_alias);
+	INIT_LIST_HEAD(&dentry->d_child);
+	d_set_d_op(dentry, dentry->d_sb->s_d_op);
+
+/*	this_cpu_inc(nr_dentry); */
+
+	return dentry;
+}
+
+void d_set_d_op(struct dentry *dentry, const struct dentry_operations *op)
+{
+	WARN_ON_ONCE(dentry->d_op);
+	WARN_ON_ONCE(dentry->d_flags & (DCACHE_OP_HASH  |
+					DCACHE_OP_COMPARE       |
+					DCACHE_OP_REVALIDATE    |
+					DCACHE_OP_DELETE));
+	dentry->d_op = op;
+	if (!op)
+		return;
+	if (op->d_hash)
+		dentry->d_flags |= DCACHE_OP_HASH;
+	if (op->d_compare)
+		dentry->d_flags |= DCACHE_OP_COMPARE;
+	if (op->d_revalidate)
+		dentry->d_flags |= DCACHE_OP_REVALIDATE;
+	if (op->d_delete)
+		dentry->d_flags |= DCACHE_OP_DELETE;
+	if (op->d_prune)
+		dentry->d_flags |= DCACHE_OP_PRUNE;
+
+}
diff --git a/arch/lib/filemap.c b/arch/lib/filemap.c
new file mode 100644
index 0000000..9a9837c
--- /dev/null
+++ b/arch/lib/filemap.c
@@ -0,0 +1,27 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include "sim.h"
+#include "sim-assert.h"
+#include <linux/fs.h>
+
+
+ssize_t generic_file_aio_read(struct kiocb *a, const struct iovec *b,
+			      unsigned long c, loff_t d)
+{
+	lib_assert(false);
+
+	return 0;
+}
+
+int generic_file_readonly_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	return -ENOSYS;
+}
+
diff --git a/arch/lib/fs.c b/arch/lib/fs.c
new file mode 100644
index 0000000..766a9a8
--- /dev/null
+++ b/arch/lib/fs.c
@@ -0,0 +1,287 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include <linux/fs.h>
+#include <linux/splice.h>
+#include <linux/mount.h>
+#include <linux/sysctl.h>
+#include <fs/mount.h>
+#include <linux/slab.h>
+#include <linux/backing-dev.h>
+#include <linux/pagemap.h>
+#include <linux/user_namespace.h>
+#include <linux/lglock.h>
+
+#include "sim-assert.h"
+
+__cacheline_aligned_in_smp DEFINE_SEQLOCK(mount_lock);
+struct super_block;
+
+struct user_namespace init_user_ns;
+
+int get_sb_pseudo(struct file_system_type *type, char *str,
+		  const struct super_operations *ops, unsigned long z,
+		  struct vfsmount *mnt)
+{
+	/* called from sockfs_get_sb by kern_mount_data */
+	mnt->mnt_sb->s_root = 0;
+	mnt->mnt_sb->s_op = ops;
+	return 0;
+}
+struct inode *new_inode(struct super_block *sb)
+{
+	/* call sock_alloc_inode through s_op */
+	struct inode *inode = sb->s_op->alloc_inode(sb);
+
+	inode->i_ino = 0;
+	inode->i_sb = sb;
+	atomic_set(&inode->i_count, 1);
+	inode->i_state = 0;
+	return inode;
+}
+void iput(struct inode *inode)
+{
+	if (atomic_dec_and_test(&inode->i_count))
+		/* call sock_destroy_inode */
+		inode->i_sb->s_op->destroy_inode(inode);
+}
+void inode_init_once(struct inode *inode)
+{
+	memset(inode, 0, sizeof(*inode));
+}
+
+/* Implementation taken from vfs_kern_mount from linux/namespace.c */
+struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
+{
+	static struct mount local_mnt;
+	struct mount *mnt = &local_mnt;
+	struct dentry *root = 0;
+
+	memset(mnt, 0, sizeof(struct mount));
+	if (!type)
+		return ERR_PTR(-ENODEV);
+	int flags = MS_KERNMOUNT;
+	char *name = (char *)type->name;
+
+	if (flags & MS_KERNMOUNT)
+		mnt->mnt.mnt_flags = MNT_INTERNAL;
+
+	root = type->mount(type, flags, name, data);
+	if (IS_ERR(root))
+		return ERR_CAST(root);
+
+	mnt->mnt.mnt_root = root;
+	mnt->mnt.mnt_sb = root->d_sb;
+	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
+	mnt->mnt_parent = mnt;
+	/* DCE is monothreaded , so we do not care of lock here */
+	list_add_tail(&mnt->mnt_instance, &root->d_sb->s_mounts);
+
+	return &mnt->mnt;
+}
+
+int register_filesystem(struct file_system_type *fs)
+{
+	/* We don't need to register anything because we never
+	   really implement. any kind of filesystem.
+	   return 0 to signal success. */
+	return 0;
+}
+
+int alloc_fd(unsigned start, unsigned flags)
+{
+	lib_assert(false);
+	return 0;
+}
+void fd_install(unsigned int fd, struct file *file)
+{
+	lib_assert(false);
+}
+void put_unused_fd(unsigned int fd)
+{
+	lib_assert(false);
+}
+
+struct file *alloc_file(struct path *path, fmode_t mode,
+			const struct file_operations *fop)
+{
+	lib_assert(false);
+	return 0;
+}
+
+struct file *fget(unsigned int fd)
+{
+	lib_assert(false);
+	return 0;
+}
+struct file *fget_light(unsigned int fd, int *fput_needed)
+{
+	lib_assert(false);
+	return 0;
+}
+void fput(struct file *file)
+{
+}
+
+struct dentry *d_alloc(struct dentry *entry, const struct qstr *str)
+{
+	lib_assert(false);
+	return 0;
+}
+void d_instantiate(struct dentry *entry, struct inode *inode)
+{
+}
+char *dynamic_dname(struct dentry *dentry, char *buffer, int buflen,
+		    const char *fmt, ...)
+{
+	lib_assert(false);
+	return 0;
+}
+
+struct dentry_stat_t dentry_stat;
+struct files_stat_struct files_stat;
+struct inodes_stat_t inodes_stat;
+
+pid_t f_getown(struct file *filp)
+{
+	lib_assert(false);
+	return 0;
+}
+
+void f_setown(struct file *filp, unsigned long arg, int force)
+{
+	lib_assert(false);
+}
+
+void kill_fasync(struct fasync_struct **fs, int a, int b)
+{
+	lib_assert(false);
+}
+int fasync_helper(int a, struct file *file, int b, struct fasync_struct **c)
+{
+	lib_assert(false);
+	return 0;
+}
+long sys_close(unsigned int fd)
+{
+	lib_assert(false);
+	return 0;
+}
+ssize_t splice_to_pipe(struct pipe_inode_info *info,
+		       struct splice_pipe_desc *desc)
+{
+	lib_assert(false);
+	return 0;
+}
+int splice_grow_spd(const struct pipe_inode_info *info,
+		    struct splice_pipe_desc *desc)
+{
+	lib_assert(false);
+	return 0;
+}
+void splice_shrink_spd(struct splice_pipe_desc *desc)
+{
+	lib_assert(false);
+}
+
+ssize_t generic_splice_sendpage(struct pipe_inode_info *pipe,
+				struct file *out, loff_t *poff, size_t len,
+				unsigned int flags)
+{
+	lib_assert(false);
+	return 0;
+}
+void *generic_pipe_buf_map(struct pipe_inode_info *pipe,
+			   struct pipe_buffer *buf, int atomic)
+{
+	lib_assert(false);
+	return 0;
+}
+
+void generic_pipe_buf_unmap(struct pipe_inode_info *pipe,
+			    struct pipe_buffer *buf, void *address)
+{
+	lib_assert(false);
+}
+
+int generic_pipe_buf_confirm(struct pipe_inode_info *pipe,
+			     struct pipe_buffer *buf)
+{
+	lib_assert(false);
+	return 0;
+}
+
+void generic_pipe_buf_release(struct pipe_inode_info *pipe,
+			      struct pipe_buffer *buf)
+{
+	lib_assert(false);
+}
+
+static int generic_pipe_buf_nosteal(struct pipe_inode_info *pipe,
+				    struct pipe_buffer *buf)
+{
+	return 1;
+}
+
+void generic_pipe_buf_get(struct pipe_inode_info *pipe, struct pipe_buffer *buf)
+{
+	lib_assert(false);
+}
+int proc_nr_inodes(struct ctl_table *table, int write, void __user *buffer,
+		   size_t *lenp, loff_t *ppos)
+{
+	lib_assert(false);
+	return 0;
+}
+
+int proc_nr_dentry(struct ctl_table *table, int write, void __user *buffer,
+		   size_t *lenp, loff_t *ppos)
+{
+	lib_assert(false);
+	return 0;
+}
+
+/*
+ * Handle writeback of dirty data for the device backed by this bdi. Also
+ * wakes up periodically and does kupdated style flushing.
+ */
+int bdi_writeback_thread(void *data)
+{
+	lib_assert(false);
+
+	return 0;
+}
+
+void get_filesystem(struct file_system_type *fs)
+{
+}
+/* #include <fs/proc/proc_sysctl.c> */
+unsigned int nr_free_buffer_pages(void)
+{
+	return 1024;
+}
+
+const struct pipe_buf_operations nosteal_pipe_buf_ops = {
+	.can_merge	= 0,
+	.confirm	= generic_pipe_buf_confirm,
+	.release	= generic_pipe_buf_release,
+	.steal		= generic_pipe_buf_nosteal,
+	.get		= generic_pipe_buf_get,
+};
+
+ssize_t
+generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
+{
+	return 0;
+}
+
+unsigned long get_max_files(void)
+{
+	return NR_FILE;
+}
diff --git a/arch/lib/glue.c b/arch/lib/glue.c
new file mode 100644
index 0000000..9208739
--- /dev/null
+++ b/arch/lib/glue.c
@@ -0,0 +1,336 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include <linux/types.h>        /* loff_t */
+#include <linux/errno.h>        /* ESPIPE */
+#include <linux/pagemap.h>      /* PAGE_CACHE_SIZE */
+#include <linux/limits.h>       /* NAME_MAX */
+#include <linux/statfs.h>       /* struct kstatfs */
+#include <linux/bootmem.h>      /* HASHDIST_DEFAULT */
+#include <linux/utsname.h>
+#include <linux/binfmts.h>
+#include <linux/init_task.h>
+#include <linux/sched/rt.h>
+#include <stdarg.h>
+#include "sim-assert.h"
+#include "sim.h"
+#include "lib.h"
+
+
+struct pipe_buffer;
+struct file;
+struct pipe_inode_info;
+struct wait_queue_t;
+struct kernel_param;
+struct super_block;
+struct tvec_base {};
+
+/* defined in fs/exec.c */
+char core_pattern[CORENAME_MAX_SIZE] = "core";
+/* defined in sched.c, used in net/sched/em_meta.c */
+unsigned long avenrun[3];
+/* defined in mm/page_alloc.c, used in net/xfrm/xfrm_hash.c */
+int hashdist = HASHDIST_DEFAULT;
+/* defined in mm/page_alloc.c */
+struct pglist_data __refdata contig_page_data;
+/* defined in linux/mmzone.h mm/memory.c */
+struct page *mem_map = 0;
+/* used during boot. */
+struct tvec_base boot_tvec_bases;
+/* used by sysinfo in kernel/timer.c */
+int nr_threads = 0;
+/* not very useful in mm/vmstat.c */
+atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS];
+
+/* XXX: used in network stack ! */
+unsigned long num_physpages = 0;
+unsigned long totalram_pages = 0;
+
+/* XXX figure out initial value */
+unsigned int interrupt_pending = 0;
+static unsigned long g_irqflags = 0;
+static unsigned long local_irqflags = 0;
+int overflowgid = 0;
+int overflowuid = 0;
+int fs_overflowgid = 0;
+int fs_overflowuid = 0;
+unsigned long sysctl_overcommit_kbytes __read_mostly;
+DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
+
+/* from kobject_uevent.c */
+char uevent_helper[UEVENT_HELPER_PATH_LEN] = "dummy-uevent";
+/* from ksysfs.c */
+int rcu_expedited;
+/* from rt.c */
+int sched_rr_timeslice = RR_TIMESLICE;
+/* from main.c */
+bool initcall_debug;
+bool static_key_initialized __read_mostly = false;
+unsigned long __start_rodata, __end_rodata;
+
+unsigned long __raw_local_save_flags(void)
+{
+	return g_irqflags;
+}
+unsigned long arch_local_save_flags(void)
+{
+	return local_irqflags;
+}
+void arch_local_irq_restore(unsigned long flags)
+{
+	local_irqflags = flags;
+}
+
+int in_egroup_p(kgid_t grp)
+{
+	/* called from sysctl code. */
+	lib_assert(false);
+	return 0;
+}
+
+void __local_bh_enable_ip(unsigned long ip, unsigned int cnt)
+{
+}
+
+unsigned long long nr_context_switches(void)
+{
+	/* we just need to return >0 to avoid the warning
+	   in kernel/rcupdate.c */
+	return 1;
+}
+
+
+long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		    unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages,
+		    struct vm_area_struct **vmas)
+{
+	/* in practice, this function is never called. It's linked in because */
+	/* we link in get_user_pages_fast which is included only because it */
+	/* is located in mm/util.c */
+	lib_assert(false);
+	return 0;
+}
+
+
+unsigned long wrong_size_cmpxchg(volatile void *ptr)
+{
+	lib_assert(false);
+}
+
+void dump_stack(void)
+{
+	/* we assert to make sure that we catch whoever calls dump_stack */
+	lib_assert(false);
+}
+
+
+void lib_printf(const char *str, ...)
+{
+	va_list args;
+
+	va_start(args, str);
+	lib_vprintf(str, args);
+	va_end(args);
+}
+
+void atomic64_inc(atomic64_t *v)
+{
+	v->counter++;
+}
+
+#include <linux/vmalloc.h>
+#include <linux/kmemleak.h>
+
+static unsigned long __meminitdata nr_kernel_pages;
+static unsigned long __meminitdata nr_all_pages;
+/*
+ * allocate a large system hash table from bootmem
+ * - it is assumed that the hash table must contain an exact power-of-2
+ *   quantity of entries
+ * - limit is the number of hash buckets, not the total allocation size
+ */
+void *__init alloc_large_system_hash(const char *tablename,
+				     unsigned long bucketsize,
+				     unsigned long numentries,
+				     int scale,
+				     int flags,
+				     unsigned int *_hash_shift,
+				     unsigned int *_hash_mask,
+				     unsigned long low_limit,
+				     unsigned long high_limit)
+{
+	unsigned long long max = high_limit;
+	unsigned long log2qty, size;
+	void *table = NULL;
+
+	/* allow the kernel cmdline to have a say */
+	if (!numentries) {
+		/* round applicable memory size up to nearest megabyte */
+		numentries = nr_kernel_pages;
+		numentries += (1UL << (20 - PAGE_SHIFT)) - 1;
+		numentries >>= 20 - PAGE_SHIFT;
+		numentries <<= 20 - PAGE_SHIFT;
+
+		/* limit to 1 bucket per 2^scale bytes of low memory */
+		if (scale > PAGE_SHIFT)
+			numentries >>= (scale - PAGE_SHIFT);
+		else
+			numentries <<= (PAGE_SHIFT - scale);
+
+		/* Make sure we've got at least a 0-order allocation.. */
+		if (unlikely(flags & HASH_SMALL)) {
+			/* Makes no sense without HASH_EARLY */
+			WARN_ON(!(flags & HASH_EARLY));
+			if (!(numentries >> *_hash_shift)) {
+				numentries = 1UL << *_hash_shift;
+				BUG_ON(!numentries);
+			}
+		} else if (unlikely((numentries * bucketsize) < PAGE_SIZE))
+			numentries = PAGE_SIZE / bucketsize;
+	}
+	numentries = roundup_pow_of_two(numentries);
+
+	/* limit allocation size to 1/16 total memory by default */
+	if (max == 0) {
+		max = ((unsigned long long)nr_all_pages << PAGE_SHIFT) >> 4;
+		do_div(max, bucketsize);
+	}
+
+	if (numentries > max)
+		numentries = max;
+
+	log2qty = ilog2(numentries);
+
+	do {
+		size = bucketsize << log2qty;
+		if (flags & HASH_EARLY)
+			table = alloc_bootmem_nopanic(size);
+		else if (hashdist)
+			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
+		else {
+			/*
+			 * If bucketsize is not a power-of-two, we may free
+			 * some pages at the end of hash table which
+			 * alloc_pages_exact() automatically does
+			 */
+			if (get_order(size) < MAX_ORDER) {
+				table = alloc_pages_exact(size, GFP_ATOMIC);
+				kmemleak_alloc(table, size, 1, GFP_ATOMIC);
+			}
+		}
+	} while (!table && size > PAGE_SIZE && --log2qty);
+
+	if (!table)
+		panic("Failed to allocate %s hash table\n", tablename);
+
+	pr_info("%s hash table entries: %d (order: %d, %lu bytes)\n",
+	       tablename,
+	       (1U << log2qty),
+	       ilog2(size) - PAGE_SHIFT,
+	       size);
+
+	if (_hash_shift)
+		*_hash_shift = log2qty;
+	if (_hash_mask)
+		*_hash_mask = (1 << log2qty) - 1;
+
+	return table;
+}
+
+int vm_insert_page(struct vm_area_struct *area, unsigned long addr,
+		   struct page *page)
+{
+	/* this function is called from af_packet.c to support mmap on packet
+	   sockets since we will never call mmap on them, this function
+	   should never be called. */
+	lib_assert(false);
+	return 0; /* quiet compiler */
+}
+
+void si_meminfo(struct sysinfo *val)
+{
+	/* This function is called from the ip layer to get information about
+	   the amount of memory in the system and make some educated guesses
+	   about some default buffer sizes. We pick a value which ensures
+	   small buffers. */
+	val->totalram = 0;
+}
+int slab_is_available(void)
+{
+	/* called from kernel/param.c. */
+	return 1;
+}
+
+/* used from kern_ptr_validate from mm/util.c which is never called */
+void *high_memory = 0;
+
+
+
+char *get_options(const char *str, int nints, int *ints)
+{
+	/* called from net/core/dev.c */
+	/* we return 0 to indicate no options. */
+	return 0;
+}
+void __xchg_called_with_bad_pointer(void)
+{
+	/* never called theoretically. */
+	lib_assert(false);
+}
+
+void async_synchronize_full(void)
+{
+	/* called from drivers/base/ *.c */
+	/* there is nothing to do, really. */
+}
+int send_sigurg(struct fown_struct *fown)
+{
+	lib_assert(false);
+	return 0;
+}
+int send_sig(int signal, struct task_struct *task, int x)
+{
+	struct SimTask *lib_task = container_of(task, struct SimTask,
+						kernel_task);
+
+	lib_signal_raised((struct SimTask *)lib_task, signal);
+	/* lib_assert (false); */
+	return 0;
+}
+unsigned long get_taint(void)
+{
+	/* never tainted. */
+	return 0;
+}
+void add_taint(unsigned flag, enum lockdep_ok lockdep_ok)
+{
+}
+struct pid *cad_pid = 0;
+
+void add_device_randomness(const void *buf, unsigned int size)
+{
+}
+
+int kobject_uevent(struct kobject *kobj, enum kobject_action action)
+{
+	return 0;
+}
+
+int sched_rr_handler(struct ctl_table *table, int write,
+		     void __user *buffer, size_t *lenp,
+		     loff_t *ppos)
+{
+	return 0;
+}
+
+void on_each_cpu_mask(const struct cpumask *mask,
+		      smp_call_func_t func, void *info, bool wait)
+{
+}
diff --git a/arch/lib/inode.c b/arch/lib/inode.c
new file mode 100644
index 0000000..ab3d2ec
--- /dev/null
+++ b/arch/lib/inode.c
@@ -0,0 +1,146 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/dcache.h>
+#include <linux/security.h>
+#include <linux/pagemap.h>
+#include <linux/backing-dev.h>
+
+
+static struct kmem_cache *inode_cachep __read_mostly;
+/*
+ * Empty aops. Can be used for the cases where the user does not
+ * define any of the address_space operations.
+ */
+const struct address_space_operations empty_aops = {
+};
+
+unsigned int get_next_ino(void)
+{
+	static unsigned int res = 0;
+
+	return ++res;
+}
+
+/**
+ * inode_init_always - perform inode structure intialisation
+ * @sb: superblock inode belongs to
+ * @inode: inode to initialise
+ *
+ * These are initializations that need to be done on every inode
+ * allocation as the fields are not initialised by slab allocation.
+ */
+int inode_init_always(struct super_block *sb, struct inode *inode)
+{
+	static const struct inode_operations empty_iops;
+	static const struct file_operations empty_fops;
+	struct address_space *const mapping = &inode->i_data;
+
+	inode->i_sb = sb;
+	inode->i_blkbits = sb->s_blocksize_bits;
+	inode->i_flags = 0;
+	atomic_set(&inode->i_count, 1);
+	inode->i_op = &empty_iops;
+	inode->__i_nlink = 1;
+	inode->i_opflags = 0;
+	i_uid_write(inode, 0);
+	i_gid_write(inode, 0);
+	atomic_set(&inode->i_writecount, 0);
+	inode->i_size = 0;
+	inode->i_blocks = 0;
+	inode->i_bytes = 0;
+	inode->i_generation = 0;
+	inode->i_pipe = NULL;
+	inode->i_bdev = NULL;
+	inode->i_cdev = NULL;
+	inode->i_rdev = 0;
+	inode->dirtied_when = 0;
+
+	if (security_inode_alloc(inode))
+		goto out;
+	spin_lock_init(&inode->i_lock);
+	lockdep_set_class(&inode->i_lock, &sb->s_type->i_lock_key);
+
+	mutex_init(&inode->i_mutex);
+	lockdep_set_class(&inode->i_mutex, &sb->s_type->i_mutex_key);
+
+	atomic_set(&inode->i_dio_count, 0);
+
+	mapping->a_ops = &empty_aops;
+	mapping->host = inode;
+	mapping->flags = 0;
+	atomic_set(&mapping->i_mmap_writable, 0);
+	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
+	mapping->private_data = NULL;
+	mapping->writeback_index = 0;
+	inode->i_private = NULL;
+	inode->i_mapping = mapping;
+	INIT_HLIST_HEAD(&inode->i_dentry);	/* buggered by rcu freeing */
+#ifdef CONFIG_FS_POSIX_ACL
+	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
+#endif
+
+#ifdef CONFIG_FSNOTIFY
+	inode->i_fsnotify_mask = 0;
+#endif
+	/* this_cpu_inc(nr_inodes); */
+
+	return 0;
+out:
+	return -ENOMEM;
+}
+
+
+static struct inode *alloc_inode(struct super_block *sb)
+{
+	struct inode *inode;
+
+	if (sb->s_op->alloc_inode)
+		inode = sb->s_op->alloc_inode(sb);
+	else
+		inode = kmem_cache_alloc(inode_cachep, GFP_KERNEL);
+
+	if (!inode)
+		return NULL;
+
+	if (unlikely(inode_init_always(sb, inode))) {
+		if (inode->i_sb->s_op->destroy_inode)
+			inode->i_sb->s_op->destroy_inode(inode);
+		else
+			kmem_cache_free(inode_cachep, inode);
+		return NULL;
+	}
+
+	return inode;
+}
+
+/**
+ *	new_inode_pseudo        - obtain an inode
+ *	@sb: superblock
+ *
+ *	Allocates a new inode for given superblock.
+ *	Inode wont be chained in superblock s_inodes list
+ *	This means :
+ *	- fs can't be unmount
+ *	- quotas, fsnotify, writeback can't work
+ */
+struct inode *new_inode_pseudo(struct super_block *sb)
+{
+	struct inode *inode = alloc_inode(sb);
+
+	if (inode) {
+		spin_lock(&inode->i_lock);
+		inode->i_state = 0;
+		spin_unlock(&inode->i_lock);
+		INIT_LIST_HEAD(&inode->i_sb_list);
+	}
+	return inode;
+}
diff --git a/arch/lib/modules.c b/arch/lib/modules.c
new file mode 100644
index 0000000..ca43fdc
--- /dev/null
+++ b/arch/lib/modules.c
@@ -0,0 +1,36 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include "sim-assert.h"
+#include <linux/moduleparam.h>
+#include <linux/kmod.h>
+#include <linux/module.h>
+
+int modules_disabled = 0;
+char modprobe_path[KMOD_PATH_LEN] = "/sbin/modprobe";
+
+static struct module_version_attribute g_empty_attr_buffer;
+/* we make the array empty by default because, really, we don't need */
+/* to look at the builtin params */
+const struct kernel_param __start___param[] = {{0}} ;
+const struct kernel_param __stop___param[] = {{0}} ;
+const struct module_version_attribute *__start___modver[] = {
+	&g_empty_attr_buffer};
+const struct module_version_attribute *__stop___modver[] = {
+	&g_empty_attr_buffer};
+
+struct module_attribute module_uevent;
+struct ctl_table usermodehelper_table[] = {};
+
+int __request_module(bool wait, const char *fmt, ...)
+{
+	/* we really should never be trying to load modules that way. */
+	/*  lib_assert (false); */
+	return 0;
+}
diff --git a/arch/lib/pid.c b/arch/lib/pid.c
new file mode 100644
index 0000000..00cf7b6
--- /dev/null
+++ b/arch/lib/pid.c
@@ -0,0 +1,29 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/pid.h>
+#include "sim.h"
+#include "sim-assert.h"
+
+void put_pid(struct pid *pid)
+{
+}
+pid_t pid_vnr(struct pid *pid)
+{
+	return pid_nr(pid);
+}
+struct task_struct *find_task_by_vpid(pid_t nr)
+{
+	lib_assert(false);
+	return 0;
+}
+struct pid *find_get_pid(int nr)
+{
+	lib_assert(false);
+	return 0;
+}
diff --git a/arch/lib/print.c b/arch/lib/print.c
new file mode 100644
index 0000000..09b1bb5
--- /dev/null
+++ b/arch/lib/print.c
@@ -0,0 +1,56 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <stdarg.h>
+#include <linux/string.h>
+#include <linux/printk.h>
+#include "sim.h"
+#include "sim-assert.h"
+
+int dmesg_restrict = 1;
+
+/* from lib/vsprintf.c */
+int vsnprintf(char *buf, size_t size, const char *fmt, va_list args);
+
+int printk(const char *fmt, ...)
+{
+	va_list args;
+	static char buf[256];
+	int value;
+
+	va_start(args, fmt);
+	value = vsnprintf(buf, 256, printk_skip_level(fmt), args);
+	lib_printf("<%c>%s", printk_get_level(fmt), buf);
+	va_end(args);
+	return value;
+}
+void panic(const char *fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	lib_vprintf(fmt, args);
+	va_end(args);
+	lib_assert(false);
+}
+
+void warn_slowpath_fmt(const char *file, int line, const char *fmt, ...)
+{
+	va_list args;
+
+	printk("%s:%d -- ", file, line);
+	va_start(args, fmt);
+	lib_vprintf(fmt, args);
+	va_end(args);
+}
+
+void warn_slowpath_null(const char *file, int line)
+{
+	printk("%s:%d -- ", file, line);
+}
+
diff --git a/arch/lib/proc.c b/arch/lib/proc.c
new file mode 100644
index 0000000..0a65d7b
--- /dev/null
+++ b/arch/lib/proc.c
@@ -0,0 +1,164 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2014 Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/fs.h>
+#include <linux/net.h>
+#include <linux/slab.h>
+#include <linux/proc_fs.h>
+#include <linux/string.h>
+#include <net/net_namespace.h>
+#include "sim-types.h"
+#include "sim-assert.h"
+#include "fs/proc/internal.h"           /* XXX */
+
+struct proc_dir_entry;
+static char proc_root_data[sizeof(struct proc_dir_entry) + 4];
+
+static struct proc_dir_entry *proc_root_sim  =
+	(struct proc_dir_entry *)proc_root_data;
+
+void lib_proc_net_initialize(void)
+{
+	proc_root_sim->parent = proc_root_sim;
+	strcpy(proc_root_sim->name, "net");
+	proc_root_sim->mode = S_IFDIR | S_IRUGO | S_IXUGO;
+	proc_root_sim->subdir = RB_ROOT;
+	init_net.proc_net = proc_root_sim;
+	init_net.proc_net_stat = proc_mkdir("stat", proc_root_sim);
+}
+struct proc_dir_entry *
+proc_net_fops_create(struct net *net,
+		     const char *name,
+		     umode_t mode, const struct file_operations *fops)
+{
+	return proc_create_data(name, mode, net->proc_net, fops, 0);
+}
+
+static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
+					  const char *name,
+					  umode_t mode,
+					  nlink_t nlink)
+{
+	struct proc_dir_entry *ent = NULL;
+	const char *fn = name;
+	struct qstr qstr;
+
+	qstr.name = fn;
+	qstr.len = strlen(fn);
+	if (qstr.len == 0 || qstr.len >= 256) {
+		WARN(1, "name len %u\n", qstr.len);
+		return NULL;
+	}
+
+	ent = kzalloc(sizeof(struct proc_dir_entry) + qstr.len + 1, GFP_KERNEL);
+	if (!ent)
+		goto out;
+
+	memcpy(ent->name, fn, qstr.len + 1);
+	ent->namelen = qstr.len;
+	ent->mode = mode;
+	ent->nlink = nlink;
+	ent->subdir = RB_ROOT;
+	atomic_set(&ent->count, 1);
+	spin_lock_init(&ent->pde_unload_lock);
+	INIT_LIST_HEAD(&ent->pde_openers);
+out:
+	return ent;
+}
+struct proc_dir_entry *proc_create_data(const char *name, umode_t mode,
+					struct proc_dir_entry *parent,
+					const struct file_operations *proc_fops,
+					void *data)
+{
+	struct proc_dir_entry *de;
+
+	de = __proc_create(&parent, name, S_IFDIR | mode, 2);
+	de->proc_fops = proc_fops;
+	de->data = data;
+	return de;
+}
+static int proc_match(unsigned int len, const char *name,
+		      struct proc_dir_entry *de)
+{
+	if (len < de->namelen)
+		return -1;
+	if (len > de->namelen)
+		return 1;
+
+	return memcmp(name, de->name, len);
+}
+static struct proc_dir_entry *pde_subdir_find(struct proc_dir_entry *dir,
+					      const char *name,
+					      unsigned int len)
+{
+	struct rb_node *node = dir->subdir.rb_node;
+
+	while (node) {
+		struct proc_dir_entry *de = container_of(node,
+							 struct proc_dir_entry,
+							 subdir_node);
+		int result = proc_match(len, name, de);
+
+		if (result < 0)
+			node = node->rb_left;
+		else if (result > 0)
+			node = node->rb_right;
+		else
+			return de;
+	}
+	return NULL;
+}
+
+void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
+{
+	struct proc_dir_entry *de, **prev;
+
+	de = pde_subdir_find(parent, name, strlen(name));
+	if (de) {
+		rb_erase(&de->subdir_node, &parent->subdir);
+		kfree(de->name);
+		kfree(de);
+	}
+}
+void proc_net_remove(struct net *net, const char *name)
+{
+	remove_proc_entry(name, net->proc_net);
+}
+void proc_remove(struct proc_dir_entry *de)
+{
+	/* XXX */
+}
+int proc_nr_files(struct ctl_table *table, int write,
+		  void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+
+struct proc_dir_entry *proc_mkdir(const char *name,
+				  struct proc_dir_entry *parent)
+{
+	return __proc_create(&parent, name, S_IFDIR | S_IRUGO, 2);
+}
+
+struct proc_dir_entry *proc_mkdir_data(const char *name, umode_t mode,
+				       struct proc_dir_entry *parent,
+				       void *data)
+{
+	struct proc_dir_entry *de;
+
+	de = __proc_create(&parent, name,
+			S_IFDIR | S_IRUGO | S_IXUGO | mode, 2);
+	de->data = data;
+	return de;
+}
+
+int proc_alloc_inum(unsigned int *inum)
+{
+	*inum = 1;
+	return 0;
+}
diff --git a/arch/lib/random.c b/arch/lib/random.c
new file mode 100644
index 0000000..9fbb8bf
--- /dev/null
+++ b/arch/lib/random.c
@@ -0,0 +1,53 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include "sim.h"
+#include <linux/random.h>
+
+u32 random32(void)
+{
+	return lib_random();
+}
+
+void get_random_bytes(void *buf, int nbytes)
+{
+	char *p = (char *)buf;
+	int i;
+
+	for (i = 0; i < nbytes; i++)
+		p[i] = lib_random();
+}
+void srandom32(u32 entropy)
+{
+}
+
+u32 prandom_u32(void)
+{
+	return lib_random();
+}
+void prandom_seed(u32 entropy)
+{
+}
+
+void prandom_bytes(void *buf, size_t bytes)
+{
+	return get_random_bytes(buf, bytes);
+}
+
+#include <linux/sysctl.h>
+
+static int nothing;
+struct ctl_table random_table[] = {
+	{
+		.procname       = "nothing",
+		.data           = &nothing,
+		.maxlen         = sizeof(int),
+		.mode           = 0444,
+		.proc_handler   = proc_dointvec,
+	}
+};
diff --git a/arch/lib/security.c b/arch/lib/security.c
new file mode 100644
index 0000000..0367189
--- /dev/null
+++ b/arch/lib/security.c
@@ -0,0 +1,45 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include "linux/capability.h"
+
+struct sock;
+struct sk_buff;
+
+bool capable(int cap)
+{
+	switch (cap) {
+	case CAP_NET_RAW:
+	case CAP_NET_BIND_SERVICE:
+	case CAP_NET_ADMIN:
+		return 1;
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+int cap_netlink_recv(struct sk_buff *skb, int cap)
+{
+	return 0;
+}
+
+int cap_netlink_send(struct sock *sk, struct sk_buff *skb)
+{
+	return 0;
+}
+bool ns_capable(struct user_namespace *ns, int cap)
+{
+	return true;
+}
+bool file_ns_capable(const struct file *file, struct user_namespace *ns,
+		     int cap)
+{
+	return true;
+}
diff --git a/arch/lib/seq.c b/arch/lib/seq.c
new file mode 100644
index 0000000..72c2f5d
--- /dev/null
+++ b/arch/lib/seq.c
@@ -0,0 +1,122 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/seq_file.h>
+
+struct hlist_node *seq_hlist_next_rcu(void *v,
+				      struct hlist_head *head,
+				      loff_t *ppos)
+{
+	return 0;
+}
+struct hlist_node *seq_hlist_start_head_rcu(struct hlist_head *head,
+					    loff_t pos)
+{
+	return 0;
+}
+struct list_head *seq_list_start(struct list_head *head,
+				 loff_t pos)
+{
+	return 0;
+}
+struct list_head *seq_list_start_head(struct list_head *head,
+				      loff_t pos)
+{
+	return 0;
+}
+
+struct list_head *seq_list_next(void *v, struct list_head *head,
+				loff_t *ppos)
+{
+	return 0;
+}
+
+void *__seq_open_private(struct file *file, const struct seq_operations *ops,
+			 int psize)
+{
+	return 0;
+}
+
+int seq_open_private(struct file *file, const struct seq_operations *ops,
+		     int psize)
+{
+	return 0;
+}
+
+int seq_release_private(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+
+loff_t seq_lseek(struct file *file, loff_t offset, int origin)
+{
+	return 0;
+}
+int seq_release(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+int seq_putc(struct seq_file *m, char c)
+{
+	return 0;
+}
+int seq_puts(struct seq_file *m, const char *s)
+{
+	return 0;
+}
+ssize_t seq_read(struct file *file, char __user *buf, size_t size, loff_t *ppos)
+{
+	return 0;
+}
+int seq_open(struct file *file, const struct seq_operations *ops)
+{
+	return 0;
+}
+int seq_printf(struct seq_file *seq, const char *fmt, ...)
+{
+	return 0;
+}
+
+int seq_write(struct seq_file *seq, const void *data, size_t len)
+{
+	return 0;
+}
+
+int seq_open_net(struct inode *inode, struct file *file,
+		 const struct seq_operations *ops, int size)
+{
+	return 0;
+}
+
+int seq_release_net(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+
+
+int single_open(struct file *file, int (*cb)(struct seq_file *,
+					     void *), void *data)
+{
+	return 0;
+}
+
+int single_release(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+
+int single_open_net(struct inode *inode, struct file *file,
+		    int (*show)(struct seq_file *, void *))
+{
+	return 0;
+}
+
+int single_release_net(struct inode *inode, struct file *file)
+{
+	return 0;
+}
diff --git a/arch/lib/splice.c b/arch/lib/splice.c
new file mode 100644
index 0000000..9ecd9e5
--- /dev/null
+++ b/arch/lib/splice.c
@@ -0,0 +1,20 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include "sim.h"
+#include "sim-assert.h"
+#include <linux/fs.h>
+
+ssize_t generic_file_splice_read(struct file *in, loff_t *ppos,
+				 struct pipe_inode_info *pipe, size_t len,
+				 unsigned int flags)
+{
+	lib_assert(false);
+
+	return 0;
+}
diff --git a/arch/lib/super.c b/arch/lib/super.c
new file mode 100644
index 0000000..45a653f
--- /dev/null
+++ b/arch/lib/super.c
@@ -0,0 +1,210 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/export.h>
+#include <linux/slab.h>
+#include <linux/acct.h>
+#include <linux/blkdev.h>
+#include <linux/mount.h>
+#include <linux/security.h>
+#include <linux/writeback.h>            /* for the emergency remount stuff */
+#include <linux/idr.h>
+#include <linux/mutex.h>
+#include <linux/backing-dev.h>
+#include <linux/rculist_bl.h>
+#include <linux/cleancache.h>
+#include <linux/fsnotify.h>
+#include <linux/fs.h>
+#include <sim-assert.h>
+
+
+void put_super(struct super_block *sb)
+{
+}
+
+int grab_super(struct super_block *s)
+{
+	return 0;
+}
+void destroy_super(struct super_block *s)
+{
+}
+
+int set_anon_super(struct super_block *s, void *data)
+{
+	return 0;
+}
+
+struct super_block;
+LIST_HEAD(super_blocks);
+
+/**
+ *	alloc_super	-	create new superblock
+ *	@type:	filesystem type superblock should belong to
+ *
+ *	Allocates and initializes a new &struct super_block.  alloc_super()
+ *	returns a pointer new superblock or %NULL if allocation had failed.
+ */
+static struct super_block *alloc_super(struct file_system_type *type)
+{
+	struct super_block *s = kzalloc(sizeof(struct super_block),  GFP_USER);
+	static const struct super_operations default_op;
+
+	if (s) {
+		if (security_sb_alloc(s)) {
+			kfree(s);
+			s = NULL;
+			goto fail;
+		}
+		INIT_HLIST_NODE(&s->s_instances);
+		INIT_HLIST_BL_HEAD(&s->s_anon);
+		INIT_LIST_HEAD(&s->s_inodes);
+		if (list_lru_init(&s->s_dentry_lru))
+			goto fail;
+		if (list_lru_init(&s->s_inode_lru))
+			goto fail;
+		INIT_LIST_HEAD(&s->s_mounts);
+		init_rwsem(&s->s_umount);
+		/*
+		 * sget() can have s_umount recursion.
+		 *
+		 * When it cannot find a suitable sb, it allocates a new
+		 * one (this one), and tries again to find a suitable old
+		 * one.
+		 *
+		 * In case that succeeds, it will acquire the s_umount
+		 * lock of the old one. Since these are clearly distrinct
+		 * locks, and this object isn't exposed yet, there's no
+		 * risk of deadlocks.
+		 *
+		 * Annotate this by putting this lock in a different
+		 * subclass.
+		 */
+		down_write_nested(&s->s_umount, SINGLE_DEPTH_NESTING);
+		s->s_count = 1;
+		atomic_set(&s->s_active, 1);
+		mutex_init(&s->s_vfs_rename_mutex);
+		lockdep_set_class(&s->s_vfs_rename_mutex,
+				  &type->s_vfs_rename_key);
+		mutex_init(&s->s_dquot.dqio_mutex);
+		mutex_init(&s->s_dquot.dqonoff_mutex);
+		s->s_maxbytes = MAX_NON_LFS;
+		s->s_op = &default_op;
+		s->s_time_gran = 1000000000;
+		s->cleancache_poolid = -1;
+
+		s->s_shrink.seeks = DEFAULT_SEEKS;
+		s->s_shrink.batch = 1024;
+		return s;
+	}
+fail:
+	destroy_super(s);
+	return NULL;
+}
+
+/**
+ *	deactivate_locked_super	-	drop an active reference to superblock
+ *	@s: superblock to deactivate
+ *
+ *	Drops an active reference to superblock, converting it into a temprory
+ *	one if there is no other active references left.  In that case we
+ *	tell fs driver to shut it down and drop the temporary reference we
+ *	had just acquired.
+ *
+ *	Caller holds exclusive lock on superblock; that lock is released.
+ */
+void deactivate_locked_super(struct super_block *s)
+{
+	struct file_system_type *fs = s->s_type;
+
+	if (atomic_dec_and_test(&s->s_active)) {
+		cleancache_invalidate_fs(s);
+		fs->kill_sb(s);
+
+		/* caches are now gone, we can safely kill the shrinker now */
+		unregister_shrinker(&s->s_shrink);
+
+		/*
+		 * We need to call rcu_barrier so all the delayed rcu free
+		 * inodes are flushed before we release the fs module.
+		 */
+		rcu_barrier();
+		put_filesystem(fs);
+		put_super(s);
+	} else
+		up_write(&s->s_umount);
+}
+
+/* from fs/super.c */
+DEFINE_SPINLOCK(sb_lock);
+/**
+ *	sget	-	find or create a superblock
+ *	@type:	filesystem type superblock should belong to
+ *	@test:	comparison callback
+ *	@set:	setup callback
+ *	@data:	argument to each of them
+ */
+struct super_block *sget(struct file_system_type *type,
+			 int (*test)(struct super_block *, void *),
+			 int (*set)(struct super_block *, void *),
+			 int flags, void *data)
+{
+	struct super_block *s = NULL;
+	struct super_block *old;
+	int err;
+
+retry:
+	spin_lock(&sb_lock);
+	if (test) {
+		hlist_for_each_entry(old, &type->fs_supers, s_instances) {
+			if (!test(old, data))
+				continue;
+			if (!grab_super(old))
+				goto retry;
+			if (s) {
+				up_write(&s->s_umount);
+				destroy_super(s);
+				s = NULL;
+			}
+			down_write(&old->s_umount);
+			if (unlikely(!(old->s_flags & MS_BORN))) {
+				deactivate_locked_super(old);
+				goto retry;
+			}
+			return old;
+		}
+	}
+	if (!s) {
+		spin_unlock(&sb_lock);
+		s = alloc_super(type);
+		if (!s)
+			return ERR_PTR(-ENOMEM);
+		goto retry;
+	}
+
+	err = set(s, data);
+	if (err) {
+		spin_unlock(&sb_lock);
+		up_write(&s->s_umount);
+		destroy_super(s);
+		return ERR_PTR(err);
+	}
+	s->s_type = type;
+	strlcpy(s->s_id, type->name, sizeof(s->s_id));
+	list_add_tail(&s->s_list, &super_blocks);
+	hlist_add_head(&s->s_instances, &type->fs_supers);
+	spin_unlock(&sb_lock);
+/*	get_filesystem(type); */
+/*	register_shrinker(&s->s_shrink); */
+	return s;
+}
+
+void kill_anon_super(struct super_block *sb)
+{
+
+}
diff --git a/arch/lib/sysfs.c b/arch/lib/sysfs.c
new file mode 100644
index 0000000..2def2ca
--- /dev/null
+++ b/arch/lib/sysfs.c
@@ -0,0 +1,83 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/sysfs.h>
+#include <linux/kobject.h>
+#include "sim.h"
+#include "sim-assert.h"
+
+int sysfs_create_bin_file(struct kobject *kobj,
+			  const struct bin_attribute *attr)
+{
+	return 0;
+}
+void sysfs_remove_bin_file(struct kobject *kobj,
+			   const struct bin_attribute *attr)
+{
+}
+int sysfs_create_dir(struct kobject *kobj)
+{
+	return 0;
+}
+int sysfs_create_link(struct kobject *kobj, struct kobject *target,
+		      const char *name)
+{
+	return 0;
+}
+int sysfs_move_dir(struct kobject *kobj,
+		   struct kobject *new_parent_kobj)
+{
+	return 0;
+}
+void sysfs_remove_dir(struct kobject *kobj)
+{
+}
+void sysfs_remove_group(struct kobject *kobj,
+			const struct attribute_group *grp)
+{
+}
+int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
+{
+	return 0;
+}
+int __must_check sysfs_create_group(struct kobject *kobj,
+				    const struct attribute_group *grp)
+{
+	return 0;
+}
+int sysfs_create_groups(struct kobject *kobj,
+			const struct attribute_group **groups)
+{
+	return 0;
+}
+int sysfs_schedule_callback(struct kobject *kobj,
+			    void (*func)(
+				    void *), void *data, struct module *owner)
+{
+	return 0;
+}
+void sysfs_delete_link(struct kobject *dir, struct kobject *targ,
+		       const char *name)
+{
+}
+void sysfs_exit_ns(enum kobj_ns_type type, const void *tag)
+{
+}
+void sysfs_notify(struct kobject *kobj, const char *dir, const char *attr)
+{
+}
+int sysfs_create_dir_ns(struct kobject *kobj, const void *ns)
+{
+	kobj->sd = lib_malloc(sizeof(struct kernfs_node));
+	return 0;
+}
+int sysfs_create_file_ns(struct kobject *kobj, const struct attribute *attr,
+			 const void *ns)
+{
+	return 0;
+}
diff --git a/arch/lib/vmscan.c b/arch/lib/vmscan.c
new file mode 100644
index 0000000..3132f66
--- /dev/null
+++ b/arch/lib/vmscan.c
@@ -0,0 +1,26 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ */
+
+#include <linux/mm.h>
+#include <linux/shrinker.h>
+
+/*
+ * Add a shrinker callback to be called from the vm
+ */
+int register_shrinker(struct shrinker *shrinker)
+{
+	return 0;
+}
+
+/*
+ * Remove one
+ */
+void unregister_shrinker(struct shrinker *shrinker)
+{
+}
+
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
