Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CE01C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:08:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5780217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 01:08:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="jtkrfv5h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5780217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7144C8E01A5; Mon, 11 Feb 2019 20:08:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69BDC8E019C; Mon, 11 Feb 2019 20:08:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B2B78E01A5; Mon, 11 Feb 2019 20:08:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 187598E019C
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 20:08:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id g188so712993pgc.22
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:08:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version:content-transfer-encoding;
        bh=WfZyIsccqWR3lZErvejq0nP1VhlSzDJCMVE8xMZxBo4=;
        b=mj29wnZgO9NUMPz3bCpLqEYBrmWxcSMYI87RgTB9MsnNXlZUN0i8mFLvcgXLF3e8gC
         +AvDZbFLK3A3qM590nOXSKQBLuhp/T/WDVOtR5FZb3MUxFPDjJ0+v923gDq+3jevqiyq
         OjvjbAWoA8PMkD2CZWaraBSvAMzbt7kOa1ghNG9oVq8n2KkORKpfeFiXk20p55BlYfv4
         1rdbhhB3I8D2x7SMQgQF2FcUCA6Co3vzPuo9S7gKc+sigH0JaQUAP4jWUr+mWweA12c/
         LwX9x+q7ITGPZ8OCzwSlZ1RRVUVH7XVut5M4NfAEfnDtywOJol4kkLvFPBU80awrIHyS
         NLMA==
X-Gm-Message-State: AHQUAub48O+WkSTAV3n7+hV1hLaMTqN1yYYnKW4LZMRw+NpNKapNYPCd
	Cge/P/JDYFou7Ko/oQp5iZrnukBH77glVufkfliGPdbMriVYy4AFE2LYsb+EZc4LzEAkTz5XdCB
	DLb8y+MBnuwbkIZ7vY78Xs2lo4+o3mvFkBwvQymZNWabG8S3zfCZPFFEp6Eh/XllKc7CpwNmj6m
	tTyGIBDboe20s4+bDdxR4VSKE2V6k75Ar08khXQtfXLF49ej7j30/76w7neqnqDyc5E+gBP82nT
	OXsLpGdcLsXHz3zzu2IznRsw8IySTVpaQIrGUw9RtbdQEUJ9Bsm1OM9cq94dxx4876dm6TFTxa5
	0UtFS8amlh//A2RQ//Nv7rJQ6ubAhbmHOeGq7V0ibmH6Bs/pvOULFdH7sVmcTshltBoAEfPfClV
	D
X-Received: by 2002:a63:da45:: with SMTP id l5mr1116270pgj.111.1549933724629;
        Mon, 11 Feb 2019 17:08:44 -0800 (PST)
X-Received: by 2002:a63:da45:: with SMTP id l5mr1116211pgj.111.1549933723770;
        Mon, 11 Feb 2019 17:08:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549933723; cv=none;
        d=google.com; s=arc-20160816;
        b=zEtjduzBXs23oginnSKOTwpN4pddKAEh5wvwMMILLr1LPDiz+5pFQSvgU+kWO930WZ
         H9ErZjaKmtr1ZUdImjD/BpZY4PhpQjUxc2Zy3Pf8qyey5F6+uJVSO8wFZAi8GGcisqNJ
         32MvsYstzFCYqs0WRrYwx2Q2ILl7z5eoo3ijEUxGELg/elmw3dbYm9rLiY2jXyy11VDA
         jwLp7RZO/qmGfTIij/+C4JXBUZdGxw/PEida2HFQDdMPP+nbiMffGPkTEl5oDyKCzDyI
         0bHBJGKTvErHx2exIadVimcRtgKhB6SSSUbmocfcB6cGST9IulLV5Prt3pzBftSwzRNg
         srow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:references
         :in-reply-to:subject:cc:to:from:dkim-signature;
        bh=WfZyIsccqWR3lZErvejq0nP1VhlSzDJCMVE8xMZxBo4=;
        b=FDGltyLIIAzHQS2D0fioxdhFseWO8ycU2kl4QUU89ktEaJJSIGry6+7J1fSLH6x+49
         SNbJms8JWbP2ziVWwEpPhrZEI6HekqILBDBtiyM72359kU6PowOANATfA4PLXxegeZHM
         tOo2HrzZEcHKmEE8QxlVU5F7M9XEY9HiAwbpow09Hd1n1qaw2U4R+uXhr3FgPEJkNzlB
         HIg8KZ0mNPk/FT4u9R+okXLLgZjQsbPUDIHrSBKaSGtUBfRNrrOr70jpaDVmoaPnLqSp
         CaiJFK5MPlfK/+zMfNc48M4DJvH2+CQYosBkDmw5K3m00tk+POpL3jpyPVrTJwx3s7BO
         7FXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=jtkrfv5h;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor266579pfe.73.2019.02.11.17.08.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 17:08:43 -0800 (PST)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=jtkrfv5h;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version:content-transfer-encoding;
        bh=WfZyIsccqWR3lZErvejq0nP1VhlSzDJCMVE8xMZxBo4=;
        b=jtkrfv5h0Z5ESOjhOeJ+kwO2Ti2RhZaG9kOTT32sBA33x6st698ZR104Kzny8NB9Gg
         8BBn24As3ax0MfwHfqh03vMdOsNkun4gA5eQAn+8U0jrslgVwBGMd/XTec5AbF37LhYW
         YoRYcglS/a37IsHlilhe4vSt8Gq0twliHzroY=
