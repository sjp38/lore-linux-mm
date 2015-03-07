Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id E00DB6B0038
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 10:08:36 -0500 (EST)
Received: by wggx13 with SMTP id x13so18560579wgg.12
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 07:08:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q3si3555393wik.5.2015.03.07.07.08.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Mar 2015 07:08:34 -0800 (PST)
Date: Sat, 7 Mar 2015 10:08:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150307150821.GA9914@phnom.home.cmpxchg.org>
References: <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <54F42FEA.1020404@suse.cz>
 <20150302223154.GJ18360@dastard>
 <20150307002055.GA29679@phnom.home.cmpxchg.org>
 <20150307034347.GG13958@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150307034347.GG13958@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sat, Mar 07, 2015 at 02:43:47PM +1100, Dave Chinner wrote:
> On Fri, Mar 06, 2015 at 07:20:55PM -0500, Johannes Weiner wrote:
> > On Tue, Mar 03, 2015 at 09:31:54AM +1100, Dave Chinner wrote:
> > > What we don't know is how many objects we might need to scan to find
> > > the objects we will eventually modify.  Here's an (admittedly
> > > extreme) example to demonstrate a worst case scenario: allocate a
> > > 64k data extent. Because it is an exact size allocation, we look it
> > > up in the by-size free space btree. Free space is fragmented, so
> > > there are about a million 64k free space extents in the tree.
> > > 
> > > Once we find the first 64k extent, we search them to find the best
> > > locality target match.  The btree records are 16 bytes each, so we
> > > fit roughly 500 to a 4k block. Say we search half the extents to
> > > find the best match - i.e. we walk a thousand leaf blocks before
> > > finding the match we want, and modify that leaf block.
> > > 
> > > Now, the modification removed an entry from the leaf and tht
> > > triggers leaf merge thresholds, so a merge with the 1002nd block
> > > occurs. That block now demand pages in and we then modify and join
> > > it to the transaction. Now we walk back up the btree to update
> > > indexes, merging blocks all the way back up to the root.  We have a
> > > worst case size btree (5 levels) and we merge at every level meaning
> > > we demand page another 8 btree blocks and modify them.
> > > 
> > > In this case, we've demand paged ~1010 btree blocks, but only
> > > modified 10 of them. i.e. the memory we consumed permanently was
> > > only 10 4k buffers (approx. 10 slab and 10 page allocations), but
> > > the allocation demand was 2 orders of magnitude more than the
> > > unreclaimable memory consumption of the btree modification.
> > > 
> > > I hope you start to see the scope of the problem now...
> > 
> > Isn't this bounded one way or another?
> 
> Fo a single transaction? No.

So you can have an infinite number of allocations in the context of a
transaction, and only the objects that are going to be locked in are
bounded?

> > Sure, the inaccuracy itself is
> > high, but when you put the absolute numbers in perspective it really
> > doesn't seem to matter: with your extreme case of 3MB per transaction,
> > you can still run 5k+ of them in parallel on a small 16G machine.
> 
> No you can't. The number of concurrent transactions is bounded by
> the size of the log and the amount of unused space available for
> reservation in the log. Under heavy modification loads, that's
> usually somewhere between 15-25% of the log, so worst case is a few
> hundred megabytes. The memory reservation demand is in the same
> order of magnitude as the log space reservation demand.....
> 
> > Occupy a generous 75% of RAM with anonymous pages, and you can STILL
> > run over a thousand transactions concurrently.  That would seem like a
> > decent pipeline to keep the storage device occupied.
> 
> Typical systems won't ever get to that - they don't do more than a
> handful of current transactions at a time - the "thousands of
> transactions" occur on dedicated storage servers like petabyte scale
> NFS servers that have hundreds of gigabytes of RAM and
> hundreds-to-thousands of processing threads to keep the request
> pipeline full. The memory in those machines is entirely dedicated to
> the filesystem, so keeping a usuable pool of a few gigabytes for
> transaction reservations isn't a big deal.
> 
> The point here is that you're taking what I'm describing as the
> requirements of a reservation pool and then applying the worst case
> to situations where completely inappropriate. That's what I mean
> when I told Michal to stop building silly strawman situations; large
> amounts of concurrency are required for huge machines, not your
> desktop workstation.

Why do you have to take everything I say in bad faith and choose to be
smug instead of constructive?  This is unneccessary.  OF COURSE you
know your constraints better than we do.  Now explain how they matter
in practice, because that's what dictates the design in engineering.

I'm trying to figure out your requirements to find the simplest model,
and yes I'm obviously going to follow up when you give me incomplete
information.  I'm responding to this:

: What we don't know is how many objects we might need to scan to find
: the objects we will eventually modify.  Here's an (admittedly
: extreme) example to demonstrate a worst case scenario:

You gave us numbers that you called "worst case", so I took them and
put them in a scenario where it looks like memory wouldn't be the
bottle neck in real life, even if we just had simple pre-allocation
semantics.  If it was a silly example, why not provide a better one?

I'm fine with reservations and I'm fine with adding more complexity
when you demonstrate that it's needed.  Your argument seems to have
been that worst-case estimates are way off, but can you please just
demonstrate why it matters in practice?  Instead of having me do it
and calling my attempts strawman arguments?  I can just guess your
constraints, it's up to you to make a case for your requirements.

