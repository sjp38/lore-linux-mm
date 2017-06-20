Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5369C6B0292
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 22:46:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g7so131464715pgr.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:46:48 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id x10si6171119plm.71.2017.06.19.19.46.46
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 19:46:47 -0700 (PDT)
Date: Tue, 20 Jun 2017 11:46:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: use slab size in the slab shrinking ratio
 calculation
Message-ID: <20170620024645.GA27702@bbox>
References: <1496949546-2223-1-git-send-email-jbacik@fb.com>
 <20170613052802.GA16061@bbox>
 <20170613120156.GA16003@destiny>
 <20170614064045.GA19843@bbox>
 <20170619151120.GA11245@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170619151120.GA11245@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>

Hello Josef,

On Mon, Jun 19, 2017 at 11:11:21AM -0400, Josef Bacik wrote:
> On Wed, Jun 14, 2017 at 03:40:45PM +0900, Minchan Kim wrote:
> > On Tue, Jun 13, 2017 at 08:01:57AM -0400, Josef Bacik wrote:
> > > On Tue, Jun 13, 2017 at 02:28:02PM +0900, Minchan Kim wrote:
> > > > Hello,
> > > > 
> > > > On Thu, Jun 08, 2017 at 03:19:05PM -0400, josef@toxicpanda.com wrote:
> > > > > From: Josef Bacik <jbacik@fb.com>
> > > > > 
> > > > > When testing a slab heavy workload I noticed that we often would barely
> > > > > reclaim anything at all from slab when kswapd started doing reclaim.
> > > > > This is because we use the ratio of nr_scanned / nr_lru to determine how
> > > > > much of slab we should reclaim.  But in a slab only/mostly workload we
> > > > > will not have much page cache to reclaim, and thus our ratio will be
> > > > > really low and not at all related to where the memory on the system is.
> > > > 
> > > > I want to understand this clearly.
> > > > Why nr_scanned / nr_lru is low if system doesnt' have much page cache?
> > > > Could you elaborate it a bit?
> > > > 
> > > 
> > > Yeah so for example on my freshly booted test box I have this
> > > 
> > > Active:            58840 kB
> > > Inactive:          46860 kB
> > > 
> > > Every time we do a get_scan_count() we do this
> > > 
> > > scan = size >> sc->priority
> > > 
> > > where sc->priority starts at DEF_PRIORITY, which is 12.  The first loop through
> > > reclaim would result in a scan target of 2 pages to 11715 total inactive pages,
> > > and 3 pages to 14710 total active pages.  This is a really really small target
> > > for a system that is entirely slab pages.  And this is super optimistic, this
> > > assumes we even get to scan these pages.  We don't increment sc->nr_scanned
> > > unless we 1) isolate the page, which assumes it's not in use, and 2) can lock
> > > the page.  Under pressure these numbers could probably go down, I'm sure there's
> > > some random pages from daemons that aren't actually in use, so the targets get
> > > even smaller.
> > > 
> > > We have to get sc->priority down a lot before we start to get to the 1:1 ratio
> > > that would even start to be useful for reclaim in this scenario.  Add to this
> > > that most shrinkable slabs have this idea that their objects have to loop
> > > through the LRU twice (no longer icache/dcache as Al took my patch to fix that
> > > thankfully) and you end up spending a lot of time looping and reclaiming
> > > nothing.  Basing it on actual slab usage makes more sense logically and avoids
> > > this kind of problem.  Thanks,
> > 
> > Thanks. I got understood now.
> > 
> > As I see your change, it seems to be rather aggressive to me.
> > 
> >         node_slab = lruvec_page_state(lruvec, NR_SLAB_RECLAIMABLE);
> >         shrink_slab(,,, node_slab >> sc->priority, node_slab);
> > 
> > The point is when we finish reclaiming from direct/background(ie, kswapd),
> > it makes sure that VM scanned slab object up to twice of the size which
> > is consistent with LRU pages.
> > 
> > What do you think about this?
> 
> Sorry for the delay, I was on a short vacation.  At first I thought this was a
> decent idea so I went to put it in there.  But there were some problems with it,
> and with sc->priority itself I beleive.  First the results were not great, we
> still end up not doing a lot of reclaim until we get down to the lower priority
> numbers.
> 
> The thing that's different with slab vs everybody else is that these numbers are
> a ratio, not a specific scan target amount.  With the other LRU's we do

Hmm, I don't get it why the ratio model is a problem.
My suggestion is to aim for scanning entire available objects list twice
in a reclaim cycle(priority from 12 to 0) which is consistent with LRU
reclaim. IOW, (1/4096 + 1/2048 + ... 1/1) * available object.
If it cannot reclaim pages with low priority(ie, 12), it try to reclaim
more objects in higher priority and finally, it try to reclaim every objects
at priority 1 and one more chance with priority 0.

> 
> scan = total >> sc->priority
> 
> and then we look through 'scan' number of pages, which means we're usually
> reclaiming enough stuff to make progress at each priority level.  Slab is
> different, pages != slab objects.  Plus we have this common pattern of putting

Aha, I see your concern. The problem is although we can reclaim a object from
slab, it doesn't mean to reclaim a page so VM should go with next priority
cycle. If so, I think we can adjust the the cost model more agressive with
ratio approach. (1/12 + 2/12 + 3/12 ...) With this, in a reclaim cycle(12..0),
we guarantees that scanning of entire objects list four times while LRU is
two times. As well, it might be a helpful if we can have slab's reclaim tunable
knob to tune reclaim agressiveness of slab like swappiness for anonymous pages.

> every object onto our lru list, and letting the scanning mechanism figure out
> which objects are actually not in use any more, which means each scan is likely
> to not make progress until we've gone through the entire lru.

Sorry, I didn't understand. Could you elaborate a bit if it's important point
in this discussion?

> 
> You are worried that we are just going to empty the slab every time, and that is
> totally a valid concern.  But we have checks in place to make sure that our
> total_scan (the number of objects we scan) doesn't end up hugely bonkers so we
> don't waste time scanning through objects.  If we wanted to be even more careful
> we could add some checks in do_shrink_slab/shrink_slab to bail as soon as we hit
> our reclaim targets, instead of having just the one check in shrink_node.

Acutually, my main worry is the expression(gslab/greclaimable).
What's the rationale for such modeling in you mind?
Without understanding that, it's hard to say whether it's proper.

For exmaple, with your expression, if nr_slab == nr_lru, it scans all objects
of slab. Why?  At that time, VM even doesn't scan full LRU.
I really want to make them consistent so when a reclaim cycle is done,
we guarantees to happen some amount of scanning.
In my idea, LRU scanning is x2 of LRU pages and slab scanning is x4 of
slab object.

> 
> As for sc->priority, I think it doesn't make much sense in general.  It makes
> total sense to limit the number of pages scanned per LRU, but we can accomplish
> this with ratios of each lru to the overall state of the system.  The fact is we
> want to keep scanning and reclaiming until we hit our reclaim target, so using
> the sc->priority thing is just kind of clunky and sometimes results in us
> looping needlessly out to get the priority lowered, when we could just apply
> ratio based pressure to the LRU's/slab until we hit our targets, and then bail
> out.  I could be wrong and that seems like a big can of worms I don't want to
> open right now, but for sure I don't think it's a good fit for slab shrinking
> because of the disconnect of nr_slab_pages to actual slab objects.  Thanks,
> 
> Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
