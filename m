Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 34DFA6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:20:02 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id z8so8726864ige.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 00:20:02 -0800 (PST)
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net (p3plsmtps2ded03.prod.phx3.secureserver.net. [208.109.80.60])
        by mx.google.com with ESMTPS id vs5si3018111igb.33.2016.02.25.00.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 00:20:01 -0800 (PST)
From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH] x86/mm: fix slow_virt_to_phys() for X86_PAE again
Date: Thu, 25 Feb 2016 01:58:12 -0800
Message-Id: <1456394292-9030-1-git-send-email-decui@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, toshi.kani@hpe.com, akpm@linux-foundation.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org, jasowang@redhat.com
Cc: olaf@aepfle.de, apw@canonical.com, kys@microsoft.com, haiyangz@microsoft.com

"d1cd12108346: x86, pageattr: Prevent overflow in slow_virt_to_phys() for X86_PAE"
was unintentionally removed by the recent
"34437e67a672: x86/mm: Fix slow_virt_to_phys() to handle large PAT bit".

And, the variable 'phys_addr' was defined as "unsigned long" by mistake -- it should
be "phys_addr_t".

As a result, Hyper-V network driver in 32-PAE Linux guest can't work again.

Fixes: "commmit 34437e67a672: x86/mm: Fix slow_virt_to_phys() to handle large PAT bit"
Signed-off-by: Dexuan Cui <decui@microsoft.com>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: K. Y. Srinivasan <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org
Cc: olaf@aepfle.de
Cc: apw@canonical.com
Cc: jasowang@redhat.com
Cc: stable@vger.kernel.org
---
 arch/x86/mm/pageattr.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 2440814..9cf96d8 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -419,24 +419,30 @@ pmd_t *lookup_pmd_address(unsigned long address)
 phys_addr_t slow_virt_to_phys(void *__virt_addr)
 {
 	unsigned long virt_addr = (unsigned long)__virt_addr;
-	unsigned long phys_addr, offset;
+	phys_addr_t phys_addr;
+	unsigned long offset;
 	enum pg_level level;
 	pte_t *pte;
 
 	pte = lookup_address(virt_addr, &level);
 	BUG_ON(!pte);
 
+	/*
+	 * pXX_pfn() returns unsigned long, which must be cast to phys_addr_t
+	 * before being left-shifted PAGE_SHIFT bits -- this trick is to
+	 * make 32-PAE kernel work correctly.
+	 */
 	switch (level) {
 	case PG_LEVEL_1G:
-		phys_addr = pud_pfn(*(pud_t *)pte) << PAGE_SHIFT;
+		phys_addr = (phys_addr_t)pud_pfn(*(pud_t *)pte) << PAGE_SHIFT;
 		offset = virt_addr & ~PUD_PAGE_MASK;
 		break;
 	case PG_LEVEL_2M:
-		phys_addr = pmd_pfn(*(pmd_t *)pte) << PAGE_SHIFT;
+		phys_addr = (phys_addr_t)pmd_pfn(*(pmd_t *)pte) << PAGE_SHIFT;
 		offset = virt_addr & ~PMD_PAGE_MASK;
 		break;
 	default:
-		phys_addr = pte_pfn(*pte) << PAGE_SHIFT;
+		phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
 		offset = virt_addr & ~PAGE_MASK;
 	}
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
