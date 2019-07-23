Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1D55C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:57:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 832BB21897
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:57:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="GphKr1rt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 832BB21897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 175FF6B0008; Tue, 23 Jul 2019 19:57:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 125F16B000A; Tue, 23 Jul 2019 19:57:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F31978E0002; Tue, 23 Jul 2019 19:57:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2EC56B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:57:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so29127323edc.17
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:57:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=dfbE91tPg3qoZ5tvCt0S1fLEh+x8NOe8dVKXjYHbtos=;
        b=fPE5mC8J3N14JK5BsaYP2V2uVHmIDGdFclZdDT2LN7fye/6SomY9GVztNAONsp39Ov
         C6oqANscrZgzLA5CZpS7T8GlRRHiS5lVg0VPsZdxO9vv02bcdls6rsun5cdzXyazrgxS
         ZFCd/UWzwPjVPpYGiVfAkZw0qO2BsoA3lVsx/kUa/erhdjw04mTW8cE5pyLIT4ox+pLR
         /34zboJpVwFOS/bF9GDK8M9z5rnoU/PmTp6ORHdLnuZUG7Lmfdj4Eu+QgBLiEhvyImbB
         9ZqArF0Y2D3iM85qC6Er/cVnVT0au4oDlwne/Pn9SmByX3M1X7Xf8Kkjw5IqBUW46cfJ
         DNvg==
X-Gm-Message-State: APjAAAWhBG9UNfnsYwUkLTbpZdkdR2WA5jspTavW9AkIukVD+gC/2Rug
	haA2HZQUkBUecRpR3MyucSETqvkfnLCJQ6wDToEEQVIXC6webJyd1tzdLB1Vd8bQmRs67Od9qla
	DSYGbmrmbqBB/NTWVlOdaA4j7iflLnm+ru1zklRCBtXr9ojYrLo1zgL8GPRR+WG4HvQ==
X-Received: by 2002:a17:906:644c:: with SMTP id l12mr58112384ejn.142.1563926275216;
        Tue, 23 Jul 2019 16:57:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCavgI+VI0VU7BpkVfP6DittssqsmpRW9RdsLsbH4jGrmwzm4rhG7/USfQvENOrjgvmIce
X-Received: by 2002:a17:906:644c:: with SMTP id l12mr58112348ejn.142.1563926274292;
        Tue, 23 Jul 2019 16:57:54 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563926274; cv=pass;
        d=google.com; s=arc-20160816;
        b=zJ74+r3Yw0ICq7hnCeJm6iM0Ex/n7v5Lp1WYbJ0N4ltqpbkqGb1Ww8ZprPQ0Cq9ipW
         X3z7AU5zmNC0sz2KHccfNlk1IJtLmd/vUSOJGP8iw+rDa0xMN7LWXxbPD3NlzwrWwsIY
         +J3QvOgRyCCoPasgAf8hDr9CueYROnp1q6fjDNJaFHjTb42NJfLu99wansOLWNONVpo0
         YGA5qcr2j1REC3r9LqM/ug134W6Qh7Se+GqHc6fcXSLS61EOvb/hJNS+SmiEEA/aD713
         OSCeF8ZkoBNx41FEKyUwhmc/X9eWYUqxT43jLyRFn+9kCDyw45BrfG9SP4seZpMhS1By
         QXkw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=dfbE91tPg3qoZ5tvCt0S1fLEh+x8NOe8dVKXjYHbtos=;
        b=fUj6pwm4mtBGd9vcdgIr+drmjzVHcubHIDxMZ1abJfA8dqKVhEoyTz+Bp/ZudGN4V8
         +FET0DnNdnjlPefdXNaC5dNtkWhSx9jjnbSL+fkYgBjWNeNtQKIBAStnX7hlA1KtShWR
         oRw+B/+3KjPDg24gn+S63FD+E5u1YGX6FZC6i2fKmj2HrgzCkh7LaTZGfB5ZqsMxTSmz
         lgpQodDtCCWpzxOpjUVzZYM88HbhKYpCo950SnB+K3Jn7f9oqyBsx5thp8HXUUJbWnEh
         2bLe211EMipdEUimhlUwQezJRmRl6DmTlEKT4Arz/yz6poUhk9IC8fM3TqRQAujpj5Fq
         uSDA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=GphKr1rt;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.86 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10086.outbound.protection.outlook.com. [40.107.1.86])
        by mx.google.com with ESMTPS id f30si8199930edb.390.2019.07.23.16.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 23 Jul 2019 16:57:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.86 as permitted sender) client-ip=40.107.1.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=GphKr1rt;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.86 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Fz+GTKquN1B0r1UsoyOgaNoEgVUiJ/oIQxPWssFSa3d/+/aYHrXBgxfbE7vB6wpQvXw+RwtkhB0nqVRuW5rpYN0fCMxh+NkwQ7bnDkyz/7NrtvazUuio6qWEkX38mCb2VYu0nUK7SOp4OIB2FbBkvb2OsOPFl7NZ6FSOvUgNzDlvXiPyZOLosOS2R5rIab044U6suzHfzOCASa0bBGijw5/889IBCuAsFaEbj12IwMnYu1P/t/T5ZMjq6PGri2RT0Ms4ljD5YBElB1d69aQ1EmD/b2rUxKSojxajjwuCmmPi94i5kMOD5k6ExLTxQFfSQ0j56lqmu0MGE3E9SDczdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dfbE91tPg3qoZ5tvCt0S1fLEh+x8NOe8dVKXjYHbtos=;
 b=hK+OOqnQcA5HRngpSQj2d5YkDw66txWr8Gc7rVzbRAszPtvH+J/JnGU0DDIsel/O/9ip9JiauX8UGKHQmtt1vFFmgxzuRo2c8r4LHhcsLcsYI6Np9cGoMFY5Zj3hUem4rP2nGs3Dz8JfuGfJ4djI4Z24+9eKO+oLPTPDn79bteDbGbQDnJdHzbAUzadp3t0APF1liI2URW0NfrAwukWgaQE3ZL8gzWPpPHKa29EkCighF2Hlh7mXK4ZraJI55MfWTe0JAIW5P4hFh0gRKp9NqnkZO0cUIVyvD5a1kaJPFDybqjFO5VNzqOTUywEVeB47lKteze2ZEaor7FGT1YF+UQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dfbE91tPg3qoZ5tvCt0S1fLEh+x8NOe8dVKXjYHbtos=;
 b=GphKr1rtJJEDecXAWp1/nIcT1rRkqGDiTrBWMzLOX2TEHNtMpTfAq4PBaT+pYd4AwE2ne/+MgyL4cOG/zyXvpbKDKFJ4L7wTVfB++S7S4prVjz+5rMqL48C/jrAr9K7JJdBLU9TxAu9K6LpXZq2B05C1rLks/AvrNBzlPLqL/30=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5037.eurprd05.prod.outlook.com (20.177.52.74) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.16; Tue, 23 Jul 2019 23:57:52 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2094.013; Tue, 23 Jul 2019
 23:57:52 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] mm/hmm: a few more C style and comment clean ups
