Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 847146B00C5
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 05:18:42 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 11/13] x86, memblock, mem-hotplug: Free hotpluggable memory reserved by memblock.
Date: Tue, 30 Apr 2013 17:21:21 +0800
Message-Id: <1367313683-10267-12-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We reserved hotpluggable memory in memblock. And when memory initialization
is done, we have to free it to buddy system.

This patch free memory reserved by memblock with flag MEMBLK_HOTPLUGGABLE.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memblock.h |    1 +
 mm/memblock.c            |   20 ++++++++++++++++++++
 mm/nobootmem.c           |    3 +++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 0f01930..08c761d 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -69,6 +69,7 @@ int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
 int memblock_reserve_local_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
+void memblock_free_hotpluggable(void);
 void memblock_trim_memory(phys_addr_t align);
 void memblock_mark_kernel_nodes(void);
 bool memblock_is_kernel_node(int nid);
diff --git a/mm/memblock.c b/mm/memblock.c
index 0c55588..54de398 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -568,6 +568,26 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
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
+	unsigned long flags = 1 << MEMBLK_HOTPLUGGABLE;
+
+	memblock_dbg("memblock: free all hotpluggable memory");
+
+	memblock_free_flags(flags);
+}
+
 static int __init_memblock memblock_reserve_region(phys_addr_t base,
 						   phys_addr_t size,
 						   int nid,
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 5e07d36..cd85604 100644
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
