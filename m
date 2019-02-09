Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8E0FC4151A
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 11:55:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22C28218D2
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 11:55:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="v31TyR6A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22C28218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5CB48E00C7; Sat,  9 Feb 2019 06:55:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0C248E00C5; Sat,  9 Feb 2019 06:55:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FA358E00C7; Sat,  9 Feb 2019 06:55:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 324D98E00C5
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 06:55:24 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id v7so2461498wme.9
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 03:55:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uIpF2o0PUkmD2Z7xloiPgNRct+4OvUEy29HRtYfPDMA=;
        b=tHPTqOCSNaxRx2EFWxVFwQlHNuB289wVsw3S+kJPejbmq4jiSL8dyALXmavW3EMZcA
         eiuXK7uaf7SC3PyxUSA5TKMNREfHz+XECq7wpzHXtcsPehEtRi7QsBd4bOioYrZzyBWW
         2AsCVHBfq/I6Z6o6GRol12ZEPVbS/X2duFe94CeeQrvtlZBHR9uXyMPQYQK89n39NMeJ
         uj/r+CK/dcELm4J+7kiNVwjl/9+xFIuIekmFqKCZFr5w7Ae/GgQ4CQP39vdMOBgiQQRA
         l+dVf4c4dAIU+Y/mg9KpCJDkiT+p8Jzcsj6FXa6dyOyXIS3EOz1IfR7Y/2++gJNVLqMe
         UX1A==
X-Gm-Message-State: AHQUAuaHdok5ms3AkmliNAh1WA1m0I9ATljfP//tvoyUCmOolZ6np2kF
	ybG1b2Pycw05CKRa+byEAk2ZzxrASwJHJ9y1hVlEGxRd156SD1yOdb9e1kOLefZQ2CzUFMpjdfJ
	LhqF1BT+qbXk3wyTAoWuIjlxRllkS+DIyaokzi82gJ+Y3FCHaoPN+E7Ecg9xeyNuv1A==
X-Received: by 2002:a7b:c0c5:: with SMTP id s5mr2785713wmh.40.1549713323578;
        Sat, 09 Feb 2019 03:55:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbL36eb+eXMA1Zwrx99OKHkWRNQu9j0gCO4A9Io360Pm1RuWfbpFtZd6V/693BspMdlLuCX
X-Received: by 2002:a7b:c0c5:: with SMTP id s5mr2785644wmh.40.1549713322142;
        Sat, 09 Feb 2019 03:55:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549713322; cv=none;
        d=google.com; s=arc-20160816;
        b=F0BxW7ou6eAQ6xVOqzQYOHskpYES27oxnNIvhqLg9dJup3u33/B9uHvKgFh+jrRr6N
         vqwFW0JMyGjPd9nsfJd/QQ4zkfyoPwqoNocJJZwr2d1CBVQi7k8YgvE41f7UNcbLT+aX
         QcOssr1IsFQqlwpuyyZ0+Mrn32k/dJ06yzju0i9+NYp3r7Q9+Lm0axmQNu0LcKeHIlqv
         daijhhT7X1XBmKm3J4Qku40zkFAplOv2NMWidtUGExT3LtBp4HPiQy7h1zAExs8G8nUT
         JVxTb1Rg2/lakGb+ON4hvKVfT7iDOhUxX5qSh3FRMw6ZIlqUUsZV1mb2rjo/aThloZqE
         dcAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=uIpF2o0PUkmD2Z7xloiPgNRct+4OvUEy29HRtYfPDMA=;
        b=VG6rsFknuq5cIPPGJEVgU1Uh759zxVDvlQFZ8elfJtyinT/5cOYc9auNaTC5AE+8XY
         ksYV1FlA6u30o+gDbPYXjnXyW+QEkqLZqyaoYWeheCBggFOzubl6Dz/MiyHHADdx5afP
         Ilh4s+pCWMht2Q9LXedBmPzZO1bRrN4YdGakZVNqBYvMSNzlV/DwM/rs14rOO1vHbfB3
         4XguPJLB5fzS8hsB7fwhDQq0MPdm/xk4gjYVbbRajrqzwppNw9QVbx+3yJxyFwCxpxWB
         y9ZVTqBnjZMdw6jfhF7FRL/yetQ4V0MHkpN0ZFbyNm/xhxCB/EFFKaZE9Jh1VrdQPC8w
         LUIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=v31TyR6A;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id l19si3622364wmc.41.2019.02.09.03.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Feb 2019 03:55:22 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=v31TyR6A;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43xVqB33Nxz9vBHB;
	Sat,  9 Feb 2019 12:55:18 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=v31TyR6A; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id P1a1gQype3dv; Sat,  9 Feb 2019 12:55:18 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43xVqB1gfMz9v9DQ;
	Sat,  9 Feb 2019 12:55:18 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1549713318; bh=uIpF2o0PUkmD2Z7xloiPgNRct+4OvUEy29HRtYfPDMA=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=v31TyR6Adk0khmmZZuScPOal81Qx6UQkmw83Q05n74cPr9hLT57F/plDBf8XSATLy
	 bulArDO16Lz62CO0g37Ljj7enfpEOL8tk4jN0irYclNX/o7jqpblfbf5mQSjbNDf+E
	 wkD/i6jrH1t5RZ8MBA9SEtcZJvTiTar5PRNGG3f0=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 4186E8B755;
	Sat,  9 Feb 2019 12:55:21 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id LwhHPHj5wZZo; Sat,  9 Feb 2019 12:55:21 +0100 (CET)
