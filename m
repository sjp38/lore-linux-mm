Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 60D4B6B0069
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 16:15:38 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id hn15so1693943igb.9
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 13:15:38 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i16si719638icf.3.2014.11.19.13.15.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Nov 2014 13:15:37 -0800 (PST)
Date: Wed, 19 Nov 2014 13:15:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] zram: rely on the bi_end_io for zram_rw_page fails
Message-Id: <20141119131535.7d848c148535c076a17b9d29@linux-foundation.org>
In-Reply-To: <20141118235201.GB7393@bbox>
References: <1415926147-9023-1-git-send-email-minchan@kernel.org>
	<20141118152336.d58b7b61a711b7d9982deb9d@linux-foundation.org>
	<20141118235201.GB7393@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Karam Lee <karam.lee@lge.com>, Dave Chinner <david@fromorbit.com>

On Wed, 19 Nov 2014 08:52:01 +0900 Minchan Kim <minchan@kernel.org> wrote:

> > >  
> > > -	/*
> > > -	 * Return 0 prevents I/O fallback trial caused by rw_page fail
> > > -	 * and upper layer can handle this IO error via page error.
> > > -	 */
> > > +	page_endio(page, rw, 0);
> > >  	return 0;
> > 
> > Losing the comment makes me sad.  The code is somewhat odd-looking.  We
> > should add some words explaining why we're not reporting errors at this
> > point.
> 
> Okay. How about this?
> 
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index decca6f161b8..1d7c90d5e0d0 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -975,6 +975,12 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
>  	err = zram_bvec_rw(zram, &bv, index, offset, rw);
>  out_unlock:
>  	up_read(&zram->init_lock);
> +	/*
> +	 * If I/O fails, just return error without calling page_endio.
> +	 * It causes resubmit the I/O with bio request by rw_page fallback
> +	 * and bio I/O complete handler does things to handle the error
> +	 * (e.g., set_page_dirty of swap_writepage fail).
> +	 */
>  	if (err == 0)
>  		page_endio(page, rw, 0);
>  	return err;

I don't understand the comment :( bdev_read_page() doesn't resubmit the
IO if block_device_operations.rw_page() returns zero and it's unclear
how the bio I/O complete handler (which one?) gets involved.

It would help in the comment was more specific.  Instead of using vague
terms like "rw_page fallback" and "bio I/O complete handler", use
actual function names so the reader understand exactly what code we're
referring to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
