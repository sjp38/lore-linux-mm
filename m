Date: Wed, 10 May 2000 17:32:02 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <Pine.LNX.4.10.10005101708590.1489-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.10005101720050.1580-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>, "Juan J. Quintela" <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Some more explanations on the differences between pre7-8 and pre7-9..

Basically pre7-9 survives mmap002 quite gracefully, and I think it does so
for all the right reasons. It's not tuned for that load at all, it's just
that mmap002 was really good at showing two weak points of the mm layer:

 - try_to_free_pages() could actually return success without freeing a
   single page (just moving pages around to the swap cache). This was bad,
   because it could cause us to get into a situation where we
   "successfully" free'd pages without ever adding any to the list. Which
   would, for all the obvious reasons, cause problems later when we
   couldn't allocate a page after all..

 - The "sync_page_buffers()" thing to sync pages directly to disk rather
   than wait for bdflush to do it for us (and have people run out of
   memory before bdflush got around to the right pages).

   Sadly, as it was set up, try_to_free_buffers() doesn't even get the
   "urgency" flag, so right now it doesn't know whether it should wait for
   previous write-outs or not. So it always does, even though for
   non-critical allocations it should just ignore locked buffers.

Fixing these things suddenly made mmap002 behave quite well. I'll make the
change to pass in the priority to sync_page_buffers() so that I'll get the
increased performance from not waiting when I don't have to, but it starts
to look like pre7 is getting in shape.

		Linus

On Wed, 10 May 2000, Linus Torvalds wrote:
> 
> Ok, there's a pre7-9 out there, and the biggest change versus pre7-8 is
> actually how block fs dirty data is flushed out. Instead of just waking up
> kflushd and hoping for the best, we actually just write it out (and even
> wait on it, if absolutely required).
> 
> Which makes the whole process much more streamlined, and makes the numbers
> more repeatable. It also fixes the problem with dirty buffer cache data
> much more efficiently than the kflushd approach, and mmap002 is not a
> problem any more. At least for me.
> 
> [ I noticed that mmap002 finishes a whole lot faster if I never actually
>   wait for the writes to complete, but that had some nasty behaviour under
>   low memory circumstances, so it's not what pre7-9 actually does. I
>   _suspect_ that I should start actually waiting for pages only when
>   priority reaches 0 - comments welcomed, see fs/buffer.c and the
>   sync_page_buffers() function ]
> 
> kswapd is still quite aggressive, and will show higher CPU time than
> before. This is a tweaking issue - I suspect it is too aggressive right
> now, but it needs more testing and feedback. 
> 
> Just the dirty buffer handling made quite an enormous difference, so
> please do test this if you hated earlier pre7 kernels.
> 
> 		Linus
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
