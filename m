Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B88E0C76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:57:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FB9922C97
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:57:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="lQZvtydN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FB9922C97
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18DFC6B000A; Thu, 25 Jul 2019 20:57:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 142168E0003; Thu, 25 Jul 2019 20:57:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E38548E0002; Thu, 25 Jul 2019 20:57:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD3E06B000A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:57:08 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id h67so39433708ybg.22
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:57:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=ucErf2NgykfAIu7RRloJG8d1JIV1vHLQef+I+l6mEkc=;
        b=MRappu5Q1QuchV8s/fQenb6QWT2/TenItzowUvabLfnvNIu66nxzwUnRvKjuQGAGQ3
         xAjJaXQZ8Gbwr9k5SQGs5N57HzI/waOJbNYPShH9n/J00T66Jl3cIk0kAAfHnEd1bwmu
         JddtgjNIW6WNZWP/F9C3TkFVCTCxFYqwwsePnChoT1yh22z1OZZg3AkQHYO6l3ftP7fY
         9oqswtwJrScmOjy4UKcn6tCBh4N8B8OCjY1p0mmgZsLtGrwxlnYh0rV6Q9cs8YRDXLfV
         3MLtiSAzXjuhoF+GNZsJmhHNEg1nx5ryFQ/1Gm3CA48O2nPVEe6l/iGh3sR3pFDsnbHm
         6/AQ==
X-Gm-Message-State: APjAAAU+CTpNFpnVDy6O+t1YA9kDEQfXfCO7PSH4wcidJyYUiDY7P8Qp
	z+ALieKUa/JZejWx0oeR2y22pAfgVBCBro9sXVne9A50gP5DDDPr3xk582jXSKahvth+X/1uLmR
	xxPKvHL5KO/Duj5U6Ix37B6G3hjQjlzy01SMzoA4ORyTyG0A4KrTj8NzJXKL6tTDLyQ==
X-Received: by 2002:a81:8187:: with SMTP id r129mr53952031ywf.309.1564102628500;
        Thu, 25 Jul 2019 17:57:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDg2ZG4IxYcRX37JdSFLxqCtzuolw0uz6xaQ3q9LNfGQJUBoNLvTdmi5woxO/Ik9hCOhdi
X-Received: by 2002:a81:8187:: with SMTP id r129mr53952016ywf.309.1564102627572;
        Thu, 25 Jul 2019 17:57:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564102627; cv=none;
        d=google.com; s=arc-20160816;
        b=U00z2HQOpgxcQ18mIht9LTvU1trngfOQLFJzGPbOLFNAtXSj4cMqf841Qn7kgHp5Dp
         2d0XtUi8mLfiWwdbPNcm6RWP1fPZ1RKgPTrSe2LDPYobvgr6V93reauBmzPzO1znXFi1
         7i3at8YpI61ehpZGj8J4XwN8eLUEn2ycm4VDvrhmDigFEpHD9ng5klkmPLD/AMMocQHF
         6sDcG4e437OxRWDiOjh6uk0suAiRSi0fMO7wgpQNAnZTAL1/3+h6DCK70UliWIAV1eEr
         nkD+wgNZQ//xoYatkMJ2YgVhxtR+qQksreoUZHVR74if6sFaLB8tM1TtzTleJnHY+eOr
         teqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=ucErf2NgykfAIu7RRloJG8d1JIV1vHLQef+I+l6mEkc=;
        b=zhss6cFw2JWfSl/pfaj8h6fxG6lp0O8Utq7se7b1PCYc67laz3I2v4RvStF37DL356
         VWtV6uV6Xg2NEsn2uUcWpHfFT0h86R7UTLG+7ZNTjHE3TYlnjIyfwNCcCEBMYEIE49+u
         rN6AZMdVWkBKxhOAoTjN64GXcVsXc/2qEEbZNDq3Y0KE1PXtq3YdVF/TDUR4cQobh2wv
         Xlh9e8Moh89pyI+DgrO0NB1Pn5mIGEviMbWP966DnocY1N2O4kxL5QpEomkhtpTMj9Cc
         ITLZuthQuhiBCEIbQt4bvSpDYZcO5UEXZSW9jfEkIJYyOmTJehssqIGvpoxlURTSF08r
         ehbA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=lQZvtydN;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 136si18758869ywx.160.2019.07.25.17.57.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 17:57:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=lQZvtydN;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3a4fea0000>; Thu, 25 Jul 2019 17:57:14 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 17:57:06 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 25 Jul 2019 17:57:06 -0700
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 00:57:04 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 26 Jul 2019 00:57:03 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3a4fdf0003>; Thu, 25 Jul 2019 17:57:03 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>,
	"Christoph Hellwig" <hch@lst.de>, Ralph Campbell <rcampbell@nvidia.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>
