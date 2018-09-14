Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9758E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:28:36 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w185-v6so9041623oig.19
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 03:28:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l18-v6si1356981ota.193.2018.09.14.03.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 03:28:34 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EANAXJ053977
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:28:34 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mg9pb3htr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:28:33 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 14 Sep 2018 11:28:32 +0100
Date: Fri, 14 Sep 2018 12:28:24 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
In-Reply-To: <20180913123937.GX24124@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
	<20180913092811.894806629@infradead.org>
	<20180913123014.0d9321b8@mschwideX1>
	<20180913105738.GW24124@hirez.programming.kicks-ass.net>
	<20180913141827.1776985e@mschwideX1>
	<20180913123937.GX24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Message-Id: <20180914122824.181d9778@mschwideX1>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, 13 Sep 2018 14:39:37 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Sep 13, 2018 at 02:18:27PM +0200, Martin Schwidefsky wrote:
> > We may get something working with a common code mmu_gather, but I fear =
the
> > day someone makes a "minor" change to that subtly break s390. The debug=
ging of
> > TLB related problems is just horrible.. =20
>=20
> Yes it is, not just on s390 :/
>=20
> And this is not something that's easy to write sanity checks for either
> AFAIK. I mean we can do a few multi-threaded mmap()/mprotect()/munmap()
> proglets and catch faults, but that doesn't even get close to covering
> all the 'fun' spots.
>=20
> Then again, you're more than welcome to the new:
>=20
>   MMU GATHER AND TLB INVALIDATION
>=20
> section in MAINTAINERS.

I spent some time to get s390 converted to the common mmu_gather code.
There is one thing I would like to request, namely the ability to
disable the page gather part of mmu_gather. For my prototype patch
see below, it defines the negative HAVE_RCU_NO_GATHER_PAGES Kconfig
symbol that if defined will remove some parts from common code.
Ugly but good enough for the prototype to convey the idea.
For the final solution we better use a positive Kconfig symbol and
add that to all arch Kconfig files except for s390.

The code itself is less hairy than I feared, it worked on the first
try and survived my fork/munmap/mprotect TLB stress test. But as
this is TLB flushing there probably is some subtle problem left..

Here we go:
--
=46rom f222a7e40427b625700f2ca0919c32f07931c19a Mon Sep 17 00:00:00 2001
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Date: Fri, 14 Sep 2018 10:50:58 +0200
Subject: [PATCH] s390/tlb: convert s390 to generic mmu_gather

Introduce HAVE_RCU_NO_GATHER_PAGES to allow the arch code to disable
page gathering in the generic mmu_gather code, then enable the generic
mmu_gather code for s390.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/Kconfig                |   3 +
 arch/s390/Kconfig           |   3 +
 arch/s390/include/asm/tlb.h | 131 ++++++++++++++--------------------------=
----
 arch/s390/mm/pgalloc.c      |  63 +--------------------
 include/asm-generic/tlb.h   |   7 +++
 mm/mmu_gather.c             |  18 +++++-
 6 files changed, 72 insertions(+), 153 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 053c44703539..9b257929a7c1 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -359,6 +359,9 @@ config HAVE_PERF_USER_STACK_DUMP
 config HAVE_ARCH_JUMP_LABEL
 	bool
=20
+config HAVE_RCU_NO_GATHER_PAGES
+	bool
+
 config HAVE_RCU_TABLE_FREE
 	bool
=20
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 9a9c7a6fe925..521457e3c5e4 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -161,6 +161,9 @@ config S390
 	select HAVE_NOP_MCOUNT
 	select HAVE_OPROFILE
 	select HAVE_PERF_EVENTS
+	select HAVE_RCU_NO_GATHER_PAGES
+	select HAVE_RCU_TABLE_FREE
+	select HAVE_RCU_TABLE_INVALIDATE
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RSEQ
 	select HAVE_SYSCALL_TRACEPOINTS
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index cf3d64313740..8073ff272b2b 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -22,98 +22,40 @@
  * Pages used for the page tables is a different story. FIXME: more
  */
