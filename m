Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D86E7C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:51:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 328FF21019
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 23:51:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="r6fY0Qsa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 328FF21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 888566B0003; Wed, 22 May 2019 19:51:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8383B6B0006; Wed, 22 May 2019 19:51:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D8DC6B0007; Wed, 22 May 2019 19:51:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1ED826B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 19:51:11 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26so6018306eda.15
        for <linux-mm@kvack.org>; Wed, 22 May 2019 16:51:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=sSvVhwtctmrWpOQ3fK6+ljrWTR6VX73lnQdRCcTtO3s=;
        b=RQnhT8K+lxzaRIuaPt11RqMV2hGj13EtlYkfqR3dDPKerb2/W8lS/EyhmZpLQ6N2Yr
         2jDuPbE/r9OSZB9qd84BfmPGqGnfHKFaLdpmH+f3WvLZtB11cAnn6VjDpHXTJLQ39pdd
         Lmicx3WP026BkmiZOm2nLgwu5/rla1FTJkCHXSdCvQmbEGMlLugr7PKt3BgmgaZgQwG8
         A7RNXrRqUNJxywERoBuTs0Xy7n6n+FTeHlSVrsHliz9c3nA68YXlxXfqB5pfm+tkty2l
         pNr2optZSiTNcAPmZkv+FPv4L56H9Fu7EmnUZuEe/IvwjTCiC4G85k4APZqXS1AQEzL/
         5kPQ==
X-Gm-Message-State: APjAAAVEnQLolv/ZQsa/PD8dJ66l9RxTLCV0p593iqm8LBDAZu1OHLF2
	JnL/WdVqfazyEXjhQ6BKv0Q98KKYEgDMqxYW6L3faZAp7NFqoZbzp47q0YZniVBiudoTZd8ly4u
	xM7/Rq7TivJ4CAQnmjoEkiVpOzFLjFWMapiMLJ3CKIi93aQzvhh7HXk+rbrct2CxP2A==
X-Received: by 2002:a17:906:8496:: with SMTP id m22mr25307595ejx.281.1558569070559;
        Wed, 22 May 2019 16:51:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwk8k+3ltW2Zj8oO+7HSM4Dn9HVbURUePKeo1JpMuxa+Fz3D2/a94+FK+1XBdOGP3i+6kDU
