Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95AEC6B025F
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 08:36:59 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 40so8336750wrv.4
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 05:36:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 64si4035332wrk.548.2017.08.30.05.36.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 05:36:57 -0700 (PDT)
Date: Wed, 30 Aug 2017 14:36:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: use per-cpu stocks for socket memory
 uncharging
Message-ID: <20170830123655.6kce7yfkrhrhwubu@dhcp22.suse.cz>
References: <20170829100150.4580-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170829100150.4580-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue 29-08-17 11:01:50, Roman Gushchin wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b9cf3cf4a3d0..a69d23082abf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1792,6 +1792,9 @@ static void refill_stock(struct mem_cgroup *memcg, unsigned int nr_pages)
>  	}
>  	stock->nr_pages += nr_pages;
>  
> +	if (stock->nr_pages > CHARGE_BATCH)
> +		drain_stock(stock);
> +
>  	local_irq_restore(flags);
>  }

Why do we need this? In other words, why cannot we rely on draining we
already do?

>  
> @@ -5886,8 +5889,7 @@ void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
>  
>  	this_cpu_sub(memcg->stat->count[MEMCG_SOCK], nr_pages);
>  
> -	page_counter_uncharge(&memcg->memory, nr_pages);
> -	css_put_many(&memcg->css, nr_pages);
> +	refill_stock(memcg, nr_pages);
>  }

This makes sense to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
