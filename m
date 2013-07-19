Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 46FD36B003A
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 04:01:00 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 03/21] x86, acpi, numa, mem-hotplug: Introduce MEMBLK_HOTPLUGGABLE to reserve hotpluggable memory.
Date: Fri, 19 Jul 2013 15:59:16 +0800
Message-Id: <1374220774-29974-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Pages used by the kernel cannot be migrated. As a result, hotpluggable
memory used by the kernel cannot be hot-removed. So for memory
hotplug users, the kernel should not use hotpluggable memory.

Since now we have flags in memblock, we introduce a MEMBLK_HOTPLUGGABLE
flag to mark hotpluggable memory. At the early time, we use memblock to
reserve hotpluggable memory, and mark it with MEMBLK_HOTPLUGGABLE flag.
When the system is up, we free these memory with MEMBLK_HOTPLUGGABLE
flag to the buddy, and arrange them into ZONE_MOVABLE. In this way, the
kernel won't be able to use it.

This patch introduces MEMBLK_HOTPLUGGABLE flag, and an API to reserve
memory with MEMBLK_HOTPLUGGABLE flag. This is a preparation for the
coming patches.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 include/linux/memblock.h |    2 ++
 mm/memblock.c            |    6 ++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 93f3453..90b49ee 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -21,6 +21,7 @@
 
 /* Definition of memblock flags. */
 #define MEMBLK_FLAGS_DEFAULT	0x0	/* default flag */
+#define MEMBLK_HOTPLUGGABLE	0x1	/* hotpluggable region */
 
 struct memblock_region {
 	phys_addr_t base;
@@ -61,6 +62,7 @@ int memblock_add(phys_addr_t base, phys_addr_t size);
 int memblock_remove(phys_addr_t base, phys_addr_t size);
 int memblock_free(phys_addr_t base, phys_addr_t size);
 int memblock_reserve(phys_addr_t base, phys_addr_t size);
+int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
 void memblock_trim_memory(phys_addr_t align);
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
diff --git a/mm/memblock.c b/mm/memblock.c
index 9e871e9..73fe62d 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -586,6 +586,12 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 				       MEMBLK_FLAGS_DEFAULT);
 }
 
+int __init_memblock memblock_reserve_hotpluggable(phys_addr_t base,
+						  phys_addr_t size, int nid)
+{
+	return memblock_reserve_region(base, size, nid, MEMBLK_HOTPLUGGABLE);
+}
+
 /**
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
