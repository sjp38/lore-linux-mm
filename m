Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0C28A9000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 11:02:39 -0400 (EDT)
Date: Tue, 20 Sep 2011 17:02:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 06/11] mm: memcg: remove optimization of keeping the
 root_mem_cgroup LRU lists empty
Message-ID: <20110920150229.GB3571@tiehlicka.suse.cz>
References: <1315825048-3437-1-git-send-email-jweiner@redhat.com>
 <1315825048-3437-7-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1315825048-3437-7-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 12-09-11 12:57:23, Johannes Weiner wrote:
> root_mem_cgroup, lacking a configurable limit, was never subject to
> limit reclaim, so the pages charged to it could be kept off its LRU
> lists.  They would be found on the global per-zone LRU lists upon
> physical memory pressure and it made sense to avoid uselessly linking
> them to both lists.
> 
> The global per-zone LRU lists are about to go away on memcg-enabled
> kernels, with all pages being exclusively linked to their respective
> per-memcg LRU lists.  As a result, pages of the root_mem_cgroup must
> also be linked to its LRU lists again.

Nevertheless we still do not charge them so this should be mentioned
here?

> 
> The overhead is temporary until the double-LRU scheme is going away
> completely.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |   12 ++----------
>  1 files changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 413e1f8..518f640 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -956,8 +956,6 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>  	/* huge page split is done under lru_lock. so, we have no races. */
>  	MEM_CGROUP_ZSTAT(mz, lru) -= 1 << compound_order(page);
> -	if (mem_cgroup_is_root(pc->mem_cgroup))
> -		return;
>  	VM_BUG_ON(list_empty(&pc->lru));
>  	list_del_init(&pc->lru);
>  }
> @@ -982,13 +980,11 @@ void mem_cgroup_rotate_reclaimable_page(struct page *page)
>  		return;
>  
>  	pc = lookup_page_cgroup(page);
> -	/* unused or root page is not rotated. */
> +	/* unused page is not rotated. */
>  	if (!PageCgroupUsed(pc))
>  		return;
>  	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
>  	smp_rmb();
> -	if (mem_cgroup_is_root(pc->mem_cgroup))
> -		return;
>  	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>  	list_move_tail(&pc->lru, &mz->lists[lru]);
>  }
> @@ -1002,13 +998,11 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
>  		return;
>  
>  	pc = lookup_page_cgroup(page);
> -	/* unused or root page is not rotated. */
> +	/* unused page is not rotated. */
>  	if (!PageCgroupUsed(pc))
>  		return;
>  	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
>  	smp_rmb();
> -	if (mem_cgroup_is_root(pc->mem_cgroup))
> -		return;
>  	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
>  	list_move(&pc->lru, &mz->lists[lru]);
>  }
> @@ -1040,8 +1034,6 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
>  	/* huge page split is done under lru_lock. so, we have no races. */
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1 << compound_order(page);
>  	SetPageCgroupAcctLRU(pc);
> -	if (mem_cgroup_is_root(pc->mem_cgroup))
> -		return;
>  	list_add(&pc->lru, &mz->lists[lru]);
>  }
>  
> -- 
> 1.7.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

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
