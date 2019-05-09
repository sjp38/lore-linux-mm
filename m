Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D978AC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:07:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F24D2177E
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:07:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Zuhx6KBF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F24D2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2053E6B000C; Thu,  9 May 2019 12:07:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B5066B000D; Thu,  9 May 2019 12:07:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07CB06B000E; Thu,  9 May 2019 12:07:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD84A6B000C
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:07:40 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id k8so2553704itd.0
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:07:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=NVGYH0XHby9mmyeGkuUXvJdFcYxk3J6W0cOvDLlMUJI=;
        b=GfDWDfcVg29ZXoDMEMFBq8A7hbLZfg896Tn+RbHIwHnzxql9aF14sK+I6Lcxz4EjHo
         DA4YtBDjnLVW0i8FaA3FBOmrxq1fMBfgoYurmBU9SfO4R3D41owAleOEAIaqMVkXKXpr
         BbcR/BpRfZxICrkLZkoOgJ6xFlvxyyzeA6BHmUK/0tFrwFiQiakkf4a+QXBLV7BTXxpn
         6MASZHMMih4cnLW1gH4gMlAGGkP8LSvhgh/3p2/Df3vC2oPyvOkbqgCZn/tYYGfxOE0D
         vXkJWLb4BPYlR1M6pYuRO8i3oLbqzGrNvXiY0htEhS7gGnYLBw4MazzehZ481wUcjmvx
         vFaA==
X-Gm-Message-State: APjAAAVyO8CkgN092vKfOFQ3EaiNEHx2TTtP4ULrhM3xOMx8rqcLeGkP
	QFXqqrqo+l1Y9ECCddh4XOsXc8e46xBGxEgU3TLCyfx+/aL8pp/H9OqU/1eKl+XRUi17X+ExpTq
	8oKP0/EphHVggBa69TZCyO5xl5VGqGVKirQeSpkY6u84jBCpvULXWkx27y8E71rMEUA==
X-Received: by 2002:a05:660c:50:: with SMTP id p16mr3717238itk.146.1557418060539;
        Thu, 09 May 2019 09:07:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzssxOXRR9kOI/WUZsZNQbtigj7Obr4xHQu2NI2gTgoj8+mHwl6JpHykASNvs2WtTop7Pt6
X-Received: by 2002:a05:660c:50:: with SMTP id p16mr3717154itk.146.1557418059567;
        Thu, 09 May 2019 09:07:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557418059; cv=none;
        d=google.com; s=arc-20160816;
        b=K6K+Iy0dUIFcisAdf96RZtgwYbiuV9+p7JCZv4vnVHDQJFPrffTn4N4K+ZMaHQStQo
         VeNxi9Ojv35PCf8EYr6qrt5KA78wUAU6+4coqFDFJlZ/mrLcDmXsLvzuU+cfAbtfEHdj
         kg6oeVDZCYmdws7bwR/TDAia3jCUDWESeG7AtGdIhiPcStlVI+IA/x7l2j5aSZhDMRCv
         eeC18F3ll/C1r98n7TyTs1hedafEplUUBXhGdGAsiceSUf3aO5QEE/Ve1R+JmAPntfWM
         6zLKcuKES31zQ8Q5erCw46hFDz9de4hkpoxXlgcKso94eMg2sjot8BLQd2CBRXVbSaLR
         MVtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=NVGYH0XHby9mmyeGkuUXvJdFcYxk3J6W0cOvDLlMUJI=;
        b=MgFxyxjdJZ/bKlAq3OTis/+7RSE6QEJ+cLaOgvTAwMfvAYjac3qHtLK3SLz8vlo1wr
         hdLRlZM8cYPgcBg+3VtCU9xK4i0l9RlNvi1rq+2+G8HlwcWeGyG7rCuTgJSps0n7kTNn
         ZF4clPW7/1erCyeHW4s6r5BjMNi9TxdBw3pNO30UgGyAeSLW3nJVYE9BXWxNaeFj/EjZ
         uf5BqoQiNCmEH10ItB/uKa8yoba6sXHpQmi3fTViwMlBIqkCJ2xO2SfrhxLdtrs2E3Fn
         4HcZBapLWBevsVLeea9zAk3wyIqjZrpJ65kLQT21KhTjB4ogzohf2YSqTs3EiXu4prNP
         LZ0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Zuhx6KBF;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l125si1727961itl.142.2019.05.09.09.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:07:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Zuhx6KBF;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x49G45Bt084958;
	Thu, 9 May 2019 16:07:34 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=NVGYH0XHby9mmyeGkuUXvJdFcYxk3J6W0cOvDLlMUJI=;
 b=Zuhx6KBF03D4sbzFJBYrPcOti8y68kH09lRoZi33teE1ALdB5B0gZwRprt8Q3h2uRBqK
 gS2QwdnN6huCIBHNvrSbYkW+Ey58b9ROHXooo6HelsugaGKhmyEQBas+SiNXu9+luH5z
 J5OERohj7mlWv+n7RqiaUtlmQwYMUZ29cR9Mc2oJ2zEPGebfAZCDotyidPoFUwt/3f3N
 15+f1kVwADR6NXEo9bNga1+zdymzkuHNC9SQXouPePz9JOy0DZuwtITJ8W1NkhX3aIeN
 v15pow2qS/J09k75VhLZ08aNneZQeYnTFNd7huX/fazGOqIzi8eZ2YTVF5mHwUFs0VV+ Qg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2s94bgbyus-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 09 May 2019 16:07:33 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x49G7672142274;
	Thu, 9 May 2019 16:07:33 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2schvywx4m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 09 May 2019 16:07:32 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x49G7VDb010297;
	Thu, 9 May 2019 16:07:31 GMT
