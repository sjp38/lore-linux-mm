Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D975FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 22:08:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 820D020863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 22:08:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="F5SIa8EQ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="DPtDgrMu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 820D020863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B3298E0003; Tue, 26 Feb 2019 17:08:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 162438E0001; Tue, 26 Feb 2019 17:08:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 028F48E0003; Tue, 26 Feb 2019 17:08:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id C87018E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 17:08:15 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id i2so10426875ywb.1
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 14:08:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ZYjvaQ+txVXPDSHchhn56d73Ie2klYqNdKlmJS1iahA=;
        b=JG/0XNOhmmlDnLiODHQsX1pMiJ/4yKht4ySZZfSSF2fGorD+HIJ3BEzgy/YbpFm3Da
         Q+C/7IzVCueCnVP87VD5wRyNLKum24nVFyGbW9LkZPsCohmMeLnkzLwZZUMhv5FAkHt2
         UwdzPg3dKxzycvDpxmm+yAZBMhJstyNEvCEJKzBSWKvP3QfcNsUHNrgCSifrNWVLONHu
         3O6qRw6TJ+0SePaK9rj1e4p2b4Vi8HcbtFGOOpHkvGr+rLI+s6KQIgb+7Ng9NdC6g3jS
         ZxHyzFJhvx9lxuJvQiMAA+eJ/mfzOrb9i0y946ISw1ItpsOyte0nDP5EcF/lR5HLdd24
         W6/w==
X-Gm-Message-State: AHQUAuYJwfyZfoaevzvUONVCQBX5z+7lDyiad4jdViIdJAuXWEV6wn21
	2Eu8pmEmNZEViFHHGkBAhazwkbSdL+n/Nuac6rCN/24NAKUcIr9S5hBfZ/rzOiwrOCpAVkKgPg7
	MCsdYUx/1OjPXA7MJ/+b68hw1DAJGL84DuNcl184wRfyrUm8sm0amJyrtsQMU6mXcTw==
X-Received: by 2002:a25:2a4f:: with SMTP id q76mr19963834ybq.126.1551218895424;
        Tue, 26 Feb 2019 14:08:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZuUeuv0GAklxwcAJgIsGzvA2Yyi2B9bSA0WF+7Cvf3FV3Y7AO+kyVq9GxR1L8hvaS6rLTT
