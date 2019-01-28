Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BADFC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:02:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC1422148E
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 21:02:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="d+upwjrd";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="fSm5Qi/r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC1422148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5350E8E0003; Mon, 28 Jan 2019 16:02:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6578E0001; Mon, 28 Jan 2019 16:02:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ACFF8E0003; Mon, 28 Jan 2019 16:02:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5EB8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 16:02:23 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id j3so13604648itf.5
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 13:02:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=4EFp/ANjoy+X+5A6stOZtw01ZM7EYQmKwj9Nv6P/vcc=;
        b=LXCkf/o8K8lF3d6Mzih5AxMPD1qpZlS414Sn7ZS9KsPbs4ENlLZUSh9+WnuzyQVBqy
         DCkDp0Tbx/O5YVfXfkudYUrZltn4FebxV4jG8Mw16du6uD2aP+HjPGV3DBxufajDiICy
         sDHPMBqcrMydCMnAWV6mJpZZpdprQS0hOBywo/e5YX/X2x4Igppul9ADLBkU5Q7rBgtG
         2j1vQ0t8VyjUhDnxj8GxEaeTBnT+im06ePdHp8pqHV8Y9sA1aCJSVjX3h2x2lC7pc8ft
         yDZhODv1KEn9Z5gtGCnoBh2SNrDKeJrqRjm0WkY/Zp7/0hcTxT0sCInXVqOgpP4YOwGX
         RGGA==
X-Gm-Message-State: AJcUukchtb6rgEPvEhNPc3Llc9TBopfpp6CXQr6yrJAkNnTxdeADE0rf
	2vX+oVV6qjBi/9Unk7Tzu7YJTLKSjTMgNOFcruLnXog64QZ2S+UiVwyXVjt6Ae8V5LWGRGgznEj
	PrTaFNv6eY6B6F/LY1H9AXdpTFgm62PHl126DR8qZh7n/UprM48pIsToIqyMUWT8oGg==
X-Received: by 2002:a05:660c:1cc:: with SMTP id s12mr10615070itk.33.1548709342653;
        Mon, 28 Jan 2019 13:02:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7OAy7liYj91RorDmOEt3EqA3v58BvI7C1ILBclmSUWQzgIqyAdMEA3M7c/Ai7yyRCi/MCE
