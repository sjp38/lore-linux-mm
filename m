Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 146D8C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 20:04:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA64F2086A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 20:04:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Y8uBkIUF";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="NQH3+ako"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA64F2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40A0F6B0005; Tue, 14 May 2019 16:04:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B86A6B0006; Tue, 14 May 2019 16:04:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 259666B0007; Tue, 14 May 2019 16:04:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id F14886B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 16:04:34 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id k25so169405uaq.8
        for <linux-mm@kvack.org>; Tue, 14 May 2019 13:04:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=XDYBZG8A2YAwR/soZSe1ByMG22/MIAVGPV0s6wx9Hhs=;
        b=pdySudXumhszFL+4qLFsRGJdaNhbfUm7DI6uycssu/aufKeNJ3+HhtMHlceAKFJMpr
         znaU+J6/prNDRusrQK7ZsqzaRLs+qVa1/pPOdGbuhbG3n+7EFU1QY3F5CAsa+n+MaZyC
         fHMVZMTMKmozmKvpiARlsAOCKwqYwZBVZjy7efvBiSFpinZHAA1IqFDQijLqB7HAJblh
         Pty5osoy1k9Bjedt50pqRamMeMj6+F13DJT/9OyR9Bq/oger9XSK8GX9Vvh+Ajw4J76e
         yBnQ3aGwbg9SL+eZ4pZ2Lhk5sBxWR0aateU+cqi5LPM2zEmnolRywehLRqcR3R/Fe7RV
         clWA==
X-Gm-Message-State: APjAAAXohwaVawgAr7D/92IAJ1qFCC0pBV/UiXRpNx63tjEUluftPz0A
	lvS9v/W4jnvMwNkWhafpVH0gqU2tL+JOh+xJuyxAGG2CiRkREvCy4yVhYrxC1/KF5l6mRXlVsz0
	uouyorDPzXMpGq2haS+/Tg9a4qmbUKBxF+OS3LV28/qz9Non22DVR3VuM2EtPfjoBVg==
X-Received: by 2002:a67:b144:: with SMTP id z4mr9263460vsl.25.1557864274601;
        Tue, 14 May 2019 13:04:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTuqx6XQ1rNFJ3PYOEB10adGLnsOI+/bK+nkLyeR/G3XGv+wycfw5R70XNk+q9KcSJaDn8
