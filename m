Date: Mon, 5 Jun 2000 13:03:08 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [uPatch] Re: Graceful failure?
In-Reply-To: <14651.49518.825666.298019@rhino.thrillseeker.net>
Message-ID: <Pine.LNX.4.21.0006051258370.31069-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Billy Harvey <Billy.Harvey@thrillseeker.net>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Jun 2000, Billy Harvey wrote:

> A "make -j" slowly over the course of 5 minutes drives the load
> to about 30.  At first the degradation is controlled, with
> sendmail refusing service, but at about 160 process visible in
> top, top quits updating (set a 8 second updates), showing about
> 2 MB swap used.  At this point it sounds like the system is
> thrashing.

That probably means you're a lot more in swap now and top
has stopped displaying before you really hit the swap...

> Is this failure process acceptable?  I'd think the system should
> react differently to the thrashing, killing off the load
> demanding user process(es), rather than degrading to a point of
> freeze.

Please take into account that the system is quite a bit beyond
where you could take previous kernels ... oh, and the attached
patch should fix the problem somewhat ;)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.4.0-t1-ac8/include/linux/mm.h.orig	Wed May 31 21:00:14 2000
+++ linux-2.4.0-t1-ac8/include/linux/mm.h	Sun Jun  4 16:21:31 2000
@@ -202,6 +202,7 @@
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
 #define PageReferenced(page)	test_bit(PG_referenced, &(page)->flags)
 #define SetPageReferenced(page)	set_bit(PG_referenced, &(page)->flags)
+#define ClearPageReferenced(page)	clear_bit(PG_referenced, &(page)->flags)
 #define PageTestandClearReferenced(page)	test_and_clear_bit(PG_referenced, &(page)->flags)
 #define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
 #define SetPageDecrAfter(page)	set_bit(PG_decr_after, &(page)->flags)
--- linux-2.4.0-t1-ac8/include/linux/swap.h.orig	Wed May 31 21:00:06 2000
+++ linux-2.4.0-t1-ac8/include/linux/swap.h	Sun Jun  4 16:22:31 2000
@@ -179,6 +179,7 @@
 	list_add(&(page)->lru, &lru_cache);	\
 	nr_lru_pages++;				\
 	page->age = PG_AGE_START;		\
+	ClearPageReferenced(page);		\
 	SetPageActive(page);			\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
