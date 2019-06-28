Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F9CFC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:31:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC2CC2086D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:31:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="RG3h+qO2";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="fnCP2Z3e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC2CC2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5383D8E0005; Fri, 28 Jun 2019 13:31:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E8618E0002; Fri, 28 Jun 2019 13:31:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3127D8E0005; Fri, 28 Jun 2019 13:31:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E54CF8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 13:31:00 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y9so3877402plp.12
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 10:31:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=VgE/836/q1ZgHFTz46BuTxhY1pWpQQygQXnKQTtXWWg=;
        b=VvvSS66OQEFRPnymLEkaBszV+uxo5m9YaOm4dflnR+7vwN7E1Y5e2Mn7QJ83GpmBZx
         Fv4s9C8RgDeYIo8yF55zD41luo92StzKeAbK+pGEXV8vySThS5OR+EBhq+LXp29yj8zc
         rz3VD4UecyhbwIQCU6DFgG8stRCn8hs3TiZ7aHqUXDq/3HRM+j2fQguLfQMZF1zpsIQV
         iwI4g6dwMuaT6RfZWM404zvsGRes8AxTV8PaWs//NaPjVJned1THH4dTtXNDUTpioQsX
         //13DEe1UBIxIKaZ01tSii72Qzi++lUYn40EC+kseahRDAdd/jG344SHt0dtG8pXLnMM
         Vc2Q==
X-Gm-Message-State: APjAAAXtCVqFhybsC8/VM8eA9KFPuTgFYcS6pslfTwpOhZSFFLx/fmIg
	brOnZnJ4u12GxZcBGbR90VyoqwI75tGpYD4T9NSTsPHIvQjaZ/XRzXeuji+4glsfDlFUIDdi53v
	NvrNoq9o6MWdt35MTiyeaHCMfVvHM1OAIwI9THlbLf729idQpg6ZWEgswc8oYMqFEUQ==
X-Received: by 2002:a17:902:1486:: with SMTP id k6mr12664394pla.177.1561743060537;
        Fri, 28 Jun 2019 10:31:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkZswSo6VF0wJCn5N7QfjbSGImrsgY6HzXend+CkeXDC3/Usazn5FFj975woFccTQD9j5M
