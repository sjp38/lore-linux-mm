Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE9D3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:20:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CE4120859
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:20:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="CjHmvvOx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CE4120859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DFDC8E003D; Wed, 20 Feb 2019 17:20:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 266F38E0002; Wed, 20 Feb 2019 17:20:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E07F8E003D; Wed, 20 Feb 2019 17:20:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A51118E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:20:30 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f2so5646471edm.18
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:20:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=gr+lEnJZhP++z6s0EWLafdT1zIYfkwmSxNTgXkiJkVg=;
        b=o1uMG+atKpArsXLRuATa88HSZ/6IogP4DUpVuj8TEXcuZhmIo7zcbImV2nv6hDsYwJ
         KBaj/BTFlWdQchYUdG2iimYQZbihIyaIbWoBDH9i1xg5yXra1Ez4YkOIyFdFdTF+jt7Q
         OZ1jLGhATyp7+C5yqDRvT50M8r+Q/hLF3GgRtvhDvpk/CcfE9ebXdPF5xbgTgfxa64UZ
         D5BG7g12/3R/dOKyScxvFhYPrE0y2rNXTvbLUlrYZtPfk/0mz1zUBPjEqY42ALAKtgNo
         1pS+UjkYPQToLXWhLDjC97/wDDq7Q3iNTwLY0Bg2M2iqjiA3B+HaxtUJSwlH2L2cL8Yx
         QSMQ==
X-Gm-Message-State: AHQUAub/PhcfJrUpxKNNpcvw9pz4hbnr/inPPqCJHedor41NivzF6pjd
	VOpgCghFU7gDEhWlm10JT9WRBukQcB973LwI8UO+LACfHDOGZ51TBgZh5Yuu9ko3GaNAImFp4ub
	z46XML72XUh6VSvKeTrRezmHPTGJpELM24uIoIs/0Tk5SEnXItJrzIFUfDM2cyGgXCQ==
X-Received: by 2002:a17:906:258d:: with SMTP id m13mr24753942ejb.73.1550701230197;
        Wed, 20 Feb 2019 14:20:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia4Fp/6upYfUCU16qxRcPBwtaAZbRi2pHFqJaGuVCbjjdHHra043tDau7oROI8ScK/cHsDh
X-Received: by 2002:a17:906:258d:: with SMTP id m13mr24753918ejb.73.1550701229234;
        Wed, 20 Feb 2019 14:20:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550701229; cv=none;
        d=google.com; s=arc-20160816;
        b=oPTyrFZHf5v8ErdFDHkid6mnNh4MlaPA609AflfYGV9VISvq5DFs88uwZRoCThQWYe
         az4YKoNwIPGVxXpcAPiL6TVGYyMOQRt7hSweG1WNEksH0dEPFVPFbNhp+Pp/cRxtFSY9
         vEG8UON+S47mc6h3qe4ZKOW6FoQkGZ+BYBsJtPrQRMlFnYsAZqLie41GdR+0dW+p3FNy
         BECMT2i2hbtwCCoYtsRM5XqvKq6PIrb1Sha2XAcl+zj97nvuV8S/xm/OQzWDZtmLoF3j
         yT4V9Bvaygm6dTuCeTu36LM0GG+y0SgHb8C7+CIvKAtfFLy+/fBSjnuxLLziAvxXMa70
         H6Og==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=gr+lEnJZhP++z6s0EWLafdT1zIYfkwmSxNTgXkiJkVg=;
        b=u0O80pKAQd6yLUQOUR3FoWKef8UcluPTBlMLKIieYvjjN77F8+dJtwCz75PEkYRU3Z
         nI9RUFnbpJM6LyUPY8B5sp6w7CWhpzWrLtn/15inyUKdfXeRgne7Mn9l3lVeiOxMJOHH
         76a1Zv8m2RtpEKBki9+K30FV8q2zNJSpti87Tiu5kP8sGwMalKt8GaeUtchpi8WJNFTD
         j9eYzMwlZSwK6s99LPzA0NYje96d8txkkyC9ozDpjnG9MiuT0ha9UJMFBu5ovKjypuaP
         auiVcJX+nSR9wDknqGwKIRG/fd7IAGNYdHYfET/4qVyPp2aVnSsvFoxuiJ8hxeahs/qi
         sQwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=CjHmvvOx;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.43 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140043.outbound.protection.outlook.com. [40.107.14.43])
        by mx.google.com with ESMTPS id h3si5672907eja.51.2019.02.20.14.20.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 20 Feb 2019 14:20:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.43 as permitted sender) client-ip=40.107.14.43;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=CjHmvvOx;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.43 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gr+lEnJZhP++z6s0EWLafdT1zIYfkwmSxNTgXkiJkVg=;
 b=CjHmvvOx6GT0QqaA2zCfPrKm+BqE+GFb6EqrhRTsw3X1vUh5XdW0QemXCwYMpsh2bnDlVGYv8mZrbSI9A1AK9V5U5TK+zclwZem4EULx6uQag0ifKI8/YWyLuDZv8RZbbbpdUykWnxj8Hst+N1u36ZLHrULUNpA9jYfU374BHBg=
