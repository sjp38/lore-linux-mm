Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93F21C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:46:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36353206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 21:46:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="njo1wa8+";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="YaYBJnO4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36353206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8F8B6B0007; Tue, 13 Aug 2019 17:46:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3FC76B0008; Tue, 13 Aug 2019 17:46:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B06C06B000E; Tue, 13 Aug 2019 17:46:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id 89D656B0007
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 17:46:54 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1961818DF
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:46:54 +0000 (UTC)
X-FDA: 75818739948.09.hope06_7656483f0663e
X-HE-Tag: hope06_7656483f0663e
X-Filterd-Recvd-Size: 10028
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 21:46:53 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7DLilAp026091;
	Tue, 13 Aug 2019 14:46:50 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=A1qkOJNoz7cDcs5D5ISvypaHekdRCaquHQOEHbzqI9w=;
 b=njo1wa8+mL6xuWAqEgD2mv+be0KXoOwT1q7ryXcHA6yfXNe4BL2d7dHNQ+eHWq2XyQW3
 1f1ki9ftkFdNURI8/d0f8BmYFuMRlQnqNy8PU0qFVrrbazg5qj9PZnC7fPayrUcGhl6q
 E9Ti9pJcSbHQ8KFFxy70Jtnjik7hmqZksS4= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2uc4uhg610-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 13 Aug 2019 14:46:50 -0700
Received: from ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) by
 ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 13 Aug 2019 14:46:48 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 13 Aug 2019 14:46:48 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Cvq83mT2GtS/FcCEcA89g74OT3hNaOt1dNtBxs5eldlMPM8kZoksXltFrFTrWga5H6wQZvyJGQUZZUaudVoLM6aCSWc2Z4lZVPoiV6Dw0Ee1tAVhnNVvilsHMvMxUpoO9+4FQrtrmScYsc3Zh2c1ef5+igsD1S2kX0Ix6HIkiu2337jbRHndpYABg5Poc+91LvVMV9KmyORcpqa0LYu6DKU6YCRKRuVC91HgQOxTW8npu6muTXBfeO6dbcAU+B0GneSZ+rzgPeLW2NY5TSt9+diXoKtlA2fr9sb69SBx+zPgzyJHVF5qTxFh+Oou6+pgb4DOjtNiffoKQ/V3FhXBGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=A1qkOJNoz7cDcs5D5ISvypaHekdRCaquHQOEHbzqI9w=;
 b=Sl7B77WnBYT45Z5ekSBhvWcXHgXaPROTayKEhd+na0rBOoTLEj5ZoJxkeLxbzFUSF6VtNGxCMCRE1QARyzSmQmRcYpjHLt7/qBQZGdj5NC7OZTHhcN2ovH4iJugOnM5S0fpVs08DJdUBMXjmMW2vsaMJqqvfDt/54U18Xly8O3T6rF/yxkEv0v1Vq5ejhLnLhDrOlQbd9285IZjTMDFR3qa9wFkjG3WnxtPYp0dBov+KP+e68qqQ8/K1lPMNqNnv8dqzmnBjzuOnnVKEFEylj5jMK1smI/tvDh3dW/RoyaoYYVu31BkZxM4iJdwhuvCSkxpDyfSkkUfalKKhyfXtXQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=A1qkOJNoz7cDcs5D5ISvypaHekdRCaquHQOEHbzqI9w=;
 b=YaYBJnO4uJBQwNHaQvLthO4UUnBAMBGaTQgLPZQ5kR2EIz3MGNK3h8r85aiwLs9/SpXzHHdgzxZB8kSuA+4tAdbAtuPNDsWSmyw91pmbQxp1TA0RuImjXyeF2YvqwZXTDrpgsYRAnEJxCLWs/KRCFdjRdgj5fdwGTbQI5t5RqlQ=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3113.namprd15.prod.outlook.com (20.179.17.74) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.18; Tue, 13 Aug 2019 21:46:47 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2157.022; Tue, 13 Aug 2019
 21:46:47 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Michal Hocko
	<mhocko@kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: flush percpu vmstats before releasing
 memcg
Thread-Topic: [PATCH 1/2] mm: memcontrol: flush percpu vmstats before
 releasing memcg
Thread-Index: AQHVUV1hR8jmqP/+sEWQCJ0sb/bX4Kb5mTIAgAAFRIA=
Date: Tue, 13 Aug 2019 21:46:47 +0000
Message-ID: <20190813214643.GA20632@tower.DHCP.thefacebook.com>
References: <20190812222911.2364802-1-guro@fb.com>
 <20190812222911.2364802-2-guro@fb.com>
 <20190813142752.35807b6070db795674f86feb@linux-foundation.org>
