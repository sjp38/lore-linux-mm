Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 001086B0337
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 18:55:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n11so244268702pfg.7
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 15:55:22 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id h184si263966pge.63.2017.03.23.15.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 15:55:22 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v1 1/5] sparc64: simplify vmemmap_populate
Date: Thu, 23 Mar 2017 19:01:49 -0400
Message-Id: <1490310113-824438-2-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
References: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.or

Remove duplicating code, by using common functions
vmemmap_pud_populate and vmemmap_pgd_populate functions.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 arch/sparc/mm/init_64.c |   23 ++++++-----------------
 1 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 2c0cb2a..01eccab 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2526,30 +2526,19 @@ int __meminit vmemmap_populate(unsigned long vstart, unsigned long vend,
 	vstart = vstart & PMD_MASK;
 	vend = ALIGN(vend, PMD_SIZE);
 	for (; vstart < vend; vstart += PMD_SIZE) {
-		pgd_t *pgd = pgd_offset_k(vstart);
+		pgd_t *pgd = vmemmap_pgd_populate(vstart, node);
 		unsigned long pte;
 		pud_t *pud;
 		pmd_t *pmd;
 
-		if (pgd_none(*pgd)) {
-			pud_t *new = vmemmap_alloc_block(PAGE_SIZE, node);
+		if (!pgd)
+			return -ENOMEM;
 
-			if (!new)
-				return -ENOMEM;
-			pgd_populate(&init_mm, pgd, new);
-		}
-
-		pud = pud_offset(pgd, vstart);
-		if (pud_none(*pud)) {
-			pmd_t *new = vmemmap_alloc_block(PAGE_SIZE, node);
-
-			if (!new)
-				return -ENOMEM;
-			pud_populate(&init_mm, pud, new);
-		}
+		pud = vmemmap_pud_populate(pgd, vstart, node);
+		if (!pud)
+			return -ENOMEM;
 
 		pmd = pmd_offset(pud, vstart);
-
 		pte = pmd_val(*pmd);
 		if (!(pte & _PAGE_VALID)) {
 			void *block = vmemmap_alloc_block(PMD_SIZE, node);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
