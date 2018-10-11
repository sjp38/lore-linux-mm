Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD776B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 20:46:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 14-v6so6350113pfk.22
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 17:46:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a62-v6sor16122471pla.29.2018.10.10.17.46.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 17:46:22 -0700 (PDT)
Date: Wed, 10 Oct 2018 17:46:18 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Message-ID: <20181011004618.GA237677@joelaf.mtv.corp.google.com>
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <20181009220222.26nzajhpsbt7syvv@kshutemo-mobl1>
 <20181009230447.GA17911@joelaf.mtv.corp.google.com>
 <20181010100011.6jqjvgeslrvvyhr3@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181010100011.6jqjvgeslrvvyhr3@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@android.com, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Oct 10, 2018 at 01:00:11PM +0300, Kirill A. Shutemov wrote:
> On Tue, Oct 09, 2018 at 04:04:47PM -0700, Joel Fernandes wrote:
> > On Wed, Oct 10, 2018 at 01:02:22AM +0300, Kirill A. Shutemov wrote:
> > > On Tue, Oct 09, 2018 at 01:14:00PM -0700, Joel Fernandes (Google) wrote:
> > > > Android needs to mremap large regions of memory during memory management
> > > > related operations. The mremap system call can be really slow if THP is
> > > > not enabled. The bottleneck is move_page_tables, which is copying each
> > > > pte at a time, and can be really slow across a large map. Turning on THP
> > > > may not be a viable option, and is not for us. This patch speeds up the
> > > > performance for non-THP system by copying at the PMD level when possible.
> > > > 
> > > > The speed up is three orders of magnitude. On a 1GB mremap, the mremap
> > > > completion times drops from 160-250 millesconds to 380-400 microseconds.
> > > > 
> > > > Before:
> > > > Total mremap time for 1GB data: 242321014 nanoseconds.
> > > > Total mremap time for 1GB data: 196842467 nanoseconds.
> > > > Total mremap time for 1GB data: 167051162 nanoseconds.
> > > > 
> > > > After:
> > > > Total mremap time for 1GB data: 385781 nanoseconds.
> > > > Total mremap time for 1GB data: 388959 nanoseconds.
> > > > Total mremap time for 1GB data: 402813 nanoseconds.
> > > > 
> > > > Incase THP is enabled, the optimization is skipped. I also flush the
> > > > tlb every time we do this optimization since I couldn't find a way to
> > > > determine if the low-level PTEs are dirty. It is seen that the cost of
> > > > doing so is not much compared the improvement, on both x86-64 and arm64.
> > > 
> > > Okay. That's interesting.
> > > 
> > > It makes me wounder why do we pass virtual address to pte_alloc() (and
> > > pte_alloc_one() inside).
> > > 
> > > If an arch has real requirement to tight a page table to a virtual address
> > > than the optimization cannot be used as it is. Per-arch should be fine
> > > for this case, I guess.
> > > 
> > > If nobody uses the address we should just drop the argument as a
> > > preparation to the patch.
> > 
> > I couldn't find any use of the address. But I am wondering why you feel
> > passing the address is something that can't be done with the optimization.
> > The pte_alloc only happens if the optimization is not triggered.
> 
> Yes, I now.
> 
> My worry is that some architecture has to allocate page table differently
> depending on virtual address (due to aliasing or something). Original page
> table was allocated for one virtual address and moving the page table to
> different spot in virtual address space may break the invariant.
> 
> > Also the clean up of the argument that you're proposing is a bit out of scope
> > of this patch but yeah we could clean it up in a separate patch if needed. I
> > don't feel too strongly about that. It seems cosmetic and in the future if
> > the address that's passed in is needed, then the architecture can use it.
> 
> Please, do. This should be pretty mechanical change, but it will help to
> make sure that none of obscure architecture will be broken by the change.
> 

The thing is its quite a lot of change, I wrote a coccinelle script to do it
tree wide, following is the diffstat:
 48 files changed, 91 insertions(+), 124 deletions(-)

Imagine then having to add the address argument back in the future in case
its ever needed. Is it really worth doing it? Anyway I confirmed that the
address is NOT used for anything at the moment so your fears of the
optimization doing anything wonky really don't exist at the moment. I really
feel this is unnecessary but I am Ok with others agree the second arg to
pte_alloc should be removed in light of this change. Andrew, what do you
think?

Anyway following are the coccinelle scripts and the resulting diff, the first
script is to remove the second argument (address) from pte_alloc and friends
(there is still some hand removal todo, but those are few). The Second script
actually verifies that the 'address' arg is unused indeed, before the
removal.  And the Third thing I added below is the diff from applying the
first script.

First script : Remove the address argument from pte_alloc and friends:

// Options: --no-includes --include-headers

virtual patch

