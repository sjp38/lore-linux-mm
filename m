Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA26201
	for <linux-mm@kvack.org>; Mon, 6 Jul 1998 13:34:12 -0400
Date: Mon, 6 Jul 1998 15:36:18 +0100
Message-Id: <199807061436.PAA01547@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: cp file /dev/zero <-> cache [was Re: increasing page size]
In-Reply-To: <Pine.LNX.3.96.980706142359.169A-100000@dragon.bogus>
References: <199807061031.LAA00800@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980706142359.169A-100000@dragon.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <arcangeli@mbox.queen.it>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 6 Jul 1998 14:34:02 +0200 (CEST), Andrea Arcangeli
<arcangeli@mbox.queen.it> said:

> On Mon, 6 Jul 1998, Stephen C. Tweedie wrote:
>> or 16MB box doing compilations, then you desperately want unused process
>> data pages --- idle bits of inetd, lpd, sendmail, init, the shell, the

> Now also the process that needs memory got swapped out.

No --- that's the whole point.  We have per-page process page aging
which lets us differentiate between processes which are active and those
which are idle, and between the used and unused pages within the active
processes.

If you are short on memory, then you don't want to keep around any
process pages which belong to idle tasks.  The only way to do that is to
invoke the swapper.  We need to make sure that we are just aggressive
enough to discard pages which are not in use, and not to discard pages
which have been touched recently.

If we simply prune the cache to zero before doing any swapping, then we
will be eliminating potentially useful data out of the cache instead of
throwing away pages to swap which may not have been used in the past
half an hour.  

That's what the balancing issue is about: if there are swap pages which
are not being touched at all and files such as header files which are
being constantly accessed, then we need to do at least _some_ swapping
to eliminate the idle process pages.

> I _really_ don' t want cache and readahead when the system needs
> memory. 

You also don't want lpd sitting around, either.

> The only important thing is to avoid the always swapin/out and provide
> free memory to the process. 

It's just wishful thinking to assume you can do this simply by
destroying the cache.  Oh, and you _do_ want readahead even with little
memory, otherwise you are doing 10 disk IOs to read a file instead of
one; and on a box which is starved of memory, that implies you'll
probably see a disk seek between each IO.  That's just going to thrash
your disk even harder.

> You don' t run in a 32Mbyte box I see ;-).

I run in 64MB,  16MB and 6MB for testing purposes.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
