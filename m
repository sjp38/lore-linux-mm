Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1CE5E6B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 19:59:21 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so21908553pab.6
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 16:59:20 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ud5si3721785pbc.25.2015.01.27.16.59.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 16:59:20 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so21930754pad.10
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 16:59:19 -0800 (PST)
Date: Wed, 28 Jan 2015 09:59:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
Message-ID: <20150128005849.GA32712@blaptop>
References: <54C25F25.9070609@redhat.com>
 <20150123154707.GA1046@swordfish>
 <20150126013309.GA26895@blaptop>
 <20150126141709.GA985@swordfish>
 <20150126160007.GC528@blaptop>
 <20150127021704.GA665@swordfish>
 <20150127031823.GA16797@blaptop>
 <20150127040305.GB665@swordfish>
 <20150128001526.GA25828@blaptop>
 <20150128002449.GA1686@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128002449.GA1686@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>

On Wed, Jan 28, 2015 at 09:24:49AM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (01/28/15 09:15), Minchan Kim wrote:
> > > > > > > > On Sat, Jan 24, 2015 at 12:47:07AM +0900, Sergey Senozhatsky wrote:
> > > > > > > > > On (01/23/15 15:48), Jerome Marchand wrote:
> > > > > > > > > > On 01/23/2015 03:24 PM, Sergey Senozhatsky wrote:
> > > > > > > > > > > On (01/23/15 14:58), Minchan Kim wrote:
> > > > > > > > > > >> We don't need to call zram_meta_free, zcomp_destroy and zs_free
> > > > > > > > > > >> under init_lock. What we need to prevent race with init_lock
> > > > > > > > > > >> in reset is setting NULL into zram->meta (ie, init_done).
> > > > > > > > > > >> This patch does it.
> > > > > > > > > > >>
> > > > > > > > > > >> Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > > > > > > > >> ---
> > > > > > > > > > >>  drivers/block/zram/zram_drv.c | 28 ++++++++++++++++------------
> > > > > > > > > > >>  1 file changed, 16 insertions(+), 12 deletions(-)
> > > > > > > > > > >>
> > > > > > > > > > >> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > > > > > > > > > >> index 9250b3f54a8f..0299d82275e7 100644
> > > > > > > > > > >> --- a/drivers/block/zram/zram_drv.c
> > > > > > > > > > >> +++ b/drivers/block/zram/zram_drv.c
> > > > > > > > > > >> @@ -708,6 +708,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> > > > > > > > > > >>  {
> > > > > > > > > > >>  	size_t index;
> > > > > > > > > > >>  	struct zram_meta *meta;
> > > > > > > > > > >> +	struct zcomp *comp;
> > > > > > > > > > >>  
> > > > > > > > > > >>  	down_write(&zram->init_lock);
> > > > > > > > > > >>  
> > > > > > > > > > >> @@ -719,20 +720,10 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> > > > > > > > > > >>  	}
> > > > > > > > > > >>  
> > > > > > > > > > >>  	meta = zram->meta;
> > > > > > > > > > >> -	/* Free all pages that are still in this zram device */
> > > > > > > > > > >> -	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> > > > > > > > > > >> -		unsigned long handle = meta->table[index].handle;
> > > > > > > > > > >> -		if (!handle)
> > > > > > > > > > >> -			continue;
> > > > > > > > > > >> -
> > > > > > > > > > >> -		zs_free(meta->mem_pool, handle);
> > > > > > > > > > >> -	}
> > > > > > > > > > >> -
> > > > > > > > > > >> -	zcomp_destroy(zram->comp);
> > > > > > > > > > > 
> > > > > > > > > > > I'm not so sure about moving zcomp destruction. if we would have detached it
> > > > > > > > > > > from zram, then yes. otherwise, think of zram ->destoy vs ->init race.
> > > > > > > > > > > 
> > > > > > > > > > > suppose,
> > > > > > > > > > > CPU1 waits for down_write() init lock in disksize_store() with new comp already allocated;
> > > > > > > > > > > CPU0 detaches ->meta and releases write init lock;
> > > > > > > > > > > CPU1 grabs the lock and does zram->comp = comp;
> > > > > > > > > > > CPU0 reaches the point of zcomp_destroy(zram->comp);
> > > > > > > > > > 
> > > > > > > > > > I don't see your point: this patch does not call
> > > > > > > > > > zcomp_destroy(zram->comp) anymore, but zram_destroy(comp), where comp is
> > > > > > > > > > the old zram->comp.
> > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > oh... yes. sorry! my bad.
> > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > anyway, on a second thought, do we even want to destoy meta out of init_lock?
> > > > > > > > > 
> > > > > > > > > I mean, it will let you init new device quicker. but... assume, you have
> > > > > > > > > 30G zram (or any other bad-enough number). on CPU0 you reset device -- iterate
> > > > > > > > > over 30G meta->table, etc. out of init_lock.
> > > > > > > > > on CPU1 you concurrently re-init device and request again 30G.
> > > > > > > > > 
> > > > > > > > > how bad that can be?
> > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > diskstore called on already initialised device is also not so perfect.
> > > > > > > > > we first will try to allocate ->meta (vmalloc pages for another 30G),
> > > > > > > > > then allocate comp, then down_write() init lock to find out that device
> > > > > > > > > is initialised and we need to release allocated memory.
> > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > 
> > > > > > > > > may be we better keep ->meta destruction under init_lock and additionally
> > > > > > > > > move ->meta and ->comp allocation under init_lock in disksize_store()?
> > > > > > > > > 
> > > > > > > > > like the following one:
> > > > > > > > > 
> > > > > > > > > ---
> > > > > > > > > 
> > > > > > > > >  drivers/block/zram/zram_drv.c | 25 +++++++++++++------------
> > > > > > > > >  1 file changed, 13 insertions(+), 12 deletions(-)
> > > > > > > > > 
> > > > > > > > > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > > > > > > > > index 9250b3f..827ab21 100644
> > > > > > > > > --- a/drivers/block/zram/zram_drv.c
> > > > > > > > > +++ b/drivers/block/zram/zram_drv.c
> > > > > > > > > @@ -765,9 +765,18 @@ static ssize_t disksize_store(struct device *dev,
> > > > > > > > >  		return -EINVAL;
> > > > > > > > >  
> > > > > > > > >  	disksize = PAGE_ALIGN(disksize);
> > > > > > > > > +	down_write(&zram->init_lock);
> > > > > > > > > +	if (init_done(zram)) {
> > > > > > > > > +		up_write(&zram->init_lock);
> > > > > > > > > +		pr_info("Cannot change disksize for initialized device\n");
> > > > > > > > > +		return -EBUSY;
> > > > > > > > > +	}
> > > > > > > > > +
> > > > > > > > >  	meta = zram_meta_alloc(zram->disk->first_minor, disksize);
> > > > > > > > > -	if (!meta)
> > > > > > > > > -		return -ENOMEM;
> > > > > > > > > +	if (!meta) {
> > > > > > > > > +		err = -ENOMEM;
> > > > > > > > > +		goto out_unlock;
> > > > > > > > > +	}
> > > > > > > > >  
> > > > > > > > >  	comp = zcomp_create(zram->compressor, zram->max_comp_streams);
> > > > > > > > >  	if (IS_ERR(comp)) {
> > > > > > > > > @@ -777,13 +786,6 @@ static ssize_t disksize_store(struct device *dev,
> > > > > > > > >  		goto out_free_meta;
> > > > > > > > >  	}
> > > > > > > > >  
> > > > > > > > > -	down_write(&zram->init_lock);
> > > > > > > > > -	if (init_done(zram)) {
> > > > > > > > > -		pr_info("Cannot change disksize for initialized device\n");
> > > > > > > > > -		err = -EBUSY;
> > > > > > > > > -		goto out_destroy_comp;
> > > > > > > > > -	}
> > > > > > > > > -
> > > > > > > > >  	zram->meta = meta;
> > > > > > > > >  	zram->comp = comp;
> > > > > > > > >  	zram->disksize = disksize;
> > > > > > > > > @@ -799,11 +801,10 @@ static ssize_t disksize_store(struct device *dev,
> > > > > > > > >  
> > > > > > > > >  	return len;
> > > > > > > > >  
> > > > > > > > > -out_destroy_comp:
> > > > > > > > > -	up_write(&zram->init_lock);
> > > > > > > > > -	zcomp_destroy(comp);
> > > > > > > > >  out_free_meta:
> > > > > > > > >  	zram_meta_free(meta);
> > > > > > > > > +out_unlock:
> > > > > > > > > +	up_write(&zram->init_lock);
> > > > > > > > >  	return err;
> > > > > > > > >  }
> > > > > > > > >  
> > > > > > > > 
> > > > > > > > The init_lock is really troublesome. We can't do call zram_meta_alloc
> > > > > > > > under init_lock due to lockdep report. Please keep in mind.
> > > > > > > >
> > > > > > > 
> > > > > > > ah... I do recall it, thanks for your reminder.
> > > > > > > 
> > > > > > > 
> > > > > > > > The zram_rw_page is one of the function under reclaim path and hold it
> > > > > > > > as read_lock while here holds it as write_lock.
> > > > > > > > It's a false positive so that we might could make shut lockdep up
> > > > > > > > by annotation but I don't want it but want to work with lockdep rather
> > > > > > > > than disable. As well, there are other pathes to use init_lock to
> > > > > > > > protect other data where would be victims of lockdep.
> > > > > > > > 
> > > > > > > > I didn't tell the motivation of this patch because it made you busy
> > > > > > > > guys wasted. Let me tell it now. It was another lockdep report by
> > > > > > > > kmem_cache_destroy for zsmalloc compaction about init_lock. That's why
> > > > > > > > the patchset was one of the patch in compaction.
> > > > > > > >
> > > > > > > > Yes, the ideal is to remove horrible init_lock of zram in this phase and
> > > > > > > > make code more simple and clear but I don't want to stuck zsmalloc
> > > > > > > > compaction by the work.
> > > > > > > 
> > > > > > > 
> > > > > > > > Having said that, I feel it's time to revisit
> > > > > > > > to remove init_lock.
> > > > > > > > At least, I will think over to find a solution to kill init_lock.
> > > > > > > 
> > > > > > > hm, can't think of anything quick...
> > > > > > > 
> > > > > > > 	-ss
> > > > > > 
> > > > > > Hello guys,
> > > > > > 
> > > > > > How about this?
> > > > > > 
> > > > > > It's based on Ganesh's patch.
> > > > > > https://lkml.org/lkml/2015/1/24/50
> > > > > (I see no similarities with Ganesh's patch)
> > > > > 
> > > > > hm, you probably meant this one https://lkml.org/lkml/2015/1/23/406
> > > > > 
> > > > > 
> > > > > at glance this makes things a bit more complicated, so I need to think more.
> > > > > 
> > > > > > From afda9fd2f6c40dd0745d8a6babe78c5cbdceddf5 Mon Sep 17 00:00:00 2001
> > > > > > From: Minchan Kim <minchan@kernel.org>
> > > > > > Date: Mon, 26 Jan 2015 14:34:10 +0900
> > > > > > Subject: [RFC] zram: remove init_lock in zram_make_request
> > > > > > 
> > > > > > Admin could reset zram during I/O operation going on so we have
> > > > > > used zram->init_lock as read-side lock in I/O path to prevent
> > > > > > sudden zram meta freeing.
> > > > > > 
> > > > > > However, the init_lock is really troublesome.
> > > > > > We can't do call zram_meta_alloc under init_lock due to lockdep splat
> > > > > > because zram_rw_page is one of the function under reclaim path and
> > > > > > hold it as read_lock while other places in process context hold it
> > > > > > as write_lock. So, we have used allocation out of the lock to avoid
> > > > > > lockdep warn but it's not good for readability and fainally, I met
> > > > > > another lockdep splat between init_lock and cpu_hotpulug from
> > > > > > kmem_cache_destroy during wokring zsmalloc compaction. :(
> > > > > > 
> > > > > > Yes, the ideal is to remove horrible init_lock of zram in rw path.
> > > > > > This patch removes it in rw path and instead, put init_done bool
> > > > > > variable to check initialization done with smp_[wmb|rmb] and
> > > > > > srcu_[un]read_lock to prevent sudden zram meta freeing
> > > > > > during I/O operation.
> > > > > > 
> > > > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > > > ---
> > > > > >  drivers/block/zram/zram_drv.c | 76 +++++++++++++++++++++++++++++--------------
> > > > > >  drivers/block/zram/zram_drv.h |  5 +++
> > > > > >  2 files changed, 57 insertions(+), 24 deletions(-)
> > > > > > 
> > > > > > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > > > > > index a598ada817f0..e06ff975f997 100644
> > > > > > --- a/drivers/block/zram/zram_drv.c
> > > > > > +++ b/drivers/block/zram/zram_drv.c
> > > > > > @@ -32,6 +32,7 @@
> > > > > >  #include <linux/string.h>
> > > > > >  #include <linux/vmalloc.h>
> > > > > >  #include <linux/err.h>
> > > > > > +#include <linux/srcu.h>
> > > > > >  
> > > > > >  #include "zram_drv.h"
> > > > > >  
> > > > > > @@ -53,9 +54,16 @@ static ssize_t name##_show(struct device *d,		\
> > > > > >  }									\
> > > > > >  static DEVICE_ATTR_RO(name);
> > > > > >  
> > > > > > -static inline int init_done(struct zram *zram)
> > > > > > +static inline bool init_done(struct zram *zram)
> > > > > >  {
> > > > > > -	return zram->meta != NULL;
> > > > > > +	/*
> > > > > > +	 * init_done can be used without holding zram->init_lock in
> > > > > > +	 * read/write handler(ie, zram_make_request) but we should make sure
> > > > > > +	 * that zram->init_done should set up after meta initialization is
> > > > > > +	 * done. Look at disksize_store.
> > > > > > +	 */
> > > > > > +	smp_rmb();
> > > > > > +	return zram->init_done;
> > > > > 
> > > > > ->init_done returns back :)
> > > > 
> > > > 
> > > > > can we rely on write ->meta; wmb; --- rmb; read ->meta?
> > > > 
> > > > Might be possible.
> > 
> > Now that I think about it, it's impossible with zram->meta because
> > we need to nullify it before call_srcu but pre-existing SRCU read-side
> > critical sections can access zram->meta.
> > Anyway, introducing a new variable should be not a party-pooper.
> > 
> > > > 
> > > > > 
> > > > > how much performance do we lose on barriers?
> > > > 
> > > > I think it's not too much than locking which does more than(ie,
> > > > barrier, fairness, spin on owner and so on) such simple barrier.
> > > > 
> > > > > 
> > > > > >  }
> > > > > >  
> > > > > >  static inline struct zram *dev_to_zram(struct device *dev)
> > > > > > @@ -326,6 +334,10 @@ static void zram_meta_free(struct zram_meta *meta)
> > > > > >  	kfree(meta);
> > > > > >  }
> > > > > >  
> > > > > > +static void rcu_zram_do_nothing(struct rcu_head *unused)
> > > > > > +{
> > > > > > +}
> > > > > > +
> > > > > >  static struct zram_meta *zram_meta_alloc(int device_id, u64 disksize)
> > > > > >  {
> > > > > >  	char pool_name[8];
> > > > > > @@ -726,11 +738,8 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> > > > > >  		return;
> > > > > >  	}
> > > > > >  
> > > > > > -	zcomp_destroy(zram->comp);
> > > > > >  	zram->max_comp_streams = 1;
> > > > > >  
> > > > > > -	zram_meta_free(zram->meta);
> > > > > > -	zram->meta = NULL;
> > > > > >  	/* Reset stats */
> > > > > >  	memset(&zram->stats, 0, sizeof(zram->stats));
> > > > > >  
> > > > > > @@ -738,8 +747,12 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> > > > > >  	if (reset_capacity)
> > > > > >  		set_capacity(zram->disk, 0);
> > > > > >  
> > > > > > +	zram->init_done = false;
> > > > > 
> > > > > missing wmb?
> > > > 
> > > > I thouht about it but when I read comment from call_srcu as follows
> > > > "each cpu is guaranteed to have executed a full memory barrier",
> > > > I decided we don't need it. Right? (ie, double check)
> > > > 
> > > 
> > > hm, need to think about it.
> > 
> > Another idea is to use kick_all_cpus_sync, not srcu.
> > With that, we don't need to add more instruction in rw path.
> > I will try it.
> > 
> 
> hm, that will kick all cpus out of idle.

It just calls smp_call_funcion which is used by a lot places
by arch and drivers by on_each_cpu and I don't think resetting
of zram is not a frequent activity.
Anyway, I'm okay either way. Just want to show the concept
and let's decide the way and go forward. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