Received: from DBBPR05MB6570.eurprd05.prod.outlook.com (20.179.44.81) by
 DBBPR05MB6441.eurprd05.prod.outlook.com (20.179.42.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.19; Wed, 20 Feb 2019 22:20:27 +0000
Received: from DBBPR05MB6570.eurprd05.prod.outlook.com
 ([fe80::5d59:2e1c:c260:ea6f]) by DBBPR05MB6570.eurprd05.prod.outlook.com
 ([fe80::5d59:2e1c:c260:ea6f%2]) with mapi id 15.20.1622.018; Wed, 20 Feb 2019
 22:20:27 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: Haggai Eran <haggaie@mellanox.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, Leon Romanovsky <leonro@mellanox.com>, Doug
 Ledford <dledford@redhat.com>, Artemy Kovalyov <artemyko@mellanox.com>, Moni
 Shoua <monis@mellanox.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Aviad Yehezkel <aviadye@mellanox.com>
Subject: Re: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Thread-Topic: [PATCH 1/1] RDMA/odp: convert to use HMM for ODP
Thread-Index: AQHUt/PpTVDkh3W8Skewftgbde5wUaXSgGwAgAnq3wCADPm7AA==
Date: Wed, 20 Feb 2019 22:20:27 +0000
Message-ID: <20190220222020.GE8415@mellanox.com>
References: <20190129165839.4127-1-jglisse@redhat.com>
 <20190129165839.4127-2-jglisse@redhat.com>
 <f48ed64f-22fe-c366-6a0e-1433e72b9359@mellanox.com>
 <20190212161123.GA4629@redhat.com>
In-Reply-To: <20190212161123.GA4629@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MWHPR19CA0017.namprd19.prod.outlook.com
 (2603:10b6:300:d4::27) To DBBPR05MB6570.eurprd05.prod.outlook.com
 (2603:10a6:10:d1::17)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [174.3.196.123]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 160dc564-ae34-4130-7daa-08d697819dbc
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DBBPR05MB6441;
x-ms-traffictypediagnostic: DBBPR05MB6441:
x-microsoft-exchange-diagnostics:
 =?us-ascii?Q?1;DBBPR05MB6441;23:KI40ICbSYdZxL0yvV1R8Shf2999thzaNO66djIODl?=
 =?us-ascii?Q?qbNK41ZmOuXqWHGsxZwqm+8MQlEmKKeom2CaRzP6ilT+rNqil14h2Td25HfL?=
 =?us-ascii?Q?qp1P9ELutYrrW/uyZRKrBwpn9PilfEyNCLIoXleQeE4Tzg5dzPy+RtJ9wPIC?=
 =?us-ascii?Q?ofa3OAB5ssbt7JxuaE1g8kLWiD2h/vkgDRFNWNO/UNpg0Mt5KVRr4ysce9To?=
 =?us-ascii?Q?yWCvY2AZ9/A+U/se84JpiEQyalIskGgn2i2Q9DB2xNfFFHaOs+o7w8i8yPyG?=
 =?us-ascii?Q?vaSjhm9YZxOEpbLNoqmSaPStXdbC9uII5X4fklHusqccM40WCZShlS8DXcop?=
 =?us-ascii?Q?zp+gmg4v0Xpd/ZWsAZwp0AVzFJXPW1ogtYDFCluXGtkTaYFSAiS4dMPQIpIE?=
 =?us-ascii?Q?jYL/7YucnV6AoIW4Rzp4RFKNSuJ+TjxwOPO6p1zgeUpFl5wrxY0x87bKY4wU?=
 =?us-ascii?Q?fmzsKC1EPIf7Jdn8mw0JVSkacEmo/q2JM58cqc/ExZUbz1qCQLy40ckRoXcv?=
 =?us-ascii?Q?1V6LsOyuyvjZnSFJ2t87UAb9Q0Sl8cCKDDVhcDDODzEZzhHWgezXlITKuTM8?=
 =?us-ascii?Q?Aqc1VQyrMFvPjx8BMIQfwvzEdAsolA7fEbiSgoh5u2V6n7IsiRAYjl7PftQK?=
 =?us-ascii?Q?8P2YpyL/oIt+InxzRtJJeH5lbnGhIKJKQMvbtHf70x34ftUDqdjBk+OSGf98?=
 =?us-ascii?Q?gmdc9D1kyYNPCxxaVRcLD7NaC9CM1ZoLUnDIFZZ3GaQm1SxIjM12bTL7g1MZ?=
 =?us-ascii?Q?M0ahZxqqeNbdwsuA23JZPObrphWmClIXGdsnTvCz4HqSzJT61AmfjpwSzRvY?=
 =?us-ascii?Q?WgwBfaFgBTtXKOJiwBcJXmotzmNBFlXawSysACUHGf0ZMVvxuR4uj/AFxx/R?=
 =?us-ascii?Q?Nlw+SJtAs59h9LMvpJCzdddbuVtYjdDTq51+gYUwovR5uWlQDEDLh0ISZjEV?=
 =?us-ascii?Q?VZqS0JwVCBvu04Z4ApZ535/bOvYHTZevUFTPjl0JR0BZH+aarNYnqiqmUznL?=
 =?us-ascii?Q?f4kdPtvG2eLNSyC9WZdmjzy/9DQQ79w8HgBozYE24xagSGVO2P5DyeAb3FpG?=
 =?us-ascii?Q?mFP37wwWa/S1ljYrq46aQ6wi/2TpMqKU2sBwYxok/ZV8U8EA/mWUwIo9isfh?=
 =?us-ascii?Q?NWlQFBLkfw/Mbq4GJCsaSEFkA/qOfgZx+Zi5LoXaf+0QZpclQOIShIfh2Nb5?=
 =?us-ascii?Q?1p44Bf4tPkTUcZp8h693rP3zyfKiuNP1TsmuDF11Z37cSXDKoR4RNoVgFp3r?=
 =?us-ascii?Q?2Bieitl7dNXy/pBdb2JFct0iSQDAsQTOJ9KEmoz8YMIxw1qSgEaC72rDQZoI?=
 =?us-ascii?Q?ZwS7Tsiz7wldwgOjJVVMW0=3D?=
x-microsoft-antispam-prvs:
 <DBBPR05MB644180D87718A4E0DE771494CF7D0@DBBPR05MB6441.eurprd05.prod.outlook.com>
x-forefront-prvs: 0954EE4910
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(39860400002)(396003)(136003)(376002)(346002)(199004)(189003)(105586002)(106356001)(36756003)(14454004)(478600001)(6116002)(97736004)(3846002)(386003)(99286004)(52116002)(6916009)(305945005)(76176011)(81156014)(8936002)(1076003)(81166006)(7736002)(102836004)(5660300002)(6506007)(93886005)(71200400001)(6436002)(6486002)(2616005)(316002)(476003)(54906003)(6512007)(26005)(107886003)(25786009)(71190400001)(33656002)(4326008)(256004)(66066001)(53936002)(229853002)(14444005)(68736007)(11346002)(6246003)(446003)(486006)(186003)(86362001)(8676002)(2906002);DIR:OUT;SFP:1101;SCL:1;SRVR:DBBPR05MB6441;H:DBBPR05MB6570.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 A7rxCMO7zWdSUd2ZCl+17pJv4aE1LlPkBQgROkBNu5bIuZb2DSeej6+a7CVLBCmDtkp5yCb8AAVm8/KeCWJSUai1Z/SSU6ru55t/eSiWA8YAzFf9DKt8VWbsz3E5CkKimpmVPg3sB4ZzftDL6Y3oFcCwRKMaps4BhG4P+YgHofj/4YTy76BRPnDxGPjkbIn/KZC2GrcEH1h7G4WbBtQz0MiuiOe0aodXHzqmbTMzeW6fkhezfLFG2yRH8p411mPIKcYBeVIAdf6utGOqWMRr+nf7MYMMv0JwWlYV5OK9d/kcGwMglqTn4aLDWeDKsuLBw710hfsqb3/XCmalDtKfYrG+ETSHcmZvts464r/DtPgyE2DRd1iUwPW924stNzRh6pEqRJNQZxqVxopPeCWzl7qv73lJZeQfXdWVcv7k1DA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B70F9D2A56FBE5489BCF876A0CF04ADF@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 160dc564-ae34-4130-7daa-08d697819dbc
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Feb 2019 22:20:27.2435
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR05MB6441
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 11:11:24AM -0500, Jerome Glisse wrote:
> This is what serialize programming the hw and any concurrent CPU page
> table invalidation. This is also one of the thing i want to improve
> long term as mlx5_ib_update_xlt() can do memory allocation and i would
> like to avoid that ie make mlx5_ib_update_xlt() and its sub-functions
> as small and to the points as possible so that they could only fail if
> the hardware is in bad state not because of memory allocation issues.

How can the translation table memory consumption be dynamic (ie use
tables sized huge pages until the OS breaks into 4k pages) if the
tables are pre-allocated?
> >=20
> > > +
> > > +static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] =3D {
> > > +	ODP_READ_BIT,	/* HMM_PFN_VALID */
> > > +	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
> > > +	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
> > It seems that the mlx5_ib code in this patch currently ignores the=20
> > ODP_DEVICE_BIT (e.g., in umem_dma_to_mtt). Is that okay? Or is it=20
> > handled implicitly by the HMM_PFN_SPECIAL case?
>=20
> This is because HMM except a bit for device memory as same API is
> use for GPU which have device memory. I can add a comment explaining
> that it is not use for ODP but there just to comply with HMM API.
>=20
> >=20
> > > @@ -327,9 +287,10 @@ void put_per_mm(struct ib_umem_odp *umem_odp)
> > >  	up_write(&per_mm->umem_rwsem);
> > > =20
> > >  	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
> > > -	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
> > > +	hmm_mirror_unregister(&per_mm->mirror);
> > >  	put_pid(per_mm->tgid);
> > > -	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
> > > +
> > > +	kfree(per_mm);
> > >  }
> > Previously the per_mm struct was released through call srcu, but now it=
=20
> > is released immediately. Is it safe? I saw that hmm_mirror_unregister=20
> > calls mmu_notifier_unregister_no_release, so I don't understand what=20
> > prevents concurrently running invalidations from accessing the released=
=20
> > per_mm struct.
>=20
> Yes it is safe, the hmm struct has its own refcount and mirror holds a
> reference on it, the mm struct itself has a reference on the mm
> struct.

The issue here is that that hmm_mirror_unregister() must be a strong
fence that guarentees no callback is running or will run after
return. mmu_notifier_unregister did not provide that.

I think I saw locking in hmm that was doing this..

Jason

