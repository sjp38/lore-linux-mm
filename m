Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 876426B0007
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 15:09:54 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id c16so1518369pgv.8
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 12:09:54 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id t74si1404686pgc.649.2018.02.28.12.09.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 12:09:51 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 4/7] Protectable Memory
Date: Wed, 28 Feb 2018 22:06:17 +0200
Message-ID: <20180228200620.30026-5-igor.stoppa@huawei.com>
In-Reply-To: <20180228200620.30026-1-igor.stoppa@huawei.com>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
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
 include/linux/genalloc.h |  13 ++
 include/linux/pmalloc.h  | 242 ++++++++++++++++++++++++
 include/linux/vmalloc.h  |   1 +
 lib/genalloc.c           |  24 +++
 mm/Kconfig               |   7 +
 mm/Makefile              |   1 +
 mm/pmalloc.c             | 468 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/usercopy.c            |  33 ++++
 8 files changed, 789 insertions(+)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
index 7b1a1f1d9985..3c936c4390df 100644
--- a/include/linux/genalloc.h
+++ b/include/linux/genalloc.h
@@ -231,6 +231,19 @@ void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma);
  */
 void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size);
 
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
+			  struct gen_pool_chunk *chunk);
+
 /**
  * gen_pool_for_each_chunk() - call func for every chunk of generic memory pool
  * @pool:	the generic memory pool
diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
new file mode 100644
index 000000000000..72550a325ca1
--- /dev/null
+++ b/include/linux/pmalloc.h
@@ -0,0 +1,242 @@
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
+struct gen_pool *pmalloc_create_pool(const char *name,
+					 int min_alloc_order);
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
+int is_pmalloc_object(const void *ptr, const unsigned long n);
+
+/**
+ * pmalloc_prealloc() - tries to allocate a memory chunk of the requested size
+ * @pool: handle to the pool to be used for memory allocation
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
+ *
+ * Return:
+ * * true	- the vmalloc call was successful
+ * * false	- error
+ */
+bool pmalloc_prealloc(struct gen_pool *pool, size_t size);
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
+/**
+ * pmalloc_protect_pool() - turn a read/write pool read-only
+ * @pool: the pool to protect
+ *
+ * Write-protects all the memory chunks assigned to the pool.
+ * This prevents any further allocation.
+ *
+ * Return:
+ * * 0		- success
+ * * -EINVAL	- error
+ */
+int pmalloc_protect_pool(struct gen_pool *pool);
+
+/**
+ * pfree() - mark as unused memory that was previously in use
+ * @pool: handle to the pool to be used for memory allocation
+ * @addr: the beginning of the memory area to be freed
+ *
+ * The behavior of pfree is different, depending on the state of the
+ * protection.
+ * If the pool is not yet protected, the memory is marked as unused and
+ * will be available for further allocations.
+ * If the pool is already protected, the memory is marked as unused, but
+ * it will still be impossible to perform further allocation, because of
+ * the existing protection.
+ * The freed memory, in this case, will be truly released only when the
+ * pool is destroyed.
+ */
+static inline void pfree(struct gen_pool *pool, const void *addr)
+{
+	gen_pool_free(pool, (unsigned long)addr, 0);
+}
+
+/**
+ * pmalloc_destroy_pool() - destroys a pool and all the associated memory
+ * @pool: the pool to destroy
+ *
+ * All the memory that was allocated through pmalloc in the pool will be freed.
+ *
+ * Return:
+ * * 0		- success
+ * * -EINVAL	- error
+ */
+int pmalloc_destroy_pool(struct gen_pool *pool);
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
index d505b959f888..a7ae088cbc5e 100644
--- a/lib/genalloc.c
+++ b/lib/genalloc.c
@@ -654,6 +654,30 @@ void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
 }
 EXPORT_SYMBOL(gen_pool_free);
 
