Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1A637280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 03:34:50 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i196so16006199pgd.2
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 00:34:50 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id bj7si605839plb.394.2017.11.07.00.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 00:34:48 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, sparse: Fix boot on arm64
Date: Tue,  7 Nov 2017 11:33:37 +0300
Message-Id: <20171107083337.89952-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Bjorn Andersson <bjorn.andersson@linaro.org>, Sudeep Holla <sudeep.holla@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Since 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for
CONFIG_SPARSEMEM_EXTREME=y") we allocate mem_section dynamically in
sparse_memory_present_with_active_regions(). But some architectures, like
arm64, don't use the routine to initialize sparsemem.

Let's move the initialization into memory_present() it should cover all
architectures.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y")
Acked-by: Will Deacon <will.deacon@arm.com>
Tested-by: Bjorn Andersson <bjorn.andersson@linaro.org>
Reported-and-tested-by: Sudeep Holla <sudeep.holla@arm.com>
---
 mm/page_alloc.c | 10 ----------
 mm/sparse.c     | 10 ++++++++++
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8dfd13f724d9..77e4d3c5c57b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5646,16 +5646,6 @@ void __init sparse_memory_present_with_active_regions(int nid)
 	unsigned long start_pfn, end_pfn;
 	int i, this_nid;
 
-#ifdef CONFIG_SPARSEMEM_EXTREME
-	if (!mem_section) {
-		unsigned long size, align;
-
-		size = sizeof(struct mem_section) * NR_SECTION_ROOTS;
-		align = 1 << (INTERNODE_CACHE_SHIFT);
-		mem_section = memblock_virt_alloc(size, align);
-	}
-#endif
-
 	for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, &this_nid)
 		memory_present(this_nid, start_pfn, end_pfn);
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index b00a97398795..d294148ba395 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -206,6 +206,16 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 {
 	unsigned long pfn;
 
+#ifdef CONFIG_SPARSEMEM_EXTREME
+	if (unlikely(!mem_section)) {
+		unsigned long size, align;
+
+		size = sizeof(struct mem_section) * NR_SECTION_ROOTS;
+		align = 1 << (INTERNODE_CACHE_SHIFT);
+		mem_section = memblock_virt_alloc(size, align);
+	}
+#endif
+
 	start &= PAGE_SECTION_MASK;
 	mminit_validate_memmodel_limits(&start, &end);
 	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
