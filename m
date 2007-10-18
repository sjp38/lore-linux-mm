Date: Wed, 17 Oct 2007 23:25:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch](memory hotplug) Make kmem_cache_node for SLUB on memory
 online to avoid panic(take 3)
In-Reply-To: <20071017204651.aefcece7.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0710172321550.11401@schroedinger.engr.sgi.com>
References: <20071018122345.514F.Y-GOTO@jp.fujitsu.com>
 <20071017204651.aefcece7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Oct 2007, Andrew Morton wrote:

> > +#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
> 
> hm.  There should be no linkage between memory hotpluggability and
> NUMA, surely?

NUMA support in the slab allocators requires allocation of per node 
structures. The per node structures are folded into the global structure 
for non NUMA.

> > +			/*
> > +			 * if n->nr_slabs > 0, slabs still exist on the node
> > +			 * that is going down. We were unable to free them,
> > +			 * and offline_pages() function shoudn't call this
> > +			 * callback. So, we must fail.
> > +			 */
> > +			BUG_ON(atomic_read(&n->nr_slabs));
> 
> Expereince tells us that WARN_ON is preferred for newly added code ;)

It would be bad to just zap a per node array while there is still data in 
there. This will cause later failures when an attempt is made to free the 
objects that now have no per node structure anymore.

> > +  		/*
> > +		 * XXX: kmem_cache_alloc_node will fallback to other nodes
> > +		 *      since memory is not yet available from the node that
> > +		 *      is brought up.
> > +  		 */
> > +		n = kmem_cache_alloc(kmalloc_caches, GFP_KERNEL);
> > +		if (!n)
> > +			return -ENOMEM;
> 
> err, we forgot slub_lock.  I'll fix that.

Right.

> So that's slub.  Does slab already have this functionality or are you
> not bothering to maintain slab in this area?

Slab brings up a per node structure when the corresponding cpu is brought 
up. That was sufficient as long as we did not have any memoryless nodes. 
Now we may have to fix some things over there as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
