Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4636AC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:16:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C051E20869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:16:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ND5cG26i";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="crVB3ElF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C051E20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E3D56B026C; Fri, 12 Apr 2019 16:16:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46A606B026E; Fri, 12 Apr 2019 16:16:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2710B6B026F; Fri, 12 Apr 2019 16:16:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id F01686B026C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:16:00 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id b75so4454139vke.6
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:16:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=tj8d9Aesqk59fYl7HFJeF3PryMc8P4Ae1h5Ah3FbvZ0=;
        b=KLhFZn8LQZqLH5cTcpLGfkxaRhcFo/hvIhKNWLlCqLvx6o932F7sBPCYPdNMeAnSR0
         /83+tVTCKVIhX+YrnrJEMq55txlNEhAeic7KNmeWspiVQKs8hWegdjz4M8PWND07pZw7
         mk8ccuG77bvUXmtS398YL0QU6sqgywb3kvVQfvboGbL66qE01aowklg45IhU+zDnOicd
         S/j+aseXi0j7iKVx6HeyRqjEyamT+cV1gElmUQRSbpMZM5M4skzoFOm73NDLGDJQ1LPE
         yLJNj/PctolYindEu7zIJpGVONL2TcFVVQAe9VAhPZ2tzrq+F3cZL/0aNp50CFvuireE
         Wc4w==
X-Gm-Message-State: APjAAAUOyb73tWTnFuQiLjRAKBybyDnHKna/5vra4O/OqFuy3OJ4x24j
	2JYzlwPhmzI/Y0E4HQMq4gVrkHVj1au/GeBqzCEklI+0MuR+6L3e5cMphbp7qvTilJNfyrzFb04
	ko6IerOnA7FKgww+djvCRG7SfDK/kyFWhxRWMLKr3nqbOehCjmBKmzxM+B88WApH6Kw==
X-Received: by 2002:a67:ee04:: with SMTP id f4mr34668692vsp.34.1555100160570;
        Fri, 12 Apr 2019 13:16:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxJ6EA0By75QCAp5ElN0IpihN1EEtovBnFfNLWBkdKa3FJ9rLAFbENxpqzyQvPVjRE09us
