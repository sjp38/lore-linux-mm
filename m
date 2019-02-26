Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D8A4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:12:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59E9120851
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:12:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="e55m6nKW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59E9120851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E961F8E0003; Tue, 26 Feb 2019 00:12:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E45A18E0002; Tue, 26 Feb 2019 00:12:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D34538E0003; Tue, 26 Feb 2019 00:12:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93EB48E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:12:35 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j13so8981713pll.15
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 21:12:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:in-reply-to
         :references:date:message-id:mime-version;
        bh=jP7E96nDoS9qSn8Kxb3Jp/bLxbA/jS+6WHNjYKFaHjE=;
        b=Wwx6Sza9jHfHqL2bFUS0Gk772Yvsz/Ioz2AVmWzlVacvYOFeiu2aC9hv/CEhCcj7Ge
         L4sp0SsUF2y1+KOZOgVUtnzbKE81vxvrxo01m02VdjdY+YctddlJH3PcQLHP9O92es2D
         CF7gejGB3s7JJqclMy1GfYVzsnc+Pa8R0htLebk/yH9vvYXTlQsLMnVcyhfGRo0XnHWZ
         1qJbo2V7cjj+GLY/jI8Q2XzVmfvylHS0gC3BxnSHt41PeQzoo1bU6k8qKTip0LpqjbyI
         XJmY6oVJeqdQqIuweDxrwvSCYBBHEz9rtCakiomfH1YwJLxb6Wv2P/xAZWToRzRT3ewS
         oXDg==
X-Gm-Message-State: AHQUAubHXgv2sMy3OtRosl3zTJr3BFypMnf/5q5/xznvJyrDFW4hYf3N
	59Dy2dqETIzSGNDM+xR/DLYbqH3fINbvfjIVxGK93zQs8R55svjpUUl0H++UqwAHZd/cv73utOG
	raOZlxHnsjm8Z9zbphrCC94mxpyPebaRkx8JX3irgT8/sGZnB2YDVbFb7Pm1yKC3+pBY009/bsd
	qQ+LEEXE6DrjOo/+IOxTfTG/yjarI4uLO3I/NX0dZurZgt/Omt/6ASd9Lv9XTbDHJQPksUDtVkp
	rpatTPAMY0uPHYhFrxlt0bz4hzITRfjBuR8Fv9SUBqeE00I5W0nXSo9rUYCpzSM9P7mmxUnF69u
	eBheg2e26AZZMzWsxF3FWLP1GVkk2GuiAVsMasi+soiRBEFfX+Dr0mP2IgZCAUHMQkSZi47TSXQ
	n
X-Received: by 2002:a17:902:4503:: with SMTP id m3mr24112109pld.35.1551157955181;
        Mon, 25 Feb 2019 21:12:35 -0800 (PST)
X-Received: by 2002:a17:902:4503:: with SMTP id m3mr24112015pld.35.1551157953627;
        Mon, 25 Feb 2019 21:12:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551157953; cv=none;
        d=google.com; s=arc-20160816;
        b=yKIx4PhBiBquAGSL/YFrJl5D5ZVn1Wle8zRbtFI2BJrjrne1KomQYbrW8BLkkjT8iA
         tgPiAzC/59pay10GOh5ydjqY/0M9X+VFW3BufoCbIdt5SiaHq2RHLV8sBVed730si0DV
         c+Ilwc5reYkeAhE5b39/gIrpOEGFygCL10ngDJ6UK2Z8dwKClwIYJ8PyhfKds9VPXzIz
         9lQEGTaKwCfEKvvN4k16mCZb/4vIY7QEW5mAm9MLpzxXsjsuw07Apzr6ubjTD2pUlIxf
         PMBY7UL2IP1hqgOh8O5Xjs5inWGTWSwPw7HLAimXWGH4PGqx67zJrjFbzohxSObUiJrn
         6XSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:dkim-signature;
        bh=jP7E96nDoS9qSn8Kxb3Jp/bLxbA/jS+6WHNjYKFaHjE=;
        b=K5QmpQBUfWT0Kib8AkPfrvH9lsnz02YtjRJ/Dk0k1AoSthS0vlePYTh7qgZFMlgs/c
         x/ZyLsN6J04TyqxlQzyX32Exd4RkjZ+URpU4E//eQ8L5RgiMl2aZH0bPfItylFnvjI2l
         7A7r9a3Ab8p9tXj+GKOGpb3qS7OP3qmk4tOdWr80yIjjATyp4Kf9bk+1D9+a120T49D+
         xpc4MA3Pc8Isn0LR1qT1o/sAUSxqra8ca+SZrgzIVFBUFaAAGLkyTpb9ZHKZNKYQ+Kvu
         OzzOoz+v3oT8CYnsjdH2wdeNGAkGZTtPQ+/C2KyPCJyBHJFQ6RUf4tyFbjLKRYbgJrbZ
         1MeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=e55m6nKW;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x13sor16525619pgr.56.2019.02.25.21.12.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 21:12:33 -0800 (PST)
