Received: from penguin.e-mind.com ([195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA27164
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 15:30:16 -0400
Date: Mon, 6 Jul 1998 21:28:42 +0200 (CEST)
From: Andrea Arcangeli <arcangeli@mbox.queen.it>
Reply-To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <199807061436.PAA01547@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.96.980706203947.369E-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Jul 1998, Stephen C. Tweedie wrote:

>No --- that's the whole point.  We have per-page process page aging
>which lets us differentiate between processes which are active and those
>which are idle, and between the used and unused pages within the active
>processes.

Nice! The problem is that probably the kernel think that bash and every
not 100% CPU eater is an idle process... 

>If you are short on memory, then you don't want to keep around any
>process pages which belong to idle tasks.  The only way to do that is to

This is again more true for low memory machines (where the current kswapd
policy sucks). I 100% agree with this, I don' t agree to swapout to make
space from the cache. The cache is too much dynamic and so the swapin/out
continue forever.

>invoke the swapper.  We need to make sure that we are just aggressive
>enough to discard pages which are not in use, and not to discard pages
>which have been touched recently.

I think that we are too much aggressive. Also my bash gone swapped out. If
I run `cp file /dev/null' on 2.0.34, when I launch `free' from the shall I
don' t see stalls. It seems that `free' remains in the cache, while on
2.1.108 I had to wait a lot of seconds to see `free' executed (and
characters printed to the console).

>If we simply prune the cache to zero before doing any swapping, then we
>will be eliminating potentially useful data out of the cache instead of
>throwing away pages to swap which may not have been used in the past
>half an hour.

It would be nice if it would be swapped out _only_ pages that are not used
in the past half an hour. If kswapd would run in such way I would thank
you a lot instead of being irritate ;-).

>That's what the balancing issue is about: if there are swap pages which
>are not being touched at all and files such as header files which are
>being constantly accessed, then we need to do at least _some_ swapping
>to eliminate the idle process pages.

100% agree.

>> I _really_ don' t want cache and readahead when the system needs
>> memory. 
>
>You also don't want lpd sitting around, either.

NO. I want lpd sitting around if it' s been used in the last 10 minutes
for example. I don' t want to swapout process for make space for the
_cache_ if the process is not 100% idle instead.

>> The only important thing is to avoid the always swapin/out and provide
>> free memory to the process. 
>
>It's just wishful thinking to assume you can do this simply by
>destroying the cache.  Oh, and you _do_ want readahead even with little

Yes we can avoid it destroying the cache I think, since it' s the only
cause I can touch by hand that cause me problems when nothing of huge is
running (when I have 20Mbyte of "not used by me" memory).  2.0.34 destroy
(wooo nice I love when I see the cache destroyed ;-)  completly the cache
and runs great. I have a friend that take 2.0.34 on its 8Mbyte laptop only
to compile the kernel in 30Minutes instead of in the N hours of 2.0.10x.

>memory, otherwise you are doing 10 disk IOs to read a file instead of
>one; and on a box which is starved of memory, that implies you'll
>probably see a disk seek between each IO.  That's just going to thrash
>your disk even harder. 

I really don' t bother about read-ahead. When the system swap the hd is so
busy that there are really no difference to go at speed of 1Km/h or 0.1Km/h ;-).
Readahead in that case is the same of run an optimized O(2^n) algorithm
(against running a not optimized one (no-readahead)).

>> You don' t run in a 32Mbyte box I see ;-).
>
>I run in 64MB,  16MB and 6MB for testing purposes.

Maybe your test are a bit light ;-). Also maybe you are not running on a
single IDE0 (UDMA) HD with the swap partition on the same HD as me. 

Please avoid the swap every time you can. Swap is the end of the life of
every machine. Trash the cache instead.

Which functions I had to touch and use to destroy the cache instead of
swapping out processes? I don' t ask a so nice feature of page aging you
are claiming about, I only need to avoid the swap to run _fast_ (as does 
2.0.34).

BTW, I started this thread these days only because I booted 2.0.34 and I
noticed the big improvement.

Andrea[s] Arcangeli

PS. Thanks anyway to all mm guys that that contributed to 2.1.x
    since I _guess_ that kswapd and the mm layer in general is OK for high
    memory machines. __Maybe__ we only need some tuning for low memory
    machines.

    BTW, how many people tune the vm layer using the sysctls?

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
