Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7D716B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 21:56:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p4so7613567wrf.17
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:56:50 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id t67si75433wrc.381.2018.03.26.18.56.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 18:56:48 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 3/6] Protectable Memory
Date: Tue, 27 Mar 2018 04:55:21 +0300
Message-ID: <20180327015524.14318-4-igor.stoppa@huawei.com>
In-Reply-To: <20180327015524.14318-1-igor.stoppa@huawei.com>
References: <20180327015524.14318-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>

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

A pool is organized in areas of virtually contiguous memory.
Whenever the protection functionality is invoked on a pool, all the
areas it contains are marked as read-only.

The process of growing and protecting the pool can be iterated at will.

The pool can only be destroyed (it is up to its user to avoid any further
references to the memory from the pool, after the destruction is invoked).

The latter case is mainly meant for releasing memory, when a module is
unloaded.

A module can have as many pools as needed, for example to support the
protection of data that is initialized in sufficiently distinct phases.

Since pmalloc memory is obtained from vmalloc, an attacker that has
gained access to the physical mapping, still has to identify where the
target of the attack is actually located.

At the same time, being also based on genalloc, pmalloc does not
generate as much trashing of the TLB as it would be caused by only using
directly vmalloc.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/pmalloc.h | 281 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/vmalloc.h |   3 +
 mm/Kconfig              |   6 +
 mm/Makefile             |   1 +
 mm/pmalloc.c            | 321 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/usercopy.c           |  33 +++++
 mm/vmalloc.c            |   2 +-
 7 files changed, 646 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
