Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EE3A36B0003
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 02:27:23 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 91-v6so4388058pla.18
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 23:27:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e14sor138622pgp.306.2018.03.26.23.27.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 23:27:22 -0700 (PDT)
Date: Mon, 26 Mar 2018 23:27:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] x86/mm/32: Remove unused node_memmap_size_bytes
Message-ID: <alpine.DEB.2.20.1803262325540.256524@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: Laura Abbott <labbott@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

node_memmap_size_bytes() has been unused since the 3.9 kernel, so remove
it.

Fixes: f03574f2d5b2 ("x86-32, mm: Rip out x86_32 NUMA remapping code")
Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/x86/Kconfig       |  4 ----
 arch/x86/mm/numa_32.c  | 11 -----------
 include/linux/mmzone.h |  5 -----
 mm/sparse.c            | 22 ----------------------
 4 files changed, 42 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1598,10 +1598,6 @@ config ARCH_HAVE_MEMORY_PRESENT
 	def_bool y
 	depends on X86_32 && DISCONTIGMEM
 
-config NEED_NODE_MEMMAP_SIZE
-	def_bool y
-	depends on X86_32 && (DISCONTIGMEM || SPARSEMEM)
-
 config ARCH_FLATMEM_ENABLE
 	def_bool y
 	depends on X86_32 && !NUMA
diff --git a/arch/x86/mm/numa_32.c b/arch/x86/mm/numa_32.c
--- a/arch/x86/mm/numa_32.c
+++ b/arch/x86/mm/numa_32.c
@@ -60,17 +60,6 @@ void memory_present(int nid, unsigned long start, unsigned long end)
 	}
 	printk(KERN_CONT "\n");
 }
-
-unsigned long node_memmap_size_bytes(int nid, unsigned long start_pfn,
-					      unsigned long end_pfn)
-{
-	unsigned long nr_pages = end_pfn - start_pfn;
-
-	if (!nr_pages)
-		return 0;
-
-	return (nr_pages + 1) * sizeof(struct page);
-}
 #endif
 
 extern unsigned long highend_pfn, highstart_pfn;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -819,10 +819,6 @@ int local_memory_node(int node_id);
 static inline int local_memory_node(int node_id) { return node_id; };
 #endif
 
-#ifdef CONFIG_NEED_NODE_MEMMAP_SIZE
-unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
-#endif
-
 /*
  * zone_idx() returns 0 for the ZONE_DMA zone, 1 for the ZONE_NORMAL zone, etc.
  */
@@ -1292,7 +1288,6 @@ struct mminit_pfnnid_cache {
 #endif
 
 void memory_present(int nid, unsigned long start, unsigned long end);
-unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 
 /*
  * If it is possible to have holes within a MAX_ORDER_NR_PAGES, then we
diff --git a/mm/sparse.c b/mm/sparse.c
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -242,28 +242,6 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 	}
 }
 
-/*
- * Only used by the i386 NUMA architecures, but relatively
- * generic code.
- */
-unsigned long __init node_memmap_size_bytes(int nid, unsigned long start_pfn,
-						     unsigned long end_pfn)
-{
-	unsigned long pfn;
-	unsigned long nr_pages = 0;
-
-	mminit_validate_memmodel_limits(&start_pfn, &end_pfn);
-	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
-		if (nid != early_pfn_to_nid(pfn))
-			continue;
-
-		if (pfn_present(pfn))
-			nr_pages += PAGES_PER_SECTION;
-	}
-
-	return nr_pages * sizeof(struct page);
-}
-
 /*
  * Subtle, we encode the real pfn into the mem_map such that
  * the identity pfn - section_mem_map will return the actual
