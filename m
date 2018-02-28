Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4F906B0008
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 15:07:18 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m130so5566605wma.1
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 12:07:18 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id h92si1974971edc.373.2018.02.28.12.07.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 12:07:15 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 1/7] genalloc: track beginning of allocations
Date: Wed, 28 Feb 2018 22:06:14 +0200
Message-ID: <20180228200620.30026-2-igor.stoppa@huawei.com>
In-Reply-To: <20180228200620.30026-1-igor.stoppa@huawei.com>
References: <20180228200620.30026-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

The genalloc library is only capable of tracking if a certain unit of
allocation is in use or not.

It is not capable of discerning where the memory associated to an
allocation request begins and where it ends.

The reason is that units of allocations are tracked by using a bitmap,
where each bit represents that the unit is either allocated (1) or
available (0).

The user of the API must keep track of how much space was requested, if
it ever needs to be freed.

This can cause errors being undetected.
Examples:
* Only a subset of the memory provided to an allocation request is freed
* The memory from a subsequent allocation is freed
* The memory being freed doesn't start at the beginning of an
  allocation.

The bitmap is used because it allows to perform lockless read/write
access, where this is supported by hw through cmpxchg.
Similarly, it is possible to scan the bitmap for a sufficiently long
sequence of zeros, to identify zones available for allocation.

This patch doubles the space reserved in the bitmap for each allocation,
to track their beginning.

For details, see the documentation inside lib/genalloc.c

The primary effect of this patch is that code using the gen_alloc
library does not need anymore to keep track of the size of the
allocations it makes.

Prior to this patch, it was necessary to keep track of the size of the
allocation, so that it would be possible, later on, to know how much
space should be freed.

Now, users of the api can choose to etiher still specify explicitly the
size, or let the library determine it, by giving a value of 0.

However, even when the value is specified, the library still uses its on
understanding of the space associated with a certain allocation, to
confirm that they are consistent.

This verification also confirms that the patch works correctly.

Eventually, the extra parameter (and the corresponding verification)
could be dropped, in favor of a simplified API.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/genalloc.h | 354 ++++++++++++++++++++---
 lib/genalloc.c           | 721 ++++++++++++++++++++++++++++++++++-------------
 2 files changed, 837 insertions(+), 238 deletions(-)

diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
index 872f930f1b06..7b1a1f1d9985 100644
--- a/include/linux/genalloc.h
+++ b/include/linux/genalloc.h
@@ -32,7 +32,7 @@
 
 #include <linux/types.h>
 #include <linux/spinlock_types.h>
-#include <linux/atomic.h>
+#include <linux/slab.h>
 
 struct device;
 struct device_node;
@@ -76,7 +76,7 @@ struct gen_pool_chunk {
 	phys_addr_t phys_addr;		/* physical starting address of memory chunk */
 	unsigned long start_addr;	/* start address of memory chunk */
 	unsigned long end_addr;		/* end address of memory chunk (inclusive) */
-	unsigned long bits[0];		/* bitmap for allocating memory chunk */
+	unsigned long entries[0];	/* bitmap for allocating memory chunk */
 };
 
 /*
@@ -93,10 +93,40 @@ struct genpool_data_fixed {
 	unsigned long offset;		/* The offset of the specific region */
 };
 
-extern struct gen_pool *gen_pool_create(int, int);
-extern phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long);
-extern int gen_pool_add_virt(struct gen_pool *, unsigned long, phys_addr_t,
-			     size_t, int);
+/**
+ * gen_pool_create() - create a new special memory pool
+ * @min_alloc_order: log base 2 of number of bytes each bitmap entry
+ *		     represents
+ * @nid: node id of the node the pool structure should be allocated on,
+ *	 or -1
+ *
+ * Create a new special memory pool that can be used to manage special
+ * purpose memory not managed by the regular kmalloc/kfree interface.
+ *
+ * Return:
+ * * pointer to the pool	- success
+ * * NULL			- otherwise
+ */
+struct gen_pool *gen_pool_create(int min_alloc_order, int nid);
+
+/**
+ * gen_pool_add_virt() - add a new chunk of special memory to the pool
+ * @pool: pool to add new memory chunk to
+ * @virt: virtual starting address of memory chunk to add to pool
+ * @phys: physical starting address of memory chunk to add to pool
+ * @size: size in bytes of the memory chunk to add to pool
+ * @nid: node id of the node the chunk structure and bitmap should be
+ *       allocated on, or -1
+ *
+ * Add a new chunk of special memory to the specified pool.
+ *
+ * Return:
+ * * 0		- success
+ * * -ve errno	- failure
+ */
+int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt,
+		      phys_addr_t phys, size_t size, int nid);
+
 /**
  * gen_pool_add - add a new chunk of special memory to the pool
  * @pool: pool to add new memory chunk to
@@ -107,60 +137,300 @@ extern int gen_pool_add_virt(struct gen_pool *, unsigned long, phys_addr_t,
  *
  * Add a new chunk of special memory to the specified pool.
  *
- * Returns 0 on success or a -ve errno on failure.
+ * Return:
+ * * 0		- on success
+ * *-ve errno	- failure
  */
 static inline int gen_pool_add(struct gen_pool *pool, unsigned long addr,
 			       size_t size, int nid)
 {
 	return gen_pool_add_virt(pool, addr, -1, size, nid);
 }
-extern void gen_pool_destroy(struct gen_pool *);
-extern unsigned long gen_pool_alloc(struct gen_pool *, size_t);
-extern unsigned long gen_pool_alloc_algo(struct gen_pool *, size_t,
-		genpool_algo_t algo, void *data);
-extern void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size,
-		dma_addr_t *dma);
-extern void gen_pool_free(struct gen_pool *, unsigned long, size_t);
-extern void gen_pool_for_each_chunk(struct gen_pool *,
-	void (*)(struct gen_pool *, struct gen_pool_chunk *, void *), void *);
-extern size_t gen_pool_avail(struct gen_pool *);
-extern size_t gen_pool_size(struct gen_pool *);
 
