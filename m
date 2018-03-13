Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 349F06B000A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:51:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m78so150104wma.7
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:51:02 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id j74si729134wmg.78.2018.03.13.14.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 14:50:59 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 5/8] Protectable Memory
Date: Tue, 13 Mar 2018 23:45:51 +0200
Message-ID: <20180313214554.28521-6-igor.stoppa@huawei.com>
In-Reply-To: <20180313214554.28521-1-igor.stoppa@huawei.com>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

The MMU available in many systems running Linux can often provide R/O
protection to the memory pages it handles.

However, the MMU-based protection works efficiently only when said pages
contain exclusively data that will not need further modifications.

Statically allocated variables can be segregated into a dedicated
section, but this does not sit very well with dynamically allocated
ones.

Dynamic allocation does not provide, currently, any means for grouping
variables in memory pages that would contain exclusively data suitable
for conversion to read only access mode.

The allocator here provided (pmalloc - protectable memory allocator)
introduces the concept of pools of protectable memory.

A module can request a pool and then refer any allocation request to the
pool handler it has received.

Once all the chunks of memory associated to a specific pool are
initialized, the pool can be protected.

After this point, the pool can only be destroyed (it is up to the module
to avoid any further references to the memory from the pool, after
the destruction is invoked).

The latter case is mainly meant for releasing memory, when a module is
unloaded.

A module can have as many pools as needed, for example to support the
protection of data that is initialized in sufficiently distinct phases.

Since pmalloc memory is obtained from vmalloc, an attacker that has
gained access to the physical mapping, still has to identify where the
target of the attack is actually located.

At the same time, being also based on genalloc, pmalloc does not
generate as much trashing of the TLB as it would be caused by using
directly only vmalloc.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/genalloc.h |   4 +
 include/linux/pmalloc.h  | 163 ++++++++++++
 include/linux/vmalloc.h  |   1 +
 lib/genalloc.c           |  23 ++
 mm/Kconfig               |   7 +
 mm/Makefile              |   1 +
 mm/pmalloc.c             | 643 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/usercopy.c            |  33 +++
 8 files changed, 875 insertions(+)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
index ff7229520656..9e98f3c991a8 100644
--- a/include/linux/genalloc.h
+++ b/include/linux/genalloc.h
@@ -120,6 +120,10 @@ void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma);
 void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size);
 
 
