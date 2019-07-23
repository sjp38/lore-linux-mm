Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 870B8C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:30:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F26D206DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:30:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="fM855tyZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F26D206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CADDD6B0006; Tue, 23 Jul 2019 19:30:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5E8E8E0003; Tue, 23 Jul 2019 19:30:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B27738E0002; Tue, 23 Jul 2019 19:30:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9258E6B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:30:26 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id f126so34260248ybg.16
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:30:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=vXNCPdLtOKpCMqnhnrWYHHQ4R9DMFg9c7ubyhWGAGSI=;
        b=FDBhXRxjvwmha4OLgxF8wQX1cAL63GMta0+csX7iLtptn0ExLjwl8iuvkL+ss6hqbe
         s7Ug1X4Touh9fuvSzPeA58Oh/wfFVMg4N3Jf/61ws0QRMSenEPc+rpyfo6x+Tk4vl/v9
         dkfrMCdDA1DswCZJSli3Bp//93YYNZCxinG6Th/dtuYxY7oapfiWO/ZRPw32djW5wSqz
         CPPxJQ2cNNTI7mBUD3RAXj9evd4NsmOoJgBzsY8SUXZ598szfdrOyB67rhuIBVwUU4V0
         BCHaXLqbyzg+E8wZlAE5Q/NzAGNhkBCfiaZxDRou0BJA/A4Q7Cyzy+QH3POzE3loxfb/
         QEww==
X-Gm-Message-State: APjAAAWSQKOHjoZCstbzryeOv5k/Mc3gcbAl2Ui7bmCrhhOCdAVGW5mn
	c4pdSS4IRAm0WD86IOXhmA3WzpqgxoqXVDx+QuabWer/RIsxFYOtOaymkD4AKjG8nfU0rSWURky
	8/vpvotlL+DbNNuKuZmL2VBoJtWKFWqMUMl3CnR8rDEN0Hb2AoN8hm7QMT3tqfzjHAw==
X-Received: by 2002:a81:f88:: with SMTP id 130mr48020007ywp.311.1563924626350;
        Tue, 23 Jul 2019 16:30:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUH/rU4ajMYAvFF5GCUVvHemitgiWHNNK063v6xylW2U9tk/1Y2eMO54ONl/gp46S+/Bbd
X-Received: by 2002:a81:f88:: with SMTP id 130mr48019975ywp.311.1563924625716;
        Tue, 23 Jul 2019 16:30:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563924625; cv=none;
        d=google.com; s=arc-20160816;
        b=mnfk7YJVTMjSWdFYNtNWXakilg/30HqOzNUxOMTgsflKWm5RuL11mKJzmSxKDVogkr
         m0nWAtP8oC4oNsCIHIxt11FgTOkN3KXJ3cmrrZiTqS+7FTIb52oTD+JWQUmckEpYIO6x
         LN8TuEVlyVg0xPTSNfNKJ0ZPZrkMb/pYnjGPVRi5ItqsjDSH62dd/THILxTn8e7FO996
         s1w+y057v2laPtS2G4FLRrlfiSMLpNYOEkbjjmgiFZIpMxNTc8IrEpIJB1XWry8ZNz40
         slnF4/Cd46218alOf7cndHLAHeHQ7GGFEm6F0moC27hNrrNZkpiW5t5U9bz7MHq+mwUp
         0VYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=vXNCPdLtOKpCMqnhnrWYHHQ4R9DMFg9c7ubyhWGAGSI=;
        b=VgqCZuqtzqKeY9RkC4uRQU4uU5ddE7eE30J+NrxyAvnwgQ+HyGMxIt1CqJzLlLeBUR
         QGxhN1QQ+zayw77CNfYeWcpVBF3/+CG+z5ldmLb98hk02fcQkfdL3fOMi5NMJQMGRFKI
         S67h1iNX8dW8G+umVn+oC1sQA6Dz5evNfXWPzCutjLaeNRpJkR9QFHnYoTF0VqlTBIZd
         hC8kcS7MKWO9gupJYhBJWAozmuf3XlhJ+ilIeYgQGxUX/bSwdMX65KzQWdKC3nbxte4Q
         h6SuZYenwZla6QvDn25MhcNVNSXA8FV7Xg5qHNrCe3J1sB9ra2//yp28bybZWfPVISjr
         vNSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fM855tyZ;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id y4si16386244ybp.210.2019.07.23.16.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 16:30:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fM855tyZ;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d37988e0000>; Tue, 23 Jul 2019 16:30:22 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 23 Jul 2019 16:30:24 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 23 Jul 2019 16:30:24 -0700
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 23 Jul
 2019 23:30:21 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Tue, 23 Jul 2019 23:30:21 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d37988d0000>; Tue, 23 Jul 2019 16:30:21 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/2] mm/hmm: a few more C style and comment clean ups
