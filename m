Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DCB9E6B0038
	for <linux-mm@kvack.org>; Thu, 28 May 2015 14:13:04 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so43464791wgb.3
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:13:04 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id cx6si30883008wib.71.2015.05.28.11.13.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 11:13:03 -0700 (PDT)
Received: by wizk4 with SMTP id k4so156105467wiz.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 11:13:03 -0700 (PDT)
Date: Thu, 28 May 2015 20:13:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: do not call reclaim if !__GFP_WAIT
Message-ID: <20150528181301.GC2321@dhcp22.suse.cz>
References: <1432833966-25538-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432833966-25538-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu 28-05-15 20:26:06, Vladimir Davydov wrote:
> When trimming memcg consumption excess (see memory.high), we call
> try_to_free_mem_cgroup_pages without checking if we are allowed to sleep
> in the current context, which can result in a deadlock. Fix this.
> 

Fixes: 241994ed8649 ("mm: memcontrol: default hierarchy interface for memory")

And I would make it for stable 4.0

> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 14c2f2017e37..9da23a7ec4c0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2323,6 +2323,8 @@ done_restock:
>  	css_get_many(&memcg->css, batch);
>  	if (batch > nr_pages)
>  		refill_stock(memcg, batch - nr_pages);
> +	if (!(gfp_mask & __GFP_WAIT))
> +		goto done;
>  	/*
>  	 * If the hierarchy is above the normal consumption range,
>  	 * make the charging task trim their excess contribution.
> -- 
> 2.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