Received: from oracle.com (/75.80.107.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 09 May 2019 09:07:31 -0700
From: Larry Bassel <larry.bassel@oracle.com>
To: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nvdimm@lists.01.org
Cc: Larry Bassel <larry.bassel@oracle.com>
Subject: [PATCH, RFC 2/2] Implement sharing/unsharing of PMDs for FS/DAX
Date: Thu,  9 May 2019 09:05:33 -0700
Message-Id: <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905090092
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905090092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is based on (but somewhat different from) what hugetlbfs
does to share/unshare page tables.

Signed-off-by: Larry Bassel <larry.bassel@oracle.com>
---
 include/linux/hugetlb.h |   4 ++
 mm/huge_memory.c        |  32 ++++++++++++++
 mm/hugetlb.c            |  21 ++++++++--
 mm/memory.c             | 108 +++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 160 insertions(+), 5 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 11943b6..9ed9542 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -142,6 +142,10 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
 void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
 				unsigned long *start, unsigned long *end);
+unsigned long page_table_shareable(struct vm_area_struct *svma,
+				   struct vm_area_struct *vma,
+				   unsigned long addr, pgoff_t idx);
+bool vma_shareable(struct vm_area_struct *vma, unsigned long addr);
 struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
 			      int write);
 struct page *follow_huge_pd(struct vm_area_struct *vma,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b6a34b3..e1627c3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1747,6 +1747,33 @@ static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
 	mm_dec_nr_ptes(mm);
 }
 
+#ifdef CONFIG_MAY_SHARE_FSDAX_PMD
+static int unshare_huge_pmd(struct mm_struct *mm, unsigned long addr,
+			    pmd_t *pmdp)
+{
+	pgd_t *pgd = pgd_offset(mm, addr);
+	p4d_t *p4d = p4d_offset(pgd, addr);
+	pud_t *pud = pud_offset(p4d, addr);
+
+	WARN_ON(page_count(virt_to_page(pmdp)) == 0);
+	if (page_count(virt_to_page(pmdp)) == 1)
+		return 0;
+
+	pud_clear(pud);
+	put_page(virt_to_page(pmdp));
+	mm_dec_nr_pmds(mm);
+	return 1;
+}
+
+#else
+static int unshare_huge_pmd(struct mm_struct *mm, unsigned long addr,
+			    pmd_t *pmdp)
+{
+	return 0;
+}
+
+#endif
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
@@ -1764,6 +1791,11 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	 * pgtable_trans_huge_withdraw after finishing pmdp related
 	 * operations.
 	 */
+	if (unshare_huge_pmd(vma->vm_mm, addr, pmd)) {
+		spin_unlock(ptl);
+		return 1;
+	}
+
 	orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
 			tlb->fullmm);
 	tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 641cedf..919a290 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4594,9 +4594,9 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
 }
 
 #ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
-static unsigned long page_table_shareable(struct vm_area_struct *svma,
-				struct vm_area_struct *vma,
-				unsigned long addr, pgoff_t idx)
+unsigned long page_table_shareable(struct vm_area_struct *svma,
+				   struct vm_area_struct *vma,
+				   unsigned long addr, pgoff_t idx)
 {
 	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
 				svma->vm_start;
@@ -4619,7 +4619,7 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
 	return saddr;
 }
 
