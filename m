Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4E4666B0036
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:13:23 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 19/21] x86, numa: Save nid when reserve memory into memblock.reserved[].
Date: Fri, 19 Jul 2013 15:59:32 +0800
Message-Id: <1374220774-29974-20-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

We have introduced numa_sync_memblock_nid to synchronize nid info in
memblock.reserved[] and numa_meminfo. But memblock_reserve() always
reserve memory with MAX_NUMNODES, even after numa_meminfo has been
initialized.

So this patch improves memblock_reserve() to reserve memory with
correct nid.

Reported-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memblock.h |    1 +
 include/linux/mm.h       |    9 +++++++++
 mm/memblock.c            |   11 +++++++++--
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 8d71795..d520015 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -63,6 +63,7 @@ int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
 int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
+int memblock_reserve_node(phys_addr_t base, phys_addr_t size, int nid);
 void memblock_free_hotpluggable(void);
 void memblock_trim_memory(phys_addr_t align);
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e0c8528..baa1aac 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1665,6 +1665,15 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
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
index 631b727..1f5dc12 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -597,12 +597,19 @@ static int __init_memblock memblock_reserve_region(phys_addr_t base,
 	return memblock_add_region(_rgn, base, size, nid, flags);
 }
 
-int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
+int __init_memblock memblock_reserve_node(phys_addr_t base,
+					  phys_addr_t size, int nid)
 {
-	return memblock_reserve_region(base, size, MAX_NUMNODES,
+	return memblock_reserve_region(base, size, nid,
 				       MEMBLK_FLAGS_DEFAULT);
 }
 
+int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
+{
+	int nid = early_numa_find_range_nid(base, size);
+	return memblock_reserve_node(base, size, nid);
+}
+
 int __init_memblock memblock_reserve_hotpluggable(phys_addr_t base,
 						  phys_addr_t size, int nid)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
