Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA20638
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 12:00:32 -0500
Date: Sun, 10 Jan 1999 16:59:43 GMT
Message-Id: <199901101659.QAA00922@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <Pine.LNX.3.95.990109134233.3478A-100000@penguin.transmeta.com>
References: <Pine.LNX.3.95.990109095521.2572A-100000@penguin.transmeta.com>
	<Pine.LNX.3.95.990109134233.3478A-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Savochkin Andrey Vladimirovich <saw@msu.ru>, Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 9 Jan 1999 13:50:14 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> On Sat, 9 Jan 1999, Linus Torvalds wrote:
>> 
>> The cleanest solution I can think of is actually to allow semaphores to be
>> recursive. I can do that with minimal overhead (just one extra instruction
>> in the non-contention case), so it's not too bad, and I've wanted to do it
>> for certain other things, but it's still a nasty piece of code to mess
>> around with. 

Ack.  I've been having a closer look, and making the superblock lock
recursive doesn't work: the ext2fs allocation code is definitely not
reentrant.  In particular, the bitmap buffers can get evicted out from
under our feet if we reenter the block allocation code, leading to nasty
filesystem and/or memory corruption.  The allocation code can also get
confused if the bitmap contents change between checking the group
descriptor for a block group and reading in the bitmap itself, leading
to potential ENOSPC errors turning up wrongly.

Preventing recursive VM access to the filesystem while we have the
superblock lock seems the only easy way out short of making the
allocation/truncate code fully reentrant.

On the other hand, it does look as if the inode deadlock is dealt with
OK if we just make that semaphore recursive; I can't see anywhere that
dies if we make that change.  This does somewhat imply that we may need
to make a distinction between reentrant and non-reentrant semaphores if
we go down this route.

--Stephen.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
