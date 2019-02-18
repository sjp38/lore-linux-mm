Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9820C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:24:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 547F520836
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:24:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="Q5k32Tlp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 547F520836
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 042B98E0003; Mon, 18 Feb 2019 06:24:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 019468E0002; Mon, 18 Feb 2019 06:23:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E496B8E0003; Mon, 18 Feb 2019 06:23:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5BF8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:23:59 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id j132so11790018pgc.15
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:23:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=Ua2Y2pqLglvhPkZ5x4rnHUcO+Ns/IxJSCHYCvBPPNoc=;
        b=MR1t4X5RX6uT1BajnFkzhEHuwPhhZD7kNSkVB3gr/PeZhpov8FeY7UTLiGQfVdiYjF
         OgsYj6xvtx+6yCESQsQ3fRqwgUoNFnPST6rL/FavSLtOd1ZFfzhqBA8ixNV8W+Em/gN6
         kWt/woU/URM6QvYFWXR/+fwaGgxLo0mGfzkoaylNIighfs1PbR6rant49K7S811XvNEl
         Ill5LHRSYaa/wUE8fSwWCUjwqKyN+GZJX8Dtb2iltE0QjYFBshypCTws9P7eQ0R3jgbV
         OJDLDSg/Ly7MFWLOfHqggG9xzNyu2iSZeXpp7TyNjO9s59GvWBInFVFQ8a92ux1Qwobv
         Mc5g==
X-Gm-Message-State: AHQUAubeXmPXZ3ED3n6bEmrV+60QQ4PUo2cgR1wCq2/+7Ycms/Xtr+o/
	tYJZVIt/gFa89cHMh/ZL4sx7Fumzc2gzmeHc0n9IUeFDiNKNPhP4BmCUU17FGmveds2rRkoBANG
	KctGYkXH5gBomcAJ+enZQAW1dAcS4gguHQGEF37YOKmfQ+/2AxuXscoHF7QgNR4PXcA==
X-Received: by 2002:a65:624c:: with SMTP id q12mr18447375pgv.379.1550489039257;
        Mon, 18 Feb 2019 03:23:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbOPsk1vLOSNNXbNONbw5jkVhhAe2iGcPOoXrGJsuf9jb+t50P3MdlPFBXWi46/nC2M2Pu6
X-Received: by 2002:a65:624c:: with SMTP id q12mr18447311pgv.379.1550489038229;
        Mon, 18 Feb 2019 03:23:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550489038; cv=none;
        d=google.com; s=arc-20160816;
        b=dCjHHGGrVrcksSjCx1RleMgCbYzvvYKWjP4kEyEP/vmgpOxdJx09CsSKIRAEM01nY9
         xdCk73m5MsDRe34WUy86tQa+ZbnMigKHSQQLSS9kCMhw0vKsFQEORT8Uqn/JbDQbH97q
         T4j3FrmskSxPyAQB3/50o8y4UWKpBY47S71j9VFDRGlJniT10xBnS8QFw6zevRxoAujl
         V4F8rgBuVozH7wD2aGXoUFnv3+c3VVRqZZVf37TJ+Vah2pSTI2Bdxah2dZ95LM8B2i/b
         DiK2d6ksQ9rMLhy53AJvslaW0mWquJ1i7zLw95n9lAtQeUhsdPThfRFfxzuzaIyAVT2Q
         BFCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=Ua2Y2pqLglvhPkZ5x4rnHUcO+Ns/IxJSCHYCvBPPNoc=;
        b=htSPB5EY8Shj7sStWZbEKkmdrsX4GrLbC/HBpccFzme23GFtxZWfHiKAPHSlDrSg9H
         Q7Pu/62W9dxNP/58JSGMFdZX56LF4q6pCQcn2Mi19vtqIaH9fcQ3W/mzYiqBVH8+/zw2
         k1vOaE/WZjvlovJ95ARYFwFH34jaziIG65eOBOXaFZ0yY32NuNH5HJ4gpIGroTt2L2PN
         snYqzr7KUYiTvuovgUzuzi/v5Qaf128+kdTelq9qHuHHnr1vX+R4I576pGmfPCgnvOm9
         NHxzddvBEo8ZdGNLAS68Gqei0MZ4m2UEdKMYS8ipgzYfXMhRPE3pTZ0OhWm28kKnwyPz
         p3vA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=Q5k32Tlp;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 40.107.15.49 as permitted sender) smtp.mailfrom=Mark.Rutland@arm.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150049.outbound.protection.outlook.com. [40.107.15.49])
        by mx.google.com with ESMTPS id i12si12548219pgg.132.2019.02.18.03.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Feb 2019 03:23:58 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 40.107.15.49 as permitted sender) client-ip=40.107.15.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b=Q5k32Tlp;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 40.107.15.49 as permitted sender) smtp.mailfrom=Mark.Rutland@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector1-arm-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ua2Y2pqLglvhPkZ5x4rnHUcO+Ns/IxJSCHYCvBPPNoc=;
 b=Q5k32TlppmzCtC/ulLxPV4cJ/up4QTPgc4l+w4pRq97/6vkVBnHdHiVdbZVk9+I7jlarqrSXXxBZNuBBAZ1uzHvw3+tiIc+wr+vYE3vY7LMg9gwrWPZGSI0fSQVq2tLnWNt25zQuWsb9553d3Tf+WXwctnCJiby3+R+hSJHorHw=
