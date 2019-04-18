Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29A84C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 03:08:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D46D217F4
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 03:07:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="D8ZKOD/I";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="XkNACIXA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D46D217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0973F6B0005; Wed, 17 Apr 2019 23:07:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04A1F6B0006; Wed, 17 Apr 2019 23:07:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E52036B0007; Wed, 17 Apr 2019 23:07:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A56726B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:07:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id p8so524397pfd.4
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 20:07:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Z2dJelOQ0yl/7TG6RhC7wYBCcKk0cxBJ3I7/DHMqBN4=;
        b=gfMWtJYo4OvepMyCAd7uUAYt1hjOQ9PSuYGo8LZ56Ir4NFlYkpgRByQu/OdrMZja2N
         FCdADUoA5yU/2pKypeNU6Hubefwe2zyD3VMbOysjjd7iA5rydyK17soMNcjhoh6Pta4v
         AOCtPk3czUbGcSP01Rc4syATrKakPshYiwZN2GEjmQOZMD3+CEy8VEbYiC1A/IFE7eLC
         RWyqSaXqGfAEGZoRIjyu3armzyfMHT7CtjCckIV+90+NnrR5k0VJKfGgnkM4/j+Y9YZU
         /Z6/jCUDmaRgidIdGS8XvcL4STMxXh23OqqWDUQnX2HUvR8XV+kLLzjv7KEDNkAkmP93
         fvng==
X-Gm-Message-State: APjAAAU7rlLQ7HHed/iVSo7sY+mvfQhnciD4dWkJs5LMC9fqcXD3aFet
	d0MKVYUwCvLR01jvnkB2H4fsvZ9NFqNhXr0ObyRqR1NbQUqinVkh4RttD5deAPewBQavaXDubQE
	6CggmuAAhqnXX5gWfvsLEsx7Tf9SIZJ3fVhjQ+CmmrAhhv9rk45LA/tDRpi693rI92w==
X-Received: by 2002:a17:902:e01:: with SMTP id 1mr93807578plw.128.1555556878252;
        Wed, 17 Apr 2019 20:07:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0ksT/luOXCDBB+F666vR0f0RGdWB2B9wZKAH9SEA6A4avKSpE9GmXaPCEqYrS5oEisxuZ
X-Received: by 2002:a17:902:e01:: with SMTP id 1mr93807523plw.128.1555556877378;
        Wed, 17 Apr 2019 20:07:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555556877; cv=none;
        d=google.com; s=arc-20160816;
        b=ShvhDwONJeci0KJ7r32wygZRZc2WQ3BcXShUjFiQDbMYRPuLT/sMX3fbZ+CH5OUHQM
         lKfOX8e4PuolWInCf79OCadnZwsjLvkS+Suva4bfoPn7Oe4xoCd32x51FJ8D3TYTncIh
         0pjpQDKIXn/xuzucbBYOTDBZAITuXyE5IzfvdCpf2k649o847SXiHNlHeUvXl+s/WW/c
         nugMNolJLNv9Q0iGMnYl3IRQgJq09OCiqzjYlP0xyS5mJRjni/s5ZY16x1uUnJa7uAYE
         6IVSWWJD3kkZ3WyqKm0lL2XnAUaxidPZNZAT6uB+OL/YXjMBPHGER50fbWy4mztK7DTe
         Dbpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Z2dJelOQ0yl/7TG6RhC7wYBCcKk0cxBJ3I7/DHMqBN4=;
        b=fDpl4StnQAWDrkjhraKaB6+3XbXgGAK3nfA9EMJQ/bKq4Z2iRp9vWo+biQS30kJ41h
         OFm2i+OlZIqZATW95RkRq/slpHFurEKqnIBMCezA7UOJYF8o225oP4JQmEvVzNnUYqLT
         xE05C1x2i0TK4FIYvR8RGNokBwKAw+TlDbunB/WAzlH8EmTcgjLKwUJuCjIUB36o1s0f
         TbHqHbidzMLdkRPj7cu9TTVYau/kbrTpcpebGSf5Baa3C8j4/U1Jgd663kB156v7kGYO
         2QYf8X9ZmZazUt4oxL1oxVlp44NGVdsmQPzxb97ELA8SHAk1l2aiCLntqznCnWP9bx8b
         o4yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="D8ZKOD/I";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=XkNACIXA;
       spf=pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=90117e5206=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c3si1006746pfg.109.2019.04.17.20.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 20:07:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="D8ZKOD/I";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=XkNACIXA;
       spf=pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=90117e5206=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x3I37M9K003913;
	Wed, 17 Apr 2019 20:07:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Z2dJelOQ0yl/7TG6RhC7wYBCcKk0cxBJ3I7/DHMqBN4=;
 b=D8ZKOD/Ihzyye6iV/EbZGj495tOCgRifPz41G+rx2tGqLvZ0zSAzFx5sMGmX6bqLXE2z
 SfFsGZWNSRelafkUPT+1rZeox0HmK9F9vCF3xxnlPspLknalz9GjFo2MunEcBXOkoj32
 z/Qy5usbs1SqLZP02CA97sEdJWJ5pDKCiOw= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2rwm8mdmgv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 17 Apr 2019 20:07:42 -0700
