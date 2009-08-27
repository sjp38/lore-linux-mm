Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1069F6B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:56:46 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4B00982C9CE
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:57:59 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WhG5h+QeoDHF for <linux-mm@kvack.org>;
	Thu, 27 Aug 2009 11:57:59 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E096A82CA27
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:57:50 -0400 (EDT)
Date: Thu, 27 Aug 2009 11:56:34 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] SLUB: fix ARCH_KMALLOC_MINALIGN cases 64 and 256
In-Reply-To: <1251387491-8417-1-git-send-email-aaro.koskinen@nokia.com>
Message-ID: <alpine.DEB.1.10.0908271151100.17470@gentwo.org>
References: <> <1251387491-8417-1-git-send-email-aaro.koskinen@nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: mpm@selenic.com, penberg@cs.helsinki.fi, linux-mm@kvack.org, Artem.Bityutskiy@nokia.com
List-ID: <linux-mm.kvack.org>

On Thu, 27 Aug 2009, Aaro Koskinen wrote:

> +++ b/include/linux/slub_def.h
> @@ -154,8 +154,10 @@ static __always_inline int kmalloc_index(size_t size)
>  		return KMALLOC_SHIFT_LOW;
>
>  #if KMALLOC_MIN_SIZE <= 64
> +#if KMALLOC_MIN_SIZE <= 32
>  	if (size > 64 && size <= 96)
>  		return 1;
> +#endif

Use elif here to move the condition together with the action?

>  	if (size > 128 && size <= 192)
>  		return 2;
>  #endif
> diff --git a/mm/slub.c b/mm/slub.c
> index b9f1491..3d32ebf 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3156,10 +3156,12 @@ void __init kmem_cache_init(void)
>  	slab_state = PARTIAL;
>
>  	/* Caches that are not of the two-to-the-power-of size */
> -	if (KMALLOC_MIN_SIZE <= 64) {
> +	if (KMALLOC_MIN_SIZE <= 32) {
>  		create_kmalloc_cache(&kmalloc_caches[1],
>  				"kmalloc-96", 96, GFP_NOWAIT);
>  		caches++;
> +	}
> +	if (KMALLOC_MIN_SIZE <= 64) {
>  		create_kmalloc_cache(&kmalloc_caches[2],
>  				"kmalloc-192", 192, GFP_NOWAIT);
>  		caches++;
> @@ -3186,10 +3188,17 @@ void __init kmem_cache_init(void)
>  	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
>  		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
>
> -	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8)
> +	for (i = 8; i < min(KMALLOC_MIN_SIZE, 192 + 8); i += 8)
>  		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;

192 + 8 is related to the  # of elements in size_index.

Define a constant for that and express 192 + 8 as ((NR_SIZE_INDEX + 1 ) *
8)?

size_index[(i - 1) /8] appears frequently now. Can we put this into an
inline function or macro to make it more understandable?

> -	if (KMALLOC_MIN_SIZE == 128) {
> +	if (KMALLOC_MIN_SIZE == 64) {
> +		/*
> +		 * The 96 byte size cache is not used if the alignment
> +		 * is 64 byte.
> +		 */
> +		for (i = 64 + 8; i <= 96; i += 8)
> +			size_index[(i - 1) / 8] = 7;
> +	} else if (KMALLOC_MIN_SIZE == 128) {
>  		/*
>  		 * The 192 byte sized cache is not used if the alignment
>  		 * is 128 byte. Redirect kmalloc to use the 256 byte cache

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
