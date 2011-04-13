Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 63B43900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:47:04 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p3DIl04L032337
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:47:00 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by hpaq6.eem.corp.google.com with ESMTP id p3DIi2U6012155
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:46:59 -0700
Received: by qwb7 with SMTP id 7so592426qwb.12
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:46:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110413173036.0756873d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-4-git-send-email-yinghan@google.com>
	<20110413173036.0756873d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Apr 2011 11:46:58 -0700
Message-ID: <BANLkTi=CxcVBKrSSbUGsGGsy-5jwgZnc+g@mail.gmail.com>
Subject: Re: [PATCH V3 3/7] New APIs to adjust per-memcg wmarks
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee0ce764104a0d13b96
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--000e0cd68ee0ce764104a0d13b96
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 13, 2011 at 1:30 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 13 Apr 2011 00:03:03 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > Add wmark_ratio and reclaim_wmarks APIs per-memcg. The wmark_ratio
> > adjusts the internal low/high wmark calculation and the reclaim_wmarks
> > exports the current value of watermarks. By default, the wmark_ratio is
> > set to 0 and the watermarks are equal to the hard_limit(limit_in_bytes).
> >
> > $ cat /dev/cgroup/A/memory.wmark_ratio
> > 0
> >
> > $ cat /dev/cgroup/A/memory.limit_in_bytes
> > 524288000
> >
> > $ echo 80 >/dev/cgroup/A/memory.wmark_ratio
> >
> > $ cat /dev/cgroup/A/memory.reclaim_wmarks
> > low_wmark 393216000
> > high_wmark 419430400
> >
>
> I think havig _ratio_ will finally leads us to a tragedy as dirty_ratio,
> a complicated interface.
>
> For memcg, I'd like to have only _bytes.
>
> And, as I wrote in previous mail, how about setting _distance_ ?
>
>   memory.low_wmark_distance_in_bytes .... # hard_limit - low_wmark.
>   memory.high_wmark_distance_in_bytes ... # hard_limit - high_wmark.
>
> Anwyay, percent is too big unit.
>

Replied to your comment on "Add per memcg reclaim watermarks". I have no
problem to make the
wmark individual tunable. One thing to confirm before making the change is
to have:


memory.low_wmark_distance_in_bytes .... # min(hard_limit, soft_limit) -
> low_wmark
> memory.high_wmark_distance_in_bytes ... # min(hard_limit, soft_limit) -
> high_wmark.
>

And also, some checks on soft_limit are needed. If "soft_limit" == 0, use
hard_limit

--Ying


