Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 486056B0023
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 04:14:36 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id v4-v6so7197784plp.16
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 01:14:36 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id c11-v6si7790717pls.723.2018.03.23.01.14.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 01:14:34 -0700 (PDT)
Subject: Re: [PATCH V3] ZBOOT: fix stack protector in compressed boot phase
From: Marek Szyprowski <m.szyprowski@samsung.com>
Message-id: <e117a68e-69d6-2f9d-b6bb-7a8b0025e2b4@samsung.com>
Date: Fri, 23 Mar 2018 09:14:23 +0100
MIME-version: 1.0
In-reply-to: <1521186916-13745-1-git-send-email-chenhc@lemote.com>
Content-type: text/plain; charset="utf-8"; format="flowed"
Content-transfer-encoding: 7bit
Content-language: en-US
References: <CGME20180316075352epcas5p3d95b13f9382ff7bbce83b8177e8e3ad6@epcas5p3.samsung.com>
	<1521186916-13745-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huacai Chen <chenhc@lemote.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, Russell King <linux@arm.linux.org.uk>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-mm@kvack.org, stable@vger.kernel.org, James Hogan <james.hogan@mips.com>, linux-arm-kernel@lists.infradead.org, 'Linux Samsung SOC' <linux-samsung-soc@vger.kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>

Hi Huacai,

On 2018-03-16 08:55, Huacai Chen wrote:
> Call __stack_chk_guard_setup() in decompress_kernel() is too late that
> stack checking always fails for decompress_kernel() itself. So remove
> __stack_chk_guard_setup() and initialize __stack_chk_guard before we
> call decompress_kernel().
>
> Original code comes from ARM but also used for MIPS and SH, so fix them
> together. If without this fix, compressed booting of these archs will
> fail because stack checking is enabled by default (>=4.16).
>
> V2: Fix build on ARM.
> V3: Fix build on SuperH.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Huacai Chen <chenhc@lemote.com>

This patch breaks booting on ARM Exynos4210 based boards (tested with
next-20180323, exynos_defconfig, both Trats and Origen fails to boot).
That's a bit strange, because all other Exynos SoC works fine (I've
checked 3250, 4412, 5250, 5410 and 542x). I really have no idea what
is so specific inc case of Exynos4210, that causes this failure.

