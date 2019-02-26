Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC4CCC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:13:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5A7F2173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:13:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5A7F2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 379A38E0005; Tue, 26 Feb 2019 10:13:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3292C8E0001; Tue, 26 Feb 2019 10:13:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23FAD8E0005; Tue, 26 Feb 2019 10:13:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEC1F8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:13:15 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u12so5593261edo.5
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:13:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mSNoZ0HCr9BUrKg1YFywfTS2OUxYWrioh3WzqsV+Dpg=;
        b=sCVI5YchaMT6E8bTVuIFneqGqprAX76+/uEm2QRpZuUQOhRblOnxPiT2uzlfgsQBFB
         jeErQEnvWvVjSB6i8nZESLbJ13Sid06LZeLtehzOSXJVO7wcejOpd1yk2FUWKohVHU+v
         eqRKjWLcsq3NTBOMJY9KRlRQgrEkTNFQav+Lu1wTOsgxva26KouRWfo2NwZAjjbZxpt8
         NdN4qKqP2O1vKf3wkuj+Dl5ItRN1oWcReClWxQuFVav+CMABHj2G0RnFn3sLWnFCdkbX
         NWpYOo8VmoCC0MjhvGM5gGBnMJPQyePmTKaGZ4/F2JEsNZQA8qkgZoHUgxrvTAF0qbE8
         wVRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: AHQUAubj0jwYuYXpJ0ssEB1EOB0esvAWPHKiAnFU0FL5aZtL+QG6eziI
	MM2SiPgAnOgGK6Ewf9nyGDhh1jlUr9rMCrUFp63HjivhvI6fgyGkwrzZjVt0G7DTOhgbRlJIpgF
	Ztvew4DQf6sUjgoZMJ8i0I666nI8LT/XWGtZXSNonYAO0oB0HAESkQcHDmaDPTeYqkA==
X-Received: by 2002:a17:906:3db1:: with SMTP id y17mr17111739ejh.90.1551193995265;
        Tue, 26 Feb 2019 07:13:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYSK1kVivTUKr3b8XZJnS3DqONgPfjf57jawonDfISV22bkkKgsAL5ykv+2rRMj1JsyLHom
X-Received: by 2002:a17:906:3db1:: with SMTP id y17mr17111677ejh.90.1551193994302;
        Tue, 26 Feb 2019 07:13:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551193994; cv=none;
        d=google.com; s=arc-20160816;
        b=YKvoq7rrUCv/d1LeCqC3WlRHVXIUHj6xCbI0C8ZEOVhLaJmo15E0osG28TrEsvwzQx
         8JXg+Qh72/aO/xYuVlvGuRkf/GGp2Ka9Uc4EVC2iycAh2wcHnKalTLhfdtViPL8aBZrp
         zcbVfOgfopdG7ZSwhzDEuJxXE3LrFFbDASI9IgjfX9GaTEVedtp8LACMGYvpxbKv6r0k
         Buj/pNHps8B7Ny2/MSi8U715cuAX5Uefeyv3SQcTEplFcNSvr5e484GJohc9Jc99Q62y
         EJQkZk0v4n5s5xZqBjRbK/8TxMb2iVRUwTFMh7Mvf5OSVjE1iZxWuZcn3a3qgeDcFEdR
         yAbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mSNoZ0HCr9BUrKg1YFywfTS2OUxYWrioh3WzqsV+Dpg=;
        b=NREcPhrqa4UmrKnI3kNSS6bxSN7ZR38oebacgPWEDCr9JsxG4dwDLPU6z+Gkxrk9za
         7hjy9uV3hteyvBMGBAn7lInBPZcioVYaG7lLPnoiIrpRURzMC8ukEtHlY+yrLoaYyOuQ
         wkT4fCRvvnF89p3sFXc4Qu2GSn2GJ3E2Hde9y9j+v6AsyvZTC7zZOaDJP/m1yBwB5K7D
         t9O+htLdYzoy75uUfA7rDoR91RbRRJX8PzY2sRtA3zuwNRn5GQCIxoBnKql10Rs6Fvc2
         ffw/i0P6rjyEYhek9/BHVmsxPGBRMHDZJYAbsGKr8tqcP1gPmaMAUrsGozQ9zo2KHx6R
         jmSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f1si1941055edd.358.2019.02.26.07.13.13
        for <linux-mm@kvack.org>;
        Tue, 26 Feb 2019 07:13:14 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1B9CAA78;
	Tue, 26 Feb 2019 07:13:13 -0800 (PST)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4B5A83F575;
	Tue, 26 Feb 2019 07:13:10 -0800 (PST)
Date: Tue, 26 Feb 2019 15:13:07 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Yu Zhao <yuzhao@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 2/3] arm64: mm: don't call page table ctors for init_mm
Message-ID: <20190226151307.GB20230@lakrids.cambridge.arm.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
 <20190218231319.178224-2-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218231319.178224-2-yuzhao@google.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Feb 18, 2019 at 04:13:18PM -0700, Yu Zhao wrote:
> init_mm doesn't require page table lock to be initialized at
> any level. Add a separate page table allocator for it, and the
> new one skips page table ctors.

Just to check, in a previous reply you mentioned we need to call the
ctors for our efi_mm, since we use apply_to_page_range() on that. Is
that only because apply_to_pte_range() tries to take the ptl for non
init_mm?

... or did I miss something else?

> The ctors allocate memory when ALLOC_SPLIT_PTLOCKS is set. Not
> calling them avoids memory leak in case we call pte_free_kernel()
> on init_mm.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>

Assuming that was all, this patch makes sense to me. FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

> ---
>  arch/arm64/mm/mmu.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index fa7351877af3..e8bf8a6300e8 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -370,6 +370,16 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
>  	} while (pgdp++, addr = next, addr != end);
>  }
>  
> +static phys_addr_t pgd_kernel_pgtable_alloc(int shift)
> +{
> +	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
> +	BUG_ON(!ptr);
> +
> +	/* Ensure the zeroed page is visible to the page table walker */
> +	dsb(ishst);
> +	return __pa(ptr);
> +}
> +
>  static phys_addr_t pgd_pgtable_alloc(int shift)
>  {
>  	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
> @@ -591,7 +601,7 @@ static int __init map_entry_trampoline(void)
>  	/* Map only the text into the trampoline page table */
>  	memset(tramp_pg_dir, 0, PGD_SIZE);
>  	__create_pgd_mapping(tramp_pg_dir, pa_start, TRAMP_VALIAS, PAGE_SIZE,
> -			     prot, pgd_pgtable_alloc, 0);
> +			     prot, pgd_kernel_pgtable_alloc, 0);
>  
>  	/* Map both the text and data into the kernel page table */
>  	__set_fixmap(FIX_ENTRY_TRAMP_TEXT, pa_start, prot);
> @@ -1067,7 +1077,8 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>  		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
>  
>  	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
> -			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
> +			     size, PAGE_KERNEL, pgd_kernel_pgtable_alloc,
> +			     flags);
>  
>  	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>  			   altmap, want_memblock);
> -- 
> 2.21.0.rc0.258.g878e2cd30e-goog
> 

