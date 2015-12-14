Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id ACAEE6B0038
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 12:15:17 -0500 (EST)
Received: by pfbo64 with SMTP id o64so29821489pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 09:15:17 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e22si18230868pfd.60.2015.12.14.09.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 09:15:16 -0800 (PST)
Date: Mon, 14 Dec 2015 20:14:55 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 4/4] mm: memcontrol: clean up alloc, online, offline,
 free functions
Message-ID: <20151214171455.GF28521@esperanza>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
 <1449863653-6546-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1449863653-6546-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Dec 11, 2015 at 02:54:13PM -0500, Johannes Weiner wrote:
...
> -static int
> -mem_cgroup_css_online(struct cgroup_subsys_state *css)
> +static struct cgroup_subsys_state * __ref
> +mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  {
> -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> -	struct mem_cgroup *parent = mem_cgroup_from_css(css->parent);
> -	int ret;
> -
> -	if (css->id > MEM_CGROUP_ID_MAX)
> -		return -ENOSPC;
> +	struct mem_cgroup *parent = mem_cgroup_from_css(parent_css);
> +	struct mem_cgroup *memcg;
> +	long error = -ENOMEM;
>  
> -	if (!parent)
> -		return 0;
> +	memcg = mem_cgroup_alloc();
> +	if (!memcg)
> +		return ERR_PTR(error);
>  
>  	mutex_lock(&memcg_create_mutex);

It is pointless to take memcg_create_mutex in ->css_alloc. It won't
prevent setting use_hierarchy for parent after a new child was
allocated, but before it was added to the list of children (see
create_css()). Taking the mutex in ->css_online renders this race
impossible. That is, your cleanup breaks use_hierarchy consistency
check.

Can we drop this use_hierarchy consistency check at all and allow
children of a cgroup with use_hierarchy=1 have use_hierarchy=0? Yeah,
that might result in some strangeness if cgroups are created in parallel
with use_hierarchy flipped, but is it a valid use case? I surmise, one
just sets use_hierarchy for a cgroup once and for good before starting
to create sub-cgroups.

> -
> -	memcg->use_hierarchy = parent->use_hierarchy;
> -	memcg->oom_kill_disable = parent->oom_kill_disable;
> -	memcg->swappiness = mem_cgroup_swappiness(parent);
> -
> -	if (parent->use_hierarchy) {
> +	memcg->high = PAGE_COUNTER_MAX;
> +	memcg->soft_limit = PAGE_COUNTER_MAX;
> +	if (parent)
> +		memcg->swappiness = mem_cgroup_swappiness(parent);
> +	if (parent && parent->use_hierarchy) {
> +		memcg->use_hierarchy = true;
> +		memcg->oom_kill_disable = parent->oom_kill_disable;

oom_kill_disable was propagated to child cgroup despite use_hierarchy
configuration. I don't see any reason to change this.

>  		page_counter_init(&memcg->memory, &parent->memory);
> -		memcg->high = PAGE_COUNTER_MAX;
> -		memcg->soft_limit = PAGE_COUNTER_MAX;
>  		page_counter_init(&memcg->memsw, &parent->memsw);
>  		page_counter_init(&memcg->kmem, &parent->kmem);
>  		page_counter_init(&memcg->tcpmem, &parent->tcpmem);
> -
> -		/*
> -		 * No need to take a reference to the parent because cgroup
> -		 * core guarantees its existence.
> -		 */
>  	} else {
>  		page_counter_init(&memcg->memory, NULL);
> -		memcg->high = PAGE_COUNTER_MAX;
> -		memcg->soft_limit = PAGE_COUNTER_MAX;
>  		page_counter_init(&memcg->memsw, NULL);
>  		page_counter_init(&memcg->kmem, NULL);
>  		page_counter_init(&memcg->tcpmem, NULL);
> @@ -4296,19 +4211,30 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	}
>  	mutex_unlock(&memcg_create_mutex);
>  
> -	ret = memcg_propagate_kmem(memcg);
> -	if (ret)
> -		return ret;
> +	/* The following stuff does not apply to the root */
> +	if (!parent) {
> +		root_mem_cgroup = memcg;
> +		return &memcg->css;
> +	}
> +
> +	error = memcg_propagate_kmem(parent, memcg);

I don't think ->css_alloc is the right place for this function: if
create_css() fails after ->css_alloc and before ->css_online, it'll call
->css_free, which won't cleanup kmem properly.

> +	if (error)
> +		goto fail;
>  
>  	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
>  		static_branch_inc(&memcg_sockets_enabled_key);

Frankly, I don't get why this should live here either. This has nothing
to do with memcg allocation and looks rather like a preparation for
online.

>  
> -	/*
> -	 * Make sure the memcg is initialized: mem_cgroup_iter()
> -	 * orders reading memcg->initialized against its callers
> -	 * reading the memcg members.
> -	 */
> -	smp_store_release(&memcg->initialized, 1);
> +	return &memcg->css;
> +fail:
> +	mem_cgroup_free(memcg);
> +	return NULL;
> +}
> +
> +static int
> +mem_cgroup_css_online(struct cgroup_subsys_state *css)
> +{
> +	if (css->id > MEM_CGROUP_ID_MAX)
> +		return -ENOSPC;
>  
>  	return 0;
>  }
> @@ -4330,10 +4256,7 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  	}
>  	spin_unlock(&memcg->event_list_lock);
>  
> -	vmpressure_cleanup(&memcg->vmpressure);
> -
>  	memcg_offline_kmem(memcg);
> -
>  	wb_memcg_offline(memcg);
>  }
>  
> @@ -4347,9 +4270,11 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
>  	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && memcg->tcpmem_active)
>  		static_branch_dec(&memcg_sockets_enabled_key);
>  
> +	vmpressure_cleanup(&memcg->vmpressure);

vmpressure->work can be scheduled after offline, so ->css_free is
definitely the right place for vmpressure_cleanup. Looks like you've
just fixed a potential use-after-free bug.

Thanks,
Vladimir

> +	cancel_work_sync(&memcg->high_work);
> +	mem_cgroup_remove_from_trees(memcg);
>  	memcg_free_kmem(memcg);
> -
> -	__mem_cgroup_free(memcg);
> +	mem_cgroup_free(memcg);
>  }
>  
>  /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
