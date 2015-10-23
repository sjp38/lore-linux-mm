Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5A36B0038
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 07:31:06 -0400 (EDT)
Received: by wikq8 with SMTP id q8so72503488wik.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 04:31:05 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id 14si391422wmg.115.2015.10.23.04.31.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 04:31:04 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so27099157wic.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 04:31:04 -0700 (PDT)
Date: Fri, 23 Oct 2015 13:31:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/8] mm: page_counter: let page_counter_try_charge()
 return bool
Message-ID: <20151023113103.GJ2410@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445487696-21545-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 22-10-15 00:21:29, Johannes Weiner wrote:
> page_counter_try_charge() currently returns 0 on success and -ENOMEM
> on failure, which is surprising behavior given the function name.
> 
> Make it follow the expected pattern of try_stuff() functions that
> return a boolean true to indicate success, or false for failure.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/page_counter.h |  6 +++---
>  mm/hugetlb_cgroup.c          |  3 ++-
>  mm/memcontrol.c              | 11 +++++------
>  mm/page_counter.c            | 14 +++++++-------
>  4 files changed, 17 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
> index 17fa4f8..7e62920 100644
> --- a/include/linux/page_counter.h
> +++ b/include/linux/page_counter.h
> @@ -36,9 +36,9 @@ static inline unsigned long page_counter_read(struct page_counter *counter)
>  
>  void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
>  void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
> -int page_counter_try_charge(struct page_counter *counter,
> -			    unsigned long nr_pages,
> -			    struct page_counter **fail);
> +bool page_counter_try_charge(struct page_counter *counter,
> +			     unsigned long nr_pages,
> +			     struct page_counter **fail);
>  void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
>  int page_counter_limit(struct page_counter *counter, unsigned long limit);
>  int page_counter_memparse(const char *buf, const char *max,
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 6a44263..d8fb10d 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -186,7 +186,8 @@ again:
>  	}
>  	rcu_read_unlock();
>  
> -	ret = page_counter_try_charge(&h_cg->hugepage[idx], nr_pages, &counter);
> +	if (!page_counter_try_charge(&h_cg->hugepage[idx], nr_pages, &counter))
> +		ret = -ENOMEM;
>  	css_put(&h_cg->css);
>  done:
>  	*ptr = h_cg;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c71fe40..a8ccdbc 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2018,8 +2018,8 @@ retry:
>  		return 0;
>  
>  	if (!do_swap_account ||
> -	    !page_counter_try_charge(&memcg->memsw, batch, &counter)) {
> -		if (!page_counter_try_charge(&memcg->memory, batch, &counter))
> +	    page_counter_try_charge(&memcg->memsw, batch, &counter)) {
> +		if (page_counter_try_charge(&memcg->memory, batch, &counter))
>  			goto done_restock;
>  		if (do_swap_account)
>  			page_counter_uncharge(&memcg->memsw, batch);
> @@ -2383,14 +2383,13 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
>  {
>  	unsigned int nr_pages = 1 << order;
>  	struct page_counter *counter;
> -	int ret = 0;
> +	int ret;
>  
>  	if (!memcg_kmem_is_active(memcg))
>  		return 0;
>  
> -	ret = page_counter_try_charge(&memcg->kmem, nr_pages, &counter);
> -	if (ret)
> -		return ret;
> +	if (!page_counter_try_charge(&memcg->kmem, nr_pages, &counter))
> +		return -ENOMEM;
>  
>  	ret = try_charge(memcg, gfp, nr_pages);
>  	if (ret) {
> diff --git a/mm/page_counter.c b/mm/page_counter.c
> index 11b4bed..7c6a63d 100644
> --- a/mm/page_counter.c
> +++ b/mm/page_counter.c
> @@ -56,12 +56,12 @@ void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
>   * @nr_pages: number of pages to charge
>   * @fail: points first counter to hit its limit, if any
>   *
> - * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
> - * its ancestors has hit its configured limit.
> + * Returns %true on success, or %false and @fail if the counter or one
> + * of its ancestors has hit its configured limit.
>   */
> -int page_counter_try_charge(struct page_counter *counter,
> -			    unsigned long nr_pages,
> -			    struct page_counter **fail)
> +bool page_counter_try_charge(struct page_counter *counter,
> +			     unsigned long nr_pages,
> +			     struct page_counter **fail)
>  {
>  	struct page_counter *c;
>  
> @@ -99,13 +99,13 @@ int page_counter_try_charge(struct page_counter *counter,
>  		if (new > c->watermark)
>  			c->watermark = new;
>  	}
> -	return 0;
> +	return true;
>  
>  failed:
>  	for (c = counter; c != *fail; c = c->parent)
>  		page_counter_cancel(c, nr_pages);
>  
> -	return -ENOMEM;
> +	return false;
>  }
>  
>  /**
> -- 
> 2.6.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
