Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA20052
	for <linux-mm@kvack.org>; Tue, 24 Feb 1998 18:40:22 -0500
Date: Tue, 24 Feb 1998 23:38:05 GMT
Message-Id: <199802242338.XAA03259@dax.dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Subject: Re: PATCH: Swap shared pages (was: How to read-protect a vm_area?)
In-Reply-To: <Pine.LNX.3.96.980224152231.7112A-100000@renass3.u-strasbg.fr>
References: <199802232317.XAA06136@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980224152231.7112A-100000@renass3.u-strasbg.fr>
Sender: owner-linux-mm@kvack.org
To: Stephane Casset <sept@renass3.u-strasbg.fr>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 1998 15:31:37 +0000 (GMT), Stephane Casset
<sept@renass3.u-strasbg.fr> said:

>> The patch below, against 2.1.88, adds a bunch of new functionality to
>> the swapper.  The main changes are:

> I tried it but got the following message :
> ipc/ipc.o: In function `shm_swap_in':
> ipc/ipc.o(.text+0x37e4): undefined reference to `read_swap_page'
> ipc/ipc.o: In function `shm_swap':
> ipc/ipc.o(.text+0x3b57): undefined reference to `write_swap_page'
> make: *** [vmlinux] Error 1

The diff below includes a patch against ipc/shm.c was missing from my
first post, and another fix for spurious warnings about shared dirty
pages.

Cheers,
 Stephen.
----------------------------------------------------------------
Index: ipc/shm.c
===================================================================
RCS file: /home/rcs/CVS/kswap3/linux/ipc/shm.c,v
retrieving revision 1.1
retrieving revision 1.2
diff -u -r1.1 -r1.2
--- shm.c	1998/02/24 08:50:30	1.1
+++ shm.c	1998/02/24 08:51:37	1.2
@@ -689,7 +689,7 @@
 			goto done;
 		}
 		if (!pte_none(pte)) {
-			read_swap_page(pte_val(pte), (char *) page);
+			rw_swap_page_nocache(READ, pte_val(pte), (char *)page);
 			pte = __pte(shp->shm_pages[idx]);
 			if (pte_present(pte))  {
 				free_page (page); /* doesn't sleep */
@@ -820,7 +820,7 @@
 	if (atomic_read(&mem_map[MAP_NR(pte_page(page))].count) != 1)
 		goto check_table;
 	shp->shm_pages[idx] = swap_nr;
-	write_swap_page (swap_nr, (char *) pte_page(page));
+	rw_swap_page_nocache (WRITE, swap_nr, (char *) pte_page(page));
 	free_page(pte_page(page));
 	swap_successes++;
 	shm_swp++;
Index: mm/page_io.c
===================================================================
RCS file: /home/rcs/CVS/kswap3/linux/mm/page_io.c,v
retrieving revision 1.4
diff -u -r1.4 page_io.c
--- page_io.c	1998/02/23 22:14:27	1.4
+++ page_io.c	1998/02/24 09:28:08
@@ -201,7 +201,9 @@
 	}
 	page->inode = &swapper_inode;
 	page->offset = entry;
+	atomic_inc(&page->count);	/* Protect from shrink_mmap() */
 	rw_swap_page(rw, entry, buffer, 1);
+	atomic_dec(&page->count);
 	page->inode = 0;
 	clear_bit(PG_swap_cache, &page->flags);
 }
Index: mm/vmscan.c
===================================================================
RCS file: /home/rcs/CVS/kswap3/linux/mm/vmscan.c,v
retrieving revision 1.5
diff -u -r1.5 vmscan.c
--- vmscan.c	1998/02/23 22:14:28	1.5
+++ vmscan.c	1998/02/24 09:22:47
@@ -108,18 +108,16 @@
 	 *
 	 * -- Stephen Tweedie 1998 */
 
-	if (pte_write(pte)) {
-		/* 
-		 * We _will_ allow dirty cached mappings later on, once
-		 * MAP_SHARED|MAP_ANONYMOUS is working, but for now
-		 * catch this as a bug.
-		 */
-		if (is_page_shared(page_map)) {
-			printk ("VM: Found a shared writable dirty page!\n");
+	if (PageSwapCache(page_map)) {
+		if (pte_write(pte)) {
+			printk ("VM: Found a writable swap-cached page!\n");
 			return 0;
 		}
-		if (PageSwapCache(page_map)) {
-			printk ("VM: Found a writable swap-cached page!\n");
+		/* We _will_ allow dirty cached mappings later
+		 * on, once MAP_SHARED|MAP_ANONYMOUS is working,
+		 * but for now catch this as a bug.  */
+		if (is_page_shared(page_map)) {
+			printk ("VM: Found a shared writable dirty page!\n");
 			return 0;
 		}
 	}
----------------------------------------------------------------
