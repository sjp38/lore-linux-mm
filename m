Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B65956B007E
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 01:20:15 -0500 (EST)
Date: Fri, 5 Mar 2010 17:20:03 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] slab: add memory hotplug support
Message-ID: <20100305062002.GV8653@laptop>
References: <alpine.DEB.2.00.1002240949140.26771@router.home>
 <4B862623.5090608@cs.helsinki.fi>
 <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002251228140.18861@router.home>
 <20100226114136.GA16335@basil.fritz.box>
 <alpine.DEB.2.00.1002260904311.6641@router.home>
 <20100226155755.GE16335@basil.fritz.box>
 <alpine.DEB.2.00.1002261123520.7719@router.home>
 <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 01, 2010 at 02:24:43AM -0800, David Rientjes wrote:
> Slab lacks any memory hotplug support for nodes that are hotplugged
> without cpus being hotplugged.  This is possible at least on x86
> CONFIG_MEMORY_HOTPLUG_SPARSE kernels where SRAT entries are marked
> ACPI_SRAT_MEM_HOT_PLUGGABLE and the regions of RAM represent a seperate
> node.  It can also be done manually by writing the start address to
> /sys/devices/system/memory/probe for kernels that have
> CONFIG_ARCH_MEMORY_PROBE set, which is how this patch was tested, and
> then onlining the new memory region.
> 
> When a node is hotadded, a nodelist for that node is allocated and 
> initialized for each slab cache.  If this isn't completed due to a lack
> of memory, the hotadd is aborted: we have a reasonable expectation that
> kmalloc_node(nid) will work for all caches if nid is online and memory is
> available.  
> 
> Since nodelists must be allocated and initialized prior to the new node's
> memory actually being online, the struct kmem_list3 is allocated off-node
> due to kmalloc_node()'s fallback.
> 
> When an entire node is offlined (or an online is aborted), these
> nodelists are subsequently drained and freed.  If objects still exist
> either on the partial or full lists for those nodes, the offline is
> aborted.  This scenario will not occur for an aborted online, however,
> since objects can never be allocated from those nodelists until the
> online has completed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

This looks OK to me in general. Couple of questions though:

> +#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
> +/*
> + * Drains and frees nodelists for a node on each slab cache, used for memory
> + * hotplug.  Returns -EBUSY if all objects cannot be drained on memory
> + * hot-remove so that the node is not removed.  When used because memory
> + * hot-add is canceled, the only result is the freed kmem_list3.
> + *
> + * Must hold cache_chain_mutex.
> + */
> +static int __meminit free_cache_nodelists_node(int node)
> +{
> +	struct kmem_cache *cachep;
> +	int ret = 0;
> +
> +	list_for_each_entry(cachep, &cache_chain, next) {
> +		struct array_cache *shared;
> +		struct array_cache **alien;
> +		struct kmem_list3 *l3;
> +
> +		l3 = cachep->nodelists[node];
> +		if (!l3)
> +			continue;
> +
> +		spin_lock_irq(&l3->list_lock);
> +		shared = l3->shared;
> +		if (shared) {
> +			free_block(cachep, shared->entry, shared->avail, node);
> +			l3->shared = NULL;
> +		}
> +		alien = l3->alien;
> +		l3->alien = NULL;
> +		spin_unlock_irq(&l3->list_lock);
> +
> +		if (alien) {
> +			drain_alien_cache(cachep, alien);
> +			free_alien_cache(alien);
> +		}
> +		kfree(shared);
> +
> +		drain_freelist(cachep, l3, l3->free_objects);
> +		if (!list_empty(&l3->slabs_full) ||
> +					!list_empty(&l3->slabs_partial)) {
> +			/*
> +			 * Continue to iterate through each slab cache to free
> +			 * as many nodelists as possible even though the
> +			 * offline will be canceled.
> +			 */
> +			ret = -EBUSY;
> +			continue;
> +		}
> +		kfree(l3);
> +		cachep->nodelists[node] = NULL;

What's stopping races of other CPUs trying to access l3 and array
caches while they're being freed?

> +	}
> +	return ret;
> +}
> +
> +/*
> + * Onlines nid either as the result of memory hot-add or canceled hot-remove.
> + */
> +static int __meminit slab_node_online(int nid)
> +{
> +	int ret;
> +	mutex_lock(&cache_chain_mutex);
> +	ret = init_cache_nodelists_node(nid);
> +	mutex_unlock(&cache_chain_mutex);
> +	return ret;
> +}
> +
> +/*
> + * Offlines nid either as the result of memory hot-remove or canceled hot-add.
> + */
> +static int __meminit slab_node_offline(int nid)
> +{
> +	int ret;
> +	mutex_lock(&cache_chain_mutex);
> +	ret = free_cache_nodelists_node(nid);
> +	mutex_unlock(&cache_chain_mutex);
> +	return ret;
> +}
> +
> +static int __meminit slab_memory_callback(struct notifier_block *self,
> +					unsigned long action, void *arg)
> +{
> +	struct memory_notify *mnb = arg;
> +	int ret = 0;
> +	int nid;
> +
> +	nid = mnb->status_change_nid;
> +	if (nid < 0)
> +		goto out;
> +
> +	switch (action) {
> +	case MEM_GOING_ONLINE:
> +	case MEM_CANCEL_OFFLINE:
> +		ret = slab_node_online(nid);
> +		break;

This would explode if CANCEL_OFFLINE fails. Call it theoretical and
put a panic() in here and I don't mind. Otherwise you get corruption
somewhere in the slab code.


> +	case MEM_GOING_OFFLINE:
> +	case MEM_CANCEL_ONLINE:
> +		ret = slab_node_offline(nid);
> +		break;
> +	case MEM_ONLINE:
> +	case MEM_OFFLINE:
> +		break;
> +	}
> +out:
> +	return ret ? notifier_from_errno(ret) : NOTIFY_OK;
> +}
> +#endif /* CONFIG_NUMA && CONFIG_MEMORY_HOTPLUG */
> +
>  /*
>   * swap the static kmem_list3 with kmalloced memory
>   */
> -static void init_list(struct kmem_cache *cachep, struct kmem_list3 *list,
> -			int nodeid)
> +static void __init init_list(struct kmem_cache *cachep, struct kmem_list3 *list,
> +				int nodeid)
>  {
>  	struct kmem_list3 *ptr;
>  
> @@ -1583,6 +1713,14 @@ void __init kmem_cache_init_late(void)
>  	 */
>  	register_cpu_notifier(&cpucache_notifier);
>  
> +#ifdef CONFIG_NUMA
> +	/*
> +	 * Register a memory hotplug callback that initializes and frees
> +	 * nodelists.
> +	 */
> +	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
> +#endif
> +
>  	/*
>  	 * The reap timers are started later, with a module init call: That part
>  	 * of the kernel is not yet operational.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
