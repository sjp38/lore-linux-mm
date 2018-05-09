Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7EDF6B0333
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:45:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16so1024116pfn.5
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:45:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k127-v6si1249951pgk.256.2018.05.09.00.45.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 May 2018 00:45:11 -0700 (PDT)
Date: Wed, 9 May 2018 09:45:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: drain stocks on resize limit
Message-ID: <20180509074508.GC32366@dhcp22.suse.cz>
References: <20180504205548.110696-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504205548.110696-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 04-05-18 13:55:48, Shakeel Butt wrote:
> Resizing the memcg limit for cgroup-v2 drains the stocks before
> triggering the memcg reclaim. Do the same for cgroup-v1 to make the
> behavior consistent.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 25b148c2d222..e2d33a37f971 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2463,6 +2463,7 @@ static int mem_cgroup_resize_max(struct mem_cgroup *memcg,
>  				 unsigned long max, bool memsw)
>  {
>  	bool enlarge = false;
> +	bool drained = false;
>  	int ret;
>  	bool limits_invariant;
>  	struct page_counter *counter = memsw ? &memcg->memsw : &memcg->memory;
> @@ -2493,6 +2494,12 @@ static int mem_cgroup_resize_max(struct mem_cgroup *memcg,
>  		if (!ret)
>  			break;
>  
> +		if (!drained) {
> +			drain_all_stock(memcg);
> +			drained = true;
> +			continue;
> +		}
> +
>  		if (!try_to_free_mem_cgroup_pages(memcg, 1,
>  					GFP_KERNEL, !memsw)) {
>  			ret = -EBUSY;
> -- 
> 2.17.0.441.gb46fe60e1d-goog

-- 
Michal Hocko
SUSE Labs
