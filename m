Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 64CB1800CA
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 04:45:46 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id v10so3005510pde.18
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 01:45:46 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id pf6si8435688pdb.229.2014.11.07.01.45.43
        for <linux-mm@kvack.org>;
        Fri, 07 Nov 2014 01:45:45 -0800 (PST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 2/2] mem-hotplug: Reset node present pages when hot-adding a new pgdat.
Date: Fri, 7 Nov 2014 17:44:41 +0800
Message-ID: <1415353481-3140-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1415353481-3140-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1415353481-3140-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.co, fabf@skynet.be, nzimmer@sgi.com, wangnan0@huawei.com, vdavydov@parallels.com, toshi.kani@hp.com, phacht@linux.vnet.ibm.com, tj@kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, luto@amacapital.net, hpa@linux.intel.com, aarcange@redhat.com, qiuxishi@huawei.com, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tangchen@cn.fujitsu.com, miaox@cn.fujitsu.com

When onlining memory on node2, node2 zoneinfo and node3 meminfo corrupted:

# for ((i = 2048; i < 2064; i++)); do echo online_movable > /sys/devices/system/node/node2/memory$i/state; done
# cat /sys/devices/system/node/node2/meminfo
Node 2 MemTotal:       33554432 kB
Node 2 MemFree:        33549092 kB
Node 2 MemUsed:            5340 kB
......
# cat /sys/devices/system/node/node3/meminfo
Node 3 MemTotal:              0 kB
Node 3 MemFree:               248 kB      /* corrupted, should be 0 */
Node 3 MemUsed:               0 kB
......

# cat /proc/zoneinfo
......
Node 2, zone   Movable
......
        spanned  8388608
        present  16777216               /* corrupted, should be 8388608 */
        managed  8388608


When memory is hot-added, all the memory is in offline state. So
clear all zone->present_pages because they will be updated in 
online_pages() and offline_pages().

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/memory_hotplug.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8aba12b..26eac61 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1067,6 +1067,14 @@ out:
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
+static void reset_node_present_pages(pg_data_t *pgdat)
+{
+        struct zone *z;
+
+        for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
+                z->present_pages = 0;
+}
+
 /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
 static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 {
@@ -1105,6 +1113,13 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	 */
 	reset_node_managed_pages(pgdat);
 
+	/*
+	 * When memory is hot-added, all the memory is in offline state. So
+	 * clear all zones' present_pages because they will be updated in
+	 * online_pages() and offline_pages().
+	 */
+	reset_node_present_pages(pgdat);
+
 	return pgdat;
 }
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
