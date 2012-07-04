Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 1B79F6B0070
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 08:04:49 -0400 (EDT)
Date: Wed, 4 Jul 2012 14:04:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 2/2] memcg: remove -ENOMEM at page migration.
Message-ID: <20120704120445.GC29842@tiehlicka.suse.cz>
References: <4FF3B0DC.5090508@jp.fujitsu.com>
 <4FF3B14E.2090300@jp.fujitsu.com>
 <20120704083019.GA7881@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120704083019.GA7881@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Wed 04-07-12 10:30:19, Johannes Weiner wrote:
> On Wed, Jul 04, 2012 at 11:58:22AM +0900, Kamezawa Hiroyuki wrote:
> > >From 257a1e6603aab8c6a3bd25648872a11e8b85ef64 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 28 Jun 2012 19:07:24 +0900
> > Subject: [PATCH 2/2] 
> > 
> > For handling many kinds of races, memcg adds an extra charge to
> > page's memcg at page migration. But this affects the page compaction
> > and make it fail if the memcg is under OOM.
> > 
> > This patch uses res_counter_charge_nofail() in page migration path
> > and remove -ENOMEM. By this, page migration will not fail by the
> > status of memcg.
> > 
> > Even though res_counter_charge_nofail can silently go over the memcg
> > limit mem_cgroup_usage compensates that and it doesn't tell the real truth
> > to the userspace.
> > 
> > Excessive charges are only temporal and done on a single page per-CPU in
> > the worst case. This sounds tolerable and actually consumes less charges
> > than the current per-cpu memcg_stock.
> 
> But it still means we end up going into reclaim on charges, limit
> resizing etc. which we wouldn't without a bunch of pages under
> migration.
> 
> Can we instead not charge the new page, just commit it while holding
> on to a css refcount, and have end_migration call a version of
> __mem_cgroup_uncharge_common() that updates the stats but leaves the
> res counters alone?

Yes, this is also a way to go. Both approaches have to lie a bit and
both have a discrepancy between stat and usage_in_bytes. I guess we can
live with that.
Kame's solution seems easier but yours prevent from a corner case when
the reclaim is triggered due to artificial charges so I guess it is
better to go with yours.
Few (trivial) comments on the patch bellow.

> oldpage will not get uncharged because of the page lock and
> PageCgroupMigration, so the charge is stable during migration.
> 
> Patch below
[...]
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 83e7ba9..17a09e8 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -100,7 +100,7 @@ int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
>  
>  extern struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg);
>  
> -extern int
> +extern void
>  mem_cgroup_prepare_migration(struct page *page,
>  	struct page *newpage, struct mem_cgroup **memcgp, gfp_t gfp_mask);
>  extern void mem_cgroup_end_migration(struct mem_cgroup *memcg,
> @@ -279,11 +279,10 @@ static inline struct cgroup_subsys_state
>  	return NULL;
>  }
>  
> -static inline int
> +static inline void
>  mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
>  	struct mem_cgroup **memcgp, gfp_t gfp_mask)
>  {
> -	return 0;
>  }
>  
>  static inline void mem_cgroup_end_migration(struct mem_cgroup *memcg,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f72b5e5..c5161f0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2911,7 +2911,8 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
>   * uncharge if !page_mapped(page)
>   */
>  static struct mem_cgroup *
> -__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
> +__mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
> +			     bool end_migration)
>  {
>  	struct mem_cgroup *memcg = NULL;
>  	unsigned int nr_pages = 1;
> @@ -2955,7 +2956,10 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  		/* fallthrough */
>  	case MEM_CGROUP_CHARGE_TYPE_DROP:
>  		/* See mem_cgroup_prepare_migration() */
> -		if (page_mapped(page) || PageCgroupMigration(pc))
> +		if (page_mapped(page))
> +			goto unlock_out;

Don't need that test or remove the one below (seems easier to read
because those cases are really different things).

> +		if (page_mapped(page) || (!end_migration &&
> +					  PageCgroupMigration(pc)))
>  			goto unlock_out;
>  		break;
>  	case MEM_CGROUP_CHARGE_TYPE_SWAPOUT:
[...]
> @@ -3166,19 +3170,18 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>   * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
>   * page belongs to.
>   */
> -int mem_cgroup_prepare_migration(struct page *page,
> +void mem_cgroup_prepare_migration(struct page *page,
>  	struct page *newpage, struct mem_cgroup **memcgp, gfp_t gfp_mask)

gfp_mask is not needed anymore


>  {
>  	struct mem_cgroup *memcg = NULL;
>  	struct page_cgroup *pc;
>  	enum charge_type ctype;
> -	int ret = 0;
>  
>  	*memcgp = NULL;
>  
>  	VM_BUG_ON(PageTransHuge(page));
>  	if (mem_cgroup_disabled())
> -		return 0;
> +		return;
>  
>  	pc = lookup_page_cgroup(page);
>  	lock_page_cgroup(pc);
> @@ -3223,24 +3226,9 @@ int mem_cgroup_prepare_migration(struct page *page,
>  	 * we return here.
>  	 */
>  	if (!memcg)
> -		return 0;
> +		return;
>  
>  	*memcgp = memcg;
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
> @@ -3254,7 +3242,7 @@ int mem_cgroup_prepare_migration(struct page *page,
>  	else
>  		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
>  	__mem_cgroup_commit_charge(memcg, newpage, 1, ctype, false);

Perhaps a comment that we are doing commit without charge because this
is only temporal would be good?

Thanks!
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
