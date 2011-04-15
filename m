Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB18900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 00:47:18 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p3F4lFii015349
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:47:15 -0700
Received: from qwb7 (qwb7.prod.google.com [10.241.193.71])
	by hpaq3.eem.corp.google.com with ESMTP id p3F4lCVI018063
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:47:13 -0700
Received: by qwb7 with SMTP id 7so1730651qwb.40
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:47:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415104029.93272e86.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-10-git-send-email-yinghan@google.com>
	<20110415104029.93272e86.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Apr 2011 21:47:10 -0700
Message-ID: <BANLkTi=dABHNJAsFVDLsh5zoTUS6n4a56g@mail.gmail.com>
Subject: Re: [PATCH V4 09/10] Add API to export per-memcg kswapd pid.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd08222831404a0edbc5c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd08222831404a0edbc5c
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 6:40 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 15:54:28 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > This add the API which exports per-memcg kswapd thread pid. The kswapd
> > thread is named as "memcg_" + css_id, and the pid can be used to put
> > kswapd thread into cpu cgroup later.
> >
> > $ mkdir /dev/cgroup/memory/A
> > $ cat /dev/cgroup/memory/A/memory.kswapd_pid
> > memcg_null 0
> >
> > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> > $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> > $ ps -ef | grep memcg
> > root      6727     2  0 14:32 ?        00:00:00 [memcg_3]
> > root      6729  6044  0 14:32 ttyS0    00:00:00 grep memcg
> >
> > $ cat memory.kswapd_pid
> > memcg_3 6727
> >
> > changelog v4..v3
> > 1. Add the API based on KAMAZAWA's request on patch v3.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> Thank you.
>
> > ---
> >  include/linux/swap.h |    2 ++
> >  mm/memcontrol.c      |   33 +++++++++++++++++++++++++++++++++
> >  mm/vmscan.c          |    2 +-
> >  3 files changed, 36 insertions(+), 1 deletions(-)
> >
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 319b800..2d3e21a 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -34,6 +34,8 @@ struct kswapd {
> >  };
> >
> >  int kswapd(void *p);
> > +extern spinlock_t kswapds_spinlock;
> > +
> >  /*
> >   * MAX_SWAPFILES defines the maximum number of swaptypes: things which
> can
> >   * be swapped to.  The swap type and the offset into that swap type are
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 1b23ff4..606b680 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4493,6 +4493,35 @@ static int mem_cgroup_wmark_read(struct cgroup
> *cgrp,
> >       return 0;
> >  }
> >
> > +static int mem_cgroup_kswapd_pid_read(struct cgroup *cgrp,
> > +     struct cftype *cft,  struct cgroup_map_cb *cb)
> > +{
> > +     struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> > +     struct task_struct *kswapd_thr = NULL;
> > +     struct kswapd *kswapd_p = NULL;
> > +     wait_queue_head_t *wait;
> > +     char name[TASK_COMM_LEN];
> > +     pid_t pid = 0;
> > +
>
> I think '0' is ... not very good. This '0' implies there is no kswapd.
> But 0 is root pid. I have no idea. Do you have no concern ?
>
> Otherewise, the interface seems good.
>

Thank you for review. I will make the change for the pid on initializing to
"-1".

--Ying

>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
>
>
>
> > +     sprintf(name, "memcg_null");
> > +
> > +     spin_lock(&kswapds_spinlock);
> > +     wait = mem_cgroup_kswapd_wait(mem);
> > +     if (wait) {
> > +             kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> > +             kswapd_thr = kswapd_p->kswapd_task;
> > +             if (kswapd_thr) {
> > +                     get_task_comm(name, kswapd_thr);
> > +                     pid = kswapd_thr->pid;
> > +             }
> > +     }
> > +     spin_unlock(&kswapds_spinlock);
> > +
> > +     cb->fill(cb, name, pid);
> > +
> > +     return 0;
> > +}
> > +
> >  static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
> >       struct cftype *cft,  struct cgroup_map_cb *cb)
> >  {
> > @@ -4610,6 +4639,10 @@ static struct cftype mem_cgroup_files[] = {
> >               .name = "reclaim_wmarks",
> >               .read_map = mem_cgroup_wmark_read,
> >       },
> > +     {
> > +             .name = "kswapd_pid",
> > +             .read_map = mem_cgroup_kswapd_pid_read,
> > +     },
> >  };
> >
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index c081112..df4e5dd 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2249,7 +2249,7 @@ static bool pgdat_balanced(pg_data_t *pgdat,
> unsigned long balanced_pages,
> >       return balanced_pages > (present_pages >> 2);
> >  }
> >
> > -static DEFINE_SPINLOCK(kswapds_spinlock);
> > +DEFINE_SPINLOCK(kswapds_spinlock);
> >  #define is_node_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
> >
> >  /* is kswapd sleeping prematurely? */
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

