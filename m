Date: Thu, 01 Nov 2007 18:21:35 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH] Add IORESOUCE_BUSY flag for System RAM (Re: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c)
In-Reply-To: <20071003135702.bdcf3f1b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071003015242.GC12049@parisc-linux.org> <20071003135702.bdcf3f1b.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20071101181700.6D9A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew@wil.cx>, LKML <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello.

I was asked from Kame-san to write this patch.

Please apply.

---------
i386 and x86-64 registers System RAM as IORESOURCE_MEM | IORESOURCE_BUSY.

But ia64 registers it as IORESOURCE_MEM only.
In addition, memory hotplug code registers new memory as IORESOURCE_MEM too.

This patch adds IORESOURCE_BUSY for them to avoid potential overlap mapping
by PCI device.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 arch/ia64/kernel/efi.c |    6 ++----
 mm/memory_hotplug.c    |    2 +-
 2 files changed, 3 insertions(+), 5 deletions(-)

Index: current/arch/ia64/kernel/efi.c
===================================================================
--- current.orig/arch/ia64/kernel/efi.c	2007-11-01 15:24:05.000000000 +0900
+++ current/arch/ia64/kernel/efi.c	2007-11-01 15:24:18.000000000 +0900
@@ -1111,7 +1111,7 @@ efi_initialize_iomem_resources(struct re
 		if (md->num_pages == 0) /* should not happen */
 			continue;
 
-		flags = IORESOURCE_MEM;
+		flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 		switch (md->type) {
 
 			case EFI_MEMORY_MAPPED_IO:
@@ -1133,12 +1133,11 @@ efi_initialize_iomem_resources(struct re
 
 			case EFI_ACPI_MEMORY_NVS:
 				name = "ACPI Non-volatile Storage";
-				flags |= IORESOURCE_BUSY;
 				break;
 
 			case EFI_UNUSABLE_MEMORY:
 				name = "reserved";
-				flags |= IORESOURCE_BUSY | IORESOURCE_DISABLED;
+				flags |= IORESOURCE_DISABLED;
 				break;
 
 			case EFI_RESERVED_TYPE:
@@ -1147,7 +1146,6 @@ efi_initialize_iomem_resources(struct re
 			case EFI_ACPI_RECLAIM_MEMORY:
 			default:
 				name = "reserved";
-				flags |= IORESOURCE_BUSY;
 				break;
 		}
 
Index: current/mm/memory_hotplug.c
===================================================================
--- current.orig/mm/memory_hotplug.c	2007-11-01 15:24:16.000000000 +0900
+++ current/mm/memory_hotplug.c	2007-11-01 15:41:27.000000000 +0900
@@ -39,7 +39,7 @@ static struct resource *register_memory_
 	res->name = "System RAM";
 	res->start = start;
 	res->end = start + size - 1;
-	res->flags = IORESOURCE_MEM;
+	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	if (request_resource(&iomem_resource, res) < 0) {
 		printk("System RAM resource %llx - %llx cannot be added\n",
 		(unsigned long long)res->start, (unsigned long long)res->end);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
