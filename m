Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l9PIJ2NA357364
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 18:19:02 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PIJ2iQ2101438
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:02 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PIJ1BM016610
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 20:19:02 +0200
Message-Id: <20071025181901.591007141@de.ibm.com>
References: <20071025181520.880272069@de.ibm.com>
Date: Thu, 25 Oct 2007 20:15:23 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [patch 3/6] arch_update_pgd call
Content-Disposition: inline; filename=003-mm-update-pgd.diff
Sender: owner-linux-mm@kvack.org
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org
Cc: borntraeger@de.ibm.com, benh@kernel.crashing.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

In order to change the layout of the page tables after an mmap has
crossed the adress space limit of the current page table layout a
architecture hook in get_unmapped_area is needed. The arguments
are the address of the new mapping and the length of it.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 mm/mmap.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: quilt-2.6/mm/mmap.c
===================================================================
--- quilt-2.6.orig/mm/mmap.c
+++ quilt-2.6/mm/mmap.c
@@ -36,6 +36,10 @@
 #define arch_mmap_check(addr, len, flags)	(0)
 #endif
 
+#ifndef arch_update_pgd
+#define arch_update_pgd(addr, len)		(addr)
+#endif
+
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
@@ -1420,7 +1424,7 @@ get_unmapped_area(struct file *file, uns
 	if (addr & ~PAGE_MASK)
 		return -EINVAL;
 
-	return addr;
+	return arch_update_pgd(addr, len);
 }
 
 EXPORT_SYMBOL(get_unmapped_area);

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
