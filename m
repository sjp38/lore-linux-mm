Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94C88C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:55:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F56D218B0
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 18:55:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavesemi.onmicrosoft.com header.i=@wavesemi.onmicrosoft.com header.b="Ig13ZI79"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F56D218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B7028E0003; Thu, 28 Feb 2019 13:55:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78CB88E0001; Thu, 28 Feb 2019 13:55:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6540E8E0003; Thu, 28 Feb 2019 13:55:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A57E8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:55:36 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id n84so6720624oia.14
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 10:55:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=1G86G/5c/y6+uynIof6ueotd56OFKyafnMLXtDoktH0=;
        b=Y3cF9N7QRD80apCX1XHDC6nmFt3wl+Qi6CdPqVI9IjDVMcI6d2xRju7adjRaKwIOjb
         z3fNAHYuTWjhu86FiV69kLcLekxhwkumoIi6bKLgNTFUdVohvTh4NlzaivXfwId+ebwE
         5iv5qZGavK0UeZrzNJ+LZFgsx1Sc1zsk06SZjFk1qaguK1VKQRZwsWuRdH1T6LclHkqE
         71gAVhd9xN59x7Hxat1ny9FUGr0AeFCiBqJQJjtHmAS7DkvL/J/KrvqyNj2amal+GbvW
         dTRguEQYJaQNPsvNyjl90eyVH+j3QcSAnjZKjibO3XAOlNDQk3Q2kDFKcgRcnGt8lyfQ
         LbbQ==
X-Gm-Message-State: APjAAAUpFJEnm/Dbz2qAbDv6O8NcQTpZI6ypaiHsfxeXPJSuB03t0vZO
	J5iT9aJzh5TN+AMNbwYEhkxENqw5w9b40PGGYZXjfOVAsgxU4HUJNSjD5h2LqatyKuFMuAsVPdh
	iM6dOt8PG8pyI2h62T/kbtgePBlizEAG4UtuxmYltRvWEkcX5WvNNWjJFU7PsZzE=
X-Received: by 2002:a9d:77c7:: with SMTP id w7mr752743otl.207.1551380135882;
        Thu, 28 Feb 2019 10:55:35 -0800 (PST)
X-Google-Smtp-Source: APXvYqwDF05LlN29+eyxNuI1k7IAZPmh50wJLtVCO3HaNyGc7Ydla5mRgNbJKIsJ6fKOmuI77CcB
X-Received: by 2002:a9d:77c7:: with SMTP id w7mr752699otl.207.1551380134985;
        Thu, 28 Feb 2019 10:55:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551380134; cv=none;
        d=google.com; s=arc-20160816;
        b=dqyYqYP0QbhS7oc/HR/bSjKBfHDFIlv9j5o+a6+rD7/9h6tddB1wfFmvNTWM1n6Fvx
         J/bU8Pg7bqxfs4Ii6gqYqRtHTJizSzXvdrlayvDv2bjjDDEa7+7OkJqXRlxGSMM5n9Rr
         4wdgBMwdGcb/J4yIJ30Ur0dS9ntkPZknyVt5FImhSNWvcqyGtPEJgzzJHjZadBozqx/2
         iClVbEBGYE1NQMB6tUPfYIwMkHr8G5PIx5PUyOD/2wJdEKgWcK21mEjWoETPUK5zOEZt
         B5SAFFuTYDO+hV9CsQxuikW74rfMIFkCVWL/AMQJ1C1sqbBqLqU3ad22xHJG6zG3Yqp5
         5llg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=1G86G/5c/y6+uynIof6ueotd56OFKyafnMLXtDoktH0=;
        b=FQ5OmeVYzIjbmMtEqWc7gg7kI/Rvhw4BI0d6u38suR72IySaps3t3UY21S5YAajQIX
         9gyEb3ZX83zjzMLpydFnbwARovP98kzsKXzN2WOmkLT2Zx5GpchUFmcHQ0ln025XjF3q
         PxlpMa9YJqaei6bG0qM+yr1nYx/rdziy8Y9FVXS2NtQlyF1ZoHI2d9QnT9OAIgqMcoKY
         5GZ0MO8rJpTXxk7jcVtqATbf5UbdR7B8LY/uGDbjPi7Y5nkVygcWlC14deyIdQZoqOiY
         OUs3OYrbd/vqAANRjg7wp4kXur/KhJ59voPnNtzfGaAekGEsJH3B1yO+UNl1sm10LBOf
         Y5/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=Ig13ZI79;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.81.122 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810122.outbound.protection.outlook.com. [40.107.81.122])
        by mx.google.com with ESMTPS id h126si7486084oib.193.2019.02.28.10.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 28 Feb 2019 10:55:34 -0800 (PST)
