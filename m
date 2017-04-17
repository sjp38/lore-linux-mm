Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0B176B03A4
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z62so16226711wrc.0
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 10:12:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 62si12168890wrm.255.2017.04.17.10.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 10:12:11 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3HH969k086751
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:10 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29vwu0js4p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 13:12:10 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 17 Apr 2017 13:12:09 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/7] mm/hugetlb/migration: Use set_huge_pte_at instead of set_pte_at
Date: Mon, 17 Apr 2017 22:41:40 +0530
In-Reply-To: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1492449106-27467-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

The right interface to use to set a hugetlb pte entry is set_huge_pte_at. Use
that instead of set_pte_at.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 mm/migrate.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 9a0897a14d37..4c272ac6fe53 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -224,25 +224,26 @@ static int remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		if (is_write_migration_entry(entry))
 			pte = maybe_mkwrite(pte, vma);
 
+		flush_dcache_page(new);
 #ifdef CONFIG_HUGETLB_PAGE
 		if (PageHuge(new)) {
 			pte = pte_mkhuge(pte);
 			pte = arch_make_huge_pte(pte, vma, new, 0);
-		}
-#endif
-		flush_dcache_page(new);
-		set_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
-
-		if (PageHuge(new)) {
+			set_huge_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
 			if (PageAnon(new))
 				hugepage_add_anon_rmap(new, vma, pvmw.address);
 			else
 				page_dup_rmap(new, true);
-		} else if (PageAnon(new))
-			page_add_anon_rmap(new, vma, pvmw.address, false);
-		else
-			page_add_file_rmap(new, false);
+		} else
+#endif
+		{
+			set_pte_at(vma->vm_mm, pvmw.address, pvmw.pte, pte);
 
+			if (PageAnon(new))
+				page_add_anon_rmap(new, vma, pvmw.address, false);
+			else
+				page_add_file_rmap(new, false);
+		}
 		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
 			mlock_vma_page(new);
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