Subject: [PATCH v2 4/7] mm: merge hmm_range_snapshot into hmm_range_fault
Date: Thu, 25 Jul 2019 17:56:47 -0700
Message-ID: <20190726005650.2566-5-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726005650.2566-1-rcampbell@nvidia.com>
References: <20190726005650.2566-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564102634; bh=ucErf2NgykfAIu7RRloJG8d1JIV1vHLQef+I+l6mEkc=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=lQZvtydNiQ/49KQg58Da0PcYWPRDnlZegDqjgfVgmt3uTKcedgTkAIGbMli2vDbMD
	 kDYa31DvyZNMh8dhuJ2IWfqbIOHBacsH8fBbU16atj2a9BdYcHSnXGYpb80sGZauso
	 kfMsmb9lGwi2UoIb1cfA0skaNwNkey7+i7sOSA+oCRseHJn5wPZYyRCW1OssaSpbaH
	 n5XiHMrMzFsCN8ZmF602lHwhJBsu0Vm6v3pqDkmjsBerRjL6c7s/OKsS+8ATwd0d1A
	 o808TFkEvOypT/yIXFhXFaus06mg5T0Q0CTl+79AxJn20SnOToOr7oAV7jzTnd3Zac
	 0Sj7FQ1ciSZPQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@lst.de>

Add a HMM_FAULT_SNAPSHOT flag so that hmm_range_snapshot can be merged
into the almost identical hmm_range_fault function.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
---
 Documentation/vm/hmm.rst | 17 ++++----
 include/linux/hmm.h      |  4 +-
 mm/hmm.c                 | 85 +---------------------------------------
 3 files changed, 13 insertions(+), 93 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index 710ce1c701bf..ddcb5ca8b296 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -192,15 +192,14 @@ read only, or fully unmap, etc.). The device must com=
plete the update before
 the driver callback returns.
=20
 When the device driver wants to populate a range of virtual addresses, it =
can
-use either::
+use::
=20
-  long hmm_range_snapshot(struct hmm_range *range);
-  long hmm_range_fault(struct hmm_range *range, bool block);
+  long hmm_range_fault(struct hmm_range *range, unsigned int flags);
=20
-The first one (hmm_range_snapshot()) will only fetch present CPU page tabl=
e
+With the HMM_RANGE_SNAPSHOT flag, it will only fetch present CPU page tabl=
e
 entries and will not trigger a page fault on missing or non-present entrie=
s.
-The second one does trigger a page fault on missing or read-only entries i=
f
-write access is requested (see below). Page faults use the generic mm page
+Without that flag, it does trigger a page fault on missing or read-only en=
tries
+if write access is requested (see below). Page faults use the generic mm p=
age
 fault code path just like a CPU page fault.
=20
 Both functions copy CPU page table entries into their pfns array argument.=
 Each
@@ -227,20 +226,20 @@ The usage pattern is::
=20
       /*
        * Just wait for range to be valid, safe to ignore return value as w=
e
-       * will use the return value of hmm_range_snapshot() below under the
+       * will use the return value of hmm_range_fault() below under the
        * mmap_sem to ascertain the validity of the range.
        */
       hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
=20
  again:
       down_read(&mm->mmap_sem);
