Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8169C8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:59:59 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p3L6xsxj021494
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:59:55 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by kpbe16.cbf.corp.google.com with ESMTP id p3L6xrFr016602
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:59:53 -0700
Received: by qyk10 with SMTP id 10so819339qyk.4
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:59:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421153804.6da5c5ea.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421124836.16769ffc.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimFASy=jsEk=1rZSH2o386-gDgvxA@mail.gmail.com>
	<20110421153804.6da5c5ea.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 20 Apr 2011 23:59:52 -0700
Message-ID: <BANLkTi=Y7SfFv=LMmaspyTXXSHrO5LJaiQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] weight for memcg background reclaim (Was Re: [PATCH
 V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefdabeb32e04a16849e6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016e64aefdabeb32e04a16849e6
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 11:38 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 20 Apr 2011 23:11:42 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Wed, Apr 20, 2011 at 8:48 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > >
> > > memcg-kswapd visits each memcg in round-robin. But required
> > > amounts of works depends on memcg' usage and hi/low watermark
> > > and taking it into account will be good.
> > >
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  include/linux/memcontrol.h |    1 +
> > >  mm/memcontrol.c            |   17 +++++++++++++++++
> > >  mm/vmscan.c                |    2 ++
> > >  3 files changed, 20 insertions(+)
> > >
> > > Index: mmotm-Apr14/include/linux/memcontrol.h
> > > ===================================================================
> > > --- mmotm-Apr14.orig/include/linux/memcontrol.h
> > > +++ mmotm-Apr14/include/linux/memcontrol.h
> > > @@ -98,6 +98,7 @@ extern bool mem_cgroup_kswapd_can_sleep(
> > >  extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);
> > >  extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
> > >  extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
> > > +extern int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem);
> > >
> > >  static inline
> > >  int mm_match_cgroup(const struct mm_struct *mm, const struct
> mem_cgroup
> > > *cgroup)
> > > Index: mmotm-Apr14/mm/memcontrol.c
> > > ===================================================================
> > > --- mmotm-Apr14.orig/mm/memcontrol.c
> > > +++ mmotm-Apr14/mm/memcontrol.c
> > > @@ -4673,6 +4673,23 @@ struct memcg_kswapd_work
> > >
> > >  struct memcg_kswapd_work       memcg_kswapd_control;
> > >
> > > +int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem)
> > > +{
> > > +       unsigned long long usage, lowat, hiwat;
> > > +       int rate;
> > > +
> > > +       usage = res_counter_read_u64(&mem->res, RES_USAGE);
> > > +       lowat = res_counter_read_u64(&mem->res, RES_LOW_WMARK_LIMIT);
> > > +       hiwat = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
> > > +       if (lowat == hiwat)
> > > +               return 0;
> > > +
> > > +       rate = (usage - hiwat) * 10 / (lowat - hiwat);
> > > +       /* If usage is big, we reclaim more */
> > > +       return rate * SWAP_CLUSTER_MAX;
>
> This may be buggy and we should have upper limit on this 'rate'.
>
>
> > > +}
> > > +
> > >
> >
> >
> > > I understand the logic in general, which we would like to reclaim more
> each
> > > time if more work needs to be done. But not quite sure the calculation
> here,
> > > the (usage - hiwat) determines the amount of work of kswapd. And why
> divide
> > > by (lowat - hiwat)? My guess is because the larger the value, the later
> we
> > > will trigger kswapd?
> >
> Because memcg-kswapd will require more work on this memcg if usage-high is
> large.
>

agree on this, and that is the idea of "rate" be proportional to
(usage-high).

>
> At first, I'm not sure this logic is good but wanted to show there is a
> chance to
> do some schedule.
>
> We have 2 ways to implement this kind of weight
>
>  1. modify to select memcg logic
>    I think we'll see starvation easily. So, didn't this for this time.
>
>  2. modify the amount to nr_to_reclaim
>    We'll be able to determine the amount by some calculation using some
> statistics.
>
> I selected "2" for this time.
>
> With HIGH/LOW watermark, the admin set LOW watermark as a kind of limit.
> Then,
> if usage is more than LOW watermark, its priority will be higher than other
> memcg
> which has lower (relative) usage.


Ok, now i know a bit more of the logic behind. Here, we would like to
reclaim more from the memcg which has higher (usage - low).

n general, memcg-kswapd can reduce memory down to high watermak only when
> the system is not busy. So, this logic tries to remove more memory from busy
> cgroup to reduce 'hit limit'.
>

So, the "busy cgroup" here means the memcg has higher (usage - low)?

--Ying

>
> And I wonder, a memcg containes pages which is related to each other. So,
> reducing
> some amount of pages larger than 32pages at once may make sense.
>
>

> Thanks,
> -Kame
>
>

