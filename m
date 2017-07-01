Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62FFA6B02C3
	for <linux-mm@kvack.org>; Sat,  1 Jul 2017 09:40:52 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o8so68921918qtc.1
        for <linux-mm@kvack.org>; Sat, 01 Jul 2017 06:40:52 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id l34si10200481qte.350.2017.07.01.06.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jul 2017 06:40:51 -0700 (PDT)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v8 02/10] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1
Date: Sat,  1 Jul 2017 09:40:00 -0400
Message-Id: <20170701134008.110579-3-zi.yan@sent.com>
In-Reply-To: <20170701134008.110579-1-zi.yan@sent.com>
References: <20170701134008.110579-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com, dave.hansen@intel.com, n-horiguchi@ah.jp.nec.com

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

_PAGE_PSE is used to distinguish between a truly non-present
(_PAGE_PRESENT=0) PMD, and a PMD which is undergoing a THP
split and should be treated as present.

But _PAGE_SWP_SOFT_DIRTY currently uses the _PAGE_PSE bit,
which would cause confusion between one of those PMDs
undergoing a THP split, and a soft-dirty PMD.
Dropping _PAGE_PSE check in pmd_present() does not work well,
because it can hurt optimization of tlb handling in thp split.

Thus, we need to move the bit.

In the current kernel, bits 1-4 are not used in non-present format
since commit 00839ee3b299 ("x86/mm: Move swap offset/type up in PTE to
work around erratum"). So let's move _PAGE_SWP_SOFT_DIRTY to bit 1.
Bit 7 is used as reserved (always clear), so please don't use it for
other purpose.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
Acked-by: Dave Hansen <dave.hansen@intel.com>
---
 arch/x86/include/asm/pgtable_64.h    | 12 +++++++++---
 arch/x86/include/asm/pgtable_types.h | 10 +++++-----
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 9991224f6238..45b7a4094de0 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -178,15 +178,21 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 /*
  * Encode and de-code a swap entry
  *
- * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2|1|0| <- bit number
- * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U|W|P| <- bit names
- * | OFFSET (14->63) | TYPE (9-13)  |0|X|X|X| X| X|X|X|0| <- swp entry
+ * |     ...            | 11| 10|  9|8|7|6|5| 4| 3|2| 1|0| <- bit number
+ * |     ...            |SW3|SW2|SW1|G|L|D|A|CD|WT|U| W|P| <- bit names
+ * | OFFSET (14->63) | TYPE (9-13)  |0|0|X|X| X| X|X|SD|0| <- swp entry
  *
  * G (8) is aliased and used as a PROT_NONE indicator for
  * !present ptes.  We need to start storing swap entries above
  * there.  We also need to avoid using A and D because of an
  * erratum where they can be incorrectly set by hardware on
  * non-present PTEs.
+ *
+ * SD (1) in swp entry is used to store soft dirty bit, which helps us
+ * remember soft dirty over page migration
+ *
+ * Bit 7 in swp entry should be 0 because pmd_present checks not only P,
+ * but also L and G.
  */
 #define SWP_TYPE_FIRST_BIT (_PAGE_BIT_PROTNONE + 1)
 #define SWP_TYPE_BITS 5
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index bf9638e1ee42..c612a8f08422 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -97,15 +97,15 @@
 /*
  * Tracking soft dirty bit when a page goes to a swap is tricky.
  * We need a bit which can be stored in pte _and_ not conflict
- * with swap entry format. On x86 bits 6 and 7 are *not* involved
- * into swap entry computation, but bit 6 is used for nonlinear
- * file mapping, so we borrow bit 7 for soft dirty tracking.
+ * with swap entry format. On x86 bits 1-4 are *not* involved
+ * into swap entry computation, but bit 7 is used for thp migration,
+ * so we borrow bit 1 for soft dirty tracking.
  *
  * Please note that this bit must be treated as swap dirty page
- * mark if and only if the PTE has present bit clear!
+ * mark if and only if the PTE/PMD has present bit clear!
  */
 #ifdef CONFIG_MEM_SOFT_DIRTY
-#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
+#define _PAGE_SWP_SOFT_DIRTY	_PAGE_RW
 #else
 #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
 #endif
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
