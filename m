Date: Wed, 27 Sep 2000 19:42:00 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000927194200.A15943@athlon.random>
References: <20000925190657.N2615@redhat.com> <20000925213242.A30832@athlon.random> <20000925205457.Y2615@redhat.com> <qwwd7hriqxs.fsf@sap.com> <20000926160554.B13832@athlon.random> <qww7l7z86qo.fsf@sap.com> <20000926191027.A16692@athlon.random> <qwwn1gu6yps.fsf@sap.com> <20000927155608.D27898@athlon.random> <qwwsnql6aet.fsf@sap.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <qwwsnql6aet.fsf@sap.com>; from cr@sap.com on Wed, Sep 27, 2000 at 06:56:42PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 27, 2000 at 06:56:42PM +0200, Christoph Rohland wrote:
> Yes, but how does the application detect that it should free the mem?

The trivial way is not to detect it and to allow the user to select how much
memory it will use as cache and to take it locked and then don't care (he will
have to decrease the size of the shm by hand if it wants to drop some cache).
>From the OS point of view it's like not having that RAM at all and there will
be zero performance difference compared into trashing into swap without such
memory. (on 2.2.x this is not true for a complexity problem in shrink mmap that
is solved with the real lru in 2.4.x)

The other way is to have the shm cache that shrinks dynamically by looking
/proc/meminfo and looking at the aging of their own cache. Again the user
should say a miniumum and a maximum of shm cache to keep locked in memory. Then
you look at the "freemem + cache + buffers - active cache" and you can say when
you're going to run into swap. Specifically with classzone you'll run into swap
when that value is near zero. So when such value is near zero you know it's
time to shrink the shm cache dynamically if it has a low age otherwise the
machine will trash into swap badly and performance will decrease. (you could
start shrinking when such value is below an amount of mbyte again configurable
via a form)

You should of course poll the /proc/meminfo. (/proc/meminfo works in O(1) in
2.4.x so it's just the overhead of a read syscall)

These DB using rawio really want to substitue part of the kernel cache
functionality and so it's quite natural that they also don't want the kernel to
play with their caches while they run and they would need some more interaction
with the kernel memory balancing (possibly via async signals) to get their shm
reclaimed dynamically more cleanly and efficiently by registering for this
functionality (they could get signals when the machine runs into swap and then
the DB chooses if it worth to release some locked cache after looking at the
/proc/meminfo and the working set on their own caches).

> Also you often have more overhead reading out of a database then
> having preprocessed data in swap. 

Yes I see, it of course depends on the kind of cache (if it's very near to the
on-disk format than more probably it shouldn't be swapped out).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
