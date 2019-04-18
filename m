Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FEEBC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:14:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26DDD20675
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:14:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="S4iJSnj7";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="PZXzz6Wh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26DDD20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0D336B0008; Thu, 18 Apr 2019 14:14:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A971C6B000C; Thu, 18 Apr 2019 14:14:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939686B000D; Thu, 18 Apr 2019 14:14:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7BE6B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:14:22 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b1so2739122qtk.11
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=DSUc3ZUilcXF9SyrLXYkcFIObP6rbmpcZ+nA23ILDqs=;
        b=pL6Mef1pnvQqgHXrQIZnkJdQt3lotXpPJrLRyiRFd8PwLNJUgraTNXCsoBzjyFW0pb
         18fTApM6a0ML6REV+DD/WKQiTnqMP+F091VV9YMFuu1AsnadUXNZEzNF9dU+zFBVcm4C
         n20afW5kn2AWsIlmgDUJxfuQQwB5n/1+hENTjyeUEjnQC3NlNxfPy6fGU5JbsaIgFeXH
         z4X973o+q5idmT06f3yVqgkrZSOB97GGhCH/OfATZt4jWZKm8kPROopT3nnve0o6PkVS
         A2yexOqoLPdn1fhyCMctUR6LeZkhM7N7oL4Kv7Wc3haRoghzAfI3io7A/yNr+ToW93ko
         wlZQ==
X-Gm-Message-State: APjAAAU2N+CKvvRwYwgyAt5qlndKFzU3NlUWnXIw17G8L9yNJR0KbSjm
	pXZML5zmsOz+L8SyQEc1grBmBejAV8fRrDrZMLRSJ14qaBLy2V1wJsc32zXv/DI6UgOvG8zQW2n
	SvCLz7JTl78cYE6BMzfGB5HXjrdjUpVxdGCDizCTtpdab6vG3OixsrqcDgkhLMigXAA==
X-Received: by 2002:aed:3427:: with SMTP id w36mr77033454qtd.54.1555611262099;
        Thu, 18 Apr 2019 11:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwe9Ns2KQHdNcFjXqO76VVe0qyTkmzmAQOF5I3r87lp7GBV+kgCjUOVv5I0MB7xim2QZqEc
X-Received: by 2002:aed:3427:: with SMTP id w36mr77033433qtd.54.1555611261473;
        Thu, 18 Apr 2019 11:14:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555611261; cv=none;
        d=google.com; s=arc-20160816;
        b=G+2OupnU+MSgS1QvGQwE8PlJNhnb/K0eBTqr+85ZvR6y7mRepE8d7DHECPNfUZlFSb
         jhDSfm6hFhLKP1CL7IcSMjFIRRFDN/OWYzQgrexv1MYAhkfEtLerLqoVBeamPYCnoW/1
         T+WO3jX/W5b6Ea1DdnmPFTyUrEHsA0/7IFCNVgITqFcfDV3gq9P98jR+awiiCF72SpZF
         GrC1XteZEE2bNJ7Nm4DOdt6RQ3m6ErFAjU+y9XwmcHJot40td8uyYavO5W7wCnTb6ofv
         t6b9r23pTsej4qPgJa6JTavBO2qM2wIT8riphs5Psm0fOB95Sc6ff5nz2auXRX1rXDCY
         JwTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=DSUc3ZUilcXF9SyrLXYkcFIObP6rbmpcZ+nA23ILDqs=;
        b=xbEmM/CMKJnyHXpLqEOhbZ5VwwhgLdIKjG0RXNAGeQOa/h3Bn36Curdvj+uG1RG0eO
         N47IRUKXBbOAT3CnyngDPS7Y7vUYwMDL1laHZtmaFSv10BJfd1V/MRm6ogEH9glPSztN
         +giz8KzQzfOwtTV3CbpVvLwnoYXOELF9uLUTXF0AvctkX21NVlivrBimLtEpKKYuFQDN
         h7b0hRTlCfVlLOki01g1ZEssDAgNilWaiEC1KyZ540t+Ofc3PXzEl7k6XDYNVdA0Smwj
         gx9Trd/Ybz1Mh77aRBVl4D/dU/j0SD7CUfGHZpU5Ruvepnsn65zrpfpR4C2GSl7ZwDQA
         opkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=S4iJSnj7;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=PZXzz6Wh;
       spf=pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90117e5206=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v25si1683410qta.108.2019.04.18.11.14.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 11:14:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=S4iJSnj7;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=PZXzz6Wh;
       spf=pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90117e5206=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3II6QOk003820;
	Thu, 18 Apr 2019 11:14:09 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=DSUc3ZUilcXF9SyrLXYkcFIObP6rbmpcZ+nA23ILDqs=;
 b=S4iJSnj7v4nw51t41u2c6Sene2JN/34aQMO5Ss3kZK4gog3bVdWW4/7g9lrBQOvwmcce
 c0OX/nWyxrJUHs9auO5bxVKRBUaKwCxwu+VAG7o6yqut/z+z4dVZdEvVbnr/Rz4NJ9Fd
 X5UgtUC7cujdMSNxicZkIi500ng600Sc8NU= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rxwj486b1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 18 Apr 2019 11:14:09 -0700
