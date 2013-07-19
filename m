Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 549C76B005C
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:01:04 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 16/21] x86, memblock, mem-hotplug: Free hotpluggable memory reserved by memblock.
Date: Fri, 19 Jul 2013 15:59:29 +0800
Message-Id: <1374220774-29974-17-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

We reserved hotpluggable memory in memblock at early time. And when memory
initialization is done, we have to free it to buddy system.

This patch free memory reserved by memblock with flag MEMBLK_HOTPLUGGABLE.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/memblock.h |    1 +
 mm/memblock.c            |   17 +++++++++++++++++
 mm/nobootmem.c           |    3 +++
 3 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 90b49ee..8d71795 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -63,6 +63,7 @@ int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
 int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
+void memblock_free_hotpluggable(void);
 void memblock_trim_memory(phys_addr_t align);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
diff --git a/mm/memblock.c b/mm/memblock.c
index 73fe62d..631b727 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -565,6 +565,23 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 	return __memblock_remove(&memblock.reserved, base, size);
 }
 
+static void __init_memblock memblock_free_flags(unsigned long flags)
+{
+	int i;
+	struct memblock_type *reserved = &memblock.reserved;
+
+	for (i = 0; i < reserved->cnt; i++) {
+		if (reserved->regions[i].flags == flags)
+			memblock_remove_region(reserved, i);
+	}
+}
+
+void __init_memblock memblock_free_hotpluggable()
+{
+	memblock_dbg("memblock: free all hotpluggable memory");
+	memblock_free_flags(MEMBLK_HOTPLUGGABLE);
+}
+
 static int __init_memblock memblock_reserve_region(phys_addr_t base,
 						   phys_addr_t size,
 						   int nid,
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index bdd3fa2..dbfbcb9 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -165,6 +165,9 @@ unsigned long __init free_all_bootmem(void)
 	for_each_online_pgdat(pgdat)
 		reset_node_lowmem_managed_pages(pgdat);
 
+	/* Hotpluggable memory reserved by memblock should also be freed. */
+	memblock_free_hotpluggable();
+
 	/*
 	 * We need to use MAX_NUMNODES instead of NODE_DATA(0)->node_id
 	 *  because in some case like Node0 doesn't have RAM installed
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
