Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id C8D4F6B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 17:32:24 -0400 (EDT)
From: T Makphaibulchoke <tmac@hp.com>
Subject: [PATCH] Fix devmem_is_allowed for below 1MB accesses for an efi machine
Date: Tue,  2 Oct 2012 15:32:16 -0600
Message-Id: <1349213536-3436-1-git-send-email-tmac@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, yinghai@kernel.org, tiwai@suse.de, viro@zeniv.linux.org.uk, aarcange@redhat.com, tony.luck@intel.com, mgorman@suse.de, weiyang@linux.vnet.ibm.com, octavian.purdila@intel.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: T Makphaibulchoke <tmac@hp.com>

Changing devmem_is_allowed so that on an EFI machine, access to physical
address below 1 MB is allowed only to physical pages that are valid in
the EFI memory map.  This prevents the possibility of an MCE due to
accessing an invalid physical address.

Signed-off-by: T Makphaibulchoke <tmac@hp.com>
---
 arch/x86/mm/init.c |   12 ++++++++++--
 include/linux/mm.h |    1 +
 kernel/resource.c  |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index ab1f6a9..3ed95c5 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -4,6 +4,7 @@
 #include <linux/swap.h>
 #include <linux/memblock.h>
 #include <linux/bootmem.h>	/* for max_low_pfn */
+#include <linux/efi.h>		/* for efi_enabled */
 
 #include <asm/cacheflush.h>
 #include <asm/e820.h>
@@ -319,8 +320,15 @@ unsigned long __init_refok init_memory_mapping(unsigned long start,
  */
 int devmem_is_allowed(unsigned long pagenr)
 {
-	if (pagenr < 256)
-		return 1;
+	if (pagenr < 256) {
+		if (!efi_enabled)
+			return 1;
+		/* For EFI, allow access only to valid physical addresses. */
+		if (page_is_valid(pagenr))
+			return 1;
+		return 0;
+	}
+
 	if (iomem_is_exclusive(pagenr << PAGE_SHIFT))
 		return 0;
 	if (!page_is_ram(pagenr))
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 311be90..fd1bcd4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -288,6 +288,7 @@ static inline int get_page_unless_zero(struct page *page)
 }
 
 extern int page_is_ram(unsigned long pfn);
+extern int page_is_valid(unsigned long pfn);
 
 /* Support for virtually mapped pages */
 struct page *vmalloc_to_page(const void *addr);
diff --git a/kernel/resource.c b/kernel/resource.c
index 34d4588..aeb091b 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -367,6 +367,53 @@ int __weak page_is_ram(unsigned long pfn)
 	return walk_system_ram_range(pfn, 1, NULL, __is_ram) == 1;
 }
 
+static int find_next_system_resource(struct resource *res)
+{
+	resource_size_t start, end;
+	struct resource *p;
+
+	BUG_ON(!res);
+
+	start = res->start;
+	end = res->end;
+	BUG_ON(start >= end);
+
+	read_lock(&resource_lock);
+	for (p = iomem_resource.child; p ; p = p->sibling) {
+		/* system ram is just marked as IORESOURCE_MEM */
+		if (!(p->flags & res->flags))
+			continue;
+		if (p->start > end) {
+			p = NULL;
+			break;
+		}
+		if ((p->end >= start) && (p->start < end))
+			break;
+	}
+	read_unlock(&resource_lock);
+	if (!p)
+		return -1;
+	/* copy data */
+	if (res->start < p->start)
+		res->start = p->start;
+	if (res->end > p->end)
+		res->end = p->end;
+	return 0;
+}
+
+int __weak page_is_valid(unsigned long start_pfn)
+{
+	struct resource res;
+	int ret = 0;
+
+	res.start = (u64) start_pfn << PAGE_SHIFT;
+	res.end = ((u64)(start_pfn + 1) << PAGE_SHIFT) - 1;
+	res.flags = IORESOURCE_MEM;
+	if (find_next_system_resource(&res) >= 0)
+		ret = 1;
+	return ret;
+}
+
 void __weak arch_remove_reservations(struct resource *avail)
 {
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