//////////////// REMOVE ARG FROM FUNC DEFINITON

// Do for pte_alloc
@pte_args1 depends on patch exists@
identifier E1, E2;
type T1, T2;
@@

- pte_alloc(T1 E1, T2 E2)
+ pte_alloc(T1 E1)
{ ... }

// Do same thing for pte_alloc_kernel
@pte_args4 depends on patch exists@
identifier E1, E2;
type T1, T2;
@@

- pte_alloc_kernel(T1 E1, T2 E2)
+ pte_alloc_kernel(T1 E1)
{ ... }

// Do for pte_alloc_one_kernel
@pte_args depends on patch exists@
identifier E1, E2;
type T1, T2;
@@

- pte_alloc_one_kernel(T1 E1, T2 E2)
+ pte_alloc_one_kernel(T1 E1)
{ ... }

// Do same thing for pte_alloc_one
@pte_args6 depends on patch exists@
identifier E1, E2;
type T1, T2;
@@

- pte_alloc_one(T1 E1, T2 E2)
+ pte_alloc_one(T1 E1)
{ ... }


//////////////// REMOVE ARG FROM FUNC DECLARATION
@pte_args12 depends on patch exists@
identifier E1, E2;
type T1, T2, T3;
@@

(
- T3 pte_alloc(T1 E1, T2 E2);
+ T3 pte_alloc(T1 E1);
|
- T3 pte_alloc_kernel(T1 E1, T2 E2);
+ T3 pte_alloc_kernel(T1 E1);
|
- T3 pte_alloc_one_kernel(T1 E1, T2 E2);
+ T3 pte_alloc_one_kernel(T1 E1);
|
- T3 pte_alloc_one(T1 E1, T2 E2);
+ T3 pte_alloc_one(T1 E1);
)

//////////////// REMOVE ARG FROM CALLERS
@pte_args13 depends on patch exists@
expression E1, E2;
@@
(
- pte_alloc(E1, E2)
+ pte_alloc(E1)
|
- pte_alloc_kernel(E1, E2)
+ pte_alloc_kernel(E1)
|
- pte_alloc_one_kernel(E1, E2)
+ pte_alloc_one_kernel(E1)
|
- pte_alloc_one(E1, E2)
+ pte_alloc_one(E1)
)

----------

Second script: Verify that the second argument is indeed unused.
This is just for pte_alloc but I wrote similar scripts for other pte_alloc
variants. Only pte_alloc_one is using the address because its passing it to
pte_alloc_one_kernel. But that function is not using it anymore.

// Options: --include-headers

virtual report

@pte_args depends on report@
identifier E1, E2;
type T1, T2;
position p;
@@

 pte_alloc@p(T1 E1, T2 E2)
 {
<+...
 E2
...+>
 }

@script:python depends on report@
p << pte_args.p;
@@
coccilib.report.print_report(p[0], "WARNING: found definition of pte_alloc with address used in the body")

------------

Diff of applying the first .cocci script:

diff --git a/arch/alpha/include/asm/pgalloc.h b/arch/alpha/include/asm/pgalloc.h
index ab3e3a8638fb..02f9f91bb4f0 100644
--- a/arch/alpha/include/asm/pgalloc.h
+++ b/arch/alpha/include/asm/pgalloc.h
@@ -52,7 +52,7 @@ pmd_free(struct mm_struct *mm, pmd_t *pmd)
 }
 
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	return pte;
@@ -65,9 +65,9 @@ pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 }
 
 static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pte_alloc_one(struct mm_struct *mm)
 {
-	pte_t *pte = pte_alloc_one_kernel(mm, address);
+	pte_t *pte = pte_alloc_one_kernel(mm);
 	struct page *page;
 
 	if (!pte)
diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.h
index 3749234b7419..9c9b5a5ebf2e 100644
--- a/arch/arc/include/asm/pgalloc.h
+++ b/arch/arc/include/asm/pgalloc.h
@@ -90,8 +90,7 @@ static inline int __get_order_pte(void)
 	return get_order(PTRS_PER_PTE * sizeof(pte_t));
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
@@ -102,7 +101,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 }
 
 static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pte_alloc_one(struct mm_struct *mm)
 {
 	pgtable_t pte_pg;
 	struct page *page;
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 2d7344f0e208..17ab72f0cc4e 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -81,7 +81,7 @@ static inline void clean_pte_table(pte_t *pte)
  *  +------------+
  */
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
@@ -93,7 +93,7 @@ pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 }
 
 static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index 2e05bcd944c8..52fa47c73bf0 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -91,13 +91,13 @@ extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgdp);
 
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return (pte_t *)__get_free_page(PGALLOC_GFP);
 }
 
 static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
