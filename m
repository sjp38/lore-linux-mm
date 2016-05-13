Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D900C6B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 03:19:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b203so190318560pfb.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 00:19:34 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u90si22859370pfa.250.2016.05.13.00.19.32
        for <linux-mm@kvack.org>;
        Fri, 13 May 2016 00:19:32 -0700 (PDT)
Date: Fri, 13 May 2016 16:20:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: introduce per-device debug_stat sysfs node
Message-ID: <20160513072006.GA21484@bbox>
References: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
 <20160512234143.GA27204@bbox>
 <20160513010929.GA615@swordfish>
 <20160513062303.GA21204@bbox>
 <20160513065805.GB615@swordfish>
 <20160513070553.GC615@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160513070553.GC615@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 13, 2016 at 04:05:53PM +0900, Sergey Senozhatsky wrote:
> On (05/13/16 15:58), Sergey Senozhatsky wrote:
> > On (05/13/16 15:23), Minchan Kim wrote:
> > [..]
> > > @@ -737,12 +737,12 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> > >  		zcomp_strm_release(zram->comp, zstrm);
> > >  		zstrm = NULL;
> > >  
> > > -		atomic64_inc(&zram->stats.num_recompress);
> > > -
> > >  		handle = zs_malloc(meta->mem_pool, clen,
> > >  				GFP_NOIO | __GFP_HIGHMEM);
> > > -		if (handle)
> > > +		if (handle) {
> > > +			atomic64_inc(&zram->stats.num_recompress);
> > >  			goto compress_again;
> > > +		}
> > 
> > not like a real concern...
> > 
> > the main (and only) purpose of num_recompress is to match performance
> > slowdowns and failed fast write paths (when the first zs_malloc() fails).
> > this matching is depending on successful second zs_malloc(), but if it's
> > also unsuccessful we would only increase failed_writes; w/o increasing
> > the failed fast write counter, while we actually would have failed fast
> > write and extra zs_malloc() [unaccounted in this case]. yet it's probably
> > a bit unlikely to happen, but still. well, just saying.
> 
> here I assume that the biggest contributor to re-compress latency is
> enabled preemption after zcomp_strm_release() and this second zs_malloc().
> the compression itself of a PAGE_SIZE buffer should be fast enough. so IOW
> we would pass down the slow path, but would not account it.

biggest contributors are 1. direct reclaim by second zsmalloc call +
                         2. recompression overhead.

If zram start to support high comp ratio but slow speed algorithm like zlib
2 might be higher than 1 in the future so let's not ignore 2 overhead.

Although 2 is smaller, your patch just accounts only direct reclaim but my
suggestion can count both 1 and 2 so isn't it better?

I don't know why it's arguable here. :)

> 
> 	-ss
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
