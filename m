Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3D4280251
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 19:50:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i85so26110298pfa.5
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:47 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id q24si6189550pfj.175.2016.10.11.16.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 16:50:46 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id e6so9245329pfk.3
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:46 -0700 (PDT)
From: Ruchi Kandoi <kandoiruchi@google.com>
Subject: [RFC 5/6] memtrack: Add memtrack accounting for forked processes.
Date: Tue, 11 Oct 2016 16:50:09 -0700
Message-Id: <1476229810-26570-6-git-send-email-kandoiruchi@google.com>
In-Reply-To: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
References: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kandoiruchi@google.com, gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, sumit.semwal@linaro.org, arnd@arndb.de, labbott@redhat.com, viro@zeniv.linux.org.uk, jlayton@poochiereds.net, bfields@fieldses.org, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, keescook@chromium.org, mhocko@suse.com, oleg@redhat.com, john.stultz@linaro.org, mguzik@redhat.com, jdanis@google.com, adobriyan@gmail.com, ghackmann@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@kernel.org, tj@kernel.org, vdavydov.dev@gmail.com, ebiederm@xmission.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

When a process is forked, all the buffers are shared with the forked
process too. Adds the functionality to add memtrack accounting for the
forked processes.

Forked process gets a copy of the mapped pages of the parent process.
This patch makes sure that the new mapped pages are attributed to the
child process instead of the parent.

Signed-off-by: Ruchi Kandoi <kandoiruchi@google.com>
---
 drivers/misc/memtrack.c           | 45 +++++++++++++++++++++++++++++++++++----
 drivers/staging/android/ion/ion.c | 45 +++++++++++++++++++++++++++++++++++++--
 include/linux/memtrack.h          | 19 +++++++++++------
 include/linux/mm.h                |  3 +++
 kernel/fork.c                     | 19 +++++++++++++++--
 5 files changed, 117 insertions(+), 14 deletions(-)

diff --git a/drivers/misc/memtrack.c b/drivers/misc/memtrack.c
index 4b2d17f..fa2601a 100644
--- a/drivers/misc/memtrack.c
+++ b/drivers/misc/memtrack.c
@@ -204,12 +204,13 @@ EXPORT_SYMBOL(memtrack_buffer_uninstall);
  * @buffer: the buffer's memtrack entry
  *
  * @vma: vma being opened
+ * @task: task which mapped the pages
  */
 void memtrack_buffer_vm_open(struct memtrack_buffer *buffer,
-		const struct vm_area_struct *vma)
+		const struct vm_area_struct *vma, struct task_struct *task)
 {
 	unsigned long flags;
-	struct task_struct *leader = current->group_leader;
+	struct task_struct *leader = task->group_leader;
 	struct memtrack_vma_list *vma_list;
 
 	vma_list = kmalloc(sizeof(*vma_list), GFP_KERNEL);
@@ -228,12 +229,13 @@ EXPORT_SYMBOL(memtrack_buffer_vm_open);
  *
  * @buffer: the buffer's memtrack entry
  * @vma: the vma being closed
+ * @task: task that mmaped the pages
  */
 void memtrack_buffer_vm_close(struct memtrack_buffer *buffer,
-		const struct vm_area_struct *vma)
+		const struct vm_area_struct *vma, struct task_struct *task)
 {
 	unsigned long flags;
-	struct task_struct *leader = current->group_leader;
+	struct task_struct *leader = task->group_leader;
 
 	write_lock_irqsave(&leader->memtrack_lock, flags);
 	memtrack_buffer_vm_close_locked(&leader->memtrack_rb, buffer, vma);
@@ -241,6 +243,41 @@ void memtrack_buffer_vm_close(struct memtrack_buffer *buffer,
 }
 EXPORT_SYMBOL(memtrack_buffer_vm_close);
 
+/**
+ * memtrack_buffer_install_fork - Install all parent's handles into
+ *  child.
+ *
+ * @parent: parent task
+ * @child: child task
+ */
+void memtrack_buffer_install_fork(struct task_struct *parent,
+		struct task_struct *child)
+{
+	struct task_struct *leader, *leader_child;
+	struct rb_root *root;
+	struct rb_node *node;
+	unsigned long flags;
+
+	if (!child || !parent)
+		return;
+
+	leader = parent->group_leader;
+	leader_child = child->group_leader;
+	write_lock_irqsave(&leader->memtrack_lock, flags);
+	root = &leader->memtrack_rb;
+	node = rb_first(root);
+	while (node) {
+		struct memtrack_handle *handle;
+
+		handle = rb_entry(node, struct memtrack_handle, node);
+		memtrack_buffer_install_locked(&leader_child->memtrack_rb,
+				handle->buffer);
+		node = rb_next(node);
+	}
+	write_unlock_irqrestore(&leader->memtrack_lock, flags);
+}
+EXPORT_SYMBOL(memtrack_buffer_install_fork);
+
 static int memtrack_id_alloc(struct memtrack_buffer *buffer)
 {
 	int ret;
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index c32d520..451aa0f 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -906,7 +906,7 @@ static void ion_vm_open(struct vm_area_struct *vma)
 	list_add(&vma_list->list, &buffer->vmas);
 	mutex_unlock(&buffer->lock);
 	pr_debug("%s: adding %p\n", __func__, vma);
-	memtrack_buffer_vm_open(&buffer->memtrack_buffer, vma);
+	memtrack_buffer_vm_open(&buffer->memtrack_buffer, vma, current);
 }
 
 static void ion_vm_close(struct vm_area_struct *vma)
@@ -925,13 +925,51 @@ static void ion_vm_close(struct vm_area_struct *vma)
 		break;
 	}
 	mutex_unlock(&buffer->lock);
