Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF996B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 04:09:27 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x68so23159144ioi.0
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 01:09:27 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 16si22614725iog.39.2016.06.28.01.09.25
        for <linux-mm@kvack.org>;
        Tue, 28 Jun 2016 01:09:26 -0700 (PDT)
Date: Tue, 28 Jun 2016 17:12:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 1/6] mm/page_alloc: recalculate some of zone threshold
 when on/offline memory
Message-ID: <20160628081217.GA19731@js1304-P5Q-DELUXE>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464243748-16367-2-git-send-email-iamjoonsoo.kim@lge.com>
 <921a37c6-b1e8-576f-095b-48e153bfd1d6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <921a37c6-b1e8-576f-095b-48e153bfd1d6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 24, 2016 at 03:20:43PM +0200, Vlastimil Babka wrote:
> On 05/26/2016 08:22 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >Some of zone threshold depends on number of managed pages in the zone.
> >When memory is going on/offline, it can be changed and we need to
> >adjust them.
> >
> >This patch add recalculation to appropriate places and clean-up
> >related function for better maintanance.
> 
> Can you be more specific about the user visible effect? Presumably
> it's not affecting just ZONE_CMA?

Yes, it's also affecting memory hotplug.

> I assume it's fixing the thresholds where only part of node is
> onlined or offlined? Or are they currently wrong even when whole
> node is onlined/offlined?

When memory hotplug happens, managed_pages changes and we need to
recalculate everything based on managed_pages. min_slab_pages and
min_unmapped_pages are missed so this patch does it, too.

Thanks.

> 
> (Sorry but I can't really orient myself in the maze of memory hotplug :(
> 
> Thanks,
> Vlastimil
> 
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> > mm/page_alloc.c | 36 +++++++++++++++++++++++++++++-------
> > 1 file changed, 29 insertions(+), 7 deletions(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index d27e8b9..90e5a82 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -4874,6 +4874,8 @@ int local_memory_node(int node)
> > }
> > #endif
> >
> >+static void setup_min_unmapped_ratio(struct zone *zone);
> >+static void setup_min_slab_ratio(struct zone *zone);
> > #else	/* CONFIG_NUMA */
> >
> > static void set_zonelist_order(void)
> >@@ -5988,9 +5990,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
> > 		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
> > #ifdef CONFIG_NUMA
> > 		zone->node = nid;
> >-		zone->min_unmapped_pages = (freesize*sysctl_min_unmapped_ratio)
> >-						/ 100;
> >-		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
> >+		setup_min_unmapped_ratio(zone);
> >+		setup_min_slab_ratio(zone);
> > #endif
> > 		zone->name = zone_names[j];
> > 		spin_lock_init(&zone->lock);
> >@@ -6896,6 +6897,7 @@ int __meminit init_per_zone_wmark_min(void)
> > {
> > 	unsigned long lowmem_kbytes;
> > 	int new_min_free_kbytes;
> >+	struct zone *zone;
> >
> > 	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
> > 	new_min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
> >@@ -6913,6 +6915,14 @@ int __meminit init_per_zone_wmark_min(void)
> > 	setup_per_zone_wmarks();
> > 	refresh_zone_stat_thresholds();
> > 	setup_per_zone_lowmem_reserve();
> >+
> >+	for_each_zone(zone) {
> >+#ifdef CONFIG_NUMA
> >+		setup_min_unmapped_ratio(zone);
> >+		setup_min_slab_ratio(zone);
> >+#endif
> >+	}
> >+
> > 	return 0;
> > }
> > core_initcall(init_per_zone_wmark_min)
> >@@ -6954,6 +6964,12 @@ int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
> > }
> >
> > #ifdef CONFIG_NUMA
> >+static void setup_min_unmapped_ratio(struct zone *zone)
> >+{
> >+	zone->min_unmapped_pages = (zone->managed_pages *
> >+			sysctl_min_unmapped_ratio) / 100;
> >+}
> >+
> > int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
> > 	void __user *buffer, size_t *length, loff_t *ppos)
> > {
> >@@ -6965,11 +6981,17 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
> > 		return rc;
> >
> > 	for_each_zone(zone)
> >-		zone->min_unmapped_pages = (zone->managed_pages *
> >-				sysctl_min_unmapped_ratio) / 100;
> >+		setup_min_unmapped_ratio(zone);
> >+
> > 	return 0;
> > }
> >
> >+static void setup_min_slab_ratio(struct zone *zone)
> >+{
> >+	zone->min_slab_pages = (zone->managed_pages *
> >+			sysctl_min_slab_ratio) / 100;
> >+}
> >+
> > int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
> > 	void __user *buffer, size_t *length, loff_t *ppos)
> > {
> >@@ -6981,8 +7003,8 @@ int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *table, int write,
> > 		return rc;
> >
> > 	for_each_zone(zone)
> >-		zone->min_slab_pages = (zone->managed_pages *
> >-				sysctl_min_slab_ratio) / 100;
> >+		setup_min_slab_ratio(zone);
> >+
> > 	return 0;
> > }
> > #endif
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