X-Received: by 2002:a05:660c:1cc:: with SMTP id s12mr10614963itk.33.1548709339939;
        Mon, 28 Jan 2019 13:02:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548709339; cv=none;
        d=google.com; s=arc-20160816;
        b=cEDdBIhUzWJMFO/IyVx+C3/zE50AleFwvi+M8w+ZpXMt9OeSPOfUeFCZyQrnY7IBYb
         7ZfN6OflWDKLh6UMS4MsPk8ynTKzBhW4J9FkXYQDWFiS6OKXGTskcTx+4DIH+VWtML/Z
         eDrc9Q+mPfmdeEJWSYmuib734VFmAcdOyNJ0GBEVmpA4h7EVcXIIhwWOQq+IhWwlmJCt
         jva5P+p8nLfnx19pS4b5jBeiduFCxb+FgP6tqbFmYR3UYcaM0V5og11qXeYQLj6GOpEL
         RI/Z4KwTDDAENJpmDBr67U9Ys6kPXeNGS/Mn5bhhG++uzsfg+21I2kixiRqn04DuryVV
         XgVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=4EFp/ANjoy+X+5A6stOZtw01ZM7EYQmKwj9Nv6P/vcc=;
        b=Wb7GuRVLbtaUrO/ttQrqqUWfieVfxMJtTH+FJ2trSxfIteI1IjPk7a3AIYqCo6SdU4
         yLiXeW1zZDRVyEMFlVX/Vj5OURX5Pg/fmnHY54Hd739zLsVXPp9fx9s5Bw1iyjhH6iC0
         yHk2IRSkDfilCN2kzcFUIZ/ylc28nvdV01o9IuSbace0KINb5wz3jb7oefVUOe3CGrhk
         +r+uFxPpsO8ZRxJXqBIrEuVLJ6DuaYImK+7UcRIB0qDfqx1G8yr1czj+1d2OypY4Ny3/
         miOl+CNx+bQVtR8Q5z1yMjUuS9O97uzV+j/mcib0o2bF3l52j4SejGZYV+j96XsPUIfh
         dchQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d+upwjrd;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="fSm5Qi/r";
       spf=pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79316e96ce=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n13si557999iop.12.2019.01.28.13.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 13:02:19 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d+upwjrd;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="fSm5Qi/r";
       spf=pass (google.com: domain of prvs=79316e96ce=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79316e96ce=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0SKwDIF029913;
	Mon, 28 Jan 2019 13:02:14 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=4EFp/ANjoy+X+5A6stOZtw01ZM7EYQmKwj9Nv6P/vcc=;
 b=d+upwjrdcL9prk6gFTG3I7gC38CFFmtNhVRgdg8ASiOq76+bfXIQ3qyMcaRPc/yUrDiP
 QOI1xgnl6oOWvDvvJ2aXts8pT+PBwkvYOk5Gg81oovioRZ0suW8wQEzdz651wQTKqzjc
 3qSC7PR2vJ5UM3hyhl9t/MrABDBMxvK8YK8= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qa5xc8vyf-17
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 28 Jan 2019 13:02:14 -0800
Received: from frc-hub06.TheFacebook.com (2620:10d:c021:18::176) by
 frc-hub02.TheFacebook.com (2620:10d:c021:18::172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 28 Jan 2019 13:00:40 -0800
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.76) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Mon, 28 Jan 2019 13:00:40 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4EFp/ANjoy+X+5A6stOZtw01ZM7EYQmKwj9Nv6P/vcc=;
 b=fSm5Qi/rg6UjzlFgVkaI/StCdsqyKHkythobN6PMO4DABcezcdR+LDng0JQTzJppz1DGRPcI9v3o2MNWj7DbvFWJMZG5eh4a9QT46OnDXchsigjAvPJJk9dcQGwWwXB1PWx+iIKL1oUnVwz9NLi5b2HVkYea5zAFc+/RZZUQfs4=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2869.namprd15.prod.outlook.com (20.178.206.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1558.16; Mon, 28 Jan 2019 21:00:38 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::7459:36fe:91f2:8b8a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::7459:36fe:91f2:8b8a%6]) with mapi id 15.20.1558.023; Mon, 28 Jan 2019
 21:00:38 +0000
From: Roman Gushchin <guro@fb.com>
To: Chris Down <chris@chrisdown.name>
CC: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        Michal Hocko <mhocko@kernel.org>, Tejun Heo
	<tj@kernel.org>,
        Dennis Zhou <dennis@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: Proportional memory.{low,min} reclaim
Thread-Topic: [PATCH] mm: Proportional memory.{low,min} reclaim
Thread-Index: AQHUs4Zt38UF96mTm0amM4LuPUpLpqXFMfgA
Date: Mon, 28 Jan 2019 21:00:38 +0000
Message-ID: <20190128210031.GA31446@castle.DHCP.thefacebook.com>
References: <20190124014455.GA6396@chrisdown.name>
In-Reply-To: <20190124014455.GA6396@chrisdown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MW2PR16CA0008.namprd16.prod.outlook.com (2603:10b6:907::21)
 To BYAPR15MB2631.namprd15.prod.outlook.com (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:d043]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2869;20:R+ksrD8yuC5joIhP3mp+ot09aKGdsUQZp+KO6sp8bqZaaab6DQFifFLdrwhIrb6S2TTqSc54e4112/RwvaO3FaMXwO3ItV92qxhN/X1AcakcbwpCQHEO4iRljXLtrkypQZjU6EpR7DIhUBvYNpg/bU/joXDHV0qz7lXlyYit8wU=
