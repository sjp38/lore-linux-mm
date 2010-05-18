Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B28096003C2
	for <linux-mm@kvack.org>; Tue, 18 May 2010 05:02:53 -0400 (EDT)
Message-ID: <4BF257BA.7020507@linux.intel.com>
Date: Tue, 18 May 2010 17:02:50 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: [RESEND][PATCH 3/3] mem-hotplug: fix potential race while building
 zonelist for new populated zone
References: <4BF0FC4C.4060306@linux.intel.com> <alpine.DEB.2.00.1005171108070.20764@router.home> <20100518021923.GA6595@localhost>
In-Reply-To: <20100518021923.GA6595@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> On Tue, May 18, 2010 at 12:09:31AM +0800, Christoph Lameter wrote:
>> Building a zonelist now has the potential side effect of changes to the
>> size of the zone?
> 
> Yeah, this sounds a bit hacky.
> 
>> Can we have a global mutex that protects against size modification of
>> zonelists instead? And it could also serialize the pageset setup?
> 
> Good suggestion. We could make zone_pageset_mutex a global mutex and
> take it in all the functions that call build_all_zonelists() --
> currently only online_pages() and numa_zonelist_order_handler().

Yes, if we don't mind adding a global mutex, it's another way to fix the race.

> This can equally fix the possible race:
> 
>     CPU0                                    CPU1                            CPU2
> (1) zone->present_pages += online_pages;
> (2)                                         build_all_zonelists();
> (3)                                                                 alloc_page();
> (4)                                                                 free_page();
> (5) build_all_zonelists();
> (6)   __build_all_zonelists();
> (7)     zone->pageset = alloc_percpu();
> 
> In step (3,4), zone->pageset still points to boot_pageset, so bad
> things may happen if 2+ nodes are in this state. Even if only 1 node
> is accessing the boot_pageset, (3) may still consume too much memory
> to fail the memory allocations in step (7).

Fengguang, this is a nice description of the possible race,
I'd include it into the changelog of this patch.

So how about the revised patch below?

---
 From 0b1e776dc6c135b1d0c9a0bfb35daa9e9cfb046d Mon Sep 17 00:00:00 2001
From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Tue, 18 May 2010 15:53:28 +0800
Subject: [PATCH] mem-hotplug: fix potential setup_zone_pageset race

Add global mutex zonelists_pageset_mutex to fix the possible race:

     CPU0                                  CPU1                    CPU2
(1) zone->present_pages += online_pages;
(2)                                       build_all_zonelists();
(3)                                                               alloc_page();
(4)                                                               free_page();
(5) build_all_zonelists();
(6)   __build_all_zonelists();
(7)     zone->pageset = alloc_percpu();

In step (3,4), zone->pageset still points to boot_pageset, so bad
things may happen if 2+ nodes are in this state. Even if only 1 node
is accessing the boot_pageset, (3) may still consume too much memory
to fail the memory allocations in step (7).

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Andi Kleen <andi.kleen@intel.com>
---
  include/linux/mmzone.h |    1 +
  mm/memory_hotplug.c    |   11 +++--------
  mm/page_alloc.c        |   15 ++++++++++++++-
  3 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index dbbcd50..5103747 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -641,6 +641,7 @@ typedef struct pglist_data {

  #include <linux/memory_hotplug.h>

+extern struct mutex zonelists_pageset_mutex;
  void get_zone_counts(unsigned long *active, unsigned long *inactive,
  			unsigned long *free);
  void build_all_zonelists(void *data);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b564b6a..b32f3eb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -389,11 +389,6 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
  	int nid;
  	int ret;
  	struct memory_notify arg;
-	/*
-	 * mutex to protect zone->pageset when it's still shared
-	 * in onlined_pages()
-	 */
-	static DEFINE_MUTEX(zone_pageset_mutex);

  	arg.start_pfn = pfn;
  	arg.nr_pages = nr_pages;
@@ -420,14 +415,14 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
  	 * This means the page allocator ignores this zone.
  	 * So, zonelist must be updated after online.
  	 */
-	mutex_lock(&zone_pageset_mutex);
+	mutex_lock(&zonelists_pageset_mutex);
  	if (!populated_zone(zone))
  		need_zonelists_rebuild = 1;

  	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
  		online_pages_range);
  	if (ret) {
-		mutex_unlock(&zone_pageset_mutex);
+		mutex_unlock(&zonelists_pageset_mutex);
  		printk(KERN_DEBUG "online_pages %lx at %lx failed\n",
  			nr_pages, pfn);
  		memory_notify(MEM_CANCEL_ONLINE, &arg);
@@ -441,7 +436,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
  	else
  		zone_pcp_update(zone);

-	mutex_unlock(&zone_pageset_mutex);
+	mutex_unlock(&zonelists_pageset_mutex);
  	setup_per_zone_wmarks();
  	calculate_zone_inactive_ratio(zone);
  	if (onlined_pages) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 72c1211..602c4b7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2434,8 +2434,11 @@ int numa_zonelist_order_handler(ctl_table *table, int write,
  			strncpy((char*)table->data, saved_string,
  				NUMA_ZONELIST_ORDER_LEN);
  			user_zonelist_order = oldval;
-		} else if (oldval != user_zonelist_order)
+		} else if (oldval != user_zonelist_order) {
+			mutex_lock(&zonelists_pageset_mutex);
  			build_all_zonelists(NULL);
+			mutex_unlock(&zonelists_pageset_mutex);
+		}
  	}
  out:
  	mutex_unlock(&zl_order_mutex);
@@ -2778,6 +2781,12 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch);
  static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
  static void setup_zone_pageset(struct zone *zone);

+/*
+ * Global mutex to protect size modification of zonelists
+ * as well as to serialize pageset setup for a new populated zone.
+ */
+DEFINE_MUTEX(zonelists_pageset_mutex);
+
  /* return values int ....just for stop_machine() */
  static __init_refok int __build_all_zonelists(void *data)
  {
@@ -2821,6 +2830,10 @@ static __init_refok int __build_all_zonelists(void *data)
  	return 0;
  }

+/*
+ * Called with zonelists_pageset_mutex held always
+ * unless system_state == SYSTEM_BOOTING.
+ */
  void build_all_zonelists(void *data)
  {
  	set_zonelist_order();
-- 
1.5.6.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
