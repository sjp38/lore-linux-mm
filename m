From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 04 Apr 2007 14:02:22 +1000
Subject: [PATCH 14/14] get_unmapped_area doesn't need hugetlbfs hacks anymore 
In-Reply-To: <1175659331.690672.592289266160.qpush@grosgo>
Message-Id: <20070404040233.35EC6DDE3F@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---

 mm/mmap.c |   16 ----------------
 1 file changed, 16 deletions(-)

Index: linux-cell/mm/mmap.c
===================================================================
--- linux-cell.orig/mm/mmap.c	2007-03-22 16:30:24.000000000 +1100
+++ linux-cell/mm/mmap.c	2007-03-22 16:30:48.000000000 +1100
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
