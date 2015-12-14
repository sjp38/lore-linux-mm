Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7486B0258
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 18:37:57 -0500 (EST)
Received: by obciw8 with SMTP id iw8so144924153obc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 15:37:57 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id l184si20702950oib.103.2015.12.14.15.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 15:37:56 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 04/11] arch: Set IORESOURCE_SYSTEM_RAM to System RAM
Date: Mon, 14 Dec 2015 16:37:19 -0700
Message-Id: <1450136246-17053-4-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

Set IORESOURCE_SYSTEM_RAM to the flags of resource ranges with
"System RAM", "Kernel code", "Kernel data", and "Kernel bss".

Note, IORESOURCE_SYSRAM (i.e. modifier bit) is set to the flags
when IORESOURCE_MEM is already set.  IORESOURCE_SYSTEM_RAM is
defined as (IORESOURCE_MEM|IORESOURCE_SYSRAM).

Note2, Some archs do not set flags for children nodes, such as
"Kernel code".  This patch keeps the flags unset in such cases.

Cc: linux-arch@vger.kernel.org
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 arch/arm/kernel/setup.c       |    6 +++---
 arch/arm64/kernel/setup.c     |    6 +++---
 arch/avr32/kernel/setup.c     |    6 +++---
 arch/ia64/kernel/efi.c        |    6 ++++--
 arch/ia64/kernel/setup.c      |    6 +++---
 arch/m32r/kernel/setup.c      |    4 ++--
 arch/mips/kernel/setup.c      |   10 ++++++----
 arch/parisc/mm/init.c         |    6 +++---
 arch/powerpc/mm/mem.c         |    2 +-
 arch/s390/kernel/setup.c      |    8 ++++----
 arch/score/kernel/setup.c     |    2 +-
 arch/sh/kernel/setup.c        |    8 ++++----
 arch/sparc/mm/init_64.c       |    8 ++++----
 arch/tile/kernel/setup.c      |   11 ++++++++---
 arch/unicore32/kernel/setup.c |    6 +++---
 15 files changed, 52 insertions(+), 43 deletions(-)

diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 20edd34..ae44e09 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -173,13 +173,13 @@ static struct resource mem_res[] = {
 		.name = "Kernel code",
 		.start = 0,
 		.end = 0,
-		.flags = IORESOURCE_MEM
+		.flags = IORESOURCE_SYSTEM_RAM
 	},
 	{
 		.name = "Kernel data",
 		.start = 0,
 		.end = 0,
-		.flags = IORESOURCE_MEM
+		.flags = IORESOURCE_SYSTEM_RAM
 	}
 };
 
@@ -781,7 +781,7 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 		res->name  = "System RAM";
 		res->start = __pfn_to_phys(memblock_region_memory_base_pfn(region));
 		res->end = __pfn_to_phys(memblock_region_memory_end_pfn(region)) - 1;
-		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 
 		request_resource(&iomem_resource, res);
 
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index 8119479..450987d 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -73,13 +73,13 @@ static struct resource mem_res[] = {
 		.name = "Kernel code",
 		.start = 0,
 		.end = 0,
-		.flags = IORESOURCE_MEM
+		.flags = IORESOURCE_SYSTEM_RAM
 	},
 	{
 		.name = "Kernel data",
 		.start = 0,
 		.end = 0,
-		.flags = IORESOURCE_MEM
+		.flags = IORESOURCE_SYSTEM_RAM
 	}
 };
 
@@ -210,7 +210,7 @@ static void __init request_standard_resources(void)
 		res->name  = "System RAM";
 		res->start = __pfn_to_phys(memblock_region_memory_base_pfn(region));
 		res->end = __pfn_to_phys(memblock_region_memory_end_pfn(region)) - 1;
-		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 
 		request_resource(&iomem_resource, res);
 
diff --git a/arch/avr32/kernel/setup.c b/arch/avr32/kernel/setup.c
index 209ae5a..e692889 100644
--- a/arch/avr32/kernel/setup.c
+++ b/arch/avr32/kernel/setup.c
@@ -49,13 +49,13 @@ static struct resource __initdata kernel_data = {
 	.name	= "Kernel data",
 	.start	= 0,
 	.end	= 0,
-	.flags	= IORESOURCE_MEM,
+	.flags	= IORESOURCE_SYSTEM_RAM,
 };
 static struct resource __initdata kernel_code = {
 	.name	= "Kernel code",
 	.start	= 0,
 	.end	= 0,
-	.flags	= IORESOURCE_MEM,
+	.flags	= IORESOURCE_SYSTEM_RAM,
 	.sibling = &kernel_data,
 };
 
