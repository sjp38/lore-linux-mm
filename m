Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 13F0E6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 04:34:13 -0500 (EST)
Date: Thu, 19 Jan 2012 10:34:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: remove unnecessary thp check at page stat
 accounting
Message-ID: <20120119093410.GB13932@tiehlicka.suse.cz>
References: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Thu 19-01-12 16:14:45, KAMEZAWA Hiroyuki wrote:
> Thank you very much for reviewing previous RFC series.
> This is a patch against memcg-devel and linux-next (can by applied without HUNKs).
> 
> ==
> 
> From 64641b360839b029bb353fbd95f7554cc806ed05 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 12 Jan 2012 16:08:33 +0900
> Subject: [PATCH] memcg: remove unnecessary thp check in mem_cgroup_update_page_stat()
> 
> commit 58b318ecf(memcg-devel)
>     memcg: make mem_cgroup_split_huge_fixup() more efficient
> removes move_lock_page_cgroup() in thp-split path.

I wouldn't refer to something which will change its commit id by its
SHA. I guess the subject is sufficient. Btw. do we really need to
mention this? Is it just to make sure that this doesn't get merged
withtout the mentioned patch?

> So, We do not have to check PageTransHuge in mem_cgroup_update_page_stat
> and fallback into the locked accounting because both move charge and thp
> split up are done with compound_lock so they cannot race. update vs.
> move is protected by the mem_cgroup_stealed sufficiently.
> 
> PageTransHuge pages shouldn't appear in this code path currently because
> we are tracking only file pages at the moment but later we are planning
> to track also other pages (e.g. mlocked ones).
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Other than that
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5073474..fb2dfc3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1801,7 +1801,7 @@ void mem_cgroup_update_page_stat(struct page *page,
>  	if (unlikely(!memcg || !PageCgroupUsed(pc)))
>  		goto out;
>  	/* pc->mem_cgroup is unstable ? */
> -	if (unlikely(mem_cgroup_stealed(memcg)) || PageTransHuge(page)) {
> +	if (unlikely(mem_cgroup_stealed(memcg))) {
>  		/* take a lock against to access pc->mem_cgroup */
>  		move_lock_page_cgroup(pc, &flags);
>  		need_unlock = true;
> -- 
> 1.7.4.1
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

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