In-Reply-To: <20190813142752.35807b6070db795674f86feb@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR0201CA0015.namprd02.prod.outlook.com
 (2603:10b6:301:74::28) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1f63]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8ef3ed42-ad7c-4b9e-c4d0-08d72037bd65
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB3113;
x-ms-traffictypediagnostic: DM6PR15MB3113:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <DM6PR15MB31139A21B7ABD6ACEF94A3C5BED20@DM6PR15MB3113.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 01283822F8
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(376002)(346002)(396003)(39860400002)(199004)(189003)(52314003)(25786009)(14454004)(6436002)(76176011)(229853002)(66476007)(54906003)(66446008)(33656002)(102836004)(66556008)(52116002)(6486002)(66946007)(316002)(6506007)(386003)(186003)(6512007)(9686003)(446003)(11346002)(5660300002)(476003)(46003)(6916009)(1076003)(64756008)(86362001)(478600001)(486006)(7736002)(2906002)(6116002)(305945005)(6246003)(8676002)(81156014)(81166006)(4326008)(99286004)(256004)(8936002)(71190400001)(71200400001)(53936002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3113;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: pwbVfuBOtcH/OZvPSXkkkUCSaRx6cfmp5OVpHRLYM8QnAawzkfv/2ZHf1ekG2aKgr8A5PX+q2SNB9QtDyVl2y6oP+R9i8TBYH/vINZfXbi5z1k80oB5zTdxWkdtI6xMOVSA+9gE772eZT3ag5QoysXHYzZggay0iMGHqsjkVKBluR9S68xNkHN7jMUT/IBjmx2BYY8Jqs6LO/iF8uon0uROcDQ8EuhIgqybsTtfAyoqMinmaHMT4NJDNa9lX4H+ijYKFT2ELvqHroaR9AlH5Ch9CZ6YBB3iOfBmu08iut5V/oNKkZxAo+1iwkpTk5JQ/1QvpN6PUXYpeUnITjPEWcOmYhiPvY+d+6tzjYZ8RQ46EkmDxdRLI1xal+/OKgtbPf0Q/wrvQjqGFXUA9hoeyPWijuOIC8RthNO7x4xZRjP0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7D0DDF28E818024486ACB710C386B46B@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 8ef3ed42-ad7c-4b9e-c4d0-08d72037bd65
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Aug 2019 21:46:47.1496
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: nDCf2U76pO3YZaQsQ00neIHtbBSc2KXsX/rHPhQ34o2x+VIRQGM4AhaNv5YsRxI+
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3113
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-13_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=854 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908130203
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 02:27:52PM -0700, Andrew Morton wrote:
> On Mon, 12 Aug 2019 15:29:10 -0700 Roman Gushchin <guro@fb.com> wrote:
>=20
> > Percpu caching of local vmstats with the conditional propagation
> > by the cgroup tree leads to an accumulation of errors on non-leaf
> > levels.
> >=20
> > Let's imagine two nested memory cgroups A and A/B. Say, a process
> > belonging to A/B allocates 100 pagecache pages on the CPU 0.
> > The percpu cache will spill 3 times, so that 32*3=3D96 pages will be
> > accounted to A/B and A atomic vmstat counters, 4 pages will remain
> > in the percpu cache.
> >=20
> > Imagine A/B is nearby memory.max, so that every following allocation
> > triggers a direct reclaim on the local CPU. Say, each such attempt
> > will free 16 pages on a new cpu. That means every percpu cache will
> > have -16 pages, except the first one, which will have 4 - 16 =3D -12.
> > A/B and A atomic counters will not be touched at all.
> >=20
> > Now a user removes A/B. All percpu caches are freed and corresponding
> > vmstat numbers are forgotten. A has 96 pages more than expected.
> >=20
> > As memory cgroups are created and destroyed, errors do accumulate.
> > Even 1-2 pages differences can accumulate into large numbers.
> >=20
> > To fix this issue let's accumulate and propagate percpu vmstat
> > values before releasing the memory cgroup. At this point these
> > numbers are stable and cannot be changed.
> >=20
> > Since on cpu hotplug we do flush percpu vmstats anyway, we can
> > iterate only over online cpus.
> >=20
> > Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctn=
ess & scalabilty")
>=20
> Is this not serious enough for a cc:stable?

I hope the "Fixes" tag will work, but yeah, my bad, cc:stable is definitely
a good idea here.

Added stable@ to cc.

Thanks!

