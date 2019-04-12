Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90D01C282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:11:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A207218D9
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:11:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="Kq/KZjZc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A207218D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79C8B6B000C; Fri, 12 Apr 2019 11:11:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 722946B000D; Fri, 12 Apr 2019 11:11:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C4AA6B0010; Fri, 12 Apr 2019 11:11:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36FCB6B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:11:28 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id n23so8000181ioj.10
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:11:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=CblifaIgK0a0yactFkBmkwVwbbx6zCY5JQRYvccqPgw=;
        b=lanVmqCTNiaYP1/77xN7N6eyv+hksqSeh1TFgquoY4u1Y1HRFnb81Wv8yheaRu/TJX
         a+yZdMzbRousGv6grAfKDK11dE0oqXiowKf0mkAsEksMrVPpIMgjmDOEpBaSJSK3L7C6
         6fXDE4S36caaLgTgLk6jZcPfRymE4pOC7kfZ8lTiupAg0ncP2o7x97Qskdbmxf0qLMix
         YMBl46W5/lQaYWYbWVes+A2Z8ySMsKtOs0B/p5DtJ1NIGaupuOfSMqfUn6ksMidjS/zB
         Ete3omd60dGhPcVz4qWSsjMEWVQwvWUVIvtdcfQkS5MehCTbtWx0BzCD5+FhVGsxKzZ7
         ZzHg==
X-Gm-Message-State: APjAAAX/QSvZwUjBLMQgAArt/U4B4xr3NxFq19sTqu7bO7zlPyEG9wmA
	kDdsbTe2SfRsHKxxCMpPoF3lHZSSSUTb9EUZ1gVbb50sj/ofIyPhxJeUbI2y61LjHA8jzA6/obB
	6AkI0ZhA8ddHdbncz4hyYtucCjxY3xvEMP7O7swDjOmC+Jvr3qSOXs4oOMjErm5uobQ==
X-Received: by 2002:a5e:950f:: with SMTP id r15mr24603973ioj.88.1555081887932;
        Fri, 12 Apr 2019 08:11:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAxNj2ebRXJpDRxc574GIJ8nq+sGXL2koY76FI62M8BtKqaPU19Av8gS8afifXEoT+CuqB
X-Received: by 2002:a5e:950f:: with SMTP id r15mr24603889ioj.88.1555081886901;
        Fri, 12 Apr 2019 08:11:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555081886; cv=none;
        d=google.com; s=arc-20160816;
        b=Fh6/B33y9Yp8insD2b6psHDt9eUjzufdWgtX8Gsy/+DnLPu5UoMJ7c1g8yTBmFquIw
         E3lk+q45OGfR75PP/Ot8Qo/CC2EZUywjHwT44MYxAYhSyvUMty1bYx9AkiuT5KR8AuTR
         3mhpLk8owS5a8iMtXOOJKVfzPs0fqHZqGYoMJAEbnF4TmNFgMUjQ9AhYopPoZxA5gTkU
         zzn+Pvw/+icXx9w9laIvrjMYHoWBYalshggF99LcUFn4A+v6hL3E7HUluMiUsMgpySmz
         rDHLxXRcX+cNpgS7KCI2RYb6JI642X6QSmNaTFOLCWq9A8U7FnfTVtpvOj6Eu+uH0Xkp
         M1jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=CblifaIgK0a0yactFkBmkwVwbbx6zCY5JQRYvccqPgw=;
        b=H/mFp2kGf11iZ5ezr+MqLk5cOtIVzfG7xnfAWDpQiVxnyR2XtUTjZZJj2HOvFOwjpg
         zIks4oA/gIhgwY2TSBVoAqa6eMYaM9iGzu9SeYzJU/ddQfol4KwTzraWtTsn0dJ5bC2b
         BkHmAqYQbQvN0O8FKD+KXEV01QQMt1TbM9lJt019QKFRKIPX4E1TjS2+MKDUgT95Q3fk
         LMdhYgP2BUIEK2n8wZGXllaHi2pzR1fn2g9BSnOo4s8SiFZqoGw88T2pm7vZ1kuMy+dD
         sEYlMU9fYqdcBfDnJcayqCSjZ0M49ZD+5Ac8ZL1ltIueNHale41Vn3Z6hegfPgX/VWuz
         pzhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b="Kq/KZjZc";
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.75.71 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750071.outbound.protection.outlook.com. [40.107.75.71])
        by mx.google.com with ESMTPS id o139si5151479itc.66.2019.04.12.08.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 12 Apr 2019 08:11:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.75.71 as permitted sender) client-ip=40.107.75.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b="Kq/KZjZc";
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.75.71 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CblifaIgK0a0yactFkBmkwVwbbx6zCY5JQRYvccqPgw=;
 b=Kq/KZjZcBE38oiy8CulDsvHMV6MeFfXqnuN5HCJbS9Ddrgm/eH7wc+iRqZMlN2jtJSVy9tQdG1mlia+pJyv0/bwOXYn/fsRmnz/EIG+iOZ6zPIRJEWdn3gPK4vy6PcwSeHH2zZWhXXPQmN3FK/Fd6iNW1thX5O1omRWK/h3wCuc=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5798.namprd05.prod.outlook.com (20.178.49.31) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.12; Fri, 12 Apr 2019 15:11:23 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd%4]) with mapi id 15.20.1792.009; Fri, 12 Apr 2019
 15:11:22 +0000
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>
CC: kernel test robot <lkp@intel.com>, LKP <lkp@01.org>, Linux List Kernel
 Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, Andy
 Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Thread-Topic: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Thread-Index: AQHU8R5sUhi0mJ9uO0aA/EiVew3tvaY4YIQAgABBN4A=
