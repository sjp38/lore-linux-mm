Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 318796B0038
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 19:45:54 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so10385462pdj.35
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 16:45:53 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ia3si29076819pbb.209.2014.08.19.16.45.51
        for <linux-mm@kvack.org>;
        Tue, 19 Aug 2014 16:45:52 -0700 (PDT)
Date: Wed, 20 Aug 2014 08:46:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 2/4] zsmalloc: change return value unit of
 zs_get_total_size_bytes
Message-ID: <20140819234621.GB32620@bbox>
References: <1408434887-16387-1-git-send-email-minchan@kernel.org>
 <1408434887-16387-3-git-send-email-minchan@kernel.org>
 <20140819144628.GA26403@cerebellum.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140819144628.GA26403@cerebellum.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com

Hey Seth,

On Tue, Aug 19, 2014 at 09:46:28AM -0500, Seth Jennings wrote:
> On Tue, Aug 19, 2014 at 04:54:45PM +0900, Minchan Kim wrote:
> > zs_get_total_size_bytes returns a amount of memory zsmalloc
> > consumed with *byte unit* but zsmalloc operates *page unit*
> > rather than byte unit so let's change the API so benefit
> > we could get is that reduce unnecessary overhead
> > (ie, change page unit with byte unit) in zsmalloc.
> > 
> > Now, zswap can rollback to zswap_pool_pages.
> > Over to zswap guys ;-)
> 
> I don't think that's how is it done :-/  Changing the API for a
> component that has two users, changing one, then saying "hope you guys
> change your newly broken stuff".

I don't get it. The zsmalloc's zs_zpool_total_size returns u64 with bytes,
not pages so what's broken stuff you mentioned?

static u64 zs_zpool_total_size(void *pool)
{
    -	return zs_get_total_size_bytes(pool);
    +	return zs_get_total_size(pool) << PAGE_SHIFT;
}

Thing I nudged to you is just you could roll back to pages count
instead of bytes if zswap guys want it and I dont' want it myself
for avoding unnecessary noise for this patchset's purpose.

> 
> I know you would rather not move zram to the zpool API but doing so
> would avoid situations like this.
> 
> Anyway, this does break the zpool API and by extension zswap, and that
> needs to be addressed in this patch or we create a point in the commit
> history where it is broken.
> 
> Quick glance:
> - zpool_get_total_size() return type is u64 but this patch changes to
> unsigned long.  Now mismatches between zbud and zsmalloc.

Nope. zs_zpool_total_size returns u64 with PAGE_SHIFT.

> - zbud_zpool_total_size needs to return pages, not bytes

It's up to you, not me.

> - as you noted s/pool_total_size/pool_pages/g in zswap.c plus
>   modification to zswap_is_full()

I didn't mean it. Sorry for the confusing.
If I miss your point, let me know it.

Thanks.

> 
> Thanks,
> Seth
> 
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/block/zram/zram_drv.c |  4 ++--
> >  include/linux/zsmalloc.h      |  2 +-
> >  mm/zsmalloc.c                 | 10 +++++-----
> >  3 files changed, 8 insertions(+), 8 deletions(-)
> > 
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index d00831c3d731..302dd37bcea3 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -103,10 +103,10 @@ static ssize_t mem_used_total_show(struct device *dev,
> >  
> >  	down_read(&zram->init_lock);
> >  	if (init_done(zram))
> > -		val = zs_get_total_size_bytes(meta->mem_pool);
> > +		val = zs_get_total_size(meta->mem_pool);
> >  	up_read(&zram->init_lock);
> >  
> > -	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> > +	return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
> >  }
> >  
> >  static ssize_t max_comp_streams_show(struct device *dev,
> > diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
> > index e44d634e7fb7..105b56e45d23 100644
> > --- a/include/linux/zsmalloc.h
> > +++ b/include/linux/zsmalloc.h
> > @@ -46,6 +46,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
> >  			enum zs_mapmode mm);
> >  void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
> >  
> > -u64 zs_get_total_size_bytes(struct zs_pool *pool);
> > +unsigned long zs_get_total_size(struct zs_pool *pool);
> >  
> >  #endif
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index a65924255763..80408a1da03a 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -299,7 +299,7 @@ static void zs_zpool_unmap(void *pool, unsigned long handle)
> >  
> >  static u64 zs_zpool_total_size(void *pool)
> >  {
> > -	return zs_get_total_size_bytes(pool);
> > +	return zs_get_total_size(pool) << PAGE_SHIFT;
> >  }
> >  
> >  static struct zpool_driver zs_zpool_driver = {
> > @@ -1186,16 +1186,16 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
> >  }
> >  EXPORT_SYMBOL_GPL(zs_unmap_object);
> >  
> > -u64 zs_get_total_size_bytes(struct zs_pool *pool)
> > +unsigned long zs_get_total_size(struct zs_pool *pool)
> >  {
> > -	u64 npages;
> > +	unsigned long npages;
> >  
> >  	spin_lock(&pool->stat_lock);
> >  	npages = pool->pages_allocated;
> >  	spin_unlock(&pool->stat_lock);
> > -	return npages << PAGE_SHIFT;
> > +	return npages;
> >  }
> > -EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
> > +EXPORT_SYMBOL_GPL(zs_get_total_size);
> >  
> >  module_init(zs_init);
> >  module_exit(zs_exit);
> > -- 
> > 2.0.0
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
