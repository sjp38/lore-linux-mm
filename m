Date: Thu, 2 Nov 2000 13:40:21 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001102134021.B1876@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="n+lFg1Zro7sl44OB"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--n+lFg1Zro7sl44OB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Next part of the kiobuf diffs: fix the fact that handle_mm_fault
doesn't guarantee to complete the operation in all cases; doesn't
guarantee that the resulting pte is writable if write access was
requested; and doesn't pin the page against immediately being swapped
back out.

--Stephen


--n+lFg1Zro7sl44OB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="02-faultfix.diff"

Only in linux-2.4.0-test10.kio.01/drivers/char: raw.c.~1~
Only in linux-2.4.0-test10.kio.01/fs: buffer.c.~1~
Only in linux-2.4.0-test10.kio.01/fs: iobuf.c.~1~
Only in linux-2.4.0-test10.kio.01/include/linux: iobuf.h.~1~
diff -ru linux-2.4.0-test10.kio.01/mm/memory.c linux-2.4.0-test10.kio.02/mm/memory.c
--- linux-2.4.0-test10.kio.01/mm/memory.c	Thu Nov  2 11:59:11 2000
+++ linux-2.4.0-test10.kio.02/mm/memory.c	Thu Nov  2 12:39:16 2000
@@ -384,7 +384,7 @@
 /*
  * Do a quick page-table lookup for a single page. 
  */
-static struct page * follow_page(unsigned long address) 
+static struct page * follow_page(unsigned long address, int write) 
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
@@ -394,7 +394,8 @@
 	if (pmd) {
 		pte_t * pte = pte_offset(pmd, address);
 		if (pte && pte_present(*pte))
-			return pte_page(*pte);
+			if (!write || pte_write(*pte))
+				return pte_page(*pte);
 	}
 	
 	return NULL;
@@ -474,11 +475,14 @@
 		if (handle_mm_fault(current->mm, vma, ptr, datain) <= 0) 
 			goto out_unlock;
 		spin_lock(&mm->page_table_lock);
-		map = follow_page(ptr);
+		map = follow_page(ptr, datain);
 		if (!map) {
+			/* If handle_mm_fault did not complete the
+                           operation, or if we hit the swapout race
+                           before taking the page_table_lock, just try
+                           again on this page. */
 			spin_unlock(&mm->page_table_lock);
-			dprintk (KERN_ERR "Missing page in map_user_kiobuf\n");
-			goto out_unlock;
+			continue;
 		}
 		map = get_page_map(map);
 		if (map)
Only in linux-2.4.0-test10.kio.01/mm: memory.c.~1~

--n+lFg1Zro7sl44OB--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
