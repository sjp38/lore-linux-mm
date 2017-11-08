Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6256B02D8
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 20:23:26 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o60so542167wrc.14
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 17:23:26 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 31sor1165607wri.79.2017.11.07.17.23.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 17:23:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171107230509.136592-1-shakeelb@google.com>
References: <20171107230509.136592-1-shakeelb@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 7 Nov 2017 17:23:22 -0800
Message-ID: <CALvZod6vf6=teKyt63yNW2M2ZUiO+LRPasmrANgXJCCU-7wBNg@mail.gmail.com>
Subject: Re: [PATCH] mm, shrinker: make shrinker_list lockless
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>

>         if (next_deferred >= scanned)
> @@ -468,18 +487,9 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
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
> +       rcu_read_lock();

Sorry, the rcu_read_lock() will not work. I am currently testing with
srcu_read_lock() and see if it gives any error.

>
> -       list_for_each_entry(shrinker, &shrinker_list, list) {
> +       list_for_each_entry_rcu(shrinker, &shrinker_list, list) {
>                 struct shrink_control sc = {
>                         .gfp_mask = gfp_mask,
>                         .nid = nid,
> @@ -498,11 +508,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>                 if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>                         sc.nid = 0;
>
> +               get_shrinker(shrinker);
>                 freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> +               put_shrinker(shrinker);
>         }
>
> -       up_read(&shrinker_rwsem);
> -out:
> +       rcu_read_unlock();
> +
>         cond_resched();
>         return freed;
>  }
> --
> 2.15.0.403.gc27cc4dac6-goog
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
