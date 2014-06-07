Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 060D76B0036
	for <linux-mm@kvack.org>; Sat,  7 Jun 2014 14:24:57 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id ik5so4713615vcb.33
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 11:24:57 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id 3si8138114vcs.47.2014.06.07.11.24.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Jun 2014 11:24:57 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id us18so2741927veb.20
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 11:24:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140607123518.88983301D2@webmail.sinamail.sina.com.cn>
References: <20140607123518.88983301D2@webmail.sinamail.sina.com.cn>
Date: Sat, 7 Jun 2014 11:24:56 -0700
Message-ID: <CA+55aFzRWZNt2AqdVzQpCChB1UJh12oBAof8UiKsvNGSMUe9BA@mail.gmail.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhdxzx@sina.com
Cc: Felipe Contreras <felipe.contreras@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, dhillf <dhillf@gmail.com>, "hillf.zj" <hillf.zj@alibaba-inc.com>

So we very recently (as in this merge window) merged a change to this
very area, but that change was very specific to one case.

Hillf's patch (below) apparently fixes the problem Felipe sees, and I
have to say, his problem sounds a *lot* like the kind of horrible
performance I've seen with writing to USB devices. I blamed
non-working per-bdi throttling, but this implies it is more generic
than that. The fact that the very same code also made nfsd very
unhappy makes me think that the code is just fundamentally broken.

And quite frankly, the whole logic is a bit questionable. That

  "nr_unqueued_dirty == nr_taken"

test is claimed to be "implies that flushers are not keeping up", but
that's not actually true at all. It just means that

 (a) all the pages we isolated are dirty
 (b) .. and none of them are under writeback

and it's very possible that none of them are under writeback because
nobody has even decided to start writeback on them yet, because nobody
has even walked through the list yet, so they were all still marked as
referenced. I guess you could say that "flushers are not keeping up",
but *we're* one of the flushers, and it's not that we aren't keeping
up, it's that we haven't even scanned things yet.

So what do we do when we haven't scanned the list enough to see any
non-referenced pages? Do we scan it a bit more? No. We decide to
congestion-wait.

That sounds completely and utterly stupid and broken. Does it make any
sense at all? No it doesn't. It just seems to delay starting any
writeback at all.

I suspect the code comes from "let's not spend too much time scanning
the dirty lists when everything is dirty", and is trying to avoid CPU
use. But what it seems to do is actually to avoid even starting
writeback in the first place, and just "congestion-waiting" even when
nothing is being written back (here "nothing" is not absolute - we're
only looking at a part of the dirty pages, obviously, but we're
looking at the *old* dirty pages, so it's a fairly important part of
it).

So I really get the feeling that this code is broken, and that the
patch to remove that "nr_unqueued_dirty == nr_taken" is correct.

In particular, doesn't that congestion wait - which is supposed to
wait for kswapd - end up waiting even when the process in question
*is* kswapd?

So it's not just processes like nfsd that got throttled down (which no
longer happens because of the recent commit 399ba0b95670), it seems
like kswapd itself gets throttled down because of this test.

So at the *very* least I feel like the new current_may_throttle()
needs to say that "kswapd must not be throttled", but I wonder if that
whole thing just needs to go.

And maybe that recent commit 399ba0b95670 is actually broken, and
wanted to fix just this part too. Maybe it *should* wait for the
"nr_immediate" case, which is the one that is currently aimed at
*only* throttling down kswapd itself. Maybe we should remove the
"current_is_kswapd()" test in the nr_immediate code instead, and make
everybody throttle when they hit the actual _real_ congestion case of
the whole zone being under writeback?

Comments? Mel, this code is mostly attributed to you, I'd like to hear
what you think in particular.

                    Linus

On Sat, Jun 7, 2014 at 5:35 AM,  <zhdxzx@sina.com> wrote:
>
> The comments around the congestion_wait,
> [1]
>          *
>          * Once a zone is flagged ZONE_WRITEBACK, kswapd will count the number
>          * of pages under pages flagged for immediate reclaim and stall if any
>          * are encountered in the nr_immediate check below.
>          */
>         if (nr_writeback && nr_writeback == nr_taken)
>                 zone_set_flag(zone, ZONE_WRITEBACK);
>
>
> [2]
>                 /*
>                  * If dirty pages are scanned that are not queued for IO, it
>                  * implies that flushers are not keeping up. In this case, flag
>                  * the zone ZONE_TAIL_LRU_DIRTY and kswapd will start writing
>                  * pages from reclaim context. It will forcibly stall in the
>                  * next check.
>                  */
>                 if (nr_unqueued_dirty == nr_taken)
>                         zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
>
> The "force stall" in [2] conflicts with "start writing pages" in [2], and
> conflicts with "nr_immediate check below" in [1] as well, IIUC.
>
> Would you please try again based only on comment [1](based on v3.15-rc8)?
> thanks
> Hillf
>
> --- a/mm/vmscan.c       Sat Jun  7 18:38:08 2014
> +++ b/mm/vmscan.c       Sat Jun  7 20:08:36 2014
> @@ -1566,7 +1566,7 @@ shrink_inactive_list(unsigned long nr_to
>                  * implies that pages are cycling through the LRU faster than
>                  * they are written so also forcibly stall.
>                  */
> -               if (nr_unqueued_dirty == nr_taken || nr_immediate)
> +               if (nr_immediate)
>                         congestion_wait(BLK_RW_ASYNC, HZ/10);
>         }
>
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
