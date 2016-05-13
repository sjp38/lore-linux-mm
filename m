Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1096B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 04:05:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so192007104pfb.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:05:44 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id q11si23135030pfi.106.2016.05.13.01.05.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 01:05:43 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id y7so8779248pfb.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:05:43 -0700 (PDT)
Date: Fri, 13 May 2016 17:06:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: introduce per-device debug_stat sysfs node
Message-ID: <20160513080643.GE615@swordfish>
References: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
 <20160512234143.GA27204@bbox>
 <20160513010929.GA615@swordfish>
 <20160513062303.GA21204@bbox>
 <20160513065805.GB615@swordfish>
 <20160513070553.GC615@swordfish>
 <20160513072006.GA21484@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160513072006.GA21484@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (05/13/16 16:20), Minchan Kim wrote:
> > > > @@ -737,12 +737,12 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> > > >  		zcomp_strm_release(zram->comp, zstrm);
> > > >  		zstrm = NULL;
> > > >  
> > > > -		atomic64_inc(&zram->stats.num_recompress);
> > > > -
> > > >  		handle = zs_malloc(meta->mem_pool, clen,
> > > >  				GFP_NOIO | __GFP_HIGHMEM);
> > > > -		if (handle)
> > > > +		if (handle) {
> > > > +			atomic64_inc(&zram->stats.num_recompress);
> > > >  			goto compress_again;
> > > > +		}


just a small note:

> Although 2 is smaller, your patch just accounts only direct reclaim but my
> suggestion can count both 1 and 2 so isn't it better?

no, my patch accounts 1) and 2) as well. the only difference is that my
patch accounts second zs_malloc() call _EVEN_ if it has failed and we
jumped to goto err (because we still could have done reclaim). the new
version would account second zs_malloc() _ONLY_ if it has succeeded, and
thus possibly reclaim would not be accounted.


recompress:
	compress
	handle = zs_malloc FAST PATH

	if (!handle) {
		release stream
		handle = zs_malloc SLOW PATH

		<< my patch accounts SLOW PATH here >>

		if (handle) {
			num_recompress++  << NEW version accounts it here, only it was OK >>
			goto recompress;
		}

		goto err;    << SLOW PATH is not accounted if SLOW PATH was unsuccessful
	}


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
