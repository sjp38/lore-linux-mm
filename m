Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from
	MPOL_INTERLEAVE masks
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070801101651.GA9113@linux-sh.org>
References: <1185566878.5069.123.camel@localhost>
	 <20070728151912.c541aec0.kamezawa.hiroyu@jp.fujitsu.com>
	 <1185812028.5492.79.camel@localhost>  <20070801101651.GA9113@linux-sh.org>
Content-Type: text/plain
Date: Wed, 01 Aug 2007 09:39:18 -0400
Message-Id: <1185975558.5059.18.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, ak@suse.de, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-01 at 19:16 +0900, Paul Mundt wrote:
> On Mon, Jul 30, 2007 at 12:13:48PM -0400, Lee Schermerhorn wrote:
> > Rationale:  some architectures and platforms include nodes with
> > memory that, in some cases, should never appear in MPOL_INTERLEAVE
> > node masks.  For example, the 'sh' architecture contains a small
> > amount of SRAM that is local to each cpu.  In some applications,
> > this memory should be reserved for explicit usage.  Another example
> > is the pseudo-node on HP ia64 platforms that is already interleaved
> > on a cache-line granularity by hardware.  Again, in some cases, we
> > want to reserve this for explicit usage, as it has bandwidth and
> > [average] latency characteristics quite different from the "real"
> > nodes.
> > 
> Well, it's not so much the interleave that's the problem so much as
> _when_ we interleave. The problem with the interleave node mask at system
> init is that the kernel attempts to spread out data structures across
> these nodes, which results in us being completely out of memory by the
> time we get to userspace. After we've booted, supporting MPOL_INTERLEAVE
> is not so much of a problem, applications just have to be careful with
> their allocations.
> 
> The main thing is keeping the kernel away from these nodes unless it's
> been specifically asked to fetch some memory from there. Every page does
> count.
> 
> The real problem is how we want to deal with the node avoidance mask. In
> SLOB things presently work quite well in this regard, Christoph's
> slub_nodes= patch did a similar thing:
> 
> 	http://marc.info/?l=linux-mm&m=118127465421877&w=2
> 	http://marc.info/?l=linux-mm&m=118127688911359&w=2
> 
> > Note that allocation of fresh hugepages in response to increases
> > in /proc/sys/vm/nr_hugepages is a form of interleaving.  I would
> > like to propose that allocate_fresh_huge_page() use the 
> > N_INTERLEAVE state as well as MPOL_INTERLEAVE.  Then, one can
> > explicity allocate hugepages on the excluded nodes, when needed,
> > using Nish Aravamundan's per node huge page sysfs attribute.
> > NOT in this patch.
> > 
> If we can differentiate between MPOL_INTERLEAVE from the kernel's point
> of view, and explicit MPOL_INTERLEAVE specifiers via mbind() from
> userspace, that works fine for my case. However, the mpol_new() changes
> in this patch deny small nodes the ability to ever be included in an
> MPOL_INTERLEAVE policy, when it's only the kernel policy that I have a
> problem with.

Ah, but it would only "deny small nodes" if you nominate them in the
boot option.  I haven't changed your heuristic in numa_policy_init.  So,
it will still eliminate small nodes from the boot time interleave
nodemask, independent of whether or not you specify them in the
no_interleave_nodes list.

Or am I missing your point?
> 
> Having said that, I do like the node states and using that to exclude a
> node from the system init interleave nodelist, but this still won't
> completely solve the tiny node problems.

Right, so we should keep your boot time heuristic.

> 
> > @@ -184,7 +184,7 @@ static struct mempolicy *mpol_new(int mo
> >  	case MPOL_INTERLEAVE:
> >  		policy->v.nodes = *nodes;
> >  		nodes_and(policy->v.nodes, policy->v.nodes,
> > -					node_states[N_MEMORY]);
> > +					node_states[N_INTERLEAVE]);
> >  		if (nodes_weight(policy->v.nodes) == 0) {
> >  			kmem_cache_free(policy_cache, policy);
> >  			return ERR_PTR(-EINVAL);
> 
> Leaving this as node_states[N_MEMORY] combined with the rest of the patch
> would work for me, but that sort of changes the scope of the entire patch
> ;-)

Yeah, it breaks one of my main reasons for proposing this.  I still have
no way to keep user requested interleaving off my "special" hardware
interleaved nodes in the case where we don't want this.  I should
mention that I'm assuming that the current "best practice" is to
interleave across "all available nodes" in the applications current
context.

[more follow up to later messages]

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
