Date: Sat, 9 Jun 2001 00:46:08 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106081743070.2699-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0106090044060.10415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, "David S. Miller" <davem@redhat.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Jun 2001, Marcelo Tosatti wrote:

> Yes, we want fair aging. No, we dont want more pages being swapped out. 
> 
> Well, I'll take a look at this. 

OK, I found a MUCH more serious issue in 2.4.6-pre1 ... this one
makes page_launder() actively work at making it impossible for the
system to fulfill the inactive_target and will make the system work
in refill_inactive() basically infinitely, doing page aging just for
the hell of it.

vmscan.c:
@@ -463,6 +458,7 @@
 
                /* Page is or was in use?  Move it to the active list. */
                if (PageReferenced(page) || page->age > 0 ||
+                               page->zone->free_pages > page->zone->pages_high ||
                                (!page->buffers && page_count(page) > 1) ||
                                page_ramdisk(page)) {
                        del_page_from_inactive_dirty_list(page);

This thing needs to go.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
