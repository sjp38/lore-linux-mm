Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA21554
	for <linux-mm@kvack.org>; Mon, 15 Mar 1999 21:17:39 -0500
Date: Tue, 16 Mar 1999 03:11:25 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: A couple of questions
In-Reply-To: <199903151858.SAA02057@dax.scot.redhat.com>
Message-ID: <Pine.LNX.4.05.9903160239270.360-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Neil Booth <NeilB@earthling.net>, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 1999, Stephen C. Tweedie wrote:

>--- mm/memory.c~	Tue Jan 19 01:33:10 1999
>+++ mm/memory.c	Mon Mar 15 18:57:31 1999
>@@ -651,13 +651,13 @@
> 		delete_from_swap_cache(page_map);
> 		/* FallThrough */
> 	case 1:
>-		/* We can release the kernel lock now.. */
>-		unlock_kernel();
>-
> 		flush_cache_page(vma, address);
> 		set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
> 		flush_tlb_page(vma, address);
> end_wp_page:
>+		/* We can release the kernel lock now.. */
>+		unlock_kernel();
>+
> 		if (new_page)
> 			free_page(new_page);
> 		return 1;
>----------------------------------------------------------------

Your sure safe patch is strictly needed according to me in order to
release the lock_kernel in the end_wp_page path.

The reason I think it's just safe remove the lock_kernel before updating
the page table of the process is because the swap_out engine will do
nothing with the page until it will be a clean page (and should be clean
because it was read-only in first place.... am I really right here?).
Every other part of the VM will block on the semaphore so it won't race
anyway with the page fault handler.

I think this patch against 2.2.3 looks needed to me (except the first
chunk that is only removing superflous code).

Seems to works fine after some minute of stress-testing.

Index: mm//memory.c
===================================================================
RCS file: /var/cvs/linux/mm/memory.c,v
retrieving revision 1.1.2.3
diff -u -r1.1.2.3 memory.c
--- memory.c	1999/01/24 02:46:31	1.1.2.3
+++ linux/mm/memory.c	1999/03/16 01:55:45
@@ -624,10 +624,6 @@
 	/* Did someone else copy this page for us while we slept? */
 	if (pte_val(*page_table) != pte_val(pte))
 		goto end_wp_page;
-	if (!pte_present(pte))
-		goto end_wp_page;
-	if (pte_write(pte))
-		goto end_wp_page;
 	old_page = pte_page(pte);
 	if (MAP_NR(old_page) >= max_mapnr)
 		goto bad_wp_page;
@@ -651,13 +647,18 @@
 		delete_from_swap_cache(page_map);
 		/* FallThrough */
 	case 1:
-		/* We can release the kernel lock now.. */
+		/*
+		 * We can release the kernel lock now.. because the swap_out
+		 * engine will do nothing with the page table until it
+		 * will be a clean page (and we are sure it's clean because it
+		 * wasn't writable yet). All other parts of the VM will
+		 * stop on the mmap semaphore. -arca
+		 */
 		unlock_kernel();
 
 		flush_cache_page(vma, address);
 		set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
 		flush_tlb_page(vma, address);
-end_wp_page:
 		if (new_page)
 			free_page(new_page);
 		return 1;
@@ -681,9 +682,15 @@
 bad_wp_page:
 	printk("do_wp_page: bogus page at address %08lx (%08lx)\n",address,old_page);
 	send_sig(SIGKILL, tsk, 1);
+	unlock_kernel();
 	if (new_page)
 		free_page(new_page);
 	return 0;
+end_wp_page:
+	unlock_kernel();
+	if (new_page)
+		free_page(new_page);
+	return 1;
 }
 
 /*



Andrea Arcangeli


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
