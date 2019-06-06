Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86E2BC28CC5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:00:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 083972070B
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 01:00:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="WZ0CNxMh";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="p1R13CVD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 083972070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8035C6B026A; Wed,  5 Jun 2019 21:00:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B2E86B026C; Wed,  5 Jun 2019 21:00:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67C726B026E; Wed,  5 Jun 2019 21:00:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 472EF6B026A
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 21:00:15 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 6so743296ybh.2
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 18:00:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=138NEH48588OSwGvM6l/KKObI1wh0TVGwJvr5k/w5pA=;
        b=HgS4KNuThVbvGC2ly1Uf4hOVmRbfPwEBKRVRu/Ht+BTif2Us88V6mNGbq5h4zlyuaE
         evFPk/3GLnuQ3U+uIG8FcT5FFQ/VF7mzm1zgJCaEVWfy+1ccbnEtP5m54gkQPRB2PkWz
         htuO2HWSKr70ZJhiyfX5NnfMyzfAgfSxFjIrtuSwZK11PeqWl+EE8beHxiruHaKf7E4e
         jNGYODoWS1TFS/TzIDvgxeXoQMnyAk0gJcKHv+zpTtkb4NyBBwIg4Yayu6PzPGf4gM2K
         D/mA4I8jcICMqm7lEajyrogDuq5tR8F88oMgcNDjVOa7pQnWiVSPfFyOYU/Ej82pUOCk
         4x3A==
X-Gm-Message-State: APjAAAXYjEyDNkpfI16ecVioYD81Ok6T9/Y1XPwBephAyPUFNm6lGmBD
	vUWwWKuZAbjm9xXNBbqp/OZqtaYViX6fq6PXcbNfEQPx590hJXRArlIJ2r4tdP10CqvF/d8IxHg
	5pr06UMKHP81xgCeHQDqXc5eTDVymCfKjzJc/QWBxUBSXE+Sjg0dNmwJ1Sg8Rxp80SA==
X-Received: by 2002:a25:a081:: with SMTP id y1mr20750026ybh.428.1559782814960;
        Wed, 05 Jun 2019 18:00:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvbnLyhrpInEuXY3ApbRRFaluWuMSbxznIJKi9C38p8K84p7Rou0y1L/Sc8ZdrgMLN6e+L
X-Received: by 2002:a25:a081:: with SMTP id y1mr20749965ybh.428.1559782813707;
        Wed, 05 Jun 2019 18:00:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559782813; cv=none;
        d=google.com; s=arc-20160816;
        b=rruRO1X93R0gVtyVUjinmSZjGmupzy9g6T/LAi4gHtdFE5sT8YhDwc/0xPUerOnwCt
         qZh8EaCiYNy3eSurQJxPmiM80A0hqBgCpevvm7iBspC6yG5JeQudR6rqkJ4Er2y0JMJg
         KJ59AInixfmhKictUYes6IPN4Tx+dCsL5tcnX/oPOqptH2ekFTX7UZfsShWAbvBbWfwW
         uo4SNKghGHFMA4T5v69FUUr6WOL56XiIPP9p8EtW9FyiBcLQeK9yE+wRWKDUUWRUta4d
         YfXyw0N8P3lYFzAiUKeqHQPGz+8DfPiGR6UOhPOiysjuyVA6JWEOWsUP2zgsCCgNEXFW
         sU8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=138NEH48588OSwGvM6l/KKObI1wh0TVGwJvr5k/w5pA=;
        b=kCLIyp+OBaR2cxaMVSg20GHnddT/P39NHND9NuCa1zJCFdwskPH9sS6Rib7TeMR9L8
         5jU0JZpPsoNKfZQxumWLrodAlYvxe8WJQcbf+rXdRMWwC3i2Jqa3c146SkcntudWAoaX
         MimsJpClRwL+HL/El/CMYjpANVqSXB8WnIuCm4nwmkUQynYljyAy+2qj2sYytOkKqG8d
         tPvZ9tXBJHUDQ9cyenxXumE4llnxIovUangqnznDOr0gJpaZ/nrSNQZhMsvFknizkoXd
         iFCl+TSZy4TMU0Ovfwbxh21UYQpY+eUzFQaKoM8+F9UABqswaLSQnUWfXXFyN10/Eu5F
         xcJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WZ0CNxMh;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=p1R13CVD;
       spf=pass (google.com: domain of prvs=10601ba4eb=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10601ba4eb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c15si121447ywk.21.2019.06.05.18.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 18:00:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10601ba4eb=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WZ0CNxMh;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=p1R13CVD;
       spf=pass (google.com: domain of prvs=10601ba4eb=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10601ba4eb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x560mLNV009614;
	Wed, 5 Jun 2019 17:48:21 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=138NEH48588OSwGvM6l/KKObI1wh0TVGwJvr5k/w5pA=;
 b=WZ0CNxMhsTqlas5Zjp/HjU4Znuson66wluCzjhguLVoUdx39mK8HdUodDg7Kz+Y2eg9q
 nlhED7DVZi5u0W43Ag+d0jfiXLqGdjv9KshRVQHS4qPR0zKp7kIzs7ZY7/3lzVkhGlAy
 xgb4RudDluZZShyyRlK12QChXi6xSupQm0g= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sxkae94pq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 05 Jun 2019 17:48:21 -0700
Received: from prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 5 Jun 2019 17:48:18 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 5 Jun 2019 17:48:18 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 5 Jun 2019 17:48:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=138NEH48588OSwGvM6l/KKObI1wh0TVGwJvr5k/w5pA=;
 b=p1R13CVDngnoG0Kctn27JCtFTJl9RrxSuWF9Xe57a6Ir0dckvbZjqdNKe9eG2g3n0jwvxhOqozcag4tE5wLCPqhMeiP1TFJcRf8GWdVFJVMV1TV/pgd+KP9111/4uDqZz1lU8ChOt9li+Rc4qxeWR2MqER5SCijoDgA+8S6mASc=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB3284.namprd15.prod.outlook.com (20.179.74.81) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1943.22; Thu, 6 Jun 2019 00:48:13 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::251b:ff54:1c67:4e5f]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::251b:ff54:1c67:4e5f%7]) with mapi id 15.20.1943.018; Thu, 6 Jun 2019
 00:48:12 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Shakeel
 Butt" <shakeelb@google.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v6 07/10] mm: synchronize access to kmem_cache dying flag
 using a spinlock
