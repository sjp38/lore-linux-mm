Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6FC6B0085
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 18:32:38 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id fp1so1825727pdb.0
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 15:32:38 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id ra6si768224pbb.60.2014.11.19.15.32.35
        for <linux-mm@kvack.org>;
        Wed, 19 Nov 2014 15:32:37 -0800 (PST)
Date: Thu, 20 Nov 2014 08:32:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: rely on the bi_end_io for zram_rw_page fails
Message-ID: <20141119233232.GA2627@bbox>
References: <1415926147-9023-1-git-send-email-minchan@kernel.org>
 <20141118152336.d58b7b61a711b7d9982deb9d@linux-foundation.org>
 <20141118235201.GB7393@bbox>
 <20141119131535.7d848c148535c076a17b9d29@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20141119131535.7d848c148535c076a17b9d29@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Karam Lee <karam.lee@lge.com>, Dave Chinner <david@fromorbit.com>

Hello,

On Wed, Nov 19, 2014 at 01:15:35PM -0800, Andrew Morton wrote:
> On Wed, 19 Nov 2014 08:52:01 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > > >  
> > > > -	/*
> > > > -	 * Return 0 prevents I/O fallback trial caused by rw_page fail
> > > > -	 * and upper layer can handle this IO error via page error.
> > > > -	 */
> > > > +	page_endio(page, rw, 0);
> > > >  	return 0;
> > > 
> > > Losing the comment makes me sad.  The code is somewhat odd-looking.  We
> > > should add some words explaining why we're not reporting errors at this
> > > point.
> > 
> > Okay. How about this?
> > 
> > 
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index decca6f161b8..1d7c90d5e0d0 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -975,6 +975,12 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
> >  	err = zram_bvec_rw(zram, &bv, index, offset, rw);
> >  out_unlock:
> >  	up_read(&zram->init_lock);
> > +	/*
> > +	 * If I/O fails, just return error without calling page_endio.
> > +	 * It causes resubmit the I/O with bio request by rw_page fallback
> > +	 * and bio I/O complete handler does things to handle the error
> > +	 * (e.g., set_page_dirty of swap_writepage fail).
> > +	 */
> >  	if (err == 0)
> >  		page_endio(page, rw, 0);
> >  	return err;
> 
> I don't understand the comment :( bdev_read_page() doesn't resubmit the
> IO if block_device_operations.rw_page() returns zero and it's unclear

It's not bdev_read_page but upper functions.
(ie, do_mpage_readpage, swap_readpage, __mpage_writepage, __swap_writepage)

> how the bio I/O complete handler (which one?) gets involved.

bio->bi_end_io.

> 
> It would help in the comment was more specific.  Instead of using vague
> terms like "rw_page fallback" and "bio I/O complete handler", use
> actual function names so the reader understand exactly what code we're
> referring to.

Indeed. I was terrible.

Hope this is better.
