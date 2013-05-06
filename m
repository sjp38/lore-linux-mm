Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 3FCB76B00B7
	for <linux-mm@kvack.org>; Mon,  6 May 2013 16:50:16 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 7 May 2013 02:16:19 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 4D29F125804E
	for <linux-mm@kvack.org>; Tue,  7 May 2013 02:21:53 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r46Knwlj7799066
	for <linux-mm@kvack.org>; Tue, 7 May 2013 02:20:00 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r46Ko51l025154
	for <linux-mm@kvack.org>; Tue, 7 May 2013 06:50:05 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/THP: Use the right function when updating access flags
Date: Tue,  7 May 2013 02:19:48 +0530
Message-Id: <1367873388-12338-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We should use pmdp_set_access_flags to update access flags. Archs like powerpc
use extra checks(_PAGE_BUSY) when updating a hugepage PTE. A set_pmd_at doesn't
do those checks. We should use set_pmd_at only when updating a none hugepage PTE.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/huge_memory.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d1cecb9..af20bb1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1265,7 +1265,9 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		 * young bit, instead of the current set_pmd_at.
 		 */
 		_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
-		set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmd, _pmd);
+		if (pmdp_set_access_flags(vma, addr & HPAGE_PMD_MASK,
+					  pmd, _pmd,  1))
+			update_mmu_cache_pmd(vma, addr, pmd);
 	}
 	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
 		if (page->mapping && trylock_page(page)) {
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
