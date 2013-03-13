Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 0BFA46B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 04:08:01 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id j4so295145bkw.3
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 01:08:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1362489058-3455-4-git-send-email-glommer@parallels.com>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
	<1362489058-3455-4-git-send-email-glommer@parallels.com>
Date: Wed, 13 Mar 2013 16:08:00 +0800
Message-ID: <CAFj3OHU6f3o5GmbFyUsqtSWqHruSS4Yyodx=s=Vh8mO7GfTE8w@mail.gmail.com>
Subject: Re: [PATCH v2 3/5] memcg: make it suck faster
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On Tue, Mar 5, 2013 at 9:10 PM, Glauber Costa <glommer@parallels.com> wrote:
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
>
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
> +       return !!mem_cgroup_subsys.disabled;
> +}
> +
> +static inline bool mem_cgroup_disabled(void)
> +{
> +       /*
> +        * Will always be false if subsys is disabled, because we have no one
> +        * to bump it up. So the test suffices and we don't have to test the
> +        * subsystem as well
> +        */
> +       if (!static_key_false(&memcg_in_use_key))
> +               return true;
> +       return false;
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
>                                 gfp_t gfp_mask);
> +
> +static inline int
> +mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
> +                         gfp_t gfp_mask)
> +{
> +       if (mem_cgroup_disabled())
> +               return 0;
> +       return __mem_cgroup_newpage_charge(page, mm, gfp_mask);
> +}
> +
>  /* for swap handling */
>  extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
>                 struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
> @@ -62,8 +92,17 @@ extern void mem_cgroup_commit_charge_swapin(struct page *page,
>                                         struct mem_cgroup *memcg);
>  extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg);
>
> -extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> -                                       gfp_t gfp_mask);
> +
> +extern int __mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> +                                    gfp_t gfp_mask);
> +static inline int
> +mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm, gfp_t gfp_mask)
> +{
> +       if (mem_cgroup_disabled())
> +               return 0;
> +
> +       return __mem_cgroup_cache_charge(page, mm, gfp_mask);
> +}
>
>  struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
>  struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
> @@ -72,8 +111,24 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
>  extern void mem_cgroup_uncharge_start(void);
>  extern void mem_cgroup_uncharge_end(void);
>
> -extern void mem_cgroup_uncharge_page(struct page *page);
> -extern void mem_cgroup_uncharge_cache_page(struct page *page);
> +extern void __mem_cgroup_uncharge_page(struct page *page);
> +extern void __mem_cgroup_uncharge_cache_page(struct page *page);
> +
> +static inline void mem_cgroup_uncharge_page(struct page *page)
> +{
> +       if (mem_cgroup_disabled())
> +               return;
> +
> +       __mem_cgroup_uncharge_page(page);
> +}
> +
> +static inline void mem_cgroup_uncharge_cache_page(struct page *page)
> +{
> +       if (mem_cgroup_disabled())
> +               return;
> +
> +       __mem_cgroup_uncharge_cache_page(page);
> +}
>
>  bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>                                   struct mem_cgroup *memcg);
> @@ -128,13 +183,6 @@ extern void mem_cgroup_replace_page_cache(struct page *oldpage,
>  extern int do_swap_account;
>  #endif
>
> -static inline bool mem_cgroup_disabled(void)
> -{
> -       if (mem_cgroup_subsys.disabled)
> -               return true;
> -       return false;
> -}
> -
>  void __mem_cgroup_begin_update_page_stat(struct page *page, bool *locked,
>                                          unsigned long *flags);
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index bfbf1c2..45c1886 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -575,6 +575,9 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
>         return (memcg == root_mem_cgroup);
>  }
>
> +static bool memcg_charges_allowed = false;
> +struct static_key memcg_in_use_key;
> +
>  /* Writing them here to avoid exposing memcg's inner layout */
>  #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>
> @@ -710,6 +713,7 @@ static void disarm_static_keys(struct mem_cgroup *memcg)
>  {
>         disarm_sock_keys(memcg);
>         disarm_kmem_keys(memcg);
> +       static_key_slow_dec(&memcg_in_use_key);
>  }
>
>  static void drain_all_stock_async(struct mem_cgroup *memcg);
> @@ -1109,6 +1113,9 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>         if (unlikely(!p))
>                 return NULL;
>
> +       if (mem_cgroup_disabled())
> +               return root_mem_cgroup;
> +
>         return mem_cgroup_from_css(task_subsys_state(p, mem_cgroup_subsys_id));
>  }
>
> @@ -1157,9 +1164,12 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>         struct mem_cgroup *memcg = NULL;
>         int id = 0;
>
> -       if (mem_cgroup_disabled())
> +       if (mem_cgroup_subsys_disabled())
>                 return NULL;
>
> +       if (mem_cgroup_disabled())
> +               return root_mem_cgroup;
> +
>         if (!root)
>                 root = root_mem_cgroup;
>
> @@ -1335,6 +1345,20 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
>         memcg = pc->mem_cgroup;
>
>         /*
> +        * Because we lazily enable memcg only after first child group is
> +        * created, we can have memcg == 0. Because page cgroup is created with
> +        * GFP_ZERO, and after charging, all page cgroups will have a non-zero
> +        * cgroup attached (even if root), we can be sure that this is a
> +        * used-but-not-accounted page. (due to lazyness). We could get around
> +        * that by scanning all pages on cgroup init is too expensive. We can
> +        * ultimately pay, but prefer to just to defer the update until we get
> +        * here. We could take the opportunity to set PageCgroupUsed, but it
> +        * won't be that important for the root cgroup.
> +        */
> +       if (!memcg && PageLRU(page))
> +               pc->mem_cgroup = memcg = root_mem_cgroup;
> +
> +       /*
>          * Surreptitiously switch any uncharged offlist page to root:
>          * an uncharged page off lru does nothing to secure
>          * its former mem_cgroup from sudden removal.
> @@ -3845,11 +3869,18 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
>         return 0;
>  }
>
> -int mem_cgroup_newpage_charge(struct page *page,
> +int __mem_cgroup_newpage_charge(struct page *page,
>                               struct mm_struct *mm, gfp_t gfp_mask)
>  {
> -       if (mem_cgroup_disabled())
> +       /*
> +        * The branch is actually very likely before the first memcg comes in.
> +        * But since the code is patched out, we'll never reach it. It is only
> +        * reachable when the code is patched in, and in that case it is
> +        * unlikely.  It will only happen during initial charges move.
> +        */
> +       if (unlikely(!memcg_charges_allowed))
>                 return 0;
> +
>         VM_BUG_ON(page_mapped(page));
>         VM_BUG_ON(page->mapping && !PageAnon(page));
>         VM_BUG_ON(!mm);
> @@ -3962,15 +3993,13 @@ void mem_cgroup_commit_charge_swapin(struct page *page,
>                                           MEM_CGROUP_CHARGE_TYPE_ANON);
>  }
>
> -int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> -                               gfp_t gfp_mask)
> +int __mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
> +                             gfp_t gfp_mask)
>  {
>         struct mem_cgroup *memcg = NULL;
>         enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
>         int ret;
>
> -       if (mem_cgroup_disabled())
> -               return 0;
>         if (PageCompound(page))
>                 return 0;
>
> @@ -4050,9 +4079,6 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype,
>         struct page_cgroup *pc;
>         bool anon;
>
> -       if (mem_cgroup_disabled())
> -               return NULL;
> -
>         VM_BUG_ON(PageSwapCache(page));
>
>         if (PageTransHuge(page)) {
> @@ -4144,7 +4170,7 @@ unlock_out:
>         return NULL;
>  }
>
> -void mem_cgroup_uncharge_page(struct page *page)
> +void __mem_cgroup_uncharge_page(struct page *page)
>  {
>         /* early check. */
>         if (page_mapped(page))
> @@ -4155,7 +4181,7 @@ void mem_cgroup_uncharge_page(struct page *page)
>         __mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON, false);
>  }
>
> -void mem_cgroup_uncharge_cache_page(struct page *page)
> +void __mem_cgroup_uncharge_cache_page(struct page *page)
>  {
>         VM_BUG_ON(page_mapped(page));
>         VM_BUG_ON(page->mapping);
> @@ -4220,6 +4246,9 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
>         struct mem_cgroup *memcg;
>         int ctype = MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
>
> +       if (mem_cgroup_disabled())
> +               return;
> +
>         if (!swapout) /* this was a swap cache but the swap is unused ! */
>                 ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
>
> @@ -6364,6 +6393,59 @@ free_out:
>         return ERR_PTR(error);
>  }
>
> +static void memcg_update_root_statistics(void)
> +{
> +       int cpu;
> +       u64 pgin, pgout, faults, mjfaults;
> +
> +       pgin = pgout = faults = mjfaults = 0;
> +       for_each_online_cpu(cpu) {
> +               struct vm_event_state *ev = &per_cpu(vm_event_states, cpu);
> +               struct mem_cgroup_stat_cpu *memcg_stat;
> +
> +               memcg_stat = per_cpu_ptr(root_mem_cgroup->stat, cpu);
> +
> +               memcg_stat->events[MEM_CGROUP_EVENTS_PGPGIN] =
> +                                                       ev->event[PGPGIN];
> +               memcg_stat->events[MEM_CGROUP_EVENTS_PGPGOUT] =
> +                                                       ev->event[PGPGOUT];

ev->event[PGPGIN/PGPGOUT] is counted in block layer(submit_bio()) and
represents the exactly number of pagein/pageout, but memcg
PGPGIN/PGPGOUT events only count it as an event and ignore the page
size. So here we can't straightforward take the ev->events for use.

> +               memcg_stat->events[MEM_CGROUP_EVENTS_PGFAULT] =
> +                                                       ev->event[PGFAULT];
> +               memcg_stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT] =
> +                                                       ev->event[PGMAJFAULT];
> +
> +               memcg_stat->nr_page_events = ev->event[PGPGIN] +
> +                                            ev->event[PGPGOUT];

There's no valid memcg->nr_page_events until now, so the threshold
notifier, but some people may use it even only root memcg exists.
Moreover, using PGPGIN + PGPGOUT(exactly number of pagein + pageout)
as nr_page_events is also inaccurate IMHO.

> +       }
> +
> +       root_mem_cgroup->nocpu_base.count[MEM_CGROUP_STAT_RSS] =
> +                               memcg_read_root_rss();
> +       root_mem_cgroup->nocpu_base.count[MEM_CGROUP_STAT_CACHE] =
> +                               atomic_long_read(&vm_stat[NR_FILE_PAGES]);
> +       root_mem_cgroup->nocpu_base.count[MEM_CGROUP_STAT_FILE_MAPPED] =
> +                               atomic_long_read(&vm_stat[NR_FILE_MAPPED]);
> +}
> +
> +static void memcg_update_root_lru(void)
> +{
> +       struct zone *zone;
> +       struct lruvec *lruvec;
> +       struct mem_cgroup_per_zone *mz;
> +       enum lru_list lru;
> +
> +       for_each_populated_zone(zone) {
> +               spin_lock_irq(&zone->lru_lock);
> +               lruvec = &zone->lruvec;
> +               mz = mem_cgroup_zoneinfo(root_mem_cgroup,
> +                               zone_to_nid(zone), zone_idx(zone));
> +
> +               for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
> +                       mz->lru_size[lru] =
> +                               zone_page_state(zone, NR_LRU_BASE + lru);
> +               spin_unlock_irq(&zone->lru_lock);
> +       }
> +}
> +
>  static int
>  mem_cgroup_css_online(struct cgroup *cont)
>  {
> @@ -6407,6 +6489,66 @@ mem_cgroup_css_online(struct cgroup *cont)
>         }
>
>         error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
> +
> +       if (!error) {
> +               static_key_slow_inc(&memcg_in_use_key);
> +               /*
> +                * The strategy to avoid races here is to let the charges just
> +                * be globally made until we lock the res counter. Since we are
> +                * copying charges from global statistics, it doesn't really
> +                * matter when we do it, as long as we are consistent. So even
> +                * after the code is patched in, they will continue being
> +                * globally charged due to memcg_charges_allowed being set to
> +                * false.
> +                *
> +                * Once we hold the res counter lock, though, we can already
> +                * safely flip it: We will go through with the charging to the
> +                * root memcg, but won't be able to actually charge it: we have
> +                * the lock.
> +                *
> +                * This works because the mm stats are only updated after the
> +                * memcg charging suceeds. If we block the charge by holding
> +                * the res_counter lock, no other charges will happen in the
> +                * system until we release it.
> +                *
> +                * manipulation always safe because the write side is always
> +                * under the memcg_mutex.
> +                */
> +               if (!memcg_charges_allowed) {
> +                       struct zone *zone;
> +
> +                       get_online_cpus();
> +                       spin_lock(&root_mem_cgroup->res.lock);
> +
> +                       memcg_charges_allowed = true;
> +
> +                       root_mem_cgroup->res.usage =
> +                               mem_cgroup_read_root(RES_USAGE, _MEM);
> +                       root_mem_cgroup->memsw.usage =
> +                               mem_cgroup_read_root(RES_USAGE, _MEMSWAP);
> +                       /*
> +                        * The max usage figure is not entirely accurate. The
> +                        * memory may have been higher in the past. But since
> +                        * we don't track that globally, this is the best we
> +                        * can do.
> +                        */
> +                       root_mem_cgroup->res.max_usage =
> +                                       root_mem_cgroup->res.usage;
> +                       root_mem_cgroup->memsw.max_usage =
> +                                       root_mem_cgroup->memsw.usage;
> +
> +                       memcg_update_root_statistics();
> +                       memcg_update_root_lru();
> +                       /*
> +                        * We are now 100 % consistent and all charges are
> +                        * transfered.  New charges should reach the
> +                        * res_counter directly.
> +                        */
> +                       spin_unlock(&root_mem_cgroup->res.lock);
> +                       put_online_cpus();
> +               }
> +       }
> +
>         mutex_unlock(&memcg_create_mutex);
>         if (error) {
>                 /*
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 6d757e3..a5bd322 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -68,7 +68,7 @@ void __init page_cgroup_init_flatmem(void)
>
>         int nid, fail;
>
> -       if (mem_cgroup_disabled())
> +       if (mem_cgroup_subsys_disabled())
>                 return;
>
>         for_each_online_node(nid)  {
> @@ -271,7 +271,7 @@ void __init page_cgroup_init(void)
>         unsigned long pfn;
>         int nid;
>
> -       if (mem_cgroup_disabled())
> +       if (mem_cgroup_subsys_disabled())
>                 return;
>
>         for_each_node_state(nid, N_MEMORY) {
> --
> 1.8.1.2
>



-- 
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