X-Google-Smtp-Source: AHgI3IYwyw2dUTqU1GUA+O3qTH7XPl2tZBiWgJCD013uPJgIBjqRK0tLqD7dhhCkrMJ3SKiUfeDYFw==
X-Received: by 2002:a62:ca03:: with SMTP id n3mr1216531pfg.241.1549933723290;
        Mon, 11 Feb 2019 17:08:43 -0800 (PST)
Received: from localhost (124-171-97-196.dyn.iinet.net.au. [124.171.97.196])
        by smtp.gmail.com with ESMTPSA id o126sm7732968pfb.126.2019.02.11.17.08.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 17:08:42 -0800 (PST)
From: Daniel Axtens <dja@axtens.net>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrey Konovalov <andreyknvl@google.com>, christophe leroy <christophe.leroy@c-s.fr>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, PowerPC <linuxppc-dev@lists.ozlabs.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>
Subject: Re: [PATCH v4 3/3] powerpc/32: Add KASAN support
In-Reply-To: <805fbf9d-a10f-03e0-aa52-6f6bd16059b9@virtuozzo.com>
References: <cover.1548166824.git.christophe.leroy@c-s.fr> <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr> <87ef8i45km.fsf@dja-thinkpad.axtens.net> <69720148-fd19-0810-5a1d-96c45e2ec00c@c-s.fr> <CAAeHK+wcUwLiSQffUkcyiH2fuox=VihJadEqQqRG1YfU3Y2gDA@mail.gmail.com> <f8b9e9ec-991b-6824-46c2-f7fc0aaa7fb8@c-s.fr> <CAAeHK+zop5ajOJQ4KEYbuxMRegk2GM1LvuGcSbCU1O5EZxB0MA@mail.gmail.com> <805fbf9d-a10f-03e0-aa52-6f6bd16059b9@virtuozzo.com>
Date: Tue, 12 Feb 2019 12:08:36 +1100
Message-ID: <87imxpak4r.fsf@linkitivity.dja.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrey Ryabinin <aryabinin@virtuozzo.com> writes:

> On 2/11/19 3:25 PM, Andrey Konovalov wrote:
>> On Sat, Feb 9, 2019 at 12:55 PM christophe leroy
>> <christophe.leroy@c-s.fr> wrote:
>>>
>>> Hi Andrey,
>>>
>>> Le 08/02/2019 =C3=A0 18:40, Andrey Konovalov a =C3=A9crit :
>>>> On Fri, Feb 8, 2019 at 6:17 PM Christophe Leroy <christophe.leroy@c-s.=
fr> wrote:
>>>>>
>>>>> Hi Daniel,
>>>>>
>>>>> Le 08/02/2019 =C3=A0 17:18, Daniel Axtens a =C3=A9crit :
>>>>>> Hi Christophe,
>>>>>>
>>>>>> I've been attempting to port this to 64-bit Book3e nohash (e6500),
>>>>>> although I think I've ended up with an approach more similar to Anee=
sh's
>>>>>> much earlier (2015) series for book3s.
>>>>>>
>>>>>> Part of this is just due to the changes between 32 and 64 bits - we =
need
>>>>>> to hack around the discontiguous mappings - but one thing that I'm
>>>>>> particularly puzzled by is what the kasan_early_init is supposed to =
do.
>>>>>
>>>>> It should be a problem as my patch uses a 'for_each_memblock(memory,
>>>>> reg)' loop.
>>>>>
>>>>>>
>>>>>>> +void __init kasan_early_init(void)
>>>>>>> +{
>>>>>>> +    unsigned long addr =3D KASAN_SHADOW_START;
>>>>>>> +    unsigned long end =3D KASAN_SHADOW_END;
>>>>>>> +    unsigned long next;
>>>>>>> +    pmd_t *pmd =3D pmd_offset(pud_offset(pgd_offset_k(addr), addr)=
, addr);
>>>>>>> +    int i;
>>>>>>> +    phys_addr_t pa =3D __pa(kasan_early_shadow_page);
>>>>>>> +
>>>>>>> +    BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
>>>>>>> +
>>>>>>> +    if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
>>>>>>> +            panic("KASAN not supported with Hash MMU\n");
>>>>>>> +
>>>>>>> +    for (i =3D 0; i < PTRS_PER_PTE; i++)
>>>>>>> +            __set_pte_at(&init_mm, (unsigned long)kasan_early_shad=
ow_page,
>>>>>>> +                         kasan_early_shadow_pte + i,
>>>>>>> +                         pfn_pte(PHYS_PFN(pa), PAGE_KERNEL_RO), 0);
>>>>>>> +
>>>>>>> +    do {
>>>>>>> +            next =3D pgd_addr_end(addr, end);
>>>>>>> +            pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_=
pte);
>>>>>>> +    } while (pmd++, addr =3D next, addr !=3D end);
>>>>>>> +}
>>>>>>
>>>>>> As far as I can tell it's mapping the early shadow page, read-only, =
over
>>>>>> the KASAN_SHADOW_START->KASAN_SHADOW_END range, and it's using the e=
arly
>>>>>> shadow PTE array from the generic code.
>>>>>>
>>>>>> I haven't been able to find an answer to why this is in the docs, so=
 I
