Subject: PATCH: SHM Bug in Highmem machines
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 10 May 2000 04:14:30 +0200
Message-ID: <ytt4s87tam1.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi
        I think that SHM can't work in recent kernels, due to the fact 
that We call prepare_highmem_swapout without locking the page (that is
necesary with the new semantics).  If we don't do that change, the
page returned by prepare_highmem_swapout will be already
locked and our call to lock will sleep forever.

Later, Juan.

PD. Christoph, could you see if that helps your problems (you are the only
person that I know that use highmem & shm).

--- pre7-8/ipc/shm.c	Tue May  9 13:20:26 2000
+++ testing/ipc/shm.c	Wed May 10 04:11:00 2000
@@ -1428,6 +1428,7 @@
 	if (page_count(page_map) != 1)
 		return RETRY;
 
+	lock_page(page_map);
 	if (!(page_map = prepare_highmem_swapout(page_map)))
 		return FAILED;
 	SHM_ENTRY (shp, idx) = swp_entry_to_pte(swap_entry);
@@ -1437,7 +1438,6 @@
 	   reading a not yet uptodate block from disk.
 	   NOTE: we just accounted the swap space reference for this
 	   swap cache page at __get_swap_page() time. */
-	lock_page(page_map);
 	add_to_swap_cache(*outpage = page_map, swap_entry);
 	return OKAY;
 }

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
