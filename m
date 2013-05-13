Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 563D36B0034
	for <linux-mm@kvack.org>; Mon, 13 May 2013 10:56:53 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 14 May 2013 11:54:28 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E80A12BB0051
	for <linux-mm@kvack.org>; Tue, 14 May 2013 00:56:46 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4DEgcr218088102
	for <linux-mm@kvack.org>; Tue, 14 May 2013 00:42:40 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4DEuiMd005004
	for <linux-mm@kvack.org>; Tue, 14 May 2013 00:56:44 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2] mm/THP: Use pmd_populate to update the pmd with pgtable_t pointer
Date: Mon, 13 May 2013 20:26:40 +0530
Message-Id: <1368457000-20874-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We should not use set_pmd_at to update pmd_t with pgtable_t pointer. set_pmd_at
is used to set pmd with huge pte entries and architectures like ppc64, clear
few flags from the pte when saving a new entry. Without this change we observe
bad pte errors like below on ppc64 with THP enabled.

BUG: Bad page map in process ld mm=0xc000001ee39f4780 pte:7fc3f37848000001 pmd:c000001ec0000000
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/huge_memory.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 03a89a2..362c329 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2325,7 +2325,12 @@ static void collapse_huge_page(struct mm_struct *mm,
 		pte_unmap(pte);
 		spin_lock(&mm->page_table_lock);
 		BUG_ON(!pmd_none(*pmd));
-		set_pmd_at(mm, address, pmd, _pmd);
+		/*
+		 * We can only use set_pmd_at when establishing
+		 * hugepmds and never for establishing regular pmds that
+		 * points to regular pagetables. Use pmd_populate for that
+		 */
+		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
 		spin_unlock(&mm->page_table_lock);
 		anon_vma_unlock_write(vma->anon_vma);
 		goto out;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
