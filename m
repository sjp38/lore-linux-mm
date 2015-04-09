Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 21C776B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 12:12:29 -0400 (EDT)
Received: by wgso17 with SMTP id o17so13542560wgs.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 09:12:28 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id v10si24870579wie.88.2015.04.09.09.12.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 09:12:27 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 9 Apr 2015 17:12:26 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 79DDA1B08061
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 17:12:56 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t39GCOio55115874
	for <linux-mm@kvack.org>; Thu, 9 Apr 2015 16:12:24 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t39GCNQ7020119
	for <linux-mm@kvack.org>; Thu, 9 Apr 2015 10:12:24 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH] mm/hugetlb: use pmd_page() in follow_huge_pmd()
Date: Thu,  9 Apr 2015 18:11:35 +0200
Message-Id: <1428595895-24140-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, stable@vger.kernel.org.#.v3.12

commit 61f77eda "mm/hugetlb: reduce arch dependent code around follow_huge_*"
broke follow_huge_pmd() on s390, where pmd and pte layout differ and using
pte_page() on a huge pmd will return wrong results. Using pmd_page() instead
fixes this.

All architectures that were touched by commit 61f77eda have pmd_page()
defined, so this should not break anything on other architectures.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: stable@vger.kernel.org # v3.12
---
 mm/hugetlb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e8c92ae..271e443 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3865,8 +3865,7 @@ retry:
 	if (!pmd_huge(*pmd))
 		goto out;
 	if (pmd_present(*pmd)) {
-		page = pte_page(*(pte_t *)pmd) +
-			((address & ~PMD_MASK) >> PAGE_SHIFT);
+		page = pmd_page(*pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
 		if (flags & FOLL_GET)
 			get_page(page);
 	} else {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
