Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 044896B006C
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 19:29:09 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id y20so157923ier.32
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:29:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q95si4007335ioi.29.2014.12.17.16.29.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Dec 2014 16:29:07 -0800 (PST)
Date: Wed, 17 Dec 2014 16:29:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/6] mm/page_alloc.c:__alloc_pages_nodemask(): don't
 alter arg gfp_mask
Message-Id: <20141217162905.9bc063be55a341d40b293c72@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1412171608300.16260@chino.kir.corp.google.com>
References: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org>
	<548F6F94.2020209@jp.fujitsu.com>
	<20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org>
	<alpine.DEB.2.10.1412171608300.16260@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, hannes@cmpxchg.org, mel@csn.ul.ie, ming.lei@canonical.com

On Wed, 17 Dec 2014 16:22:30 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Mon, 15 Dec 2014, Andrew Morton wrote:
> 
> > Well it was already wrong because the first allocation attempt uses
> > gfp_mask|__GFP_HARDWAL, but we only trace gfp_mask.
> > 
> > This?
> > 
> > --- a/mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask-fix
> > +++ a/mm/page_alloc.c
> > @@ -2877,6 +2877,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
> >  	unsigned int cpuset_mems_cookie;
> >  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
> >  	int classzone_idx;
> > +	gfp_t mask;
> >  
> >  	gfp_mask &= gfp_allowed_mask;
> >  
> > @@ -2910,23 +2911,24 @@ retry_cpuset:
> >  	classzone_idx = zonelist_zone_idx(preferred_zoneref);
> >  
> >  	/* First allocation attempt */
> > -	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> > -			zonelist, high_zoneidx, alloc_flags,
> > -			preferred_zone, classzone_idx, migratetype);
> > +	mask = gfp_mask|__GFP_HARDWALL;
> > +	page = get_page_from_freelist(mask, nodemask, order, zonelist,
> > +			high_zoneidx, alloc_flags, preferred_zone,
> > +			classzone_idx, migratetype);
> >  	if (unlikely(!page)) {
> >  		/*
> >  		 * Runtime PM, block IO and its error handling path
> >  		 * can deadlock because I/O on the device might not
> >  		 * complete.
> >  		 */
> > -		gfp_t mask = memalloc_noio_flags(gfp_mask);
> > +		mask = memalloc_noio_flags(gfp_mask);
> >  
> >  		page = __alloc_pages_slowpath(mask, order,
> >  				zonelist, high_zoneidx, nodemask,
> >  				preferred_zone, classzone_idx, migratetype);
> >  	}
> >  
> > -	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> > +	trace_mm_page_alloc(page, order, mask, migratetype);
> >  
> >  out:
> >  	/*
> 
> I'm not sure I understand why we need a local variable to hold the context 
> mask vs. what was passed to the function.  We should only be allocating 
> with a single gfp_mask that is passed to the function and modify it as 
> necessary, and that becomes the context mask that can be traced.
> 
> The above is wrong because it unconditionally sets __GFP_HARDWALL as the 
> gfp mask for __alloc_pages_slowpath() when we actually only want that for 
> the first allocation attempt, it's needed for the implementation of 
> __cpuset_node_allowed().

no,

: 	/* First allocation attempt */
: 	mask = gfp_mask|__GFP_HARDWALL;
: 	page = get_page_from_freelist(mask, nodemask, order, zonelist,
: 			high_zoneidx, alloc_flags, preferred_zone,
: 			classzone_idx, migratetype);
: 	if (unlikely(!page)) {
: 		/*
: 		 * Runtime PM, block IO and its error handling path
: 		 * can deadlock because I/O on the device might not
: 		 * complete.
: 		 */
: 		mask = memalloc_noio_flags(gfp_mask);

^^ this

: 		page = __alloc_pages_slowpath(mask, order,
: 				zonelist, high_zoneidx, nodemask,
: 				preferred_zone, classzone_idx, migratetype);
: 	}
: 
: 	trace_mm_page_alloc(page, order, mask, migratetype);

> The page allocator slowpath is always called from the fastpath if the 
> first allocation didn't succeed, so we don't know from which we allocated 
> the page at this tracepoint.

True, but the idea is that when we call trace_mm_page_alloc(), local
var `mask' holds the gfp_t which was used in the most recent allocation
attempt.

> I'm afraid the original code before either of these patches was more 
> correct.  The use of memalloc_noio_flags() for "subsequent allocation 
> attempts" doesn't really matter since neither __GFP_FS nor __GFP_IO 
> matters for fastpath allocation (we aren't reclaiming).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
