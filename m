Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E15D06B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 12:47:08 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d25-v6so2042028qtp.10
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 09:47:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31-v6sor1206649qtx.40.2018.08.02.09.47.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Aug 2018 09:47:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
References: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 2 Aug 2018 09:47:06 -0700
Message-ID: <CAHbLzkpBnNN4RBMHXzy09x1PZw4m5D99jANmjD=0GT=1tkxniQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to do_shrink_slab()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@i-love.sakura.ne.jp, willy@infradead.org, Shakeel Butt <shakeelb@google.com>, jbacik@fb.com, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Aug 2, 2018 at 4:00 AM, Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> In case of shrink_slab_memcg() we do not zero nid, when shrinker
> is not numa-aware. This is not a real problem, since currently
> all memcg-aware shrinkers are numa-aware too (we have two:

Actually, this is not true. huge_zero_page_shrinker is NOT numa-aware.
deferred_split_shrinker is numa-aware.

Thanks,
Yang


> super_block shrinker and workingset shrinker), but something may
> change in the future.
>
> (Andrew, this may be merged to mm-iterate-only-over-charged-shrinkers-during-memcg-shrink_slab)
>
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  mm/vmscan.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ea0a46166e8e..0d980e801b8a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -455,6 +455,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>                                           : SHRINK_BATCH;
>         long scanned = 0, next_deferred;
>
> +       if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
> +               nid = 0;
> +
>         freeable = shrinker->count_objects(shrinker, shrinkctl);
>         if (freeable == 0 || freeable == SHRINK_EMPTY)
>                 return freeable;
> @@ -680,9 +683,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>                         .memcg = memcg,
>                 };
>
> -               if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
> -                       sc.nid = 0;
> -
>                 ret = do_shrink_slab(&sc, shrinker, priority);
>                 if (ret == SHRINK_EMPTY)
>                         ret = 0;
>