diff --git a/arch/hexagon/include/asm/pgalloc.h b/arch/hexagon/include/asm/pgalloc.h
index eeebf862c46c..d36183887b60 100644
--- a/arch/hexagon/include/asm/pgalloc.h
+++ b/arch/hexagon/include/asm/pgalloc.h
@@ -59,8 +59,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long) pgd);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long address)
+static inline struct page *pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
@@ -75,8 +74,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 }
 
 /* _kernel variant gets to use a different allocator */
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	gfp_t flags =  GFP_KERNEL | __GFP_ZERO;
 	return (pte_t *) __get_free_page(flags);
diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index 3ee5362f2661..c9e481023c25 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -83,7 +83,7 @@ pmd_populate_kernel(struct mm_struct *mm, pmd_t * pmd_entry, pte_t * pte)
 	pmd_val(*pmd_entry) = __pa(pte);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *page;
 	void *pg;
@@ -99,8 +99,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr)
 	return page;
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long addr)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return quicklist_alloc(0, GFP_KERNEL, NULL);
 }
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 3b85c3ecac38..183b8194ce1f 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -224,7 +224,7 @@ put_kernel_page (struct page *page, unsigned long address, pgprot_t pgprot)
 		pmd = pmd_alloc(&init_mm, pud, address);
 		if (!pmd)
 			goto out;
-		pte = pte_alloc_kernel(pmd, address);
+		pte = pte_alloc_kernel(pmd);
 		if (!pte)
 			goto out;
 		if (!pte_none(*pte))
diff --git a/arch/m68k/include/asm/mcf_pgalloc.h b/arch/m68k/include/asm/mcf_pgalloc.h
index 12fe700632f4..9ac47b4aed41 100644
--- a/arch/m68k/include/asm/mcf_pgalloc.h
+++ b/arch/m68k/include/asm/mcf_pgalloc.h
@@ -12,8 +12,7 @@ extern inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 
 extern const char bad_pmd_string[];
 
-extern inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-	unsigned long address)
+extern inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	unsigned long page = __get_free_page(GFP_DMA);
 
@@ -32,7 +31,7 @@ extern inline pmd_t *pmd_alloc_kernel(pgd_t *pgd, unsigned long address)
 #define pmd_alloc_one_fast(mm, address) ({ BUG(); ((pmd_t *)1); })
 #define pmd_alloc_one(mm, address)      ({ BUG(); ((pmd_t *)2); })
 
-#define pte_alloc_one_fast(mm, addr) pte_alloc_one(mm, addr)
+#define pte_alloc_one_fast(mm, addr) pte_alloc_one(mm)
 
 #define pmd_populate(mm, pmd, page) (pmd_val(*pmd) = \
 	(unsigned long)(page_address(page)))
@@ -50,8 +49,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
 
 #define __pmd_free_tlb(tlb, pmd, address) do { } while (0)
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-	unsigned long address)
+static inline struct page *pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *page = alloc_pages(GFP_DMA, 0);
 	pte_t *pte;
diff --git a/arch/m68k/include/asm/motorola_pgalloc.h b/arch/m68k/include/asm/motorola_pgalloc.h
index 7859a86319cf..d04d9ba9b976 100644
--- a/arch/m68k/include/asm/motorola_pgalloc.h
+++ b/arch/m68k/include/asm/motorola_pgalloc.h
@@ -8,7 +8,7 @@
 extern pmd_t *get_pointer_table(void);
 extern int free_pointer_table(pmd_t *);
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
@@ -28,7 +28,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 	free_page((unsigned long) pte);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *page;
 	pte_t *pte;
