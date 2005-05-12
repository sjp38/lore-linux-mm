Date: Thu, 12 May 2005 14:53:02 -0400
From: Martin Hicks <mort@sgi.com>
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
Message-ID: <20050512185302.GO19244@localhost>
References: <20050427150848.GR8018@localhost> <20050427233335.492d0b6f.akpm@osdl.org> <4277259C.6000207@engr.sgi.com> <20050503010846.508bbe62.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050503010846.508bbe62.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ray Bryant <raybry@engr.sgi.com>, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, May 03, 2005 at 01:08:46AM -0700, Andrew Morton wrote:
> 
> Yup.  But we could add a knob to each zone which says, during page
> allocation "be more reluctant to advance onto the next node - do some
> direct reclaim instead"
> 
> And the good thing about that is that it is an easier merge because it's a
> simpler patch and because it's useful to more machines.  People can tune it
> and get better (or worse) performance from existing apps on NUMA.
> 
> Yes, if it's a "simple" patch then it _might_ do a bit of swapout or
> something.  But the VM does prefer to reclaim clean pagecache first (as
> well as slab, which is a bonus for this approach).
> 
> Worth trying, at least?

So, I did this as an exercise.  A few things came up:

1)  If you just call directly into the reclaim code then it swaps a LOT.
I stuck my "don't swap" flag back in, just to see what would happen.  It
works a lot better if you can tell it to just not swap.

2)  With a per zone on/off flag for reclaim, I then run into the
trouble where the allocator always reclaims pages, even when it
shouldn't.  Filling pagecache with files will start reclaiming from the
preferred zone as soon as the zone fills, leaving the rest of the zones
unused.

My last patch, using mempolicies, got this right because the core
kernel, which wasn't set to use reclaim, would just allocate off-node
for stuff like page cache pages.

3)  This patch has no code that limits the amount of scanning that is done
under really heavy memory stress.  A "make -j" kernel build takes more
time to complete than I'm willing to wait, while a stock kernel does
complete the run in 15-20 minutes.

Scanning too much is really the biggest problem.  I want to keep using
refill_inactive_list(), so that I don't futz with the LRU ordering or
resort to reclaiming active pages like I was doing in my old patch.

4) Under trivial tests, this patch helps NUMA machines get local memory
more often.  The silly test was to just fill node 0 with page cache and
then run a "make -j8" kernbench test on node 0  (2 cpu node).

Without zone reclaiming turned on, all memory allocations go to node 1.
With the reclaiming on, page cache is reclaimed and gcc gets all local
memory.

This is a real problem.  We even see it on modest 8p/32G build servers
because there is lots of pagecache kicking around and a lot of the
allocations end up being remote.

zone reclaiming on:

Average Optimal -j 8 Load Run:
Elapsed Time 703.87
User Time 1337.77
System Time 47.94
Percent CPU 196
Context Switches 73669
Sleeps 58874

zone reclaiming off:

Average Optimal -j 8 Load Run:
Elapsed Time 741.22
User Time 1396.97
System Time 65.14
Percent CPU 197
Context Switches 73211
Sleeps 58996

mh

-- 
Martin Hicks   ||   Silicon Graphics Inc.   ||   mort@sgi.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
