Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 242C76B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 02:57:05 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id jl1so216569816obb.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 23:57:05 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id qb8si2974647igc.55.2016.04.28.23.57.03
        for <linux-mm@kvack.org>;
        Thu, 28 Apr 2016 23:57:04 -0700 (PDT)
Date: Fri, 29 Apr 2016 15:57:12 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 1/6] mm/page_alloc: recalculate some of zone threshold
 when on/offline memory
Message-ID: <20160429065712.GB19896@js1304-P5Q-DELUXE>
References: <1461561670-28012-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1461561670-28012-2-git-send-email-iamjoonsoo.kim@lge.com>
 <bc9e4751-c953-35bf-4fb7-eae3885d3d07@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bc9e4751-c953-35bf-4fb7-eae3885d3d07@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rui Teng <rui.teng@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Apr 28, 2016 at 03:46:33PM +0800, Rui Teng wrote:
> On 4/25/16 1:21 PM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >Some of zone threshold depends on number of managed pages in the zone.
> >When memory is going on/offline, it can be changed and we need to
> >adjust them.
> >
> >This patch add recalculation to appropriate places and clean-up
> >related function for better maintanance.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> > mm/page_alloc.c | 36 +++++++++++++++++++++++++++++-------
> > 1 file changed, 29 insertions(+), 7 deletions(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 71fa015..ffa93e0 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -4633,6 +4633,8 @@ int local_memory_node(int node)
> > }
> > #endif
> >
> >+static void setup_min_unmapped_ratio(struct zone *zone);
> >+static void setup_min_slab_ratio(struct zone *zone);
> > #else	/* CONFIG_NUMA */
> >
> > static void set_zonelist_order(void)
> >@@ -5747,9 +5749,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
> > 		zone->managed_pages = is_highmem_idx(j) ? realsize : freesize;
> > #ifdef CONFIG_NUMA
> > 		zone->node = nid;
> >-		zone->min_unmapped_pages = (freesize*sysctl_min_unmapped_ratio)
> >-						/ 100;
> >-		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
> >+		setup_min_unmapped_ratio(zone);
> >+		setup_min_slab_ratio(zone);
> 
> The original logic use freesize to calculate the
> zone->min_unmapped_pages and zone->min_slab_pages here.
> But the new function will use zone->managed_pages.
> Do you mean the original logic is wrong, or the managed_pages will
> always be freesize when CONFIG_NUMA defined?

managed_pages will always be freesize so no problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
