Date: Fri, 12 Jan 2001 16:45:17 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.21.0101122038420.10842-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101121641520.8097-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 12 Jan 2001, Marcelo Tosatti wrote:
> 
> On Fri, 12 Jan 2001, Linus Torvalds wrote:
> 
> > If the page truly is new (because of some other user), then page_launder()
> > won't drop it, and it doesn't matter. But dropping it from the VM means
> > that the list handling can work right, and that the page will be aged (and
> > thrown out) at the same rate as other pages.
> 
> What about the amount of faults this potentially causes? 

It only increases the number of faults on low-memory machines where the VM
has been found to be one cause of mm pressure (otherwise we never get
here: if page_launder() is able to relieve the memory pressure we'll never
even try to swap anything out).

Basically, it increases the number of soft pagefaults (the ones where we
can find the thing in the page cache) only, and only under the one
circumstance when that soft page-fault itself is going to give us more
information about page usage (ie it will help pinpoint the processes with
big memory footprints - and can make us able to slow those down in favour
of the well-behaved applications).

So I consider it to be potentially a win, not a loss. We'll see.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
