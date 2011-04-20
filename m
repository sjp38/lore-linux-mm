Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3534A8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 23:40:01 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3K3dn5E001058
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:39:49 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by wpaz5.hot.corp.google.com with ESMTP id p3K3dghT031983
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:39:48 -0700
Received: by qwj9 with SMTP id 9so263358qwj.35
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 20:39:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110420101533.d19622ce.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<1303185466-2532-10-git-send-email-yinghan@google.com>
	<20110420101533.d19622ce.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 19 Apr 2011 20:39:47 -0700
Message-ID: <BANLkTikZFA30znOxH+6OjBh_AQt=95w6+w@mail.gmail.com>
Subject: Re: [PATCH V6 09/10] Add API to export per-memcg kswapd pid.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee05b40af04a15160b1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cd68ee05b40af04a15160b1
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 19, 2011 at 6:15 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 18 Apr 2011 20:57:45 -0700
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
> > changelog v6..v5
> > 1. Remove the legacy spinlock which has been removed from previous post.
> >
> > changelog v5..v4
> > 1. Initialize the memcg-kswapd pid to -1 instead of 0.
> > 2. Remove the kswapds_spinlock.
> >
> > changelog v4..v3
> > 1. Add the API based on KAMAZAWA's request on patch v3.
> >
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> I'm very sorry but please drop this. There is a discussion that
> we should use thread pool rather than one-thread-per-one-memcg.
> If so, we need to remove this interface and we'll see regression.
>
> I think we need some control knobs as priority/share in thread pools
> finally...
> (So, I want to use cpu cgroup.) If not, there will be unfair utilization of
> cpu/thread. But for now, it seems adding this is too early.
>

This patch is is very good self-contained and i have no problem to drop it
for now. And I won't include this in my next post.

--Ying

>
>
> > ---
> >  mm/memcontrol.c |   31 +++++++++++++++++++++++++++++++
> >  1 files changed, 31 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index d5b284c..0b108b9 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4533,6 +4533,33 @@ static int mem_cgroup_wmark_read(struct cgroup
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
> > +     pid_t pid = -1;
> > +
> > +     sprintf(name, "memcg_null");
> > +
> > +     wait = mem_cgroup_kswapd_wait(mem);
> > +     if (wait) {
> > +             kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> > +             kswapd_thr = kswapd_p->kswapd_task;
> > +             if (kswapd_thr) {
> > +                     get_task_comm(name, kswapd_thr);
> > +                     pid = kswapd_thr->pid;
> > +             }
> > +     }
> > +
> > +     cb->fill(cb, name, pid);
> > +
> > +     return 0;
> > +}
> > +
> >  static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
> >       struct cftype *cft,  struct cgroup_map_cb *cb)
> >  {
> > @@ -4650,6 +4677,10 @@ static struct cftype mem_cgroup_files[] = {
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
> > --
> > 1.7.3.1
> >
> >
>
>

--000e0cd68ee05b40af04a15160b1
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 19, 2011 at 6:15 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Mon, 18 Apr 2011 20:57:45 -0700<br>
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
&gt; changelog v6..v5<br>
&gt; 1. Remove the legacy spinlock which has been removed from previous pos=
t.<br>
&gt;<br>
&gt; changelog v5..v4<br>
&gt; 1. Initialize the memcg-kswapd pid to -1 instead of 0.<br>
&gt; 2. Remove the kswapds_spinlock.<br>
&gt;<br>
&gt; changelog v4..v3<br>
&gt; 1. Add the API based on KAMAZAWA&#39;s request on patch v3.<br>
&gt;<br>
&gt; Reviewed-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@j=
p.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div>I&#39;m very sorry but please drop this. There is a discussion that<b=
r>
we should use thread pool rather than one-thread-per-one-memcg.<br>
If so, we need to remove this interface and we&#39;ll see regression.<br>
<br>
I think we need some control knobs as priority/share in thread pools finall=
y...<br>
(So, I want to use cpu cgroup.) If not, there will be unfair utilization of=
<br>
cpu/thread. But for now, it seems adding this is too early.<br></blockquote=
><div><br></div><div>This patch is is very good self-contained and i have n=
o problem to drop it for now. And I won&#39;t include this in my next post.=
</div>
<div><br></div><div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
<br>
&gt; ---<br>
&gt; =A0mm/memcontrol.c | =A0 31 +++++++++++++++++++++++++++++++<br>
&gt; =A01 files changed, 31 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index d5b284c..0b108b9 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -4533,6 +4533,33 @@ static int mem_cgroup_wmark_read(struct cgroup =
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
&gt; + =A0 =A0 pid_t pid =3D -1;<br>
&gt; +<br>
&gt; + =A0 =A0 sprintf(name, &quot;memcg_null&quot;);<br>
&gt; +<br>
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
&gt; +<br>
&gt; + =A0 =A0 cb-&gt;fill(cb, name, pid);<br>
&gt; +<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_oom_control_read(struct cgroup *cgrp,<br>
&gt; =A0 =A0 =A0 struct cftype *cft, =A0struct cgroup_map_cb *cb)<br>
&gt; =A0{<br>
&gt; @@ -4650,6 +4677,10 @@ static struct cftype mem_cgroup_files[] =3D {<b=
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
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
&gt;<br>
<br>
</div></div></blockquote></div><br>

--000e0cd68ee05b40af04a15160b1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
