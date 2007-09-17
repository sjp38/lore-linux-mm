Date: Mon, 17 Sep 2007 12:10:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/6] cpuset write dirty map
In-Reply-To: <20070914161536.3ec5c533.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709171200360.27542@schroedinger.engr.sgi.com>
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
 <46E742A2.9040006@google.com> <20070914161536.3ec5c533.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 14 Sep 2007, Andrew Morton wrote:

> It'd be nice to see some discussion regarding the memory consumption of
> this patch and the associated tradeoffs.

On small NUMA system < 64 nodes you basically have an additional word 
added to the address_space structure. On large NUMA we may have to 
allocate very large per node arrays of up to 1024 nodes which may result 
in 128 bytes used. However, the very large systems are rare thus we want 
to do the allocation dynamically.

> afacit there is no code comment and no changelog text which explains the
> above design decision?  There should be, please.

Hmmmm... There was an extensive discussion on that one early in the year 
and I had it in the overview of the earlier releases. Ethan: Maybe get 
that piece into the overview?

> There is talk of making cpusets available with CONFIG_SMP=n.  Will this new
> feature be available in that case?  (it should be).

Yes. Cpuset with CONFIG_SMP=n has been run for years on IA64 with Tony 
Luck's special configurations.

> >  EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);
> >  
> > +#if MAX_NUMNODES > BITS_PER_LONG
> 
> waah.  In other places we do "MAX_NUMNODES <= BITS_PER_LONG"

So 

#if !(MAX_NUMNODES <= BITS_PER_LONG)

> > +/*
> > + * Special functions for NUMA systems with a large number of nodes.
> > + * The nodemask is pointed to from the address space structures.
> > + * The attachment of the dirty_node mask is protected by the
> > + * tree_lock. The nodemask is freed only when the inode is cleared
> > + * (and therefore unused, thus no locking necessary).
> > + */
> 
> hmm, OK, there's a hint as to wghat's going on.
> 
> It's unobvious why the break point is at MAX_NUMNODES = BITS_PER_LONG and
> we might want to tweak that in the future.  Yet another argument for
> centralising this comparison.

A pointer has the size of BITS_PER_LONG. If we have less nodes then we 
just waste memory and processing by having a pointer there.


> > +void cpuset_update_dirty_nodes(struct address_space *mapping,
> > +			struct page *page)
> > +{
> > +	nodemask_t *nodes = mapping->dirty_nodes;
> > +	int node = page_to_nid(page);
> > +
> > +	if (!nodes) {
> > +		nodes = kmalloc(sizeof(nodemask_t), GFP_ATOMIC);
> 
> Does it have to be atomic?  atomic is weak and can fail.
> 
> If some callers can do GFP_KERNEL and some can only do GFP_ATOMIC then we
> should at least pass the gfp_t into this function so it can do the stronger
> allocation when possible.

This is called from __set_page_dirty_nobuffers. There is no allocation 
context available at that point. If the allocation fails then we do not 
allocate a tracking structure which means that no targeted writeout occurs.

> > +void cpuset_clear_dirty_nodes(struct address_space *mapping)
> > +{
> > +	nodemask_t *nodes = mapping->dirty_nodes;
> > +
> > +	if (nodes) {
> > +		mapping->dirty_nodes = NULL;
> > +		kfree(nodes);
> > +	}
> > +}
> 
> Can this race with cpuset_update_dirty_nodes()?  And with itself?  If not,
> a comment which describes the locking requirements would be good.

You just quoted the comment above that explains the locking requirements. 
Here it is again:

/*
+ * Special functions for NUMA systems with a large number of nodes.
+ * The nodemask is pointed to from the address space structures.
+ * The attachment of the dirty_node mask is protected by the
+ * tree_lock. The nodemask is freed only when the inode is cleared
+ * (and therefore unused, thus no locking necessary).
+ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
