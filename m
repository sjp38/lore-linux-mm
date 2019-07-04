Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13080C5B578
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 02:00:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 88A2721882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 02:00:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="N8aEUaSA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 88A2721882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED4F96B0003; Wed,  3 Jul 2019 22:00:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E85188E0003; Wed,  3 Jul 2019 22:00:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFE858E0001; Wed,  3 Jul 2019 22:00:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 80D796B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 22:00:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r21so2824867edp.11
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 19:00:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=ME3mN3r/laVGQduCC0GREWkfow/AT6OjaPvOkxvI2NY=;
        b=L+MaInNGg6TuuuZ/ghir0zaoxX4YXreNABBjQUYMRzl+OJtDonE34NswnWKTzE6GBJ
         hEm5L183AvWVRP25Un55Tq5DvY1dUawMD+ACMcWmWf3fY5jTgYCd+QyXPfuMEVPY16/o
         mSSio+FllkXXoVps1hKzNF/VEzIu2J5R/tJedaw/8wN0g0hG3caGokS2eSrSaFhi5CJ8
         VFUYzEbLlTxeeIdn5ANI/Op+OlylcOkud5nKComCyuhvxL/9R8tt8eTL+4q8FVg+Z6gl
         41ukbflebN4sISk9ixwFjkLPW/FO9V+XNXEGDFjWIArNHE+NquYMWcBV3zW6cAh2Kr1h
         +jdw==
X-Gm-Message-State: APjAAAUwg3wPjahBAjTjKC/zmuzayK0SGxpWlMh/NIu7eBkpqCkPGsHB
	CgVWYpNsWF55pOmJ/4+7V6QW9ZRgjPqOiF6gq89PDjsibOR48hnWy8joayNmm1+IeecnG/s4VqO
	uUwfmE9VGEeRVSkRLdngQEmDMdJtTX69Lnhk49/wUv0i5UiHcorduFUGwSk1W0KoZoA==
X-Received: by 2002:a17:906:a2d2:: with SMTP id by18mr37019915ejb.245.1562205625862;
        Wed, 03 Jul 2019 19:00:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0f1QNJFUhCnOnLT88rrMVfPlR/xTcKRbTxXGbrHRYczUYdA3ImIQuEPn+hgQcprt5p/kU
X-Received: by 2002:a17:906:a2d2:: with SMTP id by18mr37019869ejb.245.1562205624962;
        Wed, 03 Jul 2019 19:00:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562205624; cv=none;
        d=google.com; s=arc-20160816;
        b=AUjeOVxTI864pXI7C4pJbnO326CuTCGhO6fXuCy9x5FgX/lpw4G+lxe7CbmGW4PFxE
         iRcCFwqHbVKPhs1nNWkSKCVGxU40dAI+I1hhR3lMY9TDWMe5LEzRB4cUE/7KU6aLeSuN
         a/wgwuW0kz2CPdq0CrTl3qD8Luubtqpk5ewprCu0YRXg44ZQrNHEJlmdO5RFlGrkrUl4
         VCO0aRrXeBsn6ImyQiVtArXCv/aROtPIQ7yUOuOrjquYegpmmO4woJeDi8h6Haog155o
         hrumq+ZM9XiEMJKlghs4TcinspHOrLurFn3H3uG2nzxpuutw26vZdu0gckSjCYOz+FF+
         FboQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=ME3mN3r/laVGQduCC0GREWkfow/AT6OjaPvOkxvI2NY=;
        b=ZYFn6WFlWXCkKBBN23/I6B4gao2ilhS+RioTst94JgNwdfaptgiC5JazfvDJ3jdmz6
         68/KHXvME+hCPolsx5678m4JO3YbwfTOglZRNkvHQThL4fHsycAVce9PvlTdpE5liVni
         BUz9bPUqE+0/N6WTC9vP4rwuT5uqCJpACvZxwOPrFzM9a+ZedKD2ltkQYgkea1RVXW4h
         REHICpxiBeR9CeF4j5Zpf6A0ND24v0pXsl1PWdGe0MHaA09+BdQiXVoz6sOSo2RiZLwl
         ism1nKXXi7GxaFVpPAg55v5r4JScSbH/3FEnaUJoQkylYCCzuomW+4Kw2I98w1iHPONG
         a/HA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=N8aEUaSA;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.44 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30044.outbound.protection.outlook.com. [40.107.3.44])
        by mx.google.com with ESMTPS id d25si3384752eda.172.2019.07.03.19.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Jul 2019 19:00:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.44 as permitted sender) client-ip=40.107.3.44;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=N8aEUaSA;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.44 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ME3mN3r/laVGQduCC0GREWkfow/AT6OjaPvOkxvI2NY=;
 b=N8aEUaSAr9LfwFi/rRWg5qp4oGlvAHg6o8+y111tSsjtuL36/2TgjxPqMV2txpRvmOJ5VBcsDBQ4e5rHwNOgMNRBzvsnhVpjIV8Box9hSTf/dMANb8qLS6LIwH6SB/9aODrduIBEeN7Qdwu0uKvgczqrnq1P/iWnswTu+cJ3lGE=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5390.eurprd05.prod.outlook.com (20.177.63.87) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Thu, 4 Jul 2019 02:00:19 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2032.019; Thu, 4 Jul 2019
 02:00:19 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dave Airlie <airlied@gmail.com>
