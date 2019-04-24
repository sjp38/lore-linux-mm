Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E87E2C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DD222183E
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 20:50:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavesemi.onmicrosoft.com header.i=@wavesemi.onmicrosoft.com header.b="K0+4Lyxh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DD222183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2887D6B0005; Wed, 24 Apr 2019 16:50:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2379D6B0006; Wed, 24 Apr 2019 16:50:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FF6D6B0007; Wed, 24 Apr 2019 16:50:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id D7E4C6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 16:50:35 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id q82so8141027oif.7
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:50:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=dagHIG0/uDgKzzzZeg2bbroAeyAEP6gZcPiOb0HPDgc=;
        b=g0pV/A9+d7MRH02LN6M9g4YNqqaMd5Y6qHX9NyeoVpfqkuXogFoK6UC69GRBVwoBUD
         IyJvfqYPn/xeEwSy9ppMzxcFxeNU1TbauCUYHmTAP8GulWG/thn4aIEj0e8LQK07QlRO
         fAbLf7u+Y4/rG3I5M//S1FPTWlVJ9GhnzGAWTMwANc1CxYcLq2TbjnzGBzm/CAfmokrw
         X2FX16SccnInlRaexFkbP5MEVkEjJ1cCnYQu29VCCkoOtkDsasvC9S2T9U1/TfOLMK+K
         139Y0gJu1ZHCNuauGBc2vaYBJULpLZ+i//bTBDFlaP17x9u/m9zOgO/wu1W8Utrx03mN
         WUlw==
X-Gm-Message-State: APjAAAUN9msvTF7cFLCH+DAzKZJ4JF6zhcKVS0ApXg3Q3vckIlCOieFp
	MF7INBEil6CHP97Z32vkgfc8HIH05JGWmJI9o3OcwPz4Xg0Lp686bxaGTtzUPjZhzNAj/RD6BDt
	YqlI8tpgRBjMwwV7b8SwrLe2eg4QhC8AwEq2+vKUndYAtS8GXCaOgpVvbYq1g1gA=
X-Received: by 2002:a9d:3d03:: with SMTP id a3mr22436002otc.72.1556139035526;
        Wed, 24 Apr 2019 13:50:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwi6/2CaSGt9Ra8W8n8iAw+6lH+iINQj33Klzf5sC1m/gCXfjf3JC+rmUFU6x5Ks8GKVorL
