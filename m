Date: Fri, 12 Oct 2007 15:15:41 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch 002/002] Create/delete kmem_cache_node for SLUB on memory online callback
In-Reply-To: <Pine.LNX.4.64.0710112056300.1882@schroedinger.engr.sgi.com>
References: <20071012112801.B9A1.Y-GOTO@jp.fujitsu.com> <Pine.LNX.4.64.0710112056300.1882@schroedinger.engr.sgi.com>
Message-Id: <20071012133336.B9A5.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 12 Oct 2007, Yasunori Goto wrote:
>  
> > If pages on the new node available, slub can use it before making
> > new kmem_cache_nodes. So, this callback should be called
> > BEFORE pages on the node are available.
> 
> If its called before pages on the node are available then it must 
> fallback and cannot use the pages.

Hmm. My description may be wrong. I would like to just
mention that kmem_cache_node should be created before the node's page
can be allocated. If not, it will cause of panic.


> > +#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
> > +static int slab_mem_going_offline_callback(void *arg)
> > +{
> > +	struct kmem_cache *s;
> > +	struct memory_notify *marg = arg;
> > +	int local_node, offline_node = marg->status_change_nid;
> > +
> > +	if (offline_node < 0)
> > +		/* node has memory yet. nothing to do. */
> 
> Please clarify the comment. This seems to indicate that we should not
> do anything because the node still has memory?

Yes. kmem_cache_node is still necessary for remaining memory on the
node.

> Doesnt the node always have memory before offlining?

If node doesn't have memory and offline_pages() called for it,
it must be check and fail. This callback shouldn't be called.
If not, it is bug of memory hotplug, I think.


> > +		return 0;
> > +
> > +	down_read(&slub_lock);
> > +	list_for_each_entry(s, &slab_caches, list) {
> > +		local_node = page_to_nid(virt_to_page(s));
> > +		if (local_node == offline_node)
> > +			/* This slub is on the offline node. */
> > +			return -EBUSY;
> > +	}
> > +	up_read(&slub_lock);
> 
> So this checks if the any kmem_cache structure is on the offlined node? If
> so then we cannot offline the node?

Right. If slabs' migration is possible, here would be good place for
doing it. But, it is not possible (at least now).

> > +	kmem_cache_shrink_node(s, offline_node);
> 
> kmem_cache_shrink(s) would be okay here I would think. The function is
> reasonably fast. Offlining is a rare event.

Ok. I'll fix it.

> > +static void slab_mem_offline_callback(void *arg)
> 
> We call this after we have established that no kmem_cache structures are 
> on this and after we have shrunk the slabs. Is there any guarantee that
> no slab operations have occurrent since then?

If slabs still exist, it can't be migrated and offline_pages() has
to give up offline. This means MEM_OFFLINE event is not generated when
slabs are on the removing node.
In other word, when this event is generated, all of pages on
this section is isolated and there are no used pages(slabs).


> 
> > +{
> > +	struct kmem_cache_node *n;
> > +	struct kmem_cache *s;
> > +	struct memory_notify *marg = arg;
> > +	int offline_node;
> > +
> > +	offline_node = marg->status_change_nid;
> > +
> > +	if (offline_node < 0)
> > +		/* node has memory yet. nothing to do. */
> > +		return;
> 
> Does this mean that the node still has memory?

Yes.


> > +	down_read(&slub_lock);
> > +	list_for_each_entry(s, &slab_caches, list) {
> > +		n = get_node(s, offline_node);
> > +		if (n) {
> > +			/*
> > +			 * if n->nr_slabs > 0, offline_pages() must be fail,
> > +			 * because the node is used by slub yet.
> > +			 */
> 
> It may be clearer to say:
> 
> "If nr_slabs > 0 then slabs still exist on the node that is going down.
> We were unable to free them so we must fail."

Again. If nr_slabs > 0, offline_pages must be fail due to slabs
remaining on the node before. So, this callback isn't called.

> > +static int slab_mem_going_online_callback(void *arg)
> > +{
> > +	struct kmem_cache_node *n;
> > +	struct kmem_cache *s;
> > +	struct memory_notify *marg = arg;
> > +	int nid = marg->status_change_nid;
> > +
> > +	/* If the node already has memory, then nothing is necessary. */
> > +	if (nid < 0)
> > +		return 0;
> 
> The node must have memory????  Or we have already brought up the code?

kmem_cache_node is created at boot time if the node has memory.
(Or, it is created by this callback on first added memory on the node).

When nid = - 1, kmem_cache_node is created before this node due to
node has memory. 

> 
> > +	/*
> > +	 * New memory will be onlined on the node which has no memory so far.
> > +	 * New kmem_cache_node is necssary for it.
> 
> "We are bringing a node online. No memory is available yet. We must 
> allocate a kmem_cache_node structure in order to bring the node online." ?

Your mention might be ok.
But. I would like to prefer to define status of node hotplug for
exactitude like followings


A)Node online -- pgdat is created and can be accessed for this node.
                 but there are no gurantee that cpu or memory is onlined.
                 This status is very close from memory-less node.
                 But this might be halfway status for node hotplug.
                 Node online bit is set. But N_HIGH_MEMORY
                 (or N_NORMAL_MEMORY) might be not set.

B)Node has memory--
                 one or more sections memory is onlined on the node.
                 N_HIGH_MEMORY (or N_NORMAL_MEMORY) is set.

If first memory is onlined on the node, the node status changes
from A) to B).

I feel this is very useful to manage "halfway status" of node
hotplug. (So, memory-less node patch is very helpful for me.)

So, I would like to avoid using the word "node online" at here.
But, if above definition is messy for others, I'll change it.


> > +	 */
> > +	down_read(&slub_lock);
> > +	list_for_each_entry(s, &slab_caches, list) {
> > +  		/*
> > +		 * XXX: The new node's memory can't be allocated yet,
> > +		 *      kmem_cache_node will be allocated other node.
> > +  		 */
> 
> "kmem_cache_alloc node will fallback to other nodes since memory is 
> not yet available from the node that is brought up."?

Yes.


Thanks for your comment.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
