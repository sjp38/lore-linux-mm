Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep16-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050827220254.UGQM2060.amsfep16-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Sun, 28 Aug 2005 00:02:54 +0200
Message-Id: <20050827220255.668396000@twins>
References: <20050827215756.726585000@twins>
Date: Sat, 27 Aug 2005 23:57:57 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][PATCH 1/6] CART Implementation
Content-Disposition: inline; filename=cart-nonresident.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Index: linux-2.6-cart/include/linux/swap.h
===================================================================
--- linux-2.6-cart.orig/include/linux/swap.h
+++ linux-2.6-cart/include/linux/swap.h
@@ -154,6 +154,15 @@ extern void out_of_memory(unsigned int _
 /* linux/mm/memory.c */
 extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
 
+/* linux/mm/nonresident.c */
+#define NR_filter	0x01  /* short/long */
+#define NR_list		0x02  /* b1/b2; correlates to PG_active */
+#define NR_evict	0x80000000
+
+extern unsigned int remember_page(struct address_space *, unsigned long, unsigned int);
+extern unsigned int recently_evicted(struct address_space *, unsigned long);
+extern void init_nonresident(void);
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalhigh_pages;
@@ -292,6 +301,11 @@ static inline swp_entry_t get_swap_page(
 #define grab_swap_token()  do { } while(0)
 #define has_swap_token(x) 0
 
+/* linux/mm/nonresident.c */
+#define init_nonresident()	do { } while (0)
+#define remember_page(x,y,z)	0
+#define recently_evicted(x,y)	0
+
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
Index: linux-2.6-cart/init/main.c
===================================================================
--- linux-2.6-cart.orig/init/main.c
+++ linux-2.6-cart/init/main.c
@@ -47,6 +47,7 @@
 #include <linux/rmap.h>
 #include <linux/mempolicy.h>
 #include <linux/key.h>
+#include <linux/swap.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -494,6 +495,7 @@ asmlinkage void __init start_kernel(void
 	}
 #endif
 	vfs_caches_init_early();
+	init_nonresident();
 	mem_init();
 	kmem_cache_init();
 	setup_per_cpu_pageset();
Index: linux-2.6-cart/mm/Makefile
===================================================================
--- linux-2.6-cart.orig/mm/Makefile
+++ linux-2.6-cart/mm/Makefile
@@ -12,7 +12,8 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   readahead.o slab.o swap.o truncate.o vmscan.o \
 			   prio_tree.o $(mmu-y)
 
-obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o \
+				nonresident.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
Index: linux-2.6-cart/mm/nonresident.c
===================================================================
--- /dev/null
+++ linux-2.6-cart/mm/nonresident.c
@@ -0,0 +1,277 @@
+/*
+ * mm/nonresident.c
+ * (C) 2004,2005 Red Hat, Inc
+ * Written by Rik van Riel <riel@redhat.com>
+ * Released under the GPL, see the file COPYING for details.
+ * Adapted by Peter Zijlstra <a.p.zijlstra@chello.nl> for use by ARC
+ * like algorithms.
+ *
+ * Keeps track of whether a non-resident page was recently evicted
+ * and should be immediately promoted to the active list. This also
+ * helps automatically tune the inactive target.
+ *
+ * The pageout code stores a recently evicted page in this cache
+ * by calling remember_page(mapping/mm, index/vaddr)
+ * and can look it up in the cache by calling recently_evicted()
+ * with the same arguments.
+ *
+ * Note that there is no way to invalidate pages after eg. truncate
+ * or exit, we let the pages fall out of the non-resident set through
+ * normal replacement.
+ *
+ *
+ * Modified to work with ARC like algorithms who:
+ *  - need to balance two FIFOs; |b1| + |b2| = c,
+ *  - keep a flag per non-resident page.
+ *
+ * The bucket contains two single linked cyclic lists (CLOCKS) and each
+ * clock has a tail hand. By selecting a victim clock upon insertion it
+ * is possible to balance them.
+ *
+ * The slot looks like this:
+ * struct slot_t {
+ *         u32 cookie : 24; // LSB
+ *         u32 index  :  6;
+ *         u32 filter :  1;
+ *         u32 clock  :  1; // MSB
+ * };
+ *
+ * The bucket is guarded by a spinlock.
+ */
+#include <linux/swap.h>
+#include <linux/mm.h>
+#include <linux/cache.h>
+#include <linux/spinlock.h>
+#include <linux/bootmem.h>
+#include <linux/hash.h>
+#include <linux/prefetch.h>
+#include <linux/kernel.h>
+
+#define TARGET_SLOTS	64
+#define NR_CACHELINES  (TARGET_SLOTS*sizeof(u32) / L1_CACHE_BYTES)
+#define NR_SLOTS	(((NR_CACHELINES * L1_CACHE_BYTES) - sizeof(spinlock_t) - 2*sizeof(u16)) / sizeof(u32))
+#if 0
+#if NR_SLOTS < (TARGET_SLOTS / 2)
+#warning very small slot size
+#if NR_SLOTS <= 0
+#error no room for slots left
+#endif
+#endif
+#endif
+
+#define BUILD_MASK(bits, shift) (((1 << (bits)) - 1) << (shift))
+
+#define FLAGS_BITS		2
+#define FLAGS_SHIFT		(sizeof(u32)*8 - FLAGS_BITS)
+#define FLAGS_MASK		BUILD_MASK(FLAGS_BITS, FLAGS_SHIFT)
+
+#define SET_FLAGS(x, flg)	((x) = ((x) & ~FLAGS_MASK) | ((flg) << FLAGS_SHIFT))
+#define GET_FLAGS(x)		(((x) & FLAGS_MASK) >> FLAGS_SHIFT)
+
+#define INDEX_BITS		6  /* ceil(log2(NR_SLOTS)) */
+#define INDEX_SHIFT		(FLAGS_SHIFT - INDEX_BITS)
+#define INDEX_MASK		BUILD_MASK(INDEX_BITS, INDEX_SHIFT)
+
+#define SET_INDEX(x, idx)	((x) = ((x) & ~INDEX_MASK) | ((idx) << INDEX_SHIFT))
+#define GET_INDEX(x)		(((x) & INDEX_MASK) >> INDEX_SHIFT)
+
+struct nr_bucket
+{
+	spinlock_t lock;
+	u16 hand[2];
+	u32 slot[NR_SLOTS];
+} ____cacheline_aligned;
+
+/* The non-resident page hash table. */
+static struct nr_bucket * nonres_table;
+static unsigned int nonres_shift;
+static unsigned int nonres_mask;
+
+/* hash the address into a bucket */
+static struct nr_bucket * nr_hash(void * mapping, unsigned long index)
+{
+	unsigned long bucket;
+	unsigned long hash;
+
+	hash = hash_ptr(mapping, BITS_PER_LONG);
+	hash = 37 * hash + hash_long(index, BITS_PER_LONG);
+	bucket = hash & nonres_mask;
+
+	return nonres_table + bucket;
+}
+
+/* hash the address and inode into a cookie */
+static u32 nr_cookie(struct address_space * mapping, unsigned long index)
+{
+	unsigned long cookie;
+
+	cookie = hash_ptr(mapping, BITS_PER_LONG);
+	cookie = 37 * cookie + hash_long(index, BITS_PER_LONG);
+
+	if (mapping && mapping->host) {
+		cookie = 37 * cookie + hash_long(mapping->host->i_ino, BITS_PER_LONG);
+	}
+
+	return (u32)(cookie >> (BITS_PER_LONG - 32));
+}
+
+unsigned int recently_evicted(struct address_space * mapping, unsigned long index)
+{
+	struct nr_bucket * nr_bucket;
+	u32 wanted, mask;
+	unsigned int r_flags = 0;
+	int i;
+	unsigned long iflags;
+
+	prefetch(mapping->host);
+	nr_bucket = nr_hash(mapping, index);
+
+	spin_lock_prefetch(nr_bucket); // prefetch_range(nr_bucket, NR_CACHELINES);
+	mask = ~(FLAGS_MASK | INDEX_MASK);
+	wanted = nr_cookie(mapping, index) & mask;
+
+	spin_lock_irqsave(&nr_bucket->lock, iflags);
+	for (i = 0; i < NR_SLOTS; ++i) {
+		if ((nr_bucket->slot[i] & mask) == wanted) {
+			r_flags = GET_FLAGS(nr_bucket->slot[i]);
+			r_flags |= NR_evict; /* set the MSB to mark presence */
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&nr_bucket->lock, iflags);
+
+	return r_flags;
+}
+
+/* flags:
+ *   logical and of the page flags (NR_filter, NR_list) and
+ *   an NR_evict target
+ *
+ * remove current (b from 'abc'):
+ *
+ *    initial        swap(2,3)
+ *
+ *   1: -> [2],a     1: -> [2],a
+ * * 2: -> [3],b     2: -> [1],c
+ *   3: -> [1],c   * 3: -> [3],b
+ *
+ *   3 is now free for use.
+ *
+ *
+ * insert before (d before b in 'abc')
+ *
+ *    initial          set 4         swap(2,4)
+ *
+ *   1: -> [2],a     1: -> [2],a    1: -> [2],a
+ * * 2: -> [3],b     2: -> [3],b    2: -> [4],d
+ *   3: -> [1],c     3: -> [1],c    3: -> [1],c
+ *   4: nil          4: -> [4],d  * 4: -> [3],b
+ *
+ *   leaving us with 'adbc'.
+ */
+unsigned int remember_page(struct address_space * mapping, unsigned long index, unsigned int flags)
+{
+	struct nr_bucket *nr_bucket;
+	u32 cookie;
+	u32 *slot, *tail;
+	unsigned int slot_pos, tail_pos;
+	unsigned long iflags;
+
+	prefetch(mapping->host);
+	nr_bucket = nr_hash(mapping, index);
+
+	spin_lock_prefetch(nr_bucket); // prefetchw_range(nr_bucket, NR_CACHELINES);
+	cookie = nr_cookie(mapping, index);
+	SET_FLAGS(cookie, flags);
+
+	flags &= NR_evict; /* removal chain */
+	spin_lock_irqsave(&nr_bucket->lock, iflags);
+
+	/* free a slot */
+again:
+	tail_pos = nr_bucket->hand[!!flags];
+	BUG_ON(tail_pos >= NR_SLOTS);
+	tail = &nr_bucket->slot[tail_pos];
+	if (unlikely((*tail & NR_evict) != flags)) {
+		flags ^= NR_evict; /* empty chain; take other one */
+		goto again;
+	}
+	BUG_ON((*tail & NR_evict) != flags);
+	/* free slot by swapping tail,tail+1, so that we skip over tail */
+	slot_pos = GET_INDEX(*tail);
+	BUG_ON(slot_pos >= NR_SLOTS);
+	slot = &nr_bucket->slot[slot_pos];
+	BUG_ON((*slot & NR_evict) != flags);
+	if (likely(tail != slot)) *slot = xchg(tail, *slot);
+	/* slot: -> [slot], old cookie */
+	BUG_ON(GET_INDEX(*slot) != slot_pos);
+
+	flags = (cookie & NR_evict); /* insertion chain */
+
+	/* place cookie in empty slot */
+	SET_INDEX(cookie, slot_pos); /* -> [slot], cookie */
+	cookie = xchg(slot, cookie); /* slot: -> [slot], cookie */
+
+	/* insert slot before tail; ie. MRU pos */
+	tail_pos = nr_bucket->hand[!!flags];
+	BUG_ON(tail_pos >= NR_SLOTS);
+	tail = &nr_bucket->slot[tail_pos];
+	if (likely((*tail & NR_evict) == flags && tail != slot))
+		*slot = xchg(tail, *slot); /* swap if not empty and not same */
+	nr_bucket->hand[!!flags] = slot_pos;
+
+	spin_unlock_irqrestore(&nr_bucket->lock, iflags);
+
+	return GET_FLAGS(cookie);
+}
+
+/*
+ * For interactive workloads, we remember about as many non-resident pages
+ * as we have actual memory pages.  For server workloads with large inter-
+ * reference distances we could benefit from remembering more.
+ */
+static __initdata unsigned long nonresident_factor = 1;
+void __init init_nonresident(void)
+{
+	int target;
+	int i, j;
+
+	/*
+	 * Calculate the non-resident hash bucket target. Use a power of
+	 * two for the division because alloc_large_system_hash rounds up.
+	 */
+	target = nr_all_pages * nonresident_factor;
+	target /= (sizeof(struct nr_bucket) / sizeof(u32));
+
+	nonres_table = alloc_large_system_hash("Non-resident page tracking",
+					sizeof(struct nr_bucket),
+					target,
+					0,
+					HASH_EARLY | HASH_HIGHMEM,
+					&nonres_shift,
+					&nonres_mask,
+					0);
+
+	for (i = 0; i < (1 << nonres_shift); i++) {
+		spin_lock_init(&nonres_table[i].lock);
+		nonres_table[i].hand[0] = nonres_table[i].hand[1] = 0;
+		for (j = 0; j < NR_SLOTS; ++j) {
+			nonres_table[i].slot[j] = 0;
+			SET_FLAGS(nonres_table[i].slot[j], (NR_list | NR_filter));
+			if (j < NR_SLOTS - 1)
+				SET_INDEX(nonres_table[i].slot[j], j+1);
+			else /* j == NR_SLOTS - 1 */
+				SET_INDEX(nonres_table[i].slot[j], 0);
+		}
+	}
+}
+
+static int __init set_nonresident_factor(char * str)
+{
+	if (!str)
+		return 0;
+	nonresident_factor = simple_strtoul(str, &str, 0);
+	return 1;
+}
+
+__setup("nonresident_factor=", set_nonresident_factor);

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
