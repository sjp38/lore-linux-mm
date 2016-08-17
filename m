Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9846B025F
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:28:56 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so192173717pab.0
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 02:28:56 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u65si16076685pfk.116.2016.08.17.02.28.55
        for <linux-mm@kvack.org>;
        Wed, 17 Aug 2016 02:28:55 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2] mm: kmemleak: Avoid using __va() on addresses that don't have a lowmem mapping
Date: Wed, 17 Aug 2016 10:28:50 +0100
Message-Id: <1471426130-21330-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vignesh R <vigneshr@ti.com>, Andrew Morton <akpm@linux-foundation.org>

Some of the kmemleak_*() callbacks in memblock, bootmem, CMA convert a
physical address to a virtual one using __va(). However, such physical
addresses may sometimes be located in highmem and using __va() is
incorrect, leading to inconsistent object tracking in kmemleak.

The following functions have been added to the kmemleak API and they
take a physical address as the object pointer. They only perform the
corresponding action if the address has a lowmem mapping:

kmemleak_alloc_phys
kmemleak_free_part_phys
kmemleak_not_leak_phys
kmemleak_ignore_phys

The affected calling places have been updated to use the new kmemleak
API.

Reported-by: Vignesh R <vigneshr@ti.com>
Cc: Vignesh R <vigneshr@ti.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---

v1 -> v2:
  Moved the kmemleak_*_phys() functions out of line to avoid including
  linux/mm.h in linux/kmemleak.h and cause build errors on several platforms

Vignesh, I removed your tested/acked tags since this patch has been modified
slightly. Could you please give it another try? Thank you.

 Documentation/kmemleak.txt |  9 +++++++++
 include/linux/kmemleak.h   | 18 ++++++++++++++++++
 mm/bootmem.c               |  6 +++---
 mm/cma.c                   |  2 +-
 mm/kmemleak.c              | 45 +++++++++++++++++++++++++++++++++++++++++++++
 mm/memblock.c              |  8 ++++----
 mm/nobootmem.c             |  2 +-
 7 files changed, 81 insertions(+), 9 deletions(-)

diff --git a/Documentation/kmemleak.txt b/Documentation/kmemleak.txt
index 18e24abb3ecf..35e1a8891e3a 100644
--- a/Documentation/kmemleak.txt
+++ b/Documentation/kmemleak.txt
@@ -155,6 +155,15 @@ kmemleak_erase		 - erase an old value in a pointer variable
 kmemleak_alloc_recursive - as kmemleak_alloc but checks the recursiveness
 kmemleak_free_recursive	 - as kmemleak_free but checks the recursiveness
 
+The following functions take a physical address as the object pointer
+and only perform the corresponding action if the address has a lowmem
+mapping:
+
+kmemleak_alloc_phys
+kmemleak_free_part_phys
+kmemleak_not_leak_phys
+kmemleak_ignore_phys
+
 Dealing with false positives/negatives
 --------------------------------------
 
diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index 4894c6888bc6..1c2a32829620 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -38,6 +38,11 @@ extern void kmemleak_not_leak(const void *ptr) __ref;
 extern void kmemleak_ignore(const void *ptr) __ref;
 extern void kmemleak_scan_area(const void *ptr, size_t size, gfp_t gfp) __ref;
 extern void kmemleak_no_scan(const void *ptr) __ref;
