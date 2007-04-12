From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 12 Apr 2007 12:20:32 +1000
Subject: [PATCH 11/12] get_unmapped_area handles MAP_FIXED in generic code
In-Reply-To: <1176344427.242579.337989891532.qpush@grosgo>
Message-Id: <20070412022034.C9DBCDDF31@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

generic arch_get_unmapped_area() now handles MAP_FIXED. Now that
all implementations have been fixed, change the toplevel
get_unmapped_area() to call into arch or drivers for the MAP_FIXED
case.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

 mm/mmap.c |   25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

Index: linux-cell/mm/mmap.c
===================================================================
--- linux-cell.orig/mm/mmap.c	2007-03-22 16:29:22.000000000 +1100
+++ linux-cell/mm/mmap.c	2007-03-22 16:30:06.000000000 +1100
@@ -1199,6 +1199,9 @@ arch_get_unmapped_area(struct file *filp
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
+	if (flags & MAP_FIXED)
+		return addr;
+
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
 		vma = find_vma(mm, addr);
@@ -1272,6 +1275,9 @@ arch_get_unmapped_area_topdown(struct fi
 	if (len > TASK_SIZE)
 		return -ENOMEM;
 
+	if (flags & MAP_FIXED)
+		return addr;
+
 	/* requesting a specific address */
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
@@ -1360,22 +1366,21 @@ get_unmapped_area(struct file *file, uns
 		unsigned long pgoff, unsigned long flags)
 {
 	unsigned long ret;
+	unsigned long (*get_area)(struct file *, unsigned long,
+				  unsigned long, unsigned long, unsigned long);
 
-	if (!(flags & MAP_FIXED)) {
-		unsigned long (*get_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
-
-		get_area = current->mm->get_unmapped_area;
-		if (file && file->f_op && file->f_op->get_unmapped_area)
-			get_area = file->f_op->get_unmapped_area;
-		addr = get_area(file, addr, len, pgoff, flags);
-		if (IS_ERR_VALUE(addr))
-			return addr;
-	}
+	get_area = current->mm->get_unmapped_area;
+	if (file && file->f_op && file->f_op->get_unmapped_area)
+		get_area = file->f_op->get_unmapped_area;
+	addr = get_area(file, addr, len, pgoff, flags);
+	if (IS_ERR_VALUE(addr))
+		return addr;
 
 	if (addr > TASK_SIZE - len)
 		return -ENOMEM;
 	if (addr & ~PAGE_MASK)
 		return -EINVAL;
+
 	if (file && is_file_hugepages(file))  {
 		/*
 		 * Check if the given range is hugepage aligned, and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
