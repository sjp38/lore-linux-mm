Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5209C6B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 14:35:01 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id f8so6077258wiw.14
        for <linux-mm@kvack.org>; Thu, 29 May 2014 11:34:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n3si3028794wjx.102.2014.05.29.11.34.56
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 11:34:57 -0700 (PDT)
Message-ID: <53877dd1.0350c20a.2dde.ffff99d7SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] hugetlb: restrict hugepage_migration_support() to x86_64 (Re: BUG at mm/memory.c:1489!)
Date: Thu, 29 May 2014 14:34:35 -0400
In-Reply-To: <1401353983.4930.15.camel@concordia>
References: <1401265922.3355.4.camel@concordia> <alpine.LSU.2.11.1405281712310.7156@eggly.anvils> <1401353983.4930.15.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, benh@kernel.crashing.org, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, trinity@vger.kernel.org

On Thu, May 29, 2014 at 06:59:43PM +1000, Michael Ellerman wrote:
> On Wed, 2014-05-28 at 17:33 -0700, Hugh Dickins wrote:
> > On Wed, 28 May 2014, Michael Ellerman wrote:
> > > Linux Blade312-5 3.15.0-rc7 #306 SMP Wed May 28 17:51:18 EST 2014 ppc64
> > >
> > > [watchdog] 27853 iterations. [F:22642 S:5174 HI:1276]
> > > ------------[ cut here ]------------
> > > kernel BUG at /home/michael/mmk-build/flow/mm/memory.c:1489!
> > > cpu 0xc: Vector: 700 (Program Check) at [c000000384eaf960]
> > >     pc: c0000000001ad6f0: .follow_page_mask+0x90/0x650
> > >     lr: c0000000001ad6d8: .follow_page_mask+0x78/0x650
> > >     sp: c000000384eafbe0
> > >    msr: 8000000000029032
> > >   current = 0xc0000003c27e1bc0
> > >   paca    = 0xc000000001dc3000   softe: 0        irq_happened: 0x01
> > >     pid   = 20800, comm = trinity-c12
> > > kernel BUG at /home/michael/mmk-build/flow/mm/memory.c:1489!
> > > enter ? for help
> > > [c000000384eafcc0] c0000000001e5514 .SyS_move_pages+0x524/0x7d0
> > > [c000000384eafe30] c00000000000a1d8 syscall_exit+0x0/0x98
> > > --- Exception: c01 (System Call) at 00003fff795f30a8
> > > SP (3ffff958f290) is in userspace
> > >
> > > I've left it in the debugger, can dig into it a bit more tomorrow
> > > if anyone has any clues.
> >
> > Thanks for leaving it overnight, but this one is quite obvious,
> > so go ahead and reboot whenever suits you.
> >
> > Trinity didn't even need to do anything bizarre to get this: that
> > ordinary path simply didn't get tried on powerpc or ia64 before.
> >
> > Here's a patch which should fix it for you, but I believe leaves
> > a race in common with other architectures.  I must turn away to
> > other things, and hope Naoya-san can fix up the locking separately
> > (or point out why it's already safe).
> >
> > [PATCH] mm: fix move_pages follow_page huge_addr BUG
> >
> > v3.12's e632a938d914 ("mm: migrate: add hugepage migration code to
> > move_pages()") is okay on most arches, but on follow_huge_addr-style
> > arches ia64 and powerpc, it hits my old BUG_ON(flags & FOLL_GET)
> > from v2.6.15 deceb6cd17e6 ("mm: follow_page with inner ptlock").
> >
> > The point of the BUG_ON was that nothing needed FOLL_GET there at
> > the time, and it was not clear that we have sufficient locking to
> > use get_page() safely here on the outside - maybe the page found has
> > already been freed and even reused when follow_huge_addr() returns.
> >
> > I suspect that e632a938d914's use of get_page() after return from
> > follow_huge_pmd() has the same problem: what prevents a racing
> > instance of move_pages() from already migrating away and freeing
> > that page by then?  A reference to the page should be taken while
> > holding suitable lock (huge_pte_lockptr?), to serialize against
> > concurrent migration.
> >
> > But I'm not prepared to rework the hugetlb locking here myself;
> > so for now just supply a patch to copy e632a938d914's get_page()
> > after follow_huge_pmd() to after follow_huge_addr(): removing
> > the BUG_ON(flags & FOLL_GET), but probably leaving a race.
>
> Thanks for the detailed explanation Hugh.
>
> Unfortunately I don't know our mm/hugetlb code well enough to give you a good
> answer. Ben had a quick look at our follow_huge_addr() and thought it looked
> "fishy". He suggested something like what we do in gup_pte_range() with
> page_cache_get_speculative() might be in order.
>
> Applying your patch and running trinity pretty immediately results in the
> following, which looks related (sys_move_pages() again) ?
>
> Unable to handle kernel paging request for data at address 0xf2000f80000000
> Faulting instruction address: 0xc0000000001e29bc
> cpu 0x1b: Vector: 300 (Data Access) at [c0000003c70f76f0]
>     pc: c0000000001e29bc: .remove_migration_pte+0x9c/0x320
>     lr: c0000000001e29b8: .remove_migration_pte+0x98/0x320
>     sp: c0000003c70f7970
>    msr: 8000000000009032
>    dar: f2000f80000000
>  dsisr: 40000000
>   current = 0xc0000003f9045800
>   paca    = 0xc000000001dc6c00   softe: 0        irq_happened: 0x01
>     pid   = 3585, comm = trinity-c27
> enter ? for help
> [c0000003c70f7a20] c0000000001bce88 .rmap_walk+0x328/0x470
> [c0000003c70f7ae0] c0000000001e2904 .remove_migration_ptes+0x44/0x60
> [c0000003c70f7b80] c0000000001e4ce8 .migrate_pages+0x6d8/0xa00
> [c0000003c70f7cc0] c0000000001e55ec .SyS_move_pages+0x5dc/0x7d0
> [c0000003c70f7e30] c00000000000a1d8 syscall_exit+0x0/0x98
> --- Exception: c01 (System Call) at 00003fff7b2b30a8
> SP (3fffe09728a0) is in userspace
> 1b:mon>

Sorry for inconvenience on your testing.

Hugepage migration is enabled for archs which have pmd-level hugepage
(including ppc64,) but not tested except for x86_64.
hugepage_migration_support() controls this so the following patch should
help you avoid the problem, I believe.
Could you try to test with it?

Thanks,
Naoya Horiguchi
---
Date: Thu, 29 May 2014 12:51:37 -0400
Subject: [PATCH] hugetlb: restrict hugepage_migration_support() to x86_64

Curretly hugepage migration is available for all archs which support pmd-level
hugepage, but testing is done only for x86_64 and there're bugs for other archs.
So to avoid breaking such archs, this patch limits the availability strictly to
x86_64 until developers of other archs get interested in enabling this feature.

Reported-by: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # 3.12+
---
 arch/arm/mm/hugetlbpage.c     |  5 -----
 arch/arm64/mm/hugetlbpage.c   |  5 -----
 arch/ia64/mm/hugetlbpage.c    |  5 -----
 arch/metag/mm/hugetlbpage.c   |  5 -----
 arch/mips/mm/hugetlbpage.c    |  5 -----
 arch/powerpc/mm/hugetlbpage.c | 10 ----------
 arch/s390/mm/hugetlbpage.c    |  5 -----
 arch/sh/mm/hugetlbpage.c      |  5 -----
 arch/sparc/mm/hugetlbpage.c   |  5 -----
 arch/tile/mm/hugetlbpage.c    |  5 -----
 arch/x86/Kconfig              |  4 ++++
 arch/x86/mm/hugetlbpage.c     | 10 ----------
 include/linux/hugetlb.h       | 10 ++++++----
 mm/Kconfig                    |  3 +++
 14 files changed, 13 insertions(+), 69 deletions(-)

diff --git a/arch/arm/mm/hugetlbpage.c b/arch/arm/mm/hugetlbpage.c
index 54ee6163c181..66781bf34077 100644
--- a/arch/arm/mm/hugetlbpage.c
+++ b/arch/arm/mm/hugetlbpage.c
@@ -56,8 +56,3 @@ int pmd_huge(pmd_t pmd)
 {
 	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
 }
-
-int pmd_huge_support(void)
-{
-	return 1;
-}
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 5e9aec358306..2fc8258bab2d 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -54,11 +54,6 @@ int pud_huge(pud_t pud)
 	return !(pud_val(pud) & PUD_TABLE_BIT);
 }
 
