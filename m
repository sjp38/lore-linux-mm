Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 61A7B6B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 06:27:21 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id hg5so1324920qab.8
        for <linux-mm@kvack.org>; Mon, 14 Jan 2013 03:27:20 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20130114103612.GO13304@suse.de>
References: <CA+icZUW5kryOCpX96CkaS=5uX61FmiYE0mh7y6F0eT9Bh8eUGw@mail.gmail.com>
	<20130114103612.GO13304@suse.de>
Date: Mon, 14 Jan 2013 12:27:20 +0100
Message-ID: <CA+icZUUReY7LPjnF1xTjD-aJSYYqgo9tF9K8T8--r_HjRwgCHA@mail.gmail.com>
Subject: Re: Unique commit-id for "mm: compaction: [P,p]artially revert
 capture of suitable high-order page"
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 14, 2013 at 11:36 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Sun, Jan 13, 2013 at 05:12:45PM +0100, Sedat Dilek wrote:
>> Hi Linus,
>>
>> I see two different commit-id for an identical patch (only subject
>> line differs).
>> [1] seems to be applied directly and [2] came with a merge of akpm-fixes.
>> What is in case of backports for -stable kernels?
>
> I do not expect it to matter. I was going to use
> 8fb74b9fb2b182d54beee592350d9ea1f325917a as the commit ID whenever I got
> the complaint mail from Greg's tools about a 3.7 merge failure. The 3.7.2
> backport looks like this.
>

Oh cool and thanks!
Are you planning to resend this backport-patch to the lists w/ a "3.7"
(or for-3.7) in the commit-subject?

- Sedat -

