Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0DF6B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 17:43:57 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f4so2955293wre.9
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 14:43:57 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a8si252133edn.479.2017.12.06.14.43.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Dec 2017 14:43:50 -0800 (PST)
Date: Wed, 6 Dec 2017 17:43:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 06/11] writeback: add counters for metadata usage
Message-ID: <20171206224342.GA4547@cmpxchg.org>
References: <1511385366-20329-1-git-send-email-josef@toxicpanda.com>
 <1511385366-20329-7-git-send-email-josef@toxicpanda.com>
 <20171204130630.GB17047@quack2.suse.cz>
 <20171206201833.trvfyz4pldetr2cv@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206201833.trvfyz4pldetr2cv@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Wed, Dec 06, 2017 at 03:18:35PM -0500, Josef Bacik wrote:
> On Mon, Dec 04, 2017 at 02:06:30PM +0100, Jan Kara wrote:
> > On Wed 22-11-17 16:16:01, Josef Bacik wrote:
> > > diff --git a/mm/util.c b/mm/util.c
> > > index 34e57fae959d..681d62631ee0 100644
> > > --- a/mm/util.c
> > > +++ b/mm/util.c
> > > @@ -616,6 +616,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
> > >  	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
> > >  		free = global_zone_page_state(NR_FREE_PAGES);
> > >  		free += global_node_page_state(NR_FILE_PAGES);
> > > +		free += global_node_page_state(NR_METADATA_BYTES) >> PAGE_SHIFT;
> > 
> > 
> > I'm not really sure this is OK. It depends on whether mm is really able to
> > reclaim these pages easily enough... Summon mm people for help :)
> > 
> 
> Well we count NR_SLAB_RECLAIMABLE here, so it's no different than that.  The
> point is that it's theoretically reclaimable, and we should at least try.

I agree with including metadata in the equation. The (somewhat dusty)
overcommit code is mostly for containing swap storms, which is why it
adds up all the reclaimable pools that aren't backed by swap. The
metadata pool belongs in that category.

> > > @@ -3812,6 +3813,7 @@ static inline unsigned long node_unmapped_file_pages(struct pglist_data *pgdat)
> > >  static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
> > >  {
> > >  	unsigned long nr_pagecache_reclaimable;
> > > +	unsigned long nr_metadata_reclaimable;
> > >  	unsigned long delta = 0;
> > >  
> > >  	/*
> > > @@ -3833,7 +3835,20 @@ static unsigned long node_pagecache_reclaimable(struct pglist_data *pgdat)
> > >  	if (unlikely(delta > nr_pagecache_reclaimable))
> > >  		delta = nr_pagecache_reclaimable;
> > >  
> > > -	return nr_pagecache_reclaimable - delta;
> > > +	nr_metadata_reclaimable =
> > > +		node_page_state(pgdat, NR_METADATA_BYTES) >> PAGE_SHIFT;
> > > +	/*
> > > +	 * We don't do writeout through the shrinkers so subtract any
> > > +	 * dirty/writeback metadata bytes from the reclaimable count.
> > > +	 */
> > > +	if (nr_metadata_reclaimable) {
> > > +		unsigned long unreclaimable =
> > > +			node_page_state(pgdat, NR_METADATA_DIRTY_BYTES) +
> > > +			node_page_state(pgdat, NR_METADATA_WRITEBACK_BYTES);
> > > +		unreclaimable >>= PAGE_SHIFT;
> > > +		nr_metadata_reclaimable -= unreclaimable;
> > > +	}
> > > +	return nr_metadata_reclaimable + nr_pagecache_reclaimable - delta;
> > >  }
> > 
> > Ditto as with __vm_enough_memory(). In particular I'm unsure whether the
> > watermarks like min_unmapped_pages or min_slab_pages would still work as
> > designed.
> > 
> 
> Yeah agreed I'd like an MM person's thoughts on this as well.  We don't count
> SLAB_RECLAIMABLE here, but that's because it's just not related to pagecache.  I
> guess it only matters for node reclaim and we have our node reclaim stuff turned
> off, which means it doesn't help us anyway, so I'm happy to just drop it and let
> somebody who cares about node reclaim think about it later ;).  Thanks,

Few people care about node reclaim at this point, see 4f9b16a64753
("mm: disable zone_reclaim_mode by default"), and it's honestly a bit
baffling why we made min_slab_ratio a tunable in the first place. Who
knows how/if anybody relies on that behavior. I'd just leave it alone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
