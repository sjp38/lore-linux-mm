Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60C706B79C8
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 06:50:18 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id h85so66660oib.9
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 03:50:18 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b15si48825oti.170.2018.12.06.03.50.16
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 03:50:17 -0800 (PST)
Date: Thu, 6 Dec 2018 11:50:12 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V4 4/6] arm64: mm: Offset TTBR1 to allow 52-bit
 PTRS_PER_PGD
Message-ID: <20181206115011.GC54495@arrakis.emea.arm.com>
References: <20181205164145.24568-1-steve.capper@arm.com>
 <20181205164145.24568-5-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205164145.24568-5-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, jcm@redhat.com, ard.biesheuvel@linaro.org

On Wed, Dec 05, 2018 at 04:41:43PM +0000, Steve Capper wrote:
> diff --git a/arch/arm64/include/asm/asm-uaccess.h b/arch/arm64/include/asm/asm-uaccess.h
> index 4128bec033f6..cd361dd16b12 100644
> --- a/arch/arm64/include/asm/asm-uaccess.h
> +++ b/arch/arm64/include/asm/asm-uaccess.h
> @@ -14,11 +14,13 @@
>  #ifdef CONFIG_ARM64_SW_TTBR0_PAN
>  	.macro	__uaccess_ttbr0_disable, tmp1
>  	mrs	\tmp1, ttbr1_el1			// swapper_pg_dir
> +	restore_ttbr1 \tmp1
>  	bic	\tmp1, \tmp1, #TTBR_ASID_MASK
>  	sub	\tmp1, \tmp1, #RESERVED_TTBR0_SIZE	// reserved_ttbr0 just before swapper_pg_dir
>  	msr	ttbr0_el1, \tmp1			// set reserved TTBR0_EL1
>  	isb
>  	add	\tmp1, \tmp1, #RESERVED_TTBR0_SIZE
> +	offset_ttbr1 \tmp1
>  	msr	ttbr1_el1, \tmp1		// set reserved ASID
>  	isb
>  	.endm
> @@ -27,8 +29,10 @@
>  	get_thread_info \tmp1
>  	ldr	\tmp1, [\tmp1, #TSK_TI_TTBR0]	// load saved TTBR0_EL1
>  	mrs	\tmp2, ttbr1_el1
> +	restore_ttbr1 \tmp2
>  	extr    \tmp2, \tmp2, \tmp1, #48
>  	ror     \tmp2, \tmp2, #16
> +	offset_ttbr1 \tmp2
>  	msr	ttbr1_el1, \tmp2		// set the active ASID
>  	isb
>  	msr	ttbr0_el1, \tmp1		// set the non-PAN TTBR0_EL1

The patch looks alright but I think we can simplify it further if we add:

	depends on ARM64_PAN || !ARM64_SW_TTBR0_PAN

to the 52-bit Kconfig entry.

-- 
Catalin