Date: Fri, 12 Apr 2019 15:11:22 +0000
Message-ID: <F18AF0D5-D8B4-4F4B-8469-F9DEC49683C7@vmware.com>
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
 <20190411193906.GA12232@hirez.programming.kicks-ass.net>
 <20190411195424.GL14281@hirez.programming.kicks-ass.net>
 <20190411211348.GA8451@worktop.programming.kicks-ass.net>
 <20190412105633.GM14281@hirez.programming.kicks-ass.net>
 <20190412111756.GO14281@hirez.programming.kicks-ass.net>
In-Reply-To: <20190412111756.GO14281@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9eb92dcf-e0b9-4f9e-6024-08d6bf592009
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB5798;
x-ms-traffictypediagnostic: BYAPR05MB5798:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR05MB57987D00480ABB0CA44B7565D0280@BYAPR05MB5798.namprd05.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(376002)(136003)(366004)(396003)(346002)(189003)(199004)(6916009)(6436002)(14454004)(54906003)(25786009)(966005)(561944003)(99286004)(6116002)(3846002)(93886005)(53546011)(36756003)(316002)(6246003)(5660300002)(26005)(86362001)(102836004)(76176011)(6506007)(186003)(478600001)(4326008)(2906002)(14444005)(256004)(53936002)(305945005)(105586002)(6512007)(2616005)(97736004)(82746002)(7736002)(45080400002)(33656002)(486006)(7416002)(81166006)(229853002)(81156014)(446003)(4001150100001)(11346002)(8676002)(68736007)(6486002)(66066001)(71190400001)(8936002)(71200400001)(83716004)(106356001)(6306002)(476003)(41533002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5798;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 oRdiSsRnaIk9VQM+yMqBjpEftg29X1KgmR8ATSwqTyo+VyBuj3Z8KKC5N7ZvURQveEohZoA3cEaNaHr2oqiN6KDlWW5zyIze6XfSATbuyTM3//HMZ4cVJGtRyyyI6dm0Jj4jdsgp9J7VI6TXy1P5KkcDEKavKi9tQj5sMQDrusFOfkscLZp3yyKp+eeF7y3urGyjTHAyTt9b7X345mWQYuffwVBXE+sv4x3FPqp2l8tDUOAz6tyUC7c1qDJTcAYVzMz/ubhN/Vs94CSHASNqPicpPEP0Twpv0A7xiJaVy41/DKELZZjdeJqVV2MjP3cq2fdPQVpMiHU4fp1Yh9zrnp7YreNgGQPDft0Js2mcJMcC7P11pkPPSaQ2cTmrV8c4IM87Y3IJfZRcid4qzODPYU5J6sIU+j8k2nrlr/Vlh/8=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FC7CFD56A8DCCF41B17373B5081D79FD@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9eb92dcf-e0b9-4f9e-6024-08d6bf592009
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 15:11:22.6431
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5798
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Apr 12, 2019, at 4:17 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
> On Fri, Apr 12, 2019 at 12:56:33PM +0200, Peter Zijlstra wrote:
>> On Thu, Apr 11, 2019 at 11:13:48PM +0200, Peter Zijlstra wrote:
>>> On Thu, Apr 11, 2019 at 09:54:24PM +0200, Peter Zijlstra wrote:
>>>> On Thu, Apr 11, 2019 at 09:39:06PM +0200, Peter Zijlstra wrote:
>>>>> I think this bisect is bad. If you look at your own logs this patch
>>>>> merely changes the failure, but doesn't make it go away.
>>>>>=20
>>>>> Before this patch (in fact, before tip/core/mm entirely) the errror
>>>>> reads like the below, which suggests there is memory corruption
>>>>> somewhere, and the fingered patch just makes it trigger differently.
>>>>>=20
>>>>> It would be very good to find the source of this corruption, but I'm
>>>>> fairly certain it is not here.
>>>>=20
>>>> I went back to v4.20 to try and find a time when the below error did n=
ot
>>>> occur, but even that reliably triggers the warning.
>>>=20
>>> So I also tested v4.19 and found that that was good, which made me
>>> bisect v4.19..v4.20
>>>=20
>>> # bad: [8fe28cb58bcb235034b64cbbb7550a8a43fd88be] Linux 4.20
>>> # good: [84df9525b0c27f3ebc2ebb1864fa62a97fdedb7d] Linux 4.19
>>> git bisect start 'v4.20' 'v4.19'
>>> # bad: [ec9c166434595382be3babf266febf876327774d] Merge tag 'mips_fixes=
_4.20_1' of git://git.kernel.org/pub/scm/linux/kernel/git/mips/linux
>>> git bisect bad ec9c166434595382be3babf266febf876327774d
>>> # bad: [50b825d7e87f4cff7070df6eb26390152bb29537] Merge git://git.kerne=
l.org/pub/scm/linux/kernel/git/davem/net-next
>>> git bisect bad 50b825d7e87f4cff7070df6eb26390152bb29537
>>> # good: [99e9acd85ccbdc8f5785f9e961d4956e96bd6aa5] Merge tag 'mlx5-upda=
tes-2018-10-17' of git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linu=
x
>>> git bisect good 99e9acd85ccbdc8f5785f9e961d4956e96bd6aa5
>>> # good: [c403993a41d50db1e7d9bc2d43c3c8498162312f] Merge tag 'for-linus=
-4.20' of https://nam04.safelinks.protection.outlook.com/?url=3Dhttps%3A%2F=
%2Fgithub.com%2Fcminyard%2Flinux-ipmi&amp;data=3D02%7C01%7Cnamit%40vmware.c=
om%7Ca1c3ea5d4bc34cfc785508d6bf388ff3%7Cb39138ca3cee4b4aa4d6cd83d9dd62f0%7C=
0%7C0%7C636906647013777573&amp;sdata=3D3VSR3VdE5rxOitAdkqFNPpAnAtLgDmYLzJto=
Urs5v9Y%3D&amp;reserved=3D0
>>> git bisect good c403993a41d50db1e7d9bc2d43c3c8498162312f
>>> # good: [c05f3642f4304dd081876e77a68555b6aba4483f] Merge branch 'perf-c=
ore-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>>> git bisect good c05f3642f4304dd081876e77a68555b6aba4483f
>>> # bad: [44786880df196a4200c178945c4d41675faf9fb7] Merge branch 'parisc-=
4.20-1' of git://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linu=
x
>>> git bisect bad 44786880df196a4200c178945c4d41675faf9fb7
>>> # bad: [99792e0cea1ed733cdc8d0758677981e0cbebfed] Merge branch 'x86-mm-=
for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>>> git bisect bad 99792e0cea1ed733cdc8d0758677981e0cbebfed
>>> # good: [fec98069fb72fb656304a3e52265e0c2fc9adf87] Merge branch 'x86-cp=
u-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
>>> git bisect good fec98069fb72fb656304a3e52265e0c2fc9adf87
>>> # bad: [a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542] x86/mm: Page size awa=
re flush_tlb_mm_range()
>>> git bisect bad a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542
>>> # good: [a7295fd53c39ce781a9792c9dd2c8747bf274160] x86/mm/cpa: Use flus=
h_tlb_kernel_range()
>>> git bisect good a7295fd53c39ce781a9792c9dd2c8747bf274160
>>> # good: [9cf38d5559e813cccdba8b44c82cc46ba48d0896] kexec: Allocate decr=
ypted control pages for kdump if SME is enabled
>>> git bisect good 9cf38d5559e813cccdba8b44c82cc46ba48d0896
>>> # good: [5b12904065798fee8b153a506ac7b72d5ebbe26c] x86/mm/doc: Clean up=
 the x86-64 virtual memory layout descriptions
>>> git bisect good 5b12904065798fee8b153a506ac7b72d5ebbe26c
>>> # good: [cf089611f4c446285046fcd426d90c18f37d2905] proc/vmcore: Fix i38=
6 build error of missing copy_oldmem_page_encrypted()
>>> git bisect good cf089611f4c446285046fcd426d90c18f37d2905
>>> # good: [a5b966ae42a70b194b03eaa5eaea70d8b3790c40] Merge branch 'tlb/as=
m-generic' of git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux int=
o x86/mm
>>> git bisect good a5b966ae42a70b194b03eaa5eaea70d8b3790c40
>>> # first bad commit: [a31acd3ee8f7dbc0370bdf4a4bfef7a8c13c7542] x86/mm: =
Page size aware flush_tlb_mm_range()
>>>=20
>>> And 'funnily' the bad patch is one of mine too :/
>>>=20
>>> I'll go have a look at that tomorrow, because currrently I'm way past
>>> tired.
>>=20
>> OK, so the below patchlet makes it all good. It turns out that the
>> provided config has:
>>=20
>> CONFIG_X86_L1_CACHE_SHIFT=3D7
>>=20
>> which then, for some obscure raisin, results in flush_tlb_mm_range()
>> compiling to use 320 bytes of stack:
>>=20
>>  sub    $0x140,%rsp
>>=20
>> Where a 'defconfig' build results in:
>>=20
>>  sub    $0x58,%rsp
>>=20
>> The thing that pushes it over the edge in the above fingered patch is
>> the addition of a field to struct flush_tlb_info, which grows if from 32
>> to 36 bytes.
>>=20
>> So my proposal is to basically revert that, unless we can come up with
>> something that GCC can't screw up.
>=20
> To clarify, 'that' is Nadav's patch:
>=20
>  515ab7c41306 ("x86/mm: Align TLB invalidation info")
>=20
> which turns out to be the real problem.

Sorry for that. I still think it should be aligned, especially with all the
effort the Intel puts around to avoid bus-locking on unaligned atomic
operations.

So the right solution seems to me as putting this data structure off stack.
It would prevent flush_tlb_mm_range() from being reentrant, so we can keep =
a
few entries for this matter and atomically increase the entry number every
time we enter flush_tlb_mm_range().

But my question is - should flush_tlb_mm_range() be reentrant, or can we
assume no TLB shootdowns are initiated in interrupt handlers and #MC
handlers?

