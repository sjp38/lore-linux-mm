Received: from mail.ccr.net (ccr@alogconduit1af.ccr.net [208.130.159.6])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA27920
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 01:42:41 -0500
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <199901101659.QAA00922@dax.scot.redhat.com> 	<Pine.LNX.3.95.990110103201.7668D-100000@penguin.transmeta.com> <199901102249.WAA01684@dax.scot.redhat.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 11 Jan 1999 00:04:11 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Sun, 10 Jan 1999 22:49:47 GMT"
Message-ID: <m1aezq4a78.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@redhat.com> writes:

ST> Hi,
ST> On Sun, 10 Jan 1999 10:35:10 -0800 (PST), Linus Torvalds
ST> <torvalds@transmeta.com> said:

>> On Sun, 10 Jan 1999, Stephen C. Tweedie wrote:
>>> 
>>> Ack.  I've been having a closer look, and making the superblock lock
>>> recursive doesn't work

>> That's fine - the superblock lock doesn't need to be re-entrant, because
>> __GFP_IO is quite sufficient for that one.

ST> I'm no longer convinced about that.  I think it's much much worse.  A
ST> bread() on an ext2 bitmap buffer with the superblock held is only safe
ST> if the IO can complete without _ever_ relying on a GFP_IO allocation.
ST> That means that any interrupt allocations required in that space have to
ST> be satisfiable by kswapd without GFP_IO, or kswapd could deadlock
ST> on us.

Well interrupts use GFP_ATOMIC . . . 

ST> It means that if our superblock-locked IO has to stall waiting for an
ST> nbd server process or a raid daemon, then those daemons cannot safely do
ST> GFP_IO.  It's really gross.

Right.  And the flag not to do I/O doesn't propogate across processes.
This sounds like a variation of the priority inheritance problem.

I wonder if this is why there are some known deadlocks with raid?

ST> I think it's actually ugly enough that we cannot make it safe: we can
ST> really only be sure if we prevent all GFP_IO from any process which
ST> might be involved in our deadlock loop, or if we avoid doing any IO with
ST> the superblock lock held.  

ST> In fact, to make it really safe we'd need to avoid synchronous swapout
ST> altogether: otherwise we can have

ST> Can we get away without synchronous swapout?  Notice that in this case,
ST> kswiod may be blocked but kswapd itself will not be.  As long as the nbd
ST> server does not try to do a synchronous swap, it won't deadlock on
ST> kswiod.  In other words, it is safe to wait for avaibility of another
ST> free page, but it is not safe to wait for completion of any single,
ST> specific swap IO.  If kswapd itself no longer performs the IO, then we
ST> can always free more memory, until we get to the complete death stage
ST> where there are absolutely no clean pages left in the system.

ST> If we do this, then both the inode and the superblock deadlocks
ST> disappear.

Sounds good.

I have a daemon just about ready to go, hopefully I can post it
tommorrow for preliminary testing.  It looks like my work for 2.3
in a small part can help deadlocks after all.

It walks the page tables and just writes out dirty pages, and marks
them clean but it doesn't remove them from processes.  So it can get
an early jump on writing things out.

Then if we are hitting a low memory situation (because pages become
dirty quickly), we can just wake it up, more often.

Currently we are doing totally asynchonous swapping but from the
context of the process that needs memory, (so the locks are in
different processes).  Adding a second daemon will play havoc on our
balancing but it shouldn't affect anything else. 

Grr.  I forgot about sysv shm.  It is the only thing doing synchronous
swapping right now.  

Oh, and just as a side note we are currently unfairly penalizing
threaded programs by doing for_each_task instead of for_each_mm in the
swapout code...

Eric
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
