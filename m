Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7E62C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 17:17:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 798FC20823
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 17:17:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="pyrkidHU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 798FC20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1957B8E0099; Fri,  8 Feb 2019 12:17:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11E278E0002; Fri,  8 Feb 2019 12:17:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F01258E0099; Fri,  8 Feb 2019 12:17:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 911F68E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 12:17:17 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y129so3313594wmd.1
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 09:17:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QhIXpDbKcHkuUsm1eW6ykE+MFEqnZ6lkzlTZ18smoCU=;
        b=ezPOoh0Jd12mAsYyZ3ztpnM6CjVLc1MH7EbJ85VUmwUbhGOlOPke1UYT8q226iVwhs
         EmB0pcFcecGQAwP5S2d1fiWxYaP6NQo9BN5af7SeqeFehCjZaV4o5yLsluteiaP5IWDl
         LWhMMUVRjrBGnqQ/QpqpYv3UzEtBhG4moVO7poOVZnhK1tqaZPqP9v8RRInH0l+et0/E
         Dso/Xp7kKnfYma3fXjg0FEfgOUiMX8Vk6G1738cBOELn0y/XWG0ufv8D3o+gdCogB8x0
         NTpaLQkq/4OsSDhi0HCQlryatN+urZgwfT/KKOskP2UX8ZY4EWdtsR0vXyahzqSlWA9L
         xZxQ==
X-Gm-Message-State: AHQUAubjDsrFhiv3wfrHwBFrOUkjesTBHmW7AxyAXiOqHdTsE/CXQQ+/
	rfHcAyMISRKYFT9HOl99IJ9Vs2h6k5Pb5MMcEZCzxRrQcePTCfKF8M69m/VhMxdj/5VEL6GjZ/z
	atuPIBbhlUlmzfOzxFBnequDvCp0WeWeFfy0OthZ35nLeh/qNUBZzebS+s5IcYvGdzA==
X-Received: by 2002:a1c:a185:: with SMTP id k127mr12206932wme.134.1549646237001;
        Fri, 08 Feb 2019 09:17:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZmdNcqBXETYaKy3rWGeSreoKOg3f1Q9XWDvBpk8IzAH7JWJ7iYAQOsdzBS3r3I4e8lt0rz
X-Received: by 2002:a1c:a185:: with SMTP id k127mr12206869wme.134.1549646235875;
        Fri, 08 Feb 2019 09:17:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549646235; cv=none;
        d=google.com; s=arc-20160816;
        b=fiAbXxvRUoXbswJP9awxZCNsPTCVNuhl9jwG+PE7D52wKQ9581NpOzGkxc+bNL5UiY
         qEx+pocMWUkGJ1ZyogHjw8hg9dGdaWR/hWuqqJBP8ZbPYA2QgJNPSEaa+3jlIa7fU2dL
         al8ZEdt2ZPAnmTTXwkdnZhp5I+kkHBRTYWp3cjqUGW/LeBqMUYSXBuIvFTa8JvU/l+P2
         SveumOHMisRZBDYWhgccx+tUOsejhcehVVIR6WvqkYZewBFjjTbch01cbpR1PMduUhAT
         fMLX/TSBwBWpzxUlOVixY7gj3R+M+QsSbowZ1dbovUTfRKhMKe/wW56yW5Md21RgJh6n
         AkBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=QhIXpDbKcHkuUsm1eW6ykE+MFEqnZ6lkzlTZ18smoCU=;
        b=we0eR+aANV5PtDr6L3H8gn2AdtmLWUJv48n80+1wGrqC9dybO+XdfVJk0LYX4vuLCX
         z3xijfjq/10K4gwkYIoBx02zPkaIJAJY3YmG0ZnoueOYMHTzeMy1vJdWr4qdQIY2+e/n
         lwcFlWaX/SwNKpA3oGK0rTwNz8xB+SnBvjACqBaui8Uc1nwCb7re43Y7YieZ5yKjxRja
         eff1nm2agIuWZRKj/WUQdGKqqceIFI1hBcqPKy5FcxocyEtAGGIG1DxJzX/6v0f1W6og
         5l1sUVekABUBUxVANVUyS4hOiVf1vjX+desd0Lpa0HuHvup+WMwdslUO0pHGqQE+siS5
         rxTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=pyrkidHU;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id s4si1979372wrn.89.2019.02.08.09.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 09:17:15 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=pyrkidHU;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 43x2153DBtz9v3vn;
	Fri,  8 Feb 2019 18:17:13 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=pyrkidHU; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id JDKlIB8Er7e5; Fri,  8 Feb 2019 18:17:13 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 43x2150XCvz9v3vm;
	Fri,  8 Feb 2019 18:17:13 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1549646233; bh=QhIXpDbKcHkuUsm1eW6ykE+MFEqnZ6lkzlTZ18smoCU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=pyrkidHUVmjS4dvs8XoiW15xN6cPNqTIi/OChdZ1aLMOhSwGapUnunhBir5rR1yQ8
	 3cluXFw2h1RZFi7KOiuHXluSmPbRfoSXhri3XMHJpwYXQPzmQ0VqOj132bYa7G7pm4
	 JgNmsYm+lWJb7fZkJlPQ/SL5rqKBlut98MJWovHo=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B45628B8E1;
	Fri,  8 Feb 2019 18:17:14 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id 1YXNCKcWSOhD; Fri,  8 Feb 2019 18:17:14 +0100 (CET)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.231.2])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 729798B8DF;
	Fri,  8 Feb 2019 18:17:14 +0100 (CET)
