Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA13524
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 13:03:14 -0500
Date: Sat, 9 Jan 1999 10:00:27 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990109124304.C26523@castle.nmd.msu.ru>
Message-ID: <Pine.LNX.3.95.990109095521.2572A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Savochkin Andrey Vladimirovich <saw@msu.ru>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Sat, 9 Jan 1999, Savochkin Andrey Vladimirovich wrote:
> 
> I've found an another deadlock.

Yes. This is a case I knew about, and that Alan already mentioned. Trying
to write from a shared mapping has a path that can take the write
semaphore twice.

This one is a whole lot harder to fix - the previous one needed only a
simple extra flag, this one is truly nasty.

The cleanest solution I can think of is actually to allow semaphores to be
recursive. I can do that with minimal overhead (just one extra instruction
in the non-contention case), so it's not too bad, and I've wanted to do it
for certain other things, but it's still a nasty piece of code to mess
around with. 

Oh, well. I don't think I have much choice. Making the swap-out routines
refuse to touch an inode that is busy is a sure way to allow people to
let bad users lock down infinite amounts of memory.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
