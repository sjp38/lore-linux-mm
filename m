Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFF2C6B0315
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:52 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q6so118631451pgn.12
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:23:52 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d13si12890688pln.47.2017.05.16.02.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:23:52 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4G9No0r127249
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:51 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2afs4sekmj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:23:51 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 May 2017 03:23:50 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v2 3/9] mm/hugetlb: export hugetlb_entry_migration helper
Date: Tue, 16 May 2017 14:53:26 +0530
In-Reply-To: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1494926612-23928-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1494926612-23928-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We will be using this later from the ppc64 code. Change the return type to bool.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/hugetlb.h | 1 +
 mm/hugetlb.c            | 8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index b857fc8cc2ec..fddf6cf403d5 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -126,6 +126,7 @@ int pud_huge(pud_t pud);
 unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 		unsigned long address, unsigned long end, pgprot_t newprot);
 
+bool is_hugetlb_entry_migration(pte_t pte);
 #else /* !CONFIG_HUGETLB_PAGE */
 
 static inline void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ce090186b992..25e2ee888a90 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3182,17 +3182,17 @@ static void set_huge_ptep_writable(struct vm_area_struct *vma,
 		update_mmu_cache(vma, address, ptep);
 }
 
-static int is_hugetlb_entry_migration(pte_t pte)
+bool is_hugetlb_entry_migration(pte_t pte)
 {
 	swp_entry_t swp;
 
 	if (huge_pte_none(pte) || pte_present(pte))
-		return 0;
+		return false;
 	swp = pte_to_swp_entry(pte);
 	if (non_swap_entry(swp) && is_migration_entry(swp))
-		return 1;
+		return true;
 	else
-		return 0;
+		return false;
 }
 
 static int is_hugetlb_entry_hwpoisoned(pte_t pte)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
