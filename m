Date: Tue, 3 Apr 2001 20:11:56 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Count swap faults which need to read data from the swap area as
 major faults
Message-ID: <Pine.LNX.4.21.0104032010010.7175-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

Right now we are not accounting faults which nee to read data from swap as
major faults. 

The following patch should fix that. 

Against -ac28. (probably applies against 2.4.3-ac2) 

--- linux/mm/memory.c.orig	Tue Apr  3 21:30:03 2001
+++ linux/mm/memory.c	Tue Apr  3 21:32:18 2001
@@ -1112,6 +1112,7 @@
 {
 	struct page *page;
 	pte_t pte;
+	int ret = 1;
 
 	spin_unlock(&mm->page_table_lock);
 	page = lookup_swap_cache(entry);
@@ -1125,6 +1126,9 @@
 			return -1;
 		}
 
+		/* Had to read the page from swap area: Major fault */
+		ret = 2;
+
 		flush_page_to_ram(page);
 		flush_icache_page(vma, page);
 	}
@@ -1160,7 +1164,7 @@
 
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
-	return 1;	/* Minor fault */
+	return ret;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