-      ret =3D hmm_range_snapshot(&range);
+      ret =3D hmm_range_fault(&range, HMM_RANGE_SNAPSHOT);
       if (ret) {
           up_read(&mm->mmap_sem);
           if (ret =3D=3D -EBUSY) {
             /*
              * No need to check hmm_range_wait_until_valid() return value
-             * on retry we will get proper error with hmm_range_snapshot()
+             * on retry we will get proper error with hmm_range_fault()
              */
             hmm_range_wait_until_valid(&range, TIMEOUT_IN_MSEC);
             goto again;
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 15f1b113be3c..f3693dcc8b98 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -412,7 +412,9 @@ void hmm_range_unregister(struct hmm_range *range);
  */
 #define HMM_FAULT_ALLOW_RETRY		(1 << 0)
=20
-long hmm_range_snapshot(struct hmm_range *range);
+/* Don't fault in missing PTEs, just snapshot the current state. */
+#define HMM_FAULT_SNAPSHOT		(1 << 1)
+
 long hmm_range_fault(struct hmm_range *range, unsigned int flags);
=20
 long hmm_range_dma_map(struct hmm_range *range,
diff --git a/mm/hmm.c b/mm/hmm.c
index 84f2791d3510..1bc014cddd78 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -280,7 +280,6 @@ struct hmm_vma_walk {
 	struct hmm_range	*range;
 	struct dev_pagemap	*pgmap;
 	unsigned long		last;
-	bool			fault;
 	unsigned int		flags;
 };
=20
@@ -373,7 +372,7 @@ static inline void hmm_pte_need_fault(const struct hmm_=
vma_walk *hmm_vma_walk,
 {
 	struct hmm_range *range =3D hmm_vma_walk->range;
=20
-	if (!hmm_vma_walk->fault)
+	if (hmm_vma_walk->flags & HMM_FAULT_SNAPSHOT)
 		return;
=20
 	/*
@@ -418,7 +417,7 @@ static void hmm_range_need_fault(const struct hmm_vma_w=
alk *hmm_vma_walk,
 {
 	unsigned long i;
=20
-	if (!hmm_vma_walk->fault) {
+	if (hmm_vma_walk->flags & HMM_FAULT_SNAPSHOT) {
 		*fault =3D *write_fault =3D false;
 		return;
 	}
@@ -936,85 +935,6 @@ void hmm_range_unregister(struct hmm_range *range)
 }
 EXPORT_SYMBOL(hmm_range_unregister);
=20
-/*
- * hmm_range_snapshot() - snapshot CPU page table for a range
- * @range: range
- * Return: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM inva=
lid
- *          permission (for instance asking for write and range is read on=
ly),
- *          -EBUSY if you need to retry, -EFAULT invalid (ie either no val=
id
- *          vma or it is illegal to access that range), number of valid pa=
ges
- *          in range->pfns[] (from range start address).
- *
- * This snapshots the CPU page table for a range of virtual addresses. Sna=
pshot
- * validity is tracked by range struct. See in include/linux/hmm.h for exa=
mple
- * on how to use.
- */
-long hmm_range_snapshot(struct hmm_range *range)
-{
-	const unsigned long device_vma =3D VM_IO | VM_PFNMAP | VM_MIXEDMAP;
-	unsigned long start =3D range->start, end;
-	struct hmm_vma_walk hmm_vma_walk;
-	struct hmm *hmm =3D range->hmm;
-	struct vm_area_struct *vma;
-	struct mm_walk mm_walk;
-
-	lockdep_assert_held(&hmm->mm->mmap_sem);
-	do {
-		/* If range is no longer valid force retry. */
-		if (!range->valid)
-			return -EBUSY;
-
-		vma =3D find_vma(hmm->mm, start);
-		if (vma =3D=3D NULL || (vma->vm_flags & device_vma))
-			return -EFAULT;
-
-		if (is_vm_hugetlb_page(vma)) {
-			if (huge_page_shift(hstate_vma(vma)) !=3D
-				    range->page_shift &&
-			    range->page_shift !=3D PAGE_SHIFT)
-				return -EINVAL;
-		} else {
-			if (range->page_shift !=3D PAGE_SHIFT)
-				return -EINVAL;
-		}
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
-
-		range->vma =3D vma;
-		hmm_vma_walk.pgmap =3D NULL;
-		hmm_vma_walk.last =3D start;
-		hmm_vma_walk.fault =3D false;
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
-		walk_page_range(start, end, &mm_walk);
-		start =3D end;
-	} while (start < range->end);
-
-	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
-}
-EXPORT_SYMBOL(hmm_range_snapshot);
-
 /**
  * hmm_range_fault - try to fault some address in a virtual address range
  * @range:	range being faulted
@@ -1088,7 +1008,6 @@ long hmm_range_fault(struct hmm_range *range, unsigne=
d int flags)
 		range->vma =3D vma;
 		hmm_vma_walk.pgmap =3D NULL;
 		hmm_vma_walk.last =3D start;
-		hmm_vma_walk.fault =3D true;
 		hmm_vma_walk.flags =3D flags;
 		hmm_vma_walk.range =3D range;
 		mm_walk.private =3D &hmm_vma_walk;
--=20
2.20.1

