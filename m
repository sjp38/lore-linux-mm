Date: Fri, 15 Sep 2006 10:08:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060914220011.2be9100a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609151004580.7975@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 14 Sep 2006, Andrew Morton wrote:

> hm.  GFP_THISNODE is dangerous.  For example, its use in
> kernel/profile.c:create_hash_tables() has gone and caused non-NUMA machines
> to use __GFP_NOWARN | __GFP_NORETRY in this situation.
> 
> OK, that's relatively harmless here, but why on earth did non-NUMA
> machines want to make this change?

Right. We could define GFP_THISNODE to be 0 in the non-NUMA. Note the 
missing __ __GFP_xx cannot be redefined to be 0 otherwise we get into
trouble bitchecking.

> Would it not be saner to do away with the dangerous GFP_THISNODE and then
> open-code __GFP_THIS_NODE in those places which want that behaviour?

That would bypass various processes in the page allocator. We are already
copying the fallback lists processing to other allocators but this would 
mean even more of the page allocator would be replicated elsewhere.

> And to then make non-NUMA __GFP_THISNODE equal literal zero, so we can
> remove the above ifdefs?

We can easily make GFP_THISNODE 0 which will make it easy to use.

> > + 	if (!objp)
> > + 		objp = __cache_alloc_node(cachep, flags, numa_node_id());
> > +#endif
> 
> What happened to my `#define NUMA_BUILD 0 or 1' proposal?  If we had that,
> the above could be
> 
> 	if (NUMA_BUILD && !objp)
> 		objp = ...

Ok. Lets do that then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
