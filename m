Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74D4E6B0260
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 19:50:40 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so26916113pac.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:40 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id k184si2740493pge.108.2016.10.11.16.50.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 16:50:39 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id ry6so22289700pac.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:39 -0700 (PDT)
From: Ruchi Kandoi <kandoiruchi@google.com>
Subject: [RFC 2/6] drivers: misc: add memtrack
Date: Tue, 11 Oct 2016 16:50:06 -0700
Message-Id: <1476229810-26570-3-git-send-email-kandoiruchi@google.com>
In-Reply-To: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
References: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kandoiruchi@google.com, gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, sumit.semwal@linaro.org, arnd@arndb.de, labbott@redhat.com, viro@zeniv.linux.org.uk, jlayton@poochiereds.net, bfields@fieldses.org, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, keescook@chromium.org, mhocko@suse.com, oleg@redhat.com, john.stultz@linaro.org, mguzik@redhat.com, jdanis@google.com, adobriyan@gmail.com, ghackmann@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@kernel.org, tj@kernel.org, vdavydov.dev@gmail.com, ebiederm@xmission.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Shared-buffer allocators like ion or GEM traditionally call into CMA or
alloc_pages() to get backing memory, meaning these allocations will not
show up in any process's mm counters.  But since these allocations are
often used for things like graphics buffers that can be extremely large,
the user just sees a bunch of pages vanishing from the system without an
explanation.

CONFIG_MEMTRACK adds infrastructure for "blaming" these allocations back
to the processes currently holding a reference to the shared buffer.
This information is exposed to userspace through /proc/[pid]/memtrack.

To use memtrack, the shared memory allocator should:

(1) Embed a struct memtrack_buffer somewhere in the underlying buffer's
    metadata, and initialize it with memtrack_buffer_init()

(3) Call memtrack_buffer_{install,uninstall} each time a task takes or
    drops a reference to the shared buffer

(3) Call memtrack_buffer_remove() before destroying a tracked buffer

CONFIG_MEMTRACK_DEBUG adds a global list of all buffers tracked by
memtrack, accessible through /sys/kernel/debug/memtrack.  This involves
maintaining a global idr of buffers.  Due to the extra overhead,
CONFIG_MEMTRACK_DEBUG is intended for debugging memory leaks rather than
production use.

Signed-off-by: Greg Hackmann <ghackmann@google.com>
Signed-off-by: Ruchi Kandoi <kandoiruchi@google.com>
---
 drivers/misc/Kconfig     |  16 +++
 drivers/misc/Makefile    |   1 +
 drivers/misc/memtrack.c  | 360 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/proc/base.c           |   4 +
 include/linux/memtrack.h |  94 +++++++++++++
 include/linux/sched.h    |   3 +
 kernel/fork.c            |   4 +
 7 files changed, 482 insertions(+)
 create mode 100644 drivers/misc/memtrack.c
 create mode 100644 include/linux/memtrack.h

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 64971ba..7557fb1 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -766,6 +766,22 @@ config PANEL_BOOT_MESSAGE
 	  An empty message will only clear the display at driver init time. Any other
 	  printf()-formatted message is valid with newline and escape codes.
 
+config MEMTRACK
+	tristate "Per-pid memory statistics"
+	default n
+	---help---
+	  Keeps track of shared buffers allocated by the process and
+	  exports them via /proc/<pid>/memtrack.
+
+config MEMTRACK_DEBUG
+	tristate "Per-pid memory statistics debug option"
+	depends on MEMTRACK && DEBUG_FS
+	default n
+	---help---
+	  Keeps track of all shared buffers allocated and exports the list
+	  via /sys/kernel/debug/memtrack.
+
+ source "drivers/misc/c2port/Kconfig"
 source "drivers/misc/c2port/Kconfig"
 source "drivers/misc/eeprom/Kconfig"
 source "drivers/misc/cb710/Kconfig"
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 3198336..1fbb084 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -68,3 +68,4 @@ OBJCOPYFLAGS_lkdtm_rodata_objcopy.o := \
 targets += lkdtm_rodata.o lkdtm_rodata_objcopy.o
 $(obj)/lkdtm_rodata_objcopy.o: $(obj)/lkdtm_rodata.o FORCE
 	$(call if_changed,objcopy)
