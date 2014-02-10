Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1601A6B0037
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:19:58 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id m15so4157169wgh.26
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:19:58 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id ez15si6871800wid.17.2014.02.10.06.19.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 06:19:57 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id l18so2584378wgh.5
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:19:57 -0800 (PST)
Date: Mon, 10 Feb 2014 15:19:54 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/8] mm: memcg: remove mem_cgroup_move_account_page_stat()
Message-ID: <20140210141954.GH7117@dhcp22.suse.cz>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
 <1391792665-21678-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391792665-21678-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 07-02-14 12:04:19, Johannes Weiner wrote:
> It used to disable preemption and run sanity checks but now it's only
> taking a number out of one percpu counter and putting it into another.
> Do this directly in the callsite and save the indirection.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

OK, why not.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 28 ++++++++++++----------------
>  1 file changed, 12 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index befb3dd9d46c..639cf58b2643 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3776,16 +3776,6 @@ void mem_cgroup_split_huge_fixup(struct page *head)
>  }
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
> -static void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
> -					      struct mem_cgroup *to,
> -					      unsigned int nr_pages,
> -					      enum mem_cgroup_stat_index idx)
> -{
> -	/* Update stat data for mem_cgroup */
> -	__this_cpu_sub(from->stat->count[idx], nr_pages);
> -	__this_cpu_add(to->stat->count[idx], nr_pages);
> -}
> -
>  /**
>   * mem_cgroup_move_account - move account of the page
>   * @page: the page
> @@ -3831,13 +3821,19 @@ static int mem_cgroup_move_account(struct page *page,
>  
>  	move_lock_mem_cgroup(from, &flags);
>  
> -	if (!anon && page_mapped(page))
> -		mem_cgroup_move_account_page_stat(from, to, nr_pages,
> -			MEM_CGROUP_STAT_FILE_MAPPED);
> +	if (!anon && page_mapped(page)) {
> +		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
> +			       nr_pages);
> +		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
> +			       nr_pages);
> +	}
>  
> -	if (PageWriteback(page))
> -		mem_cgroup_move_account_page_stat(from, to, nr_pages,
> -			MEM_CGROUP_STAT_WRITEBACK);
> +	if (PageWriteback(page)) {
> +		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
> +			       nr_pages);
> +		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_WRITEBACK],
> +			       nr_pages);
> +	}
>  
>  	mem_cgroup_charge_statistics(from, page, anon, -nr_pages);
>  
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
