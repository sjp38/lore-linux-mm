Date: Thu, 18 Oct 2007 18:20:50 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch](memory hotplug) Make kmem_cache_node for SLUB on memory online to avoid panic(take 3)
In-Reply-To: <20071017204651.aefcece7.akpm@linux-foundation.org>
References: <20071018122345.514F.Y-GOTO@jp.fujitsu.com> <20071017204651.aefcece7.akpm@linux-foundation.org>
Message-Id: <20071018173526.515B.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 18 Oct 2007 12:25:37 +0900 Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
> 
> > 
> > This patch fixes panic due to access NULL pointer
> > of kmem_cache_node at discard_slab() after memory online.
> > 
> > When memory online is called, kmem_cache_nodes are created for
> > all SLUBs for new node whose memory are available.
> > 
> > slab_mem_going_online_callback() is called to make kmem_cache_node()
> > in callback of memory online event. If it (or other callbacks) fails,
> > then slab_mem_offline_callback() is called for rollback.
> > 
> > In memory offline, slab_mem_going_offline_callback() is called to
> > shrink all slub cache, then slab_mem_offline_callback() is called later.
> > 
> > This patch is tested on my ia64 box.
> > 
> > ...
> >  
> > +#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
> 
> hm.  There should be no linkage between memory hotpluggability and
> NUMA, surely?

Sure. IBM's powerpc boxes have to support memory hotplug even if it 
is non-numa machine. They have the Dynamic Logical Partitioning feature.

> > +	down_read(&slub_lock);
> > +	list_for_each_entry(s, &slab_caches, list) {
> > +		n = get_node(s, offline_node);
> > +		if (n) {
> > +			/*
> > +			 * if n->nr_slabs > 0, slabs still exist on the node
> > +			 * that is going down. We were unable to free them,
> > +			 * and offline_pages() function shoudn't call this
> > +			 * callback. So, we must fail.
> > +			 */
> > +			BUG_ON(atomic_read(&n->nr_slabs));
> 
> Expereince tells us that WARN_ON is preferred for newly added code ;)

Oh... Ok!

> > +			s->node[offline_node] = NULL;
> > +			kmem_cache_free(kmalloc_caches, n);
> > +		}
> > +	}
> > +	up_read(&slub_lock);
> > +}
> > +
> > +static int slab_mem_going_online_callback(void *arg)
> > +{
> > +	struct kmem_cache_node *n;
> > +	struct kmem_cache *s;
> > +	struct memory_notify *marg = arg;
> > +	int nid = marg->status_change_nid;
> > +
> > +	/*
> > +	 * If the node's memory is already available, then kmem_cache_node is
> > +	 * already created. Nothing to do.
> > +	 */
> > +	if (nid < 0)
> > +		return 0;
> > +
> > +	/*
> > +	 * We are bringing a node online. No memory is availabe yet. We must
> > +	 * allocate a kmem_cache_node structure in order to bring the node
> > +	 * online.
> > +	 */
> > +	down_read(&slub_lock);
> > +	list_for_each_entry(s, &slab_caches, list) {
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

Oops. Indeed. Thanks for your check.

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
