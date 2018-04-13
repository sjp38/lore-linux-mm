Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C47D76B0260
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:43:13 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j69-v6so2636018lfg.6
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:43:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p74-v6sor528016lfe.93.2018.04.13.06.43.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 06:43:11 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 3/6] Protectable Memory
Date: Fri, 13 Apr 2018 17:41:28 +0400
Message-Id: <20180413134131.4651-4-igor.stoppa@huawei.com>
In-Reply-To: <20180413134131.4651-1-igor.stoppa@huawei.com>
References: <20180413134131.4651-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, corbet@lwn.net
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

The MMU available in many systems running Linux can often provide R/O
protection to the memory pages it handles.

However, the MMU-based protection works efficiently only when said pages
contain exclusively data that will not need further modifications.

Statically allocated variables can be segregated into a dedicated
section (that's how __ro_after_init works), but this does not sit very
well with dynamically allocated ones.

Dynamic allocation does not provide, currently, any means for grouping
variables in memory pages that would contain exclusively data suitable
for conversion to read only access mode.

The allocator here provided (pmalloc - protectable memory allocator)
introduces the concept of pools of protectable memory.

A module can instantiate a pool, and then refer any allocation request to
the pool handler it has received.

A pool is organized ias list of areas of virtually contiguous memory.
Whenever the protection functionality is invoked on a pool, all the
areas it contains that are not yet read-only are write-protected.

The process of growing and protecting the pool can be iterated at will.
Each iteration will prevent further allocation from the memory area
currently active, turn it into read-only mode and then proceed to
secure whatever other area might still be unprotected.

Write-protcting some part of a pool before completing all the
allocations can be wasteful, however it will guarrantee the minimum
window of vulnerability, sice the data can be allocated, initialized
and protected in a single sweep.

There are pros and cons, depending on the allocation patterns, the size
of the areas being allocated, the time intervals between initialization
and protection.

Dstroying a pool is the only way to claim back the associated memory.
It is up to its user to avoid any further references to the memory that
was allocated, once the destruction is invoked.

An example where it is desirable to destroy a pool and claim back its
memory is when unloading a kernel module.

A module can have as many pools as needed.

Since pmalloc memory is obtained from vmalloc, an attacker that has
gained access to the physical mapping, still has to identify where the
target of the attack (in virtually contiguous mapping) is located.

Compared to plain vmalloc, pmalloc does not generate as much TLB
trashing, since it can host multiple allocations in the same page,
where present.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/pmalloc.h | 166 ++++++++++++++++++++++++++++++
 include/linux/vmalloc.h |   3 +
 mm/Kconfig              |   6 ++
 mm/Makefile             |   1 +
 mm/pmalloc.c            | 265 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/usercopy.c           |  33 ++++++
 mm/vmalloc.c            |   2 +-
 7 files changed, 475 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
new file mode 100644
index 000000000000..1c24067eb167
--- /dev/null
+++ b/include/linux/pmalloc.h
@@ -0,0 +1,166 @@
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
+#include <linux/slab.h>
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
+#define PMALLOC_ALIGN_DEFAULT ARCH_KMALLOC_MINALIGN
+
+struct pmalloc_pool *pmalloc_create_custom_pool(size_t refill,
+						unsigned short align_order);
+
+/**
+ * pmalloc_create_pool() - create a protectable memory pool
+ *
+ * Shorthand for pmalloc_create_custom_pool() with default argument:
+ * * refill is set to PMALLOC_REFILL_DEFAULT
+ * * align_order is set to PMALLOC_ALIGN_DEFAULT
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
+void *pmalloc(struct pmalloc_pool *pool, size_t size);
+
+
+/**
+ * pzalloc() - zero-initialized version of pmalloc()
+ * @pool: handle to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
+ *
+ * Executes pmalloc(), initializing the memory requested to 0, before
+ * returning its address.
+ *
+ * Return:
+ * * pointer to the memory requested	- success
+ * * NULL				- error
+ */
+static inline void *pzalloc(struct pmalloc_pool *pool, size_t size)
+{
+	void *ptr = pmalloc(pool, size);
+
+	if (likely(ptr))
+		memset(ptr, 0, size);
+	return ptr;
+}
+
+
+/**
+ * pmalloc_array() - array version of pmalloc()
+ * @pool: handle to the pool to be used for memory allocation
+ * @n: number of elements in the array
+ * @size: amount of memory (in bytes) requested for each element
+ *
+ * Executes pmalloc(), on an array.
+ *
+ * Return:
+ * * the pmalloc result	- success
+ * * NULL		- error
+ */
+
+static inline void *pmalloc_array(struct pmalloc_pool *pool, size_t n,
+				  size_t size)
+{
+	if (unlikely(size != 0) && unlikely(n > SIZE_MAX / size))
+		return NULL;
+	return pmalloc(pool, n * size);
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
+	if (unlikely(size != 0) && unlikely(n > SIZE_MAX / size))
+		return NULL;
+	return pzalloc(pool, n * size);
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
+	size_t len;
+	char *buf;
+
+	len = strlen(s) + 1;
+	buf = pmalloc(pool, len);
+	if (likely(buf))
+		strncpy(buf, s, len);
+	return buf;
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
index d5004d82a1d6..d7ef40eaa4e8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -752,3 +752,9 @@ config GUP_BENCHMARK
 	  performance of get_user_pages_fast().
 
 	  See tools/testing/selftests/vm/gup_benchmark.c
+
+config PROTECTABLE_MEMORY
+    bool
+    depends on MMU
+    depends on ARCH_HAS_SET_MEMORY
+    default y
diff --git a/mm/Makefile b/mm/Makefile
index b4e54a9ae9c5..6a6668f99799 100644
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
index 000000000000..d7344b9c3a7a
--- /dev/null
+++ b/mm/pmalloc.c
@@ -0,0 +1,265 @@
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
+	size_t refill;
+	size_t offset;
+	size_t align;
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
+	area->vm->flags &= ~(VM_PMALLOC_PROTECTED | VM_PMALLOC_PROTECTED);
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
+static inline bool exhausted(struct pmalloc_pool *pool, size_t size)
+{
+	size_t space_before;
+	size_t space_after;
+
+	space_before = round_down(pool->offset, pool->align);
+	space_after = pool->offset - space_before;
+	return unlikely(space_after < size && space_before < size);
+}
+
+static inline bool space_needed(struct pmalloc_pool *pool, size_t size)
+{
+	return empty(pool) || protected(pool) || exhausted(pool, size);
+}
+
+#define DEFAULT_REFILL_SIZE PAGE_SIZE
+/**
+ * pmalloc_create_custom_pool() - create a new protectable memory pool
+ * @refill: the minimum size to allocate when in need of more memory.
+ *          It will be rounded up to a multiple of PAGE_SIZE
+ *          The value of 0 gives the default amount of PAGE_SIZE.
+ * @align_order: log2 of the alignment to use when allocating memory
+ *               Negative values give ARCH_KMALLOC_MINALIGN
+ *
+ * Creates a new (empty) memory pool for allocation of protectable
+ * memory. Memory will be allocated upon request (through pmalloc).
+ *
+ * Return:
+ * * pointer to the new pool	- success
+ * * NULL			- error
+ */
+struct pmalloc_pool *pmalloc_create_custom_pool(size_t refill,
+						unsigned short align_order)
+{
+	struct pmalloc_pool *pool;
+
+	pool = kzalloc(sizeof(struct pmalloc_pool), GFP_KERNEL);
+	if (WARN(!pool, "Could not allocate pool meta data."))
+		return NULL;
+
+	pool->refill = refill ? PAGE_ALIGN(refill) : DEFAULT_REFILL_SIZE;
+	pool->align = 1UL << align_order;
+	mutex_init(&pool->mutex);
+
+	mutex_lock(&pools_mutex);
+	list_add(&pool->pool_node, &pools_list);
+	mutex_unlock(&pools_mutex);
+	return pool;
+}
+
+
+static int grow(struct pmalloc_pool *pool, size_t size)
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
+static unsigned long reserve_mem(struct pmalloc_pool *pool, size_t size)
+{
+	pool->offset = round_down(pool->offset - size, pool->align);
+	return current_area(pool)->va_start + pool->offset;
+
+}
+
+/**
+ * pmalloc() - allocate protectable memory from a pool
+ * @pool: handle to the pool to be used for memory allocation
+ * @size: amount of memory (in bytes) requested
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
+void *pmalloc(struct pmalloc_pool *pool, size_t size)
+{
+	size_t retval = 0;
+
+	mutex_lock(&pool->mutex);
+	if (unlikely(space_needed(pool, size)) &&
+	    unlikely(grow(pool, size)))
+			goto out;
+	retval = reserve_mem(pool, size);
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
+	struct llist_node *cursor;
+	struct llist_node *tmp;
+
+	mutex_lock(&pools_mutex);
+	list_del(&pool->pool_node);
+	mutex_unlock(&pools_mutex);
+
+	cursor = pool->vm_areas.first;
+	kfree(pool);
+	while (cursor) {            /* iteration over llist */
+		tmp = cursor;
+		cursor = cursor->next;
+		area = llist_entry(tmp, struct vmap_area, area_list);
+		destroy_area(area);
+	}
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
