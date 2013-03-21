Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 8A0EB6B006E
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 05:18:45 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH part2 1/4] x86, mm, numa, acpi: Introduce numa_meminfo_all to store all the numa meminfo.
Date: Thu, 21 Mar 2013 17:21:13 +0800
Message-Id: <1363857676-30694-2-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1363857676-30694-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1363857676-30694-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, guz.fnst@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Now, Yinghai has tried to allocate pagetables and vmemmap pages in local
node. If we limit memblock allocation in movablemem_map.map[], we have to
exclude the pagetables and vmemmap pages.

So we need the following sequence:
1) Parse SRAT, store numa_meminfo.
2) Initialize memory mapping, allocate pagetables and vmemmap pages in local
   node. And reserve these memory with memblock.
3) Sanitize movablemem_map.map[], exclude the pagetables and vmemmap pages.

When parsing SRAT, we added memory ranges into numa_meminfo. But in
numa_cleanup_meminfo(), it removed all the unused memory from numa_meminfo.

         const u64 low = 0;
         const u64 high = PFN_PHYS(max_pfn);

         /* first, trim all entries */
         for (i = 0; i < mi->nr_blks; i++) {
                 struct numa_memblk *bi = &mi->blk[i];

                 /* make sure all blocks are inside the limits */
                 bi->start = max(bi->start, low);
                 bi->end = min(bi->end, high);

                 /* and there's no empty block */
                 if (bi->start >= bi->end)
                         numa_remove_memblk_from(i--, mi);
         }

So numa_meminfo doesn't have the whole memory info.

In order to sanitize movablemem_map.map[] after memory mapping initialziation,
we need the whole SRAT info.

So this patch introduces global variable numa_meminfo_all to store the whole
numa memory info.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 4f754e6..4cf3b49 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -28,12 +28,20 @@ nodemask_t numa_nodes_parsed __initdata;
 struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
 EXPORT_SYMBOL(node_data);
 
+/*e820 mapped memory info */
 static struct numa_meminfo numa_meminfo
 #ifndef CONFIG_MEMORY_HOTPLUG
 __initdata
 #endif
 ;
 
+/* All memory info */
+static struct numa_meminfo numa_meminfo_all
+#ifndef CONFIG_MEMORY_HOTPLUG
+__initdata
+#endif
+;
+
 static int numa_distance_cnt;
 static u8 *numa_distance;
 
@@ -599,10 +607,15 @@ static int __init numa_init(int (*init_func)(void))
 
 	nodes_clear(numa_nodes_parsed);
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
+	memset(&numa_meminfo_all, 0, sizeof(numa_meminfo));
 
 	ret = init_func();
 	if (ret < 0)
 		return ret;
+
+	/* Store the whole memory info before cleanup numa_meminfo. */
+	memcpy(&numa_meminfo_all, &numa_meminfo, sizeof(numa_meminfo));
+
 	ret = numa_cleanup_meminfo(&numa_meminfo);
 	if (ret < 0)
 		return ret;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
