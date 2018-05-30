Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF226B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 01:44:28 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i7-v6so5992022qtp.4
        for <linux-mm@kvack.org>; Tue, 29 May 2018 22:44:28 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i20-v6si1371324qvm.266.2018.05.29.22.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 22:44:27 -0700 (PDT)
Date: Tue, 29 May 2018 22:44:24 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 07/34] mm: return an unsigned int from
 __do_page_cache_readahead
Message-ID: <20180530054424.GV30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-8-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:30PM +0200, Christoph Hellwig wrote:
> We never return an error, so switch to returning an unsigned int.  Most
> callers already did implicit casts to an unsigned type, and the one that
> didn't can be simplified now.
> 
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok; anyone from the mm side has a strong opinion?
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  mm/internal.h  |  2 +-
>  mm/readahead.c | 15 +++++----------
>  2 files changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 62d8c34e63d5..954003ac766a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -53,7 +53,7 @@ void unmap_page_range(struct mmu_gather *tlb,
>  			     unsigned long addr, unsigned long end,
>  			     struct zap_details *details);
>  
> -extern int __do_page_cache_readahead(struct address_space *mapping,
> +extern unsigned int __do_page_cache_readahead(struct address_space *mapping,
>  		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
>  		unsigned long lookahead_size);
>  
> diff --git a/mm/readahead.c b/mm/readahead.c
> index 16d0cb1e2616..fa4d4b767130 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -147,16 +147,16 @@ static int read_pages(struct address_space *mapping, struct file *filp,
>   *
>   * Returns the number of pages requested, or the maximum amount of I/O allowed.
>   */
> -int __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
> -			pgoff_t offset, unsigned long nr_to_read,
> -			unsigned long lookahead_size)
> +unsigned int __do_page_cache_readahead(struct address_space *mapping,
> +		struct file *filp, pgoff_t offset, unsigned long nr_to_read,
> +		unsigned long lookahead_size)
>  {
>  	struct inode *inode = mapping->host;
>  	struct page *page;
>  	unsigned long end_index;	/* The last page we want to read */
>  	LIST_HEAD(page_pool);
>  	int page_idx;
> -	int nr_pages = 0;
> +	unsigned int nr_pages = 0;
>  	loff_t isize = i_size_read(inode);
>  	gfp_t gfp_mask = readahead_gfp_mask(mapping);
>  
> @@ -223,16 +223,11 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	max_pages = max_t(unsigned long, bdi->io_pages, ra->ra_pages);
>  	nr_to_read = min(nr_to_read, max_pages);
>  	while (nr_to_read) {
> -		int err;
> -
>  		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_SIZE;
>  
>  		if (this_chunk > nr_to_read)
>  			this_chunk = nr_to_read;
> -		err = __do_page_cache_readahead(mapping, filp,
> -						offset, this_chunk, 0);
> -		if (err < 0)
> -			return err;
> +		__do_page_cache_readahead(mapping, filp, offset, this_chunk, 0);
>  
>  		offset += this_chunk;
>  		nr_to_read -= this_chunk;
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
