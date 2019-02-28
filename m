Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C68AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 22:29:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 199E92075B
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 22:29:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qWxdtLZP";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="crYwUzcV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 199E92075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A24E58E0003; Thu, 28 Feb 2019 17:29:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D2A28E0001; Thu, 28 Feb 2019 17:29:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 874868E0003; Thu, 28 Feb 2019 17:29:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6098E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 17:29:53 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w134so17205285qka.6
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:29:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=W5vkPIfHSzkxX0nh7FcKnbZAu30CdNaDvZwHxlqjN+U=;
        b=BzATCV5H/JWUgnLOcYYeoIoISiHaGy1aJoZMeMtckbkYzhlSlowpoIFdMT6fNtRr9G
         K/U0vQguvjHAOrwAXEsVtQYDMkQqEMOwRv2VAgFjKeu64BKuyqyVRUOGj0h5OxLqVa8c
         l4CwNmx1voV3wulmaQ82HoXdPrFUwMsENZY4epCifi71yO5dDln8qeV9Gj8RLLzPDNvW
         i7kLeNabMsPLjsAdFE98g8vdv1kNqO2YUcnp08+Z0dLmFieHJwolYqOKcnx8v93NjtBs
         LhZ4872kwal8vzQ/T3z+SMr9s6eav+ZkvZ0PdxzJPEkvz8b1ZbQ1clzGCqkc8DYi0S6g
         NSpQ==
X-Gm-Message-State: APjAAAXo7jGe2lcICz3zE2ie6I8vqrIRVxmCX9WqsCwyuo8t+nh3y3Z4
	WlAHYrpGzUW+JWa9JO5V/H2XhxIsSTUl30W8HnrH92EZ+KX3fxv8KMZsuLllEYrJQ1asGwGDESy
	uT+CJmRvTWOZJrG9lABV/rPrTQyay/lzQoWj2gnA0DN8tYUhmuHxykka2U0JCWASp8A==
X-Received: by 2002:a37:a114:: with SMTP id k20mr1414643qke.274.1551392993119;
        Thu, 28 Feb 2019 14:29:53 -0800 (PST)
X-Google-Smtp-Source: APXvYqynhNzF8zuBtRpjwpUav7rbjORLq5u9AycymL1GPjusQuXHRFs6oSsTGJXmHT92E7ITMKAt
X-Received: by 2002:a37:a114:: with SMTP id k20mr1414592qke.274.1551392992145;
        Thu, 28 Feb 2019 14:29:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551392992; cv=none;
        d=google.com; s=arc-20160816;
        b=qfG91b7Y7zoU2G13OzDtpPTgClGgf1g59RfD7ib23B5eGBi4gK3HpnvWG+QETAnmQJ
         ddQk2IVZCdaW5h+d2/A+NW6VX22dvzuvIx2s2OVfkIrVV65jMbqb/B1rz93n0wHbyd+m
         NdXM9+tnolr0vVrCheW0SXmQFVjYN5Cncb2Z2ZkxeU9oxyHiDGrW8bjxc0FkQYDxAKgw
         SS/2geJsQC54b3BAX0OTgsoWu11wt1nyqyFCxlCK73ZcHcNMl/KtzVtqZg+QcJCMnxr/
         0KnPmpL/HAgAmKo81HRrKsZItNT64OscB8KjAcbhrfeTpRpPjrHSl5vMoVVqQ/Tg78O7
         4PTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=W5vkPIfHSzkxX0nh7FcKnbZAu30CdNaDvZwHxlqjN+U=;
        b=koAa/CJKSvoI/6W0cjmXBuiwSVvsUWdH03i8ibxYW/9oMPoXOB8toliEKtKy5jn5we
         Ut/gClwbQ5QSQhqGwVyxVpD6jVwnrBvBpS72dOJ1xOHF6LVahb6NKeo+CUo2EKaLDLPb
         sfWcAI2QjY8LNNXAtjApHLJCHSGee00mqZ9Y1y44OMgYzT9GxII8BL4TE7UVRLs3K+Pp
         HH2FLj4+X2jEbJnaX1V20de+pDt1b5jT4HrQ8W4Oj11+YwVjo5kKZkCiGBbRB1tdUI3E
         5ce3lB+Q/U9gEEysB7n6bvjEiAsYq7dhYG8p7bdyXI1GlyFh2BpNr/B888mYBrk1ESRG
         iG7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qWxdtLZP;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=crYwUzcV;
       spf=pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=896249f319=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c131si4855182qkb.206.2019.02.28.14.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 14:29:52 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qWxdtLZP;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=crYwUzcV;
       spf=pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=896249f319=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1SMMUw1009694;
	Thu, 28 Feb 2019 14:29:47 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=W5vkPIfHSzkxX0nh7FcKnbZAu30CdNaDvZwHxlqjN+U=;
 b=qWxdtLZPu93yDmZfzgA2vsfbeR0g7yRWhXwHYVZgLZzth8/mdwEedGlngv2kl3RpMNSb
 5muRuWVT79QMdRqhgAN57IrHoXna87viTeCRe6IWda/fxxLQH0yYdn5ugjl6nenNHkll
 DCByzQKPbPu3mikbCBVywK1eXuI+LE12uXU= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qxr1503np-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 28 Feb 2019 14:29:46 -0800