Thread-Topic: [PATCH v6 07/10] mm: synchronize access to kmem_cache dying flag
 using a spinlock
Thread-Index: AQHVG0i1Wx1jT2Odq02KGn1J823cf6aNSJwA///gFoCAAKPAAA==
Date: Thu, 6 Jun 2019 00:48:12 +0000
Message-ID: <20190606004807.GA11599@tower.DHCP.thefacebook.com>
References: <20190605024454.1393507-1-guro@fb.com>
 <20190605024454.1393507-8-guro@fb.com> <20190605165615.GC12453@cmpxchg.org>
 <20190605220201.GA16188@tower.DHCP.thefacebook.com>
In-Reply-To: <20190605220201.GA16188@tower.DHCP.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR2201CA0056.namprd22.prod.outlook.com
 (2603:10b6:301:16::30) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::83cb]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d3c1d354-483d-4afe-db3c-08d6ea18a729
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN8PR15MB3284;
x-ms-traffictypediagnostic: BN8PR15MB3284:
x-microsoft-antispam-prvs: <BN8PR15MB32844AFED5E9047D1C9227AFBE170@BN8PR15MB3284.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5516;
x-forefront-prvs: 00603B7EEF
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(366004)(346002)(396003)(39860400002)(189003)(199004)(102836004)(46003)(478600001)(486006)(229853002)(54906003)(186003)(76176011)(14444005)(8936002)(476003)(6246003)(7736002)(316002)(81166006)(6436002)(256004)(386003)(1076003)(5660300002)(52116002)(6506007)(6916009)(33656002)(99286004)(81156014)(9686003)(2906002)(11346002)(305945005)(8676002)(86362001)(71200400001)(14454004)(66476007)(66946007)(73956011)(64756008)(66556008)(68736007)(71190400001)(66446008)(446003)(4326008)(6486002)(6116002)(25786009)(6512007)(53936002);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB3284;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: qrf4pzwdmI24+4NbWpHwuS10QxbETjHDC0Cc7r3db6bmMPW8eKO5DGs7LZDQerSxBwHcRg4R54NELb8KLkqfs//HRF0pdYBwTYxgDOF0SqMqPgTRkFtU8zGUXe8sgw14sydqfNIYZGSe+NslaGrZgRpOOKX+9BBlFShcGNO9451izBv31Dg01Nf9FDTn+dDD1KxeCayQI54BkQ225JGqE/UZwmBouxRcEJf6PVEN6aAiJy8MJL8t6qKe3FtXoJXkGThDVaR4nXaB3arxG2lFkuCwoFQXGUGtMayqJMHsa8ebrqGTqsf2wjia4z7N0iEbC0lFUSx52jn9b69+4mfGdNGgIIyUTVNU8E9kksiETkR+2xQuq3cLsCg29eM9BgiNuR+sXDQr3fALHkgKO2+ZtrNjHFtxzskn346j5yAElUQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <83F86F943DBA35469FA89D3DD319AE51@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: d3c1d354-483d-4afe-db3c-08d6ea18a729
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Jun 2019 00:48:12.8134
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB3284
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906060004
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 03:02:03PM -0700, Roman Gushchin wrote:
> On Wed, Jun 05, 2019 at 12:56:16PM -0400, Johannes Weiner wrote:
> > On Tue, Jun 04, 2019 at 07:44:51PM -0700, Roman Gushchin wrote:
> > > Currently the memcg_params.dying flag and the corresponding
> > > workqueue used for the asynchronous deactivation of kmem_caches
> > > is synchronized using the slab_mutex.
> > >=20
> > > It makes impossible to check this flag from the irq context,
> > > which will be required in order to implement asynchronous release
> > > of kmem_caches.
> > >=20
> > > So let's switch over to the irq-save flavor of the spinlock-based
> > > synchronization.
> > >=20
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > ---
> > >  mm/slab_common.c | 19 +++++++++++++++----
> > >  1 file changed, 15 insertions(+), 4 deletions(-)
> > >=20
> > > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > > index 09b26673b63f..2914a8f0aa85 100644
> > > --- a/mm/slab_common.c
> > > +++ b/mm/slab_common.c
> > > @@ -130,6 +130,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s,=
 gfp_t flags, size_t nr,
