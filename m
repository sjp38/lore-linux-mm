Date: Sun, 21 May 2000 10:15:42 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
In-Reply-To: <Pine.LNX.4.21.0005211254240.9205-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005211005430.1320-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Sun, 21 May 2000, Rik van Riel wrote:
> 
> The only change we may want to do is completely drop
> the priority argument from swap_out since:
> - if we fail through to swap_out we *must* unmap some pages

I don't agree.

It's a balancing act. We go from door to door, and we say "can you spare a
dime?" The fact that shrink_mmap() said "I don't have anything for you
right now" doesn't mean that swap_out() _has_ to give us memory. If nobody
gives us anything the first time through, we should just try again. A bit
more forcefully this time.

> - swap_out isn't balanced against anything else, so failing
>   it doesn't make much sense (IMHO)

This is not how I see the balancing act at all.

Think of the priority as something everybody we ask uses to judge how
badly he wants to release memory. NOBODY balances against "somebody else".
Everybody balances its own heap of memory, and there is no "global"
balance. Think of it as the same thing as "per-zone" and "class-aware"
logic all over again.

A global balance would take the other allocators into account, and say "I
only have X pages, and they have Y pages, so _they_ should pay". A global
balancing algorithm is based on envy of each others pages.

The local balance is more a "Oh, since he asks me with priority 10, I'll
just see if I can quickly look through 1% of my oldest pages, and if I
find something that I'm comfortable giving you, I'll make it available".
It doesn't take other memory users into account - it is purely selfless,
and knows that somebody asks for help.

Getting rid of the priority argument to swap_out() would mean that
swap_out() can no longer make any decisions of its own. Suddenly
swap_out() is a slave to shrink_mmap(), and is not allowed to say "there's
a lot of pressure on the VM system right now, I can't free anything up at
this moment, maybe there could be some dirty buffers you could write out
instead?".

> - we really want do_try_to_free_pages to succeed every time

Well, we do want that, but at the same time we also do want it to
recognize when it really isn't making any progress. 

When our priority level turns to "Give me some pages or I'll rape your
wife and kill your children", and _still_ nobody gives us memory, we
should just realize that we should give up.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
