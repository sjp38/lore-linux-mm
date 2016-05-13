Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D65C06B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 19:05:13 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gw7so167702416pac.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 16:05:13 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a13si26865537pfc.215.2016.05.13.16.05.12
        for <linux-mm@kvack.org>;
        Fri, 13 May 2016 16:05:12 -0700 (PDT)
Date: Sat, 14 May 2016 08:05:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: introduce per-device debug_stat sysfs node
Message-ID: <20160513230546.GA26763@bbox>
References: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
 <20160512234143.GA27204@bbox>
 <20160513010929.GA615@swordfish>
 <20160513062303.GA21204@bbox>
 <20160513065805.GB615@swordfish>
 <20160513070553.GC615@swordfish>
 <20160513072006.GA21484@bbox>
 <20160513080643.GE615@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160513080643.GE615@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Sergey,

On Fri, May 13, 2016 at 05:06:43PM +0900, Sergey Senozhatsky wrote:
> On (05/13/16 16:20), Minchan Kim wrote:
> > > > > @@ -737,12 +737,12 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> > > > >  		zcomp_strm_release(zram->comp, zstrm);
> > > > >  		zstrm = NULL;
> > > > >  
> > > > > -		atomic64_inc(&zram->stats.num_recompress);
> > > > > -
> > > > >  		handle = zs_malloc(meta->mem_pool, clen,
> > > > >  				GFP_NOIO | __GFP_HIGHMEM);
> > > > > -		if (handle)
> > > > > +		if (handle) {
> > > > > +			atomic64_inc(&zram->stats.num_recompress);
> > > > >  			goto compress_again;
> > > > > +		}
> 
> 
> just a small note:
> 
> > Although 2 is smaller, your patch just accounts only direct reclaim but my
> > suggestion can count both 1 and 2 so isn't it better?
> 
> no, my patch accounts 1) and 2) as well. the only difference is that my
> patch accounts second zs_malloc() call _EVEN_ if it has failed and we
> jumped to goto err (because we still could have done reclaim). the new
> version would account second zs_malloc() _ONLY_ if it has succeeded, and
> thus possibly reclaim would not be accounted.
> 
> 
> recompress:
> 	compress
> 	handle = zs_malloc FAST PATH
> 
> 	if (!handle) {
> 		release stream
> 		handle = zs_malloc SLOW PATH
> 
> 		<< my patch accounts SLOW PATH here >>
> 
> 		if (handle) {
> 			num_recompress++  << NEW version accounts it here, only it was OK >>
> 			goto recompress;
> 		}
> 
> 		goto err;    << SLOW PATH is not accounted if SLOW PATH was unsuccessful
> 	}
> 

I got your point. You want to account every slow path and change
the naming from num_recompress to something to show that slow path.
Sorry for catching your point too late. And I absolutely agree with you.
I want to name it with 'writestall' like MM's allocstall. :)
Now I saw you sent new version but I like your suggestion more.

I will send new verion by hand :)
Thanks for the arguing. It was worth!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
