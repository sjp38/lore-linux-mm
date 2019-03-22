Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59682C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:29:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECE76218D4
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:29:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="oqlyWlzx";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="itkz/OlX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECE76218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C4F56B0005; Fri, 22 Mar 2019 18:29:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 873D96B0006; Fri, 22 Mar 2019 18:29:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 763356B0007; Fri, 22 Mar 2019 18:29:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 565DB6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:29:24 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id b199so2931503iof.14
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:29:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=LVZZ9MYE5xura6GliRHoliLQrs68t/2NTGwVcpLAMv0=;
        b=iaULq7hi8FVKJ67XO56xxCNemvj9gs9gGf+q5dRZfoJyuH/7LOel6Ibpcgow7PymEV
         r6uS/Of7vj2dH6KM1wOuwXBX6S7KCUZs5nd6WcFNq2iruhLX3Wm7+DG250DdMj2tNXXZ
         1eu/aOwrrgZJddi9pDuQsd+06SIe92IK1HMX+e73HaadPPKh3rV6IWs+g+zMZix9Aw6y
         ygu6fVMTc8Ih82B+jY9IgvfTl66YaHlC5tf6lW3AP+9c0fj6jgapiTaP5jzI63gaLU2k
         tzceZD9EKWs+Wn9DUW2XQhYQXIJgMZ7RZAvGKAa9YhTkrSoSt+419hbDtgAJoNdrqtPw
         82Gg==
X-Gm-Message-State: APjAAAVkOVc/9XmvE8MzI6E1ENTUtZQ9WHuAV42fdv/koB7LKlBDL8D0
	jTDPKDcqnCiA26G5WXbZYLo0+IwrVGEieXULtpCRaln6D4IPJOfZDL7iverfF5U/UXiW8L9Iy/g
	rBSt+sjaFJ5gPOl7VD0+FFnJBQUA31SdbMCXsBpi71COrU3sQW6IcbgsxxLuEuOKXRQ==
X-Received: by 2002:a5e:c249:: with SMTP id w9mr8669114iop.284.1553293764067;
        Fri, 22 Mar 2019 15:29:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPjY67I8AjawUIO531NYtFe1SAWO1PD4I4+YQ0EU6HcRaPxp1l5XLlZ07JbY8coW4Yv6ko
X-Received: by 2002:a5e:c249:: with SMTP id w9mr8669088iop.284.1553293763301;
        Fri, 22 Mar 2019 15:29:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553293763; cv=none;
        d=google.com; s=arc-20160816;
        b=MTgN7y+c5woUXEhNIkkBjhd3OD1yxIR/oT2nvf8cmw3R9XJmrYw5vTfuLF07NHk5Hi
         WfxOrKqlACrbXV/E3DU1V6vgOJPSm+R3xA7nU9VkVickD98zFahh8HI6G25J68pEbARV
         +T9/Or7tFp94kBLPq+WZMvdZjkOoq3geBK1/EcZPJthvS8X2a0w9rD7f2EAwLnooVTyP
         sMwgEJ17laBqTXun+h+NIfmn2l4oOsEnadR3UyLhyy7n1qftI7ZMdmNAnRWW6xxpK3Fa
         h74VYv+Ljy8HyRLeNJC0LXsfP/rYaeA5ONN5b4WSQaUemy9IZ9QHTXHc4+cmc14xIRyM
         /QvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=LVZZ9MYE5xura6GliRHoliLQrs68t/2NTGwVcpLAMv0=;
        b=PtgVg0uvXAodNP1xboZ82AIaAFGy0KI5XqnxqNQrzOMDUmuAS8ExleiylpPUlHMS0E
         gTwS7pXZJB7fazbZ0jFCklvWAk9SldJ7rV9gh3jM8nreC5Ho6oMhtQ5e5Qx7uV+5bzQ+
         ApyKM3umcmI9B8OyB1dZw3skMa2mP9LKCWbZAkOh4kF5E7SLQRdfu5uclnAFvItm5A+E
         fnMQWE/DAvN0chsPxufN7ZXHNR4ZajAGw9++PvBdWRQsrmTkgViuIdlbUW3vW2UHe0d0
         UZaejo95CrU+cW2Qg27syS0qD6z5SQ9BcXnTel1Y8oLRR1ebS4JyzXW7oH8WGIqsQW3u
         0ieg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oqlyWlzx;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="itkz/OlX";
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 65si4287708itw.34.2019.03.22.15.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 15:29:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oqlyWlzx;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="itkz/OlX";
       spf=pass (google.com: domain of prvs=89845e868f=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89845e868f=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2MMTFml029938;
	Fri, 22 Mar 2019 15:29:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=LVZZ9MYE5xura6GliRHoliLQrs68t/2NTGwVcpLAMv0=;
 b=oqlyWlzx30Zam39TmXZBny2dPFPI8ETNIlplGgEv6qRuSQAZO1ct61dgTGeP4IerFBAS
 DJDrbYcJ3+aNAUC2UbGPIB+fD4AXcD/jkcbe9/El/dsu6sWvMY+J7peDFbc4AeDaOdFT
 ctSI+9LzWOTGAT22THjP7cKxWiCzXh3ePcU= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rcy14jap4-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 22 Mar 2019 15:29:18 -0700
Received: from frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) by
 frc-hub01.TheFacebook.com (2620:10d:c021:18::171) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 15:29:17 -0700
