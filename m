Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9BF5C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 21:12:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BCD4214DA
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 21:12:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="PYHDcclZ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="aaH5wOsA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BCD4214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED97C6B0005; Mon, 19 Aug 2019 17:12:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E88EE6B0006; Mon, 19 Aug 2019 17:12:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D29926B000A; Mon, 19 Aug 2019 17:12:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0035.hostedemail.com [216.40.44.35])
	by kanga.kvack.org (Postfix) with ESMTP id B01576B0005
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 17:12:27 -0400 (EDT)
Received: from smtpin12.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 51430181AC9AE
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:12:27 +0000 (UTC)
X-FDA: 75840425934.12.screw95_1553a8e6e4e0c
X-HE-Tag: screw95_1553a8e6e4e0c
X-Filterd-Recvd-Size: 10607
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:12:26 +0000 (UTC)
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7JL8txA003079;
	Mon, 19 Aug 2019 14:12:08 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=+uP8N6sjzFxj9Z3+ZJ3W3XE+YdhhMaxnxoFPRLf4bpQ=;
 b=PYHDcclZgl80IPxAxotVJMcyS0ZaLRYmvI6mC0+EDHPV3FWp5yMTC13Or8oVx5bNw54J
 zQexh218yPoChU9BF7WmfT0O6qmRe5HUyD8MnCLOjeDyRruVSjubEaN+i9Lbo8gw9Tzd
 8UoZJDt0JSfx1vDyxyujwH0mXuGPC0bE/AQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ug3e8r0ew-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 19 Aug 2019 14:12:07 -0700
Received: from prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 19 Aug 2019 14:12:06 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 19 Aug 2019 14:12:05 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 19 Aug 2019 14:12:05 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=PZMMICHVodKGqYuyjdlMVBPPHDoo0ekm1UlqPaiqJJp0xRe3TJkbYtfWyPolakM1FgLq7POdsY1CueQItT6sieUcrSnblHoy65ak3CnLxl7cIjC3OKvbzDCCj9PlLwG9AzYr32Y+yez4w54nYeGTUKUHsrtfkY8ilcQh2pauwpebogO/UHybXnfX7lascpnceT21xz+AwLG+ELX1UTNRN2Mm2domXClifiK5nEMoyhg0c7vdpfYLPbIKoaJm9m7a1p45VuRoAIgYSy6LzCs34FLxpoyFQFGQykHIqkmZMuwJMNX79ke/zUBSZHpXtZzzZc4XjWsX9lEMl14XUhCT+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+uP8N6sjzFxj9Z3+ZJ3W3XE+YdhhMaxnxoFPRLf4bpQ=;
 b=AXK1TNj0mQpHkPeMDHlYw6I6o/5GOG+Lp7xrcr6wrNjhwuIUpYOO5BL+fmbr/rjLhFjhdqPtKjorUBwM9ZqaWTAFedDirRcF/mdOlIlsVh1cRQYIcYJ1MBRMUpCOF0uT2Ba28JKfakqMVFEeqiVRivsDKEm8uVSf9j3GfYHYZdv420N88tMH3yBh6tFiOOGr1dn4PLEedi/rWZsedubhrAhGUcds9Ka5hQOxyOKJBBPW0EVOyEot9dhMn+yQAHF2z7YkNlwbliatrMaXhHti8a6BsNviKt0BhqfTOySBPdpAHnG3oA0sdNSMOTeDD29rHWmS1hP73HIBbVl6zzfAjg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+uP8N6sjzFxj9Z3+ZJ3W3XE+YdhhMaxnxoFPRLf4bpQ=;
 b=aaH5wOsA9DrSRziZ1/p3dPkMsWIRai88zqreWNJ4ituFbkuOAYdkk1zSYSZBAySGSagrOJ56hfBeO1kVvwEUA5sdY5mMF+x/Vso87HAToLdiGyQCo5NU8b4T9gMgEmYJj/jViCP1EaiWBkKmbkRSsNAFYscxi286gDArs8XmJmo=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3545.namprd15.prod.outlook.com (10.141.164.91) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Mon, 19 Aug 2019 21:12:05 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2178.018; Mon, 19 Aug 2019
 21:12:05 +0000
From: Roman Gushchin <guro@fb.com>
To: Yafang Shao <laoar.shao@gmail.com>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Randy Dunlap
	<rdunlap@infradead.org>,
        Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko
	<mhocko@suse.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Tetsuo Handa
	<penguin-kernel@i-love.sakura.ne.jp>,
        Souptick Joarder
	<jrdr.linux@gmail.com>,
        Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