--0016e64aefdabeb32e04a16849e6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 11:38 PM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Wed, 20 Apr 2011 23:11:42 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; On Wed, Apr 20, 2011 at 8:48 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; memcg-kswapd visits each memcg in round-robin. But required<br>
&gt; &gt; amounts of works depends on memcg&#39; usage and hi/low watermark=
<br>
&gt; &gt; and taking it into account will be good.<br>
&gt; &gt;<br>
&gt; &gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.h=
iroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; =A0include/linux/memcontrol.h | =A0 =A01 +<br>
&gt; &gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 17 ++++++++++++++=
+++<br>
&gt; &gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 ++<br>
&gt; &gt; =A03 files changed, 20 insertions(+)<br>
&gt; &gt;<br>
&gt; &gt; Index: mmotm-Apr14/include/linux/memcontrol.h<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- mmotm-Apr14.orig/include/linux/memcontrol.h<br>
&gt; &gt; +++ mmotm-Apr14/include/linux/memcontrol.h<br>
&gt; &gt; @@ -98,6 +98,7 @@ extern bool mem_cgroup_kswapd_can_sleep(<br>
&gt; &gt; =A0extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);<=
br>
&gt; &gt; =A0extern void mem_cgroup_put_shrink_target(struct mem_cgroup *me=
m);<br>
&gt; &gt; =A0extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);<br>
&gt; &gt; +extern int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem);<br>
&gt; &gt;<br>
&gt; &gt; =A0static inline<br>
&gt; &gt; =A0int mm_match_cgroup(const struct mm_struct *mm, const struct m=
em_cgroup<br>
&gt; &gt; *cgroup)<br>
&gt; &gt; Index: mmotm-Apr14/mm/memcontrol.c<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; &gt; --- mmotm-Apr14.orig/mm/memcontrol.c<br>
&gt; &gt; +++ mmotm-Apr14/mm/memcontrol.c<br>
&gt; &gt; @@ -4673,6 +4673,23 @@ struct memcg_kswapd_work<br>
&gt; &gt;<br>
&gt; &gt; =A0struct memcg_kswapd_work =A0 =A0 =A0 memcg_kswapd_control;<br>
&gt; &gt;<br>
&gt; &gt; +int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem)<br>
&gt; &gt; +{<br>
&gt; &gt; + =A0 =A0 =A0 unsigned long long usage, lowat, hiwat;<br>
&gt; &gt; + =A0 =A0 =A0 int rate;<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 usage =3D res_counter_read_u64(&amp;mem-&gt;res, RE=
S_USAGE);<br>
&gt; &gt; + =A0 =A0 =A0 lowat =3D res_counter_read_u64(&amp;mem-&gt;res, RE=
S_LOW_WMARK_LIMIT);<br>
&gt; &gt; + =A0 =A0 =A0 hiwat =3D res_counter_read_u64(&amp;mem-&gt;res, RE=
S_HIGH_WMARK_LIMIT);<br>
&gt; &gt; + =A0 =A0 =A0 if (lowat =3D=3D hiwat)<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; &gt; +<br>
&gt; &gt; + =A0 =A0 =A0 rate =3D (usage - hiwat) * 10 / (lowat - hiwat);<br=
>
&gt; &gt; + =A0 =A0 =A0 /* If usage is big, we reclaim more */<br>
&gt; &gt; + =A0 =A0 =A0 return rate * SWAP_CLUSTER_MAX;<br>
<br>
</div></div>This may be buggy and we should have upper limit on this &#39;r=
ate&#39;.<br>
<div class=3D"im"><br>
<br>
&gt; &gt; +}<br>
&gt; &gt; +<br>
&gt; &gt;<br>
&gt;<br>
&gt;<br>
&gt; &gt; I understand the logic in general, which we would like to reclaim=
 more each<br>
&gt; &gt; time if more work needs to be done. But not quite sure the calcul=
ation here,<br>
&gt; &gt; the (usage - hiwat) determines the amount of work of kswapd. And =
why divide<br>
&gt; &gt; by (lowat - hiwat)? My guess is because the larger the value, the=
 later we<br>
&gt; &gt; will trigger kswapd?<br>
&gt;<br>
</div>Because memcg-kswapd will require more work on this memcg if usage-hi=
gh is large.<br></blockquote><div><br></div><div>agree on this, and that is=
 the idea of &quot;rate&quot; be=A0proportional=A0to (usage-high).</div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #=
ccc solid;padding-left:1ex;">

<br>
At first, I&#39;m not sure this logic is good but wanted to show there is a=
 chance to<br>
do some schedule.<br>
<br>
We have 2 ways to implement this kind of weight<br>
<br>
=A01. modify to select memcg logic<br>
 =A0 =A0I think we&#39;ll see starvation easily. So, didn&#39;t this for th=
is time.<br>
<br>
=A02. modify the amount to nr_to_reclaim<br>
 =A0 =A0We&#39;ll be able to determine the amount by some calculation using=
 some statistics.<br>
<br>
I selected &quot;2&quot; for this time.<br>
<br>
With HIGH/LOW watermark, the admin set LOW watermark as a kind of limit. Th=
en,<br>
if usage is more than LOW watermark, its priority will be higher than other=
 memcg<br>
which has lower (relative) usage.</blockquote><div><br></div><div>Ok, now i=
 know a bit more of the logic behind. Here, we would like to reclaim more f=
rom the memcg which has higher (usage - low).</div><div><br></div><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex;">
n general, memcg-kswapd can reduce memory down=A0to high watermak only when=
 the system is not busy. So, this logic tries to remove=A0more memory from =
busy cgroup to reduce &#39;hit limit&#39;.<br></blockquote><div><br></div><=
div>
So, the &quot;busy cgroup&quot; here means the memcg has higher (usage - lo=
w)?</div><div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
And I wonder, a memcg containes pages which is related to each other. So, r=
educing<br>
some amount of pages larger than 32pages at once may make sense.<br>
<br></blockquote><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--0016e64aefdabeb32e04a16849e6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
