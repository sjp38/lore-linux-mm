Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 04/17] prmem: dynamic allocation
Date: Wed, 24 Oct 2018 00:34:51 +0300
Message-Id: <20181023213504.28905-5-igor.stoppa@huawei.com>
In-Reply-To: <20181023213504.28905-1-igor.stoppa@huawei.com>
References: <20181023213504.28905-1-igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Mimi Zohar <zohar@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, James Morris <jmorris@namei.org>, Michal Hocko <mhocko@kernel.org>, kernel-hardening@lists.openwall.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: igor.stoppa@huawei.com, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Extension of protected memory to dynamic allocations.

Allocations are performed from "pools".
A pool is a list of virtual memory areas, in various state of
protection.

Supported cases
===============

Read Only Pool
--------------
Memory is allocated from the pool, in writable state.
Then it gets written and the content of the pool is write protected and
it cannot be altered anymore. It is only possible to destroy the pool.

Auto Read Only Pool
-------------------
Same as the plain read only, but every time a memory area is full and
phased out, it is automatically marked as read only.

Write Rare Pool
---------------
Memory is allocated from the pool, in writable state.
Then it gets written and the content of the pool is write protected and
it can be altered only by invoking special write rare functions.

Auto Write Rare Pool
--------------------
Same as the plain write rare, but every time a memory area is full and
phased out, it is automatically marked as write rare.

Start Write Rare Pool
---------------------
The memory handed out is already in write rare mode and the only way to
alter it is to use write rare functions.

When a pool is destroyed, all the memory that was obtained from it is
automatically freed. This is the only way to release protected memory.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Michal Hocko <mhocko@kernel.org>
CC: Vlastimil Babka <vbabka@suse.cz>
CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Pavel Tatashin <pasha.tatashin@oracle.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 include/linux/prmem.h | 220 +++++++++++++++++++++++++++++++++--
 mm/Kconfig            |   6 +
 mm/prmem.c            | 263 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 482 insertions(+), 7 deletions(-)

diff --git a/include/linux/prmem.h b/include/linux/prmem.h
index 3ba41d76a582..26fd48410d97 100644
--- a/include/linux/prmem.h
+++ b/include/linux/prmem.h
@@ -7,6 +7,8 @@
  *
  * Support for:
  * - statically allocated write rare data
+ * - dynamically allocated read only data
+ * - dynamically allocated write rare data
  */
 
 #ifndef _LINUX_PRMEM_H
@@ -22,6 +24,11 @@
 #include <linux/irqflags.h>
 #include <linux/set_memory.h>
 
+#define VM_PMALLOC_MASK \
+		(VM_PMALLOC | VM_PMALLOC_WR | VM_PMALLOC_PROTECTED)
+#define VM_PMALLOC_WR_MASK		(VM_PMALLOC | VM_PMALLOC_WR)
+#define VM_PMALLOC_PROTECTED_MASK	(VM_PMALLOC | VM_PMALLOC_PROTECTED)
+
 /* ============================ Write Rare ============================ */
 
 extern const char WR_ERR_RANGE_MSG[];
@@ -45,11 +52,23 @@ static __always_inline bool __is_wr_after_init(const void *ptr, size_t size)
 	return likely(start <= low && low < high && high <= end);
 }
 
+static __always_inline bool __is_wr_pool(const void *ptr, size_t size)
+{
+	struct vmap_area *area;
+
+	if (!is_vmalloc_addr(ptr))
+		return false;
+	area = find_vmap_area((unsigned long)ptr);
+	return area && area->vm && (area->vm->size >= size) &&
+		((area->vm->flags & (VM_PMALLOC | VM_PMALLOC_WR)) ==
+		 (VM_PMALLOC | VM_PMALLOC_WR));
+}
+
 /**
  * wr_memset() - sets n bytes of the destination to the c value
  * @dst: beginning of the memory to write to
  * @c: byte to replicate
- * @size: amount of bytes to copy
+ * @n_bytes: amount of bytes to copy
  *
  * Returns true on success, false otherwise.
  */
@@ -59,8 +78,10 @@ bool wr_memset(const void *dst, const int c, size_t n_bytes)
 	size_t size;
 	unsigned long flags;
 	uintptr_t d = (uintptr_t)dst;
