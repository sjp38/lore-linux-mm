Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6288E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 22:00:31 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y8so18916231pgq.12
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 19:00:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor1323955pgq.46.2018.12.27.19.00.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Dec 2018 19:00:29 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv3 1/2] mm/memblock: extend the limit inferior of bottom-up after parsing hotplug attr
Date: Fri, 28 Dec 2018 11:00:01 +0800
Message-Id: <1545966002-3075-2-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
References: <1545966002-3075-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

The bottom-up allocation style is introduced to cope with movable_node,
where the limit inferior of allocation starts from kernel's end, due to
lack of knowledge of memory hotplug info at this early time. But if later,
hotplug info has been got, the limit inferior can be extend to 0.
'kexec -c' prefers to reuse this style to alloc mem at lower address,
since if the reserved region is beyond 4G, then it requires extra mem
(default is 16M) for swiotlb.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Nicholas Piggin <npiggin@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Daniel Vacek <neelx@redhat.com>
Cc: Mathieu Malaterre <malat@debian.org>
Cc: Stefan Agner <stefan@agner.ch>
Cc: Dave Young <dyoung@redhat.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: yinghai@kernel.org,
Cc: vgoyal@redhat.com
Cc: linux-kernel@vger.kernel.org
---
 drivers/acpi/numa.c      |  4 ++++
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 58 +++++++++++++++++++++++++++++-------------------
 3 files changed, 40 insertions(+), 23 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 2746994..3eea4e4 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -462,6 +462,10 @@ int __init acpi_numa_init(void)
 
 		cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
 					    acpi_parse_memory_affinity, 0);
+
+#if defined(CONFIG_X86) || defined(CONFIG_ARM64)
+		mark_mem_hotplug_parsed();
+#endif
 	}
 
 	/* SLIT: System Locality Information Table */
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index aee299a..d89ed9e 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -125,6 +125,7 @@ int memblock_reserve(phys_addr_t base, phys_addr_t size);
 void memblock_trim_memory(phys_addr_t align);
 bool memblock_overlaps_region(struct memblock_type *type,
 			      phys_addr_t base, phys_addr_t size);
+void mark_mem_hotplug_parsed(void);
 int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
 int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 81ae63c..a3f5e46 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -231,6 +231,12 @@ __memblock_find_range_top_down(phys_addr_t start, phys_addr_t end,
 	return 0;
 }
 
+static bool mem_hotmovable_parsed __initdata_memblock;
+void __init_memblock mark_mem_hotplug_parsed(void)
+{
+	mem_hotmovable_parsed = true;
+}
+
 /**
  * memblock_find_in_range_node - find free area in given range and node
  * @size: size of free area to find
@@ -259,7 +265,7 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
 					phys_addr_t end, int nid,
 					enum memblock_flags flags)
 {
-	phys_addr_t kernel_end, ret;
+	phys_addr_t kernel_end, ret = 0;
 
 	/* pump up @end */
 	if (end == MEMBLOCK_ALLOC_ACCESSIBLE)
@@ -270,34 +276,40 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
 	end = max(start, end);
 	kernel_end = __pa_symbol(_end);
 
-	/*
-	 * try bottom-up allocation only when bottom-up mode
-	 * is set and @end is above the kernel image.
-	 */
-	if (memblock_bottom_up() && end > kernel_end) {
-		phys_addr_t bottom_up_start;
+	if (memblock_bottom_up()) {
+		phys_addr_t bottom_up_start = start;
 
-		/* make sure we will allocate above the kernel */
-		bottom_up_start = max(start, kernel_end);
-
-		/* ok, try bottom-up allocation first */
-		ret = __memblock_find_range_bottom_up(bottom_up_start, end,
-						      size, align, nid, flags);
-		if (ret)
+		if (mem_hotmovable_parsed) {
+			ret = __memblock_find_range_bottom_up(
+				bottom_up_start, end, size, align, nid,
+				flags);
 			return ret;
 
 		/*
-		 * we always limit bottom-up allocation above the kernel,
-		 * but top-down allocation doesn't have the limit, so
-		 * retrying top-down allocation may succeed when bottom-up
-		 * allocation failed.
-		 *
-		 * bottom-up allocation is expected to be fail very rarely,
-		 * so we use WARN_ONCE() here to see the stack trace if
-		 * fail happens.
+		 * if mem hotplug info is not parsed yet, try bottom-up
+		 * allocation with @end above the kernel image.
 		 */
-		WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
+		} else if (!mem_hotmovable_parsed && end > kernel_end) {
+			/* make sure we will allocate above the kernel */
+			bottom_up_start = max(start, kernel_end);
+			ret = __memblock_find_range_bottom_up(
+				bottom_up_start, end, size, align, nid,
+				flags);
+			if (ret)
+				return ret;
+			/*
+			 * we always limit bottom-up allocation above the
+			 * kernel, but top-down allocation doesn't have
+			 * the limit, so retrying top-down allocation may
+			 * succeed when bottom-up allocation failed.
+			 *
+			 * bottom-up allocation is expected to be fail
+			 * very rarely, so we use WARN_ONCE() here to see
+			 * the stack trace if fail happens.
+			 */
+			WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
 			  "memblock: bottom-up allocation failed, memory hotremove may be affected\n");
+		}
 	}
 
 	return __memblock_find_range_top_down(start, end, size, align, nid,
-- 
2.7.4
