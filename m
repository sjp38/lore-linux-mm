Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5973BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:27:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8596206BA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:27:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="mUrZ9oom";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="gZBqLNpn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8596206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C0228E0004; Mon, 11 Mar 2019 15:27:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 770A08E0002; Mon, 11 Mar 2019 15:27:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 610AB8E0004; Mon, 11 Mar 2019 15:27:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3829A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:27:36 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p40so51697qtb.10
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:27:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=PuBmJknRoHywFqubd92sKBFm6vU1s5NvgXq1XGF/Vwo=;
        b=n9c06BtWtmhjsJDBcuvEegVfY4I3LXx6ix2bYNu2SJMKL6vIwm56zgaEFTP5LcaKJ0
         c5gKzHoLcrOJFvZWFj6c6HhydRwVbi/Ez9/H0CExbKRB+/52pDDNgTLyW5E0bwRIOY2J
         App4RDZYZwA6hsMK39kFzaAGvHWcdtQt5RKFpMeAeW5PSqLoRxDMFaAor+8U8UZcTzSe
         sfl/Qe3PtNbAt5Ct0GjaPCe2pfM6NuLQaNm0zZOQD6thwFaZJZ92SidyeXh/ySomH3bz
         1k9urRzO2hcrRJxaa5NWC+jl2ChmR1n0V5YpqFYexJ+PiJn5bv21VeBYWWkM8ySveYdr
         3tjA==
X-Gm-Message-State: APjAAAWaTl8UxBVqsrClLWZsn/NkHbrL0di5FMhcRAwug0m76dRwBQTA
	Kki1+hX+zbE86iQlb3ZAj2K87WL0CDWjoj6MIbMfzPiMsrEUSstraSvG7z1bCi2vydY2n+ns7mN
	jDpWisBy4v/T+zdQb0fDe01IZ560EOFzYwdQpu09yOw1YmYyfVB+skG5TgmOgrpYM7Q==
X-Received: by 2002:a37:c584:: with SMTP id k4mr3086506qkl.130.1552332455862;
        Mon, 11 Mar 2019 12:27:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvp4WMVPhQ+WLouHnRfUvBvhHsjwI1xDIN6TPbgVHRyxpgpL90kMtMoKBkwBA43ZaKSCgI
