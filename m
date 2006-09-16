Date: Fri, 15 Sep 2006 20:38:16 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060915203816.fd260a0b.pj@sgi.com>
In-Reply-To: <20060915012810.81d9b0e3.akpm@osdl.org>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915012810.81d9b0e3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

[Adding Andi to cc list, since I mention him below. -pj]

Andrew wrote:
> I'm thinking a) is easily solved by adding an array of the zones inside the
> `struct cpuset', and change get_page_from_freelist() to only look at those
> zones.
> ...
> err, if we cache the most-recently-allocated-from zone in the cpuset then
> we don't need the array-of-zones, do we?  We'll only need to do a zone
> waddle when switching from one zone to the next, which is super-rare.
> 
> That's much simpler.
> ...
> And locking becomes simpler too.  It's just a check of
> cpuset_zone_allowed(current->cpuset->current_allocation_zone)

This will blow chunks performance wise, with the current cpuset locking
scheme.

Just one current_allocation_zone would not be enough.  Each node that
the cpuset allowed would require its own current_allocation_zone.  For
example, on a big honkin NUMA box with 2 CPUs per Node, tasks running
on CPU 32, Node 16, might be able to find free memory right on that
Node 16.  But another task in the same cpuset running on CPU 112, Node
56 might have to scan past a dozen Nodes to Node 68 to find memory.

Accessing anything from a cpuset that depends on what nodes it allows
requires taking the global mutex callback_mutex (in kernel/cpuset.c).
We don't want to put a global mutex on the page alloc hot code path.

Anything we need to access frequently from a tasks cpuset has to be
cached in its task struct.

Three alternative possibilities:

1)  Perhaps these most-recently-allocated-from-zone's shouldn't be
    properties of the cpuset, nor even of the task, but of the zone structs.

    If each zone struct on the zonelist had an additional flag bit marking
    the zones that had no free memory, then we could navigate the zonelist
    pretty quickly.  One more bit per zone struct would be enough to track
    a simple rescan mechanism, so that we could detect when a node that
    had formerly run out of memory once again had free memory.

    One or two bits per zone struct would be way cheaper, so far as
    data space requirements.

    Downside - it still hits each zone struct - suboptimal cache trashing.
    One less pointer chase than z->zone_pgdat->node_id, but still not
    great.

2)  It may be sufficient to locally optimize get_page_from_freelist()'s
    calls to cpuset_zone_allowed() - basically open code cpuset_zone_allowed,
    or at least refine its invocation.

    This might require a second nodemask in the task struct, for the typically
    larger set of nodes that GFP_KERNEL allocations can use, more than just
    the nodes that GFP_USER can use.  Such a second nodemask in the task struct
    would enable me to avoid taking the global callback_mutex for some GFP_KERNEL 
    allocations on tight memory systems.

    Downside #1 - still requires z->zone_pgdat->node_id.  Andrew suspects
    that this is enough of a problem in itself.  From the profile, which
    showed cpuset_zone_allowed(), not get_page_from_freelist(), at the
    top of the list, given that the node id is evaluated in the
    get_page_from_freelist() routine, I was figuring that the real
    problem was in the cpuset_zone_allowed() code.  Perhaps some testing
    of a simple hack approximation to this patch will tell us - next week.

    Downside #2 - may require the above mentioned additional nodemask_t
    in the task struct.

3)  The custom zonelist option - which was part of my original cpuset
    proposal, and which Andi K and I have gone back and forth on, with
    each of us liking and disliking it, at different times.  See further
    my latest writeup on this option:

      http://lkml.org/lkml/2005/11/5/252
      Date	Sat, 5 Nov 2005 20:18:41 -0800
      From	Paul Jackson <pj@sgi.com>
      Subject	Re: [PATCH]: Clean up of __alloc_pages

My current plan - see if somehow I can code up and get tested (2),
since a rough approximation to it would be trivial to code.  If that
works, go with it, unless someone convinces me otherwise.  If (2) can't
do the job, try (1), since that seems easier to code.  If that fails,
or someone shoots that down, or Andi makes a good enough case for (3),
give (3) a go - that's the hardest path, and risks the most collateral
damage to the behaviour of the memory paging subsystem.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