Received: from frc-mbx04.TheFacebook.com (192.168.155.19) by
 frc-hub06.TheFacebook.com (192.168.177.76) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 18 Apr 2019 11:14:08 -0700
Received: from frc-hub01.TheFacebook.com (192.168.177.71) by
 frc-mbx04.TheFacebook.com (192.168.155.19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 18 Apr 2019 11:14:08 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.71) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 18 Apr 2019 11:14:08 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DSUc3ZUilcXF9SyrLXYkcFIObP6rbmpcZ+nA23ILDqs=;
 b=PZXzz6WhfCMD6OW0ipbHlcfX+zlTHRvdrwTvcsDFAJUbhpRdnbn0MHv3YTqCImwtJvfgM3LlLj69GyFW7dqa/q3lk90cSQ0g2cMW5XedBJbKVoIB00m0Soh7aFc/N1UD9VHrjzyMl1h30BKLKQIFxyhs2Oy5W5c9ZPYAb1iMjJ8=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3159.namprd15.prod.outlook.com (20.178.207.220) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.17; Thu, 18 Apr 2019 18:14:05 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.021; Thu, 18 Apr 2019
 18:14:05 +0000
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
Thread-Index: AQHU9WhFLwAo90XwHUSqs2s91sh5hqZBAzaA//+a0QCAAIqtAP//ntuAgAEtKQCAAEV2gA==
Date: Thu, 18 Apr 2019 18:14:05 +0000
Message-ID: <20190418181400.GC11008@tower.DHCP.thefacebook.com>
References: <20190417215434.25897-1-guro@fb.com>
 <20190417215434.25897-5-guro@fb.com>
 <CALvZod5K8SM2EQFH1WM9bbwWBtyXWb_PvzJGvF5dg1Z=bdR7zg@mail.gmail.com>
 <20190418003850.GA13977@tower.DHCP.thefacebook.com>
 <CALvZod6UiTeN40RgpE-4zE5zagSifqh3o_AXaw8o-ubVUWf=4w@mail.gmail.com>
 <20190418030729.GA5038@castle>
 <CALvZod4K9HymKkG9hGoU-sFxZogqP+wrBRD9AighvfUzDGoTFQ@mail.gmail.com>
