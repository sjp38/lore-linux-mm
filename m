Date: Tue, 19 Sep 2006 13:52:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060918093434.e66b8887.pj@sgi.com>
Message-ID: <Pine.LNX.4.63.0609191222310.7790@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
 <20060917041707.28171868.pj@sgi.com> <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
 <20060917060358.ac16babf.pj@sgi.com> <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
 <20060917152723.5bb69b82.pj@sgi.com> <Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
 <20060917192010.cc360ece.pj@sgi.com> <20060918093434.e66b8887.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006, Paul Jackson wrote:
> For now, it could be that we can't handle hybrid systems, and that fake
> numa systems simply have a distance table of all 10's, driven by the
> kernel boot command "numa=fake=N".  But that apparatus will have to be
> extended at some point, to support hybrid fake and real NUMA combined.
> And this will have to mature from being an arch=x86_64 only thing to
> being generically available.  And it will have to become a mechanism
> that can be applied on a running system, creating (and removing) fake
> nodes on the fly, without a reboot, so long as the required physical
> memory is free and available.
> 
> A comment above arch/x86_64/mm/srat.c slit_valid() raises concerns
> about a SLIT table with all 10's.  I suspect we will just have to find
> out the hard way what that problem is.  Change the table to all 10's
> on these fake numa systems and see what hurts.
> 
> The generic kernel code should deal with this, and in particular, the
> get_page_from_freelist() loop that provoked this discussion should be
> coded so that it caches the last used node iff that node is distance
> 10 from the node at the front of the zonelist.
> 
> The only way to make this kind of stuff hold up over the long term
> is to get a good conceptual model, and stick with it.  This fake
> numa provides for multiple logical nodes on a single physical node.
> 
> The modal approach I recommended yesterday, where a system either
> supported fake NUMA or real NUMA, but not both, had the stench of
> an intermediate solution that would not hold over the long run.
> 

Any solution for how to use numa=fake=N as a means of resource management 
will come with two prerequisites:

   1.	An increase in N does not lead to degraded performance due to
	get_page_from_freelist in any more than a negligible manner.

   2.	The current infrastructure of cpusets is not changed in a risky
	(or major) way to affect real NUMA machines.

We can assume for the matter of this implementation that the system 
administrator or whomever is responsible for using this means of 
memory management configures their machine appropriately.  So there is no 
worry about allocating 256 nodes when the intent is to split the machine 
down the middle and having two "containers" for their tasks.

My current fixes to numa=fake:

   1.	It allows N nodes to be split evenly over the memory map with no
	restriction on N being a power of 2.

   2.	Memory can be allocated in 4M contiguous chunks on a machine up
	to 64G.  This means my 3G box can be booted with numa=fake=256
	or even higher if NODE_SHIFT is increased.

   3.	Nodes can be asymmetric so that you can configure as many nodes
	as you want with the sizes you specify.

This provides the system administrator with all the functionality that he 
needs so that the machine can be configured appropriately for its foreseen 
workload.  It is not, however, a dynamic solution that Christoph suggests 
where nodes can be partitioned along themselves at runtime.

The problem that is being faced is prerequisite #1 whereas 
get_page_from_freelist needs to be more efficient when considering fake 
nodes as opposed to real nodes.  In favor of prerequisite #2, 
__node_distance in arch/x86_64/can be modified so that the distance 
between fake nodes is always 10 (no distance).  This is intuitive: we have 
a UMA machine that is acting in a NUMA environment and the notion of 
memory locality is no longer a consideration.  Fake nodes currently are 
not emulated among real nodes through Andi Kleen's implementation so the 
change to __node_distance is trivial once we have abstracted whether NUMA 
emulation is, in fact, being used.

The concern about that approach is the comment in slit_valid which 
suggests that the local node should always have a smaller distance than 
the others considering the NUMA heuristics.  One of those heuristics is in 
find_next_best_node where the next best node is determined by preferring 
those that have the least distance (in addition to those with CPUS, etc).  
This is not an issue since all nodes in a fake NUMA system will have the 
same distance and thus this heuristic becomes a non-factor.  The other 
heuristic is in build_zonelists where pages are reclaimed on a local node 
as opposed to from other nodes.  Since the distance, again, is always the 
same on each node in a fake NUMA system, this should not exceed 
RECLAIM_DISTANCE and thus it is acceptable at all times to reclaim from 
across nodes (since this is, after all, an UMA machine) and no preference 
is given to being across zones instead.

There is _no_ problem with the penalty on the first node in the same 
distance group in the build_zonelists iteration.  The load on each 
individual node will be the same since the distance between the nodes 
never changes and thus the ordering of nodes is appropriate even for our 
emulation.  To be convinced of this, for any node N, node_load[N] is 
always the same for each node in our UMA machine: find_next_best_node 
treats each node equally.

The return value on a numa_emulation call in arch/x86_64/mm/numa.c is 0 
when CONFIG_NUMA_EMU is enabled and the command line was parsed and setup 
correctly.  It becomes trivial to abstract this to the global kernel code 
by creating a macro that can be tested against for any generic 
architecture (and may become useful later when NUMA emulation is 
abstracted generically as suggested prior).

So, with these changes, we now assured:

   1.	A test against a macro in global kernel code where a numa=fake
	kernel can be evaluated.

   2.	That the ordering of next_best_node treats each node equally
	by keeping in the back of our minds that this is really a UMA
	machine.

This now no longer requires us to determine whether two fake nodes are 
really on the same hardware node because we recognize the NUMA emulation 
case when appropriate and the rest of the cpusets infrastructure is 
remained unchanged (prerequisite #2).

Now stepping back to prerequisite #1, we are required to modify 
__cpuset_zone_allowed for the case where we have NUMA emulation.  The idea 
is that since we have N number of nodes where N may be large, 
get_page_from_freelist scans those N nodes before finding memory on page 
claim.  This isn't a problem with the typical NUMA machine because free 
pages can normally be found quickly in a scan of the first few zonelist 
entries; this is thanks to the N differently sorted zonelists.  It _is_ a 
problem in NUMA emulation because we have many more nodes than CPU's, but 
it can be remedied with the proposed caching and changes to 
__node_distance.

As Paul and Andrew suggested, there are three additions to task_struct:

   1.	cached copy of struct zonelist *zonelist that was passed into
	get_page_from_freelist,

   2.	index of zone where free memory was located last, and

   3.	index of next zone to try when (2) is full.

get_page_from_freelist, in the case where the passed in zonelist* differs 
from (1) or in the ~GFP_HARDWALL & ~ALLOC_CPUSET case, uses the current 
implementation going through the zonelist and finding one with enough free 
pages.  Otherwise, if we are in the NUMA emulation case, the node where 
the memory was found most recently can be cached since all memory is 
equal.  There is no consideration given to the distance between the last 
used node and the node at the front of the zonelist because the distance 
between all nodes is 10.  (If the passed in zonelist* differs from (1), 
then the three additions to task_struct are reset per the new 
configuration in the same sense as cpuset_update_task_memory_state since 
the memory placement has changed relative to current->cpuset which 
cpusets allows by outside manipulation.)  

Now, when get_page_from_freelist is called, (3) is tested for new memory 
and used if some is found, otherwise it is incremented so that we don't 
spin on this one full zone (especially in the case with the memory hogs 
from my experiment where it would never get out of this spin).  This 
prevents us from having to take callback_mutex and makes the call to 
__cpuset_zone_allowed more efficient.

Thus this solution correctly implements prerequisite #1 and keeps the 
modification to the current infrastructure of cpusets small 
(prerequisite #2) by abstracting the NUMA emulation case away from the 
current code path.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
