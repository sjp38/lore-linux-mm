Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 571FE6B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 01:43:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c8-v6so15092928qth.21
        for <linux-mm@kvack.org>; Tue, 29 May 2018 22:43:00 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i9-v6si562178qtb.306.2018.05.29.22.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 22:42:59 -0700 (PDT)
Date: Tue, 29 May 2018 22:42:48 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 06/34] mm: give the 'ret' variable a better name
 __do_page_cache_readahead
Message-ID: <20180530054248.GU30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-7-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:29PM +0200, Christoph Hellwig wrote:
> It counts the number of pages acted on, so name it nr_pages to make that
> obvious.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok, so long as the mm folks don't have any strong opinions...
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  mm/readahead.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 539bbb6c1fad..16d0cb1e2616 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -156,7 +156,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	unsigned long end_index;	/* The last page we want to read */
>  	LIST_HEAD(page_pool);
>  	int page_idx;
> -	int ret = 0;
> +	int nr_pages = 0;
>  	loff_t isize = i_size_read(inode);
>  	gfp_t gfp_mask = readahead_gfp_mask(mapping);
>  
> @@ -187,7 +187,7 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  		list_add(&page->lru, &page_pool);
>  		if (page_idx == nr_to_read - lookahead_size)
>  			SetPageReadahead(page);
> -		ret++;
> +		nr_pages++;
>  	}
>  
>  	/*
> @@ -195,11 +195,11 @@ int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	 * uptodate then the caller will launch readpage again, and
>  	 * will then handle the error.
>  	 */
> -	if (ret)
> -		read_pages(mapping, filp, &page_pool, ret, gfp_mask);
> +	if (nr_pages)
> +		read_pages(mapping, filp, &page_pool, nr_pages, gfp_mask);
>  	BUG_ON(!list_empty(&page_pool));
>  out:
> -	return ret;
> +	return nr_pages;
>  }
>  
>  /*
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
