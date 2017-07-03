Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D57A6B0279
	for <linux-mm@kvack.org>; Sun,  2 Jul 2017 21:33:06 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d18so7840590pfe.8
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 18:33:06 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m81si11136072pfa.242.2017.07.02.18.33.04
        for <linux-mm@kvack.org>;
        Sun, 02 Jul 2017 18:33:05 -0700 (PDT)
Date: Mon, 3 Jul 2017 10:33:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170703013303.GA2567@bbox>
References: <1496949546-2223-1-git-send-email-jbacik@fb.com>
 <20170613052802.GA16061@bbox>
 <20170613120156.GA16003@destiny>
 <20170614064045.GA19843@bbox>
 <20170619151120.GA11245@destiny>
 <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
 <20170630021713.GB24520@bbox>
 <20170630150322.GB9743@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630150322.GB9743@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com, david@fromorbit.com

Hello,

On Fri, Jun 30, 2017 at 11:03:24AM -0400, Josef Bacik wrote:
> On Fri, Jun 30, 2017 at 11:17:13AM +0900, Minchan Kim wrote:
> 
> <snip>
> 
> > > 
> > > Because this static step down wastes cycles.  Why loop 10 times when you could
> > > set the target at actual usage and try to get everything in one go?  Most
> > > shrinkable slabs adhere to this default of in use first model, which means that
> > > we have to hit an object in the lru twice before it is freed.  So in order to
> > 
> > I didn't know that.
> > 
> > > reclaim anything we have to scan a slab cache's entire lru at least once before
> > > any reclaim starts happening.  If we're doing this static step down thing we
> > 
> > If it's really true, I think that shrinker should be fixed first.
> > 
> 
> Easier said than done.  I've fixed this for the super shrinkers, but like I said
> below, all it takes is some asshole doing find / -exec stat {} \; twice to put
> us back in the same situation again.  There's no aging mechanism other than
> memory reclaim, so we get into this shitty situation of aging+reclaiming at the
> same time.

What's different with normal page cache problem?

It has the same problem you mentioned so need to peek what VM does to
address it.

It has two LRU list, active and inactive and maintain the size ratio 1:1.
New page is on inactive and if they are two-touched, the page will be
promoted into active list which is same problem.
However, once reclaim is triggered, VM will can move quickly them from
active to inactive with remove referenced flag untill the ratio is matched.
So, VM can reclaim pages from inactive list, easily.

Can we apply similar mechanism into the problematical slab?
How about adding shrink_slab(xxx, ACTIVE|INACTIVE) in somewhere of VM
for demotion of objects from active list and adding the logic to move
inactive object to active list when the cache hit happens to the FS?

> 
> > > scan some of it, then some more, then some more, then finally we get priority
> > > down enough that we scan a huge swatch of the list enough to start reclaiming
> > > objects.
> > > 
> > > With the usage ratio in place it's based on actual system usage, so we waste
> > > less time dropping the priority and spend more time actively trying to free
> > > objects.
> > 
> > However, I think your idea is too much agressive.
> > 
> >         100M LRU, 1000M SLAB
> > 
> > With your idea, it scans 10 times of all objects in shrinker which ends up
> > reclaim every slab pages, I guess.
> > 
> 
> No, we have limits in do_shrink_slab, so in this case we will limit the scan
> count to twice the LRU size, which accounts for this INUSE design pattern

Aha, it sounds logical. Twice of the LRU size is enough to sweep out all
objects. First round, remove INUSE flag, second round, free objects?
IOW, If LRU size is half of slab in your logic, it could reclaim all slab
objects.

> everybody loves.  Plus we have the early bailout logic so when we reclaim enough
> we are done, we don't just reclaim the whole thing.

I cannot see what bailout logic you are saying.
Once shrink_slab with big gap of #slab/#LRU in your logic is called,
it could reclaim every objects in every shrinkers.

> 
> > I think your idea comes from some of slab shrinker as you mentioned.
> > I guess at the first time, all of objects in shrinker could be INUSE state
> > as you said, however, on steady state, they would work like real LRU
> > to reflect recency, otherwise, I want to call it broken and we shouldn't
> > design general slab aging model for those specific one.
> > 
> 
> Yeah that's totally a valid argument to make, but the idea of coming up with
> something completely different hurts my head, and I'm trying to fix this problem
> right now, not in 6 cycles when we all finally agree on the new mechanism.
> 
> > > 
> > > And keep in mind this is the first patch, that sets the baseline.  The next
> > > patch makes it so we don't even really use this ratio that often, we use the
> > > ratio of changed slab pages to changed inactive pages, so that can be even more
> > > agressive.
> > 
> > Intentionally, I didn't read your next patch because without clear understanding
> > of prior patch, it's hard to digest second one so wanted to discuss this one
> > first. However, if second patch makes the situation better, I will read but
> > doubt because you said it would make more aggressive which is my concern.
> > 
> 
> Right so it adjusts the aggressiveness on the change in slab vs inactive lru
> size, so if we're generating a lot of slab pages and no inactive pages then
> it'll look just as agressive.
> 
> I think you're getting too scared of the scale of aggressiveness these numbers
> generate.  We have a bunch of logic to trim down these numbers to reasonable
> scan targets and to bail out when we've hit our reclaim target.  We end up with
> bonkers numbers in bonkers situations, and these numbers are curtailed to
> reasonable things later on, so the initial pass isn't that important.  What _is_
> important is that we are actually agressive enough, because right now we aren't
> and it hurts badly.  We can be overly agressive because we have checks in place
> to back off.

