Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 0B1C76B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:59:36 -0400 (EDT)
Date: Wed, 27 Mar 2013 10:58:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130327145727.GD29052@cmpxchg.org>
References: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364373399-17397-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Mar 27, 2013 at 09:36:39AM +0100, Michal Hocko wrote:
> As cgroup supports rename, it's unsafe to dereference dentry->d_name
> without proper vfs locks. Fix this by using cgroup_name() rather than
> dentry directly.
> 
> Also open code memcg_cache_name because it is called only from
> kmem_cache_dup which frees the returned name right after
> kmem_cache_create_memcg makes a copy of it. Such a short-lived
> allocation doesn't make too much sense. So replace it by a static
> buffer as kmem_cache_dup is called with memcg_cache_mutex.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Glauber Costa <glommer@parallels.com>
> ---
>  mm/memcontrol.c |   64 ++++++++++++++++++++++++++++---------------------------
>  1 file changed, 33 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f608546..b30547b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3364,52 +3364,54 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>  	schedule_work(&cachep->memcg_params->destroy);
>  }
>  
> -static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
> -{
> -	char *name;
> -	struct dentry *dentry;
> -
> -	rcu_read_lock();
> -	dentry = rcu_dereference(memcg->css.cgroup->dentry);
> -	rcu_read_unlock();
> -
> -	BUG_ON(dentry == NULL);
> -
> -	name = kasprintf(GFP_KERNEL, "%s(%d:%s)", s->name,
> -			 memcg_cache_id(memcg), dentry->d_name.name);
> -
> -	return name;
> -}
> +/*
> + * This lock protects updaters, not readers. We want readers to be as fast as
> + * they can, and they will either see NULL or a valid cache value. Our model
> + * allow them to see NULL, in which case the root memcg will be selected.
> + *
> + * We need this lock because multiple allocations to the same cache from a non
> + * will span more than one worker. Only one of them can create the cache.
> + */
> +static DEFINE_MUTEX(memcg_cache_mutex);
>  
> +/*
> + * Called with memcg_cache_mutex held
> + */
>  static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
>  					 struct kmem_cache *s)
>  {
> -	char *name;
>  	struct kmem_cache *new;
> +	static char *tmp_name = NULL;
>  
> -	name = memcg_cache_name(memcg, s);
> -	if (!name)
> -		return NULL;
> +	lockdep_assert_held(&memcg_cache_mutex);
> +
> +	/*
> +	 * kmem_cache_create_memcg duplicates the given name and
> +	 * cgroup_name for this name requires RCU context.
> +	 * This static temporary buffer is used to prevent from
> +	 * pointless shortliving allocation.
> +	 */
> +	if (!tmp_name) {
> +		tmp_name = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +		WARN_ON_ONCE(!tmp_name);

Just use the page allocator directly and get a free allocation failure
warning.  Then again, order-0 pages are considered cheap enough that
they never even fail in our current implementation.

Which brings me to my other point: why not just a simple single-page
allocation?  This just seems a little overelaborate.  I think this
path would be taken predominantly after cgroup creation and fork where
we do a bunch of allocations anyway.  And it happens asynchroneously
from userspace, so it's not even really performance critical.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
