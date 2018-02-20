Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 154826B0007
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 20:24:37 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id q5so7030969pll.17
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 17:24:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor171863pff.140.2018.02.19.17.24.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Feb 2018 17:24:35 -0800 (PST)
Date: Tue, 20 Feb 2018 10:24:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv3 1/2] zsmalloc: introduce zs_huge_object() function
Message-ID: <20180220012429.GA186771@rodete-desktop-imager.corp.google.com>
References: <20180210082321.17798-1-sergey.senozhatsky@gmail.com>
 <20180214055747.8420-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214055747.8420-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi Sergey,

On Wed, Feb 14, 2018 at 02:57:47PM +0900, Sergey Senozhatsky wrote:
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
>  mm/zsmalloc.c            | 26 ++++++++++++++++++++++++++
>  2 files changed, 28 insertions(+)
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
> index c3013505c305..e43fc6ebb8e1 100644
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
> @@ -1417,6 +1418,28 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
>  }
>  EXPORT_SYMBOL_GPL(zs_unmap_object);
>  
> +/**
> + * zs_huge_object() - Test if a compressed object's size is too big for normal
> + *                    zspool classes and it should be stored in a huge class.
> + * @sz: Size of the compressed object (in bytes).
> + *
> + * The function checks if the object's size falls into huge_class
> + * area. We must take handle size into account and test the actual
> + * size we are going to use, because zs_malloc() unconditionally
> + * adds %ZS_HANDLE_SIZE before it performs &size_class lookup.
> + *
> + * Context: Any context.
> + *
> + * Return:
> + * * true  - The object is too big, it will be stored in the huge class.
> + * * false - The object will be stored in a normal zspool class.
> + */
> +bool zs_huge_object(size_t sz)
> +{
> +	return sz + ZS_HANDLE_SIZE >= zs_huge_class_size;
> +}
> +EXPORT_SYMBOL_GPL(zs_huge_object);
> +
>  static unsigned long obj_malloc(struct size_class *class,
>  				struct zspage *zspage, unsigned long handle)
>  {
> @@ -2404,6 +2427,9 @@ struct zs_pool *zs_create_pool(const char *name)
>  			INIT_LIST_HEAD(&class->fullness_list[fullness]);
>  
>  		prev_class = class;
> +		if (pages_per_zspage == 1 && objs_per_zspage == 1
> +				&& !zs_huge_class_size)
> +			zs_huge_class_size = size;
>  	}

Sorry for the long delay. I was horribly busy for a few weeks. ;-(

1.
I didn't see your next patch but I bet it is thing to apply this new API to zram.
Normally, it's hard to review without callsite in same patch because sometime
we need to know context where the API is used. In my understanding, if we judge
new API is really complex to get review from others, then, introducing new API
function without callsite is justified enough. In this case, I think it's simple
enough. :)

2. 

Can't zram ask to zsmalloc about what size is for hugeobject from?
With that, zram can save the wartermark in itself and use it.
What I mean is as follows,

zram:
	size_t huge_size = _zs_huge_object(pool);
	..
	..
	if (comp_size >= huge_size)
		memcpy(dst, src, 4K);
	

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
