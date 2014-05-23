Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id BBBA96B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 09:39:40 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so3581884eei.5
        for <linux-mm@kvack.org>; Fri, 23 May 2014 06:39:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si6899511eep.37.2014.05.23.06.39.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 06:39:39 -0700 (PDT)
Date: Fri, 23 May 2014 15:39:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 7/9] mm: memcontrol: do not acquire page_cgroup lock for
 kmem pages
Message-ID: <20140523133938.GC22135@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-8-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398889543-23671-8-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

I am adding Vladimir to CC

On Wed 30-04-14 16:25:41, Johannes Weiner wrote:
> Kmem page charging and uncharging is serialized by means of exclusive
> access to the page.  Do not take the page_cgroup lock and don't set
> pc->flags atomically.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

The patch is correct I just have some comments below.
Anyway
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 16 +++-------------
>  1 file changed, 3 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c528ae9ac230..d3961fce1d54 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3535,10 +3535,8 @@ void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  	}
>  

	/*
	 * given page is newly allocated and invisible to everybody but
	 * the caller so there is no need to use page_cgroup lock nor
	 * SetPageCgroupUsed
	 */

would be helpful?

>  	pc = lookup_page_cgroup(page);
> -	lock_page_cgroup(pc);
>  	pc->mem_cgroup = memcg;
> -	SetPageCgroupUsed(pc);
> -	unlock_page_cgroup(pc);
> +	pc->flags = PCG_USED;
>  }
>  
>  void __memcg_kmem_uncharge_pages(struct page *page, int order)
> @@ -3548,19 +3546,11 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
>  
>  
>  	pc = lookup_page_cgroup(page);
> -	/*
> -	 * Fast unlocked return. Theoretically might have changed, have to
> -	 * check again after locking.
> -	 */

This comment was there since the code has been merged. Maybe it was true
at the time but after "mm: get rid of __GFP_KMEMCG" it is definitely out
of date.

	/*
	 * the pages is going away and will be freed and nobody can see
	 * it anymore so no need to take page_cgroup lock.
	 */
>  	if (!PageCgroupUsed(pc))
>  		return;
>  
> -	lock_page_cgroup(pc);
> -	if (PageCgroupUsed(pc)) {
> -		memcg = pc->mem_cgroup;
> -		ClearPageCgroupUsed(pc);
> -	}
> -	unlock_page_cgroup(pc);

maybe add
	WARN_ON_ONCE(pc->flags != PCG_USED);

to check for an unexpected flags usage in the kmem path?

> +	memcg = pc->mem_cgroup;
> +	pc->flags = 0;
>  
>  	/*
>  	 * We trust that only if there is a memcg associated with the page, it
> -- 
> 1.9.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
