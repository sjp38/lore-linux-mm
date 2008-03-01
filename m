Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by relay2.corp.sgi.com (Postfix) with ESMTP id B21DC30406A
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:16 -0800 (PST)
Received: from clameter by schroedinger.engr.sgi.com with local (Exim 3.36 #1 (Debian))
	id 1JVJ1E-0004ZV-00
	for <linux-mm@kvack.org>; Fri, 29 Feb 2008 20:08:16 -0800
Message-Id: <20080301040816.424249490@sgi.com>
References: <20080301040755.268426038@sgi.com>
Date: Fri, 29 Feb 2008 20:08:05 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [rfc 10/10] Pageflags land grab
Content-Disposition: inline; filename=pageflags_land_grab
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We have enough page flags after vmemmap no longer uses section ids.

Reserve 5 of the 6 saved flags for functionality that is currently
under development in the VM.

The new flags are only available if either of these conditions are met:

1. 64 Bit system. (then we have 8 more free of the 32)

2. !NUMA. In that case 2 bits are needed for the zone
   id which leaves 30 page flag bits. Of those we use 24. 6 left.

3. !SPARSEMEM. In that case we use 5 bits of the 30 available
   for the node. 1 leftover.

4. SPARSEMEM_VMEMMAP. Case 3 applies.

The remaining case is classic sparsemem with NUMA on a 32 bit platform.
In that case we need to use additional bits from the remaining 25 which
does not allow the use of all 5 extended page flags.

We could deal with that case by only allowing sparsemem vmemmap (if
sparsemem is selected as a model) on 32 bit NUMA platforms.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/page-flags.h |   32 +++++++++++++++++++++++++++++---
 mm/Kconfig                 |   11 +++++++++++
 2 files changed, 40 insertions(+), 3 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-02-29 19:33:01.000000000 -0800
+++ linux-2.6/include/linux/page-flags.h	2008-02-29 19:37:31.000000000 -0800
@@ -81,11 +81,24 @@ enum pageflags {
 	PG_reserved,
 	PG_private,		/* If pagecache, has fs-private data */
 	PG_writeback,		/* Page is under writeback */
-	PG_compound,		/* A compound page */
 	PG_swapcache,		/* Swap page: swp_entry_t in private */
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_buddy,		/* Page is free, on buddy lists */
+#ifdef CONFIG_EXTENDED_PAGEFLAGS
+	/*
+	 * Page flags that are only available without sparsemem on 32 bit
+	 * (sparsemem vmemmap is ok. Flags are always available on 64 bit.
+	 */
+	PG_mlock,		/* Page cannot be swapped out */
+	PG_pin,			/* Page cannot be moved in memory */
+	PG_tail,		/* Tail of a compound page */
+	PG_head,		/* Head of a compound page */
+	PG_vcompound,		/* Compound page is virtually mapped */
+	PG_filebacked,		/* Page is backed by an actual disk (not RAM) */
+#else
+	PG_compound,		/* A compound page */
+#endif
 
 #if (BITS_PER_LONG > 32)
 /*
@@ -245,8 +258,20 @@ static inline void set_page_writeback(st
 	test_set_page_writeback(page);
 }
 
-TESTPAGEFLAG(Compound, compound)
-__PAGEFLAG(Head, compound)
+#ifdef CONFIG_EXTENDED_PAGEFLAGS
+__PAGEFLAG(Head, head)
+__PAGEFLAG(Tail, tail)
+__PAGEFLAG(Vcompound, vcompound)
+__PAGEFLAG(Mlock, mlock)
+__PAGEFLAG(Pin, pin)
+__PAGEFLAG(FileBacked, filebacked)
+
+static inline int PageCompound(struct page *page)
+{
+	return (page->flags & ((1 << PG_tail) | (1 << PG_head))) != 0;
+}
+
+#else
 
 /*
  * PG_reclaim is used in combination with PG_compound to mark the
@@ -274,5 +299,6 @@ static inline void __ClearPageTail(struc
 {
 	page->flags &= ~PG_head_tail_mask;
 }
+#endif
 
 #endif	/* PAGE_FLAGS_H */
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2008-02-29 19:13:55.000000000 -0800
+++ linux-2.6/mm/Kconfig	2008-02-29 19:37:31.000000000 -0800
@@ -193,3 +193,14 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+#
+# I wish we could get rid of this...... The main problem is the page
+# flag use on 32 bit system with NUMA and SPARSEMEM (no sparsemem_vmemmap).
+# Does not really make any sense to use sparsemem there since 32 bit spaces
+# will typically be backed by contiguous RAM these days. So there is nothing
+# sparse there anymore.
+#
+config EXTENDED_PAGEFLAGS
+	def_bool y
+	depends on 64BIT || !SPARSEMEM || !NUMA || SPARSEMEM_VMEMMAP

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
