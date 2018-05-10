Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E89D76B05A6
	for <linux-mm@kvack.org>; Wed,  9 May 2018 21:18:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f6-v6so158747pgs.13
        for <linux-mm@kvack.org>; Wed, 09 May 2018 18:18:02 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id u10-v6si21918180pgv.650.2018.05.09.18.18.00
        for <linux-mm@kvack.org>;
        Wed, 09 May 2018 18:18:01 -0700 (PDT)
Date: Thu, 10 May 2018 11:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 11/33] iomap: add an iomap-based readpage and readpages
 implementation
Message-ID: <20180510011758.GR10363@dastard>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509074830.16196-12-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 09:48:08AM +0200, Christoph Hellwig wrote:
> Simply use iomap_apply to iterate over the file and a submit a bio for
> each non-uptodate but mapped region and zero everything else.  Note that
> as-is this can not be used for file systems with a blocksize smaller than
> the page size, but that support will be added later.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
.....
> +int
> +iomap_readpages(struct address_space *mapping, struct list_head *pages,
> +		unsigned nr_pages, const struct iomap_ops *ops)
> +{
> +	struct iomap_readpage_ctx ctx = { .pages = pages };
> +	loff_t pos = page_offset(list_entry(pages->prev, struct page, lru));
> +	loff_t last = page_offset(list_entry(pages->next, struct page, lru));
> +	loff_t length = last - pos + PAGE_SIZE, ret = 0;
> +
> +	while (length > 0) {
> +		ret = iomap_apply(mapping->host, pos, length, 0, ops,
> +				&ctx, iomap_readpages_actor);
> +		if (ret <= 0)
> +			break;
> +		pos += ret;
> +		length -= ret;
> +	}
> +
> +	ret = 0;

This means the function will always return zero, regardless of
whether iomap_apply returned an error or not.

> +	if (ctx.bio)
> +		submit_bio(ctx.bio);
> +	if (ctx.cur_page) {
> +		if (!ctx.cur_page_in_bio)
> +			unlock_page(ctx.cur_page);
> +		put_page(ctx.cur_page);
> +	}
> +	WARN_ON_ONCE(ret && !list_empty(ctx.pages));

And this warning will never trigger. Was this intended behaviour?
If it is, it needs a comment, because it looks wrong....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
