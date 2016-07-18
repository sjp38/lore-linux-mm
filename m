Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB15E6B0261
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 03:20:50 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u186so181381157ita.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:20:50 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id w188si7790629itf.4.2016.07.18.00.20.49
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 00:20:50 -0700 (PDT)
Date: Mon, 18 Jul 2016 16:24:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160718072455.GG9460@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160707012038.GB27987@js1304-P5Q-DELUXE>
 <20160707101701.GR11498@techsingularity.net>
 <20160708024447.GB2370@js1304-P5Q-DELUXE>
 <20160708101147.GD11498@techsingularity.net>
 <20160714052332.GA29676@js1304-P5Q-DELUXE>
 <5b6b1490-1dbc-74fc-e129-947141a1bee3@suse.cz>
 <20160718050756.GD9460@js1304-P5Q-DELUXE>
 <ddb22709-5536-b147-e0e4-cd9f6b11820a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ddb22709-5536-b147-e0e4-cd9f6b11820a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 08:51:16AM +0200, Vlastimil Babka wrote:
> On 07/18/2016 07:07 AM, Joonsoo Kim wrote:
> >On Thu, Jul 14, 2016 at 10:32:09AM +0200, Vlastimil Babka wrote:
> >>On 07/14/2016 07:23 AM, Joonsoo Kim wrote:
> >>
> >>I don't think there's a problem in the scenario? Kswapd will keep
> >>being woken up and reclaim from the node lru. It will hit and free
> >>any low zone pages that are on the lru, even though it doesn't
> >>"balance for low zone". Eventually it will either satisfy the
> >>constrained allocation by reclaiming those low-zone pages during the
> >>repeated wakeups, or the low-zone wakeups will stop coming together
> >>with higher-zone wakeups and then it will reclaim the low-zone pages
> >>in a single low-zone wakeup. If the zone-constrained request is not
> >
> >Yes, probability of this would be low.
> >
> >>allowed to fail, then it will just keep waking up kswapd and waiting
> >>for the progress. If it's allowed to fail (i.e. not __GFP_NOFAIL),
> >>but not allowed to direct reclaim, it goes "goto nopage" rather
> >>quickly in __alloc_pages_slowpath(), without any waiting for
> >>kswapd's progress, so there's not really much difference whether the
> >>kswapd wakeup picked up a low classzone or not. Note the
> >
> >Hmm... Even if allocation could fail, we should do our best to prevent
> >failure. Relying on luck isn't good idea to me.
> 
> But "Doing our best" has to have some sane limits. Allocation, that

Ensuring to do something for the requested zone at least once isn't insane.

> cannot direct reclaim, already relies on luck. And we are not really
> changing this. The allocation will "goto nopage" before kswapd can
> even wake up and start doing something, regardless of classzone_idx
> used.

But, this patch makes things worse. Even if next allocation comes
after kswapd is waking up and doing something, low zone would not be
balanced due to max classzone_idx and allocation could fail. It is
what this patch changes and I worry.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
