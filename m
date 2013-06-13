Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 353308D0024
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:28:01 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part2 PATCH v4 08/15] x86, numa: Save nid when reserve memory into memblock.reserved[].
Date: Thu, 13 Jun 2013 21:03:32 +0800
Message-Id: <1371128619-8987-9-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128619-8987-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since we introduced numa_sync_memblock_nid synchronize nid info in
memblock.reserved[] and numa_meminfo, when numa_meminfo has been
initialized, we need to save the nid into memblock.reserved[] when
we reserve memory.

Reported-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memblock.h |    1 +
 include/linux/mm.h       |    9 +++++++++
 mm/memblock.c            |   10 +++++++++-
 3 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 93f3453..f558590 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -61,6 +61,7 @@ int memblock_add(phys_addr_t base, phys_addr_t size);
 int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
+int memblock_reserve_node(phys_addr_t base, phys_addr_t size, int nid);
 void memblock_trim_memory(phys_addr_t align);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b827743..4a94b56 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1662,6 +1662,15 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 #endif
 
+#ifdef CONFIG_NUMA
+int __init early_numa_find_range_nid(u64 start, u64 size);
+#else
+static inline int __init early_numa_find_range_nid(u64 start, u64 size)
+{
+	return 0;
+}
+#endif
+
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
diff --git a/mm/memblock.c b/mm/memblock.c
index 9e871e9..cc55ff0 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -580,9 +580,17 @@ static int __init_memblock memblock_reserve_region(phys_addr_t base,
 	return memblock_add_region(_rgn, base, size, nid, flags);
 }
 
+int __init_memblock memblock_reserve_node(phys_addr_t base,
+					  phys_addr_t size, int nid)
+{
+	return memblock_reserve_region(base, size, nid,
+				       MEMBLK_FLAGS_DEFAULT);
+}
+
 int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
-	return memblock_reserve_region(base, size, MAX_NUMNODES,
+	int nid = early_numa_find_range_nid(base, size);
+	return memblock_reserve_region(base, size, nid,
 				       MEMBLK_FLAGS_DEFAULT);
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
