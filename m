Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D5B1E6B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 02:19:38 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so9297958pab.5
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 23:19:38 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id du8si25234535pdb.189.2014.08.18.23.19.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 Aug 2014 23:19:37 -0700 (PDT)
Message-ID: <53F2EBCC.9020200@huawei.com>
Date: Tue, 19 Aug 2014 14:16:44 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mem-hotplug: fix boot failed in case all the nodes are hotpluggable
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davej@redhat.com, Tang Chen <tangchen@cn.fujitsu.com>, guz.fnst@cn.fujitsu.com, Thomas Gleixner <tglx@linutronix.de>, Andrew
 Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

If all the nodes are marked hotpluggable flag, alloc node data will fail.
Because __next_mem_range_rev() will skip the hotpluggable memory regions.
numa_clear_kernel_node_hotplug() is called after alloc node data.

numa_init()
	...
	ret = init_func();  // this will mark hotpluggable flag from SRAT
	...
	memblock_set_bottom_up(false);
	...
	ret = numa_register_memblks(&numa_meminfo);  // this will alloc node data(pglist_data) 
	...
	numa_clear_kernel_node_hotplug();  // in case all the nodes are hotpluggable
	...

numa_register_memblks()
	setup_node_data()
		memblock_find_in_range_node()
			__memblock_find_range_top_down()
				for_each_mem_range_rev()
					__next_mem_range_rev()

This patch moves numa_clear_kernel_node_hotplug() into numa_register_memblks(),
clear kernel node hotpluggable flag before alloc node data, then alloc node data
won't fail even all the nodes are hotpluggable.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 arch/x86/mm/numa.c |   88 ++++++++++++++++++++++++++--------------------------
 1 files changed, 44 insertions(+), 44 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index a32b706..f7ebd97 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -478,6 +478,41 @@ static bool __init numa_meminfo_cover_memory(const struct numa_meminfo *mi)
 	return true;
 }
 
+static void __init numa_clear_kernel_node_hotplug(void)
+{
+	int i, nid;
+	nodemask_t numa_kernel_nodes = NODE_MASK_NONE;
+	unsigned long start, end;
+	struct memblock_region *r;
+
+	/*
+	 * At this time, all memory regions reserved by memblock are
+	 * used by the kernel. Set the nid in memblock.reserved will
+	 * mark out all the nodes the kernel resides in.
+	 */
+	for (i = 0; i < numa_meminfo.nr_blks; i++) {
+		struct numa_memblk *mb = &numa_meminfo.blk[i];
+		memblock_set_node(mb->start, mb->end - mb->start,
+				  &memblock.reserved, mb->nid);
+	}
+
+	/* Mark all kernel nodes. */
+	for_each_memblock(reserved, r)
+		node_set(r->nid, numa_kernel_nodes);
+
+	/* Clear MEMBLOCK_HOTPLUG flag for memory in kernel nodes. */
+	for (i = 0; i < numa_meminfo.nr_blks; i++) {
+		nid = numa_meminfo.blk[i].nid;
+		if (!node_isset(nid, numa_kernel_nodes))
+			continue;
+
+		start = numa_meminfo.blk[i].start;
+		end = numa_meminfo.blk[i].end;
+
+		memblock_clear_hotplug(start, end - start);
+	}
+}
+
 static int __init numa_register_memblks(struct numa_meminfo *mi)
 {
 	unsigned long uninitialized_var(pfn_align);
@@ -496,6 +531,15 @@ static int __init numa_register_memblks(struct numa_meminfo *mi)
 	}
 
 	/*
+	 * At very early time, the kernel have to use some memory such as
+	 * loading the kernel image. We cannot prevent this anyway. So any
+	 * node the kernel resides in should be un-hotpluggable.
+	 *
+	 * And when we come here, alloc node data won't fail.
+	 */
+	numa_clear_kernel_node_hotplug();
+
+	/*
 	 * If sections array is gonna be used for pfn -> nid mapping, check
 	 * whether its granularity is fine enough.
 	 */
@@ -554,41 +598,6 @@ static void __init numa_init_array(void)
 	}
 }
 
-static void __init numa_clear_kernel_node_hotplug(void)
-{
-	int i, nid;
-	nodemask_t numa_kernel_nodes = NODE_MASK_NONE;
-	unsigned long start, end;
-	struct memblock_region *r;
-
-	/*
-	 * At this time, all memory regions reserved by memblock are
-	 * used by the kernel. Set the nid in memblock.reserved will
-	 * mark out all the nodes the kernel resides in.
-	 */
-	for (i = 0; i < numa_meminfo.nr_blks; i++) {
-		struct numa_memblk *mb = &numa_meminfo.blk[i];
-		memblock_set_node(mb->start, mb->end - mb->start,
-				  &memblock.reserved, mb->nid);
-	}
-
-	/* Mark all kernel nodes. */
-	for_each_memblock(reserved, r)
-		node_set(r->nid, numa_kernel_nodes);
-
-	/* Clear MEMBLOCK_HOTPLUG flag for memory in kernel nodes. */
-	for (i = 0; i < numa_meminfo.nr_blks; i++) {
-		nid = numa_meminfo.blk[i].nid;
-		if (!node_isset(nid, numa_kernel_nodes))
-			continue;
-
-		start = numa_meminfo.blk[i].start;
-		end = numa_meminfo.blk[i].end;
-
-		memblock_clear_hotplug(start, end - start);
-	}
-}
-
 static int __init numa_init(int (*init_func)(void))
 {
 	int i;
@@ -643,15 +652,6 @@ static int __init numa_init(int (*init_func)(void))
 	}
 	numa_init_array();
 
-	/*
-	 * At very early time, the kernel have to use some memory such as
-	 * loading the kernel image. We cannot prevent this anyway. So any
-	 * node the kernel resides in should be un-hotpluggable.
-	 *
-	 * And when we come here, numa_init() won't fail.
-	 */
-	numa_clear_kernel_node_hotplug();
-
 	return 0;
 }
 
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
