Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BBB1B6B0070
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 05:00:09 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v6 15/15] memory-hotplug: Do not allocate pdgat if it was not freed when offline.
Date: Wed, 9 Jan 2013 17:32:39 +0800
Message-Id: <1357723959-5416-16-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Since there is no way to guarentee the address of pgdat/zone is not
on stack of any kernel threads or used by other kernel objects
without reference counting or other symchronizing method, we cannot
reset node_data and free pgdat when offlining a node. Just reset pgdat
to 0 and reuse the memory when the node is online again.

The problem is suggested by Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
The idea is from Wen Congyang <wency@cn.fujitsu.com>

NOTE: If we don't reset pgdat to 0, the WARN_ON in free_area_init_node()
      will be triggered.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8b67752..8aa2b56 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1015,11 +1015,14 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	unsigned long zholes_size[MAX_NR_ZONES] = {0};
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 
-	pgdat = arch_alloc_nodedata(nid);
-	if (!pgdat)
-		return NULL;
+	pgdat = NODE_DATA(nid);
+	if (!pgdat) {
+		pgdat = arch_alloc_nodedata(nid);
+		if (!pgdat)
+			return NULL;
 
-	arch_refresh_nodedata(nid, pgdat);
+		arch_refresh_nodedata(nid, pgdat);
+	}
 
 	/* we can use NODE_DATA(nid) from here */
 
@@ -1072,7 +1075,7 @@ out:
 int __ref add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat = NULL;
-	int new_pgdat = 0;
+	int new_pgdat = 0, new_node = 0;
 	struct resource *res;
 	int ret;
 
@@ -1083,12 +1086,13 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	if (!res)
 		goto out;
 
-	if (!node_online(nid)) {
+	new_pgdat = NODE_DATA(nid) ? 0 : 1;
+	new_node = node_online(nid) ? 0 : 1;
+	if (new_node) {
 		pgdat = hotadd_new_pgdat(nid, start);
 		ret = -ENOMEM;
 		if (!pgdat)
 			goto error;
-		new_pgdat = 1;
 	}
 
 	/* call arch's memory hotadd */
@@ -1100,7 +1104,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 	/* we online node here. we can't roll back from here. */
 	node_set_online(nid);
 
-	if (new_pgdat) {
+	if (new_node) {
 		ret = register_one_node(nid);
 		/*
 		 * If sysfs file of new node can't create, cpu on the node
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