+
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
index 000000000000..acdec0fbdde6
--- /dev/null
+++ b/mm/pmalloc.c
@@ -0,0 +1,468 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * pmalloc.c: Protectable Memory Allocator
+ *
+ * (C) Copyright 2017 Huawei Technologies Co. Ltd.
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
+static LIST_HEAD(pmalloc_final_list);
+static LIST_HEAD(pmalloc_tmp_list);
+static struct list_head *pmalloc_list = &pmalloc_tmp_list;
+static DEFINE_MUTEX(pmalloc_mutex);
+static struct kobject *pmalloc_kobject;
+
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
+static void pool_chunk_number(struct gen_pool *pool,
+			      struct gen_pool_chunk *chunk, void *data)
+{
+	unsigned long *counter = data;
+
+	(*counter)++;
+}
+
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
+/* Exposes the pool and its attributes through sysfs. */
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
+		kobj = NULL;
+	}
+	return kobj;
+}
+
+/* Removes the pool and its attributes from sysfs. */
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
+struct gen_pool *pmalloc_create_pool(const char *name, int min_alloc_order)
+{
+	struct gen_pool *pool;
+	const char *pool_name;
+	struct pmalloc_data *data;
+
+	if (unlikely(!name)) {
+		WARN(true, "unnamed pool");
+		return NULL;
+	}
+
+	if (min_alloc_order < 0)
+		min_alloc_order = ilog2(sizeof(unsigned long));
+
+	pool = gen_pool_create(min_alloc_order, NUMA_NO_NODE);
+	if (unlikely(!pool))
+		return NULL;
+
+	mutex_lock(&pmalloc_mutex);
+	list_for_each_entry(data, pmalloc_list, node)
+		if (!strcmp(name, data->pool->name))
+			goto same_name_err;
+
+	pool_name = kstrdup(name, GFP_KERNEL);
+	if (unlikely(!pool_name))
+		goto name_alloc_err;
+
+	data = kzalloc(sizeof(struct pmalloc_data), GFP_KERNEL);
+	if (unlikely(!data))
+		goto data_alloc_err;
+
+	data->protected = false;
+	data->pool = pool;
+	pmalloc_attr_init(data, protected);
+	pmalloc_attr_init(data, avail);
+	pmalloc_attr_init(data, size);
+	pmalloc_attr_init(data, chunks);
+	pool->data = data;
+	pool->name = pool_name;
+
+	list_add(&data->node, pmalloc_list);
+	if (pmalloc_list == &pmalloc_final_list)
+		data->pool_kobject = pmalloc_connect(data);
+	mutex_unlock(&pmalloc_mutex);
+	return pool;
+
+data_alloc_err:
+	kfree(pool_name);
+name_alloc_err:
+same_name_err:
+	mutex_unlock(&pmalloc_mutex);
+	gen_pool_destroy(pool);
+	return NULL;
+}
+
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
+	if (tag)
+		area->flags |= VM_PMALLOC;
+	else
+		area->flags &= ~VM_PMALLOC;
+	return true;
+}
+
+
+static inline bool tag_chunk(void *chunk)
+{
+	return chunk_tagging(chunk, true);
+}
+
+
+static inline bool untag_chunk(void *chunk)
+{
+	return chunk_tagging(chunk, false);
+}
+
+enum {
+	INVALID_PMALLOC_OBJECT = -1,
+	NOT_PMALLOC_OBJECT = 0,
+	VALID_PMALLOC_OBJECT = 1,
+};
+
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
+bool pmalloc_prealloc(struct gen_pool *pool, size_t size)
+{
+	void *chunk;
+	size_t chunk_size;
+	bool add_error;
+
+	/* Expand pool */
+	chunk_size = roundup(size, PAGE_SIZE);
+	chunk = vmalloc(chunk_size);
+	if (unlikely(chunk == NULL))
+		return false;
+
+	/* Locking is already done inside gen_pool_add */
+	add_error = gen_pool_add(pool, (unsigned long)chunk, chunk_size,
+				 NUMA_NO_NODE);
+	if (unlikely(add_error != 0))
+		goto abort;
+
+	return true;
+abort:
+	vfree_atomic(chunk);
+	return false;
+
+}
+
+void *pmalloc(struct gen_pool *pool, size_t size, gfp_t gfp)
+{
+	void *chunk;
+	size_t chunk_size;
+	bool add_error;
+	unsigned long retval;
+
+	if (unlikely(((struct pmalloc_data *)(pool->data))->protected)) {
+		WARN(true, "pool %s is already protected", pool->name);
+		return NULL;
+	}
+
+retry_alloc_from_pool:
+	retval = gen_pool_alloc(pool, size);
+	if (retval)
+		goto return_allocation;
+
+	if (unlikely((gfp & __GFP_ATOMIC))) {
+		if (unlikely((gfp & __GFP_NOFAIL)))
+			goto retry_alloc_from_pool;
+		else
+			return NULL;
+	}
+
+	/* Expand pool */
+	chunk_size = roundup(size, PAGE_SIZE);
+	chunk = vmalloc(chunk_size);
+	if (unlikely(!chunk)) {
+		if (unlikely((gfp & __GFP_NOFAIL)))
+			goto retry_alloc_from_pool;
+		else
+			return NULL;
+	}
+	if (unlikely(!tag_chunk(chunk)))
+		goto free;
+
+	/* Locking is already done inside gen_pool_add */
+	add_error = gen_pool_add(pool, (unsigned long)chunk, chunk_size,
+				 NUMA_NO_NODE);
+	if (unlikely(add_error))
+		goto abort;
+
+	retval = gen_pool_alloc(pool, size);
+	if (retval) {
+return_allocation:
+		*(size_t *)retval = size;
+		if (gfp & __GFP_ZERO)
+			memset((void *)retval, 0, size);
+		return (void *)retval;
+	}
+	/*
+	 * Here there is no test for __GFP_NO_FAIL because, in case of
+	 * concurrent allocation, one thread might add a chunk to the
+	 * pool and this memory could be allocated by another thread,
+	 * before the first thread gets a chance to use it.
+	 * As long as vmalloc succeeds, it's ok to retry.
+	 */
+	goto retry_alloc_from_pool;
+abort:
+	untag_chunk(chunk);
+free:
+	vfree_atomic(chunk);
+	return NULL;
+}
+
+static void pmalloc_chunk_set_protection(struct gen_pool *pool,
+					 struct gen_pool_chunk *chunk,
+					 void *data)
+{
+	const bool *flag = data;
+	size_t chunk_size = chunk->end_addr + 1 - chunk->start_addr;
+	unsigned long pages = chunk_size / PAGE_SIZE;
+
+	if (unlikely(chunk_size & (PAGE_SIZE - 1))) {
+		WARN(true, "Chunk size is not a multiple of PAGE_SIZE.");
+		return;
+	}
+
+	if (*flag)
+		set_memory_ro(chunk->start_addr, pages);
+	else
+		set_memory_rw(chunk->start_addr, pages);
+}
+
+static int pmalloc_pool_set_protection(struct gen_pool *pool, bool protection)
+{
+	struct pmalloc_data *data;
+	struct gen_pool_chunk *chunk;
+
+	data = pool->data;
+	if (unlikely(data->protected == protection)) {
+		WARN(true, "The pool %s is already protected as requested",
+		     pool->name);
+		return 0;
+	}
+	data->protected = protection;
+	list_for_each_entry(chunk, &(pool)->chunks, next_chunk)
+		pmalloc_chunk_set_protection(pool, chunk, &protection);
+	return 0;
+}
+
+int pmalloc_protect_pool(struct gen_pool *pool)
+{
+	return pmalloc_pool_set_protection(pool, true);
+}
+
+
+static void pmalloc_chunk_free(struct gen_pool *pool,
+			       struct gen_pool_chunk *chunk, void *data)
+{
+	untag_chunk(chunk);
+	gen_pool_flush_chunk(pool, chunk);
+	vfree_atomic((void *)chunk->start_addr);
+}
+
+
+int pmalloc_destroy_pool(struct gen_pool *pool)
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
+	return 0;
+}
+
+/*
+ * When the sysfs is ready to receive registrations, connect all the
+ * pools previously created. Also enable further pools to be connected
+ * right away.
+ */
+static int __init pmalloc_late_init(void)
+{
+	struct pmalloc_data *data, *n;
+
+	pmalloc_kobject = kobject_create_and_add("pmalloc", kernel_kobj);
+
+	mutex_lock(&pmalloc_mutex);
+	pmalloc_list = &pmalloc_final_list;
+
+	if (likely(pmalloc_kobject != NULL)) {
+		list_for_each_entry_safe(data, n, &pmalloc_tmp_list, node) {
+			list_move(&data->node, &pmalloc_final_list);
+			pmalloc_connect(data);
+		}
+	}
+	mutex_unlock(&pmalloc_mutex);
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
