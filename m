Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id DBFE96B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:11:56 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id s13so141268qcv.2
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 11:11:56 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id u5si14944662qed.99.2013.11.21.11.11.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Nov 2013 11:11:51 -0800 (PST)
Message-ID: <528E5AEF.6020007@infradead.org>
Date: Thu, 21 Nov 2013 11:11:43 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: remove the redundant declaration of kmalloc
References: <528DA0C0.8010505@huawei.com>
In-Reply-To: <528DA0C0.8010505@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/20/13 21:57, Qiang Huang wrote:
> 
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

or use my patch from 2013-09-17:
http://marc.info/?l=linux-mm&m=137944291611467&w=2

Would be nice to one of these merged...


> ---
>  include/linux/slab.h | 102 +++++++++++++++++++++++----------------------------
>  1 file changed, 46 insertions(+), 56 deletions(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 74f1058..630f22f 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -381,7 +381,52 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
>  /**
>   * kmalloc - allocate memory
>   * @size: how many bytes of memory are required.
> - * @flags: the type of memory to allocate (see kcalloc).
> + * @flags: the type of memory to allocate.
> + *
> + * The @flags argument may be one of:
> + *
> + * %GFP_USER - Allocate memory on behalf of user.  May sleep.
> + *
> + * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
> + *
> + * %GFP_ATOMIC - Allocation will not sleep.  May use emergency pools.
> + *   For example, use this inside interrupt handlers.
> + *
> + * %GFP_HIGHUSER - Allocate pages from high memory.
> + *
> + * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
> + *
> + * %GFP_NOFS - Do not make any fs calls while trying to get memory.
> + *
> + * %GFP_NOWAIT - Allocation will not sleep.
> + *
> + * %GFP_THISNODE - Allocate node-local memory only.
> + *
> + * %GFP_DMA - Allocation suitable for DMA.
> + *   Should only be used for kmalloc() caches. Otherwise, use a
> + *   slab created with SLAB_DMA.
> + *
> + * Also it is possible to set different flags by OR'ing
> + * in one or more of the following additional @flags:
> + *
> + * %__GFP_COLD - Request cache-cold pages instead of
> + *   trying to return cache-warm pages.
> + *
> + * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
> + *
> + * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
> + *   (think twice before using).
> + *
> + * %__GFP_NORETRY - If memory is not immediately available,
> + *   then give up at once.
> + *
> + * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
> + *
> + * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
> + *
> + * There are other flags available as well, but these are not intended
> + * for general use, and so are not documented here. For a full list of
> + * potential flags, always refer to linux/gfp.h.
>   *
>   * kmalloc is the normal method of allocating memory
>   * for objects smaller than page size in the kernel.
> @@ -495,61 +540,6 @@ int cache_show(struct kmem_cache *s, struct seq_file *m);
>  void print_slabinfo_header(struct seq_file *m);
> 
>  /**
> - * kmalloc - allocate memory
> - * @size: how many bytes of memory are required.
> - * @flags: the type of memory to allocate.
> - *
> - * The @flags argument may be one of:
> - *
> - * %GFP_USER - Allocate memory on behalf of user.  May sleep.
> - *
> - * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
> - *
> - * %GFP_ATOMIC - Allocation will not sleep.  May use emergency pools.
> - *   For example, use this inside interrupt handlers.
> - *
> - * %GFP_HIGHUSER - Allocate pages from high memory.
> - *
> - * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
> - *
> - * %GFP_NOFS - Do not make any fs calls while trying to get memory.
> - *
> - * %GFP_NOWAIT - Allocation will not sleep.
> - *
> - * %GFP_THISNODE - Allocate node-local memory only.
> - *
> - * %GFP_DMA - Allocation suitable for DMA.
> - *   Should only be used for kmalloc() caches. Otherwise, use a
> - *   slab created with SLAB_DMA.
> - *
> - * Also it is possible to set different flags by OR'ing
> - * in one or more of the following additional @flags:
> - *
> - * %__GFP_COLD - Request cache-cold pages instead of
> - *   trying to return cache-warm pages.
> - *
> - * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
> - *
> - * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
> - *   (think twice before using).
> - *
> - * %__GFP_NORETRY - If memory is not immediately available,
> - *   then give up at once.
> - *
> - * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
> - *
> - * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
> - *
> - * There are other flags available as well, but these are not intended
> - * for general use, and so are not documented here. For a full list of
> - * potential flags, always refer to linux/gfp.h.
> - *
> - * kmalloc is the normal method of allocating memory
> - * in the kernel.
> - */
> -static __always_inline void *kmalloc(size_t size, gfp_t flags);
> -
> -/**
>   * kmalloc_array - allocate memory for an array.
>   * @n: number of elements.
>   * @size: element size.
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
