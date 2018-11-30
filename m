Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63D0D6B581E
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 07:11:37 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id v79so4289425pfd.20
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:11:37 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c9si5124758pll.439.2018.11.30.04.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 04:11:36 -0800 (PST)
Date: Fri, 30 Nov 2018 15:11:31 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/2] x86/mm: Fix guard hole handling
Message-ID: <20181130121131.g3xvlvixv7mvlr7b@black.fi.intel.com>
References: <20181130115758.4425-1-kirill.shutemov@linux.intel.com>
 <20181130115758.4425-2-kirill.shutemov@linux.intel.com>
 <76b8ca15-405a-055f-41b3-532b116c3a8b@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <76b8ca15-405a-055f-41b3-532b116c3a8b@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, bhe@redhat.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 30, 2018 at 12:03:33PM +0000, Juergen Gross wrote:
> On 30/11/2018 12:57, Kirill A. Shutemov wrote:
> > There is a guard hole at the beginning of kernel address space, also
> > used by hypervisors. It occupies 16 PGD entries.
> > 
> > We do not state the reserved range directly, but calculate it relative
> > to other entities: direct mapping and user space ranges.
> > 
> > The calculation got broken by recent change in kernel memory layout: LDT
> > remap range is now mapped before direct mapping and makes the calculation
> > invalid.
> > 
> > The breakage leads to crash on Xen dom0 boot[1].
> > 
> > State the reserved range directly. It's part of kernel ABI (hypervisors
> > expect it to be stable) and must not depend on changes in the rest of
> > kernel memory layout.
> > 
> > [1] https://lists.xenproject.org/archives/html/xen-devel/2018-11/msg03313.html
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Hans van Kranenburg <Hans.van.Kranenburg@mendix.com>
> > Fixes: d52888aa2753 ("x86/mm: Move LDT remap out of KASLR region on 5-level paging")
> > ---
> >  arch/x86/include/asm/pgtable_64_types.h |  5 +++++
> >  arch/x86/mm/dump_pagetables.c           |  8 ++++----
> >  arch/x86/xen/mmu_pv.c                   | 11 ++++++-----
> >  3 files changed, 15 insertions(+), 9 deletions(-)
> > 
> > diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
> > index 84bd9bdc1987..13aef22cee18 100644
> > --- a/arch/x86/include/asm/pgtable_64_types.h
> > +++ b/arch/x86/include/asm/pgtable_64_types.h
> > @@ -111,6 +111,11 @@ extern unsigned int ptrs_per_p4d;
> >   */
> >  #define MAXMEM			(1UL << MAX_PHYSMEM_BITS)
> >  
> > +#define GUARD_HOLE_PGD_ENTRY	-256UL
> > +#define GUARD_HOLE_SIZE		(16UL << PGDIR_SHIFT)
> > +#define GUARD_HOLE_BASE_ADDR	(LDT_PGD_ENTRY << PGDIR_SHIFT)
> 
> s/LDT_PGD_ENTRY/GUARD_HOLE_PGD_ENTRY/

Ughh..

>From 4308d560cc2874a9f596512bcb4c601b2450653d Mon Sep 17 00:00:00 2001
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Fri, 30 Nov 2018 14:29:42 +0300
Subject: [PATCH 1/2] x86/mm: Fix guard hole handling

There is a guard hole at the beginning of kernel address space, also
used by hypervisors. It occupies 16 PGD entries.

We do not state the reserved range directly, but calculate it relative
to other entities: direct mapping and user space ranges.

The calculation got broken by recent change in kernel memory layout: LDT
remap range is now mapped before direct mapping and makes the calculation
invalid.

The breakage leads to crash on Xen dom0 boot[1].

State the reserved range directly. It's part of kernel ABI (hypervisors
expect it to be stable) and must not depend on changes in the rest of
kernel memory layout.

[1] https://lists.xenproject.org/archives/html/xen-devel/2018-11/msg03313.html

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Hans van Kranenburg <Hans.van.Kranenburg@mendix.com>
Fixes: d52888aa2753 ("x86/mm: Move LDT remap out of KASLR region on 5-level paging")
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable_64_types.h |  5 +++++
 arch/x86/mm/dump_pagetables.c           |  8 ++++----
 arch/x86/xen/mmu_pv.c                   | 11 ++++++-----
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 84bd9bdc1987..ff96fbab97b5 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -111,6 +111,11 @@ extern unsigned int ptrs_per_p4d;
  */
 #define MAXMEM			(1UL << MAX_PHYSMEM_BITS)
 
+#define GUARD_HOLE_PGD_ENTRY	-256UL
+#define GUARD_HOLE_SIZE		(16UL << PGDIR_SHIFT)
+#define GUARD_HOLE_BASE_ADDR	(GUARD_HOLE_ENTRY << PGDIR_SHIFT)
+#define GUARD_HOLE_END_ADDR	(GUARD_HOLE_BASE_ADDR + GUARD_HOLE_SIZE)
+
 #define LDT_PGD_ENTRY		-240UL
 #define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 #define LDT_END_ADDR		(LDT_BASE_ADDR + PGDIR_SIZE)
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index fc37bbd23eb8..dad153e5a427 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -512,11 +512,11 @@ static inline bool is_hypervisor_range(int idx)
 {
 #ifdef CONFIG_X86_64
 	/*
-	 * ffff800000000000 - ffff87ffffffffff is reserved for
-	 * the hypervisor.
+	 * A hole in the beginning of kernel address space reserved
+	 * for a hypervisor.
 	 */
-	return	(idx >= pgd_index(__PAGE_OFFSET) - 16) &&
-		(idx <  pgd_index(__PAGE_OFFSET));
+	return	(idx >= pgd_index(GUARD_HOLE_BASE_ADDR)) &&
+		(idx <  pgd_index(GUARD_HOLE_END_ADDR));
 #else
 	return false;
 #endif
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index a5d7ed125337..0f4fe206dcc2 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -648,19 +648,20 @@ static int __xen_pgd_walk(struct mm_struct *mm, pgd_t *pgd,
 			  unsigned long limit)
 {
 	int i, nr, flush = 0;
-	unsigned hole_low, hole_high;
+	unsigned hole_low = 0, hole_high = 0;
 
 	/* The limit is the last byte to be touched */
 	limit--;
 	BUG_ON(limit >= FIXADDR_TOP);
 
+#ifdef CONFIG_X86_64
 	/*
 	 * 64-bit has a great big hole in the middle of the address
-	 * space, which contains the Xen mappings.  On 32-bit these
-	 * will end up making a zero-sized hole and so is a no-op.
+	 * space, which contains the Xen mappings.
 	 */
-	hole_low = pgd_index(USER_LIMIT);
-	hole_high = pgd_index(PAGE_OFFSET);
+	hole_low = pgd_index(GUARD_HOLE_BASE_ADDR);
+	hole_high = pgd_index(GUARD_HOLE_END_ADDR);
+#endif
 
 	nr = pgd_index(limit) + 1;
 	for (i = 0; i < nr; i++) {
-- 
 Kirill A. Shutemov
