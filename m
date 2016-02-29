Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 013266B025B
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:29:26 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so1846559wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:29:25 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id le8si33389455wjb.80.2016.02.29.10.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:29:24 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id l68so3418348wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:29:24 -0800 (PST)
Date: Mon, 29 Feb 2016 19:29:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: reset memory.low on css offline
Message-ID: <20160229182923.GR16930@dhcp22.suse.cz>
References: <1456766193-16255-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456766193-16255-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 29-02-16 20:16:33, Vladimir Davydov wrote:
> When a cgroup directory is removed, the memory cgroup subsys state does
> not disappear immediately. Instead, it's left hanging around until the
> last reference to it is gone, which implies reclaiming all pages from
> its lruvec.
> 
> In the unified hierarchy, there's the memory.low knob, which can be used
> to set a best-effort protection for a memory cgroup - the reclaimer
> first scans those cgroups whose consumption is above memory.low, and
> only if it fails to reclaim enough pages, it gets to the rest.
> 
> Currently this protection is not reset when the cgroup directory is
> removed. As a result, if a dead memory cgroup has a lot of page cache
> charged to it and a high value of memory.low, it will result in higher
> pressure exerted on live cgroups, and userspace will have no ways to
> detect such consumers and reconfigure memory.low properly.
> 
> To fix this, let's reset memory.low on css offline.

Makes sense to me
 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ae8b81c55685..ab7bfe870c7d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4214,6 +4214,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>  
>  	memcg_offline_kmem(memcg);
>  	wb_memcg_offline(memcg);
> +
> +	memcg->low = 0;
>  }
>  
>  static void mem_cgroup_css_released(struct cgroup_subsys_state *css)
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
