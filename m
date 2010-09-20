Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 666D76B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 05:32:04 -0400 (EDT)
Subject: Re: [PATCH 2/5] mm: stack based kmap_atomic
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <AANLkTikkVZEGS=1_qbwPoG47twdbzrgWa85NEVD3TxMK@mail.gmail.com>
References: <20100918155326.478277313@chello.nl>
	 <20100918155652.684071800@chello.nl>
	 <AANLkTikkVZEGS=1_qbwPoG47twdbzrgWa85NEVD3TxMK@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 20 Sep 2010 11:31:34 +0200
Message-ID: <1284975094.2275.687.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2010-09-19 at 10:01 -0700, Linus Torvalds wrote:
> On Sat, Sep 18, 2010 at 8:53 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> =
wrote:
> >
> >  usr/src/linux-2.6/drivers/gpu/drm/nouveau/nouveau_bios.c | 6832 ------=
---------
> >  29 files changed, 361 insertions(+), 7195 deletions(-)
>=20
> What's that odd 'usr/src/linux-2.6' file that you have and removed?
>=20
> You're using some seriously broken SCM there.

I use quilt, no idea what happened, let me have a peek.

It seems to include a full copy of that file to remove it.. I must have
done something terribly daft to make that happen.

Fixed up version below:

---
Subject: mm: stack based kmap_atomic
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu Oct 08 22:10:26 CEST 2009

Keep the current interface but ignore the KM_type and use a stack
based approach.

The advantage is that we get rid of crappy code like:

	#define __KM_PTE			\
		(in_nmi() ? KM_NMI_PTE : 	\
		 in_irq() ? KM_IRQ_PTE :	\
		 KM_PTE0)

and in general can stop worrying about what context we're in and what
kmap slots might be appropriate for that.

The down-side is that FRV kmap_atomic gets more expensive.

For now we use a CPP trick suggested by Andrew:

  #define kmap_atomic(page, args...) __kmap_atomic(page)

to avoid having to touch all kmap_atomic users in a single patch.

[ not compiled on:
  - nm10300: the arch doesn't actually build with highmem to begin with ]

Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
LKML-Reference: <new-submission>
---
 arch/arm/include/asm/highmem.h         |    6 +-
 arch/arm/mm/highmem.c                  |   23 +++++---
 arch/frv/include/asm/highmem.h         |   25 +--------
 arch/frv/mb93090-mb00/pci-dma.c        |    4 -
 arch/frv/mm/cache-page.c               |    8 +--
 arch/frv/mm/highmem.c                  |   51 +++++++++++++++++++
 arch/mips/include/asm/highmem.h        |   18 ++----
 arch/mips/mm/highmem.c                 |   50 ++++++++++---------
 arch/mn10300/include/asm/highmem.h     |   42 ++++++++++------
 arch/powerpc/include/asm/highmem.h     |    9 +--
 arch/powerpc/mm/highmem.c              |   35 ++++++++-----
 arch/sparc/include/asm/highmem.h       |    4 -
 arch/sparc/mm/highmem.c                |   48 ++++++++++--------
 arch/tile/include/asm/highmem.h        |   10 +--
 arch/tile/mm/highmem.c                 |   85 ++++++++--------------------=
-----
 arch/x86/include/asm/highmem.h         |   11 ++--
 arch/x86/include/asm/iomap.h           |    4 -
 arch/x86/kernel/crash_dump_32.c        |    2=20
 arch/x86/mm/highmem_32.c               |   74 +++++++++++++++-------------
 arch/x86/mm/iomap_32.c                 |   43 ++++++++++------
 drivers/gpu/drm/i915/i915_gem.c        |    9 +--
 drivers/gpu/drm/i915/i915_irq.c        |    5 -
 drivers/gpu/drm/i915/intel_overlay.c   |    5 -
 drivers/gpu/drm/nouveau/nouveau_bios.c |    8 +--
 drivers/gpu/drm/ttm/ttm_bo_util.c      |    8 +--
 include/linux/highmem.h                |   61 +++++++++++++++--------
 include/linux/io-mapping.h             |   14 ++---
 mm/highmem.c                           |   62 +-----------------------
 28 files changed, 361 insertions(+), 363 deletions(-)

Index: linux-2.6/arch/arm/mm/highmem.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/arm/mm/highmem.c
+++ linux-2.6/arch/arm/mm/highmem.c
@@ -36,18 +36,17 @@ void kunmap(struct page *page)
 }
 EXPORT_SYMBOL(kunmap);
