Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B966C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:04:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EDE2218CD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 18:04:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Sa0qcggn";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="UbZ7bYAj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EDE2218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC5CD6B0007; Thu, 18 Apr 2019 14:04:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4F106B0008; Thu, 18 Apr 2019 14:04:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CAEA6B000A; Thu, 18 Apr 2019 14:04:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5293D6B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:04:45 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h69so1832627pfd.21
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:04:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=nyD1XsBQY82CeJGECiRnHzq5/mZwh+IClLs8oH+5N10=;
        b=J984gPfmgSwsdKfCfRyR679GIAuk1Z2cLuFyPALHY8Vk3D5xf2wvQFhH56HyC6LZmu
         INaSVz822Vw5ARD8In1v26rIp0Q77bPJkOHJtRGy3VanF1ZJ7NpkIOXUgy12FfIpbZZd
         7uW+l7N7wBu8ojp/YRfOA8rhtzr29eafL2fuXuT9idn3C6jufkpn4VIYm5DwlnA78VAP
         nQUkSatYHizLdMJYdj7N+2YqFG6FB89VCD8Z0Ow/bo/79/RtmiNqElC+Z44xWoNlHB4y
         Zz2i3d8RDKhqK4jO9y/OcWJt2FG5XLjglfGSGZgWcJrQEXjnz1Ctf2pSgGF6CXbu73KN
         B6QA==
X-Gm-Message-State: APjAAAXaEzGvKV8z6zyhbQ1LzVBT5z+3nwd6AostVRDuX9d7jJkZd8Vy
	/rLUUUSRScYpdW4QZMkqkf/gVvALZ28RZO+MJMWWn+4M5HcruSxbB7jMEjjtUxpomXrZ9x0NXY+
	H2Hp/0BvZfh7aJzmkj0iRxSZXay8ns0pVrtPJa9ctv8VqJH14qtmFP7Zf05T8fZheug==
X-Received: by 2002:a17:902:442:: with SMTP id 60mr97891565ple.107.1555610684846;
        Thu, 18 Apr 2019 11:04:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWC/TRhcVJuHxYsfbytyQwK1eiMtUMSJ/s17oqSpiHm4Gn1nZl/Kute5lws/3zHWbLp7n/
