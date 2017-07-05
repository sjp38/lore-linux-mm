Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC1B96B0387
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 09:48:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t3so29216730wme.9
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 06:48:14 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id u65si7224813wmb.21.2017.07.05.06.48.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 06:48:12 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 1/3] Protectable memory support
Date: Wed, 5 Jul 2017 16:46:26 +0300
Message-ID: <20170705134628.3803-2-igor.stoppa@huawei.com>
In-Reply-To: <20170705134628.3803-1-igor.stoppa@huawei.com>
References: <20170705134628.3803-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com, hch@infradead.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor
 Stoppa <igor.stoppa@huawei.com>

The MMU available in many systems running Linux can often provide R/O
protection to the memory pages it handles.

However, the MMU-based protection works efficiently only when said pages
contain exclusively data that will not need further modifications.

Statically allocated variables can be segregated into a dedicated
section, but this does not sit very well with dynamically allocated ones.

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

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 arch/Kconfig                   |   1 +
 include/linux/page-flags.h     |   2 +
 include/linux/pmalloc.h        | 127 +++++++++++++++
 include/trace/events/mmflags.h |   1 +
 lib/Kconfig                    |   1 +
 mm/Makefile                    |   1 +
 mm/pmalloc.c                   | 356 +++++++++++++++++++++++++++++++++++++++++
 mm/usercopy.c                  |  24 +--
 8 files changed, 504 insertions(+), 9 deletions(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

diff --git a/arch/Kconfig b/arch/Kconfig
index 6c00e5b..9d16b51 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -228,6 +228,7 @@ config GENERIC_IDLE_POLL_SETUP
 
 # Select if arch has all set_memory_ro/rw/x/nx() functions in asm/cacheflush.h
 config ARCH_HAS_SET_MEMORY
+	select GENERIC_ALLOCATOR
 	bool
 
 # Select if arch init_task initializer is different to init/init_task.c
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6b5818d..acc0723 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -81,6 +81,7 @@ enum pageflags {
 	PG_active,
 	PG_waiters,		/* Page has waiters, check its waitqueue. Must be bit #7 and in the same byte as "PG_locked" */
 	PG_slab,
+	PG_pmalloc,
 	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
 	PG_arch_1,
 	PG_reserved,
@@ -274,6 +275,7 @@ PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
 	TESTCLEARFLAG(Active, active, PF_HEAD)
 __PAGEFLAG(Slab, slab, PF_NO_TAIL)
 __PAGEFLAG(SlobFree, slob_free, PF_NO_TAIL)
+__PAGEFLAG(Pmalloc, pmalloc, PF_NO_TAIL)
 PAGEFLAG(Checked, checked, PF_NO_COMPOUND)	   /* Used by some filesystems */
 
 /* Xen */
diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
new file mode 100644
index 0000000..a374e5e
--- /dev/null
+++ b/include/linux/pmalloc.h
@@ -0,0 +1,127 @@
+/*
+ * pmalloc.h: Header for Protectable Memory Allocator
+ *
+ * (C) Copyright 2017 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#ifndef _PMALLOC_H
+#define _PMALLOC_H
+#include <linux/genalloc.h>
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
+ * determined only at runtime.
+ *
+ * ***WARNING***
+ * The user of the API is expected to synchronize:
+ * 1) allocation
+ * 2) writes to the allocated memory
+ * 3) write protection of the pool
+ * 4) freeing of the allocated memory
+ * 5) destruction of the pool
+ *
+ * For a non threaded scenario, this type of locking is not even required.
+ *
+ * Even if the library were to provided support for the locking, point 2)
+ * would still depend on the user to remember taking the lock.
+ *
+ */
+
+
+/**
+ * pmalloc_create_pool - create a new protectable memory pool -
+ * @name: the name of the pool, must be unique
+ * @min_alloc_order: log2 of the minimum allocation size obtainable
+ *                   from the pool
+ *
+ * Creates a new (empty) memory pool for allocation of protectable
+ * memory. Memory will be allocated upon request (through pmalloc).
+ *
+ * Returns a pointer to the new pool, upon succes, otherwise a NULL.
+ */
+struct gen_pool *pmalloc_create_pool(const char *name,
+					 int min_alloc_order);
+
+
+/**
+ * pmalloc - allocate protectable memory from a pool
+ * @pool: handler to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
+ *
+ * Allocates memory from an unprotected pool. If the pool doesn't have
+ * enough memory, an attempt is made to add to the pool a new chunk of
+ * memory (multiple of PAGE_SIZE) that can fit the new request.
+ *
+ * Returns the pointer to the memory requested, upon success,
+ * NULL otherwise (either no memory availabel or pool RO).
+ *
+ */
+void *pmalloc(struct gen_pool *pool, size_t size);
+
+
+
+/**
+ * pmalloc_free - release memory previously obtained through pmalloc
+ * @pool: the pool providing the memory
+ * @addr: the memory address obtained from pmalloc
+ * @size: the same amount of memory that was requested from pmalloc
+ *
+ * Releases the memory that was previously accounted for as in use.
+ * It works also on pocked pools, but the memory released is simply
+ * removed from the refcount of memory in use. It cannot be re-used.
+ */
+static __always_inline
+void pmalloc_free(struct gen_pool *pool, void *addr, size_t size)
+{
+	gen_pool_free(pool, (unsigned long)addr, size);
+}
+
+
+
+/**
+ * pmalloc_protect_pool - turn a RW pool into RO
+ * @pool: the pool to protect
+ *
+ * Write protects all the memory chunks assigned to the pool.
+ * This prevents further allocation.
+ *
+ * Returns 0 upon success, -EINVAL in abnormal cases.
+ */
+int pmalloc_protect_pool(struct gen_pool *pool);
+
+
+
+/**
+ * pmalloc_pool_protected - check if the pool is protected
+ * @pool: the pool to test
+ *
+ * Returns true if the pool is either protected or missing. False otherwise.
+ */
+bool pmalloc_pool_protected(struct gen_pool *pool);
+
+
+
+/**
+ * pmalloc_destroy_pool - destroys a pool and all the associated memory
+ * @pool: the pool to destroy
+ *
+ * All the memory that was allocated through pmalloc must first be freed
+ * with pmalloc_free. Falire to do so will BUG().
+ *
+ * Returns 0 upon success, -EINVAL in abnormal cases.
+ */
+int pmalloc_destroy_pool(struct gen_pool *pool);
+#endif
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 304ff94..41d1587 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -91,6 +91,7 @@
 	{1UL << PG_lru,			"lru"		},		\
 	{1UL << PG_active,		"active"	},		\
 	{1UL << PG_slab,		"slab"		},		\
+	{1UL << PG_pmalloc,		"pmalloc"	},		\
 	{1UL << PG_owner_priv_1,	"owner_priv_1"	},		\
 	{1UL << PG_arch_1,		"arch_1"	},		\
 	{1UL << PG_reserved,		"reserved"	},		\
diff --git a/lib/Kconfig b/lib/Kconfig
index 0c8b78a..3e3b8f6 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -270,6 +270,7 @@ config DECOMPRESS_LZ4
 # Generic allocator support is selected if needed
 #
 config GENERIC_ALLOCATOR
+	depends on ARCH_HAS_SET_MEMORY
 	bool
 
 #
diff --git a/mm/Makefile b/mm/Makefile
index 026f6a8..b47dcf8 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -65,6 +65,7 @@ obj-$(CONFIG_SPARSEMEM)	+= sparse.o
 obj-$(CONFIG_SPARSEMEM_VMEMMAP) += sparse-vmemmap.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
+obj-$(CONFIG_ARCH_HAS_SET_MEMORY) += pmalloc.o
 obj-$(CONFIG_KSM) += ksm.o
 obj-$(CONFIG_PAGE_POISONING) += page_poison.o
 obj-$(CONFIG_SLAB) += slab.o
diff --git a/mm/pmalloc.c b/mm/pmalloc.c
new file mode 100644
index 0000000..8a21fe9
--- /dev/null
+++ b/mm/pmalloc.c
@@ -0,0 +1,356 @@
+/*
+ * pmalloc.c: Protectable Memory Allocator
+ *
+ * (C) Copyright 2017 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
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
+#include <asm/set_memory.h>
+#include <asm/page.h>
+
+#include <linux/debugfs.h>
+#include <linux/kallsyms.h>
+
+static LIST_HEAD(tmp_list);
+
+/**
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
+	struct mutex mutex;
+};
+
+static LIST_HEAD(pmalloc_final_list);
+static LIST_HEAD(pmalloc_tmp_list);
+static struct list_head *pmalloc_list = &pmalloc_tmp_list;
+static DEFINE_MUTEX(pmalloc_mutex);
+static struct kobject *pmalloc_kobject;
+
+static ssize_t __pmalloc_pool_show_protected(struct kobject *dev,
+					     struct kobj_attribute *attr,
+					     char *buf)
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
+static ssize_t __pmalloc_pool_show_avail(struct kobject *dev,
+					 struct kobj_attribute *attr,
+					 char *buf)
+{
+	struct pmalloc_data *data;
+
+	data = container_of(attr, struct pmalloc_data, attr_avail);
+	return sprintf(buf, "%lu\n", gen_pool_avail(data->pool));
+}
+
+static ssize_t __pmalloc_pool_show_size(struct kobject *dev,
+					struct kobj_attribute *attr,
+					char *buf)
+{
+	struct pmalloc_data *data;
+
+	data = container_of(attr, struct pmalloc_data, attr_size);
+	return sprintf(buf, "%lu\n", gen_pool_size(data->pool));
+}
+
+static void __pool_chunk_number(struct gen_pool *pool,
+				struct gen_pool_chunk *chunk, void *data)
+{
+	if (!data)
+		return;
+	*(unsigned long *)data += 1;
+}
+
+static ssize_t __pmalloc_pool_show_chunks(struct kobject *dev,
+					  struct kobj_attribute *attr,
+					  char *buf)
+{
+	struct pmalloc_data *data;
+	unsigned long chunks_num = 0;
+
+	data = container_of(attr, struct pmalloc_data, attr_chunks);
+	gen_pool_for_each_chunk(data->pool, __pool_chunk_number, &chunks_num);
+	return sprintf(buf, "%lu\n", chunks_num);
+}
+
+/**
+ * Exposes the pool and its attributes through sysfs.
+ */
+static void __pmalloc_connect(struct pmalloc_data *data)
+{
+	data->pool_kobject = kobject_create_and_add(data->pool->name,
+						    pmalloc_kobject);
+	sysfs_create_file(data->pool_kobject, &data->attr_protected.attr);
+	sysfs_create_file(data->pool_kobject, &data->attr_avail.attr);
+	sysfs_create_file(data->pool_kobject, &data->attr_size.attr);
+	sysfs_create_file(data->pool_kobject, &data->attr_chunks.attr);
+}
+
+/**
+ * Removes the pool and its attributes from sysfs.
+ */
+static void __pmalloc_disconnect(struct pmalloc_data *data)
+{
+	sysfs_remove_file(data->pool_kobject, &data->attr_protected.attr);
+	sysfs_remove_file(data->pool_kobject, &data->attr_avail.attr);
+	sysfs_remove_file(data->pool_kobject, &data->attr_size.attr);
+	sysfs_remove_file(data->pool_kobject, &data->attr_chunks.attr);
+	kobject_put(data->pool_kobject);
+}
+
+/**
+ * Declares an attribute of the pool.
+ */
+
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+#define do_lock_dep(data, attr_name) \
+	(data->attr_##attr_name.attr.ignore_lockdep = 1)
+#else
+#define do_lock_dep(data, attr_name) do {} while (0)
+#endif
+
+#define __pmalloc_attr_init(data, attr_name) \
+do { \
+	data->attr_##attr_name.attr.name = #attr_name; \
+	data->attr_##attr_name.attr.mode = VERIFY_OCTAL_PERMISSIONS(0444); \
+	data->attr_##attr_name.show = __pmalloc_pool_show_##attr_name; \
+	do_lock_dep(data, attr_name); \
+} while (0)
+
+struct gen_pool *pmalloc_create_pool(const char *name, int min_alloc_order)
+{
+	struct gen_pool *pool;
+	const char *pool_name;
+	struct pmalloc_data *data;
+
+	if (!name)
+		return NULL;
+	pool_name = kstrdup(name, GFP_KERNEL);
+	if (!pool_name)
+		return NULL;
+	data = kzalloc(sizeof(struct pmalloc_data), GFP_KERNEL);
+	if (!data)
+		return NULL;
+	if (min_alloc_order < 0)
+		min_alloc_order = ilog2(sizeof(unsigned long));
+	pool = gen_pool_create(min_alloc_order, NUMA_NO_NODE);
+	if (!pool) {
+		kfree(pool_name);
+		kfree(data);
+		return NULL;
+	}
+	data->protected = false;
+	data->pool = pool;
+	mutex_init(&data->mutex);
+	__pmalloc_attr_init(data, protected);
+	__pmalloc_attr_init(data, avail);
+	__pmalloc_attr_init(data, size);
+	__pmalloc_attr_init(data, chunks);
+	pool->data = data;
+	pool->name = pool_name;
+	mutex_lock(&pmalloc_mutex);
+	list_add(&data->node, &pmalloc_tmp_list);
+	if (pmalloc_list == &pmalloc_final_list)
+		__pmalloc_connect(data);
+	mutex_unlock(&pmalloc_mutex);
+	return pool;
+}
+
+
+/**
+ * To support hardened usercopy, tag/untag pages supplied by pmalloc.
+ * Pages are tagged when added to a pool and untagged when removed
+ * from said pool.
+ */
+#define PMALLOC_TAG_PAGE true
+#define PMALLOC_UNTAG_PAGE false
+static inline
+int __pmalloc_tag_pages(void *base, const size_t size, const bool set_tag)
+{
+	void *end = base + size - 1;
+
+	do {
+		struct page *page;
+
+		if (!is_vmalloc_addr(base))
+			return -EINVAL;
+		page = vmalloc_to_page(base);
+		if (set_tag)
+			__SetPagePmalloc(page);
+		else
+			__ClearPagePmalloc(page);
+		base += PAGE_SIZE;
+	} while ((PAGE_MASK & (unsigned long)base) <=
+		 (PAGE_MASK & (unsigned long)end));
+	return 0;
+}
+
+
+static void __page_untag(struct gen_pool *pool,
+			 struct gen_pool_chunk *chunk, void *data)
+{
+	__pmalloc_tag_pages((void *)chunk->start_addr,
+			    chunk->end_addr - chunk->start_addr + 1,
+			    PMALLOC_UNTAG_PAGE);
+}
+
+void *pmalloc(struct gen_pool *pool, size_t size)
+{
+	void *retval, *chunk;
+	size_t chunk_size;
+
+	if (!size || !pool || ((struct pmalloc_data *)pool->data)->protected)
+		return NULL;
+	retval = (void *)gen_pool_alloc(pool, size);
+	if (retval)
+		return retval;
+	chunk_size = roundup(size, PAGE_SIZE);
+	chunk = vmalloc(chunk_size);
+	if (!chunk)
+		return NULL;
+	__pmalloc_tag_pages(chunk, size, PMALLOC_TAG_PAGE);
+	/* Locking is already done inside gen_pool_add_virt */
+	BUG_ON(gen_pool_add_virt(pool, (unsigned long)chunk,
+				(phys_addr_t)NULL, chunk_size, NUMA_NO_NODE));
+	return (void *)gen_pool_alloc(pool, size);
+}
+
+static void __page_protection(struct gen_pool *pool,
+			      struct gen_pool_chunk *chunk, void *data)
+{
+	unsigned long pages;
+
+	if (!data)
+		return;
+	pages = roundup(chunk->end_addr - chunk->start_addr + 1,
+			PAGE_SIZE) / PAGE_SIZE;
+	if (*(bool *)data)
+		set_memory_ro(chunk->start_addr, pages);
+	else
+		set_memory_rw(chunk->start_addr, pages);
+}
+
+static int __pmalloc_pool_protection(struct gen_pool *pool, bool protection)
+{
+	struct pmalloc_data *data;
+	struct gen_pool_chunk *chunk;
+
+	if (!pool)
+		return -EINVAL;
+	data = (struct pmalloc_data *)pool->data;
+	mutex_lock(&data->mutex);
+	BUG_ON(data->protected == protection);
+	data->protected = protection;
+	list_for_each_entry(chunk, &(pool)->chunks, next_chunk)
+		__page_protection(pool, chunk, &protection);
+	mutex_unlock(&data->mutex);
+	return 0;
+}
+
+int pmalloc_protect_pool(struct gen_pool *pool)
+{
+	return __pmalloc_pool_protection(pool, true);
+}
+
+
+bool pmalloc_pool_protected(struct gen_pool *pool)
+{
+	if (!pool)
+		return true;
+	return ((struct pmalloc_data *)pool->data)->protected;
+}
+
+
+int pmalloc_destroy_pool(struct gen_pool *pool)
+{
+	struct pmalloc_data *data;
+
+	if (!pool)
+		return -EINVAL;
+	data = (struct pmalloc_data *)pool->data;
+	mutex_lock(&data->mutex);
+	list_del(&data->node);
+	mutex_unlock(&data->mutex);
+	gen_pool_for_each_chunk(pool, __page_untag, NULL);
+	__pmalloc_disconnect(data);
+	__pmalloc_pool_protection(pool, false);
+	gen_pool_destroy(pool);
+	kfree(data);
+	return 0;
+}
+
+static const char msg[] = "Not a valid Pmalloc object.";
+const char *__pmalloc_check_object(const void *ptr, unsigned long n)
+{
+	unsigned long p;
+
+	p = (unsigned long)ptr;
+	n = p + n - 1;
+	for (; (PAGE_MASK & p) <= (PAGE_MASK & n); p += PAGE_SIZE) {
+		struct page *page;
+
+		if (!is_vmalloc_addr((void *)p))
+			return msg;
+		page = vmalloc_to_page((void *)p);
+		if (!(page && PagePmalloc(page)))
+			return msg;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(__pmalloc_check_object);
+
+
+/**
+ * When the sysfs is ready to receive registrations, connect all the
+ * pools previously created. Also enable further pools to be connected
+ * right away.
+ */
+static int __init pmalloc_late_init(void)
+{
+	struct pmalloc_data *data, *n;
+
+	pmalloc_kobject = kobject_create_and_add("pmalloc", kernel_kobj);
+	mutex_lock(&pmalloc_mutex);
+	pmalloc_list = &pmalloc_final_list;
+	list_for_each_entry_safe(data, n, &pmalloc_tmp_list, node) {
+		list_move(&data->node, &pmalloc_final_list);
+		__pmalloc_connect(data);
+	}
+	mutex_unlock(&pmalloc_mutex);
+	return 0;
+}
+late_initcall(pmalloc_late_init);
diff --git a/mm/usercopy.c b/mm/usercopy.c
index a9852b2..29bb691 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -195,22 +195,28 @@ static inline const char *check_page_span(const void *ptr, unsigned long n,
 	return NULL;
 }
 
+extern const char *__pmalloc_check_object(const void *ptr, unsigned long n);
+
 static inline const char *check_heap_object(const void *ptr, unsigned long n,
 					    bool to_user)
 {
 	struct page *page;
 
-	if (!virt_addr_valid(ptr))
-		return NULL;
-
-	page = virt_to_head_page(ptr);
-
-	/* Check slab allocator for flags and size. */
-	if (PageSlab(page))
-		return __check_heap_object(ptr, n, page);
+	if (virt_addr_valid(ptr)) {
+		page = virt_to_head_page(ptr);
 
+		/* Check slab allocator for flags and size. */
+		if (PageSlab(page))
+			return __check_heap_object(ptr, n, page);
 	/* Verify object does not incorrectly span multiple pages. */
-	return check_page_span(ptr, n, page, to_user);
+		return check_page_span(ptr, n, page, to_user);
+	}
+	if (likely(is_vmalloc_addr(ptr))) {
+		page = vmalloc_to_page(ptr);
+		if (unlikely(page && PagePmalloc(page)))
+			return __pmalloc_check_object(ptr, n);
+	}
+	return NULL;
 }
 
 /*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
