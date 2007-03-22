From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 22 Mar 2007 17:00:45 +1100
Subject: [RFC/PATCH 5/15] get_unmapped_area handles MAP_FIXED on i386
In-Reply-To: <1174543217.531981.572863804039.qpush@grosgo>
Message-Id: <20070322060229.E9857DE04B@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---

 arch/i386/mm/hugetlbpage.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-cell/arch/i386/mm/hugetlbpage.c
===================================================================
--- linux-cell.orig/arch/i386/mm/hugetlbpage.c	2007-03-22 16:08:12.000000000 +1100
+++ linux-cell/arch/i386/mm/hugetlbpage.c	2007-03-22 16:14:19.000000000 +1100
@@ -367,6 +367,12 @@ hugetlb_get_unmapped_area(struct file *f
 	if (len > TASK_SIZE)
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
