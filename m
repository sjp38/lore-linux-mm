Date: Tue, 06 Nov 2007 11:23:01 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH] Add IORESOUCE_BUSY flag for System RAM take 2. 
In-Reply-To: <1193934490.26106.0.camel@dyn9047017100.beaverton.ibm.com>
References: <20071101181700.6D9A.Y-GOTO@jp.fujitsu.com> <1193934490.26106.0.camel@dyn9047017100.beaverton.ibm.com>
Message-Id: <20071106111839.4D11.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew@wil.cx>, lkml <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello.

I merged Baradi-san's patch and mine. This and Kame-san's
following patch is necessary for x86-64 memory unplug.

http://marc.info/?l=linux-mm&m=119399026017901&w=2

I heard Kame-san's patch is already included in -mm.
So, I'll repost merged patch now.

This patch is tested on 2.6.23-mm1.

Please apply.

---

i386 and x86-64 registers System RAM as IORESOURCE_MEM | IORESOURCE_BUSY.

But ia64 registers it as IORESOURCE_MEM only.
In addition, memory hotplug code registers new memory as IORESOURCE_MEM too.

This difference causes a failure of memory unplug of x86-64.
This patch fix it.

This patch adds IORESOURCE_BUSY to avoid potential overlap mapping
by PCI device.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>

---
 arch/ia64/kernel/efi.c |    6 ++----
 kernel/resource.c      |    2 +-
 mm/memory_hotplug.c    |    2 +-
 3 files changed, 4 insertions(+), 6 deletions(-)

Index: current/arch/ia64/kernel/efi.c
===================================================================
--- current.orig/arch/ia64/kernel/efi.c	2007-11-02 17:17:30.000000000 +0900
+++ current/arch/ia64/kernel/efi.c	2007-11-02 17:19:10.000000000 +0900
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
--- current.orig/mm/memory_hotplug.c	2007-11-02 17:19:09.000000000 +0900
+++ current/mm/memory_hotplug.c	2007-11-02 17:19:10.000000000 +0900
@@ -39,7 +39,7 @@ static struct resource *register_memory_
 	res->name = "System RAM";
 	res->start = start;
 	res->end = start + size - 1;
-	res->flags = IORESOURCE_MEM;
+	res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	if (request_resource(&iomem_resource, res) < 0) {
 		printk("System RAM resource %llx - %llx cannot be added\n",
 		(unsigned long long)res->start, (unsigned long long)res->end);
Index: current/kernel/resource.c
===================================================================
--- current.orig/kernel/resource.c	2007-11-02 17:19:15.000000000 +0900
+++ current/kernel/resource.c	2007-11-02 17:22:39.000000000 +0900
@@ -287,7 +287,7 @@ walk_memory_resource(unsigned long start
 	int ret = -1;
 	res.start = (u64) start_pfn << PAGE_SHIFT;
 	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
-	res.flags = IORESOURCE_MEM;
+	res.flags = IORESOURCE_MEM | IORESOURCE_BUSY;
 	orig_end = res.end;
 	while ((res.start < res.end) && (find_next_system_ram(&res) >= 0)) {
 		pfn = (unsigned long)(res.start >> PAGE_SHIFT);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
