Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0850D6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:37:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so29937977wma.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:37:29 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id b75si6344724wma.30.2016.07.13.01.37.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 01:37:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 81C401C1D1D
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:37:28 +0100 (IST)
Date: Wed, 13 Jul 2016 09:37:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 06/34] mm, vmscan: have kswapd only scan based on the
 highest requested zone
Message-ID: <20160713083726.GE9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-7-git-send-email-mgorman@techsingularity.net>
 <20160712140504.GC5881@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160712140504.GC5881@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 10:05:04AM -0400, Johannes Weiner wrote:
> On Fri, Jul 08, 2016 at 10:34:42AM +0100, Mel Gorman wrote:
> > kswapd checks all eligible zones to see if they need balancing even if it
> > was woken for a lower zone.  This made sense when we reclaimed on a
> > per-zone basis because we wanted to shrink zones fairly so avoid
> > age-inversion problems.  Ideally this is completely unnecessary when
> > reclaiming on a per-node basis.  In theory, there may still be anomalies
> > when all requests are for lower zones and very old pages are preserved in
> > higher zones but this should be the exceptional case.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> I wasn't quite sure at first what the rationale is for this patch,
> since it probably won't make much difference in pratice.

Possibly not, it depends on how much embedded 32-bit platforms use features
like zswap. What I wanted to avoid was a lowmem allocation for zswap
excessively reclaiming highmem putting even further pressure on zswap if
the pages are anonymous.

> But I do
> agree that the code is cleaner to have kswapd check exactly what it
> was asked to check, rather than some do-the-"right"-thing magic.
> 

But this is a justification on its own. I encountered an astonishing number
of magic number handling that just happened to mostly work. I wanted to
iron them out as much as possible.

> A hypothetical onslaught of low-zone allocations will wreak havoc to
> the page age in higher zones anyway, right? So I don't think that case
> matters all that much.

Possibly not, but it was straight-forward to mitigate the damage without
too many side-effects.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
