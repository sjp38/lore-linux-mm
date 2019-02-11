Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF5BC282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:28:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32FFC218F0
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:28:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32FFC218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF6F28E00FB; Mon, 11 Feb 2019 11:28:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA75E8E00F6; Mon, 11 Feb 2019 11:28:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A95C28E00FB; Mon, 11 Feb 2019 11:28:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC0B8E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:28:20 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id t22-v6so2960138lji.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:28:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=CXabaxyjDT3D6OWec+4Nlzm7+oYSKaftIBCUycXZI2o=;
        b=tJw78CPAUY2T2LZkSsxksUKZEMDz2dKwuALRIJJPC56hQMh2eoOBDxNS7s0NCsyoSh
         DJbHnAaMY2T8YYxZnw3oEBuhOodpoHEVd2h1/8P49AQ+MPwQUakBbMIGiD43Qwp1hvoL
         rEnQ3rcEBiIK/jxKbvu8yAS6t4VlD/yK0PlVOI9vxq7++3Eghw35XrOySplaetAp8rGW
         RgQAi3F0wQ+Tn71+n1JfIT6GYNzi+OfxqVmIEhbCBhQKkUiuzwHQw9GKqJ4en/JIiBX8
         VGbGTGP2wb1e6rb+e06aTciLQ46r9I5oLjSkLkI09RHtf7Z+S8ZCIilhU5PuSG4RgHhG
         3NlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAubuAAOg6AlJrFVyxHwp0SXpDabP8mXuOSvEjkyeU8+qSgIPOD7U
	lz25cQe0xtriffWfAXCl1LFEJQyrKgZOgC7Rym8lHWM/SS5mhT3BEaBtqjJEIjlsCW6FOrtmSoy
	AJUVQ7cbnbH3oDYocBimacj2ikUuLwGd2GLvXsbia0eUt7rQjjS70t62anT7V4DYVIQ==
X-Received: by 2002:a2e:4503:: with SMTP id s3-v6mr21635945lja.44.1549902499487;
        Mon, 11 Feb 2019 08:28:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVNlOG89VoCS+eFHUydvLDfN/1cmpjQnmQSkvSPLL68bCjKerI52EgZi2RMjBXbAvAaQSx
X-Received: by 2002:a2e:4503:: with SMTP id s3-v6mr21635885lja.44.1549902498091;
        Mon, 11 Feb 2019 08:28:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549902498; cv=none;
        d=google.com; s=arc-20160816;
        b=UmTNSaM4qEzn+bXm1AGMIiPslzCQxM3x4CN7moM2HITXiVomqnLY7MXs2Uw2s+5AZ2
         nxWUEraCKMJBX/roH9CTcjzkMuoerdjsEYQstlbvHVJ1awEeSfJ3Wbt7PRgM3JZsxO06
         HCZ3BTI0PDr3C0zgVK652pj3+/kwvPr+4VZ4Ni/s4lWLy6Cc7ZxNJ8MbiuHh5ZjU4xbU
         ZReYp6zUzSHXniCNTx7bkEvyoEQqAAcyHT7g4oZu6B7pkcvh5lccm0W7AQzwSx0r6s8W
         flptkzAoVmioNbVEbtr2quboM0ByDMF8dTqG/FprFC45qOoeXdPv+zo3mnvv1fFWf6Z+
         IDIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=CXabaxyjDT3D6OWec+4Nlzm7+oYSKaftIBCUycXZI2o=;
        b=JWCULkmC6xXGvM8Y8ui1ntbV4PArWPoQCCcSzWdbe6ZjJQ4UrtOpt+eIFKc+PXVw9X
         Awx+Z03G8y8UJ0QM7rY9KtXgoazYmRT98X0e7fkCBFK6IIM2xMo/iyFEfTXlxPQ33nGd
         ObT6ghBWpP1S76MY+GI+b0Hgr1/KMVKz+Tyv5hCJMVb6MFZNCb4JGs20zJc+37ovfhzc
         GflgXxQ3XSP6bSr88nLoYgsqN6HJz64UXfj+Z3jdxW9NorOTrSqgx7eKnm8z/JftI4hM
         toS28NFBeUrJ1R4J04us5mzc0mgJD8jj7ZD6cTJ1izNa+miMb3cjvrQs+iR2MPy9x0gs
         U5fQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id i13si9479318lfc.125.2019.02.11.08.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:28:18 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gtERF-0001Xi-Kx; Mon, 11 Feb 2019 19:28:09 +0300
Subject: Re: [PATCH v4 3/3] powerpc/32: Add KASAN support
To: Andrey Konovalov <andreyknvl@google.com>,
 christophe leroy <christophe.leroy@c-s.fr>
Cc: Daniel Axtens <dja@axtens.net>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 PowerPC <linuxppc-dev@lists.ozlabs.org>, LKML
 <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>
References: <cover.1548166824.git.christophe.leroy@c-s.fr>
 <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
 <87ef8i45km.fsf@dja-thinkpad.axtens.net>
 <69720148-fd19-0810-5a1d-96c45e2ec00c@c-s.fr>
 <CAAeHK+wcUwLiSQffUkcyiH2fuox=VihJadEqQqRG1YfU3Y2gDA@mail.gmail.com>
 <f8b9e9ec-991b-6824-46c2-f7fc0aaa7fb8@c-s.fr>
 <CAAeHK+zop5ajOJQ4KEYbuxMRegk2GM1LvuGcSbCU1O5EZxB0MA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <805fbf9d-a10f-03e0-aa52-6f6bd16059b9@virtuozzo.com>
