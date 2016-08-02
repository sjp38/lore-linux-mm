Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D320E6B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:24:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so102443389wme.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:24:02 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id l66si2916279wml.74.2016.08.02.05.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 05:24:01 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id o80so30434610wme.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:24:01 -0700 (PDT)
Date: Tue, 2 Aug 2016 14:23:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160802122359.GH12403@dhcp22.suse.cz>
References: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 01-08-16 16:26:24, Vladimir Davydov wrote:
> An offline memory cgroup might have anonymous memory or shmem left
> charged to it and no swap. Since only swap entries pin the id of an
> offline cgroup, such a cgroup will have no id and so an attempt to
> swapout its anon/shmem will not store memory cgroup info in the swap
> cgroup map. As a result, memcg->swap or memcg->memsw will never get
> uncharged from it and any of its ascendants.

Ahh, OK, very good point! Multiple ref. counts are always very
confusing. I guess it would be good to mention the impact which would
be pre-mature memcg oom or excessive reclaim in deeper hierarchies with
the memsw limit or the swap limit enforced in a upper hierarchy AFAIU.
v2 swap limit would be little bit more subtle because it would prevent
swapout too early.

> Fix this by always charging swapout to the first ancestor cgroup that
> hasn't released its id yet.

This is a bit ugly but I guess the easiest way to fix this.

> Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")

The original commit was marked for stable so this should go to stable as
well. I already have the above backported for 4.4 so weill queue this
one up as well when submitting.

> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 27 +++++++++++++++++++++------
>  1 file changed, 21 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b5804e4e6324..5fe285f27ea7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4035,6 +4035,13 @@ static void mem_cgroup_id_get(struct mem_cgroup *memcg)
>  	atomic_inc(&memcg->id.ref);
>  }
>  
> +static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> +{
> +	while (!atomic_inc_not_zero(&memcg->id.ref))
> +		memcg = parent_mem_cgroup(memcg);
> +	return memcg;
> +}
> +
>  static void mem_cgroup_id_put(struct mem_cgroup *memcg)
>  {
>  	if (atomic_dec_and_test(&memcg->id.ref)) {
> @@ -5751,7 +5758,7 @@ subsys_initcall(mem_cgroup_init);
>   */
>  void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  {
> -	struct mem_cgroup *memcg;
> +	struct mem_cgroup *memcg, *swap_memcg;
>  	unsigned short oldid;
>  
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
> @@ -5766,15 +5773,20 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	if (!memcg)
>  		return;
>  
> -	mem_cgroup_id_get(memcg);
> -	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
> +	swap_memcg = mem_cgroup_id_get_active(memcg);
> +	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
>  	VM_BUG_ON_PAGE(oldid, page);
> -	mem_cgroup_swap_statistics(memcg, true);
> +	mem_cgroup_swap_statistics(swap_memcg, true);
>  
>  	page->mem_cgroup = NULL;
>  
>  	if (!mem_cgroup_is_root(memcg))
>  		page_counter_uncharge(&memcg->memory, 1);
> +	if (memcg != swap_memcg) {
> +		if (!mem_cgroup_is_root(swap_memcg))
> +			page_counter_charge(&swap_memcg->memsw, 1);
> +		page_counter_uncharge(&memcg->memsw, 1);
> +	}
>  
>  	/*
>  	 * Interrupts should be disabled here because the caller holds the
> @@ -5814,11 +5826,14 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
>  	if (!memcg)
>  		return 0;
>  
> +	memcg = mem_cgroup_id_get_active(memcg);
> +
>  	if (!mem_cgroup_is_root(memcg) &&
> -	    !page_counter_try_charge(&memcg->swap, 1, &counter))
> +	    !page_counter_try_charge(&memcg->swap, 1, &counter)) {
> +		mem_cgroup_id_put(memcg);
>  		return -ENOMEM;
> +	}
>  
> -	mem_cgroup_id_get(memcg);
>  	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
>  	VM_BUG_ON_PAGE(oldid, page);
>  	mem_cgroup_swap_statistics(memcg, true);
> -- 
> 2.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