X-Received: by 2002:a17:902:442:: with SMTP id 60mr97891519ple.107.1555610684146;
        Thu, 18 Apr 2019 11:04:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555610684; cv=none;
        d=google.com; s=arc-20160816;
        b=ftPXO1dtEjq7Qi9qICQHF+rg57j0qs0H5A1Bd2PgWMSEjdh49VQPIbG8WNmO3MSlOF
         3aRDgU3m6HlxDrQQyePBX7/7d2nHVnIGU4WpmdZsr4rIaMEI1k9xfYUUwezM36SYJfAd
         vl37eemLi+iIafB+Dg0apy8/Eb7jWqwfAcNkHKzOo3Dg0ekmWEgZRufyyYxICdSGMg2f
         Hzgixj/qizX/9JZhYlQWoFeNuGVt7yOnipR+0cM45RXjF+YaGaShymKfmpNvlzwzixRP
         goXVC6kxW26bqMVz5G0BmMxbRG1qb2XM5d1NwkeXKfFgv6aptldqcCiGdRvPKeZMZON3
         ybrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=nyD1XsBQY82CeJGECiRnHzq5/mZwh+IClLs8oH+5N10=;
        b=zlAYkz/AoSlRpqLmN0+1KCUHvueVdODzgrxuHZ3KUaBuXRjw4ouRElulTsBY/5yota
         5lBJ2lkFA6+7hER9qHpoE8ROvFowJGiDV/b7N/30z5PRxo0eTScNQ6GwcRDU8iDg3F5d
         TlASjhhLn+1SdwuAmF+h9EuW1/zaM4UVcsqeVZPLy9wl/vWCA8Jg6Kz9WEWTu4qbcILB
         8asuNE8cN2BhIaIMyDgsEK3XHtEU24hWElr10qK/mPtBPJmsOokyf2I1eGBiommAXgtd
         UKBkBN1TkDNaHvwZGlcGMGHo7+PgogOfC05s6lHgI3aAQhL/rqN2Y75rUdPi0HdGiWvF
         G6Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Sa0qcggn;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=UbZ7bYAj;
       spf=pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90117e5206=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o12si2393056pgp.94.2019.04.18.11.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 11:04:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Sa0qcggn;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=UbZ7bYAj;
       spf=pass (google.com: domain of prvs=90117e5206=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=90117e5206=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3IHjbVE017692;
	Thu, 18 Apr 2019 11:04:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=nyD1XsBQY82CeJGECiRnHzq5/mZwh+IClLs8oH+5N10=;
 b=Sa0qcggn9/W1DCYcoKMn1EqwHPtOe/VOZdPTKrWFStfkochgbfuOjSksgVWUnFKSOJ8P
 2PEiX50mr1rcRzp2wVI0QWRbgIUrraRVXGG8lgSp9IbzCMLE8I1w7sTp43mcyqS9kFJ0
 9mUpo1JlCQwOu9IPkqX7FYJd9GINxpvTUpE= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rxj0bteap-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 18 Apr 2019 11:04:31 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 18 Apr 2019 11:04:29 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 18 Apr 2019 11:04:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nyD1XsBQY82CeJGECiRnHzq5/mZwh+IClLs8oH+5N10=;
 b=UbZ7bYAjhMOyu6cogHZN0iRwgYu0i3VJMqeSfFKKlrFml9HMrZDIWK0P43o2Kd8gyts66OszOXw0tn83ilevBIiQBm4legnczn4aBwIH2S1wjXj8RwY3IjpQgyhFMT+uBydsZzGQKH8dwVgghShISsbAlGkPL3hda8o9DvXygYo=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2598.namprd15.prod.outlook.com (20.179.155.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.12; Thu, 18 Apr 2019 18:04:27 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.021; Thu, 18 Apr 2019
 18:04:27 +0000
From: Roman Gushchin <guro@fb.com>
To: Christopher Lameter <cl@linux.com>
CC: Roman Gushchin <guroan@gmail.com>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        "david@fromorbit.com"
	<david@fromorbit.com>,
        Pekka Enberg <penberg@kernel.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>
Subject: Re: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle management
Thread-Topic: [PATCH 4/5] mm: rework non-root kmem_cache lifecycle management
Thread-Index: AQHU9WhFLwAo90XwHUSqs2s91sh5hqZB7DAAgABLTYA=
Date: Thu, 18 Apr 2019 18:04:27 +0000
Message-ID: <20190418180421.GA11008@tower.DHCP.thefacebook.com>
References: <20190417215434.25897-1-guro@fb.com>
 <20190417215434.25897-5-guro@fb.com>
 <0100016a30a83bcf-7f99039c-77ec-4c48-a1c4-92e398f8f185-000000@email.amazonses.com>
In-Reply-To: <0100016a30a83bcf-7f99039c-77ec-4c48-a1c4-92e398f8f185-000000@email.amazonses.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR10CA0061.namprd10.prod.outlook.com
 (2603:10b6:300:2c::23) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:497d]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e06f99aa-5c21-4301-a429-08d6c4284c0b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB2598;
x-ms-traffictypediagnostic: BYAPR15MB2598:
x-microsoft-antispam-prvs: <BYAPR15MB259845626DAE16DE2A62A5C9BE260@BYAPR15MB2598.namprd15.prod.outlook.com>
x-forefront-prvs: 0011612A55
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(346002)(396003)(376002)(39860400002)(189003)(199004)(81156014)(7416002)(14454004)(316002)(54906003)(46003)(86362001)(186003)(11346002)(476003)(52116002)(446003)(99286004)(76176011)(6506007)(386003)(486006)(6512007)(9686003)(97736004)(53936002)(6246003)(5660300002)(102836004)(25786009)(1076003)(305945005)(6436002)(7736002)(4326008)(68736007)(256004)(6916009)(229853002)(6486002)(478600001)(4744005)(6116002)(81166006)(2906002)(33656002)(8936002)(71190400001)(8676002)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2598;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: JbZp0dA45yXhLdF+2x9L89yc3AUHz2IG9N6hffaKyL1t/FDi6LQjfyJ8Zict3qaZPYhJbfDa2Fi7I/lakWcpNosX80BQ9+DfDJHB1SL+FmVn8i91MlZ3Ts1Px+N09014IsaI8LjB8ZVjT5jv6meBE5cJ0J3tmAaeoUN4uRiW0x6RoJoAWID6ubpHE3Eh54mZICKwMWG1st5wiPLEYEE9SbbeFXNTTo7c5ofYUq41ABLo/GMyLmO/5qLwvp2fBbyn+7ElFwDES9hgyXH+MSV3L3r7SWg0fQCSU0E2HKyvMMRr0yxMZheEiKFrtHzuCmubcE46WbFMchfcL75R98jFuumue0VQS+ByNhNmyrdaZxw1WSZl6g5CALuVfriWGms4mC54x1kzsyRpFY0RLCyXrd9bfyW29PdEb5ci84XPXQk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <C681190BAEEB0F48889A8944DCADA4D8@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: e06f99aa-5c21-4301-a429-08d6c4284c0b
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Apr 2019 18:04:27.5813
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2598
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-18_08:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 01:34:52PM +0000, Christopher Lameter wrote:
> On Wed, 17 Apr 2019, Roman Gushchin wrote:
>=20
> > Let's make every page to hold a reference to the kmem_cache (we
> > already have a stable pointer), and make kmem_caches to hold a single
> > reference to the memory cgroup.
>=20
> Ok you are freeing one word in the page struct that can be used for other
> purposes now?
>=20

Looks so!

