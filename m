Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9A58C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:47:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 591332184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:47:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="MLL8FcU6";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="jNRoGMGB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 591332184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC2B76B0003; Thu,  8 Aug 2019 17:47:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4C646B0006; Thu,  8 Aug 2019 17:47:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9F326B0007; Thu,  8 Aug 2019 17:47:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3DF16B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 17:47:17 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id s17so32109683ybg.15
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 14:47:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=r//Ez0O4e6PSLjb+PRxheDT1eskdPOETSQuXhnvPm4s=;
        b=iMskb6Cw46cF0X/6/ynhf54ZHrCUhUWetqA4QW6Colug6hOasaFCftFDthGeEivs5s
         7RlvOeoIEZfiqAauokAuiPJOos7aONuJWsH6d/Z9Q0+3veZ8K8sJrirrBOXnGRiqITEw
         bg8UFZ59Cib3YmUtfXVVy9ELuLHpbwfW5utTrkBhPmoTqZCCtsJeitN7xcd+8eyOiAI2
         KB6Y0HUtyABr3MRxRrs9fnLs0s9FzCYOAWoHRuB90NEfYhyNdsoOnCHGOvqsajlCyz8m
         uKVi6vwNab7PIUHV0pDID69YZqcudpSktZ7EEjFo8zKn/E7+LVwfoq/UfljBA57J1k0c
         o7iQ==
X-Gm-Message-State: APjAAAU8CwkYsM9WulH/RrSvMWKwYgsOKVOCijBnNw3cWe7ykZiVqbgu
	sqfBcYRwGmuuZoGL/BEiffJ6yT+XPPuQeG4nUgZ244sBL0PXUrdPE7UXoqak39PRr/qO38g+OWS
	MAg9f+xCK2clSJuMiRHIDdqMz/k1eZDR3LES/OG6mbOlCPRV08FQWUfsCj/JZjDZaEQ==
X-Received: by 2002:a81:3d82:: with SMTP id k124mr8481304ywa.193.1565300837322;
        Thu, 08 Aug 2019 14:47:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp//+6uRnXfZqtP/uyMN7pEi08+Lwjz8jNnYwa5ogTiob9W86Mkj6NkOVW7ptky/m3Vc7m
X-Received: by 2002:a81:3d82:: with SMTP id k124mr8481276ywa.193.1565300836700;
        Thu, 08 Aug 2019 14:47:16 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565300836; cv=pass;
        d=google.com; s=arc-20160816;
        b=J4tBxJpW7s6DvHbCk9Gqa41lzdx1SdpgXHPAqLg+RAzG/GVhSHAhpmITaP0IstcMQb
         B6PhekpxlzlkfZ9EP8qYIxH4gqn/GGHZQgXam1fiVY4BpBnlKueEHYr9ORnJZOB8oXh5
         c911jbaP98lEqXpOf1OlQ4eG6YdDVIdZ3RoO9jVISB+1Hmll9jME6n32iwiG56Qu3FIx
         /XejAyQ+KZ+ucdkQucEwJNPvhhxiAXohWV8f67ffot9SJTWoxo3v8auKbwdXh17Vvi3Y
         svzVw7Dp1HhjsEwoGlwwku4fJbFKfMPhmG35prunxNXqnfwQ1gdLSxzHWyQMZWqupt5R
         Cdsg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=r//Ez0O4e6PSLjb+PRxheDT1eskdPOETSQuXhnvPm4s=;
        b=dhNt3/qKswwDYxcW3daVad8K57pTCqTsYvvjh5t0UHynHIL+lCY7dBh2bKWVNO2DYw
         CT68o0GaChf/n29IVPgtlVu/TIO1Q6svYU9G/xz7Me9rAknj/jdasKLVWD2r7ZIZ0b6/
         ZSxtF+GxGDjU/6Nf5EMNZ1ASb1x8UOrvf7urfg8X8g8mbM9fzezh2oZLw7FmBfUHSJqw
         3zm3m4zVAlMgjhybOWe85kwEZukw37OEcwXmKy9K8nTWPSzLpMrmXDndrnwR1bKBGGto
         ZLuTtzye7sh3d9nZ+Mu0xOoVslUf2wDerdnxCJisqEC6qWA0XZp8PqhkJNiopRXS4FAH
         6FHw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=MLL8FcU6;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=jNRoGMGB;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3123bb15f2=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3123bb15f2=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w123si25743080ywe.3.2019.08.08.14.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 14:47:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3123bb15f2=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=MLL8FcU6;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=jNRoGMGB;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3123bb15f2=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3123bb15f2=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x78LhPqj002316;
	Thu, 8 Aug 2019 14:47:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=r//Ez0O4e6PSLjb+PRxheDT1eskdPOETSQuXhnvPm4s=;
 b=MLL8FcU68kBSh7VzrG+GL0fMvxGZaMBAQcs6q9znvgkoaXsqUVJLdI+vdPUvARdqS1r7
 VXdLnHSiMFEhgjMEOcm7eijuMkbrvOat4G0rzAdG33/Wevyp5uEeedZlrO+36YvpFF0P
 BlkpgHXSV8Gs7ZQkdFF10giV4oJCrClQB/A= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u8taqrd5v-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 08 Aug 2019 14:47:13 -0700
