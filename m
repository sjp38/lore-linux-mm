Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A8B216B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 01:46:08 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k21-v6so14718211ioj.19
        for <linux-mm@kvack.org>; Tue, 29 May 2018 22:46:08 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 5-v6si14203270itj.69.2018.05.29.22.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 22:46:07 -0700 (PDT)
Date: Tue, 29 May 2018 22:46:04 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 08/34] mm: split ->readpages calls to avoid
 non-contiguous pages lists
Message-ID: <20180530054604.GW30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-9-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:31PM +0200, Christoph Hellwig wrote:
> That way file systems don't have to go spotting for non-contiguous pages
> and work around them.  It also kicks off I/O earlier, allowing it to
> finish earlier and reduce latency.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok, if anyone has a strong opinion they better yell soon...
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  mm/readahead.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index fa4d4b767130..e273f0de3376 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -140,8 +140,8 @@ static int read_pages(struct address_space *mapping, struct file *filp,
>  }
>  
>  /*
> - * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates all
> - * the pages first, then submits them all for I/O. This avoids the very bad
> + * __do_page_cache_readahead() actually reads a chunk of disk.  It allocates
> + * the pages first, then submits them for I/O. This avoids the very bad
>   * behaviour which would occur if page allocations are causing VM writeback.
>   * We really don't want to intermingle reads and writes like that.
>   *
> @@ -177,8 +177,18 @@ unsigned int __do_page_cache_readahead(struct address_space *mapping,
>  		rcu_read_lock();
>  		page = radix_tree_lookup(&mapping->i_pages, page_offset);
>  		rcu_read_unlock();
> -		if (page && !radix_tree_exceptional_entry(page))
> +		if (page && !radix_tree_exceptional_entry(page)) {
> +			/*
> +			 * Page already present?  Kick off the current batch of
> +			 * contiguous pages before continuing with the next
> +			 * batch.
> +			 */
> +			if (nr_pages)
> +				read_pages(mapping, filp, &page_pool, nr_pages,
> +						gfp_mask);
> +			nr_pages = 0;
>  			continue;
> +		}
>  
>  		page = __page_cache_alloc(gfp_mask);
>  		if (!page)
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
