Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1150C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:47:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7663020859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 21:47:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="CMVN92Z9";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="DLHcxTp1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7663020859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 110526B026B; Mon, 10 Jun 2019 17:47:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C1486B026C; Mon, 10 Jun 2019 17:47:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA5C46B026D; Mon, 10 Jun 2019 17:47:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0B096B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:47:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i123so8065124pfb.19
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:47:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=9NroLIhSzcJKpeMrtwemhF+MHU+S+0EktciGfgBDRQQ=;
        b=oAd8hjQYwz2jWqxrvuCY+ydh9VSCdm/PgZ2xLAximXgWp7ErpT0BgBD2IItM7omp/q
         9SNf7E1sA6z7nT0GNcLICIVgFkmCc19I8951r4lChrHp7VFlT8PAK1LhZ812Gf6eIYHq
         rQELUmXlY7CJQ84eqPb7WzswfTygC2d3S5lvB+0obUQlbkRCv6Ns8u7Anjsq5K+uYHBJ
         AEdUh5xhq/tNcMsad1SyVKbG7znbN/a5ryuNfOmQq6ubvbzkrWSgZIxl+hBT638GixtR
         pmfU5uYTOMIqTvxBsEYx3jng39N2ZKOifuEtcU6dIipTtokhpo6hSmVjusBAH9FRubv3
         oazA==
X-Gm-Message-State: APjAAAVUZF7ChnPts2isms/nU8mCE0MnPcGPIXvNoVQIvHFig+C4J4wp
	tmT/lxmxWgBzv+hZLgHTjcnIj8+RIB2D2+5Z9FJ9cyuVWc29hnP2tnGrdEIzs7hsCQe+hLNMTdn
	u6DYOI6Ed2WDjIYFntCKkz/41H1KMeYNcUBNik7JEAvUIzbiGvYG+hc7F/IWlviQtzg==
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr23327257pjb.30.1560203229244;
        Mon, 10 Jun 2019 14:47:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxU96j5GT2Oj5wYoCsrsPRxa0LO86AXM5zK+3ufT8eU5cjjT9nHGkS75qYLadSSnanPcki+
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr23327180pjb.30.1560203227690;
        Mon, 10 Jun 2019 14:47:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560203227; cv=none;
        d=google.com; s=arc-20160816;
        b=pxk730yZKxgnTi5UMDY4QXaUOVbmqVqfQ5rqc5od6FeiNhsCcLq4FnbIJ61jWpmS9E
         e1PwH9NC+e2YPmhg+NE99LtHsFNZATVlpQ0Hol+sElX9O0saLURauCUwlICM+tvaC7lj
         IIsXu4MvJ4ktpKrH9M0c+/UW31wCATljj7Wh+deyABpUo3iBuBPFvhnBQKktc/Qxv8jD
         iu+j7QB4jzJIoTF+QVOFMpBYCLcLe9VeTNG4Qe4BK6kD8aWG0B/QmL07Rq1/XOGzGfTG
         RgziqsN0bmof++DBSL8rm6SpV5j3yGZGvlqSD/z5N87dXHZNXjmhEQc0Kwfuuy2NoaeF
         /oeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=9NroLIhSzcJKpeMrtwemhF+MHU+S+0EktciGfgBDRQQ=;
        b=J7qqqkwH/YS+tL/jX2Edo3yph+SxptuojQvgRjIvPJqsA0hiiIGw571A8ZzydnkTbV
         Fd75C3WOIBW30Vs2IJ9A1CGeRe/lPEheSbh48KCsP9nURXa4kYvT3rOeBYatOysQAcg4
         4AgzIgGfM+Uf3TsKjmdfeW4cwgveiyxIMj+jFBGPG3Y5o0QNRkrLu54UkmNfHnaoX/e6
         Gn8QMKh4270qNP0gjT11wpES86qPQe29ryaLfoDyWhF/dj0Y6cC4JjaOc6HS+6l8YjE9
         j7lKWzawHZIAIOVr0qhE25peooNfnITdE2FYYamBkWurJyMwV9cU8aFhxxYI1khDGiXt
         qPEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=CMVN92Z9;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=DLHcxTp1;
       spf=pass (google.com: domain of prvs=1064574e97=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1064574e97=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h1si3072721pgg.221.2019.06.10.14.47.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 14:47:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1064574e97=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=CMVN92Z9;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=DLHcxTp1;
       spf=pass (google.com: domain of prvs=1064574e97=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1064574e97=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5AKZ1Mw007632;
	Mon, 10 Jun 2019 13:46:54 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=9NroLIhSzcJKpeMrtwemhF+MHU+S+0EktciGfgBDRQQ=;
 b=CMVN92Z9QX9oJAQ1/m1v583ol54Gs3ZL5P18xQ2EzCs6ABcUfEjxckpE9VPII9oybdcZ
 /uF0/8W9sFKEnYah3WPIjQL+fnXGljYGpnJ8+KqVJJIrc1jsahlJQDQNO4K9PRmYqjpn
 TGPahGQjs2WryOLpUkR4BAzNS60VBwge6SQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t1u3n0vqh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 10 Jun 2019 13:46:53 -0700
Received: from ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) by
 ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 10 Jun 2019 13:46:52 -0700
Received: from ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) by
 ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 10 Jun 2019 13:46:52 -0700
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 10 Jun 2019 13:46:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9NroLIhSzcJKpeMrtwemhF+MHU+S+0EktciGfgBDRQQ=;
 b=DLHcxTp1eoqcpMXgJkmMIbHTaD7YHZGYrHk0HZdboEVO5h2oNznujt9Lpsj0MZZj3QlMWIs5hVrzFUN1eIbJTAnk3oYq5SsKrP4AV5upZLe3rRy1UdgjlkD0AS6sfMD+nDxgD//igC2qQHER/RRv8xKQxjn+h9d67F1IIzYRJ4k=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB2627.namprd15.prod.outlook.com (20.179.137.221) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.17; Mon, 10 Jun 2019 20:46:47 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::251b:ff54:1c67:4e5f]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::251b:ff54:1c67:4e5f%7]) with mapi id 15.20.1965.017; Mon, 10 Jun 2019
 20:46:47 +0000