Received: from ash-exopmbx101.TheFacebook.com (2620:10d:c0a8:82::b) by
 ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 8 Aug 2019 14:47:13 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exopmbx101.TheFacebook.com (2620:10d:c0a8:82::b) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 8 Aug 2019 14:47:12 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 8 Aug 2019 14:47:12 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=lSCT1hxdhUQ+QtDL31Brr3F9v+wNBwKzFM1tTeG9jNxAjju4x3VlYSGnYxpB3bOdFKvMN2cj0P/U+bIIMETPQihzAt89CAQ916M9SWOWeyqJubzsnwYYeHC6wdKu7Gf8Cqgc5dwBCdo+uT6iy83+vaWmw3PQzq3e68HZGwAE7V+jBX3IUGJBqVsdXpiBSDOORRygkIvItsy1+ZWn3+R3FMED75aO9uyUHHCguyQkBas8+md3Fh8L4IjtN2WED23KRFYm9Os4YjBLc0GrGiKvbnh/DiHHJkB2ewr0a8xh9TLFHPuP8NSscD+sgI7CeAAyzQNxUdhwbUGBvDolE/iqCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=r//Ez0O4e6PSLjb+PRxheDT1eskdPOETSQuXhnvPm4s=;
 b=NsmlGGHxWYw4fKKzrGJ1K5g2hP8U/HTgpxtb52Zv2gSNTI5XXGBEa9p2e6IHER6FjJZEDfMJOVaqlHoc4dr0ngipSJdTISENs0brqf6CY5uoo4Vb6HEdg1AwaA9CB+KkPG/19wVfpYArRypUuSE4pRsd1LdY49ZTLFeqM4TH+cYFqV6cklEd52GFWGT2zIX0F+Zt7/C6mfIZigkF2pJoC2A+RvPRVKMUZAmGuiKfvPkrW8blrMjNYGoQD9jrRqrUodMmGPFNIZpLd5f8oEXOhPad3vtjeZGlA8l+4lfbAhwMQMgsf7VS8ZiaZpIEpFmVwFO65G5s3lH06uyHEYm25A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=r//Ez0O4e6PSLjb+PRxheDT1eskdPOETSQuXhnvPm4s=;
 b=jNRoGMGB6OkWDl7CesGs2vXSQ6pdSum8jFiXuuyKIXS12jZhyd61CgQMM13QY61UswhK2ap5d0HmFsitGZYeM9ptxDWzjiPRjOeMrH+P85fE5+jmgZNmsmU+fyQW+sAlJIyjAtOSsuUKJ9uw02zQEe+VyTHEV+eljt+qH4L8qEI=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB3252.namprd15.prod.outlook.com (20.179.76.142) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.15; Thu, 8 Aug 2019 21:47:11 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::ccdb:9b8f:f5b2:6e9]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::ccdb:9b8f:f5b2:6e9%4]) with mapi id 15.20.2157.015; Thu, 8 Aug 2019
 21:47:11 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko
	<mhocko@kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>