X-Received: by 2002:a9d:3d03:: with SMTP id a3mr22435958otc.72.1556139034748;
        Wed, 24 Apr 2019 13:50:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556139034; cv=none;
        d=google.com; s=arc-20160816;
        b=iLRd3owSGe+Kn8RHz3fIu35bMcEonR1a0H32zDfSAMtdQWAOEBckIj4LMpm80ZICPe
         e9CCDHwndmYnQ6ggKQ+KmMcs99yQudhadRAd/NHfOsKeOTNNOT1Nb04XQ4ngJrraO3G0
         p7W5LmwuAJ5JMuSMAeCWFV1oYIUEn3nQqjdmazN8sBIfS69IYMQoB5wlYdMBOsIXFYL1
         wnhrJe6f5GcDCL3GBo0JCJoiLVLqXj+wkM5yVFPADNKYqxajQULCK39KOwK2badgCUAk
         rtPipp2cszNu6XN1y76LLzNqKkDStcPTQVv5O8nRptMKd/QbbfC4uafXk1EpXXCTZUBz
         v0cA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=dagHIG0/uDgKzzzZeg2bbroAeyAEP6gZcPiOb0HPDgc=;
        b=kO9jujScR4WkNdQCJQl+f5z+I12LtNEspdH/Usqt8NQSDQvq0iFSEDXYetcWn6jPMj
         VQ9rrDePgr8ouODlNIxVi3hir9AyzS1I0YnFaiTnN1baWYZ/ugMllfLRbkQHrgkqQVE/
         twJdnz9DD/ShE/4E3cYtQ7+Bp619XPwqzkz9Fn9Wp1VxKL3zpOGGlSBqGMA6UWb0CAv8
         02+rw6lle70zkiKTzt9b0CwJs4XKb/QbB8cO9+msP08xO878f7oAtAwaXyEPyJOMdMi8
         ZCSoUgCfo2Gp3ScnQQEdGhIlG1BVcoUE8i6kkZQJe9xr45MfQ6F7xdBR0/i0faho3joF
         FKgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=K0+4Lyxh;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.81.115 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810115.outbound.protection.outlook.com. [40.107.81.115])
        by mx.google.com with ESMTPS id q3si10224763otn.207.2019.04.24.13.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 13:50:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of pburton@wavecomp.com designates 40.107.81.115 as permitted sender) client-ip=40.107.81.115;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=K0+4Lyxh;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.81.115 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=wavesemi.onmicrosoft.com; s=selector1-wavecomp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=dagHIG0/uDgKzzzZeg2bbroAeyAEP6gZcPiOb0HPDgc=;
 b=K0+4LyxhVUJ0vOGNGOd8PObmFCvltmaJbjpUJ4ojW5b2alX4kdC5BUzrSzeTrQYykDqiOcgRMVbrKBbUfRkgQkzpyN4+m0X9b4UatwgL6sXjZgcGEu9P5+5L4sGpSqRCHrKQeEvMiAcW+2iar51E5sDr+W0oiU4hjs5Cun00oLE=
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com (10.174.162.17) by
 MWHPR2201MB1040.namprd22.prod.outlook.com (10.174.169.138) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.12; Wed, 24 Apr 2019 20:50:31 +0000
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::b9d6:bf19:ec58:2765]) by MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::b9d6:bf19:ec58:2765%7]) with mapi id 15.20.1813.017; Wed, 24 Apr 2019
 20:50:31 +0000
From: Paul Burton <paul.burton@mips.com>
To: Aaro Koskinen <aaro.koskinen@iki.fi>
CC: "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: MIPS/CI20: BUG: Bad page state
Thread-Topic: MIPS/CI20: BUG: Bad page state
Thread-Index: AQHU+spp/ojd69QglkGCzSQtjt0+I6ZLsnQAgAAT/oCAAAKdAA==
Date: Wed, 24 Apr 2019 20:50:31 +0000
Message-ID: <20190424205016.yqtrlygqojii2rs6@pburton-laptop>
References: <20190424182012.GA21072@darkstar.musicnaut.iki.fi>
 <20190424192922.ilnn3oxc7ryzhd3l@pburton-laptop>
 <20190424204055.GB21072@darkstar.musicnaut.iki.fi>
In-Reply-To: <20190424204055.GB21072@darkstar.musicnaut.iki.fi>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR11CA0089.namprd11.prod.outlook.com
 (2603:10b6:a03:f4::30) To MWHPR2201MB1277.namprd22.prod.outlook.com
 (2603:10b6:301:24::17)
user-agent: NeoMutt/20180716
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [67.207.99.198]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: fdbfb9d3-42c4-48c6-330d-08d6c8f67d86
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:MWHPR2201MB1040;
x-ms-traffictypediagnostic: MWHPR2201MB1040:
x-ms-exchange-purlcount: 4
x-microsoft-antispam-prvs:
 <MWHPR2201MB104079557B7A8671F5CB37BCC13C0@MWHPR2201MB1040.namprd22.prod.outlook.com>
