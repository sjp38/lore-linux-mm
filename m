Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32E876B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 12:00:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so106829266wme.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 09:00:29 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id g5si3367935wjc.214.2016.08.02.09.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 09:00:28 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id q128so31711461wma.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 09:00:27 -0700 (PDT)
Date: Tue, 2 Aug 2016 18:00:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160802160025.GB28900@dhcp22.suse.cz>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 02-08-16 18:00:48, Vladimir Davydov wrote:
> An offline memory cgroup might have anonymous memory or shmem left
> charged to it and no swap. Since only swap entries pin the id of an
> offline cgroup, such a cgroup will have no id and so an attempt to
> swapout its anon/shmem will not store memory cgroup info in the swap
> cgroup map. As a result, memcg->swap or memcg->memsw will never get
> uncharged from it and any of its ascendants.
> 
> Fix this by always charging swapout to the first ancestor cgroup that
> hasn't released its id yet.
> 
> Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: <stable@vger.kernel.org>	[3.19+]
> ---
> Changes in v2:
>  - handle !use_hierarchy case properly (Michal)
> 
>  mm/memcontrol.c | 38 ++++++++++++++++++++++++++++++++------
>  1 file changed, 32 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3be791afd372..4ae12effe347 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4036,6 +4036,24 @@ static void mem_cgroup_id_get(struct mem_cgroup *memcg)
>  	atomic_inc(&memcg->id.ref);
>  }
>  
> +static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> +{
> +	while (!atomic_inc_not_zero(&memcg->id.ref)) {
> +		/*
> +		 * The root cgroup cannot be destroyed, so it's refcount must
> +		 * always be >= 1.
> +		 */
> +		if (memcg == root_mem_cgroup) {
> +			VM_BUG_ON(1);
> +			break;
> +		}

why not simply VM_BUG_ON(memcg == root_mem_cgroup)?

> +		memcg = parent_mem_cgroup(memcg);
> +		if (!memcg)
> +			memcg = root_mem_cgroup;
> +	}
> +	return memcg;
> +}
> +
>  static void mem_cgroup_id_put(struct mem_cgroup *memcg)
>  {
>  	if (atomic_dec_and_test(&memcg->id.ref)) {
> @@ -5752,7 +5770,7 @@ subsys_initcall(mem_cgroup_init);
>   */
>  void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  {
> -	struct mem_cgroup *memcg;
> +	struct mem_cgroup *memcg, *swap_memcg;
>  	unsigned short oldid;
>  
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
> @@ -5767,15 +5785,20 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
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

The resulting code is a weird mixture of memcg and swap_memcg usage
which is really confusing and error prone. Do we really have to do
uncharge on an already offline memcg?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