+obj-$(CONFIG_MEMTRACK)          += memtrack.o
diff --git a/drivers/misc/memtrack.c b/drivers/misc/memtrack.c
new file mode 100644
index 0000000..e5c7e03
--- /dev/null
+++ b/drivers/misc/memtrack.c
@@ -0,0 +1,360 @@
+/* drivers/misc/memtrack.c
+ *
+ * Copyright (C) 2016 Google, Inc.
+ *
+ * This software is licensed under the terms of the GNU General Public
+ * License version 2, as published by the Free Software Foundation, and
+ * may be copied, distributed, and modified under those terms.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+#include <linux/debugfs.h>
+#include <linux/device.h>
+#include <linux/fs.h>
+#include <linux/idr.h>
+#include <linux/init.h>
+#include <linux/memtrack.h>
+#include <linux/profile.h>
+#include <linux/rbtree.h>
+#include <linux/seq_file.h>
+#include <linux/slab.h>
+
+struct memtrack_handle {
+	struct memtrack_buffer *buffer;
+	struct rb_node node;
+	struct rb_root *root;
+	struct kref refcount;
+};
+
+static struct kmem_cache *memtrack_handle_cache;
+
+static DEFINE_MUTEX(memtrack_id_lock);
+#if IS_ENABLED(CONFIG_MEMTRACK_DEBUG)
+static struct dentry *debugfs_file;
+static DEFINE_IDR(mem_idr);
+#else
+static DEFINE_IDA(mem_ida);
+#endif
+
+static void memtrack_buffer_install_locked(struct rb_root *root,
+		struct memtrack_buffer *buffer)
+{
+	struct rb_node **new = &root->rb_node, *parent = NULL;
+	struct memtrack_handle *handle;
+
+	while (*new) {
+		struct rb_node *node = *new;
+
+		handle = rb_entry(node, struct memtrack_handle, node);
+		parent = node;
+		if (handle->buffer->id > buffer->id) {
+			new = &node->rb_left;
+		} else if (handle->buffer->id < buffer->id) {
+			new = &node->rb_right;
+		} else {
+			kref_get(&handle->refcount);
+			return;
+		}
+	}
+
+	handle = kmem_cache_alloc(memtrack_handle_cache, GFP_KERNEL);
+	if (!handle)
+		return;
+
+	handle->buffer = buffer;
+	handle->root = root;
+	kref_init(&handle->refcount);
+
+	rb_link_node(&handle->node, parent, new);
+	rb_insert_color(&handle->node, root);
+	atomic_inc(&handle->buffer->userspace_handles);
+}
+
+/**
+ * memtrack_buffer_install - add a userspace reference to a shared buffer
+ *
+ * @buffer: the buffer's memtrack entry
+ * @tsk: the userspace task that took the reference
+ *
+ * This is normally called while creating a userspace handle (fd, etc.) to
+ * @buffer.
+ */
+void memtrack_buffer_install(struct memtrack_buffer *buffer,
+		struct task_struct *tsk)
+{
+	struct task_struct *leader;
+	unsigned long flags;
+
+	if (!buffer || !tsk)
+		return;
+
+	leader = tsk->group_leader;
+	write_lock_irqsave(&leader->memtrack_lock, flags);
+	memtrack_buffer_install_locked(&leader->memtrack_rb, buffer);
+	write_unlock_irqrestore(&leader->memtrack_lock, flags);
+}
+EXPORT_SYMBOL(memtrack_buffer_install);
+
+static void memtrack_handle_destroy(struct kref *ref)
+{
+	struct memtrack_handle *handle;
+
+	handle = container_of(ref, struct memtrack_handle, refcount);
+	rb_erase(&handle->node, handle->root);
+	atomic_dec(&handle->buffer->userspace_handles);
+	kmem_cache_free(memtrack_handle_cache, handle);
+}
+
+static void memtrack_buffer_uninstall_locked(struct rb_root *root,
+		struct memtrack_buffer *buffer)
+{
+	struct rb_node *node = root->rb_node;
+
+	while (node) {
+		struct memtrack_handle *handle = rb_entry(node,
+				struct memtrack_handle, node);
+
+		if (handle->buffer->id > buffer->id) {
+			node = node->rb_left;
+		} else if (handle->buffer->id < buffer->id) {
+			node = node->rb_right;
+		} else {
+			kref_put(&handle->refcount, memtrack_handle_destroy);
+			return;
+		}
+	}
+}
+
+/**
+ * memtrack_buffer_uninstall - drop a userspace reference to a shared buffer
+ *
+ * @buffer: the buffer's memtrack entry
+ * @tsk: the userspace task that dropped the reference
+ *
+ * This is normally called while tearing down a userspace handle to @buffer.
+ */
+void memtrack_buffer_uninstall(struct memtrack_buffer *buffer,
+		struct task_struct *tsk)
+{
+	struct task_struct *leader;
+	unsigned long flags;
+
+	if (!buffer || !tsk)
+		return;
+
+	leader = tsk->group_leader;
+	write_lock_irqsave(&leader->memtrack_lock, flags);
+	memtrack_buffer_uninstall_locked(&leader->memtrack_rb, buffer);
+	write_unlock_irqrestore(&leader->memtrack_lock, flags);
+}
+EXPORT_SYMBOL(memtrack_buffer_uninstall);
+
+static int memtrack_id_alloc(struct memtrack_buffer *buffer)
+{
+	int ret;
+
+	mutex_lock(&memtrack_id_lock);
+#if IS_ENABLED(CONFIG_MEMTRACK_DEBUG)
+	ret = idr_alloc(&mem_idr, buffer, 0, 0, GFP_KERNEL);
+#else
+	ret = ida_simple_get(&mem_ida, 0, 0, GFP_KERNEL);
+#endif
+	mutex_unlock(&memtrack_id_lock);
+
+	return ret;
+}
+
+static void memtrack_id_free(struct memtrack_buffer *buffer)
+{
+	mutex_lock(&memtrack_id_lock);
+#if IS_ENABLED(CONFIG_MEMTRACK_DEBUG)
+	idr_remove(&mem_idr, buffer->id);
+#else
+	ida_simple_remove(&mem_ida, buffer->id);
+#endif
+	mutex_unlock(&memtrack_id_lock);
+}
+
+/**
+ * memtrack_buffer_remove - deinitialize a memtrack entry
+ *
+ * @buffer: the memtrack entry to deinitialize
+ *
+ * This is normally called just before freeing the pages backing @buffer.
+ */
+void memtrack_buffer_remove(struct memtrack_buffer *buffer)
+{
+	if (!buffer)
+		return;
+
+	if (WARN_ON(atomic_read(&buffer->userspace_handles)))
+		return;
+
+	kfree(buffer->tag);
+	memtrack_id_free(buffer);
+}
+EXPORT_SYMBOL(memtrack_buffer_remove);
+
+/**
+ * memtrack_buffer_init - initialize a memtrack entry for a shared buffer
+ *
+ * @buffer: the memtrack entry to initialize
+ * @size: the size of the shared buffer
+ *
+ * This is normally called just after allocating the buffer's backing pages.
+ *
+ * There must be a 1-to-1 mapping between buffers and
+ * struct memtrack_buffers.  That is, memtrack_buffer_init() should be called
+ * only *once* for a given buffer, even if it's exported to
+ * userspace in multiple forms (e.g., simultaneously as a dma-buf fd and a
+ * GEM handle).
+ *
+ * Return 0 on success or a negative error code on failure.
+ */
+int memtrack_buffer_init(struct memtrack_buffer *buffer, size_t size)
+{
+	if (!buffer)
+		return -EINVAL;
+
+	memset(buffer, 0, sizeof(*buffer));
+
+	buffer->id = memtrack_id_alloc(buffer);
+	if (buffer->id < 0) {
+		pr_err("%s: Error allocating unique identifier\n", __func__);
+		return buffer->id;
+	}
+
+	buffer->size = size;
+	atomic_set(&buffer->userspace_handles, 0);
+#if IS_ENABLED(CONFIG_MEMTRACK_DEBUG)
+	buffer->pid = current->group_leader->pid;
+#endif
+	return 0;
+}
+EXPORT_SYMBOL(memtrack_buffer_init);
+
+static int process_notifier(struct notifier_block *self,
+			unsigned long cmd, void *v)
+{
+	struct task_struct *task = v, *leader;
+	struct rb_root *root;
+	struct rb_node *node;
+	unsigned long flags;
+
+	if (!task)
+		return NOTIFY_OK;
+
+	leader = task->group_leader;
+	write_lock_irqsave(&leader->memtrack_lock, flags);
+	root = &leader->memtrack_rb;
+	node = rb_first(root);
+	while (node) {
+		struct memtrack_handle *handle;
+
+		handle = rb_entry(node, struct memtrack_handle, node);
+		rb_erase(&handle->node, handle->root);
+		atomic_dec(&handle->buffer->userspace_handles);
+		kmem_cache_free(memtrack_handle_cache, handle);
+
+		node = rb_next(node);
+	}
+	write_unlock_irqrestore(&leader->memtrack_lock, flags);
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block process_notifier_block = {
+	.notifier_call	= process_notifier,
+};
+
+int proc_memtrack(struct seq_file *m, struct pid_namespace *ns, struct pid *pid,
+			struct task_struct *task)
+{
+	struct rb_node *node;
+	unsigned long flags;
+
+	read_lock_irqsave(&task->memtrack_lock, flags);
+	if (RB_EMPTY_ROOT(&task->memtrack_rb))
+		goto done;
+
+	seq_printf(m, "%10.10s: %16.16s: %12.12s: %3.3s: pid:%d\n",
+			"ref_count", "Identifier", "size", "tag", task->pid);
+
+	for (node = rb_first(&task->memtrack_rb); node; node = rb_next(node)) {
+		struct memtrack_handle *handle = rb_entry(node,
+				struct memtrack_handle, node);
+		struct memtrack_buffer *buffer = handle->buffer;
+
+		seq_printf(m, "%10d  %16d  %12zu  %s\n",
+				atomic_read(&buffer->userspace_handles),
+				buffer->id, buffer->size,
+				buffer->tag ? buffer->tag : "");
+	}
+
+done:
+	read_unlock_irqrestore(&task->memtrack_lock, flags);
+	return 0;
+}
+
+#if IS_ENABLED(CONFIG_MEMTRACK_DEBUG)
+static int memtrack_show(struct seq_file *m, void *v)
+{
+	struct memtrack_buffer *buffer;
+	int i;
+
+	seq_printf(m, "%4.4s %12.12s %10s %12.12s %3.3s\n", "pid",
+			"buffer_size", "ref", "Identifier", "tag");
+
+	rcu_read_lock();
+	idr_for_each_entry(&mem_idr, buffer, i)
+		seq_printf(m, "%4d %12zu %10d %12d %s\n", buffer->pid,
+				buffer->size,
+				atomic_read(&buffer->userspace_handles),
+				buffer->id, buffer->tag ? buffer->tag : "");
+	rcu_read_unlock();
+	return 0;
+}
+
+static int memtrack_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, memtrack_show, inode->i_private);
+}
+
+static const struct file_operations memtrack_fops = {
+	.open		= memtrack_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+#endif
+
+
+static int __init memtrack_init(void)
+{
+	memtrack_handle_cache = KMEM_CACHE(memtrack_handle, SLAB_HWCACHE_ALIGN);
+	if (!memtrack_handle_cache)
+		return -ENOMEM;
+
+#if IS_ENABLED(CONFIG_MEMTRACK_DEBUG)
+	debugfs_file = debugfs_create_file("memtrack", S_IRUGO, NULL, NULL,
+			&memtrack_fops);
+#endif
+
+	profile_event_register(PROFILE_TASK_EXIT, &process_notifier_block);
+	return 0;
+}
+late_initcall(memtrack_init);
+
+static void __exit memtrack_exit(void)
+{
+	kmem_cache_destroy(memtrack_handle_cache);
+#if IS_ENABLED(CONFIG_MEMTRACK_DEBUG)
+	debugfs_remove(debugfs_file);
+#endif
+	profile_event_unregister(PROFILE_TASK_EXIT, &process_notifier_block);
+}
+__exitcall(memtrack_exit);
diff --git a/fs/proc/base.c b/fs/proc/base.c
index c2964d8..5ed9d90 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -87,6 +87,7 @@
 #include <linux/slab.h>
 #include <linux/flex_array.h>
 #include <linux/posix-timers.h>
+#include <linux/memtrack.h>
 #ifdef CONFIG_HARDWALL
 #include <asm/hardwall.h>
 #endif
@@ -2932,6 +2933,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 	REG("timers",	  S_IRUGO, proc_timers_operations),
 #endif
 	REG("timerslack_ns", S_IRUGO|S_IWUGO, proc_pid_set_timerslack_ns_operations),
+#ifdef CONFIG_MEMTRACK
+	ONE("memtrack", S_IRUGO, proc_memtrack),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file *file, struct dir_context *ctx)
diff --git a/include/linux/memtrack.h b/include/linux/memtrack.h
new file mode 100644
index 0000000..f73be07
--- /dev/null
+++ b/include/linux/memtrack.h
@@ -0,0 +1,94 @@
+/* include/linux/memtrack.h
+ *
+ * Copyright (C) 2016 Google, Inc.
+ *
+ * This software is licensed under the terms of the GNU General Public
+ * License version 2, as published by the Free Software Foundation, and
+ * may be copied, distributed, and modified under those terms.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#ifndef _MEMTRACK_
+#define _MEMTRACK_
+
+#include <linux/fs.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+
+#ifdef CONFIG_MEMTRACK
+struct memtrack_buffer {
+	size_t size;
+	atomic_t userspace_handles;
+	int id;
+	const char *tag;
+#ifdef CONFIG_MEMTRACK_DEBUG
+	pid_t pid;
+#endif
+};
+
+int proc_memtrack(struct seq_file *m, struct pid_namespace *ns, struct pid *pid,
+		struct task_struct *task);
+int memtrack_buffer_init(struct memtrack_buffer *buffer, size_t size);
+void memtrack_buffer_remove(struct memtrack_buffer *buffer);
+void memtrack_buffer_install(struct memtrack_buffer *buffer,
+		struct task_struct *tsk);
+void memtrack_buffer_uninstall(struct memtrack_buffer *buffer,
+		struct task_struct *tsk);
+
+/**
+ * memtrack_buffer_set_tag - add a descriptive tag to a memtrack entry
+ *
+ * @buffer: the memtrack entry to tag
+ * @tag: a string describing the buffer
+ *
+ * The tag is optional and provided only as information to userspace.  It has
+ * no special meaning in the kernel.
+ */
+static inline int memtrack_buffer_set_tag(struct memtrack_buffer *buffer,
+		const char *tag)
+{
+	const char *d = kstrdup(tag, GFP_KERNEL);
+
+	if (!d)
+		return -ENOMEM;
+
+	kfree(buffer->tag);
+	buffer->tag = d;
+	return 0;
+}
+#else
+struct memtrack_buffer { };
+
+static inline int memtrack_buffer_init(struct memtrack_buffer *buffer,
+		size_t size)
+{
+	return -ENOENT;
+}
+
+static inline void memtrack_buffer_remove(struct memtrack_buffer *buffer)
+{
+}
+
+static inline void memtrack_buffer_install(struct memtrack_buffer *buffer,
+		struct task_struct *tsk)
+{
+}
+
+static inline void memtrack_buffer_uninstall(struct memtrack_buffer *buffer,
+		struct task_struct *tsk)
+{
+}
+
+static inline int memtrack_buffer_set_tag(struct memtrack_buffer *buffer,
+		const char *tag)
+{
+	return -ENOENT;
+}
+
+#endif /* CONFIG_MEMTRACK */
+#endif /* _MEMTRACK_ */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 348f51b..995a94d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1954,6 +1954,9 @@ struct task_struct {
 #ifdef CONFIG_THREAD_INFO_IN_TASK
 	/* A live task holds one reference. */
 	atomic_t stack_refcount;
+#ifdef CONFIG_MEMTRACK
+	struct rb_root memtrack_rb;
+	rwlock_t memtrack_lock;
 #endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
diff --git a/kernel/fork.c b/kernel/fork.c
index 6d42242..da8537a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1615,6 +1615,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->sequential_io	= 0;
 	p->sequential_io_avg	= 0;
 #endif
+#ifdef CONFIG_MEMTRACK
+	p->memtrack_rb = RB_ROOT;
+	rwlock_init(&p->memtrack_lock);
+#endif
 
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
