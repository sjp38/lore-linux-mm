Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6ABB36B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 10:58:47 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so31135673pdn.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 07:58:47 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id e6si4062507pdl.90.2015.03.25.07.58.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 07:58:46 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so30935324pdb.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 07:58:46 -0700 (PDT)
Date: Wed, 25 Mar 2015 23:58:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: remove unnecessary insertion/removal of zspage
 in compaction
Message-ID: <20150325145838.GC3814@blaptop>
References: <1425859840-29652-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425859840-29652-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Marchand <jmarchan@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Luigi Semenzato <semenzato@google.com>, Gunho Lee <gunho.lee@lge.com>, Juneho Choi <juno.choi@lge.com>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I was missing mailing lists.
Ping again with correction.

On Mon, Mar 09, 2015 at 09:10:40AM +0900, Minchan Kim wrote:
> In putback_zspage, we don't need to insert a zspage into list of zspage
> in size_class again to just fix fullness group. We could do directly
> without reinsertion so we could save some instuctions.
> 
> Reported-by: Heesub Shin <heesub.shin@samsung.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/zsmalloc.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 71e4ef496918..e73a78cd340a 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1707,14 +1707,14 @@ static struct page *alloc_target_page(struct size_class *class)
>  static void putback_zspage(struct zs_pool *pool, struct size_class *class,
>  				struct page *first_page)
>  {
> -	int class_idx;
>  	enum fullness_group fullness;
>  
>  	BUG_ON(!is_first_page(first_page));
>  
> -	get_zspage_mapping(first_page, &class_idx, &fullness);
> +	fullness = get_fullness_group(first_page);
>  	insert_zspage(first_page, class, fullness);
> -	fullness = fix_fullness_group(class, first_page);
> +	set_zspage_mapping(first_page, class->index, fullness);
> +
>  	if (fullness == ZS_EMPTY) {
>  		zs_stat_dec(class, OBJ_ALLOCATED, get_maxobj_per_zspage(
>  			class->size, class->pages_per_zspage));
> -- 
> 1.9.1
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
