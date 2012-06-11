Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id EFB406B00C7
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:34:50 -0400 (EDT)
Date: Mon, 11 Jun 2012 09:34:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix use_hierarchy css_is_ancestor oops regression
Message-ID: <20120611073447.GA12402@tiehlicka.suse.cz>
References: <alpine.LSU.2.00.1206101150230.4239@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1206101150230.4239@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun 10-06-12 11:54:47, Hugh Dickins wrote:
> If use_hierarchy is set, reclaim testing soon oopses in css_is_ancestor()
> called from __mem_cgroup_same_or_subtree() called from page_referenced():
> when processes are exiting, it's easy for mm_match_cgroup() to pass along
> a NULL memcg coming from a NULL mm->owner.
> 
> Check for that in __mem_cgroup_same_or_subtree().  Return true or false?
> False because we cannot know if it was in the hierarchy, but also false
> because it's better not to count a reference from an exiting process.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
> This a 3.5-rc issue: not needed for stable.
> 
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 3.5-rc2/mm/memcontrol.c	2012-05-30 08:17:19.400008280 -0700
> +++ linux/mm/memcontrol.c	2012-06-10 08:39:39.618182396 -0700
> @@ -1148,7 +1148,7 @@ bool __mem_cgroup_same_or_subtree(const
>  {
>  	if (root_memcg == memcg)
>  		return true;
> -	if (!root_memcg->use_hierarchy)
> +	if (!root_memcg->use_hierarchy || !memcg)
>  		return false;
>  	return css_is_ancestor(&memcg->css, &root_memcg->css);
>  }

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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
