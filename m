Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4C06B007E
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 07:11:56 -0500 (EST)
Received: by mail-pf0-f174.google.com with SMTP id n5so939379pfn.2
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 04:11:56 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id s8si12218091pfi.10.2016.03.09.04.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 04:11:55 -0800 (PST)
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 9 Mar 2016 22:11:51 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 1A29C2CE8056
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 23:11:48 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u29CBdW043188324
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:47 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u29CBFks021451
	for <linux-mm@kvack.org>; Wed, 9 Mar 2016 23:11:15 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 3/9] mm/gup: Make follow_page_mask function PGD implementation aware
Date: Wed,  9 Mar 2016 17:40:44 +0530
Message-Id: <1457525450-4262-3-git-send-email-khandual@linux.vnet.ibm.com>
In-Reply-To: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1457525450-4262-1-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aneesh.kumar@linux.vnet.ibm.com, mpe@ellerman.id.au

Currently the function 'follow_page_mask' does not take into account
PGD based huge page implementation. This change achieves that and
makes it complete.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/gup.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index 7bf19ff..53a2013 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -232,6 +232,12 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
 		return no_page_table(vma, flags);
+	if (pgd_huge(*pgd) && vma->vm_flags & VM_HUGETLB) {
+		page = follow_huge_pgd(mm, address, pgd, flags);
+		if (page)
+			return page;
+		return no_page_table(vma, flags);
+	}
 
 	pud = pud_offset(pgd, address);
 	if (pud_none(*pud))
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
