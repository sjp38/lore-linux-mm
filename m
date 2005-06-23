Message-ID: <42BA5F7B.30904@yahoo.com.au>
Date: Thu, 23 Jun 2005 17:06:35 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch][rfc] 2/5: micro optimisation for mm/rmap.c
References: <42BA5F37.6070405@yahoo.com.au> <42BA5F5C.3080101@yahoo.com.au>
In-Reply-To: <42BA5F5C.3080101@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------060707040302090207070309"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
Cc: Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060707040302090207070309
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

2/5

--------------060707040302090207070309
Content-Type: text/plain;
 name="mm-microopt-rmap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-microopt-rmap.patch"

Microoptimise page_add_anon_rmap. Although these expressions are used only
in the taken branch of the if() statement, the compiler can't reorder them
inside because atomic_inc_and_test is a barrier.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -442,22 +442,23 @@ int page_referenced(struct page *page, i
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
-	struct anon_vma *anon_vma = vma->anon_vma;
-	pgoff_t index;
-
 	BUG_ON(PageReserved(page));
-	BUG_ON(!anon_vma);
 
 	inc_mm_counter(vma->vm_mm, anon_rss);
 
-	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	index = (address - vma->vm_start) >> PAGE_SHIFT;
-	index += vma->vm_pgoff;
-	index >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
-
 	if (atomic_inc_and_test(&page->_mapcount)) {
-		page->index = index;
+		struct anon_vma *anon_vma = vma->anon_vma;
+		pgoff_t index;
+
+		BUG_ON(!anon_vma);
+		anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 		page->mapping = (struct address_space *) anon_vma;
+
+		index = (address - vma->vm_start) >> PAGE_SHIFT;
+		index += vma->vm_pgoff;
+		index >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
+		page->index = index;
+
 		inc_page_state(nr_mapped);
 	}
 	/* else checking page index and mapping is racy */

--------------060707040302090207070309--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
