Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 610CE6B02F3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 21:48:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t25so49445769pfg.15
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 18:48:07 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v31si1831892plg.424.2017.08.08.18.48.05
        for <linux-mm@kvack.org>;
        Tue, 08 Aug 2017 18:48:06 -0700 (PDT)
Date: Wed, 9 Aug 2017 10:48:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170809014804.GA32338@bbox>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-3-git-send-email-minchan@kernel.org>
 <20170808124959.GB31390@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808124959.GB31390@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>

Hi Matthew,

On Tue, Aug 08, 2017 at 05:49:59AM -0700, Matthew Wilcox wrote:
> On Tue, Aug 08, 2017 at 03:50:20PM +0900, Minchan Kim wrote:
> > There is no need to use dynamic bio allocation for BDI_CAP_SYNC
> > devices. They can with on-stack-bio without concern about waiting
> > bio allocation from mempool under heavy memory pressure.
> 
> This seems ... more complex than necessary?  Why not simply do this:
> 
> diff --git a/fs/mpage.c b/fs/mpage.c
> index baff8f820c29..6db6bf5131ed 100644
> --- a/fs/mpage.c
> +++ b/fs/mpage.c
> @@ -157,6 +157,8 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
>  	unsigned page_block;
>  	unsigned first_hole = blocks_per_page;
>  	struct block_device *bdev = NULL;
> +	struct bio sbio;
> +	struct bio_vec sbvec;
>  	int length;
>  	int fully_mapped = 1;
>  	unsigned nblocks;
> @@ -281,10 +283,17 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
>  								page))
>  				goto out;
>  		}
> -		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
> +		if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
> +			bio = &sbio;
> +			bio_init(bio, &sbvec, nr_pages);
> +			sbio.bi_bdev = bdev;
> +			sbio.bi_iter.bi_sector = blocks[0] << (blkbits - 9);
> +		} else {
> +			bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
>  				min_t(int, nr_pages, BIO_MAX_PAGES), gfp);
> -		if (bio == NULL)
> -			goto confused;
> +			if (bio == NULL)
> +				goto confused;
> +		}
>  	}
>  
>  	length = first_hole << blkbits;
> @@ -301,6 +310,8 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
>  	else
>  		*last_block_in_bio = blocks[blocks_per_page - 1];
>  out:
> +	if (bio == &sbio)
> +		bio = mpage_bio_submit(REQ_OP_READ, 0, bio);

Looks nicer but one nitpick:

For reusing mpage_bio_submit, we need to call bio_get for on-stack-bio which
doesn't make sense to me but if you think it's more readable and ok with
overhead with two unnecessary atomic instructions(bio_get/put), I will do it
in next spin.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
