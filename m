Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE3226B025E
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 13:11:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so53323958pgx.6
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 10:11:21 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0076.outbound.protection.outlook.com. [104.47.34.76])
        by mx.google.com with ESMTPS id g6si34757718pgp.201.2016.12.09.10.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 10:11:20 -0800 (PST)
From: Robert Richter <rrichter@cavium.com>
Subject: [PATCH] arm64: mm: Fix NOMAP page initialization
Date: Fri, 9 Dec 2016 19:10:41 +0100
Message-ID: <1481307042-29773-1-git-send-email-rrichter@cavium.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, Robert Richter <rrichter@cavium.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On ThunderX systems with certain memory configurations we see the
following BUG_ON():

 kernel BUG at mm/page_alloc.c:1848!

This happens for some configs with 64k page size enabled. The BUG_ON()
checks if start and end page of a memmap range belongs to the same
zone.

The BUG_ON() check fails if a memory zone contains NOMAP regions. In
this case the node information of those pages is not initialized. This
causes an inconsistency of the page links with wrong zone and node
information for that pages. NOMAP pages from node 1 still point to the
mem zone from node 0 and have the wrong nid assigned.

The reason for the mis-configuration is a change in pfn_valid() which
reports pages marked NOMAP as invalid:

 68709f45385a arm64: only consider memblocks with NOMAP cleared for linear mapping

This causes pages marked as nomap being no longer reassigned to the
new zone in memmap_init_zone() by calling __init_single_pfn().

Fixing this by implementing an arm64 specific early_pfn_valid(). This
causes the whole mem range including NOMAP memory to be initialized by
__init_single_page() and ensures consistency of page links to zone,
node and section.

The HAVE_ARCH_PFN_VALID config option now requires an explicit
definiton of early_pfn_valid() in the same way as pfn_valid(). This
allows a customized implementation of early_pfn_valid() which
redirects to memblock_is_memory() for arm64.

Signed-off-by: Robert Richter <rrichter@cavium.com>
---
 arch/arm/include/asm/page.h   |  1 +
 arch/arm64/include/asm/page.h |  2 ++
 arch/arm64/mm/init.c          | 12 ++++++++++++
 include/linux/mmzone.h        |  5 ++++-
 4 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/arch/arm/include/asm/page.h b/arch/arm/include/asm/page.h
index 4355f0ec44d6..79761bd55f94 100644
--- a/arch/arm/include/asm/page.h
+++ b/arch/arm/include/asm/page.h
@@ -158,6 +158,7 @@ typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 extern int pfn_valid(unsigned long);
+#define early_pfn_valid(pfn)	pfn_valid(pfn)
 #endif
 
 #include <asm/memory.h>
diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
index 8472c6def5ef..17ceb7435ded 100644
--- a/arch/arm64/include/asm/page.h
+++ b/arch/arm64/include/asm/page.h
@@ -49,6 +49,8 @@ typedef struct page *pgtable_t;
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
 extern int pfn_valid(unsigned long);
+extern int early_pfn_valid(unsigned long);
+#define early_pfn_valid early_pfn_valid
 #endif
 
 #include <asm/memory.h>
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 212c4d1e2f26..fbc136533472 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -145,11 +145,23 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max)
 #endif /* CONFIG_NUMA */
 
 #ifdef CONFIG_HAVE_ARCH_PFN_VALID
+
 int pfn_valid(unsigned long pfn)
 {
 	return memblock_is_map_memory(pfn << PAGE_SHIFT);
 }
 EXPORT_SYMBOL(pfn_valid);
+
+/*
+ * We use memblock_is_memory() here to make sure all pages including
+ * NOMAP ranges are initialized with __init_single_page().
+ */
+int early_pfn_valid(unsigned long pfn)
+{
+	return memblock_is_memory(pfn << PAGE_SHIFT);
+}
+EXPORT_SYMBOL(early_pfn_valid);
+
 #endif
 
 #ifndef CONFIG_SPARSEMEM
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0f088f3a2fed..bedcf8a95881 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1170,12 +1170,16 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 }
 
 #ifndef CONFIG_HAVE_ARCH_PFN_VALID
+
 static inline int pfn_valid(unsigned long pfn)
 {
 	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
 		return 0;
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
+
+#define early_pfn_valid(pfn)	pfn_valid(pfn)
+
 #endif
 
 static inline int pfn_present(unsigned long pfn)
@@ -1200,7 +1204,6 @@ static inline int pfn_present(unsigned long pfn)
 #define pfn_to_nid(pfn)		(0)
 #endif
 
-#define early_pfn_valid(pfn)	pfn_valid(pfn)
 void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
