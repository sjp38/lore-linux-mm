Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B10E7900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 00:00:45 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3F40g3w027843
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:00:43 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by hpaq1.eem.corp.google.com with ESMTP id p3F40ZPI005922
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:00:41 -0700
Received: by qyl38 with SMTP id 38so1569021qyl.8
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:00:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415092519.a164e8f3.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-4-git-send-email-yinghan@google.com>
	<20110415092519.a164e8f3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Apr 2011 21:00:40 -0700
Message-ID: <BANLkTikvMO3NwPgsbqKGMmhN5tQKvmX6mg@mail.gmail.com>
Subject: Re: [PATCH V4 03/10] New APIs to adjust per-memcg wmarks
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee0d2a6d004a0ed15d8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cd68ee0d2a6d004a0ed15d8
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 5:25 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 15:54:22 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > Add memory.low_wmark_distance, memory.high_wmark_distance and
> reclaim_wmarks
> > APIs per-memcg. The first two adjust the internal low/high wmark
> calculation
> > and the reclaim_wmarks exports the current value of watermarks.
> >
> > By default, the low/high_wmark is calculated by subtracting the distance
> from
> > the hard_limit(limit_in_bytes).
> >
> > $ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
> > $ cat /dev/cgroup/A/memory.limit_in_bytes
> > 524288000
> >
> > $ echo 50m >/dev/cgroup/A/memory.high_wmark_distance
> > $ echo 40m >/dev/cgroup/A/memory.low_wmark_distance
> >
> > $ cat /dev/cgroup/A/memory.reclaim_wmarks
> > low_wmark 482344960
> > high_wmark 471859200
> >
> > changelog v4..v3:
> > 1. replace the "wmark_ratio" API with individual tunable for
> low/high_wmarks.
> >
> > changelog v3..v2:
> > 1. replace the "min_free_kbytes" api with "wmark_ratio". This is part of
> > feedbacks
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> But please add a sanity check (see below.)
>
>
>
> > ---
> >  mm/memcontrol.c |   95
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 95 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 1ec4014..685645c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3974,6 +3974,72 @@ static int mem_cgroup_swappiness_write(struct
> cgroup *cgrp, struct cftype *cft,
> >       return 0;
> >  }
> >
> > +static u64 mem_cgroup_high_wmark_distance_read(struct cgroup *cgrp,
> > +                                            struct cftype *cft)
> > +{
> > +     struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +     return memcg->high_wmark_distance;
> > +}
> > +
> > +static u64 mem_cgroup_low_wmark_distance_read(struct cgroup *cgrp,
> > +                                           struct cftype *cft)
> > +{
> > +     struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +     return memcg->low_wmark_distance;
> > +}
> > +
> > +static int mem_cgroup_high_wmark_distance_write(struct cgroup *cont,
> > +                                             struct cftype *cft,
> > +                                             const char *buffer)
> > +{
> > +     struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> > +     u64 low_wmark_distance = memcg->low_wmark_distance;
> > +     unsigned long long val;
> > +     u64 limit;
> > +     int ret;
> > +
> > +     ret = res_counter_memparse_write_strategy(buffer, &val);
> > +     if (ret)
> > +             return -EINVAL;
> > +
> > +     limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> > +     if ((val >= limit) || (val < low_wmark_distance) ||
> > +        (low_wmark_distance && val == low_wmark_distance))
> > +             return -EINVAL;
> > +
> > +     memcg->high_wmark_distance = val;
> > +
> > +     setup_per_memcg_wmarks(memcg);
> > +     return 0;
> > +}
>
> IIUC, as limit_in_bytes, 'distance' should not be able to set against ROOT
> memcg
> because it doesn't work.
>
> thanks for review. will change in next post.
>
> > +
> > +static int mem_cgroup_low_wmark_distance_write(struct cgroup *cont,
> > +                                            struct cftype *cft,
> > +                                            const char *buffer)
> > +{
> > +     struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> > +     u64 high_wmark_distance = memcg->high_wmark_distance;
> > +     unsigned long long val;
> > +     u64 limit;
> > +     int ret;
> > +
> > +     ret = res_counter_memparse_write_strategy(buffer, &val);
> > +     if (ret)
> > +             return -EINVAL;
> > +
> > +     limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> > +     if ((val >= limit) || (val > high_wmark_distance) ||
> > +         (high_wmark_distance && val == high_wmark_distance))
> > +             return -EINVAL;
> > +
> > +     memcg->low_wmark_distance = val;
> > +
> > +     setup_per_memcg_wmarks(memcg);
> > +     return 0;
> > +}
> > +
>
> Here, too.
>
> Will add


> I wonder we should have a method to hide unnecessary interfaces in ROOT
> cgroup...
>
> hmm. something to think about..

--Ying


> Thanks,
> -Kame
>
>

