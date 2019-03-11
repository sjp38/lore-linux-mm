Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01CACC10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 12:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B64652075C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 12:12:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B64652075C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50EE88E001B; Mon, 11 Mar 2019 08:12:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4710C8E0002; Mon, 11 Mar 2019 08:12:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33A118E001B; Mon, 11 Mar 2019 08:12:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CEBF18E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 08:12:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m25so1951490edd.6
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 05:12:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rhsrKwwju6wpjkXF857RTIdXgrqhpbn3Au0/5mrqPOs=;
        b=YvMnJ250YhC9z5t1Zt3VFZ/yFyYwqnI2tw856FIzn2JxEczb2MF0ys5ChVvyoMq578
         1Zf6Mm9r+1r+zwOCRRdqxrRMCbhOyYtLNLKS1vtdNXp0bz8luOYtg7SxkQyetTjTcrhy
         YodFAjFu+GZHxwtcaXjkmdoElgEGcSvRSIBCaJAmS1txGuShg9R3hv+ELmcFlvqrlBMb
         GPLd2qZncml9rMGT6VizMBgo5idX74Qd+V2VnehqFdIHdvknajQVMQFca5FwS0jkpH++
         4vxoShabZ1HrT8OXyhSd38HEWCf+dmE8vUPH5pnrybvgT9YOMBDnVlY+E3wbACOg2NPP
         oomw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAVC2IjPir0sFxdqUYYFdjwdBFUZMB6pBi4VIpiXzGr63Z2pjQUJ
	sEXAVe2HS+dcYMEzSXvSpUIAPt/xqipKzzXL5e3NpI+903g+hJvTDklTjc4UYqHrzrZhYEzWa6c
	pQArWlUDakIE80Ha61E4CULf7qagP+r87VFa6M3EF2tyO8OPyaAeKE/5WGlkFG65Peg==
X-Received: by 2002:a50:ca41:: with SMTP id e1mr44093308edi.73.1552306358420;
        Mon, 11 Mar 2019 05:12:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1XLAQQpeuD64HdTdH/AycZLen0NAq2TIZug4nKoWy7E6lxgLQ39BFdaRkUkRkhYRuiu++
X-Received: by 2002:a50:ca41:: with SMTP id e1mr44093253edi.73.1552306357421;
        Mon, 11 Mar 2019 05:12:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552306357; cv=none;
        d=google.com; s=arc-20160816;
        b=hGA0kY5C+aeaD47V7i7Du3ZjhZWW+JCvf239JQtYRsgUyOFCIJ3SbsBzvZevHbQX+Q
         EqLSf9qmud+GX2S8WdUcGRVbsb2DkdVf8brECnATnsMqLPWtmrc8ohfG46SRfVJALQDk
         oKLzqh7F0Tr7sezjWwNA/Q/6RRpDcIs9KAQAiIVS/lTFfIwbVyGUNSAJRJiK6KgGdBYd
         0+tChQHUksfeY02d0Jyck8usJlsvno1eWhcQR397EYcQacW9KJ8wke7Tnt8TSgbOXBxm
         j95wovOKo49Ogn2aWJl+y/VgHLbjRMvJnG0/wz9tZKT0mkvFTfc0joGqbiiGdC/lLFwU
         KMZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rhsrKwwju6wpjkXF857RTIdXgrqhpbn3Au0/5mrqPOs=;
        b=E7FIoCGxOZ5xl5K+zsVCXxzN+amSwfR7RdOt4dgAYhFWQmdHsztcBtpydQl2zJplOD
         QuIo1FjQlQ53prwuz6jeLMH5piUFvem0wNfnVlgfx5Uc7xFw3dTHgahBBU6GpvcofUaU
         cMvYxHYDqD0aWaaLuQjI39pOwQvYLk0BMFB4VrKPuGSF0R7S8rBV5oy5r9BmDzD0QVJU
         FL1TJm7YHXxf8KyvOoXfokZj2em0GNcDETbSh5pp3Blb0ISrzQyHy8OgUhw2oUD5noyf
         MVbp/SbXl4YBqbFvPnDlPMyc1E3E+q17hqIQ7NuwrJfmmgFTxT7Hw5zhx850e6wINVLa
         eG0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n15si5921581ejk.117.2019.03.11.05.12.36
        for <linux-mm@kvack.org>;
        Mon, 11 Mar 2019 05:12:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 22B80374;
	Mon, 11 Mar 2019 05:12:36 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2E8FE3F703;
	Mon, 11 Mar 2019 05:12:33 -0700 (PDT)