x-ms-office365-filtering-correlation-id: 92c73a0a-ac40-44ef-217e-08d68563a7c6
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2869;
x-ms-traffictypediagnostic: BYAPR15MB2869:
x-microsoft-antispam-prvs: <BYAPR15MB28699530BDAE1F2B59F36155BE960@BYAPR15MB2869.namprd15.prod.outlook.com>
x-forefront-prvs: 0931CB1479
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(366004)(346002)(136003)(39860400002)(189003)(199004)(76176011)(446003)(476003)(52116002)(14444005)(256004)(81166006)(4326008)(386003)(6436002)(53946003)(6506007)(86362001)(30864003)(11346002)(966005)(6306002)(81156014)(102836004)(6916009)(46003)(6512007)(9686003)(486006)(8676002)(478600001)(14454004)(106356001)(25786009)(33896004)(229853002)(2906002)(186003)(6486002)(6246003)(99286004)(7736002)(6116002)(316002)(105586002)(71200400001)(71190400001)(97736004)(8936002)(305945005)(33656002)(54906003)(68736007)(1076003)(53936002)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2869;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: QZoP5nuJ4Ze+9IHF08qOtwMbiJ/GDA+k5f4U7bp5S6fjIktsq0F9bW1c3KUE4Nu5x94BHXOl6FdNaGQo6m3JBRLrgpRQXm7Isa0NKtHQ3WkPezstKWWTD0u4S25Tf08A+Fd+OB5A+b+v9PJSPQpkms3SImSyyC6etDSG3bKBb+2DQiuFfjptw9RlCnzzZASXvgZv0EeLghD+tYPuNZbNJ7Oqw+8r/1jumje++VYIA6Q1F9lJn3tULnJAntAmDzKjUW5BqkmokNCZgLN4pD1zUwl3GdnMXq9Mnid61VkmBEGwBzGVgbN4GUXVdcgGnkRCym65cUQFZcUPhL4PrAft2sKwhJZGUIKl+M63QjB5TwheyJv/5nO+5fuQfyyiIzoyTNuf2aXvbbSP+2xMtm9IDV7+PrKgciXtr8WrP5db/os=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B729CDFF7C692D4087E527764FF2A605@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 92c73a0a-ac40-44ef-217e-08d68563a7c6
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jan 2019 21:00:37.4034
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2869
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-28_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2019 at 08:44:55PM -0500, Chris Down wrote:
> cgroup v2 introduces two memory protection thresholds: memory.low
> (best-effort) and memory.min (hard protection). While they generally do
> what they say on the tin, there is a limitation in their implementation
> that makes them difficult to use effectively: that cliff behaviour often
> manifests when they become eligible for reclaim. This patch implements
> more intuitive and usable behaviour, where we gradually mount more
> reclaim pressure as cgroups further and further exceed their protection
> thresholds.
>=20
> This cliff edge behaviour happens because we only choose whether or not
> to reclaim based on whether the memcg is within its protection limits
> (see the use of mem_cgroup_protected in shrink_node), but we don't vary
> our reclaim behaviour based on this information. Imagine the following
> timeline, with the numbers the lruvec size in this zone:
>=20
> 1. memory.low=3D1000000, memory.current=3D999999. 0 pages may be scanned.
> 2. memory.low=3D1000000, memory.current=3D1000000. 0 pages may be scanned=
.
> 3. memory.low=3D1000000, memory.current=3D1000001. 1000001* pages may be
>    scanned. (?!)
>=20
> * Of course, we won't usually scan all available pages in the zone even
>   without this patch because of scan control priority, over-reclaim
>   protection, etc. However, as shown by the tests at the end, these
>   techniques don't sufficiently throttle such an extreme change in
>   input, so cliff-like behaviour isn't really averted by their existence
>   alone.
>=20
> Here's an example of how this plays out in practice. At Facebook, we are
> trying to protect various workloads from "system" software, like
> configuration management tools, metric collectors, etc (see this[0] case
> study). In order to find a suitable memory.low value, we start by
> determining the expected memory range within which the workload will be
> comfortable operating. This isn't an exact science -- memory usage
> deemed "comfortable" will vary over time due to user behaviour,
> differences in composition of work, etc, etc. As such we need to
> ballpark memory.low, but doing this is currently problematic:
>=20
> 1. If we end up setting it too low for the workload, it won't have *any*
>    effect (see discussion above). The group will receive the full weight
>    of reclaim and won't have any priority while competing with the less
>    important system software, as if we had no memory.low configured at
>    all.
>=20
> 2. Because of this behaviour, we end up erring on the side of setting it
>    too high, such that the comfort range is reliably covered. However,
>    protected memory is completely unavailable to the rest of the system,
>    so we might cause undue memory and IO pressure there when we *know*
>    we have some elasticity in the workload.
>=20
> 3. Even if we get the value totally right, smack in the middle of the
>    comfort zone, we get extreme jumps between no pressure and full
>    pressure that cause unpredictable pressure spikes in the workload due
>    to the current binary reclaim behaviour.
>=20
> With this patch, we can set it to our ballpark estimation without too
> much worry. Any undesirable behaviour, such as too much or too little
> reclaim pressure on the workload or system will be proportional to how
> far our estimation is off. This means we can set memory.low much more
> conservatively and thus waste less resources *without* the risk of the
> workload falling off a cliff if we overshoot.
>=20
> As a more abstract technical description, this unintuitive behaviour
> results in having to give high-priority workloads a large protection
> buffer on top of their expected usage to function reliably, as otherwise
> we have abrupt periods of dramatically increased memory pressure which
> hamper performance.  Having to set these thresholds so high wastes
> resources and generally works against the principle of work
> conservation. In addition, having proportional memory reclaim behaviour
> has other benefits. Most notably, before this patch it's basically
> mandatory to set memory.low to a higher than desirable value because
> otherwise as soon as you exceed memory.low, all protection is lost, and
> all pages are eligible to scan again. By contrast, having a gradual ramp
> in reclaim pressure means that you now still get some protection when
> thresholds are exceeded, which means that one can now be more
> comfortable setting memory.low to lower values without worrying that all
> protection will be lost. This is important because workingset size is
> really hard to know exactly, especially with variable workloads, so at
> least getting *some* protection if your workingset size grows larger
> than you expect increases user confidence in setting memory.low without
> a huge buffer on top being needed.
>=20
> Thanks a lot to Johannes Weiner and Tejun Heo for their advice and
> assistance in thinking about how to make this work better.
>=20
> In testing these changes, I intended to verify that:
>=20
> 1. Changes in page scanning become gradual and proportional instead of
>    binary.
>=20
>    To test this, I experimented stepping further and further down
>    memory.low protection on a workload that floats around 19G workingset
>    when under memory.low protection, watching page scan rates for the
>    workload cgroup:
>=20
>    +------------+-----------------+--------------------+--------------+
>    | memory.low | test (pgscan/s) | control (pgscan/s) | % of control |
>    +------------+-----------------+--------------------+--------------+
>    |        21G |               0 |                  0 | N/A          |
>    |        17G |             867 |               3799 | 23%          |
>    |        12G |            1203 |               3543 | 34%          |
>    |         8G |            2534 |               3979 | 64%          |
>    |         4G |            3980 |               4147 | 96%          |
>    |          0 |            3799 |               3980 | 95%          |
>    +------------+-----------------+--------------------+--------------+
>=20
>    As you can see, the test kernel (with a kernel containing this patch)
>    ramps up page scanning significantly more gradually than the control
>    kernel (without this patch).
>=20
> 2. More gradual ramp up in reclaim aggression doesn't result in
>    premature OOMs.
>=20
>    To test this, I wrote a script that slowly increments the number of
>    pages held by stress(1)'s --vm-keep mode until a production system
>    entered severe overall memory contention. This script runs in a
>    highly protected slice taking up the majority of available system
>    memory. Watching vmstat revealed that page scanning continued
>    essentially nominally between test and control, without causing
>    forward reclaim progress to become arrested.
>=20
> [0]: https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__facebookmicro=
sites.github.io_cgroup2_docs_overview.html-23case-2Dstudy-2Dthe-2Dfbtax2-2D=
project&d=3DDwIBAg&c=3D5VD0RTtNlTh3ycd41b3MUw&r=3Di6WobKxbeG3slzHSIOxTVtYIJ=
w7qjCE6S0spDTKL-J4&m=3DMo0govWR0-jFjgSx4DTFpIgKfHsLPb-67tLa_ANbtX0&s=3D6Qtu=
D2I9uTW8eIgzRdVj1uHtwCMj4mYa6wOxkc1bTm0&e=3D
>=20
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Dennis Zhou <dennis@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: cgroups@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: kernel-team@fb.com
> ---
>  Documentation/admin-guide/cgroup-v2.rst | 20 +++++--
>  include/linux/memcontrol.h              | 17 ++++++
>  mm/memcontrol.c                         |  5 ++
>  mm/vmscan.c                             | 76 +++++++++++++++++++++++--
>  4 files changed, 106 insertions(+), 12 deletions(-)
>=20
> diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admi=
n-guide/cgroup-v2.rst
> index 7bf3f129c68b..8ed408166890 100644
> --- a/Documentation/admin-guide/cgroup-v2.rst
> +++ b/Documentation/admin-guide/cgroup-v2.rst
> @@ -606,8 +606,8 @@ on an IO device and is an example of this type.
>  Protections
>  -----------
> =20
> -A cgroup is protected to be allocated upto the configured amount of
> -the resource if the usages of all its ancestors are under their
> +A cgroup is protected upto the configured amount of the resource
> +as long as the usages of all its ancestors are under their
>  protected levels.  Protections can be hard guarantees or best effort
>  soft boundaries.  Protections can also be over-committed in which case
>  only upto the amount available to the parent is protected among
> @@ -1020,7 +1020,10 @@ PAGE_SIZE multiple when read back.
>  	is within its effective min boundary, the cgroup's memory
>  	won't be reclaimed under any conditions. If there is no
>  	unprotected reclaimable memory available, OOM killer
> -	is invoked.
> +	is invoked. Above the effective min boundary (or
> +	effective low boundary if it is higher), pages are reclaimed
> +	proportionally to the overage, reducing reclaim pressure for
> +	smaller overages.
> =20
>         Effective min boundary is limited by memory.min values of
>  	all ancestor cgroups. If there is memory.min overcommitment
> @@ -1042,7 +1045,10 @@ PAGE_SIZE multiple when read back.
>  	Best-effort memory protection.  If the memory usage of a
>  	cgroup is within its effective low boundary, the cgroup's
>  	memory won't be reclaimed unless memory can be reclaimed
> -	from unprotected cgroups.
> +	from unprotected cgroups.  Above the effective low boundary (or
> +	effective min boundary if it is higher), pages are reclaimed
> +	proportionally to the overage, reducing reclaim pressure for
> +	smaller overages.
> =20
>  	Effective low boundary is limited by memory.low values of
>  	all ancestor cgroups. If there is memory.low overcommitment
> @@ -2283,8 +2289,10 @@ system performance due to overreclaim, to the poin=
t where the feature
>  becomes self-defeating.
> =20
>  The memory.low boundary on the other hand is a top-down allocated
> -reserve.  A cgroup enjoys reclaim protection when it's within its low,
> -which makes delegation of subtrees possible.
> +reserve.  A cgroup enjoys reclaim protection when it's within its
> +effective low, which makes delegation of subtrees possible. It also
> +enjoys having reclaim pressure proportional to its overage when
> +above its effective low.
> =20
>  The original high boundary, the hard limit, is defined as a strict
>  limit that can not budge, even if the OOM killer has to be called.
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b0eb29ea0d9c..290cfbfd60cd 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -333,6 +333,11 @@ static inline bool mem_cgroup_disabled(void)
>  	return !cgroup_subsys_enabled(memory_cgrp_subsys);
>  }
> =20
> +static inline unsigned long mem_cgroup_protection(struct mem_cgroup *mem=
cg)
> +{
> +	return max(READ_ONCE(memcg->memory.emin), READ_ONCE(memcg->memory.elow)=
);
> +}
> +
>  enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
>  						struct mem_cgroup *memcg);
> =20
> @@ -526,6 +531,8 @@ void mem_cgroup_handle_over_high(void);
> =20
>  unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
> =20
> +unsigned long mem_cgroup_size(struct mem_cgroup *memcg);
> +
>  void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
>  				struct task_struct *p);
> =20
> @@ -819,6 +826,11 @@ static inline void memcg_memory_event_mm(struct mm_s=
truct *mm,
>  {
>  }
> =20
> +static inline unsigned long mem_cgroup_protection(struct mem_cgroup *mem=
cg)
> +{
> +	return 0;
> +}
> +
>  static inline enum mem_cgroup_protection mem_cgroup_protected(
>  	struct mem_cgroup *root, struct mem_cgroup *memcg)
>  {
> @@ -971,6 +983,11 @@ static inline unsigned long mem_cgroup_get_max(struc=
t mem_cgroup *memcg)
>  	return 0;
>  }
> =20
> +static inline unsigned long mem_cgroup_size(struct mem_cgroup *memcg)
> +{
> +	return 0;
> +}
> +
>  static inline void
>  mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struc=
t *p)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 18f4aefbe0bf..1d2b2aaf124d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1377,6 +1377,11 @@ unsigned long mem_cgroup_get_max(struct mem_cgroup=
 *memcg)
