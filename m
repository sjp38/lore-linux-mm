Date: Sun, 21 May 2000 16:02:45 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
In-Reply-To: <Pine.LNX.4.10.10005211005430.1320-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005211556390.9939-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 21 May 2000, Linus Torvalds wrote:
> On Sun, 21 May 2000, Rik van Riel wrote:
> > 
> > The only change we may want to do is completely drop
> > the priority argument from swap_out since:
> > - if we fail through to swap_out we *must* unmap some pages
> 
> Getting rid of the priority argument to swap_out() would mean
> that swap_out() can no longer make any decisions of its own.
> Suddenly swap_out() is a slave to shrink_mmap(), and is not
> allowed to say "there's a lot of pressure on the VM system right
> now, I can't free anything up at this moment, maybe there could
> be some dirty buffers you could write out instead?".

OK, you're right here.

> > - we really want do_try_to_free_pages to succeed every time
> 
> Well, we do want that, but at the same time we also do want it to
> recognize when it really isn't making any progress. 
> 
> When our priority level turns to "Give me some pages or I'll
> rape your wife and kill your children", and _still_ nobody gives
> us memory, we should just realize that we should give up.

Problem is that the current code seems to give up way
before that. We should be able to free memory from mmap002
no matter what, because we *can* (the backing store for
the data exists).

IMHO it is not acceptable that do_try_to_free_pages() can
fail on the mmap002, but you are completely right that my
quick and dirty idea is wrong.

(I'll steal davem's code and split the current lru queue
in active, inactive and laundry, then the system will
know which page to steal, how to do effective async IO
- don't wait for pages if we have inactive pages left,
but wait for laundry pages instead of stealing active
ones - and when it *has* to call swap_out)

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
