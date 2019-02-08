Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CE57C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 16:18:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C1F420844
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 16:18:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="ATqiyCLs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C1F420844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 038FA8E0094; Fri,  8 Feb 2019 11:18:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2B058E0002; Fri,  8 Feb 2019 11:18:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3FFB8E0094; Fri,  8 Feb 2019 11:18:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC1E8E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 11:18:24 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id b24so2935792pls.11
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 08:18:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version;
        bh=rwttkLcB0E6Lz2B+tgr9+cijqY8fQQn5nOYWb3x5YWA=;
        b=e+zzUTAptf69reHPgmVVbkA8NqyKZT6AO1VsWh+Wqo4OUF0XfFloZpi4LGxPj7Quqd
         ftyeZ0WsP/noXQ0veLHEeBVfkWB1UbTDL5p/w/kG/yRIQ6cTAMaFqcU4jz7Th9FdT9Se
         +0gl5OEpq2lCSfK7EWyVCIjR8BSD9bgO2Kbx1ZT6OoCTmF2pPC33mEHTDYVSall8V/ka
         VK9gVxxTZCuPDXYe8hkOJfDrBk8LgotEA0uSHgcsZDB5n1UO0nRaoT3NWbB9RgDfrR7r
         lfA4p0fgPkoryFXDKBWpwkec6iQMnbsJN13XorESlpVPMJ5nLadIafmr+jVpg17BYwgW
         FCWA==
X-Gm-Message-State: AHQUAuYSqK6YnAgGkM/yB3kuJCLy+YL+5BaRjrCkmileyov58gtlz7Va
	LxHscNpMSgFkTTDKYCJKBNUWCDSYijKjnUdRKAPyWPxwboAgc9NouH96CDoesI2SJN3RDEjgj5I
	jzJs1OqU+RCOVxmMyBh8MSHp1rtfeoWHxI4w/PV1gEqpFbcF3tXnOUnAzHOXES5ThdpaJYP2A+O
	UDVAUMSWw3G1X0bBFFEfr2g8AssQLQ/r4A+BF8xiDeduTR4rT9xSJWZqCPYWJfIanUfG5mRR834
	DkNrnzXqqkaD6+egkhIcM1mG6dmo3PimCpjdFYQy1jXZRmNiCdsx1ULAE07aGvwEF4WcapPsnoe
	fzwB0LPvnDK4kMFM9TyGPs+LeRMJrHAR6l5RmTVD7VuazHDsbQj4OhuYMRbAD14jHs01LmZ6w/9
	1
X-Received: by 2002:a63:d52:: with SMTP id 18mr16745937pgn.377.1549642704199;
        Fri, 08 Feb 2019 08:18:24 -0800 (PST)
X-Received: by 2002:a63:d52:: with SMTP id 18mr16745846pgn.377.1549642703081;
        Fri, 08 Feb 2019 08:18:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549642703; cv=none;
        d=google.com; s=arc-20160816;
        b=G/FnGV8JUIxWfBYlGLg7gQn6JmmTHnX6czCBYsWLsCdzk8snKnLz5nk9Kw4drDZ4gl
         /47I4gDxgaxZI39vEcDiLO7mRNA1Mm2+GhGka6eR25ID7UhBt8TpIz3nG2YEw4fdeO6X
         3Ghf5isMW0Cl5ItpousGOxDwGhJcLAYoOB4ignLL8BhJmNCQInIWIxyFz2iYrv5lVco3
         Tq2P2up3+pOel/eaKMM7K5NA9Wmuiutl57QN4Ow5HxRdUh8Ud2Uiz1ciNmXK/419teDw
         UseWET4fBRI4WHS8EMEmAq+IjIBNCP6wjRQvY9O+BXcctmoQcLBVjPb62tMP5Ylm9GQj
         zdDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:dkim-signature;
        bh=rwttkLcB0E6Lz2B+tgr9+cijqY8fQQn5nOYWb3x5YWA=;
        b=eidv4xhDg0BgzG/onx0JToAKqP29lvL9xPv55u90CuKAdP6FdIe/uRVK3BFwANe1WF
         9mrnBkk3qJKVUYdAIJW6OPo22hBL0agoQJnDILF2i2sO47Swpko5KAEv/V/BfmHZgU+/
         snC2j4F81e0sszEcEBziH5zX9+XeMv1QMRpbBd65E96L4oUM34rtgs5w43yk+qKWOFvB
         102XLZzcwulOg3z4oSQu1kfVPkPPIjSxIkwkXHZIe7Us2xj5eEjLjTau5t1FCs5hH5hL
         +S5TIW9WB4lDzpVrJafuzZhddw2WWx4rfadV+kf0MO3bi340svbF9C2A8cn6BrQ2tQUW
         6DBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=ATqiyCLs;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g79sor3863750pfg.42.2019.02.08.08.18.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Feb 2019 08:18:23 -0800 (PST)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=ATqiyCLs;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=rwttkLcB0E6Lz2B+tgr9+cijqY8fQQn5nOYWb3x5YWA=;
        b=ATqiyCLsID2FI6vHntKHhBzn+aar81HJ9Tv8JjbXVpIV9uG//cqIwTvcM2FbgcnACX
         f0uAkfpAXGLXmv0GAK9EfWCCUKhkuAfZdar46KltKoZijBTEMC1SXKiEQ6vroIqDVuU0
         YrlJ67WhEOIwLUUUeDD4/D/Sgjea59Kh+p4Z0=
