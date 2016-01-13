Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D333D828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 11:48:19 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id f206so303727964wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:48:19 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id mo12si3123391wjc.138.2016.01.13.08.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 08:48:18 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id b14so37931347wmb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:48:18 -0800 (PST)
Date: Wed, 13 Jan 2016 17:48:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 4/7] swap.h: move memcg related stuff to the end of
 the file
Message-ID: <20160113164817.GH17512@dhcp22.suse.cz>
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
 <77dd7375cd8360829093b4c347db2e557334da21.1450352792.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <77dd7375cd8360829093b4c347db2e557334da21.1450352792.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 17-12-15 15:29:57, Vladimir Davydov wrote:
> The following patches will add more functions to the memcg section of
> include/linux/swap.h. Some of them will need values defined below the
> current location of the section. So let's move the section to the end of
> the file. No functional changes intended.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/swap.h | 70 ++++++++++++++++++++++++++++------------------------
>  1 file changed, 38 insertions(+), 32 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 478e7dd038c7..f8fb4e06c4bd 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -350,39 +350,7 @@ extern void check_move_unevictable_pages(struct page **, int nr_pages);
>  
>  extern int kswapd_run(int nid);
>  extern void kswapd_stop(int nid);
> -#ifdef CONFIG_MEMCG
> -static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> -{
> -	/* root ? */
> -	if (mem_cgroup_disabled() || !memcg->css.parent)
> -		return vm_swappiness;
> -
> -	return memcg->swappiness;
> -}
>  
> -#else
> -static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
> -{
> -	return vm_swappiness;
> -}
> -#endif
> -#ifdef CONFIG_MEMCG_SWAP
> -extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
> -extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
> -extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
> -#else
> -static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> -{
> -}
> -static inline int mem_cgroup_try_charge_swap(struct page *page,
> -					     swp_entry_t entry)
> -{
> -	return 0;
> -}
> -static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
> -{
> -}
> -#endif
>  #ifdef CONFIG_SWAP
>  /* linux/mm/page_io.c */
>  extern int swap_readpage(struct page *);
> @@ -561,5 +529,43 @@ static inline swp_entry_t get_swap_page(void)
>  }
>  
>  #endif /* CONFIG_SWAP */
> +
> +#ifdef CONFIG_MEMCG
> +static inline int mem_cgroup_swappiness(struct mem_cgroup *memcg)
> +{
> +	/* root ? */
> +	if (mem_cgroup_disabled() || !memcg->css.parent)
> +		return vm_swappiness;
> +
> +	return memcg->swappiness;
> +}
> +
> +#else
> +static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
> +{
> +	return vm_swappiness;
> +}
> +#endif
> +
> +#ifdef CONFIG_MEMCG_SWAP
> +extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
> +extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
> +extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
> +#else
> +static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
> +{
> +}
> +
> +static inline int mem_cgroup_try_charge_swap(struct page *page,
> +					     swp_entry_t entry)
> +{
> +	return 0;
> +}
> +
> +static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
> +{
> +}
> +#endif
> +
>  #endif /* __KERNEL__*/
>  #endif /* _LINUX_SWAP_H */
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
