Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 481626B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:56:05 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so3625601eaj.37
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 08:56:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s8si779736eeh.206.2013.12.18.08.56.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 08:56:04 -0800 (PST)
Date: Wed, 18 Dec 2013 17:56:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/6] slab: cleanup kmem_cache_create_memcg()
Message-ID: <20131218165603.GB31080@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 18-12-13 17:16:52, Vladimir Davydov wrote:
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Glauber Costa <glommer@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Dunno, is this really better to be worth the code churn?

It even makes the generated code tiny bit bigger:
text    data     bss     dec     hex filename
4355     171     236    4762    129a mm/slab_common.o.after
4342     171     236    4749    128d mm/slab_common.o.before

Or does it make the further changes much more easier? Be explicit in the
patch description if so.

> ---
>  mm/slab_common.c |   66 +++++++++++++++++++++++++++---------------------------
>  1 file changed, 33 insertions(+), 33 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 0b7bb39..5d6f743 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -176,8 +176,9 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>  	get_online_cpus();
>  	mutex_lock(&slab_mutex);
>  
> -	if (!kmem_cache_sanity_check(memcg, name, size) == 0)
> -		goto out_locked;
> +	err = kmem_cache_sanity_check(memcg, name, size);
> +	if (err)
> +		goto out_unlock;
>  
>  	/*
>  	 * Some allocators will constraint the set of valid flags to a subset
> @@ -189,45 +190,41 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
>  
>  	s = __kmem_cache_alias(memcg, name, size, align, flags, ctor);
>  	if (s)
> -		goto out_locked;
> +		goto out_unlock;
>  
>  	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
> -	if (s) {
> -		s->object_size = s->size = size;
> -		s->align = calculate_alignment(flags, align, size);
> -		s->ctor = ctor;
> -
> -		if (memcg_register_cache(memcg, s, parent_cache)) {
> -			kmem_cache_free(kmem_cache, s);
> -			err = -ENOMEM;
> -			goto out_locked;
> -		}
> +	if (!s) {
> +		err = -ENOMEM;
> +		goto out_unlock;
> +	}
>  
> -		s->name = kstrdup(name, GFP_KERNEL);
> -		if (!s->name) {
> -			kmem_cache_free(kmem_cache, s);
> -			err = -ENOMEM;
> -			goto out_locked;
> -		}
> +	s->object_size = s->size = size;
> +	s->align = calculate_alignment(flags, align, size);
> +	s->ctor = ctor;
>  
> -		err = __kmem_cache_create(s, flags);
> -		if (!err) {
> -			s->refcount = 1;
> -			list_add(&s->list, &slab_caches);
> -			memcg_cache_list_add(memcg, s);
> -		} else {
> -			kfree(s->name);
> -			kmem_cache_free(kmem_cache, s);
> -		}
> -	} else
> +	s->name = kstrdup(name, GFP_KERNEL);
> +	if (!s->name) {
>  		err = -ENOMEM;
> +		goto out_free_cache;
> +	}
> +
> +	err = memcg_register_cache(memcg, s, parent_cache);
> +	if (err)
> +		goto out_free_cache;
>  
> -out_locked:
> +	err = __kmem_cache_create(s, flags);
> +	if (err)
> +		goto out_free_cache;
> +
> +	s->refcount = 1;
> +	list_add(&s->list, &slab_caches);
> +	memcg_cache_list_add(memcg, s);
> +
> +out_unlock:
>  	mutex_unlock(&slab_mutex);
>  	put_online_cpus();
>  
>  	if (err) {
> -
>  		if (flags & SLAB_PANIC)
>  			panic("kmem_cache_create: Failed to create slab '%s'. Error %d\n",
>  				name, err);
> @@ -236,11 +233,14 @@ out_locked:
>  				name, err);
>  			dump_stack();
>  		}
> -
>  		return NULL;
>  	}
> -
>  	return s;
> +
> +out_free_cache:
> +	kfree(s->name);
> +	kmem_cache_free(kmem_cache, s);
> +	goto out_unlock;
>  }
>  
>  struct kmem_cache *
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