Subject: Re: [PATCH] mm: memcontrol: flush slab vmstats on kmem offlining
Thread-Topic: [PATCH] mm: memcontrol: flush slab vmstats on kmem offlining
Thread-Index: AQHVTijsZ6iYL9AK2kWVN16VmeCCm6bxwj4AgAAHFAA=
Date: Thu, 8 Aug 2019 21:47:11 +0000
Message-ID: <20190808214706.GA24864@tower.dhcp.thefacebook.com>
References: <20190808203604.3413318-1-guro@fb.com>
 <20190808142146.a328cd673c66d5fdbca26f79@linux-foundation.org>
In-Reply-To: <20190808142146.a328cd673c66d5fdbca26f79@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR14CA0032.namprd14.prod.outlook.com
 (2603:10b6:300:12b::18) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:2f3d]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2d4594ac-bab5-4b88-a41f-08d71c49f78c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN8PR15MB3252;
x-ms-traffictypediagnostic: BN8PR15MB3252:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <BN8PR15MB325201A006889E85C9F41984BED70@BN8PR15MB3252.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 012349AD1C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39860400002)(346002)(136003)(366004)(376002)(199004)(189003)(52314003)(8936002)(14454004)(66556008)(71190400001)(66946007)(66476007)(66446008)(64756008)(81156014)(81166006)(1076003)(256004)(71200400001)(2906002)(86362001)(186003)(6486002)(102836004)(6436002)(11346002)(478600001)(52116002)(9686003)(6512007)(7736002)(53936002)(6916009)(316002)(476003)(76176011)(229853002)(6506007)(8676002)(5660300002)(54906003)(305945005)(6116002)(446003)(25786009)(4326008)(99286004)(486006)(6246003)(33656002)(386003)(46003);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB3252;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: B2vUTfuhJTsUMu/UT+rJzlApXWZkGaTZs1pn54tZ9PPWdkhKlFFI1AwQS1hQnCeVwfMFeU5HDV8/cMMhSR89QuLwliWGeyKsU2Htsi+9pzinHjoWjmucGK1aZDaBNIfH3doRQno+oqz/uHlDjZxAoSOCf/7MgFycZCiEE4H995ufizq3LD4UfoqvrgEBR2s46Bhz06j6h2Mp9JGPu4emZ6cGOHkBx/TjclyWG1APyVVWz7MNMwH9ZwqHNsLULGUJvNx1vD6m2SphfgS6ACSuhmQIV/yMqYv+rU/GLSbURKBaaYu1BOTKf5JbRWB10n6s+nY0fic0Iaq1+uyS8eshYudd1DYZ2U5OXP3Cqto9G+Mlm1lArg+cllg6ZVxLBY/snQTDQQAUhm0ke1w8TdnRsX2sPQS7qMLe/3VmdEMIt30=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <BB2EBE5F18A8524D983CACB14734C0D0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 2d4594ac-bab5-4b88-a41f-08d71c49f78c
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Aug 2019 21:47:11.1162
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 2Ig3LI7UxrvDZcZGSvwLjSTlnXxcI9ZMKMILBsoeuP/XHOmRtEExZ3gww8axtqQx
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB3252
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-08_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908080189
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 02:21:46PM -0700, Andrew Morton wrote:
> On Thu, 8 Aug 2019 13:36:04 -0700 Roman Gushchin <guro@fb.com> wrote:
>=20
> > I've noticed that the "slab" value in memory.stat is sometimes 0,
> > even if some children memory cgroups have a non-zero "slab" value.
> > The following investigation showed that this is the result
> > of the kmem_cache reparenting in combination with the per-cpu
> > batching of slab vmstats.
> >=20
> > At the offlining some vmstat value may leave in the percpu cache,
> > not being propagated upwards by the cgroup hierarchy. It means
> > that stats on ancestor levels are lower than actual. Later when
> > slab pages are released, the precise number of pages is substracted
> > on the parent level, making the value negative. We don't show negative
> > values, 0 is printed instead.
> >=20
> > To fix this issue, let's flush percpu slab memcg and lruvec stats
> > on memcg offlining. This guarantees that numbers on all ancestor
> > levels are accurate and match the actual number of outstanding
> > slab pages.
> >=20
>=20
> Looks expensive.  How frequently can these functions be called?

