Date: Tue, 24 Jul 2001 16:30:10 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: __alloc_pages_core speedup
Message-ID: <20010724163010.A3593@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On IBM NUMA hardware, there was a peculiar delay during boot just
prior to "ACPI: Installing SCI 9 handler pass".

It was determined that this delay (of approximately 80 seconds)
consisted of calls to __alloc_bootmem_core. It appears that it
is only called when needed, and that an individual call was
taking a great deal of time. I'm not sure what the right way to
fix this is, but I've tried a few approaches. I am interested
in hearing of other ways to cope with this situation that would
be more effective or more palatable.

First, I tried to alter this so that it read in blocks of some
compiler-supported size (e.g. u64) and performed its checks on
64-bit blocks at a time, with (of course) some provisions for
end cases. This was not successful, either due to unexpected
interactions or implementation errors.

The following merely provides some non-atomic bit operations,
and replaces the calls to the atomic versions in bootmem.c with
calls to them. It provides a speedup of 8 seconds, providing the
following timings:

----		seconds from EFI to APCI: Installing SCI 9 handler pass
Atomic:		79
Non-atomic:	71

----		seconds from above to VFS mount
Atomic:		122
Non-atomic:	114

... and other significant landmarks in booting differ by 8 seconds.

I don't believe this issue is truly architecture-specific, as it
appears to me that the properties of the algorithm would likely scale
similarly on different architectures. And I can also provide
implementations of the non-atomic bit operations for other architectures.

Cheers,
Bill

P.S.:	The diffs follow:

--- linux-old/mm/bootmem.c	Mon Jul 23 11:37:58 2001
+++ linux-0626/mm/bootmem.c	Wed Jul 18 14:50:02 2001
@@ -89,17 +89,17 @@
 		BUG();
 	if (sidx >= eidx)
 		BUG();
 	if ((addr >> PAGE_SHIFT) >= bdata->node_low_pfn)
 		BUG();
 	if (end > bdata->node_low_pfn)
 		BUG();
 	for (i = sidx; i < eidx; i++)
-		if (test_and_set_bit(i, bdata->node_bootmem_map))
+		if (__test_and_set_bit(i, bdata->node_bootmem_map))
 			printk("hm, page %08lx reserved twice.\n", i*PAGE_SIZE);
 }
 
 static void __init free_bootmem_core(bootmem_data_t *bdata, unsigned long addr, unsigned long size)
 {
 	unsigned long i;
 	unsigned long start;
 	/*
@@ -116,17 +116,17 @@
 
 	/*
 	 * Round up the beginning of the address.
 	 */
 	start = (addr + PAGE_SIZE-1) / PAGE_SIZE;
 	sidx = start - (bdata->node_boot_start/PAGE_SIZE);
 
 	for (i = sidx; i < eidx; i++) {
-		if (!test_and_clear_bit(i, bdata->node_bootmem_map))
+		if (!__test_and_clear_bit(i, bdata->node_bootmem_map))
 			BUG();
 	}
 }
 
 /*
  * We 'merge' subsequent allocations to save space. We might 'lose'
  * some fraction of a page if allocations cannot be satisfied due to
  * size constraints on boxes where there is physical RAM space
@@ -166,22 +166,22 @@
 
 	preferred = ((preferred + align - 1) & ~(align - 1)) >> PAGE_SHIFT;
 	areasize = (size+PAGE_SIZE-1)/PAGE_SIZE;
 	incr = align >> PAGE_SHIFT ? : 1;
 
 restart_scan:
 	for (i = preferred; i < eidx; i += incr) {
 		unsigned long j;
-		if (test_bit(i, bdata->node_bootmem_map))
+		if (__test_bit(i, bdata->node_bootmem_map))
 			continue;
 		for (j = i + 1; j < i + areasize; ++j) {
 			if (j >= eidx)
 				goto fail_block;
-			if (test_bit (j, bdata->node_bootmem_map))
+			if (__test_bit (j, bdata->node_bootmem_map))
 				goto fail_block;
 		}
 		start = i;
 		goto found;
 	fail_block:;
 	}
 	if (preferred) {
 		preferred = 0;
@@ -222,17 +222,17 @@
 		bdata->last_pos = start + areasize - 1;
 		bdata->last_offset = size & ~PAGE_MASK;
 		ret = phys_to_virt(start * PAGE_SIZE + bdata->node_boot_start);
 	}
 	/*
 	 * Reserve the area now:
 	 */
 	for (i = start; i < start+areasize; i++)
