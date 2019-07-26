Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0077DC76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:57:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98D7622C97
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:57:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="jkL74WID"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98D7622C97
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FE708E0003; Thu, 25 Jul 2019 20:57:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B0C08E0002; Thu, 25 Jul 2019 20:57:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22AB38E0003; Thu, 25 Jul 2019 20:57:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 020258E0002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:57:10 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id e66so32221641ybe.19
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:57:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=GyZ3LYNDHdPknOwN7r8eo0WLWm3OjKPNgGYZWHO3koQ=;
        b=Ux5KpoMKe/LMAAMnleWRsMCodASA93Y2pB6S+MdWWU7U49+3943YKoxCfVbmC0g4zV
         hWH1YSxapn3OAPL3xc+39/KO3YzORnNeB+4ZnrvK83teG8F+SuBwhWyoL7WiZr+REkhZ
         hNZrATH38Qm7CQKWRYCnSIdGoTtQZnur+6URmXFVXF67P9Xi3GbiIToqPBRP0+h4hN5Q
         3kHehG2nYXUB9L32GlfSG/iQ0R/1ytVCDlncV+GpZCMwn+4cv67fupjrm2hBQSIsZ35E
         twtK7RmPaZrYvyJkiM1cxb4iyI6++pftaG7b3cmmAAH4Zk8WxkxFtqm8rjftWWwu3uI+
         Phgg==
X-Gm-Message-State: APjAAAX45HBUP7q7oK6nFNy4iZugR/ZGhAdGJNct9Y4u6tdKb8N06blH
	/E6cFFN8FQHrDJPX75or1mLlKe0Adao1JrmYuMIKVEJY3xB7n454ghGPWBCuW5Lf3wdCqESEiPZ
	qJUtWT/24pJT3i9Ft1yDflHwf+7t4PAyqZmjDdQ8hlXzvBRGkNPK3+rebTqxZIFuqxQ==
X-Received: by 2002:a81:a491:: with SMTP id b139mr57263151ywh.148.1564102629770;
        Thu, 25 Jul 2019 17:57:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWjBTWpv8hbVc+LP0vysY+D3K5QQH/OH8mgBYPNd8RvGSPRjYAxH5Y+HmIE0aHWT7tiBNm
X-Received: by 2002:a81:a491:: with SMTP id b139mr57263125ywh.148.1564102628718;
        Thu, 25 Jul 2019 17:57:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564102628; cv=none;
        d=google.com; s=arc-20160816;
        b=nCCzzMd60ZdOiBHKBbIgmAkInFKy/4o9HYLlAMvY/eUOTLgPtQ5mXwPVVq4vb1xMU6
         jXINXXYmPDyy/G97rp9ICJdYXqKWGxTIJRs7ugUJKc8eumOnnrcz4/jQAHsgMwGMvcwX
         Uokm+wIDvMC2Sf2ROlPUND6NTl0MXMTT4dd4iJPovJziSq/+Z6D8VFOnFzV8uEZtXZkE
         3tRzOCnHJv+77yTlrEcAwGhBRLiPCpRO6qvU6AstAxGSHubT9QkjEBTngpVSg6Q1mug3
         T+77v3KgcpCUAEh9vQILdCfl73Oi1oVDzHF0884IwdI7KEn3KpyC/AeJvXeaeGPRjg0O
         CP0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=GyZ3LYNDHdPknOwN7r8eo0WLWm3OjKPNgGYZWHO3koQ=;
        b=b9rRdh+sEtjO7JMZcWwvjluyYOF1PRU9kpELk1yxqjfZnA+mO8B94KhfcxyrH1BO27
         RfYkS+3bSgaNIedpsitJ6pPj9im4ce0jw+RRJu/R99R1Q2aY5DWP+4DC9nczUhd366Al
         eOoKAz61VGS4cvLV73X1wmTos1AvkFIQbqNJJxb/TgnMoNvG1sv355KcznRlGxCW3vWt
         5rMumM+55Gwkz5zSPzKsFWSV2sD4Pl0/nvMrfA9sPqSH8figM66jEX3Lr0pBaydRUazY
         mu59HINGGgYO8tkIrQ2sdx4MsCDJEd/DIkYvkUAOplIxLNx2MBTagVI5xCFBbsUVOZwW
         Fliw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jkL74WID;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id e195si19118991ybh.158.2019.07.25.17.57.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 17:57:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=jkL74WID;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3a4fe10000>; Thu, 25 Jul 2019 17:57:05 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 17:57:07 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 25 Jul 2019 17:57:07 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 00:57:06 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 26 Jul 2019 00:57:07 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3a4fe20000>; Thu, 25 Jul 2019 17:57:06 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>, "Ralph
 Campbell" <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig
	<hch@lst.de>
