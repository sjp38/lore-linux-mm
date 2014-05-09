Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id A2FCB6B0143
	for <linux-mm@kvack.org>; Thu,  8 May 2014 23:33:49 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id j17so4215577oag.15
        for <linux-mm@kvack.org>; Thu, 08 May 2014 20:33:49 -0700 (PDT)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id tg2si356614obc.30.2014.05.08.20.33.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 20:33:49 -0700 (PDT)
Received: by mail-ob0-f175.google.com with SMTP id wo20so4145045obc.34
        for <linux-mm@kvack.org>; Thu, 08 May 2014 20:33:49 -0700 (PDT)
Date: Thu, 8 May 2014 22:33:46 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 2/4] mm/zbud: change zbud_alloc size type to size_t
Message-ID: <20140509033346.GB2274@cerebellum.variantweb.net>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
 <1399499496-3216-1-git-send-email-ddstreet@ieee.org>
 <1399499496-3216-3-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399499496-3216-3-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, May 07, 2014 at 05:51:34PM -0400, Dan Streetman wrote:
> Change the type of the zbud_alloc() size param from unsigned int
> to size_t.
> 
> Technically, this should not make any difference, as the zbud
> implementation already restricts the size to well within either
> type's limits; but as zsmalloc (and kmalloc) use size_t, and
> zpool will use size_t, this brings the size parameter type
> in line with zsmalloc/zpool.

Acked-by: Seth Jennings <sjennings@variantweb.net>

> 
> Signed-off-by: Dan Streetman <ddstreet@ieee.org>
> Cc: Seth Jennings <sjennings@variantweb.net>
> Cc: Weijie Yang <weijie.yang@samsung.com>
> ---
> 
> While the rest of the patches in this set are v2, this is new for
> the set; previously a patch to implement zsmalloc shrinking was
> here, but that's removed.  This patch instead changes the
> zbud_alloc() size parameter type from unsigned int to size_t, to
> be the same as the zsmalloc and zpool size param type.
> 
>  include/linux/zbud.h | 2 +-
>  mm/zbud.c            | 5 ++---
>  2 files changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/zbud.h b/include/linux/zbud.h
> index 0b2534e..1e9cb57 100644
> --- a/include/linux/zbud.h
> +++ b/include/linux/zbud.h
> @@ -11,7 +11,7 @@ struct zbud_ops {
>  
>  struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
>  void zbud_destroy_pool(struct zbud_pool *pool);
> -int zbud_alloc(struct zbud_pool *pool, unsigned int size,
> +int zbud_alloc(struct zbud_pool *pool, size_t size,
>  	unsigned long *handle);
>  void zbud_free(struct zbud_pool *pool, unsigned long handle);
>  int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
> diff --git a/mm/zbud.c b/mm/zbud.c
> index 847c01c..dd13665 100644
> --- a/mm/zbud.c
> +++ b/mm/zbud.c
> @@ -123,7 +123,7 @@ enum buddy {
>  };
>  
>  /* Converts an allocation size in bytes to size in zbud chunks */
> -static int size_to_chunks(int size)
> +static int size_to_chunks(size_t size)
>  {
>  	return (size + CHUNK_SIZE - 1) >> CHUNK_SHIFT;
>  }
> @@ -250,8 +250,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
>   * -EINVAL if the @size is 0, or -ENOMEM if the pool was unable to
>   * allocate a new page.
>   */
> -int zbud_alloc(struct zbud_pool *pool, unsigned int size,
> -			unsigned long *handle)
> +int zbud_alloc(struct zbud_pool *pool, size_t size, unsigned long *handle)
>  {
>  	int chunks, i, freechunks;
>  	struct zbud_header *zhdr = NULL;
> -- 
> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
