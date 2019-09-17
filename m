Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFB85C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 02:09:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5380820665
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 02:09:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="oNI0cilH";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="c4XAjtps"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5380820665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDCD36B0003; Mon, 16 Sep 2019 22:09:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E67106B0005; Mon, 16 Sep 2019 22:09:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE04C6B0006; Mon, 16 Sep 2019 22:09:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0070.hostedemail.com [216.40.44.70])
	by kanga.kvack.org (Postfix) with ESMTP id A73216B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 22:09:18 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4449818DD
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 02:09:18 +0000 (UTC)
X-FDA: 75942780396.09.point94_16f28031e610f
X-HE-Tag: point94_16f28031e610f
X-Filterd-Recvd-Size: 10890
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 02:09:17 +0000 (UTC)
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x8H29BU2006108;
	Mon, 16 Sep 2019 19:09:13 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=VxAHBUJyJ6zMzed4qXSgvmBGYdqOnBVFY6NGZe5Kw0E=;
 b=oNI0cilH3qVjMuQwZX7b7BIsaOV31t8i719HgBep94u3MIOXUWCwCGqPq25KTWlaJHrP
 fCxDagaCJc8+tgMOkgBrsQlmlddO3yl2I4xCsYrNH5uo61SSNym6CJ9xICX/bLpxdl+w
 JPPmZ/FGoQdGUHLDh8TByCPzW8UYL3FS+fk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2v1g1hfa34-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 16 Sep 2019 19:09:13 -0700
Received: from ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) by
 ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 16 Sep 2019 19:09:02 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.100) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 16 Sep 2019 19:09:02 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=b3uJOB+9ErmFxpQGYM/YJJLZTtJlbTqo9gB3lMe6VQiYosGJvmzq9CL5yrGb7VY+LlEZ2wK/yOFsGCpMBfXkISnsZxuPhZ0rwFGRpJVuzPrP8Wu7yjZ5rjv1K4N60rLO+pdox9SfnZv7SZlA4XJTX+5vAE9w0M00qxN4ij8gG2H4neJgJDstgjZLW1JG0MBlmeX6OuG2jlm4DC5PKm0KUbwklv6AdFA5yqZnCiru+nkcOk0oskdXmFaTDf4CK5rHs2jUjjDqE+IXqrnvrbzcx+6L90DW1PVA3HUlCTUPp7PpqNBLa0Gc2hAtIMCuq9HjNbROmpkEqxd4Sl37+9TWlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VxAHBUJyJ6zMzed4qXSgvmBGYdqOnBVFY6NGZe5Kw0E=;
 b=Ubvdku6nyqZiaunTbHtysrRjvl561Sa8c18vTmI9ey/nSo9XIHxU179I/F54RUN5R3TYM00dkUJ4Oq9eGwJE7aR9m+kRcf08lhNg55Gm+yMWLlwZupSVNF0QZM6EXXZnTtHPpThkAXux3wit7kbSBCPhgJRl8t3+lMwSo/MZlGdlSpoz54xLdTfN3qi/3d0i24FSzW7UsbNfeG2Tuz9LJEOjHpvgdmkJQ+VXxSe1NHwum3Y+m1/krSaZncbvMyfF1hKTb64+IlIm0RWvJTjrbz/7HZipBLYoB1qkw5eKeUWyLknqswo5viyR7QEDBBvebacVXHUx5xxhLyVvQKAbGw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VxAHBUJyJ6zMzed4qXSgvmBGYdqOnBVFY6NGZe5Kw0E=;
 b=c4XAjtpsTQv0y9Py7Kys5LHys1ymjE/sZ7gAZyK+Z3lQEvjaWFuQgNXPkV+ngJlEbVxdssS60P7l/ULP3vfJydI1hFJYhkBisfIWaMY2D7htSpdunbFja5ybCASCjZyg1vPCPbc/J5DCYiBGQ6jUeakE0KRBjTXRf7YUa6q8jwU=
Received: from BYASPR01MB0023.namprd15.prod.outlook.com (20.177.126.93) by
 BYAPR15MB2694.namprd15.prod.outlook.com (20.179.156.223) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.13; Tue, 17 Sep 2019 02:08:59 +0000
Received: from BYASPR01MB0023.namprd15.prod.outlook.com
 ([fe80::e448:b543:1171:8961]) by BYASPR01MB0023.namprd15.prod.outlook.com
 ([fe80::e448:b543:1171:8961%5]) with mapi id 15.20.2263.023; Tue, 17 Sep 2019
 02:08:59 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko
	<mhocko@kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Shakeel
 Butt" <shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        "Waiman Long" <longman@redhat.com>
Subject: Re: [PATCH RFC 04/14] mm: vmstat: convert slab vmstat counter to
 bytes
Thread-Topic: [PATCH RFC 04/14] mm: vmstat: convert slab vmstat counter to
 bytes
Thread-Index: AQHVbIuz+7DwKECJ0UKhA5+6DW0FJKcvIJ+A
Date: Tue, 17 Sep 2019 02:08:59 +0000
Message-ID: <20190917020855.GA8073@castle.DHCP.thefacebook.com>
References: <20190905214553.1643060-1-guro@fb.com>
 <20190905214553.1643060-5-guro@fb.com> <20190916123840.GA29985@cmpxchg.org>
