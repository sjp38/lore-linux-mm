Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id A1FE06B025A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 14:27:26 -0400 (EDT)
Received: by obbbh8 with SMTP id bh8so20197572obb.0
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 11:27:26 -0700 (PDT)
Received: from g1t6223.austin.hp.com (g1t6223.austin.hp.com. [15.73.96.124])
        by mx.google.com with ESMTPS id p7si2345351obx.40.2015.09.17.11.27.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 11:27:19 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 RESEND 7/11] x86/mm: Fix slow_virt_to_phys() to handle large PAT bit
Date: Thu, 17 Sep 2015 12:24:20 -0600
Message-Id: <1442514264-12475-8-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
References: <1442514264-12475-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>

slow_virt_to_phys() calls lookup_address() to obtain *pte and
its level.  It then calls pte_pfn() to obtain a physical address
for any level.  However, this physical address is not correct
when the large PAT bit is set because pte_pfn() does not mask
the large PAT bit properly for PUD/PMD.

Fix slow_virt_to_phys() to use pud_pfn() and pmd_pfn() for 1GB
and 2MB mapping levels.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/mm/pageattr.c |   24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index b6c2659..023b639 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -415,18 +415,28 @@ pmd_t *lookup_pmd_address(unsigned long address)
 phys_addr_t slow_virt_to_phys(void *__virt_addr)
 {
 	unsigned long virt_addr = (unsigned long)__virt_addr;
-	phys_addr_t phys_addr;
-	unsigned long offset;
+	unsigned long phys_addr, offset;
 	enum pg_level level;
-	unsigned long pmask;
 	pte_t *pte;
 
 	pte = lookup_address(virt_addr, &level);
 	BUG_ON(!pte);
-	pmask = page_level_mask(level);
-	offset = virt_addr & ~pmask;
-	phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
-	return (phys_addr | offset);
+
+	switch (level) {
+	case PG_LEVEL_1G:
+		phys_addr = pud_pfn(*(pud_t *)pte) << PAGE_SHIFT;
+		offset = virt_addr & ~PUD_PAGE_MASK;
+		break;
+	case PG_LEVEL_2M:
+		phys_addr = pmd_pfn(*(pmd_t *)pte) << PAGE_SHIFT;
+		offset = virt_addr & ~PMD_PAGE_MASK;
+		break;
+	default:
+		phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
+		offset = virt_addr & ~PAGE_MASK;
+	}
+
+	return (phys_addr_t)(phys_addr | offset);
 }
 EXPORT_SYMBOL_GPL(slow_virt_to_phys);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