X-Received: by 2002:a17:906:8496:: with SMTP id m22mr25307550ejx.281.1558569069715;
        Wed, 22 May 2019 16:51:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558569069; cv=none;
        d=google.com; s=arc-20160816;
        b=aW0BR5P38FyH8W7XcrO+vzH/w5bFFdPMWlejN9r+x1dQmuwwr2x/8lnMnQZpEB7GNP
         v7Ke/jNc97oj0XlkXd3zhlKuysSKBS/R5S6zSNn/f0k3EhCF5eqEaEd9H6PsjVPjzBbA
         ERCPOzVXii+57GANoHjXwHLMoP/TjzyjuEDZhpJRumM2tKtxdydwqe0hmwi9PBhyIxWq
         Dkd/p9X03g5NuTH7zYuw0c09T5/rhK9hr/NXoukT6yNJQotF5JXficd+dUeXbtwvDGSq
         27VAQhacoSVNo3VaQvfSDwk8VsvO+a41zqT1wVd5igsDtd8Mu8cIPPCCi5SDZykZMesK
         Yn+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=sSvVhwtctmrWpOQ3fK6+ljrWTR6VX73lnQdRCcTtO3s=;
        b=ixVViS9q3cUdoBll93qpdnI//TWXGcJNc8fcUe/nun2PwNUAXx+qpgWcrBHlyMN3SM
         GErDBaifbGvchZJTsfxjN6GPV7TP2v73lNmvy7shD/4QTbIM4G93yA5MyqzTpbOSCgAF
         SieXiMqy6chjYshODmfBKjjl5AqBG9BwHgAQsFYqwp6HIQQRsQLlK/FGjCf+lDPBf8Bt
         bOJHwp+oIxYhnof3lU/cXOMSeNEm2nn/a5TBPEV1YMXTO3Ki7troVcmxBjThNllHXDFv
         MNMn0qLjRdoH+UTes/tQn7aRkMvC+LAPWESUuYtHLAWY9+EFHMNt/wl73HBsKEhCSCYA
         2yXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=r6fY0Qsa;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.77 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150077.outbound.protection.outlook.com. [40.107.15.77])
        by mx.google.com with ESMTPS id c3si1790006ede.203.2019.05.22.16.51.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 May 2019 16:51:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.77 as permitted sender) client-ip=40.107.15.77;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=r6fY0Qsa;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.77 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sSvVhwtctmrWpOQ3fK6+ljrWTR6VX73lnQdRCcTtO3s=;
 b=r6fY0QsagD4T3lYr324llbBm1Ij3GgmO8vRKmYlTfYgryj7tYJsI96slftBYVL6fPNOk627WGySSPKSO/fjh5VA3B7bKI2HEKiMGnH4Yl6cal2dQcb78BRRAEY5Y8eGrtVihUOD1eA1gUqIoM2/oNo17NKmDZGyityyyKC+DjsU=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4702.eurprd05.prod.outlook.com (20.176.4.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.15; Wed, 22 May 2019 23:51:07 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1922.013; Wed, 22 May 2019
 23:51:07 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Jerome Glisse <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
Subject: Re: [PATCH] hmm: Suppress compilation warnings when
 CONFIG_HUGETLB_PAGE is not set
Thread-Topic: [PATCH] hmm: Suppress compilation warnings when
 CONFIG_HUGETLB_PAGE is not set
Thread-Index: AQHVENfOFtz/QULIxkuTKkQu4SkyeqZ3lrcAgAA6BQA=
Date: Wed, 22 May 2019 23:51:06 +0000
Message-ID: <20190522235102.GA15370@mellanox.com>
References: <20190522195151.GA23955@ziepe.ca>
 <20190522132322.15605c8b344f46b31ea8233b@linux-foundation.org>
In-Reply-To: <20190522132322.15605c8b344f46b31ea8233b@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR01CA0030.prod.exchangelabs.com (2603:10b6:208:10c::43)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.49.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e765983f-5c08-4521-565b-08d6df105b46
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4702;
x-ms-traffictypediagnostic: VI1PR05MB4702:
x-microsoft-antispam-prvs:
 <VI1PR05MB47027C621F158EAE00A95965CF000@VI1PR05MB4702.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1468;
x-forefront-prvs: 0045236D47
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(376002)(136003)(396003)(366004)(346002)(199004)(189003)(5660300002)(7736002)(8676002)(81166006)(81156014)(2616005)(8936002)(305945005)(486006)(99286004)(316002)(11346002)(2906002)(446003)(6246003)(54906003)(25786009)(66066001)(478600001)(86362001)(53936002)(6512007)(1076003)(3846002)(6116002)(102836004)(68736007)(186003)(6506007)(53546011)(6486002)(386003)(476003)(6436002)(66556008)(66446008)(229853002)(33656002)(73956011)(66946007)(66476007)(71190400001)(71200400001)(64756008)(14454004)(14444005)(256004)(36756003)(6916009)(76176011)(26005)(4326008)(52116002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4702;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 l8HhGanMRhGyjN0BS5oQYIISAVQE1uQkv8nJ/CelipO/szhgzvEWpA5Bsql5PWDQFWDRcJUKJcBG1Q/3mAcYTepEnJVADhJGq4i8/2ei0it73ar+27a5zC0SjTcUQchKvECmoqzdE/5fy7OFYrhzSl1AvzB9cb8ZN2gvc/tnyUam08B7dlBnO9deWu5TlJhQx+lLFMn/pFhx+SJNg5VBv9xtXWZTaClphHnSs0N5SDrTlER6WAkOlXcuihQnuoAOV8rxmsr7tZnCCUB8C6jEQgcCSDW8bJnOonApIYx2CZFMURoOOc7R8kmtuhExZGFdSMJOmmhdkQGfYcZKHrgqcGOPYtd5dUgd6lfHF7cRyQeNc24oA97SFCepRHw8btez5JA+vEEONPn7YuP8AmfAxWJRYXzrq6UK+UH3dpIOBu8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FFABB95CECC23D49A4F00272338576E9@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e765983f-5c08-4521-565b-08d6df105b46
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 May 2019 23:51:07.5394
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4702
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 01:23:22PM -0700, Andrew Morton wrote:
> On Wed, 22 May 2019 19:51:55 +0000 Jason Gunthorpe <jgg@mellanox.com> wro=
te:
>=20
> > gcc reports that several variables are defined but not used.
> >=20
> > For the first hunk CONFIG_HUGETLB_PAGE the entire if block is already
> > protected by pud_huge() which is forced to 0. None of the stuff under
> > the ifdef causes compilation problems as it is already stubbed out in
> > the header files.
> >=20
> > For the second hunk the dummy huge_page_shift macro doesn't touch the
> > argument, so just inline the argument.
> >=20
> > ...
> >
> > +++ b/mm/hmm.c
> > @@ -797,7 +797,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
> >  			return hmm_vma_walk_hole_(addr, end, fault,
> >  						write_fault, walk);
> > =20
> > -#ifdef CONFIG_HUGETLB_PAGE
> >  		pfn =3D pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> >  		for (i =3D 0; i < npages; ++i, ++pfn) {
> >  			hmm_vma_walk->pgmap =3D get_dev_pagemap(pfn,
> > @@ -813,9 +812,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
> >  		}
> >  		hmm_vma_walk->last =3D end;
> >  		return 0;
> > -#else
> > -		return -EINVAL;
> > -#endif
> >  	}
>=20
> Fair enough.
>=20
> >  	split_huge_pud(walk->vma, pudp, addr);
> > @@ -1024,9 +1020,8 @@ long hmm_range_snapshot(struct hmm_range *range)
> >  			return -EFAULT;
> > =20
> >  		if (is_vm_hugetlb_page(vma)) {
> > -			struct hstate *h =3D hstate_vma(vma);
> > -
> > -			if (huge_page_shift(h) !=3D range->page_shift &&
> > +			if (huge_page_shift(hstate_vma(vma)) !=3D
> > +				    range->page_shift &&
> >  			    range->page_shift !=3D PAGE_SHIFT)
> >  				return -EINVAL;
>=20
> Also fair enough.  But why the heck is huge_page_shift() a macro?  We
> keep doing that and it bites so often :(

Let's fix it, with the below? (compile tested)

Note __alloc_bootmem_huge_page was returning null but the signature
was unsigned int.

From b5e2ff3c88e6962d0e8297c87af855e6fe1a584e Mon Sep 17 00:00:00 2001
From: Jason Gunthorpe <jgg@mellanox.com>
Date: Wed, 22 May 2019 20:45:59 -0300
Subject: [PATCH] mm: Make !CONFIG_HUGE_PAGE wrappers into static inlines

Instead of using defines, which looses type safety and provokes unused
variable warnings from gcc, put the constants into static inlines.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 include/linux/hugetlb.h | 102 +++++++++++++++++++++++++++++++++-------
 1 file changed, 86 insertions(+), 16 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edf476c8cfb9c0..f895a79c6f5cb4 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -608,22 +608,92 @@ static inline void huge_ptep_modify_prot_commit(struc=
t vm_area_struct *vma,
=20
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
-#define alloc_huge_page(v, a, r) NULL
-#define alloc_huge_page_node(h, nid) NULL
-#define alloc_huge_page_nodemask(h, preferred_nid, nmask) NULL
-#define alloc_huge_page_vma(h, vma, address) NULL
-#define alloc_bootmem_huge_page(h) NULL
-#define hstate_file(f) NULL
-#define hstate_sizelog(s) NULL
-#define hstate_vma(v) NULL
-#define hstate_inode(i) NULL
-#define page_hstate(page) NULL
-#define huge_page_size(h) PAGE_SIZE
-#define huge_page_mask(h) PAGE_MASK
-#define vma_kernel_pagesize(v) PAGE_SIZE
-#define vma_mmu_pagesize(v) PAGE_SIZE
-#define huge_page_order(h) 0
-#define huge_page_shift(h) PAGE_SHIFT
+
+static inline struct page *alloc_huge_page(struct vm_area_struct *vma,
+					   unsigned long addr,
+					   int avoid_reserve)
+{
+	return NULL;
+}
+
+static inline struct page *alloc_huge_page_node(struct hstate *h, int nid)
+{
+	return NULL;
+}
+
+static inline struct page *
+alloc_huge_page_nodemask(struct hstate *h, int preferred_nid, nodemask_t *=
nmask)
+{
+	return NULL;
+}
+
+static inline struct page *alloc_huge_page_vma(struct hstate *h,
+					       struct vm_area_struct *vma,
+					       unsigned long address)
+{
+	return NULL;
+}
+
+static inline int __alloc_bootmem_huge_page(struct hstate *h)
+{
+	return 0;
+}
+
+static inline struct hstate *hstate_file(struct file *f)
+{
+	return NULL;
+}
+
+static inline struct hstate *hstate_sizelog(int page_size_log)
+{
+	return NULL;
+}
+
+static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
+{
+	return NULL;
+}
+
+static inline struct hstate *hstate_inode(struct inode *i)
+{
+	return NULL;
+}
+
+static inline struct hstate *page_hstate(struct page *page)
+{
+	return NULL;
+}
+
+static inline unsigned long huge_page_size(struct hstate *h)
+{
+	return PAGE_SIZE;
+}
+
+static inline unsigned long huge_page_mask(struct hstate *h)
+{
+	return PAGE_MASK;
+}
+
+static inline unsigned long vma_kernel_pagesize(struct vm_area_struct *vma=
)
+{
+	return PAGE_SIZE;
+}
+
+static inline unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
+{
+	return PAGE_SIZE;
+}
+
+static inline unsigned int huge_page_order(struct hstate *h)
+{
+	return 0;
+}
+
+static inline unsigned int huge_page_shift(struct hstate *h)
+{
+	return PAGE_SHIFT;
+}
+
 static inline bool hstate_is_gigantic(struct hstate *h)
 {
 	return false;
--=20
2.21.0