X-Received: by 2002:a17:902:1486:: with SMTP id k6mr12664345pla.177.1561743059785;
        Fri, 28 Jun 2019 10:30:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561743059; cv=none;
        d=google.com; s=arc-20160816;
        b=oJIF8Atd9kELPtrrO2ZTijeD/yfG1IODgCLesKXaOvLrzS7UCmmzDAOTQ/NDCnrdUx
         Yd36Pd4uz7JXw1O/rHbPOG8CAgETLIuRPeOc62M2Oe0mUxVgUcDae580nKzatJpJpeey
         EaCnyaFyD4L59uwmPu9cgyqzrIyDCi9gPimyYusM/2aKdgYotRaPlV8Lqo9vM6b15pc6
         R+4KStuojrD5clfL34V0kX6oWplMCBgg7j6nJ94UigBQEgYcp6+KoYKwCTRzY/KsMiRC
         CV59Bve6Ain4PjIbXb6/uiS/oSROvEPZHpM3+3nSu73XnNQNS/tFH3TCgLUqHNMFvPhH
         VL7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=VgE/836/q1ZgHFTz46BuTxhY1pWpQQygQXnKQTtXWWg=;
        b=FMeYhMQtORT3nVY2ins2RbdOGTYLRTWDZlyUaSxPVjbJR95euCxSqeJYYDlqvdomwL
         ILb+sO2bCyeWM4NrjPU0WnPXXA2XKiQAgc5Jk0f8PUmHqYzdo1qc02KWPLnVDsT0EO8w
         d+CETlOKd8Z/Du2BtUODHXMQ1kSrT+W7X4y+Em1504b42XN2rcyLzZLidS+9PGrsE+MQ
         MpcoYlnBO1kNtq0mGqvbs9lsqH7OH6w3AXE0BK26WQJMoRZ6vrjGTMaLkRWH4g22Wqbq
         ln0m9Z9l9JbSF3DcRgoamaLiSpYAC3WtlLA6GaMoIWDQvmDDjD7xsYdYqz+qrtT92Wbr
         hGhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RG3h+qO2;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=fnCP2Z3e;
       spf=pass (google.com: domain of prvs=2082cb8c86=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=2082cb8c86=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x13si2526029pgh.116.2019.06.28.10.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 10:30:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=2082cb8c86=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RG3h+qO2;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=fnCP2Z3e;
       spf=pass (google.com: domain of prvs=2082cb8c86=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=2082cb8c86=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5SHQ7N2028126;
	Fri, 28 Jun 2019 10:30:51 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=VgE/836/q1ZgHFTz46BuTxhY1pWpQQygQXnKQTtXWWg=;
 b=RG3h+qO2eUkVxxSHAw1yZ6M0fUOP0KjgMeAjUlRXexZDZWhyluqnvVzPEhWsIwWNPXqG
 dg4mNOO7A3fUPL/Y6peIx8gp8Sx5drQdBAFlA1Ycs9Ex46yB47K1vGFDURUCjVpJHKF4
 ITfAstaTyrYZWotQcUkEEokEsMSZvDvRY2A= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2tdk48s1kt-11
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 28 Jun 2019 10:30:51 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 28 Jun 2019 10:30:48 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 28 Jun 2019 10:30:48 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VgE/836/q1ZgHFTz46BuTxhY1pWpQQygQXnKQTtXWWg=;
 b=fnCP2Z3ei5ogfSNC2Z7AO3ZfRV6TRW3tg09Sr8nVG+XpuZuPDzbRa/h1puTh8gKAKyO+FAw3z5+B7sGcVAeCdH7i/cJxcpfwbyoQd0pGxbXhwSbiK5Mltb70urDIMfiwETSB4YCBdvpA2FAIKMdTy1w2lGm4UIe3V6kdhxSmr0k=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB2868.namprd15.prod.outlook.com (20.178.218.208) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.17; Fri, 28 Jun 2019 17:30:47 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::e594:155f:a43:92ad]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::e594:155f:a43:92ad%6]) with mapi id 15.20.2008.018; Fri, 28 Jun 2019
 17:30:46 +0000
From: Roman Gushchin <guro@fb.com>
To: Yang Shi <shy828301@gmail.com>
CC: Christopher Lameter <cl@linux.com>, Waiman Long <longman@redhat.com>,
        Pekka Enberg <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Jonathan Corbet <corbet@lwn.net>, Luis Chamberlain <mcgrof@kernel.org>,
        "Kees
 Cook" <keescook@chromium.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "Michal
 Hocko" <mhocko@kernel.org>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-doc@vger.kernel.org"
	<linux-doc@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "cgroups@vger.kernel.org"
	<cgroups@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Shakeel Butt <shakeelb@google.com>,
        "Andrea
 Arcangeli" <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Thread-Topic: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Thread-Index: AQHVKrRnjGLXeWaE8kq5EhXDbrxOt6auY3OAgAGdGgCAAAdmgIABMAYAgAAc/YCAAAQKAA==
Date: Fri, 28 Jun 2019 17:30:46 +0000
Message-ID: <20190628173040.GA11971@tower.DHCP.thefacebook.com>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
 <20190626201900.GC24698@tower.DHCP.thefacebook.com>
 <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com>
 <20190627212419.GA25233@tower.DHCP.thefacebook.com>
 <0100016b9eb7685e-0a5ab625-abb4-4e79-ab86-07744b1e4c3a-000000@email.amazonses.com>
 <CAHbLzkr+EJWgAQ9VhAdeTtMx+11=AX=mVVEvC-0UihROf2J+PA@mail.gmail.com>
