Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80F00C282C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 19:00:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30A732086C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 19:00:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavesemi.onmicrosoft.com header.i=@wavesemi.onmicrosoft.com header.b="jF2XO5hx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30A732086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5FA78E0060; Thu,  7 Feb 2019 14:00:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC1888E0002; Thu,  7 Feb 2019 14:00:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3B8D8E0060; Thu,  7 Feb 2019 14:00:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 580938E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 14:00:13 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o62so510849pga.16
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 11:00:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=mdLCWm/y+1EwdazVy0gpYpMrY5LIQZMeyNsI1Ir0wI4=;
        b=peVkNndljOLEY4VeMyardnuiaL2Gr57IZyyivEabQtzo7kWnH5xz4Q5ZFcciIx9kuT
         zMymKf/7Fr+GMRZx3pFESKENKvXtseZiPnqNRpRICuLAP7aEr/6GcdVvBkAyHAuC6evu
         Byj7Lhrqdqh5JghZ7Q391XIWLOTXHvL3eN3HkvfnMsnZKxWTqK+UCDbxpofVwVEgyU7A
         +sawN+/ArMTqeWvl4CTORoRRxpRE1u14JQtGQnsFE2VJKGc/dOiCtAvX6GEuseL2WPxH
         Jec3Tuw9V+WuckxgWuN90piG3gP1UCGu89UAegV4tGZzlSL+ClrXJG4OCpSE+7kHK7qt
         Kjmw==
X-Gm-Message-State: AHQUAuYCkVjeP/ZvfF5KcPqRjJohAIcs+5KMWAXx+9XEvwpYj9pg1UDq
	mV+qgjTsv8+n2s8T24J+rOhdljPiSxX2lS6AMOuQjroaSk7QLAwnJALWppf7O5Fv9yrpfa8l+w/
	3yEfk/9QUn8DwtklLO4Zn/c8S0O0hv9xUcnJ5dmgzk8MSh8tlB4cuZaHcK9vv9bg=
X-Received: by 2002:a63:6bc1:: with SMTP id g184mr1013469pgc.25.1549566012925;
        Thu, 07 Feb 2019 11:00:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbnzWlvmP0GiJNaKdIFn+ow8uIdRVMppeQpSxHODuCqJ8tK+BSsKrynJk3N2IDghXQ3TiTD
X-Received: by 2002:a63:6bc1:: with SMTP id g184mr1013384pgc.25.1549566011999;
        Thu, 07 Feb 2019 11:00:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549566011; cv=none;
        d=google.com; s=arc-20160816;
        b=GtyXr6dih2CodRNs1Zc1UHK7f6hkUt076eA9aIQIMjzFf1SB9XKmCKOfidx6OMS1Ud
         wOj4ss8+DTGYkuj43z7vrXFq4hiYFJMrEXzIXa3ItLeBdCdRQZhWO9sB3I9dXeOnGMNe
         cj8fj1+1ktoHH3NbvalsJ8OVlkaqoADt/FZY8/z8ZI0C3H2aZjD4bikaocxnL4EEawGv
         hW63lml5ELKQGxbosUCaU1QQZjRUF4/V2cg/PywFpdu/DFqzYLn1w+EGYNxvHhMv8CuC
         SbH5h3LSi7DjeLuxo0uh166q/fFrdnXaMiNi3Ng5jHvAZ2Rh2Q1lTxqFbwjf0Y43vz5Z
         hIKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=mdLCWm/y+1EwdazVy0gpYpMrY5LIQZMeyNsI1Ir0wI4=;
        b=nqVeAp8xDCFyWDVqmCXgFDfMeIjD2jiFINVQaxbQWRVzpJ6RwE8BRcEZtRfCEpw1TQ
         7oPbB6EXT1olkdAAID0DBtRG0R8uJD3qTHpZLvpij8TJe+pAcHCChT/FDbcL+g8YGgnT
         pfGX6x9ZnuPh5t/CyQg7ylomhCRBU3Aq6mxKMksHC7bd1gHpV8L+5ogcSpTPshVVHz4V
         OiTnAM3iW1lBxCZPfl2gnaNprVSGCMZlEQaXwK9Z/0C4hHBBUBYa+l/wbng0jslIHCma
         v9Z/squOs63seP/bWz1Hho+jOVqpJguYLrPw3h8ACV40EtgQ7qMA088qOU3hC55wev0U
         kJvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=jF2XO5hx;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.76.125 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760125.outbound.protection.outlook.com. [40.107.76.125])
        by mx.google.com with ESMTPS id r10si6209493pgr.489.2019.02.07.11.00.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 11:00:11 -0800 (PST)