In-Reply-To: <CALvZod4K9HymKkG9hGoU-sFxZogqP+wrBRD9AighvfUzDGoTFQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR04CA0095.namprd04.prod.outlook.com
 (2603:10b6:301:3a::36) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:497d]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e76cc721-e0ea-475f-3e04-08d6c429a481
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600141)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB3159;
x-ms-traffictypediagnostic: BYAPR15MB3159:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <BYAPR15MB3159E47BBD504E25027D428FBE260@BYAPR15MB3159.namprd15.prod.outlook.com>
x-forefront-prvs: 0011612A55
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(39860400002)(376002)(136003)(346002)(199004)(189003)(55674003)(54094003)(316002)(446003)(256004)(76176011)(54906003)(81156014)(8676002)(81166006)(5660300002)(33656002)(14454004)(476003)(52116002)(6486002)(7416002)(2906002)(99286004)(6916009)(6436002)(93886005)(229853002)(7736002)(6246003)(4326008)(9686003)(8936002)(68736007)(6512007)(6306002)(6116002)(305945005)(966005)(71200400001)(97736004)(102836004)(6506007)(11346002)(53546011)(386003)(53936002)(25786009)(486006)(186003)(71190400001)(1076003)(14444005)(86362001)(478600001)(46003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3159;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: MVTaA9rUXVRnPBjqqSxyxYBms6dEtKa6CgbAXJoSppfsMUnB8tYDDFbcOYWCpF4qoz7iaZ6uJxNmWuid8nO/WxBf7Wyhys9f1q09X52Q3siUdJZzjC8mqdJp9wmqm0rGfpWnmNy5NbmzshGDu82ktZjBdpa9iA6wUCPq4ylGnIivRPrKRbCABjuHoKhUgBg0Nn1bzxpjBjLkapIH60kCGA5eE+v/pHl74ZBO294zlv9EBo5PXXCDshZn0ze4UIV1chv5e3P1CoQfQLp1nln1Nq51BQCn0VcFPOF8rJV+JFbEL+Kszv8HPT8q++P6gyScC2YMaobzmY9ed8TJdWb6bEG3vsqzsB0/0XNKhJyvwxZYiKbqJ6xZJSyfet8Dyx8a0ZnjxSVoJzQ63DgIl0s54ubknsEhHVnKEEFcXDzC1jE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <ADD4024971601F44BCA664623F115C4F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: e76cc721-e0ea-475f-3e04-08d6c429a481
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Apr 2019 18:14:05.4652
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3159
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-18_09:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 07:05:24AM -0700, Shakeel Butt wrote:
> On Wed, Apr 17, 2019 at 8:07 PM Roman Gushchin <guro@fb.com> wrote:
> >
> > On Wed, Apr 17, 2019 at 06:55:12PM -0700, Shakeel Butt wrote:
> > > On Wed, Apr 17, 2019 at 5:39 PM Roman Gushchin <guro@fb.com> wrote:
> > > >
> > > > On Wed, Apr 17, 2019 at 04:41:01PM -0700, Shakeel Butt wrote:
> > > > > On Wed, Apr 17, 2019 at 2:55 PM Roman Gushchin <guroan@gmail.com>=
 wrote:
> > > > > >
> > > > > > This commit makes several important changes in the lifecycle
> > > > > > of a non-root kmem_cache, which also affect the lifecycle
> > > > > > of a memory cgroup.
> > > > > >
> > > > > > Currently each charged slab page has a page->mem_cgroup pointer
> > > > > > to the memory cgroup and holds a reference to it.
> > > > > > Kmem_caches are held by the cgroup. On offlining empty kmem_cac=
hes
> > > > > > are freed, all other are freed on cgroup release.
> > > > >
> > > > > No, they are not freed (i.e. destroyed) on offlining, only
> > > > > deactivated. All memcg kmem_caches are freed/destroyed on memcg's
> > > > > css_free.
> > > >
> > > > You're right, my bad. I was thinking about the corresponding sysfs =
entry
> > > > when was writing it. We try to free it from the deactivation path t=
oo.
> > > >
> > > > >
> > > > > >
> > > > > > So the current scheme can be illustrated as:
> > > > > > page->mem_cgroup->kmem_cache.
> > > > > >
> > > > > > To implement the slab memory reparenting we need to invert the =
scheme
> > > > > > into: page->kmem_cache->mem_cgroup.
> > > > > >
> > > > > > Let's make every page to hold a reference to the kmem_cache (we
> > > > > > already have a stable pointer), and make kmem_caches to hold a =
single
> > > > > > reference to the memory cgroup.
> > > > >
> > > > > What about memcg_kmem_get_cache()? That function assumes that by
> > > > > taking reference on memcg, it's kmem_caches will stay. I think yo=
u
> > > > > need to get reference on the kmem_cache in memcg_kmem_get_cache()
> > > > > within the rcu lock where you get the memcg through css_tryget_on=
line.
> > > >
> > > > Yeah, a very good question.
> > > >
> > > > I believe it's safe because css_tryget_online() guarantees that
> > > > the cgroup is online and won't go offline before css_free() in
> > > > slab_post_alloc_hook(). I do initialize kmem_cache's refcount to 1
> > > > and drop it on offlining, so it protects the online kmem_cache.
> > > >
> > >
> > > Let's suppose a thread doing a remote charging calls
> > > memcg_kmem_get_cache() and gets an empty kmem_cache of the remote
> > > memcg having refcnt equal to 1. That thread got a reference on the
> > > remote memcg but no reference on the kmem_cache. Let's suppose that
> > > thread got stuck in the reclaim and scheduled away. In the meantime
> > > that remote memcg got offlined and decremented the refcnt of all of
> > > its kmem_caches. The empty kmem_cache which the thread stuck in
> > > reclaim have pointer to can get deleted and may be using an already
> > > destroyed kmem_cache after coming back from reclaim.
> > >
> > > I think the above situation is possible unless the thread gets the
> > > reference on the kmem_cache in memcg_kmem_get_cache().
> >
> > Yes, you're right and I'm writing a nonsense: css_tryget_online()
> > can't prevent the cgroup from being offlined.
> >
>=20
> The reason I knew about that race is because I tried something similar
> but for different use-case:
>=20
> https://lkml.org/lkml/2018/3/26/472
>=20
> > So, the problem with getting a reference in memcg_kmem_get_cache()
> > is that it's an atomic operation on the hot path, something I'd like
> > to avoid.
> >
> > I can make the refcounter percpu, but it'll add some complexity and siz=
e
> > to the kmem_cache object. Still an option, of course.
> >
>=20
> I kind of prefer this option.
>=20
> > I wonder if we can use rcu_read_lock() instead, and bump the refcounter
> > only if we're going into reclaim.
> >
> > What do you think?
>=20
> Should it be just reclaim or anything that can reschedule the current thr=
ead?
>=20
> I can tell how we resolve the similar issue for our
> eager-kmem_cache-deletion use-case. Our solution (hack) works only for
> CONFIG_SLAB (we only use SLAB) and non-preemptible kernel. The
> underlying motivation was to reduce the overhead of slab reaper of
> traversing thousands of empty offlined kmem caches. CONFIG_SLAB
> disables interrupts before accessing the per-cpu caches and reenables
> the interrupts if it has to fallback to the page allocation. We use
> this window to call memcg_kmem_get_cache() and only increment the
> refcnt of kmem_cache if going to the fallback. Thus no need to do
> atomic operation on the hot path.
>=20
> Anyways, I think having percpu refcounter for each memcg kmem_cache is
> not that costy for CONFIG_MEMCG_KMEM users and to me that seems like
> the most simple solution.
>=20
> Shakeel

Ok, sounds like a percpu refcounter is the best option.
I'll try this approach in v2.

Thanks!

