From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 05/17] ia64: Set System RAM type and descriptor
Date: Tue, 26 Jan 2016 21:57:21 +0100
Message-ID: <1453841853-11383-6-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, linux-arch@vger.kernel.org, linux-efi <linux-efi@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>, "Luis R. Rodriguez" <mcgrof@suse.com>, Matt Fleming <matt@codeblueprint.co.uk>, Rusty Russell <rusty@rustcorp.com.au>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

Change efi_initialize_iomem_resources() to set 'flags' and 'desc' for
EFI memory types. IORESOURCE_SYSRAM, a modifier bit, is set for System
RAM as IORESOURCE_MEM is already set. IORESOURCE_SYSTEM_RAM is defined
as (IORESOURCE_MEM|IORESOURCE_SYSRAM). I/O resource descriptor is set
for "ACPI Non-volatile Storage" and "Persistent Memory".

Also set IORESOURCE_SYSTEM_RAM for "Kernel code", "Kernel data", and
"Kernel bss".

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Acked-by: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-efi <linux-efi@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: "Luis R. Rodriguez" <mcgrof@suse.com>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Link: http://lkml.kernel.org/r/1452020081-26534-5-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 arch/ia64/kernel/efi.c   | 13 ++++++++++---
 arch/ia64/kernel/setup.c |  6 +++---
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index caae3f4e4341..300dac3702f1 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -1178,7 +1178,7 @@ efi_initialize_iomem_resources(struct resource *code_resource,
 	efi_memory_desc_t *md;
 	u64 efi_desc_size;
 	char *name;
-	unsigned long flags;
+	unsigned long flags, desc;
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -1193,6 +1193,8 @@ efi_initialize_iomem_resources(struct resource *code_resource,
 			continue;
 
 		flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+		desc = IORES_DESC_NONE;
+
 		switch (md->type) {
 
 			case EFI_MEMORY_MAPPED_IO:
@@ -1207,14 +1209,17 @@ efi_initialize_iomem_resources(struct resource *code_resource,
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
 				name = "ACPI Non-volatile Storage";
+				desc = IORES_DESC_ACPI_NV_STORAGE;
 				break;
 
 			case EFI_UNUSABLE_MEMORY:
@@ -1224,6 +1229,7 @@ efi_initialize_iomem_resources(struct resource *code_resource,
 
 			case EFI_PERSISTENT_MEMORY:
 				name = "Persistent Memory";
+				desc = IORES_DESC_PERSISTENT_MEMORY;
 				break;
 
 			case EFI_RESERVED_TYPE:
@@ -1246,6 +1252,7 @@ efi_initialize_iomem_resources(struct resource *code_resource,
 		res->start = md->phys_addr;
 		res->end = md->phys_addr + efi_md_size(md) - 1;
 		res->flags = flags;
+		res->desc = desc;
 
 		if (insert_resource(&iomem_resource, res) < 0)
 			kfree(res);
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 4f118b0d3091..2029a38a72ae 100644
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
-- 
2.3.5
