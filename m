Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 385886B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 10:59:25 -0500 (EST)
Date: Fri, 13 Jan 2012 16:59:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcg: update the correct soft limit tree during
 migration
Message-ID: <20120113155922.GE17060@tiehlicka.suse.cz>
References: <1326469291-5642-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326469291-5642-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-01-12 16:41:31, Johannes Weiner wrote:
> end_migration() passes the old page instead of the new page to commit
> the charge.  This page descriptor is not used for committing itself,
> though, since we also pass the (correct) page_cgroup descriptor.  But
> it's used to find the soft limit tree through the page's zone, so the
> soft limit tree of the old page's zone is updated instead of that of
> the new page's, which might get slightly out of date until the next
> charge reaches the ratelimit point.
> 
> This glitch has been present since '5564e88 memcg: condense
> page_cgroup-to-page lookup points'.
> 
> Reported-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Well spotted.
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> This fixes a bug that I introduced in 2.6.38.  It's benign enough (to
> my knowledge) that we probably don't want this for stable.
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 602207b..7a292a5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3247,7 +3247,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>  		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
>  	else
>  		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> -	__mem_cgroup_commit_charge(memcg, page, 1, pc, ctype);
> +	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, ctype);
>  	return ret;
>  }
>  
> -- 
> 1.7.7.5
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