Thread-Topic: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
Thread-Index: AQHVViv/4dAlisUxW0emrEnYHi/MH6cC+SMA
Date: Mon, 19 Aug 2019 21:12:04 +0000
Message-ID: <20190819211200.GA24956@tower.dhcp.thefacebook.com>
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BY5PR17CA0024.namprd17.prod.outlook.com
 (2603:10b6:a03:1b8::37) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:4a49]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: db2c0546-eb54-44fb-dfcf-08d724e9e2c3
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR15MB3545;
x-ms-traffictypediagnostic: DM6PR15MB3545:
x-microsoft-antispam-prvs: <DM6PR15MB35455DA903387C39575A5256BEA80@DM6PR15MB3545.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0134AD334F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(376002)(346002)(39860400002)(136003)(199004)(51444003)(189003)(54906003)(33656002)(25786009)(6916009)(53936002)(6512007)(6116002)(1076003)(229853002)(2906002)(9686003)(81156014)(6486002)(66476007)(4326008)(81166006)(8676002)(6246003)(6436002)(5660300002)(66446008)(8936002)(86362001)(14444005)(186003)(76176011)(256004)(305945005)(14454004)(7736002)(52116002)(64756008)(66946007)(71200400001)(71190400001)(99286004)(66556008)(102836004)(316002)(478600001)(46003)(486006)(476003)(446003)(11346002)(386003)(7416002)(6506007);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3545;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: RzX6pjfKwJBXkTTOWiM2AKzLtUmRV0k8uadmWI5VB/7jjpbKGb9+iGkoLomOCcE/5O+Z3AuzWKyAXawqRBpSNq6lbkRv88u/yyx4hOsTc0w1JZmjaaePLoppvQ8EQJz64ZJgMmjXhlxaEgScfevWgYv9uszKJ4iTeG9kGg8cCq6jHb0VsBxB/o+jyvO6PDkjo+rm8JZs5UTVVxEIvmoosHk2sEcr91JAD5Zy2OFgNCnM2ToxMo7JAMa+fRMfKN9/yQr17D2s0uB0Ju0zYUPA+ALQVOrqIit4gup98sgaYwM13vMkNAXEjjKjBxMieDhVeH800pCxwb9mZVzT/bej1yot2/+Pi6gWY7oDcW7PxCx31Pm+JdNjYnNXDagCGFO+mPD8daV0ooXsn2bsVTYKxVEtwtCkbGnRVBmy9TvOhFk=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <10AE1AF2F41CF24592EFFA931D6A2484@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: db2c0546-eb54-44fb-dfcf-08d724e9e2c3
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Aug 2019 21:12:04.9550
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: zurgKvWqzs/YOsZEqiWGUseYz+fHyRw2DDpVBnmv1uYu8oRf7JIcyWCr6psHJoS4
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3545
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=629 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190212
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> In the current memory.min design, the system is going to do OOM instead
> of reclaiming the reclaimable pages protected by memory.min if the
> system is lack of free memory. While under this condition, the OOM
> killer may kill the processes in the memcg protected by memory.min.
> This behavior is very weird.
> In order to make it more reasonable, I make some changes in the OOM
> killer. In this patch, the OOM killer will do two-round scan. It will
> skip the processes under memcg protection at the first scan, and if it
> can't kill any processes it will rescan all the processes.
>=20
> Regarding the overhead this change may takes, I don't think it will be a
> problem because this only happens under system  memory pressure and
> the OOM killer can't find any proper victims which are not under memcg
> protection.

Hi Yafang!

The idea makes sense at the first glance, but actually I'm worried
about mixing per-memcg and per-process characteristics.
Actually, it raises many questions:
1) if we do respect memory.min, why not memory.low too?
2) if the task is 200Gb large, does 10Mb memory protection make any
difference? if so, why would we respect it?
3) if it works for global OOMs, why not memcg-level OOMs?
4) if the task is prioritized to be killed by OOM (via oom_score_adj),
why even small memory.protection prevents it completely?
5) if there are two tasks similar in size and both protected,
should we prefer one with the smaller protection?
etc.

Actually, I think that it makes more sense to build a completely
cgroup-aware OOM killer, which will select the OOM victim scanning
the memcg tree, not individual tasks. And then it can easily respect
memory.low/min in a reasonable way.
But I failed to reach the upstream consensus on how it should work.
You can search for "memcg-aware OOM killer" in the lkml archive,
there was a ton of discussions and many many patchset versions.


The code itself can be simplified a bit too, but I think it's
not that important now.

Thanks!

