Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE5246B0263
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 19:50:44 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rz1so27209048pab.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:44 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id u5si6179936pfa.187.2016.10.11.16.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 16:50:44 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id 190so9745117pfv.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:44 -0700 (PDT)
From: Ruchi Kandoi <kandoiruchi@google.com>
Subject: [RFC 4/6] memtrack: Adds the accounting to keep track of all mmaped/unmapped pages.
Date: Tue, 11 Oct 2016 16:50:08 -0700
Message-Id: <1476229810-26570-5-git-send-email-kandoiruchi@google.com>
In-Reply-To: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
References: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kandoiruchi@google.com, gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, sumit.semwal@linaro.org, arnd@arndb.de, labbott@redhat.com, viro@zeniv.linux.org.uk, jlayton@poochiereds.net, bfields@fieldses.org, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, keescook@chromium.org, mhocko@suse.com, oleg@redhat.com, john.stultz@linaro.org, mguzik@redhat.com, jdanis@google.com, adobriyan@gmail.com, ghackmann@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@kernel.org, tj@kernel.org, vdavydov.dev@gmail.com, ebiederm@xmission.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Since mmaped pages will be accounted by the PSS, memtrack needs a way
to differentiate the total memory that hasn't been accounted for.

Signed-off-by: Ruchi Kandoi <kandoiruchi@google.com>
Signed-off-by: Greg Hackmann <ghackmann@google.com>
---
 drivers/misc/memtrack.c           | 175 ++++++++++++++++++++++++++++++++------
 drivers/staging/android/ion/ion.c |   5 +-
 include/linux/memtrack.h          |  29 +++++++
 3 files changed, 180 insertions(+), 29 deletions(-)

diff --git a/drivers/misc/memtrack.c b/drivers/misc/memtrack.c
index e5c7e03..4b2d17f 100644
--- a/drivers/misc/memtrack.c
+++ b/drivers/misc/memtrack.c
@@ -22,12 +22,19 @@
 #include <linux/rbtree.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
+
+struct memtrack_vma_list {
+	struct hlist_node node;
+	const struct vm_area_struct *vma;
+};
 
 struct memtrack_handle {
 	struct memtrack_buffer *buffer;
 	struct rb_node node;
 	struct rb_root *root;
 	struct kref refcount;
+	struct hlist_head vma_list;
 };
 
 static struct kmem_cache *memtrack_handle_cache;
@@ -40,8 +47,8 @@ static DEFINE_IDR(mem_idr);
 static DEFINE_IDA(mem_ida);
 #endif
 
-static void memtrack_buffer_install_locked(struct rb_root *root,
-		struct memtrack_buffer *buffer)
+static struct memtrack_handle *memtrack_handle_find_locked(struct rb_root *root,
+		struct memtrack_buffer *buffer, bool alloc)
 {
 	struct rb_node **new = &root->rb_node, *parent = NULL;
 	struct memtrack_handle *handle;
@@ -56,22 +63,38 @@ static void memtrack_buffer_install_locked(struct rb_root *root,
 		} else if (handle->buffer->id < buffer->id) {
 			new = &node->rb_right;
 		} else {
-			kref_get(&handle->refcount);
-			return;
+			return handle;
 		}
 	}
 
