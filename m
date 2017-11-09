Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 59A50440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 10:34:55 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a20so3410814wrc.1
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 07:34:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a72sor1966686wme.42.2017.11.09.07.34.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 07:34:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2940c150-577a-30a8-fac3-cf59a49b84b4@I-love.SAKURA.ne.jp>
References: <20171108173740.115166-1-shakeelb@google.com> <2940c150-577a-30a8-fac3-cf59a49b84b4@I-love.SAKURA.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 9 Nov 2017 07:34:51 -0800
Message-ID: <CALvZod5NVQO+dWKD0y4pK-JYXdehLLgKm0bfc7ExPzyRLDeqzw@mail.gmail.com>
Subject: Re: [PATCH v2] mm, shrinker: make shrinker_list lockless
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

>
> If you can accept serialized register_shrinker()/unregister_shrinker(),
> I think that something like shown below can do it.
>

Thanks.

> ----------
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 388ff29..e2272dd 100644
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
> +       atomic_t nr_active; /* Counted only if !SHRINKER_PERMANENT */
>         struct list_head list;
>         /* objs pending delete, per node */
>         atomic_long_t *nr_deferred;
> @@ -74,6 +75,7 @@ struct shrinker {
>  /* Flags */
>  #define SHRINKER_NUMA_AWARE    (1 << 0)
>  #define SHRINKER_MEMCG_AWARE   (1 << 1)
> +#define SHRINKER_PERMANENT     (1 << 2)
>
>  extern int register_shrinker(struct shrinker *);
>  extern void unregister_shrinker(struct shrinker *);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1c1bc95..e963359 100644
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
> @@ -297,9 +298,14 @@ int register_shrinker(struct shrinker *shrinker)
>   */
>  void unregister_shrinker(struct shrinker *shrinker)
>  {
> -       down_write(&shrinker_rwsem);
> -       list_del(&shrinker->list);
> -       up_write(&shrinker_rwsem);
> +       BUG_ON(shrinker->flags & SHRINKER_PERMANENT);
> +       mutex_lock(&shrinker_lock);
> +       list_del_rcu(&shrinker->list);
> +       synchronize_rcu();
> +       while (atomic_read(&shrinker->nr_active))
> +               msleep(1);

If we assume that we will never do register_shrinker and
unregister_shrinker on the same object in parallel then do we still
need to do msleep & synchronize_rcu() within mutex?

> +       synchronize_rcu();

I was hoping to not put any delay for the normal case (no memory
pressure and no reclaimers).

> +       mutex_unlock(&shrinker_lock);
>         kfree(shrinker->nr_deferred);
>  }
>  EXPORT_SYMBOL(unregister_shrinker);
> @@ -468,18 +474,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
> +               bool permanent;
>                 struct shrink_control sc = {
>                         .gfp_mask = gfp_mask,
>                         .nid = nid,
> @@ -498,11 +495,16 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>                 if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>                         sc.nid = 0;
>
> +               permanent = (shrinker->flags & SHRINKER_PERMANENT);
> +               if (!permanent)
> +                       atomic_inc(&shrinker->nr_active);
> +               rcu_read_unlock();
>                 freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> +               rcu_read_lock();
> +               if (!permanent)
> +                       atomic_dec(&shrinker->nr_active);
>         }
> -
> -       up_read(&shrinker_rwsem);
> -out:
> +       rcu_read_unlock();
>         cond_resched();
>         return freed;
>  }
> ----------
>
> If you want parallel register_shrinker()/unregister_shrinker(), something like
> shown below on top of shown above will do it.
>
> ----------
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index e2272dd..471b2f6 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -67,6 +67,7 @@ struct shrinker {
>         /* These are for internal use */
>         atomic_t nr_active; /* Counted only if !SHRINKER_PERMANENT */
>         struct list_head list;
> +       struct list_head gc_list;
>         /* objs pending delete, per node */
>         atomic_long_t *nr_deferred;
>  };
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e963359..a216dc5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -157,7 +157,7 @@ struct scan_control {
>  unsigned long vm_total_pages;
>
>  static LIST_HEAD(shrinker_list);
> -static DEFINE_MUTEX(shrinker_lock);
> +static DEFINE_SPINLOCK(shrinker_lock);
>
>  #ifdef CONFIG_MEMCG
>  static bool global_reclaim(struct scan_control *sc)
> @@ -286,9 +286,9 @@ int register_shrinker(struct shrinker *shrinker)
>                 return -ENOMEM;
>
>         atomic_set(&shrinker->nr_active, 0);
> -       mutex_lock(&shrinker_lock);
> +       spin_lock(&shrinker_lock);
>         list_add_tail_rcu(&shrinker->list, &shrinker_list);
> -       mutex_unlock(&shrinker_lock);
> +       spin_unlock(&shrinker_lock);
>         return 0;
>  }
>  EXPORT_SYMBOL(register_shrinker);
> @@ -298,15 +298,30 @@ int register_shrinker(struct shrinker *shrinker)
>   */
>  void unregister_shrinker(struct shrinker *shrinker)
>  {
> +       static LIST_HEAD(shrinker_gc_list);
> +       struct shrinker *gc;
> +
>         BUG_ON(shrinker->flags & SHRINKER_PERMANENT);
> -       mutex_lock(&shrinker_lock);
> +       spin_lock(&shrinker_lock);
>         list_del_rcu(&shrinker->list);
> +       /*
> +        * Need to update ->list.next if concurrently unregistering shrinkers
> +        * can find this shrinker, for this shrinker's unregistration might
> +        * complete before their unregistrations complete.
> +        */
> +       list_for_each_entry(gc, &shrinker_gc_list, gc_list) {
> +               if (gc->list.next == &shrinker->list)
> +                       rcu_assign_pointer(gc->list.next, shrinker->list.next);
> +       }
> +       list_add_tail(&shrinker->gc_list, &shrinker_gc_list);
> +       spin_unlock(&shrinker_lock);
>         synchronize_rcu();
>         while (atomic_read(&shrinker->nr_active))
>                 msleep(1);
>         synchronize_rcu();
> -       mutex_unlock(&shrinker_lock);
> +       spin_lock(&shrinker_lock);
> +       list_del(&shrinker->gc_list);
> +       spin_unlock(&shrinker_lock);
>         kfree(shrinker->nr_deferred);
>  }
>  EXPORT_SYMBOL(unregister_shrinker);
> ----------
>
> F.Y.I. When I posted above change at
> http://lkml.kernel.org/r/201411231350.DHI12456.OLOFFJSFtQVMHO@I-love.SAKURA.ne.jp ,
> Michal Hocko commented like below.
>
>   I thought that {un}register_shrinker are really unlikely
>   paths called during initialization and tear down which usually do not
>   happen during OOM conditions.
>
>   I cannot judge the patch itself as this is out of my area but is the
>   complexity worth it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