From: Roman Gushchin <guro@fb.com>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Johannes
 Weiner" <hannes@cmpxchg.org>,
        Shakeel Butt <shakeelb@google.com>, Waiman Long
	<longman@redhat.com>
Subject: Re: [PATCH v6 07/10] mm: synchronize access to kmem_cache dying flag
 using a spinlock
Thread-Topic: [PATCH v6 07/10] mm: synchronize access to kmem_cache dying flag
 using a spinlock
Thread-Index: AQHVG0i1Wx1jT2Odq02KGn1J823cf6aTaX8AgAH7JwA=
Date: Mon, 10 Jun 2019 20:46:47 +0000
Message-ID: <20190610204639.GA5838@tower.DHCP.thefacebook.com>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-8-guro@fb.com>
 <20190609143132.cv7b4w5caghuhi53@esperanza>
In-Reply-To: <20190609143132.cv7b4w5caghuhi53@esperanza>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR10CA0003.namprd10.prod.outlook.com (2603:10b6:301::13)
 To BN8PR15MB2626.namprd15.prod.outlook.com (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:2dcb]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 28efd7d9-5125-4c60-be9d-08d6ede4c181
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN8PR15MB2627;
x-ms-traffictypediagnostic: BN8PR15MB2627:
x-microsoft-antispam-prvs: <BN8PR15MB2627CE5DE6C7C4B504FD4A33BE130@BN8PR15MB2627.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3631;
x-forefront-prvs: 0064B3273C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(376002)(396003)(346002)(366004)(136003)(199004)(189003)(52314003)(46003)(14444005)(81166006)(6486002)(52116002)(229853002)(186003)(305945005)(76176011)(6916009)(71190400001)(9686003)(6506007)(256004)(8936002)(81156014)(6512007)(386003)(99286004)(25786009)(478600001)(6436002)(4326008)(71200400001)(86362001)(7736002)(54906003)(14454004)(33656002)(68736007)(1076003)(5660300002)(486006)(6116002)(316002)(8676002)(476003)(446003)(2906002)(66556008)(66476007)(102836004)(53936002)(6246003)(11346002)(73956011)(66446008)(66946007)(64756008);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB2627;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: VPTPz4jHuQIzYFcauPESUVEdEVniCKbM+XvxLep67k/nYDfKvdujMjQlTLgdWw3IiJRYiqeaQYPCJiFBbo+h7D0sNI+N3HczEsxIqeWgLMyyzW+G6/amQQOaLrOAGojAQ8v7qE7FBzILTprNMPoPPqZ39jvAdKVEtA0BXIZoy+5+siSWiBvhk5tKLpttrPPDsZBqj7+ZZBBVIO8Ltw6lDPGGMCgvLkl5S3/ASrVQfK8mJENDpQWCK7mX5+5IHKIbXo8tfLWJHvLV32lRtuosyVvhiNxtPhmdPDhVmjFX3dGW+4uW/oF6HbFykW0dWfwoxtiwikF1gkoMv0OO3qYou8UzzcwH33JDvFCSVEA4xtP6sNkDeMpyXHS/kDJVVYOktYGtcYoYrHiCkC69qu1N1Qkdg7RPiPTV18FEJlYUDsA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <201585CDF61E2A45A240C0AB98B05E04@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 28efd7d9-5125-4c60-be9d-08d6ede4c181
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Jun 2019 20:46:47.7414
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB2627
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-10_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906100139
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 09, 2019 at 05:31:32PM +0300, Vladimir Davydov wrote:
> On Tue, Jun 04, 2019 at 07:44:51PM -0700, Roman Gushchin wrote:
> > Currently the memcg_params.dying flag and the corresponding
> > workqueue used for the asynchronous deactivation of kmem_caches
> > is synchronized using the slab_mutex.
> >=20
> > It makes impossible to check this flag from the irq context,
> > which will be required in order to implement asynchronous release
> > of kmem_caches.
> >=20
> > So let's switch over to the irq-save flavor of the spinlock-based
> > synchronization.
> >=20
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > ---
> >  mm/slab_common.c | 19 +++++++++++++++----
> >  1 file changed, 15 insertions(+), 4 deletions(-)
> >=20
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index 09b26673b63f..2914a8f0aa85 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -130,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, g=
fp_t flags, size_t nr,
> >  #ifdef CONFIG_MEMCG_KMEM
> > =20
> >  LIST_HEAD(slab_root_caches);
> > +static DEFINE_SPINLOCK(memcg_kmem_wq_lock);
> > =20
> >  void slab_init_memcg_params(struct kmem_cache *s)
> >  {
> > @@ -629,6 +630,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *mem=
cg,
> >  	struct memcg_cache_array *arr;
> >  	struct kmem_cache *s =3D NULL;
> >  	char *cache_name;
> > +	bool dying;
> >  	int idx;
> > =20
> >  	get_online_cpus();
> > @@ -640,7 +642,13 @@ void memcg_create_kmem_cache(struct mem_cgroup *me=
mcg,
> >  	 * The memory cgroup could have been offlined while the cache
> >  	 * creation work was pending.
> >  	 */
> > -	if (memcg->kmem_state !=3D KMEM_ONLINE || root_cache->memcg_params.dy=
ing)
> > +	if (memcg->kmem_state !=3D KMEM_ONLINE)
> > +		goto out_unlock;
> > +
> > +	spin_lock_irq(&memcg_kmem_wq_lock);
> > +	dying =3D root_cache->memcg_params.dying;
> > +	spin_unlock_irq(&memcg_kmem_wq_lock);
> > +	if (dying)
> >  		goto out_unlock;
>=20
> I do understand why we need to sync setting dying flag for a kmem cache
> about to be destroyed in flush_memcg_workqueue vs checking the flag in
> kmemcg_cache_deactivate: this is needed so that we don't schedule a new
> deactivation work after we flush RCU/workqueue. However, I don't think
> it's necessary to check the dying flag here, in memcg_create_kmem_cache:
> we can't schedule a new cache creation work after kmem_cache_destroy has
> started, because one mustn't allocate from a dead kmem cache; since we
> flush the queue before getting to actual destruction, no cache creation
> work can be pending. Yeah, it might happen that a cache creation work
> starts execution while flush_memcg_workqueue is in progress, but I don't
> see any point in optimizing this case - after all, cache destruction is
> a very cold path. Since checking the flag in memcg_create_kmem_cache
> raises question, I suggest to simply drop this check.

Yeah, I came to the same conclusion (in a thread with Johannes),
that this check is not required. I'll drop it in a separate patch.

>=20
> Anyway, it would be nice to see some comment in the code explaining why
> we check dying flag under a spin lock in kmemcg_cache_deactivate.

Sure, will add some.

Btw, thank you very much for reviewing the series!

