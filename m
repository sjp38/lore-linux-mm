Date: Fri, 21 Nov 2003 18:49:47 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] Comments about superflous flush_tlb_range calls.
Message-ID: <20031121174947.GE1341@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,
while searching for a s390 tlb flush problem I noticed some superflous
tlb flushes. One in zeromap_page_range, one in remap_page_range, and
another one in filemap_sync. The patch just adds comments but I think
these three flush_tlb_range calls can be removed. 

blue skies,
  Martin.

diffstat:
 mm/memory.c |    6 ++++++
 mm/msync.c  |    4 ++++
 2 files changed, 10 insertions(+)

diff -urN linux-2.6/mm/memory.c linux-2.6-s390/mm/memory.c
--- linux-2.6/mm/memory.c	Fri Nov 21 16:18:48 2003
+++ linux-2.6-s390/mm/memory.c	Fri Nov 21 16:20:25 2003
@@ -863,6 +863,9 @@
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
+	/*
+	 * Why flush? zeromap_pte_range has a BUG_ON for !pte_none()
+	 */
 	flush_tlb_range(vma, beg, end);
 	spin_unlock(&mm->page_table_lock);
 	return error;
@@ -944,6 +947,9 @@
 		from = (from + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (from && (from < end));
+	/*
+	 * Why flush? remap_pte_range has a BUG_ON for !pte_none()
+	 */
 	flush_tlb_range(vma, beg, end);
 	spin_unlock(&mm->page_table_lock);
 	return error;
diff -urN linux-2.6/mm/msync.c linux-2.6-s390/mm/msync.c
--- linux-2.6/mm/msync.c	Sat Oct 25 20:43:26 2003
+++ linux-2.6-s390/mm/msync.c	Fri Nov 21 16:20:25 2003
@@ -115,6 +115,10 @@
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
+	/*
+	 * Why flush ? filemap_sync_pte already flushed the tlbs with the
+	 * dirty bits.
+	 */
 	flush_tlb_range(vma, end - size, end);
 
 	spin_unlock(&vma->vm_mm->page_table_lock);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
