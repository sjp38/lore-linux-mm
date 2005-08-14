Subject: Re: Zoned CART
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1123857429.14899.59.camel@twins>
References: <1123857429.14899.59.camel@twins>
Content-Type: multipart/mixed; boundary="=-8aqcXJBQ+IaOy9yDhx/V"
Date: Sun, 14 Aug 2005 14:58:32 +0200
Message-Id: <1124024312.30836.26.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Rahul Iyer <rni@andrew.cmu.edu>
List-ID: <linux-mm.kvack.org>

--=-8aqcXJBQ+IaOy9yDhx/V
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2005-08-12 at 16:37 +0200, Peter Zijlstra wrote:

> This will keep:
> 
>  |B1_j|     |B1|     Sum^i(|B1_i|)
> -------- ~ ------ = -------------
>  |B2_j|     |B2|     Sum^i(|B2_i|)
> 
> however it will violate strict FIFO order within the buckets; although I
> guess it won't be too bad.
> 

Still it bothered me. So I propose the attached code to fix it. What
I've done is to keep 2 proper clocks in the bucket. Each clock is a
single linked cyclic list where links are slot positions bitfield
encoded in the cookie; only 24 bits of uniqueness left.

The code is a bit messy and totaly untested (it should explode since I
wrote it around 2 in the morning) but I think the concept is sound. The
'insert before' and 'remove current' operations are implemented by
swapping slots.

remove current (b from 'abc'):

   initial        swap(2,3)

  1: -> [2],a     1: -> [2],a
* 2: -> [3],b     2: -> [1],c
  3: -> [1],c   * 3: -> [3],b

3 is now free for use.


insert before (d before b in 'abc')

   initial        set 4          swap(2,4)

  1: -> [2],a     1: -> [2],a    1: -> [2],a
* 2: -> [3],b     2: -> [3],b    2: -> [4],d
  3: -> [1],c     3: -> [1],c    3: -> [1],c
  4: nil          4: -> [4],d  * 4: -> [3],b

leaving us with 'adbc'.


The only thing is that for this to work we have to start the algorith
with filled nonresident clocks. Currently it assumes: 
  q_i = c_i/2,
  |B1_i| = q_i,
  |B2_i| = c_i - q_i.
If q=0 etc., would be preferred changing the initial clocks to 
  |B1_j| = 0 and |B2_j| = c_j
should not pose any problems either.

Ok, now on to putting Rahul code on top of this ;-)


-- 
Peter Zijlstra <a.p.zijlstra@chello.nl>

--=-8aqcXJBQ+IaOy9yDhx/V
Content-Disposition: attachment; filename=nonresident-pages-2.patch
Content-Type: text/x-patch; name=nonresident-pages-2.patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

diff -NaurX linux-2.6.13-rc6/Documentation/dontdiff linux-2.6.13-rc6/include/linux/nonresident.h linux-2.6.13-rc6-cart/include/linux/nonresident.h
--- linux-2.6.13-rc6/include/linux/nonresident.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.13-rc6-cart/include/linux/nonresident.h	2005-08-12 13:55:54.000000000 +0200
@@ -0,0 +1,11 @@
+#ifndef __LINUX_NONRESIDENT_H
+#define __LINUX_NONRESIDENT_H
+
+#define NR_filter		0x01  /* short/long */
+#define NR_list			0x02  /* b1/b2; correlates to PG_active */
+
+#define EVICT_MASK	0x80000000
+#define EVICT_B1	0x00000000
+#define EVICT_B2	0x80000000
+
+#endif /* __LINUX_NONRESIDENT_H */
diff -NaurX linux-2.6.13-rc6/Documentation/dontdiff linux-2.6.13-rc6/include/linux/swap.h linux-2.6.13-rc6-cart/include/linux/swap.h
--- linux-2.6.13-rc6/include/linux/swap.h	2005-08-08 20:57:50.000000000 +0200
+++ linux-2.6.13-rc6-cart/include/linux/swap.h	2005-08-12 14:00:26.000000000 +0200
@@ -154,6 +154,11 @@
 /* linux/mm/memory.c */
 extern void swapin_readahead(swp_entry_t, unsigned long, struct vm_area_struct *);
 
