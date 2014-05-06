Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id EE3D46B00DF
	for <linux-mm@kvack.org>; Tue,  6 May 2014 04:25:46 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id l4so2470290lbv.6
        for <linux-mm@kvack.org>; Tue, 06 May 2014 01:25:46 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id pc8si1198026lbb.76.2014.05.06.01.25.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 May 2014 01:25:45 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so1701483lbi.23
        for <linux-mm@kvack.org>; Tue, 06 May 2014 01:25:44 -0700 (PDT)
Date: Tue, 6 May 2014 12:25:42 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [patch 2/2] mm: pgtable -- Require X86_64 for soft-dirty tracker, v2
Message-ID: <20140506082542.GI28248@moon>
References: <20140425081030.185969086@openvz.org>
 <20140425082042.848656782@openvz.org>
 <20140505163123.65e6f8853cdf0646f26bd5b4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140505163123.65e6f8853cdf0646f26bd5b4@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, mgorman@suse.de, hpa@zytor.com, mingo@kernel.org, steven@uplinklabs.net, riel@redhat.com, david.vrabel@citrix.com, peterz@infradead.org, xemul@parallels.com

On Mon, May 05, 2014 at 04:31:23PM -0700, Andrew Morton wrote:
> On Fri, 25 Apr 2014 12:10:32 +0400 Cyrill Gorcunov <gorcunov@openvz.org> wrote:
> 
> > Tracking dirty status on 2 level pages requires very ugly macros
> > and taking into account how old the machines who can operate
> > without PAE mode only are, lets drop soft dirty tracker from
> > them for code simplicity (note I can't drop all the macros
> > from 2 level pages by now since _PAGE_BIT_PROTNONE and
> > _PAGE_BIT_FILE are still used even without tracker).
> > 
> > Linus proposed to completely rip off softdirty support on
> > x86-32 (even with PAE) and since for CRIU we're not planning
> > to support native x86-32 mode, lets do that.
> > 
> > (Softdirty tracker is relatively new feature which mostly used
> >  by CRIU so I don't expect if such API change would cause problems
> >  on userspace).
> 
> i386 allnoconfig:
> 
> In file included from /usr/src/25/arch/x86/include/asm/pgtable.h:886,

Thanks! Here is an updated version.
---
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [PATCH -next] mm: pgtable -- Require X86_64 for soft-dirty tracker

Tracking dirty status on 2 level pages requires very ugly macros
and taking into account how old the machines who can operate
without PAE mode only are, lets drop soft dirty tracker from
them for code simplicity (note I can't drop all the macros
from 2 level pages by now since _PAGE_BIT_PROTNONE and
_PAGE_BIT_FILE are still used even without tracker).

Linus proposed to completely rip off softdirty support on
x86-32 (even with PAE) and since for CRIU we're not planning
to support native x86-32 mode, lets do that.

(Softdirty tracker is relatively new feature which mostly used
 by CRIU so I don't expect if such API change would cause problems
 on userspace).

v2 (by akpm@):
 - guard helpers with CONFIG_HAVE_ARCH_SOFT_DIRTY on i386, otherwise
   it fails to build because we've a generic definitions in
   asm-generic/pgtable.h

CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Peter Anvin <hpa@zytor.com>
CC: Ingo Molnar <mingo@kernel.org>
CC: Steven Noonan <steven@uplinklabs.net>
CC: Rik van Riel <riel@redhat.com>
CC: David Vrabel <david.vrabel@citrix.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Pavel Emelyanov <xemul@parallels.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 arch/x86/Kconfig                      |    2 -
 arch/x86/include/asm/pgtable-2level.h |   49 ----------------------------------
 arch/x86/include/asm/pgtable.h        |    5 +++
 3 files changed, 6 insertions(+), 50 deletions(-)

Index: linux-2.6.git/arch/x86/Kconfig
===================================================================
--- linux-2.6.git.orig/arch/x86/Kconfig
+++ linux-2.6.git/arch/x86/Kconfig
@@ -106,7 +106,7 @@ config X86
 	select HAVE_ARCH_SECCOMP_FILTER
 	select BUILDTIME_EXTABLE_SORT
 	select GENERIC_CMOS_UPDATE
-	select HAVE_ARCH_SOFT_DIRTY
+	select HAVE_ARCH_SOFT_DIRTY if X86_64
 	select CLOCKSOURCE_WATCHDOG
 	select GENERIC_CLOCKEVENTS
 	select ARCH_CLOCKSOURCE_DATA
Index: linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable-2level.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
@@ -62,53 +62,6 @@ static inline unsigned long pte_bitop(un
 	return ((value >> rightshift) & mask) << leftshift;
 }
 
