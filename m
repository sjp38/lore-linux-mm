Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D180D6B0269
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:38:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id e88-v6so1926677qtb.1
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:38:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 17-v6sor5872143qvi.45.2018.10.02.07.38.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 07:38:35 -0700 (PDT)
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Subject: [PATCH v3 2/3] mm: return zero_resv_unavail optimization
Date: Tue,  2 Oct 2018 10:38:20 -0400
Message-Id: <20181002143821.5112-3-msys.mizuma@gmail.com>
In-Reply-To: <20181002143821.5112-1-msys.mizuma@gmail.com>
References: <20181002143821.5112-1-msys.mizuma@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: Masayoshi Mizuma <msys.mizuma@gmail.com>, linux-kernel@vger.kernel.org, x86@kernel.org

From: Pavel Tatashin <pavel.tatashin@microsoft.com>

When checking for valid pfns in zero_resv_unavail(), it is not necessary to
verify that pfns within pageblock_nr_pages ranges are valid, only the first
one needs to be checked. This is because memory for pages are allocated in
contiguous chunks that contain pageblock_nr_pages struct pages.

Signed-off-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
Reviewed-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/page_alloc.c | 46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b9d89e..bd5b7e4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6440,6 +6440,29 @@ void __init free_area_init_node(int nid, unsigned long *zones_size,
 }
 
 #if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
+
+/*
+ * Zero all valid struct pages in range [spfn, epfn), return number of struct
+ * pages zeroed
+ */
+static u64 zero_pfn_range(unsigned long spfn, unsigned long epfn)
+{
+	unsigned long pfn;
+	u64 pgcnt = 0;
+
+	for (pfn = spfn; pfn < epfn; pfn++) {
+		if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages))) {
+			pfn = ALIGN_DOWN(pfn, pageblock_nr_pages)
+				+ pageblock_nr_pages - 1;
+			continue;
+		}
+		mm_zero_struct_page(pfn_to_page(pfn));
+		pgcnt++;
+	}
+
+	return pgcnt;
+}
+
 /*
  * Only struct pages that are backed by physical memory are zeroed and
  * initialized by going through __init_single_page(). But, there are some
@@ -6455,7 +6478,6 @@ void __init free_area_init_node(int nid, unsigned long *zones_size,
 void __init zero_resv_unavail(void)
 {
 	phys_addr_t start, end;
-	unsigned long pfn;
 	u64 i, pgcnt;
 	phys_addr_t next = 0;
 
@@ -6465,34 +6487,18 @@ void __init zero_resv_unavail(void)
 	pgcnt = 0;
 	for_each_mem_range(i, &memblock.memory, NULL,
 			NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end, NULL) {
-		if (next < start) {
-			for (pfn = PFN_DOWN(next); pfn < PFN_UP(start); pfn++) {
-				if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
-					continue;
-				mm_zero_struct_page(pfn_to_page(pfn));
-				pgcnt++;
-			}
-		}
+		if (next < start)
+			pgcnt += zero_pfn_range(PFN_DOWN(next), PFN_UP(start));
 		next = end;
 	}
-	for (pfn = PFN_DOWN(next); pfn < max_pfn; pfn++) {
-		if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
-			continue;
-		mm_zero_struct_page(pfn_to_page(pfn));
-		pgcnt++;
-	}
-
+	pgcnt += zero_pfn_range(PFN_DOWN(next), max_pfn);
 
 	/*
 	 * Struct pages that do not have backing memory. This could be because
 	 * firmware is using some of this memory, or for some other reasons.
-	 * Once memblock is changed so such behaviour is not allowed: i.e.
-	 * list of "reserved" memory must be a subset of list of "memory", then
-	 * this code can be removed.
 	 */
 	if (pgcnt)
 		pr_info("Zeroed struct page in unavailable ranges: %lld pages", pgcnt);
-
 }
 #endif /* CONFIG_HAVE_MEMBLOCK && !CONFIG_FLAT_NODE_MEM_MAP */
 
-- 
2.18.0
