Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3496B025E
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 04:40:40 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so27763267lfg.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:40:40 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id v18si26726052wmv.32.2016.07.13.01.40.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 01:40:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id A69BA99288
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:40:38 +0000 (UTC)
Date: Wed, 13 Jul 2016 09:40:37 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 11/34] mm, vmscan: remove duplicate logic clearing node
 congestion and dirty state
Message-ID: <20160713084037.GF9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-12-git-send-email-mgorman@techsingularity.net>
 <20160712142256.GE5881@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160712142256.GE5881@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 10:22:56AM -0400, Johannes Weiner wrote:
> On Fri, Jul 08, 2016 at 10:34:47AM +0100, Mel Gorman wrote:
> > @@ -3008,7 +3008,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
> >  {
> >  	unsigned long mark = high_wmark_pages(zone);
> >  
> > -	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
> > +	if (!zone_watermark_ok_safe(zone, order, mark, classzone_idx))
> > +		return false;
> > +
> > +	/*
> > +	 * If any eligible zone is balanced then the node is not considered
> > +	 * to be congested or dirty
> > +	 */
> > +	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
> > +	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
> 
> Predicate functions that secretly modify internal state give me the
> willies... The diffstat is flat, too. Is this really an improvement?

Primarily, it's about less duplicated code and maintenance overhead.
Overall I was both trying to remove side-effects and make the kswapd flow
easier to follow.

I'm open to renaming suggestions that make it clear the function
has side-effects. Best I came up with after the first coffee is
try_reset_zone_balanced() which returns true with congestion/dirty state
cleared if the zone is balanced. The name is not great because it's also
a little misleading. It doesn't try to reset anything, that's reclaim's job.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