+	bool is_virt = __is_wr_after_init(dst, n_bytes);
 
-	if (WARN(!__is_wr_after_init(dst, n_bytes), WR_ERR_RANGE_MSG))
+	if (WARN(!(is_virt || likely(__is_wr_pool(dst, n_bytes))),
+		 WR_ERR_RANGE_MSG))
 		return false;
 	while (n_bytes) {
 		struct page *page;
@@ -69,7 +90,10 @@ bool wr_memset(const void *dst, const int c, size_t n_bytes)
 		uintptr_t offset_complement;
 
 		local_irq_save(flags);
-		page = virt_to_page(d);
+		if (is_virt)
+			page = virt_to_page(d);
+		else
+			page = vmalloc_to_page((void *)d);
 		offset = d & ~PAGE_MASK;
 		offset_complement = PAGE_SIZE - offset;
 		size = min(n_bytes, offset_complement);
@@ -102,8 +126,10 @@ bool wr_memcpy(const void *dst, const void *src, size_t n_bytes)
 	unsigned long flags;
 	uintptr_t d = (uintptr_t)dst;
 	uintptr_t s = (uintptr_t)src;
+	bool is_virt = __is_wr_after_init(dst, n_bytes);
 
-	if (WARN(!__is_wr_after_init(dst, n_bytes), WR_ERR_RANGE_MSG))
+	if (WARN(!(is_virt || likely(__is_wr_pool(dst, n_bytes))),
+		 WR_ERR_RANGE_MSG))
 		return false;
 	while (n_bytes) {
 		struct page *page;
@@ -112,7 +138,10 @@ bool wr_memcpy(const void *dst, const void *src, size_t n_bytes)
 		uintptr_t offset_complement;
 
 		local_irq_save(flags);
-		page = virt_to_page(d);
+		if (is_virt)
+			page = virt_to_page(d);
+		else
+			page = vmalloc_to_page((void *)d);
 		offset = d & ~PAGE_MASK;
 		offset_complement = PAGE_SIZE - offset;
 		size = (size_t)min(n_bytes, offset_complement);
@@ -151,11 +180,13 @@ uintptr_t __wr_rcu_ptr(const void *dst_p_p, const void *src_p)
 	void *base;
 	uintptr_t offset;
 	const size_t size = sizeof(void *);
+	bool is_virt = __is_wr_after_init(dst_p_p, size);
 
-	if (WARN(!__is_wr_after_init(dst_p_p, size), WR_ERR_RANGE_MSG))
+	if (WARN(!(is_virt || likely(__is_wr_pool(dst_p_p, size))),
+		 WR_ERR_RANGE_MSG))
 		return (uintptr_t)NULL;
 	local_irq_save(flags);
-	page = virt_to_page(dst_p_p);
+	page = is_virt ? virt_to_page(dst_p_p) : vmalloc_to_page(dst_p_p);
 	offset = (uintptr_t)dst_p_p & ~PAGE_MASK;
 	base = vmap(&page, 1, VM_MAP, PAGE_KERNEL);
 	if (WARN(!base, WR_ERR_PAGE_MSG)) {
@@ -210,4 +241,179 @@ bool wr_ptr(const void *dst, const void *val)
 {
 	return wr_memcpy(dst, &val, sizeof(val));
 }
+
+/* ============================ Allocator ============================ */
+
+#define PMALLOC_REFILL_DEFAULT (0)
+#define PMALLOC_DEFAULT_REFILL_SIZE PAGE_SIZE
+#define PMALLOC_ALIGN_ORDER_DEFAULT ilog2(ARCH_KMALLOC_MINALIGN)
+
+#define PMALLOC_RO		0x00
+#define PMALLOC_WR		0x01
+#define PMALLOC_AUTO		0x02
+#define PMALLOC_START		0x04
+#define PMALLOC_MASK		(PMALLOC_WR | PMALLOC_AUTO | PMALLOC_START)
+
+#define PMALLOC_MODE_RO		PMALLOC_RO
+#define PMALLOC_MODE_WR		PMALLOC_WR
+#define PMALLOC_MODE_AUTO_RO	(PMALLOC_RO | PMALLOC_AUTO)
+#define PMALLOC_MODE_AUTO_WR	(PMALLOC_WR | PMALLOC_AUTO)
+#define PMALLOC_MODE_START_WR	(PMALLOC_WR | PMALLOC_START)
+
+struct pmalloc_pool {
+	struct mutex mutex;
+	struct list_head pool_node;
+	struct vmap_area *area;
+	size_t align;
+	size_t refill;
+	size_t offset;
+	uint8_t mode;
+};
+
+/*
+ * The write rare functionality is fully implemented as __always_inline,
+ * to prevent having an internal function call that is capable of modifying
+ * write protected memory.
+ * Fully inlining the function allows the compiler to optimize away its
+ * interface, making it harder for an attacker to hijack it.
+ * This still leaves the door open to attacks that might try to reuse part
+ * of the code, by jumping in the middle of the function, however it can
+ * be mitigated by having a compiler plugin that enforces Control Flow
+ * Integrity (CFI).
+ * Any addition/modification to the write rare path must follow the same
+ * approach.
+ */
+
+void pmalloc_init_custom_pool(struct pmalloc_pool *pool, size_t refill,
+			      short align_order, uint8_t mode);
+
+struct pmalloc_pool *pmalloc_create_custom_pool(size_t refill,
+						short align_order,
+						uint8_t mode);
+
+/**
+ * pmalloc_create_pool() - create a protectable memory pool
+ * @mode: can the data be altered after protection
+ *
+ * Shorthand for pmalloc_create_custom_pool() with default argument:
+ * * refill is set to PMALLOC_REFILL_DEFAULT
+ * * align_order is set to PMALLOC_ALIGN_ORDER_DEFAULT
+ *
+ * Returns:
+ * * pointer to the new pool	- success
+ * * NULL			- error
+ */
+static inline struct pmalloc_pool *pmalloc_create_pool(uint8_t mode)
+{
+	return pmalloc_create_custom_pool(PMALLOC_REFILL_DEFAULT,
+					  PMALLOC_ALIGN_ORDER_DEFAULT,
+					  mode);
+}
+
+void *pmalloc(struct pmalloc_pool *pool, size_t size);
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
+	if (unlikely(!ptr))
+		return ptr;
+	if ((pool->mode & PMALLOC_MODE_START_WR) == PMALLOC_MODE_START_WR)
+		wr_memset(ptr, 0, size);
+	else
+		memset(ptr, 0, size);
+	return ptr;
+}
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
+static inline
+void *pmalloc_array(struct pmalloc_pool *pool, size_t n, size_t size)
+{
+	size_t total_size = n * size;
+
+	if (unlikely(!(n && (total_size / n == size))))
+		return NULL;
+	return pmalloc(pool, n * size);
+}
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
+static inline
+void *pcalloc(struct pmalloc_pool *pool, size_t n, size_t size)
+{
+	size_t total_size = n * size;
+
+	if (unlikely(!(n && (total_size / n == size))))
+		return NULL;
+	return pzalloc(pool, n * size);
+}
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
+	if (unlikely(!buf))
+		return buf;
+	if ((pool->mode & PMALLOC_MODE_START_WR) == PMALLOC_MODE_START_WR)
+		wr_memcpy(buf, s, len);
+	else
+		strncpy(buf, s, len);
+	return buf;
+}
+
+
+void pmalloc_protect_pool(struct pmalloc_pool *pool);
+
+void pmalloc_make_pool_ro(struct pmalloc_pool *pool);
+
+void pmalloc_destroy_pool(struct pmalloc_pool *pool);
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index de64ea658716..1885f5565cbc 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -764,4 +764,10 @@ config GUP_BENCHMARK
 config ARCH_HAS_PTE_SPECIAL
 	bool
 
+config PRMEM
+    bool
+    depends on MMU
+    depends on ARCH_HAS_SET_MEMORY
+    default y
+
 endmenu
diff --git a/mm/prmem.c b/mm/prmem.c
index de9258f5f29a..7dd13ea43304 100644
--- a/mm/prmem.c
+++ b/mm/prmem.c
@@ -6,5 +6,268 @@
  * Author: Igor Stoppa <igor.stoppa@huawei.com>
  */
 
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
+#include <linux/prmem.h>
+
 const char WR_ERR_RANGE_MSG[] = "Write rare on invalid memory range.";
 const char WR_ERR_PAGE_MSG[] = "Failed to remap write rare page.";
+
+static LIST_HEAD(pools_list);
+static DEFINE_MUTEX(pools_mutex);
+
+#define MAX_ALIGN_ORDER (ilog2(sizeof(void *)))
+
+
+/* Various helper functions. Inlined, to reduce the attack surface. */
+
+static __always_inline void protect_area(struct vmap_area *area)
+{
+	set_memory_ro(area->va_start, area->vm->nr_pages);
+	area->vm->flags |= VM_PMALLOC_PROTECTED_MASK;
+}
+
+static __always_inline bool empty(struct pmalloc_pool *pool)
+{
+	return unlikely(!pool->area);
+}
+
+/* Allocation from a protcted area is allowed only for a START_WR pool. */
+static __always_inline bool unwritable(struct pmalloc_pool *pool)
+{
+	return  (pool->area->vm->flags & VM_PMALLOC_PROTECTED) &&
+		!((pool->area->vm->flags & VM_PMALLOC_WR) &&
+		  (pool->mode & PMALLOC_START));
+}
+
+static __always_inline
+bool exhausted(struct pmalloc_pool *pool, size_t size)
+{
+	size_t space_before;
+	size_t space_after;
+
+	space_before = round_down(pool->offset, pool->align);
+	space_after = pool->offset - space_before;
+	return unlikely(space_after < size && space_before < size);
+}
+
+static __always_inline
+bool space_needed(struct pmalloc_pool *pool, size_t size)
+{
+	return empty(pool) || unwritable(pool) || exhausted(pool, size);
+}
+
+/**
+ * pmalloc_init_custom_pool() - initialize a protectable memory pool
+ * @pool: the pointer to the struct pmalloc_pool to initialize
+ * @refill: the minimum size to allocate when in need of more memory.
+ *          It will be rounded up to a multiple of PAGE_SIZE
+ *          The value of 0 gives the default amount of PAGE_SIZE.
+ * @align_order: log2 of the alignment to use when allocating memory
+ *               Negative values give ARCH_KMALLOC_MINALIGN
+ * @mode: is the data RO or RareWrite and should be provided already in
+ *        protected mode.
+ *        The value is one of:
+ *        PMALLOC_MODE_RO, PMALLOC_MODE_WR, PMALLOC_MODE_AUTO_RO
+ *        PMALLOC_MODE_AUTO_WR, PMALLOC_MODE_START_WR
+ *
+ * Initializes an empty memory pool, for allocation of protectable
+ * memory. Memory will be allocated upon request (through pmalloc).
+ */
+void pmalloc_init_custom_pool(struct pmalloc_pool *pool, size_t refill,
+			      short align_order, uint8_t mode)
+{
+	mutex_init(&pool->mutex);
+	pool->area = NULL;
+	if (align_order < 0)
+		pool->align = ARCH_KMALLOC_MINALIGN;
+	else
+		pool->align = 1UL << align_order;
+	pool->refill = refill ? PAGE_ALIGN(refill) :
+				PMALLOC_DEFAULT_REFILL_SIZE;
+	mode &= PMALLOC_MASK;
+	if (mode & PMALLOC_START)
+		mode |= PMALLOC_WR;
+	pool->mode = mode & PMALLOC_MASK;
+	pool->offset = 0;
+	mutex_lock(&pools_mutex);
+	list_add(&pool->pool_node, &pools_list);
+	mutex_unlock(&pools_mutex);
+}
+EXPORT_SYMBOL(pmalloc_init_custom_pool);
+
+/**
+ * pmalloc_create_custom_pool() - create a new protectable memory pool
+ * @refill: the minimum size to allocate when in need of more memory.
+ *          It will be rounded up to a multiple of PAGE_SIZE
+ *          The value of 0 gives the default amount of PAGE_SIZE.
+ * @align_order: log2 of the alignment to use when allocating memory
+ *               Negative values give ARCH_KMALLOC_MINALIGN
+ * @mode: can the data be altered after protection
+ *
+ * Creates a new (empty) memory pool for allocation of protectable
+ * memory. Memory will be allocated upon request (through pmalloc).
+ *
+ * Return:
+ * * pointer to the new pool	- success
+ * * NULL			- error
+ */
+struct pmalloc_pool *pmalloc_create_custom_pool(size_t refill,
+						short align_order,
+						uint8_t mode)
+{
+	struct pmalloc_pool *pool;
+
+	pool = kmalloc(sizeof(struct pmalloc_pool), GFP_KERNEL);
+	if (WARN(!pool, "Could not allocate pool meta data."))
+		return NULL;
+	pmalloc_init_custom_pool(pool, refill, align_order, mode);
+	return pool;
+}
+EXPORT_SYMBOL(pmalloc_create_custom_pool);
+
+static int grow(struct pmalloc_pool *pool, size_t min_size)
+{
+	void *addr;
+	struct vmap_area *new_area;
+	unsigned long size;
+	uint32_t tag_mask;
+
+	size = (min_size > pool->refill) ? min_size : pool->refill;
+	addr = vmalloc(size);
+	if (WARN(!addr, "Failed to allocate %zd bytes", PAGE_ALIGN(size)))
+		return -ENOMEM;
+
+	new_area = find_vmap_area((uintptr_t)addr);
+	tag_mask = VM_PMALLOC;
+	if (pool->mode & PMALLOC_WR)
+		tag_mask |= VM_PMALLOC_WR;
+	new_area->vm->flags |= (tag_mask & VM_PMALLOC_MASK);
+	new_area->pool = pool;
+	if (pool->mode & PMALLOC_START)
+		protect_area(new_area);
+	if (pool->mode & PMALLOC_AUTO && !empty(pool))
+		protect_area(pool->area);
+	/* The area size backed by pages, without the canary bird. */
+	pool->offset = new_area->vm->nr_pages * PAGE_SIZE;
+	new_area->next = pool->area;
+	pool->area = new_area;
+	return 0;
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
+ * Allocation happens with a mutex locked, therefore it is assumed to have
+ * exclusive write access to both the pool structure and the list of
+ * vmap_areas, while inside the lock.
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
+	    unlikely(grow(pool, size) != 0))
+		goto error;
+	pool->offset = round_down(pool->offset - size, pool->align);
+	retval = (void *)(pool->area->va_start + pool->offset);
+error:
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
+	for (area = pool->area; area; area = area->next)
+		protect_area(area);
+	mutex_unlock(&pool->mutex);
+}
+EXPORT_SYMBOL(pmalloc_protect_pool);
+
+
+/**
+ * pmalloc_make_pool_ro() - forces a pool to become read-only
+ * @pool: the pool associated to the memory to make ro
+ *
+ * Drops the possibility to perform controlled writes from both the pool
+ * metadata and all the vm_area structures associated to the pool.
+ * In case the pool was configured to automatically protect memory when
+ * allocating it, the configuration is dropped.
+ */
+void pmalloc_make_pool_ro(struct pmalloc_pool *pool)
+{
+	struct vmap_area *area;
+
+	mutex_lock(&pool->mutex);
+	pool->mode &= ~(PMALLOC_WR | PMALLOC_START);
+	for (area = pool->area; area; area = area->next)
+		protect_area(area);
+	mutex_unlock(&pool->mutex);
+}
+EXPORT_SYMBOL(pmalloc_make_pool_ro);
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
+
+	mutex_lock(&pools_mutex);
+	list_del(&pool->pool_node);
+	mutex_unlock(&pools_mutex);
+	while (pool->area) {
+		area = pool->area;
+		pool->area = area->next;
+		set_memory_rw(area->va_start, area->vm->nr_pages);
+		area->vm->flags &= ~VM_PMALLOC_MASK;
+		vfree((void *)area->va_start);
+	}
+	kfree(pool);
+}
+EXPORT_SYMBOL(pmalloc_destroy_pool);
-- 
2.17.1
