Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD98A6B0311
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v4so33939098wmb.8
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:23:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r22si1122357wrc.146.2017.05.16.02.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:23:46 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4G9Neqj018351
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:45 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2afw3s4jxs-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:45 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 03:23:44 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 1/9] mm/hugetlb/migration: Use set_huge_pte_at instead of set_pte_at
Date: Tue, 16 May 2017 14:53:24 +0530
In-Reply-To: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1494926612-23928-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

The right interface to use to set a hugetlb pte entry is set_huge_pte_at. Use
that instead of set_pte_at.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
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