new file mode 100644
index 000000000000..1d71fb73bb5b
--- /dev/null
+++ b/include/linux/pmalloc.h
@@ -0,0 +1,281 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * pmalloc.h: Header for Protectable Memory Allocator
+ *
+ * (C) Copyright 2017-18 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#ifndef _LINUX_PMALLOC_H
+#define _LINUX_PMALLOC_H
+
+
+#include <linux/string.h>
+
+/*
+ * Library for dynamic allocation of pools of protectable memory.
+ * A pool is a single linked list of vmap_area structures.
+ * Whenever a pool is protected, all the areas it contain at that point
+ * are write protected.
+ * More areas can be added and protected, in the same way.
+ * Memory in a pool cannot be individually unprotected, but the pool can
+ * be destroyed.
+ * Upon destruction of a certain pool, all the related memory is released,
+ * including its metadata.
+ *
+ * Pmalloc memory is intended to complement __read_only_after_init.
+ * It can be used, for example, where there is a write-once variable, for
+ * which it is not possible to know the initialization value before init
+ * is completed (which is what __read_only_after_init requires).
+ *
+ * It can be useful also where the amount of data to protect is not known
+ * at compile time and the memory can only be allocated dynamically.
+ *
+ * Finally, it can be useful also when it is desirable to control
+ * dynamically (for example throguh the command line) if something ought
+ * to be protected or not, without having to rebuild the kernel (like in
+ * the build used for a linux distro).
+ */
+
+
+#define PMALLOC_REFILL_DEFAULT (0)
+#define PMALLOC_ALIGN_DEFAULT (-1)
+
+struct pmalloc_pool *pmalloc_create_custom_pool(unsigned long int refill,
+						short int align_order);
+
+/**
+ * pmalloc_create_pool() - create a protectable memory pool
+ *
+ * Shorthand for pmalloc_create_custom_pool() with default arguments:
+ * * refill is set to PMALLOC_REFILL_DEFAULT, which is one memory page
+ * * align_order is set to PMALLOC_ALIGN_DEFAULT, which is size_of(size_t)
+ *
+ * Return:
+ * * pointer to the new pool	- success
+ * * NULL			- error
+ */
+static inline struct pmalloc_pool *pmalloc_create_pool(void)
+{
+	return pmalloc_create_custom_pool(PMALLOC_REFILL_DEFAULT,
+					  PMALLOC_ALIGN_DEFAULT);
+}
+
+
+//bool pmalloc_expand_pool(struct gen_pool *pool, size_t size);
+
+
+void *pmalloc_align(struct pmalloc_pool *pool, size_t size,
+		    short int align_order);
+
+
+/**
+ * pmalloc() - allocates protectable memory from a pool
+ * @pool: handle to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
+ *
+ * Shorthand for pmalloc_align() with default argument:
+ * align_order = PMALLOC_ALIGN_DEFAULT, value set when creating the pool
+ *
+ * Return:
+ * * pointer to the new pool	- success
+ * * NULL			- error
+ */
+static inline void *pmalloc(struct pmalloc_pool *pool, size_t size)
+{
+	return pmalloc_align(pool, size, PMALLOC_ALIGN_DEFAULT);
+}
+
+
+/**
+ * pzalloc_align() - zero-initialized version of pmalloc_align
+ * @pool: handle to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
+ * @align_order: log2 of the alignment of the allocation
+ *               Setting it to PMALLOC_ALIGN_DEFAULT will use the value
+ *               specified when the pool was created.
+ *
+ * Executes pmalloc_align, initializing the memory requested to 0,
+ * before returning its address.
+ *
+ * Return:
+ * * pointer to the memory requested	- success
+ * * NULL				- error
+ */
+static inline void *pzalloc_align(struct pmalloc_pool *pool, size_t size,
+				  short int align_order)
+{
+	void *ptr = pmalloc_align(pool, size, align_order);
+
+	if (likely(ptr))
+		memset(ptr, 0, size);
+
+	return ptr;
+}
+
+
+/**
+ * pzalloc() - zero-initialized version of pmalloc()
+ * @pool: handle to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
+ *
+ * Shorthand for pmalloc_align(), with align set to PMALLOC_ALIGN_DEFAULT
+ *
+ * Return:
+ * * pointer to the memory requested	- success
+ * * NULL				- error
+ */
+static inline void *pzalloc(struct pmalloc_pool *pool, size_t size)
+{
+	return pzalloc_align(pool, size, PMALLOC_ALIGN_DEFAULT);
+}
+
+
+/**
+ * pmalloc_array_align() - array version of pmalloc_align
+ * @pool: handle to the pool to be used for memory allocation
+ * @n: number of elements in the array
+ * @size: amount of memory (in bytes) requested for each element
+ * @align_order: log2 of the alignment of the allocation
+ *               Setting it to PMALLOC_ALIGN_DEFAULT will use the value
+ *               specified when the pool was created.
+ *
+ * Executes pmalloc_align(), on an array.
+ *
+ * Return:
+ * * the pmalloc result	- success
+ * * NULL		- error
+ */
+static inline void *pmalloc_array_align(struct pmalloc_pool *pool,
+					size_t n, size_t size,
+					short int align_order)
+{
+	return pmalloc_align(pool, n * size, align_order);
+}
+
+
+/**
+ * pmalloc_array() - array version of pmalloc()
+ * @pool: handle to the pool to be used for memory allocation
+ * @n: number of elements in the array
+ * @size: amount of memory (in bytes) requested for each element
+ *
+ * Executes pmalloc_align(), on an array.
+ *
+ * Return:
+ * * the pmalloc result	- success
+ * * NULL		- error
+ */
+static inline void *pmalloc_array(struct pmalloc_pool *pool, size_t n,
+				  size_t size)
+{
+	return pmalloc_array_align(pool, n, size, PMALLOC_ALIGN_DEFAULT);
+}
+
+
+/**
+ * pcalloc_align() - array version of pzalloc_align()
+ * @pool: handle to the pool to be used for memory allocation
+ * @n: number of elements in the array
+ * @size: amount of memory (in bytes) requested for each element
+ * @align_order: log2 of the alignment of the allocation
+ *               Setting it to PMALLOC_ALIGN_DEFAULT will use the value
+ *               specified when the pool was created.
+ *
+ * Executes pzalloc_align(), on an array.
+ *
+ * Return:
+ * * the pmalloc result	- success
+ * * NULL		- error
+ */
+static inline void *pcalloc_align(struct pmalloc_pool *pool, size_t n,
+				  size_t size, short int align_order)
+{
+	return pzalloc_align(pool, n * size, align_order);
+}
+
+
+/**
+ * pcalloc() - array version of pzalloc()
+ * @pool: handle to the pool to be used for memory allocation
+ * @n: number of elements in the array
+ * @size: amount of memory (in bytes) requested for each element
+ *
+ * Executes pzalloc(), on an array.
+ *
+ * Return:
+ * * the pmalloc result	- success
+ * * NULL		- error
+ */
+static inline void *pcalloc(struct pmalloc_pool *pool, size_t n,
+			    size_t size)
+{
+	return pzalloc_align(pool, n * size, PMALLOC_ALIGN_DEFAULT);
+}
+
+/**
+ * pstrdup_align() - duplicate a string, using pmalloc_align()
+ * @pool: handle to the pool to be used for memory allocation
+ * @s: string to duplicate
+ * @align_order: log2 of the alignment of the allocation
+ *               Setting it to PMALLOC_ALIGN_DEFAULT will use the value
+ *               specified when the pool was created.
+ *
+ * Generates a copy of the given string, allocating sufficient memory
+ * from the given pmalloc pool.
+ *
+ * Return:
+ * * pointer to the replica	- success
+ * * NULL			- error
+ */
+static inline char *pstrdup_align(struct pmalloc_pool *pool,
+				  const char *s, short int align_order)
+{
+	size_t len;
+	char *buf;
+
+	len = strlen(s) + 1;
+	buf = pmalloc_align(pool, len, align_order);
+	if (likely(buf))
+		strncpy(buf, s, len);
+	return buf;
+}
+
+
+/**
+ * pstrdup() - duplicate a string, using pmalloc()
+ * @pool: handle to the pool to be used for memory allocation
+ * @s: string to duplicate
+ *
+ * Generates a copy of the given string, allocating sufficient memory
+ * from the given pmalloc pool.
+ *
+ * Return:
+ * * pointer to the replica	- success
+ * * NULL			- error
+ */
+static inline char *pstrdup(struct pmalloc_pool *pool, const char *s)
+{
+	return pstrdup_align(pool, s, PMALLOC_ALIGN_DEFAULT);
+}
+
+
+void pmalloc_protect_pool(struct pmalloc_pool *pool);
+
+
+void pmalloc_destroy_pool(struct pmalloc_pool *pool);
+
+
+int is_pmalloc_object(const void *ptr, const unsigned long n);
+
+
+unsigned long pmalloc_get_offset(struct pmalloc_pool *pool);
+
+
+unsigned long pmalloc_get_align(struct pmalloc_pool *pool);
+
+
+unsigned long pmalloc_get_refill(struct pmalloc_pool *pool);
+
+
+#endif
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 2d07dfef3cfd..69c12f21200f 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -20,6 +20,8 @@ struct notifier_block;		/* in notifier.h */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
+#define VM_PMALLOC		0x00000100	/* pmalloc area - see docs */
+#define VM_PMALLOC_PROTECTED	0x00000200	/* protected area - see docs */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
@@ -133,6 +135,7 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 					const void *caller);
 extern struct vm_struct *remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
