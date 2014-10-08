Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id ACDA2900014
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:27:57 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so11529639wgg.8
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:27:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si20230wjx.83.2014.10.08.06.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Oct 2014 06:27:56 -0700 (PDT)
Date: Wed, 8 Oct 2014 15:27:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: take a css reference for each
 charged page
Message-ID: <20141008132754.GB4592@dhcp22.suse.cz>
References: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
 <1411243235-24680-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411243235-24680-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat 20-09-14 16:00:33, Johannes Weiner wrote:
> Charges currently pin the css indirectly by playing tricks during
> css_offline(): user pages stall the offlining process until all of
> them have been reparented, whereas kmemcg acquires a keep-alive
> reference if outstanding kernel pages are detected at that point.
> 
> In preparation for removing all this complexity, make the pinning
> explicit and acquire a css references for every charged page.

OK, all the added {un}charges/atomics happen in a page_counter paths so
there shouldn't be any noticeable overhead.

I cannot judge the percpu counter part but the rest seems OK to me.
Two minor suggestions below.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

For the memcg part
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/cgroup.h          | 26 +++++++++++++++++++++++++
>  include/linux/percpu-refcount.h | 43 ++++++++++++++++++++++++++++++++---------
>  mm/memcontrol.c                 | 17 +++++++++++++++-
>  3 files changed, 76 insertions(+), 10 deletions(-)
> 
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 154161bb7d4c..b832c87ec43b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2317,6 +2317,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
>  		page_counter_uncharge(&old->memory, stock->nr_pages);
>  		if (do_swap_account)
>  			page_counter_uncharge(&old->memsw, stock->nr_pages);

		/* pairs with css_get_many in try_charge */
> +		css_put_many(&old->css, stock->nr_pages);
>  		stock->nr_pages = 0;
>  	}
>  	stock->cached = NULL;
[...]
> @@ -2803,8 +2808,10 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
>  		page_counter_uncharge(&memcg->memsw, nr_pages);
>  

Wouldn't a single out_css_put be more readable? I was quite confused
when I start reading the patch before I saw the next hunk.

>  	/* Not down to 0 */
> -	if (page_counter_uncharge(&memcg->kmem, nr_pages))
		goto out_css_put;

> +	if (page_counter_uncharge(&memcg->kmem, nr_pages)) {
> +		css_put_many(&memcg->css, nr_pages);
>  		return;
> +	}
>  
>  	/*
>  	 * Releases a reference taken in kmem_cgroup_css_offline in case
> @@ -2816,6 +2823,8 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
>  	 */
>  	if (memcg_kmem_test_and_clear_dead(memcg))
>  		css_put(&memcg->css);
> +

out_css_put:
> +	css_put_many(&memcg->css, nr_pages);
>  }
>  
>  /*
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