Date: Mon, 11 Feb 2019 19:28:31 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CAAeHK+zop5ajOJQ4KEYbuxMRegk2GM1LvuGcSbCU1O5EZxB0MA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/11/19 3:25 PM, Andrey Konovalov wrote:
> On Sat, Feb 9, 2019 at 12:55 PM christophe leroy
> <christophe.leroy@c-s.fr> wrote:
>>
>> Hi Andrey,
>>
>> Le 08/02/2019 à 18:40, Andrey Konovalov a écrit :
>>> On Fri, Feb 8, 2019 at 6:17 PM Christophe Leroy <christophe.leroy@c-s.fr> wrote:
>>>>
>>>> Hi Daniel,
>>>>
>>>> Le 08/02/2019 à 17:18, Daniel Axtens a écrit :
>>>>> Hi Christophe,
>>>>>
>>>>> I've been attempting to port this to 64-bit Book3e nohash (e6500),
>>>>> although I think I've ended up with an approach more similar to Aneesh's
>>>>> much earlier (2015) series for book3s.
>>>>>
>>>>> Part of this is just due to the changes between 32 and 64 bits - we need
>>>>> to hack around the discontiguous mappings - but one thing that I'm
>>>>> particularly puzzled by is what the kasan_early_init is supposed to do.
>>>>
>>>> It should be a problem as my patch uses a 'for_each_memblock(memory,
>>>> reg)' loop.
>>>>
>>>>>
>>>>>> +void __init kasan_early_init(void)
>>>>>> +{
>>>>>> +    unsigned long addr = KASAN_SHADOW_START;
>>>>>> +    unsigned long end = KASAN_SHADOW_END;
>>>>>> +    unsigned long next;
>>>>>> +    pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
>>>>>> +    int i;
>>>>>> +    phys_addr_t pa = __pa(kasan_early_shadow_page);
>>>>>> +
>>>>>> +    BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
>>>>>> +
>>>>>> +    if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
>>>>>> +            panic("KASAN not supported with Hash MMU\n");
>>>>>> +
>>>>>> +    for (i = 0; i < PTRS_PER_PTE; i++)
>>>>>> +            __set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
>>>>>> +                         kasan_early_shadow_pte + i,
>>>>>> +                         pfn_pte(PHYS_PFN(pa), PAGE_KERNEL_RO), 0);
>>>>>> +
>>>>>> +    do {
>>>>>> +            next = pgd_addr_end(addr, end);
>>>>>> +            pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
>>>>>> +    } while (pmd++, addr = next, addr != end);
>>>>>> +}
>>>>>
>>>>> As far as I can tell it's mapping the early shadow page, read-only, over
>>>>> the KASAN_SHADOW_START->KASAN_SHADOW_END range, and it's using the early
>>>>> shadow PTE array from the generic code.
>>>>>
>>>>> I haven't been able to find an answer to why this is in the docs, so I
>>>>> was wondering if you or anyone else could explain the early part of
>>>>> kasan init a bit better.
>>>>
>>>> See https://www.kernel.org/doc/html/latest/dev-tools/kasan.html for an
>>>> explanation of the shadow.
>>>>
>>>> When shadow is 0, it means the memory area is entirely accessible.
>>>>
>>>> It is necessary to setup a shadow area as soon as possible because all
>>>> data accesses check the shadow area, from the begining (except for a few
>>>> files where sanitizing has been disabled in Makefiles).
>>>>
>>>> Until the real shadow area is set, all access are granted thanks to the
>>>> zero shadow area beeing for of zeros.
>>>
>>> Not entirely correct. kasan_early_init() indeed maps the whole shadow
>>> memory range to the same kasan_early_shadow_page. However as kernel
>>> loads and memory gets allocated this shadow page gets rewritten with
>>> non-zero values by different KASAN allocator hooks. Since these values
>>> come from completely different parts of the kernel, but all land on
>>> the same page, kasan_early_shadow_page's content can be considered
>>> garbage. When KASAN checks memory accesses for validity it detects
>>> these garbage shadow values, but doesn't print any reports, as the
>>> reporting routine bails out on the current->kasan_depth check (which
>>> has the value of 1 initially). Only after kasan_init() completes, when
>>> the proper shadow memory is mapped, current->kasan_depth gets set to 0
>>> and we start reporting bad accesses.
>>
>> That's surprising, because in the early phase I map the shadow area
>> read-only, so I do not expect it to get modified unless RO protection is
>> failing for some reason.
> 
> Actually it might be that the allocator hooks don't modify shadow at
> this point, as the allocator is not yet initialized. However stack
> should be getting poisoned and unpoisoned from the very start. But the
> generic statement that early shadow gets dirtied should be correct.
> Might it be that you don't use stack instrumentation?
> 

Yes, stack instrumentation is not used here, because shadow offset which we pass to
the -fasan-shadow-offset= cflag is not specified here. So the logic in scrpits/Makefile.kasan
just fallbacks to CFLAGS_KASAN_MINIMAL, which is outline and without stack instrumentation.

Christophe, you can specify KASAN_SHADOW_OFFSET either in Kconfig (e.g. x86_64) or
in Makefile (e.g. arm64). And make early mapping writable, because compiler generated code will write
to shadow memory in function prologue/epilogue.

