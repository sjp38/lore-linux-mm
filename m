Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id BC2B46B0038
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 00:18:13 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so77685436pac.13
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 21:18:13 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id oi14si22308769pdb.130.2015.02.01.21.18.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 21:18:13 -0800 (PST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so77746949pad.7
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 21:18:12 -0800 (PST)
Date: Mon, 2 Feb 2015 14:18:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202051805.GI6402@blaptop>
References: <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
 <20150201145036.GA1290@swordfish>
 <20150202013028.GB6402@blaptop>
 <20150202014800.GA6977@swordfish>
 <20150202024405.GD6402@blaptop>
 <20150202040124.GE6977@swordfish>
 <20150202042847.GG6402@blaptop>
 <20150202050912.GA443@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202050912.GA443@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Mon, Feb 02, 2015 at 02:09:12PM +0900, Sergey Senozhatsky wrote:
> 
> the patch mosly looks good, except for one place:
> 
> On (02/02/15 13:28), Minchan Kim wrote:
> > @@ -783,6 +812,8 @@ static ssize_t disksize_store(struct device *dev,
> >  		goto out_destroy_comp;
> >  	}
> >  
> > +	init_waitqueue_head(&zram->io_done);
> > +	zram_meta_get(zram);
> 
> it was
> +       init_completion(&zram->io_done);
> +       atomic_set(&zram->refcount, 1);
> 
> I think we need to replace zram_meta_get(zram) with atomic_set(&zram->refcount, 1).
> 
> ->refcount is 0 by default and atomic_inc_not_zero(&zram->refcount) will not
> increment it here, nor anywhere else.
> 
> 
> >  	zram->meta = meta;
> >  	zram->comp = comp;
> >  	zram->disksize = disksize;
> > @@ -838,8 +869,8 @@ static ssize_t reset_store(struct device *dev,
> >  	/* Make sure all pending I/O is finished */
> >  	fsync_bdev(bdev);
> >  	bdput(bdev);
> > -
> 
> [..]
> 
> > @@ -1041,6 +1075,7 @@ static int create_device(struct zram *zram, int device_id)
> >  	int ret = -ENOMEM;
> >  
> >  	init_rwsem(&zram->init_lock);
> > +	atomic_set(&zram->refcount, 0);
> 
> sorry, I forgot that zram is kzalloc()-ated. so we can drop
> 
> 	atomic_set(&zram->refcount, 0)
> 

Everything are fixed. Ready to send a patch.
But before sending, hope we fix umount race issue first.

Thanks a lot, Sergey!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
