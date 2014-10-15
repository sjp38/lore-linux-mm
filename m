Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id C54BF6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 11:21:31 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id s18so1292180lam.9
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 08:21:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si30813580lbc.136.2014.10.15.08.21.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 08:21:29 -0700 (PDT)
Date: Wed, 15 Oct 2014 17:21:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/5] mm: memcontrol: remove obsolete kmemcg pinning tricks
Message-ID: <20141015152128.GH23547@dhcp22.suse.cz>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
 <1413303637-23862-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413303637-23862-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 14-10-14 12:20:35, Johannes Weiner wrote:
> As charges now pin the css explicitely, there is no more need for
> kmemcg to acquire a proxy reference for outstanding pages during
> offlining, or maintain state to identify such "dead" groups.
> 
> This was the last user of the uncharge functions' return values, so
> remove them as well.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/page_counter.h |  4 +--
>  mm/memcontrol.c              | 74 +-------------------------------------------
>  mm/page_counter.c            | 23 +++-----------
>  3 files changed, 7 insertions(+), 94 deletions(-)
> 
> diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
> index d92d18949474..a878ef61d073 100644
> --- a/include/linux/page_counter.h
> +++ b/include/linux/page_counter.h
> @@ -32,12 +32,12 @@ static inline unsigned long page_counter_read(struct page_counter *counter)
>  	return atomic_long_read(&counter->count);
>  }
>  
> -int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
> +void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
>  void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
>  int page_counter_try_charge(struct page_counter *counter,
>  			    unsigned long nr_pages,
>  			    struct page_counter **fail);
> -int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
> +void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
>  int page_counter_limit(struct page_counter *counter, unsigned long limit);
>  int page_counter_memparse(const char *buf, unsigned long *nr_pages);
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a3feead6be15..7551e12f8ff7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -369,7 +369,6 @@ struct mem_cgroup {
>  /* internal only representation about the status of kmem accounting. */
>  enum {
>  	KMEM_ACCOUNTED_ACTIVE, /* accounted by this cgroup itself */
> -	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
>  };
>  
>  #ifdef CONFIG_MEMCG_KMEM
> @@ -383,22 +382,6 @@ static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>  	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>  }
>  
> -static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
> -{
> -	/*
> -	 * Our caller must use css_get() first, because memcg_uncharge_kmem()
> -	 * will call css_put() if it sees the memcg is dead.
> -	 */
> -	smp_wmb();
> -	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
> -		set_bit(KMEM_ACCOUNTED_DEAD, &memcg->kmem_account_flags);
> -}
> -
> -static bool memcg_kmem_test_and_clear_dead(struct mem_cgroup *memcg)
> -{
> -	return test_and_clear_bit(KMEM_ACCOUNTED_DEAD,
> -				  &memcg->kmem_account_flags);
> -}
>  #endif
>  
>  /* Stuffs for move charges at task migration. */
> @@ -2741,22 +2724,7 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
>  	if (do_swap_account)
>  		page_counter_uncharge(&memcg->memsw, nr_pages);
>  
> -	/* Not down to 0 */
> -	if (page_counter_uncharge(&memcg->kmem, nr_pages)) {
> -		css_put_many(&memcg->css, nr_pages);
> -		return;
> -	}
> -
> -	/*
> -	 * Releases a reference taken in kmem_cgroup_css_offline in case
> -	 * this last uncharge is racing with the offlining code or it is
> -	 * outliving the memcg existence.
> -	 *
> -	 * The memory barrier imposed by test&clear is paired with the
> -	 * explicit one in memcg_kmem_mark_dead().
> -	 */
> -	if (memcg_kmem_test_and_clear_dead(memcg))
> -		css_put(&memcg->css);
> +	page_counter_uncharge(&memcg->kmem, nr_pages);
>  
>  	css_put_many(&memcg->css, nr_pages);
>  }
> @@ -4740,40 +4708,6 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
>  {
>  	mem_cgroup_sockets_destroy(memcg);
>  }
> -
> -static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
> -{
> -	if (!memcg_kmem_is_active(memcg))
> -		return;
> -
> -	/*
> -	 * kmem charges can outlive the cgroup. In the case of slab
> -	 * pages, for instance, a page contain objects from various
> -	 * processes. As we prevent from taking a reference for every
> -	 * such allocation we have to be careful when doing uncharge
> -	 * (see memcg_uncharge_kmem) and here during offlining.
> -	 *
> -	 * The idea is that that only the _last_ uncharge which sees
> -	 * the dead memcg will drop the last reference. An additional
> -	 * reference is taken here before the group is marked dead
> -	 * which is then paired with css_put during uncharge resp. here.
> -	 *
> -	 * Although this might sound strange as this path is called from
> -	 * css_offline() when the referencemight have dropped down to 0 and
> -	 * shouldn't be incremented anymore (css_tryget_online() would
> -	 * fail) we do not have other options because of the kmem
> -	 * allocations lifetime.
> -	 */
> -	css_get(&memcg->css);
> -
> -	memcg_kmem_mark_dead(memcg);
> -
> -	if (page_counter_read(&memcg->kmem))
> -		return;
> -
> -	if (memcg_kmem_test_and_clear_dead(memcg))
> -		css_put(&memcg->css);
> -}
>  #else
>  static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  {
> @@ -4783,10 +4717,6 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  static void memcg_destroy_kmem(struct mem_cgroup *memcg)
>  {
>  }
> -
> -static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
> -{
> -}
>  #endif
>  
>  /*
> @@ -5390,8 +5320,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  	}
>  	spin_unlock(&memcg->event_list_lock);
>  
> -	kmem_cgroup_css_offline(memcg);
> -
>  	/*
>  	 * This requires that offlining is serialized.  Right now that is
>  	 * guaranteed because css_killed_work_fn() holds the cgroup_mutex.
> diff --git a/mm/page_counter.c b/mm/page_counter.c
> index fc4990c6bb5b..71a0e92e7051 100644
> --- a/mm/page_counter.c
> +++ b/mm/page_counter.c
> @@ -12,19 +12,14 @@
>   * page_counter_cancel - take pages out of the local counter
>   * @counter: counter
>   * @nr_pages: number of pages to cancel
> - *
> - * Returns whether there are remaining pages in the counter.
>   */
> -int page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
> +void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages)
>  {
>  	long new;
>  
>  	new = atomic_long_sub_return(nr_pages, &counter->count);
> -
>  	/* More uncharges than charges? */
>  	WARN_ON_ONCE(new < 0);
> -
> -	return new > 0;
>  }
>  
>  /**
> @@ -113,23 +108,13 @@ failed:
>   * page_counter_uncharge - hierarchically uncharge pages
>   * @counter: counter
>   * @nr_pages: number of pages to uncharge
> - *
> - * Returns whether there are remaining charges in @counter.
>   */
> -int page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages)
> +void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages)
>  {
>  	struct page_counter *c;
> -	int ret = 1;
>  
> -	for (c = counter; c; c = c->parent) {
> -		int remainder;
> -
> -		remainder = page_counter_cancel(c, nr_pages);
> -		if (c == counter && !remainder)
> -			ret = 0;
> -	}
> -
> -	return ret;
> +	for (c = counter; c; c = c->parent)
> +		page_counter_cancel(c, nr_pages);
>  }
>  
>  /**
> -- 
> 2.1.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
