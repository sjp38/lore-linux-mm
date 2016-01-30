Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C87F56B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:30:40 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id x125so55825386pfb.0
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:30:40 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id n1si8266089pap.199.2016.01.30.01.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:30:40 -0800 (PST)
Date: Sat, 30 Jan 2016 01:29:30 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-03cb525eb25018cf5f3da01d0f1391fc8b37805a@git.kernel.org>
Reply-To: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
        dvlasenk@redhat.com, mingo@kernel.org, rusty@rustcorp.com.au,
        hpa@zytor.com, peterz@infradead.org, fenghua.yu@intel.com,
        akpm@linux-foundation.org, bp@suse.de, luto@amacapital.net,
        toshi.kani@hp.com, linux-efi@vger.kernel.org, bp@alien8.de,
        mcgrof@suse.com, tglx@linutronix.de, tony.luck@intel.com,
        brgerst@gmail.com, toshi.kani@hpe.com, linux-mm@kvack.org,
        matt@codeblueprint.co.uk
In-Reply-To: <1453841853-11383-6-git-send-email-bp@alien8.de>
References: <1453841853-11383-6-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] ia64: Set System RAM type and descriptor
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: dvlasenk@redhat.com, mingo@kernel.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rusty@rustcorp.com.au, peterz@infradead.org, hpa@zytor.com, fenghua.yu@intel.com, akpm@linux-foundation.org, bp@suse.de, toshi.kani@hp.com, luto@amacapital.net, tglx@linutronix.de, tony.luck@intel.com, linux-efi@vger.kernel.org, mcgrof@suse.com, bp@alien8.de, brgerst@gmail.com, linux-mm@kvack.org, matt@codeblueprint.co.uk, toshi.kani@hpe.com

Commit-ID:  03cb525eb25018cf5f3da01d0f1391fc8b37805a
Gitweb:     http://git.kernel.org/tip/03cb525eb25018cf5f3da01d0f1391fc8b37805a
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:21 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:57 +0100

ia64: Set System RAM type and descriptor

Change efi_initialize_iomem_resources() to set 'flags' and
'desc' for EFI memory types. IORESOURCE_SYSRAM, a modifier bit,
is set for System RAM as IORESOURCE_MEM is already set.
IORESOURCE_SYSTEM_RAM is defined as
(IORESOURCE_MEM|IORESOURCE_SYSRAM). I/O resource descriptor is
set for "ACPI Non-volatile Storage" and "Persistent Memory".

Also set IORESOURCE_SYSTEM_RAM for "Kernel code", "Kernel data",
and "Kernel bss".

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Acked-by: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-efi <linux-efi@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-6-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/ia64/kernel/efi.c   | 13 ++++++++++---
 arch/ia64/kernel/setup.c |  6 +++---
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
