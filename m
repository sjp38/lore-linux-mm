Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA29884
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 13:21:39 -0500
Date: Thu, 7 Jan 1999 10:19:09 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.96.990107145522.5867B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990107100923.4270L-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 1999, Andrea Arcangeli wrote:
> 
> This first patch allow swap_out to have a more fine grined weight. Should
> help at least in low memory envinronments.

The basic reason I didn't want to do this was that I thought it was wrong
to try to base _any_ decision on any virtual memory sizes. The reason is
simply that I think RSS isn't a very interesting thing to look at.

Yes, the current version also looks at RSS, but if you actually read the
code and think about what it does, it really only uses RSS as an
"ordering"  issue, and it doesn't actually matter for anything else -
we'll walk through all processes until they are all exhausted, and the
only thing that RSS does for us is to start off with the larger one.

Basically, it doesn't matter for anything but startup, because the steady
state will essentially just be a "go through each process in the list over
and over again", and the fact that the list has some ordering is pretty
much inconsequential. 

The real decision on what to throw out is done by the physical page scan,
that takes the PG_referenced bit into account.

So essentially, if we get anything wrong when we do the virtual page table
walk, the only thing that results in is that we might handle a few extra
page faults (not no extra IO, because the page faults will be satisfied
from the victim caches - the page cache and the swap cache). 

The only case this isn't true is the case where we have a shared file
mapping. That's where the PG_dirty issues come in - we've never done that
well from a performance standpoint, and pre-5 does not change that fact,
it just lays some foundations for doing it right in the future. 

So that's why I'd prefer to not complicate the VM counting any more. I
don't think it should make any fundamental difference (it might make a
difference in various extreme cases, but not, I think, under any kind of
realistic load).

But who knows, I've been wrong before. But now at least you know why I
didn't want it in the default kernel. 

> This other patch instead change a bit the trashing memory heuristic and
> how many pages are freed every time. I am not sure it's the best thing to
> do. So if you'll try it let me know the results... 

I think this might well be tuned some, although I think your patch is
extreme. I'd love to hear comments from people who test it under different
loads and different memory sizes.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
