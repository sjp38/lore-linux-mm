Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC8266B02C3
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 00:43:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p1so151121554pfl.2
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 21:43:03 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id v23si16290093pfj.327.2017.07.04.21.43.01
        for <linux-mm@kvack.org>;
        Tue, 04 Jul 2017 21:43:01 -0700 (PDT)
Date: Wed, 5 Jul 2017 13:43:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170705044300.GB20079@bbox>
References: <20170614064045.GA19843@bbox>
 <20170619151120.GA11245@destiny>
 <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
 <20170630021713.GB24520@bbox>
 <20170630150322.GB9743@destiny>
 <20170703013303.GA2567@bbox>
 <20170703135006.GC27097@destiny>
 <20170704030100.GA16432@bbox>
 <20170704132136.GB6807@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170704132136.GB6807@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com, david@fromorbit.com

On Tue, Jul 04, 2017 at 09:21:37AM -0400, Josef Bacik wrote:
> On Tue, Jul 04, 2017 at 12:01:00PM +0900, Minchan Kim wrote:
> > On Mon, Jul 03, 2017 at 09:50:07AM -0400, Josef Bacik wrote:
> > > On Mon, Jul 03, 2017 at 10:33:03AM +0900, Minchan Kim wrote:
> > > > Hello,
> > > > 
> > > > On Fri, Jun 30, 2017 at 11:03:24AM -0400, Josef Bacik wrote:
> > > > > On Fri, Jun 30, 2017 at 11:17:13AM +0900, Minchan Kim wrote:
> > > > > 
> > > > > <snip>
> > > > > 
> > > > > > > 
> > > > > > > Because this static step down wastes cycles.  Why loop 10 times when you could
> > > > > > > set the target at actual usage and try to get everything in one go?  Most
> > > > > > > shrinkable slabs adhere to this default of in use first model, which means that
> > > > > > > we have to hit an object in the lru twice before it is freed.  So in order to
> > > > > > 
> > > > > > I didn't know that.
> > > > > > 
> > > > > > > reclaim anything we have to scan a slab cache's entire lru at least once before
> > > > > > > any reclaim starts happening.  If we're doing this static step down thing we
> > > > > > 
> > > > > > If it's really true, I think that shrinker should be fixed first.
> > > > > > 
> > > > > 
> > > > > Easier said than done.  I've fixed this for the super shrinkers, but like I said
> > > > > below, all it takes is some asshole doing find / -exec stat {} \; twice to put
> > > > > us back in the same situation again.  There's no aging mechanism other than
> > > > > memory reclaim, so we get into this shitty situation of aging+reclaiming at the
> > > > > same time.
> > > > 
> > > > What's different with normal page cache problem?
> > > > 
> > > 
> > > What's different is reclaiming a page from pagecache gives you a page,
> > > reclaiming 10k objects from slab may only give you one page if you are super
> > > unlucky.  I'm nothing in life if I'm not unlucky.
> > > 
> > > > It has the same problem you mentioned so need to peek what VM does to
> > > > address it.
> > > > 
> > > > It has two LRU list, active and inactive and maintain the size ratio 1:1.
> > > > New page is on inactive and if they are two-touched, the page will be
> > > > promoted into active list which is same problem.
> > > > However, once reclaim is triggered, VM will can move quickly them from
> > > > active to inactive with remove referenced flag untill the ratio is matched.
> > > > So, VM can reclaim pages from inactive list, easily.
> > > > 
> > > > Can we apply similar mechanism into the problematical slab?
> > > > How about adding shrink_slab(xxx, ACTIVE|INACTIVE) in somewhere of VM
> > > > for demotion of objects from active list and adding the logic to move
> > > > inactive object to active list when the cache hit happens to the FS?
> > > > 
> > > 
> > > I did this too!  This worked out ok, but was a bit complex and the problem was
> > > solved just as well by dropping the INUSE first approach.  I think that Dave's
> > > approach to having a separate aging mechanism is a good compliment to these
> > > patches.
> > 
> > There are two problems you are try to address.
> > 
> > 1. slab *page* reclaim
> > 
> > Your claim is that it's hard to reclaim a page by slab fragmentation so need to
> > reclaim objects more aggressively.
> > 
> > Basically, aggressive scanning doesn't guarantee to reclaim a page but it just
> > increases the possibility. Even, if we think slab works with merging feature(i.e.,
> > it mixes same size several type objects in a slab), the possibility will be huge
> > dropped if you try to bail out on a certain shrinker. So for working well,
> > we should increase aggressiveness too much to sweep every objects from all shrinker.
> > I guess that's why your patch makes the logic very aggressive.
> > In here, my concern with that aggressive is to reclaim all objects too early
> > and it ends up making void caching scheme. I'm not sure it's gain in the end.
> >
> 
> Well the fact is what we have doesn't work, and I've been staring at this
> problem for a few months and I don't have a better solution.
> 
> And keep in mind we're talking about a purely slab workload, something that
> isn't likely to be a common case.  And even if our scan target is 2x, we aren't
> going to reclaim the entire cache before we bail out.  We only scan in
> 'batch_size' chunks, which generally is 1024.  In the worst case that we have

