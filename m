Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CCFCC49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 22:28:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35CF32085B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 22:28:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="NqNMdxLT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35CF32085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63DBE6B0280; Wed, 11 Sep 2019 18:28:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C94F6B0281; Wed, 11 Sep 2019 18:28:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DB3D6B0282; Wed, 11 Sep 2019 18:28:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0186.hostedemail.com [216.40.44.186])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9596B0280
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 18:28:51 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B4776181AC9C6
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:28:50 +0000 (UTC)
X-FDA: 75924080820.03.clam94_875862f914646
X-HE-Tag: clam94_875862f914646
X-Filterd-Recvd-Size: 8827
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 22:28:49 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d7975250002>; Wed, 11 Sep 2019 15:28:53 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 11 Sep 2019 15:28:49 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 11 Sep 2019 15:28:49 -0700
Received: from HQMAIL101.nvidia.com (172.20.187.10) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 11 Sep
 2019 22:28:44 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Wed, 11 Sep 2019 22:28:44 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d79751b0001>; Wed, 11 Sep 2019 15:28:43 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, "Christoph
 Hellwig" <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 1/4] mm/hmm: make full use of walk_page_range()
Date: Wed, 11 Sep 2019 15:28:26 -0700
Message-ID: <20190911222829.28874-2-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190911222829.28874-1-rcampbell@nvidia.com>
References: <20190911222829.28874-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1568240933; bh=b0VnDa9P0GKyNEg9iOk3eOIvkV4/HZzZEBTmbi87opU=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=NqNMdxLTXaIBY11JKg1HYUZzeesFC50JIFmaBIh6k/v25D5mncaLp7OFXsa4XwAtn
	 UaHM0eOqWokTFYPnoGG4loKzhH0SmsRM3SfZCKi3PpFZ+QvkfKzIud6pv5YlRaEy4V
	 WebVloNbU6FTF+pPmtxJmlItSD0CTv+5mUiNN56Ajw4bccxiOa7txd+vCoPizHuYNu
	 cB5eEnpLJXhsAoRngfxIOPw00XuhjT/rLXCBmhF5Y6IJ/SBrt0EuzoWvHVeu1aRosU
	 PqqLaLLp5052QDQQ1yNA+aBB4KUT8bhhpYA+0Qyd9oNLTC3oLcQrsN7WjagwguFANj
	 bhUur4L5uRwmA==
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
This also fixes a bug where hmm_range_fault() was not checking
start >=3D vma->vm_start before checking vma->vm_flags so hmm_range_fault()
could return an error based on the wrong vma for the requested range.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 113 ++++++++++++++++++++++++-------------------------------
 1 file changed, 50 insertions(+), 63 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 902f5fa6bf93..06041d4399ff 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -252,18 +252,17 @@ static int hmm_vma_do_fault(struct mm_walk *walk, uns=
igned long addr,
 	return -EFAULT;
 }
=20
-static int hmm_pfns_bad(unsigned long addr,
-			unsigned long end,
-			struct mm_walk *walk)
+static int hmm_pfns_fill(unsigned long addr,
+			 unsigned long end,
+			 struct hmm_range *range,
+			 enum hmm_pfn_value_e value)
 {
-	struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
-	struct hmm_range *range =3D hmm_vma_walk->range;
 	uint64_t *pfns =3D range->pfns;
 	unsigned long i;
=20
 	i =3D (addr - range->start) >> PAGE_SHIFT;
 	for (; addr < end; addr +=3D PAGE_SIZE, i++)
-		pfns[i] =3D range->values[HMM_PFN_ERROR];
+		pfns[i] =3D range->values[value];
=20
 	return 0;
 }
@@ -584,7 +583,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		}
 		return 0;
 	} else if (!pmd_present(pmd))
-		return hmm_pfns_bad(start, end, walk);
+		return hmm_pfns_fill(start, end, range, HMM_PFN_ERROR);
=20
 	if (pmd_devmap(pmd) || pmd_trans_huge(pmd)) {
 		/*
@@ -612,7 +611,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	 * recover.
 	 */
 	if (pmd_bad(pmd))
-		return hmm_pfns_bad(start, end, walk);
+		return hmm_pfns_fill(start, end, range, HMM_PFN_ERROR);
=20
 	ptep =3D pte_offset_map(pmdp, addr);
 	i =3D (addr - range->start) >> PAGE_SHIFT;
@@ -770,13 +769,36 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, uns=
igned long hmask,
 #define hmm_vma_walk_hugetlb_entry NULL
 #endif /* CONFIG_HUGETLB_PAGE */
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
+	 */
+	if (vma->vm_flags & (VM_IO | VM_PFNMAP | VM_MIXEDMAP))
+		return -EFAULT;
+
+	/*
+	 * If the vma does not allow read access, then assume that it does not
+	 * allow write access either. HMM does not support architectures
+	 * that allow write without read.
+	 */
+	if (!(vma->vm_flags & VM_READ)) {
+		(void) hmm_pfns_fill(start, end, range, HMM_PFN_NONE);
+		return -EPERM;
+	}
+
+	return 0;
 }
=20
 /*
@@ -857,6 +879,7 @@ static const struct mm_walk_ops hmm_walk_ops =3D {
 	.pmd_entry	=3D hmm_vma_walk_pmd,
 	.pte_hole	=3D hmm_vma_walk_hole,
 	.hugetlb_entry	=3D hmm_vma_walk_hugetlb_entry,
+	.test_walk	=3D hmm_vma_walk_test,
 };
=20
 /**
@@ -889,63 +912,27 @@ static const struct mm_walk_ops hmm_walk_ops =3D {
  */
 long hmm_range_fault(struct hmm_range *range, unsigned int flags)
 {
-	const unsigned long device_vma =3D VM_IO | VM_PFNMAP | VM_MIXEDMAP;
-	unsigned long start =3D range->start, end;
-	struct hmm_vma_walk hmm_vma_walk;
+	unsigned long start =3D range->start;
+	struct hmm_vma_walk hmm_vma_walk =3D {
+		.range =3D range,
+		.last =3D start,
+		.flags =3D flags,
+	};
 	struct hmm *hmm =3D range->hmm;
-	struct vm_area_struct *vma;
 	int ret;
=20
 	lockdep_assert_held(&hmm->mmu_notifier.mm->mmap_sem);
=20
 	do {
-		/* If range is no longer valid force retry. */
-		if (!range->valid)
-			return -EBUSY;
-
-		vma =3D find_vma(hmm->mmu_notifier.mm, start);
-		if (vma =3D=3D NULL || (vma->vm_flags & device_vma))
-			return -EFAULT;
-
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
+		ret =3D walk_page_range(hmm->mmu_notifier.mm, start, range->end,
+				      &hmm_walk_ops, &hmm_vma_walk);
+		start =3D hmm_vma_walk.last;
=20
-		hmm_vma_walk.pgmap =3D NULL;
-		hmm_vma_walk.last =3D start;
-		hmm_vma_walk.flags =3D flags;
-		hmm_vma_walk.range =3D range;
-		end =3D min(range->end, vma->vm_end);
+		/* Keep trying while the range is valid. */
+	} while (ret =3D=3D -EBUSY && range->valid);
=20
-		walk_page_range(vma->vm_mm, start, end, &hmm_walk_ops,
-				&hmm_vma_walk);
-
-		do {
-			ret =3D walk_page_range(vma->vm_mm, start, end,
-					&hmm_walk_ops, &hmm_vma_walk);
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
-
-	} while (start < range->end);
+	if (ret)
+		return ret;
=20
 	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
 }
--=20
2.20.1


