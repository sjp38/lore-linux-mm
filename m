Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 418166B0005
	for <linux-mm@kvack.org>; Mon,  8 Aug 2016 21:49:46 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 4so603996oih.2
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 18:49:46 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id b204si577100itc.126.2016.08.08.18.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Aug 2016 18:49:45 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id ti13so159889pac.0
        for <linux-mm@kvack.org>; Mon, 08 Aug 2016 18:49:45 -0700 (PDT)
From: AKASHI Takahiro <takahiro.akashi@linaro.org>
Subject: [PATCH v24 2/9] memblock: add memblock_cap_memory_range()
Date: Tue,  9 Aug 2016 10:55:26 +0900
Message-Id: <20160809015526.28479-1-takahiro.akashi@linaro.org>
In-Reply-To: <20160809015248.28414-2-takahiro.akashi@linaro.org>
References: <20160809015248.28414-2-takahiro.akashi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com
Cc: james.morse@arm.com, geoff@infradead.org, bauerman@linux.vnet.ibm.com, dyoung@redhat.com, mark.rutland@arm.com, kexec@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, AKASHI Takahiro <takahiro.akashi@linaro.org>

Crash dump kernel uses only a limited range of memory as System RAM.
On arm64 implementation, a new device tree property,
"linux,usable-memory-range," is used to notify crash dump kernel of
this range.[1]
But simply excluding all the other regions, whatever their memory types
are, doesn't work, especially, on the systems with ACPI. Since some of
such regions will be later mapped as "device memory" by ioremap()/
acpi_os_ioremap(), it can cause errors like unalignment accesses.[2]
This issue is akin to the one reported in [3].

So this patch follows Chen's approach, and implements a new function,
memblock_cap_memory_range(), which will exclude only the memory regions
that are not marked "NOMAP" from memblock.memory.

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2016-July/442817.html
[2] http://lists.infradead.org/pipermail/linux-arm-kernel/2016-July/444165.html
[3] http://lists.infradead.org/pipermail/linux-arm-kernel/2016-July/443356.html

Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
---
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 28 ++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 2925da2..8002f98 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -333,6 +333,7 @@ phys_addr_t memblock_start_of_DRAM(void);
 phys_addr_t memblock_end_of_DRAM(void);
 void memblock_enforce_memory_limit(phys_addr_t memory_limit);
 void memblock_mem_limit_remove_map(phys_addr_t limit);
+void memblock_cap_memory_range(phys_addr_t base, phys_addr_t size);
 bool memblock_is_memory(phys_addr_t addr);
 int memblock_is_map_memory(phys_addr_t addr);
 int memblock_is_region_memory(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 483197e..3eae109 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1539,6 +1539,34 @@ void __init memblock_mem_limit_remove_map(phys_addr_t limit)
 			      (phys_addr_t)ULLONG_MAX);
 }
 
+void __init memblock_cap_memory_range(phys_addr_t base, phys_addr_t size)
+{
+	int start_rgn, end_rgn;
+	int i, ret;
+
+	if (!size)
+		return;
+
+	ret = memblock_isolate_range(&memblock.memory, base, size,
+						&start_rgn, &end_rgn);
+	if (ret)
+		return;
+
+	/* remove all the MAP regions */
+	for (i = memblock.memory.cnt - 1; i >= end_rgn; i--)
+		if (!memblock_is_nomap(&memblock.memory.regions[i]))
+			memblock_remove_region(&memblock.memory, i);
+
+	for (i = start_rgn - 1; i >= 0; i--)
+		if (!memblock_is_nomap(&memblock.memory.regions[i]))
+			memblock_remove_region(&memblock.memory, i);
+
+	/* truncate the reserved regions */
+	memblock_remove_range(&memblock.reserved, 0, base);
+	memblock_remove_range(&memblock.reserved,
+			base + size, (phys_addr_t)ULLONG_MAX);
+}
+
 static int __init_memblock memblock_search(struct memblock_type *type, phys_addr_t addr)
 {
 	unsigned int left = 0, right = type->cnt;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