-	handle = kmem_cache_alloc(memtrack_handle_cache, GFP_KERNEL);
-	if (!handle)
-		return;
+	if (alloc) {
+		handle = kmem_cache_alloc(memtrack_handle_cache, GFP_KERNEL);
+		if (!handle)
+			return NULL;
 
-	handle->buffer = buffer;
-	handle->root = root;
-	kref_init(&handle->refcount);
+		handle->buffer = buffer;
+		handle->root = root;
+		kref_init(&handle->refcount);
+		INIT_HLIST_HEAD(&handle->vma_list);
 
-	rb_link_node(&handle->node, parent, new);
-	rb_insert_color(&handle->node, root);
-	atomic_inc(&handle->buffer->userspace_handles);
+		rb_link_node(&handle->node, parent, new);
+		rb_insert_color(&handle->node, root);
+		atomic_inc(&handle->buffer->userspace_handles);
+	}
+
+	return NULL;
+}
+
+static void memtrack_buffer_install_locked(struct rb_root *root,
+		struct memtrack_buffer *buffer)
+{
+	struct memtrack_handle *handle;
+
+	handle = memtrack_handle_find_locked(root, buffer, true);
+	if (handle) {
+		kref_get(&handle->refcount);
+		return;
+	}
 }
 
 /**
@@ -112,19 +135,41 @@ static void memtrack_handle_destroy(struct kref *ref)
 static void memtrack_buffer_uninstall_locked(struct rb_root *root,
 		struct memtrack_buffer *buffer)
 {
-	struct rb_node *node = root->rb_node;
+	struct memtrack_handle *handle;
 
-	while (node) {
-		struct memtrack_handle *handle = rb_entry(node,
-				struct memtrack_handle, node);
+	handle = memtrack_handle_find_locked(root, buffer, false);
 
-		if (handle->buffer->id > buffer->id) {
-			node = node->rb_left;
-		} else if (handle->buffer->id < buffer->id) {
-			node = node->rb_right;
-		} else {
-			kref_put(&handle->refcount, memtrack_handle_destroy);
-			return;
+	if (handle)
+		kref_put(&handle->refcount, memtrack_handle_destroy);
+}
+
+static void memtrack_buffer_vm_open_locked(struct rb_root *root,
+		struct memtrack_buffer *buffer,
+		struct memtrack_vma_list *vma_list)
+{
+	struct memtrack_handle *handle;
+
+	handle = memtrack_handle_find_locked(root, buffer, false);
+	if (handle)
+		hlist_add_head(&vma_list->node, &handle->vma_list);
+}
+
+static void memtrack_buffer_vm_close_locked(struct rb_root *root,
+		struct memtrack_buffer *buffer,
+		const struct vm_area_struct *vma)
+{
+	struct memtrack_handle *handle;
+
+	handle = memtrack_handle_find_locked(root, buffer, false);
+	if (handle) {
+		struct memtrack_vma_list *vma_list;
+
+		hlist_for_each_entry(vma_list, &handle->vma_list, node) {
+			if (vma_list->vma == vma) {
+				hlist_del(&vma_list->node);
+				kfree(vma_list);
+				return;
+			}
 		}
 	}
 }
@@ -153,6 +198,49 @@ void memtrack_buffer_uninstall(struct memtrack_buffer *buffer,
 }
 EXPORT_SYMBOL(memtrack_buffer_uninstall);
 
+/**
+ * memtrack_buffer_vm_open - account for pages mapped during vm open
+ *
+ * @buffer: the buffer's memtrack entry
+ *
+ * @vma: vma being opened
+ */
+void memtrack_buffer_vm_open(struct memtrack_buffer *buffer,
+		const struct vm_area_struct *vma)
+{
+	unsigned long flags;
+	struct task_struct *leader = current->group_leader;
+	struct memtrack_vma_list *vma_list;
+
+	vma_list = kmalloc(sizeof(*vma_list), GFP_KERNEL);
+	if (WARN_ON(!vma_list))
+		return;
+	vma_list->vma = vma;
+
+	write_lock_irqsave(&leader->memtrack_lock, flags);
+	memtrack_buffer_vm_open_locked(&leader->memtrack_rb, buffer, vma_list);
+	write_unlock_irqrestore(&leader->memtrack_lock, flags);
+}
+EXPORT_SYMBOL(memtrack_buffer_vm_open);
+
+/**
+ * memtrack_buffer_vm_close - account for pages unmapped during vm close
+ *
+ * @buffer: the buffer's memtrack entry
+ * @vma: the vma being closed
+ */
+void memtrack_buffer_vm_close(struct memtrack_buffer *buffer,
+		const struct vm_area_struct *vma)
+{
+	unsigned long flags;
+	struct task_struct *leader = current->group_leader;
+
+	write_lock_irqsave(&leader->memtrack_lock, flags);
+	memtrack_buffer_vm_close_locked(&leader->memtrack_rb, buffer, vma);
+	write_unlock_irqrestore(&leader->memtrack_lock, flags);
+}
+EXPORT_SYMBOL(memtrack_buffer_vm_close);
+
 static int memtrack_id_alloc(struct memtrack_buffer *buffer)
 {
 	int ret;
@@ -271,6 +359,33 @@ static struct notifier_block process_notifier_block = {
 	.notifier_call	= process_notifier,
 };
 
+static void show_memtrack_vma(struct seq_file *m,
+		const struct vm_area_struct *vma,
+		const struct memtrack_buffer *buf)
+{
+	unsigned long start = vma->vm_start;
+	unsigned long end = vma->vm_end;
+	unsigned long long pgoff = ((loff_t)vma->vm_pgoff) << PAGE_SHIFT;
+	vm_flags_t flags = vma->vm_flags;
+	vm_flags_t remap_flag = VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
+
+	seq_setwidth(m, 50);
+	seq_printf(m, "%68lx-%08lx  %c%c%c%c%c  %08llx",
+			start,
+			end,
+			flags & VM_READ ? 'r' : '-',
+			flags & VM_WRITE ? 'w' : '-',
+			flags & VM_EXEC ? 'x' : '-',
+			flags & VM_MAYSHARE ? 's' : 'p',
+			flags & remap_flag ? '#' : '-',
+			pgoff);
+	if (buf->tag) {
+		seq_pad(m, ' ');
+		seq_puts(m, buf->tag);
+	}
+	seq_putc(m, '\n');
+}
+
 int proc_memtrack(struct seq_file *m, struct pid_namespace *ns, struct pid *pid,
 			struct task_struct *task)
 {
@@ -281,18 +396,23 @@ int proc_memtrack(struct seq_file *m, struct pid_namespace *ns, struct pid *pid,
 	if (RB_EMPTY_ROOT(&task->memtrack_rb))
 		goto done;
 
-	seq_printf(m, "%10.10s: %16.16s: %12.12s: %3.3s: pid:%d\n",
-			"ref_count", "Identifier", "size", "tag", task->pid);
+	seq_printf(m, "%10.10s: %16.16s: %12.12s: %12.12s: %20s: %5s: %8s: pid:%d\n",
+			"ref_count", "Identifier", "size", "tag",
+			"startAddr-endAddr", "Flags", "pgOff", task->pid);
 
 	for (node = rb_first(&task->memtrack_rb); node; node = rb_next(node)) {
 		struct memtrack_handle *handle = rb_entry(node,
 				struct memtrack_handle, node);
 		struct memtrack_buffer *buffer = handle->buffer;
+		struct memtrack_vma_list *vma;
 
-		seq_printf(m, "%10d  %16d  %12zu  %s\n",
+		seq_printf(m, "%10d  %16d  %12zu  %12s\n",
 				atomic_read(&buffer->userspace_handles),
 				buffer->id, buffer->size,
 				buffer->tag ? buffer->tag : "");
+
+		hlist_for_each_entry(vma, &handle->vma_list, node)
+			show_memtrack_vma(m, vma->vma, handle->buffer);
 	}
 
 done:
@@ -308,7 +428,6 @@ static int memtrack_show(struct seq_file *m, void *v)
 
 	seq_printf(m, "%4.4s %12.12s %10s %12.12s %3.3s\n", "pid",
 			"buffer_size", "ref", "Identifier", "tag");
-
 	rcu_read_lock();
 	idr_for_each_entry(&mem_idr, buffer, i)
 		seq_printf(m, "%4d %12zu %10d %12d %s\n", buffer->pid,
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 1c2df54..c32d520 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -906,6 +906,7 @@ static void ion_vm_open(struct vm_area_struct *vma)
 	list_add(&vma_list->list, &buffer->vmas);
 	mutex_unlock(&buffer->lock);
 	pr_debug("%s: adding %p\n", __func__, vma);
+	memtrack_buffer_vm_open(&buffer->memtrack_buffer, vma);
 }
 
 static void ion_vm_close(struct vm_area_struct *vma)
@@ -924,6 +925,7 @@ static void ion_vm_close(struct vm_area_struct *vma)
 		break;
 	}
 	mutex_unlock(&buffer->lock);
+	memtrack_buffer_vm_close(&buffer->memtrack_buffer, vma);
 }
 
 static const struct vm_operations_struct ion_vma_ops = {
@@ -963,7 +965,8 @@ static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
 	if (ret)
 		pr_err("%s: failure mapping buffer to userspace\n",
 		       __func__);
-
+	else
+		memtrack_buffer_mmap(dma_buf_memtrack_buffer(dmabuf), vma);
 	return ret;
 }
 
diff --git a/include/linux/memtrack.h b/include/linux/memtrack.h
index f73be07..5a4c7ea 100644
--- a/include/linux/memtrack.h
+++ b/include/linux/memtrack.h
@@ -33,12 +33,18 @@ struct memtrack_buffer {
 
 int proc_memtrack(struct seq_file *m, struct pid_namespace *ns, struct pid *pid,
 		struct task_struct *task);
+int proc_memtrack_maps(struct seq_file *m, struct pid_namespace *ns,
+			struct pid *pid, struct task_struct *task);
 int memtrack_buffer_init(struct memtrack_buffer *buffer, size_t size);
 void memtrack_buffer_remove(struct memtrack_buffer *buffer);
 void memtrack_buffer_install(struct memtrack_buffer *buffer,
 		struct task_struct *tsk);
 void memtrack_buffer_uninstall(struct memtrack_buffer *buffer,
 		struct task_struct *tsk);
+void memtrack_buffer_vm_open(struct memtrack_buffer *buffer,
+		const struct vm_area_struct *vma);
+void memtrack_buffer_vm_close(struct memtrack_buffer *buffer,
+		const struct vm_area_struct *vma);
 
 /**
  * memtrack_buffer_set_tag - add a descriptive tag to a memtrack entry
@@ -90,5 +96,28 @@ static inline int memtrack_buffer_set_tag(struct memtrack_buffer *buffer,
 	return -ENOENT;
 }
 
+static inline void memtrack_buffer_vm_open(struct memtrack_buffer *buffer,
+		const struct vm_area_struct *vma)
+{
+}
+
+static inline void memtrack_buffer_vm_close(struct memtrack_buffer *buffer,
+		const struct vm_area_struct *vma)
+{
+}
 #endif /* CONFIG_MEMTRACK */
+
+
+/**
+ * memtrack_buffer_vm_mmap - account for pages mapped to userspace during mmap
+ *
+ * @buffer: the buffer's memtrack entry
+ * @vma: the vma passed to mmap()
+ */
+static inline void memtrack_buffer_mmap(struct memtrack_buffer *buffer,
+		const struct vm_area_struct *vma)
+{
+	memtrack_buffer_vm_open(buffer, vma);
+}
+
 #endif /* _MEMTRACK_ */
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
