Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07292C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:40:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B202821882
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:40:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="rzUpG3JP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B202821882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 393F18E0020; Wed,  3 Jul 2019 16:40:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3430E8E0019; Wed,  3 Jul 2019 16:40:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20BB28E0020; Wed,  3 Jul 2019 16:40:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C88A18E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 16:40:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k15so2464246eda.6
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 13:40:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=boRw7gXNEPgVKjC8JbPa9vT086kc+Ya39vsy5M66LG4=;
        b=Ya1m7HxQ+JVsE396+5feF3jTAtVkegJlnQiZ5u51rf0LAjcC/KX7kCblhYR6fZRRw4
         +cKIO54O9h8Ksn4vK/DP2/5/2DOP/d48Ei1BOV0JIFIRAo5P50VJ4Zi+T/YKqC/SZ/XN
         ZeWkFpMxPb+Id9FO3GR6nlfMMoBHHoa05qNlLQULp2jax5+UjbCCUUvQ7kIljb/9bPDY
         N+cdNsvEisa52mFEn5aD6c72I2ZQy20lm2k8fP6MZ7vQ5Gk1sqP1VQXVhNop4eM/O0n+
         ESYs45wMKuU8xuHgg6muLhKIWcRc1s1Q6CFcA94SlZn/pkUKkmVIxRHcxZpfRml7TKLd
         f54Q==
X-Gm-Message-State: APjAAAXmtSxuSIauRXZ1FIFpIXDnvXE48klm/ZeaBqJFXkNzgp41HO6a
	LhaLK9pgRsmpanEa0LCaS4bxu8JoymfEJdudoHpFX3SLr7p3AjqlVsGMYlFJ6x5ksGAJRPWSDYR
	wagp+r8swb2eRh6JE9D51Inbe5zg0q9O8dzFbBCljznLR8l8TAJglvnoW5ARcEvsgkw==
X-Received: by 2002:a50:b388:: with SMTP id s8mr44518326edd.15.1562186411303;
        Wed, 03 Jul 2019 13:40:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxg5Iqx7ilrURP9EL3TFoj6N/zO5t2TGZrSBQNpOdGYZXPuT2If5cvHpzWjRU0EEx2FuIbF
