Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 05E12680DC6
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 17:10:14 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id iw8so202053201obc.1
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 14:10:14 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id 62si39721231oid.142.2015.12.25.14.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 14:10:13 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 05/16] ia64: Set System RAM type and descriptor
Date: Fri, 25 Dec 2015 15:09:14 -0700
Message-Id: <1451081365-15190-5-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

Change efi_initialize_iomem_resources() to set 'flags' and 'desc'
from EFI memory types.  IORESOURCE_SYSRAM, a modifier bit, is
set to 'flags' for System RAM as IORESOURCE_MEM is already set.
IORESOURCE_SYSTEM_RAM is defined as (IORESOURCE_MEM|IORESOURCE_SYSRAM).
I/O resource descritor is set to 'desc' for "ACPI Non-volatile
Storage" and "Persistent Memory".

Also set IORESOURCE_SYSTEM_RAM to 'flags' for "Kernel code",
"Kernel data", and "Kernel bss".

Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 arch/ia64/kernel/efi.c   |   13 ++++++++++---
 arch/ia64/kernel/setup.c |    6 +++---
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index caae3f4..300dac3 100644
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