Date: Tue, 23 Jul 2019 16:30:15 -0700
Message-ID: <20190723233016.26403-2-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190723233016.26403-1-rcampbell@nvidia.com>
References: <20190723233016.26403-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563924622; bh=vXNCPdLtOKpCMqnhnrWYHHQ4R9DMFg9c7ubyhWGAGSI=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=fM855tyZ1WcjIgnyEsZQy7O05+TECy5DrMYAhbx2p36jOb6O5IiErvFCE8Lfi3V8G
	 RLKkR7eVIPK8qwtQXYw9OvS/KqkTsUX7wV7H36PbDzfFgGhMyICZWtaMoJCBxf4mJ/
	 qtpLJkHil520lNp2U4onHfGqewP3oynUtHuuQWeDqYnGvh+SS9rz2Fc7jEixEHxaY4
	 Ry9ODubJpC+UqxGV22eGSI8sYEs2SR9kkm5Jc8AaQQYyGVcWcRhT3uN/9Wy8D4pPXz
	 jUsp5ObCYqjuFQMgsIG9zmKwJ8XI9SaD5eRZoEk51lNi5lqTgUkI35WbFckjVjIvZm
	 pb4A5wgPe7U/g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A few more comments and minor programming style clean ups.
There should be no functional changes.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 34 ++++++++++++++++------------------
 1 file changed, 16 insertions(+), 18 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index b810a4fa3de9..8271f110c243 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -32,7 +32,7 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops=
;
  * hmm_get_or_create - register HMM against an mm (HMM internal)
  *
  * @mm: mm struct to attach to
- * Returns: returns an HMM object, either by referencing the existing
+ * Return: an HMM object, either by referencing the existing
  *          (per-process) object, or by creating a new one.
  *
  * This is not intended to be used directly by device drivers. If mm alrea=
dy
@@ -323,8 +323,8 @@ static int hmm_pfns_bad(unsigned long addr,
 }
=20
 /*
- * hmm_vma_walk_hole() - handle a range lacking valid pmd or pte(s)
- * @start: range virtual start address (inclusive)
+ * hmm_vma_walk_hole_() - handle a range lacking valid pmd or pte(s)
+ * @addr: range virtual start address (inclusive)
  * @end: range virtual end address (exclusive)
  * @fault: should we fault or not ?
  * @write_fault: write fault ?
@@ -374,9 +374,9 @@ static inline void hmm_pte_need_fault(const struct hmm_=
vma_walk *hmm_vma_walk,
 	/*
 	 * So we not only consider the individual per page request we also
 	 * consider the default flags requested for the range. The API can
-	 * be use in 2 fashions. The first one where the HMM user coalesce
-	 * multiple page fault into one request and set flags per pfns for
-	 * of those faults. The second one where the HMM user want to pre-
+	 * be used 2 ways. The first one where the HMM user coalesces
+	 * multiple page faults into one request and sets flags per pfn for
+	 * those faults. The second one where the HMM user wants to pre-
 	 * fault a range with specific flags. For the latter one it is a
 	 * waste to have the user pre-fill the pfn arrays with a default
 	 * flags value.
@@ -386,7 +386,7 @@ static inline void hmm_pte_need_fault(const struct hmm_=
vma_walk *hmm_vma_walk,
 	/* We aren't ask to do anything ... */
 	if (!(pfns & range->flags[HMM_PFN_VALID]))
 		return;