--000e0cdfd08222831404a0edbc5c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 6:40 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Thu, 14 Apr 2011 15:54:28 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; This add the API which exports per-memcg kswapd thread pid. The kswapd=
<br>
&gt; thread is named as &quot;memcg_&quot; + css_id, and the pid can be use=
d to put<br>
&gt; kswapd thread into cpu cgroup later.<br>
&gt;<br>
&gt; $ mkdir /dev/cgroup/memory/A<br>
&gt; $ cat /dev/cgroup/memory/A/memory.kswapd_pid<br>
&gt; memcg_null 0<br>
&gt;<br>
&gt; $ echo 500m &gt;/dev/cgroup/memory/A/memory.limit_in_bytes<br>
&gt; $ echo 50m &gt;/dev/cgroup/memory/A/memory.high_wmark_distance<br>
&gt; $ ps -ef | grep memcg<br>
&gt; root =A0 =A0 =A06727 =A0 =A0 2 =A00 14:32 ? =A0 =A0 =A0 =A000:00:00 [m=
emcg_3]<br>
&gt; root =A0 =A0 =A06729 =A06044 =A00 14:32 ttyS0 =A0 =A000:00:00 grep mem=
cg<br>
&gt;<br>
&gt; $ cat memory.kswapd_pid<br>
&gt; memcg_3 6727<br>
&gt;<br>
&gt; changelog v4..v3<br>
&gt; 1. Add the API based on KAMAZAWA&#39;s request on patch v3.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div>Thank you.<br>
<div><div></div><div class=3D"h5"><br>
&gt; ---<br>
&gt; =A0include/linux/swap.h | =A0 =A02 ++<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0| =A0 33 +++++++++++++++++++++++++++++++=
++<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-<br>
&gt; =A03 files changed, 36 insertions(+), 1 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index 319b800..2d3e21a 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -34,6 +34,8 @@ struct kswapd {<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0int kswapd(void *p);<br>
&gt; +extern spinlock_t kswapds_spinlock;<br>
&gt; +<br>
&gt; =A0/*<br>
&gt; =A0 * MAX_SWAPFILES defines the maximum number of swaptypes: things wh=
ich can<br>
&gt; =A0 * be swapped to. =A0The swap type and the offset into that swap ty=
pe are<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 1b23ff4..606b680 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -4493,6 +4493,35 @@ static int mem_cgroup_wmark_read(struct cgroup =
*cgrp,<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static int mem_cgroup_kswapd_pid_read(struct cgroup *cgrp,<br>
&gt; + =A0 =A0 struct cftype *cft, =A0struct cgroup_map_cb *cb)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);<br>
&gt; + =A0 =A0 struct task_struct *kswapd_thr =3D NULL;<br>
&gt; + =A0 =A0 struct kswapd *kswapd_p =3D NULL;<br>
&gt; + =A0 =A0 wait_queue_head_t *wait;<br>
&gt; + =A0 =A0 char name[TASK_COMM_LEN];<br>
&gt; + =A0 =A0 pid_t pid =3D 0;<br>
&gt; +<br>
<br>
</div></div>I think &#39;0&#39; is ... not very good. This &#39;0&#39; impl=
ies there is no kswapd.<br>
But 0 is root pid. I have no idea. Do you have no concern ?<br>
<br>
Otherewise, the interface seems good.<br></blockquote><div><br></div><div>T=
hank you for review. I will make the change for the pid on initializing to =
&quot;-1&quot;.</div><div><br></div><div>--Ying=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">

<br>
Reviewed-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuj=
itsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
<div><div></div><div class=3D"h5"><br>
<br>
<br>
<br>
&gt; + =A0 =A0 sprintf(name, &quot;memcg_null&quot;);<br>
&gt; +<br>
&gt; + =A0 =A0 spin_lock(&amp;kswapds_spinlock);<br>
&gt; + =A0 =A0 wait =3D mem_cgroup_kswapd_wait(mem);<br>
&gt; + =A0 =A0 if (wait) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D container_of(wait, struct kswap=
d, kswapd_wait);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_thr =3D kswapd_p-&gt;kswapd_task;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (kswapd_thr) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_task_comm(name, kswapd_t=
hr);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid =3D kswapd_thr-&gt;pid;<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 spin_unlock(&amp;kswapds_spinlock);<br>
&gt; +<br>
&gt; + =A0 =A0 cb-&gt;fill(cb, name, pid);<br>
&gt; +<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_oom_control_read(struct cgroup *cgrp,<br>
&gt; =A0 =A0 =A0 struct cftype *cft, =A0struct cgroup_map_cb *cb)<br>
&gt; =A0{<br>
&gt; @@ -4610,6 +4639,10 @@ static struct cftype mem_cgroup_files[] =3D {<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;reclaim_wmarks&quot;,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_wmark_read,<br>
&gt; =A0 =A0 =A0 },<br>
&gt; + =A0 =A0 {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;kswapd_pid&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_kswapd_pid_read,<br=
>
&gt; + =A0 =A0 },<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index c081112..df4e5dd 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -2249,7 +2249,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, uns=
igned long balanced_pages,<br>
&gt; =A0 =A0 =A0 return balanced_pages &gt; (present_pages &gt;&gt; 2);<br>
&gt; =A0}<br>
&gt;<br>
&gt; -static DEFINE_SPINLOCK(kswapds_spinlock);<br>
&gt; +DEFINE_SPINLOCK(kswapds_spinlock);<br>
&gt; =A0#define is_node_kswapd(kswapd_p) (!(kswapd_p)-&gt;kswapd_mem)<br>
&gt;<br>
&gt; =A0/* is kswapd sleeping prematurely? */<br>
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

--000e0cdfd08222831404a0edbc5c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
