Date: Tue, 25 Apr 2000 16:27:09 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: 2.3.x mem balancing
In-Reply-To: <Pine.LNX.4.10.10004251140450.847-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0004251619270.10408-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Apr 2000, Linus Torvalds wrote:
> On Tue, 25 Apr 2000, Rik van Riel wrote:
> >
> > There's only one small addition that I'd like to see. Memory
> > should be reclaimed on a more or less _global_ level because
> > the processes in node 0 could use much less memory than the
> > processes in node 1.
> > 
> > Doing strict per-zone memory balancing in this case means that
> > node 0 will have a bunch of idle pages lying around while node
> > 1 is swapping...
> 
> This is why the page allocator has to have some knowledge about
> the whole list of zones it allocates from.
> The current one actually does that:

Certainly, the current allocator is excellent for what we
do now. The only improvement I could see is quantification
of the memory load on zones and having the allocator eg. not
chose a non-local page if the memory load on the other node
is more than 90% of the memory load here.

(Stephen and me have some ideas on this, if I get the code
stable before 2.4 I'll submit it)

> That is obviously not to say that the current code gets the
> heuristics actually =right=. There are certainly bugs in the
> heuristics, as shown by bad performance.

The only bug I can see is that page _freeing_ in the current
code is done on a per-zone basis, so that we could end up with
a whole bunch of underused pages in one zone and too much
memory pressure in the other zone.

The allocation algorithm correctly choses the right zone to
allocate, but it can only do that if the freeing of pages is
done in such a way that those hints are available to the
allocation code. My patch (not completely ready yet) aims to
fix that.

> My argument is really not that the current code is perfect - it very
> obviously is not. But I am 100% convinced that it is much better to have
> independent memory-allocators with some common heuristics than it is to
> try to force a global order on them.

*nod*  Without this we can forget Linux on NUMA...

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
