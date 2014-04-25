Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 058746B0036
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 04:20:48 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id z11so1567660lbi.26
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 01:20:48 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id pr4si5007768lbc.114.2014.04.25.01.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 01:20:46 -0700 (PDT)
Received: by mail-lb0-f182.google.com with SMTP id l4so2885742lbv.27
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 01:20:45 -0700 (PDT)
Message-Id: <20140425082042.848656782@openvz.org>
Date: Fri, 25 Apr 2014 12:10:32 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 2/2] mm: pgtable -- Require X86_64 for soft-dirty tracker
References: <20140425081030.185969086@openvz.org>
Content-Disposition: inline; filename=pgbits-drop-softdirty-non-x86-64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, mgorman@suse.de, hpa@zytor.com, mingo@kernel.org, steven@uplinklabs.net, riel@redhat.com, david.vrabel@citrix.com, akpm@linux-foundation.org, peterz@infradead.org, xemul@parallels.com, gorcunov@openvz.org

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
 2 files changed, 1 insertion(+), 50 deletions(-)

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
