Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7D97D6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 20:03:47 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id g10so2411100pdj.0
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 17:03:47 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id bs2si19556pad.67.2015.01.22.17.03.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 17:03:46 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so5190470pac.13
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 17:03:46 -0800 (PST)
Date: Fri, 23 Jan 2015 10:03:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 01/10] zram: avoid calling of zram_meta_free under
 init_lock
Message-ID: <20150123010336.GA18918@blaptop>
References: <1421820866-26521-1-git-send-email-minchan@kernel.org>
 <1421820866-26521-2-git-send-email-minchan@kernel.org>
 <20150121142115.GA986@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150121142115.GA986@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>

Hello,

On Wed, Jan 21, 2015 at 11:21:53PM +0900, Sergey Senozhatsky wrote:
> On (01/21/15 15:14), Minchan Kim wrote:
> > We don't need to call zram_meta_free under init_lock.
> > What we need to prevent race is setting NULL into zram->meta
> > (ie, init_done). This patch does it.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/block/zram/zram_drv.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index 9250b3f..7e03d86 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -719,6 +719,8 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >  	}
> >  
> >  	meta = zram->meta;
> > +	zram->meta = NULL;
> > +
> >  	/* Free all pages that are still in this zram device */
> >  	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> >  		unsigned long handle = meta->table[index].handle;
> > @@ -731,8 +733,6 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >  	zcomp_destroy(zram->comp);
> >  	zram->max_comp_streams = 1;
> >  
> > -	zram_meta_free(zram->meta);
> > -	zram->meta = NULL;
> >  	/* Reset stats */
> >  	memset(&zram->stats, 0, sizeof(zram->stats));
> >  
> > @@ -741,6 +741,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >  		set_capacity(zram->disk, 0);
> >  
> >  	up_write(&zram->init_lock);
> > +	zram_meta_free(meta);
> 
> Hello,
> 
> since we detached ->meta from zram, this one doesn't really need
> ->init_lock protection:
> 
> 	/* Free all pages that are still in this zram device */
> 	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> 		unsigned long handle = meta->table[index].handle;
> 		if (!handle)
> 			continue;
> 
> 		zs_free(meta->mem_pool, handle);
> 	}
> 
> 
> 	-ss

Good catch.

As well, we could move zcomp_destroy and memset(&zram->stats)
out of the lock but zram_rw_page, ZRAM_ATTR_RO, disksize_show
and orig_data_size_show have a race bug which access stats
out of the lock so that it could show the stale vaule.
Although it's not a significant, there is no reason to hesitate the fix. :)

I will fix it. Thanks!


> 
> >  	/*
> >  	 * Revalidate disk out of the init_lock to avoid lockdep splat.
> > -- 
> > 1.9.3
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
