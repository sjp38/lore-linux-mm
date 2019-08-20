Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86262C3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 01:40:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EF1022CE8
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 01:40:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="iQ2UBd7r";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="W2xmniMS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EF1022CE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A24A36B0007; Mon, 19 Aug 2019 21:40:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 077C36B0008; Mon, 19 Aug 2019 21:40:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBEF76B000A; Mon, 19 Aug 2019 21:40:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id B3E956B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 21:40:19 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 75B338248AB7
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:40:19 +0000 (UTC)
X-FDA: 75841100958.15.rail88_1fd5b8f20fb1c
X-HE-Tag: rail88_1fd5b8f20fb1c
X-Filterd-Recvd-Size: 12319
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:40:18 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7K1Z62g026993;
	Mon, 19 Aug 2019 18:39:58 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=DuqnWFM3Jvt1pTYtStJbRE+xtpdk05T3gL41pQkNgzk=;
 b=iQ2UBd7rw4P4tBldIUWC4aeE7vbpSaw//MM7faKYYyjy8Wz6xl7oN32JTXNpCkaDcsyX
 NrUqvArYgnZNV3TQsW1Aah3tPvo5VV2ucoRbd6zYgGtl40AQDcKZAHwWd+IgRWxksPsX
 G6PAXjW5NiFFl7QT2nowBCH45jpo79EJvMs= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ug45p8q6t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 19 Aug 2019 18:39:58 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 19 Aug 2019 18:39:57 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 19 Aug 2019 18:39:57 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Q5UCGWyKW0sdgaVAnP+moma2tS6k0jSRXvBEnmhK2aiGIZ/NO3dBZavERr0T/w0AudJAw+bhiLzuiynDX4ZqLKwgZBr4dVcx3rOFCkVGTwxsCcsplaoj2k4SGeUbKoA3JSsluaz9c+CO6XO8cy11Rk3mR+u7WV/uqbdfs6MGkARhcmfx27SEKWYhe765TYtScZt/P9Mm4q6PoB2U1Mm/BvrnF40mlA65coVSvZYGwNVxgvYJZ51/nKy4+fWHbvV7Dp33XvIxKq4YT86BljeLaUQ7oGK6+sKASe78xMTXC3nyC/SrkJBTlJTffqI2XD1q4JmsPcvYHhHqn9ypWjESag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DuqnWFM3Jvt1pTYtStJbRE+xtpdk05T3gL41pQkNgzk=;
 b=N+IRT/YA2xieEo0TX4gszKoTuqKgXT9xes/ml1FmV4gKebkUQVWToWuhE5PNNqn5QxunUdhHmzu1cOA2ZqF7s5/eh2GzJ7Acqd5c6nV0tZycawlXjXmA4iUuC92ockhEXtzeUmQOb4+dw5uuhTqV4HSHo/DcMPSOOuu4vtRSNwTyCdB2ndS8HDLBplpaox8JJ41MxSJ1bjqpAz7hX2lr7l0c4NTvnEpot8h/8OVBcuUjHEpnLeRPUIVfiuvdS5U0fBEagF6paHgm0A3Kd/8ovmCRrZU5urPmyQ0oB1ixrEtt2QaHhyWNkz/POLvXVyRa7RQx/5k7IgKuwhmlY5mJog==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DuqnWFM3Jvt1pTYtStJbRE+xtpdk05T3gL41pQkNgzk=;
 b=W2xmniMSlhuan3XYciFAFbNIjKpS2kXDJRxds6T2rWVN6PpFt0Z51+6Z0v4l8bW0vyco2KISi4qKRTC7VUU2ZgCYIr6KsFeQdlhaXPaVLmwV3E6w7KJ+8gi8KKpbN+HT+lnqtBQAEuDMtMacAM1qfmfr70KENhXXrkwYmfc6zvg=
Received: from DM6PR15MB2635.namprd15.prod.outlook.com (20.179.161.152) by
 DM6PR15MB3609.namprd15.prod.outlook.com (10.141.165.95) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.18; Tue, 20 Aug 2019 01:39:55 +0000
Received: from DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e]) by DM6PR15MB2635.namprd15.prod.outlook.com
 ([fe80::d1fc:b5c5:59a1:bd7e%3]) with mapi id 15.20.2178.018; Tue, 20 Aug 2019
 01:39:55 +0000
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
Thread-Index: AQHVViv/4dAlisUxW0emrEnYHi/MH6cC+SMAgABELYCAAAapgA==
Date: Tue, 20 Aug 2019 01:39:55 +0000
Message-ID: <20190820013951.GA12897@tower.DHCP.thefacebook.com>
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190819211200.GA24956@tower.dhcp.thefacebook.com>
 <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
In-Reply-To: <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR21CA0020.namprd21.prod.outlook.com
 (2603:10b6:a03:114::30) To DM6PR15MB2635.namprd15.prod.outlook.com
 (2603:10b6:5:1a6::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:4a49]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2d38f1c3-b827-46ad-1cc4-08d7250f4d9e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR15MB3609;
