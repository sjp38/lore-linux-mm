Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 146C1C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:44:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB9072070D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 15:44:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB9072070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CEBD8E0009; Mon, 29 Jul 2019 11:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77ECE8E0002; Mon, 29 Jul 2019 11:44:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66EC78E0009; Mon, 29 Jul 2019 11:44:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9BE8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 11:44:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a5so38497689edx.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 08:44:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4w0NvDQJHYunFbzTs84/ma+toZ+YlE3yjMHTTx7zgK0=;
        b=FDZe/eLzTbaEEf9sjA6DA+TQEw80YNQaH5tZhRPk3RJs+OZXtn4gjzwpor54SaegSN
         LW/FV9JpzNifrvjGhLtfiPAPOIEPyebKPF7M6kPHfca14vs/bvAen24ghNCS4S3Bd3cD
         PvF+1Q4hWDRN93QVnkSJpe/QT6yR/HbAV39pkV+UNMYMLk48Y4JwR1WbTq28f2fceacv
         UiYc8bDknoie8upf35IM97ROHUse0sBD8GmoWoka0LMpu3nVdCkJ4rr86q0H11FlM9Lk
         tdeGx+I5vcgDhr+J20mZwCihGeFgLIvAs6cAATsAUBoe7Cks+Neb6EFGbR30psh66Ejf
         6cUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAUZ1SRj0Q56L4r/9mlAa2AbYyPJjmF/VSbuKkA/Jtf8dKGKjNWu
	OXvmIiG0PhJyNFnvvBIeBFBzcv0JKYr+U0WyTIgtyotSVYrR0bomlQB37xjaHdXJ9iY3D3b/IYQ
	4HIVbd1z+GXULd/lxDEU2NJR7xTROrTxqgkEskTEBqk9jAe21e+Y2bZbVpU5/lSAmRA==
X-Received: by 2002:aa7:d7d2:: with SMTP id e18mr98719182eds.286.1564415074655;
        Mon, 29 Jul 2019 08:44:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHW1PFESLaYhWtCs/eL+JZzRnOS2MpobV7gjpWFX5iJfuQtDVCbroSEFzg8AYoPcmQkFRf
X-Received: by 2002:aa7:d7d2:: with SMTP id e18mr98719124eds.286.1564415073811;
        Mon, 29 Jul 2019 08:44:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564415073; cv=none;
        d=google.com; s=arc-20160816;
        b=J1aRunYuVGebJXcNEzsqW/pv81dUvgxnyKtrfbb3lAsa1KSiqSDN2TOgdiKjx3KltP
         Xcjq530X1vPQi2Uf1db08FSUcdWygo5/DeVsNtoieojf20vmq2lKezinjol7k05TITaz
         rpboluBSGJTbDZHzqqgqidY4OJFJJdDQEjJAj4l0v+IbtqW3ehWEUy9yFBwHFAjG85Zy
         2U21848sTKslFVMBR9ZbGuAhbvexexF5RwrHFxIY1j5JIBJi/xVdmjT4/Nyv3WtZQMzN
         W38f6SUMg42zlDlNa/vMOBWznYrWaaAYVrVOBG2QsAr6p05RWlXommyJB2RE6mDy109f
         wCqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4w0NvDQJHYunFbzTs84/ma+toZ+YlE3yjMHTTx7zgK0=;
        b=NPd5byTIufeStqef7MXP9t3n73Bulwe7olPRhsLczJR0tbYI3S6XpuY/HAiLS0Vnwt
         b98GM3Zf04+os6G3WIZOS8T6VmTdZl8/h541RE1oUuk8ZLYv9kd0n9R1tjXg0Noxn2Dh
         qdCZgs+W3Ccjurvr3Wi3+R8xR6Z36Qo2uhSLyjhmWLVH3cPL9ySHbUDj6FBGJPw556Dd
         Bdl+eRY56RoENvCVJB3SA+VK2pA7cIrsREnivHWzEYygNR6iFjt2SQJMvohOVRHzvrIc
         juEQq4CCIYjW62Vl8Mr1riUs42v4MGdVK+mb3aRsXu2ApIwK6X7PG8IxUclDGeuOqI7W
         Q+9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id n13si18337578edn.373.2019.07.29.08.44.33
        for <linux-mm@kvack.org>;
        Mon, 29 Jul 2019 08:44:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C1FD8337;
	Mon, 29 Jul 2019 08:44:32 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 86A4B3F694;
	Mon, 29 Jul 2019 08:44:31 -0700 (PDT)
Date: Mon, 29 Jul 2019 16:44:26 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org,
	aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org,
	linux-kernel@vger.kernel.org, dvyukov@google.com
Subject: Re: [PATCH v2 1/3] kasan: support backing vmalloc space with real
 shadow memory
Message-ID: <20190729154426.GA51922@lakrids.cambridge.arm.com>
References: <20190729142108.23343-1-dja@axtens.net>
 <20190729142108.23343-2-dja@axtens.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729142108.23343-2-dja@axtens.net>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Daniel,

