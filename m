Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA32222
	for <linux-mm@kvack.org>; Mon, 11 Jan 1999 12:59:10 -0500
Date: Mon, 11 Jan 1999 09:55:59 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <19990111171138.A9675@castle.nmd.msu.ru>
Message-ID: <Pine.LNX.3.95.990111095116.4886B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Savochkin Andrey Vladimirovich <saw@msu.ru>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Mon, 11 Jan 1999, Savochkin Andrey Vladimirovich wrote:
> On Sun, Jan 10, 1999 at 10:35:10AM -0800, Linus Torvalds wrote:
> > The thing I want to make re-entrant is just semaphore accesses: at the
> > point where we would otherwise deadlock on the writer semaphore it's much
> > better to just allow nested writes. I suspect all filesystems can already
> > handle nested writes - they are a lot easier to handle than truly
> > concurrent ones.
> 
> You're an optimist, aren't you? :-)

No, drugged to my eye-brows.

> In any case I've checked your recursive semaphore code on a news server
> which reliably deadlocked with the previous kernels.
> The code seems to work well.

I found a rather nasty race in my implementation - it's basically
impossible to triggerin real life, but quite frankly I don't want to have
semaphores that have a really subtle bug in them. 

However much I tried, I couldn't make the race go away without using a
spinlock in the critical path of the semaphore, something which I very
much want to avoid.

Unless I find a good recursive semaphore implementation (and I'm starting
to despair about finding one that is lock-free for the non-contention
case), I'll have to come up with something else (like letting only kswapd
swap out pages as has been discussed here).

			Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
