Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 406A36B007E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 10:21:23 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j8so12015734lfd.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 07:21:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ct7si2915842wjc.29.2016.05.10.07.21.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 07:21:22 -0700 (PDT)
Date: Tue, 10 May 2016 16:21:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 4/5] dax: for truncate/hole-punch, do zeroing through
 the driver if possible
Message-ID: <20160510142119.GN11897@quack2.suse.cz>
References: <1462571591-3361-1-git-send-email-vishal.l.verma@intel.com>
 <1462571591-3361-5-git-send-email-vishal.l.verma@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462571591-3361-5-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>

On Fri 06-05-16 15:53:10, Vishal Verma wrote:
> +static bool dax_range_is_aligned(struct block_device *bdev,
> +				 struct blk_dax_ctl *dax, unsigned int offset,
> +				 unsigned int length)
> +{
> +	unsigned short sector_size = bdev_logical_block_size(bdev);
> +
> +	if (((u64)dax->addr + offset) % sector_size)
> +		return false;
> +	if (length % sector_size)
> +		return false;

sector_size should better be a power of two so you can save some cycles by
using & instead of %.

> @@ -1240,11 +1254,17 @@ int dax_zero_page_range(struct inode *inode, loff_t from, unsigned length,
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
> +					length / bdev_logical_block_size(bdev),
> +					GFP_NOFS, true);

This is actually wrong. blkdev_issue_zeroout() expects length to be simply
in units of 512-bytes. So you need length >> 9 here.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
