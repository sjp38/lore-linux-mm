Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 341824403D8
	for <linux-mm@kvack.org>; Fri,  5 Feb 2016 10:44:49 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id n128so70100670pfn.3
        for <linux-mm@kvack.org>; Fri, 05 Feb 2016 07:44:49 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id b10si24662214pas.7.2016.02.05.07.44.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Feb 2016 07:44:48 -0800 (PST)
Subject: Re: [PATCHv5] mm: slab: free kmem_cache_node after destroy sysfs file
References: <1454686692-18939-1-git-send-email-dsafonov@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <56B4C369.3090709@virtuozzo.com>
Date: Fri, 5 Feb 2016 18:44:41 +0300
MIME-Version: 1.0
In-Reply-To: <1454686692-18939-1-git-send-email-dsafonov@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Vladimir Davydov <vdavydov@virtuozzo.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/05/2016 06:38 PM, Dmitry Safonov wrote:
> With enabled slub_debug alloc_calls_show will try to track location and
> user of slab object on each online node, kmem_cache_node structure
> shouldn't be freed till there is the last reference to sysfs file.
Oh, scratch this, friday evening, will resent update just now.
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
>
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
> ---
> v2: Down with SLAB_SUPPORTS_SYSFS thing.
> v3: Moved sysfs_slab_remove inside shutdown_cache
> v4: Reworked all to shutdown & free caches on object->release()
> v5: Made separate __kmem_cache_free_nodes function and call it on release.
>
>   mm/slab.c        | 12 +++++++++---
>   mm/slab.h        |  1 +
>   mm/slab_common.c |  1 +
>   mm/slob.c        |  4 ++++
>   mm/slub.c        |  8 ++++----
>   5 files changed, 19 insertions(+), 7 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 6ecc697..3ccdf3c 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2276,6 +2276,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>   	err = setup_cpu_cache(cachep, gfp);
>   	if (err) {
>   		__kmem_cache_shutdown(cachep);
> +		__kmem_cache_free_nodes(cachep);
>   		return err;
>   	}
>   
> @@ -2414,8 +2415,6 @@ int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
>   
>   int __kmem_cache_shutdown(struct kmem_cache *cachep)
>   {
> -	int i;
> -	struct kmem_cache_node *n;
>   	int rc = __kmem_cache_shrink(cachep, false);
>   
>   	if (rc)
> @@ -2423,6 +2422,14 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
>   
>   	free_percpu(cachep->cpu_cache);
>   
> +	return 0;
> +}
> +
> +void __kmem_cache_free_nodes(struct kmem_cache *cachep)
> +{
> +	int i;
> +	struct kmem_cache_node *n;
> +
>   	/* NUMA: free the node structures */
>   	for_each_kmem_cache_node(cachep, i, n) {
>   		kfree(n->shared);
> @@ -2430,7 +2437,6 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
>   		kfree(n);
>   		cachep->node[i] = NULL;
>   	}
> -	return 0;
>   }
>   
>   /*
> diff --git a/mm/slab.h b/mm/slab.h
> index 834ad24..b1a6576 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -140,6 +140,7 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>   #define CACHE_CREATE_MASK (SLAB_CORE_FLAGS | SLAB_DEBUG_FLAGS | SLAB_CACHE_FLAGS)
>   
>   int __kmem_cache_shutdown(struct kmem_cache *);
> +void __kmem_cache_free_nodes(struct kmem_cache *);
>   int __kmem_cache_shrink(struct kmem_cache *, bool);
>   void slab_kmem_cache_release(struct kmem_cache *);
>   
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index b50aef0..0bc2da3 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -693,6 +693,7 @@ static inline int shutdown_memcg_caches(struct kmem_cache *s,
>   
>   void slab_kmem_cache_release(struct kmem_cache *s)
>   {
> +	__kmem_cache_free_nodes(s);
>   	destroy_memcg_params(s);
>   	kfree_const(s->name);
>   	kmem_cache_free(kmem_cache, s);
> diff --git a/mm/slob.c b/mm/slob.c
> index 17e8f8c..242d77d 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -630,6 +630,10 @@ int __kmem_cache_shutdown(struct kmem_cache *c)
>   	return 0;
>   }
>   
> +void __kmem_cache_free_nodes(struct kmem_cache *c)
> +{
> +}
> +
>   int __kmem_cache_shrink(struct kmem_cache *d, bool deactivate)
>   {
>   	return 0;
> diff --git a/mm/slub.c b/mm/slub.c
> index 2e1355a..d05bcea 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3173,7 +3173,7 @@ static void early_kmem_cache_node_alloc(int node)
>   	__add_partial(n, page, DEACTIVATE_TO_HEAD);
>   }
>   
> -static void free_kmem_cache_nodes(struct kmem_cache *s)
> +void __kmem_cache_free_nodes(struct kmem_cache *s)
>   {
>   	int node;
>   	struct kmem_cache_node *n;
> @@ -3199,7 +3199,7 @@ static int init_kmem_cache_nodes(struct kmem_cache *s)
>   						GFP_KERNEL, node);
>   
>   		if (!n) {
> -			free_kmem_cache_nodes(s);
> +			__kmem_cache_free_nodes(s);
>   			return 0;
>   		}
>   
> @@ -3405,7 +3405,7 @@ static int kmem_cache_open(struct kmem_cache *s, unsigned long flags)
>   	if (alloc_kmem_cache_cpus(s))
>   		return 0;
>   
> -	free_kmem_cache_nodes(s);
> +	__kmem_cache_free_nodes(s);
>   error:
>   	if (flags & SLAB_PANIC)
>   		panic("Cannot create slab %s size=%lu realsize=%u "
> @@ -3477,7 +3477,7 @@ static inline int kmem_cache_close(struct kmem_cache *s)
>   			return 1;
>   	}
>   	free_percpu(s->cpu_slab);
> -	free_kmem_cache_nodes(s);
> +	__kmem_cache_free_nodes(s);
>   	return 0;
>   }
>   


-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
