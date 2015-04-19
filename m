Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8BB246B0074
	for <linux-mm@kvack.org>; Sun, 19 Apr 2015 09:29:21 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so180301281pdb.2
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 06:29:21 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [203.178.142.130])
        by mx.google.com with ESMTPS id rs11si24251476pab.141.2015.04.19.06.29.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Apr 2015 06:29:20 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [RFC PATCH v3 07/10] lib: other kernel glue layer code
Date: Sun, 19 Apr 2015 22:28:21 +0900
Message-Id: <1429450104-47619-8-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1429450104-47619-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1429450104-47619-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

These files are used to provide the same function calls so that other
network stack code keeps untouched.

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Signed-off-by: Christoph Paasch <christoph.paasch@gmail.com>
---
 arch/lib/capability.c |  47 +++++++++
 arch/lib/filemap.c    |  32 ++++++
 arch/lib/fs.c         |  70 +++++++++++++
 arch/lib/glue.c       | 283 ++++++++++++++++++++++++++++++++++++++++++++++++++
 arch/lib/modules.c    |  36 +++++++
 arch/lib/pid.c        |  29 ++++++
 arch/lib/print.c      |  56 ++++++++++
 arch/lib/proc.c       |  34 ++++++
 arch/lib/random.c     |  53 ++++++++++
 arch/lib/sysfs.c      |  83 +++++++++++++++
 arch/lib/vmscan.c     |  26 +++++
 11 files changed, 749 insertions(+)
 create mode 100644 arch/lib/capability.c
 create mode 100644 arch/lib/filemap.c
 create mode 100644 arch/lib/fs.c
 create mode 100644 arch/lib/glue.c
 create mode 100644 arch/lib/modules.c
 create mode 100644 arch/lib/pid.c
 create mode 100644 arch/lib/print.c
 create mode 100644 arch/lib/proc.c
 create mode 100644 arch/lib/random.c
 create mode 100644 arch/lib/sysfs.c
 create mode 100644 arch/lib/vmscan.c

diff --git a/arch/lib/capability.c b/arch/lib/capability.c
new file mode 100644
index 0000000..7054fea
--- /dev/null
+++ b/arch/lib/capability.c
@@ -0,0 +1,47 @@
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
+int file_caps_enabled = 0;
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
diff --git a/arch/lib/filemap.c b/arch/lib/filemap.c
new file mode 100644
index 0000000..ce424ff
--- /dev/null
+++ b/arch/lib/filemap.c
@@ -0,0 +1,32 @@
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
+ssize_t
+generic_file_read_iter(struct kiocb *iocb, struct iov_iter *iter)
+{
+	return 0;
+}
diff --git a/arch/lib/fs.c b/arch/lib/fs.c
new file mode 100644
index 0000000..324e10b
--- /dev/null
+++ b/arch/lib/fs.c
@@ -0,0 +1,70 @@
+/*
+ * glue code for library version of Linux kernel
+ * Copyright (c) 2015 INRIA, Hajime Tazaki
+ *
+ * Author: Mathieu Lacage <mathieu.lacage@gmail.com>
+ *         Hajime Tazaki <tazaki@sfc.wide.ad.jp>
+ *         Frederic Urbani
+ */
+
+#include <fs/mount.h>
+
+#include "sim-assert.h"
+
+__cacheline_aligned_in_smp DEFINE_SEQLOCK(mount_lock);
+unsigned int dirtytime_expire_interval;
+
+void __init mnt_init(void)
+{
+}
+
+/* Implementation taken from vfs_kern_mount from linux/namespace.c */
+struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
+{
+	static struct mount local_mnt;
+	static int count = 0;
+	struct mount *mnt = &local_mnt;
+	struct dentry *root = 0;
+
+	/* XXX */
+	if (count != 0) return &local_mnt.mnt;
+	count++;
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
+void inode_wait_for_writeback(struct inode *inode)
+{
+}
+void truncate_inode_pages_final(struct address_space *mapping)
+{
+}
+int dirtytime_interval_handler(struct ctl_table *table, int write,
+			       void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return -ENOSYS;
+}
+
+unsigned int nr_free_buffer_pages(void)
+{
+	return 1024;
+}
diff --git a/arch/lib/glue.c b/arch/lib/glue.c
new file mode 100644
index 0000000..928040d
--- /dev/null
+++ b/arch/lib/glue.c
@@ -0,0 +1,283 @@
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
+#include <linux/backing-dev.h>
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
+static DECLARE_BITMAP(cpu_possible_bits, CONFIG_NR_CPUS) __read_mostly;
+const struct cpumask *const cpu_possible_mask = to_cpumask(cpu_possible_bits);
+
+struct backing_dev_info noop_backing_dev_info = {
+	.name		= "noop",
+	.capabilities	= 0,
+};
+
+/* from rt.c */
+int sched_rr_timeslice = RR_TIMESLICE;
+/* from main.c */
+bool initcall_debug;
+bool static_key_initialized __read_mostly = false;
+unsigned long __start_rodata, __end_rodata;
+
+unsigned long arch_local_save_flags(void)
+{
+	return local_irqflags;
+}
+void arch_local_irq_restore(unsigned long flags)
+{
+	local_irqflags = flags;
+}
+
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
+#include <linux/vmalloc.h>
+#include <linux/kmemleak.h>
+
+static unsigned long __meminitdata nr_kernel_pages = 8192;
+static unsigned long __meminitdata nr_all_pages = 81920;
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
+void async_synchronize_full(void)
+{
+	/* called from drivers/base/ *.c */
+	/* there is nothing to do, really. */
+}
+
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
index 0000000..5507730
--- /dev/null
+++ b/arch/lib/proc.c
@@ -0,0 +1,34 @@
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
+
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
