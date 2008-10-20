Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id m9KJs0Mc010318
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 20:54:01 +0100
Received: from qw-out-2122.google.com (qwe3.prod.google.com [10.241.194.3])
	by wpaz21.hot.corp.google.com with ESMTP id m9KJrwnT029551
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 12:53:59 -0700
Received: by qw-out-2122.google.com with SMTP id 3so597277qwe.43
        for <linux-mm@kvack.org>; Mon, 20 Oct 2008 12:53:58 -0700 (PDT)
Message-ID: <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
Date: Mon, 20 Oct 2008 12:53:58 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
In-Reply-To: <20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	 <20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Can't we do this in a more generic way, rather than duplicating a lot
of functionality from res_counter?

You're trying to track:

- mem usage
- mem limit
- swap usage
- swap+mem usage
- swap+mem limit

And ensuring that:

- mem usage < mem limit
- swap+mem usage < swap+mem limit

Could we somehow represent this as a pair of resource counters, one
for mem and one for swap+mem that are linked together?

Maybe have an "aggregate" pointer in a res_counter that points to
another res_counter that sums some number of counters; both the mem
and the swap res_counter objects for a cgroup would point to the
mem+swap res_counter for their aggregate. Adjusting the usage of a
counter would also adjust its aggregate (or fail if adjusting the
aggregate failed).

You could potentially use the same mechanism for aggregation across a
parent/child tree as for aggregation across different resources (mem +
swap).

The upside would be that we wouldn't need special res_counter code for
the memory controller, and any other resource controller that wanted
to do aggregation would get it for free.

The downside would be that we'd have to take two locks rather than one
(one for the main counter and one for the aggregate counter) but I
don't think that would have to be a performance hit - since these
locks would tend to be taken together anyway, we can do a
spin_lock_prefetch() on the aggregate lock before we spin on the main
lock, and the aggregate lock should be in cache by the time we get the
main lock (it's most likely that either both were already in cache, or
neither were).

Paul

