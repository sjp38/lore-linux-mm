Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE3A1828E1
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:34:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so93579771lfg.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:34:51 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id h25si21175457wmi.28.2016.08.02.05.34.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 05:34:50 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so30490029wme.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:34:50 -0700 (PDT)
Date: Tue, 2 Aug 2016 14:34:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm: memcontrol: fix memcg id ref counter on swap
 charge move
Message-ID: <20160802123448.GI12403@dhcp22.suse.cz>
References: <01cbe4d1a9fd9bbd42c95e91694d8ed9c9fc2208.1470057819.git.vdavydov@virtuozzo.com>
 <3119b9b4526b18e6afcf55d3b4220437d642b00d.1470057819.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3119b9b4526b18e6afcf55d3b4220437d642b00d.1470057819.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 01-08-16 16:26:25, Vladimir Davydov wrote:
> Since commit 73f576c04b941 swap entries do not pin memcg->css.refcnt
> directly. Instead, they pin memcg->id.ref. So we should adjust the
> reference counters accordingly when moving swap charges between cgroups.
> 
> Fixes: 73f576c04b941 ("mm: memcontrol: fix cgroup creation failure after many small jobs")

Same as the previous patch. It should be marked for stable along with
73f576c04b941.

> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/memcontrol.c | 24 ++++++++++++++++++------
>  1 file changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5fe285f27ea7..58c229071fb1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4030,9 +4030,9 @@ static struct cftype mem_cgroup_legacy_files[] = {
>  
>  static DEFINE_IDR(mem_cgroup_idr);
>  
> -static void mem_cgroup_id_get(struct mem_cgroup *memcg)
> +static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
>  {
> -	atomic_inc(&memcg->id.ref);
> +	atomic_add(n, &memcg->id.ref);
>  }
>  
>  static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> @@ -4042,9 +4042,9 @@ static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
>  	return memcg;
>  }
>  
> -static void mem_cgroup_id_put(struct mem_cgroup *memcg)
> +static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
>  {
> -	if (atomic_dec_and_test(&memcg->id.ref)) {
> +	if (atomic_sub_and_test(n, &memcg->id.ref)) {
>  		idr_remove(&mem_cgroup_idr, memcg->id.id);
>  		memcg->id.id = 0;
>  
> @@ -4053,6 +4053,16 @@ static void mem_cgroup_id_put(struct mem_cgroup *memcg)
>  	}
>  }
>  
> +static inline void mem_cgroup_id_get(struct mem_cgroup *memcg)
> +{
> +	mem_cgroup_id_get_many(memcg, 1);
> +}
> +
> +static inline void mem_cgroup_id_put(struct mem_cgroup *memcg)
> +{
> +	mem_cgroup_id_put_many(memcg, 1);
> +}
> +
>  /**
>   * mem_cgroup_from_id - look up a memcg from a memcg id
>   * @id: the memcg id to look up
> @@ -4687,6 +4697,8 @@ static void __mem_cgroup_clear_mc(void)
>  		if (!mem_cgroup_is_root(mc.from))
>  			page_counter_uncharge(&mc.from->memsw, mc.moved_swap);
>  
> +		mem_cgroup_id_put_many(mc.from, mc.moved_swap);
> +
>  		/*
>  		 * we charged both to->memory and to->memsw, so we
>  		 * should uncharge to->memory.
> @@ -4694,9 +4706,9 @@ static void __mem_cgroup_clear_mc(void)
>  		if (!mem_cgroup_is_root(mc.to))
>  			page_counter_uncharge(&mc.to->memory, mc.moved_swap);
>  
> -		css_put_many(&mc.from->css, mc.moved_swap);
> +		mem_cgroup_id_get_many(mc.to, mc.moved_swap);
> +		css_put_many(&mc.to->css, mc.moved_swap);
>  
> -		/* we've already done css_get(mc.to) */
>  		mc.moved_swap = 0;
>  	}
>  	memcg_oom_recover(from);
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
