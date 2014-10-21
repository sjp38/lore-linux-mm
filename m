Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 56B1D82BDD
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 08:53:04 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id rd3so640167pab.41
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 05:53:04 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bd15si11091080pdb.71.2014.10.21.05.53.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 05:53:03 -0700 (PDT)
Date: Tue, 21 Oct 2014 16:52:52 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 1/4] mm: memcontrol: uncharge pages on swapout
Message-ID: <20141021125252.GN16496@esperanza>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
 <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 20, 2014 at 11:22:09AM -0400, Johannes Weiner wrote:
> mem_cgroup_swapout() is called with exclusive access to the page at
> the end of the page's lifetime.  Instead of clearing the PCG_MEMSW
> flag and deferring the uncharge, just do it right away.  This allows
> follow-up patches to simplify the uncharge code.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bea3fddb3372..7709f17347f3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5799,6 +5799,7 @@ static void __init enable_swap_cgroup(void)
>   */
>  void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  {
> +	struct mem_cgroup *memcg;
>  	struct page_cgroup *pc;
>  	unsigned short oldid;
>  
> @@ -5815,13 +5816,21 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  		return;
>  
>  	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), page);
> +	memcg = pc->mem_cgroup;
>  
> -	oldid = swap_cgroup_record(entry, mem_cgroup_id(pc->mem_cgroup));
> +	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
>  	VM_BUG_ON_PAGE(oldid, page);
> +	mem_cgroup_swap_statistics(memcg, true);
>  
> -	pc->flags &= ~PCG_MEMSW;
> -	css_get(&pc->mem_cgroup->css);
> -	mem_cgroup_swap_statistics(pc->mem_cgroup, true);
> +	pc->flags = 0;
> +
> +	if (!mem_cgroup_is_root(memcg))
> +		page_counter_uncharge(&memcg->memory, 1);

AFAIU it removes batched uncharge of swapped out pages, doesn't it? Will
it affect performance?

Besides, it looks asymmetric with respect to the page cache uncharge
path, where we still defer uncharge to mem_cgroup_uncharge_list(), and I
personally rather dislike this asymmetry.

> +
> +	local_irq_disable();
> +	mem_cgroup_charge_statistics(memcg, page, -1);
> +	memcg_check_events(memcg, page);
> +	local_irq_enable();

AFAICT mem_cgroup_swapout() is called under mapping->tree_lock with irqs
disabled, so we should use irq_save/restore here.

Thanks,
Vladimir

>  }
>  
>  /**
> -- 
> 2.1.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
