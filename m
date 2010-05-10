Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 10C2D6200C5
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:41:02 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 23/25] lmb: Separate lmb_alloc_nid() and lmb_alloc_try_nid()
Date: Mon, 10 May 2010 19:38:57 +1000
Message-Id: <1273484339-28911-24-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-23-git-send-email-benh@kernel.crashing.org>
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
 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-21-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-22-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-23-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

The former is now strict, it will fail if it cannot honor the allocation
within the node, while the later implements the previous semantic which
falls back to allocating anywhere.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/sparc/mm/init_64.c |    4 ++--
 include/linux/lmb.h     |    6 +++++-
 lib/lmb.c               |   10 ++++++++++
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 88443c8..86477c5 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -820,7 +820,7 @@ static void __init allocate_node_data(int nid)
 	struct pglist_data *p;
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
-	paddr = lmb_alloc_nid(sizeof(struct pglist_data), SMP_CACHE_BYTES, nid);
+	paddr = lmb_alloc_try_nid(sizeof(struct pglist_data), SMP_CACHE_BYTES, nid);
 	if (!paddr) {
 		prom_printf("Cannot allocate pglist_data for nid[%d]\n", nid);
 		prom_halt();
@@ -840,7 +840,7 @@ static void __init allocate_node_data(int nid)
 	if (p->node_spanned_pages) {
 		num_pages = bootmem_bootmap_pages(p->node_spanned_pages);
 
-		paddr = lmb_alloc_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid);
+		paddr = lmb_alloc_try_nid(num_pages << PAGE_SHIFT, PAGE_SIZE, nid);
 		if (!paddr) {
 			prom_printf("Cannot allocate bootmap for nid[%d]\n",
 				  nid);
diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index 45724a6..4e45aa9 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -50,7 +50,11 @@ extern long __init lmb_reserve(phys_addr_t base, phys_addr_t size);
 /* The numa aware allocator is only available if
  * CONFIG_ARCH_POPULATES_NODE_MAP is set
  */
-extern phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
+extern phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align,
+					int nid);
+extern phys_addr_t __init lmb_alloc_try_nid(phys_addr_t size, phys_addr_t align,
+					    int nid);
+
 extern phys_addr_t __init lmb_alloc(phys_addr_t size, phys_addr_t align);
 
 /* Flags for lmb_alloc_base() amd __lmb_alloc_base() */
diff --git a/lib/lmb.c b/lib/lmb.c
index f4b2f95..fd98261 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -522,9 +522,19 @@ phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align, int nid)
 			return ret;
 	}
 
+	return 0;
+}
+
+phys_addr_t __init lmb_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
+{
+	phys_addr_t res = lmb_alloc_nid(size, align, nid);
+
+	if (res)
+		return res;
 	return lmb_alloc(size, align);
 }
 
+
 /*
  * Remaining API functions
  */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
