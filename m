Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id C8C666B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:43:11 -0500 (EST)
Date: Wed, 29 Feb 2012 20:43:04 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH next] memcg: remove PCG_CACHE page_cgroup flag fix
Message-ID: <20120229194304.GF1673@cmpxchg.org>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
 <alpine.LSU.2.00.1202282128500.4875@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1202282128500.4875@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 28, 2012 at 09:30:17PM -0800, Hugh Dickins wrote:
> Swapping tmpfs loads show absurd wrapped rss and wrong cache in memcg's
> memory.stat statistics: __mem_cgroup_uncharge_common() is failing to
> distinguish the anon and tmpfs cases.
> 
> Mostly we can decide between them by PageAnon, which is reliable once
> it has been set; but there are several callers who need to uncharge a
> MEM_CGROUP_CHARGE_TYPE_MAPPED page before it was fully initialized,
> so allow that case to override the PageAnon decision.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 
>  mm/memcontrol.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> --- 3.3-rc5-next/mm/memcontrol.c	2012-02-25 10:06:52.496035568 -0800
> +++ linux/mm/memcontrol.c	2012-02-26 10:44:32.146365398 -0800
> @@ -2944,13 +2944,16 @@ __mem_cgroup_uncharge_common(struct page
>  	if (!PageCgroupUsed(pc))
>  		goto unlock_out;
>  
> +	anon = PageAnon(page);
> +
>  	switch (ctype) {
>  	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> +		anon = true;
> +		/* fallthrough */

If you don't mind, could you add a small comment on why this is the
exception where we don't trust page->mapping?

Other than that,
Acked-by: Johannes Weiner <hannes@cmpxchg.org>

>  	case MEM_CGROUP_CHARGE_TYPE_DROP:
>  		/* See mem_cgroup_prepare_migration() */
>  		if (page_mapped(page) || PageCgroupMigration(pc))
>  			goto unlock_out;
> -		anon = true;
>  		break;
>  	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
>  		if (!PageAnon(page)) {	/* Shared memory */
> @@ -2958,10 +2961,8 @@ __mem_cgroup_uncharge_common(struct page
>  				goto unlock_out;
>  		} else if (page_mapped(page)) /* Anon */
>  				goto unlock_out;
> -		anon = true;
>  		break;
>  	default:
> -		anon = false;
>  		break;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
