Date: Sun, 7 May 2000 14:40:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: [DATAPOINT] pre7-6 will not swap
In-Reply-To: <Pine.LNX.4.10.10005061905180.29159-100000@cesium.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005071418520.8605-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 May 2000, Linus Torvalds wrote:

> My personal inclination is along the lines of
>  - we never really care about any particular zone. We should make sure
>    that all zones get balanced, and that is what running kswapd will
>    eventually cause. 
>  - things like "shrink_mmap" and "vmscan" should both free any page from
>    any zone that is (a) a good candidateand (b) the zone is not yet
>    well-balanced.

double-nod

>  - looking at "shrink_mmap()", my reaction would not be to add more
>    complexity to it, but to remove the _one_ special case that looks at
>    one specific zone:
> 
>         /* wrong zone?  not looped too often?    roll again... */
>         if (page->zone != zone && count)
>                 goto again;
> 
>    I would suggest just removing that test altogether. The page wasn't
>    from a "wrong zone". It was just a different zone that also needed
>    balancing.

The danger in this is that we could "use up" the remaining
ticks on the count variable in do_try_to_free_pages() and
end up with a failed rmqueue for the request...

Oh, and the return value for shrink_mmap() will still
indicate success, even if we failed to free a page for
the zone we intended ... we've already decided for that
before we get into the loop or not.

But I agree that this test is wrong; it makes shrink_mmap()
loop to often compared to swap_out(), leading to worse page
aging in the swap cache and increased cpu use.

The solution could be to let do_try_to_free_page() loop
more often than it does now ... increasing our chances
of freeing from the right zone while at the same time
not increasing the amount of work to be done (we need
to do it anyway, so why not do it now and have that
memory allocation succeed?)

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