X-Received: by 2002:a67:b144:: with SMTP id z4mr9263397vsl.25.1557864273730;
        Tue, 14 May 2019 13:04:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557864273; cv=none;
        d=google.com; s=arc-20160816;
        b=vU1sQCxkgISyY8rile2oOFVjJqA3cME14uydT8Fr0V2622T5U4keNvq8ZUBINQxyBx
         SrK3zFv6Vxp97mkk3TWpWdickA1YIXQyUSmBcSSr/infbsHaROa4+Tz9QaM+NW2QxmNU
         rUShxsb4xRiOQEy4ZDYt1ERMTVHZj7Q7/xVKqUOhk2JzB3KWzaazz8azr3OIoyrWUPje
         P6lG8Wje/jAdTRL7geUoYkWZLu5dQXTb3F7V2ZEBoFsHf3JMQCCk4QYaCMqr7Cq+8SJF
         jh2Pr6E+b37Un26VfLndpbNR4LJEVMoQrKp7qlEw3h6PEz0xGAoBhX6x2TwhckCfSYR0
         1XbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=XDYBZG8A2YAwR/soZSe1ByMG22/MIAVGPV0s6wx9Hhs=;
        b=k27AJ5FdN9vdnwliW8y93Jm7VN4zl0TrumLaIMPVcvxMySgDaqi3Dh+i3BqqS8ZQL7
         XvEvtzBVTVD05jY5qi0nI1QhZchhqTsRvYlJlBNwIujNaic62fTN0RtVIBS/nwU0ulil
         SjJV/OP0NZcm9HLfF/2YhoNKYy0LCzUWwPDWzanhuBRGpVELN+YN+csM9dIjgj2UQSvO
         lAiPdVACL+rBddzbfPuFQH20SG8ENYEcDgCt30RqBCSZRmlsiIUB5DuHC+yGyxnISZvm
         jvNiDpUt21BdA+jFrcxMtCXdTYNvQSG2psOvxN+w3rrkWpW3jrUgpsbqaLT/c7gDhwgK
         3aWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Y8uBkIUF;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=NQH3+ako;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k5si1233087vsq.197.2019.05.14.13.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 May 2019 13:04:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Y8uBkIUF;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=NQH3+ako;
       spf=pass (google.com: domain of prvs=0037dedd0e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0037dedd0e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x4EK4C6H022260;
	Tue, 14 May 2019 13:04:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=XDYBZG8A2YAwR/soZSe1ByMG22/MIAVGPV0s6wx9Hhs=;
 b=Y8uBkIUFpcPveDqGTtJ0sObqL0awHr835TfVj95DuR8UW6HIyFY7U/oimLPxxm3aZih0
 U7NXaBScwd/p0BVuCV472Pd+Hk5YHjfcCykNsRFs/T6jrrQJLRLao2aS3zUibvy29t5g
 h3LNoRO4TbW0lzkM4d+X4nSPG7ZffayCHaI= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2sfv361yr5-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 14 May 2019 13:04:29 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 14 May 2019 13:04:09 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 14 May 2019 13:04:09 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=XDYBZG8A2YAwR/soZSe1ByMG22/MIAVGPV0s6wx9Hhs=;
 b=NQH3+akos5tt/UBmphMosqnrG5Lg9d2amThk1QWrGj54XwmwC5pPt/LWoB1KMlYIKAzcPGVAkI6UXp6i7vxjDMubeEFa+XjQrwIIKkkSns6NjV/Q4tFulnk2c4xOEMa8RUrz0Es79qMUtdrVBczRuzl5RlgqNdsOqqeMp2BM9xI=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2760.namprd15.prod.outlook.com (20.179.157.209) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.22; Tue, 14 May 2019 20:04:07 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1878.024; Tue, 14 May 2019
 20:04:07 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
        "Rik
 van Riel" <riel@surriel.com>, Christoph Lameter <cl@linux.com>,
        "Vladimir
 Davydov" <vdavydov.dev@gmail.com>,
        Cgroups <cgroups@vger.kernel.org>
Subject: Re: [PATCH v3 0/7] mm: reparent slab memory on cgroup removal
Thread-Topic: [PATCH v3 0/7] mm: reparent slab memory on cgroup removal
Thread-Index: AQHVBdzwAdhboUuRQEWJczJkLkr7hKZlFjyAgAP7rACAAfcCAIAAC7UA
Date: Tue, 14 May 2019 20:04:07 +0000
Message-ID: <20190514200402.GE12629@tower.DHCP.thefacebook.com>
References: <20190508202458.550808-1-guro@fb.com>
 <CALvZod4WGVVq+UY_TZdKP_PHdifDrkYqPGgKYTeUB6DsxGAdVw@mail.gmail.com>
 <20190513202146.GA18451@tower.DHCP.thefacebook.com>
 <CALvZod4GscZjob8bfCcfhsMh0sco16r4yfOaRU69WnNO7MRrpw@mail.gmail.com>
In-Reply-To: <CALvZod4GscZjob8bfCcfhsMh0sco16r4yfOaRU69WnNO7MRrpw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR04CA0180.namprd04.prod.outlook.com
 (2603:10b6:104:4::34) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::298]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7a28cc47-6388-42c3-5c41-08d6d8a75205
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB2760;
x-ms-traffictypediagnostic: BYAPR15MB2760:
x-microsoft-antispam-prvs: <BYAPR15MB27606384D21A79C91EB97253BE080@BYAPR15MB2760.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 0037FD6480
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(366004)(136003)(39860400002)(51914003)(199004)(189003)(229853002)(6436002)(99286004)(305945005)(7736002)(76176011)(52116002)(102836004)(53546011)(1076003)(386003)(6506007)(316002)(186003)(66556008)(64756008)(66476007)(66446008)(66946007)(54906003)(73956011)(6916009)(6486002)(7416002)(9686003)(86362001)(14444005)(256004)(6512007)(446003)(11346002)(6116002)(14454004)(8936002)(8676002)(68736007)(5660300002)(81166006)(81156014)(46003)(25786009)(486006)(2906002)(4326008)(71190400001)(33656002)(478600001)(53936002)(6246003)(476003)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2760;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: y64YYLKF50mo6rqk5wQDI74iATKrh8qIjsny2QJ+0jZUSvH3YCXQHM1WI/iK2FSRORHdPd0AJhZC7Ej7kjCb30vHEwFH9gYGebpJpxvJs2e3x0+qbl4gNJ20bEtvhuRtWsYZrs+rYgExyFrin22y03tXzIuEsofF4DdoXLbv/CK9lEFs5CMezt1pFF/0+mIQrlNIu2OUfhBB0zcZGZKmhyz6y4YCAvjRDoQ+rdAWiX7fS5k+kP802TocrBJe0GffDpQckCgBOynZpEAg0tRyM9XxXGKLuvu6sVDoKaDKwOqZa0nzHu6RBvinNXl/bNxZAvm/vcWXq627RSnUL/TErWd5RK+TuStxwRKJnXvgUhunRIMVHQC267DyJWveGW2h+oujlihrifnszSZ/1sZUA8Y9FZGBCbZzoyWv86FgWX0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <78C6EF45B1ED7E4EA4926F9332690197@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 7a28cc47-6388-42c3-5c41-08d6d8a75205
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 May 2019 20:04:07.0273
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2760
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-14_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905140134
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 12:22:08PM -0700, Shakeel Butt wrote:
> From: Roman Gushchin <guro@fb.com>
> Date: Mon, May 13, 2019 at 1:22 PM
> To: Shakeel Butt
> Cc: Andrew Morton, Linux MM, LKML, Kernel Team, Johannes Weiner,
> Michal Hocko, Rik van Riel, Christoph Lameter, Vladimir Davydov,
> Cgroups
>=20
> > On Fri, May 10, 2019 at 05:32:15PM -0700, Shakeel Butt wrote:
> > > From: Roman Gushchin <guro@fb.com>
> > > Date: Wed, May 8, 2019 at 1:30 PM
> > > To: Andrew Morton, Shakeel Butt
> > > Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
> > > <kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
> > > Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
> > > Gushchin
> > >
> > > > # Why do we need this?
> > > >
> > > > We've noticed that the number of dying cgroups is steadily growing =
on most
> > > > of our hosts in production. The following investigation revealed an=
 issue
