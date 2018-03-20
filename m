Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 622476B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 18:58:53 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 15-v6so1693970oij.6
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 15:58:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b16-v6sor1266701otb.229.2018.03.20.15.58.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 15:58:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180320085452.24641-3-aaron.lu@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com> <20180320085452.24641-3-aaron.lu@intel.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Tue, 20 Mar 2018 15:58:51 -0700
Message-ID: <CAF7GXvovKsabDw88icK5c5xBqg6g0TomQdspfi4ikjtbg=XzGQ@mail.gmail.com>
Subject: Re: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Content-Type: multipart/alternative; boundary="000000000000a33f880567e00458"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

--000000000000a33f880567e00458
Content-Type: text/plain; charset="UTF-8"

2018-03-20 1:54 GMT-07:00 Aaron Lu <aaron.lu@intel.com>:

> Running will-it-scale/page_fault1 process mode workload on a 2 sockets
> Intel Skylake server showed severe lock contention of zone->lock, as
> high as about 80%(42% on allocation path and 35% on free path) CPU
> cycles are burnt spinning. With perf, the most time consuming part inside
> that lock on free path is cache missing on page structures, mostly on
> the to-be-freed page's buddy due to merging.
>
> One way to avoid this overhead is not do any merging at all for order-0
> pages. With this approach, the lock contention for zone->lock on free
> path dropped to 1.1% but allocation side still has as high as 42% lock
> contention. In the meantime, the dropped lock contention on free side
> doesn't translate to performance increase, instead, it's consumed by
> increased lock contention of the per node lru_lock(rose from 5% to 37%)
> and the final performance slightly dropped about 1%.
>
> Though performance dropped a little, it almost eliminated zone lock
> contention on free path and it is the foundation for the next patch
> that eliminates zone lock contention for allocation path.
>
> A new document file called "struct_page_filed" is added to explain
> the newly reused field in "struct page".
>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> ---
>  Documentation/vm/struct_page_field |  5 +++
>  include/linux/mm_types.h           |  1 +
>  mm/compaction.c                    | 13 +++++-
>  mm/internal.h                      | 27 ++++++++++++
>  mm/page_alloc.c                    | 89 ++++++++++++++++++++++++++++++
> +++-----
>  5 files changed, 122 insertions(+), 13 deletions(-)
>  create mode 100644 Documentation/vm/struct_page_field
>
> diff --git a/Documentation/vm/struct_page_field b/Documentation/vm/struct_
> page_field
> new file mode 100644
> index 000000000000..1ab6c19ccc7a
> --- /dev/null
> +++ b/Documentation/vm/struct_page_field
> @@ -0,0 +1,5 @@
> +buddy_merge_skipped:
> +Used to indicate this page skipped merging when added to buddy. This
> +field only makes sense if the page is in Buddy and is order zero.
> +It's a bug if any higher order pages in Buddy has this field set.
> +Shares space with index.
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index fd1af6b9591d..7edc4e102a8e 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -91,6 +91,7 @@ struct page {
>                 pgoff_t index;          /* Our offset within mapping. */
>                 void *freelist;         /* sl[aou]b first free object */
>                 /* page_deferred_list().prev    -- second tail page */
> +               bool buddy_merge_skipped; /* skipped merging when added to
> buddy */
>         };
>
>         union {
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 2c8999d027ab..fb9031fdca41 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -776,8 +776,19 @@ isolate_migratepages_block(struct compact_control
> *cc, unsigned long low_pfn,
>                  * potential isolation targets.
>                  */
>                 if (PageBuddy(page)) {
> -                       unsigned long freepage_order =
> page_order_unsafe(page);
> +                       unsigned long freepage_order;
>
> +                       /*
> +                        * If this is a merge_skipped page, do merge now
> +                        * since high-order pages are needed. zone lock
> +                        * isn't taken for the merge_skipped check so the
> +                        * check could be wrong but the worst case is we
> +                        * lose a merge opportunity.
> +                        */
> +                       if (page_merge_was_skipped(page))
> +                               try_to_merge_page(page);
> +
> +                       freepage_order = page_order_unsafe(page);
>                         /*
>                          * Without lock, we cannot be sure that what we
> got is
>                          * a valid page order. Consider only values in the
>

when the system memory is very very low and try a lot of failures and then
go into
__alloc_pages_direct_compact() to has a opportunity to do your
try_to_merge_page(), is it the best timing for here to
do order-0 migration?

diff --git a/mm/internal.h b/mm/internal.h
> index e6bd35182dae..2bfbaae2d835 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -538,4 +538,31 @@ static inline bool is_migrate_highatomic_page(struct
> page *page)
>  }
>
>  void setup_zone_pageset(struct zone *zone);
> +
> +static inline bool page_merge_was_skipped(struct page *page)
> +{
> +       return page->buddy_merge_skipped;
> +}
> +
> +void try_to_merge_page(struct page *page);
> +
> +#ifdef CONFIG_COMPACTION
> +static inline bool can_skip_merge(struct zone *zone, int order)
> +{
> +       /* Compaction has failed in this zone, we shouldn't skip merging */
> +       if (zone->compact_considered)
> +               return false;
> +
> +       /* Only consider no_merge for order 0 pages */
> +       if (order)
> +               return false;
> +
> +       return true;
> +}
> +#else /* CONFIG_COMPACTION */
> +static inline bool can_skip_merge(struct zone *zone, int order)
> +{
> +       return false;
> +}
> +#endif  /* CONFIG_COMPACTION */
>  #endif /* __MM_INTERNAL_H */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3cdf1e10d412..eb78014dfbde 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -730,6 +730,16 @@ static inline void clear_page_guard(struct zone
> *zone, struct page *page,
>                                 unsigned int order, int migratetype) {}
>  #endif
>
> +static inline void set_page_merge_skipped(struct page *page)
> +{
> +       page->buddy_merge_skipped = true;
> +}
> +
> +static inline void clear_page_merge_skipped(struct page *page)
> +{
> +       page->buddy_merge_skipped = false;
> +}
> +
>  static inline void set_page_order(struct page *page, unsigned int order)
>  {
>         set_page_private(page, order);
> @@ -739,6 +749,13 @@ static inline void set_page_order(struct page *page,
> unsigned int order)
>  static inline void add_to_buddy_common(struct page *page, struct zone
> *zone,
>                                         unsigned int order, int mt)
>  {
> +       /*
> +        * Always clear buddy_merge_skipped when added to buddy because
> +        * buddy_merge_skipped shares space with index and index could
> +        * be used as migratetype for PCP pages.
> +        */
> +       clear_page_merge_skipped(page);
> +
>         set_page_order(page, order);
>         zone->free_area[order].nr_free++;
>  }
> @@ -769,6 +786,7 @@ static inline void remove_from_buddy(struct page
> *page, struct zone *zone,
>         list_del(&page->lru);
>         zone->free_area[order].nr_free--;
>         rmv_page_order(page);
> +       clear_page_merge_skipped(page);
>  }
>
>  /*
> @@ -839,7 +857,7 @@ static inline int page_is_buddy(struct page *page,
> struct page *buddy,
>   * -- nyc
>   */
>
> -static inline void __free_one_page(struct page *page,
> +static inline void do_merge(struct page *page,
>                 unsigned long pfn,
>                 struct zone *zone, unsigned int order,
>                 int migratetype)
> @@ -851,16 +869,6 @@ static inline void __free_one_page(struct page *page,
>
>         max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
>
> -       VM_BUG_ON(!zone_is_initialized(zone));
> -       VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
> -
> -       VM_BUG_ON(migratetype == -1);
> -       if (likely(!is_migrate_isolate(migratetype)))
> -               __mod_zone_freepage_state(zone, 1 << order, migratetype);
> -
> -       VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
> -       VM_BUG_ON_PAGE(bad_range(zone, page), page);
> -
>  continue_merging:
>         while (order < max_order - 1) {
>                 buddy_pfn = __find_buddy_pfn(pfn, order);
> @@ -933,6 +941,61 @@ static inline void __free_one_page(struct page *page,
>         add_to_buddy_head(page, zone, order, migratetype);
>  }
>
> +void try_to_merge_page(struct page *page)
> +{
> +       unsigned long pfn, buddy_pfn, flags;
> +       struct page *buddy;
> +       struct zone *zone;
> +
> +       /*
> +        * No need to do merging if buddy is not free.
> +        * zone lock isn't taken so this could be wrong but worst case
> +        * is we lose a merge opportunity.
> +        */
> +       pfn = page_to_pfn(page);
> +       buddy_pfn = __find_buddy_pfn(pfn, 0);
> +       buddy = page + (buddy_pfn - pfn);
> +       if (!PageBuddy(buddy))
> +               return;
> +
> +       zone = page_zone(page);
> +       spin_lock_irqsave(&zone->lock, flags);
> +       /* Verify again after taking the lock */
> +       if (likely(PageBuddy(page) && page_merge_was_skipped(page) &&
> +                  PageBuddy(buddy))) {
> +               int mt = get_pageblock_migratetype(page);
> +
> +               remove_from_buddy(page, zone, 0);
> +               do_merge(page, pfn, zone, 0, mt);
> +       }
> +       spin_unlock_irqrestore(&zone->lock, flags);
> +}
> +
> +static inline void __free_one_page(struct page *page,
> +               unsigned long pfn,
> +               struct zone *zone, unsigned int order,
> +               int migratetype)
> +{
> +       VM_BUG_ON(!zone_is_initialized(zone));
> +       VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
> +
> +       VM_BUG_ON(migratetype == -1);
> +       if (likely(!is_migrate_isolate(migratetype)))
> +               __mod_zone_freepage_state(zone, 1 << order, migratetype);
> +
> +       VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
> +       VM_BUG_ON_PAGE(bad_range(zone, page), page);
> +
> +       if (can_skip_merge(zone, order)) {
> +               add_to_buddy_head(page, zone, 0, migratetype);
> +               set_page_merge_skipped(page);
> +               return;
> +       }
> +
> +       do_merge(page, pfn, zone, order, migratetype);
> +}
> +
> +
>  /*
>   * A bad page could be due to a number of fields. Instead of multiple
> branches,
>   * try and check multiple fields with one check. The caller must do a
> detailed
> @@ -1183,8 +1246,10 @@ static void free_pcppages_bulk(struct zone *zone,
> int count,
>                          * can be offset by reduced memory latency later.
> To
>                          * avoid excessive prefetching due to large count,
> only
>                          * prefetch buddy for the last pcp->batch nr of
> pages.
> +                        *
> +                        * If merge can be skipped, no need to prefetch
> buddy.
>                          */
> -                       if (count > pcp->batch)
> +                       if (can_skip_merge(zone, 0) || count > pcp->batch)
>                                 continue;
>                         pfn = page_to_pfn(page);
>                         buddy_pfn = __find_buddy_pfn(pfn, 0);
> --
> 2.14.3
>
>

--000000000000a33f880567e00458
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2018-03-20 1:54 GMT-07:00 Aaron Lu <span dir=3D"ltr">&lt;<a href=3D"mai=
lto:aaron.lu@intel.com" target=3D"_blank">aaron.lu@intel.com</a>&gt;</span>=
:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bo=
rder-left:1px solid rgb(204,204,204);padding-left:1ex">Running will-it-scal=
e/page_fault1 process mode workload on a 2 sockets<br>
Intel Skylake server showed severe lock contention of zone-&gt;lock, as<br>
high as about 80%(42% on allocation path and 35% on free path) CPU<br>
cycles are burnt spinning. With perf, the most time consuming part inside<b=
r>
that lock on free path is cache missing on page structures, mostly on<br>
the to-be-freed page&#39;s buddy due to merging.<br>
<br>
One way to avoid this overhead is not do any merging at all for order-0<br>
pages. With this approach, the lock contention for zone-&gt;lock on free<br=
>
path dropped to 1.1% but allocation side still has as high as 42% lock<br>
contention. In the meantime, the dropped lock contention on free side<br>
doesn&#39;t translate to performance increase, instead, it&#39;s consumed b=
y<br>
increased lock contention of the per node lru_lock(rose from 5% to 37%)<br>
and the final performance slightly dropped about 1%.<br>
<br>
Though performance dropped a little, it almost eliminated zone lock<br>
contention on free path and it is the foundation for the next patch<br>
that eliminates zone lock contention for allocation path.<br>
<br>
A new document file called &quot;struct_page_filed&quot; is added to explai=
n<br>
the newly reused field in &quot;struct page&quot;.<br>
<br>
Suggested-by: Dave Hansen &lt;<a href=3D"mailto:dave.hansen@intel.com">dave=
.hansen@intel.com</a>&gt;<br>
Signed-off-by: Aaron Lu &lt;<a href=3D"mailto:aaron.lu@intel.com">aaron.lu@=
intel.com</a>&gt;<br>
---<br>
=C2=A0Documentation/vm/struct_page_<wbr>field |=C2=A0 5 +++<br>
=C2=A0include/linux/mm_types.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=
=A0 1 +<br>
=C2=A0mm/compaction.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | 13 +++++-<br>
=C2=A0mm/internal.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 | 27 ++++++++++++<br>
=C2=A0mm/page_alloc.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 | 89 ++++++++++++++++++++++++++++++<wbr>+++-----<br>
=C2=A05 files changed, 122 insertions(+), 13 deletions(-)<br>
=C2=A0create mode 100644 Documentation/vm/struct_page_<wbr>field<br>
<br>
diff --git a/Documentation/vm/struct_<wbr>page_field b/Documentation/vm/str=
uct_<wbr>page_field<br>
new file mode 100644<br>
index 000000000000..1ab6c19ccc7a<br>
--- /dev/null<br>
+++ b/Documentation/vm/struct_<wbr>page_field<br>
@@ -0,0 +1,5 @@<br>
+buddy_merge_skipped:<br>
+Used to indicate this page skipped merging when added to buddy. This<br>
+field only makes sense if the page is in Buddy and is order zero.<br>
+It&#39;s a bug if any higher order pages in Buddy has this field set.<br>
+Shares space with index.<br>
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h<br>
index fd1af6b9591d..7edc4e102a8e 100644<br>
--- a/include/linux/mm_types.h<br>
+++ b/include/linux/mm_types.h<br>
@@ -91,6 +91,7 @@ struct page {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgoff_t index;=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Our offset within mapping. */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void *freelist;=C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* sl[aou]b first free object */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* page_deferred_li=
st().prev=C2=A0 =C2=A0 -- second tail page */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bool buddy_merge_sk=
ipped; /* skipped merging when added to buddy */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 };<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 union {<br>
diff --git a/mm/compaction.c b/mm/compaction.c<br>
index 2c8999d027ab..fb9031fdca41 100644<br>
--- a/mm/compaction.c<br>
+++ b/mm/compaction.c<br>
@@ -776,8 +776,19 @@ isolate_migratepages_block(<wbr>struct compact_control=
 *cc, unsigned long low_pfn,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* potential i=
solation targets.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageBuddy(page)=
) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0unsigned long freepage_order =3D page_order_unsafe(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0unsigned long freepage_order;<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * If this is a merge_skipped page, do merge now<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * since high-order pages are needed. zone lock<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * isn&#39;t taken for the merge_skipped check so the<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * check could be wrong but the worst case is we<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * lose a merge opportunity.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (page_merge_was_skipped(page))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0try_to_merge_page(page);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0freepage_order =3D page_order_unsafe(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 /*<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* Without lock, we cannot be sure that what we got is<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* a valid page order. Consider only values in the<br></blo=
ckquote><div><br></div><div>when the system memory is very very low and try=
 a lot of failures and then go into=C2=A0</div><div>__alloc_pages_direct_co=
mpact() to has a opportunity to do your try_to_merge_page(), is it the best=
 timing for here to=C2=A0</div><div>do order-0 migration?</div><div><br></d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;bord=
er-left:1px solid rgb(204,204,204);padding-left:1ex">
diff --git a/mm/internal.h b/mm/internal.h<br>
index e6bd35182dae..2bfbaae2d835 100644<br>
--- a/mm/internal.h<br>
+++ b/mm/internal.h<br>
@@ -538,4 +538,31 @@ static inline bool is_migrate_highatomic_page(<wbr>str=
uct page *page)<br>
=C2=A0}<br>
<br>
=C2=A0void setup_zone_pageset(struct zone *zone);<br>
+<br>
+static inline bool page_merge_was_skipped(struct page *page)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return page-&gt;buddy_merge_skipped;<br>
+}<br>
+<br>
+void try_to_merge_page(struct page *page);<br>
+<br>
+#ifdef CONFIG_COMPACTION<br>
+static inline bool can_skip_merge(struct zone *zone, int order)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* Compaction has failed in this zone, we shoul=
dn&#39;t skip merging */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (zone-&gt;compact_considered)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* Only consider no_merge for order 0 pages */<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (order)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return true;<br>
+}<br>
+#else /* CONFIG_COMPACTION */<br>
+static inline bool can_skip_merge(struct zone *zone, int order)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return false;<br>
+}<br>
+#endif=C2=A0 /* CONFIG_COMPACTION */<br>
=C2=A0#endif /* __MM_INTERNAL_H */<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index 3cdf1e10d412..eb78014dfbde 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -730,6 +730,16 @@ static inline void clear_page_guard(struct zone *zone,=
 struct page *page,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int order, int migratetype)=
 {}<br>
=C2=A0#endif<br>
<br>
+static inline void set_page_merge_skipped(struct page *page)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0page-&gt;buddy_merge_skipped =3D true;<br>
+}<br>
+<br>
+static inline void clear_page_merge_skipped(<wbr>struct page *page)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0page-&gt;buddy_merge_skipped =3D false;<br>
+}<br>
+<br>
=C2=A0static inline void set_page_order(struct page *page, unsigned int ord=
er)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 set_page_private(page, order);<br>
@@ -739,6 +749,13 @@ static inline void set_page_order(struct page *page, u=
nsigned int order)<br>
=C2=A0static inline void add_to_buddy_common(struct page *page, struct zone=
 *zone,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned=
 int order, int mt)<br>
