Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id C0F6C6B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 07:05:12 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id i185so233767411ywg.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 04:05:12 -0700 (PDT)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id f65si21560713qge.28.2016.05.31.04.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 04:05:11 -0700 (PDT)
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 31 May 2016 07:05:11 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/2] powerpc/mm: check for irq disabled() only if DEBUG_VM is enabled.
Date: Tue, 31 May 2016 16:34:48 +0530
Message-Id: <1464692688-6612-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1464692688-6612-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1464692688-6612-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We don't need to check this always. The idea here is to capture the
wrong usage of find_linux_pte_or_hugepte and we can do that by
occasionally running with DEBUG_VM enabled.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index ee09e99097f0..9bd87f269d6d 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -71,10 +71,8 @@ pte_t *__find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
 static inline pte_t *find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
 					       bool *is_thp, unsigned *shift)
 {
-	if (!arch_irqs_disabled()) {
-		pr_info("%s called with irq enabled\n", __func__);
-		dump_stack();
-	}
+	VM_WARN(!arch_irqs_disabled(),
+		"%s called with irq enabled\n", __func__);
 	return __find_linux_pte_or_hugepte(pgdir, ea, is_thp, shift);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
