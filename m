Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0CC6B0006
	for <linux-mm@kvack.org>; Sat, 10 Feb 2018 22:20:20 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t14so1185900wmc.5
        for <linux-mm@kvack.org>; Sat, 10 Feb 2018 19:20:20 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id z27si5011230edi.430.2018.02.10.19.20.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Feb 2018 19:20:17 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 1/6] genalloc: track beginning of allocations
Date: Sun, 11 Feb 2018 05:19:15 +0200
Message-ID: <20180211031920.3424-2-igor.stoppa@huawei.com>
In-Reply-To: <20180211031920.3424-1-igor.stoppa@huawei.com>
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

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

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/genalloc.h |   4 +-
 lib/genalloc.c           | 527 ++++++++++++++++++++++++++++++++++-------------
 2 files changed, 390 insertions(+), 141 deletions(-)

diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
index 872f930f1b06..dcaa33e74b1c 100644
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
diff --git a/lib/genalloc.c b/lib/genalloc.c
index ca06adc4f445..044347163acb 100644
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
@@ -36,118 +104,230 @@
 #include <linux/genalloc.h>
 #include <linux/of_device.h>
 
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
+ * get_bitmap_entry - extracts the specified entry from the bitmap
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
+
+/**
+ * mem_to_units - convert references to memory into orders of allocation
+ * @size: amount in bytes
+ * @order: power of 2 represented by each entry in the bitmap
+ *
+ * Returns the number of units representing the size.
+ */
+static inline unsigned long mem_to_units(unsigned long size,
+					 unsigned long order)
+{
+	return (size + (1UL << order) - 1) >> order;
+}
+
+/**
+ * chunk_size - dimension of a chunk of memory, in bytes
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
+ * set_bits_ll - according to the mask, sets the bits specified by
+ * value, at the address specified.
+ * @addr: where to write
+ * @mask: filter to apply for the bits to alter
+ * @value: actual configuration of bits to store
+ *
+ * Return: 0 upon success, -EBUSY otherwise
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
+ * clear_bits_ll - according to the mask, clears the bits specified by
+ * value, at the address specified.
+ * @addr: where to write
+ * @mask: filter to apply for the bits to alter
+ * @value: actual configuration of bits to clear
+ *
+ * Return: 0 upon success, -EBUSY otherwise
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
+ * get_boundary - verify that an allocation effectively
+ * starts at the given address, then measure its length.
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
+ * Return: the length of an allocation, otherwise -EINVAL if the
+ * parameters do not refer to a correct allocation.
  */
-static int bitmap_set_ll(unsigned long *map, int start, int nr)
+static int get_boundary(unsigned long *map, int start_entry, int nentries)
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
+ * alter_bitmap_ll - set or clear the entries associated with an allocation
+ * @alteration: indicates if the bits selected should be set or cleared
  * @map: pointer to a bitmap
- * @start: a bit position in @map
- * @nr: number of bits to set
+ * @start: the index of the first entry in the bitmap
+ * @nentries: number of entries to alter
+ *
+ * The modification happens lock-lessly.
+ * Several users can write to the same map simultaneously, without lock.
  *
- * Clear @nr bits start from @start in @map lock-lessly. Several users
- * can set/clear the same bitmap simultaneously without lock. If two
- * users clear the same bit, one user will return remain bits,
- * otherwise return 0.
+ * Return: If two users alter the same bit, to one it will return
+ * remaining entries, to the other it will return 0.
  */
-static int bitmap_clear_ll(unsigned long *map, int start, int nr)
+static int alter_bitmap_ll(bool alteration, unsigned long *map,
+			   int start_entry, int nentries)
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
+	int nbits;
+	int bits_to_write;
+	int index;
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
  * gen_pool_create - create a new special memory pool
- * @min_alloc_order: log base 2 of number of bytes each bitmap bit represents
+ * @min_alloc_order: log base 2 of number of bytes each bitmap entry represents
  * @nid: node id of the node the pool structure should be allocated on, or -1
  *
  * Create a new special memory pool that can be used to manage special purpose
  * memory not managed by the regular kmalloc/kfree interface.
