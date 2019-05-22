Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22502C46470
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:52:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA0482089E
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:51:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="r9//5brU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA0482089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62E4E6B0003; Wed, 22 May 2019 15:51:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DE8B6B0006; Wed, 22 May 2019 15:51:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A6E66B0007; Wed, 22 May 2019 15:51:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26E326B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 15:51:59 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g19so3098294qtb.18
        for <linux-mm@kvack.org>; Wed, 22 May 2019 12:51:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-id:content-transfer-encoding:mime-version;
        bh=/lPG7gYiwa006Pu2zvxjB339XzWnVN5/iKdeTEMqmek=;
        b=dwthtojYE7EA8CYMGMHBOnkziGuXTKRtPQCsYYizNhq3jm4g4SHOcs7p4WbZFFtxLl
         RpZq14Mihdx4CVtJQ0OTCymM6nBRZp4BdIL6F9A/KRuD+4EdzKyJD7GIUg/X+muQms50
         fFmPZmsh0+8A0PO5+EOUBHAg7x+L/SdIUUOWcXll+bgoak6ROuQJ8F4RYx4+nDd1t5Uh
         POAruZJLQqh6kIbOxI5k2ss/Bzd5OAicvnbfH/23sM3WprmzBDua98B+Q3C4PG7EVGSd
         +UdpXWzd/65nFfHh/v4cr3jk2ZWaDAXuhR67eKlkmrSCld5SGauEtshUiDhWg6z6e1VV
         QZPg==
X-Gm-Message-State: APjAAAUkRzP+1NN1IQfQS8Iqsv0BNc1kuoZEF5oSUx2TykfSEl3RBk2i
	613ihD2JXvf3CKSpbYBC0enFa7X+d9YdmfGmfnWHKsKrpVhCVKMhLTk3R89MZaAkq26XAr1ik/G
	vf7j47LZh4kujSvQI2JHccweA8f4Q6/H8BK7ABAH+biG5NKEkWN9fcAVGFULCivYZJw==
X-Received: by 2002:ac8:5399:: with SMTP id x25mr7652185qtp.147.1558554718927;
        Wed, 22 May 2019 12:51:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrkvTmaV6tsdp9YBvfCkmy5O297RuR5pl/mjRAoFMYk8MwFvKu29yutfPWPby9U66e9LdK
X-Received: by 2002:ac8:5399:: with SMTP id x25mr7652143qtp.147.1558554718312;
        Wed, 22 May 2019 12:51:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558554718; cv=none;
        d=google.com; s=arc-20160816;
        b=QeH3EtYcu0obfyx3Pt+6FdRm2pD3XFC4vuFUq1VbJDLZqSuXCO/hSodE3cXTB7OmWY
         7zmDY3J9dcVjakZbLNjCp4BV8CycXTr+U5OYOqE96GklYzbdI6oS9l2k5pxGFPRNIKXp
         4i2yF+2wIn78N8E8BpBUM8D8FGltu3ZeNyqZXm/LhS6jOt502VTdeG1r3234B5RzxhAK
         ePRPuyFEbTpc/EW71wNrn+p7+TjfJXDrTXx6Cr2Cu/uvOCZGl4PfErwZCHZZ96/TEGA8
         IE43uvnEfI8rSya+KQ17uUQfDAWkBAg8wfeHOnoFTxxnZTRgp6Na5352lX/d109Ogn3/
         eptA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=/lPG7gYiwa006Pu2zvxjB339XzWnVN5/iKdeTEMqmek=;
        b=HV+A5GQr9iRChAYpLMfQdl9P16i4oAbv2JtdnYIwNSvhKk1UNU0bYIFuwwFKdC3m/O
         1qtNMqQ3ZmwaS91KnH8pia6MGn0MR6sxbrfcUZPm1AKgo+3OvNC9mti0U0s9q/sn6S3M
         fMnbOEe10qjn+A+MzJ6ZfkVIzaa/UifJQxU3i5ov3fUrm2oeFs/7pNfZOPVfKohWkOGT
         dE5LQPXx5ZuutODACBZiPS3cMYgX0rfCQNnmiaiUwobOjAhdJDQ0Utfn6pzwE+i3LCPM
         ZMA6nlPQikB2nAO/Ip3XTS95E42F9Z0wRFLfDA2fVNij8pfgf7fB2MXTBnvlDbnkJLUb
         8bkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="r9//5brU";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.83 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40083.outbound.protection.outlook.com. [40.107.4.83])
        by mx.google.com with ESMTPS id 57si7826189qtx.185.2019.05.22.12.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 22 May 2019 12:51:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.4.83 as permitted sender) client-ip=40.107.4.83;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="r9//5brU";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.83 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/lPG7gYiwa006Pu2zvxjB339XzWnVN5/iKdeTEMqmek=;
 b=r9//5brUY2Vf4mGR9qoHQv59GIOMfJOri2+gI/6TExy/d1Rkrb6hHCjl+UG7L7zwr9uSDXgUeUsghs36FujE4JC03Z3bl065aV6+ineVBYfkib3avmufd3fjb9pv49yUFCORwursGwVBBjvGH3pd5ZKziJn0SYtgsLnJyhSI0s0=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5920.eurprd05.prod.outlook.com (20.178.126.29) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.17; Wed, 22 May 2019 19:51:55 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1922.013; Wed, 22 May 2019
 19:51:55 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH] hmm: Suppress compilation warnings when CONFIG_HUGETLB_PAGE
 is not set
