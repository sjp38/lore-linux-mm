Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id C41338D0027
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:01 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part2 PATCH v4 07/15] x86, numa: Synchronize nid info in memblock.reserve with numa_meminfo.
Date: Thu, 13 Jun 2013 21:03:31 +0800
Message-Id: <1371128619-8987-8-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Vasilis Liaskovitis found that before we parse SRAT and fulfill
numa_meminfo, the nids of all the regions in memblock.reserve[]
are MAX_NUMNODES. In this case, we cannot mark the nodes which
the kernel resides in correctly.

So after we parse SRAT and fulfill nume_meminfo, synchronize the
nid info to memblock.reserve[] immediately.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 arch/x86/mm/numa.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 05e4443..005a422 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -595,6 +595,48 @@ static void __init numa_init_array(void)
 	}
 }
 
+/*
+ * early_numa_find_range_nid - Find nid for a memory range at early time.
+ * @start: start address of the memory range (physaddr)
+ * @size: size of the memory range
+ *
+ * Return nid of the memory range, or MAX_NUMNODES if it failed to find the nid.
+ *
+ * NOTE: This function uses numa_meminfo to find the range's nid, so it should
+ *       be called after numa_meminfo has been initialized.
+ */
+int __init early_numa_find_range_nid(u64 start, u64 size)
+{
+	int i;
+	struct numa_meminfo *mi = &numa_meminfo;
+
+	for (i = 0; i < mi->nr_blks; i++)
+		if (start >= mi->blk[i].start &&
+		    (start + size - 1) <= mi->blk[i].end)
+			return mi->blk[i].nid;
+
+	return MAX_NUMNODES;
+}
+
+/*
+ * numa_sync_memblock_nid - Synchronize nid info in memblock.reserve[] to
+ *                          numa_meminfo.
+ *
+ * This function will synchronize the nid fields of regions in
+ * memblock.reserve[] to numa_meminfo.
+ */
+static void __init numa_sync_memblock_nid()
+{
+	int i, nid;
+	struct memblock_type *res = &memblock.reserved;
+
+	for (i = 0; i < res->cnt; i++) {
+		nid = early_numa_find_range_nid(res->regions[i].base,
+						res->regions[i].size);
+		memblock_set_region_node(&res->regions[i], nid);
+	}
+}
+
 static int __init numa_init(int (*init_func)(void))
 {
 	int i;
@@ -617,6 +659,13 @@ static int __init numa_init(int (*init_func)(void))
 	if (ret < 0)
 		return ret;
 
+	/*
+	 * Before fulfilling numa_meminfo, all regions allocated by memblock
+	 * are reserved with nid MAX_NUMNODES because there is no numa node
+	 * info at such an early time. Now, fill the correct nid into memblock.
+	 */
+	numa_sync_memblock_nid();
+
 	return 0;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