+extern void kmemleak_alloc_phys(phys_addr_t phys, size_t size, int min_count,
+				gfp_t gfp) __ref;
+extern void kmemleak_free_part_phys(phys_addr_t phys, size_t size) __ref;
+extern void kmemleak_not_leak_phys(phys_addr_t phys) __ref;
+extern void kmemleak_ignore_phys(phys_addr_t phys) __ref;
 
 static inline void kmemleak_alloc_recursive(const void *ptr, size_t size,
 					    int min_count, unsigned long flags,
@@ -106,6 +111,19 @@ static inline void kmemleak_erase(void **ptr)
 static inline void kmemleak_no_scan(const void *ptr)
 {
 }
+static inline void kmemleak_alloc_phys(phys_addr_t phys, size_t size,
+				       int min_count, gfp_t gfp)
+{
+}
+static inline void kmemleak_free_part_phys(phys_addr_t phys, size_t size)
+{
+}
+static inline void kmemleak_not_leak_phys(phys_addr_t phys)
+{
+}
+static inline void kmemleak_ignore_phys(phys_addr_t phys)
+{
+}
 
 #endif	/* CONFIG_DEBUG_KMEMLEAK */
 
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 0aa7dda52402..80f1d70bad2d 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -158,7 +158,7 @@ void __init free_bootmem_late(unsigned long physaddr, unsigned long size)
 {
 	unsigned long cursor, end;
 
-	kmemleak_free_part(__va(physaddr), size);
+	kmemleak_free_part_phys(physaddr, size);
 
 	cursor = PFN_UP(physaddr);
 	end = PFN_DOWN(physaddr + size);
@@ -402,7 +402,7 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 {
 	unsigned long start, end;
 
-	kmemleak_free_part(__va(physaddr), size);
+	kmemleak_free_part_phys(physaddr, size);
 
 	start = PFN_UP(physaddr);
 	end = PFN_DOWN(physaddr + size);
@@ -423,7 +423,7 @@ void __init free_bootmem(unsigned long physaddr, unsigned long size)
 {
 	unsigned long start, end;
 
-	kmemleak_free_part(__va(physaddr), size);
+	kmemleak_free_part_phys(physaddr, size);
 
 	start = PFN_UP(physaddr);
 	end = PFN_DOWN(physaddr + size);
diff --git a/mm/cma.c b/mm/cma.c
index bd0e1412475e..384c2cb51b56 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -336,7 +336,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
 		 * kmemleak scans/reads tracked objects for pointers to other
 		 * objects but this address isn't mapped and accessible
 		 */
-		kmemleak_ignore(phys_to_virt(addr));
+		kmemleak_ignore_phys(addr);
 		base = addr;
 	}
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 086292f7c59d..4a717788998b 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1121,6 +1121,51 @@ void __ref kmemleak_no_scan(const void *ptr)
 }
 EXPORT_SYMBOL(kmemleak_no_scan);
 
+/**
+ * kmemleak_alloc_phys - similar to kmemleak_alloc but taking a physical
+ *			 address argument
+ */
+void __ref kmemleak_alloc_phys(phys_addr_t phys, size_t size, int min_count,
+			       gfp_t gfp)
+{
+	if (!IS_ENABLED(CONFIG_HIGHMEM) || phys < __pa(high_memory))
+		kmemleak_alloc(__va(phys), size, min_count, gfp);
+}
+EXPORT_SYMBOL(kmemleak_alloc_phys);
+
+/**
+ * kmemleak_free_part_phys - similar to kmemleak_free_part but taking a
+ *			     physical address argument
+ */
+void __ref kmemleak_free_part_phys(phys_addr_t phys, size_t size)
+{
+	if (!IS_ENABLED(CONFIG_HIGHMEM) || phys < __pa(high_memory))
+		kmemleak_free_part(__va(phys), size);
+}
+EXPORT_SYMBOL(kmemleak_free_part_phys);
+
+/**
+ * kmemleak_not_leak_phys - similar to kmemleak_not_leak but taking a physical
+ *			    address argument
+ */
+void __ref kmemleak_not_leak_phys(phys_addr_t phys)
+{
+	if (!IS_ENABLED(CONFIG_HIGHMEM) || phys < __pa(high_memory))
+		kmemleak_not_leak(__va(phys));
+}
+EXPORT_SYMBOL(kmemleak_not_leak_phys);
+
+/**
+ * kmemleak_ignore_phys - similar to kmemleak_ignore but taking a physical
+ *			  address argument
+ */
+void __ref kmemleak_ignore_phys(phys_addr_t phys)
+{
+	if (!IS_ENABLED(CONFIG_HIGHMEM) || phys < __pa(high_memory))
+		kmemleak_ignore(__va(phys));
+}
+EXPORT_SYMBOL(kmemleak_ignore_phys);
+
 /*
  * Update an object's checksum and return true if it was modified.
  */
diff --git a/mm/memblock.c b/mm/memblock.c
index 483197ef613f..30ecea7b45d1 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -723,7 +723,7 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 		     (unsigned long long)base + size - 1,
 		     (void *)_RET_IP_);
 
-	kmemleak_free_part(__va(base), size);
+	kmemleak_free_part_phys(base, size);
 	return memblock_remove_range(&memblock.reserved, base, size);
 }
 
@@ -1152,7 +1152,7 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 		 * The min_count is set to 0 so that memblock allocations are
 		 * never reported as leaks.
 		 */
-		kmemleak_alloc(__va(found), size, 0, 0);
+		kmemleak_alloc_phys(found, size, 0, 0);
 		return found;
 	}
 	return 0;
@@ -1399,7 +1399,7 @@ void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
 	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
-	kmemleak_free_part(__va(base), size);
+	kmemleak_free_part_phys(base, size);
 	memblock_remove_range(&memblock.reserved, base, size);
 }
 
@@ -1419,7 +1419,7 @@ void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 	memblock_dbg("%s: [%#016llx-%#016llx] %pF\n",
 		     __func__, (u64)base, (u64)base + size - 1,
 		     (void *)_RET_IP_);
-	kmemleak_free_part(__va(base), size);
+	kmemleak_free_part_phys(base, size);
 	cursor = PFN_UP(base);
 	end = PFN_DOWN(base + size);
 
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index bd05a70f44b9..a056d31dff7e 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -81,7 +81,7 @@ void __init free_bootmem_late(unsigned long addr, unsigned long size)
 {
 	unsigned long cursor, end;
 
-	kmemleak_free_part(__va(addr), size);
+	kmemleak_free_part_phys(addr, size);
 
 	cursor = PFN_UP(addr);
 	end = PFN_DOWN(addr + size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
