Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA00462
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 04:45:22 -0500
Subject: Re: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
References: <Pine.LNX.3.95.990117210123.28579G-100000@penguin.transmeta.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 18 Jan 1999 01:28:38 -0600
In-Reply-To: Linus Torvalds's message of "Sun, 17 Jan 1999 21:11:45 -0800 (PST)"
Message-ID: <m1n23hdopl.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, Kalle Andersson <kalle@sslug.dk>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Max <max@Linuz.sns.it>
List-ID: <linux-mm.kvack.org>

>>>>> "LT" == Linus Torvalds <torvalds@transmeta.com> writes:


LT> Note that what I really wanted to use PG_dirty for was not for normal
LT> page-outs, but for shared mappings of files. 

LT> For normal page-out activity, the PG_dirty thing isn't a win, simply
LT> because (a) it doesn't actually buy us anything (we might as well do it 
LT> from the page tables directly) 

If we combine it with early scanning of the page tables,  it should allow us
to perform I/O before we need the memory.  While not bogging down processes.

LT> and (b) as you noticed, it increases fragmentation.

This is only because he didn't implement any kind of request queue.
A fifo queue of pages to write would have keep performance up at current levels.

LT> The reason PG_dirty should be a win for shared mappings is: (a) it gets
LT> rid of the file write semaphore problem in a very clean way and 

Nope.  Because we can still have some try to write to file X.
That write needs memory, and we try to swapout a mapping of file X.
Unless you believe it implies the write outs then must use a seperate process.

LT> (b) it
LT> reduces the number of IO requests for mappings that are writable for
LT> multiple contexts (right now we will actually do multiple page-outs, one
LT> for each shared mapping that has dirtied the page). 

With a reasonable proximity in time even that isn't necessary because of the buffer
cache.  This is only a real issue for filesystems that don't implement good
write cachine on their own.  In which case the primary thing to fix is
caching for those filesystems.  We can use PG_dirty for that case too, but
the emphasis is different.

LT> I looked at the problem, and PG_dirty for shared mappings should be
LT> reasonably simple. However, I don't think I can do it for 2.2 simply
LT> because it involves some VFS interface changes (it requires that you can
LT> use the pame_map[] information and nothing else to page out: we have the
LT> inode and the offset which actually is enough data to do it, but we don't
LT> have a good enough "inode->i_op->writepage()" setup yet).

At least in part because for NFS you need who is doing the write, which
we currently store with a struct file.  To get it correct we really
need a two level setup.  Level 1 per pte to enter in the write request.
Level 2 per page to acutally write it out.

If there are conflicts, (not the same user, etc) Level 1 can handle them.

If I have any luck I should have a draft of a complete set of changes to do
all of this for 2.3 in about a month.  I have been working on this in the
backgroud for quite a while.

Eric




--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