X-Received: by 2002:a25:2a4f:: with SMTP id q76mr19963772ybq.126.1551218894407;
        Tue, 26 Feb 2019 14:08:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551218894; cv=none;
        d=google.com; s=arc-20160816;
        b=Qkr7UkQtkcjYSoFWZFzFKnoeFYARKS5Iz2roGv1qsQMYcqQJ//ZWpv/cgyxTAHIAnn
         b+nZI9SFTRYAKs+zgze19l3I4vmMocYPQ0OfNB5/ENioLrk28eW32NTZrCyWa5nWT9gH
         jsS+ugRc1caj6uwQEVCYsRrBEzFqqA3hcWiwDbOm/aEKdWOVP36LJlnAc0WTYKP9onGa
         nMEbrq1A5unpMCfDyPPZatZ10UDfezpq5gGT6s5EbtOsYbb8JmhcD3VFf3fbzdWLLAvp
         ydPbTYx6fgp7f393AsA76vT2zjqAEJCSN5gGI2fa6CyIZtM4UA5BCR6ky4MsjcyB/lsz
         vs6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=ZYjvaQ+txVXPDSHchhn56d73Ie2klYqNdKlmJS1iahA=;
        b=xvFjh8p1AvrModnq1bH/MvssKEpmY2nf/uCcZbSNrTf0V6UpDTsY0gtDCRJdgLpSId
         Thn5oAIVyEm1gO/KIxwRLKi+1UFHYMw3I5IL9SKggUHSY+0c6zRkkll48T6rLpDrs/jJ
         Z5D95a9nKerMUEmUpePTJeSUaWDAb3ycN+kKLEC/KRh9CiRuFB/7EY/jozyhQyHW5y30
         7Sz20AF/Vhl4klmvUY2IRMTOO17NWDS9/T9DXVJe2bb5D2KfU3ioLyIzAES4j3ECuw4W
         1VhlyfEAWvtJhBjdE8mU34f8xnVTdkMeMz7BU2U8b+WnEbFaNrPMGcNF9cEtOIXIYEgm
         +GmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=F5SIa8EQ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=DPtDgrMu;
       spf=pass (google.com: domain of prvs=79607285cb=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79607285cb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f204si134714ywf.47.2019.02.26.14.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 14:08:14 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79607285cb=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=F5SIa8EQ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=DPtDgrMu;
       spf=pass (google.com: domain of prvs=79607285cb=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79607285cb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1QM5lT8021370;
	Tue, 26 Feb 2019 14:08:06 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=ZYjvaQ+txVXPDSHchhn56d73Ie2klYqNdKlmJS1iahA=;
 b=F5SIa8EQUdiplui9/sfEIMUlkl/WYLzFOqnjBr08jlEzgg9T05DKf7E3oR7ia7s6Zs46
 RJDXG3f9Wkh7Za/lz8LwUKotBoNd4uPeoiJsyHIewk7ZtAa4XElebHUvSnd0e1Ey1Z0e
 50/jTyOflrIJnXEgF8Kpy2cCyCVA4s2xiPU= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qwb5d8ppt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 26 Feb 2019 14:08:06 -0800
Received: from frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) by
 frc-hub05.TheFacebook.com (2620:10d:c021:18::175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Tue, 26 Feb 2019 14:08:05 -0800
Received: from frc-hub05.TheFacebook.com (2620:10d:c021:18::175) by
 frc-mbx05.TheFacebook.com (2620:10d:c0a1:f82::29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Tue, 26 Feb 2019 14:08:04 -0800
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.75) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Tue, 26 Feb 2019 14:08:04 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZYjvaQ+txVXPDSHchhn56d73Ie2klYqNdKlmJS1iahA=;
 b=DPtDgrMuR6vLMS2UPxHxscPHm2YRXUgR6UqVUEoWwOroF/Rukc3BjTyZN4V9qxr389Ft/swHM+Yca3VuV90tgEvm9LbxDj5ec5WU26CDmLu+QOwV+aHEi6tsn7Bi+DwAE1bm0fYyE2qILqGyrNbHK6+vF4DtsSMUrewYqitjMIo=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3383.namprd15.prod.outlook.com (20.179.59.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Tue, 26 Feb 2019 22:08:02 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1643.019; Tue, 26 Feb 2019
 22:08:02 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "Michal
 Hocko" <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
        Rik van Riel
	<riel@surriel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Shakeel Butt
	<shakeelb@google.com>
Subject: Re: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
Thread-Topic: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
Thread-Index: AQHUythGXfYU+8xM1EWrupNuYl99T6XvYi6AgALaQQCAAG1XgA==
Date: Tue, 26 Feb 2019 22:08:02 +0000
Message-ID: <20190226220756.GA25821@tower.DHCP.thefacebook.com>
References: <20190222175825.18657-1-aryabinin@virtuozzo.com>
 <20190225040255.GA31684@castle.DHCP.thefacebook.com>
 <88207884-c643-eb2c-a784-6a7b11d0e7c7@virtuozzo.com>
In-Reply-To: <88207884-c643-eb2c-a784-6a7b11d0e7c7@virtuozzo.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR11CA0060.namprd11.prod.outlook.com
 (2603:10b6:a03:80::37) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:44a8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a49d80eb-9fef-4b73-5c0c-08d69c36e051
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3383;
x-ms-traffictypediagnostic: BYAPR15MB3383:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3383;20:DIUN3pJIPzNW/MwDpyhWef9qSinnoG5dAluBG3Gp0dtTApycdvSIzD6H9FGzBJYpTWuBUyVZWST2/WM0nts03jXAAItjAJbCqP9M/6yh893CBMn7blTsBZQIDDJhdZUHffyVPzG5UIQRX0NfWgwcJ47mNG5/aczYp87EHTl5G78=
x-microsoft-antispam-prvs: <BYAPR15MB3383F9A04305BC1898D93901BE7B0@BYAPR15MB3383.namprd15.prod.outlook.com>
x-forefront-prvs: 096029FF66
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(39860400002)(136003)(396003)(376002)(346002)(199004)(189003)(51444003)(14444005)(53936002)(25786009)(6916009)(14454004)(478600001)(86362001)(105586002)(7416002)(106356001)(256004)(6116002)(6246003)(1076003)(4326008)(5660300002)(386003)(6506007)(33656002)(6486002)(53546011)(102836004)(46003)(68736007)(97736004)(76176011)(229853002)(52116002)(9686003)(81156014)(81166006)(71200400001)(71190400001)(446003)(486006)(476003)(11346002)(6436002)(2906002)(305945005)(7736002)(8676002)(8936002)(99286004)(186003)(54906003)(316002)(6512007);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3383;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: nwF7NxBiz1zxRK40x0TR6anY4rGlI0Nnx7STg9R2ekLfkhryuEExTW78YMe1h39rawiBhXewHWSjDwxEeRVi4PwpJF8d7QM1SlhuiK55kCGsZ6P55Z2/p4oEZST0O+t9ebsKgL6lcMJ7yoQT9E5ptEGbarjPk98PJiyznu+fOur2KqtAtUOsGwG7NPuAXJz3IPs3OnqoXzdcoHzdR/tIBfoVGGEIzsCnW3/9p7z8dqSNtpZDEDUKg2oMS3hdaWT1KW/ByQz4MJJpbC5hGRYgo/dGqybbKl6Zey4kuNCFI323ecWIkl6HqR9fRPCT3HR190kS1xaePiPD+sYh8BcBN9RY41J94pCaXI9Vbarv1QtUhcfzc+z3qtnsjy57PazPey390WWhY++g9uAOTrn2Iwej5e8YwyKdPbLpP9u4v1M=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3F59809F2D1A434393D80B0E0FCECFAC@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a49d80eb-9fef-4b73-5c0c-08d69c36e051
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Feb 2019 22:08:01.9925
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3383
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 06:36:38PM +0300, Andrey Ryabinin wrote:
>=20
>=20
> On 2/25/19 7:03 AM, Roman Gushchin wrote:
> > On Fri, Feb 22, 2019 at 08:58:25PM +0300, Andrey Ryabinin wrote:
> >> In a presence of more than 1 memory cgroup in the system our reclaim
> >> logic is just suck. When we hit memory limit (global or a limit on
> >> cgroup with subgroups) we reclaim some memory from all cgroups.
> >> This is sucks because, the cgroup that allocates more often always win=
s.
> >> E.g. job that allocates a lot of clean rarely used page cache will pus=
h
> >> out of memory other jobs with active relatively small all in memory
> >> working set.
> >>
> >> To prevent such situations we have memcg controls like low/max, etc wh=
ich
> >> are supposed to protect jobs or limit them so they to not hurt others.
> >> But memory cgroups are very hard to configure right because it require=
s
> >> precise knowledge of the workload which may vary during the execution.
> >> E.g. setting memory limit means that job won't be able to use all memo=
ry
> >> in the system for page cache even if the rest the system is idle.
> >> Basically our current scheme requires to configure every single cgroup
> >> in the system.
> >>
> >> I think we can do better. The idea proposed by this patch is to reclai=
m
> >> only inactive pages and only from cgroups that have big
> >> (!inactive_is_low()) inactive list. And go back to shrinking active li=
sts
> >> only if all inactive lists are low.
> >=20
> > Hi Andrey!
> >=20
> > It's definitely an interesting idea! However, let me bring some concern=
s:
> > 1) What's considered active and inactive depends on memory pressure ins=
ide
> > a cgroup.
>=20
> There is no such dependency. High memory pressure may be generated both
> by active and inactive pages. We also can have a cgroup creating no press=
ure
> with almost only active (or only inactive) pages.
>=20
> > Actually active pages in one cgroup (e.g. just deleted) can be colder
> > than inactive pages in an other (e.g. a memory-hungry cgroup with a tig=
ht
> > memory.max).
> >=20
>=20
> Well, yes, this is a drawback of having per-memcg lrus.
>=20
> > Also a workload inside a cgroup can to some extend control what's going
> > to the active LRU. So it opens a way to get more memory unfairly by
> > artificially promoting more pages to the active LRU. So a cgroup
> > can get an unfair advantage over other cgroups.
> >=20
>=20
> Unfair is usually a negative term, but in this case it's very much depend=
s on definition of what is "fair".
>=20
> If fair means to put equal reclaim pressure on all cgroups, than yes, the=
 patch
> increases such unfairness, but such unfairness is a good thing.
> Obviously it's more valuable to keep in memory actively used page than th=
e page that not used.

I think that fairness is good here.

>=20
> > Generally speaking, now we have a way to measure the memory pressure
> > inside a cgroup. So, in theory, it should be possible to balance
> > scanning effort based on memory pressure.
> >=20
>=20
> Simply by design, the inactive pages are the first candidates to reclaim.
> Any decision that doesn't take into account inactive pages probably would=
 be wrong.
>=20
> E.g. cgroup A with active job loading a big and active working set which =
creates high memory pressure
> and cgroup B - idle (no memory pressure) with a huge not used cache.
> It's definitely preferable to reclaim from B rather than from A.
>

For sure, if we're reclaiming hot pages instead of cold, it's bad for the
overall performance. But active and inactive LRUs are just an approximation=
 of
what is hot and cold. E.g. I will run "cat some_large_file" twice in a cgro=
up,
and the whole file will reside in the active LRU and considered hot. Even i=
f
nobody will ever use it again.

So it means that depending on memory usage pattern, some workloads will ben=
efit
from your change, and some will suffer.

Btw, what will be with protected cgroups (with memory.low set)?
Those will still affect global scanning decisions (active/inactive ratio),
but will be exempted from scanning?

Thanks!