Received: from frc-hub06.TheFacebook.com (2620:10d:c021:18::176) by
 frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 22 Mar 2019 15:29:17 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.76) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 22 Mar 2019 15:29:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LVZZ9MYE5xura6GliRHoliLQrs68t/2NTGwVcpLAMv0=;
 b=itkz/OlXUS2iLA77/uM5vNAnxDF4W10HOH+OTMJyg63oCq5bkeXpVSLCK0uSa9WIdX+KRnFA3h6o/MxjdRwexQKGM2p45Zb7Alj8/3T3C9/F3CrVdfBKReqWYg2vHD+6p0dGKIgS4OeVU767HbyWyaVnkZrlsIBCjMM4l4FnCAU=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB3122.namprd15.prod.outlook.com (20.178.222.78) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Fri, 22 Mar 2019 22:29:15 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::adfe:efd3:ae90:1f2a]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::adfe:efd3:ae90:1f2a%4]) with mapi id 15.20.1730.017; Fri, 22 Mar 2019
 22:29:15 +0000
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
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Thread-Topic: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Thread-Index: AQHU4MjBAXhBvPMCI0qZ3+WtTr5x4qYYO8QA
Date: Fri, 22 Mar 2019 22:29:15 +0000
Message-ID: <20190322222907.GA17496@tower.DHCP.thefacebook.com>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
In-Reply-To: <20190322160307.GA3316@chrisdown.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1301CA0022.namprd13.prod.outlook.com
 (2603:10b6:301:29::35) To BN8PR15MB2626.namprd15.prod.outlook.com
 (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3f49]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 812eaab7-ccc8-443e-7c3e-08d6af15d0e0
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BN8PR15MB3122;
x-ms-traffictypediagnostic: BN8PR15MB3122:
x-microsoft-antispam-prvs: <BN8PR15MB31223C89F8CF0476D21C3108BE430@BN8PR15MB3122.namprd15.prod.outlook.com>
x-forefront-prvs: 09840A4839
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(136003)(346002)(39860400002)(396003)(189003)(199004)(256004)(86362001)(33656002)(2906002)(68736007)(7736002)(478600001)(446003)(6246003)(5660300002)(229853002)(99286004)(97736004)(6486002)(8936002)(71200400001)(6916009)(71190400001)(14444005)(106356001)(6436002)(54906003)(476003)(6116002)(6512007)(386003)(14454004)(9686003)(1076003)(4326008)(102836004)(6506007)(25786009)(53936002)(186003)(8676002)(105586002)(11346002)(486006)(76176011)(81156014)(81166006)(52116002)(316002)(46003)(305945005);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB3122;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: OrfChOgj+LENa5SgZasDzVA8n37DwctB7LPYKpezDPfYsIn+njjPvzhaNIrKvRDZQ2d8fb5klSWUBjU6ogcI6Olaawm/Z4Yl0vOuM2vsGcVVLMi+eDv08dr0bAE0L6vEibqgUebkCfIVcBRtwIY2RQm8z/Z7iuF0TBpJhU5WWSBQW+nJV7r03JTmZ3bV13LWK2r9Xs2vDdmvY6HYcpb1jY9u+xgWIVKsxN1U7+dmpHNjLcLBtN9fsemdInc9CXmNwIBs7yalOvc+Sn2fl4OMTCvFUHDg1y+wKwcKbyCJm5c0Ms+y+3R76D6GZUTkUdiJSv07lJqSm29x7sqxFHrdhnY1HoG7oiiy2NvmjkM/KyJRmSQXtyupxPPYuuMJmqojMAmRcyr4pmFt6asMgZh8YicP7oID+3owlWyNisToWFs=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <BD6EBF9DA0538144BB28C1BB6C9247C6@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 812eaab7-ccc8-443e-7c3e-08d6af15d0e0
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Mar 2019 22:29:15.6463
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB3122
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 04:03:07PM +0000, Chris Down wrote:
> This patch is an incremental improvement on the existing
> memory.{low,min} relative reclaim work to base its scan pressure
> calculations on how much protection is available compared to the current
> usage, rather than how much the current usage is over some protection
> threshold.
>=20
> Previously the way that memory.low protection works is that if you are
> 50% over a certain baseline, you get 50% of your normal scan pressure.
> This is certainly better than the previous cliff-edge behaviour, but it
> can be improved even further by always considering memory under the
> currently enforced protection threshold to be out of bounds. This means
> that we can set relatively low memory.low thresholds for variable or
> bursty workloads while still getting a reasonable level of protection,
> whereas with the previous version we may still trivially hit the 100%
> clamp. The previous 100% clamp is also somewhat arbitrary, whereas this
> one is more concretely based on the currently enforced protection
> threshold, which is likely easier to reason about.
>=20
> There is also a subtle issue with the way that proportional reclaim
> worked previously -- it promotes having no memory.low, since it makes
> pressure higher during low reclaim. This happens because we base our
> scan pressure modulation on how far memory.current is between memory.min
> and memory.low, but if memory.low is unset, we only use the overage
> method. In most cromulent configurations, this then means that we end up
> with *more* pressure than with no memory.low at all when we're in low
> reclaim, which is not really very usable or expected.
>=20
> With this patch, memory.low and memory.min affect reclaim pressure in a
> more understandable and composable way. For example, from a user
> standpoint, "protected" memory now remains untouchable from a reclaim
> aggression standpoint, and users can also have more confidence that
> bursty workloads will still receive some amount of guaranteed
> protection.
>=20
> Signed-off-by: Chris Down <chris@chrisdown.name>
> Reviewed-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
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
>  include/linux/memcontrol.h | 25 ++++++++--------
>  mm/vmscan.c                | 61 +++++++++++++-------------------------
>  2 files changed, 32 insertions(+), 54 deletions(-)
>=20
> No functional changes, just rebased.
>=20
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index b226c4bafc93..799de23edfb7 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -333,17 +333,17 @@ static inline bool mem_cgroup_disabled(void)
>  	return !cgroup_subsys_enabled(memory_cgrp_subsys);
>  }
> =20
> -static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
> -					 unsigned long *min, unsigned long *low)
> +static inline unsigned long mem_cgroup_protection(struct mem_cgroup *mem=
cg,
> +						  bool in_low_reclaim)
>  {
> -	if (mem_cgroup_disabled()) {
> -		*min =3D 0;
> -		*low =3D 0;
> -		return;
> -	}
> +	if (mem_cgroup_disabled())
> +		return 0;
> +
> +	if (in_low_reclaim)
> +		return READ_ONCE(memcg->memory.emin);
> =20
> -	*min =3D READ_ONCE(memcg->memory.emin);
> -	*low =3D READ_ONCE(memcg->memory.elow);
> +	return max(READ_ONCE(memcg->memory.emin),
> +		   READ_ONCE(memcg->memory.elow));
>  }
> =20
>  enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
> @@ -845,11 +845,10 @@ static inline void memcg_memory_event_mm(struct mm_=
struct *mm,
>  {
>  }
> =20
> -static inline void mem_cgroup_protection(struct mem_cgroup *memcg,
> -					 unsigned long *min, unsigned long *low)
> +static inline unsigned long mem_cgroup_protection(struct mem_cgroup *mem=
cg,
> +						  bool in_low_reclaim)
>  {
> -	*min =3D 0;
> -	*low =3D 0;
> +	return 0;
>  }
> =20
>  static inline enum mem_cgroup_protection mem_cgroup_protected(
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f6b9b45f731d..d5daa224364d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2374,12 +2374,13 @@ static void get_scan_count(struct lruvec *lruvec,=
 struct mem_cgroup *memcg,
>  		int file =3D is_file_lru(lru);
>  		unsigned long lruvec_size;
>  		unsigned long scan;
> -		unsigned long min, low;
> +		unsigned long protection;
> =20
>  		lruvec_size =3D lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
> -		mem_cgroup_protection(memcg, &min, &low);
> +		protection =3D mem_cgroup_protection(memcg,
> +						   sc->memcg_low_reclaim);
> =20
> -		if (min || low) {
> +		if (protection) {
>  			/*
>  			 * Scale a cgroup's reclaim pressure by proportioning
>  			 * its current usage to its memory.low or memory.min
> @@ -2392,13 +2393,10 @@ static void get_scan_count(struct lruvec *lruvec,=
 struct mem_cgroup *memcg,
>  			 * setting extremely liberal protection thresholds. It
>  			 * also means we simply get no protection at all if we
>  			 * set it too low, which is not ideal.
> -			 */
> -			unsigned long cgroup_size =3D mem_cgroup_size(memcg);
> -
> -			/*
> -			 * If there is any protection in place, we adjust scan
> -			 * pressure in proportion to how much a group's current
> -			 * usage exceeds that, in percent.
> +			 *
> +			 * If there is any protection in place, we reduce scan
> +			 * pressure by how much of the total memory used is
> +			 * within protection thresholds.
>  			 *
>  			 * There is one special case: in the first reclaim pass,
>  			 * we skip over all groups that are within their low
> @@ -2408,43 +2406,24 @@ static void get_scan_count(struct lruvec *lruvec,=
 struct mem_cgroup *memcg,
>  			 * ideally want to honor how well-behaved groups are in
>  			 * that case instead of simply punishing them all
>  			 * equally. As such, we reclaim them based on how much
> -			 * of their best-effort protection they are using. Usage
> -			 * below memory.min is excluded from consideration when
> -			 * calculating utilisation, as it isn't ever
> -			 * reclaimable, so it might as well not exist for our
> -			 * purposes.
> +			 * memory they are using, reducing the scan pressure
> +			 * again by how much of the total memory used is under
> +			 * hard protection.
>  			 */
> -			if (sc->memcg_low_reclaim && low > min) {
> -				/*
> -				 * Reclaim according to utilisation between min
> -				 * and low
> -				 */
> -				scan =3D lruvec_size * (cgroup_size - min) /
> -					(low - min);
> -			} else {
> -				/* Reclaim according to protection overage */
> -				scan =3D lruvec_size * cgroup_size /
> -					max(min, low) - lruvec_size;

I've noticed that the old version is just wrong: if cgroup_size is way smal=
ler
than max(min, low), scan will be set to -lruvec_size.
Given that it's unsigned long, we'll end up with scanning the whole list
(due to clamp() below).

So the new commit should be probably squashed into the previous and
generally treated as a fix.

Thanks!

