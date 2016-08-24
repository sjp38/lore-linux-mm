Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 698C46B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 04:41:24 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so6543618lfw.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 01:41:24 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t9si25285751wmb.145.2016.08.24.01.41.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 01:41:23 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so1578062wma.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 01:41:22 -0700 (PDT)
Date: Wed, 24 Aug 2016 10:41:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: avoid unused function warning
Message-ID: <20160824084121.GF31179@dhcp22.suse.cz>
References: <20160824082301.632345-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160824082301.632345-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 24-08-16 10:22:43, Arnd Bergmann wrote:
> A bugfix in v4.8-rc2 introduced a harmless warning when CONFIG_MEMCG_SWAP
> is disabled but CONFIG_MEMCG is enabled:
> 
> mm/memcontrol.c:4085:27: error: 'mem_cgroup_id_get_online' defined but not used [-Werror=unused-function]
>  static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
> 
> This adds an extra #ifdef that matches the one around the caller to
> avoid the warning.

Thanks for fixing that! Could you please move the function to the same
ifdef section as its users please.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 1f47b61fb407 ("mm: memcontrol: fix swap counter leak on swapout from offline cgroup")

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2ff0289ad061..e8d787163b65 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4082,6 +4082,7 @@ static void mem_cgroup_id_get_many(struct mem_cgroup *memcg, unsigned int n)
>  	atomic_add(n, &memcg->id.ref);
>  }
>  
> +#ifdef CONFIG_MEMCG_SWAP
>  static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
>  {
>  	while (!atomic_inc_not_zero(&memcg->id.ref)) {
> @@ -4099,6 +4100,7 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
>  	}
>  	return memcg;
>  }
> +#endif
>  
>  static void mem_cgroup_id_put_many(struct mem_cgroup *memcg, unsigned int n)
>  {
> -- 
> 2.9.0
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
