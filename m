Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24591C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 09:41:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAF7021734
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 09:41:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAF7021734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88EE66B0003; Tue, 23 Jul 2019 05:41:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83F2D6B0005; Tue, 23 Jul 2019 05:41:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 706D88E0002; Tue, 23 Jul 2019 05:41:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2218E6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 05:41:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so27911659edw.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:41:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=uaG4lCzaum3hsc8jwC70pDyFFzzku6vAuvySMnVwZAc=;
        b=XO+XVVl/ApakxXZjKHW8UE3YVV9IGSc889dFO84xYry9hUgoVV0GvGHg7vbL/mj4+t
         JpVDbWWUMCO0nqGupeFIeB1P4jeZg8wBVMNXNkJUc4MTldHT/9AUGG9LG2gSK0hfkb6B
         GUWS5CsuwB8U7HPKU5UJJQ1mAJx52Nv/FHQWAy4bhlyxv7h6hQUYNtI3tFwYf6yGJtBF
         +an81srE25r+SSkHLQh6X55VvXWnbjhWvJyvUFqRxo4uZV/iQ/UVelzZwRp4AT/+nVoS
         tgEeNjnM143gmZt0kHuGAuq+N6OOk7bu0q0cRUg+vNPa7GXzuMz7dxHwlDt61TP03lp9
         a+bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAVXL1wRqs/7JAcuRG72/skFqLQQmN94N8i2t6YKkEpQY4nGQjE1
	5xH2sX2AoMZZPIIeoVrMvNijwv9rU9ml6M2cZoRp+d/oI4gLT/xBmCVm++AQKCpxJgAFT9SFx2v
	tXua4DzWO2GFR98+NnKh85n2Md7zsc8550bQX+8GmlR3rFPnU/ja6JVcTQJvQ0mJSVg==
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr55884952ejo.24.1563874882687;
        Tue, 23 Jul 2019 02:41:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVkqGcz7VV5kBz5thcACihqwwPVgNayjE8CGtBfy4shTaQZwQ6BvTq5TsO+aQ78P7Aq+P8
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr55884916ejo.24.1563874882022;
        Tue, 23 Jul 2019 02:41:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563874882; cv=none;
        d=google.com; s=arc-20160816;
        b=LKVuw/oDzNuVZJqPXK/Ww0AHN09YeAYf72hom9i9+txJX8z7TEHzXUI8tFzwVv2va5
         iL3pfLwipwtDzgU2J7svrvYOq3UsihehpLQjoe4lPJPn4xGkUP31PL7nT/UqEzWxztoI
         uepQdpx45+8JMfR+j3FWSTg32zlv5IX3VpP7XOriWJwFjfEZbk3ZI8ZDO+5LqD3Aauti
         G+C+uQo9678NGf3pibgOQICY0WsTTiS0CjzEN9nO3Qe+Xfgl54065xk6IQG7va2NA8C9
         RSmckPR+GlA2Bnvbv27B//uRx4s/x3EsM3KQ5MDOUnmTc1ia8D/OULyh73mnBZ0qESoU
         mPSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=uaG4lCzaum3hsc8jwC70pDyFFzzku6vAuvySMnVwZAc=;
        b=H0GexV5fViKW8Ps2MAJcCaRWU0h1xpn/crrQve79lYe6OuwAUrDF/mQOLOF9ukK+Tp
         npNiYPlMVNBA/15pyjCt/7a4KihS1uV0Ytej6WEq8U316NCXdGFjU2dRb4/bMq0DmYGW
         1+u10rQpIjJJqkI1MV0wyWbPFgyzQVph2WIwT3k54iVn4ZEHDC8rCUgKgaHV8vxpyCUP
         P2v32CIu39lfn9RvLtVtJhmSFPYEIXJ791liFktoELgP/TSVno9N5jKyO855TSvODwhq
         BRJRfd3EwakMjQxLYwgMXvuR5z0ehZHD5M7A/7ra6VgF0bbTlt3CSvzXhnklKyj9uOUi
         qDnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id y54si6381574edb.416.2019.07.23.02.41.21
        for <linux-mm@kvack.org>;
        Tue, 23 Jul 2019 02:41:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2D794337;
	Tue, 23 Jul 2019 02:41:21 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B37613F71A;
	Tue, 23 Jul 2019 02:41:18 -0700 (PDT)
Date: Tue, 23 Jul 2019 10:41:14 +0100
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
	Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will@kernel.org>,
	x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
Message-ID: <20190723094113.GA8085@lakrids.cambridge.arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <20190722154210.42799-11-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722154210.42799-11-steven.price@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 04:41:59PM +0100, Steven Price wrote:
> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> we may come across the exotic large mappings that come with large areas
> of contiguous memory (such as the kernel's linear map).
> 
> For architectures that don't provide all p?d_leaf() macros, provide
> generic do nothing default that are suitable where there cannot be leaf
> pages that that level.
> 
> Signed-off-by: Steven Price <steven.price@arm.com>

Not a big deal, but it would probably make sense for this to be patch 1
in the series, given it defines the semantic of p?d_leaf(), and they're
not used until we provide all the architectural implemetnations anyway.

It might also be worth pointing out the reasons for this naming, e.g.
p?d_large() aren't currently generic, and this name minimizes potential
confusion between p?d_{large,huge}().

> ---
>  include/asm-generic/pgtable.h | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 75d9d68a6de7..46275896ca66 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -1188,4 +1188,23 @@ static inline bool arch_has_pfn_modify_check(void)
>  #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
>  #endif
>  
> +/*
> + * p?d_leaf() - true if this entry is a final mapping to a physical address.
> + * This differs from p?d_huge() by the fact that they are always available (if
> + * the architecture supports large pages at the appropriate level) even
> + * if CONFIG_HUGETLB_PAGE is not defined.
> + */

I assume it's only safe to call these on valid entries? I think it would
be worth calling that out explicitly.

Otherwise, this looks sound to me:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

> +#ifndef pgd_leaf
> +#define pgd_leaf(x)	0
> +#endif
> +#ifndef p4d_leaf
> +#define p4d_leaf(x)	0
> +#endif
> +#ifndef pud_leaf
> +#define pud_leaf(x)	0
> +#endif
> +#ifndef pmd_leaf
> +#define pmd_leaf(x)	0
> +#endif
> +
>  #endif /* _ASM_GENERIC_PGTABLE_H */
> -- 
> 2.20.1
> 

