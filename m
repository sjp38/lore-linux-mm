Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j7HJ9joA030342
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:09:45 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j7HJ9jKl275718
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:09:45 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j7HJ9iFp017362
	for <linux-mm@kvack.org>; Wed, 17 Aug 2005 15:09:45 -0400
Subject: [PATCH 3/4] x86-walk-check
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1124304966.3139.37.camel@localhost.localdomain>
References: <1124304966.3139.37.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 17 Aug 2005 14:04:29 -0500
Message-Id: <1124305469.3139.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: christoph@lameter.com, ak@suse.de, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

Initial Post (Wed, 17 Aug 2005)

For demand faulting, we cannot assume that the page tables will be populated.
Do what the rest of the architectures do and test p?d_present() while walking
down the page table.

Diffed against 2.6.13-rc6-git7

Signed-off-by: Adam Litke <agl@us.ibm.com>

---
 hugetlbpage.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)
diff -upN reference/arch/i386/mm/hugetlbpage.c current/arch/i386/mm/hugetlbpage.c
--- reference/arch/i386/mm/hugetlbpage.c
+++ current/arch/i386/mm/hugetlbpage.c
@@ -46,8 +46,12 @@ pte_t *huge_pte_offset(struct mm_struct 
 	pmd_t *pmd = NULL;
 
 	pgd = pgd_offset(mm, addr);
-	pud = pud_offset(pgd, addr);
-	pmd = pmd_offset(pud, addr);
+	if (pgd_present(*pgd)) {
+		pud = pud_offset(pgd, addr);
+		if (pud_present(*pud)) {
+			pmd = pmd_offset(pud, addr);
+		}
+	}
 	return (pte_t *) pmd;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
