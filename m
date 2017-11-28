Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 37D396B0278
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:02:26 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q7so16489709pgr.10
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 22:02:26 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o5si25144435plh.477.2017.11.27.22.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 22:02:25 -0800 (PST)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH 2/2] mm: Rename zone_statistics() to numa_statistics()
Date: Tue, 28 Nov 2017 14:00:24 +0800
Message-Id: <1511848824-18709-2-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Kemi Wang <kemi.wang@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Since numa statistics has been separated from zone statistics framework,
but the functionality of zone_statistics() updates numa counters. Thus, the
function name makes people confused. So, change the name to
numa_statistics() as well as its call sites accordingly.

Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 142e1ba..61fa717 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2783,7 +2783,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
  *
  * Must be called with interrupts disabled.
  */
-static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
+static inline void numa_statistics(struct zone *preferred_zone, struct zone *z)
 {
 #ifdef CONFIG_NUMA
 	enum numa_stat_item local_stat = NUMA_LOCAL;
@@ -2845,7 +2845,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	page = __rmqueue_pcplist(zone,  migratetype, pcp, list);
 	if (page) {
 		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
-		zone_statistics(preferred_zone, zone);
+		numa_statistics(preferred_zone, zone);
 	}
 	local_irq_restore(flags);
 	return page;
@@ -2893,7 +2893,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 				  get_pcppage_migratetype(page));
 
 	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
-	zone_statistics(preferred_zone, zone);
+	numa_statistics(preferred_zone, zone);
 	local_irq_restore(flags);
 
 out:
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
