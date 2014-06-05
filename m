Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1D96B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 17:30:55 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id x19so1494785ier.41
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 14:30:54 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id c20si14670531icg.43.2014.06.05.14.30.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 14:30:54 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so1520868iec.33
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 14:30:53 -0700 (PDT)
Date: Thu, 5 Jun 2014 14:30:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 4/6] mm, compaction: skip buddy pages by their order
 in the migrate scanner
In-Reply-To: <5390374E.5080708@suse.cz>
Message-ID: <alpine.DEB.2.02.1406051428360.18119@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041656400.22536@chino.kir.corp.google.com>
 <5390374E.5080708@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Thu, 5 Jun 2014, Vlastimil Babka wrote:

> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index ae7db5f..3dce5a7 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -640,11 +640,18 @@ isolate_migratepages_range(struct zone *zone, struct
> > > compact_control *cc,
> > >   		}
> > > 
> > >   		/*
> > > -		 * Skip if free. page_order cannot be used without zone->lock
> > > -		 * as nothing prevents parallel allocations or buddy merging.
> > > +		 * Skip if free. We read page order here without zone lock
> > > +		 * which is generally unsafe, but the race window is small and
> > > +		 * the worst thing that can happen is that we skip some
> > > +		 * potential isolation targets.
> > 
> > Should we only be doing the low_pfn adjustment based on the order for
> > MIGRATE_ASYNC?  It seems like sync compaction, including compaction that
> > is triggered from the command line, would prefer to scan over the
> > following pages.
> 
> I thought even sync compaction would benefit from the skipped iterations. I'd
> say the probability of this race is smaller than probability of somebody
> allocating what compaction just freed.
> 

Ok.

> > > diff --git a/mm/internal.h b/mm/internal.h
> > > index 1a8a0d4..6aa1f74 100644
> > > --- a/mm/internal.h
> > > +++ b/mm/internal.h
> > > @@ -164,7 +164,8 @@ isolate_migratepages_range(struct zone *zone, struct
> > > compact_control *cc,
> > >    * general, page_zone(page)->lock must be held by the caller to prevent
> > > the
> > >    * page from being allocated in parallel and returning garbage as the
> > > order.
> > >    * If a caller does not hold page_zone(page)->lock, it must guarantee
> > > that the
> > > - * page cannot be allocated or merged in parallel.
> > > + * page cannot be allocated or merged in parallel. Alternatively, it must
> > > + * handle invalid values gracefully, and use page_order_unsafe() below.
> > >    */
> > >   static inline unsigned long page_order(struct page *page)
> > >   {
> > > @@ -172,6 +173,23 @@ static inline unsigned long page_order(struct page
> > > *page)
> > >   	return page_private(page);
> > >   }
> > > 
> > > +/*
> > > + * Like page_order(), but for callers who cannot afford to hold the zone
> > > lock,
> > > + * and handle invalid values gracefully. ACCESS_ONCE is used so that if
> > > the
> > > + * caller assigns the result into a local variable and e.g. tests it for
> > > valid
> > > + * range  before using, the compiler cannot decide to remove the variable
> > > and
> > > + * inline the function multiple times, potentially observing different
> > > values
> > > + * in the tests and the actual use of the result.
> > > + */
> > > +static inline unsigned long page_order_unsafe(struct page *page)
> > > +{
> > > +	/*
> > > +	 * PageBuddy() should be checked by the caller to minimize race
> > > window,
> > > +	 * and invalid values must be handled gracefully.
> > > +	 */
> > > +	return ACCESS_ONCE(page_private(page));
> > > +}
> > > +
> > >   /* mm/util.c */
> > >   void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
> > >   		struct vm_area_struct *prev, struct rb_node *rb_parent);
> > 
> > I don't like this change at all, I don't think we should have header
> > functions that imply the context in which the function will be called.  I
> > think it would make much more sense to just do
> > ACCESS_ONCE(page_order(page)) in the migration scanner with a comment.
> 
> But that won't compile. It would have to be converted to a #define, unless
> there's some trick I don't know. Sure I would hope this could be done cleaner
> somehow.
> 

Sorry, I meant ACCESS_ONCE(page_private(page)) in the migration scanner 
with a comment about it being racy.  It also helps to understand why 
you're testing for order < MAX_ORDER before skipping low_pfn there which 
is a little subtle right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
