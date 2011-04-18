Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D99FB900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 13:31:55 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p3IHVqv7007550
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:31:53 -0700
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by hpaq13.eem.corp.google.com with ESMTP id p3IHVmX6027873
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:31:51 -0700
Received: by qwa26 with SMTP id 26so3869558qwa.14
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:31:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTincTDa3gvxiMeF6m0eGk=AcGzuQJw@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-8-git-send-email-yinghan@google.com>
	<BANLkTincTDa3gvxiMeF6m0eGk=AcGzuQJw@mail.gmail.com>
Date: Mon, 18 Apr 2011 10:31:47 -0700
Message-ID: <BANLkTikNPGsejSmEO13_BqtQoiOn1ADokw@mail.gmail.com>
Subject: Re: [PATCH V5 07/10] Add per-memcg zone "unreclaimable"
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd08224bb4a04a134c41f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd08224bb4a04a134c41f
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Apr 17, 2011 at 9:27 PM, Minchan Kim <minchan.kim@gmail.com> wrote:

> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> > After reclaiming each node per memcg, it checks mem_cgroup_watermark_ok()
> > and breaks the priority loop if it returns true. The per-memcg zone will
> > be marked as "unreclaimable" if the scanning rate is much greater than
> the
> > reclaiming rate on the per-memcg LRU. The bit is cleared when there is a
> > page charged to the memcg being freed. Kswapd breaks the priority loop if
> > all the zones are marked as "unreclaimable".
> >
> > changelog v5..v4:
> > 1. reduce the frequency of updating mz->unreclaimable bit by using the
> existing
> > memcg batch in task struct.
> > 2. add new function mem_cgroup_mz_clear_unreclaimable() for recoganizing
> zone.
> >
> > changelog v4..v3:
> > 1. split off from the per-memcg background reclaim patch in V3.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/memcontrol.h |   40 ++++++++++++++
> >  include/linux/sched.h      |    1 +
> >  include/linux/swap.h       |    2 +
> >  mm/memcontrol.c            |  130
> +++++++++++++++++++++++++++++++++++++++++++-
> >  mm/vmscan.c                |   19 +++++++
> >  5 files changed, 191 insertions(+), 1 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index d4ff7f2..b18435d 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -155,6 +155,14 @@ static inline void mem_cgroup_dec_page_stat(struct
> page *page,
> >  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int
> order,
> >                                                gfp_t gfp_mask);
> >  u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> > +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int
> zid);
> > +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone
> *zone);
> > +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone
> *zone);
> > +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page
> *page);
> > +void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
> > +                                       struct zone *zone);
> > +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone*
> zone,
> > +                                       unsigned long nr_scanned);
> >
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >  void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
> > @@ -345,6 +353,38 @@ static inline void mem_cgroup_dec_page_stat(struct
> page *page,
> >  {
> >  }
> >
> > +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem,
> int nid,
> > +                                                               int zid)
> > +{
> > +       return false;
> > +}
> > +
> > +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
> > +                                               struct zone *zone)
> > +{
> > +       return false;
> > +}
> > +
> > +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup
> *mem,
> > +                                                       struct zone
> *zone)
> > +{
> > +}
> > +
> > +static inline void mem_cgroup_clear_unreclaimable(struct mem_cgroup
> *mem,
> > +                                                       struct page
> *page)
> > +{
> > +}
> > +
> > +static inline void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup
> *mem,
> > +                                                       struct zone
> *zone);
> > +{
> > +}
> > +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
> > +                                               struct zone *zone,
> > +                                               unsigned long nr_scanned)
> > +{
> > +}
> > +
> >  static inline
> >  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int
> order,
> >                                            gfp_t gfp_mask)
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 98fc7ed..3370c5a 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1526,6 +1526,7 @@ struct task_struct {
> >                struct mem_cgroup *memcg; /* target memcg of uncharge */
> >                unsigned long nr_pages; /* uncharged usage */
> >                unsigned long memsw_nr_pages; /* uncharged mem+swap usage
> */
> > +               struct zone *zone; /* a zone page is last uncharged */
> >        } memcg_batch;
> >  #endif
> >  };
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 17e0511..319b800 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -160,6 +160,8 @@ enum {
> >        SWP_SCANNING    = (1 << 8),     /* refcount in scan_swap_map */
> >  };
> >
> > +#define ZONE_RECLAIMABLE_RATE 6
> > +
>
> You can use ZONE_RECLAIMABLE_RATE in zone_reclaimable, too.
> If you want to separate rate of memcg and global, please clear macro
> name like ZONE_MEMCG_RECLAIMABLE_RATE.
>

For now I will leave them as the same value. Will make the change in the
next post.

Thanks

--Ying

>
> --
> Kind regards,
> Minchan Kim
>

