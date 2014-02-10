Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id BB9B76B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:17:20 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id l18so2585622wgh.3
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:17:20 -0800 (PST)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id dk3si6861065wib.48.2014.02.10.06.17.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 06:17:18 -0800 (PST)
Received: by mail-we0-f172.google.com with SMTP id p61so4329427wes.3
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:17:16 -0800 (PST)
Date: Mon, 10 Feb 2014 15:17:13 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/8] mm: memcg: remove unnecessary preemption disabling
Message-ID: <20140210141713.GG7117@dhcp22.suse.cz>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
 <1391792665-21678-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391792665-21678-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 07-02-14 12:04:18, Johannes Weiner wrote:
> lock_page_cgroup() disables preemption, remove explicit preemption
> disabling for code paths holding this lock.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

It would be better to document the dependency on lock_page_cgroup. But
the patch looks correct.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 15 ++++-----------
>  1 file changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 53385cd4e6f0..befb3dd9d46c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -921,8 +921,6 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
>  					 struct page *page,
>  					 bool anon, int nr_pages)
>  {
> -	preempt_disable();
> -
>  	/*
>  	 * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
>  	 * counted as CACHE even if it's on ANON LRU.
> @@ -947,8 +945,6 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
>  	}
>  
>  	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
> -
> -	preempt_enable();
>  }
>  
>  unsigned long
> @@ -3780,17 +3776,14 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
> -static inline
> -void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
> -					struct mem_cgroup *to,
> -					unsigned int nr_pages,
> -					enum mem_cgroup_stat_index idx)
> +static void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
> +					      struct mem_cgroup *to,
> +					      unsigned int nr_pages,
> +					      enum mem_cgroup_stat_index idx)
>  {
>  	/* Update stat data for mem_cgroup */
> -	preempt_disable();
>  	__this_cpu_sub(from->stat->count[idx], nr_pages);
>  	__this_cpu_add(to->stat->count[idx], nr_pages);
> -	preempt_enable();
>  }
>  
>  /**
> -- 
> 1.8.5.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
