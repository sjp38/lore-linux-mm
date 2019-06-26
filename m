Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83A7FC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 15:45:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28D842177B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 15:45:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Z5RQcz7A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28D842177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEB5B8E0018; Wed, 26 Jun 2019 11:45:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA50B8E0002; Wed, 26 Jun 2019 11:45:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 963B98E0018; Wed, 26 Jun 2019 11:45:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 447468E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:45:50 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m23so3777840edr.7
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:45:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=idasF+fNV/2NSNpe05cKLARhKYMfEgGNwaq6PUXzCoA=;
        b=bPHycxr8NyhupB734pWidF2YPcLiQAZmpTwubqd7YbytPvy0lChX8P4RUedoot/AyV
         EU9mzwAt6uxj7ICbRpuaB+aD5w3OVoimLBEPuqVxaPFIr7agv6Q7UOP/0FhteEiM/g0d
         CGRa+Wh+tQjXifxruY1/binxvmV+0lnHkJicJi1BeDl4O+1WMj6+Mu0QGJQ6yr8G0wYb
         G29D02e0d+++posFgrucGFy07X95qYQmb9E4OhIPXMvrfL1o2L978RHRtv2P+eaLf7aY
         2YoWGzgG5bA4x7UCeMSls+l53Bhga5/fwFYV9+TU42EC8bCDai2siEmhyARcm1mTCQ/K
         wLOw==
X-Gm-Message-State: APjAAAWif9vLSDdyou6oZXMwtAAKGWVm1MQlDSXhHvjWUIbS9dibqnIp
	kv6/54Vb8E0ouas+X+SzEti0k8yucZsyALYbgwr77Py49E0U1VA10BN4J4Zi5XlfoDyjlf8IcGY
	3De3g9vrqywe6b9ssdtLG5b5h1mnBnhmXfeF1rvD9B1psQG+wtP69CIvim9Pyb29YMw==
X-Received: by 2002:a50:ae8f:: with SMTP id e15mr6174516edd.74.1561563949784;
        Wed, 26 Jun 2019 08:45:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvMQLYT/aMgbh8hfSrvGnUD0/x/tzNGDTxyMyRjvMqDRRfBSB4+86Y6ttIwjtIGNLOyq38
X-Received: by 2002:a50:ae8f:: with SMTP id e15mr6174449edd.74.1561563949118;
        Wed, 26 Jun 2019 08:45:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561563949; cv=none;
        d=google.com; s=arc-20160816;
        b=LPuvF724JXP722IuhPKqrP4NzBxINQLwjDPS/6Fy8lGbmRO80l63qPvTyo3tCjK3MV
         n8qRZzg2hajI5xI3QjMwVAOv7vinA/WyWzVQXQVhHmyIyoPbGbbPCNU8/mnkJNUz/Y8+
         fIiVgrRLBwq+5zYpteDlPQyPoiDjILJWjmJiTEbpWEhMTXEuKIFdyLHP0QjCSCZcOAWV
         GE6mw5hioCw1bWJJLB1iVt487MpjSkZwJz4Hj+22vIV9y0uPpOUt73LIJKunNA91EFsS
         U2haUqaJHlGgCK2GPzMJgFsAkX6WL32c0pj8xSwZxSxYyKG0E/qt/+nLKhSQ3IcNpr8s
         nPSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=idasF+fNV/2NSNpe05cKLARhKYMfEgGNwaq6PUXzCoA=;
        b=q0T96QxmSKIAxhE+KsfwbZ/xj5RN+gPap4Y5aQRbl9fGWYmKYLoxc1bJWwAlJ43g5j
         z46N9vj0022OsprAwfrxGmNAIRgPCg+bY8RHnIBwvRb8ZQA6PKdltuCe47V05+VZ70aD
         ilhAZHcKODfOnVhLPVgksFVIdqrdM+mf4wd/6OednH/TBO7r8DT/7jHn3vHrOfps/jM7
         qBMoL3DvJONbCoigB5XQ/4Y4Ly2nfwLnT4ltUqGJVtn4WNR39XoWBetajvUNKFAQ9kqY
         eGgjYDPOIXgOU7DWBXrqA4qXC7k5d43iKdkNvXOtFZnhhoNIZ42bFYIpLDhomLikhk5J
         Xg5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=Z5RQcz7A;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.49 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60049.outbound.protection.outlook.com. [40.107.6.49])
        by mx.google.com with ESMTPS id s11si2697710eji.295.2019.06.26.08.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 26 Jun 2019 08:45:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.6.49 as permitted sender) client-ip=40.107.6.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=Z5RQcz7A;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.49 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=idasF+fNV/2NSNpe05cKLARhKYMfEgGNwaq6PUXzCoA=;
 b=Z5RQcz7A+HJv5tjI2l1kP+sDLCmzjxHl1vyMQxO3dMx7PM00d4r92FStrgemvkhnlGzWwUUg66C9HkrY0PLYqHthEKzjAbm0JVbqTuOs/kr9hCLgpyROYQepZIIVyisHcWHuDE30n0RloKCKvOfAfxUD4KN7XU33B2bCIsCBpUU=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6575.eurprd05.prod.outlook.com (20.179.25.213) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Wed, 26 Jun 2019 15:45:47 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Wed, 26 Jun 2019
 15:45:47 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>,
	"catalin.marinas@arm.com" <catalin.marinas@arm.com>,
	"anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