Received: from [192.168.232.53] (unknown [192.168.232.53])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BFDAB8B775;
	Sat,  9 Feb 2019 12:55:18 +0100 (CET)
Subject: Re: [PATCH v4 3/3] powerpc/32: Add KASAN support
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Daniel Axtens <dja@axtens.net>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 PowerPC <linuxppc-dev@lists.ozlabs.org>, LKML
 <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>
References: <cover.1548166824.git.christophe.leroy@c-s.fr>
 <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
 <87ef8i45km.fsf@dja-thinkpad.axtens.net>
 <69720148-fd19-0810-5a1d-96c45e2ec00c@c-s.fr>
 <CAAeHK+wcUwLiSQffUkcyiH2fuox=VihJadEqQqRG1YfU3Y2gDA@mail.gmail.com>
From: christophe leroy <christophe.leroy@c-s.fr>
Message-ID: <f8b9e9ec-991b-6824-46c2-f7fc0aaa7fb8@c-s.fr>
Date: Sat, 9 Feb 2019 12:55:12 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAAeHK+wcUwLiSQffUkcyiH2fuox=VihJadEqQqRG1YfU3Y2gDA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Antivirus: Avast (VPS 190208-4, 08/02/2019), Outbound message
X-Antivirus-Status: Clean
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrey,

Le 08/02/2019 à 18:40, Andrey Konovalov a écrit :
> On Fri, Feb 8, 2019 at 6:17 PM Christophe Leroy <christophe.leroy@c-s.fr> wrote:
>>
>> Hi Daniel,
>>
>> Le 08/02/2019 à 17:18, Daniel Axtens a écrit :
>>> Hi Christophe,
>>>
>>> I've been attempting to port this to 64-bit Book3e nohash (e6500),
>>> although I think I've ended up with an approach more similar to Aneesh's
>>> much earlier (2015) series for book3s.
>>>
>>> Part of this is just due to the changes between 32 and 64 bits - we need
>>> to hack around the discontiguous mappings - but one thing that I'm
>>> particularly puzzled by is what the kasan_early_init is supposed to do.
>>
>> It should be a problem as my patch uses a 'for_each_memblock(memory,
>> reg)' loop.
>>
>>>
>>>> +void __init kasan_early_init(void)
>>>> +{
>>>> +    unsigned long addr = KASAN_SHADOW_START;
>>>> +    unsigned long end = KASAN_SHADOW_END;
>>>> +    unsigned long next;
>>>> +    pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
>>>> +    int i;
>>>> +    phys_addr_t pa = __pa(kasan_early_shadow_page);
>>>> +
>>>> +    BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
>>>> +
>>>> +    if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
>>>> +            panic("KASAN not supported with Hash MMU\n");
>>>> +
>>>> +    for (i = 0; i < PTRS_PER_PTE; i++)
>>>> +            __set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
>>>> +                         kasan_early_shadow_pte + i,
>>>> +                         pfn_pte(PHYS_PFN(pa), PAGE_KERNEL_RO), 0);
>>>> +
>>>> +    do {
>>>> +            next = pgd_addr_end(addr, end);
>>>> +            pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
>>>> +    } while (pmd++, addr = next, addr != end);
>>>> +}
>>>
>>> As far as I can tell it's mapping the early shadow page, read-only, over
>>> the KASAN_SHADOW_START->KASAN_SHADOW_END range, and it's using the early
>>> shadow PTE array from the generic code.
>>>
>>> I haven't been able to find an answer to why this is in the docs, so I
>>> was wondering if you or anyone else could explain the early part of
>>> kasan init a bit better.
>>
>> See https://www.kernel.org/doc/html/latest/dev-tools/kasan.html for an
>> explanation of the shadow.
>>
>> When shadow is 0, it means the memory area is entirely accessible.
>>
>> It is necessary to setup a shadow area as soon as possible because all
>> data accesses check the shadow area, from the begining (except for a few
>> files where sanitizing has been disabled in Makefiles).
>>
>> Until the real shadow area is set, all access are granted thanks to the
>> zero shadow area beeing for of zeros.
> 
> Not entirely correct. kasan_early_init() indeed maps the whole shadow
> memory range to the same kasan_early_shadow_page. However as kernel
> loads and memory gets allocated this shadow page gets rewritten with
> non-zero values by different KASAN allocator hooks. Since these values
> come from completely different parts of the kernel, but all land on
> the same page, kasan_early_shadow_page's content can be considered
> garbage. When KASAN checks memory accesses for validity it detects
> these garbage shadow values, but doesn't print any reports, as the
> reporting routine bails out on the current->kasan_depth check (which
> has the value of 1 initially). Only after kasan_init() completes, when
> the proper shadow memory is mapped, current->kasan_depth gets set to 0
> and we start reporting bad accesses.

