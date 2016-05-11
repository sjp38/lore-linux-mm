Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E78C6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 04:15:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so35332360wme.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 01:15:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c12si8361646wmc.2.2016.05.11.01.15.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 May 2016 01:15:35 -0700 (PDT)
Date: Wed, 11 May 2016 10:15:32 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 4/5] dax: for truncate/hole-punch, do zeroing through
 the driver if possible
Message-ID: <20160511081532.GB14744@quack2.suse.cz>
References: <1462906156-22303-1-git-send-email-vishal.l.verma@intel.com>
 <1462906156-22303-5-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462906156-22303-5-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>

On Tue 10-05-16 12:49:15, Vishal Verma wrote:
> In the truncate or hole-punch path in dax, we clear out sub-page ranges.
> If these sub-page ranges are sector aligned and sized, we can do the
> zeroing through the driver instead so that error-clearing is handled
> automatically.
> 
> For sub-sector ranges, we still have to rely on clear_pmem and have the
> possibility of tripping over errors.
> 
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Jan Kara <jack@suse.cz>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>

...

> +static bool dax_range_is_aligned(struct block_device *bdev,
> +				 struct blk_dax_ctl *dax, unsigned int offset,
> +				 unsigned int length)
> +{
> +	unsigned short sector_size = bdev_logical_block_size(bdev);
> +
> +	if (!IS_ALIGNED(((u64)dax->addr + offset), sector_size))

One more question: 'dax' is initialized in dax_zero_page_range() and
dax->addr is going to be always NULL here. So either you forgot to call
dax_map_atomic() to get the addr or the use of dax->addr is just bogus
(which is what I currently believe since I see no way how the address could
be unaligned with the sector_size)...

								Honza
> +		return false;
> +	if (!IS_ALIGNED(length, sector_size))
> +		return false;
> +
> +	return true;
> +}
> +
>  /**
>   * dax_zero_page_range - zero a range within a page of a DAX file
>   * @inode: The file being truncated
> @@ -1240,11 +1254,16 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
>  			.size = PAGE_SIZE,
>  		};
>  
> -		if (dax_map_atomic(bdev, &dax) < 0)
> -			return PTR_ERR(dax.addr);
> -		clear_pmem(dax.addr + offset, length);
> -		wmb_pmem();
> -		dax_unmap_atomic(bdev, &dax);
> +		if (dax_range_is_aligned(bdev, &dax, offset, length))
> +			return blkdev_issue_zeroout(bdev, dax.sector,
> +					length >> 9, GFP_NOFS, true);
> +		else {
> +			if (dax_map_atomic(bdev, &dax) < 0)
> +				return PTR_ERR(dax.addr);
> +			clear_pmem(dax.addr + offset, length);
> +			wmb_pmem();
> +			dax_unmap_atomic(bdev, &dax);
> +		}
>  	}
>  
>  	return 0;
> -- 
> 2.5.5
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
