Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78064C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:51:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23A55208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:51:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="owwp0k7A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23A55208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2DBC6B0006; Fri,  7 Jun 2019 14:51:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADEAB6B000A; Fri,  7 Jun 2019 14:51:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A7B86B000C; Fri,  7 Jun 2019 14:51:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDFB6B0006
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:51:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s5so4435204eda.10
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:51:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=MRw/IJJcG2eME8/d+ka6VpE5+lGTha4ZmhExxxxr+Oc=;
        b=SB6KThBBX7GZEvLn0WPIN6C8HWAmwT1NvCP50h3E+hkY4dbUYtxu6iG/DT59V4VL1T
         TwqQA8hUb/BTQhCmv0fl+HKfle50bj6wbQ6Scz6TJE6Buvj5B53Y92iReuNUQic0WuUz
         OUWGsLQYhaHSyPvdUYKCCJ6bLYrIHXKxcYV1pAaDnZE4ymRSlbeEVTvJnDfFAS7lurM0
         L53ILcckj1C8MVO4benNGUDrLO8127yJUqhqqp9PBiFidJBy9GdAU4ewpWG/vHvYAEze
         h2JwdxhmtQafH+9RUR6g2ns66YwHw6/pj8ZTMK0jWt23e1i2v/S6PfxbWZd5XcjXnIOt
         CwaA==
X-Gm-Message-State: APjAAAUboifzGbyLwmZaw1WINHdoaloO5xkfDl7L0i+bCtqrowNP6I/V
	3ZTxOnSDso6Sq09bIsGiOX8kz9g+WD4oM+Np4Vb7Bm1Rp78LCH+8gwjG8QJ9whr7E6nXSbbGPlz
	Cws8ukjF16DLi74VfqIN1lQetrt/qDKTUSGzbrUotA7k6yg07iRO/SiRRH642szaQRA==
X-Received: by 2002:a50:92a5:: with SMTP id k34mr32270866eda.90.1559933481877;
        Fri, 07 Jun 2019 11:51:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwgWTEcQeddx54hR+Keavv9PuVTeYYbJNi0rmr1/5y9qe441GSMSgbnSkyOgV+g7hr7dRj
X-Received: by 2002:a50:92a5:: with SMTP id k34mr32270822eda.90.1559933481292;
        Fri, 07 Jun 2019 11:51:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559933481; cv=none;
        d=google.com; s=arc-20160816;
        b=ATfz9wpomzVlkATub/RHX49RdbxmLmICgTHxslfVCzuhS4X5BJpi61tIFkRh7JdJzl
         cdrjH+f0ulocKdCagB4JlgRXFKsq4qpcFPPIosDQGyBHSn/UaVUjGN5V7dCp5ePjIfTd
         Kri9/6ZP7lcooZzEq9KaRcU7E2FMLK8/33FuQAyddoejE+3ykEdUrosQncLqfaAUbQSD
         /9/H9NOWG7iAtl2mRGQvNFyyEFAU8hKD2kZvR3faE29FjehI2Do4R62D7ub3v34pnswz
         PUksDpBJPJHVp0X+WN//5MjvdxYS6ZV9mquYrdrjj2Bkvgxegdazgv8JX+3H2H8+nMN1
         RJxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=MRw/IJJcG2eME8/d+ka6VpE5+lGTha4ZmhExxxxr+Oc=;
        b=kxWbV36AWSWZ/9DZ3qpAtTmtYijLDgbfy+huJw4LohcaJ3RqzR0MfuZflt7t6UzJfV
         58oBxisxOkaHEmbh7zaniln9aryfKyW7spF/HBOuM5kXZIJ8Rryo52hqepY2zu8/RgWC
         ViKDfJ42iU9mMPSBcZHpbQoiyLQJ3P86ySt1bVil8maVT9vT8wB2IEJxWKskQlFw8WV8
         FmviL3RsAhD1WSMakOII1Rxk2uDQXQbU6UUN0ZQDIoIVVFgfEUfVaucM3ycdnczjXx27
         8AV5ih01gn/EQAI3glAGG71u5TMH7knFE5vPAdoxzH2CErAhpthpFLu/gw4BVSphLV46
         4fwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=owwp0k7A;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.60 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30060.outbound.protection.outlook.com. [40.107.3.60])
        by mx.google.com with ESMTPS id x18si1630442ejo.390.2019.06.07.11.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.60 as permitted sender) client-ip=40.107.3.60;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=owwp0k7A;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.60 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=MRw/IJJcG2eME8/d+ka6VpE5+lGTha4ZmhExxxxr+Oc=;
 b=owwp0k7AsULPqOBGpTrCpr/hPuxURHvaHf8Yx9ICyohivwEOklO9ywX+Qh4bcUG08fJeqRxjh8L1tV0qIVdBQhjkvAl1ndf6DttEAkBjyj037lvf/+ycsIFIK2MESxOA/2lSz6ql5BZmSsdeq70zLUmjYULHN1gYwWthB91OQi8=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5869.eurprd05.prod.outlook.com (20.178.125.142) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.14; Fri, 7 Jun 2019 18:51:18 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1965.011; Fri, 7 Jun 2019
 18:51:18 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH v2 hmm 03/11] mm/hmm: Hold a mmgrab from hmm to mm
