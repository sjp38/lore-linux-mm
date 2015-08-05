Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3D46E9003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 17:45:28 -0400 (EDT)
Received: by oigu206 with SMTP id u206so16967247oig.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 14:45:28 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id b69si2995210oig.100.2015.08.05.14.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 14:45:25 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 6/10] x86/mm: Fix slow_virt_to_phys() to handle large PAT bit
Date: Wed,  5 Aug 2015 15:43:29 -0600
Message-Id: <1438811013-30983-7-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

slow_virt_to_phys() calls lookup_address() to obtain *pte and
its level.  It then calls pte_pfn() to obtain the PFN for any
level.  This does not result the correct PFN when the large
PAT bit is set because pte_pfn() does not mask the large PAT bit
properly for PUD/PMD.

Fix slow_virt_to_phys() to use pud_pfn() and pmd_pfn() according
to the level.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
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
index 727158c..ecc24e5 100644
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
