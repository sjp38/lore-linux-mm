Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 312866B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 19:46:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o19-v6so2536945pgn.14
        for <linux-mm@kvack.org>; Wed, 30 May 2018 16:46:02 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id e4-v6si35453273pln.331.2018.05.30.16.45.59
        for <linux-mm@kvack.org>;
        Wed, 30 May 2018 16:46:00 -0700 (PDT)
Date: Thu, 31 May 2018 09:45:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 11/13] iomap: add an iomap-based readpage and readpages
 implementation
Message-ID: <20180530234557.GI10363@dastard>
References: <20180530095813.31245-1-hch@lst.de>
 <20180530095813.31245-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530095813.31245-12-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:58:11AM +0200, Christoph Hellwig wrote:
> Simply use iomap_apply to iterate over the file and a submit a bio for
> each non-uptodate but mapped region and zero everything else.  Note that
> as-is this can not be used for file systems with a blocksize smaller than
> the page size, but that support will be added later.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/iomap.c            | 203 +++++++++++++++++++++++++++++++++++++++++-
>  include/linux/iomap.h |   4 +
>  2 files changed, 206 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index b0bc928672af..5e5a266e3325 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -1,6 +1,6 @@
>  /*
>   * Copyright (C) 2010 Red Hat, Inc.
> - * Copyright (c) 2016 Christoph Hellwig.
> + * Copyright (c) 2016-2018 Christoph Hellwig.
>   *
>   * This program is free software; you can redistribute it and/or modify it
>   * under the terms and conditions of the GNU General Public License,
> @@ -18,6 +18,7 @@
>  #include <linux/uaccess.h>
>  #include <linux/gfp.h>
>  #include <linux/mm.h>
> +#include <linux/mm_inline.h>
>  #include <linux/swap.h>
>  #include <linux/pagemap.h>
>  #include <linux/file.h>
> @@ -102,6 +103,206 @@ iomap_sector(struct iomap *iomap, loff_t pos)
>  	return (iomap->addr + pos - iomap->offset) >> SECTOR_SHIFT;
>  }
>  
> +static void
> +iomap_read_end_io(struct bio *bio)
> +{
> +	int error = blk_status_to_errno(bio->bi_status);
> +	struct bio_vec *bvec;
> +	int i;
> +
> +	bio_for_each_segment_all(bvec, bio, i)
> +		page_endio(bvec->bv_page, false, error);
> +	bio_put(bio);
> +}
> +
> +struct iomap_readpage_ctx {
> +	struct page		*cur_page;
> +	bool			cur_page_in_bio;
> +	bool			is_readahead;
> +	struct bio		*bio;
> +	struct list_head	*pages;
> +};
> +
> +static loff_t
> +iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
> +		struct iomap *iomap)
> +{
> +	struct iomap_readpage_ctx *ctx = data;
> +	struct page *page = ctx->cur_page;
> +	unsigned poff = pos & (PAGE_SIZE - 1);
> +	unsigned plen = min_t(loff_t, PAGE_SIZE - poff, length);
> +	bool is_contig = false;
> +	sector_t sector;
> +
> +	/* we don't support blocksize < PAGE_SIZE quite yet: */

sentence ends with a ".". :)

> +	WARN_ON_ONCE(pos != page_offset(page));
> +	WARN_ON_ONCE(plen != PAGE_SIZE);
> +
> +	if (iomap->type != IOMAP_MAPPED || pos >= i_size_read(inode)) {

In what situation do we get a read request completely beyond EOF?
(comment, please!)

> +		zero_user(page, poff, plen);
> +		SetPageUptodate(page);
> +		goto done;
> +	}

[...]

> +int
> +iomap_readpage(struct page *page, const struct iomap_ops *ops)
> +{
> +	struct iomap_readpage_ctx ctx = { .cur_page = page };
> +	struct inode *inode = page->mapping->host;
> +	unsigned poff;
> +	loff_t ret;
> +
> +	WARN_ON_ONCE(page_has_buffers(page));
> +
> +	for (poff = 0; poff < PAGE_SIZE; poff += ret) {
> +		ret = iomap_apply(inode, page_offset(page) + poff,
> +				PAGE_SIZE - poff, 0, ops, &ctx,
> +				iomap_readpage_actor);
> +		if (ret <= 0) {
> +			WARN_ON_ONCE(ret == 0);
> +			SetPageError(page);
> +			break;
> +		}
> +	}
> +
> +	if (ctx.bio) {
> +		submit_bio(ctx.bio);
> +		WARN_ON_ONCE(!ctx.cur_page_in_bio);
> +	} else {
> +		WARN_ON_ONCE(ctx.cur_page_in_bio);
> +		unlock_page(page);
> +	}
> +	return 0;

Hmmm. If we had an error from iomap_apply, shouldn't we be returning
it here instead just throwing it away? some ->readpage callers
appear to ignore the PageError() state on return but do expect
errors to be returned.

[...]

> +iomap_readpages(struct address_space *mapping, struct list_head *pages,
> +		unsigned nr_pages, const struct iomap_ops *ops)
> +{
> +	struct iomap_readpage_ctx ctx = {
> +		.pages		= pages,
> +		.is_readahead	= true,
> +	};
> +	loff_t pos = page_offset(list_entry(pages->prev, struct page, lru));
> +	loff_t last = page_offset(list_entry(pages->next, struct page, lru));
> +	loff_t length = last - pos + PAGE_SIZE, ret = 0;

Two lines, please.

> +	while (length > 0) {
> +		ret = iomap_apply(mapping->host, pos, length, 0, ops,
> +				&ctx, iomap_readpages_actor);
> +		if (ret <= 0) {
> +			WARN_ON_ONCE(ret == 0);
> +			goto done;
> +		}
> +		pos += ret;
> +		length -= ret;
> +	}
> +	ret = 0;
> +done:
> +	if (ctx.bio)
> +		submit_bio(ctx.bio);
> +	if (ctx.cur_page) {
> +		if (!ctx.cur_page_in_bio)
> +			unlock_page(ctx.cur_page);
> +		put_page(ctx.cur_page);
> +	}
> +	WARN_ON_ONCE(!ret && !list_empty(ctx.pages));

What error condition is this warning about?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
