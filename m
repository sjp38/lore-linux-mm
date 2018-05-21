Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECE616B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 14:42:30 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x32-v6so10459707pld.16
        for <linux-mm@kvack.org>; Mon, 21 May 2018 11:42:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f9-v6si2469522pgn.334.2018.05.21.11.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 11:42:29 -0700 (PDT)
Date: Mon, 21 May 2018 11:42:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix race between kmem_cache destroy, create and
 deactivate
Message-Id: <20180521114227.233983ac7038a9f4bf5b7066@linux-foundation.org>
In-Reply-To: <20180521174116.171846-1-shakeelb@google.com>
References: <20180521174116.171846-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 21 May 2018 10:41:16 -0700 Shakeel Butt <shakeelb@google.com> wrote:

> The memcg kmem cache creation and deactivation (SLUB only) is
> asynchronous. If a root kmem cache is destroyed whose memcg cache is in
> the process of creation or deactivation, the kernel may crash.
> 
> Example of one such crash:
> 	general protection fault: 0000 [#1] SMP PTI
> 	CPU: 1 PID: 1721 Comm: kworker/14:1 Not tainted 4.17.0-smp
> 	...
> 	Workqueue: memcg_kmem_cache kmemcg_deactivate_workfn
> 	RIP: 0010:has_cpu_slab
> 	...
> 	Call Trace:
> 	? on_each_cpu_cond
> 	__kmem_cache_shrink
> 	kmemcg_cache_deact_after_rcu
> 	kmemcg_deactivate_workfn
> 	process_one_work
> 	worker_thread
> 	kthread
> 	ret_from_fork+0x35/0x40
> 
> This issue is due to the lack of reference counting for the root
> kmem_caches. There exist a refcount in kmem_cache but it is actually a
> count of aliases i.e. number of kmem_caches merged together.
> 
> This patch make alias count explicit and adds reference counting to the
> root kmem_caches. The reference of a root kmem cache is elevated on
> merge and while its memcg kmem_cache is in the process of creation or
> deactivation.
> 

The patch seems depressingly complex.

And a bit underdocumented...

> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -674,6 +674,8 @@ struct memcg_cache_params {
>  };
>  
>  int memcg_update_all_caches(int num_memcgs);
> +bool kmem_cache_tryget(struct kmem_cache *s);
> +void kmem_cache_put(struct kmem_cache *s);
>  
>  /**
>   * kmalloc_array - allocate memory for an array.
> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index d9228e4d0320..4bb22c89a740 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -41,7 +41,8 @@ struct kmem_cache {
>  /* 4) cache creation/removal */
>  	const char *name;
>  	struct list_head list;
> -	int refcount;
> +	refcount_t refcount;
> +	int alias_count;

The semantic meaning of these two?  What locking protects alias_count?

>  	int object_size;
>  	int align;
>  
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 3773e26c08c1..532d4b6f83ed 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -97,7 +97,8 @@ struct kmem_cache {
>  	struct kmem_cache_order_objects max;
>  	struct kmem_cache_order_objects min;
>  	gfp_t allocflags;	/* gfp flags to use on each alloc */
> -	int refcount;		/* Refcount for slab cache destroy */
> +	refcount_t refcount;	/* Refcount for slab cache destroy */
> +	int alias_count;	/* Number of root kmem caches merged */

"merged" what with what in what manner?

>  	void (*ctor)(void *);
>  	unsigned int inuse;		/* Offset to metadata */
>  	unsigned int align;		/* Alignment */
>
> ...
>
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -25,7 +25,8 @@ struct kmem_cache {
>  	unsigned int useroffset;/* Usercopy region offset */
>  	unsigned int usersize;	/* Usercopy region size */
>  	const char *name;	/* Slab name for sysfs */
> -	int refcount;		/* Use counter */
> +	refcount_t refcount;	/* Use counter */
> +	int alias_count;

Semantic meaning/usage of alias_count?  Locking for it?

>  	void (*ctor)(void *);	/* Called on object slot creation */
>  	struct list_head list;	/* List of all slab caches on the system */
>  };
>
> ...
>
> +bool kmem_cache_tryget(struct kmem_cache *s)
> +{
> +	if (is_root_cache(s))
> +		return refcount_inc_not_zero(&s->refcount);
> +	return false;
> +}
> +
> +void kmem_cache_put(struct kmem_cache *s)
> +{
> +	if (is_root_cache(s) &&
> +	    refcount_dec_and_test(&s->refcount))
> +		__kmem_cache_destroy(s, true);
> +}
> +
> +void kmem_cache_put_locked(struct kmem_cache *s)
> +{
> +	if (is_root_cache(s) &&
> +	    refcount_dec_and_test(&s->refcount))
> +		__kmem_cache_destroy(s, false);
> +}

Some covering documentation for the above would be useful.  Why do they
exist, why do they only operate on the root cache? etc.

>
> ...
>
