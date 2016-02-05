Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A946C4403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 11:11:38 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id uo6so36823262pac.1
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 08:11:38 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e64si24760376pfd.66.2016.02.05.08.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 08:11:37 -0800 (PST)
Date: Fri, 5 Feb 2016 19:11:24 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCHv6] mm: slab: free kmem_cache_node after destroy sysfs file
Message-ID: <20160205161124.GA26693@esperanza>
References: <1454687136-19298-1-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1454687136-19298-1-git-send-email-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Feb 05, 2016 at 06:45:36PM +0300, Dmitry Safonov wrote:
> With enabled slub_debug alloc_calls_show will try to track location and
> user of slab object on each online node, kmem_cache_node structure
> shouldn't be freed till there is the last reference to sysfs file.
> 
> Fixes the following panic:
> [43963.463055] BUG: unable to handle kernel
> [43963.463090] NULL pointer dereference at 0000000000000020
> [43963.463146] IP: [<ffffffff811c6959>] list_locations+0x169/0x4e0
> [43963.463185] PGD 257304067 PUD 438456067 PMD 0
> [43963.463220] Oops: 0000 [#1] SMP
> [43963.463850] CPU: 3 PID: 973074 Comm: cat ve: 0 Not tainted 3.10.0-229.7.2.ovz.9.30-00007-japdoll-dirty #2 9.30
> [43963.463913] Hardware name: DEPO Computers To Be Filled By O.E.M./H67DE3, BIOS L1.60c 07/14/2011
> [43963.463976] task: ffff88042a5dc5b0 ti: ffff88037f8d8000 task.ti: ffff88037f8d8000
> [43963.464036] RIP: 0010:[<ffffffff811c6959>]  [<ffffffff811c6959>] list_locations+0x169/0x4e0
> [43963.464725] Call Trace:
> [43963.464756]  [<ffffffff811c6d1d>] alloc_calls_show+0x1d/0x30
> [43963.464793]  [<ffffffff811c15ab>] slab_attr_show+0x1b/0x30
> [43963.464829]  [<ffffffff8125d27a>] sysfs_read_file+0x9a/0x1a0
> [43963.464865]  [<ffffffff811e3c6c>] vfs_read+0x9c/0x170
> [43963.464900]  [<ffffffff811e4798>] SyS_read+0x58/0xb0
> [43963.464936]  [<ffffffff81612d49>] system_call_fastpath+0x16/0x1b
> [43963.464970] Code: 5e 07 12 00 b9 00 04 00 00 3d 00 04 00 00 0f 4f c1 3d 00 04 00 00 89 45 b0 0f 84 c3 00 00 00 48 63 45 b0 49 8b 9c c4 f8 00 00 00 <48> 8b 43 20 48 85 c0 74 b6 48 89 df e8 46 37 44 00 48 8b 53 10
> [43963.465119] RIP  [<ffffffff811c6959>] list_locations+0x169/0x4e0
> [43963.465155]  RSP <ffff88037f8dbe28>
> [43963.465185] CR2: 0000000000000020
> 
> Separated nodes structures freeing into __kmem_cache_free_nodes and use
> it at kmem_cache_release.

Well, that's better indeed, although still not perfect.

...
> diff --git a/mm/slab.c b/mm/slab.c
> index 6ecc697..3ccdf3c 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2276,6 +2276,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>  	err = setup_cpu_cache(cachep, gfp);
>  	if (err) {
>  		__kmem_cache_shutdown(cachep);
> +		__kmem_cache_free_nodes(cachep);

You don't need to call the whole shutdown procedure here - the cache
hasn't been used yet. __kmem_cache_release (about it below) would be
enough.

>  		return err;
>  	}
>  
> @@ -2414,8 +2415,6 @@ int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
>  
>  int __kmem_cache_shutdown(struct kmem_cache *cachep)
>  {
> -	int i;
> -	struct kmem_cache_node *n;
>  	int rc = __kmem_cache_shrink(cachep, false);
>  
>  	if (rc)
> @@ -2423,6 +2422,14 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
>  
>  	free_percpu(cachep->cpu_cache);

And how come ->cpu_cache (and ->cpu_slab in case of SLUB) is special?
Can't sysfs access it either? I propose to introduce a method called
__kmem_cache_release (instead of __kmem_cache_free_nodes), which would
do all freeing, both per-cpu and per-node.

Thanks,
Vladimir

>  
> +	return 0;
> +}
> +
> +void __kmem_cache_free_nodes(struct kmem_cache *cachep)
> +{
> +	int i;
> +	struct kmem_cache_node *n;
> +
>  	/* NUMA: free the node structures */
>  	for_each_kmem_cache_node(cachep, i, n) {
>  		kfree(n->shared);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
