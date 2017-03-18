Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEE0C6B039D
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:59 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id r5so79652069qtb.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:59 -0700 (PDT)
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com. [209.85.220.177])
        by mx.google.com with ESMTPS id f7si7700542qtf.104.2017.03.17.17.55.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:57 -0700 (PDT)
Received: by mail-qk0-f177.google.com with SMTP id 1so77277141qkl.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:57 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 17/21] staging: android: ion: Collapse internal header files
Date: Fri, 17 Mar 2017 17:54:49 -0700
Message-Id: <1489798493-16600-18-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>


Ion current has ion_priv.h and ion.h as header files. ion.h was intended
to be used for public APIs but Ion never ended up really having anything
public. Combine the two headers so there is only one internal header.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/ion-ioctl.c         |   1 -
 drivers/staging/android/ion/ion.c               |   1 -
 drivers/staging/android/ion/ion.h               | 481 ++++++++++++++++++++----
 drivers/staging/android/ion/ion_carveout_heap.c |   1 -
 drivers/staging/android/ion/ion_chunk_heap.c    |   1 -
 drivers/staging/android/ion/ion_cma_heap.c      |   1 -
 drivers/staging/android/ion/ion_heap.c          |   1 -
 drivers/staging/android/ion/ion_page_pool.c     |   3 +-
 drivers/staging/android/ion/ion_priv.h          | 453 ----------------------
 drivers/staging/android/ion/ion_system_heap.c   |   1 -
 10 files changed, 403 insertions(+), 541 deletions(-)
 delete mode 100644 drivers/staging/android/ion/ion_priv.h

diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index 91b5c2b..4e7bf16 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -19,7 +19,6 @@
 #include <linux/uaccess.h>
 
 #include "ion.h"
