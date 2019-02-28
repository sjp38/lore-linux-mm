Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 926F3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 20:31:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 352DF218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 20:31:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Dl8FZ8UT";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="hWyJ4igb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 352DF218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4F198E0003; Thu, 28 Feb 2019 15:31:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFE488E0001; Thu, 28 Feb 2019 15:31:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AED8A8E0003; Thu, 28 Feb 2019 15:31:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84B7D8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 15:31:19 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z123so2999752qka.20
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 12:31:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=EyXom8gMdU4oy7ZJtQmqMzPuRAamqePvWnizr2DZQG0=;
        b=NHPAJxqI0yRR26TMuKoN7fTpjyogSlpl1sett3AHBpsIaqupA0t0WOX1MkJ8iOgfIC
         OqW6iwbrWPRr5NuG7tf+GVWSdPBYA8jhr7iKirw2DKnOQNPMREWu8SIpe9WfOzwZsPi5
         NtIrweIPPIy3XYcxNXyVtfXL9WC6Accv09ljqvrAdUIliQ+Q5AEEORiyYb3nEyyoHdqC
         fEcDppTQ3qFtSohGQGrEAxCGtbKNuwz+GWOyh9ZZVWkbNJIbtEMX1IYDr9aXau6+l7ye
         ObMwo1s4znOoVvtxjWBoIjfIPB+LDwsgWfjtsTPQ8Wo3n+ZkeCjp6Q3tNfPrM28BEcvM
         lCaw==
X-Gm-Message-State: APjAAAXv+5IoBoqk9Y1M1cusCCFmv6LNCQsKzrUvwfUODcnvM1cfdIow
	pPHfLUhpHZalvJBvO9Q3A9CpF/x3OAjfBnIuXdcEIg64wRaCLCL8r5ERLnkCkhnoppK9Qyy4UMY
	rXlNCgHtUdehhlrMMnnLO3gIwLUa84dBtOLcZlpc0Tt4G7OdfCttCNUSjlF06Y+n10w==
X-Received: by 2002:ac8:3339:: with SMTP id t54mr990184qta.151.1551385879124;
        Thu, 28 Feb 2019 12:31:19 -0800 (PST)