Thread-Topic: [PATCH v2 hmm 03/11] mm/hmm: Hold a mmgrab from hmm to mm
Thread-Index: AQHVHJfsjve3VpvfK0iKvy9k76PyJKaQiAIAgAACw4A=
Date: Fri, 7 Jun 2019 18:51:18 +0000
Message-ID: <20190607185113.GF14771@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-4-jgg@ziepe.ca>
 <605172dc-5c66-123f-61a3-8e6880678aef@nvidia.com>
In-Reply-To: <605172dc-5c66-123f-61a3-8e6880678aef@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR13CA0020.namprd13.prod.outlook.com
 (2603:10b6:208:160::33) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c00a4373-03ca-4166-2866-08d6eb791ffd
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:VI1PR05MB5869;
x-ms-traffictypediagnostic: VI1PR05MB5869:
x-microsoft-antispam-prvs:
 <VI1PR05MB58695D751D5C3702EDDA94DECF100@VI1PR05MB5869.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2089;
x-forefront-prvs: 0061C35778
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(346002)(396003)(366004)(39860400002)(136003)(189003)(199004)(3846002)(558084003)(86362001)(316002)(52116002)(6246003)(11346002)(8676002)(8936002)(66556008)(71200400001)(81166006)(6506007)(305945005)(54906003)(6116002)(229853002)(71190400001)(6486002)(66066001)(64756008)(66446008)(7736002)(66946007)(102836004)(99286004)(6916009)(478600001)(73956011)(6512007)(1076003)(53936002)(14454004)(6436002)(66476007)(256004)(25786009)(76176011)(33656002)(81156014)(68736007)(5660300002)(446003)(486006)(2616005)(2906002)(53546011)(186003)(4326008)(36756003)(26005)(386003)(476003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5869;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 n+stqAix+Tn0aLVPjWDW2vTKorm3d9SSzs9OhKDw4dqDsSeXwX5pqh7XhCG+hEeu7uLmRAQQdgUkJx5jj6fJHFkqBhzOi7ruFWDWqVsdYduWB6PbvrD2HcrvA+iM+FRcffuJuScRsxqKBUtTNrpTzTVcxd7hWvi1f6xtWJ+HAur5Bv0lds+VdQ6ykex7wCpddULcIHAhNQJW9ToR9TH18kHVWRe8Xcz+BWN6B5zt3De66vZGAP8QOgu+R0QaoIiRDy5YvJIQRfnv5M/rILFVkMJWncMZauZIxEOoLwDoXEJnQ+4bwWvY69fOyC8DjOaZ/bLkN6zkhbbDgY253SI2RvlUJRTKGHRseCfmhJOpamCSZWCRxLf0ieqKU7KgzPOwoXUEGou7u8tJaJF6IEDkLOpTDIt9cuRrWqcfKrnX1Dg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <0ED1D20CB91BB94C8ED721D38322F396@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c00a4373-03ca-4166-2866-08d6eb791ffd
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Jun 2019 18:51:18.4066
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5869
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 11:41:20AM -0700, Ralph Campbell wrote:
>=20
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> >=20
> > So long a a struct hmm pointer exists, so should the struct mm it is
>=20
> s/a a/as a/

Got it, thanks

Jason