In-Reply-To: <20190916123840.GA29985@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR12CA0071.namprd12.prod.outlook.com
 (2603:10b6:300:103::33) To BYASPR01MB0023.namprd15.prod.outlook.com
 (2603:10b6:a03:72::29)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::f4fb]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 67cbb2c5-fcb0-483c-9f2a-08d73b140090
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600167)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB2694;
x-ms-traffictypediagnostic: BYAPR15MB2694:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <BYAPR15MB2694A89BA4E108FD2DB9137FBE8F0@BYAPR15MB2694.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01630974C0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(376002)(396003)(39860400002)(366004)(199004)(189003)(11346002)(64756008)(81156014)(66946007)(486006)(186003)(8676002)(81166006)(66446008)(8936002)(71190400001)(476003)(478600001)(66476007)(66556008)(71200400001)(4326008)(33656002)(46003)(446003)(25786009)(9686003)(6512007)(256004)(86362001)(52116002)(14444005)(6436002)(102836004)(6246003)(76176011)(386003)(6506007)(229853002)(316002)(2906002)(7736002)(305945005)(1076003)(54906003)(5660300002)(6116002)(99286004)(6486002)(14454004)(6916009);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2694;H:BYASPR01MB0023.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: bSk4Bp2j05jemM+fK0516IgmjqdJrnhIrsE1J2pHU4xT/obwmDQn9XBCol1oua1VXYpHE/waIhfOJ3Jshp6vBT5e4eOqJIpXHW4MooNMDuOA4cc7t9Lqj2JLFXtKzgaZYZuzrYgk+Ny8SLlzu0LyiaIMynU5HvxTSJAhXuo8Ss9NhRw/iAZ7mVED290Kk+YJA+SM+o0JaYEVZ3KygNCEjNmeQ83avTgmew9h5kHS9k4JYkCobJ0n0UgnuU9Znmk0nM4iK0wmC6Ll2fIQAwsEpyRhcZySyUrklJeVUrrC5kVrGJroJ20dPQxtYC/smi47XWol1Dza63WstnKlJwwwDDd6OE5cUTZlT0XTHKHm7dmXwERJYn9VFKaye88Btz0dT7vJuOzw8W9hXwmLeJvj5UJ/STT/ixxUjqhOcfTfLgc=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CBC1F9B65198FA4EA4BEAC7F34F76C29@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 67cbb2c5-fcb0-483c-9f2a-08d73b140090
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Sep 2019 02:08:59.3175
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: W45Wc9p32Qv4IY59W/EzcgENBtlDeoFWwCZFLS5FH4o1S31InE4kLdFpt7Za5+uY
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2694
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-16_09:2019-09-11,2019-09-16 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 clxscore=1015
 mlxlogscore=999 adultscore=0 priorityscore=1501 malwarescore=0 spamscore=0
 bulkscore=0 lowpriorityscore=0 suspectscore=0 mlxscore=0 phishscore=0
 impostorscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1908290000 definitions=main-1909170023
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 02:38:40PM +0200, Johannes Weiner wrote:
> On Thu, Sep 05, 2019 at 02:45:48PM -0700, Roman Gushchin wrote:
> > In order to prepare for per-object slab memory accounting,
> > convert NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE vmstat
> > items to bytes.
> >=20
> > To make sure that these vmstats are in bytes, rename them
> > to NR_SLAB_RECLAIMABLE_B and NR_SLAB_UNRECLAIMABLE_B (similar to
> > NR_KERNEL_STACK_KB).
> >=20
> > The size of slab memory shouldn't exceed 4Gb on 32-bit machines,
> > so it will fit into atomic_long_t we use for vmstats.
> >=20
> > Signed-off-by: Roman Gushchin <guro@fb.com>

Hello Johannes!

Thank you for looking into the patchset!

>=20
> Maybe a crazy idea, but instead of mixing bytes and pages, would it be
> difficult to account all vmstat items in bytes internally? And provide
> two general apis, byte and page based, to update and query the counts,
> instead of tying the unit it to individual items?
>=20
> The vmstat_item_in_bytes() conditional shifting is pretty awkward in
> code that has a recent history littered with subtle breakages.
>=20
> The translation helper node_page_state_pages() will yield garbage if
> used with the page-based counters, which is another easy to misuse
> interface.
>=20
> We already have many places that multiply with PAGE_SIZE to get the
> stats in bytes or kb units.
>=20
> And _B/_KB suffixes are kinda clunky.
>=20
> The stats use atomic_long_t, so switching to atomic64_t doesn't make a
> difference on 64-bit and is backward compatible with 32-bit.

I fully agree here, that having different stats in different units
adds a lot of mess to the code. But I always thought that 64-bit
atomics are slow on a 32-bit machine, so it might be a noticeable
performance regression. Don't you think so?

I'm happy to prepare such a patch(set), only I'd prefer to keep it
separately from this one. It can precede or follow the slab controller
rework, either way will work. Slab controller rework is already not so
small, so adding more code (and potential issues) here will only make
the review more complex.

>=20
> The per-cpu batch size you have to raise from s8 either way.

Yeah, tbh I don't know why those are just not unsigned long by default.
Space savings are miserable here, and I don't see any other reasons.
It could be even slightly faster to use a larger type.

I kinda tried to keep the patchset as small as possible (at least for
the RFC version), so tried to avoid any non-necessary changes.
But overall using s8 or s16 here doesn't make much sense to me.

>=20
> It seems to me that would make the code and API a lot simpler and
> easier to use / harder to misuse.