Date: Mon, 11 Mar 2019 12:12:28 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Yu Zhao <yuzhao@google.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>
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
Subject: Re: [PATCH v3 3/3] arm64: mm: enable per pmd page table lock
Message-ID: <20190311121147.GA23361@lakrids.cambridge.arm.com>
References: <20190218231319.178224-1-yuzhao@google.com>
 <20190310011906.254635-1-yuzhao@google.com>
 <20190310011906.254635-3-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190310011906.254635-3-yuzhao@google.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Mar 09, 2019 at 06:19:06PM -0700, Yu Zhao wrote:
> Switch from per mm_struct to per pmd page table lock by enabling
> ARCH_ENABLE_SPLIT_PMD_PTLOCK. This provides better granularity for
> large system.
> 
> I'm not sure if there is contention on mm->page_table_lock. Given
> the option comes at no cost (apart from initializing more spin
> locks), why not enable it now.
> 
> We only do so when pmd is not folded, so we don't mistakenly call
> pgtable_pmd_page_ctor() on pud or p4d in pgd_pgtable_alloc(). (We
> check shift against PMD_SHIFT, which is same as PUD_SHIFT when pmd
> is folded).

Just to check, I take it pgtable_pmd_page_ctor() is now a NOP when the
PMD is folded, and this last paragraph is stale?

> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  arch/arm64/Kconfig               |  3 +++
>  arch/arm64/include/asm/pgalloc.h | 12 +++++++++++-
>  arch/arm64/include/asm/tlb.h     |  5 ++++-
>  3 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index cfbf307d6dc4..a3b1b789f766 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -872,6 +872,9 @@ config ARCH_WANT_HUGE_PMD_SHARE
>  config ARCH_HAS_CACHE_LINE_SIZE
>  	def_bool y
>  
> +config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> +	def_bool y if PGTABLE_LEVELS > 2
> +
>  config SECCOMP
>  	bool "Enable seccomp to safely compute untrusted bytecode"
>  	---help---
> diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
> index 52fa47c73bf0..dabba4b2c61f 100644
> --- a/arch/arm64/include/asm/pgalloc.h
> +++ b/arch/arm64/include/asm/pgalloc.h
> @@ -33,12 +33,22 @@
>  
>  static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
>  {
> -	return (pmd_t *)__get_free_page(PGALLOC_GFP);
> +	struct page *page;
> +
> +	page = alloc_page(PGALLOC_GFP);
> +	if (!page)
> +		return NULL;
> +	if (!pgtable_pmd_page_ctor(page)) {
> +		__free_page(page);
> +		return NULL;
> +	}
> +	return page_address(page);
>  }
>  
>  static inline void pmd_free(struct mm_struct *mm, pmd_t *pmdp)
>  {
>  	BUG_ON((unsigned long)pmdp & (PAGE_SIZE-1));
> +	pgtable_pmd_page_dtor(virt_to_page(pmdp));
>  	free_page((unsigned long)pmdp);
>  }

It looks like arm64's existing stage-2 code is inconsistent across
alloc/free, and IIUC this change might turn that into a real problem.
Currently we allocate all levels of stage-2 table with
__get_free_page(), but free them with p?d_free(). We always miss the
ctor and always use the dtor.

Other than that, this patch looks fine to me, but I'd feel more
comfortable if we could first fix the stage-2 code to free those stage-2
tables without invoking the dtor.

Anshuman, IIRC you had a patch to fix the stage-2 code to not invoke the
dtors. If so, could you please post that so that we could take it as a
preparatory patch for this series?

Thanks,
Mark.

> diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
> index 106fdc951b6e..4e3becfed387 100644
> --- a/arch/arm64/include/asm/tlb.h
> +++ b/arch/arm64/include/asm/tlb.h
> @@ -62,7 +62,10 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
>  static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
>  				  unsigned long addr)
>  {
> -	tlb_remove_table(tlb, virt_to_page(pmdp));
> +	struct page *page = virt_to_page(pmdp);
> +
> +	pgtable_pmd_page_dtor(page);
> +	tlb_remove_table(tlb, page);
>  }
>  #endif
>  
> -- 
> 2.21.0.360.g471c308f928-goog
> 

