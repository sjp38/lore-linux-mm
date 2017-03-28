Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 15B636B0397
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 10:52:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b140so100363wme.3
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 07:52:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z25si4963994wrz.25.2017.03.28.07.52.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Mar 2017 07:52:47 -0700 (PDT)
Date: Tue, 28 Mar 2017 16:52:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: rmap: fix huge file mmap accounting in the memcg
 stats
Message-ID: <20170328145245.GL18241@dhcp22.suse.cz>
References: <20170322005111.3156-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170322005111.3156-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 21-03-17 20:51:11, Johannes Weiner wrote:
> Huge pages are accounted as single units in the memcg's "file_mapped"
> counter. Account the correct number of base pages, like we do in the
> corresponding node counter.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

with the CC: stable 
Acked-by: Michal Hocko <mhocko@suse.com>

thanks!
> ---
>  include/linux/memcontrol.h | 6 ++++++
>  mm/rmap.c                  | 4 ++--
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index baa274150210..c5ebb32fef49 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -741,6 +741,12 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
>  	return false;
>  }
>  
> +static inline void mem_cgroup_update_page_stat(struct page *page,
> +					       enum mem_cgroup_stat_index idx,
> +					       int nr)
> +{
> +}
> +
>  static inline void mem_cgroup_inc_page_stat(struct page *page,
>  					    enum mem_cgroup_stat_index idx)
>  {
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 1d82057144ba..f514cdd84482 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1154,7 +1154,7 @@ void page_add_file_rmap(struct page *page, bool compound)
>  			goto out;
>  	}
>  	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, nr);
> -	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
> +	mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, nr);
>  out:
>  	unlock_page_memcg(page);
>  }
> @@ -1194,7 +1194,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
>  	 * pte lock(a spinlock) is held, which implies preemption disabled.
>  	 */
>  	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, -nr);
> -	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
> +	mem_cgroup_update_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, -nr);
>  
>  	if (unlikely(PageMlocked(page)))
>  		clear_page_mlock(page);
> -- 
> 2.12.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
