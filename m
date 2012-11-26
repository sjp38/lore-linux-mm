Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 59C6F6B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 05:49:50 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PATCH 2/5] memory-hotplug: export the function try_offline_node()
Date: Mon, 26 Nov 2012 18:20:24 +0800
Message-Id: <1353925227-1877-3-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
References: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-acpi@vger.kernel.org, x86@kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <len.brown@intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

The node will be offlined when all memory/cpu on the node
have been hotremoved. So we need the function try_offline_node()
in cpu-hotplug path.

If the memory-hotplug is disabled, and cpu-hotplug is enabled
1. no memory no the node
   we don't online the node, and cpu's node is the nearest node.
2. the node contains some memory
   the node has been onlined, and cpu's node is still needed
   to migrate the sleep task on the cpu to the same node.
So we do nothing in try_offline_node() in this case.

Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 include/linux/memory_hotplug.h | 2 ++
 mm/memory_hotplug.c            | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ad2dd17..48ece75 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -187,6 +187,7 @@ extern void get_page_bootmem(unsigned long ingo, struct page *page,
 
 void lock_memory_hotplug(void);
 void unlock_memory_hotplug(void);
+extern void try_offline_node(int nid);
 
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
@@ -221,6 +222,7 @@ static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
 
 static inline void lock_memory_hotplug(void) {}
 static inline void unlock_memory_hotplug(void) {}
+static inline void try_offline_node(int nid) {}
 
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 52db031..b7c30bb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1670,7 +1670,7 @@ static int check_cpu_on_node(void *data)
 }
 
 /* offline the node if all memory sections of this node are removed */
-static void try_offline_node(int nid)
+void try_offline_node(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
@@ -1720,6 +1720,7 @@ static void try_offline_node(int nid)
 	arch_refresh_nodedata(nid, NULL);
 	arch_free_nodedata(pgdat);
 }
+EXPORT_SYMBOL(try_offline_node);
 
 int __ref remove_memory(int nid, u64 start, u64 size)
 {
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
