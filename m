Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5A95C468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:52:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EB6C208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:52:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="w3CaDR2O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EB6C208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 276D76B026B; Fri,  7 Jun 2019 15:52:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 203456B026C; Fri,  7 Jun 2019 15:52:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5B756B026E; Fri,  7 Jun 2019 15:52:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADCB96B026B
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:52:46 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 21so2098575pgl.5
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:52:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=azHW+cQaxRO87i10SYgPO4FUpLCfSWASegXloVuy3VQ=;
        b=ADrCHM0yFkji0SnLCrWuOqN5FF2iT0RL3ftVdniyVzZ232PKvNCckW5aHCM2wlDmTm
         OHX8HG/yaeIiB3DJjjBdD5jYScg3BUkILQs1YjXY+6JwaCq4ImHKIFf1+SaVEuUAyEe+
         rQnrjY05894psEyw/dquE9uj9iMji/BsUScTm1zq6sMlVyOIY7lp9UJVDsG5adxp+Otr
         qn27+cIA2B2PeV+DQEJdpMIFm6UpadLdp1o5e2L9tfLI7p0/N1XnFuW3LBVQbZfuCA0V
         Cbq8hW0rpLcnAkDQF0nbukDAW8VbJrqAn5o5aCmrKnKeo3dYkg+wg7O2pJvaeD+jvAO0
         pR5g==
X-Gm-Message-State: APjAAAWCyllJRBcBkOnymwLkgVETw4AZXT1j61eFhp49GtsSR2cIwQvP
	1qtg+gee7H9mMRWFFiSd4lUqdSJ3xsSucYId6US4fG8erGbMKd1RmBX9r4xnABcDELwvq9CAcvT
	NCQsltMplfoBfTdOw0TJBDPCTq373+waSkx4a8hAzKS17Ujr2CGQhrp69+qrqefiAeA==
X-Received: by 2002:a63:6c87:: with SMTP id h129mr4678572pgc.427.1559937166184;
        Fri, 07 Jun 2019 12:52:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyl8iOkDHaogGB0JC9HVD6QvXb7i6fw5OcM1WdrhZKZ3LOBXBK09soaixAQ34I8bK1mTLrM
X-Received: by 2002:a63:6c87:: with SMTP id h129mr4678532pgc.427.1559937165180;
        Fri, 07 Jun 2019 12:52:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559937165; cv=none;
        d=google.com; s=arc-20160816;
        b=D+q5Ft2JDHwZbYm3LO8uKeVu3uhplqLD/wuW2p/i0EofBV00iSY6gOLaVgyZH/aCJA
         9MrbePxBopbrv+JTo7WTKkE4E0RQZY8JTBa2NOElSJmEkpX3pPzlrN2riaM9jY8rYeAU
         zI7OPfRDpHEE40nzng6fTLjdPwdQtCJpQWWn7QUcn/u97bCrPbY+ISsiVLpePMXDvgJ1
         gpZXvt00TwbPgdjqD3YVDqGg9RsEQE3R74LcAIxJ06FxClfRe6s9+rOp7uzDJKoENlR6
         nwPLu3Q/xgKqyzfqvpwr5geGTQru3uqGaOa+0V04xwGZcNMC5eutX9TkhNVyBGkizD96
         PV2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=azHW+cQaxRO87i10SYgPO4FUpLCfSWASegXloVuy3VQ=;
        b=JkxmBWin4Uex0lU4tvTyXOGRZL9BAQCVp6gZbbtWPlNVUsY7SaVysdAWUUm4NeURmi
         AOpZdGQ5Q4sBVstb8mEFfqxIVDFzg5pdiPYgFqAhqyuChlXEINPQLJusv6DKxbFerv+I
         fTFPCxo8dnzEiDSfaPVrJjraWWxDfcdB7YWj695J2WrgGpQUu/cvl/kKQQAkd6Lp95O1
         BXE/f4lScq7QfS2gRvT2Lq63kQJMajNEGhOYlairlm9pX2j2AfF+IYejYW2lOQ7D9kpd
         UTReZ2BoOKrBlP1W3v7LCMGzrYFkfqR7/TsFmux8l63i949wEe09V10bPRVVao8jK2Pr
         vuyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=w3CaDR2O;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g18si2776919plq.104.2019.06.07.12.52.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 12:52:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=w3CaDR2O;
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x57Ji74w098344;
	Fri, 7 Jun 2019 19:52:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=azHW+cQaxRO87i10SYgPO4FUpLCfSWASegXloVuy3VQ=;
 b=w3CaDR2O4INbPMzrHAC8aguIcoYcO5oSuWcxoIEYHztSXXbVVYZJg5+WE+14EIzCE0C1
 TVMTE2n4O7EDEytsuoc1n2hm/zTNBIcaUeDeFuoprpMxzxgNn7gn76RyTjO8IWmUlRVZ
 ZUjUWxxde/bBSNq/xwUhJJb1vpb3w3mfVrRWLbt0ybhL4KtoTPpBWfeXukHVNQ+G4VlT
 WS3KA2XBp3fi0dLpDJL4iARVbhFdld/fvWVI6fDmF4ad38jxcL3MdsC8VbsknLBn6PKe
 wt23+RHL4aBmnFtEZLSzTmWknxdbTaYmUeWlteDmG2JZxIBskT7SF31VlhAwBrxSemdF 5Q== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2suj0r05yw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 07 Jun 2019 19:52:33 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x57Jq2W2024665;
	Fri, 7 Jun 2019 19:52:32 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2swngk6psb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 07 Jun 2019 19:52:32 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x57JqThx012151;
	Fri, 7 Jun 2019 19:52:29 GMT