-#ifdef CONFIG_MEM_SOFT_DIRTY
-
-/*
- * Bits _PAGE_BIT_PRESENT, _PAGE_BIT_FILE, _PAGE_BIT_SOFT_DIRTY and
- * _PAGE_BIT_PROTNONE are taken, split up the 28 bits of offset
- * into this range.
- */
-#define PTE_FILE_MAX_BITS	28
-#define PTE_FILE_SHIFT1		(_PAGE_BIT_PRESENT + 1)
-#define PTE_FILE_SHIFT2		(_PAGE_BIT_FILE + 1)
-#define PTE_FILE_SHIFT3		(_PAGE_BIT_PROTNONE + 1)
-#define PTE_FILE_SHIFT4		(_PAGE_BIT_SOFT_DIRTY + 1)
-#define PTE_FILE_BITS1		(PTE_FILE_SHIFT2 - PTE_FILE_SHIFT1 - 1)
-#define PTE_FILE_BITS2		(PTE_FILE_SHIFT3 - PTE_FILE_SHIFT2 - 1)
-#define PTE_FILE_BITS3		(PTE_FILE_SHIFT4 - PTE_FILE_SHIFT3 - 1)
-
-#define PTE_FILE_MASK1		((1U << PTE_FILE_BITS1) - 1)
-#define PTE_FILE_MASK2		((1U << PTE_FILE_BITS2) - 1)
-#define PTE_FILE_MASK3		((1U << PTE_FILE_BITS3) - 1)
-
-#define PTE_FILE_LSHIFT2	(PTE_FILE_BITS1)
-#define PTE_FILE_LSHIFT3	(PTE_FILE_BITS1 + PTE_FILE_BITS2)
-#define PTE_FILE_LSHIFT4	(PTE_FILE_BITS1 + PTE_FILE_BITS2 + PTE_FILE_BITS3)
-
-static __always_inline pgoff_t pte_to_pgoff(pte_t pte)
-{
-	return (pgoff_t)
-		(pte_bitop(pte.pte_low, PTE_FILE_SHIFT1, PTE_FILE_MASK1,  0)		    +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT2, PTE_FILE_MASK2,  PTE_FILE_LSHIFT2) +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT3, PTE_FILE_MASK3,  PTE_FILE_LSHIFT3) +
-		 pte_bitop(pte.pte_low, PTE_FILE_SHIFT4,           -1UL,  PTE_FILE_LSHIFT4));
-}
-
-static __always_inline pte_t pgoff_to_pte(pgoff_t off)
-{
-	return (pte_t){
-		.pte_low =
-			pte_bitop(off,                0, PTE_FILE_MASK1,  PTE_FILE_SHIFT1) +
-			pte_bitop(off, PTE_FILE_LSHIFT2, PTE_FILE_MASK2,  PTE_FILE_SHIFT2) +
-			pte_bitop(off, PTE_FILE_LSHIFT3, PTE_FILE_MASK3,  PTE_FILE_SHIFT3) +
-			pte_bitop(off, PTE_FILE_LSHIFT4,           -1UL,  PTE_FILE_SHIFT4) +
-			_PAGE_FILE,
-	};
-}
-
-#else /* CONFIG_MEM_SOFT_DIRTY */
-
 /*
  * Bits _PAGE_BIT_PRESENT, _PAGE_BIT_FILE and _PAGE_BIT_PROTNONE are taken,
  * split up the 29 bits of offset into this range.
@@ -145,8 +98,6 @@ static __always_inline pte_t pgoff_to_pt
 	};
 }
 
-#endif /* CONFIG_MEM_SOFT_DIRTY */
-
 /* Encode and de-code a swap entry */
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
Index: linux-2.6.git/arch/x86/include/asm/pgtable.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable.h
@@ -297,6 +297,7 @@ static inline pmd_t pmd_mknotpresent(pmd
 	return pmd_clear_flags(pmd, _PAGE_PRESENT);
 }
 
+#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline int pte_soft_dirty(pte_t pte)
 {
 	return pte_flags(pte) & _PAGE_SOFT_DIRTY;
@@ -332,6 +333,8 @@ static inline int pte_file_soft_dirty(pt
 	return pte_flags(pte) & _PAGE_SOFT_DIRTY;
 }
 
+#endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
+
 /*
  * Mask out unsupported bits in a present pgprot.  Non-present pgprots
  * can use those bits for other purposes, so leave them be.
@@ -865,6 +868,7 @@ static inline void update_mmu_cache_pmd(
 {
 }
 
+#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
 {
 	VM_BUG_ON(pte_present_nonuma(pte));
@@ -882,6 +886,7 @@ static inline pte_t pte_swp_clear_soft_d
 	VM_BUG_ON(pte_present_nonuma(pte));
 	return pte_clear_flags(pte, _PAGE_SWP_SOFT_DIRTY);
 }
+#endif
 
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
