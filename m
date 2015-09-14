Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id EA9E36B0255
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:21:32 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so137381175wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:21:32 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id q18si17790352wik.96.2015.09.14.08.21.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:21:31 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so137380553wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:21:31 -0700 (PDT)
Date: Mon, 14 Sep 2015 17:21:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] memcg: collect kmem bypass conditions into
 __memcg_kmem_bypass()
Message-ID: <20150914152129.GE7050@dhcp22.suse.cz>
References: <20150913201416.GC25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150913201416.GC25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Sun 13-09-15 16:14:16, Tejun Heo wrote:
> memcg_kmem_newpage_charge() and memcg_kmem_get_cache() are testing the
> same series of conditions to decide whether to bypass kmem accounting.
> Collect the tests into __memcg_kmem_bypass().
> 
> This is pure refactoring.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> Hello,
> 
> These three patches are on top of mmotm as of Sep 13th and the two
> patches from the following thread.
> 
>  http://lkml.kernel.org/g/20150913185940.GA25369@htj.duckdns.org
> 
> Thanks.
> 
>  include/linux/memcontrol.h |   46 +++++++++++++++++++++------------------------
>  1 file changed, 22 insertions(+), 24 deletions(-)
> 
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -776,20 +776,7 @@ int memcg_charge_kmem(struct mem_cgroup
>  		      unsigned long nr_pages);
>  void memcg_uncharge_kmem(struct mem_cgroup *memcg, unsigned long nr_pages);
>  
> -/**
> - * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
> - * @gfp: the gfp allocation flags.
> - * @memcg: a pointer to the memcg this was charged against.
> - * @order: allocation order.
> - *
> - * returns true if the memcg where the current task belongs can hold this
> - * allocation.
> - *
> - * We return true automatically if this allocation is not to be accounted to
> - * any memcg.
> - */
> -static inline bool
> -memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
> +static inline bool __memcg_kmem_bypass(gfp_t gfp)
>  {
>  	if (!memcg_kmem_enabled())
>  		return true;
> @@ -811,6 +798,26 @@ memcg_kmem_newpage_charge(gfp_t gfp, str
>  	if (unlikely(fatal_signal_pending(current)))
>  		return true;
>  
> +	return false;
> +}
> +
> +/**
> + * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
> + * @gfp: the gfp allocation flags.
> + * @memcg: a pointer to the memcg this was charged against.
> + * @order: allocation order.
> + *
> + * returns true if the memcg where the current task belongs can hold this
> + * allocation.
> + *
> + * We return true automatically if this allocation is not to be accounted to
> + * any memcg.
> + */
> +static inline bool
> +memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
> +{
> +	if (__memcg_kmem_bypass(gfp))
> +		return true;
>  	return __memcg_kmem_newpage_charge(gfp, memcg, order);
>  }
>  
> @@ -853,17 +860,8 @@ memcg_kmem_commit_charge(struct page *pa
>  static __always_inline struct kmem_cache *
>  memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
>  {
> -	if (!memcg_kmem_enabled())
> -		return cachep;
> -	if (gfp & __GFP_NOACCOUNT)
> -		return cachep;
> -	if (gfp & __GFP_NOFAIL)
> +	if (__memcg_kmem_bypass(gfp))
>  		return cachep;
> -	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
> -		return cachep;
> -	if (unlikely(fatal_signal_pending(current)))
> -		return cachep;
> -
>  	return __memcg_kmem_get_cache(cachep);
>  }
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