-int pmd_huge_support(void)
-{
-	return 1;
-}
-
 static __init int setup_hugepagesz(char *opt)
 {
 	unsigned long ps = memparse(opt, &opt);
diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 68232db98baa..76069c18ee42 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -114,11 +114,6 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-int pmd_huge_support(void)
-{
-	return 0;
-}
-
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, int write)
 {
diff --git a/arch/metag/mm/hugetlbpage.c b/arch/metag/mm/hugetlbpage.c
index 042431509b56..3c52fa6d0f8e 100644
--- a/arch/metag/mm/hugetlbpage.c
+++ b/arch/metag/mm/hugetlbpage.c
@@ -110,11 +110,6 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-int pmd_huge_support(void)
-{
-	return 1;
-}
-
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
index 77e0ae036e7c..4ec8ee10d371 100644
--- a/arch/mips/mm/hugetlbpage.c
+++ b/arch/mips/mm/hugetlbpage.c
@@ -84,11 +84,6 @@ int pud_huge(pud_t pud)
 	return (pud_val(pud) & _PAGE_HUGE) != 0;
 }
 
-int pmd_huge_support(void)
-{
-	return 1;
-}
-
 struct page *
 follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd, int write)
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index eb923654ba80..7e70ae968e5f 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -86,11 +86,6 @@ int pgd_huge(pgd_t pgd)
 	 */
 	return ((pgd_val(pgd) & 0x3) != 0x0);
 }
