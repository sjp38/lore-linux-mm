Subject: Helding the Kernel lock while doing IO???
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 06 May 2000 03:30:47 +0200
Message-ID: <yttpur0wjlk.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi
        In the function m/memory.c()::do_swap_page():

		lock_kernel();
		swapin_readahead(entry);
		page = read_swap_cache(entry);
		unlock_kernel();

read_swap_cache is called synchronously, then we can have to wait
until we read the page to liberate the lock kernel.  It is intended?
I am losing some detail?

I have  changed that in the two places that happened.

Thanks in advance for any response.

Later, Juan.

diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-6/ipc/shm.c testing2/ipc/shm.c
--- pre7-6/ipc/shm.c	Fri May  5 23:58:56 2000
+++ testing2/ipc/shm.c	Sat May  6 02:39:17 2000
@@ -1379,10 +1379,11 @@
 			if (!page) {
 				lock_kernel();
 				swapin_readahead(entry);
-				page = read_swap_cache(entry);
+				page = read_swap_cache_async(entry, 0);
 				unlock_kernel();
 				if (!page)
 					goto oom;
+                                wait_on_page(page);
 			}
 			delete_from_swap_cache(page);
 			page = replace_with_highmem(page);
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-6/mm/memory.c testing2/mm/memory.c
--- pre7-6/mm/memory.c	Fri May  5 23:58:56 2000
+++ testing2/mm/memory.c	Sat May  6 02:02:53 2000
@@ -1038,11 +1038,10 @@
 	if (!page) {
 		lock_kernel();
 		swapin_readahead(entry);
-		page = read_swap_cache(entry);
+		page = read_swap_cache_async(entry, 0);
 		unlock_kernel();
 		if (!page)
 			return -1;
-
 		flush_page_to_ram(page);
 		flush_icache_page(vma, page);
 	}


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