Sorry but I cannot see what kinds of bailout logics you are saying.
Please elaborate it a bit. I hope it would be in general VM logic,
not FS sepecic.

> 
> > > 
> > > > 
> > > > > 
> > > > > scan = total >> sc->priority
> > > > > 
> > > > > and then we look through 'scan' number of pages, which means we're usually
> > > > > reclaiming enough stuff to make progress at each priority level.  Slab is
> > > > > different, pages != slab objects.  Plus we have this common pattern of putting
> > > > 
> > > > Aha, I see your concern. The problem is although we can reclaim a object from
> > > > slab, it doesn't mean to reclaim a page so VM should go with next priority
> > > > cycle. If so, I think we can adjust the the cost model more agressive with
> > > > ratio approach. (1/12 + 2/12 + 3/12 ...) With this, in a reclaim cycle(12..0),
> > > > we guarantees that scanning of entire objects list four times while LRU is
> > > > two times. As well, it might be a helpful if we can have slab's reclaim tunable
> > > > knob to tune reclaim agressiveness of slab like swappiness for anonymous pages.
> > > > 
> > > 
> > > Death to all tunables ;).  I prefer this mechanism, it's based on what is
> > > happening on the system currently, and not some weird static thing that can be
> > > fucked up by some idiot system administrator inside Facebook who thinks he's
> > > God's gift to kernel tuning.
> > > 
> > > I think the 1/12->2/12->3/12 thing is a better solution than your other option,
> > > but again I argue that statically stepping down just wastes time in a majority
> > > of the cases.
> > > 
> > > Thinking of it a different way, going to higher and higher priority to hopefully
> > > put enough pressure on the slab is going to have the side-effect of putting more
> > > and more pressure on active/inactive.  If our app needs its hot stuff in the
> > > active pages we'd really rather not evict all of it so we could get the ratios
> > > right to discard the slab pages we didn't care about in the first place.
> > > 
> > > > > every object onto our lru list, and letting the scanning mechanism figure out
> > > > > which objects are actually not in use any more, which means each scan is likely
> > > > > to not make progress until we've gone through the entire lru.
> > > > 
> > > > Sorry, I didn't understand. Could you elaborate a bit if it's important point
> > > > in this discussion?
> > > > 
> > > 
> > > I expanded on this above, but I'll give a more concrete example.  Consider xfs
> > > metadata, we allocate a slab object and read in our page, use it, and then free
> > > the buffer which put's it on the lru list.  XFS marks this with a INUSE flag,
> > > which must be cleared before it is free'd from the LRU.  We scan through the
> > > LRU, clearing the INUSE flag and moving the object to the back of the LRU, but
> > > not actually free'ing it.  This happens for all (well most) objects that end up
> > > on the LRU, and this design pattern is used _everywhere_.  Until recently it was
> > > used for the super shrinkers, but I changed that so thankfully the bulk of the
> > > problem is gone.  However if you do a find / -exec stat {} \;, and then do it
> > > again, you'll end up with the same scenario for the super shrinker.   There's no
> > > aging except via pressure on the slabs, so worst case we always have to scan the
> > > entire slab object lru once before we start reclaiming anything.  Being
> > > agressive here I think is ok, we have things in place to make sure we don't over
> > > reclaim.
> > 
> > Thanks for the detail example. Now I understood but the question is it is
> > always true? I mean at the first stage(ie, first population of objects), it
> > seems to be but at the steady stage, I guess some of objects have INUSE,
> > others not by access pattern so it emulates LRU model. No?
> > 
> 
> Sort of.  Lets take icache/dcache.  We open a file and close a file, this get's
> added to the LRU.  We open the file and close the file again, it's already on
> the LRU so it stays where it was and gets the INUSE flag set.  Once an object is
> on the LRU it doesn't move unless we hit it via the shrinker.  Even if we open
> and close the file, and then open and keep it open, the file stays on the LRU,
> and is only removed once the shrinker hits it, sees it's refcount is > 1, and
> removes it from the list.

How about my suggestion in above which adds active/inactive LRU list
for the slab and adding shrink_slab(xxx, active|inactive) in shrink_list,
for example? Of course, it needs more tweaks for shrinkers who are able
to use a lot of memory as a cache but I think it's the tradeoff for whom
can be memory-hogger.

