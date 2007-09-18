Date: Tue, 18 Sep 2007 12:05:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC/Patch](memory hotplug) fix null pointer access of
 kmem_cache_node after memory hotplug
In-Reply-To: <20070918211932.0FFD.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0709181200400.3351@schroedinger.engr.sgi.com>
References: <20070918211932.0FFD.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Yasunori Goto wrote:

> Its cause was null pointer access to kmem_cache_node of SLUB at
> discard_slab().
> In my understanding, it should be created for all slubs after
> memory-less-node(or new node) gets new memory. But, current -mm doen't it.
> This patch fix for it.

Right. Isnt there a notifier chain that can be used to create the missing 
node structure?

> If kmem_cache_node is created at online_pages() of memory hot-add,
> it should be done before build_zonelist to avoid race condition.
> But, it means kmem_cache_node must be allocated on other old nodes
> due not to complete initialization.

Why before build_zonelist? The regular slab bootstrap occurs after
zonelist creation.

> I think this "delay creation" fix is better way than it.

Looks like this is a way to on demand node structure creation?

> I know that failure case of kmem_cache_alloc_node() must be written
> and the prototype of init_kmem_cache_node() here is not good.
> Just I would like to confirm that I don't overlook something about SLUB.

Could be okay. I would feel better if we always had a per node structure 
for each available node on the node that it covers.

> +	else if (node_state(page_nid, N_HIGH_MEMORY) && s != kmalloc_caches) {
> +		/*
> +		 * If new memory is onlined on new(or memory less) node,
> +		 * this will happen. (Second comparison is to avoid eternal
> +		 * recursion.)
> +		 */

For memoryless nodes this function will return NULL which will cause 
fallback. It looks like we are not going into this branch because in that 
case N_HIGH_MEMORY will not be set for the node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
