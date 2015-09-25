Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id BC55A6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:50:31 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so18199314wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:50:31 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id qc8si4679035wjc.78.2015.09.25.05.50.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 25 Sep 2015 05:50:30 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id DFDB5C0043
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:50:29 +0000 (UTC)
Date: Fri, 25 Sep 2015 13:50:28 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/10] mm, page_alloc: Use masks and shifts when
 converting GFP flags to migrate types
Message-ID: <20150925125028.GF3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-5-git-send-email-mgorman@techsingularity.net>
 <20150924203445.GH3009@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150924203445.GH3009@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 24, 2015 at 04:34:45PM -0400, Johannes Weiner wrote:
> On Mon, Sep 21, 2015 at 11:52:36AM +0100, Mel Gorman wrote:
> > @@ -14,7 +14,7 @@ struct vm_area_struct;
> >  #define ___GFP_HIGHMEM		0x02u
> >  #define ___GFP_DMA32		0x04u
> >  #define ___GFP_MOVABLE		0x08u
> > -#define ___GFP_WAIT		0x10u
> > +#define ___GFP_RECLAIMABLE	0x10u
> >  #define ___GFP_HIGH		0x20u
> >  #define ___GFP_IO		0x40u
> >  #define ___GFP_FS		0x80u
> > @@ -29,7 +29,7 @@ struct vm_area_struct;
> >  #define ___GFP_NOMEMALLOC	0x10000u
> >  #define ___GFP_HARDWALL		0x20000u
> >  #define ___GFP_THISNODE		0x40000u
> > -#define ___GFP_RECLAIMABLE	0x80000u
> > +#define ___GFP_WAIT		0x80000u
> >  #define ___GFP_NOACCOUNT	0x100000u
> >  #define ___GFP_NOTRACK		0x200000u
> >  #define ___GFP_NO_KSWAPD	0x400000u
> > @@ -126,6 +126,7 @@ struct vm_area_struct;
> >  
> >  /* This mask makes up all the page movable related flags */
> >  #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
> > +#define GFP_MOVABLE_SHIFT 3
> 
> This connects the power-of-two gfp bits to the linear migrate type
> enum, so shifting back and forth between them works only with up to
> two items. A hypothetical ___GFP_FOOABLE would translate to 4, not
> 3. I'm not expecting new migratetypes to show up anytime soon, but
> this implication does not make the code exactly robust and obvious.
> 

In the event __GFP_FOOABLE is added then it would need to be reverted.
Adding new migrate types has other consequences as it increases the number
of free lists in struct zone and depending on the type then new per-cpu
lists and the the fallbacks have to be updated. It's fairly obvious if a
new migratetype is added that cares.

> > @@ -152,14 +153,15 @@ struct vm_area_struct;
> >  /* Convert GFP flags to their corresponding migrate type */
> >  static inline int gfpflags_to_migratetype(const gfp_t gfp_flags)
> >  {
> > -	WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> > +	VM_WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> > +	BUILD_BUG_ON((1UL << GFP_MOVABLE_SHIFT) != ___GFP_MOVABLE);
> > +	BUILD_BUG_ON((___GFP_MOVABLE >> GFP_MOVABLE_SHIFT) != MIGRATE_MOVABLE);
> >  
> >  	if (unlikely(page_group_by_mobility_disabled))
> >  		return MIGRATE_UNMOVABLE;
> >  
> >  	/* Group based on mobility */
> > -	return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
> > -		((gfp_flags & __GFP_RECLAIMABLE) != 0);
> > +	return (gfp_flags & GFP_MOVABLE_MASK) >> GFP_MOVABLE_SHIFT;
> 
> I'm not sure the simplification of this line is worth the fragile
> dependency between those two tables.

The BUILD_BUG_ON is there to blow up immediately if the dependency is
broken. Sure, it's complexity but it's well contained in a single
place. Do you want to insist the patch is dropped in case someone
decides to add a new migrate type that has per-cpu lists?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
