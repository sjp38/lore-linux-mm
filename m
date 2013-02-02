Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 6B96D6B0007
	for <linux-mm@kvack.org>; Sat,  2 Feb 2013 13:00:12 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id 10so4461394ied.30
        for <linux-mm@kvack.org>; Sat, 02 Feb 2013 10:00:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <0000013c25e260c8-aeaa555f-3466-4c01-8e81-9891429850b2-000000@email.amazonses.com>
References: <20130110190027.780479755@linux.com>
	<0000013c25e260c8-aeaa555f-3466-4c01-8e81-9891429850b2-000000@email.amazonses.com>
Date: Sat, 2 Feb 2013 15:00:11 -0300
Message-ID: <CALF0-+VGnhL0B5nuqJUYCEzKRxzzxJAWzT2x1SumVRmVapdLRg@mail.gmail.com>
Subject: Re: REN2 [07/13] Common constants for kmalloc boundaries
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tim Bird <tim.bird@am.sony.com>

Hi Christoph,

On Thu, Jan 10, 2013 at 4:14 PM, Christoph Lameter <cl@linux.com> wrote:
> Standardize the constants that describe the smallest and largest
> object kept in the kmalloc arrays for SLAB and SLUB.
>
> Differentiate between the maximum size for which a slab cache is used
> (KMALLOC_MAX_CACHE_SIZE) and the maximum allocatable size
> (KMALLOC_MAX_SIZE, KMALLOC_MAX_ORDER).
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux/include/linux/slab.h
> ===================================================================
> --- linux.orig/include/linux/slab.h     2013-01-10 09:42:25.640301677 -0600
> +++ linux/include/linux/slab.h  2013-01-10 09:43:40.857456229 -0600
> @@ -163,7 +163,12 @@ struct kmem_cache {
>  #else /* CONFIG_SLOB */
>
>  /*
> - * The largest kmalloc size supported by the slab allocators is
> + * Kmalloc array related definitions
> + */
> +
> +#ifdef CONFIG_SLAB
> +/*
> + * The largest kmalloc size supported by the SLAB allocators is
>   * 32 megabyte (2^25) or the maximum allocatable page order if that is
>   * less than 32 MB.
>   *
> @@ -173,9 +178,24 @@ struct kmem_cache {
>   */
>  #define KMALLOC_SHIFT_HIGH     ((MAX_ORDER + PAGE_SHIFT - 1) <= 25 ? \
>                                 (MAX_ORDER + PAGE_SHIFT - 1) : 25)
> +#define KMALLOC_SHIFT_MAX      KMALLOC_SHIFT_HIGH
> +#define KMALLOC_SHIFT_LOW      5
> +#else
> +/*
> + * SLUB allocates up to order 2 pages directly and otherwise
> + * passes the request to the page allocator.
> + */
> +#define KMALLOC_SHIFT_HIGH     (PAGE_SHIFT + 1)
> +#define KMALLOC_SHIFT_MAX      (MAX_ORDER + PAGE_SHIFT)
> +#define KMALLOC_SHIFT_LOW      3
> +#endif
>

Why do we need to distinguish SLAB from SLUB here?

I mean: why do we need to maintain 32 bytes as the smallest kmalloc cache?

Thanks,

-- 
    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