X-Received: by 2002:a50:b388:: with SMTP id s8mr44518280edd.15.1562186410574;
        Wed, 03 Jul 2019 13:40:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562186410; cv=none;
        d=google.com; s=arc-20160816;
        b=PY6nYrdO0++5VHY4tJ3dSTJM23dh+GGH+Ddc6+AYQE0cU5NjZYgGivE8vdcKTmI/HS
         1kOPDXgU727yg+rmrSpIHiQxpCQEAwwobzR9yc04ekqDDXk/Fmd/g3iAIgU47gHQs84p
         GaZl9nyYSTG6NWVdmnHf6p4qqhM467tta2FaQcqN8PtPps4DAodisMb+FowCCMLaGsyr
         YNruflQ9WHv2jw/RR6kktPQ1YiYAJKE8m23uBjAVFXRfP4+AmieXuuP/dWnEKCrUhkUq
         mmfYGBOjmh/aa2UPfckkAi7j+y1jxXdJ1ZvP0FKyW5lPTZeBv9jLi67MvuJoS4RvxD5y
         XhEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=boRw7gXNEPgVKjC8JbPa9vT086kc+Ya39vsy5M66LG4=;
        b=rJ2nDig/8PA/iMqAv1HMmFFg2qOR2s7/lgwyAcdsVtHaASn1UDk8IjhyXSVJA5K2e/
         MsiA19vULazP5q8j+ClrvyzzKFBdqHUcE8FUSbZQmCczR7s4nvYOWrXii9MDlo8j7PkB
         NZdXrNlK6BBmikPuP+l95cTxxPOhVc9fJx/Ase32eXfjQVFnQk5BXlqXFPXi8vhCujW/
         wDAXqkldliEEiJs/vu1f/HmRQZB6b2fRvZtI7gdo9JDy7zg9b+FJPLAFpyNolMkdYHGN
         cpXgH3w0A5oGpDcCzZ5TK/lIJ9oq8ZRC8ZEkmSVnDDKhRLYdwDgt6YitQ4nNA7R1NhyR
         hPvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=rzUpG3JP;
       spf=pass (google.com: domain of jgg@mellanox.com designates 2a01:111:f400:fe05::61b as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-he1eur02on061b.outbound.protection.outlook.com. [2a01:111:f400:fe05::61b])
        by mx.google.com with ESMTPS id z20si2610693eju.217.2019.07.03.13.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Jul 2019 13:40:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 2a01:111:f400:fe05::61b as permitted sender) client-ip=2a01:111:f400:fe05::61b;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=rzUpG3JP;
       spf=pass (google.com: domain of jgg@mellanox.com designates 2a01:111:f400:fe05::61b as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=boRw7gXNEPgVKjC8JbPa9vT086kc+Ya39vsy5M66LG4=;
 b=rzUpG3JPf2lpis8U1+TAuOvlVTU04PTINLfcCiVuVwcUowQgkBQ079k37C/RxEik69OMUsO3hzstoG4LexH1TD6j0OMg7zrzjP9MQVq+NinnuOd/xljk0Z/CfJfTyUsmJi6qYhSatU2OKpvuOjNBYu/vJvlyXt1t7MxIihoZzQE=
Received: from DB7PR05MB4138.eurprd05.prod.outlook.com (52.135.129.16) by
 DB7PR05MB5353.eurprd05.prod.outlook.com (20.178.42.79) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.18; Wed, 3 Jul 2019 20:40:08 +0000
Received: from DB7PR05MB4138.eurprd05.prod.outlook.com
 ([fe80::9115:7752:2368:e7ec]) by DB7PR05MB4138.eurprd05.prod.outlook.com
 ([fe80::9115:7752:2368:e7ec%4]) with mapi id 15.20.2032.019; Wed, 3 Jul 2019
 20:40:08 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ralph Campbell
	<rcampbell@nvidia.com>
Subject: Re: [PATCH 1/5] mm: return valid info from hmm_range_unregister
Thread-Topic: [PATCH 1/5] mm: return valid info from hmm_range_unregister
Thread-Index: AQHVMc9vbnYVs0S/206V41dM/fYuDaa5P52AgAAYpYCAAAMYAA==
Date: Wed, 3 Jul 2019 20:40:08 +0000
Message-ID: <20190703204002.GO18688@mellanox.com>
References: <20190703184502.16234-1-hch@lst.de>
 <20190703184502.16234-2-hch@lst.de> <20190703190045.GN18688@mellanox.com>
 <20190703202857.GA15690@lst.de>
In-Reply-To: <20190703202857.GA15690@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQBPR0101CA0060.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:1::37) To DB7PR05MB4138.eurprd05.prod.outlook.com
 (2603:10a6:5:23::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c2d72fcc-a695-484b-3606-08d6fff6a28a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DB7PR05MB5353;
x-ms-traffictypediagnostic: DB7PR05MB5353:
x-microsoft-antispam-prvs:
 <DB7PR05MB53533520153B718AD8B44DDACFFB0@DB7PR05MB5353.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 00872B689F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(376002)(346002)(39860400002)(136003)(366004)(199004)(189003)(6512007)(33656002)(52116002)(76176011)(476003)(3846002)(6116002)(11346002)(14444005)(6506007)(4326008)(25786009)(386003)(256004)(2616005)(305945005)(53936002)(6436002)(36756003)(8676002)(486006)(7736002)(8936002)(81166006)(6246003)(102836004)(6916009)(26005)(68736007)(81156014)(14454004)(73956011)(66446008)(66946007)(71190400001)(71200400001)(54906003)(66556008)(66476007)(66066001)(446003)(5660300002)(186003)(64756008)(2906002)(99286004)(316002)(229853002)(6486002)(478600001)(1076003)(86362001);DIR:OUT;SFP:1101;SCL:1;SRVR:DB7PR05MB5353;H:DB7PR05MB4138.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 jDfglUojE6QaLohL81Wj7gLMka4NP5sT4AN2MpsjUeFYA6EfzUDsjUacYNqHNDlFkll4sbJK1dD/ShvMtZLgdFeyB/GEoFthG0LHCUVuw7Wh5kMrZnHrm0m/FI1PhVKTWCCl5vK66cQcpWhELIIuNI2DJNp+cZovrAuYwRjcARIONcgMdxlIq9E7kaVwhTkpWutut2nXEpSv1gLJ7BZA0X6+qLHClSI0z7vVxxkqUT9JhM0r0tFzI/L9VcfWNwGXE0Xomw8DCQ2vKY3lbjc3vP4eD2alypF9eHQGekJErn+iEFVqm0i2KP8eOc3+fV3XF98mLOF9eWI7zcvHx1meXJGI4/buvOZlIXQOnV9PLn/pX6u/JutGVa7YL/01jHtwM4nd0OeMg+r2GOIWkzscAMZ+JHqUATdyVgC4cxIA5gk=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <06E102C96309A349A6DAB9BA508DF1DD@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c2d72fcc-a695-484b-3606-08d6fff6a28a
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jul 2019 20:40:08.2593
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB7PR05MB5353
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 10:28:57PM +0200, Christoph Hellwig wrote:
> On Wed, Jul 03, 2019 at 07:00:50PM +0000, Jason Gunthorpe wrote:
> > I don't think the API should be encouraging some shortcut here..
> >=20
> > We can't do the above pattern because the old hmm_vma API didn't allow
> > it, which is presumably a reason why it is obsolete.
> >=20
> > I'd rather see drivers move to a consistent pattern so we can then
> > easily hoist the seqcount lock scheme into some common mmu notifier
> > code, as discussed.
>=20
> So you don't like the version in amdgpu_ttm_tt_get_user_pages_done in
> linux-next either?

I looked at this for 5 mins, and I can't see the key elements of the
collision retry lock:

- Where is the retry loop?
- Where is the lock around the final test to valid prior to using
  the output of range?

For instance looking at amdgpu_gem_userptr_ioctl()..

We can't be holding a lock when we do hmm_range_wait_until_valid()
(inside amdgpu_ttm_tt_get_user_pages), otherwise it deadlocks, and
there are not other locks that would encompass the final is_valid check.

And amdgpu_gem_userptr_ioctl() looks like a syscall entry point, so
having it fail just because the lock collided (ie is_valid =3D=3D false)
can't possibly be the right thing.

I'm also unclear when the device data is updated in that sequence..

So.. I think this locking is wrong. Maybe AMD team can explain how it
should work?

Jason