Subject: [PATCH v2 5/7] mm/hmm: make full use of walk_page_range()
Date: Thu, 25 Jul 2019 17:56:48 -0700
Message-ID: <20190726005650.2566-6-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726005650.2566-1-rcampbell@nvidia.com>
References: <20190726005650.2566-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564102625; bh=GyZ3LYNDHdPknOwN7r8eo0WLWm3OjKPNgGYZWHO3koQ=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=jkL74WIDmQa1QlupaV/bl/KqbTUH1ksEkEBYqKDVCv0gPT18+fIWkOYzYvA/JhIOQ
	 WoaBiatsfQp4apyOEgWJmHcoEdUPR4iyjTzywVKgyNNm8afzWbdQXMTa9/hxtthL6D
	 /LE78tMf67hTVoBMr8RtJYQVzlwb6HbvgmT6F/zz/N1x6ESVVbuCpM+rz7BljsWl27
	 uC5J4Fa93NYNIxPT1yRulAC0TfLgGY7Kah/fiFeHkpm+tBTYaVXBUZGdk4m3bkr4fB
	 RJUcwZpJbDqishirX9ybkZn+bh2oq918k2LQCl/jh1pLxkW0lN0hR53X03mm8AOhfy
	 4ymbSl04N3uMQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hmm_range_fault() calls find_vma() and walk_page_range() in a loop.
This is unnecessary duplication since walk_page_range() calls find_vma()
in a loop already.
Simplify hmm_range_fault() by defining a walk_test() callback function
to filter unhandled vmas.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 130 ++++++++++++++++++++++++-------------------------------
 1 file changed, 57 insertions(+), 73 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 1bc014cddd78..838cd1d50497 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -840,13 +840,44 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, uns=
igned long hmask,
 #endif
 }
=20
-static void hmm_pfns_clear(struct hmm_range *range,
-			   uint64_t *pfns,
-			   unsigned long addr,
-			   unsigned long end)
+static int hmm_vma_walk_test(unsigned long start,
+			     unsigned long end,
+			     struct mm_walk *walk)
 {
-	for (; addr < end; addr +=3D PAGE_SIZE, pfns++)
-		*pfns =3D range->values[HMM_PFN_NONE];
+	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
+	struct hmm_range *range =3D hmm_vma_walk->range;
+	struct vm_area_struct *vma =3D walk->vma;
+
+	/* If range is no longer valid, force retry. */
+	if (!range->valid)
+		return -EBUSY;
+
+	/*
+	 * Skip vma ranges that don't have struct page backing them or
+	 * map I/O devices directly.
+	 * TODO: handle peer-to-peer device mappings.
+	 */
+	if (vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP))
+		return -EFAULT;
+
+	if (is_vm_hugetlb_page(vma)) {
+		if (huge_page_shift(hstate_vma(vma)) !=3D range->page_shift &&
+		    range->page_shift !=3D PAGE_SHIFT)
+			return -EINVAL;
+	} else {
+		if (range->page_shift !=3D PAGE_SHIFT)
+			return -EINVAL;
+	}
+
+	/*
+	 * If vma does not allow read access, then assume that it does not
+	 * allow write access, either. HMM does not support architectures
+	 * that allow write without read.
+	 */
+	if (!(vma->vm_flags & VM_READ))
+		return -EPERM;
+
+	return 0;
 }