-extern void gen_pool_set_algo(struct gen_pool *pool, genpool_algo_t algo,
-		void *data);
+/**
+ * gen_pool_virt_to_phys() - return the physical address of memory
+ * @pool: pool to allocate from
+ * @addr: starting address of memory
+ *
+ * Return:
+ * * the physical address	- success
+ * * \-1			- error
+ */
+phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long addr);
+
+/**
+ * gen_pool_destroy() - destroy a special memory pool
+ * @pool: pool to destroy
+ *
+ * Destroy the specified special memory pool. Verifies that there are no
+ * outstanding allocations.
+ */
+void gen_pool_destroy(struct gen_pool *pool);
+
+/**
+ * gen_pool_alloc() - allocate special memory from the pool
+ * @pool: pool to allocate from
+ * @size: number of bytes to allocate from the pool
+ *
+ * Allocate the requested number of bytes from the specified pool.
+ * Uses the pool allocation function (with first-fit algorithm by default).
+ * Can not be used in NMI handler on architectures without
+ * NMI-safe cmpxchg implementation.
+ *
+ * Return:
+ * * address of the memory allocated	- success
+ * * NULL				- error
+ */
+unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size);
+
+/**
+ * gen_pool_alloc_algo() - allocate special memory from the pool
+ * @pool: pool to allocate from
+ * @size: number of bytes to allocate from the pool
+ * @algo: algorithm passed from caller
+ * @data: data passed to algorithm
+ *
+ * Allocate the requested number of bytes from the specified pool.
+ * Uses the pool allocation function (with first-fit algorithm by default).
+ * Can not be used in NMI handler on architectures without
+ * NMI-safe cmpxchg implementation.
+ *
+ * Return:
+ * * address of the memory allocated	- success
+ * * NULL				- error
+ */
+unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
+				  genpool_algo_t algo, void *data);
+
+/**
+ * gen_pool_dma_alloc() - allocate special memory from the pool for DMA usage
+ * @pool: pool to allocate from
+ * @size: number of bytes to allocate from the pool
+ * @dma: dma-view physical address return value.  Use NULL if unneeded.
+ *
+ * Allocate the requested number of bytes from the specified pool.
+ * Uses the pool allocation function (with first-fit algorithm by default).
+ * Can not be used in NMI handler on architectures without
+ * NMI-safe cmpxchg implementation.
+ *
+ * Return:
+ * * address of the memory allocated	- success
+ * * NULL				- error
+ */
+void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma);
+
+/**
+ * gen_pool_free() - free allocated special memory back to the pool
+ * @pool: pool to free to
+ * @addr: starting address of memory to free back to pool
+ * @size: size in bytes of memory to free or 0, for auto-detection
+ *
+ * Free previously allocated special memory back to the specified
+ * pool.  Can not be used in NMI handler on architectures without
+ * NMI-safe cmpxchg implementation.
+ */
+void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size);
+
+/**
+ * gen_pool_for_each_chunk() - call func for every chunk of generic memory pool
+ * @pool:	the generic memory pool
+ * @func:	func to call
+ * @data:	additional data used by @func
+ *
+ * Call @func for every chunk of generic memory pool.  The @func is
+ * called with rcu_read_lock held.
+ */
+void gen_pool_for_each_chunk(struct gen_pool *pool,
+			     void (*func)(struct gen_pool *pool,
+					  struct gen_pool_chunk *chunk,
+					  void *data),
+			     void *data);
+
+/**
+ * addr_in_gen_pool() - checks if an address falls within the range of a pool
+ * @pool:	the generic memory pool
+ * @start:	start address
+ * @size:	size of the region
+ *
+ * Check if the range of addresses falls within the specified pool.
+ *
+ * Return:
+ * * true	- the entire range is contained in the pool
+ * * false	- otherwise
+ */
+bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
+		      size_t size);
+
+/**
+ * gen_pool_avail() - get available free space of the pool
+ * @pool: pool to get available free space
+ *
+ * Return: available free space of the specified pool.
+ */
+size_t gen_pool_avail(struct gen_pool *pool);
 
-extern unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
-		unsigned long start, unsigned int nr, void *data,
-		struct gen_pool *pool);
+/**
+ * gen_pool_size() - get size in bytes of memory managed by the pool
+ * @pool: pool to get size
+ *
+ * Return: size in bytes of memory managed by the pool.
+ */
+size_t gen_pool_size(struct gen_pool *pool);
 
-extern unsigned long gen_pool_fixed_alloc(unsigned long *map,
-		unsigned long size, unsigned long start, unsigned int nr,
-		void *data, struct gen_pool *pool);
+/**
+ * gen_pool_set_algo() - set the allocation algorithm
+ * @pool: pool to change allocation algorithm
+ * @algo: custom algorithm function
+ * @data: additional data used by @algo
+ *
+ * Call @algo for each memory allocation in the pool.
+ * If @algo is NULL use gen_pool_first_fit as default
+ * memory allocation function.
+ */
+void gen_pool_set_algo(struct gen_pool *pool, genpool_algo_t algo, void *data);
 
-extern unsigned long gen_pool_first_fit_align(unsigned long *map,
-		unsigned long size, unsigned long start, unsigned int nr,
-		void *data, struct gen_pool *pool);
+/**
+ * gen_pool_first_fit() - find the first available region
+ * of memory matching the size requirement (no alignment constraint)
+ * @map: The address to base the search on
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
+ * @data: additional data - unused
+ * @pool: pool to find the fit region memory from
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
+ */
+unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
+				 unsigned long start, unsigned int nr,
+				 void *data, struct gen_pool *pool);
 
+/**
+ * gen_pool_first_fit_align() - find the first available region
+ * of memory matching the size requirement (alignment constraint)
+ * @map: The address to base the search on
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
+ * @data: data for alignment
+ * @pool: pool to get order from
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
+ */
+unsigned long gen_pool_first_fit_align(unsigned long *map,
+				       unsigned long size,
+				       unsigned long start,
+				       unsigned int nr, void *data,
+				       struct gen_pool *pool);
 
-extern unsigned long gen_pool_first_fit_order_align(unsigned long *map,
-		unsigned long size, unsigned long start, unsigned int nr,
-		void *data, struct gen_pool *pool);
+/**
+ * gen_pool_fixed_alloc() - reserve a specific region
+ * @map: The address to base the search on
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
+ * @data: data for alignment
+ * @pool: pool to get order from
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
+ */
+unsigned long gen_pool_fixed_alloc(unsigned long *map, unsigned long size,
+				   unsigned long start, unsigned int nr,
+				   void *data, struct gen_pool *pool);
 
-extern unsigned long gen_pool_best_fit(unsigned long *map, unsigned long size,
-		unsigned long start, unsigned int nr, void *data,
-		struct gen_pool *pool);
+/**
+ * gen_pool_first_fit_order_align() - find the first available region
+ * of memory matching the size requirement. The region will be aligned
+ * to the order of the size specified.
+ * @map: The address to base the search on
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
+ * @data: additional data - unused
+ * @pool: pool to find the fit region memory from
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
+ */
+unsigned long gen_pool_first_fit_order_align(unsigned long *map,
+					     unsigned long size,
+					     unsigned long start,
+					     unsigned int nr, void *data,
+					     struct gen_pool *pool);
 
+/**
+ * gen_pool_best_fit() - find the best fitting region of memory
+ * matching the size requirement (no alignment constraint)
+ * @map: The address to base the search on
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
+ * @data: additional data - unused
+ * @pool: pool to find the fit region memory from
+ *
+ * Iterate over the bitmap to find the smallest free region
+ * which we can allocate the memory.
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
+ */
+unsigned long gen_pool_best_fit(unsigned long *map, unsigned long size,
+				unsigned long start, unsigned int nr,
+				void *data, struct gen_pool *pool);
 
-extern struct gen_pool *devm_gen_pool_create(struct device *dev,
-		int min_alloc_order, int nid, const char *name);
-extern struct gen_pool *gen_pool_get(struct device *dev, const char *name);
+/**
+ * gen_pool_get() - Obtain the gen_pool (if any) for a device
+ * @dev: device to retrieve the gen_pool from
+ * @name: name of a gen_pool or NULL, identifies a particular gen_pool
+ *	  on device
+ *
+ * Return:
+ * * the gen_pool for the device	- if it exists
+ * * NULL				- no pool exists for the device
+ */
+struct gen_pool *gen_pool_get(struct device *dev, const char *name);
 
-bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
-			size_t size);
+/**
+ * devm_gen_pool_create() - managed gen_pool_create
+ * @dev: device that provides the gen_pool
+ * @min_alloc_order: log base 2 of number of bytes each bitmap bit represents
+ * @nid: node selector for allocated gen_pool, %NUMA_NO_NODE for all nodes
+ * @name: name of a gen_pool or NULL, identifies a particular gen_pool on device
+ *
+ * Create a new special memory pool that can be used to manage special purpose
+ * memory not managed by the regular kmalloc/kfree interface. The pool will be
+ * automatically destroyed by the device management code.
+ *
+ * Return:
+ * * address of the pool	- success
+ * * NULL			- error
+ */
+struct gen_pool *devm_gen_pool_create(struct device *dev, int min_alloc_order,
+				      int nid, const char *name);
 
+/**
+ * of_gen_pool_get() - find a pool by phandle property
+ * @np: device node
+ * @propname: property name containing phandle(s)
+ * @index: index into the phandle array
+ *
+ * Return:
+ * * pool address	- it contains the chunk starting at the physical
+ *			  address of the device tree node pointed at by
+ *			  the phandle property
+ * * NULL		- otherwise
+ */
 #ifdef CONFIG_OF
-extern struct gen_pool *of_gen_pool_get(struct device_node *np,
-	const char *propname, int index);
+struct gen_pool *of_gen_pool_get(struct device_node *np,
+				 const char *propname, int index);
 #else
 static inline struct gen_pool *of_gen_pool_get(struct device_node *np,
 	const char *propname, int index)
diff --git a/lib/genalloc.c b/lib/genalloc.c
index ca06adc4f445..d505b959f888 100644
--- a/lib/genalloc.c
+++ b/lib/genalloc.c
@@ -26,6 +26,74 @@
  *
  * This source code is licensed under the GNU General Public License,
  * Version 2.  See the file COPYING for more details.
+ *
+ *
+ *
+ * Encoding of the bitmap tracking the allocations
+ * -----------------------------------------------
+ *
+ * The bitmap is composed of units of allocations.
+ *
+ * Each unit of allocation is represented using 2 consecutive bits.
+ *
+ * This makes it possible to encode, for each unit of allocation,
+ * information about:
+ *  - allocation status (busy/free)
+ *  - beginning of a sequennce of allocation units (first / successive)
+ *
+ *
+ * Dictionary of allocation units (msb to the left, lsb to the right):
+ *
+ * 11: first allocation unit in the allocation
+ * 10: any subsequent allocation unit (if any) in the allocation
+ * 00: available allocation unit
+ * 01: invalid
+ *
+ * Example, using the same notation as above - MSb.......LSb:
+ *
+ *  ...000010111100000010101011   <-- Read in this direction.
+ *     \__|\__|\|\____|\______|
+ *        |   | |     |       \___ 4 used allocation units
+ *        |   | |     \___________ 3 empty allocation units
+ *        |   | \_________________ 1 used allocation unit
+ *        |   \___________________ 2 used allocation units
+ *        \_______________________ 2 empty allocation units
+ *
+ * The encoding allows for lockless operations, such as:
+ * - search for a sufficiently large range of allocation units
+ * - reservation of a selected range of allocation units
+ * - release of a specific allocation
+ *
+ * The alignment at which to perform the research for sequence of empty
+ * allocation units (marked as zeros in the bitmap) is 2^1.
+ *
+ * This means that an allocation can start only at even places
+ * (bit 0, bit 2, etc.) in the bitmap.
+ *
+ * Therefore, the number of zeroes to look for must be twice the number
+ * of desired allocation units.
+ *
+ * When it's time to free the memory associated to an allocation request,
+ * it's a matter of checking if the corresponding allocation unit is
+ * really the beginning of an allocation (both bits are set to 1).
+ *
+ * Looking for the ending can also be performed locklessly.
+ * It's sufficient to identify the first mapped allocation unit
+ * that is represented either as free (00) or busy (11).
+ * Even if the allocation status should change in the meanwhile, it
+ * doesn't matter, since it can only transition between free (00) and
+ * first-allocated (11).
+ *
+ * The parameter indicating to the *_free() function the size of the
+ * space that should be freed can be either set to 0, for automated
+ * assessment, or it can be specified explicitly.
+ *
+ * In case it is specified explicitly, the value is verified agaisnt what
+ * the library is tracking internally.
+ *
+ * If ever needed, the bitmap could be extended, assigning larger amounts
+ * of bits to each allocation unit (the increase must follow powers of 2),
+ * to track other properties of the allocations.
  */
 
 #include <linux/slab.h>
@@ -35,119 +103,251 @@
 #include <linux/interrupt.h>
 #include <linux/genalloc.h>
 #include <linux/of_device.h>
+#include <linux/bug.h>
+
+#define ENTRY_ORDER 1UL
+#define ENTRY_MASK ((1UL << ((ENTRY_ORDER) + 1UL)) - 1UL)
+#define ENTRY_HEAD ENTRY_MASK
+#define ENTRY_UNUSED 0UL
+#define BITS_PER_ENTRY (1U << ENTRY_ORDER)
+#define BITS_DIV_ENTRIES(x) ((x) >> ENTRY_ORDER)
+#define ENTRIES_TO_BITS(x) ((x) << ENTRY_ORDER)
+#define BITS_DIV_LONGS(x) ((x) / BITS_PER_LONG)
+#define ENTRIES_DIV_LONGS(x) (BITS_DIV_LONGS(ENTRIES_TO_BITS(x)))
+
+#define ENTRIES_PER_LONG BITS_DIV_ENTRIES(BITS_PER_LONG)
+
+/* Binary pattern of 1010...1010 that spans one unsigned long. */
+#define MASK (~0UL / 3 * 2)
+
+/**
+ * get_bitmap_entry() - extracts the specified entry from the bitmap
+ * @map: pointer to a bitmap
+ * @entry_index: the index of the desired entry in the bitmap
+ *
+ * Return: The requested bitmap.
+ */
+static inline unsigned long get_bitmap_entry(unsigned long *map,
+					    int entry_index)
+{
+	return (map[ENTRIES_DIV_LONGS(entry_index)] >>
+		ENTRIES_TO_BITS(entry_index % ENTRIES_PER_LONG)) &
+		ENTRY_MASK;
+}
+
 
+/**
+ * mem_to_units() - convert references to memory into orders of allocation
+ * @size: amount in bytes
+ * @order: power of 2 represented by each entry in the bitmap
+ *
+ * Return: the number of units representing the size.
+ */
+static inline unsigned long mem_to_units(unsigned long size,
+					 unsigned long order)
+{
+	return (size + (1UL << order) - 1) >> order;
+}
+
+/**
+ * chunk_size() - dimension of a chunk of memory, in bytes
+ * @chunk: pointer to the struct describing the chunk
+ *
+ * Return: The size of the chunk, in bytes.
+ */
 static inline size_t chunk_size(const struct gen_pool_chunk *chunk)
 {
 	return chunk->end_addr - chunk->start_addr + 1;
 }
 