> Thanks,
> -Kame
>
>
> > changelog v3..v2:
> > 1. replace the "min_free_kbytes" api with "wmark_ratio". This is part of
> > feedbacks
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  mm/memcontrol.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 49 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 664cdc5..36ae377 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3983,6 +3983,31 @@ static int mem_cgroup_swappiness_write(struct
> cgroup *cgrp, struct cftype *cft,
> >       return 0;
> >  }
> >
> > +static u64 mem_cgroup_wmark_ratio_read(struct cgroup *cgrp, struct
> cftype *cft)
> > +{
> > +     struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +     return get_wmark_ratio(memcg);
> > +}
> > +
> > +static int mem_cgroup_wmark_ratio_write(struct cgroup *cgrp, struct
> cftype *cfg,
> > +                                  u64 val)
> > +{
> > +     struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +     struct mem_cgroup *parent;
> > +
> > +     if (cgrp->parent == NULL)
> > +             return -EINVAL;
> > +
> > +     parent = mem_cgroup_from_cont(cgrp->parent);
> > +
> > +     memcg->wmark_ratio = val;
> > +
> > +     setup_per_memcg_wmarks(memcg);
> > +     return 0;
> > +
> > +}
> > +
> >  static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
> >  {
> >       struct mem_cgroup_threshold_ary *t;
> > @@ -4274,6 +4299,21 @@ static void mem_cgroup_oom_unregister_event(struct
> cgroup *cgrp,
> >       mutex_unlock(&memcg_oom_mutex);
> >  }
> >
> > +static int mem_cgroup_wmark_read(struct cgroup *cgrp,
> > +     struct cftype *cft,  struct cgroup_map_cb *cb)
> > +{
> > +     struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> > +     u64 low_wmark, high_wmark;
> > +
> > +     low_wmark = res_counter_read_u64(&mem->res, RES_LOW_WMARK_LIMIT);
> > +     high_wmark = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
> > +
> > +     cb->fill(cb, "low_wmark", low_wmark);
> > +     cb->fill(cb, "high_wmark", high_wmark);
> > +
> > +     return 0;
> > +}
> > +
> >  static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
> >       struct cftype *cft,  struct cgroup_map_cb *cb)
> >  {
> > @@ -4377,6 +4417,15 @@ static struct cftype mem_cgroup_files[] = {
> >               .unregister_event = mem_cgroup_oom_unregister_event,
> >               .private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
> >       },
> > +     {
> > +             .name = "wmark_ratio",
> > +             .write_u64 = mem_cgroup_wmark_ratio_write,
> > +             .read_u64 = mem_cgroup_wmark_ratio_read,
> > +     },
> > +     {
> > +             .name = "reclaim_wmarks",
> > +             .read_map = mem_cgroup_wmark_read,
> > +     },
> >  };
> >
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
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
> >
>
>

--000e0cd68ee0ce764104a0d13b96
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 13, 2011 at 1:30 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Wed, 13 Apr 2011 00:03:03 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; Add wmark_ratio and reclaim_wmarks APIs per-memcg. The wmark_ratio<br>
&gt; adjusts the internal low/high wmark calculation and the reclaim_wmarks=
<br>
&gt; exports the current value of watermarks. By default, the wmark_ratio i=
s<br>
&gt; set to 0 and the watermarks are equal to the hard_limit(limit_in_bytes=
).<br>
&gt;<br>
&gt; $ cat /dev/cgroup/A/memory.wmark_ratio<br>
&gt; 0<br>
&gt;<br>
&gt; $ cat /dev/cgroup/A/memory.limit_in_bytes<br>
&gt; 524288000<br>
&gt;<br>
&gt; $ echo 80 &gt;/dev/cgroup/A/memory.wmark_ratio<br>
&gt;<br>
&gt; $ cat /dev/cgroup/A/memory.reclaim_wmarks<br>
&gt; low_wmark 393216000<br>
&gt; high_wmark 419430400<br>
&gt;<br>
<br>
</div>I think havig _ratio_ will finally leads us to a tragedy as dirty_rat=
io,<br>
a complicated interface.<br>
<br>
For memcg, I&#39;d like to have only _bytes.<br>
<br>
And, as I wrote in previous mail, how about setting _distance_ ?<br>
<br>
 =A0 memory.low_wmark_distance_in_bytes .... # hard_limit - low_wmark.<br>
 =A0 memory.high_wmark_distance_in_bytes ... # hard_limit - high_wmark.<br>
