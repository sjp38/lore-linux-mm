Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id C7BD36B004F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 00:50:18 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D6ACC3EE0BB
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 14:50:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD64945DE50
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 14:50:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A8FB345DE4F
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 14:50:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D0A91DB803B
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 14:50:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D738E78004
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 14:50:16 +0900 (JST)
Date: Mon, 16 Jan 2012 14:48:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: memcg: update the correct soft limit tree during
 migration
Message-Id: <20120116144837.eaedf4d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1326469291-5642-1-git-send-email-hannes@cmpxchg.org>
References: <1326469291-5642-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Jan 2012 16:41:31 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

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


Nice Catch.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