Thread-Topic: [PATCH] hmm: Suppress compilation warnings when
 CONFIG_HUGETLB_PAGE is not set
Thread-Index: AQHVENfOFtz/QULIxkuTKkQu4Skyeg==
Date: Wed, 22 May 2019 19:51:55 +0000
Message-ID: <20190522195151.GA23955@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR07CA0022.namprd07.prod.outlook.com
 (2603:10b6:208:1a0::32) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.49.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b00e4b30-5779-4b8e-ea31-08d6deeef10d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5920;
x-ms-traffictypediagnostic: VI1PR05MB5920:
x-microsoft-antispam-prvs:
 <VI1PR05MB592078524B741C78325436D5CF000@VI1PR05MB5920.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 0045236D47
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(39860400002)(346002)(376002)(396003)(189003)(199004)(81156014)(66556008)(81166006)(386003)(66476007)(99286004)(186003)(6436002)(2501003)(8676002)(6506007)(68736007)(1076003)(66446008)(64756008)(66066001)(7736002)(2906002)(305945005)(6116002)(53936002)(26005)(6486002)(33656002)(3846002)(110136005)(86362001)(478600001)(256004)(316002)(102836004)(476003)(5660300002)(8936002)(486006)(73956011)(71200400001)(71190400001)(25786009)(66946007)(6512007)(9686003)(14454004)(36756003)(52116002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5920;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Ztfamnp4dJzt3aLpWMdVRtKEPxxXIcNPuQ2hCqfhkzgLuu3aBhPoOZjqi387L9DJRweIEtvwyzl19U/XR81Vw72EfUoMB72Q3CoiwvM2F1g0JXK5cv9YP2CSd56CoDTpjenktwG10TPfGDFQiSYbwyTZEhKZTQtQabk7qVhhKHCienxb15TBfNyzDmRcjq79fDoYTan0uj99FXAsHKYd2SOeYCGy49KSGpzKugnOaUzXrKkhB16DEpJ8U/+p5pBB+rH5njfj6nwSt12tThatgWtWdV8j/BMLF62UPBJnHCPfIM9uyfwcGM8SKiTfE/BjJ+j/X10k88N5TpldCYT6QIxbBMAdfoWMRJYXAlzfWfHornWQSva/KdP9oPTgt3aD/6/pTIuemy+d3T1GtmNL3XXDCaTjzFS8G2I1Mfowb8o=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6969CB730B58C14BBAF8758C33C65E29@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b00e4b30-5779-4b8e-ea31-08d6deeef10d
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 May 2019 19:51:55.0485
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5920
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

gcc reports that several variables are defined but not used.

For the first hunk CONFIG_HUGETLB_PAGE the entire if block is already
protected by pud_huge() which is forced to 0. None of the stuff under
the ifdef causes compilation problems as it is already stubbed out in
the header files.

For the second hunk the dummy huge_page_shift macro doesn't touch the
argument, so just inline the argument.

Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
---
 mm/hmm.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index 0db8491090b888..816c2356f2449f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -797,7 +797,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 			return hmm_vma_walk_hole_(addr, end, fault,
 						write_fault, walk);
=20
-#ifdef CONFIG_HUGETLB_PAGE
 		pfn =3D pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
 		for (i =3D 0; i < npages; ++i, ++pfn) {
 			hmm_vma_walk->pgmap =3D get_dev_pagemap(pfn,
@@ -813,9 +812,6 @@ static int hmm_vma_walk_pud(pud_t *pudp,
 		}
 		hmm_vma_walk->last =3D end;
 		return 0;
-#else
-		return -EINVAL;
-#endif
 	}
=20
 	split_huge_pud(walk->vma, pudp, addr);
@@ -1024,9 +1020,8 @@ long hmm_range_snapshot(struct hmm_range *range)
 			return -EFAULT;
=20
 		if (is_vm_hugetlb_page(vma)) {
-			struct hstate *h =3D hstate_vma(vma);
-
-			if (huge_page_shift(h) !=3D range->page_shift &&
+			if (huge_page_shift(hstate_vma(vma)) !=3D
+				    range->page_shift &&
 			    range->page_shift !=3D PAGE_SHIFT)
 				return -EINVAL;
 		} else {
--=20
2.21.0

