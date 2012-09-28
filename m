Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id D0C896B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 04:31:22 -0400 (EDT)
Message-ID: <50655F8D.5010706@parallels.com>
Date: Fri, 28 Sep 2012 12:27:57 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: CK1 [06/13] Common kmalloc slab index determination
References: <20120926200005.911809821@linux.com> <0000013a043cdd82-a153095d-219a-467a-b0f2-c799f5ddbb05-000000@email.amazonses.com>
In-Reply-To: <0000013a043cdd82-a153095d-219a-467a-b0f2-c799f5ddbb05-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 09/27/2012 12:20 AM, Christoph Lameter wrote:
> Extract the function to determine the index of the slab within
> the array of kmalloc caches as well as a function to determine
> maximum object size from the nr of the kmalloc slab.
> 
> This is used here only to simplify slub bootstrap but will
> be used later also for SLAB.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com> 
> 
> Index: linux/include/linux/slab.h
> ===================================================================
> --- linux.orig/include/linux/slab.h	2012-09-19 09:19:38.904986568 -0500
> +++ linux/include/linux/slab.h	2012-09-19 09:21:27.307238804 -0500
> @@ -178,6 +178,90 @@ unsigned int kmem_cache_size(struct kmem
>  #endif
>  
>  /*
> + * Kmalloc subsystem.
> + */
> +#if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
> +#define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
> +#else
> +#ifdef CONFIG_SLAB
> +#define KMALLOC_MIN_SIZE 32
> +#else
> +#define KMALLOC_MIN_SIZE 8
> +#endif
> +#endif
> +
> +#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
> +
> +/*
> + * Figure out which kmalloc slab an allocation of a certain size
> + * belongs to.
> + * 0 = zero alloc
> + * 1 =  65 .. 96 bytes
> + * 2 = 120 .. 192 bytes
> + * n = 2^(n-1) .. 2^n -1
> + */
> +static __always_inline int kmalloc_index(size_t size)
> +{
> +	if (!size)
> +		return 0;
> +
> +	if (size <= KMALLOC_MIN_SIZE)
> +		return KMALLOC_SHIFT_LOW;
> +
> +	if (KMALLOC_MIN_SIZE <= 32 && size > 64 && size <= 96)
> +		return 1;
> +	if (KMALLOC_MIN_SIZE <= 64 && size > 128 && size <= 192)
> +		return 2;
> +	if (size <=          8) return 3;
> +	if (size <=         16) return 4;
> +	if (size <=         32) return 5;
> +	if (size <=         64) return 6;
> +	if (size <=        128) return 7;
> +	if (size <=        256) return 8;
> +	if (size <=        512) return 9;
> +	if (size <=       1024) return 10;
> +	if (size <=   2 * 1024) return 11;
> +	if (size <=   4 * 1024) return 12;
> +	if (size <=   8 * 1024) return 13;
> +	if (size <=  16 * 1024) return 14;
> +	if (size <=  32 * 1024) return 15;
> +	if (size <=  64 * 1024) return 16;
> +	if (size <= 128 * 1024) return 17;
> +	if (size <= 256 * 1024) return 18;
> +	if (size <= 512 * 1024) return 19;
> +	if (size <= 1024 * 1024) return 20;
> +	if (size <=  2 * 1024 * 1024) return 21;
> +	if (size <=  4 * 1024 * 1024) return 22;
> +	if (size <=  8 * 1024 * 1024) return 23;
> +	if (size <=  16 * 1024 * 1024) return 24;
> +	if (size <=  32 * 1024 * 1024) return 26;
> +	if (size <=  64 * 1024 * 1024) return 27;
> +	BUG();
> +
> +	/* Will never be reached. Needed because the compiler may complain */
> +	return -1;
> +}
> +

That is a bunch of branches... can't we use ilog2 for that somehow ?

In any case, you skipped "return 25".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