Thread-Topic: [PATCH 1/2] mm/hmm: a few more C style and comment clean ups
Thread-Index: AQHVQa6ccTnGbJ4iyUKRepNq/WEUcqbY4X2A
Date: Tue, 23 Jul 2019 23:57:52 +0000
Message-ID: <20190723235747.GP15331@mellanox.com>
References: <20190723233016.26403-1-rcampbell@nvidia.com>
 <20190723233016.26403-2-rcampbell@nvidia.com>
In-Reply-To: <20190723233016.26403-2-rcampbell@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR02CA0048.namprd02.prod.outlook.com
 (2603:10b6:207:3d::25) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2d870704-40c9-48e3-545d-08d70fc992a8
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5037;
x-ms-traffictypediagnostic: VI1PR05MB5037:
x-microsoft-antispam-prvs:
 <VI1PR05MB50374C489F4CF0EB5003882ECFC70@VI1PR05MB5037.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0107098B6C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(396003)(136003)(39860400002)(346002)(376002)(189003)(199004)(7736002)(486006)(14454004)(305945005)(8936002)(81156014)(2616005)(14444005)(256004)(229853002)(1076003)(8676002)(71190400001)(36756003)(66066001)(5660300002)(71200400001)(6486002)(386003)(6916009)(316002)(446003)(11346002)(86362001)(54906003)(478600001)(99286004)(3846002)(68736007)(66946007)(66446008)(76176011)(64756008)(476003)(52116002)(6512007)(186003)(66476007)(66556008)(6436002)(53936002)(6116002)(102836004)(25786009)(53546011)(26005)(4326008)(6506007)(33656002)(2906002)(6246003)(81166006)(334744003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5037;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 YsYw+TXrljd5KVznr5GNkrWU0koHjVRt9/Hg7Dq39UbN9i08nNtB4qlVNo5BNV2Bi6PST7LmG3GWRF3dMwZWG7SYj7JZqbFoG7TSfF5IVWM/1TGCmxTLL8RJM/3WOfCOosDRB4jycVYsNwvz+ucdl17NI+fS/SPOdgX5aiJ26PT6WsWRoF44wHlmfTD0zHMwteU1xssHMhXGqR3tvJmf3eYG86OzE6RIQBo6ma/NQarvxhQ+YtqO69xHV6/qE6edjCoNRUkj8wzAFRxbkSVl4aS+IItdEbSHHrgAUV1JS4D0XBFT5KCfZWVeoNhUYi7CUdg7gd0DOWFBYcJLYrk62/FFSeRPTjPOWZGMXJzOtEa+O+g5Jnil50fuu8sTzXdp6up+hya5n4eCq7zWhClGJsRuGPeR2wD9zKK06dYLH1g=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <0ADC3FCB7798D64EAEAEF7472C17BC21@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2d870704-40c9-48e3-545d-08d70fc992a8
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Jul 2019 23:57:52.2021
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5037
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 04:30:15PM -0700, Ralph Campbell wrote:
> -	if (pmd_huge(pmd) && (range->vma->vm_flags & VM_HUGETLB))
> +	if (pmd_huge(pmd) && is_vm_hugetlb_page(vma))
>  		return hmm_pfns_bad(start, end, walk);

This one is not a minor cleanup.. I think it should be done on its
own commit, and more comletely, maybe based on the below..

If vma is always the same as the the first vma, then your hunk above
here is much better than introducing a hugetlb flag as I did below..

Although I don't understand why we have this test when it does seem to
support huge pages, and the commit log suggests hugetlbfs was
deliberately supported. So a comment (or deletion) sure would be nice.

So maybe sequence this into your series?

Jason

From 6ea7cd2565b5b660d22a659b71b62614e66bc345 Mon Sep 17 00:00:00 2001
From: Jason Gunthorpe <jgg@mellanox.com>
Date: Tue, 23 Jul 2019 12:28:32 -0300
Subject: [PATCH] mm/hmm: remove hmm_range vma

This value is only read inside hmm_vma_walk_pmd() and all the callers,
through walk_page_range(), always set the value. The proper place for
per-walk data is in hmm_vma_walk, and since the only usage is a vm_flags
test just precompute and store that.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/gpu/drm/nouveau/nouveau_svm.c |  7 +++----
 include/linux/hmm.h                   |  1 -
 mm/hmm.c                              | 11 ++++++-----
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_svm.c b/drivers/gpu/drm/nouvea=
u/nouveau_svm.c
index a9c5c58d425b3d..4f4bec40b887a6 100644
--- a/drivers/gpu/drm/nouveau/nouveau_svm.c
+++ b/drivers/gpu/drm/nouveau/nouveau_svm.c
@@ -495,12 +495,12 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct=
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
@@ -508,7 +508,7 @@ nouveau_range_fault(struct hmm_mirror *mirror, struct h=
mm_range *range)
 	if (ret <=3D 0) {
 		if (ret =3D=3D 0)
 			ret =3D -EBUSY;
-		up_read(&range->vma->vm_mm->mmap_sem);
+		up_read(&range->hmm->mm->mmap_sem);
 		hmm_range_unregister(range);
 		return ret;
 	}
@@ -681,7 +681,6 @@ nouveau_svm_fault(struct nvif_notify *notify)
 			 args.i.p.addr + args.i.p.size, fn - fi);
