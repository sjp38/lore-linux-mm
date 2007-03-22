From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 22 Mar 2007 17:00:56 +1100
Subject: [RFC/PATCH 6/15] get_unmapped_area handles MAP_FIXED on ia64
In-Reply-To: <1174543217.531981.572863804039.qpush@grosgo>
Message-Id: <20070322060239.BC328DE131@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

---

 arch/ia64/kernel/sys_ia64.c |    7 +++++++
 arch/ia64/mm/hugetlbpage.c  |    8 ++++++++
 2 files changed, 15 insertions(+)

Index: linux-cell/arch/ia64/kernel/sys_ia64.c
===================================================================
--- linux-cell.orig/arch/ia64/kernel/sys_ia64.c	2007-03-22 15:10:45.000000000 +1100
+++ linux-cell/arch/ia64/kernel/sys_ia64.c	2007-03-22 15:10:47.000000000 +1100
@@ -33,6 +33,13 @@ arch_get_unmapped_area (struct file *fil
 	if (len > RGN_MAP_LIMIT)
 		return -ENOMEM;
 
+	/* handle fixed mapping: prevent overlap with huge pages */
+	if (flags & MAP_FIXED) {
+		if (is_hugepage_only_range(mm, addr, len))
+			return -EINVAL;
+		return addr;
+	}
+
 #ifdef CONFIG_HUGETLB_PAGE
 	if (REGION_NUMBER(addr) == RGN_HPAGE)
 		addr = 0;
Index: linux-cell/arch/ia64/mm/hugetlbpage.c
===================================================================
--- linux-cell.orig/arch/ia64/mm/hugetlbpage.c	2007-03-22 15:12:32.000000000 +1100
+++ linux-cell/arch/ia64/mm/hugetlbpage.c	2007-03-22 15:12:39.000000000 +1100
@@ -148,6 +148,14 @@ unsigned long hugetlb_get_unmapped_area(
 		return -ENOMEM;
 	if (len & ~HPAGE_MASK)
 		return -EINVAL;
+
+	/* Handle MAP_FIXED */
+	if (flags & MAP_FIXED) {
+		if (prepare_hugepage_range(addr, len, pgoff))
+			return -EINVAL;
+		return addr;
+	}
+
 	/* This code assumes that RGN_HPAGE != 0. */
 	if ((REGION_NUMBER(addr) != RGN_HPAGE) || (addr & (HPAGE_SIZE - 1)))
 		addr = HPAGE_REGION_BASE;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
