Subject: Re: Helding the Kernel lock while doing IO??? (take 2)
References: <yttpur0wjlk.fsf@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "06 May 2000 03:30:47 +0200"
Date: 06 May 2000 03:34:34 +0200
Message-ID: <ytthfccwjf9.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

>>>>> "juan" == Juan J Quintela <quintela@fi.udc.es> writes:

juan> Hi
juan> In the function m/memory.c()::do_swap_page():

juan> lock_kernel();
juan> swapin_readahead(entry);
juan> page = read_swap_cache(entry);
juan> unlock_kernel();

juan> read_swap_cache is called synchronously, then we can have to wait
juan> until we read the page to liberate the lock kernel.  It is intended?
juan> I am losing some detail?

juan> I have  changed that in the two places that happened.

juan> Thanks in advance for any response.

Sorry for the inconveniences.

First one lacks a wait_on_page:

diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-6/ipc/shm.c testing/ipc/shm.c
--- pre7-6/ipc/shm.c	Fri May  5 23:58:56 2000
+++ testing/ipc/shm.c	Sat May  6 03:16:34 2000
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
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-6/mm/memory.c testing/mm/memory.c
--- pre7-6/mm/memory.c	Fri May  5 23:58:56 2000
+++ testing/mm/memory.c	Sat May  6 03:25:47 2000
@@ -1038,11 +1038,11 @@
 	if (!page) {
 		lock_kernel();
 		swapin_readahead(entry);
-		page = read_swap_cache(entry);
+		page = read_swap_cache_async(entry, 0);
 		unlock_kernel();
 		if (!page)
 			return -1;
-
+                wait_on_page(page);
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