Received: from oracle.com (/75.80.107.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 07 Jun 2019 12:52:29 -0700
From: Larry Bassel <larry.bassel@oracle.com>
To: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nvdimm@lists.01.org
Cc: Larry Bassel <larry.bassel@oracle.com>
Subject: [RFC PATCH v2 2/2] Implement sharing/unsharing of PMDs for FS/DAX
Date: Fri,  7 Jun 2019 12:51:03 -0700
Message-Id: <1559937063-8323-3-git-send-email-larry.bassel@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1559937063-8323-1-git-send-email-larry.bassel@oracle.com>
References: <1559937063-8323-1-git-send-email-larry.bassel@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9281 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906070132
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9281 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906070132
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
 mm/huge_memory.c        |  37 +++++++++++++++++
 mm/hugetlb.c            |   8 ++--
 mm/memory.c             | 108 +++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 152 insertions(+), 5 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edf476c..debff55 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -140,6 +140,10 @@ pte_t *huge_pte_offset(struct mm_struct *mm,
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
index 9f8bce9..935874c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1751,6 +1751,33 @@ static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
 	mm_dec_nr_ptes(mm);
 }
 
+#ifdef CONFIG_ARCH_HAS_HUGE_PMD_SHARE
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
@@ -1768,6 +1795,11 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
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
@@ -1915,6 +1947,11 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	if (!ptl)
 		return 0;
 
+	if (unshare_huge_pmd(mm, addr, pmd)) {
+		spin_unlock(ptl);
+		return HPAGE_PMD_NR;
+	}
+
 	preserve_write = prot_numa && pmd_write(*pmd);
 	ret = 1;
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3a54c9d..1c1ed4e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4653,9 +4653,9 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
 }
 
 #ifdef CONFIG_ARCH_HAS_HUGE_PMD_SHARE
-static unsigned long page_table_shareable(struct vm_area_struct *svma,
-				struct vm_area_struct *vma,
-				unsigned long addr, pgoff_t idx)
+unsigned long page_table_shareable(struct vm_area_struct *svma,
+				   struct vm_area_struct *vma,
+				   unsigned long addr, pgoff_t idx)
 {
 	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
 				svma->vm_start;
@@ -4678,7 +4678,7 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
 	return saddr;
 }
 
-static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
+bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
 {
 	unsigned long base = addr & PUD_MASK;
 	unsigned long end = base + PUD_SIZE;
diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd..1ca8f75 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3932,6 +3932,109 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
 	return 0;
 }
 
+#ifdef CONFIG_ARCH_HAS_HUGE_PMD_SHARE
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
+			     (pmd_t *)((unsigned long)spmd & PAGE_MASK));
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
@@ -3985,7 +4088,10 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
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

