Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4B41A6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 04:20:47 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ec20so2488070lab.22
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 01:20:46 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id le2si5025908lbc.19.2014.04.25.01.20.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Apr 2014 01:20:45 -0700 (PDT)
Received: by mail-lb0-f179.google.com with SMTP id q8so2845723lbi.10
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 01:20:44 -0700 (PDT)
Message-Id: <20140425082042.737179159@openvz.org>
Date: Fri, 25 Apr 2014 12:10:31 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 1/2] mm: pgtable -- Drop unneeded preprocessor ifdef
References: <20140425081030.185969086@openvz.org>
Content-Disposition: inline; filename=pgbits-drop-if
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, mgorman@suse.de, hpa@zytor.com, mingo@kernel.org, steven@uplinklabs.net, riel@redhat.com, david.vrabel@citrix.com, akpm@linux-foundation.org, peterz@infradead.org, xemul@parallels.com, gorcunov@openvz.org

_PAGE_BIT_FILE (bit 6) is always less than _PAGE_BIT_PROTNONE (bit 8),
so drop redundant #ifdef.

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
 arch/x86/include/asm/pgtable-2level.h |   10 ----------
 arch/x86/include/asm/pgtable_64.h     |    8 --------
 2 files changed, 18 deletions(-)

Index: linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable-2level.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable-2level.h
@@ -115,13 +115,8 @@ static __always_inline pte_t pgoff_to_pt
  */
 #define PTE_FILE_MAX_BITS	29
 #define PTE_FILE_SHIFT1		(_PAGE_BIT_PRESENT + 1)
-#if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
 #define PTE_FILE_SHIFT2		(_PAGE_BIT_FILE + 1)
 #define PTE_FILE_SHIFT3		(_PAGE_BIT_PROTNONE + 1)
-#else
-#define PTE_FILE_SHIFT2		(_PAGE_BIT_PROTNONE + 1)
-#define PTE_FILE_SHIFT3		(_PAGE_BIT_FILE + 1)
-#endif
 #define PTE_FILE_BITS1		(PTE_FILE_SHIFT2 - PTE_FILE_SHIFT1 - 1)
 #define PTE_FILE_BITS2		(PTE_FILE_SHIFT3 - PTE_FILE_SHIFT2 - 1)
 
@@ -153,13 +148,8 @@ static __always_inline pte_t pgoff_to_pt
 #endif /* CONFIG_MEM_SOFT_DIRTY */
 
 /* Encode and de-code a swap entry */
-#if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
-#else
-#define SWP_TYPE_BITS (_PAGE_BIT_PROTNONE - _PAGE_BIT_PRESENT - 1)
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_FILE + 1)
-#endif
 
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
 
Index: linux-2.6.git/arch/x86/include/asm/pgtable_64.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable_64.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable_64.h
@@ -143,7 +143,6 @@ static inline int pgd_large(pgd_t pgd) {
 #define pte_unmap(pte) ((void)(pte))/* NOP */
 
 /* Encode and de-code a swap entry */
-#if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
 #ifdef CONFIG_NUMA_BALANCING
 /* Automatic NUMA balancing needs to be distinguishable from swap entries */
@@ -151,13 +150,6 @@ static inline int pgd_large(pgd_t pgd) {
 #else
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
 #endif
-#else
-#ifdef CONFIG_NUMA_BALANCING
-#error Incompatible format for automatic NUMA balancing
-#endif
-#define SWP_TYPE_BITS (_PAGE_BIT_PROTNONE - _PAGE_BIT_PRESENT - 1)
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_FILE + 1)
-#endif
 
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
