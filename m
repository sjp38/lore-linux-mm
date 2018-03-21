Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC5B6B0009
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 21:58:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g66so1934604pfj.11
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:58:41 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e87si2257647pfj.381.2018.03.20.18.58.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 18:58:40 -0700 (PDT)
Date: Wed, 21 Mar 2018 09:59:45 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20180321015944.GB28705@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
 <20180320085452.24641-3-aaron.lu@intel.com>
 <CAF7GXvovKsabDw88icK5c5xBqg6g0TomQdspfi4ikjtbg=XzGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAF7GXvovKsabDw88icK5c5xBqg6g0TomQdspfi4ikjtbg=XzGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

On Tue, Mar 20, 2018 at 03:58:51PM -0700, Figo.zhang wrote:
> 2018-03-20 1:54 GMT-07:00 Aaron Lu <aaron.lu@intel.com>:
> 
> > Running will-it-scale/page_fault1 process mode workload on a 2 sockets
> > Intel Skylake server showed severe lock contention of zone->lock, as
> > high as about 80%(42% on allocation path and 35% on free path) CPU
> > cycles are burnt spinning. With perf, the most time consuming part inside
> > that lock on free path is cache missing on page structures, mostly on
> > the to-be-freed page's buddy due to merging.
> >
> > One way to avoid this overhead is not do any merging at all for order-0
> > pages. With this approach, the lock contention for zone->lock on free
> > path dropped to 1.1% but allocation side still has as high as 42% lock
> > contention. In the meantime, the dropped lock contention on free side
> > doesn't translate to performance increase, instead, it's consumed by
> > increased lock contention of the per node lru_lock(rose from 5% to 37%)
> > and the final performance slightly dropped about 1%.
> >
> > Though performance dropped a little, it almost eliminated zone lock
> > contention on free path and it is the foundation for the next patch
> > that eliminates zone lock contention for allocation path.
> >
> > A new document file called "struct_page_filed" is added to explain
> > the newly reused field in "struct page".
> >
> > Suggested-by: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> > ---
> >  Documentation/vm/struct_page_field |  5 +++
> >  include/linux/mm_types.h           |  1 +
> >  mm/compaction.c                    | 13 +++++-
> >  mm/internal.h                      | 27 ++++++++++++
> >  mm/page_alloc.c                    | 89 ++++++++++++++++++++++++++++++
> > +++-----
> >  5 files changed, 122 insertions(+), 13 deletions(-)
> >  create mode 100644 Documentation/vm/struct_page_field
> >
> > diff --git a/Documentation/vm/struct_page_field b/Documentation/vm/struct_
> > page_field
> > new file mode 100644
> > index 000000000000..1ab6c19ccc7a
> > --- /dev/null
> > +++ b/Documentation/vm/struct_page_field
> > @@ -0,0 +1,5 @@
> > +buddy_merge_skipped:
> > +Used to indicate this page skipped merging when added to buddy. This
> > +field only makes sense if the page is in Buddy and is order zero.
> > +It's a bug if any higher order pages in Buddy has this field set.
> > +Shares space with index.
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index fd1af6b9591d..7edc4e102a8e 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -91,6 +91,7 @@ struct page {
> >                 pgoff_t index;          /* Our offset within mapping. */
> >                 void *freelist;         /* sl[aou]b first free object */
> >                 /* page_deferred_list().prev    -- second tail page */
> > +               bool buddy_merge_skipped; /* skipped merging when added to
> > buddy */
> >         };
> >
> >         union {
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 2c8999d027ab..fb9031fdca41 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -776,8 +776,19 @@ isolate_migratepages_block(struct compact_control
> > *cc, unsigned long low_pfn,
> >                  * potential isolation targets.
> >                  */
> >                 if (PageBuddy(page)) {
> > -                       unsigned long freepage_order =
> > page_order_unsafe(page);
> > +                       unsigned long freepage_order;
> >
> > +                       /*
> > +                        * If this is a merge_skipped page, do merge now
> > +                        * since high-order pages are needed. zone lock
> > +                        * isn't taken for the merge_skipped check so the
> > +                        * check could be wrong but the worst case is we
> > +                        * lose a merge opportunity.
> > +                        */
> > +                       if (page_merge_was_skipped(page))
> > +                               try_to_merge_page(page);
> > +
> > +                       freepage_order = page_order_unsafe(page);
> >                         /*
> >                          * Without lock, we cannot be sure that what we
> > got is
> >                          * a valid page order. Consider only values in the
> >
> 
> when the system memory is very very low and try a lot of failures and then

If the system memory is very very low, it doesn't appear there is a need
to do compaction since compaction needs to have enough order 0 pages to
make a high order one.

> go into
> __alloc_pages_direct_compact() to has a opportunity to do your
> try_to_merge_page(), is it the best timing for here to
> do order-0 migration?

try_to_merge_page(), as I added in this patch, doesn't do any page
migration but merging. It will not cause page migration.
