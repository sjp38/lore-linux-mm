Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7B89C76194
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:57:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8174622CBB
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 00:57:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Y+Fdrsy5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8174622CBB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33A348E0005; Thu, 25 Jul 2019 20:57:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EA088E0002; Thu, 25 Jul 2019 20:57:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2063B8E0005; Thu, 25 Jul 2019 20:57:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3B938E0002
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 20:57:14 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id p20so39084488yba.17
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 17:57:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=NZUo+DqUJdY6mTpO9a6/Oba2m7JMCHGUDDnmqd09n1Y=;
        b=ox2pVPobtZTtCGQDPd7EJ3Nnf4ftl4JV0BKr9I9PnMWo9Fqxxiz3lHyT90VfsUqyCa
         mQH+A6GWGVDJ7nLM1xlpLxR0pOmqQ3aA5jnktMpBljGjC24yLlHiptMGdjZIA6PxLj61
         mdki0fVVwZu2oOdA7pFi9TM35UElilsGIOiTYTMAxAKKYPBw+5FUUqD1A3UiiRyHUxLE
         w1qTTh03LH8odP69ODZ4dcYdanAoaLRlU3vc1/9q0qWPLXcPFFvcFFaspb/Zq//RJ0j9
         9cPe438SfPJWymhW7yYbeYuFAa3OjgHAASJ9mL3FFyDU1FqpitIerWJDNf8w07HwMXm8
         p1Bg==
X-Gm-Message-State: APjAAAXem1vRHSF8/9XcUbED2G/N6KNAZv6DhNYk9eyATsxUX93uVcXG
	sLCanBw2jtf1XtkDKhaCHH+dsMYwm795wj9uQvgfp7YeP3TWEVv50bbcWKoTbS5cj4tV3l020ow
	NwSB2w0hdB0GvC/qfT0N+MGvekJZmqEJ7PI37/nm4faH52O4lAIMzjgDBl3V4Y7g/3Q==
X-Received: by 2002:a81:3795:: with SMTP id e143mr57862558ywa.508.1564102634705;
        Thu, 25 Jul 2019 17:57:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvqWEFwZQkrfitA6Kkkd4w1v3ABCwPOhKtz4Ae1P/VP6Ne/o2p7pXg6UyVMRNtnHz6JLkX
