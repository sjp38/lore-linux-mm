Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 114F18E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:42:23 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d71so13269810pgc.1
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:42:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i4si13596402pfg.218.2018.12.18.01.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 01:42:22 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBI9eU2q143775
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:42:21 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pewf53aha-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:42:21 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 18 Dec 2018 09:42:20 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V4 4/5] mm/hugetlb: Add prot_modify_start/commit sequence for hugetlb update
Date: Tue, 18 Dec 2018 15:11:36 +0530
In-Reply-To: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com>
References: <20181218094137.13732-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20181218094137.13732-5-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: npiggin@gmail.com, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, akpm@linux-foundation.org, x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

Architectures like ppc64 requires to do a conditional tlb flush based on the old
and new value of pte. Follow the regular pte change protection sequence for
hugetlb too. This allow the architectures to override the update sequence.

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
index 705a3e9cc910..353bff385595 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4388,10 +4388,12 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
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
2.19.2