=20
-#include <linux/mm.h>
-#include <linux/pagemap.h>
-#include <linux/swap.h>
-#include <asm/processor.h>
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-
-struct mmu_gather {
-	struct mm_struct *mm;
-	struct mmu_table_batch *batch;
-	unsigned int fullmm;
-	unsigned long start, end;
-};
-
-struct mmu_table_batch {
-	struct rcu_head		rcu;
-	unsigned int		nr;
-	void			*tables[0];
-};
-
-#define MAX_TABLE_BATCH		\
-	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
-
-extern void tlb_table_flush(struct mmu_gather *tlb);
-extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
-
-static inline void
-arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
-{
-	tlb->mm =3D mm;
-	tlb->start =3D start;
-	tlb->end =3D end;
-	tlb->fullmm =3D !(start | (end+1));
-	tlb->batch =3D NULL;
-}
-
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-	__tlb_flush_mm_lazy(tlb->mm);
-}
-
-static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	tlb_table_flush(tlb);
-}
-
+void __tlb_remove_table(void *_table);
+static inline void tlb_flush(struct mmu_gather *tlb);
+static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
+					  struct page *page, int page_size);
=20
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
+#define tlb_start_vma(tlb, vma)			do { } while (0)
+#define tlb_end_vma(tlb, vma)			do { } while (0)
+#define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
=20
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (force) {
-		tlb->start =3D start;
-		tlb->end =3D end;
-	}
+#define tlb_flush tlb_flush
+#define pte_free_tlb pte_free_tlb
+#define pmd_free_tlb pmd_free_tlb
+#define p4d_free_tlb p4d_free_tlb
+#define pud_free_tlb pud_free_tlb
=20
-	tlb_flush_mmu(tlb);
-}
+#include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
+#include <asm-generic/tlb.h>
=20
 /*
  * Release the page cache reference for a pte removed by
  * tlb_ptep_clear_flush. In both flush modes the tlb for a page cache page
  * has already been freed, so just do free_page_and_swap_cache.
  */
-static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *=
page)
-{
-	free_page_and_swap_cache(page);
-	return false; /* avoid calling tlb_flush_mmu */
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *pa=
ge)
-{
-	free_page_and_swap_cache(page);
-}
-
 static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
 					  struct page *page, int page_size)
 {
-	return __tlb_remove_page(tlb, page);
+	free_page_and_swap_cache(page);
+	return false;
 }
=20
-static inline void tlb_remove_page_size(struct mmu_gather *tlb,
-					struct page *page, int page_size)
+static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	return tlb_remove_page(tlb, page);
+	__tlb_flush_mm_lazy(tlb->mm);
 }
=20
 /*
@@ -121,9 +63,18 @@ static inline void tlb_remove_page_size(struct mmu_gath=
er *tlb,
  * page table from the tlb.
  */
 static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
-				unsigned long address)
+                                unsigned long address)
 {
-	page_table_free_rcu(tlb, (unsigned long *) pte, address);
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm =3D 1;
+	tlb->freed_tables =3D 1;
+	tlb->cleared_ptes =3D 1;
+	/*
+	 * page_table_free_rcu takes care of the allocation bit masks
+	 * of the 2K table fragments in the 4K page table page,
+	 * then calls tlb_remove_table.
+	 */
+        page_table_free_rcu(tlb, (unsigned long *) pte, address);
 }
