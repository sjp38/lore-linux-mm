From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 04/17] x86/e820: Set System RAM type and descriptor
Date: Tue, 26 Jan 2016 21:57:20 +0100
Message-ID: <1453841853-11383-5-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-arch-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Jiri Kosina <jkosina@suse.cz>, Joerg Roedel <jroedel@suse.de>, Juergen Gross <jgross@suse.com>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mark Salter <msalter@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, WANG Chao <chaowang@redhat.com>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

Change e820_reserve_resources() to set 'flags' and 'desc' from
e820 types.

Set E820_RESERVED_KERN and E820_RAM's (System RAM) io resource type to
IORESOURCE_SYSTEM_RAM.

Do the same for "Kernel data", "Kernel code", and "Kernel bss", which
are child nodes of System RAM.

I/O resource descriptor is set to 'desc' for entries that are (and will
be) target ranges of walk_iomem_res() and region_intersects().

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Baoquan He <bhe@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Young <dyoung@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Jiri Kosina <jkosina@suse.cz>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Juergen Gross <jgross@suse.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: Mark Salter <msalter@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: WANG Chao <chaowang@redhat.com>
Link: http://lkml.kernel.org/r/1452020081-26534-4-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/kernel/e820.c  | 38 +++++++++++++++++++++++++++++++++++++-
 arch/x86/kernel/setup.c |  6 +++---
 2 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 569c1e4f96fe..837365f10912 100644
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
index d3d80e6d42a2..aa52c1009475 100644
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
2.3.5
