Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAEA86B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:10:35 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so116040799pad.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:10:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g1si889695ywh.480.2016.08.31.14.10.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 14:10:34 -0700 (PDT)
Date: Wed, 31 Aug 2016 14:10:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: Move definition of 'zone_names' array into
 mmzone.h
Message-Id: <20160831141033.8f617b6000bf129bbc40bda7@linux-foundation.org>
In-Reply-To: <1472613950-16867-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1472613950-16867-1-git-send-email-khandual@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 31 Aug 2016 08:55:49 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> zone_names[] is used to identify any zone given it's index which
> can be used in many other places. So moving the definition into
> include/linux/mmzone.h for broader access.
> 
> ...
>
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -341,6 +341,23 @@ enum zone_type {
>  
>  };
>  
> +static char * const zone_names[__MAX_NR_ZONES] = {
> +#ifdef CONFIG_ZONE_DMA
> +	 "DMA",
> +#endif
> +#ifdef CONFIG_ZONE_DMA32
> +	 "DMA32",
> +#endif
> +	 "Normal",
> +#ifdef CONFIG_HIGHMEM
> +	 "HighMem",
> +#endif
> +	 "Movable",
> +#ifdef CONFIG_ZONE_DEVICE
> +	 "Device",
> +#endif
> +};
> +
>  #ifndef __GENERATING_BOUNDS_H
>  
>  struct zone {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3fbe73a..8e2261c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -207,23 +207,6 @@ int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1] = {
>  
>  EXPORT_SYMBOL(totalram_pages);
>  
> -static char * const zone_names[MAX_NR_ZONES] = {
> -#ifdef CONFIG_ZONE_DMA
> -	 "DMA",
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -	 "DMA32",
> -#endif
> -	 "Normal",
> -#ifdef CONFIG_HIGHMEM
> -	 "HighMem",
> -#endif
> -	 "Movable",
> -#ifdef CONFIG_ZONE_DEVICE
> -	 "Device",
> -#endif
> -};
> -
>  char * const migratetype_names[MIGRATE_TYPES] = {
>  	"Unmovable",
>  	"Movable",

This is worrisome.  On some (ancient) compilers, this will produce a
copy of that array into each compilation unit which includes mmzone.h.

On smarter compilers, it will produce a copy of the array in each
compilation unit which *uses* zone_names[].

On even smarter compilers (and linkers!), only one copy of zone_names[]
will exist in vmlinux.

I don't know if gcc is an "even smarter compiler" and I didn't check,
and I didn't check which gcc versions are even smarter.  I'd rather not
have to ;) It is risky.

So, let's just make it non-static and add a declaration into mmzone.h,
please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