-	memtrack_buffer_vm_close(&buffer->memtrack_buffer, vma);
+	memtrack_buffer_vm_close(&buffer->memtrack_buffer, vma, current);
+}
+
+void vm_track(struct vm_area_struct *vma, struct task_struct *task)
+{
+	struct ion_buffer *buffer = vma->vm_private_data;
+
+	memtrack_buffer_vm_open(&buffer->memtrack_buffer, vma, task);
+}
+
+void vm_untrack(struct vm_area_struct *vma, struct task_struct *task)
+{
+	struct ion_buffer *buffer = vma->vm_private_data;
+
+	memtrack_buffer_vm_close(&buffer->memtrack_buffer, vma, task);
 }
 
 static const struct vm_operations_struct ion_vma_ops = {
 	.open = ion_vm_open,
 	.close = ion_vm_close,
 	.fault = ion_vm_fault,
+	.track = vm_track,
+	.untrack = vm_untrack,
+};
+
+static void memtrack_vm_close(struct vm_area_struct *vma)
+{
+	struct ion_buffer *buffer = vma->vm_private_data;
+
+	memtrack_buffer_vm_close(&buffer->memtrack_buffer, vma, current);
+}
+
+static void memtrack_vm_open(struct vm_area_struct *vma)
+{
+	struct ion_buffer *buffer = vma->vm_private_data;
+
+	memtrack_buffer_vm_open(&buffer->memtrack_buffer, vma, current);
+}
+
+static struct vm_operations_struct memtrack_vma_ops = {
+	.open = memtrack_vm_open,
+	.close = memtrack_vm_close,
+	.fault = NULL,
+	.track = vm_track,
+	.untrack = vm_untrack,
 };
 
 static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
@@ -952,6 +990,9 @@ static int ion_mmap(struct dma_buf *dmabuf, struct vm_area_struct *vma)
 		vma->vm_ops = &ion_vma_ops;
 		ion_vm_open(vma);
 		return 0;
+	} else {
+		vma->vm_private_data = buffer;
+		vma->vm_ops = &memtrack_vma_ops;
 	}
 
 	if (!(buffer->flags & ION_FLAG_CACHED))
diff --git a/include/linux/memtrack.h b/include/linux/memtrack.h
index 5a4c7ea..4595fb0 100644
--- a/include/linux/memtrack.h
+++ b/include/linux/memtrack.h
@@ -41,10 +41,12 @@ void memtrack_buffer_install(struct memtrack_buffer *buffer,
 		struct task_struct *tsk);
 void memtrack_buffer_uninstall(struct memtrack_buffer *buffer,
 		struct task_struct *tsk);
