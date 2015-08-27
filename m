Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 093FE6B0256
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:04:02 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so1231944pac.3
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:04:01 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id sa6si429706pbb.26.2015.08.27.02.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 02:04:01 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 02/11] ARC: mm: Introduce PTE_SPECIAL
Date: Thu, 27 Aug 2015 14:33:05 +0530
Message-ID: <1440666194-21478-3-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Needed for THP, but will also come in handy for fast GUP later

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgtable.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 481359fe56ae..431a83329324 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -61,6 +61,7 @@
 #define _PAGE_WRITE         (1<<4)	/* Page has user write perm (H) */
 #define _PAGE_READ          (1<<5)	/* Page has user read perm (H) */
 #define _PAGE_DIRTY         (1<<6)	/* Page modified (dirty) (S) */
+#define _PAGE_SPECIAL       (1<<7)
 #define _PAGE_GLOBAL        (1<<8)	/* Page is global (H) */
 #define _PAGE_PRESENT       (1<<10)	/* TLB entry is valid (H) */
 
@@ -72,6 +73,7 @@
 #define _PAGE_READ          (1<<3)	/* Page has user read perm (H) */
 #define _PAGE_ACCESSED      (1<<4)	/* Page is accessed (S) */
 #define _PAGE_DIRTY         (1<<5)	/* Page modified (dirty) (S) */
+#define _PAGE_SPECIAL       (1<<6)
 
 #if (CONFIG_ARC_MMU_VER >= 4)
 #define _PAGE_WTHRU         (1<<7)	/* Page cache mode write-thru (H) */
@@ -292,7 +294,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 #define pte_write(pte)		(pte_val(pte) & _PAGE_WRITE)
 #define pte_dirty(pte)		(pte_val(pte) & _PAGE_DIRTY)
 #define pte_young(pte)		(pte_val(pte) & _PAGE_ACCESSED)
-#define pte_special(pte)	(0)
+#define pte_special(pte)	(pte_val(pte) & _PAGE_SPECIAL)
 
 #define PTE_BIT_FUNC(fn, op) \
 	static inline pte_t pte_##fn(pte_t pte) { pte_val(pte) op; return pte; }
@@ -305,8 +307,9 @@ PTE_BIT_FUNC(mkold,	&= ~(_PAGE_ACCESSED));
 PTE_BIT_FUNC(mkyoung,	|= (_PAGE_ACCESSED));
 PTE_BIT_FUNC(exprotect,	&= ~(_PAGE_EXECUTE));
 PTE_BIT_FUNC(mkexec,	|= (_PAGE_EXECUTE));
+PTE_BIT_FUNC(mkspecial,	|= (_PAGE_SPECIAL));
 
-static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
+#define __HAVE_ARCH_PTE_SPECIAL
 
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