Received: from frc-mbx03.TheFacebook.com (2620:10d:c0a1:f82::27) by
 frc-hub04.TheFacebook.com (2620:10d:c021:18::174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 28 Feb 2019 14:29:45 -0800
Received: from frc-hub04.TheFacebook.com (2620:10d:c021:18::174) by
 frc-mbx03.TheFacebook.com (2620:10d:c0a1:f82::27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 28 Feb 2019 14:29:44 -0800
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.74) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Thu, 28 Feb 2019 14:29:44 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=W5vkPIfHSzkxX0nh7FcKnbZAu30CdNaDvZwHxlqjN+U=;
 b=crYwUzcVAk2C+i7p6rkWaYGBM9512+J62B2TXYf8qYn5CRlWl5nC551bzTUzv/JvlkrXMBeTcchHdHyFGsr0bZ7E68B2d5QngfTOhI2MnkUs31thRabyTlP0JZLOY6tDP0XOUv059ahUDevw/O1ytU0Xf9KHg4f/uManzOuSq0E=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3141.namprd15.prod.outlook.com (20.178.239.214) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Thu, 28 Feb 2019 22:29:43 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1665.015; Thu, 28 Feb 2019
 22:29:43 +0000
From: Roman Gushchin <guro@fb.com>
To: Dave Chinner <david@fromorbit.com>
CC: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "riel@surriel.com"
	<riel@surriel.com>,
        "dchinner@redhat.com" <dchinner@redhat.com>,
        "guroan@gmail.com" <guroan@gmail.com>,
        Kernel Team <Kernel-team@fb.com>,
        "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Topic: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Index: AQHUyCKda3Qt+ClMVUers5iRNki+jqXn/PCAgAAzK4CAABr9gIACDQgAgAracwCAAJbSAIAAEISA
Date: Thu, 28 Feb 2019 22:29:42 +0000
Message-ID: <20190228222937.GA30495@tower.DHCP.thefacebook.com>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190220024723.GA20682@dastard> <20190220055031.GA23020@dastard>
 <20190220072707.GB23020@dastard>
 <20190221224616.GB24252@tower.DHCP.thefacebook.com>
 <20190228203044.GA7160@tower.DHCP.thefacebook.com>
 <20190228213032.GN23020@dastard>
In-Reply-To: <20190228213032.GN23020@dastard>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR02CA0070.namprd02.prod.outlook.com
 (2603:10b6:a03:54::47) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:2ae]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a3bfe1f3-e801-4bc0-5f63-08d69dcc3bfe
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3141;
x-ms-traffictypediagnostic: BYAPR15MB3141:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3141;20:66K054QqwvkBpP/htIjKkr74NdEGDrGozOHUewhmiJ17MHKRTfs02HLFMs/0e1dV7eSCliuFyDVxN0FZ8giEISzq+LalXdERcEtGbrlrhxkSo5R3CWTXORUmg4Gm4As+LMgzkcgCVhEFZI56wv/Z9BJH5ITrfnj7C5fN+2ClKZc=
x-microsoft-antispam-prvs: <BYAPR15MB3141E92495C450AA741C333BBE750@BYAPR15MB3141.namprd15.prod.outlook.com>
x-forefront-prvs: 0962D394D2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39860400002)(396003)(366004)(346002)(376002)(189003)(199004)(6916009)(97736004)(186003)(2906002)(46003)(8936002)(446003)(256004)(11346002)(486006)(476003)(86362001)(68736007)(1076003)(5660300002)(6116002)(478600001)(33656002)(316002)(6436002)(9686003)(54906003)(25786009)(93886005)(386003)(6512007)(52116002)(105586002)(305945005)(6246003)(53936002)(81156014)(71200400001)(99286004)(81166006)(71190400001)(8676002)(4326008)(106356001)(6506007)(7736002)(229853002)(6486002)(14454004)(102836004)(76176011);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3141;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: zRDNF1CjOv9Sp03MckQ8y8t8QqV2qphf4C3wrJVYSiAez6p3EGXE8g4K2NOPLNoZkfTVOdTh5E0/o9QUit9Is3R65Sy8QjzE8V98QbraGWbyerjlxdww2S5jUVtAQpChWSHQJF5add8SjoyOi2pp2zEo6/fLNWHL5qK9zq/IFYswjEi612uMzOmuxTloenAP2i1+k4n0nzQVgEOcN6kb3VfNvNflKTSN34/RLXcmK4v0edsnin65BrTAzIXT1CJIdZwJ9LXxoAhuFPG4nOUeuqvYl5b/pkFzyPnWP/wHery9Lj1kJfqsfBEYWYKntpXeMZuGfU3lsqq3ia7fJaqquWom93GDhT7npK65QePqtBks0aVKLQlb7joZ6/PBQ9cT+EFJjZE+GvIqxNo973J93aWjbN5xtjJFKsNuouSVhH4=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6080E35597417D469EC72F424ABF2922@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a3bfe1f3-e801-4bc0-5f63-08d69dcc3bfe
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Feb 2019 22:29:42.8371
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3141
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_14:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 01, 2019 at 08:30:32AM +1100, Dave Chinner wrote:
> On Thu, Feb 28, 2019 at 08:30:49PM +0000, Roman Gushchin wrote:
> > On Thu, Feb 21, 2019 at 02:46:17PM -0800, Roman Gushchin wrote:
> > > On Wed, Feb 20, 2019 at 06:27:07PM +1100, Dave Chinner wrote:
> > > > On Wed, Feb 20, 2019 at 04:50:31PM +1100, Dave Chinner wrote:
> > > > > I'm just going to fix the original regression in the shrinker
> > > > > algorithm by restoring the gradual accumulation behaviour, and th=
is
> > > > > whole series of problems can be put to bed.
> > > >=20
> > > > Something like this lightly smoke tested patch below. It may be
> > > > slightly more agressive than the original code for really small
> > > > freeable values (i.e. < 100) but otherwise should be roughly
> > > > equivalent to historic accumulation behaviour.
> > > >=20
> > > > Cheers,
> > > >=20
> > > > Dave.
> > > > --=20
> > > > Dave Chinner
> > > > david@fromorbit.com
> > > >=20
> > > > mm: fix shrinker scan accumulation regression
> > > >=20
> > > > From: Dave Chinner <dchinner@redhat.com>
> > >=20
> > > JFYI: I'm testing this patch in our environment for fixing
> > > the memcg memory leak.
> > >=20
> > > It will take a couple of days to get reliable results.
> > >=20
> >=20
> > So unfortunately the proposed patch is not solving the dying memcg recl=
aim
> > issue. I've tested it as is, with s/ilog2()/fls(), suggested by Johanne=
s,
> > and also with more a aggressive zero-seek slabs reclaim (always scannin=
g
> > at least SHRINK_BATCH for zero-seeks shrinkers).
>=20
> Which makes sense if it's inodes and/or dentries shared across
> multiple memcgs and actively referenced by non-owner memcgs that
> prevent dying memcg reclaim. i.e. the shrinkers will not reclaim
> frequently referenced objects unless there is extreme memory
> pressure put on them.
>=20
> > In all cases the number
> > of outstanding memory cgroups grew almost linearly with time and didn't=
 show
> > any signs of plateauing.
>=20
> What happend to the amount of memory pinned by those dying memcgs?
> Did that change in any way? Did the rate of reclaim of objects
> referencing dying memcgs improve? What type of objects are still
> pinning those dying memcgs? did you run any traces to see how big
> those pinned caches were and how much deferal and scanning work was
> actually being done on them?

The amount of pinned memory is approximately proportional to the number
of dying cgroups, in other words it also grows almost linearly.
The rate of reclaim is better than without any patches, and it's
approximately on pair with a version with Rik's patches.

>=20
> i.e. if all you measured is the number of memcgs over time, then we
> don't have any information that tells us whether this patch has had
> any effect on the reclaimable memory footprint of those dying memcgs
> or what is actually pinning them in memory.

I'm not saying that the patch is bad, I'm saying it's not sufficient
in our environment.

>=20
> IOWs, we need to know if this patch reduces the dying memcg
> references down to just the objects that non-owner memcgs are
> keeping active in cache and hence preventing the dying memcgs from
> being freed. If this patch does that, then the shrinkers are doing
> exactly what they should be doing, and the remaining problem to
> solve is reparenting actively referenced objects pinning the dying
> memcgs...

Yes, I agree. I'll take a look.

Thanks!

