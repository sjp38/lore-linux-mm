Received: from localhost by fenrus.demon.nl
	via sendmail with esmtp
	id <m12qu1v-000OVtC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for <linux-mm@kvack.org>; Sun, 14 May 2000 10:45:43 +0200 (CEST)
Date: Sun, 14 May 2000 10:45:42 +0200 (CEST)
From: Arjan van de Ven <arjan@fenrus.demon.nl>
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.10.10005132035370.2422-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.05.10005141023530.2330-100000@fenrus.demon.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > My idea is (but I have not tested this) that for priority == 0 (aka "Uh oh")
> > shrink_mmap or do_try_to_free_pages have to block while waiting for pages to
> > be commited to disk. As far as I can see, shrink_mmap just skips pages that
> > are being commited to disk, while these could be freed when they are waited
> > upon. 

> probably fine, and you could try to just change "sync_page_buffers()" back
> to the code that did 
> 
> 	if (buffer_locked(p))
> 		__wait_on_buffer(p);
> 	else if (buffer_dirty(p))
> 		ll_rw_block(WRITE, 1, &p);
> 
> (instead of the current "buffer_dirty(p) && !buffer_locked(p)" test that
> only starts the IO).

I changed this a bit, so that the __wait_on_buffer only gets called for
do_try_to_free_pages priority 0. With this, mmap002 doesn't OOM anymore. 


> How does it feel performance-wise?

This is a bit hard to say, as my testbox is headless. However, I started
Netscape on it (over a 100Mbit network) and did a "make -j2 bzImage" at
the same time. Netscape didn't seem to suffer, but there was usually about
30 megabytes[1] ram free (according to "top"), so maybe it is to agressive
in freeing memory.

Greetings,
   Arjan van de Ven

[1] The machine has 96 Mb total ram

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
