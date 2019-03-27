Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9016C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 00:42:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A5582082F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 00:42:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mhVfrq7a";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="VT5mMrXg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A5582082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0B276B0007; Tue, 26 Mar 2019 20:42:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D93E86B0008; Tue, 26 Mar 2019 20:42:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C35E56B000A; Tue, 26 Mar 2019 20:42:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 96EC06B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 20:42:26 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id i3so15343705qtc.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 17:42:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=D++9gB0tiCTNsjjeCg0L0DK845RGtsK80Q1kk0QCOtY=;
        b=ordhH1wdliK9U9K9ApDx8XKyyHennf7GjuMotBCPKK5lkxYwtZ82Xr/9wYD4O5Q2Vy
         ZnsX3jP7JJ/fUDZR3VfZ9VdJkgyvarHbg+CJDGU8qrW5FdNvOVOHpvMPVmNv04nh84ZS
         u/jf0ORrcmh1qh8McvXVQ3Hlmu4yEcQ+2GNZ1LFms7uBEtjoSgMoa8ZGvn4tftbryHH/
         LNTM72Dtt2aADkwgn9EAutjEU8W0gKTJNCieieo6pxOdStc3h1u3L/L8G1DX5y9o33Lv
         LeIqJGgnqZPJMTzYnD2ikMdqssT7Wp+4ilhQrhHgSvgYvinFmO5oBhyQqGgw4H/X/7iw
         LGNA==
X-Gm-Message-State: APjAAAUdpfj7mlhuTlRPd5NZIaH8Sd062ZlTOLdaag1P7Kwd9pc4SGTa
	HetBSrKTjhWvdblb+tXNYqYLwEVSsCqjwl1pmFF8gruu+o/iyD48w6X2eE1CyVRtrQK2mOcxZia
	OMp8MttssdCWgIQBy1vWHgWmMom7rVR39NoK8OhjAIW7PvAdCdeYHteb4Vbr5dMMf6Q==
X-Received: by 2002:a37:8dc1:: with SMTP id p184mr25843791qkd.172.1553647346295;
        Tue, 26 Mar 2019 17:42:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRNog++otz6D7uzRJrZuNkGT+o7kE5h1NAtdBoo5LVAMpbxDI8VeBgLkryfgcxxA/aZbBq
