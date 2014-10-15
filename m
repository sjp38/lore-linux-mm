Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id DDECA6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 11:18:40 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pv20so1274838lab.34
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 08:18:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l7si31003732lae.29.2014.10.15.08.18.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 08:18:38 -0700 (PDT)
Date: Wed, 15 Oct 2014 17:18:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/5] mm: memcontrol: take a css reference for each
 charged page
Message-ID: <20141015151836.GG23547@dhcp22.suse.cz>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
 <1413303637-23862-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413303637-23862-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 14-10-14 12:20:34, Johannes Weiner wrote:
> Charges currently pin the css indirectly by playing tricks during
> css_offline(): user pages stall the offlining process until all of
> them have been reparented, whereas kmemcg acquires a keep-alive
> reference if outstanding kernel pages are detected at that point.
> 
> In preparation for removing all this complexity, make the pinning
> explicit and acquire a css references for every charged page.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/cgroup.h          | 26 +++++++++++++++++++++++
>  include/linux/percpu-refcount.h | 47 +++++++++++++++++++++++++++++++++--------
>  mm/memcontrol.c                 | 21 ++++++++++++++----
>  3 files changed, 81 insertions(+), 13 deletions(-)
> 
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 67dabe8b0aa6..a3feead6be15 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2256,6 +2256,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
>  		page_counter_uncharge(&old->memory, stock->nr_pages);
>  		if (do_swap_account)
>  			page_counter_uncharge(&old->memsw, stock->nr_pages);
> +		css_put_many(&old->css, stock->nr_pages);

I have suggested to add a comment about pairing css_get here because the
corresponding refill_stock doesn't take any reference which might be
little bit confusing. Nothing earth shattering of course...

>  		stock->nr_pages = 0;
>  	}
>  	stock->cached = NULL;
> @@ -2513,6 +2514,7 @@ bypass:
>  	return -EINTR;
>  
>  done_restock:
> +	css_get_many(&memcg->css, batch);
>  	if (batch > nr_pages)
>  		refill_stock(memcg, batch - nr_pages);
>  done:
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
