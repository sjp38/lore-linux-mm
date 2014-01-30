Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id A7EE96B0039
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 16:14:49 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so3639008pbb.11
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:14:49 -0800 (PST)
Received: from mail-pb0-x22b.google.com (mail-pb0-x22b.google.com [2607:f8b0:400e:c01::22b])
        by mx.google.com with ESMTPS id qv10si7886861pbb.112.2014.01.30.13.14.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 13:14:48 -0800 (PST)
Received: by mail-pb0-f43.google.com with SMTP id md12so3610098pbc.16
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 13:14:48 -0800 (PST)
Date: Thu, 30 Jan 2014 13:14:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on memcg_create_kmem_cache
 fail path
In-Reply-To: <20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com>
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com> <20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 30 Jan 2014, Andrew Morton wrote:

> Well gee, how did that one get through?
> 
> What was the point in permanently allocating tmp_name, btw?  "This
> static temporary buffer is used to prevent from pointless shortliving
> allocation"?  That's daft - memcg_create_kmem_cache() is not a fastpath
> and there are a million places in the kernel where we could permanently
> leak memory because it is "pointless" to allocate on demand.
> 
> The allocation of PATH_MAX bytes is unfortunate - kasprintf() wouild
> work well here, but cgroup_name()'s need for rcu_read_lock() screws us
> up.
> 

What's funnier is that tmp_name isn't required at all since 
kmem_cache_create_memcg() is just going to do a kstrdup() on it anyway, so 
you could easily just pass in the pointer to memory that has been 
allocated for s->name rather than allocating memory twice.

> So how about doing this?
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/memcontrol.c: memcg_create_kmem_cache() tweaks
> 
> Allocate tmp_name on demand rather than permanently consuming PATH_MAX
> bytes of memory.  This permits a small reduction in the mutex hold time as
> well.
> 
> Cc: Glauber Costa <glommer@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/memcontrol.c |   11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff -puN mm/memcontrol.c~mm-memcontrolc-memcg_create_kmem_cache-tweaks mm/memcontrol.c
> --- a/mm/memcontrol.c~mm-memcontrolc-memcg_create_kmem_cache-tweaks
> +++ a/mm/memcontrol.c
> @@ -3401,17 +3401,14 @@ static struct kmem_cache *memcg_create_k
>  						  struct kmem_cache *s)
>  {
>  	struct kmem_cache *new = NULL;
> -	static char *tmp_name = NULL;
> +	static char *tmp_name;

You're keeping it static and the mutex so you're still keeping it global, 
ok...

>  	static DEFINE_MUTEX(mutex);	/* protects tmp_name */
>  
>  	BUG_ON(!memcg_can_account_kmem(memcg));
>  
> -	mutex_lock(&mutex);
>  	/*
> -	 * kmem_cache_create_memcg duplicates the given name and
> -	 * cgroup_name for this name requires RCU context.
> -	 * This static temporary buffer is used to prevent from
> -	 * pointless shortliving allocation.
> +	 * kmem_cache_create_memcg duplicates the given name and cgroup_name()
> +	 * for this name requires rcu_read_lock().
>  	 */
>  	if (!tmp_name) {
>  		tmp_name = kmalloc(PATH_MAX, GFP_KERNEL);

Eek, memory leak.  Two concurrent calls to memcg_create_kmem_cache() find 
!tmp_name and do the kmalloc() concurrently.

> @@ -3419,6 +3416,7 @@ static struct kmem_cache *memcg_create_k
>  			goto out;
>  	}
>  
> +	mutex_lock(&mutex);
>  	rcu_read_lock();
>  	snprintf(tmp_name, PATH_MAX, "%s(%d:%s)", s->name,
>  			 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
> @@ -3432,6 +3430,7 @@ static struct kmem_cache *memcg_create_k
>  		new = s;
>  out:
>  	mutex_unlock(&mutex);
> +	kfree(tmp_name);

Why would we free the global buffer?

>  	return new;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