+/* linux/mm/nonresident.c */
+extern u32 remember_page(struct address_space *, unsigned long, unsigned int);
+extern unsigned int recently_evicted(struct address_space *, unsigned long);
+extern void init_nonresident(void);
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalhigh_pages;
@@ -292,6 +297,11 @@
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
diff -NaurX linux-2.6.13-rc6/Documentation/dontdiff linux-2.6.13-rc6/init/main.c linux-2.6.13-rc6-cart/init/main.c
--- linux-2.6.13-rc6/init/main.c	2005-08-08 20:57:51.000000000 +0200
+++ linux-2.6.13-rc6-cart/init/main.c	2005-08-10 08:33:38.000000000 +0200
@@ -47,6 +47,7 @@
 #include <linux/rmap.h>
 #include <linux/mempolicy.h>
 #include <linux/key.h>
+#include <linux/swap.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -494,6 +495,7 @@
 	}
 #endif
 	vfs_caches_init_early();
+	init_nonresident();
 	mem_init();
 	kmem_cache_init();
 	setup_per_cpu_pageset();
diff -NaurX linux-2.6.13-rc6/Documentation/dontdiff linux-2.6.13-rc6/mm/Makefile linux-2.6.13-rc6-cart/mm/Makefile
--- linux-2.6.13-rc6/mm/Makefile	2005-08-08 20:57:52.000000000 +0200
+++ linux-2.6.13-rc6-cart/mm/Makefile	2005-08-10 08:33:39.000000000 +0200
@@ -12,7 +12,8 @@
 			   readahead.o slab.o swap.o truncate.o vmscan.o \
 			   prio_tree.o $(mmu-y)
 
-obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o \
+			   nonresident.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
 obj-$(CONFIG_SPARSEMEM)	+= sparse.o