-static int set_bits_ll(unsigned long *addr, unsigned long mask_to_set)
+
+/**
+ * set_bits_ll() - based on value and mask, sets bits at address
+ * @addr: where to write
+ * @mask: filter to apply for the bits to alter
+ * @value: actual configuration of bits to store
+ *
+ * Return:
+ * * 0		- success
+ * * -EBUSY	- otherwise
+ */
+static int set_bits_ll(unsigned long *addr,
+		       unsigned long mask, unsigned long value)
 {
-	unsigned long val, nval;
+	unsigned long nval;
+	unsigned long present;
+	unsigned long target;
 
 	nval = *addr;
 	do {
-		val = nval;
-		if (val & mask_to_set)
+		present = nval;
+		if (present & mask)
 			return -EBUSY;
+		target =  present | value;
 		cpu_relax();
-	} while ((nval = cmpxchg(addr, val, val | mask_to_set)) != val);
-
+	} while ((nval = cmpxchg(addr, present, target)) != target);
 	return 0;
 }
 
-static int clear_bits_ll(unsigned long *addr, unsigned long mask_to_clear)
+
+/**
+ * clear_bits_ll() - based on value and mask, clears bits at address
+ * @addr: where to write
+ * @mask: filter to apply for the bits to alter
+ * @value: actual configuration of bits to clear
+ *
+ * Return:
+ * * 0		- success
+ * * -EBUSY	- otherwise
+ */
+static int clear_bits_ll(unsigned long *addr,
+			 unsigned long mask, unsigned long value)
 {
-	unsigned long val, nval;
+	unsigned long nval;
+	unsigned long present;
+	unsigned long target;
 
 	nval = *addr;
+	present = nval;
+	if (unlikely((present & mask) ^ value))
+		return -EBUSY;
 	do {
-		val = nval;
-		if ((val & mask_to_clear) != mask_to_clear)
+		present = nval;
+		if (unlikely((present & mask) ^ value))
 			return -EBUSY;
+		target =  present & ~mask;
 		cpu_relax();
-	} while ((nval = cmpxchg(addr, val, val & ~mask_to_clear)) != val);
-
+	} while ((nval = cmpxchg(addr, present, target)) != target);
 	return 0;
 }
 
-/*
- * bitmap_set_ll - set the specified number of bits at the specified position
+
+/**
+ * get_boundary() - verifies address, then measure length.
  * @map: pointer to a bitmap
- * @start: a bit position in @map
- * @nr: number of bits to set
+ * @start_entry: the index of the first entry in the bitmap
+ * @nentries: number of entries to alter
  *
- * Set @nr bits start from @start in @map lock-lessly. Several users
- * can set/clear the same bitmap simultaneously without lock. If two
- * users set the same bit, one user will return remain bits, otherwise
- * return 0.
+ * Return:
+ * * length of an allocation	- success
+ * * -EINVAL			- invalid parameters
  */
-static int bitmap_set_ll(unsigned long *map, int start, int nr)
+static int get_boundary(unsigned long *map, unsigned int start_entry,
+			unsigned int nentries)
 {
-	unsigned long *p = map + BIT_WORD(start);
-	const int size = start + nr;
-	int bits_to_set = BITS_PER_LONG - (start % BITS_PER_LONG);
-	unsigned long mask_to_set = BITMAP_FIRST_WORD_MASK(start);
-
-	while (nr - bits_to_set >= 0) {
-		if (set_bits_ll(p, mask_to_set))
-			return nr;
-		nr -= bits_to_set;
-		bits_to_set = BITS_PER_LONG;
-		mask_to_set = ~0UL;
-		p++;
-	}
-	if (nr) {
-		mask_to_set &= BITMAP_LAST_WORD_MASK(size);
-		if (set_bits_ll(p, mask_to_set))
-			return nr;
-	}
+	int i;
+	unsigned long bitmap_entry;
 
-	return 0;
+
+	if (unlikely(get_bitmap_entry(map, start_entry) != ENTRY_HEAD))
+		return -EINVAL;
+	for (i = start_entry + 1; i < nentries; i++) {
+		bitmap_entry = get_bitmap_entry(map, i);
+		if (bitmap_entry == ENTRY_HEAD ||
+		    bitmap_entry == ENTRY_UNUSED)
+			return i;
+	}
+	return nentries - start_entry;
 }
 
+
+#define SET_BITS 1
+#define CLEAR_BITS 0
+
 /*
- * bitmap_clear_ll - clear the specified number of bits at the specified position
+ * alter_bitmap_ll() - set/clear the entries associated with an allocation
+ * @alteration: indicates if the bits selected should be set or cleared
  * @map: pointer to a bitmap
- * @start: a bit position in @map
- * @nr: number of bits to set
+ * @start: the index of the first entry in the bitmap
+ * @nentries: number of entries to alter
  *
- * Clear @nr bits start from @start in @map lock-lessly. Several users
- * can set/clear the same bitmap simultaneously without lock. If two
- * users clear the same bit, one user will return remain bits,
- * otherwise return 0.
+ * The modification happens lock-lessly.
+ * Several users can write to the same map simultaneously, without lock.
+ * In case of mid-air conflict, when 2 or more writers try to alter the
+ * same word in the bitmap, only one will succeed and continue, the others
+ * will fail and receive as return value the amount of entries that were
+ * not written. Each failed writer is responsible to revert the changes
+ * it did to the bitmap.
+ * The lockless conflict resolution is implemented through cmpxchg.
+ * Success or failure is purely based on first come first served basis.
+ * The first writer that manages to gain write access to the target word
+ * of the bitmap wins. Whatever can affect the order and priority of execution
+ * of the writers can and will affect the result of the race.
+ *
+ * Return:
+ * * 0			- success
+ * * remaining entries	- failure
  */
