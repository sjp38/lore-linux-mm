Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4C56200C5
	for <linux-mm@kvack.org>; Mon, 10 May 2010 05:41:01 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 22/25] lmb: NUMA allocate can now use early_pfn_map
Date: Mon, 10 May 2010 19:38:56 +1000
Message-Id: <1273484339-28911-23-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-22-git-send-email-benh@kernel.crashing.org>
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
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

We now provide a default (weak) implementation of lmb_nid_range()
which uses the early_pfn_map[] if CONFIG_ARCH_POPULATES_NODE_MAP
is set. Sparc still needs to use its own method due to the way
the pages can be scattered between nodes.

This implementation is inefficient due to our main algorithm and
callback construct wanting to work on an ascending addresses bases
while early_pfn_map[] would rather work with nid's (it's unsorted
at that stage). But it should work and we can look into improving
it subsequently, possibly using arch compile options to chose a
different algorithm alltogether.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 include/linux/lmb.h |    3 +++
 lib/lmb.c           |   28 +++++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/include/linux/lmb.h b/include/linux/lmb.h
index 404b49c..45724a6 100644
--- a/include/linux/lmb.h
+++ b/include/linux/lmb.h
@@ -47,6 +47,9 @@ extern long lmb_remove(phys_addr_t base, phys_addr_t size);
 extern long __init lmb_free(phys_addr_t base, phys_addr_t size);
 extern long __init lmb_reserve(phys_addr_t base, phys_addr_t size);
 
+/* The numa aware allocator is only available if
+ * CONFIG_ARCH_POPULATES_NODE_MAP is set
+ */
 extern phys_addr_t __init lmb_alloc_nid(phys_addr_t size, phys_addr_t align, int nid);
 extern phys_addr_t __init lmb_alloc(phys_addr_t size, phys_addr_t align);
 
diff --git a/lib/lmb.c b/lib/lmb.c
index 848f908..f4b2f95 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -15,6 +15,7 @@
 #include <linux/init.h>
 #include <linux/bitops.h>
 #include <linux/poison.h>
+#include <linux/pfn.h>
 #include <linux/lmb.h>
 
 struct lmb lmb;
@@ -439,11 +440,36 @@ phys_addr_t __init lmb_alloc(phys_addr_t size, phys_addr_t align)
 /*
  * Additional node-local allocators. Search for node memory is bottom up
  * and walks lmb regions within that node bottom-up as well, but allocation
- * within an lmb region is top-down.
+ * within an lmb region is top-down. XXX I plan to fix that at some stage
+ *
+ * WARNING: Only available after early_node_map[] has been populated,
+ * on some architectures, that is after all the calls to add_active_range()
+ * have been done to populate it.
  */
  
 phys_addr_t __weak __init lmb_nid_range(phys_addr_t start, phys_addr_t end, int *nid)
 {
+#ifdef CONFIG_ARCH_POPULATES_NODE_MAP
+	/*
+	 * This code originates from sparc which really wants use to walk by addresses
+	 * and returns the nid. This is not very convenient for early_pfn_map[] users
+	 * as the map isn't sorted yet, and it really wants to be walked by nid.
+	 *
+	 * For now, I implement the inefficient method below which walks the early
+	 * map multiple times. Eventually we may want to use an ARCH config option
+	 * to implement a completely different method for both case.
+	 */
+	unsigned long start_pfn, end_pfn;
+	int i;
+	
+	for (i = 0; i < MAX_NUMNODES; i++) {
+		get_pfn_range_for_nid(i, &start_pfn, &end_pfn);
+		if (start < PFN_PHYS(start_pfn) || start >= PFN_PHYS(end_pfn))
+			continue;
+		*nid = i;
+		return min(end, PFN_PHYS(end_pfn));
+	}
+#endif
 	*nid = 0;
 
 	return end;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