> ---8<---
> mm: compaction: Partially revert capture of suitable high-order page
>
> commit 8fb74b9fb2b182d54beee592350d9ea1f325917a upstream.
>
> Eric Wong reported on 3.7 and 3.8-rc2 that ppoll() got stuck when waiting
> for POLLIN on a local TCP socket. It was easier to trigger if there was disk
> IO and dirty pages at the same time and he bisected it to commit 1fb3f8ca
> "mm: compaction: capture a suitable high-order page immediately when it
> is made available".
>
> The intention of that patch was to improve high-order allocations under
> memory pressure after changes made to reclaim in 3.6 drastically hurt
> THP allocations but the approach was flawed. For Eric, the problem was
> that page->pfmemalloc was not being cleared for captured pages leading to
> a poor interaction with swap-over-NFS support causing the packets to be
> dropped. However, I identified a few more problems with the patch including
> the fact that it can increase contention on zone->lock in some cases which
> could result in async direct compaction being aborted early.
>
> In retrospect the capture patch took the wrong approach. What it should
> have done is mark the pageblock being migrated as MIGRATE_ISOLATE if it
> was allocating for THP and avoided races that way. While the patch was
> showing to improve allocation success rates at the time, the benefit is
> marginal given the relative complexity and it should be revisited from
> scratch in the context of the other reclaim-related changes that have taken
> place since the patch was first written and tested. This patch partially
> reverts commit 1fb3f8ca "mm: compaction: capture a suitable high-order
> page immediately when it is made available".
>
> Reported-and-tested-by: Eric Wong <normalperson@yhbt.net>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/compaction.h |    4 +-
>  include/linux/mm.h         |    1 -
>  mm/compaction.c            |   92 +++++++-------------------------------------
>  mm/internal.h              |    1 -
>  mm/page_alloc.c            |   35 ++++-------------
>  5 files changed, 23 insertions(+), 110 deletions(-)
>
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 6ecb6dc..cc7bdde 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -22,7 +22,7 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
>                         int order, gfp_t gfp_mask, nodemask_t *mask,
> -                       bool sync, bool *contended, struct page **page);
> +                       bool sync, bool *contended);
>  extern int compact_pgdat(pg_data_t *pgdat, int order);
>  extern void reset_isolation_suitable(pg_data_t *pgdat);
>  extern unsigned long compaction_suitable(struct zone *zone, int order);
> @@ -75,7 +75,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
>  #else
>  static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
>                         int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -                       bool sync, bool *contended, struct page **page)
> +                       bool sync, bool *contended)
>  {
>         return COMPACT_CONTINUE;
>  }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index bcaab4e..280dae5 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -455,7 +455,6 @@ void put_pages_list(struct list_head *pages);
>
>  void split_page(struct page *page, unsigned int order);
>  int split_free_page(struct page *page);
> -int capture_free_page(struct page *page, int alloc_order, int migratetype);
>
>  /*
>   * Compound pages have a destructor function.  Provide a
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 694eaab..31ecd14 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -214,60 +214,6 @@ static bool suitable_migration_target(struct page *page)
>         return false;
>  }
>
> -static void compact_capture_page(struct compact_control *cc)
> -{
> -       unsigned long flags;
> -       int mtype, mtype_low, mtype_high;
> -
> -       if (!cc->page || *cc->page)
> -               return;
> -
> -       /*
> -        * For MIGRATE_MOVABLE allocations we capture a suitable page ASAP
> -        * regardless of the migratetype of the freelist is is captured from.
> -        * This is fine because the order for a high-order MIGRATE_MOVABLE
> -        * allocation is typically at least a pageblock size and overall
> -        * fragmentation is not impaired. Other allocation types must
> -        * capture pages from their own migratelist because otherwise they
> -        * could pollute other pageblocks like MIGRATE_MOVABLE with
> -        * difficult to move pages and making fragmentation worse overall.
> -        */
> -       if (cc->migratetype == MIGRATE_MOVABLE) {
> -               mtype_low = 0;
> -               mtype_high = MIGRATE_PCPTYPES;
> -       } else {
> -               mtype_low = cc->migratetype;
> -               mtype_high = cc->migratetype + 1;
> -       }
> -
> -       /* Speculatively examine the free lists without zone lock */
> -       for (mtype = mtype_low; mtype < mtype_high; mtype++) {
> -               int order;
> -               for (order = cc->order; order < MAX_ORDER; order++) {
> -                       struct page *page;
> -                       struct free_area *area;
> -                       area = &(cc->zone->free_area[order]);
> -                       if (list_empty(&area->free_list[mtype]))
> -                               continue;
> -
> -                       /* Take the lock and attempt capture of the page */
> -                       if (!compact_trylock_irqsave(&cc->zone->lock, &flags, cc))
> -                               return;
> -                       if (!list_empty(&area->free_list[mtype])) {
> -                               page = list_entry(area->free_list[mtype].next,
> -                                                       struct page, lru);
> -                               if (capture_free_page(page, cc->order, mtype)) {
> -                                       spin_unlock_irqrestore(&cc->zone->lock,
> -                                                                       flags);
> -                                       *cc->page = page;
> -                                       return;
> -                               }
> -                       }
> -                       spin_unlock_irqrestore(&cc->zone->lock, flags);
> -               }
> -       }
> -}
> -
>  /*
>   * Isolate free pages onto a private freelist. Caller must hold zone->lock.
>   * If @strict is true, will abort returning 0 on any invalid PFNs or non-free
> @@ -831,6 +777,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  static int compact_finished(struct zone *zone,
>                             struct compact_control *cc)
>  {
> +       unsigned int order;
>         unsigned long watermark;
>
>         if (fatal_signal_pending(current))
> @@ -865,22 +812,16 @@ static int compact_finished(struct zone *zone,
>                 return COMPACT_CONTINUE;
>
>         /* Direct compactor: Is a suitable page free? */
> -       if (cc->page) {
> -               /* Was a suitable page captured? */
> -               if (*cc->page)
> +       for (order = cc->order; order < MAX_ORDER; order++) {
> +               struct free_area *area = &zone->free_area[order];
> +
> +               /* Job done if page is free of the right migratetype */
> +               if (!list_empty(&area->free_list[cc->migratetype]))
> +                       return COMPACT_PARTIAL;
> +
> +               /* Job done if allocation would set block type */
> +               if (cc->order >= pageblock_order && area->nr_free)
>                         return COMPACT_PARTIAL;
> -       } else {
> -               unsigned int order;
> -               for (order = cc->order; order < MAX_ORDER; order++) {
> -                       struct free_area *area = &zone->free_area[cc->order];
> -                       /* Job done if page is free of the right migratetype */
> -                       if (!list_empty(&area->free_list[cc->migratetype]))
> -                               return COMPACT_PARTIAL;
> -
> -                       /* Job done if allocation would set block type */
> -                       if (cc->order >= pageblock_order && area->nr_free)
> -                               return COMPACT_PARTIAL;
> -               }
>         }
>
>         return COMPACT_CONTINUE;
> @@ -1018,9 +959,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>                                 goto out;
>                         }
>                 }
> -
> -               /* Capture a page now if it is a suitable size */
> -               compact_capture_page(cc);
>         }
>
>  out:
> @@ -1033,8 +971,7 @@ out:
>
>  static unsigned long compact_zone_order(struct zone *zone,
>                                  int order, gfp_t gfp_mask,
> -                                bool sync, bool *contended,
> -                                struct page **page)
> +                                bool sync, bool *contended)
>  {
>         unsigned long ret;
>         struct compact_control cc = {
> @@ -1044,7 +981,6 @@ static unsigned long compact_zone_order(struct zone *zone,
>                 .migratetype = allocflags_to_migratetype(gfp_mask),
>                 .zone = zone,
>                 .sync = sync,
> -               .page = page,
>         };
>         INIT_LIST_HEAD(&cc.freepages);
>         INIT_LIST_HEAD(&cc.migratepages);
> @@ -1074,7 +1010,7 @@ int sysctl_extfrag_threshold = 500;
>   */
>  unsigned long try_to_compact_pages(struct zonelist *zonelist,
>                         int order, gfp_t gfp_mask, nodemask_t *nodemask,
> -                       bool sync, bool *contended, struct page **page)
> +                       bool sync, bool *contended)
>  {
>         enum zone_type high_zoneidx = gfp_zone(gfp_mask);
>         int may_enter_fs = gfp_mask & __GFP_FS;
> @@ -1100,7 +1036,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
>                 int status;
>
>                 status = compact_zone_order(zone, order, gfp_mask, sync,
> -                                               contended, page);
> +                                               contended);
>                 rc = max(status, rc);
>
>                 /* If a normal allocation would succeed, stop compacting */
> @@ -1156,7 +1092,6 @@ int compact_pgdat(pg_data_t *pgdat, int order)
>         struct compact_control cc = {
>                 .order = order,
>                 .sync = false,
> -               .page = NULL,
>         };
>
>         return __compact_pgdat(pgdat, &cc);
> @@ -1167,7 +1102,6 @@ static int compact_node(int nid)
>         struct compact_control cc = {
>                 .order = -1,
>                 .sync = true,
> -               .page = NULL,
>         };
>
>         return __compact_pgdat(NODE_DATA(nid), &cc);
> diff --git a/mm/internal.h b/mm/internal.h
> index a4fa284..3c5197d 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -130,7 +130,6 @@ struct compact_control {
>         int migratetype;                /* MOVABLE, RECLAIMABLE etc */
>         struct zone *zone;
>         bool contended;                 /* True if a lock was contended */
> -       struct page **page;             /* Page captured of requested size */
>  };
>
>  unsigned long
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7e208f0..25558ed 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1376,14 +1376,8 @@ void split_page(struct page *page, unsigned int order)
>                 set_page_refcounted(page + i);
>  }
>
> -/*
> - * Similar to the split_page family of functions except that the page
> - * required at the given order and being isolated now to prevent races
> - * with parallel allocators
> - */
> -int capture_free_page(struct page *page, int alloc_order, int migratetype)
> +static int __isolate_free_page(struct page *page, unsigned int order)
>  {
> -       unsigned int order;
>         unsigned long watermark;
>         struct zone *zone;
>         int mt;
> @@ -1391,7 +1385,6 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
>         BUG_ON(!PageBuddy(page));
>
>         zone = page_zone(page);
> -       order = page_order(page);
>
>         /* Obey watermarks as if the page was being allocated */
>         watermark = low_wmark_pages(zone) + (1 << order);
> @@ -1405,13 +1398,9 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
>
>         mt = get_pageblock_migratetype(page);
>         if (unlikely(mt != MIGRATE_ISOLATE))
> -               __mod_zone_freepage_state(zone, -(1UL << alloc_order), mt);
> -
> -       if (alloc_order != order)
> -               expand(zone, page, alloc_order, order,
> -                       &zone->free_area[order], migratetype);
> +               __mod_zone_freepage_state(zone, -(1UL << order), mt);
>
> -       /* Set the pageblock if the captured page is at least a pageblock */
> +       /* Set the pageblock if the isolated page is at least a pageblock */
>         if (order >= pageblock_order - 1) {
>                 struct page *endpage = page + (1 << order) - 1;
>                 for (; page < endpage; page += pageblock_nr_pages) {
> @@ -1422,7 +1411,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
>                 }
>         }
>
> -       return 1UL << alloc_order;
> +       return 1UL << order;
>  }
>
>  /*
> @@ -1440,10 +1429,9 @@ int split_free_page(struct page *page)
>         unsigned int order;
>         int nr_pages;
>
> -       BUG_ON(!PageBuddy(page));
>         order = page_order(page);
>
> -       nr_pages = capture_free_page(page, order, 0);
> +       nr_pages = __isolate_free_page(page, order);
>         if (!nr_pages)
>                 return 0;
>
> @@ -2148,8 +2136,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>         bool *contended_compaction, bool *deferred_compaction,
>         unsigned long *did_some_progress)
>  {
> -       struct page *page = NULL;
> -
>         if (!order)
>                 return NULL;
>
> @@ -2161,16 +2147,12 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>         current->flags |= PF_MEMALLOC;
>         *did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
>                                                 nodemask, sync_migration,
> -                                               contended_compaction, &page);
> +                                               contended_compaction);
>         current->flags &= ~PF_MEMALLOC;
>
> -       /* If compaction captured a page, prep and use it */
> -       if (page) {
> -               prep_new_page(page, order, gfp_mask);
> -               goto got_page;
> -       }
> -
>         if (*did_some_progress != COMPACT_SKIPPED) {
> +               struct page *page;
> +
>                 /* Page migration frees to the PCP lists but we want merging */
>                 drain_pages(get_cpu());
>                 put_cpu();
> @@ -2180,7 +2162,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>                                 alloc_flags & ~ALLOC_NO_WATERMARKS,
>                                 preferred_zone, migratetype);
>                 if (page) {
> -got_page:
>                         preferred_zone->compact_blockskip_flush = false;
>                         preferred_zone->compact_considered = 0;
>                         preferred_zone->compact_defer_shift = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
