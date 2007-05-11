Date: Fri, 11 May 2007 10:54:24 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] optimise unlock_page
Message-ID: <20070511085424.GA15352@wotan.suse.de>
References: <20070508113709.GA19294@wotan.suse.de> <20070508114003.GB19294@wotan.suse.de> <1178659827.14928.85.camel@localhost.localdomain> <20070508224124.GD20174@wotan.suse.de> <20070508225012.GF20174@wotan.suse.de> <Pine.LNX.4.64.0705091950080.2909@blonde.wat.veritas.com> <20070510033736.GA19196@wotan.suse.de> <Pine.LNX.4.64.0705101935590.18496@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705101935590.18496@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 10, 2007 at 08:14:52PM +0100, Hugh Dickins wrote:
> On Thu, 10 May 2007, Nick Piggin wrote:
> > 
> > OK, I found a simple bug after pulling out my hair for a while :)
> > With this, a 4-way system survives a couple of concurrent make -j250s
> > quite nicely (wheras they eventually locked up before).
> > 
> > The problem is that the bit wakeup function did not go through with
> > the wakeup if it found the bit (ie. PG_locked) set. This meant that
> > waiters would not get a chance to reset PG_waiters.
> 
> That makes a lot of sense.  And this version seems stable to me,
> I've found no problems so far: magic!
> 
> Well, on the x86_64 I have seen a few of your io_schedule_timeout
> printks under load; but suspect those are no fault of your changes,

Hmm, I see... well I forgot to remove those from the page I sent,
the timeouts will kick things off again if they get stalled, so
maybe it just hides a problem? (OTOH, I *think* the logic is pretty
sound).


> In addition to 3 hours of load on the three machines, I've gone back
> and applied this new patch (and the lock bitops; remembering to shift
> PG_waiters up) to 2.6.21-rc3-mm2 on which I did the earlier lmbench
> testing, on those three machines.
> 
> On the PowerPC G5, these changes pretty much balance out your earlier
> changes (not just the one fix-fault-vs-invalidate patch, but the whole
> group which came in with that - it'd take me a while to tell exactly
> what, easiest to send you a diff if you want it), in those lmbench
> fork, exec, sh, mmap, fault tests.  On the P4 Xeons, they improve
> the numbers significantly, but only retrieve half the regression.
> 
> So here it looks like a good change; but not enough to atone ;)

Don't worry, I'm only just beginning ;) Can we then do something crazy
like this?  (working on x86-64 only, so far. It seems to eliminate
lat_pagefault and lat_proc regressions here).

What architecture and workloads are you testing with, btw?

--

Put PG_locked in its own byte from other PG_bits, so we can use non-atomic
stores to unlock it.

Index: linux-2.6/include/asm-x86_64/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-x86_64/bitops.h
+++ linux-2.6/include/asm-x86_64/bitops.h
@@ -68,6 +68,38 @@ static __inline__ void clear_bit(int nr,
 		:"dIr" (nr));
 }
 
