Date: Wed, 24 May 2000 19:44:06 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] 2.3/4 VM queues idea
In-Reply-To: <200005242057.NAA77059@apollo.backplane.com>
Message-ID: <Pine.LNX.4.21.0005241937350.24993-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 May 2000, Matthew Dillon wrote:

> :>        Two things can be done:  First, you collect a bunch of pages to be
> :>        laundered before issuing the I/O, allowing you to sort the I/O
> :>        (this is what you suggest in your design ideas email).  (p.p.s.
> :>        don't launder more then 64 or so pages at a time, doing so will just
> :>        stall other processes trying to do normal I/O).
> :> 
> :>        Second, you can locate other pages nearby the ones you've decided to
> :>        launder and launder them as well, getting the most out of the disk
> :>        seeking you have to do anyway.
> :
> :Virtual page scanning should provide us with some of these
> :benefits. Also, we'll allocate the swap entry at unmapping
> :time and can make sure to unmap virtually close pages at
> :the same time so they'll end up close to each other in the
> :inactive queue.
> :
> :This isn't going to be as good as it could be, but it's
> :probably as good as it can get without getting more invasive
> :with our changes to the source tree...
> 
>     Virtual page scanning will help with clustering, but unless you
>     already have a good page candidate to base your virtual scan on
>     you will not be able to *find* a good page candidate to base the
>     clustering around.  Or at least not find one easily.  Virtual
>     page scanning has severe scaleability problems over physical page
>     scanning.  For example, what happens when you have an oracle database
>     running with a hundred independant (non-threaded) processes mapping
>     300MB+ of shared memory?

Ohhh definately. It's just that coding up the administrative changes
required to support this would be too big a change for Linux 2.4...

>     So it can be a toss-up.  I don't think *anyone* (linux, freebsd, solaris,
>     or anyone else) has yet written the definitive swap allocation algorithm!

We still have some time. There's little chance of implementing it in
Linux before kernel version 2.5, so we should have some time left to
design the "definitive" algorithm.

For now I'll be focussing on having something decent in kernel 2.4,
we really need it to be better than 2.2. Keeping the virtual
scanning but combining it with a multi-queue system for the unmapped
pages (with all mapped pages residing in the active queue) should
at least provide us with a predictable, robust and moderately good
VM subsystem for the next stable kernel series.

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
