Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA12389
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 13:42:44 -0500
Date: Sat, 19 Dec 1998 10:41:51 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <199812191709.RAA01245@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981219102446.15343F-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>



On Sat, 19 Dec 1998, Stephen C. Tweedie wrote:
> 
> Linus, I've had a test with your 132-pre2 patch, and the performance is
> really disappointing in some important cases.  Particular effects I can
> reproduce with it include:

Try a really trivial change, which is to start the page_out priority from
8 instead of 6 (maybe 7 is the right balance, but let's try 8 first. 

The problem, I suspect, is simply that the new code obviously _always_
calls "shrink_mmap()", and with a priority of 6 shrink_mmap() is a bit too
good at throwing out page cache pages etc, so we tend to wait a bit too
long before we actually start to swap out user pages instead. 

Previously we didn't have that problem, because once we got over
shrink_mmap() due to any problem what-so-ever, then we didn't tend to
re-enter it very easily. Obviously sometimes it was _too_ hard to re-enter
it, which is why we had all the ugly hacks to magically sometimes force
our state to shrink_mmap(). 

> The problem that we have with the strict state-driven logic in
> do_try_to_free_page is that, for prolonged periods, it can bypass the
> normal shrink_mmap() loop which we _do_ want to keep active even while
> swapping.  However, I think that the 132-pre2 cure is worse than the
> disease, because it penalises swap to such an extent that we lose the
> substantial performance benefit that comes from being able to stream
> both to and from swap rapidly.

Right. It's essentially not likely enough to start swapping. 

> The patch below is the best I have so far against 132-pre2.  You will
> find that it has absolutely no references to the borrow percentages, and
> although it does honour the buffer/pgcache min percentages, those
> default to 1%.

Can you try the even siompler patch of just changing

	int i=6;

to

	int i=8;

in do_try_to_free_page()? I suspect that's actually enough.

Basically, let's think about the problem analytically before we add any
"magic rules". That's what I tried to do with the pre-2 patch, and
basically the pre-2 patch has a _very_ simple lay-out:

   Always start with "shrink_mmap()", because that's the "simple" case,
   and gets rid of excessive page caches etc. HOWEVER, make
   "shrink_mmap()" initially timid enough, that if it doesn't find a nice
   page quickly, we then try to really swap things out.

Basically, there are no magic rules, no made-up "in this case we do that" 
setup. The only issue is one of "how timid are we initially" to get a good
balance. 

With a value of 6, it means that we try to see if we can find a page we
can easily throw out in the first 1/32th of the memory we test. That
sounds fairly timid, but it really isn't all that timid at all: if we have
even just a third of all pages being buffer cache pages, it's actually
fairly likely that we'd throw out that instead of trying to page anything
out. 

A initial "timidity" value of 8 means that we'd throw out a page from the
page map only if we find it really easily (ie we only look at 1/128th of
our memory). That may be too timid (and maybe 7 is right), but basically I
think this approach should work reasonably well for a wide range of memory
sizes. And I _really_ really want to try something without any silly magic
rules first. 

In short, first prove to me somehow that the rule _has_ to be there. 
Either by some argument that makes it obvious, or by showing that the
above simple change really doesn't work. 

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