Received: from VI1PR08MB3742.eurprd08.prod.outlook.com (20.178.15.26) by
 VI1PR08MB3040.eurprd08.prod.outlook.com (52.133.14.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Mon, 18 Feb 2019 11:23:53 +0000
Received: from VI1PR08MB3742.eurprd08.prod.outlook.com
 ([fe80::2508:8790:80cb:2f91]) by VI1PR08MB3742.eurprd08.prod.outlook.com
 ([fe80::2508:8790:80cb:2f91%6]) with mapi id 15.20.1622.018; Mon, 18 Feb 2019
 11:23:53 +0000
From: Mark Rutland <Mark.Rutland@arm.com>
To: Steven Price <Steven.Price@arm.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski
	<luto@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann
	<arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, Catalin Marinas
	<Catalin.Marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo
 Molnar <mingo@redhat.com>, James Morse <James.Morse@arm.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Peter Zijlstra
	<peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon
	<Will.Deacon@arm.com>, "x86@kernel.org" <x86@kernel.org>, "H. Peter Anvin"
	<hpa@zytor.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/13] mm: pagewalk: Add 'depth' parameter to pte_hole
Thread-Topic: [PATCH 06/13] mm: pagewalk: Add 'depth' parameter to pte_hole
Thread-Index: AQHUxVB7+BoYcscuHEWALktrgxL4UKXlbjYA
Date: Mon, 18 Feb 2019 11:23:53 +0000
Message-ID: <20190218112350.GE8036@lakrids.cambridge.arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-7-steven.price@arm.com>
In-Reply-To: <20190215170235.23360-7-steven.price@arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
x-originating-ip: [217.140.106.52]
x-clientproxiedby: LO2P265CA0329.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a4::29) To VI1PR08MB3742.eurprd08.prod.outlook.com
 (2603:10a6:803:bc::26)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Mark.Rutland@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 370a9579-1a6c-451b-2e5e-08d695939028
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:VI1PR08MB3040;
x-ms-traffictypediagnostic: VI1PR08MB3040:
x-microsoft-exchange-diagnostics:
 1;VI1PR08MB3040;20:j3A26RUPxyVy73IxvMJUrlJIUlgZiBohxGZW3WtKAldNIbRtRL02dglFutJEmghL1zRlUvvvHRC4JYyz2IkEipAse0/9hzIv/rPlCJJngEUBt8rdIS7ywKmZEHGbqDNDXvaBjuv71X+RaxJS9yDydhIAHZNNOKrmIObs9BHnGDs=
x-microsoft-antispam-prvs:
 <VI1PR08MB3040736376D9DA0A8F28240D84630@VI1PR08MB3040.eurprd08.prod.outlook.com>
