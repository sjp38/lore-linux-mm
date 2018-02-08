Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F408D6B0006
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 11:30:17 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id b67so4109935qkh.5
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 08:30:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g25si334189qtf.281.2018.02.08.08.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 08:30:14 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w18GOuda102821
	for <linux-mm@kvack.org>; Thu, 8 Feb 2018 11:30:14 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2g0rhv5fth-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Feb 2018 11:30:13 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 8 Feb 2018 16:30:12 -0000
Date: Thu, 8 Feb 2018 18:30:07 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] zsmalloc: introduce zs_huge_object() function
References: <20180207092919.19696-1-sergey.senozhatsky@gmail.com>
 <20180207092919.19696-2-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207092919.19696-2-sergey.senozhatsky@gmail.com>
Message-Id: <20180208163006.GB17354@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Wed, Feb 07, 2018 at 06:29:18PM +0900, Sergey Senozhatsky wrote:
> Not every object can be share its zspage with other objects, e.g.
> when the object is as big as zspage or nearly as big a zspage.
> For such objects zsmalloc has a so called huge class - every object
> which belongs to huge class consumes the entire zspage (which
> consists of a physical page). On x86_64, PAGE_SHIFT 12 box, the
> first non-huge class size is 3264, so starting down from size 3264,
> objects can share page(-s) and thus minimize memory wastage.
> 
> ZRAM, however, has its own statically defined watermark for huge
> objects - "3 * PAGE_SIZE / 4 = 3072", and forcibly stores every
> object larger than this watermark (3072) as a PAGE_SIZE object,
> in other words, to a huge class, while zsmalloc can keep some of
> those objects in non-huge classes. This results in increased
> memory consumption.
> 
> zsmalloc knows better if the object is huge or not. Introduce
> zs_huge_object() function which tells if the given object can be
> stored in one of non-huge classes or not. This will let us to drop
> ZRAM's huge object watermark and fully rely on zsmalloc when we
> decide if the object is huge.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  include/linux/zsmalloc.h |  2 ++
>  mm/zsmalloc.c            | 17 +++++++++++++++++
>  2 files changed, 19 insertions(+)
> 
> diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> index 57a8e98f2708..9a1baf673cc1 100644
> --- a/include/linux/zsmalloc.h
> +++ b/include/linux/zsmalloc.h
> @@ -47,6 +47,8 @@ void zs_destroy_pool(struct zs_pool *pool);
>  unsigned long zs_malloc(struct zs_pool *pool, size_t size, gfp_t flags);
>  void zs_free(struct zs_pool *pool, unsigned long obj);
> 
> +bool zs_huge_object(size_t sz);
> +
>  void *zs_map_object(struct zs_pool *pool, unsigned long handle,
>  			enum zs_mapmode mm);
>  void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index c3013505c305..b3e295a806be 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -192,6 +192,7 @@ static struct vfsmount *zsmalloc_mnt;
>   * (see: fix_fullness_group())
>   */
>  static const int fullness_threshold_frac = 4;
> +static size_t zs_huge_class_size;
> 
>  struct size_class {
>  	spinlock_t lock;
> @@ -1417,6 +1418,19 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>  }
>  EXPORT_SYMBOL_GPL(zs_unmap_object);
> 
> +/*
> + * Check if the object's size falls into huge_class area. We must take
> + * ZS_HANDLE_SIZE into account and test the actual size we are going to
> + * use up. zs_malloc() unconditionally adds handle size before it performs
> + * size_class lookup, so we may endup in a huge class yet zs_huge_object()
> + * returned 'false'.
> + */

Can you please reformat this comment as kernel-doc?

> +bool zs_huge_object(size_t sz)
> +{
> +	return sz + ZS_HANDLE_SIZE >= zs_huge_class_size;
> +}
> +EXPORT_SYMBOL_GPL(zs_huge_object);
> +
>  static unsigned long obj_malloc(struct size_class *class,
>  				struct zspage *zspage, unsigned long handle)
>  {
> @@ -2404,6 +2418,9 @@ struct zs_pool *zs_create_pool(const char *name)
>  			INIT_LIST_HEAD(&class->fullness_list[fullness]);
> 
>  		prev_class = class;
> +		if (pages_per_zspage == 1 && objs_per_zspage == 1
> +				&& !zs_huge_class_size)
> +			zs_huge_class_size = size;
>  	}
> 
>  	/* debug only, don't abort if it fails */
> -- 
> 2.16.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