+/**
+ * clear_bit_unlock - Clears a bit in memory with unlock semantics
+ * @nr: Bit to clear
+ * @addr: Address to start counting from
+ */
+static __inline__ void clear_bit_unlock(int nr, volatile void * addr)
+{
+	barrier();
+	__asm__ __volatile__( LOCK_PREFIX
+		"btrl %1,%0"
+		:ADDR
+		:"dIr" (nr));
+}
+
+/**
+ * __clear_bit_unlock_byte - same as clear_bit_unlock but uses a byte sized
+ *			     non-atomic store
+ * @nr: Bit to clear
+ * @addr: Address to start counting from
+ *
+ * __clear_bit_unlock() is non-atomic, however it implements unlock ordering,
+ * so it cannot be reordered arbitrarily.
+ */
+static __inline__ void __clear_bit_unlock_byte(int nr, void *addr)
+{
+        unsigned char mask = 1UL << (nr % BITS_PER_BYTE);
+        unsigned char *p = addr + nr / BITS_PER_BYTE;
+
+        barrier();
+        *p &= ~mask;
+}
+
 static __inline__ void __clear_bit(int nr, volatile void * addr)
 {
 	__asm__ __volatile__(
@@ -132,6 +164,26 @@ static __inline__ int test_and_set_bit(i
 	return oldbit;
 }
 
+
+/**
+ * test_and_set_bit_lock - Set a bit and return its old value for locking
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is atomic and has lock barrier semantics.
+ */
+static __inline__ int test_and_set_bit_lock(int nr, volatile void * addr)
+{
+	int oldbit;
+
+	__asm__ __volatile__( LOCK_PREFIX
+		"btsl %2,%1\n\tsbbl %0,%0"
+		:"=r" (oldbit),ADDR
+		:"dIr" (nr));
+	barrier();
+	return oldbit;
+}
+
 /**
  * __test_and_set_bit - Set a bit and return its old value
  * @nr: Bit to set
@@ -408,7 +460,6 @@ static __inline__ int fls(int x)
 #define ARCH_HAS_FAST_MULTIPLIER 1
 
 #include <asm-generic/bitops/hweight.h>
-#include <asm-generic/bitops/lock.h>
 
 #endif /* __KERNEL__ */
 
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h
+++ linux-2.6/include/linux/mmzone.h
@@ -615,13 +615,13 @@ extern struct zone *next_zone(struct zon
  * with 32 bit page->flags field, we reserve 9 bits for node/zone info.
  * there are 4 zones (3 bits) and this leaves 9-3=6 bits for nodes.
  */
-#define FLAGS_RESERVED		9
+#define FLAGS_RESERVED		7
 
 #elif BITS_PER_LONG == 64
 /*
  * with 64 bit flags field, there's plenty of room.
  */
-#define FLAGS_RESERVED		32
+#define FLAGS_RESERVED		31
 
 #else
 
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -67,7 +67,6 @@
  * FLAGS_RESERVED which defines the width of the fields section
  * (see linux/mmzone.h).  New flags must _not_ overlap with this area.
  */
-#define PG_locked	 	 0	/* Page is locked. Don't touch. */
 #define PG_error		 1
 #define PG_referenced		 2
 #define PG_uptodate		 3
@@ -104,6 +103,14 @@
  *         63                            32                              0
  */
 #define PG_uncached		31	/* Page has been mapped as uncached */
+
+/*
+ * PG_locked sits in a different byte to the rest of the flags. This allows
+ * optimised implementations to use a non-atomic store to unlock.
+ */
+#define PG_locked		32
+#else
+#define PG_locked		24
 #endif
 
 /*
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -187,7 +187,11 @@ static inline void lock_page_nosync(stru
 static inline void unlock_page(struct page *page)
 {
 	VM_BUG_ON(!PageLocked(page));
-	clear_bit_unlock(PG_locked, &page->flags);
+	/*
+	 * PG_locked sits in its own byte in page->flags, away from normal
+	 * flags, so we can do a non-atomic unlock here
+	 */
+	__clear_bit_unlock_byte(PG_locked, &page->flags);
 	if (unlikely(PageWaiters(page)))
 		__unlock_page(page);
 }
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -192,17 +192,17 @@ static void bad_page(struct page *page)
 		(unsigned long)page->flags, page->mapping,
 		page_mapcount(page), page_count(page));
 	dump_stack();
-	page->flags &= ~(1 << PG_lru	|
-			1 << PG_private |
-			1 << PG_locked	|
-			1 << PG_active	|
-			1 << PG_dirty	|
-			1 << PG_reclaim |
-			1 << PG_slab    |
-			1 << PG_swapcache |
-			1 << PG_writeback |
-			1 << PG_buddy |
-			1 << PG_waiters );
+	page->flags &= ~(1UL << PG_lru	 |
+			1UL << PG_private|
+			1UL << PG_locked |
+			1UL << PG_active |
+			1UL << PG_dirty	 |
+			1UL << PG_reclaim|
+			1UL << PG_slab	 |
+			1UL << PG_swapcache|
+			1UL << PG_writeback|
+			1UL << PG_buddy	 |
+			1UL << PG_waiters );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -427,19 +427,19 @@ static inline void __free_one_page(struc
 static inline int free_pages_check(struct page *page)
 {
 	if (unlikely(page_mapcount(page) |
-		(page->mapping != NULL)  |
-		(page_count(page) != 0)  |
+		(page->mapping != NULL)	 |
+		(page_count(page) != 0)	 |
 		(page->flags & (
-			1 << PG_lru	|
-			1 << PG_private |
-			1 << PG_locked	|
-			1 << PG_active	|
-			1 << PG_slab	|
-			1 << PG_swapcache |
-			1 << PG_writeback |
-			1 << PG_reserved |
-			1 << PG_buddy |
-			1 << PG_waiters ))))
+			1UL << PG_lru	 |
+			1UL << PG_private|
+			1UL << PG_locked |
+			1UL << PG_active |
+			1UL << PG_slab	 |
+			1UL << PG_swapcache|
+			1UL << PG_writeback|
+			1UL << PG_reserved|
+			1UL << PG_buddy	 |
+			1UL << PG_waiters ))))
 		bad_page(page);
 	/*
 	 * PageReclaim == PageTail. It is only an error
@@ -582,21 +582,21 @@ static inline void expand(struct zone *z
 static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
 	if (unlikely(page_mapcount(page) |
-		(page->mapping != NULL)  |
-		(page_count(page) != 0)  |
+		(page->mapping != NULL)	 |
+		(page_count(page) != 0)	 |
 		(page->flags & (
-			1 << PG_lru	|
-			1 << PG_private	|
-			1 << PG_locked	|
-			1 << PG_active	|
-			1 << PG_dirty	|
-			1 << PG_reclaim	|
-			1 << PG_slab    |
-			1 << PG_swapcache |
-			1 << PG_writeback |
-			1 << PG_reserved |
-			1 << PG_buddy |
-			1 << PG_waiters ))))
+			1UL << PG_lru	 |
+			1UL << PG_private|
+			1UL << PG_locked |
+			1UL << PG_active |
+			1UL << PG_dirty	 |
+			1UL << PG_reclaim|
+			1UL << PG_slab	 |
+			1UL << PG_swapcache|
+			1UL << PG_writeback|
+			1UL << PG_reserved|
+			1UL << PG_buddy	 |
+			1UL << PG_waiters ))))
 		bad_page(page);
 
 	/*
@@ -606,9 +606,9 @@ static int prep_new_page(struct page *pa
 	if (PageReserved(page))
 		return 1;
 
-	page->flags &= ~(1 << PG_uptodate | 1 << PG_error |
-			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
+	page->flags &= ~(1UL << PG_uptodate | 1UL << PG_error |
+			1UL << PG_referenced | 1UL << PG_arch_1 |
+			1UL << PG_owner_priv_1 | 1UL << PG_mappedtodisk);
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
