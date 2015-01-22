Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A9F6A6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 05:04:57 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so862774pad.7
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 02:04:57 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id zm1si11775564pac.187.2015.01.22.02.04.56
        for <linux-mm@kvack.org>;
        Thu, 22 Jan 2015 02:04:56 -0800 (PST)
Date: Thu, 22 Jan 2015 10:04:41 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] ARM: use default ioremap alignment for SMP or LPAE
Message-ID: <20150122100441.GA19811@e104818-lin.cambridge.arm.com>
References: <1421911075-8814-1-git-send-email-s.dyasly@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421911075-8814-1-git-send-email-s.dyasly@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <s.dyasly@samsung.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, James Bottomley <JBottomley@parallels.com>, Will Deacon <Will.Deacon@arm.com>, Arnd Bergmann <arnd.bergmann@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <d.safonov@partner.samsung.com>

On Thu, Jan 22, 2015 at 07:17:55AM +0000, Sergey Dyasly wrote:
> 16MB alignment for ioremap mappings was added by commit a069c896d0d6 ("[ARM]
> 3705/1: add supersection support to ioremap()") in order to support supersection
> mappings. But __arm_ioremap_pfn_caller uses section and supersection mappings
> only in !SMP && !LPAE case. There is no need for such big alignment if either
> SMP or LPAE is enabled.
[...]
> diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
> index 184def0..c3ef139 100644
> --- a/arch/arm/include/asm/memory.h
> +++ b/arch/arm/include/asm/memory.h
> @@ -78,10 +78,12 @@
>   */
>  #define XIP_VIRT_ADDR(physaddr)  (MODULES_VADDR + ((physaddr) & 0x000fffff))
>  
> +#if !defined(CONFIG_SMP) && !defined(CONFIG_ARM_LPAE)
>  /*
>   * Allow 16MB-aligned ioremap pages
>   */
>  #define IOREMAP_MAX_ORDER	24
> +#endif

Actually, I think we could make this depend only on CONFIG_IO_36. That's
the only scenario where we get the supersections matter, and maybe make
CONFIG_IO_36 dependent on !SMP or !ARM_LPAE. My assumption is that we
don't support single zImage with CPU_XSC3 enabled (but I haven't
followed the latest developments here).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