x-forefront-prvs: 09525C61DB
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(376002)(39860400002)(346002)(396003)(136003)(40434004)(189003)(199004)(8936002)(186003)(99286004)(6636002)(25786009)(229853002)(81166006)(81156014)(7736002)(8676002)(5660300002)(26005)(68736007)(316002)(86362001)(446003)(1076003)(14454004)(72206003)(2906002)(6506007)(386003)(476003)(305945005)(11346002)(478600001)(102836004)(6116002)(3846002)(44832011)(6512007)(6246003)(53936002)(58126008)(71200400001)(54906003)(14444005)(4326008)(256004)(6436002)(33656002)(5024004)(71190400001)(105586002)(76176011)(52116002)(7416002)(486006)(97736004)(66066001)(6862004)(6486002)(106356001)(18370500001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR08MB3040;H:VI1PR08MB3742.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 AlU0ZG8sPR36ZyJW9lSnMGHUc7UfbyIfYyDgaUgLTowsd+vfNIW3shucra3cU+jblcq6ml48MigkLwjRFLEtcZyjOYQt7RCLhta3e9gb56Kwo8BnFvCuu4O1DV9ZWlGzVb+5TlwnuxE90mrvJU2PHM0qYL1UZNlvDCZILiUi9AmmTTNBFO7cRbPFt7OH5Xep39UvrF2/V1Ow6lPj3fseicxaHA15UO6MO1nzwF3cvc57UVg+KjnbHv5kCGAEZxI1zT0E/A8MxllNaYyLvO0WUi2rqLtflUHmRpq5cH6Q7NLFAYs4zswDtOyqg/YsYugBRwSb14Pfj4dMf1GSTjsO2iwz6rD00+DdUGfnzbmWz7m/xlFOu8vGyqL6lXEToTmK0lIXVh2N5kDH9os65+l1ZcK14D+7p7Vp/0+Dly7ZV4Y=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <B21B81C21E7E834CB0208E2833B2C1CC@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 370a9579-1a6c-451b-2e5e-08d695939028
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Feb 2019 11:23:52.4773
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR08MB3040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 05:02:27PM +0000, Steven Price wrote:
> The pte_hole() callback is called at multiple levels of the page tables.
> Code dumping the kernel page tables needs to know what at what depth
> the missing entry is. Add this is an extra parameter to pte_hole().
> When the depth isn't know (e.g. processing a vma) then -1 is passed.
>
> Note that depth starts at 0 for a PGD so that PUD/PMD/PTE retain their
> natural numbers as levels 2/3/4.
>
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  fs/proc/task_mmu.c |  4 ++--
>  include/linux/mm.h |  5 +++--
>  mm/hmm.c           |  2 +-
>  mm/migrate.c       |  1 +
>  mm/mincore.c       |  1 +
>  mm/pagewalk.c      | 16 ++++++++++------
>  6 files changed, 18 insertions(+), 11 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index f0ec9edab2f3..91131cd4e9e0 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -474,7 +474,7 @@ static void smaps_account(struct mem_size_stats *mss,=
 struct page *page,
>
>  #ifdef CONFIG_SHMEM
>  static int smaps_pte_hole(unsigned long addr, unsigned long end,
> -struct mm_walk *walk)
> +  __always_unused int depth, struct mm_walk *walk)
>  {
>  struct mem_size_stats *mss =3D walk->private;
>
> @@ -1203,7 +1203,7 @@ static int add_to_pagemap(unsigned long addr, pagem=
ap_entry_t *pme,
>  }
>
>  static int pagemap_pte_hole(unsigned long start, unsigned long end,
> -struct mm_walk *walk)
> +    __always_unused int depth, struct mm_walk *walk)
>  {
>  struct pagemapread *pm =3D walk->private;
>  unsigned long addr =3D start;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 1a4b1615d012..0418a018d7b3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1420,7 +1420,8 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_a=
rea_struct *start_vma,
>   *       pmd_trans_huge() pmds.  They may simply choose to
>   *       split_huge_page() instead of handling it explicitly.
>   * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
> - * @pte_hole: if set, called for each hole at all levels
> + * @pte_hole: if set, called for each hole at all levels,
> + *            depth is -1 if not known
>   * @hugetlb_entry: if set, called for each hugetlb entry
>   * @test_walk: caller specific callback function to determine whether
>   *             we walk over the current vma or not. Returning 0
> @@ -1445,7 +1446,7 @@ struct mm_walk {
>  int (*pte_entry)(pte_t *pte, unsigned long addr,
>   unsigned long next, struct mm_walk *walk);
>  int (*pte_hole)(unsigned long addr, unsigned long next,
> -struct mm_walk *walk);
> +int depth, struct mm_walk *walk);
>  int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
>       unsigned long addr, unsigned long next,
>       struct mm_walk *walk);
> diff --git a/mm/hmm.c b/mm/hmm.c
> index a04e4b810610..e3e6b8fda437 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -440,7 +440,7 @@ static void hmm_range_need_fault(const struct hmm_vma=
_walk *hmm_vma_walk,
>  }
>
>  static int hmm_vma_walk_hole(unsigned long addr, unsigned long end,
> -     struct mm_walk *walk)
> +     __always_unused int depth, struct mm_walk *walk)
>  {
>  struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
>  struct hmm_range *range =3D hmm_vma_walk->range;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index d4fd680be3b0..8b62a9fecb5c 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2121,6 +2121,7 @@ struct migrate_vma {
>
>  static int migrate_vma_collect_hole(unsigned long start,
>      unsigned long end,
> +    __always_unused int depth,
>      struct mm_walk *walk)
>  {
>  struct migrate_vma *migrate =3D walk->private;
> diff --git a/mm/mincore.c b/mm/mincore.c
> index 218099b5ed31..c4edbc688241 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -104,6 +104,7 @@ static int __mincore_unmapped_range(unsigned long add=
r, unsigned long end,
>  }
>
>  static int mincore_unmapped_range(unsigned long addr, unsigned long end,
> +   __always_unused int depth,
>     struct mm_walk *walk)
>  {
>  walk->private +=3D __mincore_unmapped_range(addr, end,
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index dac0c848b458..b8038f852f06 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -38,7 +38,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long add=
r, unsigned long end,
>  next =3D pmd_addr_end(addr, end);
>  if (pmd_none(*pmd)) {
>  if (walk->pte_hole)
> -err =3D walk->pte_hole(addr, next, walk);
> +err =3D walk->pte_hole(addr, next, 3, walk);
>  if (err)
>  break;
>  continue;
> @@ -88,7 +88,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long add=
r, unsigned long end,
>  next =3D pud_addr_end(addr, end);
>  if (pud_none(*pud)) {
>  if (walk->pte_hole)
> -err =3D walk->pte_hole(addr, next, walk);
> +err =3D walk->pte_hole(addr, next, 2, walk);
>  if (err)
>  break;
>  continue;
> @@ -123,13 +123,17 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long=
 addr, unsigned long end,
>  p4d_t *p4d;
>  unsigned long next;
>  int err =3D 0;
> +/* If the p4ds are actually just pgds then we should report a depth
> + * of 0 not 1 (as a missing entry is really a missing pgd
> + */

Nit: comment style violation. This should look like:
should be:

/*
 * If the p4ds are actually just pgds then we should report a depth
 * of 0 not 1 (as a missing entry is really a missing pgd
 */

> +int depth =3D (PTRS_PER_P4D =3D=3D 1)?0:1;

Nit: the ternary should have spacing.

We don't seem to do this at any other level that could be folded, so why
does p4d need special care?

For example, what happens on arm64 when using 64K pages and 3 level
paging, where puds are folded into pgds?

Thanks,
Mark.

>
>  p4d =3D p4d_offset(pgd, addr);
>  do {
>  next =3D p4d_addr_end(addr, end);
>  if (p4d_none_or_clear_bad(p4d)) {
>  if (walk->pte_hole)
> -err =3D walk->pte_hole(addr, next, walk);
> +err =3D walk->pte_hole(addr, next, depth, walk);
>  if (err)
>  break;
>  continue;
> @@ -160,7 +164,7 @@ static int walk_pgd_range(unsigned long addr, unsigne=
d long end,
>  next =3D pgd_addr_end(addr, end);
>  if (pgd_none_or_clear_bad(pgd)) {
>  if (walk->pte_hole)
> -err =3D walk->pte_hole(addr, next, walk);
> +err =3D walk->pte_hole(addr, next, 0, walk);
>  if (err)
>  break;
>  continue;
> @@ -206,7 +210,7 @@ static int walk_hugetlb_range(unsigned long addr, uns=
igned long end,
>  if (pte)
>  err =3D walk->hugetlb_entry(pte, hmask, addr, next, walk);
>  else if (walk->pte_hole)
> -err =3D walk->pte_hole(addr, next, walk);
> +err =3D walk->pte_hole(addr, next, -1, walk);
>
>  if (err)
>  break;
> @@ -249,7 +253,7 @@ static int walk_page_test(unsigned long start, unsign=
ed long end,
>  if (vma->vm_flags & VM_PFNMAP) {
>  int err =3D 1;
>  if (walk->pte_hole)
> -err =3D walk->pte_hole(start, end, walk);
> +err =3D walk->pte_hole(start, end, -1, walk);
>  return err ? err : 1;
>  }
>  return 0;
> --
> 2.20.1
>
IMPORTANT NOTICE: The contents of this email and any attachments are confid=
ential and may also be privileged. If you are not the intended recipient, p=
lease notify the sender immediately and do not disclose the contents to any=
 other person, use it for any purpose, or store or copy the information in =
any medium. Thank you.

