Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id F03EB6B0038
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 22:43:53 -0500 (EST)
Received: by pdjy10 with SMTP id y10so10098298pdj.12
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 19:43:53 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id qd5si17545558pbb.185.2015.03.06.19.43.51
        for <linux-mm@kvack.org>;
        Fri, 06 Mar 2015 19:43:52 -0800 (PST)
Date: Sat, 7 Mar 2015 14:43:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150307034347.GG13958@dastard>
References: <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <54F42FEA.1020404@suse.cz>
 <20150302223154.GJ18360@dastard>
 <20150307002055.GA29679@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150307002055.GA29679@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Fri, Mar 06, 2015 at 07:20:55PM -0500, Johannes Weiner wrote:
> On Tue, Mar 03, 2015 at 09:31:54AM +1100, Dave Chinner wrote:
> > What we don't know is how many objects we might need to scan to find
> > the objects we will eventually modify.  Here's an (admittedly
> > extreme) example to demonstrate a worst case scenario: allocate a
> > 64k data extent. Because it is an exact size allocation, we look it
> > up in the by-size free space btree. Free space is fragmented, so
> > there are about a million 64k free space extents in the tree.
> > 
> > Once we find the first 64k extent, we search them to find the best
> > locality target match.  The btree records are 16 bytes each, so we
> > fit roughly 500 to a 4k block. Say we search half the extents to
> > find the best match - i.e. we walk a thousand leaf blocks before
> > finding the match we want, and modify that leaf block.
> > 
> > Now, the modification removed an entry from the leaf and tht
> > triggers leaf merge thresholds, so a merge with the 1002nd block
> > occurs. That block now demand pages in and we then modify and join
> > it to the transaction. Now we walk back up the btree to update
> > indexes, merging blocks all the way back up to the root.  We have a
> > worst case size btree (5 levels) and we merge at every level meaning
> > we demand page another 8 btree blocks and modify them.
> > 
> > In this case, we've demand paged ~1010 btree blocks, but only
> > modified 10 of them. i.e. the memory we consumed permanently was
> > only 10 4k buffers (approx. 10 slab and 10 page allocations), but
> > the allocation demand was 2 orders of magnitude more than the
> > unreclaimable memory consumption of the btree modification.
> > 
> > I hope you start to see the scope of the problem now...
> 
> Isn't this bounded one way or another?

Fo a single transaction? No.

> Sure, the inaccuracy itself is
> high, but when you put the absolute numbers in perspective it really
> doesn't seem to matter: with your extreme case of 3MB per transaction,
> you can still run 5k+ of them in parallel on a small 16G machine.

No you can't. The number of concurrent transactions is bounded by
the size of the log and the amount of unused space available for
reservation in the log. Under heavy modification loads, that's
usually somewhere between 15-25% of the log, so worst case is a few
hundred megabytes. The memory reservation demand is in the same
order of magnitude as the log space reservation demand.....

> Occupy a generous 75% of RAM with anonymous pages, and you can STILL
> run over a thousand transactions concurrently.  That would seem like a
> decent pipeline to keep the storage device occupied.

Typical systems won't ever get to that - they don't do more than a
handful of current transactions at a time - the "thousands of
transactions" occur on dedicated storage servers like petabyte scale
NFS servers that have hundreds of gigabytes of RAM and
hundreds-to-thousands of processing threads to keep the request
pipeline full. The memory in those machines is entirely dedicated to
the filesystem, so keeping a usuable pool of a few gigabytes for
transaction reservations isn't a big deal.

The point here is that you're taking what I'm describing as the
requirements of a reservation pool and then applying the worst case
to situations where completely inappropriate. That's what I mean
when I told Michal to stop building silly strawman situations; large
amounts of concurrency are required for huge machines, not your
desktop workstation.

And, realistically, sizing that reservation pool appropriately is my
problem to solve - it will depend on many factors, one of which is
the actual geometry of the filesystem itself. You need to stop
thinking like you can control how application use the memory
allocation and reclaim subsystem and start to trust we will our
memory usage appropriately to maintain maximum system throughput.

After all, we already do that for all the filesystem caches the mm
subsystem doesn't control - why do you think I have had such an
interest in shrinker scalability? For XFS, the only cache we
actually don't control reclaim from is user data in the page cache -
we control everything else directly from custom shrinkers.....

> The level of precision that you are asking for comes with complexity
> and fragility that I'm not convinced is necessary, or justified.

Look, if you dont think reservations will work, then how about you
suggest something that will. I don't really care what you implement,
as long as it meets the needs of demand paging, I have direct
control over memory usage and concurrency policy and the allocation
mechanism guarantees forward progress without needing the OOM
killer.

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
