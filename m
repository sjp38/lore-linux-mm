Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 774906B0257
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:35:32 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id u188so61926417wmu.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 03:35:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id in5si25103455wjb.155.2016.01.25.03.35.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 03:35:31 -0800 (PST)
Date: Mon, 25 Jan 2016 12:35:44 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: filemap: Remove redundant code in
 do_read_cache_page
Message-ID: <20160125113544.GF20933@quack.suse.cz>
References: <1453716204-20409-1-git-send-email-mgorman@techsingularity.net>
 <1453716204-20409-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453716204-20409-2-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 25-01-16 10:03:23, Mel Gorman wrote:
> do_read_cache_page and __read_cache_page duplicates page filler code
> when filling the page for the first time. This patch simply removes the
> duplicate logic.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 43 ++++++++++++-------------------------------
>  1 file changed, 12 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index bc943867d68c..aa38593d0cd5 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2283,7 +2283,7 @@ static struct page *wait_on_page_read(struct page *page)
>  	return page;
>  }
>  
> -static struct page *__read_cache_page(struct address_space *mapping,
> +static struct page *do_read_cache_page(struct address_space *mapping,
>  				pgoff_t index,
>  				int (*filler)(void *, struct page *),
>  				void *data,
> @@ -2305,31 +2305,19 @@ static struct page *__read_cache_page(struct address_space *mapping,
>  			/* Presumably ENOMEM for radix tree node */
>  			return ERR_PTR(err);
>  		}
> +
> +filler:
>  		err = filler(data, page);
>  		if (err < 0) {
>  			page_cache_release(page);
> -			page = ERR_PTR(err);
> -		} else {
> -			page = wait_on_page_read(page);
> +			return ERR_PTR(err);
>  		}
> -	}
> -	return page;
> -}
> -
> -static struct page *do_read_cache_page(struct address_space *mapping,
> -				pgoff_t index,
> -				int (*filler)(void *, struct page *),
> -				void *data,
> -				gfp_t gfp)
> -
> -{
> -	struct page *page;
> -	int err;
>  
> -retry:
> -	page = __read_cache_page(mapping, index, filler, data, gfp);
> -	if (IS_ERR(page))
> -		return page;
> +		page = wait_on_page_read(page);
> +		if (IS_ERR(page))
> +			return page;
> +		goto out;
> +	}
>  	if (PageUptodate(page))
>  		goto out;
>  
> @@ -2337,21 +2325,14 @@ static struct page *do_read_cache_page(struct address_space *mapping,
>  	if (!page->mapping) {
>  		unlock_page(page);
>  		page_cache_release(page);
> -		goto retry;
> +		goto repeat;
>  	}
>  	if (PageUptodate(page)) {
>  		unlock_page(page);
>  		goto out;
>  	}
> -	err = filler(data, page);
> -	if (err < 0) {
> -		page_cache_release(page);
> -		return ERR_PTR(err);
> -	} else {
> -		page = wait_on_page_read(page);
> -		if (IS_ERR(page))
> -			return page;
> -	}
> +	goto filler;
> +
>  out:
>  	mark_page_accessed(page);
>  	return page;
> -- 
> 2.6.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