=20
 /*
@@ -139,6 +90,10 @@ static inline void pmd_free_tlb(struct mmu_gather *tlb,=
 pmd_t *pmd,
 	if (tlb->mm->context.asce_limit <=3D _REGION3_SIZE)
 		return;
 	pgtable_pmd_page_dtor(virt_to_page(pmd));
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm =3D 1;
+	tlb->freed_tables =3D 1;
+	tlb->cleared_puds =3D 1;
 	tlb_remove_table(tlb, pmd);
 }
=20
@@ -154,6 +109,10 @@ static inline void p4d_free_tlb(struct mmu_gather *tlb=
, p4d_t *p4d,
 {
 	if (tlb->mm->context.asce_limit <=3D _REGION1_SIZE)
 		return;
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm =3D 1;
+	tlb->freed_tables =3D 1;
+	tlb->cleared_p4ds =3D 1;
 	tlb_remove_table(tlb, p4d);
 }
=20
@@ -169,19 +128,11 @@ static inline void pud_free_tlb(struct mmu_gather *tl=
b, pud_t *pud,
 {
 	if (tlb->mm->context.asce_limit <=3D _REGION2_SIZE)
 		return;
+	tlb->mm->context.flush_mm =3D 1;
+	tlb->freed_tables =3D 1;
+	tlb->cleared_puds =3D 1;
 	tlb_remove_table(tlb, pud);
 }
=20
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
-#define tlb_remove_pmd_tlb_entry(tlb, pmdp, addr)	do { } while (0)
-#define tlb_migrate_finish(mm)			do { } while (0)
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-
-static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned i=
nt page_size)
-{
-}
=20
 #endif /* _S390_TLB_H */
diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
index 76d89ee8b428..f7656a0b3a1a 100644
--- a/arch/s390/mm/pgalloc.c
+++ b/arch/s390/mm/pgalloc.c
@@ -288,7 +288,7 @@ void page_table_free_rcu(struct mmu_gather *tlb, unsign=
ed long *table,
 	tlb_remove_table(tlb, table);
 }
=20
-static void __tlb_remove_table(void *_table)
+void __tlb_remove_table(void *_table)
 {
 	unsigned int mask =3D (unsigned long) _table & 3;
 	void *table =3D (void *)((unsigned long) _table ^ mask);
@@ -314,67 +314,6 @@ static void __tlb_remove_table(void *_table)
 	}
 }
=20
-static void tlb_remove_table_smp_sync(void *arg)
-{
-	/* Simply deliver the interrupt */
-}
-
-static void tlb_remove_table_one(void *table)
-{
-	/*
-	 * This isn't an RCU grace period and hence the page-tables cannot be
-	 * assumed to be actually RCU-freed.
-	 *
-	 * It is however sufficient for software page-table walkers that rely
-	 * on IRQ disabling. See the comment near struct mmu_table_batch.
-	 */
-	smp_call_function(tlb_remove_table_smp_sync, NULL, 1);
-	__tlb_remove_table(table);
-}
-
-static void tlb_remove_table_rcu(struct rcu_head *head)
-{
-	struct mmu_table_batch *batch;
-	int i;
-
-	batch =3D container_of(head, struct mmu_table_batch, rcu);
-
-	for (i =3D 0; i < batch->nr; i++)
-		__tlb_remove_table(batch->tables[i]);
-
-	free_page((unsigned long)batch);
-}
-
-void tlb_table_flush(struct mmu_gather *tlb)
-{
-	struct mmu_table_batch **batch =3D &tlb->batch;
-
-	if (*batch) {
-		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
-		*batch =3D NULL;
-	}
-}
-
-void tlb_remove_table(struct mmu_gather *tlb, void *table)
-{
-	struct mmu_table_batch **batch =3D &tlb->batch;
-
-	tlb->mm->context.flush_mm =3D 1;
-	if (*batch =3D=3D NULL) {
-		*batch =3D (struct mmu_table_batch *)
-			__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
-		if (*batch =3D=3D NULL) {
-			__tlb_flush_mm_lazy(tlb->mm);
-			tlb_remove_table_one(table);
-			return;
-		}
-		(*batch)->nr =3D 0;
-	}
-	(*batch)->tables[(*batch)->nr++] =3D table;
-	if ((*batch)->nr =3D=3D MAX_TABLE_BATCH)
-		tlb_flush_mmu(tlb);
-}
-
 /*
  * Base infrastructure required to generate basic asces, region, segment,
  * and page tables that do not make use of enhanced features like EDAT1.
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 21c751cd751e..930e25abf4de 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -179,6 +179,7 @@ extern void tlb_remove_table(struct mmu_gather *tlb, vo=
id *table);
=20
 #endif
=20
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 /*
  * If we can't allocate a page to make a big batch of page pointers
  * to work on, then just handle a few from the on-stack structure.
@@ -203,6 +204,8 @@ struct mmu_gather_batch {
  */
 #define MAX_GATHER_BATCH_COUNT	(10000UL/MAX_GATHER_BATCH)
