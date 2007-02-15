Date: Thu, 15 Feb 2007 01:38:10 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: NUMA replicated pagecache
Message-ID: <20070215003810.GE29797@wotan.suse.de>
References: <20070213060924.GB20644@wotan.suse.de> <1171485124.5099.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1171485124.5099.43.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 14, 2007 at 03:32:04PM -0500, Lee Schermerhorn wrote:
> On Tue, 2007-02-13 at 07:09 +0100, Nick Piggin wrote:
> > Hi,
> > 
> > Just tinkering around with this and got something working, so I'll see
> > if anyone else wants to try it.
> > 
> > Not proposing for inclusion, but I'd be interested in comments or results.
> > 
> > Thanks,
> > Nick
> 
> I've included a small patch below that allow me to build and boot with
> these patches on an HP NUMA platform.  I'm still seeing an "unable to

Thanks Lee. Merged.

> > - Would like to be able to control replication via userspace, and maybe
> >   even internally to the kernel.
> How about per cpuset?  Consider a cpuset, on a NUMA system, with cpus
> and memories from a specific set of nodes.  One might choose to have
> page cache pages referenced by tasks in this cpuset to be pulled into
> the cpuset's memories for local access.  The remainder of the system may
> choose not to replicate page cache pages--e.g., to conserve memory.
> However, "unreplicating" on write would still need to work system wide.
> 
> But, note:  may [probably] want option to disable replication for shmem
> pages?  I'm thinking here of large data base shmem regions that, at any
> time, might have a lot of pages accessed "read only".  Probably wouldn't
> want a lot of replication/unreplication happening behind the scene. 

Yeah cpusets is an interesting possibility. A per-inode attribute could be
another one. The good old global sysctl is also a must :)


> > - Ideally, reclaim might reclaim replicated pages preferentially, however
> >   I aim to be _minimally_ intrusive.
> > - Would like to replicate PagePrivate, but filesystem may dirty page via
> >   buffers. Any solutions? (currently should mount with 'nobh').
> Linux migrates pages with PagePrivate using a per mapping migratepage
> address space op to handle the buffers.  File systems can provide their
> own or use a generic version.  How about a "replicatepage" aop?

I guess the main problem is those filesystems which dirty the page via
the buffers, via b_this_page, or b_data. However AFAIKS, these only happen
for things like directories. I _think_ we can safely assume that regular
file pages will not get modified (that would be data corruption!).

> > +struct page * find_get_page_readonly(struct address_space *mapping, unsigned long offset)
> > +{
> > +	struct page *page;
> > +
> > +retry:
> > +	read_lock_irq(&mapping->tree_lock);
> > +	if (radix_tree_tag_get(&mapping->page_tree, offset,
> > +					PAGECACHE_TAG_REPLICATED)) {
> > +		int nid;
> > +		struct pcache_desc *pcd;
> > +replicated:
> > +		nid = numa_node_id();
> > +		pcd = radix_tree_lookup(&mapping->page_tree, offset);
> ??? possible NULL pcd?  I believe I'm seeing one here...

Hmm, OK. I'll have to do some stress testing. I'm sure there are a few bugs
left.

> 
> > +		if (!node_isset(nid, pcd->nodes_present)) {
> Do this check [and possible replicate] only if replication enabled
> [system wide?, per cpuset?  based on explicit replication policy?, ...]?

Yep.

> > +			struct page *repl_page;
> > +
> > +			page = pcd->master;
> > +			page_cache_get(page);
> > +			read_unlock_irq(&mapping->tree_lock);
> > +			repl_page = alloc_pages_node(nid,
> > +					mapping_gfp_mask(mapping), 0);
> ??? don't try to hard to allocate page, as it's only a performance
> optimization.  E.g., add in GFP_THISNODE and remove and __GFP_WAIT?

I think that has merit. The problem if we remove __GFP_WAIT is that the
page allocator gives us access to some reserves. __GFP_NORETRY should
be reasonable?

> 
> > +			if (!repl_page)
> > +				return page;
> > +			copy_highpage(repl_page, page);
> > +			flush_dcache_page(repl_page);
> > +			page->mapping = mapping;
> > +			page->index = offset;
> > +			SetPageUptodate(repl_page); /* XXX: nonatomic */
> > +			page_cache_release(page);
> > +			write_lock_irq(&mapping->tree_lock);
> > +			__insert_replicated_page(repl_page, mapping, offset, nid);
> ??? can this fail due to race?  Don't care because we retry the lookup?
> page freed [released] in the function...

Yeah, I told you it was ugly :P Sorry you had to wade through this, but
it can be cleaned up..

> >  EXPORT_SYMBOL(find_lock_page);
> ??? should find_trylock_page() handle potential replicated page?
>     until it is removed, anyway?  

It is removed upstream, but in 2.6.20 it has no callers anyway so I didn't
worry about it.


Thanks for the comments & patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
