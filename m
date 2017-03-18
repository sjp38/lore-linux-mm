Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3608E6B03A2
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:56:09 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id j127so86680963qke.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:56:09 -0700 (PDT)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by mx.google.com with ESMTPS id v24si7683036qtv.214.2017.03.17.17.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:56:07 -0700 (PDT)
Received: by mail-qk0-f169.google.com with SMTP id 1so77278533qkl.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:56:07 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 20/21] staging: android: ion: Remove ion_handle and ion_client
Date: Fri, 17 Mar 2017 17:54:52 -0700
Message-Id: <1489798493-16600-21-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


ion_handle was introduced as an abstraction to represent a reference to
a buffer via an ion_client. As frameworks outside of Ion evolved, the dmabuf
emerged as the preferred standard for use in the kernel. This has made
the ion_handle an unnecessary abstraction and prone to race
conditions. ion_client is also now only used internally. We have enough
mechanisms for race conditions and leaks already so just drop ion_handle
and ion_client. This also includes ripping out most of the debugfs
infrastructure since much of that was tied to clients and handles.
The debugfs infrastructure was prone to give confusing data (orphaned
allocations) so it can be replaced with something better if people
actually want it.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion-ioctl.c |  53 +--
 drivers/staging/android/ion/ion.c       | 697 ++------------------------------
 drivers/staging/android/ion/ion.h       |  73 +---
 drivers/staging/android/uapi/ion.h      |  25 +-
 4 files changed, 49 insertions(+), 799 deletions(-)

diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index 4e7bf16..76427e4 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -21,9 +21,7 @@
 #include "ion.h"
 
 union ion_ioctl_arg {
-	struct ion_fd_data fd;
 	struct ion_allocation_data allocation;
-	struct ion_handle_data handle;
 	struct ion_heap_query query;
 };
 
