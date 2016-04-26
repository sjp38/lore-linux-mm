Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D30B16B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:30:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so8693961lfc.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 03:30:24 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id y5si29214943wjf.136.2016.04.26.03.30.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 03:30:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 724551C15D7
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 11:30:22 +0100 (IST)
Date: Tue, 26 Apr 2016 11:30:17 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 05/28] mm, page_alloc: Inline the fast path of the
 zonelist iterator
Message-ID: <20160426103017.GA2858@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-6-git-send-email-mgorman@techsingularity.net>
 <571E2EAA.2050206@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <571E2EAA.2050206@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 25, 2016 at 04:50:18PM +0200, Vlastimil Babka wrote:
> > @@ -3193,17 +3193,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >   	 */
> >   	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> >   
> > -	/*
> > -	 * Find the true preferred zone if the allocation is unconstrained by
> > -	 * cpusets.
> > -	 */
> > -	if (!(alloc_flags & ALLOC_CPUSET) && !ac->nodemask) {
> > -		struct zoneref *preferred_zoneref;
> > -		preferred_zoneref = first_zones_zonelist(ac->zonelist,
> > -				ac->high_zoneidx, NULL, &ac->preferred_zone);
> > -		ac->classzone_idx = zonelist_zone_idx(preferred_zoneref);
> > -	}
> > -
> >   	/* This is the last chance, in general, before the goto nopage. */
> >   	page = get_page_from_freelist(gfp_mask, order,
> >   				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
> > @@ -3359,14 +3348,21 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >   	struct zoneref *preferred_zoneref;
> >   	struct page *page = NULL;
> >   	unsigned int cpuset_mems_cookie;
> > -	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
> > +	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_FAIR;
> >   	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
> >   	struct alloc_context ac = {
> >   		.high_zoneidx = gfp_zone(gfp_mask),
> > +		.zonelist = zonelist,
> >   		.nodemask = nodemask,
> >   		.migratetype = gfpflags_to_migratetype(gfp_mask),
> >   	};
> >   
> > +	if (cpusets_enabled()) {
> > +		alloc_flags |= ALLOC_CPUSET;
> > +		if (!ac.nodemask)
> > +			ac.nodemask = &cpuset_current_mems_allowed;
> > +	}
> 
> My initial reaction is that this is setting ac.nodemask in stone outside
> of cpuset_mems_cookie, but I guess it's ok since we're taking a pointer
> into current's task_struct, not the contents of the current's nodemask.
> It's however setting a non-NULL nodemask into stone, which means no
> zonelist iterator fasthpaths... but only in the slowpath. I guess it's
> not an issue then.
> 

You're right in that setting it in stone is problematic if the cpuset
nodemask changes duration allocation. The retry loop knows there is a
change but does not look it up which would loop once then potentially fail
unnecessarily. I should have moved the retry_cpuset label above the point
where cpuset_current_mems_allowed gets set. That's option 1 as a fixlet
to this patch.

> > +
> >   	gfp_mask &= gfp_allowed_mask;
> >   
> >   	lockdep_trace_alloc(gfp_mask);
> > @@ -3390,16 +3386,12 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
> >   retry_cpuset:
> >   	cpuset_mems_cookie = read_mems_allowed_begin();
> >   
> > -	/* We set it here, as __alloc_pages_slowpath might have changed it */
> > -	ac.zonelist = zonelist;
> 
> This doesn't seem relevant to the preferred_zoneref changes in
> __alloc_pages_slowpath, so why it became ok? Maybe it is, but it's not
> clear from the changelog.
> 

The slowpath is no longer altering the preferred_zoneref.

> Anyway, thinking about it made me realize that maybe we could move the
> whole mems_cookie thing into slowpath? As soon as the optimistic
> fastpath succeeds, we don't check the cookie anyway, so what about
> something like this on top?
> 

That in general would seem reasonable although I don't think it applies
to the series properly. Do you want to do this as a patch on top of the
series or will I use the fixlet for now and probably follow up with the
cookie move in a week or so when I've caught up after LSF/MM?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
