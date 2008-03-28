Message-Id: <20080328015422.561646000@nick.local0.net>
References: <20080328015238.519230000@nick.local0.net>
Date: Fri, 28 Mar 2008 12:52:45 +1100
From: npiggin@suse.de
Subject: [patch 7/7] s390: remove struct page entries for DCSS memory segments
Content-Disposition: inline; filename=s390-remove-struct-page-entries-for-DCSS-memory-segments.patch
Sender: owner-linux-mm@kvack.org
From: Carsten Otte <cotte@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch removes struct page entries for DCSS segments that are being loaded.
They can still be accessed correctly, thanks to the struct page-less XIP work
of previous patches.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jared Hulbert <jaredeh@gmail.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/mm/vmem.c |   18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

Index: linux-2.6/arch/s390/mm/vmem.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/vmem.c
+++ linux-2.6/arch/s390/mm/vmem.c
@@ -323,8 +323,6 @@ out:
 int add_shared_memory(unsigned long start, unsigned long size)
 {
 	struct memory_segment *seg;
-	struct page *page;
-	unsigned long pfn, num_pfn, end_pfn;
 	int ret;
 
 	mutex_lock(&vmem_mutex);
@@ -339,24 +337,10 @@ int add_shared_memory(unsigned long star
 	if (ret)
 		goto out_free;
 
-	ret = vmem_add_mem(start, size);
+	ret = vmem_add_range(start, size);
 	if (ret)
 		goto out_remove;
 
-	pfn = PFN_DOWN(start);
-	num_pfn = PFN_DOWN(size);
-	end_pfn = pfn + num_pfn;
-
-	page = pfn_to_page(pfn);
-	memset(page, 0, num_pfn * sizeof(struct page));
-
-	for (; pfn < end_pfn; pfn++) {
-		page = pfn_to_page(pfn);
-		init_page_count(page);
-		reset_page_mapcount(page);
-		SetPageReserved(page);
-		INIT_LIST_HEAD(&page->lru);
-	}
 	goto out;
 
 out_remove:

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
