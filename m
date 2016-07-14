Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 239C16B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:05:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so52008009wme.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 02:05:05 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id s73si767095lfi.307.2016.07.14.02.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 02:05:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 63D991C257C
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 10:05:02 +0100 (IST)
Date: Thu, 14 Jul 2016 10:05:00 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
Message-ID: <20160714090500.GL9806@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160707012038.GB27987@js1304-P5Q-DELUXE>
 <20160707101701.GR11498@techsingularity.net>
 <20160708024447.GB2370@js1304-P5Q-DELUXE>
 <20160708101147.GD11498@techsingularity.net>
 <20160714052332.GA29676@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160714052332.GA29676@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 14, 2016 at 02:23:32PM +0900, Joonsoo Kim wrote:
> > 
> > > > > And, I'd like to know why max() is used for classzone_idx rather than
> > > > > min()? I think that kswapd should balance the lowest zone requested.
> > > > > 
> > > > 
> > > > If there are two allocation requests -- one zone-constraned and the other
> > > > zone-unconstrained, it does not make sense to have kswapd skip the pages
> > > > usable for the zone-unconstrained and waste a load of CPU. You could
> > > 
> > > I agree that, in this case, it's not good to skip the pages usable
> > > for the zone-unconstrained request. But, what I am concerned is that
> > > kswapd stop reclaim prematurely in the view of zone-constrained
> > > requestor.
> > 
> > It doesn't stop reclaiming for the lower zones. It's reclaiming the LRU
> > for the whole node that may or may not have lower zone pages at the end
> > of the LRU. If it does, then the allocation request will be satisfied.
> > If it does not, then kswapd will think the node is balanced and get
> > rewoken to do a zone-constrained reclaim pass.
> 
> If zone-constrained request could go direct reclaim pass, there would
> be no problem. But, please assume that request is zone-constrained
> without __GFP_DIRECT_RECLAIM which is common for some device driver
> implementation.

Then it's likely GFP_ATOMIC and it'll wake kswapd on each failure. If
kswapd is containtly awake for highmem requests then we're reclaiming
everything anyway.  Remember that if kswapd is reclaiming for higher zones,
it'll still cover the lower zones eventually. There is no guarantee that
skipping the highmem pages will satisfy the atomic allocations any faster
but consuming the CPU to skip the pages is a definite cost.

Even worse, skipping highmem pages when a highmem pages are required may
ake lowmem pressure worse because those pages are freed faster and can
be consumed by zone-unconstrained requests.

If this really is a problem in practice then we can consider having
allocation requests that are zone-constrained and !__GFP_DIRECT_RECLAIM
set a flag and use the min classzone for the wakeup. That flag remains
set until kswapd takes at least one pass using the lower classzone and
clears it. The classzone will not be adjusted higher until that flag is
cleared. I don't think we should do it without evidence that it's a real
problem because kswapd potentially uses useless CPU and the potential for
higher lowmem pressure.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
