Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA12671
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 14:42:35 -0500
Date: Sat, 19 Dec 1998 11:41:56 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <199812191709.RAA01245@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981219112608.348B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>



Btw, Steven, there's another approach that might actually be the best one,
and that also makes a ton of sense to me. I'm not married to any specific
approach, but basically what I want is that whatever we do it should be
sensible, in a way that we can say "this is the basic approach", and then
when you read the code you see that yes, that's what it does. In other
words, something "pretty". 

If you're testing different approaches, how about this one (_reasoning_
first, not just some magic heuristic): 

 - kswapd and normal processes are decidedly different animals - that's
   fairly obvious. A normal process wants low latency in order to go on
   with what it's doing, while kswapd is meant to be this background
   deamon to make sure we can get memory with low latency.

 - as a result, it doesn't necessarily make sense to have the same
   "do_try_to_free_page()" for them both. For example, for a normal
   process, it makes sense to do a shrink_mmap() more aggressively to just
   try to get rid of some page without actually having to do any IO. In
   contrast, kswapd quite naturally wants to be more aggressive about
   paging things out so that when a regular process does need memory, it
   will get it easily without having to wait for it.

So with the above premise of _not_ trying to make one function work for
both cases, how about:

 - regular processes use something that looks very much like the
   "do_try_to_free_page()" in pre-2. No state crap, and it uses
   shrink_mmap() first (and then it can be reasonably aggressive, so
   forget about increasing "i" to make it timid)

 - kswapd uses something totally different, which essentially looks more
   like the previous loop that used a state to "stay" in a good mode for a
   while. We want kswapd to "stay" in the swap-out mode in order to get
   nice cpntiguous bursty page-outs that we can do efficiently. 

Does the above make sense to you? It would quite naturally explain your
"magic heuristic" in your previous patch with "current != kswapd", but
would be more explainable and cleaner - be quite up front about the fact
that kswapd tries to generate nice page-out patterns, while normal
processes (when they have to call try_to_free_page() at all, which is
hopefully not too often) just want to get memory quickly. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
