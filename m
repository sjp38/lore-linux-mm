Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 007816B007B
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 16:45:22 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id o1BLjKE7022838
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:45:20 -0800
Received: from pxi13 (pxi13.prod.google.com [10.243.27.13])
	by spaceape10.eur.corp.google.com with ESMTP id o1BLjI7E027815
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:45:19 -0800
Received: by pxi13 with SMTP id 13so1200047pxi.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2010 13:45:18 -0800 (PST)
Date: Thu, 11 Feb 2010 13:45:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] [3/4] SLAB: Set up the l3 lists for the memory of freshly
 added memory v2
In-Reply-To: <20100211205403.05A8EB1978@basil.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002111344130.8809@chino.kir.corp.google.com>
References: <20100211953.850854588@firstfloor.org> <20100211205403.05A8EB1978@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, Andi Kleen wrote:

> Index: linux-2.6.32-memhotadd/mm/slab.c
> ===================================================================
> --- linux-2.6.32-memhotadd.orig/mm/slab.c
> +++ linux-2.6.32-memhotadd/mm/slab.c
> @@ -115,6 +115,7 @@
>  #include	<linux/reciprocal_div.h>
>  #include	<linux/debugobjects.h>
>  #include	<linux/kmemcheck.h>
> +#include	<linux/memory.h>
>  
>  #include	<asm/cacheflush.h>
>  #include	<asm/tlbflush.h>
> @@ -1554,6 +1555,23 @@ void __init kmem_cache_init(void)
>  	g_cpucache_up = EARLY;
>  }
>  
> +static int slab_memory_callback(struct notifier_block *self,
> +				unsigned long action, void *arg)
> +{
> +	struct memory_notify *mn = (struct memory_notify *)arg;
> +
> +	/*
> +	 * When a node goes online allocate l3s early.	 This way
> +	 * kmalloc_node() works for it.
> +	 */
> +	if (action == MEM_ONLINE && mn->status_change_nid >= 0) {
> +		mutex_lock(&cache_chain_mutex);
> +		slab_node_prepare(mn->status_change_nid);
> +		mutex_unlock(&cache_chain_mutex);
> +	}
> +	return NOTIFY_OK;
> +}
> +
>  void __init kmem_cache_init_late(void)
>  {
>  	struct kmem_cache *cachep;
> @@ -1577,6 +1595,8 @@ void __init kmem_cache_init_late(void)
>  	 */
>  	register_cpu_notifier(&cpucache_notifier);
>  
> +	hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK_PRI);
> +

Only needed for CONFIG_NUMA, but there's no side-effects for UMA kernels 
since status_change_nid will always be -1.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