=20
-void *kmap_atomic(struct page *page, enum km_type type)
+void *__kmap_atomic(struct page *page)
 {
 	unsigned int idx;
 	unsigned long vaddr;
 	void *kmap;
+	int type;
=20
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
=20
-	debug_kmap_atomic(type);
-
 #ifdef CONFIG_DEBUG_HIGHMEM
 	/*
 	 * There is no cache coherency issue when non VIVT, so force the
@@ -61,6 +60,8 @@ void *kmap_atomic(struct page *page, enu
 	if (kmap)
 		return kmap;
=20
+	type =3D kmap_atomic_idx_push();
+
 	idx =3D type + KM_TYPE_NR * smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -80,14 +81,17 @@ void *kmap_atomic(struct page *page, enu
=20
 	return (void *)vaddr;
 }
-EXPORT_SYMBOL(kmap_atomic);
+EXPORT_SYMBOL(__kmap_atomic);
=20
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void __kunmap_atomic(void *kvaddr)
 {
 	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
-	unsigned int idx =3D type + KM_TYPE_NR * smp_processor_id();
+	int idx, type;
=20
 	if (kvaddr >=3D (void *)FIXADDR_START) {
+		type =3D kmap_atomic_idx_pop();
+		idx =3D type + KM_TYPE_NR * smp_processor_id();
+
 		if (cache_is_vivt())
 			__cpuc_flush_dcache_area((void *)vaddr, PAGE_SIZE);
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -103,15 +107,16 @@ void kunmap_atomic_notypecheck(void *kva
 	}
 	pagefault_enable();
 }
-EXPORT_SYMBOL(kunmap_atomic_notypecheck);
+EXPORT_SYMBOL(__kunmap_atomic);
=20
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
+void *kmap_atomic_pfn(unsigned long pfn)
 {
-	unsigned int idx;
 	unsigned long vaddr;
+	int idx, type;
=20
 	pagefault_disable();
=20
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR * smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
Index: linux-2.6/arch/frv/include/asm/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/frv/include/asm/highmem.h
+++ linux-2.6/arch/frv/include/asm/highmem.h
@@ -112,12 +112,11 @@ extern struct page *kmap_atomic_to_page(
 	(void *) damlr;										  \
 })
=20
-static inline void *kmap_atomic(struct page *page, enum km_type type)
+static inline void *kmap_atomic_primary(struct page *page, enum km_type ty=
pe)
 {
 	unsigned long paddr;
=20
 	pagefault_disable();
-	debug_kmap_atomic(type);
 	paddr =3D page_to_phys(page);
=20
 	switch (type) {
@@ -125,14 +124,6 @@ static inline void *kmap_atomic(struct p
         case 1:		return __kmap_atomic_primary(1, paddr, 3);
         case 2:		return __kmap_atomic_primary(2, paddr, 4);
         case 3:		return __kmap_atomic_primary(3, paddr, 5);
-        case 4:		return __kmap_atomic_primary(4, paddr, 6);
-        case 5:		return __kmap_atomic_primary(5, paddr, 7);
-        case 6:		return __kmap_atomic_primary(6, paddr, 8);
-        case 7:		return __kmap_atomic_primary(7, paddr, 9);
-        case 8:		return __kmap_atomic_primary(8, paddr, 10);
-
-	case 9 ... 9 + NR_TLB_LINES - 1:
-		return __kmap_atomic_secondary(type - 9, paddr);
=20
 	default:
 		BUG();
@@ -152,22 +143,13 @@ do {									\
 	asm volatile("tlbpr %0,gr0,#4,#1" : : "r"(vaddr) : "memory");	\
 } while(0)
=20
-static inline void kunmap_atomic_notypecheck(void *kvaddr, enum km_type ty=
pe)
+static inline void kunmap_atomic_primary(void *kvaddr, enum km_type type)
 {
 	switch (type) {
         case 0:		__kunmap_atomic_primary(0, 2);	break;
         case 1:		__kunmap_atomic_primary(1, 3);	break;
         case 2:		__kunmap_atomic_primary(2, 4);	break;
         case 3:		__kunmap_atomic_primary(3, 5);	break;
-        case 4:		__kunmap_atomic_primary(4, 6);	break;
-        case 5:		__kunmap_atomic_primary(5, 7);	break;
-        case 6:		__kunmap_atomic_primary(6, 8);	break;
-        case 7:		__kunmap_atomic_primary(7, 9);	break;
-        case 8:		__kunmap_atomic_primary(8, 10);	break;
-
-	case 9 ... 9 + NR_TLB_LINES - 1:
-		__kunmap_atomic_secondary(type - 9, kvaddr);
-		break;
=20
 	default:
 		BUG();
@@ -175,6 +157,9 @@ static inline void kunmap_atomic_notypec
 	pagefault_enable();
 }
=20
+void *__kmap_atomic(struct page *page);
+void __kunmap_atomic(void *kvaddr);
+
 #endif /* !__ASSEMBLY__ */
=20
 #endif /* __KERNEL__ */
Index: linux-2.6/arch/mips/mm/highmem.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/mips/mm/highmem.c
+++ linux-2.6/arch/mips/mm/highmem.c
@@ -9,7 +9,7 @@ static pte_t *kmap_pte;
=20
 unsigned long highstart_pfn, highend_pfn;
=20
-void *__kmap(struct page *page)
+void *kmap(struct page *page)
 {
 	void *addr;
=20
@@ -21,16 +21,16 @@ void *__kmap(struct page *page)
=20
 	return addr;
 }
-EXPORT_SYMBOL(__kmap);
+EXPORT_SYMBOL(kmap);
=20
-void __kunmap(struct page *page)
+void kunmap(struct page *page)
 {
 	BUG_ON(in_interrupt());
 	if (!PageHighMem(page))
 		return;
 	kunmap_high(page);
 }
-EXPORT_SYMBOL(__kunmap);
+EXPORT_SYMBOL(kunmap);
=20
 /*
  * kmap_atomic/kunmap_atomic is significantly faster than kmap/kunmap beca=
use
@@ -41,17 +41,17 @@ EXPORT_SYMBOL(__kunmap);
  * kmaps are appropriate for short, tight code paths only.
  */
=20
-void *__kmap_atomic(struct page *page, enum km_type type)
+void *__kmap_atomic(struct page *page)
 {
-	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int idx, type;
=20
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
=20
-	debug_kmap_atomic(type);
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR*smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -64,43 +64,47 @@ void *__kmap_atomic(struct page *page, e
 }
 EXPORT_SYMBOL(__kmap_atomic);
=20
-void __kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void __kunmap_atomic(void *kvaddr)
 {
-#ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx =3D type + KM_TYPE_NR*smp_processor_id();
+	int type;
=20
 	if (vaddr < FIXADDR_START) { // FIXME
 		pagefault_enable();
 		return;
 	}
=20
-	BUG_ON(vaddr !=3D __fix_to_virt(FIX_KMAP_BEGIN + idx));
+	type =3D kmap_atomic_idx_pop();
+#ifdef CONFIG_DEBUG_HIGHMEM
+	{
+		int idx =3D type + KM_TYPE_NR * smp_processor_id();
=20
-	/*
-	 * force other mappings to Oops if they'll try to access
-	 * this pte without first remap it
-	 */
-	pte_clear(&init_mm, vaddr, kmap_pte-idx);
-	local_flush_tlb_one(vaddr);
-#endif
+		BUG_ON(vaddr !=3D __fix_to_virt(FIX_KMAP_BEGIN + idx));
=20
+		/*
+		 * force other mappings to Oops if they'll try to access
+		 * this pte without first remap it
+		 */
+		pte_clear(&init_mm, vaddr, kmap_pte-idx);
+		local_flush_tlb_one(vaddr);
+	}
+#endif
 	pagefault_enable();
 }
-EXPORT_SYMBOL(__kunmap_atomic_notypecheck);
+EXPORT_SYMBOL(__kunmap_atomic);
=20
 /*
  * This is the same as kmap_atomic() but can map memory that doesn't
  * have a struct page associated with it.
  */
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
+void *kmap_atomic_pfn(unsigned long pfn)
 {
-	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int idx, type;
=20
 	pagefault_disable();
=20
-	debug_kmap_atomic(type);
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR*smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	set_pte(kmap_pte-idx, pfn_pte(pfn, PAGE_KERNEL));
@@ -109,7 +113,7 @@ void *kmap_atomic_pfn(unsigned long pfn,
 	return (void*) vaddr;
 }
=20
-struct page *__kmap_atomic_to_page(void *ptr)
+struct page *kmap_atomic_to_page(void *ptr)
 {
 	unsigned long idx, vaddr =3D (unsigned long)ptr;
 	pte_t *pte;
Index: linux-2.6/arch/mn10300/include/asm/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/mn10300/include/asm/highmem.h
+++ linux-2.6/arch/mn10300/include/asm/highmem.h
@@ -70,15 +70,16 @@ static inline void kunmap(struct page *p
  * be used in IRQ contexts, so in some (very limited) cases we need
  * it.
  */
-static inline unsigned long kmap_atomic(struct page *page, enum km_type ty=
pe)
+static inline unsigned long __kmap_atomic(struct page *page)
 {
-	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int idx, type;
=20
+	pagefault_disable();
 	if (page < highmem_start_page)
 		return page_address(page);
=20
-	debug_kmap_atomic(type);
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR * smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #if HIGHMEM_DEBUG
@@ -91,26 +92,35 @@ static inline unsigned long kmap_atomic(
 	return vaddr;
 }
=20
-static inline void kunmap_atomic_notypecheck(unsigned long vaddr, enum km_=
type type)
+static inline void __kunmap_atomic(unsigned long vaddr)
 {
-#if HIGHMEM_DEBUG
-	enum fixed_addresses idx =3D type + KM_TYPE_NR * smp_processor_id();
+	int type;
=20
-	if (vaddr < FIXADDR_START) /* FIXME */
+	if (vaddr < FIXADDR_START) { /* FIXME */
+		pagefault_enable();
 		return;
+	}
=20
-	if (vaddr !=3D __fix_to_virt(FIX_KMAP_BEGIN + idx))
-		BUG();
+	type =3D kmap_atomic_idx_pop();
=20
-	/*
-	 * force other mappings to Oops if they'll try to access
-	 * this pte without first remap it
-	 */
-	pte_clear(kmap_pte - idx);
-	__flush_tlb_one(vaddr);
+#if HIGHMEM_DEBUG
+	{
+		unsigned int idx;
+		idx =3D type + KM_TYPE_NR * smp_processor_id();
+
+		if (vaddr !=3D __fix_to_virt(FIX_KMAP_BEGIN + idx))
+			BUG();
+
+		/*
+		 * force other mappings to Oops if they'll try to access
+		 * this pte without first remap it
+		 */
+		pte_clear(kmap_pte - idx);
+		__flush_tlb_one(vaddr);
+	}
 #endif
+	pagefault_enable();
 }
-
 #endif /* __KERNEL__ */
=20
 #endif /* _ASM_HIGHMEM_H */
Index: linux-2.6/arch/powerpc/mm/highmem.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/powerpc/mm/highmem.c
+++ linux-2.6/arch/powerpc/mm/highmem.c
@@ -29,17 +29,17 @@
  * be used in IRQ contexts, so in some (very limited) cases we need
  * it.
  */
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot=
)
+void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 {
-	unsigned int idx;
 	unsigned long vaddr;
+	int idx, type;
=20
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
=20
-	debug_kmap_atomic(type);
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR*smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 #ifdef CONFIG_DEBUG_HIGHMEM
@@ -52,26 +52,33 @@ void *kmap_atomic_prot(struct page *page
 }
 EXPORT_SYMBOL(kmap_atomic_prot);
=20
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void __kunmap_atomic(void *kvaddr)
 {
-#ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx =3D type + KM_TYPE_NR*smp_processor_id();
+	int type;
=20
 	if (vaddr < __fix_to_virt(FIX_KMAP_END)) {
 		pagefault_enable();
 		return;
 	}
=20
-	BUG_ON(vaddr !=3D __fix_to_virt(FIX_KMAP_BEGIN + idx));
+	type =3D kmap_atomic_idx_pop();
=20
-	/*
-	 * force other mappings to Oops if they'll try to access
-	 * this pte without first remap it
-	 */
-	pte_clear(&init_mm, vaddr, kmap_pte-idx);
-	local_flush_tlb_page(NULL, vaddr);
+#ifdef CONFIG_DEBUG_HIGHMEM
+	{
+		unsigned int idx;
+
+		idx =3D type + KM_TYPE_NR * smp_processor_id();
+		BUG_ON(vaddr !=3D __fix_to_virt(FIX_KMAP_BEGIN + idx));
+
+		/*
+		 * force other mappings to Oops if they'll try to access
+		 * this pte without first remap it
+		 */
+		pte_clear(&init_mm, vaddr, kmap_pte-idx);
+		local_flush_tlb_page(NULL, vaddr);
+	}
 #endif
 	pagefault_enable();
 }
-EXPORT_SYMBOL(kunmap_atomic_notypecheck);
+EXPORT_SYMBOL(__kunmap_atomic);
Index: linux-2.6/arch/sparc/mm/highmem.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sparc/mm/highmem.c
+++ linux-2.6/arch/sparc/mm/highmem.c
@@ -29,17 +29,17 @@
 #include <asm/tlbflush.h>
 #include <asm/fixmap.h>
=20
-void *kmap_atomic(struct page *page, enum km_type type)
+void *__kmap_atomic(struct page *page)
 {
-	unsigned long idx;
 	unsigned long vaddr;
+	long idx, type;
=20
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	pagefault_disable();
 	if (!PageHighMem(page))
 		return page_address(page);
=20
-	debug_kmap_atomic(type);
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR*smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
=20
@@ -63,44 +63,50 @@ void *kmap_atomic(struct page *page, enu
=20
 	return (void*) vaddr;
 }
-EXPORT_SYMBOL(kmap_atomic);
+EXPORT_SYMBOL(__kmap_atomic);
=20
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void __kunmap_atomic(void *kvaddr)
 {
-#ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
-	unsigned long idx =3D type + KM_TYPE_NR*smp_processor_id();
+	int type;
=20
 	if (vaddr < FIXADDR_START) { // FIXME
 		pagefault_enable();
 		return;
 	}
=20
-	BUG_ON(vaddr !=3D __fix_to_virt(FIX_KMAP_BEGIN+idx));
+	type =3D kmap_atomic_idx_pop();
=20
-/* XXX Fix - Anton */
+#ifdef CONFIG_DEBUG_HIGHMEM
+	{
+		unsigned long idx;
+
+		idx =3D type + KM_TYPE_NR * smp_processor_id();
+		BUG_ON(vaddr !=3D __fix_to_virt(FIX_KMAP_BEGIN+idx));
+
+		/* XXX Fix - Anton */
 #if 0
-	__flush_cache_one(vaddr);
+		__flush_cache_one(vaddr);
 #else
-	flush_cache_all();
+		flush_cache_all();
 #endif
=20
-	/*
-	 * force other mappings to Oops if they'll try to access
-	 * this pte without first remap it
-	 */
-	pte_clear(&init_mm, vaddr, kmap_pte-idx);
-/* XXX Fix - Anton */
+		/*
+		 * force other mappings to Oops if they'll try to access
+		 * this pte without first remap it
+		 */
+		pte_clear(&init_mm, vaddr, kmap_pte-idx);
+		/* XXX Fix - Anton */
 #if 0
-	__flush_tlb_one(vaddr);
+		__flush_tlb_one(vaddr);
 #else
-	flush_tlb_all();
+		flush_tlb_all();
 #endif
+	}
 #endif
-
 	pagefault_enable();
 }
-EXPORT_SYMBOL(kunmap_atomic_notypecheck);
+EXPORT_SYMBOL(__kunmap_atomic);
=20
 /* We may be fed a pagetable here by ptep_to_xxx and others. */
 struct page *kmap_atomic_to_page(void *ptr)
Index: linux-2.6/arch/x86/mm/highmem_32.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/x86/mm/highmem_32.c
+++ linux-2.6/arch/x86/mm/highmem_32.c
@@ -9,6 +9,7 @@ void *kmap(struct page *page)
 		return page_address(page);
 	return kmap_high(page);
 }
+EXPORT_SYMBOL(kmap);
=20
 void kunmap(struct page *page)
 {
@@ -18,6 +19,7 @@ void kunmap(struct page *page)
 		return;
 	kunmap_high(page);
 }
+EXPORT_SYMBOL(kunmap);
=20
 /*
  * kmap_atomic/kunmap_atomic is significantly faster than kmap/kunmap beca=
use
@@ -27,10 +29,10 @@ void kunmap(struct page *page)
  * However when holding an atomic kmap it is not legal to sleep, so atomic
  * kmaps are appropriate for short, tight code paths only.
  */
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot=
)
+void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 {
-	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int idx, type;
=20
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
 	pagefault_disable();
@@ -38,8 +40,7 @@ void *kmap_atomic_prot(struct page *page
 	if (!PageHighMem(page))
 		return page_address(page);
=20
-	debug_kmap_atomic(type);
-
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR*smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	BUG_ON(!pte_none(*(kmap_pte-idx)));
@@ -47,44 +48,57 @@ void *kmap_atomic_prot(struct page *page
=20
 	return (void *)vaddr;
 }
+EXPORT_SYMBOL(kmap_atomic_prot);
+
+void *__kmap_atomic(struct page *page)
+{
+	return kmap_atomic_prot(page, kmap_prot);
+}
+EXPORT_SYMBOL(__kmap_atomic);
=20
-void *kmap_atomic(struct page *page, enum km_type type)
+/*
+ * This is the same as kmap_atomic() but can map memory that doesn't
+ * have a struct page associated with it.
+ */
+void *kmap_atomic_pfn(unsigned long pfn)
 {
-	return kmap_atomic_prot(page, type, kmap_prot);
+	return kmap_atomic_prot_pfn(pfn, kmap_prot);
 }
+EXPORT_SYMBOL_GPL(kmap_atomic_pfn);
=20
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void __kunmap_atomic(void *kvaddr)
 {
 	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx =3D type + KM_TYPE_NR*smp_processor_id();
=20
-	/*
-	 * Force other mappings to Oops if they'll try to access this pte
-	 * without first remap it.  Keeping stale mappings around is a bad idea
-	 * also, in case the page changes cacheability attributes or becomes
-	 * a protected page in a hypervisor.
-	 */
-	if (vaddr =3D=3D __fix_to_virt(FIX_KMAP_BEGIN+idx))
+	if (vaddr >=3D __fix_to_virt(FIX_KMAP_END) &&
+	    vaddr <=3D __fix_to_virt(FIX_KMAP_BEGIN)) {
+		int idx, type;
+
+		type =3D kmap_atomic_idx_pop();
+		idx =3D type + KM_TYPE_NR * smp_processor_id();
+
+#ifdef CONFIG_DEBUG_HIGHMEM
+		WARN_ON_ONCE(idx !=3D
+			((vaddr - __fix_to_virt(FIX_KMAP_BEGIN)) >> PAGE_SHIFT));
+#endif
+		/*
+		 * Force other mappings to Oops if they'll try to access this
+		 * pte without first remap it.  Keeping stale mappings around
+		 * is a bad idea also, in case the page changes cacheability
+		 * attributes or becomes a protected page in a hypervisor.
+		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
-	else {
+	}
 #ifdef CONFIG_DEBUG_HIGHMEM
+	else {
 		BUG_ON(vaddr < PAGE_OFFSET);
 		BUG_ON(vaddr >=3D (unsigned long)high_memory);
-#endif
 	}
+#endif
=20
 	pagefault_enable();
 }
-
-/*
- * This is the same as kmap_atomic() but can map memory that doesn't
- * have a struct page associated with it.
- */
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
-{
-	return kmap_atomic_prot_pfn(pfn, type, kmap_prot);
-}
-EXPORT_SYMBOL_GPL(kmap_atomic_pfn); /* temporarily in use by i915 GEM unti=
l vmap */
+EXPORT_SYMBOL(__kunmap_atomic);
=20
 struct page *kmap_atomic_to_page(void *ptr)
 {
@@ -98,12 +112,6 @@ struct page *kmap_atomic_to_page(void *p
 	pte =3D kmap_pte - (idx - FIX_KMAP_BEGIN);
 	return pte_page(*pte);
 }
-
-EXPORT_SYMBOL(kmap);
-EXPORT_SYMBOL(kunmap);
-EXPORT_SYMBOL(kmap_atomic);
-EXPORT_SYMBOL(kunmap_atomic_notypecheck);
-EXPORT_SYMBOL(kmap_atomic_prot);
 EXPORT_SYMBOL(kmap_atomic_to_page);
=20
 void __init set_highmem_pages_init(void)
Index: linux-2.6/include/linux/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/highmem.h
+++ linux-2.6/include/linux/highmem.h
@@ -28,18 +28,6 @@ static inline void invalidate_kernel_vma
=20
 #include <asm/kmap_types.h>
=20
-#ifdef CONFIG_DEBUG_HIGHMEM
-
-void debug_kmap_atomic(enum km_type type);
-
-#else
-
-static inline void debug_kmap_atomic(enum km_type type)
-{
-}
-
-#endif
-
 #ifdef CONFIG_HIGHMEM
 #include <asm/highmem.h>
=20
@@ -49,6 +37,27 @@ extern unsigned long totalhigh_pages;
=20
 void kmap_flush_unused(void);
=20
+DECLARE_PER_CPU(int, __kmap_atomic_idx);
+
+static inline int kmap_atomic_idx_push(void)
+{
+	int idx =3D __get_cpu_var(__kmap_atomic_idx)++;
+#ifdef CONFIG_DEBUG_HIGHMEM
+	WARN_ON_ONCE(in_irq() && !irqs_disabled());
+	BUG_ON(idx > KM_TYPE_NR);
+#endif
+	return idx;
+}
+
+static inline int kmap_atomic_idx_pop(void)
+{
+	int idx =3D --__get_cpu_var(__kmap_atomic_idx);
+#ifdef CONFIG_DEBUG_HIGHMEM
+	BUG_ON(idx < 0);
+#endif
+	return idx;
+}
+
 #else /* CONFIG_HIGHMEM */
=20
 static inline unsigned int nr_free_highpages(void) { return 0; }
@@ -66,19 +75,19 @@ static inline void kunmap(struct page *p
 {
 }
=20
-static inline void *kmap_atomic(struct page *page, enum km_type idx)
+static inline void *__kmap_atomic(struct page *page)
 {
 	pagefault_disable();
 	return page_address(page);
 }
-#define kmap_atomic_prot(page, idx, prot)	kmap_atomic(page, idx)
+#define kmap_atomic_prot(page, prot)	__kmap_atomic(page)
=20
-static inline void kunmap_atomic_notypecheck(void *addr, enum km_type idx)
+static inline void __kunmap_atomic(void *addr)
 {
 	pagefault_enable();
 }
=20
-#define kmap_atomic_pfn(pfn, idx)	kmap_atomic(pfn_to_page(pfn), (idx))
+#define kmap_atomic_pfn(pfn)	kmap_atomic(pfn_to_page(pfn))
 #define kmap_atomic_to_page(ptr)	virt_to_page(ptr)
=20
 #define kmap_flush_unused()	do {} while(0)
@@ -86,12 +95,20 @@ static inline void kunmap_atomic_notypec
=20
 #endif /* CONFIG_HIGHMEM */
=20
-/* Prevent people trying to call kunmap_atomic() as if it were kunmap() */
-/* kunmap_atomic() should get the return value of kmap_atomic, not the pag=
e. */
-#define kunmap_atomic(addr, idx) do { \
-		BUILD_BUG_ON(__same_type((addr), struct page *)); \
-		kunmap_atomic_notypecheck((addr), (idx)); \
-	} while (0)
+/*
+ * Make both: kmap_atomic(page, idx) and kmap_atomic(page) work.
+ */
+#define kmap_atomic(page, args...) __kmap_atomic(page)
+
+/*
+ * Prevent people trying to call kunmap_atomic() as if it were kunmap()
+ * kunmap_atomic() should get the return value of kmap_atomic, not the pag=
e.
+ */
+#define kunmap_atomic(addr, args...) 				\
+do {								\
+	BUILD_BUG_ON(__same_type((addr), struct page *));	\
+	__kunmap_atomic(addr);					\
+} while (0)
=20
 /* when CONFIG_HIGHMEM is not set these will be plain clear/copy_page */
 #ifndef clear_user_highpage
Index: linux-2.6/mm/highmem.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/mm/highmem.c
+++ linux-2.6/mm/highmem.c
@@ -42,6 +42,10 @@
 unsigned long totalhigh_pages __read_mostly;
 EXPORT_SYMBOL(totalhigh_pages);
=20
+
+DEFINE_PER_CPU(int, __kmap_atomic_idx);
+EXPORT_PER_CPU_SYMBOL(__kmap_atomic_idx);
+
 unsigned int nr_free_highpages (void)
 {
 	pg_data_t *pgdat;
@@ -422,61 +426,3 @@ void __init page_address_init(void)
 }
=20
 #endif	/* defined(CONFIG_HIGHMEM) && !defined(WANT_PAGE_VIRTUAL) */
-
-#ifdef CONFIG_DEBUG_HIGHMEM
-
-void debug_kmap_atomic(enum km_type type)
-{
-	static int warn_count =3D 10;
-
-	if (unlikely(warn_count < 0))
-		return;
-
-	if (unlikely(in_interrupt())) {
-		if (in_nmi()) {
-			if (type !=3D KM_NMI && type !=3D KM_NMI_PTE) {
-				WARN_ON(1);
-				warn_count--;
-			}
-		} else if (in_irq()) {
-			if (type !=3D KM_IRQ0 && type !=3D KM_IRQ1 &&
-			    type !=3D KM_BIO_SRC_IRQ && type !=3D KM_BIO_DST_IRQ &&
-			    type !=3D KM_BOUNCE_READ && type !=3D KM_IRQ_PTE) {
-				WARN_ON(1);
-				warn_count--;
-			}
-		} else if (!irqs_disabled()) {	/* softirq */
-			if (type !=3D KM_IRQ0 && type !=3D KM_IRQ1 &&
-			    type !=3D KM_SOFTIRQ0 && type !=3D KM_SOFTIRQ1 &&
-			    type !=3D KM_SKB_SUNRPC_DATA &&
-			    type !=3D KM_SKB_DATA_SOFTIRQ &&
-			    type !=3D KM_BOUNCE_READ) {
-				WARN_ON(1);
-				warn_count--;
-			}
-		}
-	}
-
-	if (type =3D=3D KM_IRQ0 || type =3D=3D KM_IRQ1 || type =3D=3D KM_BOUNCE_R=
EAD ||
-			type =3D=3D KM_BIO_SRC_IRQ || type =3D=3D KM_BIO_DST_IRQ ||
-			type =3D=3D KM_IRQ_PTE || type =3D=3D KM_NMI ||
-			type =3D=3D KM_NMI_PTE ) {
-		if (!irqs_disabled()) {
-			WARN_ON(1);
-			warn_count--;
-		}
-	} else if (type =3D=3D KM_SOFTIRQ0 || type =3D=3D KM_SOFTIRQ1) {
-		if (irq_count() =3D=3D 0 && !irqs_disabled()) {
-			WARN_ON(1);
-			warn_count--;
-		}
-	}
-#ifdef CONFIG_KGDB_KDB
-	if (unlikely(type =3D=3D KM_KDB && atomic_read(&kgdb_active) =3D=3D -1)) =
{
-		WARN_ON(1);
-		warn_count--;
-	}
-#endif /* CONFIG_KGDB_KDB */
-}
-
-#endif
Index: linux-2.6/arch/x86/mm/iomap_32.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/x86/mm/iomap_32.c
+++ linux-2.6/arch/x86/mm/iomap_32.c
@@ -48,21 +48,20 @@ int iomap_create_wc(resource_size_t base
 }
 EXPORT_SYMBOL_GPL(iomap_create_wc);
=20
-void
-iomap_free(resource_size_t base, unsigned long size)
+void iomap_free(resource_size_t base, unsigned long size)
 {
 	io_free_memtype(base, base + size);
 }
 EXPORT_SYMBOL_GPL(iomap_free);
=20
-void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t =
prot)
+void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
-	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int idx, type;
=20
 	pagefault_disable();
=20
-	debug_kmap_atomic(type);
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR * smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	set_pte(kmap_pte - idx, pfn_pte(pfn, prot));
@@ -72,10 +71,10 @@ void *kmap_atomic_prot_pfn(unsigned long
 }
=20
 /*
- * Map 'pfn' using fixed map 'type' and protections 'prot'
+ * Map 'pfn' using protections 'prot'
  */
 void __iomem *
-iomap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot)
+iomap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
 	/*
 	 * For non-PAT systems, promote PAGE_KERNEL_WC to PAGE_KERNEL_UC_MINUS.
@@ -86,24 +85,34 @@ iomap_atomic_prot_pfn(unsigned long pfn,
 	if (!pat_enabled && pgprot_val(prot) =3D=3D pgprot_val(PAGE_KERNEL_WC))
 		prot =3D PAGE_KERNEL_UC_MINUS;
=20
-	return (void __force __iomem *) kmap_atomic_prot_pfn(pfn, type, prot);
+	return (void __force __iomem *) kmap_atomic_prot_pfn(pfn, prot);
 }
 EXPORT_SYMBOL_GPL(iomap_atomic_prot_pfn);
=20
 void
-iounmap_atomic(void __iomem *kvaddr, enum km_type type)
+iounmap_atomic(void __iomem *kvaddr)
 {
 	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx =3D type + KM_TYPE_NR*smp_processor_id();
=20
-	/*
-	 * Force other mappings to Oops if they'll try to access this pte
-	 * without first remap it.  Keeping stale mappings around is a bad idea
-	 * also, in case the page changes cacheability attributes or becomes
-	 * a protected page in a hypervisor.
-	 */
-	if (vaddr =3D=3D __fix_to_virt(FIX_KMAP_BEGIN+idx))
+	if (vaddr >=3D __fix_to_virt(FIX_KMAP_END) &&
+	    vaddr <=3D __fix_to_virt(FIX_KMAP_BEGIN)) {
+		int idx, type;
+
+		type =3D kmap_atomic_idx_pop();
+		idx =3D type + KM_TYPE_NR * smp_processor_id();
+
+#ifdef CONFIG_DEBUG_HIGHMEM
+		WARN_ON_ONCE(idx !=3D
+			((vaddr - __fix_to_virt(FIX_KMAP_BEGIN)) >> PAGE_SHIFT));
+#endif
+		/*
+		 * Force other mappings to Oops if they'll try to access this
+		 * pte without first remap it.  Keeping stale mappings around
+		 * is a bad idea also, in case the page changes cacheability
+		 * attributes or becomes a protected page in a hypervisor.
+		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
+	}
=20
 	pagefault_enable();
 }
Index: linux-2.6/arch/frv/mb93090-mb00/pci-dma.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/frv/mb93090-mb00/pci-dma.c
+++ linux-2.6/arch/frv/mb93090-mb00/pci-dma.c
@@ -61,14 +61,14 @@ int dma_map_sg(struct device *dev, struc
 	dampr2 =3D __get_DAMPR(2);
=20
 	for (i =3D 0; i < nents; i++) {
-		vaddr =3D kmap_atomic(sg_page(&sg[i]), __KM_CACHE);
+		vaddr =3D kmap_atomic_primary(sg_page(&sg[i]), __KM_CACHE);
=20
 		frv_dcache_writeback((unsigned long) vaddr,
 				     (unsigned long) vaddr + PAGE_SIZE);
=20
 	}
=20
-	kunmap_atomic(vaddr, __KM_CACHE);
+	kunmap_atomic_primary(vaddr, __KM_CACHE);
 	if (dampr2) {
 		__set_DAMPR(2, dampr2);
 		__set_IAMPR(2, dampr2);
Index: linux-2.6/arch/frv/mm/cache-page.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/frv/mm/cache-page.c
+++ linux-2.6/arch/frv/mm/cache-page.c
@@ -26,11 +26,11 @@ void flush_dcache_page(struct page *page
=20
 	dampr2 =3D __get_DAMPR(2);
=20
-	vaddr =3D kmap_atomic(page, __KM_CACHE);
+	vaddr =3D kmap_atomic_primary(page, __KM_CACHE);
=20
 	frv_dcache_writeback((unsigned long) vaddr, (unsigned long) vaddr + PAGE_=
SIZE);
=20
-	kunmap_atomic(vaddr, __KM_CACHE);
+	kunmap_atomic_primary(vaddr, __KM_CACHE);
=20
 	if (dampr2) {
 		__set_DAMPR(2, dampr2);
@@ -54,12 +54,12 @@ void flush_icache_user_range(struct vm_a
=20
 	dampr2 =3D __get_DAMPR(2);
=20
-	vaddr =3D kmap_atomic(page, __KM_CACHE);
+	vaddr =3D kmap_atomic_primary(page, __KM_CACHE);
=20
 	start =3D (start & ~PAGE_MASK) | (unsigned long) vaddr;
 	frv_cache_wback_inv(start, start + len);
=20
-	kunmap_atomic(vaddr, __KM_CACHE);
+	kunmap_atomic_primary(vaddr, __KM_CACHE);
=20
 	if (dampr2) {
 		__set_DAMPR(2, dampr2);
Index: linux-2.6/arch/frv/mm/highmem.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/frv/mm/highmem.c
+++ linux-2.6/arch/frv/mm/highmem.c
@@ -36,3 +36,54 @@ struct page *kmap_atomic_to_page(void *p
 {
 	return virt_to_page(ptr);
 }
+
+void *__kmap_atomic(struct page *page)
+{
+	unsigned long paddr;
+	int type;
+
+	pagefault_disable();
+	type =3D kmap_atomic_idx_push();
+	paddr =3D page_to_phys(page);
+
+	switch (type) {
+	/*
+	 * The first 4 primary maps are reserved for architecture code
+	 */
+	case 0:		return __kmap_atomic_primary(4, paddr, 6);
+	case 1:		return __kmap_atomic_primary(5, paddr, 7);
+	case 2:		return __kmap_atomic_primary(6, paddr, 8);
+	case 3:		return __kmap_atomic_primary(7, paddr, 9);
+	case 4:		return __kmap_atomic_primary(8, paddr, 10);
+
+	case 5 ... 5 + NR_TLB_LINES - 1:
+		return __kmap_atomic_secondary(type - 5, paddr);
+
+	default:
+		BUG();
+		return NULL;
+	}
+}
+EXPORT_SYMBOL(__kmap_atomic);
+
+void __kunmap_atomic(void *kvaddr)
+{
+	int type =3D kmap_atomic_idx_pop();
+	switch (type) {
+	case 0:		__kunmap_atomic_primary(4, 6);	break;
+	case 1:		__kunmap_atomic_primary(5, 7);	break;
+	case 2:		__kunmap_atomic_primary(6, 8);	break;
+	case 3:		__kunmap_atomic_primary(7, 9);	break;
+	case 4:		__kunmap_atomic_primary(8, 10);	break;
+
+	case 5 ... 5 + NR_TLB_LINES - 1:
+		__kunmap_atomic_secondary(type - 5, kvaddr);
+		break;
+
+	default:
+		BUG();
+	}
+	pagefault_enable();
+}
+EXPORT_SYMBOL(__kunmap_atomic);
+
Index: linux-2.6/arch/arm/include/asm/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/arm/include/asm/highmem.h
+++ linux-2.6/arch/arm/include/asm/highmem.h
@@ -35,9 +35,9 @@ extern void kunmap_high_l1_vipt(struct p
 #ifdef CONFIG_HIGHMEM
 extern void *kmap(struct page *page);
 extern void kunmap(struct page *page);
-extern void *kmap_atomic(struct page *page, enum km_type type);
-extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
-extern void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
+extern void *__kmap_atomic(struct page *page);
+extern void __kunmap_atomic(void *kvaddr);
+extern void *kmap_atomic_pfn(unsigned long pfn);
 extern struct page *kmap_atomic_to_page(const void *ptr);
 #endif
=20
Index: linux-2.6/arch/mips/include/asm/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/mips/include/asm/highmem.h
+++ linux-2.6/arch/mips/include/asm/highmem.h
@@ -45,18 +45,12 @@ extern pte_t *pkmap_page_table;
 extern void * kmap_high(struct page *page);
 extern void kunmap_high(struct page *page);
=20
-extern void *__kmap(struct page *page);
-extern void __kunmap(struct page *page);
-extern void *__kmap_atomic(struct page *page, enum km_type type);
-extern void __kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
-extern void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
-extern struct page *__kmap_atomic_to_page(void *ptr);
-
-#define kmap			__kmap
-#define kunmap			__kunmap
-#define kmap_atomic		__kmap_atomic
-#define kunmap_atomic_notypecheck		__kunmap_atomic_notypecheck
-#define kmap_atomic_to_page	__kmap_atomic_to_page
+extern void *kmap(struct page *page);
+extern void kunmap(struct page *page);
+extern void *__kmap_atomic(struct page *page);
+extern void __kunmap_atomic(void *kvaddr);
+extern void *kmap_atomic_pfn(unsigned long pfn);
+extern struct page *kmap_atomic_to_page(void *ptr);
=20
 #define flush_cache_kmaps()	flush_cache_all()
=20
Index: linux-2.6/arch/powerpc/include/asm/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/powerpc/include/asm/highmem.h
+++ linux-2.6/arch/powerpc/include/asm/highmem.h
@@ -60,9 +60,8 @@ extern pte_t *pkmap_page_table;
=20
 extern void *kmap_high(struct page *page);
 extern void kunmap_high(struct page *page);
-extern void *kmap_atomic_prot(struct page *page, enum km_type type,
-			      pgprot_t prot);
-extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
+extern void *kmap_atomic_prot(struct page *page, pgprot_t prot);
+extern void __kunmap_atomic(void *kvaddr);
=20
 static inline void *kmap(struct page *page)
 {
@@ -80,9 +79,9 @@ static inline void kunmap(struct page *p
 	kunmap_high(page);
 }
=20
-static inline void *kmap_atomic(struct page *page, enum km_type type)
+static inline void *__kmap_atomic(struct page *page)
 {
-	return kmap_atomic_prot(page, type, kmap_prot);
+	return kmap_atomic_prot(page, kmap_prot);
 }
=20
 static inline struct page *kmap_atomic_to_page(void *ptr)
Index: linux-2.6/arch/sparc/include/asm/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/sparc/include/asm/highmem.h
+++ linux-2.6/arch/sparc/include/asm/highmem.h
@@ -70,8 +70,8 @@ static inline void kunmap(struct page *p
 	kunmap_high(page);
 }
=20
-extern void *kmap_atomic(struct page *page, enum km_type type);
-extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
+extern void *__kmap_atomic(struct page *page);
+extern void __kunmap_atomic(void *kvaddr);
 extern struct page *kmap_atomic_to_page(void *vaddr);
=20
 #define flush_cache_kmaps()	flush_cache_all()
Index: linux-2.6/arch/tile/include/asm/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/tile/include/asm/highmem.h
+++ linux-2.6/arch/tile/include/asm/highmem.h
@@ -60,12 +60,12 @@ void *kmap_fix_kpte(struct page *page, i
 /* This macro is used only in map_new_virtual() to map "page". */
 #define kmap_prot page_to_kpgprot(page)
=20
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
-void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t =
prot);
+void *__kmap_atomic(struct page *page);
+void __kunmap_atomic(void *kvaddr);
+void *kmap_atomic_pfn(unsigned long pfn);
+void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
 struct page *kmap_atomic_to_page(void *ptr);
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot=
);
-void *kmap_atomic(struct page *page, enum km_type type);
+void *kmap_atomic_prot(struct page *page, pgprot_t prot);
 void kmap_atomic_fix_kpte(struct page *page, int finished);
=20
 #define flush_cache_kmaps()	do { } while (0)
Index: linux-2.6/arch/tile/mm/highmem.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/tile/mm/highmem.c
+++ linux-2.6/arch/tile/mm/highmem.c
@@ -56,50 +56,6 @@ void kunmap(struct page *page)
 }
 EXPORT_SYMBOL(kunmap);
=20
-static void debug_kmap_atomic_prot(enum km_type type)
-{
-#ifdef CONFIG_DEBUG_HIGHMEM
-	static unsigned warn_count =3D 10;
-
-	if (unlikely(warn_count =3D=3D 0))
-		return;
-
-	if (unlikely(in_interrupt())) {
-		if (in_irq()) {
-			if (type !=3D KM_IRQ0 && type !=3D KM_IRQ1 &&
-			    type !=3D KM_BIO_SRC_IRQ &&
-			    /* type !=3D KM_BIO_DST_IRQ && */
-			    type !=3D KM_BOUNCE_READ) {
-				WARN_ON(1);
-				warn_count--;
-			}
-		} else if (!irqs_disabled()) {	/* softirq */
-			if (type !=3D KM_IRQ0 && type !=3D KM_IRQ1 &&
-			    type !=3D KM_SOFTIRQ0 && type !=3D KM_SOFTIRQ1 &&
-			    type !=3D KM_SKB_SUNRPC_DATA &&
-			    type !=3D KM_SKB_DATA_SOFTIRQ &&
-			    type !=3D KM_BOUNCE_READ) {
-				WARN_ON(1);
-				warn_count--;
-			}
-		}
-	}
-
-	if (type =3D=3D KM_IRQ0 || type =3D=3D KM_IRQ1 || type =3D=3D KM_BOUNCE_R=
EAD ||
-	    type =3D=3D KM_BIO_SRC_IRQ /* || type =3D=3D KM_BIO_DST_IRQ */) {
-		if (!irqs_disabled()) {
-			WARN_ON(1);
-			warn_count--;
-		}
-	} else if (type =3D=3D KM_SOFTIRQ0 || type =3D=3D KM_SOFTIRQ1) {
-		if (irq_count() =3D=3D 0 && !irqs_disabled()) {
-			WARN_ON(1);
-			warn_count--;
-		}
-	}
-#endif
-}
-
 /*
  * Describe a single atomic mapping of a page on a given cpu at a
  * given address, and allow it to be linked into a list.
@@ -240,10 +196,10 @@ void kmap_atomic_fix_kpte(struct page *p
  * When holding an atomic kmap is is not legal to sleep, so atomic
  * kmaps are appropriate for short, tight code paths only.
  */
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot=
)
+void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 {
-	enum fixed_addresses idx;
 	unsigned long vaddr;
+	int idx, type;
 	pte_t *pte;
=20
 	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
@@ -255,8 +211,7 @@ void *kmap_atomic_prot(struct page *page
 	if (!PageHighMem(page))
 		return page_address(page);
=20
-	debug_kmap_atomic_prot(type);
-
+	type =3D kmap_atomic_idx_push();
 	idx =3D type + KM_TYPE_NR*smp_processor_id();
 	vaddr =3D __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	pte =3D kmap_get_pte(vaddr);
@@ -269,25 +224,31 @@ void *kmap_atomic_prot(struct page *page
 }
 EXPORT_SYMBOL(kmap_atomic_prot);
=20
-void *kmap_atomic(struct page *page, enum km_type type)
+void *__kmap_atomic(struct page *page)
 {
 	/* PAGE_NONE is a magic value that tells us to check immutability. */
 	return kmap_atomic_prot(page, type, PAGE_NONE);
 }
-EXPORT_SYMBOL(kmap_atomic);
+EXPORT_SYMBOL(__kmap_atomic);
=20
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
+void __kunmap_atomic(void *kvaddr)
 {
 	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
-	enum fixed_addresses idx =3D type + KM_TYPE_NR*smp_processor_id();
=20
-	/*
-	 * Force other mappings to Oops if they try to access this pte without
-	 * first remapping it.  Keeping stale mappings around is a bad idea.
-	 */
-	if (vaddr =3D=3D __fix_to_virt(FIX_KMAP_BEGIN+idx)) {
+	if (vaddr >=3D __fix_to_virt(FIX_KMAP_END) &&
+	    vaddr <=3D __fix_to_virt(FIX_KMAP_BEGIN)) {
 		pte_t *pte =3D kmap_get_pte(vaddr);
 		pte_t pteval =3D *pte;
+		int idx, type;
+
+		type =3D kmap_atomic_idx_pop();
+		idx =3D type + KM_TYPE_NR*smp_processor_id();
+
+		/*
+		 * Force other mappings to Oops if they try to access this pte
+		 * without first remapping it.  Keeping stale mappings around
+		 * is a bad idea.
+		 */
 		BUG_ON(!pte_present(pteval) && !pte_migrating(pteval));
 		kmap_atomic_unregister(pte_page(pteval), vaddr);
 		kpte_clear_flush(pte, vaddr);
@@ -300,19 +261,19 @@ void kunmap_atomic_notypecheck(void *kva
 	arch_flush_lazy_mmu_mode();
 	pagefault_enable();
 }
-EXPORT_SYMBOL(kunmap_atomic_notypecheck);
+EXPORT_SYMBOL(__kunmap_atomic);
=20
 /*
  * This API is supposed to allow us to map memory without a "struct page".
  * Currently we don't support this, though this may change in the future.
  */
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
+void *kmap_atomic_pfn(unsigned long pfn)
 {
-	return kmap_atomic(pfn_to_page(pfn), type);
+	return kmap_atomic(pfn_to_page(pfn));
 }
-void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t =
prot)
+void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 {
-	return kmap_atomic_prot(pfn_to_page(pfn), type, prot);
+	return kmap_atomic_prot(pfn_to_page(pfn), prot);
 }
=20
 struct page *kmap_atomic_to_page(void *ptr)
Index: linux-2.6/arch/x86/include/asm/highmem.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/x86/include/asm/highmem.h
+++ linux-2.6/arch/x86/include/asm/highmem.h
@@ -59,11 +59,12 @@ extern void kunmap_high(struct page *pag
=20
 void *kmap(struct page *page);
 void kunmap(struct page *page);
-void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot=
);
-void *kmap_atomic(struct page *page, enum km_type type);
-void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
-void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
-void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t =
prot);
+
+void *kmap_atomic_prot(struct page *page, pgprot_t prot);
+void *__kmap_atomic(struct page *page);
+void __kunmap_atomic(void *kvaddr);
+void *kmap_atomic_pfn(unsigned long pfn);
+void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
 struct page *kmap_atomic_to_page(void *ptr);
=20
 #define flush_cache_kmaps()	do { } while (0)
Index: linux-2.6/arch/x86/kernel/crash_dump_32.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/x86/kernel/crash_dump_32.c
+++ linux-2.6/arch/x86/kernel/crash_dump_32.c
@@ -61,7 +61,7 @@ ssize_t copy_oldmem_page(unsigned long p
 	if (!is_crashed_pfn_valid(pfn))
 		return -EFAULT;
=20
-	vaddr =3D kmap_atomic_pfn(pfn, KM_PTE0);
+	vaddr =3D kmap_atomic_pfn(pfn);
=20
 	if (!userbuf) {
 		memcpy(buf, (vaddr + offset), csize);
Index: linux-2.6/arch/x86/include/asm/iomap.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/x86/include/asm/iomap.h
+++ linux-2.6/arch/x86/include/asm/iomap.h
@@ -27,10 +27,10 @@
 #include <asm/tlbflush.h>
=20
 void __iomem *
-iomap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot)=
;
+iomap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot);
=20
 void
-iounmap_atomic(void __iomem *kvaddr, enum km_type type);
+iounmap_atomic(void __iomem *kvaddr);
=20
 int
 iomap_create_wc(resource_size_t base, unsigned long size, pgprot_t *prot);
Index: linux-2.6/drivers/gpu/drm/i915/i915_gem.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/gpu/drm/i915/i915_gem.c
+++ linux-2.6/drivers/gpu/drm/i915/i915_gem.c
@@ -508,10 +508,10 @@ fast_user_write(struct io_mapping *mappi
 	char *vaddr_atomic;
 	unsigned long unwritten;
=20
-	vaddr_atomic =3D io_mapping_map_atomic_wc(mapping, page_base, KM_USER0);
+	vaddr_atomic =3D io_mapping_map_atomic_wc(mapping, page_base);
 	unwritten =3D __copy_from_user_inatomic_nocache(vaddr_atomic + page_offse=
t,
 						      user_data, length);
-	io_mapping_unmap_atomic(vaddr_atomic, KM_USER0);
+	io_mapping_unmap_atomic(vaddr_atomic);
 	if (unwritten)
 		return -EFAULT;
 	return 0;
@@ -3331,8 +3331,7 @@ i915_gem_object_pin_and_relocate(struct=20
 		reloc_offset =3D obj_priv->gtt_offset + reloc->offset;
 		reloc_page =3D io_mapping_map_atomic_wc(dev_priv->mm.gtt_mapping,
 						      (reloc_offset &
-						       ~(PAGE_SIZE - 1)),
-						      KM_USER0);
+						       ~(PAGE_SIZE - 1)));
 		reloc_entry =3D (uint32_t __iomem *)(reloc_page +
 						   (reloc_offset & (PAGE_SIZE - 1)));
 		reloc_val =3D target_obj_priv->gtt_offset + reloc->delta;
@@ -3343,7 +3342,7 @@ i915_gem_object_pin_and_relocate(struct=20
 			  readl(reloc_entry), reloc_val);
 #endif
 		writel(reloc_val, reloc_entry);
-		io_mapping_unmap_atomic(reloc_page, KM_USER0);
+		io_mapping_unmap_atomic(reloc_page);
=20
 		/* The updated presumed offset for this entry will be
 		 * copied back out to the user.
Index: linux-2.6/drivers/gpu/drm/i915/i915_irq.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/gpu/drm/i915/i915_irq.c
+++ linux-2.6/drivers/gpu/drm/i915/i915_irq.c
@@ -456,10 +456,9 @@ i915_error_object_create(struct drm_devi
=20
 		local_irq_save(flags);
 		s =3D io_mapping_map_atomic_wc(dev_priv->mm.gtt_mapping,
-					     reloc_offset,
-					     KM_IRQ0);
+					     reloc_offset);
 		memcpy_fromio(d, s, PAGE_SIZE);
-		io_mapping_unmap_atomic(s, KM_IRQ0);
+		io_mapping_unmap_atomic(s);
 		local_irq_restore(flags);
=20
 		dst->pages[page] =3D d;
Index: linux-2.6/drivers/gpu/drm/i915/intel_overlay.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/gpu/drm/i915/intel_overlay.c
+++ linux-2.6/drivers/gpu/drm/i915/intel_overlay.c
@@ -187,8 +187,7 @@ static struct overlay_registers *intel_o
=20
 	if (OVERLAY_NONPHYSICAL(overlay->dev)) {
 		regs =3D io_mapping_map_atomic_wc(dev_priv->mm.gtt_mapping,
-						overlay->reg_bo->gtt_offset,
-						KM_USER0);
+						overlay->reg_bo->gtt_offset);
=20
 		if (!regs) {
 			DRM_ERROR("failed to map overlay regs in GTT\n");
@@ -203,7 +202,7 @@ static struct overlay_registers *intel_o
 static void intel_overlay_unmap_regs_atomic(struct intel_overlay *overlay)
 {
 	if (OVERLAY_NONPHYSICAL(overlay->dev))
-		io_mapping_unmap_atomic(overlay->virt_addr, KM_USER0);
+		io_mapping_unmap_atomic(overlay->virt_addr);
=20
 	overlay->virt_addr =3D NULL;
=20
Index: linux-2.6/drivers/gpu/drm/ttm/ttm_bo_util.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/gpu/drm/ttm/ttm_bo_util.c
+++ linux-2.6/drivers/gpu/drm/ttm/ttm_bo_util.c
@@ -170,7 +170,7 @@ static int ttm_copy_io_ttm_page(struct t
 	src =3D (void *)((unsigned long)src + (page << PAGE_SHIFT));
=20
 #ifdef CONFIG_X86
-	dst =3D kmap_atomic_prot(d, KM_USER0, prot);
+	dst =3D kmap_atomic_prot(d, prot);
 #else
 	if (pgprot_val(prot) !=3D pgprot_val(PAGE_KERNEL))
 		dst =3D vmap(&d, 1, 0, prot);
@@ -183,7 +183,7 @@ static int ttm_copy_io_ttm_page(struct t
 	memcpy_fromio(dst, src, PAGE_SIZE);
=20
 #ifdef CONFIG_X86
-	kunmap_atomic(dst, KM_USER0);
+	kunmap_atomic(dst);
 #else
 	if (pgprot_val(prot) !=3D pgprot_val(PAGE_KERNEL))
 		vunmap(dst);
@@ -206,7 +206,7 @@ static int ttm_copy_ttm_io_page(struct t
=20
 	dst =3D (void *)((unsigned long)dst + (page << PAGE_SHIFT));
 #ifdef CONFIG_X86
-	src =3D kmap_atomic_prot(s, KM_USER0, prot);
+	src =3D kmap_atomic_prot(s, prot);
 #else
 	if (pgprot_val(prot) !=3D pgprot_val(PAGE_KERNEL))
 		src =3D vmap(&s, 1, 0, prot);
@@ -219,7 +219,7 @@ static int ttm_copy_ttm_io_page(struct t
 	memcpy_toio(dst, src, PAGE_SIZE);
=20
 #ifdef CONFIG_X86
-	kunmap_atomic(src, KM_USER0);
+	kunmap_atomic(src);
 #else
 	if (pgprot_val(prot) !=3D pgprot_val(PAGE_KERNEL))
 		vunmap(src);
Index: linux-2.6/include/linux/io-mapping.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/io-mapping.h
+++ linux-2.6/include/linux/io-mapping.h
@@ -81,8 +81,7 @@ io_mapping_free(struct io_mapping *mappi
 /* Atomic map/unmap */
 static inline void __iomem *
 io_mapping_map_atomic_wc(struct io_mapping *mapping,
-			 unsigned long offset,
-			 int slot)
+			 unsigned long offset)
 {
 	resource_size_t phys_addr;
 	unsigned long pfn;
@@ -90,13 +89,13 @@ io_mapping_map_atomic_wc(struct io_mappi
 	BUG_ON(offset >=3D mapping->size);
 	phys_addr =3D mapping->base + offset;
 	pfn =3D (unsigned long) (phys_addr >> PAGE_SHIFT);
-	return iomap_atomic_prot_pfn(pfn, slot, mapping->prot);
+	return iomap_atomic_prot_pfn(pfn, mapping->prot);
 }
=20
 static inline void
-io_mapping_unmap_atomic(void __iomem *vaddr, int slot)
+io_mapping_unmap_atomic(void __iomem *vaddr)
 {
-	iounmap_atomic(vaddr, slot);
+	iounmap_atomic(vaddr);
 }
=20
 static inline void __iomem *
@@ -137,14 +136,13 @@ io_mapping_free(struct io_mapping *mappi
 /* Atomic map/unmap */
 static inline void __iomem *
 io_mapping_map_atomic_wc(struct io_mapping *mapping,
-			 unsigned long offset,
-			 int slot)
+			 unsigned long offset)
 {
 	return ((char __force __iomem *) mapping) + offset;
 }
=20
 static inline void
-io_mapping_unmap_atomic(void __iomem *vaddr, int slot)
+io_mapping_unmap_atomic(void __iomem *vaddr)
 {
 }
=20
Index: linux-2.6/drivers/gpu/drm/nouveau/nouveau_bios.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/gpu/drm/nouveau/nouveau_bios.c
+++ linux-2.6/drivers/gpu/drm/nouveau/nouveau_bios.c
@@ -2167,11 +2167,11 @@ peek_fb(struct drm_device *dev, struct i
=20
 	if (off < pci_resource_len(dev->pdev, 1)) {
 		uint8_t __iomem *p =3D
-			io_mapping_map_atomic_wc(fb, off & PAGE_MASK, KM_USER0);
+			io_mapping_map_atomic_wc(fb, off & PAGE_MASK);
=20
 		val =3D ioread32(p + (off & ~PAGE_MASK));
=20
-		io_mapping_unmap_atomic(p, KM_USER0);
+		io_mapping_unmap_atomic(p);
 	}
=20
 	return val;
@@ -2183,12 +2183,12 @@ poke_fb(struct drm_device *dev, struct i
 {
 	if (off < pci_resource_len(dev->pdev, 1)) {
 		uint8_t __iomem *p =3D
-			io_mapping_map_atomic_wc(fb, off & PAGE_MASK, KM_USER0);
+			io_mapping_map_atomic_wc(fb, off & PAGE_MASK);
=20
 		iowrite32(val, p + (off & ~PAGE_MASK));
 		wmb();
=20
-		io_mapping_unmap_atomic(p, KM_USER0);
+		io_mapping_unmap_atomic(p);
 	}
 }
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
