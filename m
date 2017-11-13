Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 380A26B0253
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 17:05:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id l188so3961338wma.0
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 14:05:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n23sor1487604wra.8.2017.11.13.14.05.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Nov 2017 14:05:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 13 Nov 2017 14:05:34 -0800
Message-ID: <CALvZod5RgJrWgsy=14qBpDRLOad3WD8_fPrG5nFjkTQ4rL3rsQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 13, 2017 at 1:37 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> When shrinker_rwsem was introduced, it was assumed that
> register_shrinker()/unregister_shrinker() are really unlikely paths
> which are called during initialization and tear down. But nowadays,
> register_shrinker()/unregister_shrinker() might be called regularly.
> This patch prepares for allowing parallel registration/unregistration
> of shrinkers.
>
> Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
> using one RCU section. But using atomic_inc()/atomic_dec() for each
> do_shrink_slab() call will not impact so much.
>
> This patch uses polling loop with short sleep for unregister_shrinker()
> rather than wait_on_atomic_t(), for we can save reader's cost (plain
> atomic_dec() compared to atomic_dec_and_test()), we can expect that
> do_shrink_slab() of unregistering shrinker likely returns shortly, and
> we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
> shrinker unexpectedly took so long.
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Reviewed-and-tested-by: Shakeel Butt <shakeelb@google.com>

> ---
>  include/linux/shrinker.h |  3 ++-
>  mm/vmscan.c              | 41 +++++++++++++++++++----------------------
>  2 files changed, 21 insertions(+), 23 deletions(-)
>
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 388ff29..333a1d0 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -62,9 +62,10 @@ struct shrinker {
>
>         int seeks;      /* seeks to recreate an obj */
>         long batch;     /* reclaim batch size, 0 = default */
> -       unsigned long flags;
> +       unsigned int flags;
>
>         /* These are for internal use */
> +       atomic_t nr_active;
>         struct list_head list;
>         /* objs pending delete, per node */
>         atomic_long_t *nr_deferred;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1c1bc95..c8996e8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -157,7 +157,7 @@ struct scan_control {
>  unsigned long vm_total_pages;
>
>  static LIST_HEAD(shrinker_list);
> -static DECLARE_RWSEM(shrinker_rwsem);
> +static DEFINE_MUTEX(shrinker_lock);
>
>  #ifdef CONFIG_MEMCG
>  static bool global_reclaim(struct scan_control *sc)
> @@ -285,9 +285,10 @@ int register_shrinker(struct shrinker *shrinker)
>         if (!shrinker->nr_deferred)
>                 return -ENOMEM;
>
> -       down_write(&shrinker_rwsem);
> -       list_add_tail(&shrinker->list, &shrinker_list);
> -       up_write(&shrinker_rwsem);
> +       atomic_set(&shrinker->nr_active, 0);
> +       mutex_lock(&shrinker_lock);
> +       list_add_tail_rcu(&shrinker->list, &shrinker_list);
> +       mutex_unlock(&shrinker_lock);
>         return 0;
>  }
>  EXPORT_SYMBOL(register_shrinker);
> @@ -297,9 +298,13 @@ int register_shrinker(struct shrinker *shrinker)
>   */
>  void unregister_shrinker(struct shrinker *shrinker)
>  {
> -       down_write(&shrinker_rwsem);
> -       list_del(&shrinker->list);
> -       up_write(&shrinker_rwsem);
> +       mutex_lock(&shrinker_lock);
> +       list_del_rcu(&shrinker->list);
> +       synchronize_rcu();
> +       while (atomic_read(&shrinker->nr_active))
> +               schedule_timeout_uninterruptible(1);
> +       synchronize_rcu();
> +       mutex_unlock(&shrinker_lock);
>         kfree(shrinker->nr_deferred);
>  }
>  EXPORT_SYMBOL(unregister_shrinker);
> @@ -468,18 +473,8 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>         if (nr_scanned == 0)
>                 nr_scanned = SWAP_CLUSTER_MAX;
>
> -       if (!down_read_trylock(&shrinker_rwsem)) {
> -               /*
> -                * If we would return 0, our callers would understand that we
> -                * have nothing else to shrink and give up trying. By returning
> -                * 1 we keep it going and assume we'll be able to shrink next
> -                * time.
> -                */
> -               freed = 1;
> -               goto out;
> -       }
> -
> -       list_for_each_entry(shrinker, &shrinker_list, list) {
> +       rcu_read_lock();
> +       list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
>                 struct shrink_control sc = {
>                         .gfp_mask = gfp_mask,
>                         .nid = nid,
> @@ -498,11 +493,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>                 if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>                         sc.nid = 0;
>
> +               atomic_inc(&shrinker->nr_active);
> +               rcu_read_unlock();
>                 freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> +               rcu_read_lock();
> +               atomic_dec(&shrinker->nr_active);
>         }
> -
> -       up_read(&shrinker_rwsem);
> -out:
> +       rcu_read_unlock();
>         cond_resched();
>         return freed;
>  }
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
