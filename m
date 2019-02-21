Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A055FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 13:41:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D1EA20855
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 13:41:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D1EA20855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8652C8E0083; Thu, 21 Feb 2019 08:41:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 815DD8E0002; Thu, 21 Feb 2019 08:41:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7064B8E0083; Thu, 21 Feb 2019 08:41:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA158E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 08:41:56 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o27so1086796edc.14
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 05:41:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zNLkUA2CHO+DUTV7jQBZKZK58f1IZJfaD3xZgsMtjvU=;
        b=TevVaOqQ1Gnhz3rz2z1GCgJQCKU1CzJgpoV9VTJrE90M3rJFKkUN3u0mlOTNNbz8Xk
         A2QxXZ61Le+bLpGM/K8Gke3i4nsRif5qg2W8B9/LzTsV8veGNDjHtWpI3wm3U2pY7Zh6
         q2UfcY7wZPayIC/smrN4GYSfAUjOLLkq0Zy0jhRjaomsZmkda61P0VvewRWsqsBSTzAm
         NMw5+TNPYkHTKepPMfMdyMKMTt9B+FtjWWNK52PeEhQvyIVByktW4CrqzbgCoObgQJDc
         ylANVFO/WV/igwxmf7OHtKCvwfu6WXcxsaMA6DLU8FYf8sM99gTDC/CcKi994ZdKNi2E
         00fg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: AHQUAuZQZK8yadoqAQ8UKp3fO54hjxfCemh1MNBp0u+hy4TKwUOUxJtw
	4Pl95OwM+8yPM2rFVC6WTXk/3YsdMiZlfpZk5dlnfG537GkhhuwHx7dfZ0PCM4XGptdDhTSBQci
	yH+0JSWWEVi/eYeZxdxzq/jihbFq+ftMyuyZsfTa0/ldZdyRC+Fl+QX0hEAwuYJyhGA==
X-Received: by 2002:a17:906:4212:: with SMTP id z18mr27569557ejk.78.1550756515479;
        Thu, 21 Feb 2019 05:41:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYiS3lgL5WwZqLdQlMx0tqkY6jsAjYaP3oI1Oc0Kc7ocogMdr4ovNcluI4IS4bzJ8S37+Rx
X-Received: by 2002:a17:906:4212:: with SMTP id z18mr27569512ejk.78.1550756514540;
        Thu, 21 Feb 2019 05:41:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550756514; cv=none;
        d=google.com; s=arc-20160816;
        b=jL8GeNsYAFGyEk3z46vYcVfMC9Ra56GXNRGBop55k71kaPiSTsJKduyfQgo4jBZ3Ni
         FA3Z3HXE+X5hYuj7AoI1rsYjHEm1oXnY04lO4N6YFUd6Uw1is9zWLiox7cs4p8HGrrPX
         ew5fkt2PKXdiB0m5yCTVzTv+1zUNX0yGidLnK1AsuuvMM7IkfLojf6q9ENWuyeGFG90y
         n9xEIyXBud7j2NP5w363H8wA0/Y70VFjuK3io1G+QkFiDkFID74dONAjCu0wyxPSlH1z
         CUELZqnuKoj8stMRJQLk2uiN8Ue+naQS/IQ0UTCKyNmvaLUde6PQuXTJzAQlan4SJcIG
         0wqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zNLkUA2CHO+DUTV7jQBZKZK58f1IZJfaD3xZgsMtjvU=;
        b=C6xkiwjNNUyBWPhpThW0QtdYd7/j1Hcrb97NtThjsSWbt6IyiAu42mf4KqnPvxzrcR
         CdwvLxN5rPFzL/VezP3VIyzQPvdH3Glj8E+lmr4m7VISBFs44aeElHNspijSZUoO510C
         Q6iu+skIyS01FSsHGzBpwD6JTiqQcW6WPNKvWhfrV6fjSagVczV9gw4emWVA20eIb3Jj
         88OHzpSAaTijqmSnvOiQkZutMnK/2CnrJJ/gJu2FVoWvrxCcFG6Ktubcz4CAvG5HwuaL
         XREVyeQ7beSGAoVWnd1wPA1dEFAxyrBfU3G7pDcmd5oewSIUyfMhP5U+TWwBqqI45uVL
         TCLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t29si4448060edt.450.2019.02.21.05.41.54
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 05:41:54 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F087280D;
	Thu, 21 Feb 2019 05:41:52 -0800 (PST)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8B55F3F5C1;
	Thu, 21 Feb 2019 05:41:49 -0800 (PST)
Date: Thu, 21 Feb 2019 13:41:46 +0000
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
Subject: Re: [PATCH v2 03/13] mm: Add generic p?d_large() macros
Message-ID: <20190221134146.GF33673@lakrids.cambridge.arm.com>
References: <20190221113502.54153-1-steven.price@arm.com>
 <20190221113502.54153-4-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221113502.54153-4-steven.price@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:34:52AM +0000, Steven Price wrote:
> From: James Morse <james.morse@arm.com>
> 
> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> we may come across the exotic large mappings that come with large areas
> of contiguous memory (such as the kernel's linear map).
> 
> For architectures that don't provide p?d_large() macros, provided a
> does nothing default.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  include/asm-generic/pgtable.h | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 05e61e6c843f..f0de24100ac6 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -1186,4 +1186,23 @@ static inline bool arch_has_pfn_modify_check(void)
>  #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
>  #endif
>  
> +/*
> + * p?d_large() - true if this entry is a final mapping to a physical address.

It might make sense to s/final/leaf/, but otherwise that's a great
definition!

> + * This differs from p?d_huge() by the fact that they are always available (if
> + * the architecture supports large pages at the appropriate level) even
> + * if CONFIG_HUGETLB_PAGE is not defined.

I'm not sure if we need this part, since we don't mention
p?d_trans_huge(), etc, but either way:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

> + */
> +#ifndef pgd_large
> +#define pgd_large(x)	0
> +#endif
> +#ifndef p4d_large
> +#define p4d_large(x)	0
> +#endif
> +#ifndef pud_large
> +#define pud_large(x)	0
> +#endif
> +#ifndef pmd_large
> +#define pmd_large(x)	0
> +#endif
> +
>  #endif /* _ASM_GENERIC_PGTABLE_H */
> -- 
> 2.20.1
> 