Received-SPF: pass (google.com: domain of pburton@wavecomp.com designates 40.107.81.122 as permitted sender) client-ip=40.107.81.122;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=Ig13ZI79;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.81.122 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=wavesemi.onmicrosoft.com; s=selector1-wavecomp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1G86G/5c/y6+uynIof6ueotd56OFKyafnMLXtDoktH0=;
 b=Ig13ZI79xC3LA3Rhapevy/kU+Gsq5UQFhJBBK/hDQoXyNBijlQRTamsdOhTNnncBjRquZ8cXfUTa7gop4evcWaRCBS/BrOv8oWIpHm/F0nSG++Mp2/ubBNLYXFsPTDBS57gkcB5vdTFc+8OIUOD/1Eco7IkVQCSFBPz/OXOA70s=
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com (10.174.162.17) by
 MWHPR2201MB1359.namprd22.prod.outlook.com (10.174.162.149) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.16; Thu, 28 Feb 2019 18:55:28 +0000
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::7d5e:f3b0:4a5:4636]) by MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::7d5e:f3b0:4a5:4636%9]) with mapi id 15.20.1643.019; Thu, 28 Feb 2019
 18:55:28 +0000
From: Paul Burton <paul.burton@mips.com>
To: Steven Price <steven.price@arm.com>
CC: Mark Rutland <Mark.Rutland@arm.com>, Peter Zijlstra
	<peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave
 Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>,
	"linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>,
	Ingo Molnar <mingo@redhat.com>, James Hogan <jhogan@kernel.org>, Arnd
 Bergmann <arnd@arndb.de>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski
	<luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, Ard Biesheuvel
	<ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, James
 Morse <james.morse@arm.com>
Subject: Re: [PATCH v3 11/34] mips: mm: Add p?d_large() definitions
Thread-Topic: [PATCH v3 11/34] mips: mm: Add p?d_large() definitions
Thread-Index: AQHUzr7i/d0uU6ROnE+g9kAjsVHJ0KX0eXKAgACmggCAAHDjAA==
Date: Thu, 28 Feb 2019 18:55:28 +0000
Message-ID: <20190228185526.hdryn2zsfign7vht@pburton-laptop>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-12-steven.price@arm.com>
 <20190228021526.bb6m3my46ohb4o6h@pburton-laptop>
 <74944d83-f3c0-ff02-590e-b7e5abcea485@arm.com>
In-Reply-To: <74944d83-f3c0-ff02-590e-b7e5abcea485@arm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR21CA0024.namprd21.prod.outlook.com
 (2603:10b6:a03:114::34) To MWHPR2201MB1277.namprd22.prod.outlook.com
 (2603:10b6:301:24::17)