X-Received: by 2002:a37:8dc1:: with SMTP id p184mr25843772qkd.172.1553647345701;
        Tue, 26 Mar 2019 17:42:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553647345; cv=none;
        d=google.com; s=arc-20160816;
        b=AxegxeLb5iMW5mRfuQvIcAuRvNuvwf0dhKZfPATMTjEs8Xj1N4sV3A1d+7HHznapbt
         ry60HT1SJufx/rdJ6F8L9OQzMjMz2YJIWvSeeLnUeSU0Sv6ZxGhZAgdorwYra/JNe/3v
         R4/CI21vBQsyZKlBmxxTh66mFPVGLpwP9nS/osKAXoX5ftEEPyr1trLbK8FfDdxrK7oU
         CmbWK149OU+a7ugSRfc/kvXOTVJxQsgp8vGgQ+t5WSJd1p8rxMNXQ24A41D/QjFFxVZQ
         EzfL7QPGyx2seaIjGgosPRMVB1twh1Ok6FByBgriuMCM2YXCWzCq/R7zkJdttnrrs3Id
         DzMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=D++9gB0tiCTNsjjeCg0L0DK845RGtsK80Q1kk0QCOtY=;
        b=DAjK+U6IBtOk+E9QPBuN7flAUYJ4ZMVY8antzqzA9uJwJNJWoY+wWcoj9POmQpvhXk
         FK3ZlJRzKEdsJp+sgyyF59089XnHuOIR+YFtiM2kQo4lipakkUVgZ3tgmn578jdw1I+C
         bt07RpLQo5YaD4v/3hfnXar2Qu9askB2VVkAKVZzNa2H+lvUaPA3TbtaxTFItQhNUigz
         IxScC3qSHMFNn+8JUA786pK0UKRyJgLPOKsb3z6hX6RLuPLW342+/M1Qd0OAbuy9eNbM
         lx1FTocN8Oml+HWx/d/qIOJKsy/oIyqLrHeohq+e5w+wJ9H2dAxG6K59wGOdT9tCpKVl
         yGjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mhVfrq7a;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=VT5mMrXg;
       spf=pass (google.com: domain of prvs=8989f3ed18=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=8989f3ed18=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id b189si1672280qkd.230.2019.03.26.17.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 17:42:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=8989f3ed18=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mhVfrq7a;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=VT5mMrXg;
       spf=pass (google.com: domain of prvs=8989f3ed18=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=8989f3ed18=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x2R0el7N004388;
	Tue, 26 Mar 2019 17:41:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=D++9gB0tiCTNsjjeCg0L0DK845RGtsK80Q1kk0QCOtY=;
 b=mhVfrq7a7vWFoNHRRQI2FGfqDUazpUYUBcUhvEZXBo8J12LcRVWjkhr/yHGje259/Z3i
 5632HCJatstbagMjWHk0eoU8x9l129wAJ4/u368qjDtf7hYBoDgiMAEaCBRIvKmwMq+c
 kBoKFJpPsfvG582lVPULBqz/60g6l7dRsms= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2rfx6n85a9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 26 Mar 2019 17:41:41 -0700
Received: from prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 26 Mar 2019 17:41:41 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 26 Mar 2019 17:41:40 -0700
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 26 Mar 2019 17:41:40 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=D++9gB0tiCTNsjjeCg0L0DK845RGtsK80Q1kk0QCOtY=;
 b=VT5mMrXgNmTSXRxJxrwKcZs/+fgYjDEUTd6KfKBshiw7AmwF7+Gt3arAKr0zR/GXPQsGq0nm63QRVF6HpcJtiqXDV0GK01Kb/q1i0ZIgUE55hFJeMDjO8uEpBWC/Q+rvRHHEI2pB0B4rvPSpTkSBrR4o8vG0nqGxuKPIcB6sWT8=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3302.namprd15.prod.outlook.com (20.179.58.14) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.15; Wed, 27 Mar 2019 00:41:37 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%3]) with mapi id 15.20.1730.019; Wed, 27 Mar 2019
 00:41:37 +0000
From: Roman Gushchin <guro@fb.com>
To: Uladzislau Rezki <urezki@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
        Matthew Wilcox <willy@infradead.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Thomas Garnier
	<thgarnie@google.com>,
        Oleksiy Avramchenko
	<oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 1/1] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Topic: [RFC PATCH v2 1/1] mm/vmap: keep track of free blocks for vmap
 allocation
Thread-Index: AQHU4BjXJdywTTE8CEqJ5FdlsRP4taYXvgiAgATfxQCAAWjngIAApMCA
Date: Wed, 27 Mar 2019 00:41:37 +0000
Message-ID: <20190327004130.GA31035@tower.DHCP.thefacebook.com>
References: <20190321190327.11813-1-urezki@gmail.com>
 <20190321190327.11813-2-urezki@gmail.com>
 <20190322215413.GA15943@tower.DHCP.thefacebook.com>
 <20190325172010.q343626klaozjtg4@pc636>
 <20190326145153.r7y3llwtvqsg4r2s@pc636>
In-Reply-To: <20190326145153.r7y3llwtvqsg4r2s@pc636>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR20CA0046.namprd20.prod.outlook.com
 (2603:10b6:300:ed::32) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::f95c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 42fe6de5-9b68-4b9b-50ec-08d6b24cf82a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3302;
