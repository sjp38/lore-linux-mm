Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id AAAC56B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 14:53:10 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id d1so7216204wiv.12
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:53:10 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id p2si9531651wix.7.2014.10.20.11.53.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 11:53:09 -0700 (PDT)
Received: by mail-wi0-f175.google.com with SMTP id d1so8028873wiv.8
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 11:53:08 -0700 (PDT)
Date: Mon, 20 Oct 2014 20:53:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm] memcg: remove activate_kmem_mutex
Message-ID: <20141020185306.GB505@dhcp22.suse.cz>
References: <1413817889-13915-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413817889-13915-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 20-10-14 19:11:29, Vladimir Davydov wrote:
> The activate_kmem_mutex is used to serialize memcg.kmem.limit updates,
> but we already serialize them with memcg_limit_mutex so let's remove the
> former.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Is this the case since bd67314586a3 (memcg, slab: simplify
synchronization scheme)?

Anyway Looks good to me.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   24 +++++-------------------
>  1 file changed, 5 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3a203c7ec6c7..e957f0c80c6e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2618,8 +2618,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
>   */
>  static DEFINE_MUTEX(memcg_slab_mutex);
>  
> -static DEFINE_MUTEX(activate_kmem_mutex);
> -
>  /*
>   * This is a bit cumbersome, but it is rarely used and avoids a backpointer
>   * in the memcg_cache_params struct.
> @@ -3756,9 +3754,8 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
>  }
>  
>  #ifdef CONFIG_MEMCG_KMEM
> -/* should be called with activate_kmem_mutex held */
> -static int __memcg_activate_kmem(struct mem_cgroup *memcg,
> -				 unsigned long nr_pages)
> +static int memcg_activate_kmem(struct mem_cgroup *memcg,
> +			       unsigned long nr_pages)
>  {
>  	int err = 0;
>  	int memcg_id;
> @@ -3820,17 +3817,6 @@ out:
>  	return err;
>  }
>  
> -static int memcg_activate_kmem(struct mem_cgroup *memcg,
> -			       unsigned long nr_pages)
> -{
> -	int ret;
> -
> -	mutex_lock(&activate_kmem_mutex);
> -	ret = __memcg_activate_kmem(memcg, nr_pages);
> -	mutex_unlock(&activate_kmem_mutex);
> -	return ret;
> -}
> -
>  static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
>  				   unsigned long limit)
>  {
> @@ -3853,14 +3839,14 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>  	if (!parent)
>  		return 0;
>  
> -	mutex_lock(&activate_kmem_mutex);
> +	mutex_lock(&memcg_limit_mutex);
>  	/*
>  	 * If the parent cgroup is not kmem-active now, it cannot be activated
>  	 * after this point, because it has at least one child already.
>  	 */
>  	if (memcg_kmem_is_active(parent))
> -		ret = __memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
> -	mutex_unlock(&activate_kmem_mutex);
> +		ret = memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
> +	mutex_unlock(&memcg_limit_mutex);
>  	return ret;
>  }
>  #else
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
