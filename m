Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69DD8C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:07:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C6FD20850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 20:07:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="OthroVqi";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Ld+kq/Xk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C6FD20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 955856B000C; Fri, 12 Apr 2019 16:07:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DD626B000D; Fri, 12 Apr 2019 16:07:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77E076B0010; Fri, 12 Apr 2019 16:07:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 50D126B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 16:07:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p26so9776402qtq.21
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:07:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=w34ue0TCLhcYpA27Lg6nzR6yawZCjemc0AF2Iua7eSc=;
        b=NZKdoFFc8utTtAZn/Ao7E9w9wWhMjdGb29M9Qpaf/2Q4FUoei1u121aHj+A4VSNj3q
         e4ZsOfu+F1ibXkGxNPamH0nmGViS8QT/I41U3OXavgQdtvnmTvpX6TfxQbYxjGZCZT7K
         r1AMqG6XxhluhRbdfEda7SMnsB+AIH21JgzKjmJpaL2cDHCWbErYUd5npjqJM0me1NJ+
         zgxk0sP6f9VYrFRHrrfJtT73lSXZJRljAYKg+jQMNSgcKJOLprgkrkOE1SWN+JEnaLIi
         VT4ZzAWB+a5QtWHBqfLdSQTRq0fYnHdwHJqW+T5ccSIhcCm8jHkYLLJl6lkSTPV9dR4t
         vVWA==
X-Gm-Message-State: APjAAAVL/q3YCHPUWzPUv8S14tiPw3d4VA7QzePuirbihnNtZF35igjy
	q5XRXt9HnFrZcooKTOYO3pdsF628q+RcJ7AGTw10bgSaucNhaRRHCoNmcj3i719k2uqcCrMyfdY
	UwYBQtRrdXwRYfUcrtXwrNOWJ37HxhQBgGSQVr7OZi+yrYhtD5nWJoRjouw91vtTz7Q==
X-Received: by 2002:ac8:180b:: with SMTP id q11mr48208728qtj.113.1555099625004;
        Fri, 12 Apr 2019 13:07:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9HMIk5RWgGJW+BepjsmxSrJTSj1dnD7BU2BA9SEFH2Xg4vJibZR2f3FNZGJ2KunutceCT