>>>>>> was wondering if you or anyone else could explain the early part of
>>>>>> kasan init a bit better.
>>>>>
>>>>> See https://www.kernel.org/doc/html/latest/dev-tools/kasan.html for an
>>>>> explanation of the shadow.
>>>>>
>>>>> When shadow is 0, it means the memory area is entirely accessible.
>>>>>
>>>>> It is necessary to setup a shadow area as soon as possible because all
>>>>> data accesses check the shadow area, from the begining (except for a =
few
>>>>> files where sanitizing has been disabled in Makefiles).
>>>>>
>>>>> Until the real shadow area is set, all access are granted thanks to t=
he
>>>>> zero shadow area beeing for of zeros.
>>>>
>>>> Not entirely correct. kasan_early_init() indeed maps the whole shadow
>>>> memory range to the same kasan_early_shadow_page. However as kernel
>>>> loads and memory gets allocated this shadow page gets rewritten with
>>>> non-zero values by different KASAN allocator hooks. Since these values
>>>> come from completely different parts of the kernel, but all land on
>>>> the same page, kasan_early_shadow_page's content can be considered
>>>> garbage. When KASAN checks memory accesses for validity it detects
>>>> these garbage shadow values, but doesn't print any reports, as the
>>>> reporting routine bails out on the current->kasan_depth check (which
>>>> has the value of 1 initially). Only after kasan_init() completes, when
>>>> the proper shadow memory is mapped, current->kasan_depth gets set to 0
>>>> and we start reporting bad accesses.
>>>
>>> That's surprising, because in the early phase I map the shadow area
>>> read-only, so I do not expect it to get modified unless RO protection is
>>> failing for some reason.
>>=20
>> Actually it might be that the allocator hooks don't modify shadow at
>> this point, as the allocator is not yet initialized. However stack
>> should be getting poisoned and unpoisoned from the very start. But the
>> generic statement that early shadow gets dirtied should be correct.
>> Might it be that you don't use stack instrumentation?
>>=20
>
> Yes, stack instrumentation is not used here, because shadow offset which =
we pass to
> the -fasan-shadow-offset=3D cflag is not specified here. So the logic in =
scrpits/Makefile.kasan
> just fallbacks to CFLAGS_KASAN_MINIMAL, which is outline and without stac=
k instrumentation.
>
> Christophe, you can specify KASAN_SHADOW_OFFSET either in Kconfig (e.g. x=
86_64) or
> in Makefile (e.g. arm64). And make early mapping writable, because compil=
er generated code will write
> to shadow memory in function prologue/epilogue.

Hmm. Is this limitation just that compilers have not implemented
out-of-line support for stack instrumentation, or is there a deeper
reason that stack/global instrumentation relies upon inline
instrumentation?

I ask because it's very common on ppc64 to have the virtual address
space split up into discontiguous blocks. I know this means we lose
inline instrumentation, but I didn't realise we'd also lose stack and
global instrumentation...

I wonder if it would be worth, in the distant future, trying to
implement a smarter scheme in compilers where we could insert more
complex inline mapping schemes.

Regards,
Daniel

