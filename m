Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6936B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 13:51:55 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id tt10so162429763pab.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 10:51:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z66si16727562pfa.79.2016.03.14.10.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 10:51:54 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 35/50] x86/mm: Fix slow_virt_to_phys() for X86_PAE again
Date: Mon, 14 Mar 2016 10:50:53 -0700
Message-Id: <20160314175018.367163035@linuxfoundation.org>
In-Reply-To: <20160314175013.403628835@linuxfoundation.org>
References: <20160314175013.403628835@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dexuan Cui <decui@microsoft.com>, Toshi Kani <toshi.kani@hpe.com>, olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org, linux-mm@kvack.org, apw@canonical.com, Andrew Morton <akpm@linux-foundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dexuan Cui <decui@microsoft.com>

commit bf70e5513dfea29c3682e7eb3dbb45f0723bac09 upstream.

"d1cd12108346: x86, pageattr: Prevent overflow in slow_virt_to_phys() for
X86_PAE" was unintentionally removed by the recent "34437e67a672: x86/mm: Fix
slow_virt_to_phys() to handle large PAT bit".

And, the variable 'phys_addr' was defined as "unsigned long" by mistake -- it should
be "phys_addr_t".

As a result, Hyper-V network driver in 32-PAE Linux guest can't work again.

Fixes: commit 34437e67a672: "x86/mm: Fix slow_virt_to_phys() to handle large PAT bit"
Signed-off-by: Dexuan Cui <decui@microsoft.com>
Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
Cc: olaf@aepfle.de
Cc: jasowang@redhat.com
Cc: driverdev-devel@linuxdriverproject.org
Cc: linux-mm@kvack.org
Cc: apw@canonical.com
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: K. Y. Srinivasan <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Link: http://lkml.kernel.org/r/1456394292-9030-1-git-send-email-decui@microsoft.com
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/mm/pageattr.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -414,24 +414,30 @@ pmd_t *lookup_pmd_address(unsigned long
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