> > >  #ifdef CONFIG_MEMCG_KMEM
> > > =20
> > >  LIST_HEAD(slab_root_caches);
> > > +static DEFINE_SPINLOCK(memcg_kmem_wq_lock);
> > > =20
> > >  void slab_init_memcg_params(struct kmem_cache *s)
> > >  {
> > > @@ -629,6 +630,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *m=
emcg,
> > >  	struct memcg_cache_array *arr;
> > >  	struct kmem_cache *s =3D NULL;
> > >  	char *cache_name;
> > > +	bool dying;
> > >  	int idx;
> > > =20
> > >  	get_online_cpus();
> > > @@ -640,7 +642,13 @@ void memcg_create_kmem_cache(struct mem_cgroup *=
memcg,
> > >  	 * The memory cgroup could have been offlined while the cache
> > >  	 * creation work was pending.
> > >  	 */
> > > -	if (memcg->kmem_state !=3D KMEM_ONLINE || root_cache->memcg_params.=
dying)
> > > +	if (memcg->kmem_state !=3D KMEM_ONLINE)
> > > +		goto out_unlock;
> > > +
> > > +	spin_lock_irq(&memcg_kmem_wq_lock);
> > > +	dying =3D root_cache->memcg_params.dying;
> > > +	spin_unlock_irq(&memcg_kmem_wq_lock);
> > > +	if (dying)
> > >  		goto out_unlock;
> >=20
> > What does this lock protect? The dying flag could get set right after
> > the unlock.
> >
>=20
> Hi Johannes!
>=20
> Here is my logic:
>=20
> 1) flush_memcg_workqueue() must guarantee that no new memcg kmem_caches
> will be created, and there are no works queued, which will touch
> the root kmem_cache, so it can be released
> 2) so it sets the dying flag, waits for an rcu grace period and flushes
> the workqueue (that means for all in-flight works)
> 3) dying flag in checked in kmemcg_cache_shutdown() and
> kmemcg_cache_deactivate(), so that if it set, no new works/rcu tasks
> will be queued. corresponding queue_work()/call_rcu() are all under
> memcg_kmem_wq_lock lock.
> 4) memcg_schedule_kmem_cache_create() doesn't check the dying flag
> (probably to avoid taking locks on a hot path), but it does
> memcg_create_kmem_cache(), which is part of the scheduled work.
> And it does it at the very beginning, so even if new kmem_caches
> are scheduled to be created, the root kmem_cache won't be touched.
>=20
> Previously the flag was checked under slab_mutex, but now we set it
> under memcg_kmem_wq_lock lock. So I'm not sure we can read it without
> taking this lock.
>=20
> If the flag will be set after unlock, it's fine. It means that the
> work has already been scheduled, and flush_workqueue() in
> flush_memcg_workqueue() will wait for it. The only problem is if we
> don't see the flag after flush_workqueue() is called, but I don't
> see how it's possible.
>=20
> Does it makes sense? I'm sure there are ways to make it more obvious.
> Please, let me know if you've any ideas.

Hm, after some thoughts, I've found that the problem is that we check
the dying flag of the root cache. But it's the same in the existing code.

So currently (without my patches):
1) we do set the dying flag under slab_mutex
2) waiting for the workqueue to flush
3) grabbing the slab_mutex and going to release the root kmem_cache

a concurrent memcg_kmem_cache_create_func() can be scheduled after 2),
grab the slab_mutex after 3) and check the kmem_cache->memcg_params.dying
flag of already released kmem_cache.

The reason why it's not a real problem is that it's expected from a user
that kmem_cache will not be used for new allocations after calling
kmem_cache_destroy(). It means no new memcg kmem_cache creation will be
scheduled, and we can avoid checking the dying flag at all.

Does this makes sense?

Thanks!

