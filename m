Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 99BFD6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 00:55:27 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so5855583pab.22
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 21:55:27 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vs4si4360452pbc.165.2014.09.22.21.55.25
        for <linux-mm@kvack.org>;
        Mon, 22 Sep 2014 21:55:26 -0700 (PDT)
Date: Tue, 23 Sep 2014 13:56:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 4/5] zram: add swap full hint
Message-ID: <20140923045602.GC8325@bbox>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
 <1411344191-2842-5-git-send-email-minchan@kernel.org>
 <20140922141118.de46ae5e54099cf2b39c8c5b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140922141118.de46ae5e54099cf2b39c8c5b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Mon, Sep 22, 2014 at 02:11:18PM -0700, Andrew Morton wrote:
> On Mon, 22 Sep 2014 09:03:10 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > This patch implement SWAP_FULL handler in zram so that VM can
> > know whether zram is full or not and use it to stop anonymous
> > page reclaim.
> > 
> > How to judge fullness is below,
> > 
> > fullness = (100 * used space / total space)
> > 
> > It means the higher fullness is, the slower we reach zram full.
> > Now, default of fullness is 80 so that it biased more momory
> > consumption rather than early OOM kill.
> 
> It's unclear to me why this is being done.  What's wrong with "use it
> until it's full then stop", which is what I assume the current code
> does?  Why add this stuff?  What goes wrong with the current code and
> how does this fix it?
> 
> ie: better explanation and justification in the chagnelogs, please.

My bad. I should have wrote down about zram allocator's fragmentation
problem.

zsmalloc has various size class so it has a fragmentation problem.
For example, a page swap out -> comprssed 32 byte -> has a empty slot
of zsmalloc's 32 size class -> successful write.

Another swap out -> compressed 256 byte -> no empty slot in zsmalloc's
256 size class -> zsmalloc should allocate new zspage but it would be
over limit so it would be failed.

The problem is swap layer cannot know compressed size of the page
in advance so it couldn't expect whether swap-write will be successful
while it could get empty swap slot easily since zram's virtual disk
size is fairy enough.

Given that zsmalloc's fragmentation, it would be *early-OOM* if zram
says *full* as soon as it reaches page limit because it could have
empty slots in various size classes. IOW, it doesn't consider fragment
problem so this patch suggests two condition to solve it.

	if (total_pages >= zram->limit_pages) {

		compr_pages = atomic64_read(&zram->stats.compr_data_size)
					>> PAGE_SHIFT;
		if ((100 * compr_pages / total_pages)
			>= zram->fullness)
			return 1;
	}

First of all, zram-consumed page should reach *limit* and then we
consider fullness. If used space is over 80%, we regards it as full
in this implementation because I want to focus more memory usage to
avoid early OOM kill when I consider zram's popular usecase in
embedded.

> 
> > Above logic works only when used space of zram hit over the limit
> > but zram also pretend to be full once 32 consecutive allocation
> > fail happens. It's safe guard to prevent system hang caused by
> > fragment uncertainty.
> 
> So allocation requests are of variable size, yes?  If so, the above
> statement should read "32 consecutive allocation attempts for regions
> or size 2 or more slots".  Because a failure of a single-slot
> allocation attempt is an immediate failure.
> 
> The 32-in-a-row thing sounds like a hack.  Why can't we do this
> deterministically?  If one request for four slots fails then the next
> one will as well, so why bother retrying?

The problem is swap layer cannot expect what compressed size in the end
in advance without compressing. If the page is compressed to the size
zsmalloc has empty slot in size class, it would be successful.

> 
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -43,6 +43,20 @@ static const char *default_compressor = "lzo";
> >  /* Module params (documentation at end) */
> >  static unsigned int num_devices = 1;
> >  
> > +/*
> > + * If (100 * used_pages / total_pages) >= ZRAM_FULLNESS_PERCENT),
> > + * we regards it as zram-full. It means that the higher
> > + * ZRAM_FULLNESS_PERCENT is, the slower we reach zram full.
> > + */
> 
> I just don't understand this patch :( To me, the above implies that the
> user who sets 80% has elected to never use 20% of the zram capacity. 
> Why on earth would anyone do that?  This chagnelog doesn't tell me.

