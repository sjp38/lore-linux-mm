Subject: Re: [PATCH] Memoryless nodes:  use "node_memory_map" for cpuset
	mems_allowed validation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070723214816.GC6036@us.ibm.com>
References: <20070711182219.234782227@sgi.com>
	 <20070711182250.005856256@sgi.com>
	 <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
	 <1184964564.9651.66.camel@localhost> <20070723190922.GA6036@us.ibm.com>
	 <1185224393.23917.6.camel@localhost>  <20070723214816.GC6036@us.ibm.com>
Content-Type: text/plain
Date: Tue, 24 Jul 2007 10:11:03 -0400
Message-Id: <1185286264.5649.23.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-23 at 14:48 -0700, Nishanth Aravamudan wrote:
> On 23.07.2007 [16:59:52 -0400], Lee Schermerhorn wrote:
> > On Mon, 2007-07-23 at 12:09 -0700, Nishanth Aravamudan wrote: 
> > > On 20.07.2007 [16:49:24 -0400], Lee Schermerhorn wrote:
> > > > This fixes a problem I encountered testing Christoph's memoryless nodes
> > > > series.  Applies atop that series.  Other than this, series holds up
> > > > under what testing I've been able to do this week.
> > > > 
> > > > Memoryless Nodes:  use "node_memory_map" for cpusets mems_allowed validation
> > > > 
> > > > cpusets try to ensure that any node added to a cpuset's 
> > > > mems_allowed is on-line and contains memory.  The assumption
> > > > was that online nodes contained memory.  Thus, it is possible
> > > > to add memoryless nodes to a cpuset and then add tasks to this
> > > > cpuset.  This results in continuous series of oom-kill and other
> > > > console stack traces and apparent system hang.
> > > > 
> > > > Change cpusets to use node_states[N_MEMORY] [a.k.a.
> > > > node_memory_map] in place of node_online_map when vetting 
> > > > memories.  Return error if admin attempts to write a non-empty
> > > > mems_allowed node mask containing only memoryless-nodes.
> > > > 
> > > > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > 
> > > Lee, while looking at this change, I think it ends up fixing
> > > cpuset_mems_allowed() to return nodemasks that only include nodes in
> > > node_states[N_MEMORY]. However, cpuset_current_mems_allowed is a
> > > lockless macro which would still be broken. I think it would need to
> > > becom a static inline nodes_and() in the CPUSET case and a #define
> > > node_states[N_MEMORY] in the non-CPUSET case?
> > > 
> > > Or perhaps we should adjust cpusets to make it so that the mems_allowed
> > > member only includes nodes that are set in node_states[N_MEMORY]?
> > 
> > 
> > I thought that's what my patch to nodelist_parse() did.  It ensures that
> > current->mems_allowed is correct [contains at least one node with
> > memory, and only nodes with memory] at the time it is installed, but
> > doesn't consider memory hot plug and node off-lining.  Is this
> > [offline/hotplug] your point?
> 
> And everytime it is updated, right? (current->mems_allowed).   My concern
> is purely whether I can then directly use cpuset_current_mems_allowed in
> the interleave code for hugetlb.c and it will do the right thing. It
> will work, if the #define is changed for !CPUSETS and if your change
> guarantess current->mems_allowed is always consistent with
> node_states[N_MEMORY].

Other than offlining/hot removal of memory, I think the only place that
current->mems_allowed gets updated in in update_nodelist() [I wrote
nodelist_parse() previously by mistake].  My patch to that function
tries to ensure that current->mems_allowed always contains at least one
node with memory.

If by "gets updated" you're referring to
"cpuset_update_task_memory_state(), the latter calls
"guarantee_online_mems()", which I also patched to use
node_states[N_MEMORY] instead of "node_online_map".  So, I think you can
use current->mems_allowed in the hugetlb code.  Maybe call
"cpuset_update_task_memory_state()" before using it?  However, I think
that will have the effect of escaping the cpuset constraints if all of
the nodes in the current task's mems_allowed have been offlined or hot
removed since this mask was created/updated in update_nodelist().

> 
> I think I simply was confused about the full impact of your changes, as
> I don't know cpusets that well. I'm going to try and test a memoryless
> node box I have at work w/ your change, though, and see what happens.

FYI:  I initially tried to test Christoph's memless nodes series with
your rebased hugetlb patches, but the system appeared to hang.  [Might
be related to Ken Chen's recent hugetlb patch?]  I backed off to just
Christoph's series and things seem to run OK.  That's when I noticed
that one could create a cpuset with just memoryless nodes and posted the
subject patch.  I'll get back to testing your patches on my memoryless
nodes system "real soon now".

Meanwhile, as you've pointed out, I missed the "node_online_map" usage
in the header and, I see, in the initialization of the top level cpuset
in cpuset_init_smp().  I'm testing this now.  I'll repost the patch with
these fixes shortly.

For completeness, here's the numactl --hardware output [less the SLIT
info] from my test platform [ia64] in it's current config:

available: 5 nodes (0-4)
node 0 size: 0 MB
node 0 free: 0 MB
node 1 size: 0 MB
node 1 free: 0 MB
node 2 size: 0 MB
node 2 free: 0 MB
node 3 size: 0 MB
node 3 free: 0 MB
node 4 size: 8191 MB
node 4 free: 105 MB

Booted with mem=8G to ensure swapping, ...  Free mem is so low because
of the tests I'm running.  It varies between ~40M and ~150M.

> 
> > Seems like that is an issue that exists in the unpatched code as
> > well--i.e., unlike cpuset_mems_allowed(), the lockless, "_current_"
> > version does not vet current->mems_allowed against the
> > nodes_online_mask.  So, all valid nodes in current->mems_allowed could
> > have been off-lined since the mask was installed.  Am I reading this
> > right?
> 
> True -- I honestly don't know. I doubt much of this code has been fully
> audited for full node unplug?

Looks like at least an initial stab has been made...


Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
