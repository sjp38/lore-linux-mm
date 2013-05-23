Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6338F6B003B
	for <linux-mm@kvack.org>; Thu, 23 May 2013 13:08:20 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id l18so2176273wgh.13
        for <linux-mm@kvack.org>; Thu, 23 May 2013 10:08:18 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 06/11] ARM64: mm: Restore memblock limit when map_mem finished.
Date: Thu, 23 May 2013 18:07:53 +0100
Message-Id: <1369328878-11706-7-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
References: <1369328878-11706-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, patches@linaro.org, Steve Capper <steve.capper@linaro.org>

In paging_init the memblock limit is set to restrict any addresses
returned by early_alloc to fit within the initial direct kernel
mapping in swapper_pg_dir. This allows map_mem to allocate puds,
pmds and ptes from the initial direct kernel mapping.

The limit stays low after paging_init() though, meaning any
bootmem allocations will be from a restricted subset of memory.
Gigabyte huge pages, for instance, are normally allocated from
bootmem as their order (18) is too large for the default buddy
allocator (MAX_ORDER = 11).

This patch restores the memblock limit when map_mem has finished,
allowing gigabyte huge pages (and other objects) to be allocated
from all of bootmem.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/mm/mmu.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index eeecc9c..9fa027b 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -297,6 +297,16 @@ static void __init map_mem(void)
 {
 	struct memblock_region *reg;
 
+	/*
+	 * Temporarily limit the memblock range. We need to do this as
+	 * create_mapping requires puds, pmds and ptes to be allocated from
+	 * memory addressable from the initial direct kernel mapping.
+	 *
+	 * The initial direct kernel mapping, located at swapper_pg_dir,
+	 * gives us PGDIR_SIZE memory starting from PHYS_OFFSET (aligned).
+	 */
+	memblock_set_current_limit((PHYS_OFFSET & PGDIR_MASK) + PGDIR_SIZE);
+
 	/* map all the memory banks */
 	for_each_memblock(memory, reg) {
 		phys_addr_t start = reg->base;
@@ -307,6 +317,9 @@ static void __init map_mem(void)
 
 		create_mapping(start, __phys_to_virt(start), end - start);
 	}
+
+	/* Limit no longer required. */
+	memblock_set_current_limit(MEMBLOCK_ALLOC_ANYWHERE);
 }
 
 /*
@@ -317,12 +330,6 @@ void __init paging_init(void)
 {
 	void *zero_page;
 
-	/*
-	 * Maximum PGDIR_SIZE addressable via the initial direct kernel
-	 * mapping in swapper_pg_dir.
-	 */
-	memblock_set_current_limit((PHYS_OFFSET & PGDIR_MASK) + PGDIR_SIZE);
-
 	init_mem_pgprot();
 	map_mem();
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
