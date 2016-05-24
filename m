Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id D884F6B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 04:17:09 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id x1so7446965pav.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 01:17:09 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l76si22424986pfj.253.2016.05.24.01.17.07
        for <linux-mm@kvack.org>;
        Tue, 24 May 2016 01:17:08 -0700 (PDT)
Date: Tue, 24 May 2016 17:17:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 11/12] zsmalloc: page migration support
Message-ID: <20160524081721.GC29094@bbox>
References: <1463754225-31311-1-git-send-email-minchan@kernel.org>
 <1463754225-31311-12-git-send-email-minchan@kernel.org>
 <20160524052824.GA496@swordfish>
 <20160524062801.GB29094@bbox>
 <20160524080511.GB496@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160524080511.GB496@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, May 24, 2016 at 05:05:11PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (05/24/16 15:28), Minchan Kim wrote:
> [..]
> > Most important point to me is that it makes code *simple* at the cost of
> > addtional wasting memory. Now, every zspage lives in *a* list so we don't
> > need to check zspage groupness to use list_empty of zspage.
> > I'm not sure how you feel it makes code simple a lot.
> > However, while I implement page migration logic, the check with condition
> > that zspage's groupness is either almost_empty and almost_full is really
> > bogus and tricky to me so I should debug several time to find what's
> > wrong.
> > 
> > Compared to old, zsmalloc is complicated day by day so I want to weight
> > on *simple* for easy maintainance.
> > 
> > One more note:
> > Now, ZS_EMPTY is used as pool. Look at find_get_zspage. So adding
> > "empty" column in ZSMALLOC_STAT might be worth but I wanted to handle it
> > as another topic.
> > 
> > So if you don't feel strong the saving is really huge, I want to
> > go with this. And if we are adding more wasted memory in future,
> > let's handle it then.
> 
> oh, sure, all those micro-optimizations can be done later,
> off the series.
> 
> > About CONFIG_ZSMALLOC_STAT, It might be off-topic. Frankly speaking,
> > I have guided production team to enable it because when I profile the
> > overhead caused by ZSMALLOC_STAT, there is no performance lost
> > in real workload. However, the stat gives more detailed useful
> > information.
> 
> ok, agree.
> good to know that you use stats in production, by the way.
> 
> [..]
> > > > +	pos = (((class->objs_per_zspage * class->size) *
> > > > +		page_idx / class->pages_per_zspage) / class->size
> > > > +	      ) * class->size;
> > > 
> > > 
> > > something went wrong with the indentation here :)
> > > 
> > > so... it's
> > > 
> > > 	(((class->objs_per_zspage * class->size) * page_idx / class->pages_per_zspage) / class->size ) * class->size;
> > > 
> > > the last ' / class->size ) * class->size' can be dropped, I think.
> > 
> > You prove I didn't learn math.
> > Will drop it.
> 
> haha, no, that wasn't the point :) great job with the series!
> 
> [..]
> > > hm... zsmalloc is getting sooo complex now.
> > > 
> > > `system_wq' -- can we have problems here when the system is getting
> > > low on memory and workers are getting increasingly busy trying to
> > > allocate the memory for some other purposes?
> > > 
> > > _theoretically_ zsmalloc can stack a number of ready-to-release zspages,
> > > which won't be accessible to zsmalloc, nor will they be released. how likely
> > > is this? hm, can zsmalloc take zspages from that deferred release list when
> > > it wants to allocate a new zspage?
> > 
> > Done.
> 
> oh, good. that was a purely theoretical thing, and to continue with the
> theories, I assume that zs_malloc() will improve with this change. the
> sort of kind of problem with zs_malloc(), *I think*, is that we release
> the class ->lock after failed find_get_zspage():
> 
> 	handle = cache_alloc_handle(pool, gfp);
> 	if (!handle)
> 		return 0;
> 
> 	zspage = find_get_zspage(class);
> 	if (likely(zspage)) {
> 		obj = obj_malloc(class, zspage, handle);
> 		[..]
> 		spin_unlock(&class->lock);
> 
> 		return handle;
> 	}
> 
> 	spin_unlock(&class->lock);
> 
> 	zspage = alloc_zspage(pool, class, gfp);
> 	if (!zspage) {
> 		cache_free_handle(pool, handle);
> 		return 0;
> 	}
> 
> 	spin_lock(&class->lock);
> 	obj = obj_malloc(class, zspage, handle);
> 	[..]
> 	spin_unlock(&class->lock);
> 
> 
> _theoretically_, on a not-really-huge system, let's say 64 CPUs for
> example, we can have 64 write paths trying to store objects of size
> OBJ_SZ to a ZS_FULL class-OBJSZ. the write path (each of them) will
> fail on find_get_zspage(), unlock the class ->lock (so another write
> path will have its chance to fail on find_get_zspage()), alloc_zspage(),
> create a page chain, spin on class ->lock to add the new zspage to the
> class. so we can end up allocating up to 64 zspages, each of them will
> carry N PAGE_SIZE pages. those zspages, at least at the beginning, will
> store only one object per-zspage; which will blastoff the internal
> fragmentation and can cause more compaction/migration/etc later on. well,
> it's a bit pessimistic, but I think to _some extent_ this scenario is
> quite possible.
> 
> I assume that this "pick an already marked for release zspage" thing is
> happening as a fast path within the first class ->lock section, so the
> rest of concurrent write requests that are spinning on the class ->lock
> at the moment will see a zspage, instead of !find_get_zspage().

As well, we would reduce page alloc/free cost although it's not expensive
compared to comp overhead. :)

Thanks for giving the thought!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
