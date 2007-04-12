From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 12 Apr 2007 12:20:33 +1000
Subject: [PATCH 12/12] get_unmapped_area doesn't need hugetlbfs hacks anymore 
In-Reply-To: <1176344427.242579.337989891532.qpush@grosgo>
Message-Id: <20070412022035.4BD9CDDF32@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Remove the hugetlbfs specific hacks in toplevel get_unmapped_area() now
that all archs and hugetlbfs itself do the right thing for both cases.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

 mm/mmap.c |   16 ----------------
 1 file changed, 16 deletions(-)

Index: linux-cell/mm/mmap.c
===================================================================
--- linux-cell.orig/mm/mmap.c	2007-04-12 12:14:46.000000000 +1000
+++ linux-cell/mm/mmap.c	2007-04-12 12:14:47.000000000 +1000
@@ -1381,22 +1381,6 @@ get_unmapped_area(struct file *file, uns
 	if (addr & ~PAGE_MASK)
 		return -EINVAL;
 
-	if (file && is_file_hugepages(file))  {
-		/*
-		 * Check if the given range is hugepage aligned, and
-		 * can be made suitable for hugepages.
-		 */
-		ret = prepare_hugepage_range(addr, len, pgoff);
-	} else {
-		/*
-		 * Ensure that a normal request is not falling in a
-		 * reserved hugepage range.  For some archs like IA-64,
-		 * there is a separate region for hugepages.
-		 */
-		ret = is_hugepage_only_range(current->mm, addr, len);
-	}
-	if (ret)
-		return -EINVAL;
 	return addr;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
