Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DNBurU021852
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 19:11:56 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DNBust261848
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 17:11:56 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DNBtWQ008059
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 17:11:56 -0600
Date: Wed, 13 Jun 2007 16:11:53 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
Message-ID: <20070613231153.GW3798@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com> <1181769033.6148.116.camel@localhost> <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On 13.06.2007 [15:46:11 -0700], Christoph Lameter wrote:
> On Wed, 13 Jun 2007, Lee Schermerhorn wrote:
> 
> > SLUB early allocation, included in the patch.  Works on HP ia64 platform
> > with small DMA only node and "zone order" zonelists.  Will test on
> > x86_64 real soon now...
> 
> I do not see the difference?? How does this work? node_memory(x) fails 
> there?
> 
> > The map of nodes with memory may include nodes with just
> > DMA/DMA32 memory.  Using this map/mask together with
> > GFP_THISNODE will not guarantee on-node allocations at higher
> > zones.  Modify checks in alloc_pages_node() to ensure that the
> > first zone in the selected zonelist is "on-node".
> 
> That check is already done by __alloc_pages.
> 
> > This change will result in alloc_pages_node() returning NULL
> > when GFP_THISNODE is specified and the first zone in the zonelist
> > selected by (nid, gfp_zone(gfp_mask) is not on node 'nid'.  This,
> > in turn, BUGs out in slub.c:early_kmem_cache_node_alloc() which
> > apparently can't handle a NULL page from new_slab().  Fix SLUB
> > to handle NULL page in early allocation.
> 
> Ummm... Slub would need to consult node_memory_map instead I guess.
> 
> > Index: Linux/mm/slub.c
> > ===================================================================
> > --- Linux.orig/mm/slub.c	2007-06-13 16:36:02.000000000 -0400
> > +++ Linux/mm/slub.c	2007-06-13 16:38:41.000000000 -0400
> > @@ -1870,16 +1870,18 @@ static struct kmem_cache_node * __init e
> >  	/* new_slab() disables interupts */
> >  	local_irq_enable();
> >  
> > -	BUG_ON(!page);
> > -	n = page->freelist;
> > -	BUG_ON(!n);
> > -	page->freelist = get_freepointer(kmalloc_caches, n);
> > -	page->inuse++;
> > -	kmalloc_caches->node[node] = n;
> > -	setup_object_debug(kmalloc_caches, page, n);
> > -	init_kmem_cache_node(n);
> > -	atomic_long_inc(&n->nr_slabs);
> > -	add_partial(n, page);
> > +	if (page) {
> > +		n = page->freelist;
> > +		BUG_ON(!n);
> > +		page->freelist = get_freepointer(kmalloc_caches, n);
> > +		page->inuse++;
> > +		kmalloc_caches->node[node] = n;
> > +		setup_object_debug(kmalloc_caches, page, n);
> > +		init_kmem_cache_node(n);
> > +		atomic_long_inc(&n->nr_slabs);
> > +		add_partial(n, page);
> > +	} else
> > +		kmalloc_caches->node[node] = NULL;
> >  	return n;
> >  }
> 
> It would be easier to modify SLUB to loop over node_memory_map instead of 
> node_online_map? Potentially we have to change all loops over online node 
> in the slab allocators.

So, I think we are really close to closing the gaps here. Just need to
figure out how to fix Lee's platform so it does what he wants, I think.
I've tested the current set (which is going to change again, once we
figure out how to deal with SLUB (I'm guessing we'll go with your patch
Christoph, but it didn't exist when I was testing earlier :) and Lee's
platform properly). But everything, including the sysfs allocator, works
with a 4-node x86_64, with all nodes populated and a 4-node ppc64, with
only 2 nodes populated.

I would like to roll up the patches and small fixes into a set of 4 or 5
patches that Andrew can pick up, so once this is all stable, I'll post a
fresh series. Sound good, Andrew?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
