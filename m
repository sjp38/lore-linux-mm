Date: Sat, 6 May 2000 15:16:50 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Helding the Kernel lock while doing IO???
In-Reply-To: <yttpur0wjlk.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0005060509050.2332-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On 6 May 2000, Juan J. Quintela wrote:

>I am losing some detail?

kernel lock is released by schedule(). (the only problem of swapin are the
races with swapoff)

>diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-6/ipc/shm.c testing2/ipc/shm.c
>--- pre7-6/ipc/shm.c	Fri May  5 23:58:56 2000
>+++ testing2/ipc/shm.c	Sat May  6 02:39:17 2000
>@@ -1379,10 +1379,11 @@
> 			if (!page) {
> 				lock_kernel();
> 				swapin_readahead(entry);
>-				page = read_swap_cache(entry);
>+				page = read_swap_cache_async(entry, 0);
> 				unlock_kernel();
> 				if (!page)
> 					goto oom;
>+                                wait_on_page(page);
> 			}
> 			delete_from_swap_cache(page);
> 			page = replace_with_highmem(page);
>diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS pre7-6/mm/memory.c testing2/mm/memory.c
>--- pre7-6/mm/memory.c	Fri May  5 23:58:56 2000
>+++ testing2/mm/memory.c	Sat May  6 02:02:53 2000
>@@ -1038,11 +1038,10 @@
> 	if (!page) {
> 		lock_kernel();
> 		swapin_readahead(entry);
>-		page = read_swap_cache(entry);
>+		page = read_swap_cache_async(entry, 0);
> 		unlock_kernel();
> 		if (!page)
> 			return -1;
>-
> 		flush_page_to_ram(page);
> 		flush_icache_page(vma, page);
> 	}

The above patch would break swapin.

Andrea


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
