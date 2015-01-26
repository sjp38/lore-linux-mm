Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C4F1E6B006C
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 11:00:20 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so12452647pad.4
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 08:00:20 -0800 (PST)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id tj9si12817216pbc.7.2015.01.26.08.00.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 08:00:19 -0800 (PST)
Received: by mail-pd0-f172.google.com with SMTP id v10so12639478pde.3
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 08:00:19 -0800 (PST)
Date: Tue, 27 Jan 2015 01:00:07 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
Message-ID: <20150126160007.GC528@blaptop>
References: <1421992707-32658-1-git-send-email-minchan@kernel.org>
 <20150123142435.GA2320@swordfish>
 <54C25F25.9070609@redhat.com>
 <20150123154707.GA1046@swordfish>
 <20150126013309.GA26895@blaptop>
 <20150126141709.GA985@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150126141709.GA985@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, sergey.senozhatsky.work@gmail.com

On Mon, Jan 26, 2015 at 11:17:09PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (01/26/15 10:33), Minchan Kim wrote:
> > Hello,
> > 
> > On Sat, Jan 24, 2015 at 12:47:07AM +0900, Sergey Senozhatsky wrote:
> > > On (01/23/15 15:48), Jerome Marchand wrote:
> > > > On 01/23/2015 03:24 PM, Sergey Senozhatsky wrote:
> > > > > On (01/23/15 14:58), Minchan Kim wrote:
> > > > >> We don't need to call zram_meta_free, zcomp_destroy and zs_free
> > > > >> under init_lock. What we need to prevent race with init_lock
> > > > >> in reset is setting NULL into zram->meta (ie, init_done).
> > > > >> This patch does it.
> > > > >>
> > > > >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > >> ---
> > > > >>  drivers/block/zram/zram_drv.c | 28 ++++++++++++++++------------
> > > > >>  1 file changed, 16 insertions(+), 12 deletions(-)
> > > > >>
> > > > >> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > > > >> index 9250b3f54a8f..0299d82275e7 100644
> > > > >> --- a/drivers/block/zram/zram_drv.c
> > > > >> +++ b/drivers/block/zram/zram_drv.c
> > > > >> @@ -708,6 +708,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> > > > >>  {
> > > > >>  	size_t index;
> > > > >>  	struct zram_meta *meta;
> > > > >> +	struct zcomp *comp;
> > > > >>  
> > > > >>  	down_write(&zram->init_lock);
> > > > >>  
> > > > >> @@ -719,20 +720,10 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> > > > >>  	}
> > > > >>  
> > > > >>  	meta = zram->meta;
> > > > >> -	/* Free all pages that are still in this zram device */
> > > > >> -	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> > > > >> -		unsigned long handle = meta->table[index].handle;
> > > > >> -		if (!handle)
> > > > >> -			continue;
> > > > >> -
> > > > >> -		zs_free(meta->mem_pool, handle);
> > > > >> -	}
> > > > >> -
> > > > >> -	zcomp_destroy(zram->comp);
> > > > > 
> > > > > I'm not so sure about moving zcomp destruction. if we would have detached it
> > > > > from zram, then yes. otherwise, think of zram ->destoy vs ->init race.
> > > > > 
> > > > > suppose,
> > > > > CPU1 waits for down_write() init lock in disksize_store() with new comp already allocated;
> > > > > CPU0 detaches ->meta and releases write init lock;
> > > > > CPU1 grabs the lock and does zram->comp = comp;
> > > > > CPU0 reaches the point of zcomp_destroy(zram->comp);
> > > > 
> > > > I don't see your point: this patch does not call
> > > > zcomp_destroy(zram->comp) anymore, but zram_destroy(comp), where comp is
> > > > the old zram->comp.
> > > 
> > > 
> > > oh... yes. sorry! my bad.
> > > 
> > > 
> > > 
> > > anyway, on a second thought, do we even want to destoy meta out of init_lock?
> > > 
> > > I mean, it will let you init new device quicker. but... assume, you have
> > > 30G zram (or any other bad-enough number). on CPU0 you reset device -- iterate
> > > over 30G meta->table, etc. out of init_lock.
> > > on CPU1 you concurrently re-init device and request again 30G.
> > > 
> > > how bad that can be?
> > > 
> > > 
> > > 
> > > diskstore called on already initialised device is also not so perfect.
> > > we first will try to allocate ->meta (vmalloc pages for another 30G),
> > > then allocate comp, then down_write() init lock to find out that device
> > > is initialised and we need to release allocated memory.
> > > 
> > > 
> > > 
> > > may be we better keep ->meta destruction under init_lock and additionally
> > > move ->meta and ->comp allocation under init_lock in disksize_store()?
> > > 
> > > like the following one:
> > > 
> > > ---
> > > 
> > >  drivers/block/zram/zram_drv.c | 25 +++++++++++++------------
> > >  1 file changed, 13 insertions(+), 12 deletions(-)
> > > 
> > > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > > index 9250b3f..827ab21 100644
> > > --- a/drivers/block/zram/zram_drv.c
> > > +++ b/drivers/block/zram/zram_drv.c
> > > @@ -765,9 +765,18 @@ static ssize_t disksize_store(struct device *dev,
> > >  		return -EINVAL;
> > >  
> > >  	disksize = PAGE_ALIGN(disksize);
> > > +	down_write(&zram->init_lock);
> > > +	if (init_done(zram)) {
> > > +		up_write(&zram->init_lock);
> > > +		pr_info("Cannot change disksize for initialized device\n");
> > > +		return -EBUSY;
> > > +	}
> > > +
> > >  	meta = zram_meta_alloc(zram->disk->first_minor, disksize);
> > > -	if (!meta)
> > > -		return -ENOMEM;
> > > +	if (!meta) {
> > > +		err = -ENOMEM;
> > > +		goto out_unlock;
> > > +	}
> > >  
> > >  	comp = zcomp_create(zram->compressor, zram->max_comp_streams);
> > >  	if (IS_ERR(comp)) {
> > > @@ -777,13 +786,6 @@ static ssize_t disksize_store(struct device *dev,
> > >  		goto out_free_meta;
> > >  	}
> > >  
> > > -	down_write(&zram->init_lock);
> > > -	if (init_done(zram)) {
> > > -		pr_info("Cannot change disksize for initialized device\n");
> > > -		err = -EBUSY;
> > > -		goto out_destroy_comp;
> > > -	}
> > > -
> > >  	zram->meta = meta;
> > >  	zram->comp = comp;
> > >  	zram->disksize = disksize;
> > > @@ -799,11 +801,10 @@ static ssize_t disksize_store(struct device *dev,
> > >  
> > >  	return len;
> > >  
> > > -out_destroy_comp:
> > > -	up_write(&zram->init_lock);
> > > -	zcomp_destroy(comp);
> > >  out_free_meta:
> > >  	zram_meta_free(meta);
> > > +out_unlock:
> > > +	up_write(&zram->init_lock);
> > >  	return err;
> > >  }
> > >  
> > 
> > The init_lock is really troublesome. We can't do call zram_meta_alloc
> > under init_lock due to lockdep report. Please keep in mind.
> >
> 
> ah... I do recall it, thanks for your reminder.
> 
> 
> > The zram_rw_page is one of the function under reclaim path and hold it
> > as read_lock while here holds it as write_lock.
> > It's a false positive so that we might could make shut lockdep up
> > by annotation but I don't want it but want to work with lockdep rather
> > than disable. As well, there are other pathes to use init_lock to
> > protect other data where would be victims of lockdep.
> > 
> > I didn't tell the motivation of this patch because it made you busy
> > guys wasted. Let me tell it now. It was another lockdep report by
> > kmem_cache_destroy for zsmalloc compaction about init_lock. That's why
> > the patchset was one of the patch in compaction.
> >
> > Yes, the ideal is to remove horrible init_lock of zram in this phase and
> > make code more simple and clear but I don't want to stuck zsmalloc
> > compaction by the work.
> 
> 
> > Having said that, I feel it's time to revisit
> > to remove init_lock.
> > At least, I will think over to find a solution to kill init_lock.
> 
> hm, can't think of anything quick...
> 
> 	-ss

Hello guys,

How about this?

It's based on Ganesh's patch.
https://lkml.org/lkml/2015/1/24/50