-#include "ion_priv.h"
 
 union ion_ioctl_arg {
 	struct ion_fd_data fd;
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index fbab1e3..e1fb865 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -39,7 +39,6 @@
 #include <linux/sched/task.h>
 
 #include "ion.h"
-#include "ion_priv.h"
 
 bool ion_buffer_cached(struct ion_buffer *buffer)
 {
diff --git a/drivers/staging/android/ion/ion.h b/drivers/staging/android/ion/ion.h
index e8a6ffe..67fcb73 100644
--- a/drivers/staging/android/ion/ion.h
+++ b/drivers/staging/android/ion/ion.h
@@ -1,5 +1,5 @@
 /*
- * drivers/staging/android/ion/ion.h
+ * drivers/staging/android/ion/ion_priv.h
  *
  * Copyright (C) 2011 Google, Inc.
  *
@@ -14,24 +14,26 @@
  *
  */
 
-#ifndef _LINUX_ION_H
-#define _LINUX_ION_H
+#ifndef _ION_PRIV_H
+#define _ION_PRIV_H
 
+#include <linux/device.h>
+#include <linux/dma-direction.h>
+#include <linux/kref.h>
+#include <linux/mm_types.h>
+#include <linux/mutex.h>
+#include <linux/rbtree.h>
+#include <linux/sched.h>
+#include <linux/shrinker.h>
 #include <linux/types.h>
+#include <linux/miscdevice.h>
 
 #include "../uapi/ion.h"
 
-struct ion_handle;
-struct ion_device;
-struct ion_heap;
-struct ion_mapper;
-struct ion_client;
-struct ion_buffer;
-
 /**
  * struct ion_platform_heap - defines a heap in the given platform
  * @type:	type of the heap from ion_heap_type enum
- * @id:		unique identifier for heap.  When allocating higher numbers
+ * @id:		unique identifier for heap.  When allocating higher numb ers
  *		will be allocated from first.  At allocation these are passed
  *		as a bit mask and therefore can not exceed ION_NUM_HEAP_IDS.
  * @name:	used for debug purposes
@@ -52,114 +54,433 @@ struct ion_platform_heap {
 };
 
 /**
- * struct ion_platform_data - array of platform heaps passed from board file
- * @nr:		number of structures in the array
- * @heaps:	array of platform_heap structions
+ * struct ion_buffer - metadata for a particular buffer
+ * @ref:		reference count
+ * @node:		node in the ion_device buffers tree
+ * @dev:		back pointer to the ion_device
+ * @heap:		back pointer to the heap the buffer came from
+ * @flags:		buffer specific flags
+ * @private_flags:	internal buffer specific flags
+ * @size:		size of the buffer
+ * @priv_virt:		private data to the buffer representable as
+ *			a void *
+ * @lock:		protects the buffers cnt fields
+ * @kmap_cnt:		number of times the buffer is mapped to the kernel
+ * @vaddr:		the kernel mapping if kmap_cnt is not zero
+ * @sg_table:		the sg table for the buffer if dmap_cnt is not zero
+ * @pages:		flat array of pages in the buffer -- used by fault
+ *			handler and only valid for buffers that are faulted in
+ * @vmas:		list of vma's mapping this buffer
+ * @handle_count:	count of handles referencing this buffer
+ * @task_comm:		taskcomm of last client to reference this buffer in a
+ *			handle, used for debugging
+ * @pid:		pid of last client to reference this buffer in a
+ *			handle, used for debugging
+ */
+struct ion_buffer {
+	struct kref ref;
+	union {
+		struct rb_node node;
+		struct list_head list;
+	};
+	struct ion_device *dev;
+	struct ion_heap *heap;
+	unsigned long flags;
+	unsigned long private_flags;
+	size_t size;
+	void *priv_virt;
+	struct mutex lock;
+	int kmap_cnt;
+	void *vaddr;
+	struct sg_table *sg_table;
+	struct page **pages;
+	struct list_head vmas;
+	struct list_head attachments;
+	/* used to track orphaned buffers */
+	int handle_count;
+	char task_comm[TASK_COMM_LEN];
+	pid_t pid;
+};
+void ion_buffer_destroy(struct ion_buffer *buffer);
+
+/**
+ * struct ion_device - the metadata of the ion device node
+ * @dev:		the actual misc device
+ * @buffers:		an rb tree of all the existing buffers
+ * @buffer_lock:	lock protecting the tree of buffers
+ * @lock:		rwsem protecting the tree of heaps and clients
+ * @heaps:		list of all the heaps in the system
+ * @user_clients:	list of all the clients created from userspace
+ */
+struct ion_device {
+	struct miscdevice dev;
+	struct rb_root buffers;
+	struct mutex buffer_lock;
+	struct rw_semaphore lock;
+	struct plist_head heaps;
+	struct rb_root clients;
+	struct dentry *debug_root;
+	struct dentry *heaps_debug_root;
+	struct dentry *clients_debug_root;
+	int heap_cnt;
+};
+
+/**
+ * struct ion_client - a process/hw block local address space
+ * @node:		node in the tree of all clients
+ * @dev:		backpointer to ion device
+ * @handles:		an rb tree of all the handles in this client
+ * @idr:		an idr space for allocating handle ids
+ * @lock:		lock protecting the tree of handles
+ * @name:		used for debugging
+ * @display_name:	used for debugging (unique version of @name)
+ * @display_serial:	used for debugging (to make display_name unique)
+ * @task:		used for debugging
+ *
+ * A client represents a list of buffers this client may access.
+ * The mutex stored here is used to protect both handles tree
+ * as well as the handles themselves, and should be held while modifying either.
+ */
+struct ion_client {
+	struct rb_node node;
+	struct ion_device *dev;
+	struct rb_root handles;
+	struct idr idr;
+	struct mutex lock;
+	const char *name;
+	char *display_name;
+	int display_serial;
+	struct task_struct *task;
+	pid_t pid;
+	struct dentry *debug_root;
+};
+
+/**
+ * ion_handle - a client local reference to a buffer
+ * @ref:		reference count
+ * @client:		back pointer to the client the buffer resides in
+ * @buffer:		pointer to the buffer
+ * @node:		node in the client's handle rbtree
+ * @kmap_cnt:		count of times this client has mapped to kernel
+ * @id:			client-unique id allocated by client->idr
+ *
+ * Modifications to node, map_cnt or mapping should be protected by the
+ * lock in the client.  Other fields are never changed after initialization.
+ */
+struct ion_handle {
+	struct kref ref;
+	struct ion_client *client;
+	struct ion_buffer *buffer;
+	struct rb_node node;
+	unsigned int kmap_cnt;
+	int id;
+};
+
+/**
+ * struct ion_heap_ops - ops to operate on a given heap
+ * @allocate:		allocate memory
+ * @free:		free memory
+ * @map_kernel		map memory to the kernel
+ * @unmap_kernel	unmap memory to the kernel
+ * @map_user		map memory to userspace
  *
- * Provided by the board file in the form of platform data to a platform device.
+ * allocate, phys, and map_user return 0 on success, -errno on error.
+ * map_dma and map_kernel return pointer on success, ERR_PTR on
+ * error. @free will be called with ION_PRIV_FLAG_SHRINKER_FREE set in
+ * the buffer's private_flags when called from a shrinker. In that
+ * case, the pages being free'd must be truly free'd back to the
+ * system, not put in a page pool or otherwise cached.
  */
-struct ion_platform_data {
-	int nr;
-	struct ion_platform_heap *heaps;
+struct ion_heap_ops {
+	int (*allocate)(struct ion_heap *heap,
+			struct ion_buffer *buffer, unsigned long len,
+			unsigned long flags);
+	void (*free)(struct ion_buffer *buffer);
+	void * (*map_kernel)(struct ion_heap *heap, struct ion_buffer *buffer);
+	void (*unmap_kernel)(struct ion_heap *heap, struct ion_buffer *buffer);
+	int (*map_user)(struct ion_heap *mapper, struct ion_buffer *buffer,
+			struct vm_area_struct *vma);
+	int (*shrink)(struct ion_heap *heap, gfp_t gfp_mask, int nr_to_scan);
 };
 
 /**
- * ion_client_create() -  allocate a client and returns it
- * @dev:		the global ion device
+ * heap flags - flags between the heaps and core ion code
+ */
+#define ION_HEAP_FLAG_DEFER_FREE (1 << 0)
+
+/**
+ * private flags - flags internal to ion
+ */
+/*
+ * Buffer is being freed from a shrinker function. Skip any possible
+ * heap-specific caching mechanism (e.g. page pools). Guarantees that
+ * any buffer storage that came from the system allocator will be
+ * returned to the system allocator.
+ */
+#define ION_PRIV_FLAG_SHRINKER_FREE (1 << 0)
+
+/**
+ * struct ion_heap - represents a heap in the system
+ * @node:		rb node to put the heap on the device's tree of heaps
+ * @dev:		back pointer to the ion_device
+ * @type:		type of heap
+ * @ops:		ops struct as above
+ * @flags:		flags
+ * @id:			id of heap, also indicates priority of this heap when
+ *			allocating.  These are specified by platform data and
+ *			MUST be unique
  * @name:		used for debugging
+ * @shrinker:		a shrinker for the heap
+ * @free_list:		free list head if deferred free is used
+ * @free_list_size	size of the deferred free list in bytes
+ * @lock:		protects the free list
+ * @waitqueue:		queue to wait on from deferred free thread
+ * @task:		task struct of deferred free thread
+ * @debug_show:		called when heap debug file is read to add any
+ *			heap specific debug info to output
+ *
+ * Represents a pool of memory from which buffers can be made.  In some
+ * systems the only heap is regular system memory allocated via vmalloc.
+ * On others, some blocks might require large physically contiguous buffers
+ * that are allocated from a specially reserved heap.
  */
-struct ion_client *ion_client_create(struct ion_device *dev,
-				     const char *name);
+struct ion_heap {
+	struct plist_node node;
+	struct ion_device *dev;
+	enum ion_heap_type type;
+	struct ion_heap_ops *ops;
+	unsigned long flags;
+	unsigned int id;
+	const char *name;
+	struct shrinker shrinker;
+	struct list_head free_list;
+	size_t free_list_size;
+	spinlock_t free_lock;
+	wait_queue_head_t waitqueue;
+	struct task_struct *task;
+
+	int (*debug_show)(struct ion_heap *heap, struct seq_file *, void *);
+};
 
 /**
- * ion_client_destroy() -  free's a client and all it's handles
- * @client:	the client
+ * ion_buffer_cached - this ion buffer is cached
+ * @buffer:		buffer
  *
- * Free the provided client and all it's resources including
- * any handles it is holding.
+ * indicates whether this ion buffer is cached
  */
-void ion_client_destroy(struct ion_client *client);
+bool ion_buffer_cached(struct ion_buffer *buffer);
 
 /**
- * ion_alloc - allocate ion memory
- * @client:		the client
- * @len:		size of the allocation
- * @heap_id_mask:	mask of heaps to allocate from, if multiple bits are set
- *			heaps will be tried in order from highest to lowest
- *			id
- * @flags:		heap flags, the low 16 bits are consumed by ion, the
- *			high 16 bits are passed on to the respective heap and
- *			can be heap custom
+ * ion_buffer_fault_user_mappings - fault in user mappings of this buffer
+ * @buffer:		buffer
  *
- * Allocate memory in one of the heaps provided in heap mask and return
- * an opaque handle to it.
+ * indicates whether userspace mappings of this buffer will be faulted
+ * in, this can affect how buffers are allocated from the heap.
  */
-struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
-			     unsigned int heap_id_mask,
-			     unsigned int flags);
+bool ion_buffer_fault_user_mappings(struct ion_buffer *buffer);
 
 /**
- * ion_free - free a handle
- * @client:	the client
- * @handle:	the handle to free
+ * ion_device_create - allocates and returns an ion device
  *
- * Free the provided handle.
+ * returns a valid device or -PTR_ERR
+ */
+struct ion_device *ion_device_create(void);
+
+/**
+ * ion_device_destroy - free and device and it's resource
+ * @dev:		the device
+ */
+void ion_device_destroy(struct ion_device *dev);
+
+/**
+ * ion_device_add_heap - adds a heap to the ion device
+ * @dev:		the device
+ * @heap:		the heap to add
  */
+void ion_device_add_heap(struct ion_device *dev, struct ion_heap *heap);
+
+/**
+ * some helpers for common operations on buffers using the sg_table
+ * and vaddr fields
+ */
+void *ion_heap_map_kernel(struct ion_heap *heap, struct ion_buffer *buffer);
+void ion_heap_unmap_kernel(struct ion_heap *heap, struct ion_buffer *buffer);
+int ion_heap_map_user(struct ion_heap *heap, struct ion_buffer *buffer,
+		      struct vm_area_struct *vma);
+int ion_heap_buffer_zero(struct ion_buffer *buffer);
+int ion_heap_pages_zero(struct page *page, size_t size, pgprot_t pgprot);
+
+struct ion_handle *ion_alloc(struct ion_client *client, size_t len,
+				unsigned int heap_id_mask,
+				unsigned int flags);
+
 void ion_free(struct ion_client *client, struct ion_handle *handle);
 
+int ion_share_dma_buf_fd(struct ion_client *client, struct ion_handle *handle);
+
 /**
- * ion_map_kernel - create mapping for the given handle
- * @client:	the client
- * @handle:	handle to map
+ * ion_heap_init_shrinker
+ * @heap:		the heap
  *
- * Map the given handle into the kernel and return a kernel address that
- * can be used to access this address.
+ * If a heap sets the ION_HEAP_FLAG_DEFER_FREE flag or defines the shrink op
+ * this function will be called to setup a shrinker to shrink the freelists
+ * and call the heap's shrink op.
  */
-void *ion_map_kernel(struct ion_client *client, struct ion_handle *handle);
+void ion_heap_init_shrinker(struct ion_heap *heap);
 
 /**
- * ion_unmap_kernel() - destroy a kernel mapping for a handle
- * @client:	the client
- * @handle:	handle to unmap
+ * ion_heap_init_deferred_free -- initialize deferred free functionality
+ * @heap:		the heap
+ *
+ * If a heap sets the ION_HEAP_FLAG_DEFER_FREE flag this function will
+ * be called to setup deferred frees. Calls to free the buffer will
+ * return immediately and the actual free will occur some time later
  */
-void ion_unmap_kernel(struct ion_client *client, struct ion_handle *handle);
+int ion_heap_init_deferred_free(struct ion_heap *heap);
 
 /**
- * ion_share_dma_buf() - share buffer as dma-buf
- * @client:	the client
- * @handle:	the handle
+ * ion_heap_freelist_add - add a buffer to the deferred free list
+ * @heap:		the heap
+ * @buffer:		the buffer
+ *
+ * Adds an item to the deferred freelist.
  */
-struct dma_buf *ion_share_dma_buf(struct ion_client *client,
-						struct ion_handle *handle);
+void ion_heap_freelist_add(struct ion_heap *heap, struct ion_buffer *buffer);
 
 /**
- * ion_share_dma_buf_fd() - given an ion client, create a dma-buf fd
- * @client:	the client
- * @handle:	the handle
+ * ion_heap_freelist_drain - drain the deferred free list
+ * @heap:		the heap
+ * @size:		amount of memory to drain in bytes
+ *
+ * Drains the indicated amount of memory from the deferred freelist immediately.
+ * Returns the total amount freed.  The total freed may be higher depending
+ * on the size of the items in the list, or lower if there is insufficient
+ * total memory on the freelist.
  */
-int ion_share_dma_buf_fd(struct ion_client *client, struct ion_handle *handle);
+size_t ion_heap_freelist_drain(struct ion_heap *heap, size_t size);
 
 /**
- * ion_import_dma_buf() - get ion_handle from dma-buf
- * @client:	the client
- * @dmabuf:	the dma-buf
+ * ion_heap_freelist_shrink - drain the deferred free
+ *				list, skipping any heap-specific
+ *				pooling or caching mechanisms
+ *
+ * @heap:		the heap
+ * @size:		amount of memory to drain in bytes
+ *
+ * Drains the indicated amount of memory from the deferred freelist immediately.
+ * Returns the total amount freed.  The total freed may be higher depending
+ * on the size of the items in the list, or lower if there is insufficient
+ * total memory on the freelist.
  *
- * Get the ion_buffer associated with the dma-buf and return the ion_handle.
- * If no ion_handle exists for this buffer, return newly created ion_handle.
- * If dma-buf from another exporter is passed, return ERR_PTR(-EINVAL)
+ * Unlike with @ion_heap_freelist_drain, don't put any pages back into
+ * page pools or otherwise cache the pages. Everything must be
+ * genuinely free'd back to the system. If you're free'ing from a
+ * shrinker you probably want to use this. Note that this relies on
+ * the heap.ops.free callback honoring the ION_PRIV_FLAG_SHRINKER_FREE
+ * flag.
+ */
+size_t ion_heap_freelist_shrink(struct ion_heap *heap,
+					size_t size);
+
+/**
+ * ion_heap_freelist_size - returns the size of the freelist in bytes
+ * @heap:		the heap
+ */
+size_t ion_heap_freelist_size(struct ion_heap *heap);
+
+
+/**
+ * functions for creating and destroying the built in ion heaps.
+ * architectures can add their own custom architecture specific
+ * heaps as appropriate.
  */
-struct ion_handle *ion_import_dma_buf(struct ion_client *client,
-				      struct dma_buf *dmabuf);
+
+
+struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data);
+void ion_heap_destroy(struct ion_heap *heap);
+
+struct ion_heap *ion_system_heap_create(struct ion_platform_heap *unused);
+void ion_system_heap_destroy(struct ion_heap *heap);
+struct ion_heap *ion_system_contig_heap_create(struct ion_platform_heap *heap);
+void ion_system_contig_heap_destroy(struct ion_heap *heap);
+
+struct ion_heap *ion_carveout_heap_create(struct ion_platform_heap *heap_data);
+void ion_carveout_heap_destroy(struct ion_heap *heap);
+
+struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data);
+void ion_chunk_heap_destroy(struct ion_heap *heap);
+
+struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data);
+void ion_cma_heap_destroy(struct ion_heap *heap);
 
 /**
- * ion_import_dma_buf_fd() - given a dma-buf fd from the ion exporter get handle
- * @client:	the client
- * @fd:		the dma-buf fd
+ * functions for creating and destroying a heap pool -- allows you
+ * to keep a pool of pre allocated memory to use from your heap.  Keeping
+ * a pool of memory that is ready for dma, ie any cached mapping have been
+ * invalidated from the cache, provides a significant performance benefit on
+ * many systems
+ */
+
+/**
+ * struct ion_page_pool - pagepool struct
+ * @high_count:		number of highmem items in the pool
+ * @low_count:		number of lowmem items in the pool
+ * @high_items:		list of highmem items
+ * @low_items:		list of lowmem items
+ * @mutex:		lock protecting this struct and especially the count
+ *			item list
+ * @gfp_mask:		gfp_mask to use from alloc
+ * @order:		order of pages in the pool
+ * @list:		plist node for list of pools
+ * @cached:		it's cached pool or not
  *
- * Given an dma-buf fd that was allocated through ion via ion_share_dma_buf_fd,
- * import that fd and return a handle representing it. If a dma-buf from
- * another exporter is passed in this function will return ERR_PTR(-EINVAL)
+ * Allows you to keep a pool of pre allocated pages to use from your heap.
+ * Keeping a pool of pages that is ready for dma, ie any cached mapping have
+ * been invalidated from the cache, provides a significant performance benefit
+ * on many systems
  */