x-forefront-prvs: 00179089FD
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(979002)(7916004)(366004)(346002)(39850400004)(136003)(376002)(396003)(189003)(199004)(54094003)(478600001)(66556008)(1076003)(44832011)(64756008)(73956011)(476003)(486006)(7736002)(446003)(33716001)(53936002)(11346002)(6436002)(71200400001)(256004)(42882007)(68736007)(14444005)(305945005)(5660300002)(71190400001)(66446008)(6246003)(66476007)(6486002)(229853002)(66946007)(966005)(66066001)(14454004)(386003)(6506007)(102836004)(97736004)(26005)(99286004)(186003)(81166006)(8676002)(76176011)(52116002)(8936002)(81156014)(58126008)(2906002)(4326008)(9686003)(6512007)(6306002)(316002)(3846002)(6116002)(25786009)(54906003)(6916009)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1040;H:MWHPR2201MB1277.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 i3rqxhW0EHmzBxsVG6+9aqwqopMU2M5qw2XRApmJUTOMyqK8VbsmSBZDn286VvI8tPFp81SzKScmd7uEEfnbP6jwQAfXj/OCDtcjRIxHsBprrtZ8U3+TtTOhY+IXL/0OsJkv2ZenQ+dckXNc0NU8Xy/B1iC+FhAFRkWNklDn+ccTFRnvlFUMcWoxCP1QJk7r31wktPQ4TIkKySRiI+4RFsh4baM8rh/rsOlzqBnf/rz9McT8FjCk1O02DrDUhVHVnYPLWZZomDtNkw3bo86KFmehK/l6upUpNgMxzvUKtfzNOb/OT7VEXKJ6G7/1qi5+9JBbUF7KxTaya7DVAPaoEAmosL4ET6M8JNk6dJsyb1PGndg99Ulgs9zbc2B+2Re2Hjtu1F7AseOso94RkM6O6BNjz/xo2U+VQiQIUOSHjTU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <792F3D94E681F64898B3F8D1982535F6@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: fdbfb9d3-42c4-48c6-330d-08d6c8f67d86
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Apr 2019 20:50:31.5602
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Aaro,

On Wed, Apr 24, 2019 at 11:40:55PM +0300, Aaro Koskinen wrote:
> On Wed, Apr 24, 2019 at 07:29:29PM +0000, Paul Burton wrote:
> > On Wed, Apr 24, 2019 at 09:20:12PM +0300, Aaro Koskinen wrote:
> > > I have been trying to get GCC bootstrap to pass on CI20 board, but it
> > > seems to always crash. Today, I finally got around connecting the ser=
ial
> > > console to see why, and it logged the below BUG.
> > >=20
> > > I wonder if this is an actual bug, or is the hardware faulty?
> > >=20
> > > FWIW, this is 32-bit board with 1 GB RAM. The rootfs is on MMC, as we=
ll
> > > as 2 GB + 2 GB swap files.
> > >=20
> > > Kernel config is at the end of the mail.
> >=20
> > I'd bet on memory corruption, though not necessarily faulty hardware.
> >=20
> > Unfortunately memory corruption on Ci20 boards isn't uncommon... Someon=
e
> > did make some tweaks to memory timings configured in the DDR controller
> > which improved things for them a while ago:
> >=20
> >   https://github.com/MIPS/CI20_u-boot/pull/18
> >=20
> > Would you be up for testing with those tweaks? I'd be happy to help wit=
h
> > updating U-Boot if needed.
>=20
> Thanks, I wasn't aware of this, and seems like it could help.
>=20
> I guess instructions here <https://elinux.org/CI20_Dev_Zone> are valid,
> i.e. I can use MMC/SD card to re-flash the U-boot without the risk of
> bricking the board, if I understood correctly?

Yes that's correct. It's difficult to impossible to totally brick the
board, given the ability to boot from SD or USB & rewrite the NAND.

One option would be to just build the new U-Boot for SD boot, and leave
your NAND U-Boot entirely untouched until/unless you're satisfied that
the changes help.

> BTW, would it be possible to re-adjust these timings from the kernel side=
?

Maybe, I'm really not sure. So long as it can be done without destroying
any of the RAM content it would be OK, but I don't know if that's the
case.

> > Do you know which board revision you have? (Is it square or a funny
> > shape, green or purple, and does it have a revision number printed on
> > the silkscreen?)
>=20
> It's a purple one. Based on quick look all printings are identical to thi=
s
> one:
> https://images.anandtech.com/doci/8958/purple%20ci20_smaller_678x452.jpg

OK good to know - so it's a revision B board, which changed from Hynix
to Samsung DDR:

  https://elinux.org/CI20_Hardware#Board_Revisions_and_changes

That's also the revision Gabriele who submitted the U-Boot pull request
linked above has.

Thanks,
    Paul