user-agent: NeoMutt/20180716
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [67.207.99.198]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 550c1196-5533-4a3f-2915-08d69dae4e26
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:MWHPR2201MB1359;
x-ms-traffictypediagnostic: MWHPR2201MB1359:
x-microsoft-exchange-diagnostics:
 =?iso-8859-1?Q?1;MWHPR2201MB1359;23:APQz/DE9p4wWq6b0dZpgpoDdUz3tcNtWFG4R3?=
 =?iso-8859-1?Q?c0SV6754VZ1bgIRlfhf/JpFe0B9xDmVvJ980SCtXoIn6GsCluDx4ng/vga?=
 =?iso-8859-1?Q?Z6MBuXYzMolQlFMMjV4s8HWnG/isT/TcSlu1ATdYhqUB6Lhehb/EQfc11b?=
 =?iso-8859-1?Q?KppF3LNFiXAvVEXwcK1SkCfE5aXXcU2Eox6OzxgEGmFDp8rCcla5Bbti0Z?=
 =?iso-8859-1?Q?eUSKhtccHf50S4STr25a/mvb/Ec24qt437bV9E7jrDqDJzLkPGWpyuaUxq?=
 =?iso-8859-1?Q?LlG1DvGqxIdUt3hqaAy8wUsLB2H6zOBaqfN1qdiI4wDfHjs0HtDxf73v0u?=
 =?iso-8859-1?Q?0+8CtFQHSf/nUW3GuUz/q3Pf/BvfjxSSQWMvQcg1Hm/Z26oJDWdiojK2G/?=
 =?iso-8859-1?Q?5PUozKEd+mJiNVmxeu6qyUi2eOFabVK0Wu1C+XI9KFf2dz01RhhU4QyZpJ?=
 =?iso-8859-1?Q?0QLyXgkgfQocjWq419QWEB3kvYrBquiFweQVgTRNKKYNIFQtJnS3b32KK+?=
 =?iso-8859-1?Q?EUVBa5X0YQJwLmz74Q+IcDDfs+zkrhaOKpxgF6v8WDrjJsHwgxMT6fFOv1?=
 =?iso-8859-1?Q?m1jb83oDEn3+RuWvfmUH3it2kpOaqsqzRff3yfIRYKYLinkv+mqfnOsj9f?=
 =?iso-8859-1?Q?Ci3okklujtmg0fjSvs8pVzdnmH/yjVOjhY90gH4KUvFlZXOQ07Lqr1qDKi?=
 =?iso-8859-1?Q?UczI/luYgvGcFvySRa/35dWfe4JaSkMz74M5xq1S2yMudANxIG4ekmGLex?=
 =?iso-8859-1?Q?rvBoYMIGN3UDHbEC+6cwdklNER7AoS2M8GHJTxZ6/wYqyaoYZ3q+iiqBGp?=
 =?iso-8859-1?Q?JDTtv3SSnhQ3131Y7tHvdL5CDAgf2EjSX9GFDuu2tnVHWW1a2Xbs6gxKvH?=
 =?iso-8859-1?Q?CFA9t2GTka3a6xkYIEgdZEO7snoaTJr46x8Q2QYjWpQvaJVtvZ8q4pYzE3?=
 =?iso-8859-1?Q?66VBzV+0d+ONOOI98vtBY2KflW4E+vbBZ1pRphFAZ6fMD0nDl+6Y4ikWrz?=
 =?iso-8859-1?Q?HSvE9s/rHwDmZi5qkTdDPHFiTxoZsT2j0wU2bIHDSfNmupgg1w9/RgQhe9?=
 =?iso-8859-1?Q?eHTJPAbWR7SSLbbDx1+rWnv+XQ0xSQWsBkhPNfrXSax/n0fZSWAUN4Oz04?=
 =?iso-8859-1?Q?wwtzWYWA+P0V/X5UWKVBNbFdc0+K0/HUY94/UeRae+7S+c5MzjPquc5/RZ?=
 =?iso-8859-1?Q?Y1s4qdv/RuJHkcGKGWVwti841wULQV/1f1b3EwjTq27dNswehDoKLpyltj?=
 =?iso-8859-1?Q?NuliAZXR3L8V3iHUoDTWhKP5EAeynilGhHdrVvp3ifuKBtHasnjEu5S3r9?=
 =?iso-8859-1?Q?wvQSPI01GQn2YHziU1Qj0dCaa0gEWf1cPDv6Xz2JV0xjCI6A2hHvtfdLH9?=
 =?iso-8859-1?Q?zfICz2vkZSEV4jxvkuJWxvt0BeHyn1mf4rRFoCrZObypXQLPJxE4H9XylU?=
 =?iso-8859-1?Q?Cc1VrDz9NxASPKqti2h0ZI/zQQCUiY5JmnOkN?=
x-microsoft-antispam-prvs:
 <MWHPR2201MB1359F18426AD3A01B32E4F36C1750@MWHPR2201MB1359.namprd22.prod.outlook.com>
x-forefront-prvs: 0962D394D2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(7916004)(346002)(136003)(376002)(366004)(396003)(39850400004)(51914003)(199004)(189003)(186003)(6246003)(6486002)(486006)(11346002)(106356001)(446003)(476003)(42882007)(52116002)(53546011)(305945005)(6506007)(386003)(66066001)(93886005)(7416002)(6916009)(256004)(229853002)(478600001)(6436002)(102836004)(33716001)(76176011)(53936002)(9686003)(14444005)(6512007)(4326008)(81156014)(81166006)(25786009)(71190400001)(6116002)(8676002)(71200400001)(5660300002)(97736004)(3846002)(2906002)(1076003)(44832011)(68736007)(316002)(26005)(14454004)(8936002)(54906003)(99286004)(7736002)(105586002)(58126008);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1359;H:MWHPR2201MB1277.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 sQdOpLduEp5xt+4qfJPbXOED9r3yioy1Wm4u843ee1EHOpDndmuGOWtHeeEtfv7fmvwKXnrqYQ/WdZPeolaf87flYadfVSP0Q02VGgzMHyl0kRAOREUwzDb7DHDhSE2MJ+atyIHKdNIRJ984narfxtSwpjcYIrzJ6J0lMFwHJNAwnTn3Idkyz5nDJP/hzUBnuV3sLFcaGf9QVMr9H4ql6tzAhAkRY+x2XgCCbVYVmDHBAy2B7By8rTX5T+JkwV2mSn8ZIeepb/MPFnunBlvSZ91Q6DsXQBgpl39gRSNh4h3oPrpxRaie9ioPH/gaMTRYwvro7ji8pnMi9Wm/+F9GVMo6yOyTJcisaR0x3TD8dpWuaErqJ+/ZEilf5J+MFevYHeLLbG+C4ldpsP80HzkUOwSKiJiUYPD3YpLV6RmHfNE=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <FFBA1DC130D1404CBBCECA4240085204@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 550c1196-5533-4a3f-2915-08d69dae4e26
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Feb 2019 18:55:27.9917
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1359
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Steven,

