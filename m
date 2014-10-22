Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 531226B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:34:58 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id gf13so3510846lab.29
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:34:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2si23728158laa.120.2014.10.22.08.34.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 08:34:56 -0700 (PDT)
Date: Wed, 22 Oct 2014 17:34:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/4] mm: memcontrol: uncharge pages on swapout
Message-ID: <20141022153455.GD30802@dhcp22.suse.cz>
References: <1413818532-11042-1-git-send-email-hannes@cmpxchg.org>
 <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413818532-11042-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 20-10-14 11:22:09, Johannes Weiner wrote:
> mem_cgroup_swapout() is called with exclusive access to the page at
> the end of the page's lifetime.  Instead of clearing the PCG_MEMSW
> flag and deferring the uncharge, just do it right away.  This allows
> follow-up patches to simplify the uncharge code.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

OK, it makes sense. With the irq fixup
Acked-by: Michal Hocko <mhocko@suse.cz>

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
> +
> +	local_irq_disable();
> +	mem_cgroup_charge_statistics(memcg, page, -1);
> +	memcg_check_events(memcg, page);
> +	local_irq_enable();
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
