Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id D364A6B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 10:52:29 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id n25-v6so14771040otf.13
        for <linux-mm@kvack.org>; Tue, 22 May 2018 07:52:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c9-v6si6241165otc.374.2018.05.22.07.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 07:52:28 -0700 (PDT)
Date: Tue, 22 May 2018 10:52:27 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 08/34] mm: split ->readpages calls to avoid
 non-contiguous pages lists
Message-ID: <20180522145226.GA25251@bfoster.bfoster>
References: <20180518164830.1552-1-hch@lst.de>
 <20180518164830.1552-9-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518164830.1552-9-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, May 18, 2018 at 06:48:04PM +0200, Christoph Hellwig wrote:
> That way file systems don't have to go spotting for non-contiguous pages
> and work around them.  It also kicks off I/O earlier, allowing it to
> finish earlier and reduce latency.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/readahead.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/readahead.c b/mm/readahead.c
> index fa4d4b767130..044ab0c137cc 100644
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
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

The comment at the top of this function explicitly states that we don't
submit I/Os before all of the pages are allocated. That probably needs
an update, at least.

That aside, couldn't this introduce that kind of problematic read/write
behavior if the mapping was sparsely populated for whatever reason
(every other page, for example)? Perhaps that's just too unlikely to
matter.

Brian

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