X-Received: by 2002:a37:c584:: with SMTP id k4mr3086462qkl.130.1552332455024;
        Mon, 11 Mar 2019 12:27:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552332455; cv=none;
        d=google.com; s=arc-20160816;
        b=rZWQc2TEBmddX69B2/I0D1BDks/RzCL/OMBAXdIYQf/4zPo3ifYgYguY/uYNgliIxd
         n7Jg36Ef0b3gW+TmnAhbIvm2kH4xLXS3ak19A77h838C5RBAbLy6XUeLrCUMYx2Vb0f1
         kpAEprMXPiBMP+gy+oluWDae5BYa/107PahjQXWDl9E6S0QMsGtm+BL998oqxrri4LD9
         C/KgAJ5JbmucVN4ns4k0+Mjd9Yp1R7rXEv1pis6hLhBZjFBJZ3h5ylwLMq0g1OfuhYs3
         0BV/uzCsw0YrydjI7b0BsJSm64zGDWs+y1syB5f9/yTKXlwnwpDPGpaSMgR/0dQc0yv3
         Nclw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=PuBmJknRoHywFqubd92sKBFm6vU1s5NvgXq1XGF/Vwo=;
        b=btKMaaKv6y3rP1aPXhPzCA29hi/z3R+Zi0EfvrXDI2w0uVzlNXTb7hE7CFz/eHF+bv
         62svmzfzTv1j3SUZpmrAaBLbkzw5e+qyWzlJ0sUEPr3giqvxs1OXpMOr8VLcTVfeGJiu
         nLAhkGUuf26SvmSxSnvaVqzay4wAGPYovyRJfrJhTjcq3qfLWZMCokBjZOuS0uviZgp/
         Faodgvzo6nRtoOUg/7N05tuZlOun6ANqjGA7Qqnm3Sv3UD6aVvDB+Z+Lt8WiE5ppasEM
         IU/ys7lAYAXvR1eVsFkvgnlxVaImh8KwfU7ARpC+pmFkOQ5sHLnrqU2x6ob3JKWS35fX
         pBGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mUrZ9oom;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=gZBqLNpn;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t5si3919023qta.213.2019.03.11.12.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:27:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=mUrZ9oom;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=gZBqLNpn;
       spf=pass (google.com: domain of prvs=897363b8f0=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=897363b8f0=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2BJMVim019506;
	Mon, 11 Mar 2019 12:27:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=PuBmJknRoHywFqubd92sKBFm6vU1s5NvgXq1XGF/Vwo=;
 b=mUrZ9oomr7/f7cVOyeMKIXzLrvOo7t4XGFySgu82RAWJspV5MftG3XQblXd97sABC7nh
 ZUNS7ibVNkxe7tzoN6XvHUvwMqifGrMiqnzWelcKFGpeI7zUYR2PKWy6Faq8FzPKLCLy
 3Iy7dHRwv42Zjllh19HvAycgezD4kSSXe+M= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2r5vc4rc51-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 11 Mar 2019 12:27:18 -0700
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-hub02.TheFacebook.com (2620:10d:c021:18::172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 11 Mar 2019 12:27:17 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 11 Mar 2019 12:27:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PuBmJknRoHywFqubd92sKBFm6vU1s5NvgXq1XGF/Vwo=;
 b=gZBqLNpn+riBddCVM0TiUbZERiAkgE7Sb2cfRhbWHAevVbg+MNW/lirOMu4CJeRuyqvFe2hli244puJRlRUjb414vsWFBXcFBch9iUZEofvpFwO55fhaZ13WVc3+myFX4RT78nmCuJOE3M9oYBK9EMj7FvBZ3Xk6d2pQuL45Hyo=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2966.namprd15.prod.outlook.com (20.178.237.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.16; Mon, 11 Mar 2019 19:27:08 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Mon, 11 Mar 2019
 19:27:08 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: Roman Gushchin <guroan@gmail.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Kernel Team <Kernel-team@fb.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Tejun Heo
	<tj@kernel.org>, Rik van Riel <riel@surriel.com>,
        Michal Hocko
	<mhocko@kernel.org>
Subject: Re: [PATCH 5/5] mm: spill memcg percpu stats and events before
 releasing
Thread-Topic: [PATCH 5/5] mm: spill memcg percpu stats and events before
 releasing
Thread-Index: AQHU1TmwoulMxqBT9U+dUzzlGgn+iaYGuAGAgAAeXAA=
Date: Mon, 11 Mar 2019 19:27:08 +0000
Message-ID: <20190311192702.GA6622@tower.DHCP.thefacebook.com>
References: <20190307230033.31975-1-guro@fb.com>
 <20190307230033.31975-6-guro@fb.com> <20190311173825.GE10823@cmpxchg.org>
In-Reply-To: <20190311173825.GE10823@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR21CA0034.namprd21.prod.outlook.com
 (2603:10b6:300:129::20) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:b487]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a6654dd5-30c3-4a13-2ba5-08d6a6578d09
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2966;
x-ms-traffictypediagnostic: BYAPR15MB2966:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2966;20:uVdq8nnCJU/DKhoO42G+rN8y75eaJX0WlHNcmrNkKifUg4J73FP1juqcyt3FgnrKCFyVSglXVzB/uh9RpaWUBKStwQYFOpJKxWKdxTcbpXBRE/DytsPXQAWSKL1Fq2c+MunbAOGaccLM3O+VCc9CE8GFNltSy52oqtgnjp6f99o=
x-microsoft-antispam-prvs: <BYAPR15MB296680A644850C258224DF69BE480@BYAPR15MB2966.namprd15.prod.outlook.com>
x-forefront-prvs: 09730BD177
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(366004)(376002)(346002)(39860400002)(189003)(199004)(25786009)(14454004)(52116002)(6486002)(102836004)(229853002)(6246003)(4326008)(105586002)(99286004)(33656002)(68736007)(14444005)(5660300002)(256004)(106356001)(86362001)(6512007)(6436002)(53936002)(54906003)(478600001)(316002)(9686003)(6116002)(386003)(305945005)(7736002)(76176011)(186003)(6506007)(46003)(446003)(81166006)(8936002)(476003)(11346002)(81156014)(6916009)(8676002)(1076003)(97736004)(71200400001)(71190400001)(2906002)(486006);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2966;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: U1xSphB1K7QRdUxX5/itZYhwbdVyAA7iTiUs8xtlRBbRf+v6/Rb4Ee8s4wMgre2Dzs+hmuSNPtOIYsdJJBJVjlQXf9h78mXeifquMrQZpmQ+IpgVlAMhXYFwjYYAZr+kMHjAYIJRNXxU4VBAxw/XNUHRvq7Oy2KSQpdDl08Y8aV2oLHVInBPb4amR32hNl1DLBtdUyHJPZY0RARHI/Mq7DX4ckNKXAkRlrLwJHIXSnC9wpV8iJrm8gnzvCa5Teu27+JbzoBv8c7/Ao+oP/rD2hDrWj0Q8QEkxThF4wcs5O/HOc4uo9z7y5UtsLftoDPu+LZA95cIRi5hBA2AKxxA2sr0wHg2RNezZBpVCG8IqL+bLq2EelYNVT8j/dLcl1fApIUn7p+b3zlraGOM7knzIsf755S725BDRE8SrePX3GY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A8B3421037A6B442A7D3FEE88FE09D90@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a6654dd5-30c3-4a13-2ba5-08d6a6578d09
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Mar 2019 19:27:08.1890
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2966
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-11_14:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 01:38:25PM -0400, Johannes Weiner wrote:
> On Thu, Mar 07, 2019 at 03:00:33PM -0800, Roman Gushchin wrote:
> > Spill percpu stats and events data to corresponding before releasing
> > percpu memory.
> >=20
> > Although per-cpu stats are never exactly precise, dropping them on
> > floor regularly may lead to an accumulation of an error. So, it's
> > safer to sync them before releasing.
> >=20
> > To minimize the number of atomic updates, let's sum all stats/events
> > on all cpus locally, and then make a single update per entry.
> >=20
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > ---
> >  mm/memcontrol.c | 52 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 52 insertions(+)
> >=20
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 18e863890392..b7eb6fac735e 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4612,11 +4612,63 @@ static int mem_cgroup_css_online(struct cgroup_=
subsys_state *css)
> >  	return 0;
> >  }
> > =20
> > +/*
> > + * Spill all per-cpu stats and events into atomics.
> > + * Try to minimize the number of atomic writes by gathering data from
> > + * all cpus locally, and then make one atomic update.
> > + * No locking is required, because no one has an access to
> > + * the offlined percpu data.
> > + */
> > +static void mem_cgroup_spill_offlined_percpu(struct mem_cgroup *memcg)
> > +{
> > +	struct memcg_vmstats_percpu __percpu *vmstats_percpu;
> > +	struct lruvec_stat __percpu *lruvec_stat_cpu;
> > +	struct mem_cgroup_per_node *pn;
> > +	int cpu, i;
> > +	long x;
> > +
> > +	vmstats_percpu =3D memcg->vmstats_percpu_offlined;
> > +
> > +	for (i =3D 0; i < MEMCG_NR_STAT; i++) {
> > +		int nid;
> > +
> > +		x =3D 0;
> > +		for_each_possible_cpu(cpu)
> > +			x +=3D per_cpu(vmstats_percpu->stat[i], cpu);
> > +		if (x)
> > +			atomic_long_add(x, &memcg->vmstats[i]);
> > +
> > +		if (i >=3D NR_VM_NODE_STAT_ITEMS)
> > +			continue;
> > +
> > +		for_each_node(nid) {
> > +			pn =3D mem_cgroup_nodeinfo(memcg, nid);
> > +			lruvec_stat_cpu =3D pn->lruvec_stat_cpu_offlined;
> > +
> > +			x =3D 0;
> > +			for_each_possible_cpu(cpu)
> > +				x +=3D per_cpu(lruvec_stat_cpu->count[i], cpu);
> > +			if (x)
> > +				atomic_long_add(x, &pn->lruvec_stat[i]);
> > +		}
> > +	}
> > +
> > +	for (i =3D 0; i < NR_VM_EVENT_ITEMS; i++) {
> > +		x =3D 0;
> > +		for_each_possible_cpu(cpu)
> > +			x +=3D per_cpu(vmstats_percpu->events[i], cpu);
> > +		if (x)
> > +			atomic_long_add(x, &memcg->vmevents[i]);
> > +	}
>=20
> This looks good, but couldn't this be merged with the cpu offlining?
> It seems to be exactly the same code, except for the nesting of the
> for_each_possible_cpu() iteration here.
>=20
> This could be a function that takes a CPU argument and then iterates
> the cgroups and stat items to collect and spill the counters of that
> specified CPU; offlining would call it once, and this spill code here
> would call it for_each_possible_cpu().
>=20
> We shouldn't need the atomicity of this_cpu_xchg() during hotunplug,
> the scheduler isn't even active on that CPU anymore when it's called.

Good point!
I initially tried to adapt the cpu offlining code, but it didn't work
well: the code became too complex and ugly. But the opposite can be done
easily: mem_cgroup_spill_offlined_percpu() can take a cpumask,
and the cpu offlining code will look like:
	for_each_mem_cgroup(memcg)
		mem_cgroup_spill_offlined_percpu(memcg, cpumask);
I'll master a separate patch.

Thank you!

