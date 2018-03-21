Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34C146B0009
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 00:21:36 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id i9-v6so2232558oth.3
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 21:21:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c48-v6sor1441269otj.42.2018.03.20.21.21.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 21:21:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180321015944.GB28705@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com> <20180320085452.24641-3-aaron.lu@intel.com>
 <CAF7GXvovKsabDw88icK5c5xBqg6g0TomQdspfi4ikjtbg=XzGQ@mail.gmail.com> <20180321015944.GB28705@intel.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Tue, 20 Mar 2018 21:21:33 -0700
Message-ID: <CAF7GXvrQG0+iPu8h13coo2QW7WxNhjHA1JAaOYoEBBB9-obRSQ@mail.gmail.com>
Subject: Re: [RFC PATCH v2 2/4] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Content-Type: multipart/alternative; boundary="000000000000c4dba90567e4864b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

--000000000000c4dba90567e4864b
Content-Type: text/plain; charset="UTF-8"

2018-03-20 18:59 GMT-07:00 Aaron Lu <aaron.lu@intel.com>:

> On Tue, Mar 20, 2018 at 03:58:51PM -0700, Figo.zhang wrote:
> > 2018-03-20 1:54 GMT-07:00 Aaron Lu <aaron.lu@intel.com>:
> >
> > > Running will-it-scale/page_fault1 process mode workload on a 2 sockets
> > > Intel Skylake server showed severe lock contention of zone->lock, as
> > > high as about 80%(42% on allocation path and 35% on free path) CPU
> > > cycles are burnt spinning. With perf, the most time consuming part
> inside
> > > that lock on free path is cache missing on page structures, mostly on
> > > the to-be-freed page's buddy due to merging.
> > >
> > > One way to avoid this overhead is not do any merging at all for order-0
> > > pages. With this approach, the lock contention for zone->lock on free
> > > path dropped to 1.1% but allocation side still has as high as 42% lock
> > > contention. In the meantime, the dropped lock contention on free side
> > > doesn't translate to performance increase, instead, it's consumed by
> > > increased lock contention of the per node lru_lock(rose from 5% to 37%)
> > > and the final performance slightly dropped about 1%.
> > >
> > > Though performance dropped a little, it almost eliminated zone lock
> > > contention on free path and it is the foundation for the next patch
> > > that eliminates zone lock contention for allocation path.
> > >
> > > A new document file called "struct_page_filed" is added to explain
> > > the newly reused field in "struct page".
> > >
> > > Suggested-by: Dave Hansen <dave.hansen@intel.com>
> > > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> > > ---
> > >  Documentation/vm/struct_page_field |  5 +++
> > >  include/linux/mm_types.h           |  1 +
> > >  mm/compaction.c                    | 13 +++++-
> > >  mm/internal.h                      | 27 ++++++++++++
> > >  mm/page_alloc.c                    | 89 ++++++++++++++++++++++++++++++
> > > +++-----
> > >  5 files changed, 122 insertions(+), 13 deletions(-)
> > >  create mode 100644 Documentation/vm/struct_page_field
> > >
> > > diff --git a/Documentation/vm/struct_page_field
> b/Documentation/vm/struct_
> > > page_field
> > > new file mode 100644
> > > index 000000000000..1ab6c19ccc7a
> > > --- /dev/null
> > > +++ b/Documentation/vm/struct_page_field
> > > @@ -0,0 +1,5 @@
> > > +buddy_merge_skipped:
> > > +Used to indicate this page skipped merging when added to buddy. This
> > > +field only makes sense if the page is in Buddy and is order zero.
> > > +It's a bug if any higher order pages in Buddy has this field set.
> > > +Shares space with index.
> > > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > > index fd1af6b9591d..7edc4e102a8e 100644
> > > --- a/include/linux/mm_types.h
> > > +++ b/include/linux/mm_types.h
> > > @@ -91,6 +91,7 @@ struct page {
> > >                 pgoff_t index;          /* Our offset within mapping.
> */
> > >                 void *freelist;         /* sl[aou]b first free object
> */
> > >                 /* page_deferred_list().prev    -- second tail page */
> > > +               bool buddy_merge_skipped; /* skipped merging when
> added to
> > > buddy */
> > >         };
> > >
> > >         union {
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index 2c8999d027ab..fb9031fdca41 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -776,8 +776,19 @@ isolate_migratepages_block(struct compact_control
> > > *cc, unsigned long low_pfn,
> > >                  * potential isolation targets.
> > >                  */
> > >                 if (PageBuddy(page)) {
> > > -                       unsigned long freepage_order =
> > > page_order_unsafe(page);
> > > +                       unsigned long freepage_order;
> > >
> > > +                       /*
> > > +                        * If this is a merge_skipped page, do merge
> now
> > > +                        * since high-order pages are needed. zone lock
> > > +                        * isn't taken for the merge_skipped check so
> the
> > > +                        * check could be wrong but the worst case is
> we
> > > +                        * lose a merge opportunity.
> > > +                        */
> > > +                       if (page_merge_was_skipped(page))
> > > +                               try_to_merge_page(page);
> > > +
> > > +                       freepage_order = page_order_unsafe(page);
> > >                         /*
> > >                          * Without lock, we cannot be sure that what we
> > > got is
> > >                          * a valid page order. Consider only values in
> the
> > >
> >
> > when the system memory is very very low and try a lot of failures and
> then
>
> >If the system memory is very very low, it doesn't appear there is a need
> >to do compaction since compaction needs to have enough order 0 pages to
> >make a high order one.
>
>
suppose that in free_one_page() will try to merge to high order anytime ,
but now in your patch,
those merge has postponed when system in low memory status, it is very easy
let system trigger
low memory state and get poor performance.

--000000000000c4dba90567e4864b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">2018-03-20 18:59 GMT-07:00 Aaron Lu <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:aaron.lu@intel.com" target=3D"_blank">aaron.lu@intel.com</a>&gt;</span=
>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5=
">On Tue, Mar 20, 2018 at 03:58:51PM -0700, Figo.zhang wrote:<br>
&gt; 2018-03-20 1:54 GMT-07:00 Aaron Lu &lt;<a href=3D"mailto:aaron.lu@inte=
l.com">aaron.lu@intel.com</a>&gt;:<br>
&gt;<br>
&gt; &gt; Running will-it-scale/page_fault1 process mode workload on a 2 so=
ckets<br>
&gt; &gt; Intel Skylake server showed severe lock contention of zone-&gt;lo=
ck, as<br>
&gt; &gt; high as about 80%(42% on allocation path and 35% on free path) CP=
U<br>
&gt; &gt; cycles are burnt spinning. With perf, the most time consuming par=
t inside<br>
&gt; &gt; that lock on free path is cache missing on page structures, mostl=
y on<br>
&gt; &gt; the to-be-freed page&#39;s buddy due to merging.<br>
&gt; &gt;<br>
&gt; &gt; One way to avoid this overhead is not do any merging at all for o=
rder-0<br>
&gt; &gt; pages. With this approach, the lock contention for zone-&gt;lock =
on free<br>
&gt; &gt; path dropped to 1.1% but allocation side still has as high as 42%=
 lock<br>
&gt; &gt; contention. In the meantime, the dropped lock contention on free =
side<br>
&gt; &gt; doesn&#39;t translate to performance increase, instead, it&#39;s =
consumed by<br>
&gt; &gt; increased lock contention of the per node lru_lock(rose from 5% t=
o 37%)<br>
&gt; &gt; and the final performance slightly dropped about 1%.<br>
&gt; &gt;<br>
&gt; &gt; Though performance dropped a little, it almost eliminated zone lo=
ck<br>
&gt; &gt; contention on free path and it is the foundation for the next pat=
ch<br>
&gt; &gt; that eliminates zone lock contention for allocation path.<br>
&gt; &gt;<br>
&gt; &gt; A new document file called &quot;struct_page_filed&quot; is added=
 to explain<br>
&gt; &gt; the newly reused field in &quot;struct page&quot;.<br>
&gt; &gt;<br>
&gt; &gt; Suggested-by: Dave Hansen &lt;<a href=3D"mailto:dave.hansen@intel=
.com">dave.hansen@intel.com</a>&gt;<br>
&gt; &gt; Signed-off-by: Aaron Lu &lt;<a href=3D"mailto:aaron.lu@intel.com"=
>aaron.lu@intel.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt;=C2=A0 Documentation/vm/struct_page_<wbr>field |=C2=A0 5 +++<br>
&gt; &gt;=C2=A0 include/linux/mm_types.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0|=C2=A0 1 +<br>
&gt; &gt;=C2=A0 mm/compaction.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 | 13 +++++-<br>
&gt; &gt;=C2=A0 mm/internal.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | 27 ++++++++++++<br>
&gt; &gt;=C2=A0 mm/page_alloc.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 | 89 ++++++++++++++++++++++++++++++<br>
&gt; &gt; +++-----<br>
&gt; &gt;=C2=A0 5 files changed, 122 insertions(+), 13 deletions(-)<br>
&gt; &gt;=C2=A0 create mode 100644 Documentation/vm/struct_page_<wbr>field<=
br>
&gt; &gt;<br>
&gt; &gt; diff --git a/Documentation/vm/struct_<wbr>page_field b/Documentat=
ion/vm/struct_<br>
&gt; &gt; page_field<br>
&gt; &gt; new file mode 100644<br>
&gt; &gt; index 000000000000..1ab6c19ccc7a<br>
&gt; &gt; --- /dev/null<br>
&gt; &gt; +++ b/Documentation/vm/struct_<wbr>page_field<br>
&gt; &gt; @@ -0,0 +1,5 @@<br>
&gt; &gt; +buddy_merge_skipped:<br>
&gt; &gt; +Used to indicate this page skipped merging when added to buddy. =
This<br>
&gt; &gt; +field only makes sense if the page is in Buddy and is order zero=
.<br>
&gt; &gt; +It&#39;s a bug if any higher order pages in Buddy has this field=
 set.<br>
&gt; &gt; +Shares space with index.<br>
&gt; &gt; diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h<=
br>
&gt; &gt; index fd1af6b9591d..7edc4e102a8e 100644<br>
&gt; &gt; --- a/include/linux/mm_types.h<br>
&gt; &gt; +++ b/include/linux/mm_types.h<br>
&gt; &gt; @@ -91,6 +91,7 @@ struct page {<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgof=
f_t index;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Our offset within mapping. =
*/<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0void=
 *freelist;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* sl[aou]b first free object =
*/<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* p=
age_deferred_list().prev=C2=A0 =C2=A0 -- second tail page */<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0bool budd=
y_merge_skipped; /* skipped merging when added to<br>
&gt; &gt; buddy */<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0};<br>
&gt; &gt;<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0union {<br>
&gt; &gt; diff --git a/mm/compaction.c b/mm/compaction.c<br>
&gt; &gt; index 2c8999d027ab..fb9031fdca41 100644<br>
&gt; &gt; --- a/mm/compaction.c<br>
&gt; &gt; +++ b/mm/compaction.c<br>
&gt; &gt; @@ -776,8 +776,19 @@ isolate_migratepages_block(<wbr>struct compa=
ct_control<br>
&gt; &gt; *cc, unsigned long low_pfn,<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * p=
otential isolation targets.<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<=
br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (=
PageBuddy(page)) {<br>
&gt; &gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0unsigned long freepage_order =3D<br>
&gt; &gt; page_order_unsafe(page);<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0unsigned long freepage_order;<br>
&gt; &gt;<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0/*<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 * If this is a merge_skipped page, do merge now<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 * since high-order pages are needed. zone lock<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 * isn&#39;t taken for the merge_skipped check so the<b=
r>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 * check could be wrong but the worst case is we<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 * lose a merge opportunity.<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 */<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0if (page_merge_was_skipped(page))<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0try_to_merge_page(page);<br=
>
&gt; &gt; +<br>
&gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0freepage_order =3D page_order_unsafe(page);<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 * Without lock, we cannot be sure that what we<br>
&gt; &gt; got is<br>
&gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 * a valid page order. Consider only values in the<=
br>
&gt; &gt;<br>
&gt;<br>
&gt; when the system memory is very very low and try a lot of failures and =
then<br>
<br>
</div></div>&gt;If the system memory is very very low, it doesn&#39;t appea=
r there is a need<br>&gt;to do compaction since compaction needs to have en=
ough order 0 pages to<br>&gt;make a high order one.<br>
<span class=3D""><br></span></blockquote><div>=C2=A0</div><div>suppose that=
 in free_one_page() will try to merge to high order anytime , but now in yo=
ur patch,=C2=A0</div><div>those merge has postponed when system in low memo=
ry status, it is very easy let system trigger=C2=A0</div><div>low memory st=
ate and get poor performance.</div></div><br></div></div>

--000000000000c4dba90567e4864b--