Received-SPF: pass (google.com: domain of pburton@wavecomp.com designates 40.107.76.125 as permitted sender) client-ip=40.107.76.125;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wavesemi.onmicrosoft.com header.s=selector1-wavecomp-com header.b=jF2XO5hx;
       spf=pass (google.com: domain of pburton@wavecomp.com designates 40.107.76.125 as permitted sender) smtp.mailfrom=pburton@wavecomp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=wavesemi.onmicrosoft.com; s=selector1-wavecomp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=mdLCWm/y+1EwdazVy0gpYpMrY5LIQZMeyNsI1Ir0wI4=;
 b=jF2XO5hxPNRvvoZ1sA6WgfQXUGNaUML8zEexZjFRlFFyu8ixJ8Ai5+sk/7M9Glk0LaoVb2IXPgclwMag8VVVzNo/y//zxPELx7+vKEZ2FPJfe/XRi7Xh/JMzbJ1yMDgDRVzKifTkKpppz1NQx/BhS8ZweMVcEBbvTdkgVU0gsrU=
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com (10.174.162.17) by
 MWHPR2201MB1391.namprd22.prod.outlook.com (10.172.63.9) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.19; Thu, 7 Feb 2019 19:00:09 +0000
Received: from MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::7d5e:f3b0:4a5:4636]) by MWHPR2201MB1277.namprd22.prod.outlook.com
 ([fe80::7d5e:f3b0:4a5:4636%9]) with mapi id 15.20.1580.019; Thu, 7 Feb 2019
 19:00:09 +0000
From: Paul Burton <paul.burton@mips.com>
To: Davidlohr Bueso <dave@stgolabs.net>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>, James
 Hogan <jhogan@kernel.org>, "linux-mips@vger.kernel.org"
	<linux-mips@vger.kernel.org>, Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 2/2] MIPS/c-r4k: do no use mmap_sem for gup_fast()
Thread-Topic: [PATCH 2/2] MIPS/c-r4k: do no use mmap_sem for gup_fast()
Thread-Index: AQHUvqdibN/VJXh0p0CcjWrTW3p8AqXUsWAA
Date: Thu, 7 Feb 2019 19:00:09 +0000
Message-ID: <20190207190007.jz4rz6e6qxwazxm7@pburton-laptop>
References: <20190207053740.26915-1-dave@stgolabs.net>
 <20190207053740.26915-3-dave@stgolabs.net>
In-Reply-To: <20190207053740.26915-3-dave@stgolabs.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR02CA0027.namprd02.prod.outlook.com
 (2603:10b6:a02:ee::40) To MWHPR2201MB1277.namprd22.prod.outlook.com
 (2603:10b6:301:24::17)