+void memtrack_buffer_install_fork(struct task_struct *parent,
+		struct task_struct *child);
 void memtrack_buffer_vm_open(struct memtrack_buffer *buffer,
-		const struct vm_area_struct *vma);
+		const struct vm_area_struct *vma, struct task_struct *task);
 void memtrack_buffer_vm_close(struct memtrack_buffer *buffer,
-		const struct vm_area_struct *vma);
+		const struct vm_area_struct *vma, struct task_struct *task);
 
 /**
  * memtrack_buffer_set_tag - add a descriptive tag to a memtrack entry
@@ -90,6 +92,11 @@ static inline void memtrack_buffer_uninstall(struct memtrack_buffer *buffer,
 {
 }
 
+static inline void memtrack_buffer_install_fork(struct task_struct *parent,
+		struct task_struct *child)
+{
+}
+
 static inline int memtrack_buffer_set_tag(struct memtrack_buffer *buffer,
 		const char *tag)
 {
@@ -97,12 +104,12 @@ static inline int memtrack_buffer_set_tag(struct memtrack_buffer *buffer,
 }
 
 static inline void memtrack_buffer_vm_open(struct memtrack_buffer *buffer,
-		const struct vm_area_struct *vma)
+		const struct vm_area_struct *vma, struct task_struct *task)
 {
 }
 
 static inline void memtrack_buffer_vm_close(struct memtrack_buffer *buffer,
-		const struct vm_area_struct *vma)
+		const struct vm_area_struct *vma, struct task_struct *task)
 {
 }
 #endif /* CONFIG_MEMTRACK */
@@ -115,9 +122,9 @@ static inline void memtrack_buffer_vm_close(struct memtrack_buffer *buffer,
  * @vma: the vma passed to mmap()
  */
 static inline void memtrack_buffer_mmap(struct memtrack_buffer *buffer,
-		const struct vm_area_struct *vma)
+		struct vm_area_struct *vma)
 {
-	memtrack_buffer_vm_open(buffer, vma);
+	memtrack_buffer_vm_open(buffer, vma, current);
 }
 
 #endif /* _MEMTRACK_ */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e9caec6..619ea7f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -402,6 +402,9 @@ struct vm_operations_struct {
 	 */
 	struct page *(*find_special_page)(struct vm_area_struct *vma,
 					  unsigned long addr);
+
+	void (*track)(struct vm_area_struct *vma, struct task_struct *task);
+	void (*untrack)(struct vm_area_struct *vma, struct task_struct *task);
 };
 
 struct mmu_gather;
diff --git a/kernel/fork.c b/kernel/fork.c
index da8537a..43a2e73 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -76,6 +76,7 @@
 #include <linux/compiler.h>
 #include <linux/sysctl.h>
 #include <linux/kcov.h>
+#include <linux/memtrack.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -547,7 +548,8 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 }
 
 #ifdef CONFIG_MMU
-static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
+static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm,
+		struct task_struct *tsk)
 {
 	struct vm_area_struct *mpnt, *tmp, *prev, **pprev;
 	struct rb_node **rb_link, *rb_parent;
@@ -660,6 +662,11 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
 
+		if (tmp->vm_ops && tmp->vm_ops->track && tmp->vm_ops->untrack) {
+			tmp->vm_ops->untrack(tmp, current);
+			tmp->vm_ops->track(tmp, tsk);
+		}
+
 		if (retval)
 			goto out;
 	}
@@ -1125,7 +1132,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 
-	err = dup_mmap(mm, oldmm);
+	err = dup_mmap(mm, oldmm, tsk);
 	if (err)
 		goto free_pt;
 
@@ -1235,6 +1242,12 @@ static int copy_files(unsigned long clone_flags, struct task_struct *tsk)
 
 	tsk->files = newf;
 	error = 0;
+#ifdef CONFIG_MEMTRACK
+	if (!(clone_flags & CLONE_THREAD)) {
+		tsk->group_leader = tsk;
+		memtrack_buffer_install_fork(current, tsk);
+	}
+#endif
 out:
 	return error;
 }
@@ -2153,6 +2166,8 @@ static int unshare_fd(unsigned long unshare_flags, struct files_struct **new_fdp
 		*new_fdp = dup_fd(fd, &error);
 		if (!*new_fdp)
 			return error;
+
+		memtrack_buffer_install_fork(current->parent, current);
 	}
 
 	return 0;
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