X-Received: by 2002:a81:3795:: with SMTP id e143mr57862547ywa.508.1564102634113;
        Thu, 25 Jul 2019 17:57:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564102634; cv=none;
        d=google.com; s=arc-20160816;
        b=JGOSglk+U7k/phAZ3L6lO3kqioSsQ/BqJXd6BwPqzos6AioYJFY0sTVK3OugGLjGkL
         rMJNT7BAc+GkHkFlhvOCZ86XLuXkBd3Cv3IWcmTbkXj4pqFHXFMo2znTjWxIE8ZEWGR8
         CsPTdIeGLx0fV4kAL5ge7TA9Bcf6g7YGDVkHkYKXmzGvTd0Cbvh0nVaAhslReGh70AkE
         vo49QT20pl+V/OLJszG97K4twH+jcejjoEHt1TyLSZwR7gJYOWz/kunQbINqK7yePmwJ
         f14Lb2xi4WLsyw16G1khP9s4gIRQFtLcJKoNfe0EBLQT5xbhVMkt9rMOdjGg4a+jdWEM
         oeww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=NZUo+DqUJdY6mTpO9a6/Oba2m7JMCHGUDDnmqd09n1Y=;
        b=PGr281f8W9DM52iiVHkdGHF/97S50p3y/zx2PMoHaEJmGmOVGEsTLZE2RjemHvz3nL
         5pFaK7ipABSsu2sLwp3r+HmAMKKilLZKf/ZqJkkIa7jQAfdGcneVwB1hIOX2Us0H3VC2
         xybIJdl5XwheSPqCdO6rYc6t3yIAMSAyTr+wgxxN0KZK14tggyb822t41LLMGaUAqYZT
         7/44ErGsewAVWzsWCl2D73XCRh/ri01KvKX5pIRbAiXVDsAUNX9TAUNx4JJYL9FAEVjc
         NSAnBKra/UI947QSkUnXJtg+NSIWSR3FXJA6K3QhUNz5JSQvjJJ5xHGRNKhGJhxrFrPe
         n86w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Y+Fdrsy5;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v135si18614327ywc.53.2019.07.25.17.57.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 17:57:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Y+Fdrsy5;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3a4fe90000>; Thu, 25 Jul 2019 17:57:14 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 25 Jul 2019 17:57:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 25 Jul 2019 17:57:13 -0700
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL108.nvidia.com
 (172.18.146.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 26 Jul
 2019 00:57:11 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 26 Jul 2019 00:57:11 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d3a4fe70000>; Thu, 25 Jul 2019 17:57:11 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <amd-gfx@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <nouveau@lists.freedesktop.org>, "Ralph
 Campbell" <rcampbell@nvidia.com>, Jason Gunthorpe <jgg@mellanox.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Christoph Hellwig
	<hch@lst.de>
Subject: [PATCH v2 7/7] mm/hmm: remove hmm_range vma
Date: Thu, 25 Jul 2019 17:56:50 -0700
Message-ID: <20190726005650.2566-8-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726005650.2566-1-rcampbell@nvidia.com>
References: <20190726005650.2566-1-rcampbell@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564102634; bh=NZUo+DqUJdY6mTpO9a6/Oba2m7JMCHGUDDnmqd09n1Y=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Type:Content-Transfer-Encoding;
	b=Y+Fdrsy5YTiGjTNAPneWU7N67hB8atyhiYSL7w1D9fRjSIU0CfPzTBs1+TJzPLeRd
	 lZg+U+KeM5lIDv23Uued3ANTxSgkBOSMlBDcqTqFQrMZetgu7wTZJ/18nJTgFUlQH7
	 9M9bqjlekVURUgBu+xXY9uNZnDjVOHAMuds+n9WmwMP9IafFxNItlvDkk5+7xf168C
	 /jBL6ulVlFTzr3sEKhNy9uO7sVIGou26UW/rn8gdQOF2MPV5eBWbEIWuUlRjHkUVyb
	 MyIizWpUTiSts0J7sLQ9gk5Raxzo7iAUIw4fsLk+jXjvBR9uvF6CPcFSA49r+/WBWC
	 ev8fK2+UEnDJg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since hmm_range_fault() doesn't use the struct hmm_range vma field,
remove it.

Suggested-by: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c | 7 +++----
 include/linux/hmm.h                   | 1 -
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouvea=
u/nouveau_svm.c
index 49b520c60fc5..a74530b5a523 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -496,12 +496,12 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct=
 hmm_range *range)
 				 range->start, range->end,
 				 PAGE_SHIFT);
 	if (ret) {
-		up_read(&range->vma->vm_mm->mmap_sem);
+		up_read(&range->hmm->mm->mmap_sem);
 		return (int)ret;
 	}
=20
 	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
-		up_read(&range->vma->vm_mm->mmap_sem);
+		up_read(&range->hmm->mm->mmap_sem);
 		return -EBUSY;
 	}
=20
@@ -509,7 +509,7 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct h=
mm_range *range)
 	if (ret <=3D 0) {
 		if (ret =3D=3D 0)
 			ret =3D -EBUSY;
-		up_read(&range->vma->vm_mm->mmap_sem);
+		up_read(&range->hmm->mm->mmap_sem);
 		hmm_range_unregister(range);
 		return ret;
 	}
@@ -682,7 +682,6 @@ nouveau_svm_fault(struct nvif_notify *notify)
 			 args.i.p.addr + args.i.p.size, fn - fi);
=20
 		/* Have HMM fault pages within the fault window to the GPU. */
-		range.vma =3D vma;
 		range.start =3D args.i.p.addr;
 		range.end =3D args.i.p.addr + args.i.p.size;
 		range.pfns =3D args.phys;
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index f3693dcc8b98..68949cf815f9 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -164,7 +164,6 @@ enum hmm_pfn_value_e {
  */
 struct hmm_range {
 	struct hmm		*hmm;
-	struct vm_area_struct	*vma;
 	struct list_head	list;
 	unsigned long		start;
 	unsigned long		end;
--=20
2.20.1

