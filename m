From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 12 Apr 2007 12:20:31 +1000
Subject: [PATCH 8/12] get_unmapped_area handles MAP_FIXED on sparc64
In-Reply-To: <1176344427.242579.337989891532.qpush@grosgo>
Message-Id: <20070412022033.34908DDF2F@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Handle MAP_FIXED in hugetlb_get_unmapped_area on sparc64
by just using prepare_hugepage_range()

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

 arch/sparc64/mm/hugetlbpage.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-cell/arch/sparc64/mm/hugetlbpage.c
===================================================================
--- linux-cell.orig/arch/sparc64/mm/hugetlbpage.c	2007-03-22 16:12:57.000000000 +1100
+++ linux-cell/arch/sparc64/mm/hugetlbpage.c	2007-03-22 16:15:33.000000000 +1100
@@ -175,6 +175,12 @@ hugetlb_get_unmapped_area(struct file *f
 	if (len > task_size)
 		return -ENOMEM;
 
+	if (flags & MAP_FIXED) {
+		if (prepare_hugepage_range(addr, len, pgoff))
+			return -EINVAL;
+		return addr;
+	}
+
 	if (addr) {
 		addr = ALIGN(addr, HPAGE_SIZE);
 		vma = find_vma(mm, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