-struct ion_handle *ion_import_dma_buf_fd(struct ion_client *client, int fd);
+struct ion_page_pool {
+	int high_count;
+	int low_count;
+	bool cached;
+	struct list_head high_items;
+	struct list_head low_items;
+	struct mutex mutex;
+	gfp_t gfp_mask;
+	unsigned int order;
+	struct plist_node list;
+};
+
+struct ion_page_pool *ion_page_pool_create(gfp_t gfp_mask, unsigned int order,
+					   bool cached);
+void ion_page_pool_destroy(struct ion_page_pool *pool);
+struct page *ion_page_pool_alloc(struct ion_page_pool *pool);
+void ion_page_pool_free(struct ion_page_pool *pool, struct page *page);
+
+/** ion_page_pool_shrink - shrinks the size of the memory cached in the pool
+ * @pool:		the pool
+ * @gfp_mask:		the memory type to reclaim
+ * @nr_to_scan:		number of items to shrink in pages
+ *
+ * returns the number of items freed in pages
+ */
+int ion_page_pool_shrink(struct ion_page_pool *pool, gfp_t gfp_mask,
+			  int nr_to_scan);
+
+long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
+
+struct ion_handle *ion_handle_get_by_id_nolock(struct ion_client *client,
+						int id);
+
+void ion_free_nolock(struct ion_client *client, struct ion_handle *handle);
+
+int ion_handle_put_nolock(struct ion_handle *handle);
+
+struct ion_handle *ion_handle_get_by_id(struct ion_client *client,
+						int id);
+
+int ion_handle_put(struct ion_handle *handle);
+
+int ion_query_heaps(struct ion_client *client, struct ion_heap_query *query);
 
