Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id E053C6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 10:19:04 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id fp4so16667149obb.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 07:19:04 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id k81si2832618oif.147.2016.03.08.07.19.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 07:19:04 -0800 (PST)
Received: by mail-ob0-x231.google.com with SMTP id fz5so16795750obc.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 07:19:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160307160838.GB5028@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<20160203132718.GI6757@dhcp22.suse.cz>
	<alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
	<20160225092315.GD17573@dhcp22.suse.cz>
	<20160229210213.GX16930@dhcp22.suse.cz>
	<20160307160838.GB5028@dhcp22.suse.cz>
Date: Wed, 9 Mar 2016 00:19:03 +0900
Message-ID: <CAAmzW4P2SPwW6F7X61QdAW8HTO_HUnZ_a9rbtei51SEuWXFvPg@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

2016-03-08 1:08 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Mon 29-02-16 22:02:13, Michal Hocko wrote:
>> Andrew,
>> could you queue this one as well, please? This is more a band aid than a
>> real solution which I will be working on as soon as I am able to
>> reproduce the issue but the patch should help to some degree at least.
>
> Joonsoo wasn't very happy about this approach so let me try a different
> way. What do you think about the following? Hugh, Sergey does it help

I'm still not happy. Just ensuring one compaction run doesn't mean our
best. What's your purpose of OOM rework? From my understanding,
you'd like to trigger OOM kill deterministic and *not prematurely*.
This makes sense.

But, what you did in case of high order allocation is completely different
with original purpose. It may be deterministic but *completely premature*.
There is no way to prevent premature OOM kill. So, I want to ask one more
time. Why OOM kill is better than retry reclaiming when there is reclaimable
page? Deterministic is for what? It ensures something more?

Please see Hugh's latest vmstat. There are plenty of anon pages when
OOM kill happens and it may have enough swap space. Even if
compaction runs and fails, why do we need to kill something
in this case? OOM kill should be a last resort.

Please see Hugh's previous report and OOM dump.

[  796.540791] Mem-Info:
[  796.557378] active_anon:150198 inactive_anon:46022 isolated_anon:32
 active_file:5107 inactive_file:1664 isolated_file:57
 unevictable:3067 dirty:4 writeback:75 unstable:0
 slab_reclaimable:13907 slab_unreclaimable:23236
 mapped:8889 shmem:3171 pagetables:2176 bounce:0
 free:1637 free_pcp:54 free_cma:0
[  796.630465] Node 0 DMA32 free:13904kB min:3940kB low:4944kB
high:5948kB active_anon:588776kB inactive_anon:188816kB
active_file:20432kB inactive_file:6928kB unevictable:12268kB
isolated(anon):128kB isolated(file):8kB present:1046128kB
managed:1004892kB mlocked:12268kB dirty:16kB writeback:1400kB
mapped:35556kB shmem:12684kB slab_reclaimable:55628kB
slab_unreclaimable:92944kB kernel_stack:4448kB pagetables:8604kB
unstable:0kB bounce:0kB free_pcp:296kB local_pcp:164kB free_cma:0kB
writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  796.685815] lowmem_reserve[]: 0 0 0
[  796.687390] Node 0 DMA32: 969*4kB (UE) 184*8kB (UME) 167*16kB (UM)
19*32kB (UM) 3*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB
0*4096kB = 8820kB
[  796.729696] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB

See [  796.557378] and [  796.630465].
In this 100 ms time interval, freepage increase a lot and
there are enough high order pages. OOM kill happen later
so freepage would come from reclaim. This shows
that your previous implementation which uses static retry number
causes premature OOM.

This attempt using compaction result looks not different to me.
It would also cause premature OOM kill.

I don't insist endless retry. I just want a more scientific criteria
that prevents
premature OOM kill. I'm really tire to say same thing again and again.
Am I missing something? This is the situation that I totally misunderstand
something? Please let me know.

Note: your current implementation doesn't consider which zone is compacted.
If DMA zone which easily fail to make high order page is compacted,
your implementation will not do retry. It also looks not our best.

Thanks.

