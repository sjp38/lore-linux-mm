Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA07476
	for <linux-mm@kvack.org>; Thu, 2 Apr 1998 14:23:24 -0500
Date: Wed, 1 Apr 1998 21:28:49 +0100
Message-Id: <199804012028.VAA04493@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: new allocation algorithm
In-Reply-To: <Pine.LNX.3.95.980327092811.6613C-100000@penguin.transmeta.com>
References: <Pine.LNX.3.91.980327095733.3532A-100000@mirkwood.dummy.home>
	<Pine.LNX.3.95.980327092811.6613C-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <H.H.vanRiel@fys.ruu.nl>, "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 27 Mar 1998 09:30:40 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> The current scheme is fairly efficient and extremely stable, and gives
> good behaviour for the cases we _really_ care about (pageorders 0, 1 and
> to some degree 2). It comes reasonably close to working for the higher
> orders too, but they really aren't as critical..

Sorry to put a spanner in the works at this stage, but there's
something we haven't really considered yet in the page balancing.  The
aim I'm currently working towards is to eliminate free memory as much
as possible, by replacing "free" space with reserved, lazy-reclaimed
cache memory.  We ought to be able to maintain 5-10% memory in this
form with much less performance impact than we would have if that
memory was truly free, but the downside is that this nearly-free
memory is not on our free page lists and therefore we have no simple
way of assessing the fragmentation of the lazy-reclaimable pages.

Now, this is both a blessing and a curse.  The positive side is that
we can do what to some extent happens today, and keep as much memory
as possible on the lazy list in the blind hope that we will be able to
find free higher order pages when we need them by returning lazy pages
to the free list one by one.  The drawback is that we don't have an
easy way of suspending kswapd when we get enough free higher order
pages.

This is just an observation --- we cannot tune this stuff until it is
stable enough to integrate, but the impact on our free space
heuristics may be worth thinking about now.

--Stephen