=C2=A0{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Always clear buddy_merge_skipped when added =
to buddy because<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * buddy_merge_skipped shares space with index =
and index could<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * be used as migratetype for PCP pages.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0clear_page_merge_skipped(page)<wbr>;<br>
+<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 set_page_order(page, order);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 zone-&gt;free_area[order].nr_<wbr>free++;<br>
=C2=A0}<br>
@@ -769,6 +786,7 @@ static inline void remove_from_buddy(struct page *page,=
 struct zone *zone,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&amp;page-&gt;lru);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 zone-&gt;free_area[order].nr_<wbr>free--;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 rmv_page_order(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0clear_page_merge_skipped(page)<wbr>;<br>
=C2=A0}<br>
<br>
=C2=A0/*<br>
@@ -839,7 +857,7 @@ static inline int page_is_buddy(struct page *page, stru=
ct page *buddy,<br>
=C2=A0 * -- nyc<br>
=C2=A0 */<br>
<br>
-static inline void __free_one_page(struct page *page,<br>
+static inline void do_merge(struct page *page,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long pfn,<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone, =
unsigned int order,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int migratetype)<br=
>
@@ -851,16 +869,6 @@ static inline void __free_one_page(struct page *page,<=
br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 max_order =3D min_t(unsigned int, MAX_ORDER, pa=
geblock_order + 1);<br>
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(!zone_is_<wbr>initialized(zone));<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON_PAGE(page-&gt;flags &amp; PAGE_FLAGS_=
CHECK_AT_PREP, page);<br>
-<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(migratetype =3D=3D -1);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(!is_migrate_isolate(<wbr>migratetype=
)))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_freepage=
_state(<wbr>zone, 1 &lt;&lt; order, migratetype);<br>
-<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON_PAGE(pfn &amp; ((1 &lt;&lt; order) - =
1), page);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON_PAGE(bad_range(zone, page), page);<br=
>
-<br>
=C2=A0continue_merging:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 while (order &lt; max_order - 1) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 buddy_pfn =3D __fin=
d_buddy_pfn(pfn, order);<br>
@@ -933,6 +941,61 @@ static inline void __free_one_page(struct page *page,<=
br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 add_to_buddy_head(page, zone, order, migratetyp=
e);<br>
=C2=A0}<br>
<br>
+void try_to_merge_page(struct page *page)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long pfn, buddy_pfn, flags;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *buddy;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * No need to do merging if buddy is not free.<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * zone lock isn&#39;t taken so this could be w=
rong but worst case<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * is we lose a merge opportunity.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0pfn =3D page_to_pfn(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0buddy_pfn =3D __find_buddy_pfn(pfn, 0);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0buddy =3D page + (buddy_pfn - pfn);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageBuddy(buddy))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0zone =3D page_zone(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irqsave(&amp;zone-&gt;lock, flags);<b=
r>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* Verify again after taking the lock */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(PageBuddy(page) &amp;&amp; page_merg=
e_was_skipped(page) &amp;&amp;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 PageBuddy(b=
uddy))) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int mt =3D get_page=
block_migratetype(<wbr>page);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_from_buddy(p=
age, zone, 0);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0do_merge(page, pfn,=
 zone, 0, mt);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqrestore(&amp;zone-&gt;<wbr>lock,=
 flags);<br>
+}<br>
+<br>
+static inline void __free_one_page(struct page *page,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long pfn,<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone, =
unsigned int order,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int migratetype)<br=
>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(!zone_is_<wbr>initialized(zone));<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON_PAGE(page-&gt;flags &amp; PAGE_FLAGS_=
CHECK_AT_PREP, page);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(migratetype =3D=3D -1);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(!is_migrate_isolate(<wbr>migratetype=
)))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__mod_zone_freepage=
_state(<wbr>zone, 1 &lt;&lt; order, migratetype);<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON_PAGE(pfn &amp; ((1 &lt;&lt; order) - =
1), page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON_PAGE(bad_range(zone, page), page);<br=
>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (can_skip_merge(zone, order)) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_buddy_head(p=
age, zone, 0, migratetype);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_page_merge_skip=
ped(page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0do_merge(page, pfn, zone, order, migratetype);<=
br>
+}<br>
+<br>
+<br>
=C2=A0/*<br>
=C2=A0 * A bad page could be due to a number of fields. Instead of multiple=
 branches,<br>
=C2=A0 * try and check multiple fields with one check. The caller must do a=
 detailed<br>
@@ -1183,8 +1246,10 @@ static void free_pcppages_bulk(struct zone *zone, in=
t count,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* can be offset by reduced memory latency later. To<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* avoid excessive prefetching due to large count, only<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0* prefetch buddy for the last pcp-&gt;batch nr of pages.<b=
r>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 *<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * If merge can be skipped, no need to prefetch buddy.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0*/<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (count &gt; pcp-&gt;batch)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (can_skip_merge(zone, 0) || count &gt; pcp-&gt;batch)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 pfn =3D page_to_pfn(page);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 buddy_pfn =3D __find_buddy_pfn(pfn, 0);<br>
<span class=3D"gmail-HOEnZb"><font color=3D"#888888">--<br>
2.14.3<br>
<br>
</font></span></blockquote></div><br></div></div>

--000000000000a33f880567e00458--
