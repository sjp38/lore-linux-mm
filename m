Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 05F2C900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:42:12 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p5MNfxu3011888
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:41:59 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by kpbe15.cbf.corp.google.com with ESMTP id p5MNeDRr019780
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:41:57 -0700
Received: by pwi3 with SMTP id 3so1079122pwi.8
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:41:57 -0700 (PDT)
Date: Wed, 22 Jun 2011 16:41:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slob: push the min alignment to long long
In-Reply-To: <alpine.DEB.2.00.1106141614480.10017@router.home>
Message-ID: <alpine.DEB.2.00.1106221641120.14635@chino.kir.corp.google.com>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc> <alpine.DEB.2.00.1106141614480.10017@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 14 Jun 2011, Christoph Lameter wrote:

> Index: linux-2.6/include/linux/slab.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slab.h	2011-06-14 15:46:38.000000000 -0500
> +++ linux-2.6/include/linux/slab.h	2011-06-14 15:46:59.000000000 -0500
> @@ -133,6 +133,16 @@ unsigned int kmem_cache_size(struct kmem
>  #define KMALLOC_MAX_SIZE	(1UL << KMALLOC_SHIFT_HIGH)
>  #define KMALLOC_MAX_ORDER	(KMALLOC_SHIFT_HIGH - PAGE_SHIFT)
> 
> +#ifdef ARCH_DMA_MINALIGN
> +#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
> +#else
> +#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
> +#endif
> +
> +#ifndef ARCH_SLAB_MINALIGN
> +#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
> +#endif
> +
>  /*
>   * Common kmalloc functions provided by all allocators
>   */
> Index: linux-2.6/include/linux/slab_def.h
> ===================================================================
> --- linux-2.6.orig/include/linux/slab_def.h	2011-06-14 15:47:04.000000000 -0500
> +++ linux-2.6/include/linux/slab_def.h	2011-06-14 15:50:04.000000000 -0500
> @@ -18,32 +18,6 @@
>  #include <trace/events/kmem.h>
> 
>  /*
> - * Enforce a minimum alignment for the kmalloc caches.
> - * Usually, the kmalloc caches are cache_line_size() aligned, except when
> - * DEBUG and FORCED_DEBUG are enabled, then they are BYTES_PER_WORD aligned.
> - * Some archs want to perform DMA into kmalloc caches and need a guaranteed
> - * alignment larger than the alignment of a 64-bit integer.
> - * ARCH_KMALLOC_MINALIGN allows that.
> - * Note that increasing this value may disable some debug features.
> - */
> -#ifdef ARCH_DMA_MINALIGN
> -#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
> -#else
> -#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
> -#endif
> -
> -#ifndef ARCH_SLAB_MINALIGN
> -/*
> - * Enforce a minimum alignment for all caches.
> - * Intended for archs that get misalignment faults even for BYTES_PER_WORD
> - * aligned buffers. Includes ARCH_KMALLOC_MINALIGN.
> - * If possible: Do not enable this flag for CONFIG_DEBUG_SLAB, it disables
> - * some debug features.
> - */
> -#define ARCH_SLAB_MINALIGN 0
> -#endif
> -
> -/*
>   * struct kmem_cache
>   *
>   * manages a cache.

Looks like we lost some valuable information in the comments when this got 
moved to slab.h :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
