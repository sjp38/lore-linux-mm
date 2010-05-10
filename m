Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 841466B0249
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:40:07 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 11/25] lmb: Remove lmb_type.size and add lmb.memory_size instead
Date: Mon, 10 May 2010 19:38:45 +1000
Message-Id: <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-11-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-10-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-11-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Right now, both the "memory" and "reserved" lmb_type structures have
a "size" member. It's unused in the later case, and represent the
calculated memory size in the later case.

This moves it out to the main lmb structure instead

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/powerpc/mm/mem.c |    2 +-
 include/linux/lmb.h   |    2 +-
 lib/lmb.c             |    8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 17a8027..87e122e 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -301,7 +301,7 @@ void __init mem_init(void)
 		swiotlb_init(1);
 #endif
 
-	num_physpages = lmb.memory.size >> PAGE_SHIFT;
+	num_physpages = lmb_phys_mem_size() >> PAGE_SHIFT;
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index 5fdd900..27c2386 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -27,12 +27,12 @@ struct lmb_region {
 
 struct lmb_type {
 	unsigned long cnt;
-	phys_addr_t size;
 	struct lmb_region regions[MAX_LMB_REGIONS+1];
 };
 
 struct lmb {
 	phys_addr_t current_limit;
+	phys_addr_t memory_size;	/* Updated by lmb_analyze() */
 	struct lmb_type memory;
 	struct lmb_type reserved;
 };
diff --git a/lib/lmb.c b/lib/lmb.c
index 2995673..41cee3b 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -49,7 +49,7 @@ void lmb_dump_all(void)
 		return;
 
 	pr_info("LMB configuration:\n");
-	pr_info(" memory.size = 0x%llx\n", (unsigned long long)lmb.memory.size);
+	pr_info(" memory size = 0x%llx\n", (unsigned long long)lmb.memory_size);
 
 	lmb_dump(&lmb.memory, "memory");
 	lmb_dump(&lmb.reserved, "reserved");
@@ -123,10 +123,10 @@ void __init lmb_analyze(void)
 {
 	int i;
 
-	lmb.memory.size = 0;
+	lmb.memory_size = 0;
 
 	for (i = 0; i < lmb.memory.cnt; i++)
-		lmb.memory.size += lmb.memory.regions[i].size;
+		lmb.memory_size += lmb.memory.regions[i].size;
 }
 
 static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
@@ -423,7 +423,7 @@ phys_addr_t __init __lmb_alloc_base(phys_addr_t size, phys_addr_t align, phys_ad
 /* You must call lmb_analyze() before this. */
 phys_addr_t __init lmb_phys_mem_size(void)
 {
-	return lmb.memory.size;
+	return lmb.memory_size;
 }
 
 phys_addr_t lmb_end_of_DRAM(void)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
