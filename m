Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA13239
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 17:02:37 -0500
Date: Sat, 19 Dec 1998 22:01:14 GMT
Message-Id: <199812192201.WAA04889@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: New patch (was Re: [PATCH] swapin readahead v3 + kswapd fixes)
In-Reply-To: <Pine.LNX.3.95.981219112608.348B-100000@penguin.transmeta.com>
References: <199812191709.RAA01245@dax.scot.redhat.com>
	<Pine.LNX.3.95.981219112608.348B-100000@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi Linus,

On Sat, 19 Dec 1998 11:41:56 -0800 (PST), Linus Torvalds
<torvalds@transmeta.com> said:

> If you're testing different approaches, how about this one (_reasoning_
> first, not just some magic heuristic): 

>  - kswapd and normal processes are decidedly different animals

>  - as a result, it doesn't necessarily make sense to have the same
>    "do_try_to_free_page()" for them both. 

Absolutely.  There's nothing "magic" in the patch I just sent you,
except for one special condition in do_try_to_free_page:

	if (current != kswapd_task)
		if (shrink_mmap(6, gfp_mask))
			return 1;

The entire point is that we really want swapping out to disk to be a
background task, but we still want memory to be continue to be made
available to otherwise-stalled foreground processes.  

I have already been experimenting with this: having a fairly traditional
but shrink_mmap-biased do_try_to_free_page for foreground tasks and a
dedicated swap loop within kswapd, for example.  I simply failed to get
any such scheme to perform as well as the patch I sent you.

>    For example, for a normal process, it makes sense to do a
>    shrink_mmap() more aggressively to just try to get rid of some page
>    without actually having to do any IO. In contrast, kswapd quite
>    naturally wants to be more aggressive about paging things out so
>    that when a regular process does need memory, it will get it easily
>    without having to wait for it.

That is precisely the compromise I reached in the patch I sent you,
courtesy of the test above.  In fact, you'll see in that patch that
get_free_pages() also has a section

		/* Try this if you want, but it seems to result in too
		 * much IO activity during builds, and does not
		 * substantially reduce the number of times we invoke
		 * kswapd.  --sct */
#if 0
		if (nr_free_pages < freepages.high &&
		    !(gfp_mask & (__GFP_MED | __GFP_HIGH)))
			try_to_shrink_cache(gfp_mask);
#endif

In other words, I have _already_ tried this and it didn't work, for one
of the same reasons your own 132-pre2 didn't work: that it could far too
easily trap itself in a loop in which a kernel build was regularly doing
100 or 200 read IOs per second, indicating too small a cache.  This is a
regression over the mechanism we already had.

> Does the above make sense to you?  It would quite naturally explain
> your "magic heuristic" in your previous patch

Yes.  Linus, I actually tried a _huge_ number of such schemes back when
I was doing the original 1.2.13 kswap stuff.  I think I had about 24
separately tagged sets of heuristics in CVS at one point.  From what I
learnt then, and from what I've experienced recently when looking more
closely at new stuff like the effects on performance of Rik's swap
clustering ideas, I really do think that we need to find a balance which
allows us to expand a cache somewhat under heavy IO load, to shrink the
cache aggressively when under other loads, and which still allows us to
stream to swap very rapidly.  

The "magic heuristic" you talk about was a quite deliberate result of
the same line of thought you are taking now.  The problem is, I'm going
to be mostly offline now until the New Year, so right now I do not have
time to sit down and invent a completely new mechanism here: I want to
make sure that we have something which is sufficiently recognisable as
our tried and tested VM to have some confidence we are not introducing
new pathological behaviours before 2.2, while still removing the black
magic and using reasoned algorithms.  The patch I sent you is the result
of that.

Ultimately, I don't think we just want a separate set of routines for
background and foreground swapping: I think we really need more than
that.  We need the background swap task to be separate from the
background cache cleaner: swapping can potentially stall for a number of
reasons (especially when swapping to a file), but for the sake of IRQ
memory demand we still want to have some page stealing capacity when the
swapout-task blocks (one of the old heuristics I have got coded
somewhere in fact does this, separating out the kswapd thread --- which
is now fully asynchronous --- from a kswapio thread which does the
actual IO, and just in this past week I've been trying a scheme in which
kswapd only calls swap_out if it knows that there are few enough async
pages in progress that the IO won't block.

The trouble is, every such scheme I have tried has some disadvantage
compared with ac11 or with the last patch I sent you.  In particular,
they tend to stream swap poorly, and often have very unbalanced or
unstable cache sizes.

I _could_ in theory tune one of these other mechanisms up until it
matched what we have today, but I've spent quite a bit of time over
the past week or two getting various problems out of the existing VM
now and benchmarking it under a variety of load conditions.
Unfortunately, that will have to wait until the new year if you want
it done.  If somebody else wants to, it might be useful to try putting
together your changes here with the clustered pagein stuff to see what
sort of performance results.

Anyway, so far I've done a very brief couple of tests with the s/6/8/
change you suggested.  It certainly seems to work about as well many
of the previous VMs for the 64MB test case, although a bit slower in
8MB; however it appears to shrink the cache rather aggressively and I
noticed some rather odd amounts of IO during a kernel build.  Too
early to make a definitive judgement, but it is certainly _much_
better than the "i=6" version.


--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
