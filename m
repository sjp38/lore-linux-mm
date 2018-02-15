Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 143EF6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 12:04:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i8so156045pgv.23
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 09:04:35 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x23-v6si2838746pln.423.2018.02.15.09.04.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 09:04:33 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 2/6] x86/mm/memory_hotplug: determine block size based on the end of boot memory
Date: Thu, 15 Feb 2018 11:59:16 -0500
Message-Id: <20180215165920.8570-3-pasha.tatashin@oracle.com>
In-Reply-To: <20180215165920.8570-1-pasha.tatashin@oracle.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

Memory sections are combined into "memory block" chunks.  These chunks are
the units upon which memory can be added and removed.

On x86 the new memory may be added after the end of the boot memory,
therefore, if block size does not align with end of boot memory, memory
hotplugging/hotremoving can be broken.

Currently, whenever machine is booted with more than 64G the block size
is unconditionally increased to 2G from the base 128M. This is done in
order to reduce number of memory device files in sysfs:
	/sys/devices/system/memory/memoryXXX

We must use the largest allowed block size that aligns to the next
address to be able to hotplug the next block of memory.

So, when memory is larger or equal to 64G, we check the end address and
find the largest block size that is still power of two but smaller or
equal to 2G.

Before, the fix:
Run qemu with:
-m 64G,slots=2,maxmem=66G -object memory-backend-ram,id=mem1,size=2G

(qemu) device_add pc-dimm,id=dimm1,memdev=mem1
Block size [0x80000000] unaligned hotplug range: start 0x1040000000,
							size 0x80000000
acpi PNP0C80:00: add_memory failed
acpi PNP0C80:00: acpi_memory_enable_device() error
acpi PNP0C80:00: Enumeration failure

With the fix memory is added successfully as the block size is set to 1G,
and therefore aligns with start address 0x1040000000.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/init_64.c | 33 +++++++++++++++++++++++++++++----
 1 file changed, 29 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 8b72923f1d35..9ac776de2252 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1326,14 +1326,39 @@ int kern_addr_valid(unsigned long addr)
 	return pfn_valid(pte_pfn(*pte));
 }
 
+/*
+ * Block size is the minimum amount of memory which can be hotplugged or
+ * hotremoved. It must be power of two and must be equal or larger than
+ * MIN_MEMORY_BLOCK_SIZE.
+ */
+#define MAX_BLOCK_SIZE (2UL << 30)
+
+/* Amount of ram needed to start using large blocks */
+#define MEM_SIZE_FOR_LARGE_BLOCK (64UL << 30)
+
 static unsigned long probe_memory_block_size(void)
 {
-	unsigned long bz = MIN_MEMORY_BLOCK_SIZE;
+	unsigned long boot_mem_end = max_pfn << PAGE_SHIFT;
+	unsigned long bz;
 
-	/* if system is UV or has 64GB of RAM or more, use large blocks */
-	if (is_uv_system() || ((max_pfn << PAGE_SHIFT) >= (64UL << 30)))
-		bz = 2UL << 30; /* 2GB */
+	/* If this is UV system, always set 2G block size */
+	if (is_uv_system()) {
+		bz = MAX_BLOCK_SIZE;
+		goto done;
+	}
 
+	/* Use regular block if RAM is smaller than MEM_SIZE_FOR_LARGE_BLOCK */
+	if (boot_mem_end < MEM_SIZE_FOR_LARGE_BLOCK) {
+		bz = MIN_MEMORY_BLOCK_SIZE;
+		goto done;
+	}
+
+	/* Find the largest allowed block size that aligns to memory end */
+	for (bz = MAX_BLOCK_SIZE; bz > MIN_MEMORY_BLOCK_SIZE; bz >>= 1) {
+		if (IS_ALIGNED(boot_mem_end, bz))
+			break;
+	}
+done:
 	pr_info("x86/mm: Memory block size: %ldMB\n", bz >> 20);
 
 	return bz;
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
