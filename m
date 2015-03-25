Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E12846B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 05:12:08 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so22355896pdb.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:12:08 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id xs1si2824784pbb.21.2015.03.25.02.12.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 02:12:07 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH 5/6] mm/gup: Replace ACCESS_ONCE with READ_ONCE for STRICT_MM_TYPECHECKS
Date: Wed, 25 Mar 2015 20:11:58 +1100
Message-Id: <1427274719-25890-5-git-send-email-mpe@ellerman.id.au>
In-Reply-To: <1427274719-25890-1-git-send-email-mpe@ellerman.id.au>
References: <1427274719-25890-1-git-send-email-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@ozlabs.org
Cc: linux-kernel@vger.kernel.org, aneesh.kumar@in.ibm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, borntraeger@de.ibm.com, steve.capper@linaro.org, linux-mm@kvack.org

If STRICT_MM_TYPECHECKS is enabled the generic gup code fails to build
because we are using ACCESS_ONCE on non-scalar types.

Convert all uses to READ_ONCE.

Cc: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com
Cc: aarcange@redhat.com
Cc: borntraeger@de.ibm.com
Cc: steve.capper@linaro.org
Cc: linux-mm@kvack.org
Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 mm/gup.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index a6e24e246f86..120c3adc843c 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -901,7 +901,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		 *
 		 * for an example see gup_get_pte in arch/x86/mm/gup.c
 		 */
-		pte_t pte = ACCESS_ONCE(*ptep);
+		pte_t pte = READ_ONCE(*ptep);
 		struct page *page;
 
 		/*
@@ -1191,7 +1191,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	local_irq_save(flags);
 	pgdp = pgd_offset(mm, addr);
 	do {
-		pgd_t pgd = ACCESS_ONCE(*pgdp);
+		pgd_t pgd = READ_ONCE(*pgdp);
 
 		next = pgd_addr_end(addr, end);
 		if (pgd_none(pgd))
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
