Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6A06B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:46:19 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id p127so29173409iop.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:46:19 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0079.outbound.protection.outlook.com. [104.47.33.79])
        by mx.google.com with ESMTPS id u23si4666137ite.36.2016.12.14.01.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 01:46:18 -0800 (PST)
Date: Wed, 14 Dec 2016 10:45:42 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH] arm64: mm: Fix NOMAP page initialization
Message-ID: <20161214094542.GE5588@rric.localdomain>
References: <1481307042-29773-1-git-send-email-rrichter@cavium.com>
 <83d6e6d0-cfb3-ec8b-241b-ec6a50dc2aa9@huawei.com>
 <9168b603-04aa-4302-3197-00f17fb336bd@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <9168b603-04aa-4302-3197-00f17fb336bd@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, James Morse <james.morse@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>

On 12.12.16 17:53:02, Yisheng Xie wrote:
> It seems that memblock_is_memory() is also too strict for early_pfn_valid,
> so what about this patch, which use common pfn_valid as early_pfn_valid
> when CONFIG_HAVE_ARCH_PFN_VALID=y:
> ------------
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 0f088f3..9d596f3 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1200,7 +1200,17 @@ static inline int pfn_present(unsigned long pfn)
>  #define pfn_to_nid(pfn)                (0)
>  #endif
> 
> +#ifdef CONFIG_HAVE_ARCH_PFN_VALID
> +static inline int early_pfn_valid(unsigned long pfn)
> +{
> +       if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> +               return 0;
> +       return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
> +}

I sent a V2 patch that uses pfn_present(). This only initilizes
sections with memory.

-Robert

> +#define early_pfn_valid early_pfn_valid
> +#else
>  #define early_pfn_valid(pfn)   pfn_valid(pfn)
> +#endif
>  void sparse_init(void);
>  #else
>  #define sparse_init()  do {} while (0)
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
