Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1EB8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:51:18 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z68so4709000qkb.14
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:51:18 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z34si1473909qvg.50.2019.01.16.00.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 00:51:17 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0G8n3Ve083356
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:51:17 -0500
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q1ybepau3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:51:16 -0500
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 16 Jan 2019 08:51:16 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V5 4/5] mm/hugetlb: Add prot_modify_start/commit sequence for hugetlb update
Date: Wed, 16 Jan 2019 14:20:34 +0530
In-Reply-To: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190116085035.29729-5-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

Architectures like ppc64 require to do a conditional tlb flush based on the old
and new value of pte. Follow the regular pte change protection sequence for
hugetlb too. This allows the architectures to override the update sequence.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 include/linux/hugetlb.h | 20 ++++++++++++++++++++
 mm/hugetlb.c            |  8 +++++---
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 087fd5f48c91..39e78b80375c 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -543,6 +543,26 @@ static inline void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr
 	set_huge_pte_at(mm, addr, ptep, pte);
 }
 #endif
+
+#ifndef huge_ptep_modify_prot_start
+#define huge_ptep_modify_prot_start huge_ptep_modify_prot_start
+static inline pte_t huge_ptep_modify_prot_start(struct vm_area_struct *vma,
+						unsigned long addr, pte_t *ptep)
+{
+	return huge_ptep_get_and_clear(vma->vm_mm, addr, ptep);
+}
+#endif
+
+#ifndef huge_ptep_modify_prot_commit
+#define huge_ptep_modify_prot_commit huge_ptep_modify_prot_commit
+static inline void huge_ptep_modify_prot_commit(struct vm_area_struct *vma,
+						unsigned long addr, pte_t *ptep,
+						pte_t old_pte, pte_t pte)
+{
+	set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
+}
+#endif
+
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
 #define alloc_huge_page(v, a, r) NULL
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index df2e7dd5ff17..f824d2200ca9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4387,10 +4387,12 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 			continue;
 		}
 		if (!huge_pte_none(pte)) {
-			pte = huge_ptep_get_and_clear(mm, address, ptep);
-			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
+			pte_t old_pte;
+
+			old_pte = huge_ptep_modify_prot_start(vma, address, ptep);
+			pte = pte_mkhuge(huge_pte_modify(old_pte, newprot));
 			pte = arch_make_huge_pte(pte, vma, NULL, 0);
-			set_huge_pte_at(mm, address, ptep, pte);
+			huge_ptep_modify_prot_commit(vma, address, ptep, old_pte, pte);
 			pages++;
 		}
 		spin_unlock(ptl);
-- 
2.20.1
