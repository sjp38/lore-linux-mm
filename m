Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 2E6F96B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 06:08:13 -0400 (EDT)
Date: Wed, 4 Jul 2012 11:08:09 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where it
 left
Message-ID: <20120704100809.GK13141@csn.ul.ie>
References: <20120628135520.0c48b066@annuminas.surriel.com>
 <4FECE844.2050803@kernel.org>
 <4FF308CE.4070209@redhat.com>
 <4FF3AA43.1000500@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FF3AA43.1000500@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com

On Wed, Jul 04, 2012 at 11:28:19AM +0900, Minchan Kim wrote:
> >>> +                      zone->compact_cached_free_pfn>
> >>> +                      cc->start_free_pfn))
> >>> +            pfn = min(pfn, zone->compact_cached_free_pfn);
> >>
> >>
> >> The pfn can be where migrate_pfn below?
> >> I mean we need this?
> >>
> >> if (pfn<= low_pfn)
> >>     goto out;
> > 
> > That is a good point. I guess there is a small possibility that
> > another compaction thread is below us with cc->free_pfn and
> > cc->migrate_pfn, and we just inherited its cc->free_pfn via
> > zone->compact_cached_free_pfn, bringing us to below our own
> > cc->migrate_pfn.
> > 
> > Given that this was already possible with parallel compaction
> > in the past, I am not sure how important it is. It could result
> > in wasting a little bit of CPU, but your fix for it looks easy
> > enough.
> 
> In the past, it was impossible since we have per-compaction context free_pfn.
>  
> 
> > 
> > Mel, any downside to compaction bailing (well, wrapping around)
> > a little earlier, like Minchan suggested?
> 
> 
> I can't speak for Mel. But IMHO, if we meet such case, we can ignore compact_cached_free_pfn
> , then go with just pfn instead of early bailing.
> 

Wrapping early is not a problem. As Minchan pointed out this applies in
the case where the migrate scanner and free scanner have almost met or
have overlapped. In this case, it might even be better to wrap early
because there is no point isolating free pages that will then have to be
migrated a second time when the free scanner wraps and the migrate
scanner moves in.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
