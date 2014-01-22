Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 919316B0036
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 22:06:15 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id c41so1230381yho.6
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 19:06:15 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id s6si8726275yho.139.2014.01.21.19.06.12
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 19:06:14 -0800 (PST)
Date: Wed, 22 Jan 2014 14:06:07 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140122030607.GB27606@dastard>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <20140117000517.GB18112@dastard>
 <20140120231737.GS6963@cmpxchg.org>
 <20140121030358.GN18112@dastard>
 <20140121055017.GT6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140121055017.GT6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jan 21, 2014 at 12:50:17AM -0500, Johannes Weiner wrote:
> On Tue, Jan 21, 2014 at 02:03:58PM +1100, Dave Chinner wrote:
> > On Mon, Jan 20, 2014 at 06:17:37PM -0500, Johannes Weiner wrote:
> > > On Fri, Jan 17, 2014 at 11:05:17AM +1100, Dave Chinner wrote:
> > > > On Fri, Jan 10, 2014 at 01:10:43PM -0500, Johannes Weiner wrote:
> > > > > +static struct shrinker workingset_shadow_shrinker = {
> > > > > +	.count_objects = count_shadow_nodes,
> > > > > +	.scan_objects = scan_shadow_nodes,
> > > > > +	.seeks = DEFAULT_SEEKS * 4,
> > > > > +	.flags = SHRINKER_NUMA_AWARE,
> > > > > +};
> > > > 
> > > > Can you add a comment explaining how you calculated the .seeks
> > > > value? It's important to document the weighings/importance
> > > > we give to slab reclaim so we can determine if it's actually
> > > > acheiving the desired balance under different loads...
> > > 
> > > This is not an exact science, to say the least.
> > 
> > I know, that's why I asked it be documented rather than be something
> > kept in your head.
> > 
> > > The shadow entries are mostly self-regulated, so I don't want the
> > > shrinker to interfere while the machine is just regularly trimming
> > > caches during normal operation.
> > > 
> > > It should only kick in when either a) reclaim is picking up and the
> > > scan-to-reclaim ratio increases due to mapped pages, dirty cache,
> > > swapping etc. or b) the number of objects compared to LRU pages
> > > becomes excessive.
> > > 
> > > I think that is what most shrinkers with an elevated seeks value want,
> > > but this translates very awkwardly (and not completely) to the current
> > > cost model, and we should probably rework that interface.
> > > 
> > > "Seeks" currently encodes 3 ratios:
> > > 
> > >   1. the cost of creating an object vs. a page
> > > 
> > >   2. the expected number of objects vs. pages
> > 
> > It doesn't encode that at all. If it did, then the default value
> > wouldn't be "2".
> >
> > >   3. the cost of reclaiming an object vs. a page
> > 
> > Which, when you consider #3 in conjunction with #1, the actual
> > intended meaning of .seeks is "the cost of replacing this object in
> > the cache compared to the cost of replacing a page cache page."
> 
> But what it actually seems to do is translate scan rate from LRU pages
> to scan rate in another object pool.  The actual replacement cost
> varies based on hotness of each set, an in-use object is more
> expensive to replace than a cold page and vice versa, the dentry and
> inode shrinkers reflect this by rotating hot objects and refusing to
> actually reclaim items while they are in active use.

Right, but so does the page cache when the page referenced bit is
seen by the LRU scanner. That's a scanned page, so what is passed to
shrink_slab is a ratio of pages scanned vs pages eligible for
reclaim. IOWs, the fact that the slab caches rotate rather than
reclaim is irrelevant - what matters is the same proportional
pressure is applied to the slab cache that was applied to the page
cache....

> So I am having a hard time deriving a meaningful value out of this
> definition for my usecase because I want to push back objects based on
> reclaim efficiency (scan rate vs. reclaim rate).  The other shrinkers
> with non-standard seek settings reek of magic number as well, which
> suggests I am not alone with this.

Right, which is exactly why I'm asking you to document it. I've got
no idea how other subsystems have come up with their magic numbers
because they are not documented, and so it's just about impossible
to determine what the author of the code really needed and hence the
best way to improve the interface is difficult to determine.

> I wonder if we can come up with a better interface that allows both
> traditional cache shrinkers with their own aging, as well as object
> pools that want to push back based on reclaim efficiency.

We probably can, though I'd prefer we don't end up with some
alternative algorithm that is specific to a single shrinker.

So, how do we measure page cache reclaim efficiency? How can that be
communicated to a shrinker? how can we tell a shrinker what measure
to use? How do we tell shrinker authors what measure to use?  How do
we translate that new method useful scan count information?

> > > but they are not necessarily correlated.  How I would like to
> > > configure the shadow shrinker instead is:
> > > 
> > >   o scan objects when reclaim efficiency is down to 75%, because they
> > >     are more valuable than use-once cache but less than workingset
> > > 
> > >   o scan objects when the ratio between them and the number of pages
> > >     exceeds 1/32 (one shadow entry for each resident page, up to 64
> > >     entries per shrinkable object, assume 50% packing for robustness)
> > > 
> > >   o as the expected balance between objects and lru pages is 1:32,
> > >     reclaim one object for every 32 reclaimed LRU pages, instead of
> > >     assuming that number of scanned pages corresponds meaningfully to
> > >     number of objects to scan.
> > 
> > You're assuming that every radix tree node has a full population of
> > pages. This only occurs on sequential read and write workloads, and
> > so isn't going tobe true for things like mapped executables or any
> > semi-randomly accessed data set...
> 
> No, I'm assuming 50% population on average for that reason.  I don't
> know how else I could assign a fixed value to a variable object.

Ok, I should have say "fixed population", not "full population". Do
you have any stats on the typical mapping tree radix node population
on running systems?

> > > "4" just doesn't have the same ring to it.
> > 
> > Right, but you still haven't explained how you came to the value of
> > "4"....
> 
> It's a complete magic number.  The tests I ran suggested lower numbers
> throw out shadow entries prematurely, whereas higher numbers thrash
> the working set while there are plenty radix tree nodes present.

That, at minimum, needs to be in a comment so that people have some
idea of how the magic number biases behaviour. ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
