Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7BCE6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:32:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so58126894pfy.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:07 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id k72si33488210pge.102.2016.11.07.15.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:32:06 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id i88so17317618pfk.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:32:06 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 01/12] mm: x86: move _PAGE_SWP_SOFT_DIRTY from bit 7 to bit 6
Date: Tue,  8 Nov 2016 08:31:46 +0900
Message-Id: <1478561517-4317-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

pmd_present() checks _PAGE_PSE along with _PAGE_PRESENT to avoid false negative
return when it races with thp spilt (during which _PAGE_PRESENT is temporary
cleared.) I don't think that dropping _PAGE_PSE check in pmd_present() works
well because it can hurt optimization of tlb handling in thp split.
In the current kernel, bit 6 is not used in non-present format because nonlinear
file mapping is obsolete, so let's move _PAGE_SWP_SOFT_DIRTY to that bit.
Bit 7 is used as reserved (always clear), so please don't use it for other
purpose.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/x86/include/asm/pgtable_types.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_types.h v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_types.h
index 8b4de22..89e88f1 100644
--- v4.9-rc2-mmotm-2016-10-27-18-27/arch/x86/include/asm/pgtable_types.h
+++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/arch/x86/include/asm/pgtable_types.h
@@ -98,14 +98,14 @@
  * Tracking soft dirty bit when a page goes to a swap is tricky.
  * We need a bit which can be stored in pte _and_ not conflict
  * with swap entry format. On x86 bits 6 and 7 are *not* involved
- * into swap entry computation, but bit 6 is used for nonlinear
- * file mapping, so we borrow bit 7 for soft dirty tracking.
+ * into swap entry computation, but bit 7 is used for thp migration,
+ * so we borrow bit 6 for soft dirty tracking.
  *
  * Please note that this bit must be treated as swap dirty page
- * mark if and only if the PTE has present bit clear!
+ * mark if and only if the PTE/PMD has present bit clear!
  */
 #ifdef CONFIG_MEM_SOFT_DIRTY
-#define _PAGE_SWP_SOFT_DIRTY	_PAGE_PSE
+#define _PAGE_SWP_SOFT_DIRTY	_PAGE_DIRTY
 #else
 #define _PAGE_SWP_SOFT_DIRTY	(_AT(pteval_t, 0))
 #endif
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