+void gen_pool_flush_chunk(struct gen_pool *pool,
+			  struct gen_pool_chunk *chunk);
+
+
 void gen_pool_for_each_chunk(struct gen_pool *pool,
 			     void (*func)(struct gen_pool *pool,
 					  struct gen_pool_chunk *chunk,
diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
new file mode 100644
index 000000000000..3c393069c9f1
--- /dev/null
+++ b/include/linux/pmalloc.h
@@ -0,0 +1,163 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * pmalloc.h: Header for Protectable Memory Allocator
+ *
+ * (C) Copyright 2017 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#ifndef _LINUX_PMALLOC_H
+#define _LINUX_PMALLOC_H
+
+
+#include <linux/genalloc.h>
+#include <linux/string.h>
+
+#define PMALLOC_DEFAULT_ALLOC_ORDER (-1)
+
+/*
+ * Library for dynamic allocation of pools of memory that can be,
+ * after initialization, marked as read-only.
+ *
+ * This is intended to complement __read_only_after_init, for those cases
+ * where either it is not possible to know the initialization value before
+ * init is completed, or the amount of data is variable and can be
+ * determined only at run-time.
+ *
+ * ***WARNING***
+ * The user of the API is expected to synchronize:
+ * 1) allocation,
+ * 2) writes to the allocated memory,
+ * 3) write protection of the pool,
+ * 4) freeing of the allocated memory, and
+ * 5) destruction of the pool.
+ *
+ * For a non-threaded scenario, this type of locking is not even required.
+ *
+ * Even if the library were to provide support for locking, point 2)
+ * would still depend on the user taking the lock.
+ */
+
+
+struct gen_pool *pmalloc_create_pool(const char *name,
+					 int min_alloc_order);
+
+
+int is_pmalloc_object(const void *ptr, const unsigned long n);
+
+
+bool pmalloc_expand_pool(struct gen_pool *pool, size_t size);
+
+
+void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp);
+
+
+/**
+ * pzalloc() - zero-initialized version of pmalloc
+ * @pool: handle to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
+ * @gfp: flags for page allocation
+ *
+ * Executes pmalloc, initializing the memory requested to 0,
+ * before returning the pointer to it.
+ *
+ * Return:
+ * * pointer to the memory requested	- success
+ * * NULL				- either no memory available or
+ *					  pool already read-only
+ */
+static inline void *pzalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
+{
+	return pmalloc(pool, size, gfp | __GFP_ZERO);
+}
+
+
+/**
+ * pmalloc_array() - allocates an array according to the parameters
+ * @pool: handle to the pool to be used for memory allocation
+ * @n: number of elements in the array
+ * @size: amount of memory (in bytes) requested for each element
+ * @flags: flags for page allocation
+ *
+ * Executes pmalloc, if it has a chance to succeed.
+ *
+ * Return:
+ * * the pmalloc result	- success
+ * * NULL		- error
+ */
+static inline void *pmalloc_array(struct gen_pool *pool, size_t n,
+				  size_t size, gfp_t flags)
+{
+	if (unlikely(!(pool && n && size)))
+		return NULL;
+	return pmalloc(pool, n * size, flags);
+}
+
+
+/**
+ * pcalloc() - allocates a 0-initialized array according to the parameters
+ * @pool: handle to the pool to be used for memory allocation
+ * @n: number of elements in the array
+ * @size: amount of memory (in bytes) requested
+ * @flags: flags for page allocation
+ *
+ * Executes pmalloc_array, if it has a chance to succeed.
+ *
+ * Return:
+ * * the pmalloc result	- success
+ * * NULL		- error
+ */
+static inline void *pcalloc(struct gen_pool *pool, size_t n,
+			    size_t size, gfp_t flags)
+{
+	return pmalloc_array(pool, n, size, flags | __GFP_ZERO);
+}
+
+
+/**
+ * pstrdup() - duplicate a string, using pmalloc as allocator
+ * @pool: handle to the pool to be used for memory allocation
+ * @s: string to duplicate
+ * @gfp: flags for page allocation
+ *
+ * Generates a copy of the given string, allocating sufficient memory
+ * from the given pmalloc pool.
+ *
+ * Return:
+ * * pointer to the replica	- success
+ * * NULL			- error
+ */
+static inline char *pstrdup(struct gen_pool *pool, const char *s, gfp_t gfp)
+{
+	size_t len;
+	char *buf;
+
+	if (unlikely(pool == NULL || s == NULL))
+		return NULL;
+
+	len = strlen(s) + 1;
+	buf = pmalloc(pool, len, gfp);
+	if (likely(buf))
+		strncpy(buf, s, len);
+	return buf;
+}
+
+
+void pmalloc_protect_pool(struct gen_pool *pool);
+
+
+/**
+ * pfree() - frees memory previously allocated from a pool
+ * @pool: handle to the pool used to allocate the memory to free
+ * @addr: the beginning of the location to free
+ *
+ */
+static inline void pfree(struct gen_pool *pool, const void *addr)
+{
+	gen_pool_free(pool, (unsigned long)addr, 0);
+}
+
+
+void pmalloc_destroy_pool(struct gen_pool *pool);
+
+#endif
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 1e5d8c392f15..116d280cca53 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -20,6 +20,7 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+#define VM_PMALLOC		0x00000100	/* pmalloc area - see docs */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/lib/genalloc.c b/lib/genalloc.c
index b5f5e1f9b6cf..f3a94bbf18f2 100644
--- a/lib/genalloc.c
+++ b/lib/genalloc.c
@@ -661,6 +661,29 @@ void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
 EXPORT_SYMBOL(gen_pool_free);
 
 
+/**
+ * gen_pool_flush_chunk() - drops all the allocations from a specific chunk
+ * @pool:	the generic memory pool
+ * @chunk:	The chunk to wipe clear.
+ *
+ * This is meant to be called only while destroying a pool. It's up to the
+ * caller to avoid races, but really, at this point the pool should have
+ * already been retired and it should have become unavailable for any other
+ * sort of operation.
+ */
+void gen_pool_flush_chunk(struct gen_pool *pool,
+			  struct gen_pool_chunk *chunk)
+{
+	size_t size;
+
+	size = chunk->end_addr + 1 - chunk->start_addr;
+	memset(chunk->entries, 0,
+	       DIV_ROUND_UP(size >> pool->min_alloc_order * BITS_PER_ENTRY,
+			    BITS_PER_BYTE));
+	atomic_long_set(&chunk->avail, size);
+}
+
+
 /**
  * gen_pool_for_each_chunk() - call func for every chunk of generic memory pool
  * @pool:	the generic memory pool
diff --git a/mm/Kconfig b/mm/Kconfig
index c782e8fb7235..016d29b9400b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -760,3 +760,10 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config PROTECTABLE_MEMORY
+    bool
+    depends on MMU
+    depends on ARCH_HAS_SET_MEMORY
+    select GENERIC_ALLOCATOR
+    default y
diff --git a/mm/Makefile b/mm/Makefile
index e669f02c5a54..959fdbdac118 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -65,6 +65,7 @@ obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_PROTECTABLE_MEMORY) += pmalloc.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/pmalloc.c b/mm/pmalloc.c
new file mode 100644
index 000000000000..59f385922510
--- /dev/null
+++ b/mm/pmalloc.c
@@ -0,0 +1,643 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * pmalloc.c: Protectable Memory Allocator
+ *
+ * (C) Copyright 2017-2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#include <linux/printk.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+#include <linux/genalloc.h>
+#include <linux/kernel.h>
+#include <linux/log2.h>
+#include <linux/slab.h>
+#include <linux/device.h>
+#include <linux/atomic.h>
+#include <linux/rculist.h>
+#include <linux/set_memory.h>
+#include <linux/bug.h>
+#include <asm/cacheflush.h>
+#include <asm/page.h>
+
+#include <linux/pmalloc.h>
+/*
+ * pmalloc_data contains the data specific to a pmalloc pool,
+ * in a format compatible with the design of gen_alloc.
+ * Some of the fields are used for exposing the corresponding parameter
+ * to userspace, through sysfs.
+ */
+struct pmalloc_data {
+	struct gen_pool *pool;  /* Link back to the associated pool. */
+	bool protected;     /* Status of the pool: RO or RW. */
+	struct kobj_attribute attr_protected; /* Sysfs attribute. */
+	struct kobj_attribute attr_avail;     /* Sysfs attribute. */
+	struct kobj_attribute attr_size;      /* Sysfs attribute. */
+	struct kobj_attribute attr_chunks;    /* Sysfs attribute. */
+	struct kobject *pool_kobject;
+	struct list_head node; /* list of pools */
+};
+
+static LIST_HEAD(pmalloc_list);
+static bool sysfs_ready;
+static DEFINE_MUTEX(pmalloc_mutex);
+static struct kobject *pmalloc_kobject;
+
+
+/**
+ * pmalloc_pool_show_protected() - shows if a pool is write-protected
+ * @dev: the associated kobject
+ * @attr:A handle to the attribute object
+ * @buf: the buffer where to write the value
+ *
+ * Return:
+ * * the number of bytes written
+ */
+static ssize_t pmalloc_pool_show_protected(struct kobject *dev,
+					   struct kobj_attribute *attr,
+					   char *buf)
+{
+	struct pmalloc_data *data;
+
+	data = container_of(attr, struct pmalloc_data, attr_protected);
+	if (data->protected)
+		return sprintf(buf, "protected\n");
+	else
+		return sprintf(buf, "unprotected\n");
+}
+
+
+/**
+ * pmalloc_pool_show_avail() - shows cumulative available space in a pool
+ * @dev: the associated kobject
+ * @attr:A handle to the attribute object
+ * @buf: the buffer where to write the value
+ *
+ * The value shown is only indicative, because it doesn't take in account
+ * various factors, like allocation strategy, nor fragmentation, both
+ * across multiple chunks and even within the same chunk.
+ *
+ * Return:
+ * * the number of bytes written
+ */
+static ssize_t pmalloc_pool_show_avail(struct kobject *dev,
+				       struct kobj_attribute *attr,
+				       char *buf)
+{
+	struct pmalloc_data *data;
+
+	data = container_of(attr, struct pmalloc_data, attr_avail);
+	return sprintf(buf, "%lu\n",
+		       (unsigned long)gen_pool_avail(data->pool));
+}
+
+
+/**
+ * pmalloc_pool_show_size() - shows cumulative size of a pool
+ * @dev: the associated kobject
+ * @attr: handle to the attribute object
+ * @buf: the buffer where to write the value
+ *
+ * Return:
+ * * the number of bytes written
+ */
+static ssize_t pmalloc_pool_show_size(struct kobject *dev,
+				      struct kobj_attribute *attr,
+				      char *buf)
+{
+	struct pmalloc_data *data;
+
+	data = container_of(attr, struct pmalloc_data, attr_size);
+	return sprintf(buf, "%lu\n",
+		       (unsigned long)gen_pool_size(data->pool));
+}
+
+/**
+ * pool_chunk_number() - callback to count the number of chunks in a pool
+ * @pool: handle to the pool
+ * @chunk: chunk for the current iteration
+ * @data: opaque data passed by the calling iterator
+ */
+static void pool_chunk_number(struct gen_pool *pool,
+			      struct gen_pool_chunk *chunk, void *data)
+{
+	unsigned long *counter = data;
+
+	(*counter)++;
+}
+
+/**
+ * pmalloc_pool_show_chunks() - callback exposing the number of chunks
+ * @dev: the associated kobject
+ * @attr: handle to the attribute object
+ * @buf: the buffer where to write the value
+ *
+ * Return:
+ * * number of bytes written
+ */
+static ssize_t pmalloc_pool_show_chunks(struct kobject *dev,
+					struct kobj_attribute *attr,
+					char *buf)
+{
+	struct pmalloc_data *data;
+	unsigned long chunks_num = 0;
+
+	data = container_of(attr, struct pmalloc_data, attr_chunks);
+	gen_pool_for_each_chunk(data->pool, pool_chunk_number, &chunks_num);
+	return sprintf(buf, "%lu\n", chunks_num);
+}
+
+
+/**
+ * pmalloc_connect() - Exposes the pool and its attributes through sysfs.
+ * @data: pointer to the data structure describing a pool
+ *
+ * Return:
+ * * pointer	- to the kobject created
+ * * NULL	- error
+ */
+static struct kobject *pmalloc_connect(struct pmalloc_data *data)
+{
+	const struct attribute *attrs[] = {
+		&data->attr_protected.attr,
+		&data->attr_avail.attr,
+		&data->attr_size.attr,
+		&data->attr_chunks.attr,
+		NULL
+	};
+	struct kobject *kobj;
+
+	kobj = kobject_create_and_add(data->pool->name, pmalloc_kobject);
+	if (unlikely(!kobj))
+		return NULL;
+
+	if (unlikely(sysfs_create_files(kobj, attrs) < 0)) {
+		kobject_put(kobj);
+		return NULL;
+	}
+	return kobj;
+}
+
+/**
+ * pmalloc_disconnect() - Removes the pool and its attributes from sysfs.
+ * @data: opaque data passed from the caller
+ * @kobj: the object to disconnect
+ */
+static void pmalloc_disconnect(struct pmalloc_data *data,
+			       struct kobject *kobj)
+{
+	const struct attribute *attrs[] = {
+		&data->attr_protected.attr,
+		&data->attr_avail.attr,
+		&data->attr_size.attr,
+		&data->attr_chunks.attr,
+		NULL
+	};
+
+	sysfs_remove_files(kobj, attrs);
+	kobject_put(kobj);
+}
+
+/* Declares an attribute of the pool. */
+#define pmalloc_attr_init(data, attr_name) \
+do { \
+	sysfs_attr_init(&data->attr_##attr_name.attr); \
+	data->attr_##attr_name.attr.name = #attr_name; \
+	data->attr_##attr_name.attr.mode = VERIFY_OCTAL_PERMISSIONS(0400); \
+	data->attr_##attr_name.show = pmalloc_pool_show_##attr_name; \
+} while (0)
+
+
+/**
+ * init_pool() - allocates and initializes the data strutures for a pool
+ * @pool: handle to the pool to initialise.
+ * @name: the name for the new pool,
+ *
+ * Return:
+ * * true	- success
+ * * false	- failed allocations for meta-data
+ */
+static inline bool init_pool(struct gen_pool *pool, const char *name)
+{
+	const char *pool_name;
+	struct pmalloc_data *data;
+
+	pool_name = kstrdup(name, GFP_KERNEL);
+	if (WARN(!pool_name, "failed to allocate memory for pool name"))
+		return false;
+
+	data = kzalloc(sizeof(struct pmalloc_data), GFP_KERNEL);
+	if (WARN(!data, "failed to allocate memory for pool data")) {
+		kfree(pool_name);
+		return false;
+	}
+
+	data->protected = false;
+	data->pool = pool;
+	pmalloc_attr_init(data, protected);
+	pmalloc_attr_init(data, avail);
+	pmalloc_attr_init(data, size);
+	pmalloc_attr_init(data, chunks);
+	pool->data = data;
+	pool->name = pool_name;
+	return true;
+}
+
+
+/**
+ * pmalloc_create_pool() - create a new protectable memory pool
+ * @name: the name of the pool, enforced to be unique
+ * @min_alloc_order: log2 of the minimum allocation size obtainable
+ *                   from the pool; -1 will pick sizeof(unsigned long)
+ *
+ * Creates a new (empty) memory pool for allocation of protectable
+ * memory. Memory will be allocated upon request (through pmalloc).
+ *
+ * Return:
+ * * pointer to the new pool	- success
+ * * NULL			- error
+ */
+struct gen_pool *pmalloc_create_pool(const char *name, int min_alloc_order)
+{
+	struct gen_pool *pool;
+	struct pmalloc_data *data;
+
+	if (WARN(!name, "Refusing to create unnamed pool"))
+		return NULL;
+
+	if (min_alloc_order < 0)
+		min_alloc_order = ilog2(sizeof(unsigned long));
+
+	pool = gen_pool_create(min_alloc_order, NUMA_NO_NODE);
+	if (WARN(!pool, "Could not allocate memory for pool"))
+		return NULL;
+
+	if (WARN(!init_pool(pool, name),
+		 "Failed to initialize pool %s.", name))
+		goto init_pool_err;
+
+	mutex_lock(&pmalloc_mutex);
+	list_for_each_entry(data, &pmalloc_list, node) {
+		if (!strcmp(name, data->pool->name)) {
+			mutex_unlock(&pmalloc_mutex);
+			goto same_name_err;
+		}
+	}
+
+	data = (struct pmalloc_data *)pool->data;
+	list_add(&data->node, &pmalloc_list);
+	if (sysfs_ready)
+		data->pool_kobject = pmalloc_connect(data);
+	mutex_unlock(&pmalloc_mutex);
+	return pool;
+
+same_name_err:
+	kfree(pool->data);
+init_pool_err:
+	gen_pool_destroy(pool);
+	return NULL;
+}
+
+#define CHUNK_TAG true
+#define CHUNK_UNTAG false
+/**
+ * chunk_tagging() - (un)tags the area corresponding to a chunk
+ * @chunk: vmalloc allocation, as multiple of memory pages
+ * @tag: selects whether to tag or untag the pages from the chunk
+ *
+ * Return:
+ * * true	- success
+ * * false	- failure
+ */
+static inline bool chunk_tagging(void *chunk, bool tag)
+{
+	struct vm_struct *area;
+	struct page *page;
+
+	if (!is_vmalloc_addr(chunk))
+		return false;
+
+	page = vmalloc_to_page(chunk);
+	if (unlikely(!page))
+		return false;
+
+	area = page->area;
+	if (tag == CHUNK_UNTAG)
+		area->flags &= ~VM_PMALLOC;
+	else
+		area->flags |= VM_PMALLOC;
+	return true;
+}
+
+
+enum {
+	INVALID_PMALLOC_OBJECT = -1,
+	NOT_PMALLOC_OBJECT = 0,
+	VALID_PMALLOC_OBJECT = 1,
+};
+
+
+/**
+ * is_pmalloc_object() - validates the existence of an alleged object
+ * @ptr: address of the object
+ * @n: size of the object, in bytes
+ *
+ * Return:
+ * * 0		- the object does not belong to pmalloc
+ * * 1		- the object belongs to pmalloc
+ * * \-1	- the object overlaps pmalloc memory incorrectly
+ */
+int is_pmalloc_object(const void *ptr, const unsigned long n)
+{
+	struct vm_struct *area;
+	struct page *page;
+	unsigned long area_start;
+	unsigned long area_end;
+	unsigned long object_start;
+	unsigned long object_end;
+
+
+	/*
+	 * is_pmalloc_object gets called pretty late, so chances are high
+	 * that the object is indeed of vmalloc type
+	 */
+	if (unlikely(!is_vmalloc_addr(ptr)))
+		return NOT_PMALLOC_OBJECT;
+
+	page = vmalloc_to_page(ptr);
+	if (unlikely(!page))
+		return NOT_PMALLOC_OBJECT;
+
+	area = page->area;
+
+	if (likely(!(area->flags & VM_PMALLOC)))
+		return NOT_PMALLOC_OBJECT;
+
+	area_start = (unsigned long)area->addr;
+	area_end = area_start + area->nr_pages * PAGE_SIZE - 1;
+	object_start = (unsigned long)ptr;
+	object_end = object_start + n - 1;
+
+	if (likely((area_start <= object_start) &&
+		   (object_end <= area_end)))
+		return VALID_PMALLOC_OBJECT;
+	else
+		return INVALID_PMALLOC_OBJECT;
+}
+
+
+/**
+ * pmalloc_expand_pool() - adds a memory chunk of the requested size
+ * @pool: handle for the pool
+ * @size: amount of memory (in bytes) requested
+ *
+ * Prepares a chunk of the requested size.
+ * This is intended to both minimize latency in later memory requests and
+ * avoid sleeping during allocation.
+ * Memory allocated with prealloc is stored in one single chunk, as
+ * opposed to what is allocated on-demand when pmalloc runs out of free
+ * space already existing in the pool and has to invoke vmalloc.
+ * One additional advantage of pre-allocating larger chunks of memory is
+ * that the total slack tends to be smaller.
+ * If used for avoiding sleep, the intended user must be protected from
+ * other, parasitic users, for example with a lock.
+ *
+ * Return:
+ * * true	- allocation and registration were successful
+ * * false	- some error occurred
+ */
+bool pmalloc_expand_pool(struct gen_pool *pool, size_t size)
+{
+	void *chunk;
+	size_t chunk_size;
+
+	chunk_size = roundup(size, PAGE_SIZE);
+	chunk = vmalloc(chunk_size);
+	if (WARN(chunk == NULL,
+		 "Could not allocate %zu bytes from vmalloc", chunk_size))
+		return false;
+
+	if (WARN(!chunk_tagging(chunk, CHUNK_TAG),
+		 "Failed to tag chunk as pmalloc memory"))
+		goto free;
+
+	/* Locking is already done inside gen_pool_add */
+	if (WARN(gen_pool_add(pool, (unsigned long)chunk, chunk_size,
+			      NUMA_NO_NODE),
+		 "Failed to add chunk to pool %s", pool->name)) {
+		chunk_tagging(chunk, CHUNK_UNTAG);
+free:
+		/*
+		 * expand_pool might be called with a lock held, so use
+		 * vfree_atomic, instaed of plain vfree.
+		 */
+		vfree_atomic(chunk);
+		return false;
+	}
+
+	return true;
+
+}
+
+
+/**
+ * pmalloc() - allocate protectable memory from a pool
+ * @pool: handle to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
+ * @gfp: flags for page allocation
+ *
+ * Allocates memory from an unprotected pool. If the pool doesn't have
+ * enough memory, and the request did not include GFP_ATOMIC, an attempt
+ * is made to add a new chunk of memory to the pool
+ * (a multiple of PAGE_SIZE), in order to fit the new request.
+ * Otherwise, NULL is returned.
+ *
+ * Return:
+ * * pointer to the memory requested	- success
+ * * NULL				- either no memory available or
+ *					  pool already read-only
+ */
+void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
+{
+	unsigned long addr;
+	struct pmalloc_data *data = (struct pmalloc_data *)(pool->data);
+
+	if (WARN(data->protected, "pool %s already protected",
+		 pool->name))
+		return NULL;
+
+	/*
+	 * Even when everything goes fine, 2 or more allocations might
+	 * happen in parallel, where one "steals" the memory added by
+	 * another, but that's ok, just try to allocate some more.
+	 * Eventually the "stealing" will subside.
+	 */
+	while (true) {
+		/* Try to add enough memory to the pool. */
+		addr = gen_pool_alloc(pool, size);
+		if (likely(addr))
+			break; /* Success! Retry the allocation. */
+
+		/* There was no suitable memory available in the pool. */
+		if (likely(!(gfp & __GFP_ATOMIC))) {
+			/* Not in atomic context, expand the pool. */
+			if (likely(pmalloc_expand_pool(pool, size)) ||
+			    unlikely(gfp & __GFP_NOFAIL))
+			/* Retry, either upon success or if mandated. */
+				continue;
+			/* Otherwise, give up. */
+			WARN(true, "Could not add %zu bytes to %s pool",
+			     size, pool->name);
+			return NULL;
+		}
+
+		/* Atomic context: no chance to expand the pool. */
+		if (WARN(!(gfp & __GFP_NOFAIL),
+			 "Could not get %zu bytes from %s and ATOMIC",
+			 size, pool->name))
+			return NULL; /* Fail, if possible. */
+		/* Otherwise, retry.*/
+	}
+
+	if (unlikely(gfp & __GFP_ZERO))
+		memset((void *)addr, 0, size);
+	return (void *)addr;
+}
+
+
+/**
+ * pmalloc_chunk_set_protection() - (un)protects a pool
+ * @pool: handle to the pool to (un)protect
+ * @chunk: handle to the chunk to (un)protect
+ * @data: opaque data from the chunk iterator - it's a boolean
+ * * TRUE	- protect the chunk
+ * * FALSE	- unprotect the chunk
+ */
+static void pmalloc_chunk_set_protection(struct gen_pool *pool,
+					 struct gen_pool_chunk *chunk,
+					 void *data)
+{
+	const bool *flag = data;
+	size_t chunk_size = chunk->end_addr + 1 - chunk->start_addr;
+	unsigned long pages = chunk_size / PAGE_SIZE;
+
+	if (WARN(chunk_size & (PAGE_SIZE - 1),
+		 "Chunk size is not a multiple of PAGE_SIZE."))
+		return;
+
+	if (*flag)
+		set_memory_ro(chunk->start_addr, pages);
+	else
+		set_memory_rw(chunk->start_addr, pages);
+}
+
+
+/**
+ * pmalloc_pool_set_protection() - (un)protects a pool
+ * @pool: handle to the pool to (un)protect
+ * @protection:
+ * * TRUE	- protect
+ * * FALSE	- unprotect
+ */
+static void pmalloc_pool_set_protection(struct gen_pool *pool,
+					bool protection)
+{
+	struct pmalloc_data *data;
+	struct gen_pool_chunk *chunk;
+
+	data = pool->data;
+	if (WARN(data->protected == protection,
+		 "The pool %s is already protected as requested",
+		 pool->name))
+		return;
+	data->protected = protection;
+	list_for_each_entry(chunk, &(pool)->chunks, next_chunk)
+		pmalloc_chunk_set_protection(pool, chunk, &protection);
+}
+
+
+/**
+ * pmalloc_protect_pool() - turn a read/write pool into read-only
+ * @pool: the pool to protect
+ *
+ * Write-protects all the memory chunks assigned to the pool.
+ * This prevents any further allocation.
+ */
+void  pmalloc_protect_pool(struct gen_pool *pool)
+{
+	pmalloc_pool_set_protection(pool, true);
+}
+
+
+/**
+ * pmalloc_chunk_free() - untags and frees the pages from a chunk
+ * @pool: handle to the pool containing the chunk
+ * @chunk: the chunk to free
+ * @data: opaque data passed by the iterator invoking this function
+ */
+static void pmalloc_chunk_free(struct gen_pool *pool,
+			       struct gen_pool_chunk *chunk, void *data)
+{
+	chunk_tagging(chunk, CHUNK_UNTAG);
+	gen_pool_flush_chunk(pool, chunk);
+	vfree_atomic((void *)chunk->start_addr);
+}
+
+
+/**
+ * pmalloc_destroy_pool() - destroys a pool and all the associated memory
+ * @pool: the pool to destroy
+ *
+ * All the memory that was allocated through pmalloc in the pool will be freed.
+ */
+void pmalloc_destroy_pool(struct gen_pool *pool)
+{
+	struct pmalloc_data *data;
+
+	data = pool->data;
+
+	mutex_lock(&pmalloc_mutex);
+	list_del(&data->node);
+	mutex_unlock(&pmalloc_mutex);
+
+	if (likely(data->pool_kobject))
+		pmalloc_disconnect(data, data->pool_kobject);
+
+	pmalloc_pool_set_protection(pool, false);
+	gen_pool_for_each_chunk(pool, pmalloc_chunk_free, NULL);
+	gen_pool_destroy(pool);
+	kfree(data);
+}
+
+
+/**
+ * pmalloc_late_init() - registers to debug sysfs pools pretading it
+ *
+ * When the sysfs infrastructure is ready to receive registrations,
+ * connect all the pools previously created. Also enable further pools
+ * to be connected right away.
+ *
+ * Return:
+ * * 0		- success
+ * * \-1	- error
+ */
+static int __init pmalloc_late_init(void)
+{
+	struct pmalloc_data *data, *n;
+
+	pmalloc_kobject = kobject_create_and_add("pmalloc", kernel_kobj);
+	if (WARN(!pmalloc_kobject,
+		 "Failed to create pmalloc root sysfs dir"))
+		return -1;
+
+	mutex_lock(&pmalloc_mutex);
+	sysfs_ready = true;
+	list_for_each_entry_safe(data, n, &pmalloc_list, node)
+		pmalloc_connect(data);
+	mutex_unlock(&pmalloc_mutex);
+
+	return 0;
+}
+late_initcall(pmalloc_late_init);
diff --git a/mm/usercopy.c b/mm/usercopy.c
index e9e9325f7638..946ce051e296 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -240,6 +240,36 @@ static inline void check_heap_object(const void *ptr, unsigned long n,
 	}
 }
 
+#ifdef CONFIG_PROTECTABLE_MEMORY
+
+int is_pmalloc_object(const void *ptr, const unsigned long n);
+
+static void check_pmalloc_object(const void *ptr, unsigned long n,
+				 bool to_user)
+{
+	int retv;
+
+	retv = is_pmalloc_object(ptr, n);
+	if (unlikely(retv)) {
+		if (unlikely(!to_user))
+			usercopy_abort("pmalloc",
+				       "trying to write to pmalloc object",
+				       to_user, (const unsigned long)ptr, n);
+		if (retv < 0)
+			usercopy_abort("pmalloc",
+				       "invalid pmalloc object",
+				       to_user, (const unsigned long)ptr, n);
+	}
+}
+
+#else
+
+static void check_pmalloc_object(const void *ptr, unsigned long n,
+				 bool to_user)
+{
+}
+#endif
+
 /*
  * Validates that the given object is:
  * - not bogus address
@@ -277,5 +307,8 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 
 	/* Check for object in kernel to avoid text exposure. */
 	check_kernel_text_object((const unsigned long)ptr, n, to_user);
+
+	/* Check if object is from a pmalloc chunk. */
+	check_pmalloc_object(ptr, n, to_user);
 }
 EXPORT_SYMBOL(__check_object_size);
-- 
2.14.1
