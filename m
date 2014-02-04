Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 137A36B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 10:13:29 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id n12so4490468wgh.0
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 07:13:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu5si12248498wjc.50.2014.02.04.07.13.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 07:13:28 -0800 (PST)
Date: Tue, 4 Feb 2014 16:13:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/8] memcg, slab: remove cgroup name from memcg cache
 names
Message-ID: <20140204151326.GJ4890@dhcp22.suse.cz>
References: <cover.1391356789.git.vdavydov@parallels.com>
 <90b34882d51b18a9dd557d24f6a377df1ba13945.1391356789.git.vdavydov@parallels.com>
 <20140204144526.GG4890@dhcp22.suse.cz>
 <52F1031C.7070506@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F1031C.7070506@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On Tue 04-02-14 19:11:24, Vladimir Davydov wrote:
> On 02/04/2014 06:45 PM, Michal Hocko wrote:
> > On Sun 02-02-14 20:33:47, Vladimir Davydov wrote:
> >> The cgroup name is not informative at all in case the cgroup hierarchy
> >> is not flat. Besides, we can always find the memcg a particular cache
> >> belongs to by its kmemcg id, which is now exported via "memory.kmem.id"
> >> cgroup fs file for each memcg.
> >>
> >> So let's remove the cgroup name part from kmem caches names - it will
> >> greatly simplify the call paths and make the code look clearer.
> >>
> >> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> > I guess this one doesn't make much sense withou 1/8, right?
> 
> Actually, the rest of the patchset does not depend on the logic of the
> first two - they only have a couple of hunks overlapped. However, there
> is v2 already.

OK, I am already switched to v2 (you are too fast...). I've just noticed
that this version has generated quite some discussion so I felt I should
react here first.

> 
> Thanks.
> 
> >
> >> ---
> >>  mm/memcontrol.c  |   63 +++++++++++++-----------------------------------------
> >>  mm/slab_common.c |    6 +++++-
> >>  2 files changed, 20 insertions(+), 49 deletions(-)
> >>
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 91d242707404..3351c5b5486d 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -3405,44 +3405,6 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
> >>  	schedule_work(&cachep->memcg_params->destroy);
> >>  }
> >>  
> >> -static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> >> -						  struct kmem_cache *s)
> >> -{
> >> -	struct kmem_cache *new = NULL;
> >> -	static char *tmp_name = NULL;
> >> -	static DEFINE_MUTEX(mutex);	/* protects tmp_name */
> >> -
> >> -	BUG_ON(!memcg_can_account_kmem(memcg));
> >> -
> >> -	mutex_lock(&mutex);
> >> -	/*
> >> -	 * kmem_cache_create_memcg duplicates the given name and
> >> -	 * cgroup_name for this name requires RCU context.
> >> -	 * This static temporary buffer is used to prevent from
> >> -	 * pointless shortliving allocation.
> >> -	 */
> >> -	if (!tmp_name) {
> >> -		tmp_name = kmalloc(PATH_MAX, GFP_KERNEL);
> >> -		if (!tmp_name)
> >> -			goto out;
> >> -	}
> >> -
> >> -	rcu_read_lock();
> >> -	snprintf(tmp_name, PATH_MAX, "%s(%d:%s)", s->name,
> >> -			 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
> >> -	rcu_read_unlock();
> >> -
> >> -	new = kmem_cache_create_memcg(memcg, tmp_name, s->object_size, s->align,
> >> -				      (s->flags & ~SLAB_PANIC), s->ctor, s);
> >> -	if (new)
> >> -		new->allocflags |= __GFP_KMEMCG;
> >> -	else
> >> -		new = s;
> >> -out:
> >> -	mutex_unlock(&mutex);
> >> -	return new;
> >> -}
> >> -
> >>  void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
> >>  {
> >>  	struct kmem_cache *c;
> >> @@ -3489,12 +3451,6 @@ void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
> >>  	mutex_unlock(&activate_kmem_mutex);
> >>  }
> >>  
> >> -struct create_work {
> >> -	struct mem_cgroup *memcg;
> >> -	struct kmem_cache *cachep;
> >> -	struct work_struct work;
> >> -};
> >> -
> >>  static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
> >>  {
> >>  	struct kmem_cache *cachep;
> >> @@ -3512,13 +3468,24 @@ static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
> >>  	mutex_unlock(&memcg->slab_caches_mutex);
> >>  }
> >>  
> >> +struct create_work {
> >> +	struct mem_cgroup *memcg;
> >> +	struct kmem_cache *cachep;
> >> +	struct work_struct work;
> >> +};
> >> +
> >>  static void memcg_create_cache_work_func(struct work_struct *w)
> >>  {
> >> -	struct create_work *cw;
> >> +	struct create_work *cw = container_of(w, struct create_work, work);
> >> +	struct mem_cgroup *memcg = cw->memcg;
> >> +	struct kmem_cache *s = cw->cachep;
> >> +	struct kmem_cache *new;
> >>  
> >> -	cw = container_of(w, struct create_work, work);
> >> -	memcg_create_kmem_cache(cw->memcg, cw->cachep);
> >> -	css_put(&cw->memcg->css);
> >> +	new = kmem_cache_create_memcg(memcg, s->name, s->object_size, s->align,
> >> +				      (s->flags & ~SLAB_PANIC), s->ctor, s);
> >> +	if (new)
> >> +		new->allocflags |= __GFP_KMEMCG;
> >> +	css_put(&memcg->css);
> >>  	kfree(cw);
> >>  }
> >>  
> >> diff --git a/mm/slab_common.c b/mm/slab_common.c
> >> index 1ec3c619ba04..152d9b118b7a 100644
> >> --- a/mm/slab_common.c
> >> +++ b/mm/slab_common.c
> >> @@ -213,7 +213,11 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
> >>  	s->align = calculate_alignment(flags, align, size);
> >>  	s->ctor = ctor;
> >>  
> >> -	s->name = kstrdup(name, GFP_KERNEL);
> >> +	if (!memcg)
> >> +		s->name = kstrdup(name, GFP_KERNEL);
> >> +	else
> >> +		s->name = kasprintf(GFP_KERNEL, "%s:%d",
> >> +				    name, memcg_cache_id(memcg));
> >>  	if (!s->name)
> >>  		goto out_free_cache;
> >>  
> >> -- 
> >> 1.7.10.4
> >>
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