x-ms-traffictypediagnostic: DM6PR15MB3609:
x-microsoft-antispam-prvs: <DM6PR15MB36092EE84033B0513D2E1C00BEAB0@DM6PR15MB3609.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 013568035E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(376002)(39860400002)(136003)(346002)(199004)(189003)(8936002)(54906003)(6436002)(33656002)(81166006)(81156014)(229853002)(99286004)(5660300002)(186003)(64756008)(14444005)(8676002)(6486002)(256004)(25786009)(66446008)(66556008)(66476007)(66946007)(102836004)(53936002)(53546011)(6506007)(386003)(11346002)(46003)(14454004)(7736002)(486006)(446003)(478600001)(7416002)(316002)(305945005)(6246003)(476003)(6512007)(52116002)(76176011)(4326008)(1076003)(9686003)(71200400001)(71190400001)(86362001)(6916009)(6116002)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR15MB3609;H:DM6PR15MB2635.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: asuAiTVr319E/FKMgODaQcl7a69Cvzu8K84oRvkyauEVlbGB5otcv6zEuMPTDcVWwRS6dmpwTqmJw00oXQ0Im2T+jPWkyigqc/jlHiKaCYqbXaS1xRdIm+OkWuheySOQ++qJIZ65p9XrT/yuuQ/lHyQh/RGjmvaGjG9BW0zSoUQEaS2JB2MnlB8w72FO1ODwbMYf5pX76lVzqJ3S1F7oYFFT7fQLPDUCum3E4uNKLCB6syASBd9JrDKoO+2pQUMczpITvqjDLwF8vaKRZ32KWZ8autspuVHoOqtjnU3VhOgYN+YYdyAfiai++XaIwniH73N2E/MNbK9Ah1IwaZeSogKyS0K8CvorD9mF31i2j4ZAS6798wfPZilj2nmb7YJa18x9dYANm+CbgYt9EcgYPLLKGbSaFmHb5YAU188u5ts=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7C61A9879A3EE646914162FEDA22C7A2@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 2d38f1c3-b827-46ad-1cc4-08d7250f4d9e
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Aug 2019 01:39:55.5468
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: pPVG5yCjeYx2dtFUneHh1uE538VO5XVzRHWNCRQ4T59SNhP31Mri8TXVSQujK2F+
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR15MB3609
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908200011
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 09:16:01AM +0800, Yafang Shao wrote:
> On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
> >
> > On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > > In the current memory.min design, the system is going to do OOM inste=
ad
> > > of reclaiming the reclaimable pages protected by memory.min if the
> > > system is lack of free memory. While under this condition, the OOM
> > > killer may kill the processes in the memcg protected by memory.min.
> > > This behavior is very weird.
> > > In order to make it more reasonable, I make some changes in the OOM
> > > killer. In this patch, the OOM killer will do two-round scan. It will
> > > skip the processes under memcg protection at the first scan, and if i=
t
> > > can't kill any processes it will rescan all the processes.
> > >
> > > Regarding the overhead this change may takes, I don't think it will b=
e a
> > > problem because this only happens under system  memory pressure and
> > > the OOM killer can't find any proper victims which are not under memc=
g
> > > protection.
> >
> > Hi Yafang!
> >
> > The idea makes sense at the first glance, but actually I'm worried
> > about mixing per-memcg and per-process characteristics.
> > Actually, it raises many questions:
> > 1) if we do respect memory.min, why not memory.low too?
>=20
> memroy.low is different with memory.min, as the OOM killer will not be
> invoked when it is reached.
> If memory.low should be considered as well, we can use
> mem_cgroup_protected() here to repclace task_under_memcg_protection()
> here.
>=20
> > 2) if the task is 200Gb large, does 10Mb memory protection make any
> > difference? if so, why would we respect it?
>=20
> Same with above, only consider it when the proctecion is enabled.

Right, but memory.min is a number, not a boolean flag. It defines
how much memory is protected. You're using it as an on-off knob,
which is sub-optimal from my point of view.

>=20
> > 3) if it works for global OOMs, why not memcg-level OOMs?
>=20
> memcg OOM is when the memory limit is reached and it can't find
> something to relcaim in the memcg and have to kill processes in this
> memcg.
> That is different with global OOM, because the global OOM can chose
> processes outside the memcg but the memcg OOM can't.

Imagine the following hierarchy:
     /
     |
     A         memory.max =3D 10G, memory.min =3D 2G
    / \
   B   C       memory.min =3D 1G, memory.min =3D 0

Say, you have memcg OOM in A, why B's memory min is not respected?
How it's different to the system-wide OOM?

>=20
> > 4) if the task is prioritized to be killed by OOM (via oom_score_adj),
> > why even small memory.protection prevents it completely?
>=20
> Would you pls. show me some examples that when we will set both
> memory.min(meaning the porcesses in this memcg is very important) and
> higher oom_score_adj(meaning the porcesses in this memcg is not
> improtant at all) ?
> Note that the memory.min don't know which processes is important,
> while it only knows is if this process in this memcg.

For instance, to prefer a specific process to be killed in case
of memcg OOM.
Also, memory.min can be used mostly to preserve the pagecache,
and an OOM kill means nothing but some anon memory leak.
In this case, it makes no sense to protect the leaked task.

>=20
> > 5) if there are two tasks similar in size and both protected,
> > should we prefer one with the smaller protection?
> > etc.
>=20
> Same with the answer in 1).

So the problem is not that your patch is incorrect (or the idea is bad),
but you're defining a new policy, which will be impossible or very hard
to change further (as any other policy).

So it's important to define it very well. Using the memory.min
number as a binary flag for selecting tasks seems a bit limited.


Thanks!