Received: from prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 17 Apr 2019 20:07:41 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 17 Apr 2019 20:07:40 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 17 Apr 2019 20:07:40 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Z2dJelOQ0yl/7TG6RhC7wYBCcKk0cxBJ3I7/DHMqBN4=;
 b=XkNACIXA9ktp4uZ/hi3GBQcWnc49gLlB5iH9DRdfGGvhW9Tb1MfrfIEQPw5WB7ZLZC0HUpOh/eU5vCwL69jrN9NHAmpmCQAKA99Ny8UD0H++Rg4GT/1HCKKNlEsa2R8BqdmU5Gi05no4GqWz5M4ATkukbjcwcp7/EanUMCQ6RkE=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3477.namprd15.prod.outlook.com (20.179.60.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.12; Thu, 18 Apr 2019 03:07:37 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.021; Thu, 18 Apr 2019
 03:07:37 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Roman Gushchin <guroan@gmail.com>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Johannes
 Weiner" <hannes@cmpxchg.org>,
        Michal Hocko <mhocko@kernel.org>, Rik van Riel
	<riel@surriel.com>,
        "david@fromorbit.com" <david@fromorbit.com>,
        "Christoph
 Lameter" <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        Cgroups <cgroups@vger.kernel.org>
Subject: Re: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle management
Thread-Topic: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle management
Thread-Index: AQHU9WhFLwAo90XwHUSqs2s91sh5hqZBAzaA//+a0QCAAIqtAIAAFDUA
Date: Thu, 18 Apr 2019 03:07:37 +0000
Message-ID: <20190418030729.GA5038@castle>
References: <20190417215434.25897-1-guro@fb.com>
 <20190417215434.25897-5-guro@fb.com>
 <CALvZod5K8SM2EQFH1WM9bbwWBtyXWb_PvzJGvF5dg1Z=bdR7zg@mail.gmail.com>
 <20190418003850.GA13977@tower.DHCP.thefacebook.com>
 <CALvZod6UiTeN40RgpE-4zE5zagSifqh3o_AXaw8o-ubVUWf=4w@mail.gmail.com>
In-Reply-To: <CALvZod6UiTeN40RgpE-4zE5zagSifqh3o_AXaw8o-ubVUWf=4w@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR2201CA0040.namprd22.prod.outlook.com
 (2603:10b6:301:16::14) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::3f5]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 87abc140-bcc3-48df-d2c1-08d6c3ab02a1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600141)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB3477;
