Message-ID: <390EFF9C.44C7CCE5@norran.net>
Date: Tue, 02 May 2000 18:17:32 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
References: <Pine.LNX.4.21.0005012017300.7508-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have been playing with the idea to have a lru for each zone.
It should be trivial to do since page contains a pointer to zone.

With this change you will shrink_mmap only check among relevant pages.
(the caller will need to call shrink_mmap for other zone if call failed)

With this change you probably do not need to move pages to young. And
can get around without modifying the list.

I think keeping active/inactive (= generational) lists are also an
interesting proposal. But since it is orthogonal both methods can be
used!

/RogerL


Rik van Riel wrote:
> 
> On Tue, 2 May 2000, Roger Larsson wrote:
> 
> > I think there are some problems in the current (pre7-1) shrink_mmap.
> >
> > 1) "Random" resorting for zone with free_pages > pages_high
> >   while loop searches from the end of the list.
> >   old pages on non memory pressure zones are disposed as 'young'.
> >   Young pages are put in front, like recently touched ones.
> >   This results in a random resort for these pages.
> 
> Not doing this would result in having to scan the same "wrong zone"
> pages over and over again, possibly never reaching the pages we do
> want to free.
> 
> > 2) The implemented algorithm results in a lot of list operations -
> >    each scanned page is deleted from the list.
> 
> *nod*
> 
> Maybe it's better to scan the list and leave it unchanged, doing
> second chance replacement on it like we do in 2.2 ... or even 2
> or 3 bit aging?
> 
> That way we only have to scan and do none of the expensive list
> operations. Sorting doesn't make much sense anyway since we put
> most pages on the list in an essentially random order...
> 
> > 3) The list is supposed to be small - it is not...
> 
> Who says the list is supposed to be small?
> 
> > 4) Count is only decreased for suitable pages, but is related
> >    to total pages.
> 
> Not doing this resulted in being unable to free the "right" pages,
> even if they are there on the list (just beyond where we stopped
> scanning) and killing a process with out of memory errors.
> 
> > 5) Returns on first fully successful page. Rescan from beginning
> >    at next call to get another one... (not that bad since pages
> >    are moved to the end)
> 
> Well, it *is* bad since we'll end up scanning all the pages in
> &old; (and trying to free them again, which probably fails just
> like it did last time). The more I think about it, the more I think
> we want to go to a second chance algorithm where we don't change
> the list (except to remove pages from the list).
> 
> We can simply "move" the list_head when we're done scanning and
> continue from where we left off last time. That way we'll be much
> less cpu intensive and scan all pages fairly.
> 
> Using not one but 2 or 3 bits for aging the pages can result in
> something closer to lru and cheaper than the scheme we have now.
> 
> What do you (and others) think about this idea?
> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/               http://www.surriel.com/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
