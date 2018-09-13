Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E6B6B8E000C
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 05:29:46 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bh1-v6so2481746plb.15
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 02:29:46 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p9-v6si3880230pgi.553.2018.09.13.02.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 02:29:45 -0700 (PDT)
Message-ID: <20180913092811.894806629@infradead.org>
Date: Thu, 13 Sep 2018 11:21:11 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
References: <20180913092110.817204997@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

Write a comment explaining some of this..

Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/tlb.h |  120 ++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 117 insertions(+), 3 deletions(-)

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -22,6 +22,119 @@
 
 #ifdef CONFIG_MMU
 
+/*
+ * Generic MMU-gather implementation.
+ *
+ * The mmu_gather data structure is used by the mm code to implement the
+ * correct and efficient ordering of freeing pages and TLB invalidations.
+ *
+ * This correct ordering is:
+ *
+ *  1) unhook page
+ *  2) TLB invalidate page
+ *  3) free page
+ *
+ * That is, we must never free a page before we have ensured there are no live
+ * translations left to it. Otherwise it might be possible to observe (or
+ * worse, change) the page content after it has been reused.
+ *
+ * The mmu_gather API consists of:
+ *
+ *  - tlb_gather_mmu() / tlb_finish_mmu(); start and finish a mmu_gather
+ *
+ *    Finish in particular will issue a (final) TLB invalidate and free
+ *    all (remaining) queued pages.
+ *
+ *  - tlb_start_vma() / tlb_end_vma(); marks the start / end of a VMA
+ *
+ *    Defaults to flushing at tlb_end_vma() to reset the range; helps when
+ *    there's large holes between the VMAs.
+ *
+ *  - tlb_remove_page() / __tlb_remove_page()
+ *  - tlb_remove_page_size() / __tlb_remove_page_size()
+ *
+ *    __tlb_remove_page_size() is the basic primitive that queues a page for
+ *    freeing. __tlb_remove_page() assumes PAGE_SIZE. Both will return a
+ *    boolean indicating if the queue is (now) full and a call to
+ *    tlb_flush_mmu() is required.
+ *
+ *    tlb_remove_page() and tlb_remove_page_size() imply the call to
+ *    tlb_flush_mmu() when required and has no return value.
+ *
+ *  - tlb_change_page_size()
+ *
+ *    call before __tlb_remove_page*() to set the current page-size; implies a
+ *    possible tlb_flush_mmu() call.
+ *
+ *  - tlb_flush_mmu() / tlb_flush_mmu_tlbonly() / tlb_flush_mmu_free()
+ *
+ *    tlb_flush_mmu_tlbonly() - does the TLB invalidate (and resets
+ *                              related state, like the range)
+ *
+ *    tlb_flush_mmu_free() - frees the queued pages; make absolutely
+ *			     sure no additional tlb_remove_page()
+ *			     calls happen between _tlbonly() and this.
+ *
+ *    tlb_flush_mmu() - the above two calls.
+ *
+ *  - mmu_gather::fullmm
+ *
+ *    A flag set by tlb_gather_mmu() to indicate we're going to free
+ *    the entire mm; this allows a number of optimizations.
+ *
+ *    XXX list optimizations
+ *
+ *  - mmu_gather::need_flush_all
+ *
+ *    A flag that can be set by the arch code if it wants to force
+ *    flush the entire TLB irrespective of the range. For instance
+ *    x86-PAE needs this when changing top-level entries.
+ *
+ * And requires the architecture to provide and implement tlb_flush().
+ *
+ * tlb_flush() may, in addition to the above mentioned mmu_gather fields, make
+ * use of:
+ *
+ *  - mmu_gather::start / mmu_gather::end
+ *
+ *    which (when !need_flush_all; fullmm will have start = end = ~0UL) provides
+ *    the range that needs to be flushed to cover the pages to be freed.
+ *
+ *  - mmu_gather::freed_tables
+ *
+ *    set when we freed page table pages
+ *
+ *  - tlb_get_unmap_shift() / tlb_get_unmap_size()
+ *
+ *    returns the smallest TLB entry size unmapped in this range
+ *
+ * Additionally there are a few opt-in features:
+ *
+ *  HAVE_MMU_GATHER_PAGE_SIZE
+ *
+ *  This ensures we call tlb_flush() every time tlb_change_page_size() actually
+ *  changes the size and provides mmu_gather::page_size to tlb_flush().
+ *
+ *  HAVE_RCU_TABLE_FREE
+ *
+ *  This provides tlb_remove_table(), to be used instead of tlb_remove_page()
+ *  for page directores (__p*_free_tlb()). This provides separate freeing of
+ *  the page-table pages themselves in a semi-RCU fashion (see comment below).
+ *  Useful if your architecture doesn't use IPIs for remote TLB invalidates
+ *  and therefore doesn't naturally serialize with software page-table walkers.
+ *
+ *  When used, an architecture is expected to provide __tlb_remove_table()
+ *  which does the actual freeing of these pages.
+ *
+ *  HAVE_RCU_TABLE_INVALIDATE
+ *
+ *  This makes HAVE_RCU_TABLE_FREE call tlb_flush_mmu_tlbonly() before freeing
+ *  the page-table pages. Required if you use HAVE_RCU_TABLE_FREE and your
+ *  architecture uses the Linux page-tables natively.
+ *
+ */
+#define HAVE_GENERIC_MMU_GATHER
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 /*
  * Semi RCU freeing of the page directories.
@@ -89,14 +202,17 @@ struct mmu_gather_batch {
  */
 #define MAX_GATHER_BATCH_COUNT	(10000UL/MAX_GATHER_BATCH)
 
-/* struct mmu_gather is an opaque type used by the mm code for passing around
+/*
+ * struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
  */
 struct mmu_gather {
 	struct mm_struct	*mm;
+
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	struct mmu_table_batch	*batch;
 #endif
+
 	unsigned long		start;
 	unsigned long		end;
 	/*
@@ -131,8 +247,6 @@ struct mmu_gather {
 	int page_size;
 };
 
-#define HAVE_GENERIC_MMU_GATHER
-
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
 	struct mm_struct *mm, unsigned long start, unsigned long end);
 void tlb_flush_mmu(struct mmu_gather *tlb);
