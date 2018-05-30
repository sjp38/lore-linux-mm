Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 166FE6B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 01:52:47 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id q5-v6so13723769itq.2
        for <linux-mm@kvack.org>; Tue, 29 May 2018 22:52:47 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q139-v6si11693869itc.61.2018.05.29.22.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 22:52:46 -0700 (PDT)
Date: Tue, 29 May 2018 22:52:42 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 13/34] iomap: add a iomap_sector helper
Message-ID: <20180530055242.GB30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-14-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:36PM +0200, Christoph Hellwig wrote:
> Factor the repeated calculation of the on-disk sector for a given logical
> block into a littler helper.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/iomap.c | 19 ++++++++++---------
>  1 file changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/iomap.c b/fs/iomap.c
> index 8e28f25f086f..f928df4ab9a9 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -97,6 +97,12 @@ iomap_apply(struct inode *inode, loff_t pos, loff_t length, unsigned flags,
>  	return written ? written : ret;
>  }
>  
> +static sector_t
> +iomap_sector(struct iomap *iomap, loff_t pos)
> +{
> +	return (iomap->addr + pos - iomap->offset) >> SECTOR_SHIFT;
> +}
> +
>  static void
>  iomap_write_failed(struct inode *inode, loff_t pos, unsigned len)
>  {
> @@ -354,11 +360,8 @@ static int iomap_zero(struct inode *inode, loff_t pos, unsigned offset,
>  static int iomap_dax_zero(loff_t pos, unsigned offset, unsigned bytes,
>  		struct iomap *iomap)
>  {
> -	sector_t sector = (iomap->addr +
> -			   (pos & PAGE_MASK) - iomap->offset) >> 9;
> -
> -	return __dax_zero_page_range(iomap->bdev, iomap->dax_dev, sector,
> -			offset, bytes);
> +	return __dax_zero_page_range(iomap->bdev, iomap->dax_dev,
> +			iomap_sector(iomap, pos & PAGE_MASK), offset, bytes);
>  }
>  
>  static loff_t
> @@ -943,8 +946,7 @@ iomap_dio_zero(struct iomap_dio *dio, struct iomap *iomap, loff_t pos,
>  
>  	bio = bio_alloc(GFP_KERNEL, 1);
>  	bio_set_dev(bio, iomap->bdev);
> -	bio->bi_iter.bi_sector =
> -		(iomap->addr + pos - iomap->offset) >> 9;
> +	bio->bi_iter.bi_sector = iomap_sector(iomap, pos);
>  	bio->bi_private = dio;
>  	bio->bi_end_io = iomap_dio_bio_end_io;
>  
> @@ -1038,8 +1040,7 @@ iomap_dio_actor(struct inode *inode, loff_t pos, loff_t length,
>  
>  		bio = bio_alloc(GFP_KERNEL, nr_pages);
>  		bio_set_dev(bio, iomap->bdev);
> -		bio->bi_iter.bi_sector =
> -			(iomap->addr + pos - iomap->offset) >> 9;
> +		bio->bi_iter.bi_sector = iomap_sector(iomap, pos);
>  		bio->bi_write_hint = dio->iocb->ki_hint;
>  		bio->bi_private = dio;
>  		bio->bi_end_io = iomap_dio_bio_end_io;
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