x-ms-traffictypediagnostic: BYAPR15MB3302:
x-microsoft-antispam-prvs: <BYAPR15MB33025FC963A29D52BFB726D3BE580@BYAPR15MB3302.namprd15.prod.outlook.com>
x-forefront-prvs: 0989A7979C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(39860400002)(136003)(366004)(376002)(189003)(199004)(68736007)(386003)(86362001)(106356001)(105586002)(6506007)(6116002)(52116002)(97736004)(81156014)(81166006)(99286004)(7736002)(1411001)(71190400001)(305945005)(8676002)(316002)(71200400001)(102836004)(6246003)(53936002)(6512007)(6916009)(9686003)(76176011)(33656002)(186003)(476003)(93886005)(446003)(46003)(11346002)(7416002)(486006)(6486002)(8936002)(256004)(229853002)(6436002)(14444005)(54906003)(478600001)(1076003)(2906002)(14454004)(4326008)(25786009)(5660300002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3302;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: MgTCs4xPC43IyA4Ee/bfMhTTYCFmjMiURrS0nwB0jono7vPURLqGvz7BkwDI0cdNFnNx8nwlRRu4jfkIrbadHFiYYAuPGmLn809NKOTR4znALohI5L8N4vL4RKXD3Dh+m4hkct8tecvnkAlR8KEgr/c9YzsvVFUvP5/rmoaCHRYrKCpYocUv/RWRyNvc88P3DSgGVs5v3zI3VhNJFTThwfdzXVedhjLerj8v28Q7/N0A/S7fakXLwvDPMOrSngjyxFzl2ZvuGlxsUI3E79sLKZYq+stC3lRdJ8AqMKPOjwWryEfUFfXJb+QOep8tfftAJhGSyfd7H7i9z308M6dSI8y313AqO3fiFmHHSI+GXMXYJqAtlKuFtmsSS6GoosTEbCbhBAfs89ibOw8P0Ygd4D/sDHHx+YFSEwsWBepMeF8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8EDBAC804E191248898D12C079C7B5CB@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 42fe6de5-9b68-4b9b-50ec-08d6b24cf82a
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Mar 2019 00:41:37.6940
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3302
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-26_16:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 03:51:53PM +0100, Uladzislau Rezki wrote:
> Hello, Roman.
>=20
> > >=20
> > > So, does it mean that this function always returns two following elem=
ents?
> > > Can't it return a single element using the return statement instead?
> > > The second one can be calculated as ->next?
> > >=20
> > Yes, they follow each other and if you return "prev" for example you ca=
n easily
> > refer to next. But you will need to access "next" anyway. I would rathe=
r keep
> > implementation, because it strictly clear what it return when you look =
at this
> > function.
> >=20
> > But if there are some objections and we can simplify, let's discuss :)
> >=20
> > > > +		}
> > > > +	} else {
> > > > +		/*
> > > > +		 * The red-black tree where we try to find VA neighbors
> > > > +		 * before merging or inserting is empty, i.e. it means
> > > > +		 * there is no free vmap space. Normally it does not
> > > > +		 * happen but we handle this case anyway.
> > > > +		 */
> > > > +		*prev =3D *next =3D &free_vmap_area_list;
> > >=20
> > > And for example, return NULL in this case.
> > >=20
> > Then we will need to check in the __merge_or_add_vmap_area() that
> > next/prev are not NULL and not head. But i do not like current implemen=
tation
> > as well, since it is hardcoded to specific list head.
> >=20
> Like you said, it is more clever to return only one element, for example =
next.
> After that just simply access to the previous one. If nothing is found re=
turn
> NULL.
>=20
> static inline struct list_head *
> __get_va_next_sibling(struct rb_node *parent, struct rb_node **link)
> {
> 	struct list_head *list;
>=20
> 	if (likely(parent)) {
> 		list =3D &rb_entry(parent, struct vmap_area, rb_node)->list;
> 		return (&parent->rb_right =3D=3D link ? list->next:list);
> 	}
>=20
> 	/*
> 	 * The red-black tree where we try to find VA neighbors
> 	 * before merging or inserting is empty, i.e. it means
> 	 * there is no free vmap space. Normally it does not
> 	 * happen but we handle this case anyway.
> 	 */
> 	return NULL;
> }
> ...
> static inline void
> __merge_or_add_vmap_area(struct vmap_area *va,
> 	struct rb_root *root, struct list_head *head)
> {
> ...
> 	/*
> 	 * Get next node of VA to check if merging can be done.
> 	 */
> 	next =3D __get_va_next_sibling(parent, link);
> 	if (unlikely(next =3D=3D NULL))
> 		goto insert;
> ...
> }
>=20
> Agree with your point and comment.

Hello, Uladzislau!

Yeah, the version above looks much simpler!
Looking forward for the next version of the patchset.

Thanks!

