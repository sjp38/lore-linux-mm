Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA29207
	for <linux-mm@kvack.org>; Wed, 25 Feb 1998 17:48:58 -0500
Date: Wed, 25 Feb 1998 14:48:15 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: your mail
In-Reply-To: <Pine.LNX.3.91.980225230741.1545A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980225144057.8068C-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Wed, 25 Feb 1998, Rik van Riel wrote:
> 
> I've just come up with a very simple idea to limit
> thrashing, and I'm asking you if you want it implemented
> (there's some cost involved :-( ).
> 
> We could simply prohibit the VM subsystem from swapping
> out pages which have been allocated less than one second
> ago, this way the movement of pages becomes 'slower', and
> thrashing might get somewhat less.

I'm _really_ nervous about "rate-based" limiting. Personally I think that
it only makes sense for things like networking, and even there it had
better be done by hardware. 

The reason I dislike rate-based things is that it is _so_ hard to give any
kind of guarantees at all on the sanity of the thing. You can tweak the
rates, but they don't have any logic to them, and most importantly they
are very hard to make self-tweaking. 

I tend to prefer a "balancing" approach to these problems: the important
part about balancing is that while it may not have some specific
well-defined behaviour that you can point your finger to ("will not page
out the same page that it paged in within 5 seconds"), the basic approach
is to write something that doesn't have any hard rules but that TENDS
towards some certain goal. 

That way you get algorithms that you can be fairly confident work well in
the normal cases (because you test those normal cases), and because there
are no hard rules you also don't get strange "edges" when something
unexpected happens: performance may well degrade badly, but it degrades
_softly_ rather than in quantisized jumps.

			Linus
