Date: Tue, 15 Jun 2004 19:44:36 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] s390: lost dirty bits.
Message-ID: <20040615174436.GA10098@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,
we just tracked down a severe bug in the memory management
code of s390. There is a race window where s390 can loose
a dirty bit. I never expected that SetPageUptodate is called
on an already up to date page...

blue skies,
  Martin.

---

[PATCH] s390: lost dirty bits.

The SetPageUptodate function is called for pages that are already
up to date. The arch_set_page_uptodate function of s390 may not
clear the dirty bit in that case otherwise a dirty bit which is set
between the start of an i/o for a writeback and a following call
to SetPageUptodate is lost.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

diffstat:

--- linux-2.5/include/asm-s390/pgtable.h	24 Mar 2004 18:18:22 -0000	1.23
+++ linux-2.5/include/asm-s390/pgtable.h	15 Jun 2004 16:43:35 -0000	1.23.2.1
@@ -652,7 +652,8 @@
 
 #define arch_set_page_uptodate(__page)					  \
 	do {								  \
-		asm volatile ("sske %0,%1" : : "d" (0),			  \
+		if (!PageUptodate(__page))				  \
+			asm volatile ("sske %0,%1" : : "d" (0),		  \
 			      "a" (__pa((__page-mem_map) << PAGE_SHIFT)));\
 	} while (0)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