In-Reply-To: <CAHbLzkr+EJWgAQ9VhAdeTtMx+11=AX=mVVEvC-0UihROf2J+PA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR13CA0034.namprd13.prod.outlook.com
 (2603:10b6:300:95::20) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:e2ec]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f68ec203-4456-4e4e-2347-08d6fbee5abe
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN8PR15MB2868;
x-ms-traffictypediagnostic: BN8PR15MB2868:
x-microsoft-antispam-prvs: <BN8PR15MB286844A9C0D2B3F61340502ABEFC0@BN8PR15MB2868.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 00826B6158
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(346002)(376002)(136003)(39860400002)(189003)(199004)(6512007)(81166006)(9686003)(102836004)(305945005)(66476007)(446003)(6116002)(64756008)(6246003)(6436002)(73956011)(66946007)(316002)(6486002)(66446008)(25786009)(386003)(66556008)(86362001)(14454004)(1411001)(1076003)(71200400001)(71190400001)(54906003)(486006)(11346002)(186003)(8676002)(14444005)(256004)(229853002)(33656002)(476003)(6506007)(46003)(53546011)(8936002)(53936002)(52116002)(76176011)(2906002)(81156014)(68736007)(478600001)(5660300002)(7736002)(99286004)(4326008)(6916009)(7416002);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB2868;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: PsMfrYT+MMnl1+MiSXu8aFedaregyy8EiFnekbYMHIX4/79EIJvUT7IbGe4/7xL6HP+V5FS0VWSiAyOffsSqZzW4b/DuyM1syOMFQ0mxh5lPlJZkiunP71n6pNC/FSyk+5dtkv9Xgza09NGoIxdXDhWnzY3EeM64fkXF4pqo1yJ8eg71+LwglTVICpeppbxnRunQ8nemOJfTgCaOTUfcWNm3Isr1LF1cLyoF9pisUxZ5IB8Eub/G/CClLKzBH5rTgZBrMeALuQVNovUz79ma4NAARzzEgmk+ulnfT2560rYcVbuKjx3809D+PU3VFa10HxMa10Y1eRiWWK+kyjypLga/8MKz76RU0yIJZ8ZFUpFdZxfScuAEcZVnJx3ElewqZeCbPUmdQzr6zTGUmc55rZdMrHHoMGVGvbPAYLBgirc=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <96E427C466A25B4EB9262E3679EF031A@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: f68ec203-4456-4e4e-2347-08d6fbee5abe
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jun 2019 17:30:46.7759
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB2868
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-28_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=739 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906280200
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 10:16:13AM -0700, Yang Shi wrote:
> On Fri, Jun 28, 2019 at 8:32 AM Christopher Lameter <cl@linux.com> wrote:
> >
> > On Thu, 27 Jun 2019, Roman Gushchin wrote:
> >
> > > so that objects belonging to different memory cgroups can share the s=
ame page
> > > and kmem_caches.
> > >
> > > It's a fairly big change though.
> >
> > Could this be done at another level? Put a cgoup pointer into the
> > corresponding structures and then go back to just a single kmen_cache f=
or
> > the system as a whole? You can still account them per cgroup and there
> > will be no cleanup problem anymore. You could scan through a slab cache
> > to remove the objects of a certain cgroup and then the fragmentation
> > problem that cgroups create here will be handled by the slab allocators=
 in
> > the traditional way. The duplication of the kmem_cache was not designed
> > into the allocators but bolted on later.
>=20
> I'm afraid this may bring in another problem for memcg page reclaim.
> When shrinking the slabs, the shrinker may end up scanning a very long
> list to find out the slabs for a specific memcg. Particularly for the
> count operation, it may have to scan the list from the beginning all
> the way down to the end. It may take unbounded time.
>=20
> When I worked on THP deferred split shrinker problem, I used to do
> like this, but it turns out it may take milliseconds to count the
> objects on the list, but it may just need reclaim a few of them.

I don't think the shrinker mechanism should be altered. Shrinker lists
already contain individual objects, and I don't see any reasons, why
these objects can't reside on a shared set of pages.

What we're discussing is that it's way too costly (under some conditions)
to have many sets of kmem_caches, if each of them is containing only
few objects.

Thanks!

