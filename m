Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30BEA6B497D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:09:38 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id t13so8466452otk.4
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:09:38 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e26si1900562oth.259.2018.11.27.09.09.36
        for <linux-mm@kvack.org>;
        Tue, 27 Nov 2018 09:09:36 -0800 (PST)
Date: Tue, 27 Nov 2018 17:09:32 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH V3 2/5] arm64: mm: Introduce DEFAULT_MAP_WINDOW
Message-ID: <20181127170931.GC3563@arrakis.emea.arm.com>
References: <20181114133920.7134-1-steve.capper@arm.com>
 <20181114133920.7134-3-steve.capper@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114133920.7134-3-steve.capper@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@arm.com>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, jcm@redhat.com, ard.biesheuvel@linaro.org

Hi Steve,

On Wed, Nov 14, 2018 at 01:39:17PM +0000, Steve Capper wrote:
> diff --git a/arch/arm64/include/asm/processor.h b/arch/arm64/include/asm/processor.h
> index 3e2091708b8e..da41a2655b69 100644
> --- a/arch/arm64/include/asm/processor.h
> +++ b/arch/arm64/include/asm/processor.h
> @@ -25,6 +25,9 @@
>  #define USER_DS		(TASK_SIZE_64 - 1)
>  
>  #ifndef __ASSEMBLY__
> +
> +#define DEFAULT_MAP_WINDOW_64	(UL(1) << VA_BITS)
> +
>  #ifdef __KERNEL__

That's a strange place to place DEFAULT_MAP_WINDOW_64. Did you have any
#include dependency issues? If yes, we could look at cleaning them up,
maybe moving these definitions into a separate file.

(also, if you do a clean-up I don't think we need __KERNEL__ anymore)

>  
>  #include <linux/build_bug.h>
> @@ -51,13 +54,16 @@
>  				TASK_SIZE_32 : TASK_SIZE_64)
>  #define TASK_SIZE_OF(tsk)	(test_tsk_thread_flag(tsk, TIF_32BIT) ? \
>  				TASK_SIZE_32 : TASK_SIZE_64)
> +#define DEFAULT_MAP_WINDOW	(test_thread_flag(TIF_32BIT) ? \
> +				TASK_SIZE_32 : DEFAULT_MAP_WINDOW_64)
>  #else
>  #define TASK_SIZE		TASK_SIZE_64
> +#define DEFAULT_MAP_WINDOW	DEFAULT_MAP_WINDOW_64
>  #endif /* CONFIG_COMPAT */
>  
> -#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(TASK_SIZE / 4))
> +#define TASK_UNMAPPED_BASE	(PAGE_ALIGN(DEFAULT_MAP_WINDOW / 4))
> +#define STACK_TOP_MAX		DEFAULT_MAP_WINDOW_64
>  
> -#define STACK_TOP_MAX		TASK_SIZE_64
>  #ifdef CONFIG_COMPAT
>  #define AARCH32_VECTORS_BASE	0xffff0000
>  #define STACK_TOP		(test_thread_flag(TIF_32BIT) ? \
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 9d9582cac6c4..e5a1dc0beef9 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -609,7 +609,7 @@ void __init mem_init(void)
>  	 * detected at build time already.
>  	 */
>  #ifdef CONFIG_COMPAT
> -	BUILD_BUG_ON(TASK_SIZE_32			> TASK_SIZE_64);
> +	BUILD_BUG_ON(TASK_SIZE_32			> DEFAULT_MAP_WINDOW_64);
>  #endif

Since you are at this, can you please remove the useless white space (I
guess it was there before when we had more BUILD_BUG_ONs).

> diff --git a/drivers/firmware/efi/libstub/arm-stub.c b/drivers/firmware/efi/libstub/arm-stub.c
> index 30ac0c975f8a..d1ec7136e3e1 100644
> --- a/drivers/firmware/efi/libstub/arm-stub.c
> +++ b/drivers/firmware/efi/libstub/arm-stub.c
> @@ -33,7 +33,7 @@
>  #define EFI_RT_VIRTUAL_SIZE	SZ_512M
>  
>  #ifdef CONFIG_ARM64
> -# define EFI_RT_VIRTUAL_LIMIT	TASK_SIZE_64
> +# define EFI_RT_VIRTUAL_LIMIT	DEFAULT_MAP_WINDOW_64
>  #else
>  # define EFI_RT_VIRTUAL_LIMIT	TASK_SIZE
>  #endif

Just curious, would anything happen if we leave this to TASK_SIZE_64?

-- 
Catalin