diff --git a/arch/m68k/include/asm/sun3_pgalloc.h b/arch/m68k/include/asm/sun3_pgalloc.h
index 11485d38de4e..1456c5eecbd9 100644
--- a/arch/m68k/include/asm/sun3_pgalloc.h
+++ b/arch/m68k/include/asm/sun3_pgalloc.h
@@ -35,8 +35,7 @@ do {							\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	unsigned long page = __get_free_page(GFP_KERNEL);
 
@@ -47,8 +46,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	return (pte_t *) (page);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-					unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
         struct page *page = alloc_pages(GFP_KERNEL, 0);
 
diff --git a/arch/m68k/mm/kmap.c b/arch/m68k/mm/kmap.c
index 40a3b327da07..883d1cdcc34b 100644
--- a/arch/m68k/mm/kmap.c
+++ b/arch/m68k/mm/kmap.c
@@ -208,7 +208,7 @@ void __iomem *__ioremap(unsigned long physaddr, unsigned long size, int cachefla
 			virtaddr += PTRTREESIZE;
 			size -= PTRTREESIZE;
 		} else {
-			pte_dir = pte_alloc_kernel(pmd_dir, virtaddr);
+			pte_dir = pte_alloc_kernel(pmd_dir);
 			if (!pte_dir) {
 				printk("ioremap: no mem for pte_dir\n");
 				return NULL;
diff --git a/arch/m68k/sun3x/dvma.c b/arch/m68k/sun3x/dvma.c
index b2acbc862f60..87935a30d628 100644
--- a/arch/m68k/sun3x/dvma.c
+++ b/arch/m68k/sun3x/dvma.c
@@ -109,7 +109,7 @@ inline int dvma_map_cpu(unsigned long kaddr,
 			pte_t *pte;
 			unsigned long end3;
 
-			if((pte = pte_alloc_kernel(pmd, vaddr)) == NULL) {
+			if((pte = pte_alloc_kernel(pmd)) == NULL) {
 				ret = -ENOMEM;
 				goto out;
 			}
diff --git a/arch/microblaze/include/asm/pgalloc.h b/arch/microblaze/include/asm/pgalloc.h
index 7c89390c0c13..08984b05713f 100644
--- a/arch/microblaze/include/asm/pgalloc.h
+++ b/arch/microblaze/include/asm/pgalloc.h
@@ -108,10 +108,9 @@ static inline void free_pgd_slow(pgd_t *pgd)
 #define pmd_alloc_one_fast(mm, address)	({ BUG(); ((pmd_t *)1); })
 #define pmd_alloc_one(mm, address)	({ BUG(); ((pmd_t *)2); })
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm);
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-		unsigned long address)
+static inline struct page *pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *ptepage;
 
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index 7f525962cdfa..fd9013f2b8ee 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -144,7 +144,7 @@ int map_page(unsigned long va, phys_addr_t pa, int flags)
 	/* Use upper 10 bits of VA to index the first level map */
 	pd = pmd_offset(pgd_offset_k(va), va);
 	/* Use middle 10 bits of VA to index the second-level map */
-	pg = pte_alloc_kernel(pd, va); /* from powerpc - pgtable.c */
+	pg = pte_alloc_kernel(pd); /* from powerpc - pgtable.c */
 	/* pg = pte_alloc_kernel(&init_mm, pd, va); */
 
 	if (pg != NULL) {
@@ -235,8 +235,7 @@ unsigned long iopa(unsigned long addr)
 	return pa;
 }
 
-__ref pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-		unsigned long address)
+__ref pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 	if (mem_init_done) {
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index 39b9f311c4ef..27808d9461f4 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -50,14 +50,12 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-	unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return (pte_t *)__get_free_pages(GFP_KERNEL | __GFP_ZERO, PTE_ORDER);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-	unsigned long address)
+static inline struct page *pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
diff --git a/arch/mips/mm/ioremap.c b/arch/mips/mm/ioremap.c
index 1601d90b087b..18c2be1b69c0 100644
--- a/arch/mips/mm/ioremap.c
+++ b/arch/mips/mm/ioremap.c
@@ -56,7 +56,7 @@ static inline int remap_area_pmd(pmd_t * pmd, unsigned long address,
 	phys_addr -= address;
 	BUG_ON(address >= end);
 	do {
-		pte_t * pte = pte_alloc_kernel(pmd, address);
+		pte_t * pte = pte_alloc_kernel(pmd);
 		if (!pte)
 			return -ENOMEM;
 		remap_area_pte(pte, address, end - address, address + phys_addr, flags);
diff --git a/arch/nds32/include/asm/pgalloc.h b/arch/nds32/include/asm/pgalloc.h
index 27448869131a..3c5fee5b5759 100644
--- a/arch/nds32/include/asm/pgalloc.h
+++ b/arch/nds32/include/asm/pgalloc.h
@@ -22,8 +22,7 @@ extern void pgd_free(struct mm_struct *mm, pgd_t * pgd);
 
 #define check_pgt_cache()		do { } while (0)
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long addr)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
@@ -34,7 +33,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	return pte;
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	pgtable_t pte;
 
diff --git a/arch/nds32/kernel/dma.c b/arch/nds32/kernel/dma.c
index d0dbd4fe9645..17b485ab631a 100644
--- a/arch/nds32/kernel/dma.c
+++ b/arch/nds32/kernel/dma.c
@@ -310,7 +310,7 @@ static int __init consistent_init(void)
 		 * It's not necessary to warn here. */
 		/* WARN_ON(!pmd_none(*pmd)); */
 
-		pte = pte_alloc_kernel(pmd, CONSISTENT_BASE);
+		pte = pte_alloc_kernel(pmd);
 		if (!pte) {
 			ret = -ENOMEM;
 			break;
diff --git a/arch/nios2/include/asm/pgalloc.h b/arch/nios2/include/asm/pgalloc.h
index bb47d08c8ef7..3a149ead1207 100644
--- a/arch/nios2/include/asm/pgalloc.h
+++ b/arch/nios2/include/asm/pgalloc.h
@@ -37,8 +37,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_pages((unsigned long)pgd, PGD_ORDER);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-	unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
@@ -47,8 +46,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	return pte;
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-	unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
diff --git a/arch/nios2/mm/ioremap.c b/arch/nios2/mm/ioremap.c
index 3a28177a01eb..00d1434c2f28 100644
--- a/arch/nios2/mm/ioremap.c
+++ b/arch/nios2/mm/ioremap.c
@@ -61,7 +61,7 @@ static inline int remap_area_pmd(pmd_t *pmd, unsigned long address,
 	if (address >= end)
 		BUG();
 	do {
-		pte_t *pte = pte_alloc_kernel(pmd, address);
+		pte_t *pte = pte_alloc_kernel(pmd);
 
 		if (!pte)
 			return -ENOMEM;
diff --git a/arch/openrisc/include/asm/pgalloc.h b/arch/openrisc/include/asm/pgalloc.h
index 8999b9226512..149c82ee4b8b 100644
--- a/arch/openrisc/include/asm/pgalloc.h
+++ b/arch/openrisc/include/asm/pgalloc.h
@@ -70,10 +70,9 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm);
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-					 unsigned long address)
+static inline struct page *pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 	pte = alloc_pages(GFP_KERNEL, 0);
diff --git a/arch/openrisc/mm/ioremap.c b/arch/openrisc/mm/ioremap.c
index 2175e4bfd9fc..24fb1021c75a 100644
--- a/arch/openrisc/mm/ioremap.c
+++ b/arch/openrisc/mm/ioremap.c
@@ -118,8 +118,7 @@ EXPORT_SYMBOL(iounmap);
  * the memblock infrastructure.
  */
 
-pte_t __ref *pte_alloc_one_kernel(struct mm_struct *mm,
-					 unsigned long address)
+pte_t __ref *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index cf13275f7c6d..d05c678c77c4 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -122,7 +122,7 @@ pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd, pte_t *pte)
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
 static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *page = alloc_page(GFP_KERNEL|__GFP_ZERO);
 	if (!page)
@@ -135,7 +135,7 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 }
 
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_ZERO);
 	return pte;
diff --git a/arch/parisc/kernel/pci-dma.c b/arch/parisc/kernel/pci-dma.c
index 04c48f1ef3fb..d5588c80bda2 100644
--- a/arch/parisc/kernel/pci-dma.c
+++ b/arch/parisc/kernel/pci-dma.c
@@ -113,7 +113,7 @@ static inline int map_pmd_uncached(pmd_t * pmd, unsigned long vaddr,
 	if (end > PGDIR_SIZE)
 		end = PGDIR_SIZE;
 	do {
-		pte_t * pte = pte_alloc_kernel(pmd, vaddr);
+		pte_t * pte = pte_alloc_kernel(pmd);
 		if (!pte)
 			return -ENOMEM;
 		if (map_pte_uncached(pte, orig_vaddr, end - vaddr, paddr_ptr))
diff --git a/arch/powerpc/include/asm/book3s/32/pgalloc.h b/arch/powerpc/include/asm/book3s/32/pgalloc.h
index 82e44b1a00ae..af9e13555d95 100644
--- a/arch/powerpc/include/asm/book3s/32/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/32/pgalloc.h
@@ -82,8 +82,8 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmdp,
 #define pmd_pgtable(pmd) pmd_page(pmd)
 #endif
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
-extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm);
+extern pgtable_t pte_alloc_one(struct mm_struct *mm);
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index 391ed2c3b697..8a33f2044923 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -192,14 +192,12 @@ static inline pgtable_t pmd_pgtable(pmd_t pmd)
 	return (pgtable_t)pmd_page_vaddr(pmd);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return (pte_t *)pte_fragment_alloc(mm, address, 1);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-				      unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	return (pgtable_t)pte_fragment_alloc(mm, address, 0);
 }
diff --git a/arch/powerpc/include/asm/nohash/32/pgalloc.h b/arch/powerpc/include/asm/nohash/32/pgalloc.h
index 8825953c225b..16623f53f0d4 100644
--- a/arch/powerpc/include/asm/nohash/32/pgalloc.h
+++ b/arch/powerpc/include/asm/nohash/32/pgalloc.h
@@ -83,8 +83,8 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmdp,
 #define pmd_pgtable(pmd) pmd_page(pmd)
 #endif
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr);
-extern pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm);
+extern pgtable_t pte_alloc_one(struct mm_struct *mm);
 
 static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
 {
diff --git a/arch/powerpc/include/asm/nohash/64/pgalloc.h b/arch/powerpc/include/asm/nohash/64/pgalloc.h
index e2d62d033708..2e7e0230edf4 100644
--- a/arch/powerpc/include/asm/nohash/64/pgalloc.h
+++ b/arch/powerpc/include/asm/nohash/64/pgalloc.h
@@ -96,14 +96,12 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 }
 
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-				      unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *page;
 	pte_t *pte;