user-agent: NeoMutt/20180716
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [67.207.99.198]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;MWHPR2201MB1391;6:ls39BYP+zaS44uQFrRD23ArLAkMSTg/w0CLWKxRrAJX3mnIuXpHt80ptJj15Xdi1C0aoYEfgADrVF/JnPvpXZzQMWL1t0SUPBAAdCLRJIhEnnZJWJbRRvlbTjlOjUJ7GShdDwZX5M/EmU/5ay5nmSRMmNemwIu//48Mbfg8GBgZA0KIKBEFN/grkIJ5Cp1p9bxCXnJAJoyDfpW8O9NrxkwIkWWRgcZnaaaCNgWco417acoc8pRwSuA1/PLDPQF7Cn8T0OE4sRpdmMOVSJxcQAZZe9sKU9DlZImwCPQx1rW9A198JaoEHcFN0y48CnyGQB2rvCiCAAh1KbuYb9R0WaJvnZesPLA+YmDNlSILA5cZCw5IFBgOcjqTIyVUXSloR7cqRWNPGcZchHU1pkRTGWRcN/owRbdtioLGKwQpgqm1I+7qP4RHnAhmPoTA5XAFmFGYf18hFnFwzNBrDReN9NQ==;5:jnz9jjdQJyel2v3AY5NETiYkOCy8O0CGU9wtpwW04M5fXxhG+ETSNWlncE5zHjQ79UvMsRAuSr++/VOe4jmmWbwHEVsWoL81LxYmzGgo/EgwByizQpktXdGG1HY6NuiBc97DMWM6gZlghXNCkuIBTv+AikfXvP+ZkNmL683pt0WvWaWXB40SpN7eBDOaHYTVwGsVj/LNVgWxMUCgHVfqJA==;7:ZOYcPcK/u+SijvFOKaTQzlX9kdoCoOtgKyhvVthq/ppvGtifrAdmG2GVy3CjWoWJaIEAu6dlQJAjza4lZfFIxqe7gfx8oP1Ka8YpGJP06lS5/LZEt+g4FZj6rSwAD24uCXq69IpZ+kmF4p2kgmbsbw==
x-ms-office365-filtering-correlation-id: 8183cfbf-3a91-49a7-e4e9-08d68d2e7b24
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:MWHPR2201MB1391;
x-ms-traffictypediagnostic: MWHPR2201MB1391:
x-microsoft-antispam-prvs:
 <MWHPR2201MB139168B3154F0FAB077FEFE7C1680@MWHPR2201MB1391.namprd22.prod.outlook.com>
x-forefront-prvs: 0941B96580
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(7916004)(396003)(376002)(136003)(39850400004)(346002)(366004)(199004)(189003)(97736004)(68736007)(305945005)(4326008)(8936002)(6246003)(14444005)(7736002)(99286004)(81156014)(6916009)(8676002)(256004)(2906002)(81166006)(6512007)(9686003)(6486002)(478600001)(186003)(229853002)(66066001)(71190400001)(71200400001)(4744005)(14454004)(26005)(386003)(44832011)(6436002)(6506007)(25786009)(54906003)(58126008)(316002)(52116002)(76176011)(33896004)(53936002)(33716001)(102836004)(105586002)(106356001)(486006)(42882007)(3846002)(6116002)(1076003)(446003)(476003)(11346002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1391;H:MWHPR2201MB1277.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 UzUxSDcix+Y2r26Gsq5Okh1ymaWeedUI299LyhBWkPt3z/FXReSrf2GNHYk4Rl7bUgY5lCPLMPafWHsRlI9gGycS7esvbfenePR/76W4QZx7lHWBu2/uhVbhP4v/iNuaByeYZMe8FQcsToWaw6Ec3YzMJGrKvYil3FWh6D40YPgiYZzex97DswfeosIs1mPcCVbh/TjedA2PC7m68Fa9wq24izUQyqUZBrCxDeeAgd8uz1NNMv20nfxf6Be+v8DGMuLt+UNhw9+jMwqbsXbjAodRsbQdxGE7OoejGP1I7LIKt5INx17lIpg7nccaesFtj0b6wnaGxy+ytAubsvp8z4BurpVZ9nCkNo0ik8HNyrWPvpj3qYVvrDNMMAqOQ9ErSTlLNrvD3h7kui3NaXAOi3+oQuCbymhkQyXs8Ub9daI=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <71A7310B61D4C846AF3BC8DAE9D665F4@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8183cfbf-3a91-49a7-e4e9-08d68d2e7b24
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Feb 2019 19:00:08.8667
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1391
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Davidlohr,

On Wed, Feb 06, 2019 at 09:37:40PM -0800, Davidlohr Bueso wrote:
> It is well known that because the mm can internally
> call the regular gup_unlocked if the lockless approach
> fails and take the sem there, the caller must not hold
> the mmap_sem already.
>=20
> Fixes: e523f289fe4d (MIPS: c-r4k: Fix sigtramp SMP call to use kmap)
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: Paul Burton <paul.burton@mips.com>
> Cc: James Hogan <jhogan@kernel.org>
> Cc: linux-mips@vger.kernel.org
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Thanks - this looks good, but:

 1) The problem it fixes was introduced in v4.8.

 2) Commit adcc81f148d7 ("MIPS: math-emu: Write-protect delay slot
    emulation pages") actually left flush_cache_sigtramp unused, and has
    been backported to stable kernels also as far as v4.8.

Therefore this will just fix code that never gets called, and I'll go
delete the whole thing instead.

Thanks,
    Paul