That's surprising, because in the early phase I map the shadow area 
read-only, so I do not expect it to get modified unless RO protection is 
failing for some reason.

Next week I'll add a test in early_init() to check the content of the 
early shadow area.

Christophe

> 
>>
>> I mainly used ARM arch as an exemple when I implemented KASAN for ppc32.
>>
>>>
>>> At the moment, I don't do any early init, and like Aneesh's series for
>>> book3s, I end up needing a special flag to disable kasan until after
>>> kasan_init. Also, as with Balbir's seris for Radix, some tests didn't
>>> fire, although my missing tests are a superset of his. I suspect the
>>> early init has something to do with these...?
>>
>> I think you should really focus on establishing a zero shadow area as
>> early as possible instead of trying to ack the core parts of KASAN.
>>
>>>
>>> (I'm happy to collate answers into a patch to the docs, btw!)
>>
>> We can also have the discussion going via
>> https://github.com/linuxppc/issues/issues/106
>>
>>>
>>> In the long term I hope to revive Aneesh's and Balbir's series for hash
>>> and radix as well.
>>
>> Great.
>>
>> Christophe
>>
>>>
>>> Regards,
>>> Daniel
>>>
>>>> +
>>>> +static void __init kasan_init_region(struct memblock_region *reg)
>>>> +{
>>>> +    void *start = __va(reg->base);
>>>> +    void *end = __va(reg->base + reg->size);
>>>> +    unsigned long k_start, k_end, k_cur, k_next;
>>>> +    pmd_t *pmd;
>>>> +
>>>> +    if (start >= end)
>>>> +            return;
>>>> +
>>>> +    k_start = (unsigned long)kasan_mem_to_shadow(start);
>>>> +    k_end = (unsigned long)kasan_mem_to_shadow(end);
>>>> +    pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
>>>> +
>>>> +    for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
>>>> +            k_next = pgd_addr_end(k_cur, k_end);
>>>> +            if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte) {
>>>> +                    pte_t *new = pte_alloc_one_kernel(&init_mm);
>>>> +
>>>> +                    if (!new)
>>>> +                            panic("kasan: pte_alloc_one_kernel() failed");
>>>> +                    memcpy(new, kasan_early_shadow_pte, PTE_TABLE_SIZE);
>>>> +                    pmd_populate_kernel(&init_mm, pmd, new);
>>>> +            }
>>>> +    };
>>>> +
>>>> +    for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
>>>> +            void *va = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
>>>> +            pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
>>>> +
>>>> +            if (!va)
>>>> +                    panic("kasan: memblock_alloc() failed");
>>>> +            pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
>>>> +            pte_update(pte_offset_kernel(pmd, k_cur), ~0, pte_val(pte));
>>>> +    }
>>>> +    flush_tlb_kernel_range(k_start, k_end);
>>>> +}
>>>> +
>>>> +void __init kasan_init(void)
>>>> +{
>>>> +    struct memblock_region *reg;
>>>> +
>>>> +    for_each_memblock(memory, reg)
>>>> +            kasan_init_region(reg);
>>>> +
>>>> +    kasan_init_tags();
>>>> +
>>>> +    /* At this point kasan is fully initialized. Enable error messages */
>>>> +    init_task.kasan_depth = 0;
>>>> +    pr_info("KASAN init done\n");
>>>> +}
>>>> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
>>>> index 33cc6f676fa6..ae7db88b72d6 100644
>>>> --- a/arch/powerpc/mm/mem.c
>>>> +++ b/arch/powerpc/mm/mem.c
>>>> @@ -369,6 +369,10 @@ void __init mem_init(void)
>>>>       pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
>>>>               PKMAP_BASE, PKMAP_ADDR(LAST_PKMAP));
>>>>    #endif /* CONFIG_HIGHMEM */
>>>> +#ifdef CONFIG_KASAN
>>>> +    pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
>>>> +            KASAN_SHADOW_START, KASAN_SHADOW_END);
>>>> +#endif
>>>>    #ifdef CONFIG_NOT_COHERENT_CACHE
>>>>       pr_info("  * 0x%08lx..0x%08lx  : consistent mem\n",
>>>>               IOREMAP_TOP, IOREMAP_TOP + CONFIG_CONSISTENT_SIZE);
>>>> --
>>>> 2.13.3
>>
>> --
>> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
>> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
>> To post to this group, send email to kasan-dev@googlegroups.com.
>> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/69720148-fd19-0810-5a1d-96c45e2ec00c%40c-s.fr.
>> For more options, visit https://groups.google.com/d/optout.

---
L'absence de virus dans ce courrier électronique a été vérifiée par le logiciel antivirus Avast.
https://www.avast.com/antivirus