@@ -48,8 +46,6 @@ static int validate_ioctl_arg(unsigned int cmd, union ion_ioctl_arg *arg)
 static unsigned int ion_ioctl_dir(unsigned int cmd)
 {
 	switch (cmd) {
-	case ION_IOC_FREE:
-		return _IOC_WRITE;
 	default:
 		return _IOC_DIR(cmd);
 	}
@@ -57,8 +53,6 @@ static unsigned int ion_ioctl_dir(unsigned int cmd)
 
 long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 {
-	struct ion_client *client = filp->private_data;
-	struct ion_handle *cleanup_handle = NULL;
 	int ret = 0;
 	unsigned int dir;
 	union ion_ioctl_arg data;
@@ -86,61 +80,28 @@ long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 	switch (cmd) {
 	case ION_IOC_ALLOC:
 	{
-		struct ion_handle *handle;
+		int fd;
 
-		handle = ion_alloc(client, data.allocation.len,
+		fd = ion_alloc(data.allocation.len,
 						data.allocation.heap_id_mask,
 						data.allocation.flags);
-		if (IS_ERR(handle))
-			return PTR_ERR(handle);
+		if (fd < 0)
+			return fd;
 
-		data.allocation.handle = handle->id;
+		data.allocation.fd = fd;
 
-		cleanup_handle = handle;
-		break;
-	}
-	case ION_IOC_FREE:
-	{
-		struct ion_handle *handle;
-
-		mutex_lock(&client->lock);
-		handle = ion_handle_get_by_id_nolock(client,
-						     data.handle.handle);
-		if (IS_ERR(handle)) {
-			mutex_unlock(&client->lock);
-			return PTR_ERR(handle);
-		}
-		ion_free_nolock(client, handle);
-		ion_handle_put_nolock(handle);
-		mutex_unlock(&client->lock);
-		break;
-	}
-	case ION_IOC_SHARE:
-	{
-		struct ion_handle *handle;
-
-		handle = ion_handle_get_by_id(client, data.handle.handle);
-		if (IS_ERR(handle))
-			return PTR_ERR(handle);
-		data.fd.fd = ion_share_dma_buf_fd(client, handle);
-		ion_handle_put(handle);
-		if (data.fd.fd < 0)
-			ret = data.fd.fd;
 		break;
 	}
 	case ION_IOC_HEAP_QUERY:
-		ret = ion_query_heaps(client, &data.query);
+		ret = ion_query_heaps(&data.query);
 		break;
 	default:
 		return -ENOTTY;
 	}
 
 	if (dir & _IOC_READ) {
-		if (copy_to_user((void __user *)arg, &data, _IOC_SIZE(cmd))) {
-			if (cleanup_handle)
-				ion_free(client, cleanup_handle);
+		if (copy_to_user((void __user *)arg, &data, _IOC_SIZE(cmd)))
 			return -EFAULT;
-		}
 	}
 	return ret;
 }
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 5a82bea..64c652b 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -90,7 +90,6 @@ static struct ion_buffer *ion_buffer_create(struct ion_heap *heap,
 
 	buffer->heap = heap;
 	buffer->flags = flags;
-	kref_init(&buffer->ref);
 
 	ret = heap->ops->allocate(heap, buffer, len, flags);
 
@@ -140,9 +139,8 @@ void ion_buffer_destroy(struct ion_buffer *buffer)
 	kfree(buffer);
 }
 
-static void _ion_buffer_destroy(struct kref *kref)
+static void _ion_buffer_destroy(struct ion_buffer *buffer)
 {
-	struct ion_buffer *buffer = container_of(kref, struct ion_buffer, ref);
 	struct ion_heap *heap = buffer->heap;
 	struct ion_device *dev = buffer->dev;
 
@@ -156,255 +154,6 @@ static void _ion_buffer_destroy(struct kref *kref)
 		ion_buffer_destroy(buffer);
 }
 
-static void ion_buffer_get(struct ion_buffer *buffer)
-{
-	kref_get(&buffer->ref);
-}
-
-static int ion_buffer_put(struct ion_buffer *buffer)
-{
-	return kref_put(&buffer->ref, _ion_buffer_destroy);
-}
-
-static void ion_buffer_add_to_handle(struct ion_buffer *buffer)
-{
-	mutex_lock(&buffer->lock);
-	buffer->handle_count++;
-	mutex_unlock(&buffer->lock);
-}
-
-static void ion_buffer_remove_from_handle(struct ion_buffer *buffer)
-{
-	/*
-	 * when a buffer is removed from a handle, if it is not in
-	 * any other handles, copy the taskcomm and the pid of the
-	 * process it's being removed from into the buffer.  At this
-	 * point there will be no way to track what processes this buffer is
-	 * being used by, it only exists as a dma_buf file descriptor.
-	 * The taskcomm and pid can provide a debug hint as to where this fd
-	 * is in the system
-	 */
-	mutex_lock(&buffer->lock);
-	buffer->handle_count--;
-	BUG_ON(buffer->handle_count < 0);
-	if (!buffer->handle_count) {
-		struct task_struct *task;
-
-		task = current->group_leader;
-		get_task_comm(buffer->task_comm, task);
-		buffer->pid = task_pid_nr(task);
-	}
-	mutex_unlock(&buffer->lock);
-}
-
-static struct ion_handle *ion_handle_create(struct ion_client *client,
-					    struct ion_buffer *buffer)
-{
-	struct ion_handle *handle;
-
-	handle = kzalloc(sizeof(*handle), GFP_KERNEL);
-	if (!handle)
-		return ERR_PTR(-ENOMEM);
-	kref_init(&handle->ref);
-	RB_CLEAR_NODE(&handle->node);
-	handle->client = client;
-	ion_buffer_get(buffer);
-	ion_buffer_add_to_handle(buffer);
-	handle->buffer = buffer;
-
-	return handle;
-}
-
-static void ion_handle_kmap_put(struct ion_handle *);
-
-static void ion_handle_destroy(struct kref *kref)
-{
-	struct ion_handle *handle = container_of(kref, struct ion_handle, ref);
-	struct ion_client *client = handle->client;
-	struct ion_buffer *buffer = handle->buffer;
-
-	mutex_lock(&buffer->lock);
-	while (handle->kmap_cnt)
-		ion_handle_kmap_put(handle);
-	mutex_unlock(&buffer->lock);
-
-	idr_remove(&client->idr, handle->id);
-	if (!RB_EMPTY_NODE(&handle->node))
-		rb_erase(&handle->node, &client->handles);
-
-	ion_buffer_remove_from_handle(buffer);
-	ion_buffer_put(buffer);
-
-	kfree(handle);
-}
-
-static void ion_handle_get(struct ion_handle *handle)
-{
-	kref_get(&handle->ref);
-}
-
-int ion_handle_put_nolock(struct ion_handle *handle)
-{
-	return kref_put(&handle->ref, ion_handle_destroy);
-}
-
-int ion_handle_put(struct ion_handle *handle)
-{
-	struct ion_client *client = handle->client;
-	int ret;
-
-	mutex_lock(&client->lock);
-	ret = ion_handle_put_nolock(handle);
-	mutex_unlock(&client->lock);
-
-	return ret;
-}
-
-struct ion_handle *ion_handle_get_by_id_nolock(struct ion_client *client,
-					       int id)
-{
-	struct ion_handle *handle;
-
-	handle = idr_find(&client->idr, id);
-	if (handle)
-		ion_handle_get(handle);
-
-	return handle ? handle : ERR_PTR(-EINVAL);
-}
-
-struct ion_handle *ion_handle_get_by_id(struct ion_client *client,
-					       int id)
-{
-	struct ion_handle *handle;
-
-	mutex_lock(&client->lock);
-	handle = ion_handle_get_by_id_nolock(client, id);
-	mutex_unlock(&client->lock);
-
-	return handle;
-}
-
-static bool ion_handle_validate(struct ion_client *client,
-				struct ion_handle *handle)
-{
-	WARN_ON(!mutex_is_locked(&client->lock));
-	return idr_find(&client->idr, handle->id) == handle;
-}
-
-static int ion_handle_add(struct ion_client *client, struct ion_handle *handle)
-{
-	int id;
-	struct rb_node **p = &client->handles.rb_node;
-	struct rb_node *parent = NULL;
-	struct ion_handle *entry;
-
-	id = idr_alloc(&client->idr, handle, 1, 0, GFP_KERNEL);
-	if (id < 0)
-		return id;
-
-	handle->id = id;
-
-	while (*p) {
-		parent = *p;
-		entry = rb_entry(parent, struct ion_handle, node);
-
-		if (handle->buffer < entry->buffer)
-			p = &(*p)->rb_left;
-		else if (handle->buffer > entry->buffer)
-			p = &(*p)->rb_right;
-		else
-			WARN(1, "%s: buffer already found.", __func__);
-	}
-
-	rb_link_node(&handle->node, parent, p);
-	rb_insert_color(&handle->node, &client->handles);
-
-	return 0;
-}
-
-struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
-			     unsigned int heap_id_mask,
-			     unsigned int flags)
-{
-	struct ion_handle *handle;
-	struct ion_device *dev = client->dev;
-	struct ion_buffer *buffer = NULL;
-	struct ion_heap *heap;
-	int ret;
-
-	pr_debug("%s: len %zu heap_id_mask %u flags %x\n", __func__,
-		 len, heap_id_mask, flags);
-	/*
-	 * traverse the list of heaps available in this system in priority
-	 * order.  If the heap type is supported by the client, and matches the
-	 * request of the caller allocate from it.  Repeat until allocate has
-	 * succeeded or all heaps have been tried
-	 */
-	len = PAGE_ALIGN(len);
-
-	if (!len)
-		return ERR_PTR(-EINVAL);
-
-	down_read(&dev->lock);
-	plist_for_each_entry(heap, &dev->heaps, node) {
-		/* if the caller didn't specify this heap id */
-		if (!((1 << heap->id) & heap_id_mask))
-			continue;
-		buffer = ion_buffer_create(heap, dev, len, flags);
-		if (!IS_ERR(buffer))
-			break;
-	}
-	up_read(&dev->lock);
-
-	if (buffer == NULL)
-		return ERR_PTR(-ENODEV);
-
-	if (IS_ERR(buffer))
-		return ERR_CAST(buffer);
-
-	handle = ion_handle_create(client, buffer);
-
-	/*
-	 * ion_buffer_create will create a buffer with a ref_cnt of 1,
-	 * and ion_handle_create will take a second reference, drop one here
-	 */
-	ion_buffer_put(buffer);
-
-	if (IS_ERR(handle))
-		return handle;
-
-	mutex_lock(&client->lock);
-	ret = ion_handle_add(client, handle);
-	mutex_unlock(&client->lock);
-	if (ret) {
-		ion_handle_put(handle);
-		handle = ERR_PTR(ret);
-	}
-
-	return handle;
-}
-EXPORT_SYMBOL(ion_alloc);
-
-void ion_free_nolock(struct ion_client *client,
-		     struct ion_handle *handle)
-{
-	if (!ion_handle_validate(client, handle)) {
-		WARN(1, "%s: invalid handle passed to free.\n", __func__);
-		return;
-	}
-	ion_handle_put_nolock(handle);
-}
-
-void ion_free(struct ion_client *client, struct ion_handle *handle)
-{
-	BUG_ON(client != handle->client);
-
-	mutex_lock(&client->lock);
-	ion_free_nolock(client, handle);
-	mutex_unlock(&client->lock);
-}
-EXPORT_SYMBOL(ion_free);
-
 static void *ion_buffer_kmap_get(struct ion_buffer *buffer)
 {
 	void *vaddr;
@@ -433,234 +182,6 @@ static void ion_buffer_kmap_put(struct ion_buffer *buffer)
 	}
 }
 