-	/* If this is device memory than only fault if explicitly requested */
+	/* If this is device memory then only fault if explicitly requested */
 	if ((cpu_flags & range->flags[HMM_PFN_DEVICE_PRIVATE])) {
 		/* Do we fault on device memory ? */
 		if (pfns & range->flags[HMM_PFN_DEVICE_PRIVATE]) {
@@ -500,7 +500,7 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
 	hmm_vma_walk->last =3D end;
 	return 0;
 #else
-	/* If THP is not enabled then we should never reach that code ! */
+	/* If THP is not enabled then we should never reach this code ! */
 	return -EINVAL;
 #endif
 }
@@ -624,13 +624,12 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	pte_t *ptep;
 	pmd_t pmd;
=20
-
 again:
 	pmd =3D READ_ONCE(*pmdp);
 	if (pmd_none(pmd))
 		return hmm_vma_walk_hole(start, end, walk);
=20
-	if (pmd_huge(pmd) && (range->vma->vm_flags & VM_HUGETLB))
+	if (pmd_huge(pmd) && is_vm_hugetlb_page(vma))
 		return hmm_pfns_bad(start, end, walk);
=20
 	if (thp_migration_supported() && is_pmd_migration_entry(pmd)) {
@@ -655,11 +654,11 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
=20
 	if (pmd_devmap(pmd) || pmd_trans_huge(pmd)) {
 		/*
-		 * No need to take pmd_lock here, even if some other threads
+		 * No need to take pmd_lock here, even if some other thread
 		 * is splitting the huge pmd we will get that event through
 		 * mmu_notifier callback.
 		 *
-		 * So just read pmd value and check again its a transparent
+		 * So just read pmd value and check again it's a transparent
 		 * huge or device mapping one and compute corresponding pfn
 		 * values.
 		 */
@@ -673,7 +672,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	}
=20
 	/*
-	 * We have handled all the valid case above ie either none, migration,
+	 * We have handled all the valid cases above ie either none, migration,
 	 * huge or transparent huge. At this point either it is a valid pmd
 	 * entry pointing to pte directory or it is a bad pmd that will not
 	 * recover.
@@ -793,10 +792,10 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, uns=
igned long hmask,
 	pte_t entry;
 	int ret =3D 0;
=20
-	size =3D 1UL << huge_page_shift(h);
+	size =3D huge_page_size(h);
 	mask =3D size - 1;
 	if (range->page_shift !=3D PAGE_SHIFT) {
-		/* Make sure we are looking at full page. */
+		/* Make sure we are looking at a full page. */
 		if (start & mask)
 			return -EINVAL;
 		if (end < (start + size))
@@ -807,8 +806,7 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsig=
ned long hmask,
 		size =3D PAGE_SIZE;
 	}
=20
-
-	ptl =3D huge_pte_lock(hstate_vma(walk->vma), walk->mm, pte);
+	ptl =3D huge_pte_lock(hstate_vma(vma), walk->mm, pte);
 	entry =3D huge_ptep_get(pte);
=20
 	i =3D (start - range->start) >> range->page_shift;
@@ -857,7 +855,7 @@ static void hmm_pfns_clear(struct hmm_range *range,
  * @start: start virtual address (inclusive)
  * @end: end virtual address (exclusive)
  * @page_shift: expect page shift for the range
- * Returns 0 on success, -EFAULT if the address space is no longer valid
+ * Return: 0 on success, -EFAULT if the address space is no longer valid
  *
  * Track updates to the CPU page table see include/linux/hmm.h
  */
--=20
2.20.1

