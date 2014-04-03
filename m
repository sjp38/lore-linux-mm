Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF1A76B0037
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 15:09:58 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so1667690lab.6
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 12:09:58 -0700 (PDT)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id g7si4109914lab.166.2014.04.03.12.09.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 12:09:57 -0700 (PDT)
Received: by mail-la0-f52.google.com with SMTP id ec20so1711862lab.11
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 12:09:56 -0700 (PDT)
Message-Id: <20140403190952.766500364@openvz.org>
Date: Thu, 03 Apr 2014 22:48:47 +0400
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [rfc 3/3] mm: pgtable -- Use _PAGE_SOFT_DIRTY for swap entries
References: <20140403184844.260532690@openvz.org>
Content-Disposition: inline; filename=pgbits-drop-pse-for-dirty-swap
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: gorcunov@openvz.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Pavel Emelyanov <xemul@parallels.com>

Since we support soft-dirty on x86-64 now we can release _PAGE_PSE
bit used to track dirty swap entries and reuse ealready existing
_PAGE_SOFT_DIRTY.

Thus for all soft-dirty needs we use same pte bit.

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
 arch/x86/include/asm/pgtable_64.h    |   12 ++++++++++--
 arch/x86/include/asm/pgtable_types.h |   19 ++++---------------
 2 files changed, 14 insertions(+), 17 deletions(-)

Index: linux-2.6.git/arch/x86/include/asm/pgtable_64.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable_64.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable_64.h
@@ -142,9 +142,17 @@ static inline int pgd_large(pgd_t pgd) {
 #define pte_offset_map(dir, address) pte_offset_kernel((dir), (address))
 #define pte_unmap(pte) ((void)(pte))/* NOP */
 
-/* Encode and de-code a swap entry */
+/*
+ * Encode and de-code a swap entry. When soft-dirty memory tracker is
+ * enabled we need to borrow _PAGE_BIT_SOFT_DIRTY bit for own needs,
+ * which limits the max size of swap partiotion about to 1T.
+ */
 #define SWP_TYPE_BITS (_PAGE_BIT_FILE - _PAGE_BIT_PRESENT - 1)
-#define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
+#ifdef CONFIG_MEM_SOFT_DIRTY
+# define SWP_OFFSET_SHIFT (_PAGE_BIT_SOFT_DIRTY + 1)
+#else
+# define SWP_OFFSET_SHIFT (_PAGE_BIT_PROTNONE + 1)
+#endif
 
 #define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
 
Index: linux-2.6.git/arch/x86/include/asm/pgtable_types.h
===================================================================
--- linux-2.6.git.orig/arch/x86/include/asm/pgtable_types.h
+++ linux-2.6.git/arch/x86/include/asm/pgtable_types.h
@@ -59,29 +59,18 @@
  * The same hidden bit is used by kmemcheck, but since kmemcheck
  * works on kernel pages while soft-dirty engine on user space,
  * they do not conflict with each other.
+ *
+ * Because soft-dirty is limited to x86-64 only we can reuse this
+ * bit to track swap entries as well.
  */
 
 #define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_HIDDEN
 
 #ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 1) << _PAGE_BIT_SOFT_DIRTY)
+#define _PAGE_SWP_SOFT_DIRTY	_PAGE_SOFT_DIRTY
 #else
 #define _PAGE_SOFT_DIRTY	(_AT(pteval_t, 0))
-#endif
-
-/*
- * Tracking soft dirty bit when a page goes to a swap is tricky.
- * We need a bit which can be stored in pte _and_ not conflict
- * with swap entry format. On x86 bits 6 and 7 are *not* involved
- * into swap entry computation, but bit 6 is used for nonlinear
- * file mapping, so we borrow bit 7 for soft dirty tracking.
- *
- * Please note that this bit must be treated as swap dirty page
- * mark if and only if the PTE has present bit clear!
- */
-#ifdef CONFIG_MEM_SOFT_DIRTY
-#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
-#else
 #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