-static int bitmap_clear_ll(unsigned long *map, int start, int nr)
+static unsigned int alter_bitmap_ll(bool alteration, unsigned long *map,
+				    unsigned int start_entry,
+				    unsigned int nentries)
 {
-	unsigned long *p = map + BIT_WORD(start);
-	const int size = start + nr;
-	int bits_to_clear = BITS_PER_LONG - (start % BITS_PER_LONG);
-	unsigned long mask_to_clear = BITMAP_FIRST_WORD_MASK(start);
-
-	while (nr - bits_to_clear >= 0) {
-		if (clear_bits_ll(p, mask_to_clear))
-			return nr;
-		nr -= bits_to_clear;
-		bits_to_clear = BITS_PER_LONG;
-		mask_to_clear = ~0UL;
-		p++;
-	}
-	if (nr) {
-		mask_to_clear &= BITMAP_LAST_WORD_MASK(size);
-		if (clear_bits_ll(p, mask_to_clear))
-			return nr;
+	unsigned long start_bit;
+	unsigned long end_bit;
+	unsigned long mask;
+	unsigned long value;
+	unsigned int nbits;
+	unsigned int bits_to_write;
+	unsigned int index;
+	int (*action)(unsigned long *addr,
+		      unsigned long mask, unsigned long value);
+
+	action = (alteration == SET_BITS) ? set_bits_ll : clear_bits_ll;
+
+	/*
+	 * Prepare for writing the initial part of the allocation, from
+	 * starting entry, to the end of the UL bitmap element which
+	 * contains it. It might be larger than the actual allocation.
+	 */
+	start_bit = ENTRIES_TO_BITS(start_entry);
+	end_bit = ENTRIES_TO_BITS(start_entry + nentries);
+	nbits = ENTRIES_TO_BITS(nentries);
+	bits_to_write = BITS_PER_LONG - start_bit % BITS_PER_LONG;
+	mask = BITMAP_FIRST_WORD_MASK(start_bit);
+	/* Mark the beginning of the allocation. */
+	value = MASK | (1UL << (start_bit % BITS_PER_LONG));
+	index = BITS_DIV_LONGS(start_bit);
+
+	/*
+	 * Writes entries to the bitmap, as long as the reminder is
+	 * positive or zero.
+	 * Might be skipped if the entries to write do not reach the end
+	 * of a bitmap UL unit.
+	 */
+	while (nbits >= bits_to_write) {
+		if (action(map + index, mask, value & mask))
+			return BITS_DIV_ENTRIES(nbits);
+		nbits -= bits_to_write;
+		bits_to_write = BITS_PER_LONG;
+		mask = ~0UL;
+		value = MASK;
+		index++;
 	}
 
+	/* Takes care of the ending part of the entries to mark. */
+	if (nbits > 0) {
+		mask ^= BITMAP_FIRST_WORD_MASK((end_bit) % BITS_PER_LONG);
+		bits_to_write = nbits;
+		if (action(map + index, mask, value & mask))
+			return BITS_DIV_ENTRIES(nbits);
+	}
 	return 0;
 }
 
+
 /**
- * gen_pool_create - create a new special memory pool
- * @min_alloc_order: log base 2 of number of bytes each bitmap bit represents
- * @nid: node id of the node the pool structure should be allocated on, or -1
+ * gen_pool_create() - create a new special memory pool
+ * @min_alloc_order: log base 2 of number of bytes each bitmap entry
+ *		     represents
+ * @nid: node id of the node the pool structure should be allocated on,
+ *	 or -1
  *
- * Create a new special memory pool that can be used to manage special purpose
- * memory not managed by the regular kmalloc/kfree interface.
+ * Create a new special memory pool that can be used to manage special
+ * purpose memory not managed by the regular kmalloc/kfree interface.
+ *
+ * Return:
+ * * pointer to the pool	- success
+ * * NULL			- otherwise
  */
 struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
 {
@@ -167,7 +367,7 @@ struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
 EXPORT_SYMBOL(gen_pool_create);
 
 /**
- * gen_pool_add_virt - add a new chunk of special memory to the pool
+ * gen_pool_add_virt() - add a new chunk of special memory to the pool
  * @pool: pool to add new memory chunk to
  * @virt: virtual starting address of memory chunk to add to pool
  * @phys: physical starting address of memory chunk to add to pool
@@ -177,16 +377,20 @@ EXPORT_SYMBOL(gen_pool_create);
  *
  * Add a new chunk of special memory to the specified pool.
  *
- * Returns 0 on success or a -ve errno on failure.
+ * Return:
+ * * 0		- success
+ * * -ve errno	- failure
  */
-int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phys,
-		 size_t size, int nid)
+int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt,
+		      phys_addr_t phys, size_t size, int nid)
 {
 	struct gen_pool_chunk *chunk;
-	int nbits = size >> pool->min_alloc_order;
-	int nbytes = sizeof(struct gen_pool_chunk) +
-				BITS_TO_LONGS(nbits) * sizeof(long);
+	unsigned int nentries;
+	unsigned int nbytes;
 
+	nentries = size >> pool->min_alloc_order;
+	nbytes = sizeof(struct gen_pool_chunk) +
+		 ENTRIES_DIV_LONGS(nentries) * sizeof(long);
 	chunk = kzalloc_node(nbytes, GFP_KERNEL, nid);
 	if (unlikely(chunk == NULL))
 		return -ENOMEM;
@@ -205,11 +409,13 @@ int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phy
 EXPORT_SYMBOL(gen_pool_add_virt);
 
 /**
- * gen_pool_virt_to_phys - return the physical address of memory
+ * gen_pool_virt_to_phys() - return the physical address of memory
  * @pool: pool to allocate from
  * @addr: starting address of memory
  *
- * Returns the physical address on success, or -1 on error.
+ * Return:
+ * * the physical address	- success
+ * * \-1			- error
  */
 phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long addr)
 {
@@ -230,7 +436,7 @@ phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long addr)
 EXPORT_SYMBOL(gen_pool_virt_to_phys);
 
 /**
- * gen_pool_destroy - destroy a special memory pool
+ * gen_pool_destroy() - destroy a special memory pool
  * @pool: pool to destroy
  *
  * Destroy the specified special memory pool. Verifies that there are no
@@ -240,26 +446,33 @@ void gen_pool_destroy(struct gen_pool *pool)
 {
 	struct list_head *_chunk, *_next_chunk;
 	struct gen_pool_chunk *chunk;
-	int order = pool->min_alloc_order;
-	int bit, end_bit;
+	unsigned int order = pool->min_alloc_order;
+	unsigned long bit, end_bit;
+	bool empty = true;
 
 	list_for_each_safe(_chunk, _next_chunk, &pool->chunks) {
 		chunk = list_entry(_chunk, struct gen_pool_chunk, next_chunk);
 		list_del(&chunk->next_chunk);
 
 		end_bit = chunk_size(chunk) >> order;
-		bit = find_next_bit(chunk->bits, end_bit, 0);
-		BUG_ON(bit < end_bit);
-
+		bit = find_next_bit(chunk->entries, end_bit, 0);
+		if (unlikely(bit < end_bit)) {
+			WARN(true, "Attempt to destroy non-empty pool %s",
+				      pool->name);
+			empty = false;
+			continue;
+		}
 		kfree(chunk);
 	}
-	kfree_const(pool->name);
-	kfree(pool);
+	if (likely(empty)) {
+		kfree_const(pool->name);
+		kfree(pool);
+	}
 }
 EXPORT_SYMBOL(gen_pool_destroy);
 
 /**
- * gen_pool_alloc - allocate special memory from the pool
+ * gen_pool_alloc() - allocate special memory from the pool
  * @pool: pool to allocate from
  * @size: number of bytes to allocate from the pool
  *
@@ -267,6 +480,10 @@ EXPORT_SYMBOL(gen_pool_destroy);
  * Uses the pool allocation function (with first-fit algorithm by default).
  * Can not be used in NMI handler on architectures without
  * NMI-safe cmpxchg implementation.
+ *
+ * Return:
+ * * address of the memory allocated	- success
+ * * NULL				- error
  */
 unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
 {
@@ -275,7 +492,7 @@ unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
 EXPORT_SYMBOL(gen_pool_alloc);
 
 /**
- * gen_pool_alloc_algo - allocate special memory from the pool
+ * gen_pool_alloc_algo() - allocate special memory from the pool
  * @pool: pool to allocate from
  * @size: number of bytes to allocate from the pool
  * @algo: algorithm passed from caller
@@ -285,14 +502,18 @@ EXPORT_SYMBOL(gen_pool_alloc);
  * Uses the pool allocation function (with first-fit algorithm by default).
  * Can not be used in NMI handler on architectures without
  * NMI-safe cmpxchg implementation.
+ *
+ * Return:
+ * * address of the memory allocated	- success
+ * * NULL				- error
  */
 unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
 		genpool_algo_t algo, void *data)
 {
 	struct gen_pool_chunk *chunk;
 	unsigned long addr = 0;
-	int order = pool->min_alloc_order;
-	int nbits, start_bit, end_bit, remain;
+	unsigned int order = pool->min_alloc_order;
+	unsigned int nentries, start_entry, end_entry, remain;
 
 #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
 	BUG_ON(in_nmi());
@@ -301,29 +522,32 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
 	if (size == 0)
 		return 0;
 
-	nbits = (size + (1UL << order) - 1) >> order;
+	nentries = mem_to_units(size, order);
 	rcu_read_lock();
 	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
 		if (size > atomic_long_read(&chunk->avail))
 			continue;
 
-		start_bit = 0;
-		end_bit = chunk_size(chunk) >> order;
+		start_entry = 0;
+		end_entry = chunk_size(chunk) >> order;
 retry:
-		start_bit = algo(chunk->bits, end_bit, start_bit,
-				 nbits, data, pool);
-		if (start_bit >= end_bit)
+		start_entry = algo(chunk->entries, end_entry, start_entry,
+				  nentries, data, pool);
+		if (start_entry >= end_entry)
 			continue;
-		remain = bitmap_set_ll(chunk->bits, start_bit, nbits);
+		remain = alter_bitmap_ll(SET_BITS, chunk->entries,
+					 start_entry, nentries);
 		if (remain) {
-			remain = bitmap_clear_ll(chunk->bits, start_bit,
-						 nbits - remain);
-			BUG_ON(remain);
+			remain = alter_bitmap_ll(CLEAR_BITS,
+						 chunk->entries,
+						 start_entry,
+						 nentries - remain);
 			goto retry;
 		}
 
-		addr = chunk->start_addr + ((unsigned long)start_bit << order);
-		size = nbits << order;
+		addr = chunk->start_addr +
+			((unsigned long)start_entry << order);
+		size = nentries << order;
 		atomic_long_sub(size, &chunk->avail);
 		break;
 	}