On Thu, Feb 28, 2019 at 12:11:24PM +0000, Steven Price wrote:
> On 28/02/2019 02:15, Paul Burton wrote:
> > On Wed, Feb 27, 2019 at 05:05:45PM +0000, Steven Price wrote:
> >> For mips, we don't support large pages on 32 bit so add stubs returnin=
g 0.
> >=20
> > So far so good :)
> >=20
> >> For 64 bit look for _PAGE_HUGE flag being set. This means exposing the
> >> flag when !CONFIG_MIPS_HUGE_TLB_SUPPORT.
> >=20
> > Here I have to ask why? We could just return 0 like the mips32 case whe=
n
> > CONFIG_MIPS_HUGE_TLB_SUPPORT=3Dn, let the compiler optimize the whole
> > thing out and avoid redundant work at runtime.
> >=20
> > This could be unified too in asm/pgtable.h - checking for
> > CONFIG_MIPS_HUGE_TLB_SUPPORT should be sufficient to cover the mips32
> > case along with the subset of mips64 configurations without huge pages.
>=20
> The intention here is to define a new set of macros/functions which will
> always tell us whether we're at the leaf of a page table walk, whether
> or not huge pages are compiled into the kernel. Basically this allows
> the page walking code to be used on page tables other than user space,
> for instance the kernel page tables (which e.g. might use a large
> mapping for linear memory even if huge pages are not compiled in) or
> page tables from firmware (e.g. EFI on arm64).
>=20
> I'm not familiar enough with mips to know how it handles things like the
> linear map so I don't know how relevant that is, but I'm trying to
> introduce a new set of functions which differ from the existing
> p?d_huge() macros by not depending on whether these mappings could exist
> for a user space VMA (i.e. not depending on HUGETLB support and existing
> for all levels that architecturally they can occur at).

Thanks for the explanation - the background helps.

Right now for MIPS, with one exception, there'll be no difference
between a page being huge or large. So for the vast majority of kernels
with CONFIG_MIPS_HUGE_TLB_SUPPORT=3Dn we should just return 0.

The one exception I mentioned is old SGI IP27 support, which allows the
kernel to be mapped through the TLB & does that using 2x 16MB pages when
CONFIG_MAPPED_KERNEL=3Dy. However even there your patch as-is won't pick
up on that for 2 reasons:

  1) The pages in question don't appear to actually be recorded in the
     page tables - they're just written straight into the TLB as wired
     entries (ie. entries that will never be evicted).

  2) Even if they were in the page tables the _PAGE_HUGE bit isn't set.

Since those pages aren't recorded in the page tables anyway we'd either
need to:

  a) Add them to the page tables, and set the _PAGE_HUGE bit.

  b) Ignore them if the code you're working on won't be operating on the
     memory mapping the kernel.

For other platforms the kernel is run from unmapped memory, and for all
cases including IP27 the kernel will use unmapped memory to access
lowmem or peripherals when possible. That is, MIPS has virtual address
regions ((c)kseg[01] or xkphys) which are architecturally defined as
linear maps to physical memory & so VA->PA translation doesn't use the
TLB at all.

So my thought would be that for almost everything we could just do:

  #define pmd_large(pmd)	pmd_huge(pmd)
  #define pud_large(pmd)	pud_huge(pmd)

And whether we need to do anything about IP27 depends on whether a) or
b) is chosen above.

Or alternatively you could do something like:

  #ifdef _PAGE_HUGE

  static inline int pmd_large(pmd_t pmd)
  {
  	return (pmd_val(pmd) & _PAGE_HUGE) !=3D 0;
  }

  static inline int pud_large(pud_t pud)
  {
  	return (pud_val(pud) & _PAGE_HUGE) !=3D 0;
  }

  #else
  # define pmd_large(pmd)	0
  # define pud_large(pud)	0
  #endif

That would cover everything except for the IP27, but would make it pick
up the IP27 kernel pages automatically if someone later defines
_PAGE_HUGE for IP27 CONFIG_MAPPED_KERNEL=3Dy & makes use of it for those
pages.

Thanks,
    Paul

