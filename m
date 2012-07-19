Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 6B5E86B005C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2012 20:09:29 -0400 (EDT)
Date: Thu, 19 Jul 2012 09:10:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to -mm
 tree
Message-ID: <20120719001002.GA6579@bbox>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
 <20120718012200.GA27770@bbox>
 <20120718143810.b15564b3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120718143810.b15564b3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Wed, Jul 18, 2012 at 02:38:10PM -0700, Andrew Morton wrote:
> On Wed, 18 Jul 2012 10:22:00 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > > 
> > > Is this really necessary?  Does the zone start out all-zeroes?  If not, can we
> > > make it do so?
> > 
> > Good point.
> > It can remove zap_zone_vm_stats and zone->flags = 0, too.
> > More important thing is that we could remove adding code to initialize
> > zero whenever we add new field to zone. So I look at the code.
> > 
> > In summary, IMHO, all is already initialie zero out but we need double
> > check in mips.
> > 
> 
> Well, this is hardly a performance-critical path.  So rather than
> groveling around ensuring that each and every architectures does the
> right thing, would it not be better to put a single memset() into core
> MM if there is an appropriate place?

I think most good place is free_area_init_node but at a glance,
bootmem_data is set up eariler than free_area_init_node so shouldn't we
keep that pointer still?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 32985dd..1e7ca80 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4366,9 +4366,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
        int ret;
 
        pgdat_resize_init(pgdat);
-       pgdat->nr_zones = 0;
        init_waitqueue_head(&pgdat->kswapd_wait);
-       pgdat->kswapd_max_order = 0;
        pgdat_page_cgroup_init(pgdat);
 
        for (j = 0; j < MAX_NR_ZONES; j++) {
@@ -4429,11 +4427,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
                zone_pcp_init(zone);
                lruvec_init(&zone->lruvec, zone);
-               zap_zone_vm_stats(zone);
-               zone->flags = 0;
-#ifdef CONFIG_MEMORY_ISOLATION
-               zone->nr_pageblock_isolate = 0;
-#endif
                if (!size)
                        continue;
 
@@ -4495,7 +4488,15 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
                unsigned long node_start_pfn, unsigned long *zholes_size)
 {
        pg_data_t *pgdat = NODE_DATA(nid);
-
+       /* We guarantees pg_data_t starts out all-zeroes except bdata */
+#ifndef CONFIG_NO_BOOTMEM
+       struct bootmem_data *bdata;
+       bdata = pgdat->bdata;
+#endif
+       memset(pgdat, 0, sizeof(pg_data_t));
+#ifndef CONFIG_NO_BOOTMEM
+       pgdat->bdata = bdata;
+#endif
        pgdat->node_id = nid;
        pgdat->node_start_pfn = node_start_pfn;
        calculate_node_totalpages(pgdat, zones_size, zholes_size);

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