<br>
Anwyay, percent is too big unit.<br></blockquote><div><br></div><div>Replie=
d to your comment on &quot;Add per memcg reclaim watermarks&quot;. I have n=
o problem to make the</div><div>wmark individual tunable. One thing to conf=
irm before making the change is to have:</div>
<div><br></div><div><br></div><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8">me=
mory.low_wmark_distance_in_bytes .... # min(hard_limit, soft_limit) - low_w=
mark<br>
<meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8">me=
mory.high_wmark_distance_in_bytes ... # min(hard_limit, soft_limit) - high_=
wmark.<br></blockquote><div><br></div><div>And also, some checks on soft_li=
mit are needed. If &quot;soft_limit&quot; =3D=3D 0, use hard_limit</div>
<div><br></div><div>--Ying=A0</div><div>=A0</div><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">
Thanks,<br>
-Kame<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; changelog v3..v2:<br>
&gt; 1. replace the &quot;min_free_kbytes&quot; api with &quot;wmark_ratio&=
quot;. This is part of<br>
&gt; feedbacks<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0 49 ++++++++++++++++++++++++++++++++++++++++++=
+++++++<br>
&gt; =A01 files changed, 49 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 664cdc5..36ae377 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -3983,6 +3983,31 @@ static int mem_cgroup_swappiness_write(struct c=
group *cgrp, struct cftype *cft,<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static u64 mem_cgroup_wmark_ratio_read(struct cgroup *cgrp, struct cf=
type *cft)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);<br>
&gt; +<br>
&gt; + =A0 =A0 return get_wmark_ratio(memcg);<br>
&gt; +}<br>
&gt; +<br>
&gt; +static int mem_cgroup_wmark_ratio_write(struct cgroup *cgrp, struct c=
ftype *cfg,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u=
64 val)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);<br>
&gt; + =A0 =A0 struct mem_cgroup *parent;<br>
&gt; +<br>
&gt; + =A0 =A0 if (cgrp-&gt;parent =3D=3D NULL)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;<br>
&gt; +<br>
&gt; + =A0 =A0 parent =3D mem_cgroup_from_cont(cgrp-&gt;parent);<br>
&gt; +<br>
&gt; + =A0 =A0 memcg-&gt;wmark_ratio =3D val;<br>
&gt; +<br>
&gt; + =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool s=
wap)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_threshold_ary *t;<br>
&gt; @@ -4274,6 +4299,21 @@ static void mem_cgroup_oom_unregister_event(str=
uct cgroup *cgrp,<br>
&gt; =A0 =A0 =A0 mutex_unlock(&amp;memcg_oom_mutex);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static int mem_cgroup_wmark_read(struct cgroup *cgrp,<br>
&gt; + =A0 =A0 struct cftype *cft, =A0struct cgroup_map_cb *cb)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);<br>
&gt; + =A0 =A0 u64 low_wmark, high_wmark;<br>
&gt; +<br>
&gt; + =A0 =A0 low_wmark =3D res_counter_read_u64(&amp;mem-&gt;res, RES_LOW=
_WMARK_LIMIT);<br>
&gt; + =A0 =A0 high_wmark =3D res_counter_read_u64(&amp;mem-&gt;res, RES_HI=
GH_WMARK_LIMIT);<br>
&gt; +<br>
&gt; + =A0 =A0 cb-&gt;fill(cb, &quot;low_wmark&quot;, low_wmark);<br>
&gt; + =A0 =A0 cb-&gt;fill(cb, &quot;high_wmark&quot;, high_wmark);<br>
&gt; +<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_oom_control_read(struct cgroup *cgrp,<br>
&gt; =A0 =A0 =A0 struct cftype *cft, =A0struct cgroup_map_cb *cb)<br>
&gt; =A0{<br>
&gt; @@ -4377,6 +4417,15 @@ static struct cftype mem_cgroup_files[] =3D {<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .unregister_event =3D mem_cgroup_oom_unreg=
ister_event,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .private =3D MEMFILE_PRIVATE(_OOM_TYPE, OO=
M_CONTROL),<br>
&gt; =A0 =A0 =A0 },<br>
&gt; + =A0 =A0 {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;wmark_ratio&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D mem_cgroup_wmark_ratio_write,=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D mem_cgroup_wmark_ratio_read,<b=
r>
&gt; + =A0 =A0 },<br>
&gt; + =A0 =A0 {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;reclaim_wmarks&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_wmark_read,<br>
&gt; + =A0 =A0 },<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
</div></div>&gt; --<br>
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
&gt;<br>
<br>
</blockquote></div><br>

--000e0cd68ee0ce764104a0d13b96--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
