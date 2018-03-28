Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 325C26B0012
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 14:00:01 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j2so2210656qtl.1
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 11:00:01 -0700 (PDT)
Received: from brightrain.aerifal.cx (216-12-86-13.cv.mvl.ntelos.net. [216.12.86.13])
        by mx.google.com with ESMTP id 34si5332237qks.5.2018.03.28.11.00.00
        for <linux-mm@kvack.org>;
        Wed, 28 Mar 2018 11:00:00 -0700 (PDT)
Date: Wed, 28 Mar 2018 13:59:52 -0400
From: Rich Felker <dalias@libc.org>
Subject: Re: [PATCH V4 Resend] ZBOOT: fix stack protector in compressed boot
 phase
Message-ID: <20180328175952.GO1436@brightrain.aerifal.cx>
References: <1522226933-29317-1-git-send-email-chenhc@lemote.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522226933-29317-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huacai Chen <chenhc@lemote.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <james.hogan@mips.com>, linux-mips@linux-mips.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-sh@vger.kernel.org, stable@vger.kernel.org

On Wed, Mar 28, 2018 at 04:48:53PM +0800, Huacai Chen wrote:
> Call __stack_chk_guard_setup() in decompress_kernel() is too late that
> stack checking always fails for decompress_kernel() itself. So remove
> __stack_chk_guard_setup() and initialize __stack_chk_guard before we
> call decompress_kernel().
> 
> Original code comes from ARM but also used for MIPS and SH, so fix them
> together. If without this fix, compressed booting of these archs will
> fail because stack checking is enabled by default (>=4.16).
> 
> V1 -> V2: Fix build on ARM.
> V2 -> V3: Fix build on SuperH.
> V3 -> V4: Initialize __stack_chk_guard in C code as a constant.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Huacai Chen <chenhc@lemote.com>
> ---
>  arch/arm/boot/compressed/misc.c        | 9 +--------
>  arch/mips/boot/compressed/decompress.c | 9 +--------
>  arch/sh/boot/compressed/misc.c         | 9 +--------
>  3 files changed, 3 insertions(+), 24 deletions(-)
> 
> [...]
> 
> diff --git a/arch/sh/boot/compressed/misc.c b/arch/sh/boot/compressed/misc.c
> index 627ce8e..c15cac9 100644
> --- a/arch/sh/boot/compressed/misc.c
> +++ b/arch/sh/boot/compressed/misc.c
> @@ -104,12 +104,7 @@ static void error(char *x)
>  	while(1);	/* Halt */
>  }
>  
> -unsigned long __stack_chk_guard;
> -
> -void __stack_chk_guard_setup(void)
> -{
> -	__stack_chk_guard = 0x000a0dff;
> -}
> +const unsigned long __stack_chk_guard = 0x000a0dff;
>  
>  void __stack_chk_fail(void)
>  {
> @@ -130,8 +125,6 @@ void decompress_kernel(void)
>  {
>  	unsigned long output_addr;
>  
> -	__stack_chk_guard_setup();
> -
>  #ifdef CONFIG_SUPERH64
>  	output_addr = (CONFIG_MEMORY_START + 0x2000);
>  #else
> -- 
> 2.7.0

LGTM.

Acked-by: Rich Felker <dalias@libc.org>

Rich