@@ -333,7 +557,7 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
 EXPORT_SYMBOL(gen_pool_alloc_algo);
 
 /**
- * gen_pool_dma_alloc - allocate special memory from the pool for DMA usage
+ * gen_pool_dma_alloc() - allocate special memory from the pool for DMA usage
  * @pool: pool to allocate from
  * @size: number of bytes to allocate from the pool
  * @dma: dma-view physical address return value.  Use NULL if unneeded.
@@ -342,14 +566,15 @@ EXPORT_SYMBOL(gen_pool_alloc_algo);
  * Uses the pool allocation function (with first-fit algorithm by default).
  * Can not be used in NMI handler on architectures without
  * NMI-safe cmpxchg implementation.
+ *
+ * Return:
+ * * address of the memory allocated	- success
+ * * NULL				- error
  */
 void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
 {
 	unsigned long vaddr;
 
-	if (!pool)
-		return NULL;
-
 	vaddr = gen_pool_alloc(pool, size);
 	if (!vaddr)
 		return NULL;
@@ -362,10 +587,10 @@ void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
 EXPORT_SYMBOL(gen_pool_dma_alloc);
 
 /**
- * gen_pool_free - free allocated special memory back to the pool
+ * gen_pool_free() - free allocated special memory back to the pool
  * @pool: pool to free to
  * @addr: starting address of memory to free back to pool
- * @size: size in bytes of memory to free
+ * @size: size in bytes of memory to free or 0, for auto-detection
  *
  * Free previously allocated special memory back to the specified
  * pool.  Can not be used in NMI handler on architectures without
@@ -374,34 +599,63 @@ EXPORT_SYMBOL(gen_pool_dma_alloc);
 void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
 {
 	struct gen_pool_chunk *chunk;
-	int order = pool->min_alloc_order;
-	int start_bit, nbits, remain;
+	unsigned int order = pool->min_alloc_order;
+	unsigned int start_entry, remaining_entries, nentries, remain;
+	int boundary;
 
 #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
 	BUG_ON(in_nmi());
 #endif
 
-	nbits = (size + (1UL << order) - 1) >> order;
 	rcu_read_lock();
 	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
 		if (addr >= chunk->start_addr && addr <= chunk->end_addr) {
-			BUG_ON(addr + size - 1 > chunk->end_addr);
-			start_bit = (addr - chunk->start_addr) >> order;
-			remain = bitmap_clear_ll(chunk->bits, start_bit, nbits);
-			BUG_ON(remain);
-			size = nbits << order;
-			atomic_long_add(size, &chunk->avail);
+			if (unlikely(addr + size - 1 > chunk->end_addr)) {
+				rcu_read_unlock();
+				WARN(true,
+				     "Trying to free unallocated memory"
+				     " from pool %s", pool);
+				return;
+			}
+			start_entry = (addr - chunk->start_addr) >> order;
+			remaining_entries = (chunk->end_addr - addr) >> order;
+			boundary = get_boundary(chunk->entries, start_entry,
+						remaining_entries);
+			if (unlikely(exit_test(boundary < 0))) {
+				rcu_read_unlock();
+				WARN(true, "Corrupted pool %s", pool);
+				return;
+			}
+			nentries = boundary - start_entry;
+			if (unlikely(size && (nentries !=
+					      mem_to_units(size, order)))) {
+				rcu_read_unlock();
+				WARN(true,
+				     "Size provided differs from size "
+				     "measured from pool %s", pool);
+				return;
+			}
+			remain = alter_bitmap_ll(CLEAR_BITS, chunk->entries,
+						 start_entry, nentries);
+			if (unlikely(remain)) {
+				rcu_read_unlock();
+				WARN(true,
+				     "Unexpected bitmap collision while"
+				     " freeing memory in pool %s", pool);
+				return;
+			}
+			atomic_long_add(nentries << order, &chunk->avail);
 			rcu_read_unlock();
 			return;
 		}
 	}
 	rcu_read_unlock();
-	BUG();
+	WARN(true, "address not found in pool %s", pool->name);
 }
 EXPORT_SYMBOL(gen_pool_free);
 
 /**
- * gen_pool_for_each_chunk - call func for every chunk of generic memory pool
+ * gen_pool_for_each_chunk() - call func for every chunk of generic memory pool
  * @pool:	the generic memory pool
  * @func:	func to call
  * @data:	additional data used by @func
@@ -423,16 +677,19 @@ void gen_pool_for_each_chunk(struct gen_pool *pool,
 EXPORT_SYMBOL(gen_pool_for_each_chunk);
 
 /**
- * addr_in_gen_pool - checks if an address falls within the range of a pool
+ * addr_in_gen_pool() - checks if an address falls within the range of a pool
  * @pool:	the generic memory pool
  * @start:	start address
  * @size:	size of the region
  *
- * Check if the range of addresses falls within the specified pool. Returns
- * true if the entire range is contained in the pool and false otherwise.
+ * Check if the range of addresses falls within the specified pool.
+ *
+ * Return:
+ * * true	- the entire range is contained in the pool
+ * * false	- otherwise
  */
 bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
-			size_t size)
+		      size_t size)
 {
 	bool found = false;
 	unsigned long end = start + size - 1;
@@ -452,10 +709,10 @@ bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
 }
 
 /**
- * gen_pool_avail - get available free space of the pool
+ * gen_pool_avail() - get available free space of the pool
  * @pool: pool to get available free space
  *
- * Return available free space of the specified pool.
+ * Return: available free space of the specified pool.
  */
 size_t gen_pool_avail(struct gen_pool *pool)
 {
@@ -471,10 +728,10 @@ size_t gen_pool_avail(struct gen_pool *pool)
 EXPORT_SYMBOL_GPL(gen_pool_avail);
 
 /**
- * gen_pool_size - get size in bytes of memory managed by the pool
+ * gen_pool_size() - get size in bytes of memory managed by the pool
  * @pool: pool to get size
  *
- * Return size in bytes of memory managed by the pool.
+ * Return: size in bytes of memory managed by the pool.
  */
 size_t gen_pool_size(struct gen_pool *pool)
 {
@@ -490,7 +747,7 @@ size_t gen_pool_size(struct gen_pool *pool)
 EXPORT_SYMBOL_GPL(gen_pool_size);
 
 /**
- * gen_pool_set_algo - set the allocation algorithm
+ * gen_pool_set_algo() - set the allocation algorithm
  * @pool: pool to change allocation algorithm
  * @algo: custom algorithm function
  * @data: additional data used by @algo
@@ -514,137 +771,200 @@ void gen_pool_set_algo(struct gen_pool *pool, genpool_algo_t algo, void *data)
 EXPORT_SYMBOL(gen_pool_set_algo);
 
 /**
- * gen_pool_first_fit - find the first available region
+ * gen_pool_first_fit() - find the first available region
  * of memory matching the size requirement (no alignment constraint)
  * @map: The address to base the search on
- * @size: The bitmap size in bits
- * @start: The bitnumber to start searching at
- * @nr: The number of zeroed bits we're looking for
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
  * @data: additional data - unused
  * @pool: pool to find the fit region memory from
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
  */
 unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
-		unsigned long start, unsigned int nr, void *data,
-		struct gen_pool *pool)
+				 unsigned long start, unsigned int nr,
+				 void *data, struct gen_pool *pool)
 {
-	return bitmap_find_next_zero_area(map, size, start, nr, 0);
+	unsigned long align_mask;
+	unsigned long bit_index;
+
+	align_mask = roundup_pow_of_two(BITS_PER_ENTRY) - 1;
+	bit_index = bitmap_find_next_zero_area(map, ENTRIES_TO_BITS(size),
+					       ENTRIES_TO_BITS(start),
+					       ENTRIES_TO_BITS(nr),
+					       align_mask);
+	return BITS_DIV_ENTRIES(bit_index);
 }
 EXPORT_SYMBOL(gen_pool_first_fit);
 
 /**
- * gen_pool_first_fit_align - find the first available region
+ * gen_pool_first_fit_align() - find the first available region
  * of memory matching the size requirement (alignment constraint)
  * @map: The address to base the search on
- * @size: The bitmap size in bits
- * @start: The bitnumber to start searching at
- * @nr: The number of zeroed bits we're looking for
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
  * @data: data for alignment
  * @pool: pool to get order from
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
  */