-#endif /* _LINUX_ION_H */
+#endif /* _ION_PRIV_H */
diff --git a/drivers/staging/android/ion/ion_carveout_heap.c b/drivers/staging/android/ion/ion_carveout_heap.c
index 1419a89..7287279 100644
--- a/drivers/staging/android/ion/ion_carveout_heap.c
+++ b/drivers/staging/android/ion/ion_carveout_heap.c
@@ -23,7 +23,6 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include "ion.h"
-#include "ion_priv.h"
 
 #define ION_CARVEOUT_ALLOCATE_FAIL	-1
 
diff --git a/drivers/staging/android/ion/ion_chunk_heap.c b/drivers/staging/android/ion/ion_chunk_heap.c
index 606f25f..9210bfe 100644
--- a/drivers/staging/android/ion/ion_chunk_heap.c
+++ b/drivers/staging/android/ion/ion_chunk_heap.c
@@ -22,7 +22,6 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include "ion.h"
-#include "ion_priv.h"
 
 struct ion_chunk_heap {
 	struct ion_heap heap;
diff --git a/drivers/staging/android/ion/ion_cma_heap.c b/drivers/staging/android/ion/ion_cma_heap.c
index f3e0f59..e67e78d 100644
--- a/drivers/staging/android/ion/ion_cma_heap.c
+++ b/drivers/staging/android/ion/ion_cma_heap.c
@@ -23,7 +23,6 @@
 #include <linux/scatterlist.h>
 
 #include "ion.h"
-#include "ion_priv.h"
 
 struct ion_cma_heap {
 	struct ion_heap heap;
diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
index 03b554f..acb292c 100644
--- a/drivers/staging/android/ion/ion_heap.c
+++ b/drivers/staging/android/ion/ion_heap.c
@@ -24,7 +24,6 @@
 #include <linux/scatterlist.h>
 #include <linux/vmalloc.h>
 #include "ion.h"
-#include "ion_priv.h"
 
 void *ion_heap_map_kernel(struct ion_heap *heap,
 			  struct ion_buffer *buffer)
diff --git a/drivers/staging/android/ion/ion_page_pool.c b/drivers/staging/android/ion/ion_page_pool.c
index 532eda7..817849d 100644
--- a/drivers/staging/android/ion/ion_page_pool.c
+++ b/drivers/staging/android/ion/ion_page_pool.c
@@ -22,7 +22,8 @@
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
-#include "ion_priv.h"
+
+#include "ion.h"
 
 static void *ion_page_pool_alloc_pages(struct ion_page_pool *pool)
 {
diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
deleted file mode 100644
index a86866a..0000000
--- a/drivers/staging/android/ion/ion_priv.h
+++ /dev/null
@@ -1,453 +0,0 @@
-/*
- * drivers/staging/android/ion/ion_priv.h
- *
- * Copyright (C) 2011 Google, Inc.
- *
- * This software is licensed under the terms of the GNU General Public
- * License version 2, as published by the Free Software Foundation, and
- * may be copied, distributed, and modified under those terms.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- */
-
-#ifndef _ION_PRIV_H
-#define _ION_PRIV_H
-
-#include <linux/device.h>
-#include <linux/dma-direction.h>
-#include <linux/kref.h>
-#include <linux/mm_types.h>
-#include <linux/mutex.h>
-#include <linux/rbtree.h>
-#include <linux/sched.h>
-#include <linux/shrinker.h>
-#include <linux/types.h>
-#include <linux/miscdevice.h>
-
-#include "ion.h"
-
-/**
- * struct ion_buffer - metadata for a particular buffer
- * @ref:		reference count
- * @node:		node in the ion_device buffers tree
- * @dev:		back pointer to the ion_device
- * @heap:		back pointer to the heap the buffer came from
- * @flags:		buffer specific flags
- * @private_flags:	internal buffer specific flags
- * @size:		size of the buffer
- * @priv_virt:		private data to the buffer representable as
- *			a void *
- * @lock:		protects the buffers cnt fields
- * @kmap_cnt:		number of times the buffer is mapped to the kernel
- * @vaddr:		the kernel mapping if kmap_cnt is not zero
- * @sg_table:		the sg table for the buffer if dmap_cnt is not zero
- * @pages:		flat array of pages in the buffer -- used by fault
- *			handler and only valid for buffers that are faulted in
- * @vmas:		list of vma's mapping this buffer
- * @handle_count:	count of handles referencing this buffer
- * @task_comm:		taskcomm of last client to reference this buffer in a
- *			handle, used for debugging
- * @pid:		pid of last client to reference this buffer in a
- *			handle, used for debugging
- */
-struct ion_buffer {
-	struct kref ref;
-	union {
-		struct rb_node node;
-		struct list_head list;
-	};
-	struct ion_device *dev;
-	struct ion_heap *heap;
-	unsigned long flags;
-	unsigned long private_flags;
-	size_t size;
-	void *priv_virt;
-	struct mutex lock;
-	int kmap_cnt;
-	void *vaddr;
-	struct sg_table *sg_table;
-	struct page **pages;
-	struct list_head vmas;
-	struct list_head attachments;
-	/* used to track orphaned buffers */
-	int handle_count;
-	char task_comm[TASK_COMM_LEN];
-	pid_t pid;
-};
-void ion_buffer_destroy(struct ion_buffer *buffer);
-
-/**
- * struct ion_device - the metadata of the ion device node
- * @dev:		the actual misc device
- * @buffers:		an rb tree of all the existing buffers
- * @buffer_lock:	lock protecting the tree of buffers
- * @lock:		rwsem protecting the tree of heaps and clients
- * @heaps:		list of all the heaps in the system
- * @user_clients:	list of all the clients created from userspace
- */
-struct ion_device {
-	struct miscdevice dev;
-	struct rb_root buffers;
-	struct mutex buffer_lock;
-	struct rw_semaphore lock;
-	struct plist_head heaps;
-	struct rb_root clients;
-	struct dentry *debug_root;
-	struct dentry *heaps_debug_root;
-	struct dentry *clients_debug_root;
-	int heap_cnt;
-};
-
-/**
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
- * struct ion_heap_ops - ops to operate on a given heap
- * @allocate:		allocate memory
- * @free:		free memory
- * @map_kernel		map memory to the kernel
- * @unmap_kernel	unmap memory to the kernel
- * @map_user		map memory to userspace
- *
- * allocate, phys, and map_user return 0 on success, -errno on error.
- * map_dma and map_kernel return pointer on success, ERR_PTR on
- * error. @free will be called with ION_PRIV_FLAG_SHRINKER_FREE set in
- * the buffer's private_flags when called from a shrinker. In that
- * case, the pages being free'd must be truly free'd back to the
- * system, not put in a page pool or otherwise cached.
- */
-struct ion_heap_ops {
-	int (*allocate)(struct ion_heap *heap,
-			struct ion_buffer *buffer, unsigned long len,
-			unsigned long flags);
-	void (*free)(struct ion_buffer *buffer);
-	void * (*map_kernel)(struct ion_heap *heap, struct ion_buffer *buffer);
-	void (*unmap_kernel)(struct ion_heap *heap, struct ion_buffer *buffer);
-	int (*map_user)(struct ion_heap *mapper, struct ion_buffer *buffer,
-			struct vm_area_struct *vma);
-	int (*shrink)(struct ion_heap *heap, gfp_t gfp_mask, int nr_to_scan);
-};
-
-/**
- * heap flags - flags between the heaps and core ion code
- */
-#define ION_HEAP_FLAG_DEFER_FREE (1 << 0)
-
-/**
- * private flags - flags internal to ion
- */
-/*
- * Buffer is being freed from a shrinker function. Skip any possible
- * heap-specific caching mechanism (e.g. page pools). Guarantees that
- * any buffer storage that came from the system allocator will be
- * returned to the system allocator.
- */
-#define ION_PRIV_FLAG_SHRINKER_FREE (1 << 0)
-
-/**
- * struct ion_heap - represents a heap in the system
- * @node:		rb node to put the heap on the device's tree of heaps
- * @dev:		back pointer to the ion_device
- * @type:		type of heap
- * @ops:		ops struct as above
- * @flags:		flags
- * @id:			id of heap, also indicates priority of this heap when
- *			allocating.  These are specified by platform data and
- *			MUST be unique
- * @name:		used for debugging
- * @shrinker:		a shrinker for the heap
- * @free_list:		free list head if deferred free is used
- * @free_list_size	size of the deferred free list in bytes
- * @lock:		protects the free list
- * @waitqueue:		queue to wait on from deferred free thread
- * @task:		task struct of deferred free thread
- * @debug_show:		called when heap debug file is read to add any
- *			heap specific debug info to output
- *
- * Represents a pool of memory from which buffers can be made.  In some
- * systems the only heap is regular system memory allocated via vmalloc.
- * On others, some blocks might require large physically contiguous buffers
- * that are allocated from a specially reserved heap.
- */
-struct ion_heap {
-	struct plist_node node;
-	struct ion_device *dev;
-	enum ion_heap_type type;
-	struct ion_heap_ops *ops;
-	unsigned long flags;
-	unsigned int id;
-	const char *name;
-	struct shrinker shrinker;
-	struct list_head free_list;
-	size_t free_list_size;
-	spinlock_t free_lock;
-	wait_queue_head_t waitqueue;
-	struct task_struct *task;
-
-	int (*debug_show)(struct ion_heap *heap, struct seq_file *, void *);
-};
-
-/**
- * ion_buffer_cached - this ion buffer is cached
- * @buffer:		buffer
- *
- * indicates whether this ion buffer is cached
- */
-bool ion_buffer_cached(struct ion_buffer *buffer);
-
-/**
- * ion_buffer_fault_user_mappings - fault in user mappings of this buffer
- * @buffer:		buffer
- *
- * indicates whether userspace mappings of this buffer will be faulted
- * in, this can affect how buffers are allocated from the heap.
- */
-bool ion_buffer_fault_user_mappings(struct ion_buffer *buffer);
-
-/**
- * ion_device_create - allocates and returns an ion device
- *
- * returns a valid device or -PTR_ERR
- */
-struct ion_device *ion_device_create(void);
-
-/**
- * ion_device_destroy - free and device and it's resource
- * @dev:		the device
- */
-void ion_device_destroy(struct ion_device *dev);
-
-/**
- * ion_device_add_heap - adds a heap to the ion device
- * @dev:		the device
- * @heap:		the heap to add
- */
-void ion_device_add_heap(struct ion_device *dev, struct ion_heap *heap);
-
-/**
- * some helpers for common operations on buffers using the sg_table
- * and vaddr fields
- */
-void *ion_heap_map_kernel(struct ion_heap *heap, struct ion_buffer *buffer);
-void ion_heap_unmap_kernel(struct ion_heap *heap, struct ion_buffer *buffer);
-int ion_heap_map_user(struct ion_heap *heap, struct ion_buffer *buffer,
-		      struct vm_area_struct *vma);
-int ion_heap_buffer_zero(struct ion_buffer *buffer);
-int ion_heap_pages_zero(struct page *page, size_t size, pgprot_t pgprot);
-
-/**
- * ion_heap_init_shrinker
- * @heap:		the heap
- *
- * If a heap sets the ION_HEAP_FLAG_DEFER_FREE flag or defines the shrink op
- * this function will be called to setup a shrinker to shrink the freelists
- * and call the heap's shrink op.
- */
-void ion_heap_init_shrinker(struct ion_heap *heap);
-
-/**
- * ion_heap_init_deferred_free -- initialize deferred free functionality
- * @heap:		the heap
- *
- * If a heap sets the ION_HEAP_FLAG_DEFER_FREE flag this function will
- * be called to setup deferred frees. Calls to free the buffer will
- * return immediately and the actual free will occur some time later
- */
-int ion_heap_init_deferred_free(struct ion_heap *heap);
-
-/**
- * ion_heap_freelist_add - add a buffer to the deferred free list
- * @heap:		the heap
- * @buffer:		the buffer
- *
- * Adds an item to the deferred freelist.
- */
-void ion_heap_freelist_add(struct ion_heap *heap, struct ion_buffer *buffer);
-
-/**
- * ion_heap_freelist_drain - drain the deferred free list
- * @heap:		the heap
- * @size:		amount of memory to drain in bytes
- *
- * Drains the indicated amount of memory from the deferred freelist immediately.
- * Returns the total amount freed.  The total freed may be higher depending
- * on the size of the items in the list, or lower if there is insufficient
- * total memory on the freelist.
- */
-size_t ion_heap_freelist_drain(struct ion_heap *heap, size_t size);
-
-/**
- * ion_heap_freelist_shrink - drain the deferred free
- *				list, skipping any heap-specific
- *				pooling or caching mechanisms
- *
- * @heap:		the heap
- * @size:		amount of memory to drain in bytes
- *
- * Drains the indicated amount of memory from the deferred freelist immediately.
- * Returns the total amount freed.  The total freed may be higher depending
- * on the size of the items in the list, or lower if there is insufficient
- * total memory on the freelist.
- *
- * Unlike with @ion_heap_freelist_drain, don't put any pages back into
- * page pools or otherwise cache the pages. Everything must be
- * genuinely free'd back to the system. If you're free'ing from a
- * shrinker you probably want to use this. Note that this relies on
- * the heap.ops.free callback honoring the ION_PRIV_FLAG_SHRINKER_FREE
- * flag.
- */
-size_t ion_heap_freelist_shrink(struct ion_heap *heap,
-					size_t size);
-
-/**
- * ion_heap_freelist_size - returns the size of the freelist in bytes
- * @heap:		the heap
- */
-size_t ion_heap_freelist_size(struct ion_heap *heap);
-
-
-/**
- * functions for creating and destroying the built in ion heaps.
- * architectures can add their own custom architecture specific
- * heaps as appropriate.
- */
-
-struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data);
-void ion_heap_destroy(struct ion_heap *heap);
-struct ion_heap *ion_system_heap_create(struct ion_platform_heap *unused);
-void ion_system_heap_destroy(struct ion_heap *heap);
-
-struct ion_heap *ion_system_contig_heap_create(struct ion_platform_heap *heap);
-void ion_system_contig_heap_destroy(struct ion_heap *heap);
-
-struct ion_heap *ion_carveout_heap_create(struct ion_platform_heap *heap_data);
-void ion_carveout_heap_destroy(struct ion_heap *heap);
-
-struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data);
-void ion_chunk_heap_destroy(struct ion_heap *heap);
-struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data);
-void ion_cma_heap_destroy(struct ion_heap *heap);
-
-/**
- * functions for creating and destroying a heap pool -- allows you
- * to keep a pool of pre allocated memory to use from your heap.  Keeping
- * a pool of memory that is ready for dma, ie any cached mapping have been
- * invalidated from the cache, provides a significant performance benefit on
- * many systems
- */
-
-/**
- * struct ion_page_pool - pagepool struct
- * @high_count:		number of highmem items in the pool
- * @low_count:		number of lowmem items in the pool
- * @high_items:		list of highmem items
- * @low_items:		list of lowmem items
- * @mutex:		lock protecting this struct and especially the count
- *			item list
- * @gfp_mask:		gfp_mask to use from alloc
- * @order:		order of pages in the pool
- * @list:		plist node for list of pools
- * @cached:		it's cached pool or not
- *
- * Allows you to keep a pool of pre allocated pages to use from your heap.
- * Keeping a pool of pages that is ready for dma, ie any cached mapping have
- * been invalidated from the cache, provides a significant performance benefit
- * on many systems
- */
-struct ion_page_pool {
-	int high_count;
-	int low_count;
-	bool cached;
-	struct list_head high_items;
-	struct list_head low_items;
-	struct mutex mutex;
-	gfp_t gfp_mask;
-	unsigned int order;
-	struct plist_node list;
-};
-
-struct ion_page_pool *ion_page_pool_create(gfp_t gfp_mask, unsigned int order,
-					   bool cached);
-void ion_page_pool_destroy(struct ion_page_pool *pool);
-struct page *ion_page_pool_alloc(struct ion_page_pool *pool);
-void ion_page_pool_free(struct ion_page_pool *pool, struct page *page);
-
-/** ion_page_pool_shrink - shrinks the size of the memory cached in the pool
- * @pool:		the pool
- * @gfp_mask:		the memory type to reclaim
- * @nr_to_scan:		number of items to shrink in pages
- *
- * returns the number of items freed in pages
- */
-int ion_page_pool_shrink(struct ion_page_pool *pool, gfp_t gfp_mask,
-			  int nr_to_scan);
-
-long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
-
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
-
-#endif /* _ION_PRIV_H */
diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
index a33331b..4e6fe37 100644
--- a/drivers/staging/android/ion/ion_system_heap.c
+++ b/drivers/staging/android/ion/ion_system_heap.c
@@ -24,7 +24,6 @@
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include "ion.h"
-#include "ion_priv.h"
 
 #define NUM_ORDERS ARRAY_SIZE(orders)
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
