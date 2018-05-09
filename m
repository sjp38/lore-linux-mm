Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F35676B052C
	for <linux-mm@kvack.org>; Wed,  9 May 2018 11:45:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y12so18198354pfe.8
        for <linux-mm@kvack.org>; Wed, 09 May 2018 08:45:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v5-v6si14598678pgq.227.2018.05.09.08.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 08:45:04 -0700 (PDT)
Date: Wed, 9 May 2018 08:45:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 06/33] mm: give the 'ret' variable a better name
 __do_page_cache_readahead
Message-ID: <20180509154501.GD1313@bombadil.infradead.org>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509074830.16196-7-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 09:48:03AM +0200, Christoph Hellwig wrote:
> It counts the number of pages acted on, so name it nr_pages to make that
> obvious.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Yes!

Also, it can't return an error, so how about changing it to unsigned int?
And deleting the error check from the caller?

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