X-Received: by 2002:ac8:180b:: with SMTP id q11mr48208657qtj.113.1555099623974;
        Fri, 12 Apr 2019 13:07:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555099623; cv=none;
        d=google.com; s=arc-20160816;
        b=b9r4dc+j424O4qu81t61ZUCDujepYC7qJR75DD01Hu4YcNlTJxCIA7TBxdrWeuFjEB
         vTFjyE+Dt6uwrHa+XzWbB9RsczzV38Ag5J7dRJtoASCHdWZFPtHFlBKl11sl6pnw+czR
         L6pIta2dU5sFe00EM3B4p/+/eTIO++8nYxMMjYTCjVKtuCYh9ul4Qw+9tqW69ylxRb/s
         5Kfbiy+pXUHpzVdaEtzKlnSTUeWXl4Pw6yxdHjnYaexwHwn98dFAQQ5ggm2nV9hujjS3
         VGVs5rOfw8LzpcBEtjesUHbE0sz3OdgPrplf3eVfAPoO4xcn/rulFNTc6sMpPej4s+aQ
         6lCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=w34ue0TCLhcYpA27Lg6nzR6yawZCjemc0AF2Iua7eSc=;
        b=BAZ/Lh9tnCb9cKN025O1e8KyfVBO8PPcECYa2u3nisM4aI89pWKKiJqxqvrIBxjoZl
         Su/EDTIvXDodlYRQOK9mUvDu07yHa5vWT4R4RIot+lJYJLOGQukLRtCg9DWa/kVH+W7h
         9XjmqDDx6oJlvSEfxhbzqmxZk69xd4Z5tyxqDwzT3TNIwW3V0CkZ7s3HmjbbTlBipaPS
         WKg3SDDgMzmCDaxG0yd827zlVuOT5KWR/TPL8gtPbmIG0m/XB7G5M7KiYKokjbeXfF6Y
         JTgjZg8ZV/3sc4kAUBUcMcBfOOFdTxtFMnfe/gl9Zpbgaz1v7rIQEHJ3wrfNp5op6I+J
         WWAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=OthroVqi;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="Ld+kq/Xk";
       spf=pass (google.com: domain of prvs=90051be98c=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90051be98c=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k50si422961qtk.103.2019.04.12.13.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 13:07:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90051be98c=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=OthroVqi;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="Ld+kq/Xk";
       spf=pass (google.com: domain of prvs=90051be98c=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90051be98c=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3CK4fO3030123;
	Fri, 12 Apr 2019 13:06:58 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=w34ue0TCLhcYpA27Lg6nzR6yawZCjemc0AF2Iua7eSc=;
 b=OthroVqixESb+voiTgT+rRwz2z7bj5BNfFMIO2/xMNVkVWLv+mKfkzUBouvv90TalpsN
 sbpQNL6y56qGAdw/CRJuU7tTJN/TZDYWHfFSORUXpR4n9AUfle2/KJjQH9LnfI5+XF/U
 ifpgWi1K1S9vQ3ChY43t6MdhrHhdgvMW564= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rtw0wrxg6-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 12 Apr 2019 13:06:58 -0700
Received: from prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 12 Apr 2019 13:06:56 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 12 Apr 2019 13:06:55 -0700
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 12 Apr 2019 13:06:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=w34ue0TCLhcYpA27Lg6nzR6yawZCjemc0AF2Iua7eSc=;
 b=Ld+kq/XkF7mybhf8LhRGO1LH0MlPBJuffsxGDYoPBPbxom7sQaAkpdxHzIAYpe+pRPpCHrM+VDgcs52scN3rK3ZDQk89KLH7n2qPyJlUIimGXko5hYyxangmYD7eS4wOESVT9ACxs3ZQAqJzC8QKPlMg17v1k4KbqbE3NhBhkiw=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3464.namprd15.prod.outlook.com (20.179.60.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.17; Fri, 12 Apr 2019 20:06:34 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.016; Fri, 12 Apr 2019
 20:06:34 +0000
From: Roman Gushchin <guro@fb.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: fix false-positive OVERCOMMIT_GUESS failures
Thread-Topic: [PATCH] mm: fix false-positive OVERCOMMIT_GUESS failures
Thread-Index: AQHU8WPzV7whvXpmeUeLhsl6IRCndKY486cA
Date: Fri, 12 Apr 2019 20:06:34 +0000
Message-ID: <20190412200629.GA24377@tower.DHCP.thefacebook.com>
References: <20190412191418.26333-1-hannes@cmpxchg.org>
In-Reply-To: <20190412191418.26333-1-hannes@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR10CA0060.namprd10.prod.outlook.com
 (2603:10b6:300:2c::22) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:2586]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 618b90be-36fd-4858-de96-08d6bf825c63
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB3464;
x-ms-traffictypediagnostic: BYAPR15MB3464:
x-microsoft-antispam-prvs: <BYAPR15MB34644CDEFE076D0722E31AC2BE280@BYAPR15MB3464.namprd15.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(366004)(39860400002)(136003)(199004)(189003)(76176011)(476003)(11346002)(33656002)(81156014)(81166006)(486006)(478600001)(446003)(68736007)(229853002)(8936002)(6436002)(102836004)(6512007)(5660300002)(1076003)(6116002)(54906003)(316002)(4326008)(14454004)(256004)(7736002)(71190400001)(2906002)(71200400001)(6506007)(386003)(305945005)(9686003)(6916009)(86362001)(25786009)(6486002)(14444005)(106356001)(105586002)(6246003)(99286004)(186003)(97736004)(53936002)(52116002)(8676002)(46003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3464;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: a2FLjq9PZzm9RXIQb4/s5oW76KDP6WrSHcN+R/HqE1rdkyXjmhAOBLvBaAOfW/iStb+8udrALGRjiqLWleAdAJcFE2X15zykVg2CQmQ/STrbbPXEFMBJxtanOre2uRID6En4FmqFQUAriQwrca8ahwGOohONKxxhCoopzU7xosBceSRLn1j66biTVRdULoHQZCoCdmR8C4LyTVGF9YaLySnMINLcbxMHgEZUzd8Ko3Lk3/Tr03r3BhSa8HeY3PryaopYaWno5Ori5BglrEmcAgGORdhHw/To9CK6Lw7lNVJJb+0JQkpTYB+IhvnjO4FSOYwfIg5DrwpbAwyZvXzi5iGCcDK16TJ6FvAbKH6c0Ax/cMnwaiviKw9SaOTvYwv/KHMkt5YZbkf4V8wzoBuF3ZGTZBrrjLEGNx4qCEHDzqo=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <07E8811B2E537E488E0FA5B519045F3F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 618b90be-36fd-4858-de96-08d6bf825c63
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 20:06:34.1190
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3464
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

On Fri, Apr 12, 2019 at 03:14:18PM -0400, Johannes Weiner wrote:
> With the default overcommit=3D=3Dguess we occasionally run into mmap
> rejections despite plenty of memory that would get dropped under
> pressure but just isn't accounted reclaimable. One example of this is
> dying cgroups pinned by some page cache. A previous case was auxiliary
> path name memory associated with dentries; we have since annotated
> those allocations to avoid overcommit failures (see d79f7aa496fc ("mm:
> treat indirectly reclaimable memory as free in overcommit logic")).
>=20
> But trying to classify all allocated memory reliably as reclaimable
> and unreclaimable is a bit of a fool's errand. There could be a myriad
> of dependencies that constantly change with kernel versions.
>=20
> It becomes even more questionable of an effort when considering how
> this estimate of available memory is used: it's not compared to the
> system-wide allocated virtual memory in any way. It's not even
> compared to the allocating process's address space. It's compared to
> the single allocation request at hand!
>=20
> So we have an elaborate left-hand side of the equation that tries to
> assess the exact breathing room the system has available down to a
> page - and then compare it to an isolated allocation request with no
> additional context. We could fail an allocation of N bytes, but for
> two allocations of N/2 bytes we'd do this elaborate dance twice in a
> row and then still let N bytes of virtual memory through. This doesn't
> make a whole lot of sense.
>=20
> Let's take a step back and look at the actual goal of the
> heuristic. From the documentation:
>=20
>    Heuristic overcommit handling. Obvious overcommits of address
>    space are refused. Used for a typical system. It ensures a
>    seriously wild allocation fails while allowing overcommit to
>    reduce swap usage.  root is allowed to allocate slightly more
>    memory in this mode. This is the default.
>=20
> If all we want to do is catch clearly bogus allocation requests
> irrespective of the general virtual memory situation, the physical
> memory counter-part doesn't need to be that complicated, either.
>=20
> When in GUESS mode, catch wild allocations by comparing their request
> size to total amount of ram and swap in the system.
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

My 2c here: any kinds of percpu counters and percpu data is accounted
as unreclaimable and can alter the calculation significantly.

This is a special problem on hosts, which were idle for some time.
Without any memory pressure, kernel caches do occupy most of the memory,
so than a following attempt to start a workload fails.

With a big pleasure:
Acked-by: Roman Gushchin <guro@fb.com>

Thanks!