+ *
+ * Return: pointer to the pool, if successful, NULL otherwise
  */
 struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
 {
@@ -177,16 +357,18 @@ EXPORT_SYMBOL(gen_pool_create);
  *
  * Add a new chunk of special memory to the specified pool.
  *
- * Returns 0 on success or a -ve errno on failure.
+ * Return: 0 on success or a -ve errno on failure.
  */
 int gen_pool_add_virt(struct gen_pool *pool, unsigned long virt, phys_addr_t phys,
 		 size_t size, int nid)
 {
 	struct gen_pool_chunk *chunk;
-	int nbits = size >> pool->min_alloc_order;
-	int nbytes = sizeof(struct gen_pool_chunk) +
-				BITS_TO_LONGS(nbits) * sizeof(long);
+	int nentries;
+	int nbytes;
 
+	nentries = size >> pool->min_alloc_order;
+	nbytes = sizeof(struct gen_pool_chunk) +
+		 ENTRIES_DIV_LONGS(nentries) * sizeof(long);
 	chunk = kzalloc_node(nbytes, GFP_KERNEL, nid);
 	if (unlikely(chunk == NULL))
 		return -ENOMEM;
@@ -209,7 +391,7 @@ EXPORT_SYMBOL(gen_pool_add_virt);
  * @pool: pool to allocate from
  * @addr: starting address of memory
  *
- * Returns the physical address on success, or -1 on error.
+ * Return: the physical address on success, or -1 on error.
  */
 phys_addr_t gen_pool_virt_to_phys(struct gen_pool *pool, unsigned long addr)
 {
@@ -248,7 +430,7 @@ void gen_pool_destroy(struct gen_pool *pool)
 		list_del(&chunk->next_chunk);
 
 		end_bit = chunk_size(chunk) >> order;
-		bit = find_next_bit(chunk->bits, end_bit, 0);
+		bit = find_next_bit(chunk->entries, end_bit, 0);
 		BUG_ON(bit < end_bit);
 
 		kfree(chunk);
@@ -267,6 +449,8 @@ EXPORT_SYMBOL(gen_pool_destroy);
  * Uses the pool allocation function (with first-fit algorithm by default).
  * Can not be used in NMI handler on architectures without
  * NMI-safe cmpxchg implementation.
+ *
+ * Return: address of the memory allocated, otherwise NULL
  */
 unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
 {
@@ -285,6 +469,8 @@ EXPORT_SYMBOL(gen_pool_alloc);
  * Uses the pool allocation function (with first-fit algorithm by default).
  * Can not be used in NMI handler on architectures without
  * NMI-safe cmpxchg implementation.
+ *
+ * Return: address of the memory allocated, otherwise NULL
  */
 unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
 		genpool_algo_t algo, void *data)
@@ -292,7 +478,7 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
 	struct gen_pool_chunk *chunk;
 	unsigned long addr = 0;
 	int order = pool->min_alloc_order;
-	int nbits, start_bit, end_bit, remain;
+	int nentries, start_entry, end_entry, remain;
 
 #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
 	BUG_ON(in_nmi());
@@ -301,29 +487,32 @@ unsigned long gen_pool_alloc_algo(struct gen_pool *pool, size_t size,
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
@@ -342,6 +531,8 @@ EXPORT_SYMBOL(gen_pool_alloc_algo);
  * Uses the pool allocation function (with first-fit algorithm by default).
  * Can not be used in NMI handler on architectures without
  * NMI-safe cmpxchg implementation.
+ *
+ * Return: address of the memory allocated, otherwise NULL
  */
 void *gen_pool_dma_alloc(struct gen_pool *pool, size_t size, dma_addr_t *dma)
 {
@@ -365,7 +556,7 @@ EXPORT_SYMBOL(gen_pool_dma_alloc);
  * gen_pool_free - free allocated special memory back to the pool
  * @pool: pool to free to
  * @addr: starting address of memory to free back to pool
- * @size: size in bytes of memory to free
+ * @size: size in bytes of memory to free or 0, for auto-detection
  *
  * Free previously allocated special memory back to the specified
  * pool.  Can not be used in NMI handler on architectures without
@@ -375,22 +566,29 @@ void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
 {
 	struct gen_pool_chunk *chunk;
 	int order = pool->min_alloc_order;
-	int start_bit, nbits, remain;
+	int start_entry, remaining_entries, nentries, remain;
+	int boundary;
 
 #ifndef CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG
 	BUG_ON(in_nmi());
 #endif
 
-	nbits = (size + (1UL << order) - 1) >> order;
 	rcu_read_lock();
 	list_for_each_entry_rcu(chunk, &pool->chunks, next_chunk) {
 		if (addr >= chunk->start_addr && addr <= chunk->end_addr) {
 			BUG_ON(addr + size - 1 > chunk->end_addr);
-			start_bit = (addr - chunk->start_addr) >> order;
-			remain = bitmap_clear_ll(chunk->bits, start_bit, nbits);
+			start_entry = (addr - chunk->start_addr) >> order;
+			remaining_entries = (chunk->end_addr - addr) >> order;
+			boundary = get_boundary(chunk->entries, start_entry,
+						remaining_entries);
+			BUG_ON(boundary < 0);
+			nentries = boundary - start_entry;
+			BUG_ON(size &&
+			       (nentries != mem_to_units(size, order)));
+			remain = alter_bitmap_ll(CLEAR_BITS, chunk->entries,
+						 start_entry, nentries);
 			BUG_ON(remain);
-			size = nbits << order;
-			atomic_long_add(size, &chunk->avail);
+			atomic_long_add(nentries << order, &chunk->avail);
 			rcu_read_unlock();
 			return;
 		}
@@ -428,8 +626,9 @@ EXPORT_SYMBOL(gen_pool_for_each_chunk);
  * @start:	start address
  * @size:	size of the region
  *
- * Check if the range of addresses falls within the specified pool. Returns
- * true if the entire range is contained in the pool and false otherwise.
+ * Check if the range of addresses falls within the specified pool.
+ *
+ * Return: true if the entire range is contained in the pool, false otherwise.
  */
 bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
 			size_t size)
@@ -455,7 +654,7 @@ bool addr_in_gen_pool(struct gen_pool *pool, unsigned long start,
  * gen_pool_avail - get available free space of the pool
  * @pool: pool to get available free space
  *
- * Return available free space of the specified pool.
+ * Return: available free space of the specified pool.
  */
 size_t gen_pool_avail(struct gen_pool *pool)
 {
@@ -474,7 +673,7 @@ EXPORT_SYMBOL_GPL(gen_pool_avail);
  * gen_pool_size - get size in bytes of memory managed by the pool
  * @pool: pool to get size
  *
- * Return size in bytes of memory managed by the pool.
+ * Return: size in bytes of memory managed by the pool.
  */
 size_t gen_pool_size(struct gen_pool *pool)
 {
@@ -517,17 +716,27 @@ EXPORT_SYMBOL(gen_pool_set_algo);
  * gen_pool_first_fit - find the first available region
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
+ * Return: index of the memory allocated, otherwise the end of the range
  */
 unsigned long gen_pool_first_fit(unsigned long *map, unsigned long size,
 		unsigned long start, unsigned int nr, void *data,
 		struct gen_pool *pool)
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
 
@@ -535,11 +744,13 @@ EXPORT_SYMBOL(gen_pool_first_fit);
  * gen_pool_first_fit_align - find the first available region
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
+ * Return: index of the memory allocated, otherwise the end of the range
  */
 unsigned long gen_pool_first_fit_align(unsigned long *map, unsigned long size,
 		unsigned long start, unsigned int nr, void *data,
@@ -547,23 +758,32 @@ unsigned long gen_pool_first_fit_align(unsigned long *map, unsigned long size,
 {
 	struct genpool_data_align *alignment;
 	unsigned long align_mask;
+	unsigned long bit_index;
 	int order;
 
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
  * gen_pool_fixed_alloc - reserve a specific region
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
+ * Return: index of the memory allocated, otherwise the end of the range
  */
 unsigned long gen_pool_fixed_alloc(unsigned long *map, unsigned long size,
 		unsigned long start, unsigned int nr, void *data,
@@ -571,20 +791,23 @@ unsigned long gen_pool_fixed_alloc(unsigned long *map, unsigned long size,
 {
 	struct genpool_data_fixed *fixed_data;
 	int order;
-	unsigned long offset_bit;
-	unsigned long start_bit;
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
 
@@ -593,60 +816,84 @@ EXPORT_SYMBOL(gen_pool_fixed_alloc);
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
+ * Return: index of the memory allocated, otherwise the end of the range
  */
 unsigned long gen_pool_first_fit_order_align(unsigned long *map,
 		unsigned long size, unsigned long start,
 		unsigned int nr, void *data, struct gen_pool *pool)
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
  * gen_pool_best_fit - find the best fitting region of memory
- * macthing the size requirement (no alignment constraint)
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
+ * Return: index of the memory allocated, otherwise the end of the range
  */
 unsigned long gen_pool_best_fit(unsigned long *map, unsigned long size,
 		unsigned long start, unsigned int nr, void *data,
 		struct gen_pool *pool)
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
+		int next_bit;
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
-EXPORT_SYMBOL(gen_pool_best_fit);
 
 static void devm_gen_pool_release(struct device *dev, void *res)
 {
@@ -672,7 +919,7 @@ static int devm_gen_pool_match(struct device *dev, void *res, void *data)
  * @dev: device to retrieve the gen_pool from
  * @name: name of a gen_pool or NULL, identifies a particular gen_pool on device
  *
- * Returns the gen_pool for the device if one is present, or NULL.
+ * Return: the gen_pool for the device if one is present, or NULL.
  */
 struct gen_pool *gen_pool_get(struct device *dev, const char *name)
 {
@@ -696,6 +943,8 @@ EXPORT_SYMBOL_GPL(gen_pool_get);
  * Create a new special memory pool that can be used to manage special purpose
  * memory not managed by the regular kmalloc/kfree interface. The pool will be
  * automatically destroyed by the device management code.
+ *
+ * Return: the address of the pool, if successful, otherwise NULL
  */
 struct gen_pool *devm_gen_pool_create(struct device *dev, int min_alloc_order,
 				      int nid, const char *name)
@@ -743,7 +992,7 @@ EXPORT_SYMBOL(devm_gen_pool_create);
  * @propname: property name containing phandle(s)
  * @index: index into the phandle array
  *
- * Returns the pool that contains the chunk starting at the physical
+ * Return: the pool that contains the chunk starting at the physical
  * address of the device tree node pointed at by the phandle property,
  * or NULL if not found.
  */
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