=20
+#endif
+
 /*
  * struct mmu_gather is an opaque type used by the mm code for passing aro=
und
  * any data needed by arch specific code for tlb_remove_page.
@@ -249,6 +252,7 @@ struct mmu_gather {
=20
 	unsigned int		batch_count;
=20
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
@@ -256,6 +260,7 @@ struct mmu_gather {
 #ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
 	unsigned int page_size;
 #endif
+#endif
 };
=20
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
@@ -264,8 +269,10 @@ void tlb_flush_mmu(struct mmu_gather *tlb);
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 			 unsigned long start, unsigned long end, bool force);
 void tlb_flush_mmu_free(struct mmu_gather *tlb);
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *pa=
ge,
 				   int page_size);
+#endif
=20
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 				      unsigned long address,
diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index 2d5e617131f6..d3d2763d91b2 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -13,6 +13,8 @@
=20
 #ifdef HAVE_GENERIC_MMU_GATHER
=20
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
+
 static bool tlb_next_batch(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
@@ -41,6 +43,8 @@ static bool tlb_next_batch(struct mmu_gather *tlb)
 	return true;
 }
=20
+#endif
+
 void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 				unsigned long start, unsigned long end)
 {
@@ -49,12 +53,14 @@ void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct=
 mm_struct *mm,
 	/* Is it from 0 to ~0? */
 	tlb->fullmm     =3D !(start | (end+1));
 	tlb->need_flush_all =3D 0;
+
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 	tlb->local.next =3D NULL;
 	tlb->local.nr   =3D 0;
 	tlb->local.max  =3D ARRAY_SIZE(tlb->__pages);
 	tlb->active     =3D &tlb->local;
 	tlb->batch_count =3D 0;
-
+#endif
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch =3D NULL;
 #endif
@@ -67,16 +73,20 @@ void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct=
 mm_struct *mm,
=20
 void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 	struct mmu_gather_batch *batch;
+#endif
=20
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 	for (batch =3D &tlb->local; batch && batch->nr; batch =3D batch->next) {
 		free_pages_and_swap_cache(batch->pages, batch->nr);
 		batch->nr =3D 0;
 	}
 	tlb->active =3D &tlb->local;
+#endif
 }
=20
 void tlb_flush_mmu(struct mmu_gather *tlb)
@@ -92,7 +102,9 @@ void tlb_flush_mmu(struct mmu_gather *tlb)
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 		unsigned long start, unsigned long end, bool force)
 {
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 	struct mmu_gather_batch *batch, *next;
+#endif
=20
 	if (force) {
 		__tlb_reset_range(tlb);
@@ -104,13 +116,16 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
=20
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 	for (batch =3D tlb->local.next; batch; batch =3D next) {
 		next =3D batch->next;
 		free_pages((unsigned long)batch, 0);
 	}
 	tlb->local.next =3D NULL;
+#endif
 }
=20
+#ifndef CONFIG_HAVE_RCU_NO_GATHER_PAGES
 /* __tlb_remove_page
  *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), whi=
le
  *	handling the additional races in SMP caused by other CPUs caching valid
@@ -143,6 +158,7 @@ bool __tlb_remove_page_size(struct mmu_gather *tlb, str=
uct page *page, int page_
=20
 	return false;
 }
+#endif
=20
 #endif /* HAVE_GENERIC_MMU_GATHER */
=20
--=20
2.16.4


--=20
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
