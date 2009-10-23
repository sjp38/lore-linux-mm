Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id F2E696B0073
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 13:11:45 -0400 (EDT)
Message-Id: <20091023171132.783398962@sequoia.sous-sol.org>
Date: Fri, 23 Oct 2009 10:10:53 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: [RFC PATCH 2/2] bootmem: add free_bootmem_late
References: <20091023171051.993073846@sequoia.sous-sol.org>
Content-Disposition: inline; filename=bootmem-make-free_pages_bootmem-generic.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: David Woodhouse <dwmw2@infradead.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add a new function for freeing bootmem after the bootmem allocator has
been released and the unreserved pages given to the page allocator.
This allows us to reserve bootmem and then release it if we later
discover it was not needed.

Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---
 include/linux/bootmem.h |    1 +
 mm/bootmem.c            |   43 ++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 39 insertions(+), 5 deletions(-)

--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -53,6 +53,7 @@ extern void free_bootmem_node(pg_data_t 
 			      unsigned long addr,
 			      unsigned long size);
 extern void free_bootmem(unsigned long addr, unsigned long size);
+extern void free_bootmem_late(unsigned long addr, unsigned long size);
 
 /*
  * Flags for reserve_bootmem (also if CONFIG_HAVE_ARCH_BOOTMEM_NODE,
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -151,7 +151,9 @@ unsigned long __init init_bootmem(unsign
  *
  * This will free the pages in the range @start to @end, making them
  * available to the page allocator.  The @map will be used to skip
- * reserved pages.  Returns the count of pages freed.
+ * reserved pages.  In the case that @map is NULL, the bootmem allocator
+ * is already free and the range is contiguous.  Returns the count of
+ * pages freed.
  */
 static unsigned long __init free_bootmem_pages(unsigned long start,
 					       unsigned long end,
@@ -164,13 +166,23 @@ static unsigned long __init free_bootmem
 	 * If the start is aligned to the machines wordsize, we might
 	 * be able to free pages in bulks of that order.
 	 */
-	aligned = !(start & (BITS_PER_LONG - 1));
+	if (map)
+		aligned = !(start & (BITS_PER_LONG - 1));
+	else
+		aligned = 1;
 
 	for (cursor = start; cursor < end; cursor += BITS_PER_LONG) {
-		unsigned long idx, vec;
+		unsigned long vec;
 
-		idx = cursor - start;
-		vec = ~map[idx / BITS_PER_LONG];
+		if (map) {
+			unsigned long idx = cursor - start;
+			vec = ~map[idx / BITS_PER_LONG];
+		} else {
+			if (end - cursor >= BITS_PER_LONG)
+				vec = ~0UL;
+			else
+				vec = (1UL << (end - cursor)) - 1;
+		}
 
 		if (aligned && vec == ~0UL && cursor + BITS_PER_LONG < end) {
 			int order = ilog2(BITS_PER_LONG);
@@ -387,6 +399,27 @@ void __init free_bootmem(unsigned long a
 }
 
 /**
+ * free_bootmem_late - free bootmem pages directly to page allocator
+ * @addr: starting address of the range
+ * @size: size of the range in bytes
+ *
+ * This is only useful when the bootmem allocator has already been torn
+ * down, but we are still initializing the system.  Pages are given directly
+ * to the page allocator, no bootmem metadata is updated because it is gone.
+ */
+void __init free_bootmem_late(unsigned long addr, unsigned long size)
+{
+	unsigned long start, end;
+
+	kmemleak_free_part(__va(addr), size);
+
+	start = PFN_UP(addr);
+	end = PFN_DOWN(addr + size);
+
+	totalram_pages += free_bootmem_pages(start, end, NULL);
+}
+
+/**
  * reserve_bootmem_node - mark a page range as reserved
  * @pgdat: node the range resides on
  * @physaddr: starting address of the range

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
