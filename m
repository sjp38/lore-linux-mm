Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B9E9C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:21:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33E33208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:21:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="HvR8LkL7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33E33208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D22C56B0005; Tue, 14 May 2019 03:21:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CACB16B0007; Tue, 14 May 2019 03:21:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4C166B0008; Tue, 14 May 2019 03:21:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85B096B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:21:36 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id x193so5824310oix.1
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:21:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=7I0I7EqMp9u8qoAqgsPq2edPo34Jt6gf97q8PQTA6gw=;
        b=Ws+yv+8Yf/Oa7f/asvAxmwVFZynMFPuohJwBDAyTFiHFXWs2HCm08wJeQNxuDsmrO/
         7SKZCLMZuaq45TctgRtpDW8UyFgnm66FKIxA+FXSy2FGwBZtrBZ8kx1wx4d4tuPxWw9L
         4M2ZnOldv4r0o+L3HN+ZWQxlpXbsLnttwPj9r7JaqSYjXUwuBbgHyiUYqME4+PBl0ALW
         nEPKFtK9iWs13HRQDVa0cZMcFE4qqrvj6hdCFTN319anjeB6XYpADk7cdhL8ooQR1yHu
         Q+fnTO8Flr0+oO2v0r6IKBgPLmRhllwdP3B/RFRedSXJrKp1DayjwIkvcEiLpIezf14A
         ERTw==
X-Gm-Message-State: APjAAAW7j6sEybnx9NMw2D0C5lLSb+yNRZvH+gx7fkFHu0sQ/UVKO6Pg
	zL9eYjiM0ST5czDEYTK53qd8BQ8qhxmQlojd0DV++SlsxCjdtH3EWJ3KNaO1cGThPn6qmLf3DH+
	fkhLTY4WSvyFsJ2fx9oWsznzmqki2cIielfGm8QuuVeVxEzvTeqNF29+Rcj4m+b/7NA==
X-Received: by 2002:aca:c348:: with SMTP id t69mr1975817oif.95.1557818496039;
        Tue, 14 May 2019 00:21:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyinmafBJX4e3VAJXW7CRkSEaHGp2rjDHo8CCSM1U410g5zCD7OcJ8BJ1Co/ZaNPoet9Jg/
X-Received: by 2002:aca:c348:: with SMTP id t69mr1975795oif.95.1557818495175;
        Tue, 14 May 2019 00:21:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557818495; cv=none;
        d=google.com; s=arc-20160816;
        b=u80sUPrsMv2YY1zX5BxhLUS+f7BCoAbfPgrUTjDDHborlqDhM/7N2hqzVDVbrxbajz
         wK05sGcCBXUB9PiOxagPbq3E7xsFNjU77oR9/5eew/fjT//tXWwvJiWMO74H5Sl2t8vs
         6fO/53hydiT1DK0c6M+ZfiJQbpdfvyvY7dwoyzsyfLJdzlguoOVogqvhiSQ/WWokK288
         EU8ICQBF7Evkub7qM6qKb5/PP3wHEeIv/aN9hkxKjB9DLZvrzEKZkHfcjrS1jmzcQgdI
         ZErG5z7gyEhI6/B6WX8AoL6hj5XkvXrhSRTcCY4dK9YoVzaqyM7bbmnPUxr8me9EBJOY
         eWZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=7I0I7EqMp9u8qoAqgsPq2edPo34Jt6gf97q8PQTA6gw=;
        b=E+IyWJWtMACzRviPhrQ6GXAR5obHtOafb/ozLLd1qb7MLnNbzKRRKx8akW3ItrxElx
         PSA3vd1+LDChRCABQ+mn1JkilfjDZ4zZTUVG3XdnSP6q+vT7eb7miwgthL/nYZjJ0/dg
         v1YhV4MCh40Y3LbwcRCd1u5xV73/jNzYmdDRXc4mKMmaamH5+PLU5DUeIgXY0O2sqcar
         qNuZ+IVG7BJgVDPnBOFA1nO0m0/dD+QjQ4AFlp3INldTI7yzx3C6wNPeUvIV+FDqNZ+S
         jRdAFX6yrvWE4iWyTo6m9z12JBnKvs508L9ehocK7oNsXLJbU6mt0v10nBOqAflojvdi
         /fVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=HvR8LkL7;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.81.84 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810084.outbound.protection.outlook.com. [40.107.81.84])
        by mx.google.com with ESMTPS id p19si476751otf.1.2019.05.14.00.21.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 May 2019 00:21:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.81.84 as permitted sender) client-ip=40.107.81.84;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=HvR8LkL7;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.81.84 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7I0I7EqMp9u8qoAqgsPq2edPo34Jt6gf97q8PQTA6gw=;
 b=HvR8LkL7t2fasfzTvvJk3WsltZRAIkASXXTez6W9A1wJ3YR6+fCBX+sgjGqs/DZFRbRpgNBZKMzZKGGOG7vr1QsotKorQtf/Nth5ybtw5SovtyMivfhc+MXJNgfDThE4252qz8Klhv2I77wPR/j+e7z7eLUEEmEVUq8gR+tX/qc=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5173.namprd05.prod.outlook.com (20.177.231.31) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.4; Tue, 14 May 2019 07:21:33 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098%7]) with mapi id 15.20.1900.010; Tue, 14 May 2019
 07:21:33 +0000
