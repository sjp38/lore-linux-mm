Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC80280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 05:46:32 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so7005270pdb.27
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 02:46:31 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id rp11si8932289pab.22.2014.10.31.02.46.29
        for <linux-mm@kvack.org>;
        Fri, 31 Oct 2014 02:46:31 -0700 (PDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 2/2] mem-hotplug: Fix wrong check for zone->pageset initialization in online_pages().
Date: Fri, 31 Oct 2014 17:46:52 +0800
Message-ID: <1414748812-22610-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1414748812-22610-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1414748812-22610-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.co, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, luto@amacapital.net, hpa@linux.intel.com, aarcange@redhat.com, qiuxishi@huawei.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com, Gu Zheng <guz.fnst@cn.fujitsu.com>

When we are doing memory hot-add, the following functions are called:

add_memory()
|--> hotadd_new_pgdat()
     |--> free_area_init_node()
          |--> free_area_init_core()
               |--> zone->present_pages = realsize;           /* 1. zone is populated */
                    |--> zone_pcp_init()
                         |--> zone->pageset = &boot_pageset;  /* 2. zone->pageset is set to boot_pageset */

There are two problems here:
1. Zones could be populated before any memory is onlined.
2. All the zones on a newly added node have the same pageset pointing to boot_pageset.

The above two problems will result in the following problem:
When we online memory on one node, e.g node2, the following code is executed:

online_pages()
{
        ......
        if (!populated_zone(zone)) {
                need_zonelists_rebuild = 1;
                build_all_zonelists(NULL, zone);
        }
        ......
}

Because of problem 1, the zone has been populated, and the build_all_zonelists()
                      will never called. zone->pageset won't be updated.
Because of problem 2, All the zones on a newly added node have the same pageset
                      pointing to boot_pageset.
And as a result, when we online memory on node2, node3's meminfo will corrupt.
Pages on node2 may be freed to node3.

# for ((i = 2048; i < 2064; i++)); do echo online_movable > /sys/devices/system/node/node2/memory$i/state; done
# cat /sys/devices/system/node/node2/meminfo
Node 2 MemTotal:       33554432 kB
Node 2 MemFree:        33549092 kB
Node 2 MemUsed:            5340 kB
......
# cat /sys/devices/system/node/node3/meminfo
Node 3 MemTotal:              0 kB
Node 3 MemFree:               248 kB                    /* corrupted */
Node 3 MemUsed:               0 kB
......

We have to populate some zones before onlining memory, otherwise no memory could be onlined.
So when onlining pages, we should also check if zone->pageset is pointing to boot_pageset.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/mm.h  | 1 +
 mm/memory_hotplug.c | 6 +++++-
 mm/page_alloc.c     | 5 +++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 02d11ee..83e6505 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1732,6 +1732,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
 
+extern bool zone_pcp_initialized(struct zone *zone);
 extern void zone_pcp_update(struct zone *zone);
 extern void zone_pcp_reset(struct zone *zone);
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3ab01b2..bc0de0f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1013,9 +1013,13 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	 * If this zone is not populated, then it is not in zonelist.
 	 * This means the page allocator ignores this zone.
 	 * So, zonelist must be updated after online.
+	 *
+	 * If this zone is populated, zone->pageset could be initialized
+	 * to boot_pageset for the first time a node is added. If so,
+	 * zone->pageset should be allocated.
 	 */
 	mutex_lock(&zonelists_mutex);
-	if (!populated_zone(zone)) {
+	if (!populated_zone(zone) || !zone_pcp_initialized(zone)) {
 		need_zonelists_rebuild = 1;
 		build_all_zonelists(NULL, zone);
 	}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 736d8e1..4ff1540 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6456,6 +6456,11 @@ void __meminit zone_pcp_update(struct zone *zone)
 }
 #endif
 
+bool zone_pcp_initialized(struct zone *zone)
+{
+	return (zone->pageset != &boot_pageset);
+}
+
 void zone_pcp_reset(struct zone *zone)
 {
 	unsigned long flags;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