CC: Stephen Rothwell <sfr@canb.auug.org.au>, Alex Deucher
	<alexdeucher@gmail.com>, "Yang, Philip" <Philip.Yang@amd.com>, Dave Airlie
	<airlied@linux.ie>, "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-next@vger.kernel.org"
	<linux-next@vger.kernel.org>, "Deucher, Alexander"
	<Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Topic: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Index:
 AQHVMUJXWs8sf5cAOUS0d/4NvIH/Saa473yAgABzhwCAAAGdAIAABmoAgAAbwICAAC8hAA==
Date: Thu, 4 Jul 2019 02:00:19 +0000
Message-ID: <20190704020014.GA32502@mellanox.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
 <20190703141001.GH18688@mellanox.com>
 <a9764210-9401-471b-96a7-b93606008d07@amd.com>
 <CADnq5_M0GREGG73wiu3eb=E+G2iTRmjXELh7m69BRJfVNEiHtw@mail.gmail.com>
 <20190704073214.266a9c33@canb.auug.org.au>
 <CAPM=9tx+w5ujeaFQ1koqsqV5cTw8M8B=Ws_-wB1Z_Jy-msFtAQ@mail.gmail.com>
In-Reply-To:
 <CAPM=9tx+w5ujeaFQ1koqsqV5cTw8M8B=Ws_-wB1Z_Jy-msFtAQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR01CA0013.prod.exchangelabs.com (2603:10b6:208:71::26)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 88633ecd-415f-49be-9256-08d700235db4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5390;
x-ms-traffictypediagnostic: VI1PR05MB5390:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <VI1PR05MB5390DB7709DB09D561CAA4A1CFFA0@VI1PR05MB5390.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0088C92887
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(346002)(396003)(39860400002)(366004)(136003)(199004)(189003)(966005)(53936002)(86362001)(256004)(71190400001)(68736007)(6306002)(478600001)(6916009)(8676002)(99286004)(5660300002)(25786009)(4326008)(7416002)(14454004)(6512007)(71200400001)(2906002)(81156014)(81166006)(2616005)(1411001)(8936002)(6506007)(316002)(1076003)(6246003)(66946007)(7736002)(6486002)(66446008)(54906003)(229853002)(66556008)(64756008)(26005)(76176011)(66476007)(73956011)(6436002)(11346002)(476003)(66066001)(446003)(33656002)(386003)(36756003)(3846002)(486006)(305945005)(52116002)(6116002)(102836004)(186003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5390;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 rKELJ694naT5gGDd4kqK5UDxIRL9SdMf7WLMDnUrujLbRaZnRyLZdyVfyYg1vPx8Yy0DJfX8f7wY+1BwTXJx9i+s9CiqrRlOcNDdRLk6Jbfd6AEDKyXV6Tt0amSSM3rvM+Aj3CvENpy/+F2jQ4uOYWUV8HlH1xwccb5PZpEnAkCIY6wRZz3G77WUF9zjoi6iqzGlngZ8mTWrPoMp0yLstiK0R2fx/FZMYUlbvUhkdoq15DQWg1hPyKebad2faC7LlwjT1ZMe9Re35Q3T8pBeOE+UNqCtA4wcWYRoySr8hW+ZY3Q9CY3ec5jcNOfY86cA8KpVF3UDf/vcyI/plhAeWgpjpNahACEC+29xp6R5JzyjQPRpcBUjEpRmPovPcg+Vd9Iq1vbPzYgvAjpa52v84aRXqIZP1HL7dzqDKliRRBU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <67836C539BDF9F479C5FD35E4F835B2D@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 88633ecd-415f-49be-9256-08d700235db4
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Jul 2019 02:00:19.6612
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5390
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 04, 2019 at 09:11:33AM +1000, Dave Airlie wrote:
> On Thu, 4 Jul 2019 at 07:32, Stephen Rothwell <sfr@canb.auug.org.au> wrot=
e:
> >
> > Hi Alex,
> >
> > On Wed, 3 Jul 2019 17:09:16 -0400 Alex Deucher <alexdeucher@gmail.com> =
wrote:
> > >
> > > Go ahead and respin your patch as per the suggestion above.  then I
> > > can apply it I can either merge hmm into amd's drm-next or we can jus=
t
> > > provide the conflict fix patch whichever is easier.  Which hmm branch
> > > is for 5.3?
> > > https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/?h=3Dhm=
m
> >
> > Please do not merge the hmm tree into yours - especially if the
> > conflict comes down to just a few lines.  Linus has addressed this in
> > the past.  There is a possibility that he may take some objection to
> > the hmm tree (for example) and then your tree (and consequently the drm
> > tree) would also not be mergeable.
> >
>=20
> I'm fine with merging the hmm tree if Jason has a stable non-rebasing
> base. I'd rather merge into drm tree and then have amd backmerge if it
> we are doing it.

Yes, it is a stable non-rebasing tree for this purpose.

> But if we can just reduce the conflicts to a small amount it's easier
> for everyone to just do that.

Yes, I concur with Stephen. hmm.git is setup so we can merge it across
trees as a feature branch if we need to - but merging to avoid a
trivial conflict is something Linus has frowned on in the past.

If we can get the resolution down to one line then I would forward it
to Linus. Since it is a build break only it should be highlighted in
the DRM PR.

For RDMA we often have conflicts and I usually send Linus a 2nd tag
(ie for-linus-merged) with the conflicts all resolved so he can
compare his and my resolution as a sanity check. Linus wrote a nice
email on this topic..

Jason

