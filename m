Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF3F06B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 21:24:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 1so39456779pfi.14
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 18:24:38 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d20si5197210plj.429.2017.06.29.18.24.37
        for <linux-mm@kvack.org>;
        Thu, 29 Jun 2017 18:24:38 -0700 (PDT)
Date: Fri, 30 Jun 2017 10:24:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: simplify zs_max_alloc_size handling
Message-ID: <20170630012436.GA24520@bbox>
References: <20170628081420.26898-1-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170628081420.26898-1-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Mahendran Ganesh <opensource.ganesh@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Jerome,

On Wed, Jun 28, 2017 at 10:14:20AM +0200, Jerome Marchand wrote:
> Commit 40f9fb8cffc6 ("mm/zsmalloc: support allocating obj with size of
> ZS_MAX_ALLOC_SIZE") fixes a size calculation error that prevented
> zsmalloc to allocate an object of the maximal size
> (ZS_MAX_ALLOC_SIZE). I think however the fix is unneededly
> complicated.
> 
> This patch replaces the dynamic calculation of zs_size_classes at init
> time by a compile time calculation that uses the DIV_ROUND_UP() macro
> already used in get_size_class_index().
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> ---
>  mm/zsmalloc.c | 52 +++++++++++++++-------------------------------------
>  1 file changed, 15 insertions(+), 37 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index d41edd2..134024b 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -116,6 +116,11 @@
>  #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
>  #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
>  
> +#define FULLNESS_BITS	2
> +#define CLASS_BITS	8
> +#define ISOLATED_BITS	3
> +#define MAGIC_VAL_BITS	8
> +
>  #define MAX(a, b) ((a) >= (b) ? (a) : (b))
>  /* ZS_MIN_ALLOC_SIZE must be multiple of ZS_ALIGN */
>  #define ZS_MIN_ALLOC_SIZE \
> @@ -137,6 +142,8 @@
>   *  (reason above)
>   */
>  #define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_BITS)
> +#define ZS_SIZE_CLASSES	DIV_ROUND_UP(ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE, \
> +				     ZS_SIZE_CLASS_DELTA)

#define ZS_SIZE_CLASSES	(DIV_ROUND_UP(ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE, \
				     ZS_SIZE_CLASS_DELTA) + 1)


I think it should add +1 to cover ZS_MIN_ALLOC_SIZE.
Otherwise, looks good to me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
