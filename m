Date: Thu, 4 May 2000 22:30:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: 7-4 VM killing (A solution)
In-Reply-To: <39121A22.BA0BA852@sgi.com>
Message-ID: <Pine.LNX.4.21.0005042227540.28833-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Rajagopal Ananthanarayanan wrote:

> Ok, I may have a solution after having asked, mostly to myself,
> why doesn't shrink_mmap() find pages to free?
> 
> The answer apparenlty is because in 7-4 shrink_mmap(),
> unreferenced pages get filed as "young" if the zone has
> enough pages in it (free_pages > pages_high).
> 
> Because of this bug, if we examine a zone which already
> has enough free pages, all referenced pages now go to
> the "back" of the lru list.
> 
> On a subsequent scan, we may never get to these pages in time.
> Comments?
> 
> Here's the new code to shrink_mmap:
> 
> ------------
> 		[ ... ]
> 		 dispose = &young;
>                 if (test_and_clear_bit(PG_referenced, &page->flags))
>                         goto dispose_continue;
> 
>                 if (!page->buffers && page_count(page) > 1)
>                         goto dispose_continue;
> 
>                 dispose = &old;
>                 if (p_zone->free_pages > p_zone->pages_high)
>                         goto dispose_continue;

I've tried this variant (a few weeks ago, before submitting
the current code to Linus) and have found a serious bug in
it.

If we put all the unreferenced pages from one zone (with
enough free pages) on the front of the queue, a subsequent
run will not make it to the pages of the zone which needs
to have pages freed currently...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