-static void ion_handle_kmap_put(struct ion_handle *handle)
-{
-	struct ion_buffer *buffer = handle->buffer;
-
-	if (!handle->kmap_cnt) {
-		WARN(1, "%s: Double unmap detected! bailing...\n", __func__);
-		return;
-	}
-	handle->kmap_cnt--;
-	if (!handle->kmap_cnt)
-		ion_buffer_kmap_put(buffer);
-}
-
-static struct mutex debugfs_mutex;
-static struct rb_root *ion_root_client;
-static int is_client_alive(struct ion_client *client)
-{
-	struct rb_node *node;
-	struct ion_client *tmp;
-	struct ion_device *dev;
-
-	node = ion_root_client->rb_node;
-	dev = container_of(ion_root_client, struct ion_device, clients);
-
-	down_read(&dev->lock);
-	while (node) {
-		tmp = rb_entry(node, struct ion_client, node);
-		if (client < tmp) {
-			node = node->rb_left;
-		} else if (client > tmp) {
-			node = node->rb_right;
-		} else {
-			up_read(&dev->lock);
-			return 1;
-		}
-	}
-
-	up_read(&dev->lock);
-	return 0;
-}
-
-static int ion_debug_client_show(struct seq_file *s, void *unused)
-{
-	struct ion_client *client = s->private;
-	struct rb_node *n;
-	size_t sizes[ION_NUM_HEAP_IDS] = {0};
-	const char *names[ION_NUM_HEAP_IDS] = {NULL};
-	int i;
-
-	mutex_lock(&debugfs_mutex);
-	if (!is_client_alive(client)) {
-		seq_printf(s, "ion_client 0x%p dead, can't dump its buffers\n",
-			   client);
-		mutex_unlock(&debugfs_mutex);
-		return 0;
-	}
-
-	mutex_lock(&client->lock);
-	for (n = rb_first(&client->handles); n; n = rb_next(n)) {
-		struct ion_handle *handle = rb_entry(n, struct ion_handle,
-						     node);
-		unsigned int id = handle->buffer->heap->id;
-
-		if (!names[id])
-			names[id] = handle->buffer->heap->name;
-		sizes[id] += handle->buffer->size;
-	}
-	mutex_unlock(&client->lock);
-	mutex_unlock(&debugfs_mutex);
-
-	seq_printf(s, "%16.16s: %16.16s\n", "heap_name", "size_in_bytes");
-	for (i = 0; i < ION_NUM_HEAP_IDS; i++) {
-		if (!names[i])
-			continue;
-		seq_printf(s, "%16.16s: %16zu\n", names[i], sizes[i]);
-	}
-	return 0;
-}
-
-static int ion_debug_client_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ion_debug_client_show, inode->i_private);
-}
-
-static const struct file_operations debug_client_fops = {
-	.open = ion_debug_client_open,
-	.read = seq_read,
-	.llseek = seq_lseek,
-	.release = single_release,
-};
-
-static int ion_get_client_serial(const struct rb_root *root,
-				 const unsigned char *name)
-{
-	int serial = -1;
-	struct rb_node *node;
-
-	for (node = rb_first(root); node; node = rb_next(node)) {
-		struct ion_client *client = rb_entry(node, struct ion_client,
-						     node);
-
-		if (strcmp(client->name, name))
-			continue;
-		serial = max(serial, client->display_serial);
-	}
-	return serial + 1;
-}
-
-struct ion_client *ion_client_create(struct ion_device *dev,
-				     const char *name)
-{
-	struct ion_client *client;
-	struct task_struct *task;
-	struct rb_node **p;
-	struct rb_node *parent = NULL;
-	struct ion_client *entry;
-	pid_t pid;
-
-	if (!name) {
-		pr_err("%s: Name cannot be null\n", __func__);
-		return ERR_PTR(-EINVAL);
-	}
-
-	get_task_struct(current->group_leader);
-	task_lock(current->group_leader);
-	pid = task_pid_nr(current->group_leader);
-	/*
-	 * don't bother to store task struct for kernel threads,
-	 * they can't be killed anyway
-	 */
-	if (current->group_leader->flags & PF_KTHREAD) {
-		put_task_struct(current->group_leader);
-		task = NULL;
-	} else {
-		task = current->group_leader;
-	}
-	task_unlock(current->group_leader);
-
-	client = kzalloc(sizeof(*client), GFP_KERNEL);
-	if (!client)
-		goto err_put_task_struct;
-
-	client->dev = dev;
-	client->handles = RB_ROOT;
-	idr_init(&client->idr);
-	mutex_init(&client->lock);
-	client->task = task;
-	client->pid = pid;
-	client->name = kstrdup(name, GFP_KERNEL);
-	if (!client->name)
-		goto err_free_client;
-
-	down_write(&dev->lock);
-	client->display_serial = ion_get_client_serial(&dev->clients, name);
-	client->display_name = kasprintf(
-		GFP_KERNEL, "%s-%d", name, client->display_serial);
-	if (!client->display_name) {
-		up_write(&dev->lock);
-		goto err_free_client_name;
-	}
-	p = &dev->clients.rb_node;
-	while (*p) {
-		parent = *p;
-		entry = rb_entry(parent, struct ion_client, node);
-
-		if (client < entry)
-			p = &(*p)->rb_left;
-		else if (client > entry)
-			p = &(*p)->rb_right;
-	}
-	rb_link_node(&client->node, parent, p);
-	rb_insert_color(&client->node, &dev->clients);
-
-	client->debug_root = debugfs_create_file(client->display_name, 0664,
-						 dev->clients_debug_root,
-						 client, &debug_client_fops);
-	if (!client->debug_root) {
-		char buf[256], *path;
-
-		path = dentry_path(dev->clients_debug_root, buf, 256);
-		pr_err("Failed to create client debugfs at %s/%s\n",
-		       path, client->display_name);
-	}
-
-	up_write(&dev->lock);
-
-	return client;
-
-err_free_client_name:
-	kfree(client->name);
-err_free_client:
-	kfree(client);
-err_put_task_struct:
-	if (task)
-		put_task_struct(current->group_leader);
-	return ERR_PTR(-ENOMEM);
-}
-EXPORT_SYMBOL(ion_client_create);
-
-void ion_client_destroy(struct ion_client *client)
-{
-	struct ion_device *dev = client->dev;
-	struct rb_node *n;
-
-	pr_debug("%s: %d\n", __func__, __LINE__);
-	mutex_lock(&debugfs_mutex);
-	while ((n = rb_first(&client->handles))) {
-		struct ion_handle *handle = rb_entry(n, struct ion_handle,
-						     node);
-		ion_handle_destroy(&handle->ref);
-	}
-
-	idr_destroy(&client->idr);
-
-	down_write(&dev->lock);
-	if (client->task)
-		put_task_struct(client->task);
-	rb_erase(&client->node, &dev->clients);
-	debugfs_remove_recursive(client->debug_root);
-	up_write(&dev->lock);
-
-	kfree(client->display_name);
-	kfree(client->name);
-	kfree(client);
-	mutex_unlock(&debugfs_mutex);
-}
-EXPORT_SYMBOL(ion_client_destroy);
-
 static struct sg_table *dup_sg_table(struct sg_table *table)
 {
 	struct sg_table *new_table;
@@ -802,7 +323,7 @@ static void ion_dma_buf_release(struct dma_buf *dmabuf)
 {
 	struct ion_buffer *buffer = dmabuf->priv;
 
-	ion_buffer_put(buffer);
+	_ion_buffer_destroy(buffer);
 }
 
 static void *ion_dma_buf_kmap(struct dma_buf *dmabuf, unsigned long offset)
@@ -881,24 +402,44 @@ static const struct dma_buf_ops dma_buf_ops = {
 	.kunmap = ion_dma_buf_kunmap,
 };
 
-struct dma_buf *ion_share_dma_buf(struct ion_client *client,
-				  struct ion_handle *handle)
+int ion_alloc(size_t len, unsigned int heap_id_mask, unsigned int flags)
 {
+	struct ion_device *dev = internal_dev;
+	struct ion_buffer *buffer = NULL;
+	struct ion_heap *heap;
 	DEFINE_DMA_BUF_EXPORT_INFO(exp_info);
-	struct ion_buffer *buffer;
+	int fd;
 	struct dma_buf *dmabuf;
-	bool valid_handle;
 
-	mutex_lock(&client->lock);
-	valid_handle = ion_handle_validate(client, handle);
-	if (!valid_handle) {
-		WARN(1, "%s: invalid handle passed to share.\n", __func__);
-		mutex_unlock(&client->lock);
-		return ERR_PTR(-EINVAL);
+	pr_debug("%s: len %zu heap_id_mask %u flags %x\n", __func__,
+		 len, heap_id_mask, flags);
+	/*
+	 * traverse the list of heaps available in this system in priority
+	 * order.  If the heap type is supported by the client, and matches the
+	 * request of the caller allocate from it.  Repeat until allocate has
+	 * succeeded or all heaps have been tried
+	 */
+	len = PAGE_ALIGN(len);
+
+	if (!len)
+		return -EINVAL;
+
+	down_read(&dev->lock);
+	plist_for_each_entry(heap, &dev->heaps, node) {
+		/* if the caller didn't specify this heap id */
+		if (!((1 << heap->id) & heap_id_mask))
+			continue;
+		buffer = ion_buffer_create(heap, dev, len, flags);
+		if (!IS_ERR(buffer))
+			break;
 	}
-	buffer = handle->buffer;
-	ion_buffer_get(buffer);
-	mutex_unlock(&client->lock);
+	up_read(&dev->lock);
+
+	if (buffer == NULL)
+		return -ENODEV;
+
+	if (IS_ERR(buffer))
+		return PTR_ERR(buffer);
 
 	exp_info.ops = &dma_buf_ops;
 	exp_info.size = buffer->size;
@@ -907,22 +448,9 @@ struct dma_buf *ion_share_dma_buf(struct ion_client *client,
 
 	dmabuf = dma_buf_export(&exp_info);
 	if (IS_ERR(dmabuf)) {
-		ion_buffer_put(buffer);
-		return dmabuf;
-	}
-
-	return dmabuf;
-}
-EXPORT_SYMBOL(ion_share_dma_buf);
-
-int ion_share_dma_buf_fd(struct ion_client *client, struct ion_handle *handle)
-{
-	struct dma_buf *dmabuf;
-	int fd;
-
-	dmabuf = ion_share_dma_buf(client, handle);
-	if (IS_ERR(dmabuf))
+		_ion_buffer_destroy(buffer);
 		return PTR_ERR(dmabuf);
+	}
 
 	fd = dma_buf_fd(dmabuf, O_CLOEXEC);
 	if (fd < 0)
@@ -930,11 +458,10 @@ int ion_share_dma_buf_fd(struct ion_client *client, struct ion_handle *handle)
 
 	return fd;
 }
-EXPORT_SYMBOL(ion_share_dma_buf_fd);
 
-int ion_query_heaps(struct ion_client *client, struct ion_heap_query *query)
+int ion_query_heaps(struct ion_heap_query *query)
 {
-	struct ion_device *dev = client->dev;
+	struct ion_device *dev = internal_dev;
 	struct ion_heap_data __user *buffer = u64_to_user_ptr(query->heaps);
 	int ret = -EINVAL, cnt = 0, max_cnt;
 	struct ion_heap *heap;
@@ -976,137 +503,14 @@ int ion_query_heaps(struct ion_client *client, struct ion_heap_query *query)
 	return ret;
 }
 
-static int ion_release(struct inode *inode, struct file *file)
-{
-	struct ion_client *client = file->private_data;
-
-	pr_debug("%s: %d\n", __func__, __LINE__);
-	ion_client_destroy(client);
-	return 0;
-}
-
-static int ion_open(struct inode *inode, struct file *file)
-{
-	struct miscdevice *miscdev = file->private_data;
-	struct ion_device *dev = container_of(miscdev, struct ion_device, dev);
-	struct ion_client *client;
-	char debug_name[64];
-
-	pr_debug("%s: %d\n", __func__, __LINE__);
-	snprintf(debug_name, 64, "%u", task_pid_nr(current->group_leader));
-	client = ion_client_create(dev, debug_name);
-	if (IS_ERR(client))
-		return PTR_ERR(client);
-	file->private_data = client;
-
-	return 0;
-}
-
 static const struct file_operations ion_fops = {
 	.owner          = THIS_MODULE,
-	.open           = ion_open,
-	.release        = ion_release,
 	.unlocked_ioctl = ion_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ion_ioctl,
 #endif
 };
 
-static size_t ion_debug_heap_total(struct ion_client *client,
-				   unsigned int id)
-{
-	size_t size = 0;
-	struct rb_node *n;
-
-	mutex_lock(&client->lock);
-	for (n = rb_first(&client->handles); n; n = rb_next(n)) {
-		struct ion_handle *handle = rb_entry(n,
-						     struct ion_handle,
-						     node);
-		if (handle->buffer->heap->id == id)
-			size += handle->buffer->size;
-	}
-	mutex_unlock(&client->lock);
-	return size;
-}
-
-static int ion_debug_heap_show(struct seq_file *s, void *unused)
-{
-	struct ion_heap *heap = s->private;
-	struct ion_device *dev = heap->dev;
-	struct rb_node *n;
-	size_t total_size = 0;
-	size_t total_orphaned_size = 0;
-
-	seq_printf(s, "%16s %16s %16s\n", "client", "pid", "size");
-	seq_puts(s, "----------------------------------------------------\n");
-
-	mutex_lock(&debugfs_mutex);
-	for (n = rb_first(&dev->clients); n; n = rb_next(n)) {
-		struct ion_client *client = rb_entry(n, struct ion_client,
-						     node);
-		size_t size = ion_debug_heap_total(client, heap->id);
-
-		if (!size)
-			continue;
-		if (client->task) {
-			char task_comm[TASK_COMM_LEN];
-
-			get_task_comm(task_comm, client->task);
-			seq_printf(s, "%16s %16u %16zu\n", task_comm,
-				   client->pid, size);
-		} else {
-			seq_printf(s, "%16s %16u %16zu\n", client->name,
-				   client->pid, size);
-		}
-	}
-	mutex_unlock(&debugfs_mutex);
-
-	seq_puts(s, "----------------------------------------------------\n");
-	seq_puts(s, "orphaned allocations (info is from last known client):\n");
-	mutex_lock(&dev->buffer_lock);
-	for (n = rb_first(&dev->buffers); n; n = rb_next(n)) {
-		struct ion_buffer *buffer = rb_entry(n, struct ion_buffer,
-						     node);
-		if (buffer->heap->id != heap->id)
-			continue;
-		total_size += buffer->size;
-		if (!buffer->handle_count) {
-			seq_printf(s, "%16s %16u %16zu %d %d\n",
-				   buffer->task_comm, buffer->pid,
-				   buffer->size, buffer->kmap_cnt,
-				   kref_read(&buffer->ref));
-			total_orphaned_size += buffer->size;
-		}
-	}
-	mutex_unlock(&dev->buffer_lock);
-	seq_puts(s, "----------------------------------------------------\n");
-	seq_printf(s, "%16s %16zu\n", "total orphaned",
-		   total_orphaned_size);
-	seq_printf(s, "%16s %16zu\n", "total ", total_size);
-	if (heap->flags & ION_HEAP_FLAG_DEFER_FREE)
-		seq_printf(s, "%16s %16zu\n", "deferred free",
-			   heap->free_list_size);
-	seq_puts(s, "----------------------------------------------------\n");
-
-	if (heap->debug_show)
-		heap->debug_show(heap, s, unused);
-
-	return 0;
-}
-
-static int ion_debug_heap_open(struct inode *inode, struct file *file)
-{
-	return single_open(file, ion_debug_heap_show, inode->i_private);
-}
-
-static const struct file_operations debug_heap_fops = {
-	.open = ion_debug_heap_open,
-	.read = seq_read,
-	.llseek = seq_lseek,
-	.release = single_release,
-};
-
 static int debug_shrink_set(void *data, u64 val)
 {
 	struct ion_heap *heap = data;
@@ -1169,17 +573,6 @@ void ion_device_add_heap(struct ion_heap *heap)
 	 */
 	plist_node_init(&heap->node, -heap->id);
 	plist_add(&heap->node, &dev->heaps);
-	debug_file = debugfs_create_file(heap->name, 0664,
-					 dev->heaps_debug_root, heap,
-					 &debug_heap_fops);
-
-	if (!debug_file) {
-		char buf[256], *path;
-
-		path = dentry_path(dev->heaps_debug_root, buf, 256);
-		pr_err("Failed to create heap debugfs at %s/%s\n",
-		       path, heap->name);
-	}
 
 	if (heap->shrinker.count_objects && heap->shrinker.scan_objects) {
 		char debug_name[64];
@@ -1227,24 +620,12 @@ int ion_device_create(void)
 		pr_err("ion: failed to create debugfs root directory.\n");
 		goto debugfs_done;
 	}
-	idev->heaps_debug_root = debugfs_create_dir("heaps", idev->debug_root);
-	if (!idev->heaps_debug_root) {
-		pr_err("ion: failed to create debugfs heaps directory.\n");
-		goto debugfs_done;
-	}
-	idev->clients_debug_root = debugfs_create_dir("clients",
-						idev->debug_root);
-	if (!idev->clients_debug_root)
-		pr_err("ion: failed to create debugfs clients directory.\n");
 
 debugfs_done:
 	idev->buffers = RB_ROOT;
 	mutex_init(&idev->buffer_lock);
 	init_rwsem(&idev->lock);
 	plist_head_init(&idev->heaps);
-	idev->clients = RB_ROOT;
-	ion_root_client = &idev->clients;
-	mutex_init(&debugfs_mutex);
 	internal_dev = idev;
 	return 0;
 }
diff --git a/drivers/staging/android/ion/ion.h b/drivers/staging/android/ion/ion.h
index 27b08c8..410cc86 100644
--- a/drivers/staging/android/ion/ion.h
+++ b/drivers/staging/android/ion/ion.h
@@ -78,7 +78,6 @@ struct ion_platform_heap {
  *			handle, used for debugging
  */
 struct ion_buffer {
-	struct kref ref;
 	union {
 		struct rb_node node;
 		struct list_head list;
@@ -118,7 +117,6 @@ struct ion_device {
 	struct mutex buffer_lock;
 	struct rw_semaphore lock;
 	struct plist_head heaps;
-	struct rb_root clients;
 	struct dentry *debug_root;
 	struct dentry *heaps_debug_root;
 	struct dentry *clients_debug_root;
@@ -126,57 +124,6 @@ struct ion_device {
 };
 
 /**
- * struct ion_client - a process/hw block local address space
- * @node:		node in the tree of all clients
- * @dev:		backpointer to ion device
- * @handles:		an rb tree of all the handles in this client
- * @idr:		an idr space for allocating handle ids
- * @lock:		lock protecting the tree of handles
- * @name:		used for debugging
- * @display_name:	used for debugging (unique version of @name)
- * @display_serial:	used for debugging (to make display_name unique)
- * @task:		used for debugging
- *
- * A client represents a list of buffers this client may access.
- * The mutex stored here is used to protect both handles tree
- * as well as the handles themselves, and should be held while modifying either.
- */
-struct ion_client {
-	struct rb_node node;
-	struct ion_device *dev;
-	struct rb_root handles;
-	struct idr idr;
-	struct mutex lock;
-	const char *name;
-	char *display_name;
-	int display_serial;
-	struct task_struct *task;
-	pid_t pid;
-	struct dentry *debug_root;
-};
-
-/**
- * ion_handle - a client local reference to a buffer
- * @ref:		reference count
- * @client:		back pointer to the client the buffer resides in
- * @buffer:		pointer to the buffer
- * @node:		node in the client's handle rbtree
- * @kmap_cnt:		count of times this client has mapped to kernel
- * @id:			client-unique id allocated by client->idr
- *
- * Modifications to node, map_cnt or mapping should be protected by the
- * lock in the client.  Other fields are never changed after initialization.
- */
-struct ion_handle {
-	struct kref ref;
-	struct ion_client *client;
-	struct ion_buffer *buffer;
-	struct rb_node node;
-	unsigned int kmap_cnt;
-	int id;
-};
-
-/**
  * struct ion_heap_ops - ops to operate on a given heap
  * @allocate:		allocate memory
  * @free:		free memory
@@ -296,14 +243,10 @@ int ion_heap_map_user(struct ion_heap *heap, struct ion_buffer *buffer,
 int ion_heap_buffer_zero(struct ion_buffer *buffer);
 int ion_heap_pages_zero(struct page *page, size_t size, pgprot_t pgprot);
 
-struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
+int ion_alloc(size_t len,
 				unsigned int heap_id_mask,
 				unsigned int flags);
 
-void ion_free(struct ion_client *client, struct ion_handle *handle);
-
-int ion_share_dma_buf_fd(struct ion_client *client, struct ion_handle *handle);
-
 /**
  * ion_heap_init_shrinker
  * @heap:		the heap
@@ -431,18 +374,6 @@ int ion_page_pool_shrink(struct ion_page_pool *pool, gfp_t gfp_mask,
 
 long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
 
-struct ion_handle *ion_handle_get_by_id_nolock(struct ion_client *client,
-						int id);
-
-void ion_free_nolock(struct ion_client *client, struct ion_handle *handle);
-
-int ion_handle_put_nolock(struct ion_handle *handle);
-
-struct ion_handle *ion_handle_get_by_id(struct ion_client *client,
-						int id);
-
-int ion_handle_put(struct ion_handle *handle);
-
-int ion_query_heaps(struct ion_client *client, struct ion_heap_query *query);
+int ion_query_heaps(struct ion_heap_query *query);
 
 #endif /* _ION_PRIV_H */
diff --git a/drivers/staging/android/uapi/ion.h b/drivers/staging/android/uapi/ion.h
index bba1c47..b76db1b 100644
--- a/drivers/staging/android/uapi/ion.h
+++ b/drivers/staging/android/uapi/ion.h
@@ -85,31 +85,8 @@ struct ion_allocation_data {
 	__u64 len;
 	__u32 heap_id_mask;
 	__u32 flags;
-	__u32 handle;
-	__u32 unused;
-};
-
-/**
- * struct ion_fd_data - metadata passed to/from userspace for a handle/fd pair
- * @handle:	a handle
- * @fd:		a file descriptor representing that handle
- *
- * For ION_IOC_SHARE or ION_IOC_MAP userspace populates the handle field with
- * the handle returned from ion alloc, and the kernel returns the file
- * descriptor to share or map in the fd field.  For ION_IOC_IMPORT, userspace
- * provides the file descriptor and the kernel returns the handle.
- */
-struct ion_fd_data {
-	__u32 handle;
 	__u32 fd;
-};
-
-/**
- * struct ion_handle_data - a handle passed to/from the kernel
- * @handle:	a handle
- */
-struct ion_handle_data {
-	__u32 handle;
+	__u32 unused;
 };
 
 #define MAX_HEAP_NAME			32
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
