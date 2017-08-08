Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49C366B0292
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 11:48:10 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 16so38408947pgg.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 08:48:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j21si979177pgn.452.2017.08.08.08.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 08:48:09 -0700 (PDT)
Date: Tue, 8 Aug 2017 08:48:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1 5/6] zram: remove zram_rw_page
Message-ID: <20170808154806.GD31390@bombadil.infradead.org>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-6-git-send-email-minchan@kernel.org>
 <20170808070226.GC7765@jagdpanzerIV.localdomain>
 <20170808081338.GA30908@bbox>
 <20170808082350.GD7765@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808082350.GD7765@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, Aug 08, 2017 at 05:23:50PM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (08/08/17 17:13), Minchan Kim wrote:
> > Hi Sergey,
> > 
> > On Tue, Aug 08, 2017 at 04:02:26PM +0900, Sergey Senozhatsky wrote:
> > > On (08/08/17 15:50), Minchan Kim wrote:
> > > > With on-stack-bio, rw_page interface doesn't provide a clear performance
> > > > benefit for zram and surely has a maintenance burden, so remove the
> > > > last user to remove rw_page completely.
> > > 
> > > OK, never really liked it, I think we had that conversation before.
> > > 
> > > as far as I remember, zram_rw_page() was the reason we had to do some
> > > tricks with init_lock to make lockdep happy. may be now we can "simplify"
> > > the things back.
> > 
> > I cannot remember. Blame my brain. ;-)
> 
> no worries. I didn't remember it clearly as well, hence the "may be" part.
> 
> commit 08eee69fcf6baea543a2b4d2a2fcba0e61aa3160
> Author: Minchan Kim
> 
>     zram: remove init_lock in zram_make_request
>     
>     Admin could reset zram during I/O operation going on so we have used
>     zram->init_lock as read-side lock in I/O path to prevent sudden zram
>     meta freeing.
>     
>     However, the init_lock is really troublesome.  We can't do call
>     zram_meta_alloc under init_lock due to lockdep splat because
>     zram_rw_page is one of the function under reclaim path and hold it as
>     read_lock while other places in process context hold it as write_lock.
>     So, we have used allocation out of the lock to avoid lockdep warn but
>     it's not good for readability and fainally, I met another lockdep splat
>     between init_lock and cpu_hotplug from kmem_cache_destroy during working
>     zsmalloc compaction.  :(

I don't think this patch is going to change anything with respect to the
use of init_lock.  You're still going to be called in the reclaim path,
no longer through rw_page, but through the bio path instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
