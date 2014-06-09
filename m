Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 58D2F6B0080
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 08:58:14 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id k48so5891265wev.33
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 05:58:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hm3si31444230wjc.49.2014.06.09.05.58.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 05:58:12 -0700 (PDT)
Date: Mon, 9 Jun 2014 13:58:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
Message-ID: <20140609125806.GN10819@suse.de>
References: <20140607123518.88983301D2@webmail.sinamail.sina.com.cn>
 <CA+55aFzRWZNt2AqdVzQpCChB1UJh12oBAof8UiKsvNGSMUe9BA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFzRWZNt2AqdVzQpCChB1UJh12oBAof8UiKsvNGSMUe9BA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: zhdxzx@sina.com, Felipe Contreras <felipe.contreras@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, dhillf <dhillf@gmail.com>, "hillf.zj" <hillf.zj@alibaba-inc.com>

On Sat, Jun 07, 2014 at 11:24:56AM -0700, Linus Torvalds wrote:
> So we very recently (as in this merge window) merged a change to this
> very area, but that change was very specific to one case.
> 
> Hillf's patch (below) apparently fixes the problem Felipe sees, and I
> have to say, his problem sounds a *lot* like the kind of horrible
> performance I've seen with writing to USB devices. I blamed
> non-working per-bdi throttling, but this implies it is more generic
> than that. The fact that the very same code also made nfsd very
> unhappy makes me think that the code is just fundamentally broken.
> 
> And quite frankly, the whole logic is a bit questionable. That
> 
>   "nr_unqueued_dirty == nr_taken"
> 
> test is claimed to be "implies that flushers are not keeping up", but
> that's not actually true at all. It just means that
> 
>  (a) all the pages we isolated are dirty
>  (b) .. and none of them are under writeback
> 
> and it's very possible that none of them are under writeback because
> nobody has even decided to start writeback on them yet, because nobody
> has even walked through the list yet, so they were all still marked as
> referenced. I guess you could say that "flushers are not keeping up",
> but *we're* one of the flushers, and it's not that we aren't keeping
> up, it's that we haven't even scanned things yet.
> 
> So what do we do when we haven't scanned the list enough to see any
> non-referenced pages? Do we scan it a bit more? No. We decide to
> congestion-wait.
> 
> That sounds completely and utterly stupid and broken. Does it make any
> sense at all? No it doesn't. It just seems to delay starting any
> writeback at all.
> 

The original intent was moving away from direct reclaimers and kswapd just
blocking on congestion for the sake of it and avoiding excessive swapping
during IO. That was not a smooth road.

> I suspect the code comes from "let's not spend too much time scanning
> the dirty lists when everything is dirty", and is trying to avoid CPU
> use.

Yes. At the time we moved away from calling congestion_wait() for all
sorts of reasons there were a number of bugs with different root causes
but looked like kswapd using 99% of CPU during heavy IO.

> But what it seems to do is actually to avoid even starting
> writeback in the first place, and just "congestion-waiting" even when
> nothing is being written back (here "nothing" is not absolute - we're
> only looking at a part of the dirty pages, obviously, but we're
> looking at the *old* dirty pages, so it's a fairly important part of
> it).
> 
> So I really get the feeling that this code is broken, and that the
> patch to remove that "nr_unqueued_dirty == nr_taken" is correct.
> 

I cannot think of a reason to disagree with that. It was a mistake because
it also failed to take into account that writeback might not have delayed
because the dirty expire limit had not been reached.

> In particular, doesn't that congestion wait - which is supposed to
> wait for kswapd - end up waiting even when the process in question
> *is* kswapd?
> 
> So it's not just processes like nfsd that got throttled down (which no
> longer happens because of the recent commit 399ba0b95670), it seems
> like kswapd itself gets throttled down because of this test.
> 
> So at the *very* least I feel like the new current_may_throttle()
> needs to say that "kswapd must not be throttled", but I wonder if that
> whole thing just needs to go.
> 
> And maybe that recent commit 399ba0b95670 is actually broken, and
> wanted to fix just this part too. Maybe it *should* wait for the
> "nr_immediate" case, which is the one that is currently aimed at
> *only* throttling down kswapd itself. Maybe we should remove the
> "current_is_kswapd()" test in the nr_immediate code instead, and make
> everybody throttle when they hit the actual _real_ congestion case of
> the whole zone being under writeback?
> 
> Comments? Mel, this code is mostly attributed to you, I'd like to hear
> what you think in particular.
> 

I've no problem with your patch so lets go with it with the caveat that there
are three bugs to watch out for. The first is excessive CPU usage during
reclaim by direct reclaimers or kswapd which should still be controlled
but worth watching for anyway. The second is excessive writeback from
kswapd context resulting in poor IO efficiency which is harder to measure a
performance impact for but looks like high counts for nr_vmscan_write. The
third is excessive swapping during IO as the file LRUs are being scanned
with mostly dirty pages and the reclaimer swaps anonymous pages instead
which will look like interactivity stalls due to swapping during heavy IO. I
can keep an eye out for all three when my regression tests pick up 3.16-rc1.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