diff -NaurX linux-2.6.13-rc6/Documentation/dontdiff linux-2.6.13-rc6/mm/nonresident.c linux-2.6.13-rc6-cart/mm/nonresident.c
--- linux-2.6.13-rc6/mm/nonresident.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.13-rc6-cart/mm/nonresident.c	2005-08-12 14:00:26.000000000 +0200
@@ -0,0 +1,211 @@
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
+ *         u32 cookie : 24; /* LSB */
+ *         u32 index  :  6;
+ *         u32 filter :  1;
+ *         u32 clock  :  1; /* MSB */
+ * };
+ *
+ * The bucket is guarded by a spinlock.
+ */
+#include <linux/mm.h>
+#include <linux/cache.h>
+#include <linux/spinlock.h>
+#include <linux/bootmem.h>
+#include <linux/hash.h>
+#include <linux/prefetch.h>
+#include <linux/kernel.h>
+#include <linux/nonresident.h>
+
+#define TARGET_SLOTS	64
+#define NR_CACHELINES  (TARGET_SLOTS*sizeof(u32) / L1_CACHE_BYTES);
+#define NR_SLOTS	(((NR_CACHELINES * L1_CACHE_BYTES) - sizeof(spinlock_t) - 2*sizeof(u16)) / sizeof(u32))
+#if NR_SLOTS < TARGET_SLOTS / 2
+#warning very small slot size
+#if NR_SLOTS <= 0
+#error no room for slots left
+#endif
+#endif
+
+#define BUILD_MASK(bits, shift) (((1 << (bits)) - 1) << (shift))
+
+#define FLAGS_BITS		2
+#define FLAGS_SHIFT		(sizeof(u32)*8 - FLAGS_BITS)
+#define FLAGS_MASK		BUILD_MASK(FLAGS_BITS, FLAGS_SHIFT)
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
+/* hash the address, inode and flags into a cookie */
+/* the two msb are flags; where msb-1 is a type flag and msb a period flag */
+static u32 nr_cookie(struct address_space * mapping, unsigned long index, unsigned int flags)
+{
+	u32 c;
+	unsigned long cookie;
+	
+	cookie = hash_ptr(mapping, BITS_PER_LONG);
+	cookie = 37 * cookie + hash_long(index, BITS_PER_LONG);
+
+	if (mapping->host) {
+		cookie = 37 * cookie + hash_long(mapping->host->i_ino, BITS_PER_LONG);
+	}
+
+	c = (u32)(cookie >> (BITS_PER_LONG - 32));
+	c = (c & ~FLAGS_MASK) | ((flags << FLAGS_SHIFT) & FLAGS_MASK);
+	return c;
+}
+
+unsigned int recently_evicted(struct address_space * mapping, unsigned long index)
+{
+	struct nr_bucket * nr_bucket;
+	u32 wanted, mask;
+	unsigned int r_flags = 0;
+	int i;
+
+	prefetch(mapping->host);
+	nr_bucket = nr_hash(mapping, index);
+
+	spin_lock_prefetch(nr_bucket); // prefetch_range(nr_bucket, NR_CACHELINES);
+	wanted = nr_cookie(mapping, index, 0) & ~INDEX_MASK;
+	mask = ~(FLAGS_MASK | INDEX_MASK);
+
+	spin_lock(&nr_bucket->lock);
+	for (i = 0; i < NR_SLOTS; ++i) {
+		if (nr_bucket->slot[i] & mask == wanted) {
+			r_flags = nr_bucket->slot[i] >> FLAGS_SHIFT;
+			r_flags |= EVICT_MASK; /* set the MSB to mark presence */
+			break;
+		}
+	}
+	spin_unlock(&nr_bucket->lock);
+
+	return r_flags;
+}
+
+/* flags: 
+ *   logical and of the page flags (NR_filter, NR_list) and
+ *   an EVICT_ target
+ */
+u32 remember_page(struct address_space * mapping, unsigned long index, unsigned int flags)
+{
+	struct nr_bucket *nr_bucket;
+	u32 cookie;
+	u32 *slot, *tail;
+	int slot_pos, tail_pos;
+
+	prefetch(mapping->host);
+	nr_bucket = nr_hash(mapping, index);
+
+	spin_lock_prefetch(nr_bucket); // prefetchw_range(nr_bucket, NR_CACHELINES);
+	cookie = nr_cookie(mapping, index, flags);
+
+	flags &= EVICT_MASK;
+	spin_lock(&nr_bucket->lock);
+
+again:
+	tail_pos = nr_bucket->hand[!!flags]; /* tail slot in removal clock */
+	&tail = &nr_bucket->slot[tail_pos];
+	if (unlikely(*tail & EVICT_MASK != flags)) {
+		flags ^= EVICT_MASK; /* empty clock; take other one */
+		goto again;
+	} 
+	/* free slot by swapping tail,tail+1, so that we skip over tail */
+	slot_pos = GET_INDEX(*tail);
+	slot = &nr_bucket->slot[slot_pos];
+	if (likely(tail != slot)) *slot = xchg(tail, *slot);
+
+	SET_INDEX(cookie, slot_pos); /* cookie -> slot */
+
+	flags = cookie & EVICT_MASK; /* insertion chain */
+	tail = &nr_bucket->slot[nr_bucket->hand[!!flags]];
+	cookie = xchg(tail, cookie); /* prev/tail-1 -> cookie/tail -> slot */
+
+	if (likely(tail != slot)) cookie = xchg(slot, cookie);
+	nr_bucket->hand[!!flags] = slot_pos; /* prev -> cookie -> slot/tail */
+
+	spin_unlock(&nr_bucket->lock);
+
+	return cookie;
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
+		nonres_table[i].hand[0] = 0;
+		nonres_table[i].hand[1] = NR_SLOTS/2;
+		for (j = 0; j < NR_SLOTS; ++j) {
+			nonres_table[i].slot[j] = (j < NR_SLOTS/2) ? 0 : EVICT_MASK;
+			if (j < NR_SLOTS/2 - 1)
+				SET_INDEX(nonres_table[i].slot[j], j+1);
+			else if (j == NR_SLOTS/2 - 1)
+				SET_INDEX(nonres_table[i].slot[j], 0);
+			else if (j < NR_SLOTS - 1)
+				SET_INDEX(nonres_table[i].slot[j], j+1);
+			else /* j == NR_SLOTS - 1 */
+				SET_INDEX(nonres_table[i].slot[j], NR_SLOTS/2);
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
+__setup("nonresident_factor=", set_nonresident_factor);

--=-8aqcXJBQ+IaOy9yDhx/V--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
