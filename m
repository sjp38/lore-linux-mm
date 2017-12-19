Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 401D26B025F
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 01:41:46 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a5so10713900pgu.1
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 22:41:46 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id k91si10570919pld.115.2017.12.18.22.41.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 22:41:45 -0800 (PST)
From: Kemi Wang <kemi.wang@intel.com>
Subject: [PATCH v2 4/5] mm: use node_page_state_snapshot to avoid deviation
Date: Tue, 19 Dec 2017 14:39:25 +0800
Message-Id: <1513665566-4465-5-git-send-email-kemi.wang@intel.com>
In-Reply-To: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Kemi Wang <kemi.wang@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

To avoid deviation, this patch uses node_page_state_snapshot instead of
node_page_state for node page stats query.
e.g. cat /proc/zoneinfo
     cat /sys/devices/system/node/node*/vmstat
     cat /sys/devices/system/node/node*/numastat

As it is a slow path and would not be read frequently, I would worry about
it.

Signed-off-by: Kemi Wang <kemi.wang@intel.com>
---
 drivers/base/node.c | 17 ++++++++++-------
 mm/vmstat.c         |  2 +-
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index a045ea1..cf303f8 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -169,12 +169,15 @@ static ssize_t node_read_numastat(struct device *dev,
 		       "interleave_hit %lu\n"
 		       "local_node %lu\n"
 		       "other_node %lu\n",
-		       node_page_state(NODE_DATA(dev->id), NUMA_HIT),
-		       node_page_state(NODE_DATA(dev->id), NUMA_MISS),
-		       node_page_state(NODE_DATA(dev->id), NUMA_FOREIGN),
-		       node_page_state(NODE_DATA(dev->id), NUMA_INTERLEAVE_HIT),
-		       node_page_state(NODE_DATA(dev->id), NUMA_LOCAL),
-		       node_page_state(NODE_DATA(dev->id), NUMA_OTHER));
+		       node_page_state_snapshot(NODE_DATA(dev->id), NUMA_HIT),
+		       node_page_state_snapshot(NODE_DATA(dev->id), NUMA_MISS),
+		       node_page_state_snapshot(NODE_DATA(dev->id),
+			       NUMA_FOREIGN),
+		       node_page_state_snapshot(NODE_DATA(dev->id),
+			       NUMA_INTERLEAVE_HIT),
+		       node_page_state_snapshot(NODE_DATA(dev->id), NUMA_LOCAL),
+		       node_page_state_snapshot(NODE_DATA(dev->id),
+			       NUMA_OTHER));
 }
 
 static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
@@ -194,7 +197,7 @@ static ssize_t node_read_vmstat(struct device *dev,
 	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
 		n += sprintf(buf+n, "%s %lu\n",
 			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-			     node_page_state(pgdat, i));
+			     node_page_state_snapshot(pgdat, i));
 
 	return n;
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 64e08ae..d65f28d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1466,7 +1466,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
 			seq_printf(m, "\n      %-12s %lu",
 				vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
-				node_page_state(pgdat, i));
+				node_page_state_snapshot(pgdat, i));
 		}
 	}
 	seq_printf(m,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
