Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7389B6B0271
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:00:27 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l138so73944168wmg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:00:27 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id 73si2799871wmu.116.2016.09.22.07.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 07:52:52 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 133so14525435wmq.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 07:52:39 -0700 (PDT)
Date: Thu, 22 Sep 2016 16:52:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160922145237.GH11875@dhcp22.suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160906135258.18335-3-vbabka@suse.cz>
 <20160921171348.GF24210@dhcp22.suse.cz>
 <f1670976-b4da-5d2c-0a85-37f9a87d6868@suse.cz>
 <20160922140821.GG11875@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160922140821.GG11875@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Thu 22-09-16 16:08:21, Michal Hocko wrote:
> On Thu 22-09-16 14:51:48, Vlastimil Babka wrote:
> > >From 465e1bd61b7a6d6901a44f09b1a76514dbc220fa Mon Sep 17 00:00:00 2001
> > From: Vlastimil Babka <vbabka@suse.cz>
> > Date: Thu, 22 Sep 2016 13:54:32 +0200
> > Subject: [PATCH] mm, compaction: more reliably increase direct compaction
> >  priority-fix
> > 
> > When increasing the compaction priority, also reset retries. Otherwise we can
> > consume all retries on the lower priorities.
> 
> OK, this is an improvement. I am just thinking that we might want to
> pull
> 	if (order && compaction_made_progress(compact_result))
> 		compaction_retries++;
> 
> into should_compact_retry as well. I've had it there originally because
> it was in line with no_progress_loops but now that we have compaction
> priorities it would fit into retry logic better. As a plus it would
> count only those compaction rounds where we we didn't have to rely on
                                                 did that should be

> the compaction retry logic. What do you think?
> 
> > Suggested-by: Michal Hocko <mhocko@suse.com>
> > Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Anyway
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> > ---
> >  mm/page_alloc.c | 13 +++++++------
> >  1 file changed, 7 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f8bed910e3cf..82fdb690ac62 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3162,7 +3162,7 @@ static inline bool
> >  should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
> >  		     enum compact_result compact_result,
> >  		     enum compact_priority *compact_priority,
> > -		     int compaction_retries)
> > +		     int *compaction_retries)
> >  {
> >  	int max_retries = MAX_COMPACT_RETRIES;
> >  
> > @@ -3196,16 +3196,17 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
> >  	 */
> >  	if (order > PAGE_ALLOC_COSTLY_ORDER)
> >  		max_retries /= 4;
> > -	if (compaction_retries <= max_retries)
> > +	if (*compaction_retries <= max_retries)
> >  		return true;
> >  
> >  	/*
> > -	 * Make sure there is at least one attempt at the highest priority
> > -	 * if we exhausted all retries at the lower priorities
> > +	 * Make sure there are attempts at the highest priority if we exhausted
> > +	 * all retries or failed at the lower priorities.
> >  	 */
> >  check_priority:
> >  	if (*compact_priority > MIN_COMPACT_PRIORITY) {
> >  		(*compact_priority)--;
> > +		*compaction_retries = 0;
> >  		return true;
> >  	}
> >  	return false;
> > @@ -3224,7 +3225,7 @@ static inline bool
> >  should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
> >  		     enum compact_result compact_result,
> >  		     enum compact_priority *compact_priority,
> > -		     int compaction_retries)
> > +		     int *compaction_retries)
> >  {
> >  	struct zone *zone;
> >  	struct zoneref *z;
> > @@ -3663,7 +3664,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (did_some_progress > 0 &&
> >  			should_compact_retry(ac, order, alloc_flags,
> >  				compact_result, &compact_priority,
> > -				compaction_retries))
> > +				&compaction_retries))
> >  		goto retry;
> >  
> >  	/* Reclaim has failed us, start killing things */
> > -- 
> > 2.10.0
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
