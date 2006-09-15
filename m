Date: Thu, 14 Sep 2006 23:49:26 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060914234926.9b58fd77.pj@sgi.com>
In-Reply-To: <20060914220011.2be9100a.akpm@osdl.org>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew wrote:
> hm, there's cpuset_zone_allowed() again.
> 
> I have a feeling that we need to nuke that thing: take a 128-node machine,
> create a cpuset which has 64 memnodes, consume all the memory in 60 of
> them, do some heavy page allocation, then stick a thermometer into
> get_page_from_freelist()?

Hmmm ... are you worried that if get_page_from_freelist() has to scan
many nodes before it finds memory, that it will end up spending more
CPU cycles than we'd like calling cpuset_zone_allowed()?

The essential thing that cpuset_zone_allowed() does, in the most common
case, is to determine if a zone is on one of the nodes the task is allowed
to use.

The get_page_from_freelist() and cpuset_zone_allowed() code is optimized
for the case that memory is usually found in the first few zones in the
zonelist.

Here's the relevant portion of the get_page_from_freelist() code, as it
stands now:


============================================================
static struct page *
get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
                struct zonelist *zonelist, int alloc_flags)
{
        struct zone **z = zonelist->zones;
	...
        do {
                if ((alloc_flags & ALLOC_CPUSET) &&
                                !cpuset_zone_allowed(*z, gfp_mask))
                        continue;
                ... if zone z has free pages, use them ...
        } while (*(++z) != NULL);
============================================================


For the purposes of discussion here, let me open code the hot code
path down into cpuset_zone_allowed(), so we can see more what's
happening here.  Here's the open coded rewrite:


============================================================
static struct page *
get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
                struct zonelist *zonelist, int alloc_flags)
{
        struct zone **z = zonelist->zones;
	...
	int do_cpuset_check = !in_interrupt() && alloc_flags & ALLOC_CPUSET;

        do {
		int node = z->zone_pgdat->node_id
                if (do_cpuset_check &&
				!node_isset(node, current->mems_allowed) &&
				!cpuset_zone_allowed_slow_path_check())
                        continue;
                ... if zone z has free pages, use them ...
        } while (*(++z) != NULL);
============================================================


With this open coding, we can see what cpuset_zone_allowed() is doing
here.  The key thing it must do each loop (each zone z) is to ask if
that zone's node is set in current->mems_allowed.

My hypothetical routine 'cpuset_zone_allowed_slow_path_check()'
contains the infrequently executed code path.  Usually, either we are
not doing the cpuset check (because we are in interrupt), or we are
checking and the check passes because the 'node' is allowed in
current->mems_allowed.

This code is optimized for the case that we find memory in a node
fairly near the front of the zonelist.  If we have to go scavanging
down a long list of zones before we find a node with free memory, then
yes, we are sucking wind calling cpuset_zone_allowed(), or my
hypothetical cpuset_zone_allowed_slow_path_check(), many times.

I guess that was your concern.

I don't think we should be tuning especially hard for that case.

On a big honking NUMA box, if we have to go scavanging for memory
dozens or hundreds of nodes removed from the scene of the memory fault,
then **even if we found that precious free page of memory instantly**
(in zero cost CPU cycles in the above code) we're -still- screwed.

Well, the user of that machine is still screwed.  They have overloaded
its memory, forcing poor NUMA placement. It's obviously not as bad as
swap hell, but it's not good either.  There is nothing that the above
code can do to make the "Non-Uniform" part of "NUMA" magically
disappear.  Recall that these zonelists are sorted by distance from
the starting node; so the further down the list we go, the slower the
memory we get, relative to the tasks current CPU.

We shouldn't be heavily tuning for this case, and I am not aware of any
real world situations where real users would have reasonably determined
otherwise, had they had full realization of what was going on.

By 'not heavily tuning', I mean we should be more interested in minimizing
kernel text size and cache footprint here than in optimizing CPU cycles
for the case of having to frequently scan a long way down a long zonelist.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
