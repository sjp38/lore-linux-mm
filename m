Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id AF5846B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 09:21:50 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id u63so26020529wmu.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:21:50 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id x1si12084599wjy.37.2015.12.10.06.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 06:21:49 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id c201so35469551wme.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:21:49 -0800 (PST)
Date: Thu, 10 Dec 2015 15:21:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] mm: memcontrol: account "kmem" consumers in cgroup2
 memory controller
Message-ID: <20151210142147.GP19496@dhcp22.suse.cz>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-8-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449599665-18047-8-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 08-12-15 13:34:24, Johannes Weiner wrote:
> The original cgroup memory controller has an extension to account slab
> memory (and other "kernel memory" consumers) in a separate "kmem"
> counter, once the user set an explicit limit on that "kmem" pool.
> 
> However, this includes various consumers whose sizes are directly
> linked to userspace activity. Accounting them as an optional "kmem"
> extension is problematic for several reasons:
> 
> 1. It leaves the main memory interface with incomplete semantics. A
>    user who puts their workload into a cgroup and configures a memory
>    limit does not expect us to leave holes in the containment as big
>    as the dentry and inode cache, or the kernel stack pages.
> 
> 2. If the limit set on this random historical subgroup of consumers is
>    reached, subsequent allocations will fail even when the main memory
>    pool available to the cgroup is not yet exhausted and/or has
>    reclaimable memory in it.
> 
> 3. Calling it 'kernel memory' is misleading. The dentry and inode
>    caches are no more 'kernel' (or no less 'user') memory than the
>    page cache itself. Treating these consumers as different classes is
>    a historical implementation detail that should not leak to users.
> 
> So, in addition to page cache, anonymous memory, and network socket
> memory, account the following memory consumers per default in the
> cgroup2 memory controller:
> 
>      - threadinfo
>      - task_struct
>      - task_delay_info
>      - pid
>      - cred
>      - mm_struct
>      - vm_area_struct and vm_region (nommu)
>      - anon_vma and anon_vma_chain
>      - signal_struct
>      - sighand_struct
>      - fs_struct
>      - files_struct
>      - fdtable and fdtable->full_fds_bits
>      - dentry and external_name
>      - inode for all filesystems.
> 
> This should give us reasonable memory isolation for most common
> workloads out of the box.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ab72c47..d048137 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2356,13 +2356,14 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
>  	if (!memcg_kmem_online(memcg))
>  		return 0;
>  
> -	if (!page_counter_try_charge(&memcg->kmem, nr_pages, &counter))
> -		return -ENOMEM;
> -
>  	ret = try_charge(memcg, gfp, nr_pages);
> -	if (ret) {
> -		page_counter_uncharge(&memcg->kmem, nr_pages);
> +	if (ret)
>  		return ret;
> +
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) &&
> +	    !page_counter_try_charge(&memcg->kmem, nr_pages, &counter)) {
> +		cancel_charge(memcg, nr_pages);
> +		return -ENOMEM;
>  	}
>  
>  	page->mem_cgroup = memcg;
> @@ -2391,7 +2392,9 @@ void __memcg_kmem_uncharge(struct page *page, int order)
>  
>  	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
>  
> -	page_counter_uncharge(&memcg->kmem, nr_pages);
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +		page_counter_uncharge(&memcg->kmem, nr_pages);
> +
>  	page_counter_uncharge(&memcg->memory, nr_pages);
>  	if (do_memsw_account())
>  		page_counter_uncharge(&memcg->memsw, nr_pages);
> @@ -2895,7 +2898,8 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  	 * onlined after this point, because it has at least one child
>  	 * already.
>  	 */
> -	if (memcg_kmem_online(parent))
> +	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) ||
> +	    memcg_kmem_online(parent))
>  		ret = memcg_online_kmem(memcg);
>  	mutex_unlock(&memcg_limit_mutex);
>  	return ret;
> -- 
> 2.6.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
