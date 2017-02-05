Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51E5F6B0266
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 11:14:34 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id d201so31440193qkg.2
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 08:14:34 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id 21si23295921qkf.16.2017.02.05.08.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 08:14:33 -0800 (PST)
From: Zi Yan <zi.yan@sent.com>
Subject: [PATCH v3 04/14] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 1
Date: Sun,  5 Feb 2017 11:12:42 -0500
Message-Id: <20170205161252.85004-5-zi.yan@sent.com>
In-Reply-To: <20170205161252.85004-1-zi.yan@sent.com>
References: <20170205161252.85004-1-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu

From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid
false negative return when it races with thp spilt
(during which _PAGE_PRESENT is temporary cleared.) I don't think that
dropping _PAGE_PSE check in pmd_present() works well because it can
hurt optimization of tlb handling in thp split.
In the current kernel, bits 1-4 are not used in non-present format
since commit 00839ee3b299 ("x86/mm: Move swap offset/type up in PTE to
work around erratum"). So let's move _PAGE_SWP_SOFT_DIRTY to bit 1.
Bit 7 is used as reserved (always clear), so please don't use it for
other purpose.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

ChangeLog v3:
- Move _PAGE_SWP_SOFT_DIRTY to bit 1, it was placed at bit 6. Because
some CPUs might accidentally set bit 5 or 6.

Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
---
 arch/x86/include/asm/pgtable_types.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 8b4de22d6429..3695abd58ef6 100644
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
