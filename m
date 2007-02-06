Subject: [RFC/PATCH] prepare_unmapped_area
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070206044516.GA16647@wotan.suse.de>
References: <200702060405.l1645R7G009668@shell0.pdx.osdl.net>
	 <1170736938.2620.213.camel@localhost.localdomain>
	 <20070206044516.GA16647@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 06 Feb 2007 16:04:56 +1100
Message-Id: <1170738296.2620.220.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@linux-foundation.org, hugh@veritas.com, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi folks !

On Cell, I have, for performance reasons, a need to create special
mappings of SPEs that use a different page size as the system base page
size _and_ as the huge page size.

Due to the way the PowerPC memory management works, however, I can only
have one page size per "segment" of 256MB (or 1T) and thus after such a
mapping have been created in its own segment, I need to constraint
-other- vma's to stay out of that area.

This currently cannot be done with the existing arch hooks (because of
MAP_FIXED). However, the hugetlbfs code already has a hack in there to
do the exact same thing for huge pages. Thus, this patch moves that hack
into something that can be overriden by the architectures. This approach
was choosen as the less ugly of the uglies after discussing with Nick
Piggin. If somebody has a better idea, I'd love to hear it.

If it doesn't shoke anybody to death, I'd like to see that in -mm (and
possibly upstream, I don't know yet if my code using that will make
2.6.21 or not, but it would be nice if the list of "dependent" patches
wasn't 3 pages long anyway :-)

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Index: linux-cell/mm/mmap.c
===================================================================
--- linux-cell.orig/mm/mmap.c	2007-02-06 15:56:42.000000000 +1100
+++ linux-cell/mm/mmap.c	2007-02-06 15:59:23.000000000 +1100
@@ -1353,6 +1353,28 @@ void arch_unmap_area_topdown(struct mm_s
 		mm->free_area_cache = mm->mmap_base;
 }
 
+#ifndef HAVE_ARCH_PREPARE_UNMAPPED_AREA
+int arch_prepare_unmapped_area(struct file *file, unsigned long addr,
+			       unsigned long len, unsigned long pgoff,
+			       unsigned long flags)
+{
+	if (file && is_file_hugepages(file))  {
+		/*
+		 * Check if the given range is hugepage aligned, and
+		 * can be made suitable for hugepages.
+		 */
+		return prepare_hugepage_range(addr, len, pgoff);
+	} else {
+		/*
+		 * Ensure that a normal request is not falling in a
+		 * reserved hugepage range.  For some archs like IA-64,
+		 * there is a separate region for hugepages.
+		 */
+		return is_hugepage_only_range(current->mm, addr, len);
+	}
+}
+#endif /* HAVE_ARCH_PREPARE_UNMAPPED_AREA */
+
 unsigned long
 get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
 		unsigned long pgoff, unsigned long flags)
@@ -1374,20 +1396,7 @@ get_unmapped_area(struct file *file, uns
 		return -ENOMEM;
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
+	ret = arch_prepare_unmapped_area(file, addr, len, pgoff, flags);
 	if (ret)
 		return -EINVAL;
 	return addr;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
