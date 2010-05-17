Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0F1926B01F0
	for <linux-mm@kvack.org>; Mon, 17 May 2010 04:18:39 -0400 (EDT)
Message-ID: <4BF0FBDB.3090202@linux.intel.com>
Date: Mon, 17 May 2010 16:18:35 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mem-hotplug: separate setup_per_cpu_pageset() into separate
 functions
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

From: Wu Fengguang <fengguang.wu@intel.com>

No behavior change here.

Move some of setup_per_cpu_pageset() code into a new function
setup_zone_pageset() that will be useful for memory hotplug.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Reviewed-by: Andi Kleen <andi.kleen@intel.com>
---
  mm/page_alloc.c |   37 ++++++++++++++++++++-----------------
  1 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d03c946..3eb7c31 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3146,31 +3146,34 @@ static void setup_pagelist_highmark(struct per_cpu_pageset *p,
  		pcp->batch = PAGE_SHIFT * 8;
  }

+static __meminit void setup_zone_pageset(struct zone *zone)
+{
+	int cpu;
+
+	zone->pageset = alloc_percpu(struct per_cpu_pageset);
+
+	for_each_possible_cpu(cpu) {
+		struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
+
+		setup_pageset(pcp, zone_batchsize(zone));
+
+		if (percpu_pagelist_fraction)
+			setup_pagelist_highmark(pcp,
+				(zone->present_pages /
+					percpu_pagelist_fraction));
+	}
+}
+
  /*
   * Allocate per cpu pagesets and initialize them.
   * Before this call only boot pagesets were available.
- * Boot pagesets will no longer be used by this processorr
- * after setup_per_cpu_pageset().
   */
  void __init setup_per_cpu_pageset(void)
  {
  	struct zone *zone;
-	int cpu;

-	for_each_populated_zone(zone) {
-		zone->pageset = alloc_percpu(struct per_cpu_pageset);
-
-		for_each_possible_cpu(cpu) {
-			struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
-
-			setup_pageset(pcp, zone_batchsize(zone));
-
-			if (percpu_pagelist_fraction)
-				setup_pagelist_highmark(pcp,
-					(zone->present_pages /
-						percpu_pagelist_fraction));
-		}
-	}
+	for_each_populated_zone(zone)
+		setup_zone_pageset(zone);
  }

  static noinline __init_refok
-- 
1.6.0.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
