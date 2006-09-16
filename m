Date: Sat, 16 Sep 2006 14:51:17 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060916145117.9b44786d.pj@sgi.com>
In-Reply-To: <20060916083825.ba88eee8.akpm@osdl.org>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060916044847.99802d21.pj@sgi.com>
	<20060916083825.ba88eee8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Andrew wrote:
> Pretty much all loads?  If you haven't consumed most of the "container"'s
> memory then you have overprovisioned its size.

Not so on real NUMA boxes.  If you configure your system so that
you are having to go a long way off-node for much of your memory,
then your performance is screwed.

No one in their right mind would run a memory hog that eats 40 nodes
of memory and a kernel build both in the same 60 node, small CPU
count cpuset on a real NUMA box.

The primary motivation for cpusets is to improve memory locality on
NUMA boxes.  You're using fake numa and cpusets to simulate destroying
memory locality.

On a real 64 node NUMA box, there would be 64 differently sorted
zonelists, each one centered on a different node.  The kernel build
would be running on different CPUs, associated with different nodes
than the memory hog, and it would be using zonelists that had the
unloaded (still has free memory) nodes at the front the list.

Aha - maybe this is the problem - the fake numa stuff is missing the
properly sorted zone lists.

We normally pick which zone list to use based on which CPU the
thread is running on, but that assumes there are at least as many
CPUs as Nodes, so that we have a many-to-one map from CPUs to Nodes.
In this fake numa setup, we've got way more Nodes than CPUs.

The current macro wrapper that calls __alloc_pages() in gfp.h relies
on per-node data to select a zonelist, and the node is selected based
on the tasks current CPU.  You can see this in the following code
from mmzone.h and gfp.h:

  #define numa_node_id()   (cpu_to_node(raw_smp_processor_id()))

  nid = numa_node_id();

  return __alloc_pages(gfp_mask, order,
        NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));

For the fake numa mechanism to work well, it would need to assign a
different zone list to the kernel build tasks in this test case than
it assigned to the memory hogs.  These different zone lists would
have to have a different sort, with unloaded nodes at the front.
The definition of numa_node_id() would have to depend on more than
just the processor id for this to work.

Perhaps the memory hog and the kernel build should be in separate
cpusets, and the zonelists they were assigned should depend on their
cpuset (not just their current CPU, as it is now), so that they
got zonelists with a different sort to them.  Then the kernel build
wouldn't have to waddle past all the used up memory hog nodes to find
some free memory

...

Well, I intentionally overstated the case a bit.  I doubt that we
should put a big effort -at this time- into elaborating the zonelists
and numa_node_id() mechanisms for x86_64 fake numa configurations.

Rather, we should recognize that it is only in such configurations that
the existing code in get_page_from_freelist() and cpuset_zone_allowed()
has the suboptimal performance observed here, due to the different
zonelist configuration.


In an earlier message, Andrew wrote:
> Guys, it's still 50 cachelines per page.  This one needs more than tweaking
> - algorithmic changes are needed.

I disagree (respectfully disagree -- Andrew has *way* more experience
hacking memory code than I ;).

I still don't know if this x86_64 fake numa mechanism has any real
life outside of entertaining kernel memory hackers.

We should first see how far the localized tweaks get us.

I suspect the tweaks will help quite a bit and provide an adequate
basis for effective machine partitioning, as proposed by the various
bright sparks.  If this partitioning proves useful, then I agree
that we should elaborate the algorithms and data structures to also
handle this usage well.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
