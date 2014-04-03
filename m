Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1CEF86B0035
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 15:09:57 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id hr17so1683903lab.5
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 12:09:57 -0700 (PDT)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id sz4si4124004lbb.36.2014.04.03.12.09.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 12:09:55 -0700 (PDT)
Received: by mail-la0-f51.google.com with SMTP id pv20so1683511lab.38
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 12:09:55 -0700 (PDT)
Message-Id: <20140403190952.552007526@openvz.org>
Date: Thu, 03 Apr 2014 22:48:45 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [rfc 1/3] mm: pgtable -- Drop unneeded preprocessor ifdef
References: <20140403184844.260532690@openvz.org>
Content-Disposition: inline; filename=pgbits-drop-if
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: gorcunov@openvz.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Pavel Emelyanov <xemul@parallels.com>

_PAGE_BIT_FILE (bit 6) is always less than
_PAGE_BIT_PROTNONE (bit 9) so drop redundant #ifdef.

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
 arch/x86/include/asm/pgtable_64.h     |    5 -----
 2 files changed, 15 deletions(-)

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
@@ -143,13 +143,8 @@ static inline int pgd_large(pgd_t pgd) {
 #define pte_unmap(pte) ((void)(pte))/* NOP */
 
 /* Encode and de-code a swap entry */
-#if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
 #define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
-#else
-#define SWP_TYPE_BITS (_PAGE_BIT_PROTNONE - _PAGE_BIT_PRESENT - 1)
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_FILE + 1)
-#endif
 
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
