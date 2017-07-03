Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C55C06B0292
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 09:50:10 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q38so41699821qtq.4
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 06:50:10 -0700 (PDT)
Received: from mail-qt0-x236.google.com (mail-qt0-x236.google.com. [2607:f8b0:400d:c0d::236])
        by mx.google.com with ESMTPS id m4si14956007qke.80.2017.07.03.06.50.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jul 2017 06:50:09 -0700 (PDT)
Received: by mail-qt0-x236.google.com with SMTP id 32so143639811qtv.1
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 06:50:09 -0700 (PDT)
Date: Mon, 3 Jul 2017 09:50:07 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170703135006.GC27097@destiny>
References: <1496949546-2223-1-git-send-email-jbacik@fb.com>
 <20170613052802.GA16061@bbox>
 <20170613120156.GA16003@destiny>
 <20170614064045.GA19843@bbox>
 <20170619151120.GA11245@destiny>
 <20170620024645.GA27702@bbox>
 <20170627135931.GA14097@destiny>
 <20170630021713.GB24520@bbox>
 <20170630150322.GB9743@destiny>
 <20170703013303.GA2567@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170703013303.GA2567@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Josef Bacik <josef@toxicpanda.com>, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, mhocko@kernel.org, cl@linux.com, david@fromorbit.com

On Mon, Jul 03, 2017 at 10:33:03AM +0900, Minchan Kim wrote:
> Hello,
> 
> On Fri, Jun 30, 2017 at 11:03:24AM -0400, Josef Bacik wrote:
> > On Fri, Jun 30, 2017 at 11:17:13AM +0900, Minchan Kim wrote:
> > 
> > <snip>
> > 
> > > > 
> > > > Because this static step down wastes cycles.  Why loop 10 times when you could
> > > > set the target at actual usage and try to get everything in one go?  Most
> > > > shrinkable slabs adhere to this default of in use first model, which means that
> > > > we have to hit an object in the lru twice before it is freed.  So in order to
> > > 
> > > I didn't know that.
> > > 
> > > > reclaim anything we have to scan a slab cache's entire lru at least once before
> > > > any reclaim starts happening.  If we're doing this static step down thing we
> > > 
> > > If it's really true, I think that shrinker should be fixed first.
> > > 
> > 
> > Easier said than done.  I've fixed this for the super shrinkers, but like I said
> > below, all it takes is some asshole doing find / -exec stat {} \; twice to put
> > us back in the same situation again.  There's no aging mechanism other than
> > memory reclaim, so we get into this shitty situation of aging+reclaiming at the
> > same time.
> 
> What's different with normal page cache problem?
> 

What's different is reclaiming a page from pagecache gives you a page,
reclaiming 10k objects from slab may only give you one page if you are super
unlucky.  I'm nothing in life if I'm not unlucky.

> It has the same problem you mentioned so need to peek what VM does to
> address it.
> 
> It has two LRU list, active and inactive and maintain the size ratio 1:1.
> New page is on inactive and if they are two-touched, the page will be
> promoted into active list which is same problem.
> However, once reclaim is triggered, VM will can move quickly them from
> active to inactive with remove referenced flag untill the ratio is matched.
> So, VM can reclaim pages from inactive list, easily.
> 
> Can we apply similar mechanism into the problematical slab?
> How about adding shrink_slab(xxx, ACTIVE|INACTIVE) in somewhere of VM
> for demotion of objects from active list and adding the logic to move
> inactive object to active list when the cache hit happens to the FS?
> 

I did this too!  This worked out ok, but was a bit complex and the problem was
solved just as well by dropping the INUSE first approach.  I think that Dave's
approach to having a separate aging mechanism is a good compliment to these
patches.

> > 
> > > > scan some of it, then some more, then some more, then finally we get priority
> > > > down enough that we scan a huge swatch of the list enough to start reclaiming
> > > > objects.
> > > > 
> > > > With the usage ratio in place it's based on actual system usage, so we waste
> > > > less time dropping the priority and spend more time actively trying to free
> > > > objects.
> > > 
> > > However, I think your idea is too much agressive.
> > > 
> > >         100M LRU, 1000M SLAB
> > > 
> > > With your idea, it scans 10 times of all objects in shrinker which ends up
> > > reclaim every slab pages, I guess.
> > > 
> > 
> > No, we have limits in do_shrink_slab, so in this case we will limit the scan
> > count to twice the LRU size, which accounts for this INUSE design pattern
> 
> Aha, it sounds logical. Twice of the LRU size is enough to sweep out all
> objects. First round, remove INUSE flag, second round, free objects?
> IOW, If LRU size is half of slab in your logic, it could reclaim all slab
> objects.
> 
> > everybody loves.  Plus we have the early bailout logic so when we reclaim enough
> > we are done, we don't just reclaim the whole thing.
> 
> I cannot see what bailout logic you are saying.
> Once shrink_slab with big gap of #slab/#LRU in your logic is called,
> it could reclaim every objects in every shrinkers.
> 
> > 
> > > I think your idea comes from some of slab shrinker as you mentioned.
> > > I guess at the first time, all of objects in shrinker could be INUSE state
> > > as you said, however, on steady state, they would work like real LRU
> > > to reflect recency, otherwise, I want to call it broken and we shouldn't
> > > design general slab aging model for those specific one.
> > > 
> > 
> > Yeah that's totally a valid argument to make, but the idea of coming up with
> > something completely different hurts my head, and I'm trying to fix this problem
> > right now, not in 6 cycles when we all finally agree on the new mechanism.
> > 
> > > > 
> > > > And keep in mind this is the first patch, that sets the baseline.  The next
> > > > patch makes it so we don't even really use this ratio that often, we use the
> > > > ratio of changed slab pages to changed inactive pages, so that can be even more
> > > > agressive.
> > > 
> > > Intentionally, I didn't read your next patch because without clear understanding
> > > of prior patch, it's hard to digest second one so wanted to discuss this one
> > > first. However, if second patch makes the situation better, I will read but
> > > doubt because you said it would make more aggressive which is my concern.
> > > 
> > 
> > Right so it adjusts the aggressiveness on the change in slab vs inactive lru
> > size, so if we're generating a lot of slab pages and no inactive pages then
> > it'll look just as agressive.
> > 
> > I think you're getting too scared of the scale of aggressiveness these numbers
> > generate.  We have a bunch of logic to trim down these numbers to reasonable
> > scan targets and to bail out when we've hit our reclaim target.  We end up with
> > bonkers numbers in bonkers situations, and these numbers are curtailed to
> > reasonable things later on, so the initial pass isn't that important.  What _is_
> > important is that we are actually agressive enough, because right now we aren't
> > and it hurts badly.  We can be overly agressive because we have checks in place
> > to back off.
> 
> Sorry but I cannot see what kinds of bailout logics you are saying.
> Please elaborate it a bit. I hope it would be in general VM logic,
> not FS sepecic.
>

Jesus I'm sorry Minchan, I've done so many different things trying to solve this
problem I've bled together what the code looks like and other things I've done.
I had at some point in the past moved the bailout code to do_shrink_slab to keep
us from over-reclaiming slab, but I dropped them at some point but just went on
thinking thats how it all worked.  I'll respin these patches and add the early
bailout conditions as well to address this problem.  Sorry again,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
