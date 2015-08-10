Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 98ABD6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:53:18 -0400 (EDT)
Received: by pawu10 with SMTP id u10so135936246paw.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:53:18 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id fp10si7013037pac.199.2015.08.10.01.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 01:53:17 -0700 (PDT)
Received: by pdrh1 with SMTP id h1so51218765pdr.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 01:53:17 -0700 (PDT)
Date: Mon, 10 Aug 2015 17:53:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC zsmalloc 2/4] zsmalloc: squeeze inuse into page->mapping
Message-ID: <20150810085302.GB600@swordfish>
References: <1439190743-13933-1-git-send-email-minchan@kernel.org>
 <1439190743-13933-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439190743-13933-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, gioh.kim@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (08/10/15 16:12), Minchan Kim wrote:
[..]
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 491491a..75fefba 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -35,7 +35,7 @@
>   *		metadata.
>   *	page->lru: links together first pages of various zspages.
>   *		Basically forming list of zspages in a fullness group.
> - *	page->mapping: class index and fullness group of the zspage
> + *	page->mapping: override by struct zs_meta
>   *
>   * Usage of struct page flags:
>   *	PG_private: identifies the first component page
> @@ -132,6 +132,14 @@
>  /* each chunk includes extra space to keep handle */
>  #define ZS_MAX_ALLOC_SIZE	PAGE_SIZE
>  
> +#define CLASS_IDX_BITS	8
> +#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
> +#define FULLNESS_BITS	2
> +#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
> +#define INUSE_BITS	11
> +#define INUSE_MASK	((1 << INUSE_BITS) - 1)
> +#define ETC_BITS	((sizeof(unsigned long) * 8) - CLASS_IDX_BITS \
> +				- FULLNESS_BITS - INUSE_BITS)
>  /*
>   * On systems with 4K page size, this gives 255 size classes! There is a
>   * trader-off here:
> @@ -145,16 +153,15 @@
>   *  ZS_MIN_ALLOC_SIZE and ZS_SIZE_CLASS_DELTA must be multiple of ZS_ALIGN
>   *  (reason above)
>   */
> -#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> 8)
> +#define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_IDX_BITS)
>  
>  /*
>   * We do not maintain any list for completely empty or full pages
> + * Don't reorder.
>   */
>  enum fullness_group {
> -	ZS_ALMOST_FULL,
> +	ZS_ALMOST_FULL = 0,
>  	ZS_ALMOST_EMPTY,
> -	_ZS_NR_FULLNESS_GROUPS,
> -
>  	ZS_EMPTY,
>  	ZS_FULL
>  };
> @@ -198,7 +205,7 @@ static const int fullness_threshold_frac = 4;
>  
>  struct size_class {
>  	spinlock_t lock;
> -	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
> +	struct page *fullness_list[ZS_EMPTY];
>  	/*
>  	 * Size of objects stored in this class. Must be multiple
>  	 * of ZS_ALIGN.
> @@ -259,13 +266,16 @@ struct zs_pool {
>  };
>  
>  /*
> - * A zspage's class index and fullness group
> - * are encoded in its (first)page->mapping
> + * In this implementation, a zspage's class index, fullness group,
> + * inuse object count are encoded in its (first)page->mapping
> + * sizeof(struct zs_meta) should be equal to sizeof(unsigned long).
>   */
> -#define CLASS_IDX_BITS	28
> -#define FULLNESS_BITS	4
> -#define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
> -#define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
> +struct zs_meta {
> +	unsigned long class_idx:CLASS_IDX_BITS;
> +	unsigned long fullness:FULLNESS_BITS;
> +	unsigned long inuse:INUSE_BITS;
> +	unsigned long etc:ETC_BITS;
> +};
>  
>  struct mapping_area {
>  #ifdef CONFIG_PGTABLE_MAPPING
> @@ -403,26 +413,51 @@ static int is_last_page(struct page *page)
>  	return PagePrivate2(page);
>  }
>  
> +static int get_inuse_obj(struct page *page)
> +{
> +	struct zs_meta *m;
> +
> +	BUG_ON(!is_first_page(page));
> +
> +	m = (struct zs_meta *)&page->mapping;
> +
> +	return m->inuse;
> +}

a side note. I think there are too many BUG_ON in zsmalloc. some of
them are clearly unnecessary, just because same checks are performed
several lines above. for example:

get_fullness_group()
	BUG_ON(!is_first_page(page))
	get_inuse_obj()
		BUG_ON(!is_first_page(page))


fix_fullness_group()
	BUG_ON(!is_first_page(page))
	get_zspage_mapping()
		BUG_ON(!is_first_page(page))


and so on.


> +static void set_inuse_obj(struct page *page, int inc)
> +{
> +	struct zs_meta *m;
> +
> +	BUG_ON(!is_first_page(page));
> +
> +	m = (struct zs_meta *)&page->mapping;
> +	m->inuse += inc;
> +}
> +

{get,set}_zspage_inuse() ?


[..]

> +	BUILD_BUG_ON(sizeof(unsigned long) * 8 < (CLASS_IDX_BITS + \
> +			FULLNESS_BITS + INUSE_BITS + ETC_BITS));

this build_bug is overwritten in the next patch?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
