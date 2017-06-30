Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D27C96B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 22:17:16 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u62so106543892pgb.13
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 19:17:16 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id i127si4786759pgc.170.2017.06.29.19.17.14
        for <linux-mm@kvack.org>;
        Thu, 29 Jun 2017 19:17:15 -0700 (PDT)
Date: Fri, 30 Jun 2017 11:17:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170630021713.GB24520@bbox>
References: <1496949546-2223-1-git-send-email-jbacik@fb.com>
 <20170613052802.GA16061@bbox>
 <20170613120156.GA16003@destiny>
 <20170614064045.GA19843@bbox>
 <20170619151120.GA11245@destiny>
 <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170627135931.GA14097@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com, david@fromorbit.com

On Tue, Jun 27, 2017 at 09:59:32AM -0400, Josef Bacik wrote:
> On Tue, Jun 20, 2017 at 11:46:45AM +0900, Minchan Kim wrote:
> > Hello Josef,
> > 
> > On Mon, Jun 19, 2017 at 11:11:21AM -0400, Josef Bacik wrote:
> > > On Wed, Jun 14, 2017 at 03:40:45PM +0900, Minchan Kim wrote:
> > > > On Tue, Jun 13, 2017 at 08:01:57AM -0400, Josef Bacik wrote:
> > > > > On Tue, Jun 13, 2017 at 02:28:02PM +0900, Minchan Kim wrote:
> > > > > > Hello,
> > > > > > 
> > > > > > On Thu, Jun 08, 2017 at 03:19:05PM -0400, josef@toxicpanda.com wrote:
> > > > > > > From: Josef Bacik <jbacik@fb.com>
> > > > > > > 
> > > > > > > When testing a slab heavy workload I noticed that we often would barely
> > > > > > > reclaim anything at all from slab when kswapd started doing reclaim.
> > > > > > > This is because we use the ratio of nr_scanned / nr_lru to determine how
> > > > > > > much of slab we should reclaim.  But in a slab only/mostly workload we
> > > > > > > will not have much page cache to reclaim, and thus our ratio will be
> > > > > > > really low and not at all related to where the memory on the system is.
> > > > > > 
> > > > > > I want to understand this clearly.
> > > > > > Why nr_scanned / nr_lru is low if system doesnt' have much page cache?
> > > > > > Could you elaborate it a bit?
> > > > > > 
> > > > > 
> > > > > Yeah so for example on my freshly booted test box I have this
> > > > > 
> > > > > Active:            58840 kB
> > > > > Inactive:          46860 kB
> > > > > 
> > > > > Every time we do a get_scan_count() we do this
> > > > > 
> > > > > scan = size >> sc->priority
> > > > > 
> > > > > where sc->priority starts at DEF_PRIORITY, which is 12.  The first loop through
> > > > > reclaim would result in a scan target of 2 pages to 11715 total inactive pages,
> > > > > and 3 pages to 14710 total active pages.  This is a really really small target
> > > > > for a system that is entirely slab pages.  And this is super optimistic, this
> > > > > assumes we even get to scan these pages.  We don't increment sc->nr_scanned
> > > > > unless we 1) isolate the page, which assumes it's not in use, and 2) can lock
> > > > > the page.  Under pressure these numbers could probably go down, I'm sure there's
> > > > > some random pages from daemons that aren't actually in use, so the targets get
> > > > > even smaller.
> > > > > 
> > > > > We have to get sc->priority down a lot before we start to get to the 1:1 ratio
> > > > > that would even start to be useful for reclaim in this scenario.  Add to this
> > > > > that most shrinkable slabs have this idea that their objects have to loop
> > > > > through the LRU twice (no longer icache/dcache as Al took my patch to fix that
> > > > > thankfully) and you end up spending a lot of time looping and reclaiming
> > > > > nothing.  Basing it on actual slab usage makes more sense logically and avoids
> > > > > this kind of problem.  Thanks,
> > > > 
> > > > Thanks. I got understood now.
> > > > 
> > > > As I see your change, it seems to be rather aggressive to me.
> > > > 
> > > >         node_slab = lruvec_page_state(lruvec, NR_SLAB_RECLAIMABLE);
> > > >         shrink_slab(,,, node_slab >> sc->priority, node_slab);
> > > > 
> > > > The point is when we finish reclaiming from direct/background(ie, kswapd),
> > > > it makes sure that VM scanned slab object up to twice of the size which
> > > > is consistent with LRU pages.
> > > > 
> > > > What do you think about this?
> > > 
> > > Sorry for the delay, I was on a short vacation.  At first I thought this was a
> > > decent idea so I went to put it in there.  But there were some problems with it,
> > > and with sc->priority itself I beleive.  First the results were not great, we
> > > still end up not doing a lot of reclaim until we get down to the lower priority
> > > numbers.
> > > 
> > > The thing that's different with slab vs everybody else is that these numbers are
> > > a ratio, not a specific scan target amount.  With the other LRU's we do
> > 
> > Hmm, I don't get it why the ratio model is a problem.
> > My suggestion is to aim for scanning entire available objects list twice
> > in a reclaim cycle(priority from 12 to 0) which is consistent with LRU
> > reclaim. IOW, (1/4096 + 1/2048 + ... 1/1) * available object.
> > If it cannot reclaim pages with low priority(ie, 12), it try to reclaim
> > more objects in higher priority and finally, it try to reclaim every objects
> > at priority 1 and one more chance with priority 0.
> 
> Because this static step down wastes cycles.  Why loop 10 times when you could
> set the target at actual usage and try to get everything in one go?  Most
> shrinkable slabs adhere to this default of in use first model, which means that
> we have to hit an object in the lru twice before it is freed.  So in order to

