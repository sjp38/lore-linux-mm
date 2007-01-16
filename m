Date: Tue, 16 Jan 2007 09:13:19 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/8] Cpuset aware writeback
In-Reply-To: <20070116012509.145ead36.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0701160907280.17822@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
 <20070116012509.145ead36.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jan 2007, Paul Jackson wrote:

> > 1. The nodemask expands the inode structure significantly if the
> > architecture allows a high number of nodes. This is only an issue
> > for IA64. 
> 
> Should that logic be disabled if HOTPLUG is configured on?  Or is
> nr_node_ids a valid upper limit on what could be plugged in, even on a
> mythical HOTPLUG system?

nr_node_ids is a valid upper limit on what could be plugged in. We could
modify nodemasks to only use nr_node_ids bits and the kernel would still
be functioning correctly.

> > 2. The calculation of the per cpuset limits can require looping
> > over a number of nodes which may bring the performance of get_dirty_limits
> > near pre 2.6.18 performance
> 
> Could we cache these limits?  Perhaps they only need to be recalculated if
> a tasks mems_allowed changes?

No they change dynamically. In particular writeout reduces the number of 
dirty / unstable pages.

> Separate question - what happens if a tasks mems_allowed changes while it is
> dirtying pages?  We could easily end up with dirty pages on nodes that are
> no longer allowed to the task.  Is there anyway that such a miscalculation
> could cause us to do harmful things?

The dirty_map on an inode is independent of a cpuset. The cpuset only 
comes into effect when we decide to do writeout and are scanning for files 
with pages on the nodes of interest.

> In patch 2/8:
> > The dirty map is cleared when the inode is cleared. There is no
> > synchronization (except for atomic nature of node_set) for the dirty_map. The
> > only problem that could be done is that we do not write out an inode if a
> > node bit is not set.
> 
> Does this mean that a dirty page could be left 'forever' in memory, unwritten,
> exposing us to risk of data corruption on disk, from some write done weeks ago,
> but unwritten, in the event of say a power loss?

No it will age and be written out anyways. Note that there are usually 
multiple dirty pages which reduces the chance of the race. These are node
bits that help to decide when to start writeout of all dirty pages of an 
inode regardless of where the other pages are.

> Also in patch 2/8:
> > +static inline void cpuset_update_dirty_nodes(struct inode *i,
> > +		struct page *page) {}
> 
> Is an incomplete 'struct inode;' declaration needed here in cpuset.h,
> to avoid a warning if compiling with CPUSETS not configured?

Correct.

> 
> In patch 4/8:
> > We now add per node information which I think is equal or less effort
> > since there are less nodes than processors.
> 
> Not so on Paul Menage's fake NUMA nodes - he can have say 64 fake nodes on
> a system with 2 or 4 CPUs and one real node.  But I guess that's ok ...

True but then its fake.

> In patch 4/8:
> > +#ifdef CONFIG_CPUSETS
> > +	/*
> > +	 * Calculate the limits relative to the current cpuset if necessary.
> > +	 */
> > +	if (unlikely(nodes &&
> > +			!nodes_subset(node_online_map, *nodes))) {
> > +		int node;
> > +
> > +		is_subset = 1;
> > +		...
> > +#ifdef CONFIG_HIGHMEM
> > +			high_memory += NODE_DATA(node)
> > +				->node_zones[ZONE_HIGHMEM]->present_pages;
> > +#endif
> > +			nr_mapped += node_page_state(node, NR_FILE_MAPPED) +
> > +					node_page_state(node, NR_ANON_PAGES);
> > +		}
> > +	} else
> > +#endif
> > +	{
> 
> I'm wishing there was a clearer way to write the above code.  Nested
> ifdef's and an ifdef block ending in an open 'else' and perhaps the first
> #ifdef CONFIG_CPUSETS ever, outside of fs/proc/base.c ...

I have tried to replicate the structure for global dirty_limits 
calculation which has the same ifdef.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
