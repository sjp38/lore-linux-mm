Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id DCF406B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 12:48:17 -0400 (EDT)
Date: Mon, 2 Jul 2012 18:48:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 2/2] memcg : remove -ENOMEM at page migration.
Message-ID: <20120702164813.GG8050@tiehlicka.suse.cz>
References: <4FEC300A.7040209@jp.fujitsu.com>
 <4FEC308F.4020909@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FEC308F.4020909@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Thu 28-06-12 19:23:11, KAMEZAWA Hiroyuki wrote:
> For handling many kinds of races, memcg adds an extra charge to
> page's memcg at page migration. But this affects the page compaction
> and make it fail if the memcg is under OOM.
> 
> This patch uses res_counter_charge_nofail() in page migration path
> and remove -ENOMEM. By this, page migration will not fail by the
> status of memcg.

Maybe we could add something like below to the changelog as well.
"
Even though res_counter_charge_nofail can silently go over the memcg
limit mem_cgroup_usage compensates that and it doesn't tell the real truth
to the userspace. 
Excessive charges are only temporal and done on a single page per-CPU in
the worst case. This sounds tolerable and actually consumes less charges
than the current per-cpu memcg_stock.
"

> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
>  mm/memcontrol.c |   26 +++++++-------------------
>  1 files changed, 7 insertions(+), 19 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a2677e0..7424fab 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3168,6 +3168,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>  	struct page *newpage, struct mem_cgroup **memcgp, gfp_t gfp_mask)
>  {
>  	struct mem_cgroup *memcg = NULL;
> +	struct res_counter *dummy;
>  	struct page_cgroup *pc;
>  	enum charge_type ctype;
>  	int ret = 0;
> @@ -3222,29 +3223,16 @@ int mem_cgroup_prepare_migration(struct page *page,
>  	 */
>  	if (!memcg)
>  		return 0;
> -
> -	*memcgp = memcg;
> -	ret = __mem_cgroup_try_charge(NULL, gfp_mask, 1, memcgp, false);
> -	css_put(&memcg->css);/* drop extra refcnt */
> -	if (ret) {
> -		if (PageAnon(page)) {
> -			lock_page_cgroup(pc);
> -			ClearPageCgroupMigration(pc);
> -			unlock_page_cgroup(pc);
> -			/*
> -			 * The old page may be fully unmapped while we kept it.
> -			 */
> -			mem_cgroup_uncharge_page(page);
> -		}
> -		/* we'll need to revisit this error code (we have -EINTR) */
> -		return -ENOMEM;
> -	}
>  	/*
>  	 * We charge new page before it's used/mapped. So, even if unlock_page()
>  	 * is called before end_migration, we can catch all events on this new
>  	 * page. In the case new page is migrated but not remapped, new page's
>  	 * mapcount will be finally 0 and we call uncharge in end_migration().
>  	 */
> +	res_counter_charge_nofail(&memcg->res, PAGE_SIZE, &dummy);
> +	if (do_swap_account)
> +		res_counter_charge_nofail(&memcg->memsw, PAGE_SIZE, &dummy);
> +
>  	if (PageAnon(page))
>  		ctype = MEM_CGROUP_CHARGE_TYPE_ANON;
>  	else if (page_is_file_cache(page))
> @@ -3807,9 +3795,9 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  
>  	if (!mem_cgroup_is_root(memcg)) {
>  		if (!swap)
> -			return res_counter_read_u64(&memcg->res, RES_USAGE);
> +			return res_counter_usage_safe(&memcg->res);
>  		else
> -			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
> +			return res_counter_usage_safe(&memcg->memsw);
>  	}
>  
>  	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
> -- 
> 1.7.4.1
> 
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