=20
 /*
@@ -965,82 +996,35 @@ EXPORT_SYMBOL(hmm_range_unregister);
  */
 long hmm_range_fault(struct hmm_range *range, unsigned int flags)
 {
-	const unsigned long device_vma =3D VM_IO | VM_PFNMAP | VM_MIXEDMAP;
-	unsigned long start =3D range->start, end;
-	struct hmm_vma_walk hmm_vma_walk;
+	unsigned long start =3D range->start;
+	struct hmm_vma_walk hmm_vma_walk =3D {};
 	struct hmm *hmm =3D range->hmm;
-	struct vm_area_struct *vma;
-	struct mm_walk mm_walk;
+	struct mm_walk mm_walk =3D {};
 	int ret;
=20
 	lockdep_assert_held(&hmm->mm->mmap_sem);
=20
-	do {
-		/* If range is no longer valid force retry. */
-		if (!range->valid)
-			return -EBUSY;
+	hmm_vma_walk.range =3D range;
+	hmm_vma_walk.last =3D start;
+	hmm_vma_walk.flags =3D flags;
+	mm_walk.private =3D &hmm_vma_walk;
=20
-		vma =3D find_vma(hmm->mm, start);
-		if (vma =3D=3D NULL || (vma->vm_flags & device_vma))
-			return -EFAULT;
-
-		if (is_vm_hugetlb_page(vma)) {
-			if (huge_page_shift(hstate_vma(vma)) !=3D
-			    range->page_shift &&
-			    range->page_shift !=3D PAGE_SHIFT)
-				return -EINVAL;
-		} else {
-			if (range->page_shift !=3D PAGE_SHIFT)
-				return -EINVAL;
-		}
+	mm_walk.mm =3D hmm->mm;
+	mm_walk.pud_entry =3D hmm_vma_walk_pud;
+	mm_walk.pmd_entry =3D hmm_vma_walk_pmd;
+	mm_walk.pte_hole =3D hmm_vma_walk_hole;
+	mm_walk.hugetlb_entry =3D hmm_vma_walk_hugetlb_entry;
+	mm_walk.test_walk =3D hmm_vma_walk_test;
=20
-		if (!(vma->vm_flags & VM_READ)) {
-			/*
-			 * If vma do not allow read access, then assume that it
-			 * does not allow write access, either. HMM does not
-			 * support architecture that allow write without read.
-			 */
-			hmm_pfns_clear(range, range->pfns,
-				range->start, range->end);
-			return -EPERM;
-		}
+	do {
+		ret =3D walk_page_range(start, range->end, &mm_walk);
+		start =3D hmm_vma_walk.last;
=20
-		range->vma =3D vma;
-		hmm_vma_walk.pgmap =3D NULL;
-		hmm_vma_walk.last =3D start;
-		hmm_vma_walk.flags =3D flags;
-		hmm_vma_walk.range =3D range;
-		mm_walk.private =3D &hmm_vma_walk;
-		end =3D min(range->end, vma->vm_end);
-
-		mm_walk.vma =3D vma;
-		mm_walk.mm =3D vma->vm_mm;
-		mm_walk.pte_entry =3D NULL;
-		mm_walk.test_walk =3D NULL;
-		mm_walk.hugetlb_entry =3D NULL;
-		mm_walk.pud_entry =3D hmm_vma_walk_pud;
-		mm_walk.pmd_entry =3D hmm_vma_walk_pmd;
-		mm_walk.pte_hole =3D hmm_vma_walk_hole;
-		mm_walk.hugetlb_entry =3D hmm_vma_walk_hugetlb_entry;
-
-		do {
-			ret =3D walk_page_range(start, end, &mm_walk);
-			start =3D hmm_vma_walk.last;
-
-			/* Keep trying while the range is valid. */
-		} while (ret =3D=3D -EBUSY && range->valid);
-
-		if (ret) {
-			unsigned long i;
-
-			i =3D (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
-			hmm_pfns_clear(range, &range->pfns[i],
-				hmm_vma_walk.last, range->end);
-			return ret;
-		}
-		start =3D end;
+		/* Keep trying while the range is valid. */
+	} while (ret =3D=3D -EBUSY && range->valid);
=20
-	} while (start < range->end);
+	if (ret)
+		return ret;
=20
 	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
 }
--=20
2.20.1

