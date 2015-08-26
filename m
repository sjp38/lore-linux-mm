Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id D59516B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 14:10:45 -0400 (EDT)
Received: by wijn1 with SMTP id n1so32536821wij.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:10:45 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id bv19si11183811wib.81.2015.08.26.11.10.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 11:10:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id A199D98960
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 18:10:43 +0000 (UTC)
Date: Wed, 26 Aug 2015 19:10:41 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 07/12] mm, page_alloc: Distinguish between being unable
 to sleep, unwilling to sleep and avoiding waking kswapd
Message-ID: <20150826181041.GR12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-8-git-send-email-mgorman@techsingularity.net>
 <55DC8BD7.602@suse.cz>
 <20150826144533.GO12432@techsingularity.net>
 <55DDE842.8000103@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <55DDE842.8000103@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 26, 2015 at 06:24:34PM +0200, Vlastimil Babka wrote:
> On 08/26/2015 04:45 PM, Mel Gorman wrote:
> >On Tue, Aug 25, 2015 at 05:37:59PM +0200, Vlastimil Babka wrote:
> >>>@@ -2158,7 +2158,7 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
> >>>  		return false;
> >>>  	if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
> >>>  		return false;
> >>>-	if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & __GFP_WAIT))
> >>>+	if (fail_page_alloc.ignore_gfp_wait && (gfp_mask & (__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
> >>>  		return false;
> >>>
> >>>  	return should_fail(&fail_page_alloc.attr, 1 << order);
> >>
> >>IIUC ignore_gfp_wait tells it to assume that reclaimers will eventually
> >>succeed (for some reason?), so they shouldn't fail. Probably to focus the
> >>testing on atomic allocations. But your change makes atomic allocation never
> >>fail, so that goes against the knob IMHO?
> >>
> >
> >Fair point, I'll remove the __GFP_ATOMIC check. I felt this was a sensible
> >but then again deliberately failing allocations makes my brain twitch a
> >bit. In retrospect, someone who cared should add a ignore_gfp_atomic knob.
> 
> Thanks.
> 
> >>>@@ -2660,7 +2660,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
> >>>  		if (test_thread_flag(TIF_MEMDIE) ||
> >>>  		    (current->flags & (PF_MEMALLOC | PF_EXITING)))
> >>>  			filter &= ~SHOW_MEM_FILTER_NODES;
> >>>-	if (in_interrupt() || !(gfp_mask & __GFP_WAIT))
> >>>+	if (in_interrupt() || !(gfp_mask & __GFP_WAIT) || (gfp_mask & __GFP_ATOMIC))
> >>>  		filter &= ~SHOW_MEM_FILTER_NODES;
> >>>
> >>>  	if (fmt) {
> >>
> >>This caught me previously and I convinced myself that it's OK, but now I'm
> >>not anymore. IIUC this is to not filter nodes by mems_allowed during
> >>printing, if the allocation itself wasn't limited? In that case it should
> >>probably only look at __GFP_ATOMIC after this patch? As that's the only
> >>thing that determines ALLOC_CPUSET.
> >>I don't know where in_interrupt() comes from, but it was probably considered
> >>in the past, as can be seen in zlc_setup()?
> >>
> >
> >I assumed the in_interrupt() thing was simply because cpusets were the
> >primary means of limiting allocations of interest to the author at the
> >time.
> 
> IIUC this hunk is unrelated to the previous one - not about limiting
> allocations, but printing allocation warnings. Which includes the state of
> nodes where the allocation was allowed to try. And ~SHOW_MEM_FILTER_NODES
> means it was allowed everywhere, so the printing won't filter by
> mems_allowed.
> 
> >I guess now that I think about it more that a more sensible check would
> >be against __GFP_DIRECT_RECLAIM because that covers the interesting
> >cases.
> 
> I think the most robust check would be to rely on what was already prepared
> by gfp_to_alloc_flags(), instead of repeating it here. So add alloc_flags
> parameter to warn_alloc_failed(), and drop the filter when
> - ALLOC_CPUSET is not set, as that disables the cpuset checks
> - ALLOC_NO_WATERMARKS is set, as that allows calling
>   __alloc_pages_high_priority() attempt which ignores cpusets
> 

warn_alloc_failed is used outside of page_alloc.c in a context that does
not have alloc_flags. It could be extended to take an extra parameter
that is ALLOC_CPUSET for the other callers or else split it into
__warn_alloc_failed (takes alloc_flags parameter) and warn_alloc_failed
(calls __warn_alloc_failed with ALLOC_CPUSET) but is it really worth it?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
