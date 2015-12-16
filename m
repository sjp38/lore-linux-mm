Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id E0AE76B0267
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 07:17:49 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id kw15so24329200lbb.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 04:17:49 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id p5si3512038lfb.119.2015.12.16.04.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 04:17:48 -0800 (PST)
Date: Wed, 16 Dec 2015 15:17:27 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 4/4] mm: memcontrol: clean up alloc, online, offline,
 free functions
Message-ID: <20151216121727.GL28521@esperanza>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
 <1449863653-6546-4-git-send-email-hannes@cmpxchg.org>
 <20151214171455.GF28521@esperanza>
 <20151215193858.GA15265@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151215193858.GA15265@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Dec 15, 2015 at 02:38:58PM -0500, Johannes Weiner wrote:
> On Mon, Dec 14, 2015 at 08:14:55PM +0300, Vladimir Davydov wrote:
> > On Fri, Dec 11, 2015 at 02:54:13PM -0500, Johannes Weiner wrote:
> > ...
> > > -static int
> > > -mem_cgroup_css_online(struct cgroup_subsys_state *css)
> > > +static struct cgroup_subsys_state * __ref
> > > +mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
> > >  {
> > > -	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> > > -	struct mem_cgroup *parent = mem_cgroup_from_css(css->parent);
> > > -	int ret;
> > > -
> > > -	if (css->id > MEM_CGROUP_ID_MAX)
> > > -		return -ENOSPC;
> > > +	struct mem_cgroup *parent = mem_cgroup_from_css(parent_css);
> > > +	struct mem_cgroup *memcg;
> > > +	long error = -ENOMEM;
> > >  
> > > -	if (!parent)
> > > -		return 0;
> > > +	memcg = mem_cgroup_alloc();
> > > +	if (!memcg)
> > > +		return ERR_PTR(error);
> > >  
> > >  	mutex_lock(&memcg_create_mutex);
> > 
> > It is pointless to take memcg_create_mutex in ->css_alloc. It won't
> > prevent setting use_hierarchy for parent after a new child was
> > allocated, but before it was added to the list of children (see
> > create_css()). Taking the mutex in ->css_online renders this race
> > impossible. That is, your cleanup breaks use_hierarchy consistency
> > check.
> > 
> > Can we drop this use_hierarchy consistency check at all and allow
> > children of a cgroup with use_hierarchy=1 have use_hierarchy=0? Yeah,
> > that might result in some strangeness if cgroups are created in parallel
> > with use_hierarchy flipped, but is it a valid use case? I surmise, one
> > just sets use_hierarchy for a cgroup once and for good before starting
> > to create sub-cgroups.
> 
> I don't think we have to support airtight exclusion between somebody
> changing the parent attribute and creating new children that inherit
> these attributes. Everything will still work if this race happens.
> 
> Does that mean we have to remove the restriction altogether? I'm not
> convinced. We can just keep it for historical purposes so that we do
> not *encourage* this weird setting.

Well, legacy hierarchy is scheduled to die, so it's too late to
encourage or discourage any setting regarding it.

Besides, hierarchy mode must be enabled for 99% setups, because this is
what systemd does at startup. So I don't think we would hurt anybody by
dropping this check altogether - IMO it'd be fairer than having a check
that might sometimes fail.

It's not something I really care about though, so I don't insist.

> 
> I think that's good enough. Let's just remove the memcg_create_mutex.

I'm fine with it, but I think this deserves a comment in the commit
message.

...
> So, how about the following fixlets on top to address your comments?
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index af8714a..124a802 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -250,13 +250,6 @@ enum res_type {
>  /* Used for OOM nofiier */
>  #define OOM_CONTROL		(0)
>  
> -/*
> - * The memcg_create_mutex will be held whenever a new cgroup is created.
> - * As a consequence, any change that needs to protect against new child cgroups
> - * appearing has to hold it as well.
> - */
> -static DEFINE_MUTEX(memcg_create_mutex);
> -
>  /* Some nice accessors for the vmpressure. */
>  struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg)
>  {
> @@ -2660,14 +2653,6 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  {
>  	bool ret;
>  
> -	/*
> -	 * The lock does not prevent addition or deletion of children, but
> -	 * it prevents a new child from being initialized based on this
> -	 * parent in css_online(), so it's enough to decide whether
> -	 * hierarchically inherited attributes can still be changed or not.
> -	 */
> -	lockdep_assert_held(&memcg_create_mutex);
> -
>  	rcu_read_lock();
>  	ret = css_next_child(NULL, &memcg->css);
>  	rcu_read_unlock();
> @@ -2730,10 +2715,8 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
>  	struct mem_cgroup *parent_memcg = mem_cgroup_from_css(memcg->css.parent);
>  
> -	mutex_lock(&memcg_create_mutex);
> -
>  	if (memcg->use_hierarchy == val)
> -		goto out;
> +		return 0;
>  
>  	/*
>  	 * If parent's use_hierarchy is set, we can't make any modifications
> @@ -2752,9 +2735,6 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
>  	} else
>  		retval = -EINVAL;
>  
> -out:
> -	mutex_unlock(&memcg_create_mutex);
> -
>  	return retval;
>  }
>  
> @@ -2929,6 +2909,10 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
>  
>  static void memcg_free_kmem(struct mem_cgroup *memcg)
>  {
> +	/* css_alloc() failed, offlining didn't happen */
> +	if (unlikely(memcg->kmem_state == KMEM_ONLINE))

It's not a hot-path, so there's no need in using 'unlikely' here apart
from improving readability, but the comment should be enough.

> +		memcg_offline_kmem(memcg);
> +

Calling 'offline' from css_free looks a little bit awkward, but let it
be.

Anyway, it's a really nice cleanup, thanks!

Acked-by: Vladimir Davydov <vdavydov@virtuozzo.com>

>  	if (memcg->kmem_state == KMEM_ALLOCATED) {
>  		memcg_destroy_kmem_caches(memcg);
>  		static_branch_dec(&memcg_kmem_enabled_key);
> @@ -2956,11 +2940,9 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
>  	mutex_lock(&memcg_limit_mutex);
>  	/* Top-level cgroup doesn't propagate from root */
>  	if (!memcg_kmem_online(memcg)) {
> -		mutex_lock(&memcg_create_mutex);
>  		if (cgroup_is_populated(memcg->css.cgroup) ||
>  		    (memcg->use_hierarchy && memcg_has_children(memcg)))
>  			ret = -EBUSY;
> -		mutex_unlock(&memcg_create_mutex);
>  		if (ret)
>  			goto out;
>  		ret = memcg_online_kmem(memcg);
> @@ -4184,14 +4166,14 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  	if (!memcg)
>  		return ERR_PTR(error);
>  
> -	mutex_lock(&memcg_create_mutex);
>  	memcg->high = PAGE_COUNTER_MAX;
>  	memcg->soft_limit = PAGE_COUNTER_MAX;
> -	if (parent)
> +	if (parent) {
>  		memcg->swappiness = mem_cgroup_swappiness(parent);
> +		memcg->oom_kill_disable = parent->oom_kill_disable;
> +	}
>  	if (parent && parent->use_hierarchy) {
>  		memcg->use_hierarchy = true;
> -		memcg->oom_kill_disable = parent->oom_kill_disable;
>  		page_counter_init(&memcg->memory, &parent->memory);
>  		page_counter_init(&memcg->memsw, &parent->memsw);
>  		page_counter_init(&memcg->kmem, &parent->kmem);
> @@ -4209,7 +4191,6 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  		if (parent != root_mem_cgroup)
>  			memory_cgrp_subsys.broken_hierarchy = true;
>  	}
> -	mutex_unlock(&memcg_create_mutex);
>  
>  	/* The following stuff does not apply to the root */
>  	if (!parent) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