-
-int pmd_huge_support(void)
-{
-	return 1;
-}
 #else
 int pmd_huge(pmd_t pmd)
 {
@@ -106,11 +101,6 @@ int pgd_huge(pgd_t pgd)
 {
 	return 0;
 }
-
-int pmd_huge_support(void)
-{
-	return 0;
-}
 #endif
 
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 0727a55d87d9..0ff66a7e29bb 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -220,11 +220,6 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-int pmd_huge_support(void)
-{
-	return 1;
-}
-
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmdp, int write)
 {
diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
index 0d676a41081e..d7762349ea48 100644
--- a/arch/sh/mm/hugetlbpage.c
+++ b/arch/sh/mm/hugetlbpage.c
@@ -83,11 +83,6 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-int pmd_huge_support(void)
-{
-	return 0;
-}
-
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 9bd9ce80bf77..d329537739c6 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -231,11 +231,6 @@ int pud_huge(pud_t pud)
 	return 0;
 }
 
-int pmd_huge_support(void)
-{
-	return 0;
-}
-
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 0cb3bbaa580c..e514899e1100 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -166,11 +166,6 @@ int pud_huge(pud_t pud)
 	return !!(pud_val(pud) & _PAGE_HUGE_PAGE);
 }
 
-int pmd_huge_support(void)
-{
-	return 1;
-}
-
 struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 			     pmd_t *pmd, int write)
 {
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 25d2c6f7325e..0cf6a7d0a93e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1871,6 +1871,10 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 	def_bool y
 	depends on X86_64 || X86_PAE
 
+config ARCH_ENABLE_HUGEPAGE_MIGRATION
+	def_bool y
+	depends on X86_64 || MIGRATION
+
 menu "Power management and ACPI options"
 
 config ARCH_HIBERNATION_HEADER
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 8c9f647ff9e1..8b977ebf9388 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -58,11 +58,6 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 {
 	return NULL;
 }
-
-int pmd_huge_support(void)
-{
-	return 0;
-}
 #else
 
 struct page *
@@ -80,11 +75,6 @@ int pud_huge(pud_t pud)
 {
 	return !!(pud_val(pud) & _PAGE_PSE);
 }
-
-int pmd_huge_support(void)
-{
-	return 1;
-}
 #endif
 
 #ifdef CONFIG_HUGETLB_PAGE
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 63214868c5b2..61c2e349af64 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -385,15 +385,18 @@ static inline pgoff_t basepage_index(struct page *page)
 
 extern void dissolve_free_huge_pages(unsigned long start_pfn,
 				     unsigned long end_pfn);
-int pmd_huge_support(void);
 /*
- * Currently hugepage migration is enabled only for pmd-based hugepage.
+ * Currently hugepage migration is enabled only for x86_64.
  * This function will be updated when hugepage migration is more widely
  * supported.
  */
 static inline int hugepage_migration_support(struct hstate *h)
 {
-	return pmd_huge_support() && (huge_page_shift(h) == PMD_SHIFT);
+#ifdef CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION
+	return huge_page_shift(h) == PMD_SHIFT;
+#else
+	return 0;
+#endif
 }
 
 static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
@@ -443,7 +446,6 @@ static inline pgoff_t basepage_index(struct page *page)
 	return page->index;
 }
 #define dissolve_free_huge_pages(s, e)	do {} while (0)
-#define pmd_huge_support()	0
 #define hugepage_migration_support(h)	0
 
 static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
diff --git a/mm/Kconfig b/mm/Kconfig
index ebe5880c29d6..1e22701c972b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -264,6 +264,9 @@ config MIGRATION
 	  pages as migration can relocate pages to satisfy a huge page
 	  allocation instead of reclaiming.
 
+config ARCH_ENABLE_HUGEPAGE_MIGRATION
+	boolean
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