> > > > in userspace memory reclaim code [1], accounting of kernel stacks [=
2],
> > > > and also the mainreason: slab objects.
> > > >
> > > > The underlying problem is quite simple: any page charged
> > > > to a cgroup holds a reference to it, so the cgroup can't be reclaim=
ed unless
> > > > all charged pages are gone. If a slab object is actively used by ot=
her cgroups,
> > > > it won't be reclaimed, and will prevent the origin cgroup from bein=
g reclaimed.
> > > >
> > > > Slab objects, and first of all vfs cache, is shared between cgroups=
, which are
> > > > using the same underlying fs, and what's even more important, it's =
shared
> > > > between multiple generations of the same workload. So if something =
is running
> > > > periodically every time in a new cgroup (like how systemd works), w=
e do
> > > > accumulate multiple dying cgroups.
> > > >
> > > > Strictly speaking pagecache isn't different here, but there is a ke=
y difference:
> > > > we disable protection and apply some extra pressure on LRUs of dyin=
g cgroups,
> > >
> > > How do you apply extra pressure on dying cgroups? cgroup-v2 does not
> > > have memory.force_empty.
> >
> > I mean the following part of get_scan_count():
> >         /*
> >          * If the cgroup's already been deleted, make sure to
> >          * scrape out the remaining cache.
> >          */
> >         if (!scan && !mem_cgroup_online(memcg))
> >                 scan =3D min(lruvec_size, SWAP_CLUSTER_MAX);
> >
> > It seems to work well, so that pagecache alone doesn't pin too many
> > dying cgroups. The price we're paying is some excessive IO here,
>=20
> Thanks for the explanation. However for this to work, something still
> needs to trigger the memory pressure until then we will keep the
> zombies around. BTW the get_scan_count() is getting really creepy. It
> needs a refactor soon.

Sure, but that's true for all sorts of memory.
Re get_scan_count(): for sure, yeah, it's way too hairy now.

>=20
> > which can be avoided had we be able to recharge the pagecache.
> >
>=20
> Are you looking into this? Do you envision a mount option which will
> tell the filesystem is shared and do recharging on the offlining of
> the origin memcg?

Not really working on it now, but thinking of what to do here long-term.
One of the ideas I have (just an idea for now) is to move memcg pointer
from individual pages to the inode level. It can bring more opportunities
in terms of recharging and reparenting, but I'm not sure how complex it is
and what are possible downsides.

Do you have any plans or ideas here?

>=20
> > Btw, thank you very much for looking into the patchset. I'll address
> > all comments and send v4 soon.
> >
>=20
> You are most welcome.

Thanks!

