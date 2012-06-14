Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C8D466B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:54:00 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [PATCH] trivial, memory hotplug: add kswapd_is_running() for better readability
Date: Thu, 14 Jun 2012 16:49:36 +0800
Message-ID: <1339663776-196-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <4FD97718.6060008@kernel.org>
References: <4FD97718.6060008@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Keping Chen <chenkeping@huawei.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

Add kswapd_is_running() to check whether the kswapd worker thread is already
running before calling kswapd_run() when onlining memory pages.

It's based on a draft version from Minchan Kim <minchan@kernel.org>.

Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 include/linux/swap.h |    5 +++++
 mm/memory_hotplug.c  |    3 ++-
 mm/vmscan.c          |    3 +--
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c84ec68..36249d5 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -301,6 +301,11 @@ static inline void scan_unevictable_unregister_node(struct node *node)
 
 extern int kswapd_run(int nid);
 extern void kswapd_stop(int nid);
+static inline bool kswapd_is_running(int nid)
+{
+	return !!(NODE_DATA(nid)->kswapd);
+}
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern int mem_cgroup_swappiness(struct mem_cgroup *mem);
 #else
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0d7e3ec..88e479d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -522,7 +522,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 	init_per_zone_wmark_min();
 
 	if (onlined_pages) {
-		kswapd_run(zone_to_nid(zone));
+		if (!kswapd_is_running(zone_to_nid(zone)))
+			kswapd_run(zone_to_nid(zone));
 		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7585101..3dafdbe 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2941,8 +2941,7 @@ int kswapd_run(int nid)
 	pg_data_t *pgdat = NODE_DATA(nid);
 	int ret = 0;
 
-	if (pgdat->kswapd)
-		return 0;
+	BUG_ON(pgdat->kswapd);
 
 	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
 	if (IS_ERR(pgdat->kswapd)) {
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