Thread-Topic: [PATCH v3 0/4] Devmap cleanups + arm64 support
Thread-Index: AQHVK/HAM2r3dJ5EjUuvQfApLyHQmKat3lEAgAA0MoCAAAH5AA==
Date: Wed, 26 Jun 2019 15:45:47 +0000
Message-ID: <20190626154532.GA3088@mellanox.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <20190626073533.GA24199@infradead.org>
 <20190626123139.GB20635@lakrids.cambridge.arm.com>
 <20190626153829.GA22138@infradead.org>
In-Reply-To: <20190626153829.GA22138@infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR01CA0014.prod.exchangelabs.com (2603:10b6:a02:80::27)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [12.199.206.50]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 395090c3-c108-460c-e2cd-08d6fa4d5b82
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6575;
x-ms-traffictypediagnostic: VI1PR05MB6575:
x-microsoft-antispam-prvs:
 <VI1PR05MB6575250D31F7320E2C693BC8CFE20@VI1PR05MB6575.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7219;
x-forefront-prvs: 00808B16F3
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(396003)(346002)(136003)(366004)(39860400002)(199004)(189003)(81166006)(25786009)(8676002)(53936002)(476003)(6506007)(81156014)(508600001)(6486002)(54906003)(446003)(71200400001)(6512007)(7416002)(71190400001)(6916009)(11346002)(66556008)(2616005)(4326008)(486006)(64756008)(7736002)(6246003)(66446008)(66066001)(305945005)(66946007)(99286004)(73956011)(66476007)(3846002)(386003)(6116002)(52116002)(76176011)(14454004)(26005)(33656002)(86362001)(36756003)(229853002)(6436002)(8936002)(2906002)(256004)(316002)(102836004)(186003)(68736007)(5660300002)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6575;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 PO7x2UUHnxQV/A4UKLcEVnD6eJR4Ysj2OBxUB42vJc3dQ95Tq26noIFSHH/c3BEDXNvLIC1YLhjPJAJ9SCxyljVlaJGaZjtsrQflagLvIEbeIbutLKtVj/Zq8aUNdaazTSYPpTGM+nMh80KonObvrCWd96/MeQFkHr8bnaFbZwmRXpZn5NsH/rdIVMeREHr3lmEJGegA+Ciu33JfCqik0gMneY5Nj+1VrVVx2GQupE6hc1rKZ3pqDm/7ahjGLEtzxi5mbF1+4fBpXXLC9lVWZdy9Itn8ouDfUv3jZ7VVv+p3HOwAJqXXZ0FznKWD3fZdbGVeFuCvk1IoSoeCqBM0FvLQnnM40cu2HTx65ap+6noEGGBw5H4B9EzWUy5rXEloAhiqN42y4ab+cu7x9r7CuoemHie6qNwbPknt9MKruXg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6C512E815C6B3B468056524CEC187B15@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 395090c3-c108-460c-e2cd-08d6fa4d5b82
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Jun 2019 15:45:47.7482
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6575
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 08:38:29AM -0700, Christoph Hellwig wrote:
> On Wed, Jun 26, 2019 at 01:31:40PM +0100, Mark Rutland wrote:
> > On Wed, Jun 26, 2019 at 12:35:33AM -0700, Christoph Hellwig wrote:
> > > Robin, Andrew:
> >=20
> > As a heads-up, Robin is currently on holiday, so this is all down to
> > Andrew's preference.
> >=20
> > > I have a series for the hmm tree, which touches the section size
> > > bits, and remove device public memory support.
> > >=20
> > > It might be best if we include this series in the hmm tree as well
> > > to avoid conflicts.  Is it ok to include the rebase version of at lea=
st
> > > the cleanup part (which looks like it is not required for the actual
> > > arm64 support) in the hmm tree to avoid conflicts?
> >=20
> > Per the cover letter, the arm64 patch has a build dependency on the
> > others, so that might require a stable brnach for the common prefix.
>=20
> I guess we'll just have to live with the merge errors then, as the
> mm tree is a patch series and thus can't easily use a stable base
> tree.  That is unlike Andrew wants to pull in the hmm tree as a prep
> patch for the series.

It looks like the first three patches apply cleanly to hmm.git ..

So what we can do is base this 4 patch series off rc6 and pull the
first 3 into hmm and the full 4 into arm.git. We use this workflow often
with rdma and netdev.

Let me know and I can help orchestate this.

Jason