>  	return max;
>  }
> =20
> +unsigned long mem_cgroup_size(struct mem_cgroup *memcg)
> +{
> +	return page_counter_read(&memcg->memory);
> +}
> +
>  static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp=
_mask,
>  				     int order)
>  {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a714c4f800e9..638c3655dc4b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2445,17 +2445,74 @@ static void get_scan_count(struct lruvec *lruvec,=
 struct mem_cgroup *memcg,
>  	*lru_pages =3D 0;
>  	for_each_evictable_lru(lru) {
>  		int file =3D is_file_lru(lru);
> -		unsigned long size;
> +		unsigned long lruvec_size;
>  		unsigned long scan;
> +		unsigned long protection;
> +
> +		lruvec_size =3D lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
> +		protection =3D mem_cgroup_protection(memcg);
> +
> +		if (protection > 0) {
> +			/*
> +			 * Scale a cgroup's reclaim pressure by proportioning its current
> +			 * usage to its memory.low or memory.min setting.
> +			 *
> +			 * This is important, as otherwise scanning aggression becomes
> +			 * extremely binary -- from nothing as we approach the memory
> +			 * protection threshold, to totally nominal as we exceed it. This
> +			 * results in requiring setting extremely liberal protection
> +			 * thresholds. It also means we simply get no protection at all if
> +			 * we set it too low, which is not ideal.
> +			 */
> +			unsigned long cgroup_size =3D mem_cgroup_size(memcg);
> +			unsigned long baseline =3D 0;
> +
> +			/*
> +			 * During the reclaim first pass, we only consider cgroups in
> +			 * excess of their protection setting, but if that doesn't produce
> +			 * free pages, we come back for a second pass where we reclaim from
> +			 * all groups.
> +			 *
> +			 * To maintain fairness in both cases, the first pass targets
> +			 * groups in proportion to their overage, and the second pass
> +			 * targets groups in proportion to their protection utilization.
> +			 *
> +			 * So on the first pass, a group whose size is 130% of its
> +			 * protection will be targeted at 30% of its size. On the second
> +			 * pass, a group whose size is at 40% of its protection will be
> +			 * targeted at 40% of its size.
> +			 */
> +			if (!sc->memcg_low_reclaim)
> +				baseline =3D lruvec_size;
> +			scan =3D lruvec_size * cgroup_size / protection - baseline;

Hm, it looks a bit suspicious to me.

Let's say memory.low =3D 3G, memory.min =3D 1G and memory.current =3D 2G.
cgroup_size / protection =3D=3D 1, so scan doesn't depend on memory.min at =
all.

So, we need to look directly at memory.emin in memcg_low_reclaim case, and
ignore memory.(e)low.

> +
> +			/*
> +			 * Don't allow the scan target to exceed the lruvec size, which
> +			 * otherwise could happen if we have >200% overage in the normal
> +			 * case, or >100% overage when sc->memcg_low_reclaim is set.
> +			 *
> +			 * This is important because other cgroups without memory.low have
> +			 * their scan target initially set to their lruvec size, so
> +			 * allowing values >100% of the lruvec size here could result in
> +			 * penalising cgroups with memory.low set even *more* than their
> +			 * peers in some cases in the case of large overages.
> +			 *
> +			 * Also, minimally target SWAP_CLUSTER_MAX pages to keep reclaim
> +			 * moving forwards.
> +			 */
> +			scan =3D clamp(scan, SWAP_CLUSTER_MAX, lruvec_size);

Idk, how much sense does it have to make it larger than SWAP_CLUSTER_MAX,
given that it will become 0 on default (and almost any other) priority.


> +		} else {
> +			scan =3D lruvec_size;
> +		}
> +
> +		scan >>=3D sc->priority;
> =20
> -		size =3D lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
> -		scan =3D size >> sc->priority;
>  		/*
>  		 * If the cgroup's already been deleted, make sure to
>  		 * scrape out the remaining cache.
>  		 */
>  		if (!scan && !mem_cgroup_online(memcg))
> -			scan =3D min(size, SWAP_CLUSTER_MAX);
> +			scan =3D min(lruvec_size, SWAP_CLUSTER_MAX);
> =20
>  		switch (scan_balance) {
>  		case SCAN_EQUAL:
> @@ -2475,7 +2532,7 @@ static void get_scan_count(struct lruvec *lruvec, s=
truct mem_cgroup *memcg,
>  		case SCAN_ANON:
>  			/* Scan one type exclusively */
>  			if ((scan_balance =3D=3D SCAN_FILE) !=3D file) {
> -				size =3D 0;
> +				lruvec_size =3D 0;
>  				scan =3D 0;
>  			}
>  			break;
> @@ -2484,7 +2541,7 @@ static void get_scan_count(struct lruvec *lruvec, s=
truct mem_cgroup *memcg,
>  			BUG();
>  		}
> =20
> -		*lru_pages +=3D size;
> +		*lru_pages +=3D lruvec_size;
>  		nr[lru] =3D scan;
>  	}
>  }
> @@ -2745,6 +2802,13 @@ static bool shrink_node(pg_data_t *pgdat, struct s=
can_control *sc)
>  				memcg_memory_event(memcg, MEMCG_LOW);
>  				break;
>  			case MEMCG_PROT_NONE:
> +				/*
> +				 * All protection thresholds breached.

Or never set.

> We may
> +				 * still choose to vary the scan pressure
> +				 * applied based on by how much the cgroup in
> +				 * question has exceeded its protection
> +				 * thresholds (see get_scan_count).
> +				 */
>  				break;
>  			}
> =20
> --=20
> 2.20.1
>=20

