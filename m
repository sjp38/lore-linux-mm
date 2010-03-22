Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DB0216B01BD
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 13:29:19 -0400 (EDT)
Message-ID: <4BA7A8D6.4000706@cs.helsinki.fi>
Date: Mon, 22 Mar 2010 19:28:54 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch] slab: add memory hotplug support
References: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box> <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com> <20100305062002.GV8653@laptop> <alpine.DEB.2.00.1003081502400.30456@chino.kir.corp.google.com> <20100309134633.GM8653@laptop>
In-Reply-To: <20100309134633.GM8653@laptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Mon, Mar 08, 2010 at 03:19:48PM -0800, David Rientjes wrote:
>> On Fri, 5 Mar 2010, Nick Piggin wrote:
>>
>>>> +#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
>>>> +/*
>>>> + * Drains and frees nodelists for a node on each slab cache, used for memory
>>>> + * hotplug.  Returns -EBUSY if all objects cannot be drained on memory
>>>> + * hot-remove so that the node is not removed.  When used because memory
>>>> + * hot-add is canceled, the only result is the freed kmem_list3.
>>>> + *
>>>> + * Must hold cache_chain_mutex.
>>>> + */
>>>> +static int __meminit free_cache_nodelists_node(int node)
>>>> +{
>>>> +	struct kmem_cache *cachep;
>>>> +	int ret = 0;
>>>> +
>>>> +	list_for_each_entry(cachep, &cache_chain, next) {
>>>> +		struct array_cache *shared;
>>>> +		struct array_cache **alien;
>>>> +		struct kmem_list3 *l3;
>>>> +
>>>> +		l3 = cachep->nodelists[node];
>>>> +		if (!l3)
>>>> +			continue;
>>>> +
>>>> +		spin_lock_irq(&l3->list_lock);
>>>> +		shared = l3->shared;
>>>> +		if (shared) {
>>>> +			free_block(cachep, shared->entry, shared->avail, node);
>>>> +			l3->shared = NULL;
>>>> +		}
>>>> +		alien = l3->alien;
>>>> +		l3->alien = NULL;
>>>> +		spin_unlock_irq(&l3->list_lock);
>>>> +
>>>> +		if (alien) {
>>>> +			drain_alien_cache(cachep, alien);
>>>> +			free_alien_cache(alien);
>>>> +		}
>>>> +		kfree(shared);
>>>> +
>>>> +		drain_freelist(cachep, l3, l3->free_objects);
>>>> +		if (!list_empty(&l3->slabs_full) ||
>>>> +					!list_empty(&l3->slabs_partial)) {
>>>> +			/*
>>>> +			 * Continue to iterate through each slab cache to free
>>>> +			 * as many nodelists as possible even though the
>>>> +			 * offline will be canceled.
>>>> +			 */
>>>> +			ret = -EBUSY;
>>>> +			continue;
>>>> +		}
>>>> +		kfree(l3);
>>>> +		cachep->nodelists[node] = NULL;
>>> What's stopping races of other CPUs trying to access l3 and array
>>> caches while they're being freed?
>>>
>> numa_node_id() will not return an offlined nodeid and cache_alloc_node() 
>> already does a fallback to other onlined nodes in case a nodeid is passed 
>> to kmalloc_node() that does not have a nodelist.  l3->shared and l3->alien 
>> cannot be accessed without l3->list_lock (drain, cache_alloc_refill, 
>> cache_flusharray) or cache_chain_mutex (kmem_cache_destroy, cache_reap).
> 
> Yeah, but can't it _have_ a nodelist (ie. before it is set to NULL here)
> while it is being accessed by another CPU and concurrently being freed
> on this one? 
> 
> 
>>>> +	}
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +/*
>>>> + * Onlines nid either as the result of memory hot-add or canceled hot-remove.
>>>> + */
>>>> +static int __meminit slab_node_online(int nid)
>>>> +{
>>>> +	int ret;
>>>> +	mutex_lock(&cache_chain_mutex);
>>>> +	ret = init_cache_nodelists_node(nid);
>>>> +	mutex_unlock(&cache_chain_mutex);
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +/*
>>>> + * Offlines nid either as the result of memory hot-remove or canceled hot-add.
>>>> + */
>>>> +static int __meminit slab_node_offline(int nid)
>>>> +{
>>>> +	int ret;
>>>> +	mutex_lock(&cache_chain_mutex);
>>>> +	ret = free_cache_nodelists_node(nid);
>>>> +	mutex_unlock(&cache_chain_mutex);
>>>> +	return ret;
>>>> +}
>>>> +
>>>> +static int __meminit slab_memory_callback(struct notifier_block *self,
>>>> +					unsigned long action, void *arg)
>>>> +{
>>>> +	struct memory_notify *mnb = arg;
>>>> +	int ret = 0;
>>>> +	int nid;
>>>> +
>>>> +	nid = mnb->status_change_nid;
>>>> +	if (nid < 0)
>>>> +		goto out;
>>>> +
>>>> +	switch (action) {
>>>> +	case MEM_GOING_ONLINE:
>>>> +	case MEM_CANCEL_OFFLINE:
>>>> +		ret = slab_node_online(nid);
>>>> +		break;
>>> This would explode if CANCEL_OFFLINE fails. Call it theoretical and
>>> put a panic() in here and I don't mind. Otherwise you get corruption
>>> somewhere in the slab code.
>>>
>> MEM_CANCEL_ONLINE would only fail here if a struct kmem_list3 couldn't be 
>> allocated anywhere on the system and if that happens then the node simply 
>> couldn't be allocated from (numa_node_id() would never return it as the 
>> cpu's node, so it's possible to fallback in this scenario).
> 
> Why would it never return the CPU's node? It's CANCEL_OFFLINE that is
> the problem.

So I was thinking of pushing this towards Linus but I didn't see anyone 
respond to Nick's concerns. I'm not that familiar with all this hotplug 
stuff so can someone make also Nick happy so we can move forward?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
