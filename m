Date: Mon, 1 May 2000 20:23:43 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
In-Reply-To: <390E1534.B33FF871@norran.net>
Message-ID: <Pine.LNX.4.21.0005012017300.7508-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005012017302.7508@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 May 2000, Roger Larsson wrote:

> I think there are some problems in the current (pre7-1) shrink_mmap.
> 
> 1) "Random" resorting for zone with free_pages > pages_high
>   while loop searches from the end of the list.
>   old pages on non memory pressure zones are disposed as 'young'.
>   Young pages are put in front, like recently touched ones.
>   This results in a random resort for these pages.

Not doing this would result in having to scan the same "wrong zone"
pages over and over again, possibly never reaching the pages we do
want to free.

> 2) The implemented algorithm results in a lot of list operations -
>    each scanned page is deleted from the list.

*nod*

Maybe it's better to scan the list and leave it unchanged, doing
second chance replacement on it like we do in 2.2 ... or even 2
or 3 bit aging?

That way we only have to scan and do none of the expensive list
operations. Sorting doesn't make much sense anyway since we put
most pages on the list in an essentially random order...

> 3) The list is supposed to be small - it is not...

Who says the list is supposed to be small?

> 4) Count is only decreased for suitable pages, but is related
>    to total pages.

Not doing this resulted in being unable to free the "right" pages,
even if they are there on the list (just beyond where we stopped
scanning) and killing a process with out of memory errors.

> 5) Returns on first fully successful page. Rescan from beginning
>    at next call to get another one... (not that bad since pages
>    are moved to the end)

Well, it *is* bad since we'll end up scanning all the pages in
&old; (and trying to free them again, which probably fails just
like it did last time). The more I think about it, the more I think
we want to go to a second chance algorithm where we don't change
the list (except to remove pages from the list).

We can simply "move" the list_head when we're done scanning and
continue from where we left off last time. That way we'll be much
less cpu intensive and scan all pages fairly.

Using not one but 2 or 3 bits for aging the pages can result in 
something closer to lru and cheaper than the scheme we have now.

What do you (and others) think about this idea?

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