> for your load? I have tested it with the Hugh's load and there was no
> major difference from the previous testing so at least nothing has blown
> up as I am not able to reproduce the issue here.
>
> Other changes in the compaction are still needed but I would like to not
> depend on them right now.
> ---
> From 0974f127e8eb7fe53e65f3a8b398db57effe9755 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 7 Mar 2016 15:30:37 +0100
> Subject: [PATCH] mm, oom: protect !costly allocations some more
>
> should_reclaim_retry will give up retries for higher order allocations
> if none of the eligible zones has any requested or higher order pages
> available even if we pass the watermak check for order-0. This is done
> because there is no guarantee that the reclaimable and currently free
> pages will form the required order.
>
> This can, however, lead to situations were the high-order request (e.g.
> order-2 required for the stack allocation during fork) will trigger
> OOM too early - e.g. after the first reclaim/compaction round. Such a
> system would have to be highly fragmented and there is no guarantee
> further reclaim/compaction attempts would help but at least make sure
> that the compaction was active before we go OOM and keep retrying even
> if should_reclaim_retry tells us to oom if the last compaction round
> was either inactive (deferred, skipped or bailed out early due to
> contention) or it told us to continue.
>
> Additionally define COMPACT_NONE which reflects cases where the
> compaction is completely disabled.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/compaction.h |  2 ++
>  mm/page_alloc.c            | 41 ++++++++++++++++++++++++-----------------
>  2 files changed, 26 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 4cd4ddf64cc7..a4cec4a03f7d 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -1,6 +1,8 @@
>  #ifndef _LINUX_COMPACTION_H
>  #define _LINUX_COMPACTION_H
>
> +/* compaction disabled */
> +#define COMPACT_NONE           -1
>  /* Return values for compact_zone() and try_to_compact_pages() */
>  /* compaction didn't start as it was deferred due to past failures */
>  #define COMPACT_DEFERRED       0
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 269a04f20927..f89e3cbfdf90 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2819,28 +2819,22 @@ static struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>                 int alloc_flags, const struct alloc_context *ac,
>                 enum migrate_mode mode, int *contended_compaction,
> -               bool *deferred_compaction)
> +               unsigned long *compact_result)
>  {
> -       unsigned long compact_result;
>         struct page *page;
>
> -       if (!order)
> +       if (!order) {
> +               *compact_result = COMPACT_NONE;
>                 return NULL;
> +       }
>
>         current->flags |= PF_MEMALLOC;
> -       compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> +       *compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>                                                 mode, contended_compaction);
>         current->flags &= ~PF_MEMALLOC;
>
> -       switch (compact_result) {
> -       case COMPACT_DEFERRED:
> -               *deferred_compaction = true;
> -               /* fall-through */
> -       case COMPACT_SKIPPED:
> +       if (*compact_result <= COMPACT_SKIPPED)
>                 return NULL;
> -       default:
> -               break;
> -       }
>
>         /*
>          * At least in one zone compaction wasn't deferred or skipped, so let's
> @@ -2875,8 +2869,9 @@ static inline struct page *
>  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>                 int alloc_flags, const struct alloc_context *ac,
>                 enum migrate_mode mode, int *contended_compaction,
> -               bool *deferred_compaction)
> +               unsigned long *compact_result)
>  {
> +       *compact_result = COMPACT_NONE;
>         return NULL;
>  }
>  #endif /* CONFIG_COMPACTION */
> @@ -3118,7 +3113,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>         int alloc_flags;
>         unsigned long did_some_progress;
>         enum migrate_mode migration_mode = MIGRATE_ASYNC;
> -       bool deferred_compaction = false;
> +       unsigned long compact_result;
>         int contended_compaction = COMPACT_CONTENDED_NONE;
>         int no_progress_loops = 0;
>
> @@ -3227,7 +3222,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>         page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
>                                         migration_mode,
>                                         &contended_compaction,
> -                                       &deferred_compaction);
> +                                       &compact_result);
>         if (page)
>                 goto got_pg;
>
> @@ -3240,7 +3235,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>                  * to heavily disrupt the system, so we fail the allocation
>                  * instead of entering direct reclaim.
>                  */
> -               if (deferred_compaction)
> +               if (compact_result == COMPACT_DEFERRED)
>                         goto nopage;
>
>                 /*
> @@ -3294,6 +3289,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>                                  did_some_progress > 0, no_progress_loops))
>                 goto retry;
>
> +       /*
> +        * !costly allocations are really important and we have to make sure
> +        * the compaction wasn't deferred or didn't bail out early due to locks
> +        * contention before we go OOM.
> +        */
> +       if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
> +               if (compact_result <= COMPACT_CONTINUE)
> +                       goto retry;
> +               if (contended_compaction > COMPACT_CONTENDED_NONE)
> +                       goto retry;
> +       }
> +
>         /* Reclaim has failed us, start killing things */
>         page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
>         if (page)
> @@ -3314,7 +3321,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>         page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
>                                             ac, migration_mode,
>                                             &contended_compaction,
> -                                           &deferred_compaction);
> +                                           &compact_result);
>         if (page)
>                 goto got_pg;
>  nopage:
> --
> 2.7.0
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
