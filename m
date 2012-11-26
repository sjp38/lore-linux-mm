Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D43536B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 05:14:05 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PATCH 4/5] cpu-hotplug,memory-hotplug: clear cpu_to_node() when offlining the node
Date: Mon, 26 Nov 2012 18:20:26 +0800
Message-Id: <1353925227-1877-5-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
References: <1353925227-1877-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-acpi@vger.kernel.org, x86@kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <len.brown@intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

When the node is offlined, there is no memory/cpu on the node. If a
sleep task runs on a cpu of this node, it will be migrated to the
cpu on the other node. So we can clear cpu-to-node mapping.

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
 mm/memory_hotplug.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b7c30bb..5ae86d7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1669,6 +1669,34 @@ static int check_cpu_on_node(void *data)
 	return 0;
 }
 
+static void unmap_cpu_on_node(void *data)
+{
+#ifdef CONFIG_ACPI_NUMA
+	struct pglist_data *pgdat = data;
+	int cpu;
+
+	for_each_possible_cpu(cpu)
+		if (cpu_to_node(cpu) == pgdat->node_id)
+			numa_clear_node(cpu);
+#endif
+}
+
+static int check_and_unmap_cpu_on_node(void *data)
+{
+	int ret = check_cpu_on_node(data);
+
+	if (ret)
+		return ret;
+
+	/*
+	 * the node will be offlined when we come here, so we can clear
+	 * the cpu_to_node() now.
+	 */
+
+	unmap_cpu_on_node(data);
+	return 0;
+}
+
 /* offline the node if all memory sections of this node are removed */
 void try_offline_node(int nid)
 {
@@ -1695,7 +1723,7 @@ void try_offline_node(int nid)
 		return;
 	}
 
-	if (stop_machine(check_cpu_on_node, NODE_DATA(nid), NULL))
+	if (stop_machine(check_and_unmap_cpu_on_node, NODE_DATA(nid), NULL))
 		return;
 
 	/*
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
