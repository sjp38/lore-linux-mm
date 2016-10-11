Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 878E96B0261
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 19:50:42 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id kc8so27194093pab.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:42 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id e18si6195406pfd.130.2016.10.11.16.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 16:50:41 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id 190so9744725pfv.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 16:50:41 -0700 (PDT)
From: Ruchi Kandoi <kandoiruchi@google.com>
Subject: [RFC 3/6] dma-buf: add memtrack support
Date: Tue, 11 Oct 2016 16:50:07 -0700
Message-Id: <1476229810-26570-4-git-send-email-kandoiruchi@google.com>
In-Reply-To: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
References: <1476229810-26570-1-git-send-email-kandoiruchi@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kandoiruchi@google.com, gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, sumit.semwal@linaro.org, arnd@arndb.de, labbott@redhat.com, viro@zeniv.linux.org.uk, jlayton@poochiereds.net, bfields@fieldses.org, mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org, keescook@chromium.org, mhocko@suse.com, oleg@redhat.com, john.stultz@linaro.org, mguzik@redhat.com, jdanis@google.com, adobriyan@gmail.com, ghackmann@google.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@kernel.org, tj@kernel.org, vdavydov.dev@gmail.com, ebiederm@xmission.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Signed-off-by: Greg Hackmann <ghackmann@google.com>
Signed-off-by: Ruchi Kandoi <kandoiruchi@google.com>
---
 drivers/dma-buf/dma-buf.c              | 37 ++++++++++++++++++++++++++++++++++
 drivers/staging/android/ion/ion.c      | 14 +++++++++++++
 drivers/staging/android/ion/ion_priv.h |  2 ++
 include/linux/dma-buf.h                |  5 +++++
 4 files changed, 58 insertions(+)

diff --git a/drivers/dma-buf/dma-buf.c b/drivers/dma-buf/dma-buf.c
index ddaee60..f632c2b 100644
--- a/drivers/dma-buf/dma-buf.c
+++ b/drivers/dma-buf/dma-buf.c
@@ -297,12 +297,32 @@ static long dma_buf_ioctl(struct file *file,
 	}
 }
 
+static void dma_buf_installed(struct file *file, struct task_struct *task)
+{
+	struct memtrack_buffer *memtrack =
+			dma_buf_memtrack_buffer(file->private_data);
+
+	if (memtrack)
+		memtrack_buffer_install(memtrack, task);
+}
+
+static void dma_buf_uninstalled(struct file *file, struct task_struct *task)
+{
+	struct memtrack_buffer *memtrack =
+			dma_buf_memtrack_buffer(file->private_data);
+
+	if (memtrack)
+		memtrack_buffer_uninstall(memtrack, task);
+}
+
 static const struct file_operations dma_buf_fops = {
 	.release	= dma_buf_release,
 	.mmap		= dma_buf_mmap_internal,
 	.llseek		= dma_buf_llseek,
 	.poll		= dma_buf_poll,
 	.unlocked_ioctl	= dma_buf_ioctl,
+	.installed	= dma_buf_installed,
+	.uninstalled	= dma_buf_uninstalled,
 };
 
 /*
@@ -830,6 +850,23 @@ void dma_buf_vunmap(struct dma_buf *dmabuf, void *vaddr)
 }
 EXPORT_SYMBOL_GPL(dma_buf_vunmap);
 
+/**
+ * dma_buf_memtrack_buffer - returns a memtrack entry associated with dma_buf
+ *
+ * @dmabuf:	[in]	pointer to dma_buf
+ *
+ * Returns the struct memtrack_buffer associated with this dma_buf's
+ * backing pages.  If memtrack isn't enabled in the kernel, or the dma_buf
+ * exporter doesn't have memtrack support, returns NULL.
+ */
+struct memtrack_buffer *dma_buf_memtrack_buffer(struct dma_buf *dmabuf)
+{
+	if (!dmabuf->ops->memtrack_buffer)
+		return NULL;
+	return dmabuf->ops->memtrack_buffer(dmabuf);
+}
+EXPORT_SYMBOL_GPL(dma_buf_memtrack_buffer);
+
 #ifdef CONFIG_DEBUG_FS
 static int dma_buf_debug_show(struct seq_file *s, void *unused)
 {
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 396ded5..1c2df54 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -196,6 +196,7 @@ void ion_buffer_destroy(struct ion_buffer *buffer)
 		buffer->heap->ops->unmap_kernel(buffer->heap, buffer);
 	buffer->heap->ops->free(buffer);
 	vfree(buffer->pages);
+	memtrack_buffer_remove(&buffer->memtrack_buffer);
 	kfree(buffer);
 }
 