I didn't know that.

> reclaim anything we have to scan a slab cache's entire lru at least once before
> any reclaim starts happening.  If we're doing this static step down thing we

If it's really true, I think that shrinker should be fixed first.

> scan some of it, then some more, then some more, then finally we get priority
> down enough that we scan a huge swatch of the list enough to start reclaiming
> objects.
> 
> With the usage ratio in place it's based on actual system usage, so we waste
> less time dropping the priority and spend more time actively trying to free
> objects.

However, I think your idea is too much agressive.

        100M LRU, 1000M SLAB

With your idea, it scans 10 times of all objects in shrinker which ends up
reclaim every slab pages, I guess.

I think your idea comes from some of slab shrinker as you mentioned.
I guess at the first time, all of objects in shrinker could be INUSE state
as you said, however, on steady state, they would work like real LRU
to reflect recency, otherwise, I want to call it broken and we shouldn't
design general slab aging model for those specific one.

> 
> And keep in mind this is the first patch, that sets the baseline.  The next
> patch makes it so we don't even really use this ratio that often, we use the
> ratio of changed slab pages to changed inactive pages, so that can be even more
> agressive.

Intentionally, I didn't read your next patch because without clear understanding
of prior patch, it's hard to digest second one so wanted to discuss this one
first. However, if second patch makes the situation better, I will read but
doubt because you said it would make more aggressive which is my concern.

> 
> > 
> > > 
> > > scan = total >> sc->priority
> > > 
> > > and then we look through 'scan' number of pages, which means we're usually
> > > reclaiming enough stuff to make progress at each priority level.  Slab is
> > > different, pages != slab objects.  Plus we have this common pattern of putting
> > 
> > Aha, I see your concern. The problem is although we can reclaim a object from
> > slab, it doesn't mean to reclaim a page so VM should go with next priority
> > cycle. If so, I think we can adjust the the cost model more agressive with
> > ratio approach. (1/12 + 2/12 + 3/12 ...) With this, in a reclaim cycle(12..0),
> > we guarantees that scanning of entire objects list four times while LRU is
> > two times. As well, it might be a helpful if we can have slab's reclaim tunable
> > knob to tune reclaim agressiveness of slab like swappiness for anonymous pages.
> > 
> 
> Death to all tunables ;).  I prefer this mechanism, it's based on what is
> happening on the system currently, and not some weird static thing that can be
> fucked up by some idiot system administrator inside Facebook who thinks he's
> God's gift to kernel tuning.
> 
> I think the 1/12->2/12->3/12 thing is a better solution than your other option,
> but again I argue that statically stepping down just wastes time in a majority
> of the cases.
> 
> Thinking of it a different way, going to higher and higher priority to hopefully
> put enough pressure on the slab is going to have the side-effect of putting more
> and more pressure on active/inactive.  If our app needs its hot stuff in the
> active pages we'd really rather not evict all of it so we could get the ratios
> right to discard the slab pages we didn't care about in the first place.
> 
> > > every object onto our lru list, and letting the scanning mechanism figure out
> > > which objects are actually not in use any more, which means each scan is likely
> > > to not make progress until we've gone through the entire lru.
> > 
> > Sorry, I didn't understand. Could you elaborate a bit if it's important point
> > in this discussion?
> > 
> 
> I expanded on this above, but I'll give a more concrete example.  Consider xfs
> metadata, we allocate a slab object and read in our page, use it, and then free
> the buffer which put's it on the lru list.  XFS marks this with a INUSE flag,
> which must be cleared before it is free'd from the LRU.  We scan through the
> LRU, clearing the INUSE flag and moving the object to the back of the LRU, but
> not actually free'ing it.  This happens for all (well most) objects that end up
> on the LRU, and this design pattern is used _everywhere_.  Until recently it was
> used for the super shrinkers, but I changed that so thankfully the bulk of the
> problem is gone.  However if you do a find / -exec stat {} \;, and then do it
> again, you'll end up with the same scenario for the super shrinker.   There's no
> aging except via pressure on the slabs, so worst case we always have to scan the
> entire slab object lru once before we start reclaiming anything.  Being
> agressive here I think is ok, we have things in place to make sure we don't over
> reclaim.