X-Received: by 2002:a67:ee04:: with SMTP id f4mr34668665vsp.34.1555100159976;
        Fri, 12 Apr 2019 13:15:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555100159; cv=none;
        d=google.com; s=arc-20160816;
        b=QGz3d1jzB6m8THBJvAqf1gKGvBXLdlSpo70NbrYBPDbtan/H/ZPilXqtdzt65HLm0h
         sZf1MnfFOYPYrlI72gFUTQQRLnJE2geCaP5X6J6Cbkyk0d6WStit6qMc7D5u1OOwM7De
         nVYZ6FEiyFh2GUi/5/lcX641v2P/EqnJbVYoRTSZYcOqzQDMPfTeamNWxgq6WkVrF9U6
         FYQba7ErP/hzoXaeEvzVUOlrmadIUQjb+UhNMb/LdzeYz2JwlVJhS7XpLKP55MwI6Q2W
         hFDLdYaLlo6hWpy5/q87lvuillt7ZZKISoI+K308Xv1JDQhuEsI1Rwmx0eI1Gr3NvRv2
         Ga6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=tj8d9Aesqk59fYl7HFJeF3PryMc8P4Ae1h5Ah3FbvZ0=;
        b=NvWi9MLLO/aFbZLdVhfittg2VDdmWQ98oYmuyD9QXGsIcoJtm1mBQgXdWrQYDI0w8u
         GhCrmJqyfBhArLvkRHozLW1/arzsMNUjlGB3W4yreoE5HCU7hQJaQ1ArpzYorcWQzD7Z
         P7Kzvcvs5iUhzlgWD+TsTAh1h+Vxj6V8gF/qj0yTtHYmGWdPGPTE3rs9uqk8HxSQZhn0
         h9dTdWOnMFToPEHLshN4X7iwGCT6R21uWLn2QR264j626aIpY687SSzhlNHqqa+ZsgSs
         jI4pWSBVzG4aa/tdRc2gSd99hGMxZ8nIKPZ/UKSE3dJUA0jqYrxHDrGpvDoUYfx797f8
         R5Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ND5cG26i;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=crVB3ElF;
       spf=pass (google.com: domain of prvs=90051be98c=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90051be98c=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l21si14952260vso.72.2019.04.12.13.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 13:15:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90051be98c=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ND5cG26i;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=crVB3ElF;
       spf=pass (google.com: domain of prvs=90051be98c=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90051be98c=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3CK05o6029224;
	Fri, 12 Apr 2019 13:15:56 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=tj8d9Aesqk59fYl7HFJeF3PryMc8P4Ae1h5Ah3FbvZ0=;
 b=ND5cG26i3vMtxZnN8OPgYUA0GjvVFAP9FzCxsJBJ9NWkrMnjeXA0PNMgz9uz0exAgMX9
 /PghIVhdFWaC7GAaSmnid7++khsytxHo8qioGdfm793DlT5NAf3eTJqmRGWrrt4Qkkh7
 XKUXhf/OOtnJcUMlDVYkY8EeuPRsmq1SeY4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rtrx9hsdj-8
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 12 Apr 2019 13:15:56 -0700
Received: from prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 12 Apr 2019 13:15:41 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 12 Apr 2019 13:15:41 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 12 Apr 2019 13:15:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tj8d9Aesqk59fYl7HFJeF3PryMc8P4Ae1h5Ah3FbvZ0=;
 b=crVB3ElFsL4Vd2R9GD6Bvj8BQ2Zenr25Ra3dS4S3a7zO9ivqs/rslGABqTj+RjbTpTBnlMvEmmlnKfThc9U8VSY+NqCIukGDONENfiBVPfubqbohnuzXjF4heeBsimJzHOAgOyLf/XkL/XWY+HF3hewt8EaotYrObq9RSOoPWbk=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3159.namprd15.prod.outlook.com (20.178.207.220) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.17; Fri, 12 Apr 2019 20:15:39 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.016; Fri, 12 Apr 2019
 20:15:39 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>, Cgroups
	<cgroups@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Kernel Team
	<Kernel-team@fb.com>
Subject: Re: [PATCH 3/4] mm: memcontrol: fix recursive statistics correctness
 & scalabilty
Thread-Topic: [PATCH 3/4] mm: memcontrol: fix recursive statistics correctness
 & scalabilty
Thread-Index: AQHU8UKUV0F4p+EmokWSlSobKT/LA6Y48L8AgAAFtYA=
Date: Fri, 12 Apr 2019 20:15:38 +0000
Message-ID: <20190412201534.GB24377@tower.DHCP.thefacebook.com>
References: <20190412151507.2769-1-hannes@cmpxchg.org>
 <20190412151507.2769-4-hannes@cmpxchg.org>
 <CALvZod4xu10+E41YyaamigysZAnDcdA09f5m-hGd72LeJ9VmEg@mail.gmail.com>
In-Reply-To: <CALvZod4xu10+E41YyaamigysZAnDcdA09f5m-hGd72LeJ9VmEg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR03CA0040.namprd03.prod.outlook.com
 (2603:10b6:301:3b::29) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:2586]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 125b0329-fb27-4491-1eea-08d6bf83a151
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3159;
x-ms-traffictypediagnostic: BYAPR15MB3159:
x-microsoft-antispam-prvs: <BYAPR15MB31591CD0F47CAABABE6FB7B5BE280@BYAPR15MB3159.namprd15.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(136003)(376002)(346002)(39860400002)(189003)(199004)(52116002)(81166006)(71200400001)(105586002)(71190400001)(97736004)(68736007)(478600001)(8936002)(14454004)(7736002)(81156014)(6116002)(33656002)(106356001)(8676002)(25786009)(305945005)(486006)(54906003)(5660300002)(1076003)(476003)(46003)(316002)(4326008)(99286004)(53936002)(446003)(76176011)(86362001)(6246003)(256004)(6436002)(2906002)(9686003)(11346002)(6512007)(6486002)(102836004)(53546011)(186003)(6916009)(386003)(6506007)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3159;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: fbf353SeamkSFWKGkIHYPCnsqViX/Opvi0LBCLohv31qIeMltFxLdC5xKM38uK7Wn4v1HoHTriqBB03H4tAFlfK1638xscrkbDAHfW/7lHldgQIX6jQqpRUOUO2RICOg4tkzmU4CjWHDVjon3UTzcTkXSDXv0NevoZRYm90reu5H6Ne6fXW0fHT3iEg2XVyK+ep0le2ckrTkeXwxoZDnVr+J96QToBog0G37fbrHimm/ntbBxQ6/eFo3dxvDd9MALZ981gjR9j/uHxmwIJOnFnEt+qtZ+SnL9dJmwcR6Mti+6AO3UEio7sI8tPccq4ygBHQLKPkl0vreO4FYsdTfVWHnFPNF/NlDURvNoVI+63OsEGlVmBj4zGqB2hOr6c6Z00lM39D2RkXdY7DEqxBHnEGmVap3WQju9iJCZxIkuMU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <83C4D58C79AA094F9D9733F4C0F7C635@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 125b0329-fb27-4491-1eea-08d6bf83a151
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 20:15:38.9934
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3159
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-12_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 12:55:10PM -0700, Shakeel Butt wrote:
> On Fri, Apr 12, 2019 at 8:15 AM Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> >
> > Right now, when somebody needs to know the recursive memory statistics
> > and events of a cgroup subtree, they need to walk the entire subtree
> > and sum up the counters manually.
> >
> > There are two issues with this:
> >
> > 1. When a cgroup gets deleted, its stats are lost. The state counters
> > should all be 0 at that point, of course, but the events are not. When
> > this happens, the event counters, which are supposed to be monotonic,
> > can go backwards in the parent cgroups.
> >
>=20
> We also faced this exact same issue as well and had the similar solution.
>=20
> > 2. During regular operation, we always have a certain number of lazily
> > freed cgroups sitting around that have been deleted, have no tasks,
> > but have a few cache pages remaining. These groups' statistics do not
> > change until we eventually hit memory pressure, but somebody watching,
> > say, memory.stat on an ancestor has to iterate those every time.
> >
> > This patch addresses both issues by introducing recursive counters at
> > each level that are propagated from the write side when stats change.
> >
> > Upward propagation happens when the per-cpu caches spill over into the
> > local atomic counter. This is the same thing we do during charge and
> > uncharge, except that the latter uses atomic RMWs, which are more
> > expensive; stat changes happen at around the same rate. In a sparse
> > file test (page faults and reclaim at maximum CPU speed) with 5 cgroup
> > nesting levels, perf shows __mod_memcg_page state at ~1%.
> >
>=20
> (Unrelated to this patchset) I think there should also a way to get
> the exact memcg stats. As the machines are getting bigger (more cpus
> and larger basic page size) the accuracy of stats are getting worse.
> Internally we have an additional interface memory.stat_exact for that.
> However I am not sure in the upstream kernel will an additional
> interface is better or something like /proc/sys/vm/stat_refresh which
> sync all per-cpu stats.

I was thinking about eventually consistent counters: sync them periodically
from a worker thread. It should keep the cost of reading small, but
should increase the accuracy. Will it work for you?

