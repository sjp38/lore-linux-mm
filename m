Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD48AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 13:52:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 849902084F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 13:52:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 849902084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F84C8E0084; Thu, 21 Feb 2019 08:52:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 180308E0002; Thu, 21 Feb 2019 08:52:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 047D48E0084; Thu, 21 Feb 2019 08:52:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 995EE8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 08:52:09 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c18so11331724edt.23
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 05:52:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=x8aXtCsvUtSVcpW2yrG1sr8Alwm3FoYWoIGlK41Ki/U=;
        b=LceJ7s5IWJQL+TBcxNV0Nmwn6A4eBqoNcpQ3HsBP23WrfzygojtiTC+STTIU+R3Ev0
         4teAomAYmVFPaLQ6/WA+VKyF36ByimJg/ucIljwsB/RqSx6RRDeSKfT1MZOKkRPsO9eG
         Riu1kxA5odI1O6ktvIJu6cQdDmANOEkqy5lMZ/fxOYjS9kMP2yCJfp12ID2Zl5XK+n8Q
         bBJkpmxe72tPT3QhEk+8yci+bJK9bWAyA9P9+jQyzHG7lHFjU1dQMRnA+6qcvSn1hNH5
         cku3tSu2F0Yjv86Wj7RGfEnAIQgm0ZvNlQ7P558FPJndFPqDzmlPmmJD7VOiWA398HzB
         1JRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: AHQUAuaD/2w3pzmsTWCXoxzLOtgHir3FTocLEqK+zlhZ8IHP32AKD/iY
	eRVgh7fBcDUfqI/ugDNdbpA+d/qic4FxMUNZiPkzJzd+qK1dgwM4zCOOov3aRT7fYmoZmuEExNR
	j7pmI3JHmM0v/MbnFI8CmwCIu/WAciny94wFBZPykeIa8ExmqtyHvbxSKiVS4z64C3Q==
X-Received: by 2002:a17:906:59d3:: with SMTP id m19mr27998880ejs.37.1550757129146;
        Thu, 21 Feb 2019 05:52:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY8f3yoFMN8CDqxzQji1+/3XcsmAUBvfg1PnooNveU20ARWSms47gyQKuNkawuoMIa88aC0
X-Received: by 2002:a17:906:59d3:: with SMTP id m19mr27998813ejs.37.1550757127887;
        Thu, 21 Feb 2019 05:52:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550757127; cv=none;
        d=google.com; s=arc-20160816;
        b=XQnPiR65eJdbkqq4D4T9Sogkirr8PUZNeRZR2MHt5mCP89AF5rj++/tlFSHPbtmWiz
         9omUrsQEXqGqSmZmP9ebSX+LtrlNrWEMBhSNomuf+1Stb/2EjzmIfFoEtxiiXNgzBrn0
         sPTJgXzODJ/oH2uHFupxoLP9JJpiMo9Kj8/+u1jPqQh41GOxIWqioUE3vugE1Jy8sXXy
         XLCfF5uzQgCIf6I/0EvrIh8JDH3nf2YMlfkY9SaegMtACPlqdfle3W24438VLp8egBbG
         CHKiwbAdSUYXrCLvvJJN6xUDZBRnwOPb5MxJembmdgqJE+Tj+ZAyOSbGyH18y8Xp8+Cx
         H4Tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=x8aXtCsvUtSVcpW2yrG1sr8Alwm3FoYWoIGlK41Ki/U=;
        b=S92RT6xUWr+JX8s2k/UjJekz6IRfA4TaI3+9jh/v3iwlfYXq6wMd6m3oXAzQIFU+d+
         9G5Ve9JcdwRv49shRUKtlaCKq3/6sqhfNUOIdxXxLYWaftVI+o7cxUgqLNJC7MEjnwhT
         FqEO3Dho/V6oIkJyjK3l7A5KJw3mEU5fxB/661HJLgZGAxpD9AsLRG6al5Ys1mjBMGuo
         O1Ap9lgTdC9Ocdd2fymRZdkDvJeswdfxl6/nk3vvc+cA1f2k3+mFWzPYTIEbkbw4Ld0N
         lnzDCpjP2cLNQIU1S/W+YlkUOfgR6xpN1V85TIwvOgK8o6E+A4+/QOkmBa1e/8w549pd
         MtfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n6si668365edr.330.2019.02.21.05.52.07
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 05:52:07 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6E47680D;
	Thu, 21 Feb 2019 05:52:06 -0800 (PST)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 14BE13F5C1;
	Thu, 21 Feb 2019 05:52:02 -0800 (PST)
Date: Thu, 21 Feb 2019 13:52:00 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v2 01/13] arm64: mm: Add p?d_large() definitions
Message-ID: <20190221135200.GG33673@lakrids.cambridge.arm.com>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-2-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221113502.54153-2-steven.price@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:34:50AM +0000, Steven Price wrote:
> From: James Morse <james.morse@arm.com>
> 
> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> we may come across the exotic large mappings that come with large areas
> of contiguous memory (such as the kernel's linear map).
> 
> Expose p?d_large() from each architecture to detect these large mappings.
> 
> arm64 already has these macros defined, but with a different name.
> p?d_large() is used by s390, sparc and x86. Only arm/arm64 use p?d_sect().
> Add a macro to allow both names.

So that we can avoid conflciting terminology, could we reword this as:

A generic walk_page_range() needs to handle exotic leaf entries at
arbitrary depths in the page tables (e.g. section mappings in the
kernel's linear map, or huge pages in userspace page tables).

Currently there is no generic API to detect such entries, but s390,
sparc, and x86 have all aligned on p?d_large(). Let's implement the same
for arm64 atop of p?d_cont().

With that:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  arch/arm64/include/asm/pgtable.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index de70c1eabf33..09d308921625 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  				 PMD_TYPE_TABLE)
>  #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
>  				 PMD_TYPE_SECT)
> +#define pmd_large(x)		pmd_sect(x)
>  
>  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
>  #define pud_sect(pud)		(0)
> @@ -435,6 +436,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
>  #else
>  #define pud_sect(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
>  				 PUD_TYPE_SECT)
> +#define pud_large(x)		pud_sect(x)
>  #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
>  				 PUD_TYPE_TABLE)
>  #endif
> -- 
> 2.20.1
> 