On Fri, Oct 17, 2008 at 3:56 AM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> For mem+swap controller, we'll use special counter which has 2 values and
> 2 limit. Before doing that, replace current res_counter with new mem_counter.
>
> This patch doen't have much meaning other than for clean up before mem+swap
> controller. New mem_counter's counter is "unsigned long" and account resource by
> # of pages. (I think "unsigned long" is safe under 32bit machines when we count
> resource by # of pages rather than bytes.) No changes in user interface.
> User interface is in "bytes".
>
> Using "unsigned long long", we have to be nervous to read to temporal value
> without lock.
>
> Changelog: v2 -> v3
>  - fix trivial bugs
>  - rebased on memcg-update-v7
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d5b492f..e1c20d2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -17,10 +17,9 @@
>  * GNU General Public License for more details.
>  */
>
> -#include <linux/res_counter.h>
> +#include <linux/mm.h>
>  #include <linux/memcontrol.h>
>  #include <linux/cgroup.h>
> -#include <linux/mm.h>
>  #include <linux/smp.h>
>  #include <linux/page-flags.h>
>  #include <linux/backing-dev.h>
> @@ -116,12 +115,21 @@ struct mem_cgroup_lru_info {
>  * no reclaim occurs from a cgroup at it's low water mark, this is
>  * a feature that will be implemented much later in the future.
>  */
> +struct mem_counter {
> +       unsigned long   pages;
> +       unsigned long   pages_limit;
> +       unsigned long   max_pages;
> +       unsigned long   failcnt;
> +       spinlock_t      lock;
> +};
> +
> +
>  struct mem_cgroup {
>        struct cgroup_subsys_state css;
>        /*
>         * the counter to account for memory usage
>         */
> -       struct res_counter res;
> +       struct mem_counter res;
>        /*
>         * Per cgroup active and inactive list, similar to the
>         * per zone LRU lists.
> @@ -158,6 +166,14 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
>        0, /* FORCE */
>  };
>
> +/* Private File ID for memory resource controller's interface */
> +enum {
> +       MEMCG_FILE_PAGE_LIMIT,
> +       MEMCG_FILE_PAGE_USAGE,
> +       MEMCG_FILE_PAGE_MAX_USAGE,
> +       MEMCG_FILE_FAILCNT,
> +};
> +
>  /*
>  * Always modified under lru lock. Then, not necessary to preempt_disable()
>  */
> @@ -237,6 +253,81 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>                                struct mem_cgroup, css);
>  }
>
> +/*
> + * counter for memory resource accounting.
> + */
> +static void mem_counter_init(struct mem_cgroup *mem)
> +{
> +       memset(&mem->res, 0, sizeof(mem->res));
> +       mem->res.pages_limit = ~0UL;
> +       spin_lock_init(&mem->res.lock);
> +}
> +
> +static int mem_counter_charge(struct mem_cgroup *mem, long num)
> +{
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&mem->res.lock, flags);
> +       if (mem->res.pages + num > mem->res.pages_limit)
> +               goto busy_out;
> +       mem->res.pages += num;
> +       if (mem->res.pages > mem->res.max_pages)
> +               mem->res.max_pages = mem->res.pages;
> +       spin_unlock_irqrestore(&mem->res.lock, flags);
> +       return 0;
> +busy_out:
> +       mem->res.failcnt++;
> +       spin_unlock_irqrestore(&mem->res.lock, flags);
> +       return -EBUSY;
> +}
> +
> +static void mem_counter_uncharge_page(struct mem_cgroup *mem, long num)
> +{
> +       unsigned long flags;
> +       spin_lock_irqsave(&mem->res.lock, flags);
> +       mem->res.pages -= num;
> +       spin_unlock_irqrestore(&mem->res.lock, flags);
> +}
> +
> +static int mem_counter_set_pages_limit(struct mem_cgroup *mem,
> +                                       unsigned long num)
> +{
> +       unsigned long flags;
> +       int ret = -EBUSY;
> +
> +       spin_lock_irqsave(&mem->res.lock, flags);
> +       if (mem->res.pages < num) {
> +               mem->res.pages_limit = num;
> +               ret = 0;
> +       }
> +       spin_unlock_irqrestore(&mem->res.lock, flags);
> +       return ret;
> +}
> +
> +static int mem_counter_check_under_pages_limit(struct mem_cgroup *mem)
> +{
> +       if (mem->res.pages < mem->res.pages_limit)
> +               return 1;
> +       return 0;
> +}
> +
> +static void mem_counter_reset(struct mem_cgroup *mem, int member)
> +{
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&mem->res.lock, flags);
> +       switch (member) {
> +       case MEMCG_FILE_PAGE_MAX_USAGE:
> +               mem->res.max_pages = 0;
> +               break;
> +       case MEMCG_FILE_FAILCNT:
> +               mem->res.failcnt = 0;
> +               break;
> +       }
> +       spin_unlock_irqrestore(&mem->res.lock, flags);
> +}
> +
> +
>  static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
>                        struct page_cgroup *pc)
>  {
> @@ -368,7 +459,7 @@ int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
>         * usage is recorded in bytes. But, here, we assume the number of
>         * physical pages can be represented by "long" on any arch.
>         */
> -       total = (long) (mem->res.usage >> PAGE_SHIFT) + 1L;
> +       total = (long) (mem->res.pages) + 1L;
>        rss = (long)mem_cgroup_read_stat(&mem->stat, MEM_CGROUP_STAT_RSS);
>        return (int)((rss * 100L) / total);
>  }
> @@ -692,7 +783,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>        }
>
>
> -       while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
> +       while (unlikely(mem_counter_charge(mem, 1))) {
>                if (!(gfp_mask & __GFP_WAIT))
>                        goto nomem;
>
> @@ -706,7 +797,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>                 * Check the limit again to see if the reclaim reduced the
>                 * current usage of the cgroup before giving up
>                 */
> -               if (res_counter_check_under_limit(&mem->res))
> +               if (mem_counter_check_under_pages_limit(mem))
>                        continue;
>
>                if (!nr_retries--) {
> @@ -760,7 +851,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>         */
>        if (unlikely(PageCgroupUsed(pc))) {
>                unlock_page_cgroup(pc);
> -               res_counter_uncharge(&mem->res, PAGE_SIZE);
> +               mem_counter_uncharge_page(mem, 1);
>                css_put(&mem->css);
>                return;
>        }
> @@ -841,7 +932,7 @@ static int mem_cgroup_move_account(struct page_cgroup *pc,
>
>        if (spin_trylock(&to_mz->lru_lock)) {
>                __mem_cgroup_remove_list(from_mz, pc);
> -               res_counter_uncharge(&from->res, PAGE_SIZE);
> +               mem_counter_uncharge_page(from, PAGE_SIZE);
>                pc->mem_cgroup = to;
>                __mem_cgroup_add_list(to_mz, pc, false);
>                ret = 0;
> @@ -888,7 +979,7 @@ static int mem_cgroup_move_parent(struct page_cgroup *pc,
>        css_put(&parent->css);
>        /* uncharge if move fails */
>        if (ret)
> -               res_counter_uncharge(&parent->res, PAGE_SIZE);
> +               mem_counter_uncharge_page(parent, 1);
>
>        return ret;
>  }
> @@ -1005,7 +1096,7 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
>                return;
>        if (!mem)
>                return;
> -       res_counter_uncharge(&mem->res, PAGE_SIZE);
> +       mem_counter_uncharge_page(mem, 1);
>        css_put(&mem->css);
>  }
>
> @@ -1042,7 +1133,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>         * We must uncharge here because "reuse" can occur just after we
>         * unlock this.
>         */
> -       res_counter_uncharge(&mem->res, PAGE_SIZE);
> +       mem_counter_uncharge_page(mem, 1);
>        unlock_page_cgroup(pc);
>        release_page_cgroup(pc);
>        return;
> @@ -1174,7 +1265,7 @@ int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)
>
>        do {
>                progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
> -               progress += res_counter_check_under_limit(&mem->res);
> +               progress += mem_counter_check_under_pages_limit(mem);
>        } while (!progress && --retry);
>
>        css_put(&mem->css);
> @@ -1189,8 +1280,12 @@ int mem_cgroup_resize_limit(struct mem_cgroup *memcg, unsigned long long val)
>        int retry_count = MEM_CGROUP_RECLAIM_RETRIES;
>        int progress;
>        int ret = 0;
> +       unsigned long new_lim = (unsigned long)(val >> PAGE_SHIFT);
>
> -       while (res_counter_set_limit(&memcg->res, val)) {
> +       if (val & (PAGE_SIZE-1))
> +               new_lim += 1;
> +
> +       while (mem_counter_set_pages_limit(memcg, new_lim)) {
>                if (signal_pending(current)) {
>                        ret = -EINTR;
>                        break;
> @@ -1273,7 +1368,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *mem)
>
>        shrink = 0;
>  move_account:
> -       while (mem->res.usage > 0) {
> +       while (mem->res.pages > 0) {
>                ret = -EBUSY;
>                if (atomic_read(&mem->css.cgroup->count) > 0)
>                        goto out;
> @@ -1316,7 +1411,7 @@ try_to_free:
>        }
>        /* try to free all pages in this cgroup */
>        shrink = 1;
> -       while (nr_retries && mem->res.usage > 0) {
> +       while (nr_retries && mem->res.pages > 0) {
>                int progress;
>                progress = try_to_free_mem_cgroup_pages(mem,
>                                                  GFP_HIGHUSER_MOVABLE);
> @@ -1325,7 +1420,7 @@ try_to_free:
>
>        }
>        /* try move_account...there may be some *locked* pages. */
> -       if (mem->res.usage)
> +       if (mem->res.pages)
>                goto move_account;
>        ret = 0;
>        goto out;
> @@ -1333,13 +1428,43 @@ try_to_free:
>
>  static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  {
> -       return res_counter_read_u64(&mem_cgroup_from_cont(cont)->res,
> -                                   cft->private);
> +       unsigned long long ret;
> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +
> +       switch (cft->private) {
> +       case MEMCG_FILE_PAGE_LIMIT:
> +               ret = (unsigned long long)mem->res.pages_limit << PAGE_SHIFT;
> +               break;
> +       case MEMCG_FILE_PAGE_USAGE:
> +               ret = (unsigned long long)mem->res.pages << PAGE_SHIFT;
> +               break;
> +       case MEMCG_FILE_PAGE_MAX_USAGE:
> +               ret = (unsigned long long)mem->res.max_pages << PAGE_SHIFT;
> +               break;
> +       case MEMCG_FILE_FAILCNT:
> +               ret = (unsigned long long)mem->res.failcnt;
> +               break;
> +       default:
> +               BUG();
> +       }
> +       return ret;
>  }
>  /*
>  * The user of this function is...
>  * RES_LIMIT.
>  */
> +static int call_memparse(const char *buf, unsigned long long *val)
> +{
> +       char *end;
> +
> +       *val = memparse((char *)buf, &end);
> +       if (*end != '\0')
> +               return -EINVAL;
> +       *val = PAGE_ALIGN(*val);
> +       return 0;
> +}
> +
> +
>  static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>                            const char *buffer)
>  {
> @@ -1348,9 +1473,9 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>        int ret;
>
>        switch (cft->private) {
> -       case RES_LIMIT:
> +       case MEMCG_FILE_PAGE_LIMIT:
>                /* This function does all necessary parse...reuse it */
> -               ret = res_counter_memparse_write_strategy(buffer, &val);
> +               ret = call_memparse(buffer, &val);
>                if (!ret)
>                        ret = mem_cgroup_resize_limit(memcg, val);
>                break;
> @@ -1367,12 +1492,12 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
>
>        mem = mem_cgroup_from_cont(cont);
>        switch (event) {
> -       case RES_MAX_USAGE:
> -               res_counter_reset_max(&mem->res);
> -               break;
> -       case RES_FAILCNT:
> -               res_counter_reset_failcnt(&mem->res);
> +       case MEMCG_FILE_PAGE_MAX_USAGE:
> +       case MEMCG_FILE_FAILCNT:
> +               mem_counter_reset(mem, event);
>                break;
> +       default:
> +               BUG();
>        }
>        return 0;
>  }
> @@ -1436,24 +1561,24 @@ static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
>  static struct cftype mem_cgroup_files[] = {
>        {
>                .name = "usage_in_bytes",
> -               .private = RES_USAGE,
> +               .private = MEMCG_FILE_PAGE_USAGE,
>                .read_u64 = mem_cgroup_read,
>        },
>        {
>                .name = "max_usage_in_bytes",
> -               .private = RES_MAX_USAGE,
> +               .private = MEMCG_FILE_PAGE_MAX_USAGE,
>                .trigger = mem_cgroup_reset,
>                .read_u64 = mem_cgroup_read,
>        },
>        {
>                .name = "limit_in_bytes",
> -               .private = RES_LIMIT,
> +               .private = MEMCG_FILE_PAGE_LIMIT,
>                .write_string = mem_cgroup_write,
>                .read_u64 = mem_cgroup_read,
>        },
>        {
>                .name = "failcnt",
> -               .private = RES_FAILCNT,
> +               .private = MEMCG_FILE_FAILCNT,
>                .trigger = mem_cgroup_reset,
>                .read_u64 = mem_cgroup_read,
>        },
> @@ -1578,7 +1703,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>                        return ERR_PTR(-ENOMEM);
>        }
>
> -       res_counter_init(&mem->res);
> +       mem_counter_init(mem);
>
>        for_each_node_state(node, N_POSSIBLE)
>                if (alloc_mem_cgroup_per_zone_info(mem, node))
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
