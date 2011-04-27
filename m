Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0700B9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 20:03:31 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p3R03Sth014507
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:03:28 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by wpaz17.hot.corp.google.com with ESMTP id p3R02xhh015806
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:03:27 -0700
Received: by qyk2 with SMTP id 2so725337qyk.16
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 17:03:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426095524.F348.A69D9226@jp.fujitsu.com>
References: <1303752134-4856-2-git-send-email-yinghan@google.com>
	<20110426094356.F341.A69D9226@jp.fujitsu.com>
	<20110426095524.F348.A69D9226@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 17:03:26 -0700
Message-ID: <BANLkTik9mVUeS0UV1h9FyEWZTnNs0mxnfg@mail.gmail.com>
Subject: Re: [PATCH V2 1/2] change the shrink_slab by passing shrink_control
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefda85f0d104a1db2b3c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016e64aefda85f0d104a1db2b3c
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 25, 2011 at 5:53 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > > This patch consolidates existing parameters to shrink_slab() to
> > > a new shrink_control struct. This is needed later to pass the same
> > > struct to shrinkers.
> > >
> > > changelog v2..v1:
> > > 1. define a new struct shrink_control and only pass some values down
> > > to the shrinker instead of the scan_control.
> > >
> > > Signed-off-by: Ying Han <yinghan@google.com>
> > > ---
> > >  fs/drop_caches.c   |    6 +++++-
> > >  include/linux/mm.h |   13 +++++++++++--
> > >  mm/vmscan.c        |   30 ++++++++++++++++++++++--------
> > >  3 files changed, 38 insertions(+), 11 deletions(-)
> >
> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> Sigh. No. This patch seems premature.
>
>
> > This patch consolidates existing parameters to shrink_slab() to
> > a new shrink_control struct. This is needed later to pass the same
> > struct to shrinkers.
> >
> > changelog v2..v1:
> > 1. define a new struct shrink_control and only pass some values down
> > to the shrinker instead of the scan_control.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  fs/drop_caches.c   |    6 +++++-
> >  include/linux/mm.h |   13 +++++++++++--
> >  mm/vmscan.c        |   30 ++++++++++++++++++++++--------
> >  3 files changed, 38 insertions(+), 11 deletions(-)
> >
> > diff --git a/fs/drop_caches.c b/fs/drop_caches.c
> > index 816f88e..c671290 100644
> > --- a/fs/drop_caches.c
> > +++ b/fs/drop_caches.c
> > @@ -36,9 +36,13 @@ static void drop_pagecache_sb(struct super_block *sb,
> void *unused)
> >  static void drop_slab(void)
> >  {
> >       int nr_objects;
> > +     struct shrink_control shrink = {
> > +             .gfp_mask = GFP_KERNEL,
> > +             .nr_scanned = 1000,
> > +     };
> >
> >       do {
> > -             nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
> > +             nr_objects = shrink_slab(&shrink, 1000);
> >       } while (nr_objects > 10);
> >  }
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0716517..7a2f657 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1131,6 +1131,15 @@ static inline void sync_mm_rss(struct task_struct
> *task, struct mm_struct *mm)
> >  #endif
> >
> >  /*
> > + * This struct is used to pass information from page reclaim to the
> shrinkers.
> > + * We consolidate the values for easier extention later.
> > + */
> > +struct shrink_control {
> > +     unsigned long nr_scanned;
>
> nr_to_scan is better. sc.nr_scanned mean how much _finished_ scan pages.
>

Ok, the name is changed.


> eg.
>        scan_control {
>        (snip)
>                /* Number of pages freed so far during a call to
> shrink_zones() */
>                unsigned long nr_reclaimed;
>
>                /* How many pages shrink_list() should reclaim */
>                unsigned long nr_to_reclaim;
>
>
>
> > +     gfp_t gfp_mask;
> > +};
> > +
> > +/*
> >   * A callback you can register to apply pressure to ageable caches.
> >   *
> >   * 'shrink' is passed a count 'nr_to_scan' and a 'gfpmask'.  It should
> > @@ -1601,8 +1610,8 @@ int in_gate_area_no_task(unsigned long addr);
> >
> >  int drop_caches_sysctl_handler(struct ctl_table *, int,
> >                                       void __user *, size_t *, loff_t *);
> > -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> > -                     unsigned long lru_pages);
> > +unsigned long shrink_slab(struct shrink_control *shrink,
> > +                             unsigned long lru_pages);
> >
> >  #ifndef CONFIG_MMU
> >  #define randomize_va_space 0
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 060e4c1..40edf73 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -220,11 +220,13 @@ EXPORT_SYMBOL(unregister_shrinker);
> >   *
> >   * Returns the number of slab objects which we shrunk.
> >   */
> > -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> > -                     unsigned long lru_pages)
> > +unsigned long shrink_slab(struct shrink_control *shrink,
> > +                       unsigned long lru_pages)
> >  {
> >       struct shrinker *shrinker;
> >       unsigned long ret = 0;
> > +     unsigned long scanned = shrink->nr_scanned;
> > +     gfp_t gfp_mask = shrink->gfp_mask;
> >
> >       if (scanned == 0)
> >               scanned = SWAP_CLUSTER_MAX;
> > @@ -2032,7 +2034,8 @@ static bool all_unreclaimable(struct zonelist
> *zonelist,
> >   *           else, the number of pages reclaimed
> >   */
> >  static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> > -                                     struct scan_control *sc)
> > +                                     struct scan_control *sc,
> > +                                     struct shrink_control *shrink)
> >  {
>
> Worthless argument addition. gfpmask can be getting from scan_control and
> .nr_scanned is calculated in this function.
>

changed.

>
>
>
> >       int priority;
> >       unsigned long total_scanned = 0;
> > @@ -2066,7 +2069,8 @@ static unsigned long do_try_to_free_pages(struct
> zonelist *zonelist,
> >                               lru_pages += zone_reclaimable_pages(zone);
> >                       }
> >
> > -                     shrink_slab(sc->nr_scanned, sc->gfp_mask,
> lru_pages);
> > +                     shrink->nr_scanned = sc->nr_scanned;
> > +                     shrink_slab(shrink, lru_pages);
> >                       if (reclaim_state) {
> >                               sc->nr_reclaimed +=
> reclaim_state->reclaimed_slab;
> >                               reclaim_state->reclaimed_slab = 0;
> > @@ -2130,12 +2134,15 @@ unsigned long try_to_free_pages(struct zonelist
> *zonelist, int order,
> >               .mem_cgroup = NULL,
> >               .nodemask = nodemask,
> >       };
> > +     struct shrink_control shrink = {
> > +             .gfp_mask = sc.gfp_mask,
> > +     };
> >
> >       trace_mm_vmscan_direct_reclaim_begin(order,
> >                               sc.may_writepage,
> >                               gfp_mask);
> >
> > -     nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> > +     nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
> >
> >       trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
> >
> > @@ -2333,6 +2340,9 @@ static unsigned long balance_pgdat(pg_data_t
> *pgdat, int order,
> >               .order = order,
> >               .mem_cgroup = NULL,
> >       };
> > +     struct shrink_control shrink = {
> > +             .gfp_mask = sc.gfp_mask,
> > +     };
> >  loop_again:
> >       total_scanned = 0;
> >       sc.nr_reclaimed = 0;
> > @@ -2432,8 +2442,8 @@ loop_again:
> >                                       end_zone, 0))
> >                               shrink_zone(priority, zone, &sc);
> >                       reclaim_state->reclaimed_slab = 0;
> > -                     nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
> > -                                             lru_pages);
> > +                     shrink.nr_scanned = sc.nr_scanned;
> > +                     nr_slab = shrink_slab(&shrink, lru_pages);
> >                       sc.nr_reclaimed += reclaim_state->reclaimed_slab;
> >                       total_scanned += sc.nr_scanned;
> >
> > @@ -2969,6 +2979,9 @@ static int __zone_reclaim(struct zone *zone, gfp_t
> gfp_mask, unsigned int order)
> >               .swappiness = vm_swappiness,
> >               .order = order,
> >       };
> > +     struct shrink_control shrink = {
> > +             .gfp_mask = sc.gfp_mask,
> > +     };
> >       unsigned long nr_slab_pages0, nr_slab_pages1;
> >
> >       cond_resched();
> > @@ -2995,6 +3008,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t
> gfp_mask, unsigned int order)
> >       }
> >
> >       nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
> > +     shrink.nr_scanned = sc.nr_scanned;
> >       if (nr_slab_pages0 > zone->min_slab_pages) {
>
> strange. this assignment should be move into this if brace.
> changed.
>
> >               /*
> >                * shrink_slab() does not currently allow us to determine
> how
> > @@ -3010,7 +3024,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t
> gfp_mask, unsigned int order)
> >                       unsigned long lru_pages =
> zone_reclaimable_pages(zone);
> >
> >                       /* No reclaimable slab or very low memory pressure
> */
> > -                     if (!shrink_slab(sc.nr_scanned, gfp_mask,
> lru_pages))
> > +                     if (!shrink_slab(&shrink, lru_pages))
> >                               break;
> >
> >                       /* Freed enough memory */
> > --
> > 1.7.3.1
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>
>

--0016e64aefda85f0d104a1db2b3c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 25, 2011 at 5:53 PM, KOSAKI =
Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujitsu=
.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">
<div><div></div><div class=3D"h5">&gt; &gt; This patch consolidates existin=
g parameters to shrink_slab() to<br>
&gt; &gt; a new shrink_control struct. This is needed later to pass the sam=
e<br>
&gt; &gt; struct to shrinkers.<br>
&gt; &gt;<br>
&gt; &gt; changelog v2..v1:<br>
&gt; &gt; 1. define a new struct shrink_control and only pass some values d=
own<br>
&gt; &gt; to the shrinker instead of the scan_control.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com"=
>yinghan@google.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; =A0fs/drop_caches.c =A0 | =A0 =A06 +++++-<br>
&gt; &gt; =A0include/linux/mm.h | =A0 13 +++++++++++--<br>
&gt; &gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0| =A0 30 ++++++++++++++++++++++----=
----<br>
&gt; &gt; =A03 files changed, 38 insertions(+), 11 deletions(-)<br>
&gt;<br>
&gt; Reviewed-by: KOSAKI Motohiro &lt;<a href=3D"mailto:kosaki.motohiro@jp.=
fujitsu.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;<br>
<br>
</div></div>Sigh. No. This patch seems premature.<br>
<div class=3D"im"><br>
<br>
&gt; This patch consolidates existing parameters to shrink_slab() to<br>
&gt; a new shrink_control struct. This is needed later to pass the same<br>
&gt; struct to shrinkers.<br>
&gt;<br>
&gt; changelog v2..v1:<br>
&gt; 1. define a new struct shrink_control and only pass some values down<b=
r>
&gt; to the shrinker instead of the scan_control.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0fs/drop_caches.c =A0 | =A0 =A06 +++++-<br>
&gt; =A0include/linux/mm.h | =A0 13 +++++++++++--<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0| =A0 30 ++++++++++++++++++++++--------<=
br>
&gt; =A03 files changed, 38 insertions(+), 11 deletions(-)<br>
&gt;<br>
</div>&gt; diff --git a/fs/drop_caches.c b/fs/drop_caches.c<br>
&gt; index 816f88e..c671290 100644<br>
&gt; --- a/fs/drop_caches.c<br>
&gt; +++ b/fs/drop_caches.c<br>
&gt; @@ -36,9 +36,13 @@ static void drop_pagecache_sb(struct super_block *s=
b, void *unused)<br>
&gt; =A0static void drop_slab(void)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 int nr_objects;<br>
&gt; + =A0 =A0 struct shrink_control shrink =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .nr_scanned =3D 1000,<br>
&gt; + =A0 =A0 };<br>
&gt;<br>
&gt; =A0 =A0 =A0 do {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 nr_objects =3D shrink_slab(1000, GFP_KERNEL,=
 1000);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 nr_objects =3D shrink_slab(&amp;shrink, 1000=
);<br>
&gt; =A0 =A0 =A0 } while (nr_objects &gt; 10);<br>
&gt; =A0}<br>
&gt;<br>
&gt; diff --git a/include/linux/mm.h b/include/linux/mm.h<br>
&gt; index 0716517..7a2f657 100644<br>
&gt; --- a/include/linux/mm.h<br>
&gt; +++ b/include/linux/mm.h<br>
&gt; @@ -1131,6 +1131,15 @@ static inline void sync_mm_rss(struct task_stru=
ct *task, struct mm_struct *mm)<br>
&gt; =A0#endif<br>
&gt;<br>
&gt; =A0/*<br>
&gt; + * This struct is used to pass information from page reclaim to the s=
hrinkers.<br>
&gt; + * We consolidate the values for easier extention later.<br>
&gt; + */<br>
&gt; +struct shrink_control {<br>
&gt; + =A0 =A0 unsigned long nr_scanned;<br>
<br>
nr_to_scan is better. sc.nr_scanned mean how much _finished_ scan pages.<br=
></blockquote><div><br></div><div>Ok, the name is changed.</div><div>=A0</d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex;">

eg.<br>
 =A0 =A0 =A0 =A0scan_control {<br>
 =A0 =A0 =A0 =A0(snip)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Number of pages freed so far during a ca=
ll to shrink_zones() */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_reclaimed;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* How many pages shrink_list() should recl=
aim */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_to_reclaim;<br>
<br>
<br>
<br>
&gt; + =A0 =A0 gfp_t gfp_mask;<br>
&gt; +};<br>
&gt; +<br>
&gt; +/*<br>
&gt; =A0 * A callback you can register to apply pressure to ageable caches.=
<br>
&gt; =A0 *<br>
&gt; =A0 * &#39;shrink&#39; is passed a count &#39;nr_to_scan&#39; and a &#=
39;gfpmask&#39;. =A0It should<br>
&gt; @@ -1601,8 +1610,8 @@ int in_gate_area_no_task(unsigned long addr);<br=
>
&gt;<br>
&gt; =A0int drop_caches_sysctl_handler(struct ctl_table *, int,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 void __user *, size_t *, loff_t *);<br>
&gt; -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages);<br=
>
&gt; +unsigned long shrink_slab(struct shrink_control *shrink,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lon=
g lru_pages);<br>
&gt;<br>
&gt; =A0#ifndef CONFIG_MMU<br>
&gt; =A0#define randomize_va_space 0<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 060e4c1..40edf73 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -220,11 +220,13 @@ EXPORT_SYMBOL(unregister_shrinker);<br>
&gt; =A0 *<br>
&gt; =A0 * Returns the number of slab objects which we shrunk.<br>
&gt; =A0 */<br>
&gt; -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages)<br>
&gt; +unsigned long shrink_slab(struct shrink_control *shrink,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages)=
<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct shrinker *shrinker;<br>
&gt; =A0 =A0 =A0 unsigned long ret =3D 0;<br>
&gt; + =A0 =A0 unsigned long scanned =3D shrink-&gt;nr_scanned;<br>
&gt; + =A0 =A0 gfp_t gfp_mask =3D shrink-&gt;gfp_mask;<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (scanned =3D=3D 0)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 scanned =3D SWAP_CLUSTER_MAX;<br>
&gt; @@ -2032,7 +2034,8 @@ static bool all_unreclaimable(struct zonelist *z=
onelist,<br>
&gt; =A0 * =A0 =A0 =A0 =A0 =A0 else, the number of pages reclaimed<br>
&gt; =A0 */<br>
&gt; =A0static unsigned long do_try_to_free_pages(struct zonelist *zonelist=
,<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct shrink_control *shrink)<br>
&gt; =A0{<br>
<br>
Worthless argument addition. gfpmask can be getting from scan_control and<b=
r>
.nr_scanned is calculated in this function.<br></blockquote><div><br></div>=
<div>changed.=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
<br>
<br>
&gt; =A0 =A0 =A0 int priority;<br>
&gt; =A0 =A0 =A0 unsigned long total_scanned =3D 0;<br>
&gt; @@ -2066,7 +2069,8 @@ static unsigned long do_try_to_free_pages(struct=
 zonelist *zonelist,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru_pages =
+=3D zone_reclaimable_pages(zone);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_slab(sc-&gt;nr_scanne=
d, sc-&gt;gfp_mask, lru_pages);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink-&gt;nr_scanned =3D sc=
-&gt;nr_scanned;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_slab(shrink, lru_page=
s);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (reclaim_state) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_=
reclaimed +=3D reclaim_state-&gt;reclaimed_slab;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_st=
ate-&gt;reclaimed_slab =3D 0;<br>
&gt; @@ -2130,12 +2134,15 @@ unsigned long try_to_free_pages(struct zonelis=
t *zonelist, int order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D NULL,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nodemask =3D nodemask,<br>
&gt; =A0 =A0 =A0 };<br>
&gt; + =A0 =A0 struct shrink_control shrink =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D sc.gfp_mask,<br>
&gt; + =A0 =A0 };<br>
&gt;<br>
&gt; =A0 =A0 =A0 trace_mm_vmscan_direct_reclaim_begin(order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.may_wri=
tepage,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_mask);=
<br>
&gt;<br>
&gt; - =A0 =A0 nr_reclaimed =3D do_try_to_free_pages(zonelist, &amp;sc);<br=
>
&gt; + =A0 =A0 nr_reclaimed =3D do_try_to_free_pages(zonelist, &amp;sc, &am=
p;shrink);<br>
&gt;<br>
&gt; =A0 =A0 =A0 trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);<br>
&gt;<br>
&gt; @@ -2333,6 +2340,9 @@ static unsigned long balance_pgdat(pg_data_t *pg=
dat, int order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D NULL,<br>
&gt; =A0 =A0 =A0 };<br>
&gt; + =A0 =A0 struct shrink_control shrink =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D sc.gfp_mask,<br>
&gt; + =A0 =A0 };<br>
&gt; =A0loop_again:<br>
&gt; =A0 =A0 =A0 total_scanned =3D 0;<br>
&gt; =A0 =A0 =A0 sc.nr_reclaimed =3D 0;<br>
&gt; @@ -2432,8 +2442,8 @@ loop_again:<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 end_zone, 0))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zon=
e(priority, zone, &amp;sc);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 reclaim_state-&gt;reclaime=
d_slab =3D 0;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_slab =3D shrink_slab(sc.n=
r_scanned, GFP_KERNEL,<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 lru_pages);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink.nr_scanned =3D sc.nr_=
scanned;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_slab =3D shrink_slab(&amp=
;shrink, lru_pages);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.nr_reclaimed +=3D recla=
im_state-&gt;reclaimed_slab;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_s=
canned;<br>
&gt;<br>
&gt; @@ -2969,6 +2979,9 @@ static int __zone_reclaim(struct zone *zone, gfp=
_t gfp_mask, unsigned int order)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,<br>
&gt; =A0 =A0 =A0 };<br>
&gt; + =A0 =A0 struct shrink_control shrink =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D sc.gfp_mask,<br>
&gt; + =A0 =A0 };<br>
&gt; =A0 =A0 =A0 unsigned long nr_slab_pages0, nr_slab_pages1;<br>
&gt;<br>
&gt; =A0 =A0 =A0 cond_resched();<br>
&gt; @@ -2995,6 +3008,7 @@ static int __zone_reclaim(struct zone *zone, gfp=
_t gfp_mask, unsigned int order)<br>
&gt; =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 nr_slab_pages0 =3D zone_page_state(zone, NR_SLAB_RECLAIMAB=
LE);<br>
&gt; + =A0 =A0 shrink.nr_scanned =3D sc.nr_scanned;<br>
&gt; =A0 =A0 =A0 if (nr_slab_pages0 &gt; zone-&gt;min_slab_pages) {<br>
<br>
strange. this assignment should be move into this if brace.<br>
changed.<br>
<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* shrink_slab() does not currently allo=
w us to determine how<br>
&gt; @@ -3010,7 +3024,7 @@ static int __zone_reclaim(struct zone *zone, gfp=
_t gfp_mask, unsigned int order)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages =
=3D zone_reclaimable_pages(zone);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* No reclaimable slab or =
very low memory pressure */<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!shrink_slab(sc.nr_scann=
ed, gfp_mask, lru_pages))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!shrink_slab(&amp;shrink=
, lru_pages))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Freed enough memory */<=
br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Fight unfair telecom internet charges in Canada: sign <a href=3D"http:=
//stopthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
<br>
<br>
</blockquote></div><br>

--0016e64aefda85f0d104a1db2b3c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
