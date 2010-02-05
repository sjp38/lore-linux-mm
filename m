Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2A86B0071
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 16:18:02 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o15LHx86018612
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 13:17:59 -0800
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by wpaz13.hot.corp.google.com with ESMTP id o15LHwL2027267
	for <linux-mm@kvack.org>; Fri, 5 Feb 2010 13:17:58 -0800
Received: by pzk33 with SMTP id 33so896548pzk.2
        for <linux-mm@kvack.org>; Fri, 05 Feb 2010 13:17:58 -0800 (PST)
Date: Fri, 5 Feb 2010 13:17:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [2/4] SLAB: Set up the l3 lists for the memory of freshly
 added memory
In-Reply-To: <20100203213913.D5CD4B1620@basil.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002051316300.2376@chino.kir.corp.google.com>
References: <201002031039.710275915@firstfloor.org> <20100203213913.D5CD4B1620@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Andi Kleen wrote:

> Index: linux-2.6.33-rc3-ak/mm/slab.c
> ===================================================================
> --- linux-2.6.33-rc3-ak.orig/mm/slab.c
> +++ linux-2.6.33-rc3-ak/mm/slab.c
> @@ -115,6 +115,7 @@
>  #include	<linux/reciprocal_div.h>
>  #include	<linux/debugobjects.h>
>  #include	<linux/kmemcheck.h>
> +#include	<linux/memory.h>
>  
>  #include	<asm/cacheflush.h>
>  #include	<asm/tlbflush.h>
> @@ -1560,6 +1561,20 @@ void __init kmem_cache_init(void)
>  	g_cpucache_up = EARLY;
>  }
>  
> +static int slab_memory_callback(struct notifier_block *self,
> +				unsigned long action, void *arg)
> +{
> +	struct memory_notify *mn = (struct memory_notify *)arg;

No cast necessary.

> +
> +	/*
> +	 * When a node goes online allocate l3s early.	 This way
> +	 * kmalloc_node() works for it.
> +	 */
> +	if (action == MEM_ONLINE && mn->status_change_nid >= 0)
> +		slab_node_prepare(mn->status_change_nid);
> +	return NOTIFY_OK;
> +}
> +
>  void __init kmem_cache_init_late(void)
>  {
>  	struct kmem_cache *cachep;
> @@ -1583,6 +1598,8 @@ void __init kmem_cache_init_late(void)
>  	 */
>  	register_cpu_notifier(&cpucache_notifier);
>  
> +	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);

Only needed for CONFIG_NUMA.

> +
>  	/*
>  	 * The reap timers are started later, with a module init call: That part
>  	 * of the kernel is not yet operational.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
