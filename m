Date: Tue, 14 Aug 2007 06:36:31 -0500
Subject: [PATCH] calculation of pgoff in do_linear_fault() uses mixed
 units
Message-ID: <46C193BF.mailxDHL111USQ@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: dcn@sgi.com (Dean Nelson)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The calculation of pgoff in do_linear_fault() should use PAGE_SHIFT and not
PAGE_CACHE_SHIFT since vma->vm_pgoff is in units of PAGE_SIZE and not
PAGE_CACHE_SIZE. At the moment linux/pagemap.h has PAGE_CACHE_SHIFT defined
as PAGE_SHIFT, but should that ever change this calculation would break.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2007-08-10 09:11:32.000000000 -0500
+++ linux-2.6/mm/memory.c	2007-08-14 06:26:11.731319983 -0500
@@ -2466,7 +2466,7 @@
 		int write_access, pte_t orig_pte)
 {
 	pgoff_t pgoff = (((address & PAGE_MASK)
-			- vma->vm_start) >> PAGE_CACHE_SHIFT) + vma->vm_pgoff;
+			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 	unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
 
 	return __do_fault(mm, vma, address, page_table, pmd, pgoff,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