--000e0cdfd08224bb4a04a134c41f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, Apr 17, 2011 at 9:27 PM, Minchan=
 Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan=
.kim@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Sat, Apr 16, 2011 at 8:23 AM, Ying Han=
 &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&gt; wrote=
:<br>
&gt; After reclaiming each node per memcg, it checks mem_cgroup_watermark_o=
k()<br>
&gt; and breaks the priority loop if it returns true. The per-memcg zone wi=
ll<br>
&gt; be marked as &quot;unreclaimable&quot; if the scanning rate is much gr=
eater than the<br>
&gt; reclaiming rate on the per-memcg LRU. The bit is cleared when there is=
 a<br>
&gt; page charged to the memcg being freed. Kswapd breaks the priority loop=
 if<br>
&gt; all the zones are marked as &quot;unreclaimable&quot;.<br>
&gt;<br>
&gt; changelog v5..v4:<br>
&gt; 1. reduce the frequency of updating mz-&gt;unreclaimable bit by using =
the existing<br>
&gt; memcg batch in task struct.<br>
&gt; 2. add new function mem_cgroup_mz_clear_unreclaimable() for recoganizi=
ng zone.<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. split off from the per-memcg background reclaim patch in V3.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h | =A0 40 ++++++++++++++<br>
&gt; =A0include/linux/sched.h =A0 =A0 =A0| =A0 =A01 +<br>
&gt; =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A02 +<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0130 +++++++++++++++++++=
++++++++++++++++++++++++-<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 19 +++++++<br>
&gt; =A05 files changed, 191 insertions(+), 1 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index d4ff7f2..b18435d 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -155,6 +155,14 @@ static inline void mem_cgroup_dec_page_stat(struc=
t page *page,<br>
&gt; =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int =
order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask);<br>
&gt; =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);<br>
&gt; +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int=
 zid);<br>
&gt; +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone =
*zone);<br>
&gt; +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct z=
one *zone);<br>
&gt; +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct pa=
ge *page);<br>
&gt; +void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 struct zone *zone);<br>
&gt; +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone*=
 zone,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 unsigned long nr_scanned);<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE<br>
&gt; =A0void mem_cgroup_split_huge_fixup(struct page *head, struct page *ta=
il);<br>
&gt; @@ -345,6 +353,38 @@ static inline void mem_cgroup_dec_page_stat(struc=
t page *page,<br>
&gt; =A0{<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem=
, int nid,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int zid)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 return false;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem=
,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 return false;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup =
*mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)<br>
&gt; +{<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline void mem_cgroup_clear_unreclaimable(struct mem_cgroup *=
mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *page)<br>
&gt; +{<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline void mem_cgroup_mz_clear_unreclaimable(struct mem_cgrou=
p *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone);<br>
&gt; +{<br>
&gt; +}<br>
&gt; +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem=
,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned)<br>
&gt; +{<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static inline<br>
&gt; =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int =
order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0gfp_t gfp_mask)<br>
&gt; diff --git a/include/linux/sched.h b/include/linux/sched.h<br>
&gt; index 98fc7ed..3370c5a 100644<br>
&gt; --- a/include/linux/sched.h<br>
&gt; +++ b/include/linux/sched.h<br>
&gt; @@ -1526,6 +1526,7 @@ struct task_struct {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup *memcg; /* target mem=
cg of uncharge */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_pages; /* uncharged us=
age */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long memsw_nr_pages; /* unchar=
ged mem+swap usage */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone; /* a zone page is las=
t uncharged */<br>
&gt; =A0 =A0 =A0 =A0} memcg_batch;<br>
&gt; =A0#endif<br>
&gt; =A0};<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index 17e0511..319b800 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -160,6 +160,8 @@ enum {<br>
&gt; =A0 =A0 =A0 =A0SWP_SCANNING =A0 =A0=3D (1 &lt;&lt; 8), =A0 =A0 /* refc=
ount in scan_swap_map */<br>
&gt; =A0};<br>
&gt;<br>
&gt; +#define ZONE_RECLAIMABLE_RATE 6<br>
&gt; +<br>
<br>
</div></div>You can use ZONE_RECLAIMABLE_RATE in zone_reclaimable, too.<br>
If you want to separate rate of memcg and global, please clear macro<br>
name like ZONE_MEMCG_RECLAIMABLE_RATE.<br></blockquote><div><br></div><div>=
For now I will leave them as the same value. Will make the change in the ne=
xt post.</div><div><br></div><div>Thanks</div><div><br></div><div>--Ying=A0=
</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
--<br>
Kind regards,<br>
<font color=3D"#888888">Minchan Kim<br>
</font></blockquote></div><br>

--000e0cdfd08224bb4a04a134c41f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
