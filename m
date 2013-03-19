Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3188D6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 09:58:25 -0400 (EDT)
Date: Tue, 19 Mar 2013 14:58:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/5] memcg: make it suck faster
Message-ID: <20130319135821.GG7869@dhcp22.suse.cz>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
 <1362489058-3455-4-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1362489058-3455-4-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On Tue 05-03-13 17:10:56, Glauber Costa wrote:
> It is an accepted fact that memcg sucks. But can it suck faster?  Or in
> a more fair statement, can it at least stop draining everyone's
> performance when it is not in use?
> 
> This experimental and slightly crude patch demonstrates that we can do
> that by using static branches to patch it out until the first memcg
> comes to life. There are edges to be trimmed, and I appreciate comments
> for direction. In particular, the events in the root are not fired, but
> I believe this can be done without further problems by calling a
> specialized event check from mem_cgroup_newpage_charge().
> 
> My goal was to have enough numbers to demonstrate the performance gain
> that can come from it. I tested it in a 24-way 2-socket Intel box, 24 Gb
> mem. I used Mel Gorman's pft test, that he used to demonstrate this
> problem back in the Kernel Summit. There are three kernels:
> 
> nomemcg  : memcg compile disabled.
> base     : memcg enabled, patch not applied.
> bypassed : memcg enabled, with patch applied.
> 
>                 base    bypassed
> User          109.12      105.64
> System       1646.84     1597.98
> Elapsed       229.56      215.76
> 
>              nomemcg    bypassed
> User          104.35      105.64
> System       1578.19     1597.98
> Elapsed       212.33      215.76

Do you have profiles for where we spend the time?

> So as one can see, the difference between base and nomemcg in terms
> of both system time and elapsed time is quite drastic, and consistent
> with the figures shown by Mel Gorman in the Kernel summit. This is a
> ~ 7 % drop in performance, just by having memcg enabled. memcg functions
> appear heavily in the profiles, even if all tasks lives in the root
> memcg.
> 
> With bypassed kernel, we drop this down to 1.5 %, which starts to fall
> in the acceptable range. More investigation is needed to see if we can
> claim that last percent back, but I believe at last part of it should
> be.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memcontrol.h |  72 ++++++++++++++++----
>  mm/memcontrol.c            | 166 +++++++++++++++++++++++++++++++++++++++++----
>  mm/page_cgroup.c           |   4 +-
>  3 files changed, 216 insertions(+), 26 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d6183f0..009f925 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -42,6 +42,26 @@ struct mem_cgroup_reclaim_cookie {
>  };
>  
>  #ifdef CONFIG_MEMCG
> +extern struct static_key memcg_in_use_key;
> +
> +static inline bool mem_cgroup_subsys_disabled(void)
> +{
> +	return !!mem_cgroup_subsys.disabled;
> +}
> +
> +static inline bool mem_cgroup_disabled(void)
> +{
> +	/*
> +	 * Will always be false if subsys is disabled, because we have no one
> +	 * to bump it up. So the test suffices and we don't have to test the
> +	 * subsystem as well
> +	 */

but static_key_false adds an atomic read here which is more costly so I
am not sure you are optimizing much.

> +	if (!static_key_false(&memcg_in_use_key))
> +		return true;
> +	return false;
> +}
> +
> +
>  /*
>   * All "charge" functions with gfp_mask should use GFP_KERNEL or
>   * (gfp_mask & GFP_RECLAIM_MASK). In current implementatin, memcg doesn't
> @@ -53,8 +73,18 @@ struct mem_cgroup_reclaim_cookie {
>   * (Of course, if memcg does memory allocation in future, GFP_KERNEL is sane.)
>   */
>  
> -extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
> +extern int __mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
>  				gfp_t gfp_mask);
> +
> +static inline int
> +mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
> +			  gfp_t gfp_mask)
> +{
> +	if (mem_cgroup_disabled())
> +		return 0;
> +	return __mem_cgroup_newpage_charge(page, mm, gfp_mask);
> +}
> +
>  /* for swap handling */
>  extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>  		struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
> @@ -62,8 +92,17 @@ extern void mem_cgroup_commit_charge_swapin(struct page *page,
>  					struct mem_cgroup *memcg);
>  extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg);
>  
> -extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> -					gfp_t gfp_mask);
> +
> +extern int __mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> +				     gfp_t gfp_mask);
> +static inline int
> +mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
> +{
> +	if (mem_cgroup_disabled())
> +		return 0;
> +
> +	return __mem_cgroup_cache_charge(page, mm, gfp_mask);
> +}

Are there any reasons to not get down to __mem_cgroup_try_charge? We
will not be perfect, all right, because some wrappers already do some
work but we should at least cover most of them.

I am also thinking whether this stab at charging path is not just an
overkill. Wouldn't it suffice to do something like:
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f608546..b70e8f6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2707,7 +2707,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	 * thread group leader migrates. It's possible that mm is not
 	 * set, if so charge the root memcg (happens for pagecache usage).
 	 */
-	if (!*ptr && !mm)
+	if (!*ptr && (!mm || !static_key_false(&memcg_in_use_key)))
 		*ptr = root_mem_cgroup;
 again:
 	if (*ptr) { /* css should be a valid one */

We should get rid of the biggest overhead, no?

>  struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
>  struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bfbf1c2..45c1886 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -1335,6 +1345,20 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>  	memcg = pc->mem_cgroup;

I would expect that you want to prevent lookup as well if there are no
other groups.

>  	/*
> +	 * Because we lazily enable memcg only after first child group is
> +	 * created, we can have memcg == 0. Because page cgroup is created with
> +	 * GFP_ZERO, and after charging, all page cgroups will have a non-zero
> +	 * cgroup attached (even if root), we can be sure that this is a
> +	 * used-but-not-accounted page. (due to lazyness). We could get around
> +	 * that by scanning all pages on cgroup init is too expensive. We can
> +	 * ultimately pay, but prefer to just to defer the update until we get
> +	 * here. We could take the opportunity to set PageCgroupUsed, but it
> +	 * won't be that important for the root cgroup.
> +	 */
> +	if (!memcg && PageLRU(page))
> +		pc->mem_cgroup = memcg = root_mem_cgroup;

Why not return page_cgroup_zoneinfo(root_mem_cgroup, page);
This would require messing up with __mem_cgroup_uncharge_common but that
doesn't sound incredibly crazy (to the local standard of course ;)).

> +
> +	/*
>  	 * Surreptitiously switch any uncharged offlist page to root:
>  	 * an uncharged page off lru does nothing to secure
>  	 * its former mem_cgroup from sudden removal.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