On Tue, Jul 30, 2019 at 12:21:06AM +1000, Daniel Axtens wrote:
> Hook into vmalloc and vmap, and dynamically allocate real shadow
> memory to back the mappings.
> 
> Most mappings in vmalloc space are small, requiring less than a full
> page of shadow space. Allocating a full shadow page per mapping would
> therefore be wasteful. Furthermore, to ensure that different mappings
> use different shadow pages, mappings would have to be aligned to
> KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.
> 
> Instead, share backing space across multiple mappings. Allocate
> a backing page the first time a mapping in vmalloc space uses a
> particular page of the shadow region. Keep this page around
> regardless of whether the mapping is later freed - in the mean time
> the page could have become shared by another vmalloc mapping.
> 
> This can in theory lead to unbounded memory growth, but the vmalloc
> allocator is pretty good at reusing addresses, so the practical memory
> usage grows at first but then stays fairly stable.
> 
> This requires architecture support to actually use: arches must stop
> mapping the read-only zero page over portion of the shadow region that
> covers the vmalloc space and instead leave it unmapped.
> 
> This allows KASAN with VMAP_STACK, and will be needed for architectures
> that do not have a separate module space (e.g. powerpc64, which I am
> currently working on).
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=202009
> Signed-off-by: Daniel Axtens <dja@axtens.net>

This generally looks good, but I have a few concerns below, mostly
related to concurrency.

[...]

> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 2277b82902d8..15d8f4ad581b 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -568,6 +568,7 @@ void kasan_kfree_large(void *ptr, unsigned long ip)
>  	/* The object will be poisoned by page_alloc. */
>  }
>  
> +#ifndef CONFIG_KASAN_VMALLOC
>  int kasan_module_alloc(void *addr, size_t size)
>  {
>  	void *ret;
> @@ -603,6 +604,7 @@ void kasan_free_shadow(const struct vm_struct *vm)
>  	if (vm->flags & VM_KASAN)
>  		vfree(kasan_mem_to_shadow(vm->addr));
>  }
> +#endif

IIUC we can drop MODULE_ALIGN back to PAGE_SIZE in this case, too.

>  
>  extern void __kasan_report(unsigned long addr, size_t size, bool is_write, unsigned long ip);
>  
> @@ -722,3 +724,52 @@ static int __init kasan_memhotplug_init(void)
>  
>  core_initcall(kasan_memhotplug_init);
>  #endif
> +
> +#ifdef CONFIG_KASAN_VMALLOC
> +void kasan_cover_vmalloc(unsigned long requested_size, struct vm_struct *area)

Nit: I think it would be more consistent to call this
kasan_populate_vmalloc().

> +{
> +	unsigned long shadow_alloc_start, shadow_alloc_end;
> +	unsigned long addr;
> +	unsigned long backing;
> +	pgd_t *pgdp;
> +	p4d_t *p4dp;
> +	pud_t *pudp;
> +	pmd_t *pmdp;
> +	pte_t *ptep;
> +	pte_t backing_pte;

Nit: I think it would be preferable to use 'page' rather than 'backing',
and 'pte' rather than 'backing_pte', since there's no otehr namespace to
collide with here. Otherwise, using 'shadow' rather than 'backing' would
be consistent with the existing kasan code.

> +
> +	shadow_alloc_start = ALIGN_DOWN(
> +		(unsigned long)kasan_mem_to_shadow(area->addr),
> +		PAGE_SIZE);
> +	shadow_alloc_end = ALIGN(
> +		(unsigned long)kasan_mem_to_shadow(area->addr + area->size),
> +		PAGE_SIZE);
> +
> +	addr = shadow_alloc_start;
> +	do {
> +		pgdp = pgd_offset_k(addr);
> +		p4dp = p4d_alloc(&init_mm, pgdp, addr);
> +		pudp = pud_alloc(&init_mm, p4dp, addr);
> +		pmdp = pmd_alloc(&init_mm, pudp, addr);
> +		ptep = pte_alloc_kernel(pmdp, addr);
> +
> +		/*
> +		 * we can validly get here if pte is not none: it means we
> +		 * allocated this page earlier to use part of it for another
> +		 * allocation
> +		 */
> +		if (pte_none(*ptep)) {
> +			backing = __get_free_page(GFP_KERNEL);
> +			backing_pte = pfn_pte(PFN_DOWN(__pa(backing)),
> +					      PAGE_KERNEL);
> +			set_pte_at(&init_mm, addr, ptep, backing_pte);
> +		}

Does anything prevent two threads from racing to allocate the same
shadow page?

AFAICT it's possible for two threads to get down to the ptep, then both
see pte_none(*ptep)), then both try to allocate the same page.

I suspect we have to take init_mm::page_table_lock when plumbing this
in, similarly to __pte_alloc().

> +	} while (addr += PAGE_SIZE, addr != shadow_alloc_end);
> +
> +	kasan_unpoison_shadow(area->addr, requested_size);
> +	requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> +	kasan_poison_shadow(area->addr + requested_size,
> +			    area->size - requested_size,
> +			    KASAN_VMALLOC_INVALID);

IIUC, this could leave the final portion of an allocated page
unpoisoned.

I think it might make more sense to poison each page when it's
allocated, then plumb it into the page tables, then unpoison the object.

That way, we can rely on any shadow allocated by another thread having
been initialized to KASAN_VMALLOC_INVALID, and only need mutual
exclusion when allocating the shadow, rather than when poisoning
objects.

Thanks,
Mark.