Subject: Re: [PATCH v4 3/3] powerpc/32: Add KASAN support
To: Daniel Axtens <dja@axtens.net>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com
References: <cover.1548166824.git.christophe.leroy@c-s.fr>
 <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
 <87ef8i45km.fsf@dja-thinkpad.axtens.net>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <69720148-fd19-0810-5a1d-96c45e2ec00c@c-s.fr>
Date: Fri, 8 Feb 2019 18:17:14 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <87ef8i45km.fsf@dja-thinkpad.axtens.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Daniel,

Le 08/02/2019 à 17:18, Daniel Axtens a écrit :
> Hi Christophe,
> 
> I've been attempting to port this to 64-bit Book3e nohash (e6500),
> although I think I've ended up with an approach more similar to Aneesh's
> much earlier (2015) series for book3s.
> 
> Part of this is just due to the changes between 32 and 64 bits - we need
> to hack around the discontiguous mappings - but one thing that I'm
> particularly puzzled by is what the kasan_early_init is supposed to do.

It should be a problem as my patch uses a 'for_each_memblock(memory, 
reg)' loop.

> 
>> +void __init kasan_early_init(void)
>> +{
>> +	unsigned long addr = KASAN_SHADOW_START;
>> +	unsigned long end = KASAN_SHADOW_END;
>> +	unsigned long next;
>> +	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
>> +	int i;
>> +	phys_addr_t pa = __pa(kasan_early_shadow_page);
>> +
>> +	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
>> +
>> +	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
>> +		panic("KASAN not supported with Hash MMU\n");
>> +
>> +	for (i = 0; i < PTRS_PER_PTE; i++)
>> +		__set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
>> +			     kasan_early_shadow_pte + i,
>> +			     pfn_pte(PHYS_PFN(pa), PAGE_KERNEL_RO), 0);
>> +
>> +	do {
>> +		next = pgd_addr_end(addr, end);
>> +		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
>> +	} while (pmd++, addr = next, addr != end);
>> +}
> 
> As far as I can tell it's mapping the early shadow page, read-only, over
> the KASAN_SHADOW_START->KASAN_SHADOW_END range, and it's using the early
> shadow PTE array from the generic code.
> 
> I haven't been able to find an answer to why this is in the docs, so I
> was wondering if you or anyone else could explain the early part of
> kasan init a bit better.

