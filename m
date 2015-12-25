Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id A9B56680DC6
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 17:10:10 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id 18so203622073obc.2
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 14:10:10 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id uu6si9102784obc.50.2015.12.25.14.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 14:10:10 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 04/16] x86/e820: Set System RAM type and descriptor
Date: Fri, 25 Dec 2015 15:09:13 -0700
Message-Id: <1451081365-15190-4-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, bp@alien8.de
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, Toshi Kani <toshi.kani@hpe.com>

Change e820_reserve_resources() to set 'flags' and 'desc' from
e820 types.

IORESOURCE_SYSTEM_RAM is set to 'flags' for System RAM, which
are E820_RESERVED_KERN and E820_RAM.  IORESOURCE_SYSTEM_RAM is
also set to "Kernel data", "Kernel code", and "Kernel bss",
which are children nodes of System RAM.

I/O resource descriptor is set to 'desc' for entries that are
(and will be) target ranges of walk_iomem_res() and
region_intersects().

Cc: Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 arch/x86/kernel/e820.c  |   38 +++++++++++++++++++++++++++++++++++++-
 arch/x86/kernel/setup.c |    6 +++---
 2 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 569c1e4..837365f 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -925,6 +925,41 @@ static const char *e820_type_to_string(int e820_type)
 	}
 }
 
+static unsigned long e820_type_to_iomem_type(int e820_type)
+{
+	switch (e820_type) {
+	case E820_RESERVED_KERN:
+	case E820_RAM:
+		return IORESOURCE_SYSTEM_RAM;
+	case E820_ACPI:
+	case E820_NVS:
+	case E820_UNUSABLE:
+	case E820_PRAM:
+	case E820_PMEM:
+	default:
+		return IORESOURCE_MEM;
+	}
+}
+
+static unsigned long e820_type_to_iores_desc(int e820_type)
+{
+	switch (e820_type) {
+	case E820_ACPI:
+		return IORES_DESC_ACPI_TABLES;
+	case E820_NVS:
+		return IORES_DESC_ACPI_NV_STORAGE;
+	case E820_PMEM:
+		return IORES_DESC_PERSISTENT_MEMORY;
+	case E820_PRAM:
+		return IORES_DESC_PERSISTENT_MEMORY_LEGACY;
+	case E820_RESERVED_KERN:
+	case E820_RAM:
+	case E820_UNUSABLE:
+	default:
+		return IORES_DESC_NONE;
+	}
+}
+
 static bool do_mark_busy(u32 type, struct resource *res)
 {
 	/* this is the legacy bios/dos rom-shadow + mmio region */
@@ -967,7 +1002,8 @@ void __init e820_reserve_resources(void)
 		res->start = e820.map[i].addr;
 		res->end = end;
 
-		res->flags = IORESOURCE_MEM;
+		res->flags = e820_type_to_iomem_type(e820.map[i].type);
+		res->desc = e820_type_to_iores_desc(e820.map[i].type);
 
 		/*
 		 * don't register the region that could be conflicted with
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index d2bbe34..a492c30 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -152,21 +152,21 @@ static struct resource data_resource = {
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
 
 static struct resource bss_resource = {
 	.name	= "Kernel bss",
 	.start	= 0,
 	.end	= 0,
-	.flags	= IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags	= IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM
 };
 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