From: Nadav Amit <namit@vmware.com>
To: Jan Stancek <jstancek@redhat.com>
CC: Yang Shi <yang.shi@linux.alibaba.com>, Will Deacon <will.deacon@arm.com>,
	"peterz@infradead.org" <peterz@infradead.org>, "minchan@kernel.org"
	<minchan@kernel.org>, "mgorman@suse.de" <mgorman@suse.de>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Topic: [v2 PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Index: AQHVCfj1/ZS8SZ4p0ke1CH5gp1S1IPlIMumfrSIEdAA=
Date: Tue, 14 May 2019 07:21:33 +0000
Message-ID: <9E536319-815D-4425-B4B6-8786D415442C@vmware.com>
References: <45c6096e-c3e0-4058-8669-75fbba415e07@email.android.com>
 <914836977.22577826.1557818139522.JavaMail.zimbra@redhat.com>
In-Reply-To: <914836977.22577826.1557818139522.JavaMail.zimbra@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [50.204.119.4]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ac502c48-e668-4174-56e5-08d6d83ccac7
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB5173;
x-ms-traffictypediagnostic: BYAPR05MB5173:
x-microsoft-antispam-prvs:
 <BYAPR05MB5173E2C0864A692094A3A104D0080@BYAPR05MB5173.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1332;
x-forefront-prvs: 0037FD6480
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(396003)(346002)(136003)(376002)(366004)(51444003)(13464003)(189003)(199004)(26005)(6916009)(76116006)(486006)(82746002)(8936002)(11346002)(446003)(476003)(2616005)(53546011)(6506007)(3846002)(6116002)(8676002)(102836004)(64756008)(66946007)(86362001)(478600001)(66476007)(66556008)(99286004)(66446008)(76176011)(73956011)(2906002)(186003)(305945005)(33656002)(81166006)(81156014)(54906003)(14444005)(7736002)(25786009)(256004)(66066001)(4326008)(68736007)(83716004)(14454004)(71190400001)(71200400001)(6246003)(316002)(6436002)(5660300002)(6486002)(53936002)(229853002)(36756003)(6512007);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5173;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 jjvcp9/FuCA+7L2BLRNXI2KVPUCKVLkqEiABBUAolJOx08v596JYEHvi8zyej5TMk//dNwHPC0vzjiDo5fdGgG8mKoSw/LOPTRQSBlXWnirIGyuLD34jckMdDkxKt/2KThV1le9URf+Rya6TPXtbRIZEDHUIlgwYBpQ0s4c0dJPhdSlqgTMgyjlRNIvCFJe9umdHHhibwwfH9uPPj/UWdAnfHZaN4MNvve9gg8TLo2alcjFkCF0RPGYmpkdRm2aEkepPJq0cI2Hf7NIcFxWOzHAA+Txw4Ux+0T0ZS3Tm1pEI/aqxDBBJNcaRbcLegFZupiq6we1WvtE8zBneMUe1Cc67keYOdH69ZwHfXsgnLKbqbV5g0rNHMgrvEA8q/0zaHsvbiJzCXH2A01wrQMxqUm64PoDlJJjzeD/rWHu+TsE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <92DBC1E19E9DE0418FCBE6C11065680D@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ac502c48-e668-4174-56e5-08d6d83ccac7
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 May 2019 07:21:33.0143
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5173
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On May 14, 2019, at 12:15 AM, Jan Stancek <jstancek@redhat.com> wrote:
>=20
>=20
> ----- Original Message -----
>> On May 13, 2019 4:01 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>=20
>>=20
>> On 5/13/19 9:38 AM, Will Deacon wrote:
>>> On Fri, May 10, 2019 at 07:26:54AM +0800, Yang Shi wrote:
>>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>>>> index 99740e1..469492d 100644
>>>> --- a/mm/mmu_gather.c
>>>> +++ b/mm/mmu_gather.c
>>>> @@ -245,14 +245,39 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>>>  {
>>>>      /*
>>>>       * If there are parallel threads are doing PTE changes on same ra=
nge
>>>> -     * under non-exclusive lock(e.g., mmap_sem read-side) but defer T=
LB
>>>> -     * flush by batching, a thread has stable TLB entry can fail to f=
lush
>>>> -     * the TLB by observing pte_none|!pte_dirty, for example so flush=
 TLB
>>>> -     * forcefully if we detect parallel PTE batching threads.
>>>> +     * under non-exclusive lock (e.g., mmap_sem read-side) but defer =
TLB
>>>> +     * flush by batching, one thread may end up seeing inconsistent P=
TEs
>>>> +     * and result in having stale TLB entries.  So flush TLB forceful=
ly
>>>> +     * if we detect parallel PTE batching threads.
>>>> +     *
>>>> +     * However, some syscalls, e.g. munmap(), may free page tables, t=
his
>>>> +     * needs force flush everything in the given range. Otherwise thi=
s
>>>> +     * may result in having stale TLB entries for some architectures,
>>>> +     * e.g. aarch64, that could specify flush what level TLB.
>>>>       */
>>>> -    if (mm_tlb_flush_nested(tlb->mm)) {
>>>> -            __tlb_reset_range(tlb);
>>>> -            __tlb_adjust_range(tlb, start, end - start);
>>>> +    if (mm_tlb_flush_nested(tlb->mm) && !tlb->fullmm) {
>>>> +            /*
>>>> +             * Since we can't tell what we actually should have
>>>> +             * flushed, flush everything in the given range.
>>>> +             */
>>>> +            tlb->freed_tables =3D 1;
>>>> +            tlb->cleared_ptes =3D 1;
>>>> +            tlb->cleared_pmds =3D 1;
>>>> +            tlb->cleared_puds =3D 1;
>>>> +            tlb->cleared_p4ds =3D 1;
>>>> +
>>>> +            /*
>>>> +             * Some architectures, e.g. ARM, that have range invalida=
tion
>>>> +             * and care about VM_EXEC for I-Cache invalidation, need
>>>> force
>>>> +             * vma_exec set.
>>>> +             */
>>>> +            tlb->vma_exec =3D 1;
>>>> +
>>>> +            /* Force vma_huge clear to guarantee safer flush */
>>>> +            tlb->vma_huge =3D 0;
>>>> +
>>>> +            tlb->start =3D start;
>>>> +            tlb->end =3D end;
>>>>      }
>>> Whilst I think this is correct, it would be interesting to see whether
>>> or not it's actually faster than just nuking the whole mm, as I mention=
ed
>>> before.
>>>=20
>>> At least in terms of getting a short-term fix, I'd prefer the diff belo=
w
>>> if it's not measurably worse.
>>=20
>> I did a quick test with ebizzy (96 threads with 5 iterations) on my x86
>> VM, it shows slightly slowdown on records/s but much more sys time spent
>> with fullmm flush, the below is the data.
>>=20
>>                                     nofullmm                 fullmm
>> ops (records/s)              225606                  225119
>> sys (s)                            0.69                        1.14
>>=20
>> It looks the slight reduction of records/s is caused by the increase of
>> sys time.
>>=20
>>> Will
>>>=20
>>> --->8
>>>=20
>>> diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
>>> index 99740e1dd273..cc251422d307 100644
>>> --- a/mm/mmu_gather.c
>>> +++ b/mm/mmu_gather.c
>>> @@ -251,8 +251,9 @@ void tlb_finish_mmu(struct mmu_gather *tlb,
>>>        * forcefully if we detect parallel PTE batching threads.
>>>        */
>>>       if (mm_tlb_flush_nested(tlb->mm)) {
>>> +             tlb->fullmm =3D 1;
>>>               __tlb_reset_range(tlb);
>>> -             __tlb_adjust_range(tlb, start, end - start);
>>> +             tlb->freed_tables =3D 1;
>>>       }
>>>=20
>>>       tlb_flush_mmu(tlb);
>>=20
>>=20
>> I think that this should have set need_flush_all and not fullmm.
>=20
> Wouldn't that skip the flush?
>=20
> If fulmm =3D=3D 0, then __tlb_reset_range() sets tlb->end =3D 0.
>  tlb_flush_mmu
>    tlb_flush_mmu_tlbonly
>      if (!tlb->end)
>         return
>=20
> Replacing fullmm with need_flush_all, brings the problem back / reproduce=
r hangs.

Maybe setting need_flush_all does not have the right effect, but setting
fullmm and then calling __tlb_reset_range() when the PTEs were already
zapped seems strange.

fullmm is described as:

        /*
         * we are in the middle of an operation to clear
         * a full mm and can make some optimizations
         */

And this not the case.