> 
> With my patch in place we will have a smattering of objects that are not in use
> with the INUSE flag set, objects with no INUSE so get free'd immediately
> (hooray!), and objects that really are in use that get removed from the LRU once
> we encounter them.
> 
> Even with this "ideal" (or less shitty depending on your point of view), our LRU
> is going to be made up with a pretty significant number of objects that can't be
> free'd right away in the worst case.
> 
> > > 
> > > > > 
> > > > > You are worried that we are just going to empty the slab every time, and that is
> > > > > totally a valid concern.  But we have checks in place to make sure that our
> > > > > total_scan (the number of objects we scan) doesn't end up hugely bonkers so we
> > > > > don't waste time scanning through objects.  If we wanted to be even more careful
> > > > > we could add some checks in do_shrink_slab/shrink_slab to bail as soon as we hit
> > > > > our reclaim targets, instead of having just the one check in shrink_node.
> > > > 
> > > > Acutually, my main worry is the expression(gslab/greclaimable).
> > > > What's the rationale for such modeling in you mind?
> > > > Without understanding that, it's hard to say whether it's proper.
> > > > 
> > > > For exmaple, with your expression, if nr_slab == nr_lru, it scans all objects
> > > > of slab. Why?  At that time, VM even doesn't scan full LRU.
> > > > I really want to make them consistent so when a reclaim cycle is done,
> > > > we guarantees to happen some amount of scanning.
> > > > In my idea, LRU scanning is x2 of LRU pages and slab scanning is x4 of
> > > > slab object.
> > > 
> > > I really should read the whole email before I start replying to parts ;).  I
> > > think I've explained my rationale above, but I'll summarize here
> > > 
> > > 1) Slab reclaim isn't like page reclaim.
> > >   a) slab objects != slab pages, there's more objects to reclaim than pages, and
> > >      fragmentation can fuck us.
> > 
> > 
> > True. there were some discussion to improve it better. yes, that's not trivial
> > job but at least it would be better to revisit ideas before making slab
> > reclaim too aggressive.
> > 
> > Ccing Dave, Christoph and others guys might have a interest on slab reclaim.
> > 
> >         page-based slab reclaim,
> >         https://lkml.org/lkml/2010/2/8/329
> > 
> >         slab defragmentation
> >         https://lkml.org/lkml/2007/7/7/175
> > 
> 
> This is the first path I went down, and I burned and salted the earth on my way
> back.  The problem with trying to reclaim slab pages is you have to have some
> insight into the objects contained on the page.  That gets you into weird
> locking scenarios and end's up pretty yucky.
> 
> The next approach I took was having a slab lru, and then the reclaim would tell
> the file system "I want to reclaim this page."  The problem is there's a
> disconnect between what the vm will think is last touched vs what is actually
> last touched, which could lead to us free'ing hotter objects when there are
> cooler ones to free.
> 
> Admittedly I didn't spend much time on these solutions, all I really want is to
> make the current situation less shitty right now so I can go back to being a
> btrfs developer and not a everything else fixer ;).
> 
> > >   b) scanning/reclaiming slab objects is generally faster than page reclaim, so
> > >      scanning more of them is a higher cpu cost, generally we don't have to do
> > >      IO in order to reclaim (*cough*except for xfs*cough*).
> > >   c) most slab lru's institute that INUSE flag bullshit that forces us to scan
> > >      the whole LRU once before reclaim occurs.
> > 
> > If it's really true, I think we should fix it rather than making VM slab reclaim
> > logic too agressive which will affect other sane shrinkers.
> > 
> 
> Agreed, and it's been fixed for the super shrinkers which are the largest pool.
> However you can still force the bad behavior, so we still need to be able to
> handle the worst case.
> 
> > > 2) gslab/greclaimable equates to actual system usage.  With a normal machine
> > >    nothing really changes, slab will be some single digit %, and nobody will
> > >    notice, however with a mostly slab workload the slab lru's can be huge and
> > >    then small static targets get us no where (see 1c).
> > > 3) My next patch means we don't actually use gslab/greclaimable in reality that
> > >    often, we'll use delta_slab/delta_inactive, so changing this here doesn't
> > >    matter much unless we also want to debate my second patch as well.
> > > 
> > > Sorry for the long delay Minchin, I'm not trying to ignore you, been trying to
> > > track down a cgroup cpu thing, I'll try to be more responsive from now on as I'd
> > > like to get these patches into the next merge window.  Thanks,
> > 
> > No problem, Josef. I belive it would be a good chance to think over slab reclaim
> > redesign.
> > 
> 
> Yeah I've had a smattering of talks with various people over the last year, and
> I've tried to implement a few of the ideas, but nothing has turned out to be
> really viable.
> 
> What I'm hoping to convince you of is that yes, the initial numbers are fucking
> huge, and that does make us more agressive.  However there are checks to pull
> these numbers down to reasonable counts, so we are never in danger of scanning
> all slab objects 10 times for one reclaim loop.  Coupled with the early bailout
> logic these things keep the worst case insanity down to something sane.  Thanks,

Before the answering, I need to know what you means about early bailout logic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
