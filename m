Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3265D6B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 12:25:38 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id kq3so63501808wjc.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 09:25:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18si17262012wra.151.2017.01.30.09.25.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 09:25:37 -0800 (PST)
Date: Mon, 30 Jan 2017 18:25:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/9] bcache: use kvmalloc
Message-ID: <20170130172535.GC14783@dhcp22.suse.cz>
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-9-mhocko@kernel.org>
 <28e7a4de-6940-5626-d382-1381640d58f0@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28e7a4de-6940-5626-d382-1381640d58f0@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Kent Overstreet <kent.overstreet@gmail.com>

On Mon 30-01-17 17:47:31, Vlastimil Babka wrote:
> On 01/30/2017 10:49 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > bcache_device_init uses kmalloc for small requests and vmalloc for those
> > which are larger than 64 pages. This alone is a strange criterion.
> > Moreover kmalloc can fallback to vmalloc on the failure. Let's simply
> > use kvmalloc instead as it knows how to handle the fallback properly
> 
> I don't see why separate patch, some of the conversions in 5/9 were quite
> similar (except comparing with PAGE_SIZE, not 64*PAGE_SIZE), but nevermind.

I just found it later so I kept it separate. It can be folded to 5/9 if
that makes more sense.
 
> > Cc: Kent Overstreet <kent.overstreet@gmail.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> > ---
> >  drivers/md/bcache/super.c | 8 ++------
> >  1 file changed, 2 insertions(+), 6 deletions(-)
> > 
> > diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
> > index 3a19cbc8b230..4cb6b88a1465 100644
> > --- a/drivers/md/bcache/super.c
> > +++ b/drivers/md/bcache/super.c
> > @@ -767,16 +767,12 @@ static int bcache_device_init(struct bcache_device *d, unsigned block_size,
> >  	}
> > 
> >  	n = d->nr_stripes * sizeof(atomic_t);
> > -	d->stripe_sectors_dirty = n < PAGE_SIZE << 6
> > -		? kzalloc(n, GFP_KERNEL)
> > -		: vzalloc(n);
> > +	d->stripe_sectors_dirty = kvzalloc(n, GFP_KERNEL);
> >  	if (!d->stripe_sectors_dirty)
> >  		return -ENOMEM;
> > 
> >  	n = BITS_TO_LONGS(d->nr_stripes) * sizeof(unsigned long);
> > -	d->full_dirty_stripes = n < PAGE_SIZE << 6
> > -		? kzalloc(n, GFP_KERNEL)
> > -		: vzalloc(n);
> > +	d->full_dirty_stripes = kvzalloc(n, GFP_KERNEL);
> >  	if (!d->full_dirty_stripes)
> >  		return -ENOMEM;
> > 
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
