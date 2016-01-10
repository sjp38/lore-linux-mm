Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C638B828F3
	for <linux-mm@kvack.org>; Sat,  9 Jan 2016 19:55:03 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id n128so26998251pfn.3
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 16:55:03 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id 14si16168168pfa.12.2016.01.09.16.55.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jan 2016 16:55:03 -0800 (PST)
Received: by mail-pa0-x233.google.com with SMTP id yy13so209715562pab.3
        for <linux-mm@kvack.org>; Sat, 09 Jan 2016 16:55:03 -0800 (PST)
Date: Sat, 9 Jan 2016 16:54:59 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH next] powerpc/mm: fix _PAGE_SWP_SOFT_DIRTY breaking swapoff
Message-ID: <alpine.LSU.2.11.1601091651130.9808@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Swapoff after swapping hangs on the G5, when CONFIG_CHECKPOINT_RESTORE=y
but CONFIG_MEM_SOFT_DIRTY is not set.  That's because the non-zero
_PAGE_SWP_SOFT_DIRTY bit, added by CONFIG_HAVE_ARCH_SOFT_DIRTY=y, is not
discounted when CONFIG_MEM_SOFT_DIRTY is not set: so swap ptes cannot be
recognized.

(I suspect that the peculiar dependence of HAVE_ARCH_SOFT_DIRTY on
CHECKPOINT_RESTORE in arch/powerpc/Kconfig comes from an incomplete
attempt to solve this problem.)

It's true that the relationship between CONFIG_HAVE_ARCH_SOFT_DIRTY and
and CONFIG_MEM_SOFT_DIRTY is too confusing, and it's true that swapoff
should be made more robust; but nevertheless, fix up the powerpc ifdefs
as x86_64 and s390 (which met the same problem) have them, defining the
bits as 0 if CONFIG_MEM_SOFT_DIRTY is not set.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 arch/powerpc/include/asm/book3s/64/hash.h    |    5 +++++
 arch/powerpc/include/asm/book3s/64/pgtable.h |    9 ++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

--- 4.4-next/arch/powerpc/include/asm/book3s/64/hash.h	2016-01-06 11:54:01.377508976 -0800
+++ linux/arch/powerpc/include/asm/book3s/64/hash.h	2016-01-09 13:54:24.410893347 -0800
@@ -33,7 +33,12 @@
 #define _PAGE_F_GIX_SHIFT	12
 #define _PAGE_F_SECOND		0x08000 /* Whether to use secondary hash or not */
 #define _PAGE_SPECIAL		0x10000 /* software: special page */
+
+#ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SOFT_DIRTY	0x20000 /* software: software dirty tracking */
+#else
+#define _PAGE_SOFT_DIRTY	0x00000
+#endif
 
 /*
  * We need to differentiate between explicit huge page and THP huge
--- 4.4-next/arch/powerpc/include/asm/book3s/64/pgtable.h	2016-01-06 11:54:01.377508976 -0800
+++ linux/arch/powerpc/include/asm/book3s/64/pgtable.h	2016-01-09 13:54:24.410893347 -0800
@@ -162,8 +162,13 @@ static inline void pgd_set(pgd_t *pgdp,
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val((pte)) })
 #define __swp_entry_to_pte(x)		__pte((x).val)
 
-#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
+#ifdef CONFIG_MEM_SOFT_DIRTY
 #define _PAGE_SWP_SOFT_DIRTY   (1UL << (SWP_TYPE_BITS + _PAGE_BIT_SWAP_TYPE))
+#else
+#define _PAGE_SWP_SOFT_DIRTY	0UL
+#endif /* CONFIG_MEM_SOFT_DIRTY */
+
+#ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 static inline pte_t pte_swp_mksoft_dirty(pte_t pte)
 {
 	return __pte(pte_val(pte) | _PAGE_SWP_SOFT_DIRTY);
@@ -176,8 +181,6 @@ static inline pte_t pte_swp_clear_soft_d
 {
 	return __pte(pte_val(pte) & ~_PAGE_SWP_SOFT_DIRTY);
 }
-#else
-#define _PAGE_SWP_SOFT_DIRTY	0
 #endif /* CONFIG_HAVE_ARCH_SOFT_DIRTY */
 
 void pgtable_cache_add(unsigned shift, void (*ctor)(void *));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
