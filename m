Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1A20E6B0255
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:40:22 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id u63so22109748wmu.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:40:22 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id v191si19288656wmd.52.2015.12.10.04.40.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 04:40:21 -0800 (PST)
Received: by wmww144 with SMTP id w144so22913146wmw.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:40:20 -0800 (PST)
Date: Thu, 10 Dec 2015 13:40:19 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/8] mm: memcontrol: remove double kmem page_counter init
Message-ID: <20151210124019.GH19496@dhcp22.suse.cz>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449599665-18047-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 08-12-15 13:34:19, Johannes Weiner wrote:
> The kmem page_counter's limit is initialized to PAGE_COUNTER_MAX
> inside mem_cgroup_css_online(). There is no need to repeat this
> from memcg_propagate_kmem().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 24 ++++++++++--------------
>  1 file changed, 10 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index eda8d43..02167db 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2840,8 +2840,7 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
>  }
>  
>  #ifdef CONFIG_MEMCG_KMEM
> -static int memcg_activate_kmem(struct mem_cgroup *memcg,
> -			       unsigned long nr_pages)
> +static int memcg_activate_kmem(struct mem_cgroup *memcg)
>  {
>  	int err = 0;
>  	int memcg_id;
> @@ -2876,13 +2875,6 @@ static int memcg_activate_kmem(struct mem_cgroup *memcg,
>  		goto out;
>  	}
>  
> -	/*
> -	 * We couldn't have accounted to this cgroup, because it hasn't got
> -	 * activated yet, so this should succeed.
> -	 */
> -	err = page_counter_limit(&memcg->kmem, nr_pages);
> -	VM_BUG_ON(err);
> -
>  	static_branch_inc(&memcg_kmem_enabled_key);
>  	/*
>  	 * A memory cgroup is considered kmem-active as soon as it gets
> @@ -2903,10 +2895,14 @@ static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
>  	int ret;
>  
>  	mutex_lock(&memcg_limit_mutex);
> -	if (!memcg_kmem_is_active(memcg))
> -		ret = memcg_activate_kmem(memcg, limit);
> -	else
> -		ret = page_counter_limit(&memcg->kmem, limit);
> +	/* Top-level cgroup doesn't propagate from root */
> +	if (!memcg_kmem_is_active(memcg)) {
> +		ret = memcg_activate_kmem(memcg);
> +		if (ret)
> +			goto out;
> +	}
> +	ret = page_counter_limit(&memcg->kmem, limit);
> +out:
>  	mutex_unlock(&memcg_limit_mutex);
>  	return ret;
>  }
> @@ -2925,7 +2921,7 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  	 * after this point, because it has at least one child already.
>  	 */
>  	if (memcg_kmem_is_active(parent))
> -		ret = memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
> +		ret = memcg_activate_kmem(memcg);
>  	mutex_unlock(&memcg_limit_mutex);
>  	return ret;
>  }
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