x-ms-traffictypediagnostic: BYAPR15MB3477:
x-microsoft-antispam-prvs: <BYAPR15MB34771EF43DB9470AAB2AFAF9BE260@BYAPR15MB3477.namprd15.prod.outlook.com>
x-forefront-prvs: 0011612A55
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(7916004)(376002)(346002)(136003)(366004)(39860400002)(396003)(55674003)(54094003)(189003)(199004)(33656002)(5660300002)(486006)(52116002)(476003)(76176011)(68736007)(8936002)(316002)(81166006)(99286004)(186003)(54906003)(11346002)(8676002)(53546011)(386003)(6916009)(46003)(6116002)(446003)(7736002)(6506007)(14444005)(71190400001)(71200400001)(305945005)(256004)(97736004)(6486002)(478600001)(7416002)(86362001)(102836004)(25786009)(81156014)(33716001)(1076003)(4326008)(53936002)(93886005)(9686003)(6246003)(229853002)(2906002)(6436002)(6512007)(14454004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3477;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: OOvb08rZP7Ag0/s7hw+nAGUHEjK+WKpRCONorlIFbJvVjVX4Ra26585ye/81+fU/anYn24VszrAfWzKwPA9KTuYyAVf8IjRdy3lvPXuPGt2kkGkLuOh70lHnsJCVMvgXVoShi2m//9UF9YV/Zk5Q4tzf3VulxSZ0cFba0XLZVQpMkyDQQVAoyfNKfntVjwfC5d6804zMS9fS/lP4vi6JZxxH05eW+7e3yJd3/cdQ3vIZYKovrkb4Q6rcZ9Mey5JjBk46hhtR20EF5x/DMS715/AKkMeXhcwwthdaAF0B1BmqiI/JHBrDMnhgYdHieJlsrgZW119e2AfyCfPIKMaECFtXFa+xoXvt2dJZX4otH+Dxz1Mp1NBYCZmhyUHeMZKu6W3nM2OrY6PSFY4FGO0h2BoLCECX2Z98g0yZtpTiU6g=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <247B59BC911AF840B54250803B8E442F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 87abc140-bcc3-48df-d2c1-08d6c3ab02a1
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Apr 2019 03:07:37.4820
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3477
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-18_02:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 06:55:12PM -0700, Shakeel Butt wrote:
> On Wed, Apr 17, 2019 at 5:39 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > On Wed, Apr 17, 2019 at 04:41:01PM -0700, Shakeel Butt wrote:
> > > On Wed, Apr 17, 2019 at 2:55 PM Roman Gushchin <guroan@gmail.com> wro=
te:
> > > >
> > > > This commit makes several important changes in the lifecycle
> > > > of a non-root kmem_cache, which also affect the lifecycle
> > > > of a memory cgroup.
> > > >
> > > > Currently each charged slab page has a page->mem_cgroup pointer
> > > > to the memory cgroup and holds a reference to it.
> > > > Kmem_caches are held by the cgroup. On offlining empty kmem_caches
> > > > are freed, all other are freed on cgroup release.
> > >
> > > No, they are not freed (i.e. destroyed) on offlining, only
> > > deactivated. All memcg kmem_caches are freed/destroyed on memcg's
> > > css_free.
> >
> > You're right, my bad. I was thinking about the corresponding sysfs entr=
y
> > when was writing it. We try to free it from the deactivation path too.
> >
> > >
> > > >
> > > > So the current scheme can be illustrated as:
> > > > page->mem_cgroup->kmem_cache.
> > > >
> > > > To implement the slab memory reparenting we need to invert the sche=
me
> > > > into: page->kmem_cache->mem_cgroup.
> > > >
> > > > Let's make every page to hold a reference to the kmem_cache (we
> > > > already have a stable pointer), and make kmem_caches to hold a sing=
le
> > > > reference to the memory cgroup.
> > >
> > > What about memcg_kmem_get_cache()? That function assumes that by
> > > taking reference on memcg, it's kmem_caches will stay. I think you
> > > need to get reference on the kmem_cache in memcg_kmem_get_cache()
> > > within the rcu lock where you get the memcg through css_tryget_online=
.
> >
> > Yeah, a very good question.
> >
> > I believe it's safe because css_tryget_online() guarantees that
> > the cgroup is online and won't go offline before css_free() in
> > slab_post_alloc_hook(). I do initialize kmem_cache's refcount to 1
> > and drop it on offlining, so it protects the online kmem_cache.
> >
>=20
> Let's suppose a thread doing a remote charging calls
> memcg_kmem_get_cache() and gets an empty kmem_cache of the remote
> memcg having refcnt equal to 1. That thread got a reference on the
> remote memcg but no reference on the kmem_cache. Let's suppose that
> thread got stuck in the reclaim and scheduled away. In the meantime
> that remote memcg got offlined and decremented the refcnt of all of
> its kmem_caches. The empty kmem_cache which the thread stuck in
> reclaim have pointer to can get deleted and may be using an already
> destroyed kmem_cache after coming back from reclaim.
>=20
> I think the above situation is possible unless the thread gets the
> reference on the kmem_cache in memcg_kmem_get_cache().

Yes, you're right and I'm writing a nonsense: css_tryget_online()
can't prevent the cgroup from being offlined.

So, the problem with getting a reference in memcg_kmem_get_cache()
is that it's an atomic operation on the hot path, something I'd like
to avoid.

I can make the refcounter percpu, but it'll add some complexity and size
to the kmem_cache object. Still an option, of course.

I wonder if we can use rcu_read_lock() instead, and bump the refcounter
only if we're going into reclaim.

What do you think?

Thanks!