See https://www.kernel.org/doc/html/latest/dev-tools/kasan.html for an 
explanation of the shadow.

When shadow is 0, it means the memory area is entirely accessible.

It is necessary to setup a shadow area as soon as possible because all 
data accesses check the shadow area, from the begining (except for a few 
files where sanitizing has been disabled in Makefiles).

Until the real shadow area is set, all access are granted thanks to the 
zero shadow area beeing for of zeros.

I mainly used ARM arch as an exemple when I implemented KASAN for ppc32.

> 
> At the moment, I don't do any early init, and like Aneesh's series for
> book3s, I end up needing a special flag to disable kasan until after
> kasan_init. Also, as with Balbir's seris for Radix, some tests didn't
> fire, although my missing tests are a superset of his. I suspect the
> early init has something to do with these...?

I think you should really focus on establishing a zero shadow area as 
early as possible instead of trying to ack the core parts of KASAN.

> 
> (I'm happy to collate answers into a patch to the docs, btw!)

We can also have the discussion going via 
https://github.com/linuxppc/issues/issues/106

> 
> In the long term I hope to revive Aneesh's and Balbir's series for hash
> and radix as well.

Great.

Christophe

> 
> Regards,
> Daniel
> 
>> +
>> +static void __init kasan_init_region(struct memblock_region *reg)
>> +{
>> +	void *start = __va(reg->base);
>> +	void *end = __va(reg->base + reg->size);
>> +	unsigned long k_start, k_end, k_cur, k_next;
>> +	pmd_t *pmd;
>> +
>> +	if (start >= end)
>> +		return;
>> +
>> +	k_start = (unsigned long)kasan_mem_to_shadow(start);
>> +	k_end = (unsigned long)kasan_mem_to_shadow(end);
>> +	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
>> +
>> +	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
>> +		k_next = pgd_addr_end(k_cur, k_end);
>> +		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte) {
>> +			pte_t *new = pte_alloc_one_kernel(&init_mm);
>> +
>> +			if (!new)
>> +				panic("kasan: pte_alloc_one_kernel() failed");
>> +			memcpy(new, kasan_early_shadow_pte, PTE_TABLE_SIZE);
>> +			pmd_populate_kernel(&init_mm, pmd, new);
>> +		}
>> +	};
>> +
>> +	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
>> +		void *va = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
>> +		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
>> +
>> +		if (!va)
>> +			panic("kasan: memblock_alloc() failed");
>> +		pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
>> +		pte_update(pte_offset_kernel(pmd, k_cur), ~0, pte_val(pte));
>> +	}
>> +	flush_tlb_kernel_range(k_start, k_end);
>> +}
>> +
>> +void __init kasan_init(void)
>> +{
>> +	struct memblock_region *reg;
>> +
>> +	for_each_memblock(memory, reg)
>> +		kasan_init_region(reg);
>> +
>> +	kasan_init_tags();
>> +
>> +	/* At this point kasan is fully initialized. Enable error messages */
>> +	init_task.kasan_depth = 0;
>> +	pr_info("KASAN init done\n");
>> +}
>> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
>> index 33cc6f676fa6..ae7db88b72d6 100644
>> --- a/arch/powerpc/mm/mem.c
>> +++ b/arch/powerpc/mm/mem.c
>> @@ -369,6 +369,10 @@ void __init mem_init(void)
>>   	pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
>>   		PKMAP_BASE, PKMAP_ADDR(LAST_PKMAP));
>>   #endif /* CONFIG_HIGHMEM */
>> +#ifdef CONFIG_KASAN
>> +	pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
>> +		KASAN_SHADOW_START, KASAN_SHADOW_END);
>> +#endif
>>   #ifdef CONFIG_NOT_COHERENT_CACHE
>>   	pr_info("  * 0x%08lx..0x%08lx  : consistent mem\n",
>>   		IOREMAP_TOP, IOREMAP_TOP + CONFIG_CONSISTENT_SIZE);
>> -- 
>> 2.13.3

