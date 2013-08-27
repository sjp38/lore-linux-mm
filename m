Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 157996B003C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 05:39:16 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 05/11] memblock: Introduce allocation order to memblock.
Date: Tue, 27 Aug 2013 17:37:42 +0800
Message-Id: <1377596268-31552-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

The Linux kernel cannot migrate pages used by the kernel. As a result, kernel
pages cannot be hot-removed. So we cannot allocate hotpluggable memory for
the kernel.

ACPI SRAT (System Resource Affinity Table) contains the memory hotplug info.
But before SRAT is parsed, memblock has already started to allocate memory
for the kernel. So we need to prevent memblock from doing this.

In a memory hotplug system, any numa node the kernel resides in should
be unhotpluggable. And for a modern server, each node could have at least
16GB memory. So memory around the kernel image is highly likely unhotpluggable.

So the basic idea is: Allocate memory from the end of the kernel image and
to the higher memory. Since memory allocation before SRAT is parsed won't
be too much, it could highly likely be in the same node with kernel image.

The current memblock can only allocate memory from high address to low.
So this patch introduces the allocation order to memblock. It could be
used to tell memblock to allocate memory from high to low or from low
to high.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/memblock.h |   15 +++++++++++++++
 mm/memblock.c            |   13 +++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index cabd685..f233c1f 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -19,6 +19,11 @@
 
 #define INIT_MEMBLOCK_REGIONS	128
 
+/* Allocation order. */
+#define MEMBLOCK_ORDER_HIGH_TO_LOW	0
+#define MEMBLOCK_ORDER_LOW_TO_HIGH	1
+#define MEMBLOCK_ORDER_DEFAULT		MEMBLOCK_ORDER_HIGH_TO_LOW
+
 struct memblock_region {
 	phys_addr_t base;
 	phys_addr_t size;
@@ -35,6 +40,7 @@ struct memblock_type {
 };
 
 struct memblock {
+	int current_order;	/* allocate from higher or lower address */
 	phys_addr_t current_limit_low;	/* lower boundary of accessable range */
 	phys_addr_t current_limit_high;	/* upper boundary of accessable range */
 	struct memblock_type memory;
@@ -174,6 +180,15 @@ static inline void memblock_dump_all(void)
 }
 
 /**
+ * memblock_set_current_order - Set the current allocation order to allow
+ *                         allocating memory from higher to lower address or
+ *                         from lower to higher address
+ * @order: In which order to allocate memory. Could be
+ *         MEMBLOCK_ORDER_{HIGH_TO_LOW|LOW_TO_HIGH}
+ */
+void memblock_set_current_order(int order);
+
+/**
  * memblock_set_current_limit_low - Set the current allocation lower limit to
  *                         allow limiting allocations to what is currently
  *                         accessible during boot
diff --git a/mm/memblock.c b/mm/memblock.c
index 54c1c2e..8f1e2d4 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -32,6 +32,7 @@ struct memblock memblock __initdata_memblock = {
 	.reserved.cnt		= 1,	/* empty dummy entry */
 	.reserved.max		= INIT_MEMBLOCK_REGIONS,
 
+	.current_order		= MEMBLOCK_ORDER_DEFAULT,
 	.current_limit_low	= 0,
 	.current_limit_high	= MEMBLOCK_ALLOC_ANYWHERE,
 };
@@ -989,6 +990,18 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
 	}
 }
 
+void __init_memblock memblock_set_current_order(int order)
+{
+	if (order != MEMBLOCK_ORDER_HIGH_TO_LOW &&
+	    order != MEMBLOCK_ORDER_LOW_TO_HIGH) {
+		pr_warn("memblock: Failed to set allocation order. "
+			"Invalid order type: %d\n", order);
+		return;
+	}
+
+	memblock.current_order = order;
+}
+
 void __init_memblock memblock_set_current_limit_low(phys_addr_t limit)
 {
 	memblock.current_limit_low = limit;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