Here is another example where you responded to akpm:

---
> When allocating pages the caller should drain its reserves in
> preference to dipping into the regular freelist.  This guy has already
> done his reclaim and shouldn't be penalised a second time.  I guess
> Johannes's preallocation code should switch to doing this for the same
> reason, plus the fact that snipping a page off
> task_struct.prealloc_pages is super-fast and needs to be done sometime
> anyway so why not do it by default.

That is at odds with the requirements of demand paging, which
allocate for objects that are reclaimable within the course of the
transaction. The reserve is there to ensure forward progress for
allocations for objects that aren't freed until after the
transaction completes, but if we drain it for reclaimable objects we
then have nothing left in the reserve pool when we actually need it.

We do not know ahead of time if the object we are allocating is
going to modified and hence locked into the transaction. Hence we
can't say "use the reserve for this *specific* allocation", and so
the only guidance we can really give is "we will to allocate and
*permanently consume* this much memory", and the reserve pool needs
to cover that consumption to guarantee forwards progress.

Forwards progress for all other allocations is guaranteed because
they are reclaimable objects - they either freed directly back to
their source (slab, heap, page lists) or they are freed by shrinkers
once they have been released from the transaction.

Hence we need allocations to come from the free list and trigger
reclaim, regardless of the fact there is a reserve pool there. The
reserve pool needs to be a last resort once there are no other
avenues to allocate memory. i.e. it would be used to replace the OOM
killer for GFP_NOFAIL allocations.
---

Andrew makes a proposal and backs it up with real life benefits:
simpler, faster.  You on the other hand follow up with a list of
unfounded claims and your only counter-argument really seems to be
that Andrew's proposal differs from what you've had in mind.  What you
had in mind was obviously driven by constraints known to you, but it's
not an argument until you actually include them.  We're not taking
your claims at face value, that's not how this ever works.

Just explain why and how your requirements, demand paging reserves in
this case, matter in real life.  Then we can take them seriously.

> And, realistically, sizing that reservation pool appropriately is my
> problem to solve - it will depend on many factors, one of which is
> the actual geometry of the filesystem itself. You need to stop
> thinking like you can control how application use the memory
> allocation and reclaim subsystem and start to trust we will our
> memory usage appropriately to maintain maximum system throughput.

You've been working on the kernel long enough to know that this is not
how it goes.  I don't care about getting a list of things you claim
you need and implementing them blindly, trusting that you know what
you're doing when it comes to memory.  If you want us to expose an
interface, which puts constraints on our implementation, then you
better provide justification for every single requirement.

> After all, we already do that for all the filesystem caches the mm
> subsystem doesn't control - why do you think I have had such an
> interest in shrinker scalability? For XFS, the only cache we
> actually don't control reclaim from is user data in the page cache -
> we control everything else directly from custom shrinkers.....

You mean those global object pools that are aged through unrelated and
independent per-zone pressure values?

Look, we are specialized in different subsystems, which means we know
the details in front of us better than the details in the surrounding
areas.  You are quick to dismiss constraints and scalability concerns
in the memory subsystem, and I do the same for memory users.  We are
having this discussion in order to explore where our problem spaces
intersect, and we could be making more progress if you stopped
assuming that everybody else is an idiot and you already found the
perfect solution.

We need data on your parameters in order to make a basic cost-benefit
analysis of any proposed solutions.  Don't just propose something and
talk down to us when we ask for clarifications on your constraints.
It's not getting us anywhere.  Explore the problem space with us,
explain your constraints and exact requirements based on real life
data, and then we can look for potential solutions.  That is how we
evaluate every single proposal for the kernel, and it's how it's going
to work in this case.  It's not that complicated.

> > The level of precision that you are asking for comes with complexity
> > and fragility that I'm not convinced is necessary, or justified.
> 
> Look, if you dont think reservations will work, then how about you
> suggest something that will. I don't really care what you implement,
> as long as it meets the needs of demand paging, I have direct
> control over memory usage and concurrency policy and the allocation
> mechanism guarantees forward progress without needing the OOM
> killer.

Reservations are fine and I also want them to replace the OOM killer,
we agree on that.

The only thing my email was about was that, in light of the worst-case
numbers you quoted, it didn't look like the demand paging requirement
is strictly necessary to make the system work in practice, which is
why I'm questioning that particular requirement and prompting you to
clarify your position.  You have yet to address this.

Until then, the simplest semantics are preallocation semantics, where
you in advance establish private reserve pools (which can be backed by
clean cache) from which you allocate directly using __GFP_RESERVE.  If
the pool is empty it's immediately detectable and attributable to the
culprit, and the other reserves are not impacted by it.

A globally shared demand-paged pool is much more fragile because you
trust other participants in the system to keep their promise and not
pin more objects than they reserved for.  Otherwise, they deadlock
your transaction and corrupt your userdata.  How does "XFS filesystem
corrupted because it shares its emergency memory pool to ensure data
integrity with some buggy driver" sound to you?

It's also harder to verify.  If one of the participants misbehaves and
pins more objects than they initially reserved for, how do we identify
the culprit when the system locks up?

Make an actual case why preallocation semantics are unworkable on real
systems with real memory and real filesystems and real data on them,
then we can consider making the model more complex and fragile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