Once per memcg lifetime.

>=20
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3412,6 +3412,50 @@ static int memcg_online_kmem(struct mem_cgroup *=
memcg)
> >  	return 0;
> >  }
> > =20
> > +static void memcg_flush_slab_node_stats(struct mem_cgroup *memcg, int =
node)
> > +{
> > +	struct mem_cgroup_per_node *pn =3D memcg->nodeinfo[node];
> > +	struct mem_cgroup_per_node *pi;
> > +	unsigned long recl =3D 0, unrecl =3D 0;
> > +	int cpu;
> > +
> > +	for_each_possible_cpu(cpu) {
> > +		recl +=3D raw_cpu_read(
> > +			pn->lruvec_stat_cpu->count[NR_SLAB_RECLAIMABLE]);
> > +		unrecl +=3D raw_cpu_read(
> > +			pn->lruvec_stat_cpu->count[NR_SLAB_UNRECLAIMABLE]);
> > +	}
> > +
> > +	for (pi =3D pn; pi; pi =3D parent_nodeinfo(pi, node)) {
> > +		atomic_long_add(recl,
> > +				&pi->lruvec_stat[NR_SLAB_RECLAIMABLE]);
> > +		atomic_long_add(unrecl,
> > +				&pi->lruvec_stat[NR_SLAB_UNRECLAIMABLE]);
> > +	}
> > +}
> > +
> > +static void memcg_flush_slab_vmstats(struct mem_cgroup *memcg)
> > +{
> > +	struct mem_cgroup *mi;
> > +	unsigned long recl =3D 0, unrecl =3D 0;
> > +	int node, cpu;
> > +
> > +	for_each_possible_cpu(cpu) {
> > +		recl +=3D raw_cpu_read(
> > +			memcg->vmstats_percpu->stat[NR_SLAB_RECLAIMABLE]);
> > +		unrecl +=3D raw_cpu_read(
> > +			memcg->vmstats_percpu->stat[NR_SLAB_UNRECLAIMABLE]);
> > +	}
> > +
> > +	for (mi =3D memcg; mi; mi =3D parent_mem_cgroup(mi)) {
> > +		atomic_long_add(recl, &mi->vmstats[NR_SLAB_RECLAIMABLE]);
> > +		atomic_long_add(unrecl, &mi->vmstats[NR_SLAB_UNRECLAIMABLE]);
> > +	}
> > +
> > +	for_each_node(node)
> > +		memcg_flush_slab_node_stats(memcg, node);
>=20
> This loops across all possible CPUs once for each possible node.  Ouch.
>=20
> Implementing hotplug handlers in here (which is surprisingly simple)
> brings this down to num_online_nodes * num_online_cpus which is, I
> think, potentially vastly better.
>

Hm, maybe I'm biased because we don't play much with offlining, and
don't have many NUMA nodes. What's the real world scenario? Disabling
hyperthreading?

Idk, given that it happens once per memcg lifetime, and memcg destruction
isn't cheap anyway, I'm not sure it worth it. But if you are, I'm happy
to add hotplug handlers.

I also thought about merging per-memcg stats and per-memcg-per-node stats
(reading part can aggregate over 2? 4? numa nodes each time). That will
make everything overall cheaper. But it's a separate topic.

Thanks!