-unsigned long gen_pool_first_fit_align(unsigned long *map, unsigned long size,
-		unsigned long start, unsigned int nr, void *data,
-		struct gen_pool *pool)
+unsigned long gen_pool_first_fit_align(unsigned long *map,
+				       unsigned long size,
+				       unsigned long start,
+				       unsigned int nr, void *data,
+				       struct gen_pool *pool)
 {
 	struct genpool_data_align *alignment;
 	unsigned long align_mask;
-	int order;
+	unsigned long bit_index;
+	unsigned int order;
 
 	alignment = data;
 	order = pool->min_alloc_order;
-	align_mask = ((alignment->align + (1UL << order) - 1) >> order) - 1;
-	return bitmap_find_next_zero_area(map, size, start, nr, align_mask);
+	align_mask = roundup_pow_of_two(
+			ENTRIES_TO_BITS(mem_to_units(alignment->align,
+						     order))) - 1;
+	bit_index = bitmap_find_next_zero_area(map, ENTRIES_TO_BITS(size),
+					       ENTRIES_TO_BITS(start),
+					       ENTRIES_TO_BITS(nr),
+					       align_mask);
+	return BITS_DIV_ENTRIES(bit_index);
 }
 EXPORT_SYMBOL(gen_pool_first_fit_align);
 
 /**
- * gen_pool_fixed_alloc - reserve a specific region
+ * gen_pool_fixed_alloc() - reserve a specific region
  * @map: The address to base the search on
- * @size: The bitmap size in bits
- * @start: The bitnumber to start searching at
- * @nr: The number of zeroed bits we're looking for
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
  * @data: data for alignment
  * @pool: pool to get order from
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
  */
 unsigned long gen_pool_fixed_alloc(unsigned long *map, unsigned long size,
-		unsigned long start, unsigned int nr, void *data,
-		struct gen_pool *pool)
+				   unsigned long start, unsigned int nr,
+				   void *data, struct gen_pool *pool)
 {
 	struct genpool_data_fixed *fixed_data;
-	int order;
-	unsigned long offset_bit;
-	unsigned long start_bit;
+	unsigned int order;
+	unsigned long offset;
+	unsigned long align_mask;
+	unsigned long bit_index;
 
 	fixed_data = data;
 	order = pool->min_alloc_order;
-	offset_bit = fixed_data->offset >> order;
 	if (WARN_ON(fixed_data->offset & ((1UL << order) - 1)))
 		return size;
+	offset = fixed_data->offset >> order;
+	align_mask = roundup_pow_of_two(BITS_PER_ENTRY) - 1;
+	bit_index = bitmap_find_next_zero_area(map, ENTRIES_TO_BITS(size),
+					       ENTRIES_TO_BITS(start + offset),
+					       ENTRIES_TO_BITS(nr), align_mask);
+	if (bit_index != ENTRIES_TO_BITS(offset))
+		return size;
 
-	start_bit = bitmap_find_next_zero_area(map, size,
-			start + offset_bit, nr, 0);
-	if (start_bit != offset_bit)
-		start_bit = size;
-	return start_bit;
+	return BITS_DIV_ENTRIES(bit_index);
 }
 EXPORT_SYMBOL(gen_pool_fixed_alloc);
 
 /**
- * gen_pool_first_fit_order_align - find the first available region
+ * gen_pool_first_fit_order_align() - find the first available region
  * of memory matching the size requirement. The region will be aligned
  * to the order of the size specified.
  * @map: The address to base the search on
- * @size: The bitmap size in bits
- * @start: The bitnumber to start searching at
- * @nr: The number of zeroed bits we're looking for
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
  * @data: additional data - unused
  * @pool: pool to find the fit region memory from
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
  */
 unsigned long gen_pool_first_fit_order_align(unsigned long *map,
-		unsigned long size, unsigned long start,
-		unsigned int nr, void *data, struct gen_pool *pool)
+					     unsigned long size,
+					     unsigned long start,
+					     unsigned int nr, void *data,
+					     struct gen_pool *pool)
 {
-	unsigned long align_mask = roundup_pow_of_two(nr) - 1;
-
-	return bitmap_find_next_zero_area(map, size, start, nr, align_mask);
+	unsigned long align_mask;
+	unsigned long bit_index;
+
+	align_mask = roundup_pow_of_two(ENTRIES_TO_BITS(nr)) - 1;
+	bit_index = bitmap_find_next_zero_area(map, ENTRIES_TO_BITS(size),
+					       ENTRIES_TO_BITS(start),
+					       ENTRIES_TO_BITS(nr),
+					       align_mask);
+	return BITS_DIV_ENTRIES(bit_index);
 }
 EXPORT_SYMBOL(gen_pool_first_fit_order_align);
 
 /**
- * gen_pool_best_fit - find the best fitting region of memory
- * macthing the size requirement (no alignment constraint)
+ * gen_pool_best_fit() - find the best fitting region of memory
+ * matching the size requirement (no alignment constraint)
  * @map: The address to base the search on
- * @size: The bitmap size in bits
- * @start: The bitnumber to start searching at
- * @nr: The number of zeroed bits we're looking for
+ * @size: The number of allocation units in the bitmap
+ * @start: The allocation unit to start searching at
+ * @nr: The number of allocation units we're looking for
  * @data: additional data - unused
  * @pool: pool to find the fit region memory from
  *
  * Iterate over the bitmap to find the smallest free region
  * which we can allocate the memory.
+ *
+ * Return:
+ * * index of the memory allocated	- sufficient space available
+ * * end of the range			- insufficient space
  */
 unsigned long gen_pool_best_fit(unsigned long *map, unsigned long size,
-		unsigned long start, unsigned int nr, void *data,
-		struct gen_pool *pool)
+				unsigned long start, unsigned int nr,
+				void *data, struct gen_pool *pool)
 {
-	unsigned long start_bit = size;
+	unsigned long start_bit = ENTRIES_TO_BITS(size);
 	unsigned long len = size + 1;
 	unsigned long index;
+	unsigned long align_mask;
+	unsigned long bit_index;
 
-	index = bitmap_find_next_zero_area(map, size, start, nr, 0);
+	align_mask = roundup_pow_of_two(BITS_PER_ENTRY) - 1;
+	bit_index = bitmap_find_next_zero_area(map, ENTRIES_TO_BITS(size),
+					       ENTRIES_TO_BITS(start),
+					       ENTRIES_TO_BITS(nr),
+					       align_mask);
+	index = BITS_DIV_ENTRIES(bit_index);
 
 	while (index < size) {
-		int next_bit = find_next_bit(map, size, index + nr);
-		if ((next_bit - index) < len) {
-			len = next_bit - index;
-			start_bit = index;
+		unsigned long next_bit;
+
+		next_bit = find_next_bit(map, ENTRIES_TO_BITS(size),
+					 ENTRIES_TO_BITS(index + nr));
+		if ((BITS_DIV_ENTRIES(next_bit) - index) < len) {
+			len = BITS_DIV_ENTRIES(next_bit) - index;
+			start_bit = ENTRIES_TO_BITS(index);
 			if (len == nr)
-				return start_bit;
+				return BITS_DIV_ENTRIES(start_bit);
 		}
-		index = bitmap_find_next_zero_area(map, size,
-						   next_bit + 1, nr, 0);
+		bit_index =
+			bitmap_find_next_zero_area(map,
+						   ENTRIES_TO_BITS(size),
+						   next_bit + 1,
+						   ENTRIES_TO_BITS(nr),
+						   align_mask);
+		index = BITS_DIV_ENTRIES(bit_index);
 	}
 
-	return start_bit;
+	return BITS_DIV_ENTRIES(start_bit);
 }
 EXPORT_SYMBOL(gen_pool_best_fit);
 
@@ -668,11 +988,14 @@ static int devm_gen_pool_match(struct device *dev, void *res, void *data)
 }
 
 /**
- * gen_pool_get - Obtain the gen_pool (if any) for a device
+ * gen_pool_get() - Obtain the gen_pool (if any) for a device
  * @dev: device to retrieve the gen_pool from
- * @name: name of a gen_pool or NULL, identifies a particular gen_pool on device
+ * @name: name of a gen_pool or NULL, identifies a particular gen_pool
+ *	  on device
  *
- * Returns the gen_pool for the device if one is present, or NULL.
+ * Return:
+ * * the gen_pool for the device	- if it exists
+ * * NULL				- no pool exists for the device
  */
 struct gen_pool *gen_pool_get(struct device *dev, const char *name)
 {
@@ -687,7 +1010,7 @@ struct gen_pool *gen_pool_get(struct device *dev, const char *name)
 EXPORT_SYMBOL_GPL(gen_pool_get);
 
 /**
- * devm_gen_pool_create - managed gen_pool_create
+ * devm_gen_pool_create() - managed gen_pool_create
  * @dev: device that provides the gen_pool
  * @min_alloc_order: log base 2 of number of bytes each bitmap bit represents
  * @nid: node selector for allocated gen_pool, %NUMA_NO_NODE for all nodes
@@ -696,6 +1019,10 @@ EXPORT_SYMBOL_GPL(gen_pool_get);
  * Create a new special memory pool that can be used to manage special purpose
  * memory not managed by the regular kmalloc/kfree interface. The pool will be
  * automatically destroyed by the device management code.
+ *
+ * Return:
+ * * address of the pool	- success
+ * * NULL			- error
  */
 struct gen_pool *devm_gen_pool_create(struct device *dev, int min_alloc_order,
 				      int nid, const char *name)
@@ -738,17 +1065,19 @@ EXPORT_SYMBOL(devm_gen_pool_create);
 
 #ifdef CONFIG_OF
 /**
- * of_gen_pool_get - find a pool by phandle property
+ * of_gen_pool_get() - find a pool by phandle property
  * @np: device node
  * @propname: property name containing phandle(s)
  * @index: index into the phandle array
  *
- * Returns the pool that contains the chunk starting at the physical
- * address of the device tree node pointed at by the phandle property,
- * or NULL if not found.
+ * Return:
+ * * pool address	- it contains the chunk starting at the physical
+ *			  address of the device tree node pointed at by
+ *			  the phandle property
+ * * NULL		- otherwise
  */
 struct gen_pool *of_gen_pool_get(struct device_node *np,
-	const char *propname, int index)
+				 const char *propname, int index)
 {
 	struct platform_device *pdev;
 	struct device_node *np_pool, *parent;
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
