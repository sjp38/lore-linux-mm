Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA4B6B0031
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 05:09:15 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id rd18so5550622iec.10
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:09:15 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id mk5si15799291igb.35.2014.06.09.02.09.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 02:09:14 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id x19so275420ier.16
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:09:14 -0700 (PDT)
Date: Mon, 9 Jun 2014 02:09:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 4/6] mm, compaction: skip buddy pages by their order
 in the migrate scanner
In-Reply-To: <53916BB0.3070001@suse.cz>
Message-ID: <alpine.DEB.2.02.1406090207300.24247@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041656400.22536@chino.kir.corp.google.com> <5390374E.5080708@suse.cz>
 <alpine.DEB.2.02.1406051428360.18119@chino.kir.corp.google.com> <53916BB0.3070001@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Fri, 6 Jun 2014, Vlastimil Babka wrote:

> >> > > diff --git a/mm/internal.h b/mm/internal.h
> >> > > index 1a8a0d4..6aa1f74 100644
> >> > > --- a/mm/internal.h
> >> > > +++ b/mm/internal.h
> >> > > @@ -164,7 +164,8 @@ isolate_migratepages_range(struct zone *zone, struct
> >> > > compact_control *cc,
> >> > >    * general, page_zone(page)->lock must be held by the caller to prevent
> >> > > the
> >> > >    * page from being allocated in parallel and returning garbage as the
> >> > > order.
> >> > >    * If a caller does not hold page_zone(page)->lock, it must guarantee
> >> > > that the
> >> > > - * page cannot be allocated or merged in parallel.
> >> > > + * page cannot be allocated or merged in parallel. Alternatively, it must
> >> > > + * handle invalid values gracefully, and use page_order_unsafe() below.
> >> > >    */
> >> > >   static inline unsigned long page_order(struct page *page)
> >> > >   {
> >> > > @@ -172,6 +173,23 @@ static inline unsigned long page_order(struct page
> >> > > *page)
> >> > >   	return page_private(page);
> >> > >   }
> >> > > 
> >> > > +/*
> >> > > + * Like page_order(), but for callers who cannot afford to hold the zone
> >> > > lock,
> >> > > + * and handle invalid values gracefully. ACCESS_ONCE is used so that if
> >> > > the
> >> > > + * caller assigns the result into a local variable and e.g. tests it for
> >> > > valid
> >> > > + * range  before using, the compiler cannot decide to remove the variable
> >> > > and
> >> > > + * inline the function multiple times, potentially observing different
> >> > > values
> >> > > + * in the tests and the actual use of the result.
> >> > > + */
> >> > > +static inline unsigned long page_order_unsafe(struct page *page)
> >> > > +{
> >> > > +	/*
> >> > > +	 * PageBuddy() should be checked by the caller to minimize race
> >> > > window,
> >> > > +	 * and invalid values must be handled gracefully.
> >> > > +	 */
> >> > > +	return ACCESS_ONCE(page_private(page));
> >> > > +}
> >> > > +
> >> > >   /* mm/util.c */
> >> > >   void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
> >> > >   		struct vm_area_struct *prev, struct rb_node *rb_parent);
> >> > 
> >> > I don't like this change at all, I don't think we should have header
> >> > functions that imply the context in which the function will be called.  I
> >> > think it would make much more sense to just do
> >> > ACCESS_ONCE(page_order(page)) in the migration scanner with a comment.
> >> 
> >> But that won't compile. It would have to be converted to a #define, unless
> >> there's some trick I don't know. Sure I would hope this could be done cleaner
> >> somehow.
> >> 
> > 
> > Sorry, I meant ACCESS_ONCE(page_private(page)) in the migration scanner 
> 
> Hm but that's breaking the abstraction of page_order(). I don't know if it's
> worse to create a new variant of page_order() or to do this. BTW, seems like
> next_active_pageblock() in memory-hotplug.c should use this variant too.
> 

The compiler seems free to disregard the access of a volatile object above 
because the return value of the inline function is unsigned long.  What's 
the difference between unsigned long order = page_order_unsafe(page) and
unsigned long order = (unsigned long)ACCESS_ONCE(page_private(page)) and 
the compiler being able to reaccess page_private() because the result is 
no longer volatile qualified?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
