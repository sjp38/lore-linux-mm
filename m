Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E20C6B025F
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 01:03:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y134so299829690pfg.1
        for <linux-mm@kvack.org>; Sun, 17 Jul 2016 22:03:51 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id jh2si24701888pac.238.2016.07.17.22.03.49
        for <linux-mm@kvack.org>;
        Sun, 17 Jul 2016 22:03:50 -0700 (PDT)
Date: Mon, 18 Jul 2016 14:07:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160718050756.GD9460@js1304-P5Q-DELUXE>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160707012038.GB27987@js1304-P5Q-DELUXE>
 <20160707101701.GR11498@techsingularity.net>
 <20160708024447.GB2370@js1304-P5Q-DELUXE>
 <20160708101147.GD11498@techsingularity.net>
 <20160714052332.GA29676@js1304-P5Q-DELUXE>
 <5b6b1490-1dbc-74fc-e129-947141a1bee3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b6b1490-1dbc-74fc-e129-947141a1bee3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 14, 2016 at 10:32:09AM +0200, Vlastimil Babka wrote:
> On 07/14/2016 07:23 AM, Joonsoo Kim wrote:
> >On Fri, Jul 08, 2016 at 11:11:47AM +0100, Mel Gorman wrote:
> >>On Fri, Jul 08, 2016 at 11:44:47AM +0900, Joonsoo Kim wrote:
> >>
> >>It doesn't stop reclaiming for the lower zones. It's reclaiming the LRU
> >>for the whole node that may or may not have lower zone pages at the end
> >>of the LRU. If it does, then the allocation request will be satisfied.
> >>If it does not, then kswapd will think the node is balanced and get
> >>rewoken to do a zone-constrained reclaim pass.
> >
> >If zone-constrained request could go direct reclaim pass, there would
> >be no problem. But, please assume that request is zone-constrained
> >without __GFP_DIRECT_RECLAIM which is common for some device driver
> >implementation. And, please assume one more thing that this request
> >always comes with zone-unconstrained allocation request. In this case,
> >your max() logic will set kswapd_classzone_idx to highest zone index
> >and re-worken kswapd would not balance for low zone again. In the end,
> >zone-constrained allocation request without __GFP_DIRECT_RECLAIM could
> >fail.
> 
> I don't think there's a problem in the scenario? Kswapd will keep
> being woken up and reclaim from the node lru. It will hit and free
> any low zone pages that are on the lru, even though it doesn't
> "balance for low zone". Eventually it will either satisfy the
> constrained allocation by reclaiming those low-zone pages during the
> repeated wakeups, or the low-zone wakeups will stop coming together
> with higher-zone wakeups and then it will reclaim the low-zone pages
> in a single low-zone wakeup. If the zone-constrained request is not

Yes, probability of this would be low.

> allowed to fail, then it will just keep waking up kswapd and waiting
> for the progress. If it's allowed to fail (i.e. not __GFP_NOFAIL),
> but not allowed to direct reclaim, it goes "goto nopage" rather
> quickly in __alloc_pages_slowpath(), without any waiting for
> kswapd's progress, so there's not really much difference whether the
> kswapd wakeup picked up a low classzone or not. Note the

Hmm... Even if allocation could fail, we should do our best to prevent
failure. Relying on luck isn't good idea to me.

Thanks.

> __GFP_NOFAIL but ~__GFP_DIRECT_RECLAIM is a WARN_ON_ONCE() scenario,
> so definitely not common...
> 
> >Thanks.
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
