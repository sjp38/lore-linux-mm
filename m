Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E49AC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:54:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B33122239F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 14:54:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="hv4zF8aV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B33122239F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A8BD8E0003; Tue, 23 Jul 2019 10:54:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 359AB8E0002; Tue, 23 Jul 2019 10:54:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FBAE8E0003; Tue, 23 Jul 2019 10:54:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C201A8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:54:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so28390690edc.17
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 07:54:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=4mMIkWPy7OlbnNwE8X8tiEOFqH0MXBd3HY7q9oa8rY8=;
        b=Z92ZEmCnz51PQfqPFZah81PrU6iBdoTtstdxaboD+SsD2tNeFyJVA20Rwv02hms39u
         VSM0TE91UgoBX1Z/DgB1Cto/7oDGFDu6gRRjnagCo25vSdZrtBT7N/fIKbBC/J4VbUZG
         tgveg6SambGUjzYk+pdk86gTgaX6fd9Qn9cCqxK28Pq0x4/9UdSmmxD/kgJpElk65U8V
         mG2FP4Cs5qYXXTPj321/t+LSFlOGk3c5P8PYlbQfm3JM/f79BjR1j916x0L7xYNiYZ8f
         JB+drw+3mR9KqsEfFHo+OSJGBRpHyV8Z9WKxVxmEpgwg9P0ztoAuJ6bj08/Bf5IdJj3j
         FSuQ==
X-Gm-Message-State: APjAAAVJi7eH1JhQuQ8zXxuPwd/w3DPpHh79DZwrkt5kLTZADLllZuPz
	bMe+ccAP2pt0omk61SLpImLiuribOlMdjJbGa8BU6m0bvtvPRVY8baDtQ1eQ7UsJXgsOI/6dO27
	SRGceqTrBsBPnMw081HvWY8tvNOr7IpfeKzTeNJGMA5fmRtDfwFwd+dOUXD4ad/IqMw==
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr67499504edb.304.1563893688345;
        Tue, 23 Jul 2019 07:54:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6QgwUeL5mtBqOkiPbSon8j3HqdN+GfrVePyzy3RoBaHVbp+s7nsiU1qQaEnV/IW2Nf1bO
