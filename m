Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA31543
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 16:11:01 -0500
Subject: Re: Results: 2.2.0-pre5 vs arcavm10 vs arcavm9 vs arcavm7
References: <Pine.LNX.3.95.990107112314.5025B-100000@penguin.transmeta.com>
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 07 Jan 1999 22:10:12 +0100
In-Reply-To: Linus Torvalds's message of "Thu, 7 Jan 1999 11:33:49 -0800 (PST)"
Message-ID: <87ogoa7psb.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@transmeta.com> writes:

> On 7 Jan 1999, Zlatko Calusic wrote:
> > 
> > 1) Swap performance in pre-5 is much worse compared to pre-4 in
> > *certain* circumstances. I'm using quite stupid and unintelligent
> > program to check for raw swap speed (attached below). With 64 MB of
> > RAM I usually run it as 'hogmem 100 3' and watch for result which is
> > recently around 6 MB/sec. But when I lately decided to start two
> > instances of it like "hogmem 50 3 & hogmem 50 3 &" in pre-4 I got 2 x
> > 2.5 MB/sec and in pre-5 it is only 2 x 1 MB/sec and disk is making
> > very weird and frightening sounds. My conclusion is that now (pre-5)
> > system behaves much poorer when we have more than one thrashing
> > task. *Please*, check this, it is a quite serious problem.
> 
> Ok, will investigate. One thing you can test is to try out different
> "count" arguments to try_to_free_pages() (this was part of what Andrea
> did, btw). So instead of (page_alloc.c, line 285):
> 
> 	freed = try_to_free_pages(gfp_mask, SWAP_CLUSTER_MAX);
> 
> you can try different things for the second argument: the thing Andrea did
> was something like
> 
> 	freed = try_to_free_pages(gfp_mask, freepages.high - nr_free_pages);
> 
> which could work well (one thing I'm nervous about is that this probably
> needs to be limited some way - it can be quite a large number on large
> machines, and that's why I'd like to hear comments from people).

OK, I'll check what can be done with that, as time permits.

> 
> > 2) In pre-5, under heavy load, free memory is hovering around
> > freepages.min instead of being somewhere between freepages.low &
> > freepages.max. This could make trouble for bursts of atomic
> > allocations (networking!).
> 
> The change above would change this too.

Yes, probably.

> 
> > 3) Nitpick #1: /proc/swapstats exist but is only filled with
> > zeros. Probably it should go away. I believe Stephen added it
> > recently, but only part of his patch got actually applied.
> 
> Maybe somebody can find a use for it.

Of course it can, but *right now* it's useless. So if nobody gets in
(Stephen?), I'll take it and fix it. I have a similar, even more
verbose patch for MM statistics with ~15 columns of information, but
that one does not apply cleanly on the latest kernels (obvious
reasons).

> 
> > 4) Nitpick #2": "Swap cache:" line in report of Alt-SysRq-M is not
> > useful as it is laid now. People have repeatedly sent patches (Rik,
> > Andrea...) to fix this but it is still not fixed, as of pre-5.
> 
> I never use it, so it hasn't been a big issue.

But it is, cause if properly done, it could give valuable information
about swap cache hit, and thus differentiate among various algorithms
we use for memory management. If I understand correctly, lots of
changes happened in MM in last few kernel revisions, but nobody knows
exactly what we're doing (there were few macro benchmarks done, which
are by definition not very useful for selecting among algorithms).

> 
> > 5) There is lots of #if 0 constructs in MM code, and also lots of
> > structures are not anymore used but still take precious memory in
> > compiled kernel and uncover itself under /proc (/proc/sys/vm/swapctl
> > for instance). Do you want a patch to remove this cruft?
> 
> Some of the #if 0 code should certainly be removed. Some of it is useful
> as a kind of commentary - sometimes code is removed not because it doesn't
> make sense, but because the implementation wasn't quite good enough.
> 

I'll see tomorrow if I can prepare one patch to fix few annoyances I
reported.

Good night!
-- 
Zlatko
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
