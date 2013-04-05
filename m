Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 6C5016B00F8
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 09:45:59 -0400 (EDT)
Date: Fri, 5 Apr 2013 15:45:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 2/7] memcg: don't use mem_cgroup_get() when creating
 a kmemcg cache
Message-ID: <20130405134557.GG31132@dhcp22.suse.cz>
References: <515BF233.6070308@huawei.com>
 <515BF275.5080408@huawei.com>
 <20130403153133.GM16471@dhcp22.suse.cz>
 <515EA73C.8050602@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515EA73C.8050602@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 05-04-13 14:28:12, Glauber Costa wrote:
> On 04/03/2013 07:31 PM, Michal Hocko wrote:
> > On Wed 03-04-13 17:12:21, Li Zefan wrote:
> >> Use css_get()/css_put() instead of mem_cgroup_get()/mem_cgroup_put().
> >>
> >> Signed-off-by: Li Zefan <lizefan@huawei.com>
> >> ---
> >>  mm/memcontrol.c | 10 +++++-----
> >>  1 file changed, 5 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 43ca91d..dafacb8 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -3191,7 +3191,7 @@ void memcg_release_cache(struct kmem_cache *s)
> >>  	list_del(&s->memcg_params->list);
> >>  	mutex_unlock(&memcg->slab_caches_mutex);
> >>  
> >> -	mem_cgroup_put(memcg);
> >> +	css_put(&memcg->css);
> >>  out:
> >>  	kfree(s->memcg_params);
> >>  }
> >> @@ -3350,16 +3350,18 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> >>  
> >>  	mutex_lock(&memcg_cache_mutex);
> >>  	new_cachep = cachep->memcg_params->memcg_caches[idx];
> >> -	if (new_cachep)
> >> +	if (new_cachep) {
> >> +		css_put(&memcg->css);
> >>  		goto out;
> >> +	}
> >>  
> >>  	new_cachep = kmem_cache_dup(memcg, cachep);
> >>  	if (new_cachep == NULL) {
> >>  		new_cachep = cachep;
> >> +		css_put(&memcg->css);
> >>  		goto out;
> >>  	}
> >>  
> >> -	mem_cgroup_get(memcg);
> >>  	atomic_set(&new_cachep->memcg_params->nr_pages , 0);
> >>  
> >>  	cachep->memcg_params->memcg_caches[idx] = new_cachep;
> >> @@ -3449,8 +3451,6 @@ static void memcg_create_cache_work_func(struct work_struct *w)
> >>  
> >>  	cw = container_of(w, struct create_work, work);
> >>  	memcg_create_kmem_cache(cw->memcg, cw->cachep);
> >> -	/* Drop the reference gotten when we enqueued. */
> >> -	css_put(&cw->memcg->css);
> >>  	kfree(cw);
> >>  }
> > 
> > You are putting references but I do not see any single css_{try}get
> > here. /me puzzled.
> > 
> 
> There are two things being done in this code:
> First, we acquired a css_ref to make sure that the underlying cgroup
> would not go away. That is a short lived reference, and it is put as
> soon as the cache is created.
> At this point, we acquire a long-lived per-cache memcg reference count
> to guarantee that the memcg will still be alive.
> 
> so it is:
> 
> enqueue: css_get
> create : memcg_get, css_put
> destroy: css_put
> 
> If I understand Li's patch correctly, he is not touching the first
> css_get, only turning that into the long lived reference (which was not
> possible before, since that would prevent rmdir).
> 
> Then he only needs to get rid of the memcg_get, change the memcg_put to
> css_put, and get rid of the now extra css_put.
> 
> He is issuing extra css_puts in memcg_create_kmem_cache, but only in
> failure paths. So the code reads as:
> * css_get on enqueue (already done, so not shown in patch)
> * if it fails, css_put
> * if it succeeds, don't do anything. This is already the long-lived
> reference count. put it at release time.

OK, this makes more sense now. It is __memcg_create_cache_enqueue which
takes the reference and it is not put after this because it replaced
mem_cgroup reference counting.
Li, please put something along these lines into the changelog. This is
really tricky and easy to get misunderstand.

You can put my Acked-by then.

> The code looks correct, and of course, extremely simpler due to the
> use of a single reference.
> 
> Li, am I right in my understanding that this is your intention?
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