Received-SPF: pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@axtens.net header.s=google header.b=e55m6nKW;
       spf=pass (google.com: domain of dja@axtens.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=dja@axtens.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=jP7E96nDoS9qSn8Kxb3Jp/bLxbA/jS+6WHNjYKFaHjE=;
        b=e55m6nKW/IQe++VEbFmJ3PdWMLlNZdt+OvmM+JvnjNi4qDJ0NM71riTgrciXkTr2/d
         XOyow++bPK333G+xGQ94OB3Mpc36jFTiBk1xLUyrNHdd+jxuz4xyhsKq24yIKGDXgYyw
         HJmDnxCSixGHOTPu7P25HX5DZEjJXzAyHMzG0=
X-Google-Smtp-Source: AHgI3IaSLGOpU22EpGz/ie7BujSE7kSVELONx0Juwd5c5vPPZ5pv3S8o7D4lS8F/xPSn7sZWKZdL1w==
X-Received: by 2002:a63:354a:: with SMTP id c71mr22981364pga.150.1551157953041;
        Mon, 25 Feb 2019 21:12:33 -0800 (PST)
Received: from localhost (124-171-134-245.dyn.iinet.net.au. [124.171.134.245])
        by smtp.gmail.com with ESMTPSA id d5sm16233714pfo.83.2019.02.25.21.12.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 21:12:32 -0800 (PST)
From: Daniel Axtens <dja@axtens.net>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Subject: Re: [PATCH v7 07/11] powerpc/32: prepare shadow area for KASAN
In-Reply-To: <bada5c0051f749565d27da9527ce933aa205bf86.1551098214.git.christophe.leroy@c-s.fr>
References: <cover.1551098214.git.christophe.leroy@c-s.fr> <bada5c0051f749565d27da9527ce933aa205bf86.1551098214.git.christophe.leroy@c-s.fr>
Date: Tue, 26 Feb 2019 16:12:29 +1100
Message-ID: <87a7ij2kw2.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christophe Leroy <christophe.leroy@c-s.fr> writes:

> This patch prepares a shadow area for KASAN.
>
> The shadow area will be at the top of the kernel virtual
> memory space above the fixmap area and will occupy one
> eighth of the total kernel virtual memory space.
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  arch/powerpc/Kconfig              |  5 +++++
>  arch/powerpc/include/asm/fixmap.h |  5 +++++
>  arch/powerpc/include/asm/kasan.h  | 17 +++++++++++++++++
>  arch/powerpc/mm/mem.c             |  4 ++++
>  arch/powerpc/mm/ptdump/ptdump.c   |  8 ++++++++
>  5 files changed, 39 insertions(+)
>
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 652c25260838..f446e016f4a1 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -382,6 +382,11 @@ config PGTABLE_LEVELS
>  	default 3 if PPC_64K_PAGES && !PPC_BOOK3S_64
>  	default 4
>  
> +config KASAN_SHADOW_OFFSET
> +	hex
> +	depends on KASAN
> +	default 0xe0000000
> +

Should this live in Kconfig.debug?

Regards,
Daniel

>  source "arch/powerpc/sysdev/Kconfig"
>  source "arch/powerpc/platforms/Kconfig"
>  
> diff --git a/arch/powerpc/include/asm/fixmap.h b/arch/powerpc/include/asm/fixmap.h
> index b9fbed84ddca..51a1a309c919 100644
> --- a/arch/powerpc/include/asm/fixmap.h
> +++ b/arch/powerpc/include/asm/fixmap.h
> @@ -22,7 +22,12 @@
>  #include <asm/kmap_types.h>
>  #endif
>  
> +#ifdef CONFIG_KASAN
> +#include <asm/kasan.h>
> +#define FIXADDR_TOP	KASAN_SHADOW_START
> +#else
>  #define FIXADDR_TOP	((unsigned long)(-PAGE_SIZE))
> +#endif
>  
>  /*
>   * Here we define all the compile-time 'special' virtual
> diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
> index 2efd0e42cfc9..b554d3bd3e2c 100644
> --- a/arch/powerpc/include/asm/kasan.h
> +++ b/arch/powerpc/include/asm/kasan.h
> @@ -12,4 +12,21 @@
>  #define EXPORT_SYMBOL_KASAN(fn)	EXPORT_SYMBOL(fn)
>  #endif
>  
> +#ifndef __ASSEMBLY__
> +
> +#include <asm/page.h>
> +#include <asm/pgtable-types.h>
> +
> +#define KASAN_SHADOW_SCALE_SHIFT	3
> +
> +#define KASAN_SHADOW_OFFSET	ASM_CONST(CONFIG_KASAN_SHADOW_OFFSET)
> +
> +#define KASAN_SHADOW_START	(KASAN_SHADOW_OFFSET + \
> +				 (PAGE_OFFSET >> KASAN_SHADOW_SCALE_SHIFT))
> +
> +#define KASAN_SHADOW_END	0UL
> +
> +#define KASAN_SHADOW_SIZE	(KASAN_SHADOW_END - KASAN_SHADOW_START)
> +
> +#endif /* __ASSEMBLY */
>  #endif
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index f6787f90e158..4e7fa4eb2dd3 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -309,6 +309,10 @@ void __init mem_init(void)
>  	mem_init_print_info(NULL);
>  #ifdef CONFIG_PPC32
>  	pr_info("Kernel virtual memory layout:\n");
> +#ifdef CONFIG_KASAN
> +	pr_info("  * 0x%08lx..0x%08lx  : kasan shadow mem\n",
> +		KASAN_SHADOW_START, KASAN_SHADOW_END);
> +#endif
>  	pr_info("  * 0x%08lx..0x%08lx  : fixmap\n", FIXADDR_START, FIXADDR_TOP);
>  #ifdef CONFIG_HIGHMEM
>  	pr_info("  * 0x%08lx..0x%08lx  : highmem PTEs\n",
> diff --git a/arch/powerpc/mm/ptdump/ptdump.c b/arch/powerpc/mm/ptdump/ptdump.c
> index 37138428ab55..812ed680024f 100644
> --- a/arch/powerpc/mm/ptdump/ptdump.c
> +++ b/arch/powerpc/mm/ptdump/ptdump.c
> @@ -101,6 +101,10 @@ static struct addr_marker address_markers[] = {
>  	{ 0,	"Fixmap start" },
>  	{ 0,	"Fixmap end" },
>  #endif
> +#ifdef CONFIG_KASAN
> +	{ 0,	"kasan shadow mem start" },
> +	{ 0,	"kasan shadow mem end" },
> +#endif
>  	{ -1,	NULL },
>  };
>  
> @@ -322,6 +326,10 @@ static void populate_markers(void)
>  #endif
>  	address_markers[i++].start_address = FIXADDR_START;
>  	address_markers[i++].start_address = FIXADDR_TOP;
> +#ifdef CONFIG_KASAN
> +	address_markers[i++].start_address = KASAN_SHADOW_START;
> +	address_markers[i++].start_address = KASAN_SHADOW_END;
> +#endif
>  #endif /* CONFIG_PPC64 */
>  }
>  
> -- 
> 2.13.3

