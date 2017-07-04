Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5ADDF6B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 23:01:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 1so154894927pfi.14
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 20:01:03 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d12si13763352pln.478.2017.07.03.20.01.01
        for <linux-mm@kvack.org>;
        Mon, 03 Jul 2017 20:01:02 -0700 (PDT)
Date: Tue, 4 Jul 2017 12:01:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170704030100.GA16432@bbox>
References: <20170613052802.GA16061@bbox>
 <20170613120156.GA16003@destiny>
 <20170614064045.GA19843@bbox>
 <20170619151120.GA11245@destiny>
 <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
 <20170630021713.GB24520@bbox>
 <20170630150322.GB9743@destiny>
 <20170703013303.GA2567@bbox>
 <20170703135006.GC27097@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170703135006.GC27097@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com, david@fromorbit.com

On Mon, Jul 03, 2017 at 09:50:07AM -0400, Josef Bacik wrote:
> On Mon, Jul 03, 2017 at 10:33:03AM +0900, Minchan Kim wrote:
> > Hello,
> > 
> > On Fri, Jun 30, 2017 at 11:03:24AM -0400, Josef Bacik wrote:
> > > On Fri, Jun 30, 2017 at 11:17:13AM +0900, Minchan Kim wrote:
> > > 
> > > <snip>
> > > 
> > > > > 
> > > > > Because this static step down wastes cycles.  Why loop 10 times when you could
> > > > > set the target at actual usage and try to get everything in one go?  Most
> > > > > shrinkable slabs adhere to this default of in use first model, which means that
> > > > > we have to hit an object in the lru twice before it is freed.  So in order to
> > > > 
> > > > I didn't know that.
> > > > 
> > > > > reclaim anything we have to scan a slab cache's entire lru at least once before
> > > > > any reclaim starts happening.  If we're doing this static step down thing we
> > > > 
> > > > If it's really true, I think that shrinker should be fixed first.
> > > > 
> > > 
> > > Easier said than done.  I've fixed this for the super shrinkers, but like I said
> > > below, all it takes is some asshole doing find / -exec stat {} \; twice to put
> > > us back in the same situation again.  There's no aging mechanism other than
> > > memory reclaim, so we get into this shitty situation of aging+reclaiming at the
> > > same time.
> > 
> > What's different with normal page cache problem?
> > 
> 
> What's different is reclaiming a page from pagecache gives you a page,
> reclaiming 10k objects from slab may only give you one page if you are super
> unlucky.  I'm nothing in life if I'm not unlucky.
> 
> > It has the same problem you mentioned so need to peek what VM does to
> > address it.
> > 
> > It has two LRU list, active and inactive and maintain the size ratio 1:1.
> > New page is on inactive and if they are two-touched, the page will be
> > promoted into active list which is same problem.
> > However, once reclaim is triggered, VM will can move quickly them from
> > active to inactive with remove referenced flag untill the ratio is matched.
> > So, VM can reclaim pages from inactive list, easily.
> > 
> > Can we apply similar mechanism into the problematical slab?
> > How about adding shrink_slab(xxx, ACTIVE|INACTIVE) in somewhere of VM
> > for demotion of objects from active list and adding the logic to move
> > inactive object to active list when the cache hit happens to the FS?
> > 
> 
> I did this too!  This worked out ok, but was a bit complex and the problem was
> solved just as well by dropping the INUSE first approach.  I think that Dave's
> approach to having a separate aging mechanism is a good compliment to these
> patches.

There are two problems you are try to address.

1. slab *page* reclaim

Your claim is that it's hard to reclaim a page by slab fragmentation so need to
reclaim objects more aggressively.

Basically, aggressive scanning doesn't guarantee to reclaim a page but it just
increases the possibility. Even, if we think slab works with merging feature(i.e.,
it mixes same size several type objects in a slab), the possibility will be huge
dropped if you try to bail out on a certain shrinker. So for working well,
we should increase aggressiveness too much to sweep every objects from all shrinker.
I guess that's why your patch makes the logic very aggressive.
In here, my concern with that aggressive is to reclaim all objects too early
and it ends up making void caching scheme. I'm not sure it's gain in the end.

2. stream-workload

Your claim is that every objects can have INUSE flag in that workload so they
need to scan full-cycle with removing the flag and finally, next cycle,
objects can be reclaimed. On the situation, static incremental scanning would
make deep prorioty drop which causes unncessary CPU cycle waste.

Actually, there isn't nice solution for that at the moment. Page cache try
to solve it with multi-level LRU and as you said, it would solve the
problem. However, it would be too complicated so you could be okay with
Dave's suggestion which periodic aging(i.e., LFU) but it's not free so that
it could increase runtime latency.

The point is that such workload is hard to solve in general and just
general agreessive scanning is not a good solution because it can sweep
other shrinkers which don't have such problem so I hope it should be
solved by a specific shrinker itself rather than general VM level.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
