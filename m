Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB106B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 14:43:57 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id hm4so1812781wib.14
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 11:43:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x46si13333584eea.269.2014.04.04.11.43.54
        for <linux-mm@kvack.org>;
        Fri, 04 Apr 2014 11:43:55 -0700 (PDT)
Date: Fri, 04 Apr 2014 14:43:33 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <533efd6b.46250e0a.4a07.5836SMTPIN_ADDED_BROKEN@mx.google.com>
Subject: [PATCH] mm/hugetlb.c: add NULL check of return value of
 huge_pte_offset
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, andi@firstfloor.org, sasha.levin@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org

huge_pte_offset() could return NULL, so we need NULL check to avoid
potential NULL pointer dereferences.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7222247a590b..b8f2bde6ca53 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2662,7 +2662,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 				BUG_ON(huge_pte_none(pte));
 				spin_lock(ptl);
 				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
-				if (likely(pte_same(huge_ptep_get(ptep), pte)))
+				if (likely(ptep &&
+					   pte_same(huge_ptep_get(ptep), pte)))
 					goto retry_avoidcopy;
 				/*
 				 * race occurs while re-acquiring page table
@@ -2706,7 +2707,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	spin_lock(ptl);
 	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
-	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
+	if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
 		ClearPagePrivate(new_page);
 
 		/* Break COW */
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