=20
 		/* Have HMM fault pages within the fault window to the GPU. */
-		range.vma =3D vma;
 		range.start =3D args.i.p.addr;
 		range.end =3D args.i.p.addr + args.i.p.size;
 		range.pfns =3D args.phys;
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 9f32586684c9c3..d4b89f655817cd 100644
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
diff --git a/mm/hmm.c b/mm/hmm.c
index 16b6731a34db79..3d8cdfb67a6ab8 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -285,8 +285,9 @@ struct hmm_vma_walk {
 	struct hmm_range	*range;
 	struct dev_pagemap	*pgmap;
 	unsigned long		last;
-	bool			fault;
-	bool			block;
+	bool			fault : 1;
+	bool			block : 1;
+	bool			hugetlb : 1;
 };
=20
 static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
@@ -635,7 +636,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 	if (pmd_none(pmd))
 		return hmm_vma_walk_hole(start, end, walk);
=20
-	if (pmd_huge(pmd) && (range->vma->vm_flags & VM_HUGETLB))
+	if (pmd_huge(pmd) && hmm_vma_walk->hugetlb)
 		return hmm_pfns_bad(start, end, walk);
=20
 	if (thp_migration_supported() && is_pmd_migration_entry(pmd)) {
@@ -994,7 +995,7 @@ long hmm_range_snapshot(struct hmm_range *range)
 			return -EPERM;
 		}
=20
-		range->vma =3D vma;
+		hmm_vma_walk.hugetlb =3D vma->vm_flags & VM_HUGETLB;
 		hmm_vma_walk.pgmap =3D NULL;
 		hmm_vma_walk.last =3D start;
 		hmm_vma_walk.fault =3D false;
@@ -1090,7 +1091,7 @@ long hmm_range_fault(struct hmm_range *range, bool bl=
ock)
 			return -EPERM;
 		}
=20
-		range->vma =3D vma;
+		hmm_vma_walk.hugetlb =3D vma->vm_flags & VM_HUGETLB;
 		hmm_vma_walk.pgmap =3D NULL;
 		hmm_vma_walk.last =3D start;
 		hmm_vma_walk.fault =3D true;
--=20
2.22.0

