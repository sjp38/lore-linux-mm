Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 39CB46B0074
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 08:46:11 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so14742549pab.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:46:11 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id eb1si11200113pbc.100.2015.06.18.05.46.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 05:46:10 -0700 (PDT)
Received: by padev16 with SMTP id ev16so60887259pad.0
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 05:46:10 -0700 (PDT)
Date: Thu, 18 Jun 2015 21:45:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCHv3 2/7] zsmalloc: partial page ordering within a
 fullness_list
Message-ID: <20150618124526.GA2519@swordfish>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20150618121314.GA518@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618121314.GA518@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (06/18/15 21:13), Sergey Senozhatsky wrote:
> I think it makes sense to also consider 'fullness_group fullness' in
> insert_zspage(). Unconditionally put ZS_ALMOST_FULL pages to list
> head, or (if zspage is !ZS_ALMOST_FULL) compage ->inuse.
> 
> IOW, something like this
> 
> ---
> 
>  mm/zsmalloc.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 692b7dc..d576397 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -645,10 +645,11 @@ static void insert_zspage(struct page *page, struct size_class *class,
>  		 * We want to see more ZS_FULL pages and less almost
>  		 * empty/full. Put pages with higher ->inuse first.
>  		 */
> -		if (page->inuse < (*head)->inuse)
> -			list_add_tail(&page->lru, &(*head)->lru);
> -		else
> +		if (fullness == ZS_ALMOST_FULL ||
> +				(page->inuse >= (*head)->inuse))
>  			list_add(&page->lru, &(*head)->lru);
> +		else
> +			list_add_tail(&page->lru, &(*head)->lru);
>  	}
>  
>  	*head = page;
> 


             almost_full         full almost_empty obj_allocated   obj_used pages_used

Base
 Total                 3          168           26          2324       1822        307
 Total                 3          167           29          2391       1815        314
 Total                 5          172           25          2392       1827        313

Patched
 Total                 4          180           27          2425       1835        327
 Total                 4          169           27          2405       1825        312
 Total                 2          176           28          2452       1825        315


... no chance the test is right.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