X-Google-Smtp-Source: AHgI3IYFm9qTo0YgHqGZSOhIItRjWouKqbzosTgd/PKnqIu7ryPVhhmeCqyP/F/uRP5+deEAfJDA9Q==
X-Received: by 2002:aa7:8d51:: with SMTP id s17mr8824013pfe.16.1549642702499;
        Fri, 08 Feb 2019 08:18:22 -0800 (PST)
Received: from localhost (124-171-150-195.dyn.iinet.net.au. [124.171.150.195])
        by smtp.gmail.com with ESMTPSA id s71sm3704832pfa.122.2019.02.08.08.18.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Feb 2019 08:18:20 -0800 (PST)
From: Daniel Axtens <dja@axtens.net>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com
Subject: Re: [PATCH v4 3/3] powerpc/32: Add KASAN support
In-Reply-To: <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
References: <cover.1548166824.git.christophe.leroy@c-s.fr> <1f5629e03181d0e30efc603f00dad78912991a45.1548166824.git.christophe.leroy@c-s.fr>
Date: Sat, 09 Feb 2019 03:18:17 +1100
Message-ID: <87ef8i45km.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christophe,

I've been attempting to port this to 64-bit Book3e nohash (e6500),
although I think I've ended up with an approach more similar to Aneesh's
much earlier (2015) series for book3s.

Part of this is just due to the changes between 32 and 64 bits - we need
to hack around the discontiguous mappings - but one thing that I'm
particularly puzzled by is what the kasan_early_init is supposed to do.

> +void __init kasan_early_init(void)
> +{
> +	unsigned long addr = KASAN_SHADOW_START;
> +	unsigned long end = KASAN_SHADOW_END;
> +	unsigned long next;
> +	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
> +	int i;
> +	phys_addr_t pa = __pa(kasan_early_shadow_page);
> +
> +	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
> +
> +	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
> +		panic("KASAN not supported with Hash MMU\n");
> +
> +	for (i = 0; i < PTRS_PER_PTE; i++)
> +		__set_pte_at(&init_mm, (unsigned long)kasan_early_shadow_page,
> +			     kasan_early_shadow_pte + i,
> +			     pfn_pte(PHYS_PFN(pa), PAGE_KERNEL_RO), 0);
> +
> +	do {
> +		next = pgd_addr_end(addr, end);
> +		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
> +	} while (pmd++, addr = next, addr != end);
> +}

As far as I can tell it's mapping the early shadow page, read-only, over
the KASAN_SHADOW_START->KASAN_SHADOW_END range, and it's using the early
shadow PTE array from the generic code.

I haven't been able to find an answer to why this is in the docs, so I
was wondering if you or anyone else could explain the early part of
kasan init a bit better.

At the moment, I don't do any early init, and like Aneesh's series for
book3s, I end up needing a special flag to disable kasan until after
kasan_init. Also, as with Balbir's seris for Radix, some tests didn't
fire, although my missing tests are a superset of his. I suspect the
early init has something to do with these...?

(I'm happy to collate answers into a patch to the docs, btw!)

In the long term I hope to revive Aneesh's and Balbir's series for hash
and radix as well.

Regards,
Daniel

> +
> +static void __init kasan_init_region(struct memblock_region *reg)
> +{
> +	void *start = __va(reg->base);
> +	void *end = __va(reg->base + reg->size);
> +	unsigned long k_start, k_end, k_cur, k_next;
> +	pmd_t *pmd;
> +
> +	if (start >= end)
> +		return;
> +
> +	k_start = (unsigned long)kasan_mem_to_shadow(start);
> +	k_end = (unsigned long)kasan_mem_to_shadow(end);
> +	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
> +
> +	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
> +		k_next = pgd_addr_end(k_cur, k_end);
> +		if ((void *)pmd_page_vaddr(*pmd) == kasan_early_shadow_pte) {
> +			pte_t *new = pte_alloc_one_kernel(&init_mm);
> +
> +			if (!new)
> +				panic("kasan: pte_alloc_one_kernel() failed");
> +			memcpy(new, kasan_early_shadow_pte, PTE_TABLE_SIZE);
> +			pmd_populate_kernel(&init_mm, pmd, new);
> +		}
> +	};
> +
> +	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
> +		void *va = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
> +		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
> +
> +		if (!va)
> +			panic("kasan: memblock_alloc() failed");
> +		pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
> +		pte_update(pte_offset_kernel(pmd, k_cur), ~0, pte_val(pte));
> +	}
> +	flush_tlb_kernel_range(k_start, k_end);
> +}
> +
> +void __init kasan_init(void)
> +{
> +	struct memblock_region *reg;
> +
> +	for_each_memblock(memory, reg)
> +		kasan_init_region(reg);
> +
> +	kasan_init_tags();
> +
> +	/* At this point kasan is fully initialized. Enable error messages */
> +	init_task.kasan_depth = 0;
> +	pr_info("KASAN init done\n");
> +}
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index 33cc6f676fa6..ae7db88b72d6 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -369,6 +369,10 @@ void __init mem_init(void)
>  	pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
>  		PKMAP_BASE, PKMAP_ADDR(LAST_PKMAP));
>  #endif /* CONFIG_HIGHMEM */
> +#ifdef CONFIG_KASAN
> +	pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
> +		KASAN_SHADOW_START, KASAN_SHADOW_END);
> +#endif
>  #ifdef CONFIG_NOT_COHERENT_CACHE
>  	pr_info("  * 0x%08lx..0x%08lx  : consistent mem\n",
>  		IOREMAP_TOP, IOREMAP_TOP + CONFIG_CONSISTENT_SIZE);
> -- 
> 2.13.3