Hope above my words make you clear.

> 
> > +#define ZRAM_FULLNESS_PERCENT 80
> 
> We've had problems in the past where 1% is just too large an increment
> for large systems.

So, do you want fullness_bytes like dirty_bytes?

> 
> > @@ -597,10 +613,15 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >  	}
> >  
> >  	alloced_pages = zs_get_total_pages(meta->mem_pool);
> > -	if (zram->limit_pages && alloced_pages > zram->limit_pages) {
> > -		zs_free(meta->mem_pool, handle);
> > -		ret = -ENOMEM;
> > -		goto out;
> > +	if (zram->limit_pages) {
> > +		if (alloced_pages > zram->limit_pages) {
> 
> This is all a bit racy, isn't it?  pool->pages_allocated and
> zram->limit_pages could be changing under our feet.

limit_pages cannot be changed by init_lock but pool->pages_allocated
is yes but the result by the race is not critical.

1. swap write fail so swap layer could make the page dirty again
   so it's no problem.
Or
2. alloc_fail race so zram could be full if consecutive alloc_fail is
   higher 32 and there is already over the limit currently.
   I think it is rare and if it happens, it's not a big problem, IMO.

> 
> > +			zs_free(meta->mem_pool, handle);
> > +			atomic_inc(&zram->alloc_fail);
> > +			ret = -ENOMEM;
> > +			goto out;
> > +		} else {
> > +			atomic_set(&zram->alloc_fail, 0);
> > +		}
>  	}
>  
>  	update_used_max(zram, alloced_pages);
> 
> > @@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >  	down_write(&zram->init_lock);
> >  
> >  	zram->limit_pages = 0;
> > +	atomic_set(&zram->alloc_fail, 0);
> >  
> >  	if (!init_done(zram)) {
> >  		up_write(&zram->init_lock);
> > @@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_device *bdev,
> >  	return 0;
> >  }
> >  
> > +static int zram_full(struct block_device *bdev, void *arg)
> 
> This could return a bool.  That implies that zram_swap_hint should
> return bool too, but as we haven't been told what the zram_swap_hint
> return value does, I'm a bit stumped.

Hmm, currently, SWAP_FREE doesn't use return and SWAP_FULL uses return
as bool so in the end, we can change it as bool but I want to remain it
as int for the future. At least, we might use it as propagating error
in future. Instead, I will use *arg to return the result instead of
return val. But I'm not strong so if you want to remove return val,
I will do it. For clarifictaion, please tell me again if you want.

> 
> And why include the unusefully-named "void *arg"?  It doesn't get used here.
> 
> > +{
> > +	struct zram *zram;
> > +	struct zram_meta *meta;
> > +	unsigned long total_pages, compr_pages;
> > +
> > +	zram = bdev->bd_disk->private_data;
> > +	if (!zram->limit_pages)
> > +		return 0;
> > +
> > +	meta = zram->meta;
> > +	total_pages = zs_get_total_pages(meta->mem_pool);
> > +
> > +	if (total_pages >= zram->limit_pages) {
> > +
> > +		compr_pages = atomic64_read(&zram->stats.compr_data_size)
> > +					>> PAGE_SHIFT;
> > +		if ((100 * compr_pages / total_pages)
> > +			>= ZRAM_FULLNESS_PERCENT)
> > +			return 1;
> > +	}
> > +
> > +	if (atomic_read(&zram->alloc_fail) > ALLOC_FAIL_MAX)
> > +		return 1;
> > +
> > +	return 0;
> > +}
> > +
> >  static int zram_swap_hint(struct block_device *bdev,
> >  				unsigned int hint, void *arg)
> >  {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