@@ -134,7 +134,7 @@ add_physical_memory(resource_size_t start, resource_size_t end)
 	new->start = start;
 	new->end = end;
 	new->name = "System RAM";
-	new->flags = IORESOURCE_MEM;
+	new->flags = IORESOURCE_SYSTEM_RAM;
 
 	*pprev = new;
 }
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index caae3f4..b6939b0 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -1207,10 +1207,12 @@ efi_initialize_iomem_resources(struct resource *code_resource,
 				if (md->attribute & EFI_MEMORY_WP) {
 					name = "System ROM";
 					flags |= IORESOURCE_READONLY;
-				} else if (md->attribute == EFI_MEMORY_UC)
+				} else if (md->attribute == EFI_MEMORY_UC) {
 					name = "Uncached RAM";
-				else
+				} else {
 					name = "System RAM";
+					flags |= IORESOURCE_SYSRAM;
+				}
 				break;
 
 			case EFI_ACPI_MEMORY_NVS:
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 4f118b0..2029a38 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -80,17 +80,17 @@ unsigned long vga_console_membase;
 
 static struct resource data_resource = {
 	.name	= "Kernel data",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static struct resource code_resource = {
 	.name	= "Kernel code",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static struct resource bss_resource = {
 	.name	= "Kernel bss",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 unsigned long ia64_max_cacheline_size;
diff --git a/arch/m32r/kernel/setup.c b/arch/m32r/kernel/setup.c
index 0392112..5f62ff0 100644
--- a/arch/m32r/kernel/setup.c
+++ b/arch/m32r/kernel/setup.c
@@ -70,14 +70,14 @@ static struct resource data_resource = {
 	.name   = "Kernel data",
 	.start  = 0,
 	.end    = 0,
-	.flags  = IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags  = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static struct resource code_resource = {
 	.name   = "Kernel code",
 	.start  = 0,
 	.end    = 0,
-	.flags  = IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags  = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 unsigned long memory_start;
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index 66aac55..c385af1 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -732,21 +732,23 @@ static void __init resource_init(void)
 			end = HIGHMEM_START - 1;
 
 		res = alloc_bootmem(sizeof(struct resource));
+
+		res->start = start;
+		res->end = end;
+		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+
 		switch (boot_mem_map.map[i].type) {
 		case BOOT_MEM_RAM:
 		case BOOT_MEM_INIT_RAM:
 		case BOOT_MEM_ROM_DATA:
 			res->name = "System RAM";
+			res->flags |= IORESOURCE_SYSRAM;
 			break;
 		case BOOT_MEM_RESERVED:
 		default:
 			res->name = "reserved";
 		}
 
-		res->start = start;
-		res->end = end;
-
-		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 		request_resource(&iomem_resource, res);
 
 		/*
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 1b366c4..3c07d6b 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -55,12 +55,12 @@ signed char pfnnid_map[PFNNID_MAP_MAX] __read_mostly;
 
 static struct resource data_resource = {
 	.name	= "Kernel data",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM,
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
 };
 
 static struct resource code_resource = {
 	.name	= "Kernel code",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM,
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
 };
 
 static struct resource pdcdata_resource = {
@@ -201,7 +201,7 @@ static void __init setup_bootmem(void)
 		res->name = "System RAM";
 		res->start = pmem_ranges[i].start_pfn << PAGE_SHIFT;
 		res->end = res->start + (pmem_ranges[i].pages << PAGE_SHIFT)-1;
-		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 		request_resource(&iomem_resource, res);
 	}
 
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 22d94c3..e78a2b7 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -541,7 +541,7 @@ static int __init add_system_ram_resources(void)
 			res->name = "System RAM";
 			res->start = base;
 			res->end = base + size - 1;
-			res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+			res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 			WARN_ON(request_resource(&iomem_resource, res) < 0);
 		}
 	}
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index c837bca..b65a883 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -376,17 +376,17 @@ static void __init setup_lowcore(void)
 
 static struct resource code_resource = {
 	.name  = "Kernel code",
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
 };
 
 static struct resource data_resource = {
 	.name = "Kernel data",
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
 };
 
 static struct resource bss_resource = {
 	.name = "Kernel bss",
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
 };
 
 static struct resource __initdata *standard_resources[] = {
@@ -410,7 +410,7 @@ static void __init setup_resources(void)
 
 	for_each_memblock(memory, reg) {
 		res = alloc_bootmem_low(sizeof(*res));
-		res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
+		res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
 
 		res->name = "System RAM";
 		res->start = reg->base;
diff --git a/arch/score/kernel/setup.c b/arch/score/kernel/setup.c
index b48459a..f3a0649 100644
--- a/arch/score/kernel/setup.c
+++ b/arch/score/kernel/setup.c
@@ -101,7 +101,7 @@ static void __init resource_init(void)
 	res->name = "System RAM";
 	res->start = MEMORY_START;
 	res->end = MEMORY_START + MEMORY_SIZE - 1;
-	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	request_resource(&iomem_resource, res);
 
 	request_resource(res, &code_resource);
diff --git a/arch/sh/kernel/setup.c b/arch/sh/kernel/setup.c
index de19cfa..3f1c18b 100644
--- a/arch/sh/kernel/setup.c
+++ b/arch/sh/kernel/setup.c
@@ -78,17 +78,17 @@ static char __initdata command_line[COMMAND_LINE_SIZE] = { 0, };
 
 static struct resource code_resource = {
 	.name = "Kernel code",
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
 };
 
 static struct resource data_resource = {
 	.name = "Kernel data",
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM,
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
 };
 
 static struct resource bss_resource = {
 	.name	= "Kernel bss",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM,
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
 };
 
 unsigned long memory_start;
@@ -202,7 +202,7 @@ void __init __add_active_range(unsigned int nid, unsigned long start_pfn,
 	res->name = "System RAM";
 	res->start = start;
 	res->end = end - 1;
-	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 
 	if (request_resource(&iomem_resource, res)) {
 		pr_err("unable to request memory_resource 0x%lx 0x%lx\n",
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 3025bd5..a02d43d 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2862,17 +2862,17 @@ void hugetlb_setup(struct pt_regs *regs)
 
 static struct resource code_resource = {
 	.name	= "Kernel code",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static struct resource data_resource = {
 	.name	= "Kernel data",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static struct resource bss_resource = {
 	.name	= "Kernel bss",
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static inline resource_size_t compute_kern_paddr(void *addr)
@@ -2908,7 +2908,7 @@ static int __init report_memory(void)
 		res->name = "System RAM";
 		res->start = pavail[i].phys_addr;
 		res->end = pavail[i].phys_addr + pavail[i].reg_size - 1;
-		res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
+		res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
 
 		if (insert_resource(&iomem_resource, res) < 0) {
 			pr_warn("Resource insertion failed.\n");
diff --git a/arch/tile/kernel/setup.c b/arch/tile/kernel/setup.c
index 6b755d1..6606fe2 100644
--- a/arch/tile/kernel/setup.c
+++ b/arch/tile/kernel/setup.c
@@ -1632,14 +1632,14 @@ static struct resource data_resource = {
 	.name	= "Kernel data",
 	.start	= 0,
 	.end	= 0,
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 static struct resource code_resource = {
 	.name	= "Kernel code",
 	.start	= 0,
 	.end	= 0,
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 /*
@@ -1673,10 +1673,15 @@ insert_ram_resource(u64 start_pfn, u64 end_pfn, bool reserved)
 		kzalloc(sizeof(struct resource), GFP_ATOMIC);
 	if (!res)
 		return NULL;
-	res->name = reserved ? "Reserved" : "System RAM";
 	res->start = start_pfn << PAGE_SHIFT;
 	res->end = (end_pfn << PAGE_SHIFT) - 1;
 	res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
+	if (reserved) {
+		res->name = "Reserved";
+	} else {
+		res->name = "System RAM";
+		res->flags |= IORESOURCE_SYSRAM;
+	}
 	if (insert_resource(&iomem_resource, res)) {
 		kfree(res);
 		return NULL;
diff --git a/arch/unicore32/kernel/setup.c b/arch/unicore32/kernel/setup.c
index 3fa317f..c2bffa5 100644
--- a/arch/unicore32/kernel/setup.c
+++ b/arch/unicore32/kernel/setup.c
@@ -72,13 +72,13 @@ static struct resource mem_res[] = {
 		.name = "Kernel code",
 		.start = 0,
 		.end = 0,
-		.flags = IORESOURCE_MEM
+		.flags = IORESOURCE_SYSTEM_RAM
 	},
 	{
 		.name = "Kernel data",
 		.start = 0,
 		.end = 0,
-		.flags = IORESOURCE_MEM
+		.flags = IORESOURCE_SYSTEM_RAM
 	}
 };
 
@@ -211,7 +211,7 @@ request_standard_resources(struct meminfo *mi)
 		res->name  = "System RAM";
 		res->start = mi->bank[i].start;
 		res->end   = mi->bank[i].start + mi->bank[i].size - 1;
-		res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 
 		request_resource(&iomem_resource, res);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
