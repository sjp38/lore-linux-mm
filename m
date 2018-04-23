Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B259A6B000A
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:55:38 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 135-v6so6758275iti.0
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:55:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e195-v6sor4075459itc.103.2018.04.23.05.55.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 05:55:36 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 3/9] Protectable Memory
Date: Mon, 23 Apr 2018 16:54:52 +0400
Message-Id: <20180423125458.5338-4-igor.stoppa@huawei.com>
In-Reply-To: <20180423125458.5338-1-igor.stoppa@huawei.com>
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net
Cc: labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>

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
 include/linux/pmalloc.h | 148 ++++++++++++++++++++++++++++++++++++++++
 include/linux/vmalloc.h |   3 +
 mm/Kconfig              |   6 ++
 mm/Makefile             |   1 +
 mm/pmalloc.c            | 174 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/pmalloc_helpers.h    | 154 ++++++++++++++++++++++++++++++++++++++++++
 mm/usercopy.c           |   9 +++
 mm/vmalloc.c            |   2 +-
 8 files changed, 496 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/pmalloc_helpers.h

diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
new file mode 100644
index 000000000000..eebaf1ebc6f3
--- /dev/null
+++ b/include/linux/pmalloc.h
@@ -0,0 +1,148 @@
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
+ * Whenever a pool is protected, all the areas it contains at that point
+ * are write protected.
+ * More areas can be added and protected, in the same way.
+ * Memory in a pool cannot be individually unprotected, but the pool can
+ * be destroyed.
+ * Upon destruction of a certain pool, all the related memory is released,
+ * including its metadata.
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
+void pmalloc_protect_pool(struct pmalloc_pool *pool);
+
+void pmalloc_destroy_pool(struct pmalloc_pool *pool);
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
index 000000000000..ddaef41837f4
--- /dev/null
+++ b/mm/pmalloc.c
@@ -0,0 +1,174 @@
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
+#include "pmalloc_helpers.h"
+
+static LIST_HEAD(pools_list);
+static DEFINE_MUTEX(pools_mutex);
+
+#define MAX_ALIGN_ORDER (ilog2(sizeof(void *)))
+#define DEFAULT_REFILL_SIZE PAGE_SIZE
+
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
+EXPORT_SYMBOL(pmalloc_create_custom_pool);
+
+
+static int grow(struct pmalloc_pool *pool, size_t min_size)
+{
+	void *addr;
+	struct vmap_area *area;
+	unsigned long size;
+
+	size = (min_size > pool->refill) ? min_size : pool->refill;
+	addr = vmalloc(size);
+	if (WARN(!addr, "Failed to allocate %zd bytes", PAGE_ALIGN(size)))
+		return -ENOMEM;
+
+	area = find_vmap_area((unsigned long)addr);
+	tag_area(area);
+	pool->offset = get_area_pages_size(area);
+	llist_add(&area->area_list, &pool->vm_areas);
+	return 0;
+}
+
+static void *reserve_mem(struct pmalloc_pool *pool, size_t size)
+{
+	pool->offset = round_down(pool->offset - size, pool->align);
+	return (void *)(current_area(pool)->va_start + pool->offset);
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
+	void *retval = NULL;
+
+	mutex_lock(&pool->mutex);
+	if (unlikely(space_needed(pool, size)) &&
+	    unlikely(grow(pool, size)))
+			goto out;
+	retval = reserve_mem(pool, size);
+out:
+	mutex_unlock(&pool->mutex);
+	return retval;
+}
+EXPORT_SYMBOL(pmalloc);
+
+/**
+ * pmalloc_protect_pool() - write-protects the memory in the pool
+ * @pool: the pool associated to the memory to write-protect
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
+		protect_area(area);
+	mutex_unlock(&pool->mutex);
+}
+EXPORT_SYMBOL(pmalloc_protect_pool);
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
+EXPORT_SYMBOL(pmalloc_destroy_pool);
+
diff --git a/mm/pmalloc_helpers.h b/mm/pmalloc_helpers.h
new file mode 100644
index 000000000000..52d4d899e173
--- /dev/null
+++ b/mm/pmalloc_helpers.h
@@ -0,0 +1,154 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * pmalloc_helpers.h: Protectable Memory Allocator internal header
+ *
+ * (C) Copyright 2018 Huawei Technologies Co. Ltd.
+ * Author: Igor Stoppa <igor.stoppa@huawei.com>
+ */
+
+#ifndef _MM_VMALLOC_HELPERS_H
+#define _MM_VMALLOC_HELPERS_H
+
+#ifndef CONFIG_PROTECTABLE_MEMORY
+
+static inline void check_pmalloc_object(const void *ptr, unsigned long n,
+					bool to_user)
+{
+}
+
+#else
+
+#include <linux/set_memory.h>
+struct pmalloc_pool {
+	struct mutex mutex;
+	struct list_head pool_node;
+	struct llist_head vm_areas;
+	size_t refill;
+	size_t offset;
+	size_t align;
+};
+
+#define VM_PMALLOC_PROTECTED_MASK (VM_PMALLOC | VM_PMALLOC_PROTECTED)
+#define VM_PMALLOC_MASK (VM_PMALLOC | VM_PMALLOC_PROTECTED)
+
+static __always_inline unsigned long area_flags(struct vmap_area *area)
+{
+	return area->vm->flags & VM_PMALLOC_MASK;
+}
+
+static __always_inline void tag_area(struct vmap_area *area)
+{
+	area->vm->flags |= VM_PMALLOC;
+}
+
+static __always_inline void untag_area(struct vmap_area *area)
+{
+	area->vm->flags &= ~VM_PMALLOC_MASK;
+}
+
+static __always_inline struct vmap_area *current_area(struct pmalloc_pool *pool)
+{
+	return llist_entry(pool->vm_areas.first, struct vmap_area,
+			   area_list);
+}
+
+static __always_inline bool is_area_protected(struct vmap_area *area)
+{
+	return (area->vm->flags & VM_PMALLOC_PROTECTED_MASK) ==
+	       VM_PMALLOC_PROTECTED_MASK;
+}
+
+static __always_inline void protect_area(struct vmap_area *area)
+{
+	if (unlikely(is_area_protected(area)))
+		return;
+	set_memory_ro(area->va_start, area->vm->nr_pages);
+	area->vm->flags |= VM_PMALLOC_PROTECTED_MASK;
+}
+
+static __always_inline void unprotect_area(struct vmap_area *area)
+{
+	if (likely(is_area_protected(area)))
+		set_memory_rw(area->va_start, area->vm->nr_pages);
+	untag_area(area);
+}
+
+static __always_inline void destroy_area(struct vmap_area *area)
+{
+	WARN(!is_area_protected(area), "Destroying unprotected area.");
+	unprotect_area(area);
+	vfree((void *)area->va_start);
+}
+
+static __always_inline bool empty(struct pmalloc_pool *pool)
+{
+	return unlikely(llist_empty(&pool->vm_areas));
+}
+
+static __always_inline bool protected(struct pmalloc_pool *pool)
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
+static __always_inline bool space_needed(struct pmalloc_pool *pool, size_t size)
+{
+	return empty(pool) || protected(pool) || exhausted(pool, size);
+}
+
+static __always_inline size_t get_area_pages_size(struct vmap_area *area)
+{
+	return area->vm->nr_pages * PAGE_SIZE;
+}
+
+static inline int is_pmalloc_object(const void *ptr, const unsigned long n)
+{
+	struct vm_struct *area;
+	unsigned long start = (unsigned long)ptr;
+	unsigned long end = start + n;
+	unsigned long area_end;
+
+	if (likely(!is_vmalloc_addr(ptr)))
+		return false;
+
+	area = vmalloc_to_page(ptr)->area;
+	if (unlikely(!(area->flags & VM_PMALLOC)))
+		return false;
+
+	area_end = area->nr_pages * PAGE_SIZE + (unsigned long)area->addr;
+	return (start <= end) && (end <= area_end);
+}
+
+void __noreturn usercopy_abort(const char *name, const char *detail,
+			       bool to_user, unsigned long offset,
+			       unsigned long len);
+
+static inline void check_pmalloc_object(const void *ptr, unsigned long n,
+					bool to_user)
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
+#endif
+#endif
diff --git a/mm/usercopy.c b/mm/usercopy.c
index e9e9325f7638..6c47bd765033 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -20,8 +20,14 @@
 #include <linux/sched/task.h>
 #include <linux/sched/task_stack.h>
 #include <linux/thread_info.h>
+#include <linux/init.h>
+#include <linux/debugfs.h>
+#include <linux/pmalloc.h>
+#include <linux/sched/clock.h>
 #include <asm/sections.h>
 
+#include "pmalloc_helpers.h"
+
 /*
  * Checks if a given pointer and length is contained by the current
  * stack frame (if possible).
@@ -277,5 +283,8 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 
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
