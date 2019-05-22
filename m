Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6482C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 17:04:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47E962070D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 17:04:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nkK3gtoO";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="n9VmEX5C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47E962070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D14AF6B0005; Wed, 22 May 2019 13:04:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC48A6B0006; Wed, 22 May 2019 13:04:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8BA86B0007; Wed, 22 May 2019 13:04:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9935B6B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 13:04:02 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g19so2606364qtb.18
        for <linux-mm@kvack.org>; Wed, 22 May 2019 10:04:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=WgCGtBQOvcWvqhCP4BvVezpXhGfHNgoGFhAqyvMtHLY=;
        b=Kgjyk5Gme0UWQwszpOp31EplcTRkNUOpJ1IBnp8YBTJU/5qKaYiAPYVYmp7YIU9NvG
         AuivoEVddhbQrcuCUvpXd6ryBkd855Ig75BGHHk/EuaJsEWPQOL6LpwAptYbwGXeE/eC
         qfiMEElKX1SGBPpHMjlVK0Y0v14uF2yBU678HOT8hE9Vl1NRWfFL8lW4HjWaAZ0P1Efn
         9JZ+nEdYYp0lXN7FpPEAseItOgsxMxyp58eZZlmI+MKwZ5QdauOOszHHe7/6R+MFjtRQ
         AMCq3zpykBReidi1xAdHYR7gwfGJhuRIS4wqyEtf1KeYt5C1nvoPhf2u3oYzuQN2zVce
         o7vA==
X-Gm-Message-State: APjAAAWhee6ZisHgGZEo6utSz/X+1RYSVG5tg/bLGaq4R64uh1p5LtQb
	K1WS5Jx2XDISMw9a3YAKGYyF8qeV4fjzMbxUasgFeg/5m2Nhy/gV1ZAPFSSz5aG6s3Fp08mtm1Q
	4BjFESYqcq5FZ+aXsWCGt59CuaZPT2EPkpTN1ppM1LdFTvzVqbNLF2CdaawrTTLfS7Q==
X-Received: by 2002:ac8:1c59:: with SMTP id j25mr70284957qtk.358.1558544642325;
        Wed, 22 May 2019 10:04:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYAgb5zirYAM4eTYcyDr3j58uA9ORf85IQRP1MKycliMNatV389qUmMON5uJuMQbHEPkF8