-static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
+bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
 {
 	unsigned long base = addr & PUD_MASK;
 	unsigned long end = base + PUD_SIZE;
@@ -4763,6 +4763,19 @@ void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
 				unsigned long *start, unsigned long *end)
 {
 }
+
+unsigned long page_table_shareable(struct vm_area_struct *svma,
+				   struct vm_area_struct *vma,
+				   unsigned long addr, pgoff_t idx)
+{
+	return 0;
+}
+
+bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
+{
+	return false;
+}
+
 #define want_pmd_share()	(0)
 #endif /* CONFIG_ARCH_WANT_HUGE_PMD_SHARE */
 
diff --git a/mm/memory.c b/mm/memory.c
index f7d962d..4c1814c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3845,6 +3845,109 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
 	return 0;
 }
 
+#ifdef CONFIG_MAY_SHARE_FSDAX_PMD
+static pmd_t *huge_pmd_offset(struct mm_struct *mm,
+			      unsigned long addr, unsigned long sz)
+{
+	pgd_t *pgd;
+	p4d_t *p4d;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+		return NULL;
+	p4d = p4d_offset(pgd, addr);
+	if (!p4d_present(*p4d))
+		return NULL;
+
+	pud = pud_offset(p4d, addr);
+	if (sz != PUD_SIZE && pud_none(*pud))
+		return NULL;
+	/* hugepage or swap? */
+	if (pud_huge(*pud) || !pud_present(*pud))
+		return (pmd_t *)pud;
+
+	pmd = pmd_offset(pud, addr);
+	if (sz != PMD_SIZE && pmd_none(*pmd))
+		return NULL;
+	/* hugepage or swap? */
+	if (pmd_huge(*pmd) || !pmd_present(*pmd))
+		return pmd;
+
+	return NULL;
+}
+
+static pmd_t *pmd_share(struct mm_struct *mm, pud_t *pud, unsigned long addr)
+{
+	struct vm_area_struct *vma = find_vma(mm, addr);
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	pgoff_t idx = ((addr - vma->vm_start) >> PAGE_SHIFT) +
+			vma->vm_pgoff;
+	struct vm_area_struct *svma;
+	unsigned long saddr;
+	pmd_t *spmd = NULL;
+	pmd_t *pmd;
+	spinlock_t *ptl;
+
+	if (!vma_shareable(vma, addr))
+		return pmd_alloc(mm, pud, addr);
+
+	i_mmap_lock_write(mapping);
+
+	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
+		if (svma == vma)
+			continue;
+
+		saddr = page_table_shareable(svma, vma, addr, idx);
+		if (saddr) {
+			spmd = huge_pmd_offset(svma->vm_mm, saddr,
+					       vma_mmu_pagesize(svma));
+			if (spmd) {
+				get_page(virt_to_page(spmd));
+				break;
+			}
+		}
+	}
+
+	if (!spmd)
+		goto out;
+
+	ptl = pmd_lockptr(mm, spmd);
+	spin_lock(ptl);
+
+	if (pud_none(*pud)) {
+		pud_populate(mm, pud,
+			    (pmd_t *)((unsigned long)spmd & PAGE_MASK));
+		mm_inc_nr_pmds(mm);
+	} else {
+		put_page(virt_to_page(spmd));
+	}
+	spin_unlock(ptl);
+out:
+	pmd = pmd_alloc(mm, pud, addr);
+	i_mmap_unlock_write(mapping);
+	return pmd;
+}
+
+static bool may_share_pmd(struct vm_area_struct *vma)
+{
+	if (vma_is_fsdax(vma))
+		return true;
+	return false;
+}
+#else
+static pmd_t *pmd_share(struct mm_struct *mm, pud_t *pud, unsigned long addr)
+{
+	return pmd_alloc(mm, pud, addr);
+}
+
+static bool may_share_pmd(struct vm_area_struct *vma)
+{
+	return false;
+}
+#endif
+
 /*
  * By the time we get here, we already hold the mm semaphore
  *
@@ -3898,7 +4001,10 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 		}
 	}
 
-	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
+	if (unlikely(may_share_pmd(vma)))
+		vmf.pmd = pmd_share(mm, vmf.pud, address);
+	else
+		vmf.pmd = pmd_alloc(mm, vmf.pud, address);
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
 	if (pmd_none(*vmf.pmd) && __transparent_hugepage_enabled(vma)) {
-- 
1.8.3.1