X-Received: by 2002:a50:a4ef:: with SMTP id x44mr67499436edb.304.1563893687600;
        Tue, 23 Jul 2019 07:54:47 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563893687; cv=pass;
        d=google.com; s=arc-20160816;
        b=hULxG2D9h7yaL878bM8RjxNW/XwOmqbfyXLTHICGSW10iodUxFDE+o16qtDCmy2lCI
         YaWp2rCfmwGW5gPttN5uEAydIOh0w4OQBUDNVqGuUD+UVinylS9a65XOlvS3zYdnE+ng
         jlqrsBatSGVrZcmHcIZvxJwjVYuDQYweu5BzT4F0GYEGrTng8oe2+2nHrfSQQVg8yy6q
         w/vdvSIXasIzHoMGHLaM9MoRAoOKw8N8UP4k4RcEq9Ivee6qJ40jiHeNOUSOfdxK7kke
         pxlqezhd3KTVk7fyh3G9TYBVtkHqb8s6lTRnVDa3G5bu7BVDyk/GO6LqZ6DmFzw8UOWk
         Umfg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=4mMIkWPy7OlbnNwE8X8tiEOFqH0MXBd3HY7q9oa8rY8=;
        b=OGLdCGEiVFYe809fuf2gSdiPRLkV5tHA8KJ7UkWZ19upWrGDF7Pd+6wFBs6geg6j/6
         EGKK8zodNreNRQ90J/3SWsnr7XMei+DoeoQrENADAMI5vmFHs/aNiG5k6QR0e91uvO4y
         w5UFYJwKjabT/4ICI3hGApENnU70wVrqBhe/cC4n+m5EQ55XHAqrw7v1brBv2n9aAaDo
         IlD6jg+6V5QZi6WvFTeHxa8hwhnax6aKVPafQKJ9uMFcMmyr9ROaACjj/P7fCuASx6AI
         o29fjPX1vakL8EPXaKHTll6uUmzTP8qbKguUmNayvGYlgTNuy09SIuqEmEKh7wMmP16e
         i5Hg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=hv4zF8aV;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.45 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20045.outbound.protection.outlook.com. [40.107.2.45])
        by mx.google.com with ESMTPS id d20si5891336ejk.62.2019.07.23.07.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 07:54:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.45 as permitted sender) client-ip=40.107.2.45;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=hv4zF8aV;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.45 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=WJf+0/uq2SjX1VN6KNu+HWXUznvleLGlyAWWpN5Y2Cv+GA7PeqJkWe+B4iN+po63ZAkUQnLcPQJp40GuRl/XL+57A36Ok6DbOYEsak0jHkhvHa5ACylwE/pwMV7oIojjEIW+/i89xOjIDLRZCkPoOwvk5dUmKwth/tkNVXv5nnZpQN2uz9yaV3lc2knbiXKjaMwUrovzIHOu7DKxAYhRE5yxws/zPZtN9DCRW/W0AQPO2X6XAKRNUmdddrN5cE3esi84EIDcqc61UZKbcJ6TsFP1/1y9ZcuyJtUEdpwt+59mn7zq2zjorK1V5LCL16yxh1ym1CmqXP7ioyIHRfK/wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4mMIkWPy7OlbnNwE8X8tiEOFqH0MXBd3HY7q9oa8rY8=;
 b=XX9FppSk0lpwyOgUgp2lxtJdMH5UuA1HWFCT2OgAOuKZgyPhEDNW4BhxUCguKFAy0d1M6A7FhWilbfgWbpKgDcfvBzy/eShyIf6HIBjmjFsbwy43XmuuC6+qsPEMkpQon90zzgpIufH6fwIOSgaXShZqkfwnVWylPFG+uIq+l+5g373lpbJpPZQWjE/KPkC3MmuNsDxFkl2Xb8vdmtJBpqU3SbRzjiauuHE3P0EyzYtXvX7YiI71hV7bAsxTb6m3XvnU/74UyoY4rhCc0Q4l3nBPsuxwUbi0e7g+t2/DrnGC0zD6+DpBdSdAOelsm4upNW4GyvwGV5k6LS+6zvzy9g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4mMIkWPy7OlbnNwE8X8tiEOFqH0MXBd3HY7q9oa8rY8=;
 b=hv4zF8aV5+O2OvGuMKH+i3y9edejOgSdsLgoBQ/n3o5GHjzSWTwL2LnZgPrmnwg/vFmwhWzztAvFJMRWWuzXvyK2SynNlC8ofn8LEwPBrvHXF3Tlk19NJCPMaxhYpoTZgXtKa2hk8MwiJdIv+yxZO0B7Zwv04VPwR2bAjBkmBzE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3472.eurprd05.prod.outlook.com (10.170.239.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.16; Tue, 23 Jul 2019 14:54:45 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2094.013; Tue, 23 Jul 2019
 14:54:45 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
CC: Christoph Hellwig <hch@lst.de>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Ralph Campbell
	<rcampbell@nvidia.com>, Linux-MM <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Felix Kuehling
	<Felix.Kuehling@amd.com>
Subject: Re: [PATCH 1/6] mm: always return EBUSY for invalid ranges in
 hmm_range_{fault,snapshot}
Thread-Topic: [PATCH 1/6] mm: always return EBUSY for invalid ranges in
 hmm_range_{fault,snapshot}
Thread-Index: AQHVQHIRs6fGZEVop06hMQcrvsZ8NqbWtRqAgAGXHoA=
Date: Tue, 23 Jul 2019 14:54:45 +0000
Message-ID: <20190723145441.GI15331@mellanox.com>
References: <20190722094426.18563-1-hch@lst.de>
 <20190722094426.18563-2-hch@lst.de>
 <CAFqt6zY8zWAmc-VTrZ1KxQPBCdbTxmZy_tq2-OkUi3TVrfp7Og@mail.gmail.com>
In-Reply-To:
 <CAFqt6zY8zWAmc-VTrZ1KxQPBCdbTxmZy_tq2-OkUi3TVrfp7Og@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR15CA0003.namprd15.prod.outlook.com
 (2603:10b6:208:1b4::16) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d966fda0-338e-478c-42a1-08d70f7db38f
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3472;
x-ms-traffictypediagnostic: VI1PR05MB3472:
x-microsoft-antispam-prvs:
 <VI1PR05MB347230E82CADE677CF76D105CFC70@VI1PR05MB3472.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0107098B6C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(396003)(366004)(376002)(136003)(39860400002)(199004)(189003)(3846002)(52116002)(8676002)(86362001)(4326008)(14444005)(6512007)(5660300002)(36756003)(6246003)(64756008)(54906003)(478600001)(66446008)(7416002)(53936002)(66556008)(66476007)(305945005)(7736002)(68736007)(25786009)(256004)(66946007)(6116002)(476003)(486006)(81166006)(33656002)(81156014)(11346002)(1076003)(6486002)(6916009)(2616005)(2906002)(76176011)(8936002)(6436002)(71200400001)(71190400001)(316002)(186003)(6506007)(14454004)(53546011)(386003)(446003)(66066001)(229853002)(99286004)(102836004)(26005)(142933001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3472;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 cJYSJS2lynI+8NSitY0FCPF3DUkNFAV9rRYTDScuv0IEZyNwhUTOooWDYj2xi0xGXE3/oMIvdp7ZHywr0NO2Zklirmi83UxUGZsHZLBriJog+mCFGxkkPNbNbYM8HynGZeKbNPuWrGdmNbJR1POj87XJ9HqDsIJ6+Rzk5U3sb5rBYCw7cXdsReBv4kLS2ipscGz1zpHloPKnWfrm5yasb+YL7Obs74wYRn868EhdOQwLte3hQNWWExU78jtuMPdy6MvtixZmTXbrheElthkZAmU45ShPGsC920dg8ldAyWFsfFo1gkyg8dMxngwKBEzc9PiCsk2pD3L1RCBmFzsdxujyg4fIQTTBqcOveNHDooi/ki2rqYBCv0xzGO5VkBzrRW1Y0X+tFjyZxl1Uy3QPkDxI6Es1212yFeCGnjy6s60=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <84AEF1430B5CAF409CC0D62618B7407E@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d966fda0-338e-478c-42a1-08d70f7db38f
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Jul 2019 14:54:45.5342
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3472
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 08:07:33PM +0530, Souptick Joarder wrote:
> On Mon, Jul 22, 2019 at 3:14 PM Christoph Hellwig <hch@lst.de> wrote:
> >
> > We should not have two different error codes for the same condition.  I=
n
> > addition this really complicates the code due to the special handling o=
f
> > EAGAIN that drops the mmap_sem due to the FAULT_FLAG_ALLOW_RETRY logic
> > in the core vm.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> > Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
> >  Documentation/vm/hmm.rst |  2 +-
> >  mm/hmm.c                 | 10 ++++------
> >  2 files changed, 5 insertions(+), 7 deletions(-)
> >
> > diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
> > index 7d90964abbb0..710ce1c701bf 100644
> > +++ b/Documentation/vm/hmm.rst
> > @@ -237,7 +237,7 @@ The usage pattern is::
> >        ret =3D hmm_range_snapshot(&range);
> >        if (ret) {
> >            up_read(&mm->mmap_sem);
> > -          if (ret =3D=3D -EAGAIN) {
> > +          if (ret =3D=3D -EBUSY) {
> >              /*
> >               * No need to check hmm_range_wait_until_valid() return va=
lue
> >               * on retry we will get proper error with hmm_range_snapsh=
ot()
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index e1eedef129cf..16b6731a34db 100644
> > +++ b/mm/hmm.c
> > @@ -946,7 +946,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
> >   * @range: range
> >   * Return: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM =
invalid
> >   *          permission (for instance asking for write and range is rea=
d only),
> > - *          -EAGAIN if you need to retry, -EFAULT invalid (ie either n=
o valid
> > + *          -EBUSY if you need to retry, -EFAULT invalid (ie either no=
 valid
> >   *          vma or it is illegal to access that range), number of vali=
d pages
> >   *          in range->pfns[] (from range start address).
> >   *
> > @@ -967,7 +967,7 @@ long hmm_range_snapshot(struct hmm_range *range)
> >         do {
> >                 /* If range is no longer valid force retry. */
> >                 if (!range->valid)
> > -                       return -EAGAIN;
> > +                       return -EBUSY;
> >
> >                 vma =3D find_vma(hmm->mm, start);
> >                 if (vma =3D=3D NULL || (vma->vm_flags & device_vma))
> > @@ -1062,10 +1062,8 @@ long hmm_range_fault(struct hmm_range *range, bo=
ol block)
> >
> >         do {
> >                 /* If range is no longer valid force retry. */
> > -               if (!range->valid) {
> > -                       up_read(&hmm->mm->mmap_sem);
> > -                       return -EAGAIN;
> > -               }
> > +               if (!range->valid)
> > +                       return -EBUSY;
>=20
> Is it fine to remove  up_read(&hmm->mm->mmap_sem) ?

It seems very subtle, but under the covers this calls
handle_mm_fault() with FAULT_FLAG_ALLOW_RETRY which will cause the
mmap sem to become unlocked along the -EAGAIN return path.

I think without the commit message I wouldn't have been able to
understand that, so Christoph, could you also add the comment below
please?

Otherwise

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Frankly, I find the 'int *locked' scheme of GUP easier to understand..

diff --git a/mm/hmm.c b/mm/hmm.c
index 16b6731a34db79..54b3a4162ae949 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -301,8 +301,10 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsi=
gned long addr,
 	flags |=3D hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
 	flags |=3D write_fault ? FAULT_FLAG_WRITE : 0;
 	ret =3D handle_mm_fault(vma, addr, flags);
-	if (ret & VM_FAULT_RETRY)
+	if (ret & VM_FAULT_RETRY) {
+		/* Note, handle_mm_fault did up_read(&mm->mmap_sem)) */
 		return -EAGAIN;
+	}
 	if (ret & VM_FAULT_ERROR) {
 		*pfn =3D range->values[HMM_PFN_ERROR];
 		return -EFAULT;