X-Google-Smtp-Source: APXvYqxm6mLE9I2KFjOyD0rwPVLHZ9E6jKVNBiUmyPrpO28OuorjrLtjcUF2G5JNIRw+27Id8cst
X-Received: by 2002:ac8:3339:: with SMTP id t54mr990123qta.151.1551385878187;
        Thu, 28 Feb 2019 12:31:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551385878; cv=none;
        d=google.com; s=arc-20160816;
        b=VNNMkLV2LuQJ0ER8jIIRs+3UJmCRgI3uXUijd8O7s0SlJvPsRmPAVWc1ak4zzXAKEu
         LU/9PYHcZNDuAlA4nKMksudLkpgg6PLBHm259CwDx58M2cNDLmitpSn5eXSdV5C+r/xS
         k3JExpAmqDHahWaH3CKi1Xl78bP+B4n0XLK4NDMVL4lxB27MVWsNOP2v1UtneB0f235L
         3wW5EhxC8gcYgMBowffaxsrYsWeQas76hsEWaOTqNjfzNI+ojCnswH2xwTgKb5/vBFSt
         FBzRLxxNRHxUbPeEXnIzyVhKGKdCI2m5udZDBooqdZTOYLpTqjaC8A3xM79BCT8hLlie
         LkeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=EyXom8gMdU4oy7ZJtQmqMzPuRAamqePvWnizr2DZQG0=;
        b=m9RFiiukLlET1TVK4xSFGrPEn8SY6g+g5SHhbE6rHjrxvnKpDP0rj41eSQZT8zgqDe
         1Rp+T+CcoeTFCblOfrTyez7MwrpwWxA2ooqmym7WiekvZTeTGUNIxs54ZO6fgkLJk3Tk
         LPRDjGp94p3F2hAU1X00jjCrg5dI5qZvXhOsQ81mhByiJ0ZeqdNEK/hUgJmGaP8s3QyK
         3bRIfgl/T6qRH7Nzgnao0M1m+/J1RLCzl9F3MS2BLZJRMM1qk5VK1eEmoEGzqaN4jQcL
         qqmCQRiBJUj28fFPIfMekN5pqkHxAwmGx2lOUlrK5zDnyZyNNz0kOwq6e78nEglf4pgv
         N1UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Dl8FZ8UT;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=hWyJ4igb;
       spf=pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=896249f319=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id w35si1680419qtw.397.2019.02.28.12.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 12:31:18 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Dl8FZ8UT;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=hWyJ4igb;
       spf=pass (google.com: domain of prvs=896249f319=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=896249f319=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x1SKTKNm018800;
	Thu, 28 Feb 2019 12:31:14 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=EyXom8gMdU4oy7ZJtQmqMzPuRAamqePvWnizr2DZQG0=;
 b=Dl8FZ8UTgEREHBSFoaj3UdVOdKYUOO1yRIqEDmY11Mnris+dingEXpjW8FfahZqQaIGb
 b/kppO0ifj0nTB0xB3G14dCTcJXriMtAuopb4c+ynr0KJDV1ZSxjYcCJKWtKuIqN4VJe
 JQfZa0uuCSrMITnXBQYmKCxt5xQzMPLhMCk= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2qxkjb0qh7-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 28 Feb 2019 12:31:13 -0800
Received: from prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 28 Feb 2019 12:30:51 -0800
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Thu, 28 Feb 2019 12:30:51 -0800
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Thu, 28 Feb 2019 12:30:51 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=EyXom8gMdU4oy7ZJtQmqMzPuRAamqePvWnizr2DZQG0=;
 b=hWyJ4igbUVoFN/wKbJaxmTdXXTPoPebRlUxw6vM2drDtgQpZjZVVU8jMIsmH0WjhcmThdg556oO92pUOWUCfdx5g/7S5AfMNhXYalONLIrdjJq5IUd/xoV4YX4NlwZf3KRm7FhhrH6be0/uYOysNkeX6n70OI4BSuJJv8qRvGz8=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3463.namprd15.prod.outlook.com (20.179.60.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.15; Thu, 28 Feb 2019 20:30:49 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1665.015; Thu, 28 Feb 2019
 20:30:49 +0000
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
Thread-Index: AQHUyCKda3Qt+ClMVUers5iRNki+jqXn/PCAgAAzK4CAABr9gIACDQgAgAtgkAA=
Date: Thu, 28 Feb 2019 20:30:49 +0000
Message-ID: <20190228203044.GA7160@tower.DHCP.thefacebook.com>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190220024723.GA20682@dastard> <20190220055031.GA23020@dastard>
 <20190220072707.GB23020@dastard>
 <20190221224616.GB24252@tower.DHCP.thefacebook.com>
In-Reply-To: <20190221224616.GB24252@tower.DHCP.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR05CA0064.namprd05.prod.outlook.com
 (2603:10b6:a03:74::41) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:b9ba]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 87da58cb-28d8-41f0-4a22-08d69dbba031
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3463;
x-ms-traffictypediagnostic: BYAPR15MB3463:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3463;20:VPhIV/PHpwpZkFj6aN3gjvtGOprrl4tft+KxQJLBJ6+Oue5u4uskVTXFCUQQx4/86m7oDOlIL9vnzbaaOG5nTdXg9tTjhl80zaF6WEqaf4GrXvQF90sfYnSBX5iyAqbok82hba6+ELlJOj48D6UCd7txmcKJJUKd08bwjcxY9ks=
x-microsoft-antispam-prvs: <BYAPR15MB346304AF9209EF1816EE0616BE750@BYAPR15MB3463.namprd15.prod.outlook.com>
x-forefront-prvs: 0962D394D2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(376002)(346002)(136003)(396003)(366004)(199004)(189003)(478600001)(25786009)(6506007)(33656002)(386003)(6486002)(93886005)(81166006)(4326008)(229853002)(6246003)(9686003)(6512007)(106356001)(7736002)(305945005)(97736004)(71200400001)(81156014)(71190400001)(6116002)(256004)(6436002)(14454004)(102836004)(5660300002)(105586002)(316002)(486006)(52116002)(54906003)(8936002)(46003)(86362001)(11346002)(186003)(2906002)(446003)(76176011)(53936002)(8676002)(476003)(1076003)(99286004)(68736007)(6916009);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3463;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: cR1D0RsFnBKz0NE+/qe3aq/w8R9shMnYLQUuZQjUaiRjgqCKKL+QpuD35wKwt5wlFRQW5YKebBsWl8K00+IA0OesvIwzSwkP9HARn4Ea6oWgSgayZZ8DeXeWjaEUPovneb984mHlKwgx1sS2fEFZwNK0O+9w5+wplaPZn8zkOvgDHMfeCyPX9HZiLRuAht0BlR4LvO57YXY5bLlC2F5zpxjNaa7C//jGmr+dyGh1pWgYRZdUDpxjBVIqjkSC5amo5V4jC5kkcEb7/xDWEJ6h1HYlFIG+RfO/IVGIHqmrkAJOKY//kpZ8qp7W6RiuRPqYeJDaf95cfmagHH+pBf/N7cBRri/OCVJq4V3tUXK4yg0sr2iEj8TKp1JlqJcFJVv/RvRytdfutX1Ocwzmiask8B2F8MQW1XpJ18psAmK3L5I=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <470E287E03DD5B48AD8ED302A0C59417@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 87da58cb-28d8-41f0-4a22-08d69dbba031
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Feb 2019 20:30:49.4946
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3463
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-28_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 02:46:17PM -0800, Roman Gushchin wrote:
> On Wed, Feb 20, 2019 at 06:27:07PM +1100, Dave Chinner wrote:
> > On Wed, Feb 20, 2019 at 04:50:31PM +1100, Dave Chinner wrote:
> > > I'm just going to fix the original regression in the shrinker
> > > algorithm by restoring the gradual accumulation behaviour, and this
> > > whole series of problems can be put to bed.
> >=20
> > Something like this lightly smoke tested patch below. It may be
> > slightly more agressive than the original code for really small
> > freeable values (i.e. < 100) but otherwise should be roughly
> > equivalent to historic accumulation behaviour.
> >=20
> > Cheers,
> >=20
> > Dave.
> > --=20
> > Dave Chinner
> > david@fromorbit.com
> >=20
> > mm: fix shrinker scan accumulation regression
> >=20
> > From: Dave Chinner <dchinner@redhat.com>
>=20
> JFYI: I'm testing this patch in our environment for fixing
> the memcg memory leak.
>=20
> It will take a couple of days to get reliable results.
>=20

So unfortunately the proposed patch is not solving the dying memcg reclaim
issue. I've tested it as is, with s/ilog2()/fls(), suggested by Johannes,
and also with more a aggressive zero-seek slabs reclaim (always scanning
at least SHRINK_BATCH for zero-seeks shrinkers). In all cases the number
of outstanding memory cgroups grew almost linearly with time and didn't sho=
w
any signs of plateauing.

Thanks!

