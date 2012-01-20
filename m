Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id F1AD86B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 03:43:12 -0500 (EST)
Date: Fri, 20 Jan 2012 09:43:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3] memcg: remove unnecessary thp check at page stat
 accounting
Message-ID: <20120120084310.GB9655@tiehlicka.suse.cz>
References: <20120119161445.b3a8a9d2.kamezawa.hiroyu@jp.fujitsu.com>
 <20120120122512.decd06c0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120120122512.decd06c0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Fri 20-01-12 12:25:12, KAMEZAWA Hiroyuki wrote:
> Updated description.
> ==
> From a6395205d9f517af7963ff61d66efbcf1c64b2a5 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 12 Jan 2012 16:08:33 +0900
> Subject: [PATCH v3] memcg: remove unnecessary check in mem_cgroup_update_page_stat()
> 
> This patch is a fix for

I would rather call it a follow up for this patch. It doesn't fixes it.

>     memcg: make mem_cgroup_split_huge_fixup() more efficient
> 
> Above patch removes move_lock_page_cgroup(). So, we do not have
> to check PageTransHuge in mem_cgroup_update_page_stat and fallback into
> the locked accounting because both move_account and thp split are done
> with compound_lock so they cannot race.
> The race between update vs. move is protected by mem_cgroup_stealed,
> 
> PageTransHuge pages shouldn't appear in this code path currently because
> we are tracking only file pages at the moment but later we are planning
> to track also other pages (e.g. mlocked ones).
> 
> Changelog:
>  - updated description.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Anyway
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3dbff4d..ff24520 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1867,7 +1867,7 @@ void mem_cgroup_update_page_stat(struct page *page,
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
