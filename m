Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D08F6B03A9
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 04:00:18 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x61so9403722wrb.8
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 01:00:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3si6645172wrb.20.2017.04.07.01.00.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 01:00:16 -0700 (PDT)
Date: Fri, 7 Apr 2017 10:00:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, swap_cgroup: reschedule when neeed in
 swap_cgroup_swapoff()
Message-ID: <20170407080012.GA16392@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1704061315270.80559@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1704061315270.80559@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 06-04-17 13:16:24, David Rientjes wrote:
> We got need_resched() warnings in swap_cgroup_swapoff() because
> swap_cgroup_ctrl[type].length is particularly large.
> 
> Reschedule when needed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/swap_cgroup.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
> --- a/mm/swap_cgroup.c
> +++ b/mm/swap_cgroup.c
> @@ -201,6 +201,8 @@ void swap_cgroup_swapoff(int type)
>  			struct page *page = map[i];
>  			if (page)
>  				__free_page(page);
> +			if (!(i % SWAP_CLUSTER_MAX))
> +				cond_resched();
>  		}
>  		vfree(map);
>  	}
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