-		if (test_and_set_bit(i, bdata->node_bootmem_map))
+		if (__test_and_set_bit(i, bdata->node_bootmem_map))
 			BUG();
 	memset(ret, 0, size);
 	return ret;
 }
 
 static unsigned long __init free_all_bootmem_core(pg_data_t *pgdat)
 {
 	struct page *page = pgdat->node_mem_map;
@@ -240,17 +240,17 @@
 	unsigned long i, count, total = 0;
 	unsigned long idx;
 
 	if (!bdata->node_bootmem_map) BUG();
 
 	count = 0;
 	idx = bdata->node_low_pfn - (bdata->node_boot_start >> PAGE_SHIFT);
 	for (i = 0; i < idx; i++, page++) {
-		if (!test_bit(i, bdata->node_bootmem_map)) {
+		if (!__test_bit(i, bdata->node_bootmem_map)) {
 			count++;
 			ClearPageReserved(page);
 			set_page_count(page, 1);
 			__free_page(page);
 		}
 	}
 	total += count;
 

--- linux-old/include/asm-ia64/bitops.h	Mon Jul 23 11:38:28 2001
+++ linux-0626/include/asm-ia64/bitops.h	Wed Jul 18 14:53:34 2001
@@ -30,16 +30,27 @@
 	bit = 1 << (nr & 31);
 	do {
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old | bit;
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
+static __inline__ void
+__set_bit(int nr, void * addr)
+{
+	__u32 bit, old, *m;
+	m = ((__u32 *)addr) + (nr >> 5);
+	bit = 0x1 << (nr & 0x1f);
+	old = *m;
+	*m |= bit;
+	return;
+}
+
 /*
  * clear_bit() doesn't provide any barrier for the compiler.
  */
 #define smp_mb__before_clear_bit()	smp_mb()
 #define smp_mb__after_clear_bit()	smp_mb()
 static __inline__ void
 clear_bit (int nr, volatile void *addr)
 {
@@ -51,16 +62,27 @@
 	mask = ~(1 << (nr & 31));
 	do {
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old & mask;
 	} while (cmpxchg_acq(m, old, new) != old);
 }
 
+static __inline__ void
+__clear_bit(int nr, void * addr)
+{
+	__u32 mask, old, *m;
+	m = ((__u32 *)addr) + (nr >> 5);
+	mask = ~(0x1 << (nr & 0x1f));
+	old = *m;
+	*m &= mask;
+	return;
+}
+
 /*
  * WARNING: non atomic version.
  */
 static __inline__ void
 __change_bit (int nr, void *addr)
 {
 	volatile __u32 *m = (__u32 *) addr + (nr >> 5);
 	__u32 bit = (1 << (nr & 31));
@@ -97,32 +119,55 @@
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old | bit;
 	} while (cmpxchg_acq(m, old, new) != old);
 	return (old & bit) != 0;
 }
 
 static __inline__ int
+__test_and_set_bit(int nr, void * addr)
+{
+	__u32 bit, old;
+	__u32 * m;
+	m = ((__u32 *)addr) + (nr >> 5);
+	bit = 0x1 << (nr & 0x1f);
+	old = *m;
+	*m |= bit;
+	return((old & bit) != 0);
+}
+
+static __inline__ int
 test_and_clear_bit (int nr, volatile void *addr)
 {
 	__u32 mask, old, new;
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
 	m = (volatile __u32 *) addr + (nr >> 5);
 	mask = ~(1 << (nr & 31));
 	do {
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old & mask;
 	} while (cmpxchg_acq(m, old, new) != old);
 	return (old & ~mask) != 0;
 }
 
+static __inline__ int
+__test_and_clear_bit(int nr, void * addr)
+{
+	__u32 mask, old, *m;
+	m = ((__u32 *)addr) + (nr >> 5);
+	mask = ~(0x1 << (nr & 0x1f));
+	old = *m;
+	*m &= mask;
+	return((old & ~mask) != 0);
+}
+
 /*
  * WARNING: non atomic version.
  */
 static __inline__ int
 __test_and_change_bit (int nr, void *addr)
 {
 	__u32 old, bit = (1 << (nr & 31));
 	__u32 *m = (__u32 *) addr + (nr >> 5);
@@ -148,16 +193,22 @@
 	} while (cmpxchg_acq(m, old, new) != old);
 	return (old & bit) != 0;
 }
 
 static __inline__ int
 test_bit (int nr, volatile void *addr)
 {
 	return 1 & (((const volatile __u32 *) addr)[nr >> 5] >> (nr & 31));
+}
+
+static __inline__ int
+__test_bit(int nr, void * addr)
+{
+	return 0x1 & (((__u32 *)addr)[nr >> 5] >> (nr & 0x1f));
 }
 
 /*
  * ffz = "find first zero".  Returns the bit number (0..63) of the first (least
  * significant) bit that is zero in X.  Undefined if no zero exists, so code should check
  * against ~0UL first...
  */
 static inline unsigned long
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