@@ -458,6 +459,8 @@ struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
 		handle = ERR_PTR(ret);
 	}
 
+	memtrack_buffer_init(&buffer->memtrack_buffer, len);
+
 	return handle;
 }
 EXPORT_SYMBOL(ion_alloc);
@@ -1013,6 +1016,16 @@ static int ion_dma_buf_end_cpu_access(struct dma_buf *dmabuf,
 	return 0;
 }
 
+static struct memtrack_buffer *ion_memtrack_buffer(struct dma_buf *buffer)
+{
+	if (IS_ENABLED(CONFIG_MEMTRACK) && buffer && buffer->priv) {
+		struct ion_buffer *ion_buffer = buffer->priv;
+
+		return &ion_buffer->memtrack_buffer;
+	}
+	return NULL;
+}
+
 static struct dma_buf_ops dma_buf_ops = {
 	.map_dma_buf = ion_map_dma_buf,
 	.unmap_dma_buf = ion_unmap_dma_buf,
@@ -1024,6 +1037,7 @@ static struct dma_buf_ops dma_buf_ops = {
 	.kunmap_atomic = ion_dma_buf_kunmap,
 	.kmap = ion_dma_buf_kmap,
 	.kunmap = ion_dma_buf_kunmap,
+	.memtrack_buffer = ion_memtrack_buffer,
 };
 
 struct dma_buf *ion_share_dma_buf(struct ion_client *client,
diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
index 3c3b324..74c38eb 100644
--- a/drivers/staging/android/ion/ion_priv.h
+++ b/drivers/staging/android/ion/ion_priv.h
@@ -27,6 +27,7 @@
 #include <linux/shrinker.h>
 #include <linux/types.h>
 #include <linux/miscdevice.h>
+#include <linux/memtrack.h>
 
 #include "ion.h"
 
@@ -78,6 +79,7 @@ struct ion_buffer {
 	int handle_count;
 	char task_comm[TASK_COMM_LEN];
 	pid_t pid;
+	struct memtrack_buffer memtrack_buffer;
 };
 void ion_buffer_destroy(struct ion_buffer *buffer);
 
diff --git a/include/linux/dma-buf.h b/include/linux/dma-buf.h
index e0b0741..dfcc2d0 100644
--- a/include/linux/dma-buf.h
+++ b/include/linux/dma-buf.h
@@ -32,6 +32,7 @@
 #include <linux/fs.h>
 #include <linux/fence.h>
 #include <linux/wait.h>
+#include <linux/memtrack.h>
 
 struct device;
 struct dma_buf;
@@ -70,6 +71,8 @@ struct dma_buf_attachment;
  * @vmap: [optional] creates a virtual mapping for the buffer into kernel
  *	  address space. Same restrictions as for vmap and friends apply.
  * @vunmap: [optional] unmaps a vmap from the buffer
+ * @memtrack_buffer: [optional] returns the memtrack entry for this buffer's
+ *        backing pages
  */
 struct dma_buf_ops {
 	int (*attach)(struct dma_buf *, struct device *,
@@ -104,6 +107,7 @@ struct dma_buf_ops {
 
 	void *(*vmap)(struct dma_buf *);
 	void (*vunmap)(struct dma_buf *, void *vaddr);
+	struct memtrack_buffer *(*memtrack_buffer)(struct dma_buf *);
 };
 
 /**
@@ -242,4 +246,5 @@ int dma_buf_mmap(struct dma_buf *, struct vm_area_struct *,
 		 unsigned long);
 void *dma_buf_vmap(struct dma_buf *);
 void dma_buf_vunmap(struct dma_buf *, void *vaddr);
+struct memtrack_buffer *dma_buf_memtrack_buffer(struct dma_buf *dmabuf);
 #endif /* __DMA_BUF_H__ */
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