diff --git a/arch/powerpc/mm/pgtable-book3e.c b/arch/powerpc/mm/pgtable-book3e.c
index a2298930f990..c931a3f536ca 100644
--- a/arch/powerpc/mm/pgtable-book3e.c
+++ b/arch/powerpc/mm/pgtable-book3e.c
@@ -86,7 +86,7 @@ int map_kernel_page(unsigned long ea, unsigned long pa, unsigned long flags)
 		pmdp = pmd_alloc(&init_mm, pudp, ea);
 		if (!pmdp)
 			return -ENOMEM;
-		ptep = pte_alloc_kernel(pmdp, ea);
+		ptep = pte_alloc_kernel(pmdp);
 		if (!ptep)
 			return -ENOMEM;
 		set_pte_at(&init_mm, ea, ptep, pfn_pte(pa >> PAGE_SHIFT,
diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
index 692bfc9e372c..49eae44db5b2 100644
--- a/arch/powerpc/mm/pgtable-hash64.c
+++ b/arch/powerpc/mm/pgtable-hash64.c
@@ -158,7 +158,7 @@ int hash__map_kernel_page(unsigned long ea, unsigned long pa, unsigned long flag
 		pmdp = pmd_alloc(&init_mm, pudp, ea);
 		if (!pmdp)
 			return -ENOMEM;
-		ptep = pte_alloc_kernel(pmdp, ea);
+		ptep = pte_alloc_kernel(pmdp);
 		if (!ptep)
 			return -ENOMEM;
 		set_pte_at(&init_mm, ea, ptep, pfn_pte(pa >> PAGE_SHIFT,
diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
index c879979faa73..8002696c338e 100644
--- a/arch/powerpc/mm/pgtable-radix.c
+++ b/arch/powerpc/mm/pgtable-radix.c
@@ -163,7 +163,7 @@ static int __map_kernel_page(unsigned long ea, unsigned long pa,
 		ptep = pmdp_ptep(pmdp);
 		goto set_the_pte;
 	}
-	ptep = pte_alloc_kernel(pmdp, ea);
+	ptep = pte_alloc_kernel(pmdp);
 	if (!ptep)
 		return -ENOMEM;
 
@@ -212,7 +212,7 @@ void radix__change_memory_range(unsigned long start, unsigned long end,
 			ptep = pmdp_ptep(pmdp);
 			goto update_the_pte;
 		}
-		ptep = pte_alloc_kernel(pmdp, idx);
+		ptep = pte_alloc_kernel(pmdp);
 		if (!ptep)
 			continue;
 update_the_pte:
diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
index 120a49bfb9c6..12d5520586cc 100644
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -43,7 +43,7 @@ EXPORT_SYMBOL(ioremap_bot);	/* aka VMALLOC_END */
 
 extern char etext[], _stext[], _sinittext[], _einittext[];
 
-__ref pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+__ref pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
@@ -57,7 +57,7 @@ __ref pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 	return pte;
 }
 
-pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *ptepage;
 
@@ -218,7 +218,7 @@ int map_kernel_page(unsigned long va, phys_addr_t pa, int flags)
 	/* Use upper 10 bits of VA to index the first level map */
 	pd = pmd_offset(pud_offset(pgd_offset_k(va), va), va);
 	/* Use middle 10 bits of VA to index the second-level map */
-	pg = pte_alloc_kernel(pd, va);
+	pg = pte_alloc_kernel(pd);
 	if (pg != 0) {
 		err = 0;
 		/* The PTE should never be already set nor present in the
diff --git a/arch/riscv/include/asm/pgalloc.h b/arch/riscv/include/asm/pgalloc.h
index a79ed5faff3a..94043cf83c90 100644
--- a/arch/riscv/include/asm/pgalloc.h
+++ b/arch/riscv/include/asm/pgalloc.h
@@ -82,15 +82,13 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 
 #endif /* __PAGETABLE_PMD_FOLDED */
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-	unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return (pte_t *)__get_free_page(
 		GFP_KERNEL | __GFP_RETRY_MAYFAIL | __GFP_ZERO);
 }
 
-static inline struct page *pte_alloc_one(struct mm_struct *mm,
-	unsigned long address)
+static inline struct page *pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
index ed053a359ab7..8ad73cb31121 100644
--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -32,14 +32,12 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 /*
  * Allocate and free page tables.
  */
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return quicklist_alloc(QUICK_PT, GFP_KERNEL, NULL);
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-					unsigned long address)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *page;
 	void *pg;
diff --git a/arch/sparc/include/asm/pgalloc_32.h b/arch/sparc/include/asm/pgalloc_32.h
index 90459481c6c7..282be50a4adf 100644
--- a/arch/sparc/include/asm/pgalloc_32.h
+++ b/arch/sparc/include/asm/pgalloc_32.h
@@ -58,10 +58,9 @@ void pmd_populate(struct mm_struct *mm, pmd_t *pmdp, struct page *ptep);
 void pmd_set(pmd_t *pmdp, pte_t *ptep);
 #define pmd_populate_kernel(MM, PMD, PTE) pmd_set(PMD, PTE)
 
-pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address);
+pgtable_t pte_alloc_one(struct mm_struct *mm);
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return srmmu_get_nocache(PTE_SIZE, PTE_SIZE);
 }
diff --git a/arch/sparc/include/asm/pgalloc_64.h b/arch/sparc/include/asm/pgalloc_64.h
index 874632f34f62..48abccba4991 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -60,10 +60,8 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 	kmem_cache_free(pgtable_cache, pmd);
 }
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-			    unsigned long address);
-pgtable_t pte_alloc_one(struct mm_struct *mm,
-			unsigned long address);
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm);
+pgtable_t pte_alloc_one(struct mm_struct *mm);
 void pte_free_kernel(struct mm_struct *mm, pte_t *pte);
 void pte_free(struct mm_struct *mm, pgtable_t ptepage);
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index f396048a0d68..6133f21811e9 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2921,8 +2921,7 @@ void __flush_tlb_all(void)
 			     : : "r" (pstate));
 }
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-			    unsigned long address)
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	struct page *page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 	pte_t *pte = NULL;
@@ -2933,8 +2932,7 @@ pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	return pte;
 }
 