X-Received: by 2002:ac8:1c59:: with SMTP id j25mr70284854qtk.358.1558544641256;
        Wed, 22 May 2019 10:04:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558544641; cv=none;
        d=google.com; s=arc-20160816;
        b=IbGSvEOBeQu48Y32JvX84I2pbZW9wS2Wo1lglH6Cww2TZxRaboFkOnAnJ0ZyJ+cBMn
         JfVCNWlTjFlOWVhAa62aQuSLQHHkaFdRrb0TETshF1tOPRCz284LjaNH0mJVhouCA0aa
         Lj9ZHL1su384nW0micfEwUgaScqc2lc1epjFKYWtPYcp/tzis/BvHrg0Lwa+HKfYYNLt
         jJKGm8ZDDQWWIrKtXOIiOWUpRd78UD8i3hgwrd2AxWIYTi588etKj3bH0rRweuBRQWsD
         2QD4E5k4NtHQ8GIxpcQyZwbr4zRfyY5nw9sQ9chzZn9FP2XHUVg8Riw6W6ihH/x2jjo8
         r7aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=WgCGtBQOvcWvqhCP4BvVezpXhGfHNgoGFhAqyvMtHLY=;
        b=sCLCP2MqYo0s0fBCOmCjuq9dyN1D5sKH4qEtwrDjwwaIxOAd++kx0QmejRDfrtIuZG
         BjrZqLQJOrIG6+pTc5FxXAXWYkzQtapPqj+vNf5N/Ar47Lxv1EeTv4W2I9n+FG2zy3nk
         B81Y+dj1ZnmeqZjxqNwO7dQBQxc8uTPe+vmHWVFtqhPXe+mtviZo21OWwWN1kSgaOjOE
         UBgn+bdnSKP2iRzYdDayjE+A5OnJYgzqdAa0BSKll/irjyMYiXtMjfFFc7Vx3hrAce7E
         6+gZ68iBqbh5TU7tnDNUHMVkXAzbMko0tU03ynz4LAsAN8rGNxi/kUwSOw+TyH0dH5ME
         GDMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nkK3gtoO;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=n9VmEX5C;
       spf=pass (google.com: domain of prvs=00452a55eb=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=00452a55eb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l9si3457826qvt.183.2019.05.22.10.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 10:04:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=00452a55eb=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nkK3gtoO;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=n9VmEX5C;
       spf=pass (google.com: domain of prvs=00452a55eb=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=00452a55eb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4MH3sIY027947;
	Wed, 22 May 2019 10:03:55 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=WgCGtBQOvcWvqhCP4BvVezpXhGfHNgoGFhAqyvMtHLY=;
 b=nkK3gtoOi6vwAW5msMF9SKxD1B/0BEI8qfPkcMlYx/ccJArqND7QOozRpt5rNxUtnm43
 LP5DK9cnrjSEygS9Q8bwUUitngaDFB1jIlEZ2nNdJVEC6Y1V6Ym4YfUFbdxBUJAYvS45
 Vfkpxm7JCOwiyfoJcgz9I3MAuAkVefVkc3g= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2snabk01cy-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 22 May 2019 10:03:55 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 22 May 2019 10:03:51 -0700
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 22 May 2019 10:03:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WgCGtBQOvcWvqhCP4BvVezpXhGfHNgoGFhAqyvMtHLY=;
 b=n9VmEX5CJ1tUiunRMmjLdw49CqMRQl+7KYycA8e3huw7bX/1neemEaT1RZ3OojdaOhwuy42cPdSKsWUyucAZRk8Wa9xW5Acai0iXbFehWrhkroorRrhYB/74ucO6row2yde2S2222ADzcxby/0zJRjHz9+1x7yQKDV/ccN/JdK0=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2342.namprd15.prod.outlook.com (52.135.197.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.18; Wed, 22 May 2019 17:03:48 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1900.020; Wed, 22 May 2019
 17:03:48 +0000
From: Roman Gushchin <guro@fb.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
CC: Michal Hocko <mhocko@kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Vlastimil
 Babka" <vbabka@suse.cz>,
        Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] proc/meminfo: add MemKernel counter
Thread-Topic: [PATCH] proc/meminfo: add MemKernel counter
Thread-Index: AQHVEKxMijk76PIMmkOK94/In9VVJqZ3S1QAgAAEwgCAAA8xAA==
Date: Wed, 22 May 2019 17:03:48 +0000
Message-ID: <20190522170342.GA11077@tower.DHCP.thefacebook.com>
References: <155853600919.381.8172097084053782598.stgit@buzz>
 <20190522155220.GB4374@dhcp22.suse.cz>
 <177f56cd-6e10-4d2e-7a3e-23276222ba19@yandex-team.ru>
In-Reply-To: <177f56cd-6e10-4d2e-7a3e-23276222ba19@yandex-team.ru>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR11CA0013.namprd11.prod.outlook.com
 (2603:10b6:301:1::23) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:b434]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 69b3b830-ba92-4b9c-66b6-08d6ded7750b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB2342;
x-ms-traffictypediagnostic: BYAPR15MB2342:
x-microsoft-antispam-prvs: <BYAPR15MB234221F12D2BEDBD57E5A8F3BE000@BYAPR15MB2342.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0045236D47
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39860400002)(136003)(366004)(376002)(346002)(189003)(199004)(476003)(64756008)(99286004)(66446008)(66556008)(66476007)(486006)(11346002)(54906003)(9686003)(68736007)(86362001)(5660300002)(6512007)(14454004)(8676002)(186003)(66946007)(76176011)(102836004)(52116002)(446003)(386003)(6916009)(25786009)(6436002)(73956011)(6116002)(6506007)(53546011)(81166006)(81156014)(46003)(478600001)(4326008)(7736002)(6486002)(305945005)(8936002)(1076003)(256004)(2906002)(6246003)(316002)(229853002)(33656002)(53936002)(71200400001)(71190400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2342;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: J0zDvcUSItJHCsRmFsZQ6kXrOXe3JuZ+VZ2pzsenzrCK6bVkyg2ufgncaBqDNj4VI23JZUn0ke9lNaiH/a5Dwj7PUawUbjSgP+qhcrzQhjFrI2H0VgkIbI9Nvs/pkCiFl0tE9/DvgsfSkpv3LEvK8KRZZ0wzbIJ7GCZqGYVC5THiiszSvwlAhel4XwP9R94TKaTd5u7dLTeC+YCxdLFzXnGoMpyiVHEIV5geoIvgxNkjMbbfBum5eO/aZeQKkMrcpXLSnbIEve3ivNtt/oqwoicx+2k1TQ3N4GMYgR6jsPKlvvO2m6hqtxJcfcHTfkap4a1TkY4uGbE4poWIK7La67EmPirJlSBnJF/lEiZ0bbf9h3OTAqzSe3nuO8d53/rH5zC97lVRIRljM5jaZc4+DL1U73pg3YAsDXjSaKhFzao=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <60F765A80C84264D94E551496AAD5BB6@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 69b3b830-ba92-4b9c-66b6-08d6ded7750b
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 May 2019 17:03:48.5478
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2342
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=883 adultscore=1 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220120
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 07:09:22PM +0300, Konstantin Khlebnikov wrote:
> On 22.05.2019 18:52, Michal Hocko wrote:
> > On Wed 22-05-19 17:40:09, Konstantin Khlebnikov wrote:
> > > Some kinds of kernel allocations are not accounted or not show in mem=
info.
> > > For example vmalloc allocations are tracked but overall size is not s=
hown
> > > for performance reasons. There is no information about network buffer=
s.
> > >=20
> > > In most cases detailed statistics is not required. At first place we =
need
> > > information about overall kernel memory usage regardless of its struc=
ture.
> > >=20
> > > This patch estimates kernel memory usage by subtracting known sizes o=
f
> > > free, anonymous, hugetlb and caches from total memory size: MemKernel=
 =3D
> > > MemTotal - MemFree - Buffers - Cached - SwapCached - AnonPages - Huge=
tlb.
> >=20
> > Why do we need to export something that can be calculated in the
> > userspace trivially? Also is this really something the number really
> > meaningful? Say you have a driver that exports memory to the userspace
> > via mmap but that memory is not accounted. Is this really a kernel
> > memory?
> >=20
>=20
> It may be trivial right now but not fixed.
> Adding new kinds of memory may change this definition.

Right, and it's what causes me to agree with Michal here, and leave it
to the userspace calculation.

The real meaning of the counter is the size of the "gray zone",
basically the memory which we have no clue about.

If we'll add accounting of some new type of memory, which now in this
gray zone (say, xfs buffers), we probably should exclude it too.
And this means that definition of this counter will change.

So IMO the definition is way too implementation-defined to be a part
of procfs API.