I replied your new patchset. It breaks fair aging.

> one in use object on every slab page we own then yes we're fucked, but we're
> still fucked with the current code, only with the current code it'll take us 20
> minutes of looping in the vm vs. seconds scanning the whole list twice.

Don't get me wrong. As I replied at first discussion, I tend to agree
increase aggressiveness. What I dislike is your patch increases it too much
via SLAB/LRU ratio. It can reclaim all of objects although memory pressure
is not severe but small LRU/big SLAB.

You said we can bail out but it breaks aging problem between shrinkers
as reply of new patch.

As well, gslab/lru ratio is totally out of control from VM pov.
IMO, VM want to define hot workingset with survival pages although it
has twice full scan(1/4096 + 1/2048 + ....  1/1) so if VM cannot see
any progress in that full scan until MAX_RECLAIM_RETRIES(16), it decide
to kill some process although there are reclaimable pages in there.

Like that, VM need some guide line to guarantee. However, if we use
SLAB/LRU ratio, it can scan all of objects twice from the beginning.
It means it can 24 full scan in reclaim iteration. Also, it can be
changed with SLAB/LRU ratio so it's really unpredictable.

> 
> > 2. stream-workload
> > 
> > Your claim is that every objects can have INUSE flag in that workload so they
> > need to scan full-cycle with removing the flag and finally, next cycle,
> > objects can be reclaimed. On the situation, static incremental scanning would
> > make deep prorioty drop which causes unncessary CPU cycle waste.
> > 
> > Actually, there isn't nice solution for that at the moment. Page cache try
> > to solve it with multi-level LRU and as you said, it would solve the
> > problem. However, it would be too complicated so you could be okay with
> > Dave's suggestion which periodic aging(i.e., LFU) but it's not free so that
> > it could increase runtime latency.
> > 
> > The point is that such workload is hard to solve in general and just
> > general agreessive scanning is not a good solution because it can sweep
> > other shrinkers which don't have such problem so I hope it should be
> > solved by a specific shrinker itself rather than general VM level.
> 
> The only problem I see here is our shrinker list is just a list, there's no
> order or anything and we just walk through one at a time.  We could mitigate

I don't get it. Why do you think ordered list solves this stream-workload
issues?

> this problem by ordering the list based on objects, but this isn't necessarily a
> good indication of overall size.  Consider xfs_buf, where each slab object is
> also hiding 1 page, so for every slab object we free we also free 1 page.  This
> may appear to be a smaller slab by object measures, but may actually be larger.
> We could definitely make this aspect of the shrinker smarter, but these patches
> here need to still be in place in general to solve the problem of us not being
> aggressive enough currently.  Thanks,
> 
> Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
