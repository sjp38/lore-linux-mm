Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id E30ED6B0257
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:47:17 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so29307087pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:47:17 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id sz5si7734726pab.19.2015.09.22.21.47.17
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:47:17 -0700 (PDT)
Subject: [PATCH 04/15] x86, mm: quiet arch_add_memory()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:41:34 -0400
Message-ID: <20150923044134.36490.18815.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org

Switch to pr_debug() so that dynamic-debug can disable these messages by
default.  This gets noisy in the presence of devm_memremap_pages().

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init.c    |    4 ++--
 arch/x86/mm/init_64.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 1d8a83df153a..4b9ea3f27de4 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -354,7 +354,7 @@ static int __meminit split_mem_range(struct map_range *mr, int nr_range,
 	}
 
 	for (i = 0; i < nr_range; i++)
-		printk(KERN_DEBUG " [mem %#010lx-%#010lx] page %s\n",
+		pr_debug(" [mem %#010lx-%#010lx] page %s\n",
 				mr[i].start, mr[i].end - 1,
 				page_size_string(&mr[i]));
 
@@ -401,7 +401,7 @@ unsigned long __init_refok init_memory_mapping(unsigned long start,
 	unsigned long ret = 0;
 	int nr_range, i;
 
-	pr_info("init_memory_mapping: [mem %#010lx-%#010lx]\n",
+	pr_debug("init_memory_mapping: [mem %#010lx-%#010lx]\n",
 	       start, end - 1);
 
 	memset(mr, 0, sizeof(mr));
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 30564e2752d3..bf827f231470 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1268,7 +1268,7 @@ static int __meminit vmemmap_populate_hugepages(unsigned long start,
 				/* check to see if we have contiguous blocks */
 				if (p_end != p || node_start != node) {
 					if (p_start)
-						printk(KERN_DEBUG " [%lx-%lx] PMD -> [%p-%p] on node %d\n",
+						pr_debug(" [%lx-%lx] PMD -> [%p-%p] on node %d\n",
 						       addr_start, addr_end-1, p_start, p_end-1, node_start);
 					addr_start = addr;
 					node_start = node;
@@ -1366,7 +1366,7 @@ void register_page_bootmem_memmap(unsigned long section_nr,
 void __meminit vmemmap_populate_print_last(void)
 {
 	if (p_start) {
-		printk(KERN_DEBUG " [%lx-%lx] PMD -> [%p-%p] on node %d\n",
+		pr_debug(" [%lx-%lx] PMD -> [%p-%p] on node %d\n",
 			addr_start, addr_end-1, p_start, p_end-1, node_start);
 		p_start = NULL;
 		p_end = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
