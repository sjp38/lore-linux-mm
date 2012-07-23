Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 6E5A66B0062
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:38:51 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/34] mm: memory hotplug: Check if pages are correctly reserved on a per-section basis
Date: Mon, 23 Jul 2012 14:38:15 +0100
Message-Id: <1343050727-3045-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit 2bbcb8788311a40714b585fc11b51da6ffa2ab92 upstream.

Stable note: Fixes https://bugzilla.novell.com/show_bug.cgi?id=721039 .
	Without the patch, memory hot-add can fail for kernel configurations
	that do not set CONFIG_SPARSEMEM_VMEMMAP.

It is expected that memory being brought online is PageReserved
similar to what happens when the page allocator is being brought up.
Memory is onlined in "memory blocks" which consist of one or more
sections. Unfortunately, the code that verifies PageReserved is
currently assuming that the memmap backing all these pages is virtually
contiguous which is only the case when CONFIG_SPARSEMEM_VMEMMAP is set.

This patch updates the PageReserved check to lookup struct page once per
section to guarantee the correct struct page is being checked.

[Check pages within sections properly: rientjes@google.com]
[original patch by: nfont@linux.vnet.ibm.com]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Tested-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 drivers/base/memory.c |   58 ++++++++++++++++++++++++++++++++++---------------
 1 file changed, 40 insertions(+), 18 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 45d7c8f..5fb6aae 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -224,13 +224,48 @@ int memory_isolate_notify(unsigned long val, void *v)
 }
 
 /*
+ * The probe routines leave the pages reserved, just as the bootmem code does.
+ * Make sure they're still that way.
+ */
+static bool pages_correctly_reserved(unsigned long start_pfn,
+					unsigned long nr_pages)
+{
+	int i, j;
+	struct page *page;
+	unsigned long pfn = start_pfn;
+
+	/*
+	 * memmap between sections is not contiguous except with
+	 * SPARSEMEM_VMEMMAP. We lookup the page once per section
+	 * and assume memmap is contiguous within each section
+	 */
+	for (i = 0; i < sections_per_block; i++, pfn += PAGES_PER_SECTION) {
+		if (WARN_ON_ONCE(!pfn_valid(pfn)))
+			return false;
+		page = pfn_to_page(pfn);
+
+		for (j = 0; j < PAGES_PER_SECTION; j++) {
+			if (PageReserved(page + j))
+				continue;
+
+			printk(KERN_WARNING "section number %ld page number %d "
+				"not reserved, was it already online?\n",
+				pfn_to_section_nr(pfn), j);
+
+			return false;
+		}
+	}
+
+	return true;
+}
+
+/*
  * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
  * OK to have direct references to sparsemem variables in here.
  */
 static int
 memory_block_action(unsigned long phys_index, unsigned long action)
 {
-	int i;
 	unsigned long start_pfn, start_paddr;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	struct page *first_page;
@@ -238,26 +273,13 @@ memory_block_action(unsigned long phys_index, unsigned long action)
 
 	first_page = pfn_to_page(phys_index << PFN_SECTION_SHIFT);
 
-	/*
-	 * The probe routines leave the pages reserved, just
-	 * as the bootmem code does.  Make sure they're still
-	 * that way.
-	 */
-	if (action == MEM_ONLINE) {
-		for (i = 0; i < nr_pages; i++) {
-			if (PageReserved(first_page+i))
-				continue;
-
-			printk(KERN_WARNING "section number %ld page number %d "
-				"not reserved, was it already online?\n",
-				phys_index, i);
-			return -EBUSY;
-		}
-	}
-
 	switch (action) {
 		case MEM_ONLINE:
 			start_pfn = page_to_pfn(first_page);
+
+			if (!pages_correctly_reserved(start_pfn, nr_pages))
+				return -EBUSY;
+
 			ret = online_pages(start_pfn, nr_pages);
 			break;
 		case MEM_OFFLINE:
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