> ---
>   arch/arm/boot/compressed/head.S        | 4 ++++
>   arch/arm/boot/compressed/misc.c        | 7 -------
>   arch/mips/boot/compressed/decompress.c | 7 -------
>   arch/mips/boot/compressed/head.S       | 4 ++++
>   arch/sh/boot/compressed/head_32.S      | 8 ++++++++
>   arch/sh/boot/compressed/head_64.S      | 4 ++++
>   arch/sh/boot/compressed/misc.c         | 7 -------
>   7 files changed, 20 insertions(+), 21 deletions(-)
>
> diff --git a/arch/arm/boot/compressed/head.S b/arch/arm/boot/compressed/head.S
> index 45c8823..bae1fc6 100644
> --- a/arch/arm/boot/compressed/head.S
> +++ b/arch/arm/boot/compressed/head.S
> @@ -547,6 +547,10 @@ not_relocated:	mov	r0, #0
>   		bic	r4, r4, #1
>   		blne	cache_on
>   
> +		ldr	r0, =__stack_chk_guard
> +		ldr	r1, =0x000a0dff
> +		str	r1, [r0]
> +
>   /*
>    * The C runtime environment should now be setup sufficiently.
>    * Set up some pointers, and start decompressing.
> diff --git a/arch/arm/boot/compressed/misc.c b/arch/arm/boot/compressed/misc.c
> index 16a8a80..e518ef5 100644
> --- a/arch/arm/boot/compressed/misc.c
> +++ b/arch/arm/boot/compressed/misc.c
> @@ -130,11 +130,6 @@ asmlinkage void __div0(void)
>   
>   unsigned long __stack_chk_guard;
>   
> -void __stack_chk_guard_setup(void)
> -{
> -	__stack_chk_guard = 0x000a0dff;
> -}
> -
>   void __stack_chk_fail(void)
>   {
>   	error("stack-protector: Kernel stack is corrupted\n");
> @@ -150,8 +145,6 @@ decompress_kernel(unsigned long output_start, unsigned long free_mem_ptr_p,
>   {
>   	int ret;
>   
> -	__stack_chk_guard_setup();
> -
>   	output_data		= (unsigned char *)output_start;
>   	free_mem_ptr		= free_mem_ptr_p;
>   	free_mem_end_ptr	= free_mem_ptr_end_p;
> diff --git a/arch/mips/boot/compressed/decompress.c b/arch/mips/boot/compressed/decompress.c
> index fdf99e9..5ba431c 100644
> --- a/arch/mips/boot/compressed/decompress.c
> +++ b/arch/mips/boot/compressed/decompress.c
> @@ -78,11 +78,6 @@ void error(char *x)
>   
>   unsigned long __stack_chk_guard;
>   
> -void __stack_chk_guard_setup(void)
> -{
> -	__stack_chk_guard = 0x000a0dff;
> -}
> -
>   void __stack_chk_fail(void)
>   {
>   	error("stack-protector: Kernel stack is corrupted\n");
> @@ -92,8 +87,6 @@ void decompress_kernel(unsigned long boot_heap_start)
>   {
>   	unsigned long zimage_start, zimage_size;
>   
> -	__stack_chk_guard_setup();
> -
>   	zimage_start = (unsigned long)(&__image_begin);
>   	zimage_size = (unsigned long)(&__image_end) -
>   	    (unsigned long)(&__image_begin);
> diff --git a/arch/mips/boot/compressed/head.S b/arch/mips/boot/compressed/head.S
> index 409cb48..00d0ee0 100644
> --- a/arch/mips/boot/compressed/head.S
> +++ b/arch/mips/boot/compressed/head.S
> @@ -32,6 +32,10 @@ start:
>   	bne	a2, a0, 1b
>   	 addiu	a0, a0, 4
>   
> +	PTR_LA	a0, __stack_chk_guard
> +	PTR_LI	a1, 0x000a0dff
> +	sw	a1, 0(a0)
> +
>   	PTR_LA	a0, (.heap)	     /* heap address */
>   	PTR_LA	sp, (.stack + 8192)  /* stack address */
>   
> diff --git a/arch/sh/boot/compressed/head_32.S b/arch/sh/boot/compressed/head_32.S
> index 7bb1681..e84237d 100644
> --- a/arch/sh/boot/compressed/head_32.S
> +++ b/arch/sh/boot/compressed/head_32.S
> @@ -76,6 +76,10 @@ l1:
>   	mov.l	init_stack_addr, r0
>   	mov.l	@r0, r15
>   
> +	mov.l	__stack_chk_guard_addr, r0
> +	mov.l	__stack_chk_guard_val, r1
> +	mov.l	r1, @r0
> +
>   	/* Decompress the kernel */
>   	mov.l	decompress_kernel_addr, r0
>   	jsr	@r0
> @@ -97,6 +101,10 @@ kexec_magic:
>   	.long	0x400000F0	/* magic used by kexec to parse zImage format */
>   init_stack_addr:
>   	.long	stack_start
> +__stack_chk_guard_val:
> +	.long	0x000A0DFF
> +__stack_chk_guard_addr:
> +	.long	__stack_chk_guard
>   decompress_kernel_addr:
>   	.long	decompress_kernel
>   kernel_start_addr:
> diff --git a/arch/sh/boot/compressed/head_64.S b/arch/sh/boot/compressed/head_64.S
> index 9993113..8b4d540 100644
> --- a/arch/sh/boot/compressed/head_64.S
> +++ b/arch/sh/boot/compressed/head_64.S
> @@ -132,6 +132,10 @@ startup:
>   	addi	r22, 4, r22
>   	bne	r22, r23, tr1
>   
> +	movi	datalabel __stack_chk_guard, r0
> +	movi	0x000a0dff, r1
> +	st.l	r0, 0, r1
> +
>   	/*
>   	 * Decompress the kernel.
>   	 */
> diff --git a/arch/sh/boot/compressed/misc.c b/arch/sh/boot/compressed/misc.c
> index 627ce8e..fe4c079 100644
> --- a/arch/sh/boot/compressed/misc.c
> +++ b/arch/sh/boot/compressed/misc.c
> @@ -106,11 +106,6 @@ static void error(char *x)
>   
>   unsigned long __stack_chk_guard;
>   
> -void __stack_chk_guard_setup(void)
> -{
> -	__stack_chk_guard = 0x000a0dff;
> -}
> -
>   void __stack_chk_fail(void)
>   {
>   	error("stack-protector: Kernel stack is corrupted\n");
> @@ -130,8 +125,6 @@ void decompress_kernel(void)
>   {
>   	unsigned long output_addr;
>   
> -	__stack_chk_guard_setup();
> -
>   #ifdef CONFIG_SUPERH64
>   	output_addr = (CONFIG_MEMORY_START + 0x2000);
>   #else

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
