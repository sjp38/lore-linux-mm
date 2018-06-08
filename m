Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBC4C6B0008
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 15:21:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 44-v6so8146751wrt.9
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 12:21:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15-v6sor16622097wrp.61.2018.06.08.12.21.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 12:21:22 -0700 (PDT)
MIME-Version: 1.0
References: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
 <152698379298.3393.3040399931339145602.stgit@localhost.localdomain>
In-Reply-To: <152698379298.3393.3040399931339145602.stgit@localhost.localdomain>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 8 Jun 2018 12:21:10 -0700
Message-ID: <CALvZod4zzw0f_q4a1HpMHWjhjfK9OcegRkAQb5ZSyfjAYpAfJw@mail.gmail.com>
Subject: Re: [PATCH v7 15/17] mm: Generalize shrink_slab() calls in shrink_node()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, stummala@codeaurora.org, gregkh@linuxfoundation.org, Stephen Rothwell <sfr@canb.auug.org.au>, Roman Gushchin <guro@fb.com>, mka@chromium.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Chris Wilson <chris@chris-wilson.co.uk>, longman@redhat.com, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, jbacik@fb.com, Guenter Roeck <linux@roeck-us.net>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, lirongqing@baidu.com, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Tue, May 22, 2018 at 3:09 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> From: Vladimir Davydov <vdavydov.dev@gmail.com>
>
> The patch makes shrink_slab() be called for root_mem_cgroup
> in the same way as it's called for the rest of cgroups.
> This simplifies the logic and improves the readability.
>
> Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
> ktkhai: Description written.
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  mm/vmscan.c |   21 ++++++---------------
>  1 file changed, 6 insertions(+), 15 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f26ca1e00efb..6dbc659db120 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -628,10 +628,8 @@ static unsigned long shrink_slab_memcg(gfp_t gfp_mask, int nid,
>   * @nid is passed along to shrinkers with SHRINKER_NUMA_AWARE set,
>   * unaware shrinkers will receive a node id of 0 instead.
>   *
> - * @memcg specifies the memory cgroup to target. If it is not NULL,
> - * only shrinkers with SHRINKER_MEMCG_AWARE set will be called to scan
> - * objects from the memory cgroup specified. Otherwise, only unaware
> - * shrinkers are called.
> + * @memcg specifies the memory cgroup to target. Unaware shrinkers
> + * are called only if it is the root cgroup.
>   *
>   * @priority is sc->priority, we take the number of objects and >> by priority
>   * in order to get the scan target.
> @@ -645,7 +643,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>         struct shrinker *shrinker;
>         unsigned long freed = 0;
>

Shouldn't there be a VM_BUG_ON(!memcg) here?

> -       if (memcg && !mem_cgroup_is_root(memcg))
> +       if (!mem_cgroup_is_root(memcg))
>                 return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>
>         if (!down_read_trylock(&shrinker_rwsem))
> @@ -658,9 +656,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>                         .memcg = memcg,
>                 };
>
> -               if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> -                       continue;
> -
>                 if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>                         sc.nid = 0;
>
> @@ -690,6 +685,7 @@ void drop_slab_node(int nid)
>                 struct mem_cgroup *memcg = NULL;
>
>                 freed = 0;
> +               memcg = mem_cgroup_iter(NULL, NULL, NULL);
>                 do {
>                         freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
>                 } while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
> @@ -2709,9 +2705,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>                         shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
>                         node_lru_pages += lru_pages;
>
> -                       if (memcg)
> -                               shrink_slab(sc->gfp_mask, pgdat->node_id,
> -                                           memcg, sc->priority);
> +                       shrink_slab(sc->gfp_mask, pgdat->node_id,
> +                                   memcg, sc->priority);
>
>                         /* Record the group's reclaim efficiency */
>                         vmpressure(sc->gfp_mask, memcg, false,
> @@ -2735,10 +2730,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>                         }
>                 } while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>
> -               if (global_reclaim(sc))
> -                       shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
> -                                   sc->priority);
> -
>                 if (reclaim_state) {
>                         sc->nr_reclaimed += reclaim_state->reclaimed_slab;
>                         reclaim_state->reclaimed_slab = 0;
>
