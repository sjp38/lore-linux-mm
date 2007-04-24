From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 24 Apr 2007 15:33:37 +1000
Subject: [PATCH 8/12] get_unmapped_area handles MAP_FIXED on sparc64
In-Reply-To: <1177392813.924664.32930750763.qpush@grosgo>
Message-Id: <20070424053340.5B581DDF0E@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Handle MAP_FIXED in hugetlb_get_unmapped_area on sparc64
by just using prepare_hugepage_range()

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Acked-by: William Irwin <bill.irwin@oracle.com>

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
