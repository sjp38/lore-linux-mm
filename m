Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 20F456B0062
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 09:31:12 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so20709932lbj.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 06:31:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340783514-8150-3-git-send-email-minchan@kernel.org>
References: <1340783514-8150-1-git-send-email-minchan@kernel.org>
	<1340783514-8150-3-git-send-email-minchan@kernel.org>
Date: Mon, 9 Jul 2012 19:01:09 +0530
Message-ID: <CAEtiSavGmp=V37jxmLm2eQyRP3F08KotF9Dma5JCn7uaJbPo+w@mail.gmail.com>
Subject: Re: [PATCH 2/2 v2] memory-hotplug: fix kswapd looping forever problem
From: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On Wed, Jun 27, 2012 at 1:21 PM, Minchan Kim <minchan@kernel.org> wrote:
> When hotplug offlining happens on zone A, it starts to mark freed page
> as MIGRATE_ISOLATE type in buddy for preventing further allocation.
> (MIGRATE_ISOLATE is very irony type because it's apparently on buddy
> but we can't allocate them).
> When the memory shortage happens during hotplug offlining,
> current task starts to reclaim, then wake up kswapd.
> Kswapd checks watermark, then go sleep because current zone_watermark_ok_safe
> doesn't consider MIGRATE_ISOLATE freed page count.
> Current task continue to reclaim in direct reclaim path without kswapd's helping.
> The problem is that zone->all_unreclaimable is set by only kswapd
> so that current task would be looping forever like below.
>
> __alloc_pages_slowpath
> restart:
>         wake_all_kswapd
> rebalance:
>         __alloc_pages_direct_reclaim
>                 do_try_to_free_pages
>                         if global_reclaim && !all_unreclaimable
>                                 return 1; /* It means we did did_some_progress */
>         skip __alloc_pages_may_oom
>         should_alloc_retry
>                 goto rebalance;
>
> If we apply KOSAKI's patch[1] which doesn't depends on kswapd
> about setting zone->all_unreclaimable, we can solve this problem
> by killing some task in direct reclaim path. But it doesn't wake up kswapd, still.
> It could be a problem still if other subsystem needs GFP_ATOMIC request.
> So kswapd should consider MIGRATE_ISOLATE when it calculate free pages
> BEFORE going sleep.
>
> This patch counts the number of MIGRATE_ISOLATE page block and
> zone_watermark_ok_safe will consider it if the system has such blocks
> (fortunately, it's very rare so no problem in POV overhead and kswapd is never
> hotpath).
>
> Copy/modify from Mel's quote
> "
> Ideal solution would be "allocating" the pageblock.
> It would keep the free space accounting as it is but historically,
> memory hotplug didn't allocate pages because it would be difficult to
> detect if a pageblock was isolated or if part of some balloon.
> Allocating just full pageblocks would work around this, However,
> it would play very badly with CMA.
> "
>
> [1] http://lkml.org/lkml/2012/6/14/74
>
> * from v1
>  - add changelog
>  - make functions simple
>  - remove atomic variable
>  - discard exact isolated free page accounting.
>  - rebased on next-20120626
>
> Suggested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>
> Aaditya, coul you confirm this patch solve your problem and
> make sure nr_pageblock_isolate is zero after hotplug end?

I am really sorry for the delay.
I  just tried this patch on my ARM setup.


>
> +#ifdef CONFIG_MEMORY_ISOLATION
> +static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
> +{
> +       unsigned long nr_pages = 0;
> +
> +       if (unlikely(zone->nr_pageblock_isolate)) {
> +               nr_pages = zone->nr_pageblock_isolate * pageblock_nr_pages;
> +       }
> +       return nr_pages;
> +}
> +#else
> +static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
> +{
> +       return 0;
> +}
> +#endif
> +
>  bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>                       int classzone_idx, int alloc_flags)
>  {
> @@ -1629,6 +1651,14 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
>         if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>                 free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>
> +       /*
> +        * If the zone has MIGRATE_ISOLATE type free page,
> +        * we should consider it. nr_zone_isolate_freepages is never
> +        * accurate so kswapd might not sleep although she can.
> +        * But it's more desirable for memory hotplug rather than
> +        * forever sleep which cause livelock in direct reclaim path.
> +        */
> +       free_pages -= nr_zone_isolate_freepages(z);
>         return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
>                                                                 free_pages);

For my test case, pages to be off lined span the whole node.
With this setup the free_pages become negative. (As you and Kamezawa-san
already expected.)

BUT because of free_pages going negative the memory off lining still livelocks
as __zone_watermark_ok() returns true.

This is because in below if comparison, because of an unsigned value
(z->lowmem_reserve[classzone_idx])
all the longs are converted to unsigned long.

static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
              int classzone_idx, int alloc_flags, long free_pages)
{
 <snip>
    if (free_pages <= min + z->lowmem_reserve[classzone_idx])
        return false;
<snip>


So, may be you can consider following also:
As for the nr_pageblock_isolate going back to zero, yes it is going back to zero
for my test case.(I tested after this change)

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1594,6 +1594,7 @@ static bool __zone_watermark_ok(struct zone *z,
int order, unsigned long mark,
 {
        /* free_pages my go negative - that's OK */
        long min = mark;
+      long lowmem_res =  z->lowmem_reserve[classzone_idx];
        int o;

        free_pages -= (1 << order) - 1;
@@ -1602,7 +1603,7 @@ static bool __zone_watermark_ok(struct zone *z,
int order, unsigned long mark,
        if (alloc_flags & ALLOC_HARDER)
                min -= min / 4;

-       if (free_pages <= min + z->lowmem_reserve[classzone_idx])
+      if (free_pages <= min + lowmem_res)
                return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