Thanks for the detail example. Now I understood but the question is it is
always true? I mean at the first stage(ie, first population of objects), it
seems to be but at the steady stage, I guess some of objects have INUSE,
others not by access pattern so it emulates LRU model. No?

> 
> > > 
> > > You are worried that we are just going to empty the slab every time, and that is
> > > totally a valid concern.  But we have checks in place to make sure that our
> > > total_scan (the number of objects we scan) doesn't end up hugely bonkers so we
> > > don't waste time scanning through objects.  If we wanted to be even more careful
> > > we could add some checks in do_shrink_slab/shrink_slab to bail as soon as we hit
> > > our reclaim targets, instead of having just the one check in shrink_node.
> > 
> > Acutually, my main worry is the expression(gslab/greclaimable).
> > What's the rationale for such modeling in you mind?
> > Without understanding that, it's hard to say whether it's proper.
> > 
> > For exmaple, with your expression, if nr_slab == nr_lru, it scans all objects
> > of slab. Why?  At that time, VM even doesn't scan full LRU.
> > I really want to make them consistent so when a reclaim cycle is done,
> > we guarantees to happen some amount of scanning.
> > In my idea, LRU scanning is x2 of LRU pages and slab scanning is x4 of
> > slab object.
> 
> I really should read the whole email before I start replying to parts ;).  I
> think I've explained my rationale above, but I'll summarize here
> 
> 1) Slab reclaim isn't like page reclaim.
>   a) slab objects != slab pages, there's more objects to reclaim than pages, and
>      fragmentation can fuck us.


True. there were some discussion to improve it better. yes, that's not trivial
job but at least it would be better to revisit ideas before making slab
reclaim too aggressive.

Ccing Dave, Christoph and others guys might have a interest on slab reclaim.

        page-based slab reclaim,
        https://lkml.org/lkml/2010/2/8/329

        slab defragmentation
        https://lkml.org/lkml/2007/7/7/175

>   b) scanning/reclaiming slab objects is generally faster than page reclaim, so
>      scanning more of them is a higher cpu cost, generally we don't have to do
>      IO in order to reclaim (*cough*except for xfs*cough*).
>   c) most slab lru's institute that INUSE flag bullshit that forces us to scan
>      the whole LRU once before reclaim occurs.

If it's really true, I think we should fix it rather than making VM slab reclaim
logic too agressive which will affect other sane shrinkers.

> 2) gslab/greclaimable equates to actual system usage.  With a normal machine
>    nothing really changes, slab will be some single digit %, and nobody will
>    notice, however with a mostly slab workload the slab lru's can be huge and
>    then small static targets get us no where (see 1c).
> 3) My next patch means we don't actually use gslab/greclaimable in reality that
>    often, we'll use delta_slab/delta_inactive, so changing this here doesn't
>    matter much unless we also want to debate my second patch as well.
> 
> Sorry for the long delay Minchin, I'm not trying to ignore you, been trying to
> track down a cgroup cpu thing, I'll try to be more responsive from now on as I'd
> like to get these patches into the next merge window.  Thanks,

No problem, Josef. I belive it would be a good chance to think over slab reclaim
redesign.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
