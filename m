Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9526B006E
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:19:17 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so12723976pab.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:19:17 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id hg5si1407108pac.34.2015.06.16.06.19.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 06:19:15 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so14390303pdb.1
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:19:15 -0700 (PDT)
Date: Tue, 16 Jun 2015 22:19:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv2 2/8] zsmalloc: partial page ordering within a
 fullness_list
Message-ID: <20150616131903.GA31387@blaptop>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433505838-23058-3-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433505838-23058-3-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello Sergey,

On Fri, Jun 05, 2015 at 09:03:52PM +0900, Sergey Senozhatsky wrote:
> We want to see more ZS_FULL pages and less ZS_ALMOST_{FULL, EMPTY}
> pages. Put a page with higher ->inuse count first within its
> ->fullness_list, which will give us better chances to fill up this
> page with new objects (find_get_zspage() return ->fullness_list head
> for new object allocation), so some zspages will become
> ZS_ALMOST_FULL/ZS_FULL quicker.
> 
> It performs a trivial and cheap ->inuse compare which does not slow
> down zsmalloc, and in the worst case it keeps the list pages not in
> any particular order, just like we do it now.

Fair enough.

I think it would be better with small cost and it matches current
zsmalloc design which allocates a object from ALMOST_FULL zspage
first to reduce memory footprint.

Although we uses page->lru to link zspages, it's not lru order
so I like your idea.

One think I want to say is it doesn't need to be part of this patchset.
I hope you gives some data to prove gain and includes it in changelog
and resubmit, please.

> 
> A more expensive solution could sort fullness_list by ->inuse count.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  mm/zsmalloc.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index ce3310c..cd37bda 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -658,8 +658,16 @@ static void insert_zspage(struct page *page, struct size_class *class,
>  		return;
>  
>  	head = &class->fullness_list[fullness];
> -	if (*head)
> -		list_add_tail(&page->lru, &(*head)->lru);
> +	if (*head) {
> +		/*
> +		 * We want to see more ZS_FULL pages and less almost
> +		 * empty/full. Put pages with higher ->inuse first.
> +		 */
> +		if (page->inuse < (*head)->inuse)
> +			list_add_tail(&page->lru, &(*head)->lru);
> +		else
> +			list_add(&page->lru, &(*head)->lru);
> +	}
>  
>  	*head = page;
>  	zs_stat_inc(class, fullness == ZS_ALMOST_EMPTY ?
> -- 
> 2.4.2.387.gf86f31a
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