--000e0cd68ee0d2a6d004a0ed15d8
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 5:25 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Thu, 14 Apr 2011 15:54:22 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; Add memory.low_wmark_distance, memory.high_wmark_distance and reclaim_=
wmarks<br>
&gt; APIs per-memcg. The first two adjust the internal low/high wmark calcu=
lation<br>
&gt; and the reclaim_wmarks exports the current value of watermarks.<br>
&gt;<br>
&gt; By default, the low/high_wmark is calculated by subtracting the distan=
ce from<br>
&gt; the hard_limit(limit_in_bytes).<br>
&gt;<br>
&gt; $ echo 500m &gt;/dev/cgroup/A/memory.limit_in_bytes<br>
&gt; $ cat /dev/cgroup/A/memory.limit_in_bytes<br>
&gt; 524288000<br>
&gt;<br>
&gt; $ echo 50m &gt;/dev/cgroup/A/memory.high_wmark_distance<br>
&gt; $ echo 40m &gt;/dev/cgroup/A/memory.low_wmark_distance<br>
&gt;<br>
&gt; $ cat /dev/cgroup/A/memory.reclaim_wmarks<br>
&gt; low_wmark 482344960<br>
&gt; high_wmark 471859200<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. replace the &quot;wmark_ratio&quot; API with individual tunable for=
 low/high_wmarks.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. replace the &quot;min_free_kbytes&quot; api with &quot;wmark_ratio&=
quot;. This is part of<br>
&gt; feedbacks<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div>Reviewed-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@=
jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
<br>
But please add a sanity check (see below.)<br>
<div><div></div><div class=3D"h5"><br>
<br>
<br>
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0 95 ++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A01 files changed, 95 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 1ec4014..685645c 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -3974,6 +3974,72 @@ static int mem_cgroup_swappiness_write(struct c=
group *cgrp, struct cftype *cft,<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static u64 mem_cgroup_high_wmark_distance_read(struct cgroup *cgrp,<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0struct cftype *cft)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);<br>
&gt; +<br>
&gt; + =A0 =A0 return memcg-&gt;high_wmark_distance;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static u64 mem_cgroup_low_wmark_distance_read(struct cgroup *cgrp,<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 struct cftype *cft)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);<br>
&gt; +<br>
&gt; + =A0 =A0 return memcg-&gt;low_wmark_distance;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static int mem_cgroup_high_wmark_distance_write(struct cgroup *cont,<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct cftype *cft,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 const char *buffer)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cont);<br>
&gt; + =A0 =A0 u64 low_wmark_distance =3D memcg-&gt;low_wmark_distance;<br>
&gt; + =A0 =A0 unsigned long long val;<br>
&gt; + =A0 =A0 u64 limit;<br>
&gt; + =A0 =A0 int ret;<br>
&gt; +<br>
&gt; + =A0 =A0 ret =3D res_counter_memparse_write_strategy(buffer, &amp;val=
);<br>
&gt; + =A0 =A0 if (ret)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;<br>
&gt; +<br>
&gt; + =A0 =A0 limit =3D res_counter_read_u64(&amp;memcg-&gt;res, RES_LIMIT=
);<br>
&gt; + =A0 =A0 if ((val &gt;=3D limit) || (val &lt; low_wmark_distance) ||<=
br>
&gt; + =A0 =A0 =A0 =A0(low_wmark_distance &amp;&amp; val =3D=3D low_wmark_d=
istance))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;<br>
&gt; +<br>
&gt; + =A0 =A0 memcg-&gt;high_wmark_distance =3D val;<br>
&gt; +<br>
&gt; + =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
<br>
</div></div>IIUC, as limit_in_bytes, &#39;distance&#39; should not be able =
to set against ROOT memcg<br>
because it doesn&#39;t work.<br>
<div class=3D"im"><br>
thanks for review. will change in next post.<br>
<br>
&gt; +<br>
&gt; +static int mem_cgroup_low_wmark_distance_write(struct cgroup *cont,<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0struct cftype *cft,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0const char *buffer)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cont);<br>
&gt; + =A0 =A0 u64 high_wmark_distance =3D memcg-&gt;high_wmark_distance;<b=
r>
&gt; + =A0 =A0 unsigned long long val;<br>
&gt; + =A0 =A0 u64 limit;<br>
&gt; + =A0 =A0 int ret;<br>
&gt; +<br>
&gt; + =A0 =A0 ret =3D res_counter_memparse_write_strategy(buffer, &amp;val=
);<br>
&gt; + =A0 =A0 if (ret)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;<br>
&gt; +<br>
&gt; + =A0 =A0 limit =3D res_counter_read_u64(&amp;memcg-&gt;res, RES_LIMIT=
);<br>
&gt; + =A0 =A0 if ((val &gt;=3D limit) || (val &gt; high_wmark_distance) ||=
<br>
&gt; + =A0 =A0 =A0 =A0 (high_wmark_distance &amp;&amp; val =3D=3D high_wmar=
k_distance))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;<br>
&gt; +<br>
&gt; + =A0 =A0 memcg-&gt;low_wmark_distance =3D val;<br>
&gt; +<br>
&gt; + =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
<br>
</div>Here, too.<br>
<br></blockquote><div>Will add</div><div>=A0</div><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex;">
I wonder we should have a method to hide unnecessary interfaces in ROOT cgr=
oup...<br>
<br></blockquote><div>hmm. something to think about..</div><div><br></div><=
div>--Ying</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--000e0cd68ee0d2a6d004a0ed15d8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
