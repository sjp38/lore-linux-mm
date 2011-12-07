Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 686CF6B004D
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 06:14:58 -0500 (EST)
Date: Wed, 7 Dec 2011 12:14:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [BUGFIX][PATCH] add mem_cgroup_replace_page_cache.
Message-ID: <20111207111455.GA18249@tiehlicka.suse.cz>
References: <20111206123923.1432ab52.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111206123923.1432ab52.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Miklos Szeredi <mszeredi@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue 06-12-11 12:39:23, KAMEZAWA Hiroyuki wrote:
> 
> Hm, is this too naive ? better idea is welcome. 
> ==
> From 33638351c5cd28af9f47f9ab1c44eeb1f63d9964 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Tue, 6 Dec 2011 12:32:32 +0900
> Subject: [PATCH] memcg: add mem_cgroup_replace_page_cache() for fixing LRU issue.
> 
> commit ef6a3c6311 adds a function replace_page_cache_page(). This
> function replaces a page in radix-tree with a new page.
> At doing this, memory cgroup need to fix up the accounting information.
> memcg need to check PCG_USED bit etc.
> 
> In some(many?) case, 'newpage' is on LRU before calling replace_page_cache().
> So, memcg's LRU accounting information should be fixed, too.
> 
> This patch adds mem_cgroup_replace_page_cache() and removing old hooks.
> In that function, old pages will be unaccounted without touching res_counter
> and new page will be accounted to the memcg (of old page). At overwriting
> pc->mem_cgroup of newpage, take zone->lru_lock and avoid race with
> LRU handling.
> 
> Background:
>   replace_page_cache_page() is called by FUSE code in its splice() handling.
>   Here, 'newpage' is replacing oldpage but this newpage is not a newly allocated
>   page and may be on LRU. LRU mis-accounting will be critical for memory cgroup
>   because rmdir() checks the whole LRU is empty and there is no account leak.
>   If a page is on the other LRU than it should be, rmdir() will fail.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    6 ++++++
>  mm/filemap.c               |   18 ++----------------
>  mm/memcontrol.c            |   41 +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 49 insertions(+), 16 deletions(-)
> 
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8880a32..a9e92a6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3306,6 +3306,47 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
>  	cgroup_release_and_wakeup_rmdir(&memcg->css);
>  }
>  
> +/*
> + * At replace page cache, newpage is not under any memcg but it's on
> + * LRU. So, this function doesn't touch res_counter but handles LRU
> + * in correct way.

Could you add?
Both pages are locked so we cannot race with uncharge

> + */
> +void mem_cgroup_replace_page_cache(struct page *oldpage,
> +				  struct page *newpage)
> +{
> +	struct mem_cgroup *memcg;
> +	struct page_cgroup *pc;
> +	struct zone *zone;
> +	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
> +	unsigned long flags;
> +

You are missing 
	if (mem_cgroup_disabled())
		return;

> +	pc = lookup_page_cgroup(oldpage);
> +	/* fix accounting on old pages */
> +	lock_page_cgroup(pc);
> +	memcg = pc->mem_cgroup;
> +	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), -1);
> +	ClearPageCgroupUsed(pc);
> +	unlock_page_cgroup(pc);
> +
> +	if (PageSwapBacked(oldpage))
> +		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> +
> +	zone = page_zone(newpage);
> +	pc = lookup_page_cgroup(newpage);
> +	/*
> +	 * Even if newpage->mapping was NULL before starting replacement,
> +	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
> +	 * LRU while we overwrite pc->mem_cgroup.
> +	 */
> +	spin_lock_irqsave(&zone->lru_lock, flags);
> +	if (PageLRU(newpage))
> +		del_page_from_lru_list(zone, newpage, page_lru(newpage));
> +	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, type);
> +	if (PageLRU(newpage))
> +		add_page_to_lru_list(zone, newpage, page_lru(newpage));
> +	spin_unlock_irqrestore(&zone->lru_lock, flags);
> +}
> +

Other than that looks ok.

Thanks
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
