Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA24632
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 17:50:06 -0500
Date: Sun, 10 Jan 1999 22:49:47 GMT
Message-Id: <199901102249.WAA01684@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>
References: <199901101659.QAA00922@dax.scot.redhat.com>
	<Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 10 Jan 1999 10:35:10 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> On Sun, 10 Jan 1999, Stephen C. Tweedie wrote:
>> 
>> Ack.  I've been having a closer look, and making the superblock lock
>> recursive doesn't work

> That's fine - the superblock lock doesn't need to be re-entrant, because
> __GFP_IO is quite sufficient for that one.

I'm no longer convinced about that.  I think it's much much worse.  A
bread() on an ext2 bitmap buffer with the superblock held is only safe
if the IO can complete without _ever_ relying on a GFP_IO allocation.
That means that any interrupt allocations required in that space have to
be satisfiable by kswapd without GFP_IO, or kswapd could deadlock on us.
It means that if our superblock-locked IO has to stall waiting for an
nbd server process or a raid daemon, then those daemons cannot safely do
GFP_IO.  It's really gross.

I think it's actually ugly enough that we cannot make it safe: we can
really only be sure if we prevent all GFP_IO from any process which
might be involved in our deadlock loop, or if we avoid doing any IO with
the superblock lock held.  

It really looks as if the right way around this is to prevent GFP_IO
from deadlocking in the first place, by moving the asynchronous page
writes out of kswapd/try_to_free_page and into a separate worker thread.
That way we can continue to try to reclaim memory somewhere else without
deadlocking.  In that case the only thing we are left having to worry
about is doing a synchronous swapout, where we end up blocking waiting
for the IO thread to complete.  

In fact, to make it really safe we'd need to avoid synchronous swapout
altogether: otherwise we can have

	    A			kswiod		nbd server process
	    lock_super();
	    bread(ndb device);
	    try_to_free_page();
	    rw_swap_page_async();
				filemap_write_page();
				lock_super();
	    wait_on_buffer();
						try_to_free_page();
						rw_swap_page_sync();
						Oops, kswiod is stalled.

Can we get away without synchronous swapout?  Notice that in this case,
kswiod may be blocked but kswapd itself will not be.  As long as the nbd
server does not try to do a synchronous swap, it won't deadlock on
kswiod.  In other words, it is safe to wait for avaibility of another
free page, but it is not safe to wait for completion of any single,
specific swap IO.  If kswapd itself no longer performs the IO, then we
can always free more memory, until we get to the complete death stage
where there are absolutely no clean pages left in the system.

If we do this, then both the inode and the superblock deadlocks
disappear.

--Stephen.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