-pgtable_t pte_alloc_one(struct mm_struct *mm,
-			unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 	if (!page)
diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
index be9cb0065179..0c59e690aead 100644
--- a/arch/sparc/mm/srmmu.c
+++ b/arch/sparc/mm/srmmu.c
@@ -364,12 +364,12 @@ pgd_t *get_pgd_fast(void)
  * Alignments up to the page size are the same for physical and virtual
  * addresses of the nocache area.
  */
-pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	unsigned long pte;
 	struct page *page;
 
-	if ((pte = (unsigned long)pte_alloc_one_kernel(mm, address)) == 0)
+	if ((pte = (unsigned long) pte_alloc_one_kernel(mm)) == 0)
 		return NULL;
 	page = pfn_to_page(__nocache_pa(pte) >> PAGE_SHIFT);
 	if (!pgtable_page_ctor(page)) {
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 3c0e470ea646..1f277191fbf3 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -197,7 +197,7 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long) pgd);
 }
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
@@ -205,7 +205,7 @@ pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
 	return pte;
 }
 
-pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
diff --git a/arch/unicore32/include/asm/pgalloc.h b/arch/unicore32/include/asm/pgalloc.h
index f0fdb268f8f2..7cceabecf4e3 100644
--- a/arch/unicore32/include/asm/pgalloc.h
+++ b/arch/unicore32/include/asm/pgalloc.h
@@ -34,7 +34,7 @@ extern void free_pgd_slow(struct mm_struct *mm, pgd_t *pgd);
  * Allocate one PTE table.
  */
 static inline pte_t *
-pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *pte;
 
@@ -46,7 +46,7 @@ pte_alloc_one_kernel(struct mm_struct *mm, unsigned long addr)
 }
 
 static inline pgtable_t
-pte_alloc_one(struct mm_struct *mm, unsigned long addr)
+pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 089e78c4effd..a2eff247377b 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -23,12 +23,12 @@ EXPORT_SYMBOL(physical_mask);
 
 gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	return (pte_t *)__get_free_page(PGALLOC_GFP & ~__GFP_ACCOUNT);
 }
 
-pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
+pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	struct page *pte;
 
diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
index 1065bc8bcae5..b3b388ff2f01 100644
--- a/arch/xtensa/include/asm/pgalloc.h
+++ b/arch/xtensa/include/asm/pgalloc.h
@@ -38,8 +38,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	free_page((unsigned long)pgd);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					 unsigned long address)
+static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
 {
 	pte_t *ptep;
 	int i;
@@ -52,13 +51,12 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 	return ptep;
 }
 
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-					unsigned long addr)
+static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
 {
 	pte_t *pte;
 	struct page *page;
 
-	pte = pte_alloc_one_kernel(mm, addr);
+	pte = pte_alloc_one_kernel(mm);
 	if (!pte)
 		return NULL;
 	page = virt_to_page(pte);
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 517f5853ffed..c0fc9204b4a5 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -65,7 +65,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 	u64 pfn;
 
 	pfn = phys_addr >> PAGE_SHIFT;
-	pte = pte_alloc_kernel(pmd, addr);
+	pte = pte_alloc_kernel(pmd);
 	if (!pte)
 		return -ENOMEM;
 	do {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 00704060b7f7..fd7e8714e5a1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -558,7 +558,7 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
 		return VM_FAULT_FALLBACK;
 	}
 
-	pgtable = pte_alloc_one(vma->vm_mm, haddr);
+	pgtable = pte_alloc_one(vma->vm_mm);
 	if (unlikely(!pgtable)) {
 		ret = VM_FAULT_OOM;
 		goto release;
@@ -683,7 +683,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		struct page *zero_page;
 		bool set;
 		vm_fault_t ret;
-		pgtable = pte_alloc_one(vma->vm_mm, haddr);
+		pgtable = pte_alloc_one(vma->vm_mm);
 		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
 		zero_page = mm_get_huge_zero_page(vma->vm_mm);
@@ -772,7 +772,7 @@ vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 		return VM_FAULT_SIGBUS;
 
 	if (arch_needs_pgtable_deposit()) {
-		pgtable = pte_alloc_one(vma->vm_mm, addr);
+		pgtable = pte_alloc_one(vma->vm_mm);
 		if (!pgtable)
 			return VM_FAULT_OOM;
 	}
@@ -910,7 +910,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (!vma_is_anonymous(vma))
 		return 0;
 
-	pgtable = pte_alloc_one(dst_mm, addr);
+	pgtable = pte_alloc_one(dst_mm);
 	if (unlikely(!pgtable))
 		goto out;
 
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 7a2a2f13f86f..272849cd2007 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -121,7 +121,7 @@ static int __ref zero_pmd_populate(pud_t *pud, unsigned long addr,
 			pte_t *p;
 
 			if (slab_is_available())
-				p = pte_alloc_one_kernel(&init_mm, addr);
+				p = pte_alloc_one_kernel(&init_mm);
 			else
 				p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
 			if (!p)
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..6feb96ae5599 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -650,7 +650,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 {
 	spinlock_t *ptl;
-	pgtable_t new = pte_alloc_one(mm, address);
+	pgtable_t new = pte_alloc_one(mm);
 	if (!new)
 		return -ENOMEM;
 
@@ -683,7 +683,7 @@ int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 
 int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
 {
-	pte_t *new = pte_alloc_one_kernel(&init_mm, address);
+	pte_t *new = pte_alloc_one_kernel(&init_mm);
 	if (!new)
 		return -ENOMEM;
 
@@ -2192,7 +2192,7 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	spinlock_t *uninitialized_var(ptl);
 
 	pte = (mm == &init_mm) ?
-		pte_alloc_kernel(pmd, addr) :
+		pte_alloc_kernel(pmd) :
 		pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
@@ -3365,7 +3365,7 @@ static vm_fault_t do_set_pmd(struct vm_fault *vmf, struct page *page)
 	 * related to pte entry. Use the preallocated table for that.
 	 */
 	if (arch_needs_pgtable_deposit() && !vmf->prealloc_pte) {
-		vmf->prealloc_pte = pte_alloc_one(vma->vm_mm, vmf->address);
+		vmf->prealloc_pte = pte_alloc_one(vma->vm_mm);
 		if (!vmf->prealloc_pte)
 			return VM_FAULT_OOM;
 		smp_wmb(); /* See comment in __pte_alloc() */
@@ -3603,8 +3603,7 @@ static vm_fault_t do_fault_around(struct vm_fault *vmf)
 			start_pgoff + nr_pages - 1);
 
 	if (pmd_none(*vmf->pmd)) {
-		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm_mm,
-						  vmf->address);
+		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm_mm);
 		if (!vmf->prealloc_pte)
 			goto out;
 		smp_wmb(); /* See comment in __pte_alloc() */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a728fc492557..d5115fda9fd2 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -141,7 +141,7 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 	 * callers keep track of where we're up to.
 	 */
 
-	pte = pte_alloc_kernel(pmd, addr);
+	pte = pte_alloc_kernel(pmd);
 	if (!pte)
 		return -ENOMEM;
 	do {
diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index ed162a6c57c5..3f8180414301 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -628,7 +628,7 @@ static int create_hyp_pmd_mappings(pud_t *pud, unsigned long start,
 		BUG_ON(pmd_sect(*pmd));
 
 		if (pmd_none(*pmd)) {
-			pte = pte_alloc_one_kernel(NULL, addr);
+			pte = pte_alloc_one_kernel(NULL);
 			if (!pte) {
 				kvm_err("Cannot allocate Hyp pte\n");
 				return -ENOMEM;