+extern struct vmap_area *find_vmap_area(unsigned long addr);
 
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page **pages);
diff --git a/mm/Kconfig b/mm/Kconfig
index c782e8fb7235..1ac1dfc60c22 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -760,3 +760,9 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config PROTECTABLE_MEMORY
+    bool
+    depends on MMU
+    depends on ARCH_HAS_SET_MEMORY
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
index 000000000000..68270a23ad8b
--- /dev/null
+++ b/mm/pmalloc.c
@@ -0,0 +1,321 @@
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
+#include <linux/kernel.h>
+#include <linux/log2.h>
+#include <linux/slab.h>
+#include <linux/set_memory.h>
+#include <linux/bug.h>
+#include <linux/mutex.h>
+#include <linux/llist.h>
+#include <asm/cacheflush.h>
+#include <asm/page.h>
+
+#include <linux/pmalloc.h>
+
+#define MAX_ALIGN_ORDER (ilog2(sizeof(void *)))
+struct pmalloc_pool {
+	struct mutex mutex;
+	struct list_head pool_node;
+	struct llist_head vm_areas;
+	unsigned long refill;
+	unsigned long offset;
+	unsigned long align;
+};
+
+static LIST_HEAD(pools_list);
+static DEFINE_MUTEX(pools_mutex);
+
+static inline void tag_area(struct vmap_area *area)
+{
+	area->vm->flags |= VM_PMALLOC;
+}
+
+static inline void untag_area(struct vmap_area *area)
+{
+	area->vm->flags &= ~VM_PMALLOC;
+}
+
+static inline struct vmap_area *current_area(struct pmalloc_pool *pool)
+{
+	return llist_entry(pool->vm_areas.first, struct vmap_area,
+			   area_list);
+}
+
+static inline bool is_area_protected(struct vmap_area *area)
+{
+	return area->vm->flags & VM_PMALLOC_PROTECTED;
+}
+
+static inline bool protect_area(struct vmap_area *area)
+{
+	if (unlikely(is_area_protected(area)))
+		return false;
+	set_memory_ro(area->va_start, area->vm->nr_pages);
+	area->vm->flags |= VM_PMALLOC_PROTECTED;
+	return true;
+}
+
+static inline void destroy_area(struct vmap_area *area)
+{
+	WARN(!is_area_protected(area), "Destroying unprotected area.");
+	set_memory_rw(area->va_start, area->vm->nr_pages);
+	vfree((void *)area->va_start);
+}
+
+static inline bool empty(struct pmalloc_pool *pool)
+{
+	return unlikely(llist_empty(&pool->vm_areas));
+}
+
+static inline bool protected(struct pmalloc_pool *pool)
+{
+	return is_area_protected(current_area(pool));
+}
+
+static inline unsigned long get_align(struct pmalloc_pool *pool,
+				      short int align_order)
+{
+	if (likely(align_order < 0))
+		return pool->align;
+	return 1UL << align_order;
+}
+
+static inline bool exhausted(struct pmalloc_pool *pool, size_t size,
+			     short int align_order)
+{
+	unsigned long align = get_align(pool, align_order);
+	unsigned long space_before = round_down(pool->offset, align);
+	unsigned long space_after = pool->offset - space_before;
+
+	return unlikely(space_after < size && space_before < size);
+}
+
+static inline bool space_needed(struct pmalloc_pool *pool, size_t size,
+				short int align_order)
+{
+	return empty(pool) || protected(pool) ||
+		exhausted(pool, size, align_order);
+}
+
+#define DEFAULT_REFILL_SIZE PAGE_SIZE
+/**
+ * pmalloc_create_custom_pool() - create a new protectable memory pool
+ * @refill: the minimum size to allocate when in need of more memory.
+ *          It will be rounded up to a multiple of PAGE_SIZE
+ *          The value of 0 gives the default amount of PAGE_SIZE.
+ * @align_order: log2 of the alignment to use when allocating memory
+ *               Negative values give log2(sizeof(size_t)).
+ *
+ * Creates a new (empty) memory pool for allocation of protectable
+ * memory. Memory will be allocated upon request (through pmalloc).
+ *
+ * Return:
+ * * pointer to the new pool	- success
+ * * NULL			- error
+ */
+struct pmalloc_pool *pmalloc_create_custom_pool(unsigned long refill,
+						short int align_order)
+{
+	struct pmalloc_pool *pool;
+
+	pool = kzalloc(sizeof(struct pmalloc_pool), GFP_KERNEL);
+	if (WARN(!pool, "Could not allocate pool meta data."))
+		return NULL;
+
+	pool->refill = refill ? PAGE_ALIGN(refill) : DEFAULT_REFILL_SIZE;
+	if (align_order < 0)
+		pool->align = sizeof(size_t);
+	else
+		pool->align = 1UL << align_order;
+	mutex_init(&pool->mutex);
+
+	mutex_lock(&pools_mutex);
+	list_add(&pool->pool_node, &pools_list);
+	mutex_unlock(&pools_mutex);
+	return pool;
+}
+
+
+static int grow(struct pmalloc_pool *pool, size_t size,
+		short int align_order)
+{
+	void *addr;
+	struct vmap_area *area;
+
+	addr = vmalloc(max(size, pool->refill));
+	if (WARN(!addr, "Failed to allocate %zd bytes", PAGE_ALIGN(size)))
+		return -ENOMEM;
+
+	area = find_vmap_area((unsigned long)addr);
+	tag_area(area);
+	pool->offset = area->vm->nr_pages * PAGE_SIZE;
+	llist_add(&area->area_list, &pool->vm_areas);
+	return 0;
+}
+
+static unsigned long reserve_mem(struct pmalloc_pool *pool, size_t size,
+				 short int align_order)
+{
+	unsigned long align;
+
+	align = get_align(pool, align_order);
+	pool->offset = round_down(pool->offset - size, align);
+	return current_area(pool)->va_start + pool->offset;
+
+}
+
+/**
+ * pmalloc_align() - allocate protectable memory from a pool
+ * @pool: handle to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
+ * @align_order: log2 of the alignment of the allocation
+ *               Setting it to PMALLOC_ALIGN_DEFAULT will use the value
+ *               specified when the pool was created.
+ *
+ * Allocates memory from a pool.
+ * If needed, the pool will automatically allocate enough memory to
+ * either satisfy the request or meet the "refill" parameter received
+ * upon creation.
+ * New allocation can happen also if the current memory in the pool is
+ * already write protected.
+ *
+ * Return:
+ * * pointer to the memory requested	- success
+ * * NULL				- error
+ */
+void *pmalloc_align(struct pmalloc_pool *pool, size_t size,
+		    short int align_order)
+{
+	unsigned long retval = 0;
+
+	mutex_lock(&pool->mutex);
+	if (space_needed(pool, size, align_order))
+		if (unlikely(grow(pool, size, align_order)))
+			goto out;
+	retval = reserve_mem(pool, size, align_order);
+out:
+	mutex_unlock(&pool->mutex);
+	return (void *)retval;
+}
+
+/**
+ * pmalloc_protect_pool() - write-protects the memory in the pool
+ * @pool: the pool associated tothe memory to write-protect
+ *
+ * Write-protects all the memory areas currently assigned to the pool
+ * that are still unprotected.
+ * This does not prevent further allocation of additional memory, that
+ * can be initialized and protected.
+ * The catch is that protecting a pool will make unavailable whatever
+ * free memory it might still contain.
+ * Successive allocations will grab more free pages.
+ */
+void pmalloc_protect_pool(struct pmalloc_pool *pool)
+{
+	struct vmap_area *area;
+
+	mutex_lock(&pool->mutex);
+	llist_for_each_entry(area, pool->vm_areas.first, area_list)
+		if (unlikely(!protect_area(area)))
+			break;
+	mutex_unlock(&pool->mutex);
+}
+
+
+/**
+ * is_pmalloc_object() - test if the given range is within a pmalloc pool
+ * @ptr: the base address of the range
+ * @n: the size of the range
+ *
+ * Return:
+ * * true	- the range given is fully within a pmalloc pool
+ * * false	- the range given is not fully within a pmalloc pool
+ */
+int is_pmalloc_object(const void *ptr, const unsigned long n)
+{
+	struct vm_struct *area;
+
+	if (likely(!is_vmalloc_addr(ptr)))
+		return false;
+
+	area = vmalloc_to_page(ptr)->area;
+	if (unlikely(!(area->flags & VM_PMALLOC)))
+		return false;
+
+	return ((n + (unsigned long)ptr) <=
+		(area->nr_pages * PAGE_SIZE + (unsigned long)area->addr));
+
+}
+
+
+/**
+ * pmalloc_destroy_pool() - destroys a pool and all the associated memory
+ * @pool: the pool to destroy
+ *
+ * All the memory associated to the pool will be freed, including the
+ * metadata used for the pool.
+ */
+void pmalloc_destroy_pool(struct pmalloc_pool *pool)
+{
+	struct vmap_area *area;
+	struct llist_node *tmp;
+
+	mutex_lock(&pools_mutex);
+	list_del(&pool->pool_node);
+	mutex_unlock(&pools_mutex);
+
+	mutex_lock(&pool->mutex);
+	while (pool->vm_areas.first) {
+		tmp = pool->vm_areas.first;
+		pool->vm_areas.first = pool->vm_areas.first->next;
+		area = llist_entry(tmp, struct vmap_area, area_list);
+		destroy_area(area);
+	}
+	mutex_unlock(&pool->mutex);
+	kfree(pool);
+}
+
+/**
+ * pmalloc_get_offset() - returns the offset in a pool
+ * @pool: the pool from which to return the offset
+ *
+ * Return: the offset inside the active vmap_area
+ */
+unsigned long pmalloc_get_offset(struct pmalloc_pool *pool)
+{
+	return pool->offset;
+}
+
+
+/**
+ * pmalloc_get_align() - returns the align in a pool
+ * @pool: the pool from which to return the align
+ *
+ * Return: the align inside the active vmap_area
+ */
+unsigned long pmalloc_get_align(struct pmalloc_pool *pool)
+{
+	return pool->align;
+}
+
+
+/**
+ * pmalloc_get_refill() - returns the refill in a pool
+ * @pool: the pool from which to return the refill
+ *
+ * Return: the refill inside the active vmap_area
+ */
+unsigned long pmalloc_get_refill(struct pmalloc_pool *pool)
+{
+	return pool->refill;
+}
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
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1bb2233bb262..da9cc9cd8b52 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -759,7 +759,7 @@ static void free_unmap_vmap_area(struct vmap_area *va)
 	free_vmap_area_noflush(va);
 }
 
-static struct vmap_area *find_vmap_area(unsigned long addr)
+struct vmap_area *find_vmap_area(unsigned long addr)
 {
 	struct vmap_area *va;
 
-- 
2.14.1
