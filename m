Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 6C2946B0006
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:46:49 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 2/5] memory-hotplug: export the function try_offline_node()
Date: Tue, 22 Jan 2013 19:45:53 +0800
Message-Id: <1358855156-6126-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358855156-6126-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358855156-6126-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rjw@sisk.pl, len.brown@intel.com, mingo@redhat.com, tglx@linutronix.de, minchan.kim@gmail.com, rientjes@google.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, Jiang Liu <liuj97@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Peter Zijlstra <peterz@infradead.org>

From: Wen Congyang <wency@cn.fujitsu.com>

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
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memory_hotplug.h |    2 ++
 mm/memory_hotplug.c            |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 69903cc..0b2878e 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -193,6 +193,7 @@ extern void get_page_bootmem(unsigned long ingo, struct page *page,
 
 void lock_memory_hotplug(void);
 void unlock_memory_hotplug(void);
+extern void try_offline_node(int nid);
 
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
@@ -227,6 +228,7 @@ static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
 
 static inline void lock_memory_hotplug(void) {}
 static inline void unlock_memory_hotplug(void) {}
+static inline void try_offline_node(int nid) {}
 
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f0dc9ad..edd1773 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1703,7 +1703,7 @@ static int check_cpu_on_node(void *data)
 }
 
 /* offline the node if all memory sections of this node are removed */
-static void try_offline_node(int nid)
+void try_offline_node(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	unsigned long start_pfn = pgdat->node_start_pfn;
@@ -1759,6 +1759,7 @@ static void try_offline_node(int nid)
 	 */
 	memset(pgdat, 0, sizeof(*pgdat));
 }
+EXPORT_SYMBOL(try_offline_node);
 
 int __ref remove_memory(int nid, u64 start, u64 size)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
