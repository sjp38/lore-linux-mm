Date: Thu, 4 Jul 2002 22:51:16 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: vm lock contention reduction
In-Reply-To: <3D2530B9.8BC0C0AE@zip.com.au>
Message-ID: <Pine.LNX.4.44.0207042237130.7465-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Thu, 4 Jul 2002, Andrew Morton wrote:
> >
> > Get away from this "minimum wait" thing, because it is WRONG.
>
> Well yes, we do want to batch work up.  And a crude way of doing that
> is "each time 64 pages have come clean, wake up one waiter".

That would probably work, but we also need to be careful that we don't get
into some strange situations (ie we have 50 waiters that all needed memory
at the same time, and less than 50*64 pages that caused us to be in
trouble, so we only wake up the 46 first waiters and the last 4 waiters
get stuck until the next batch even though we now have _lots_ of pages
free).

Dont't laugh - things like this has actually happened at times with some
of our balancing work with HIGHMEM/NORMAL. Basically, the logic would go:
"everybody who ends up having to wait for an allocation should free at
least N pages", but then you would end up with 50*N pages total that the
system thought it "needed" to free up, and that could be a big number that
would cause the VM to want to free up stuff long after it was really done.

> Or
> "as soon as the number of reclaimable pages exceeds zone->pages_min".
> Some logic would also be needed to prevent new page allocators from
> jumping the queue, of course.

Yeah, the unfairness is the thing that really can be nasty.

On the other hand, some unfairness is ok too - and can improve throughput.
So jumping the queue is fine, you just must not be able to _consistently_
jump the queue.

(In fact, jumping the queue is inevitable to some degree - not allowing
any queue jumping at all would imply that any time _anybody_ starts
waiting, every single allocation afterwards will have to wait until the
waiter got woken up. Which we have actually tried before at times, but
which causes really really bad behaviour and horribly bad "pausing")

You probably want the occasional allocator able to jump the queue, but the
"big spenders" to be caught eventually. "Fairness" really doesn't mean
that "everybody should wait equally much", it really means "people should
wait roughly relative to how much as they 'spend' memory".

If a process is frugal with it's memory footprint, and doesn't dirty a lot
of pages/buffers, such a process should obviously wait less than one that
allocates/dirties a lot.

Right now, we get roughly this behaviour simply by way of statistical
behaviour for the page allocator ("if somebody allocates 5 times as many
pages, he's 5 times as likely to have to clean something up too"), but
trying to be smarter about this could easily break this relative fairness.

In particular, statefulness like "cannot jump the queue" breaks it.

> > some fuzzy feeling about "we shouldn't wait unless we have to". We _do_
> > have to wait.
>
> Sure, page allocators must throttle their allocation rate to that at
> which the IO system can retire writes.  But by waiting on a randomly-chosen
> disk block, we're at the mercy of the elevator.

Yes. On the other hand, "random" is actually usually a fairly good choice
in itself. And it a lot easier that many of the alternatives - especially
when it comes to fairness.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
