Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CCBCB900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 00:36:35 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p3F4aVkO018332
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:36:31 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by wpaz24.hot.corp.google.com with ESMTP id p3F4aUkH019090
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:36:30 -0700
Received: by qyk2 with SMTP id 2so1578176qyk.9
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:36:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415094007.9cfc4a7d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-6-git-send-email-yinghan@google.com>
	<20110415094007.9cfc4a7d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Apr 2011 21:36:28 -0700
Message-ID: <BANLkTikGzW6RNmMwCkJHt1avgqygiiijuw@mail.gmail.com>
Subject: Re: [PATCH V4 05/10] Implement the select_victim_node within memcg.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00248c6a84cadd63ea04a0ed9533
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--00248c6a84cadd63ea04a0ed9533
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 5:40 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 15:54:24 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > This add the mechanism for background reclaim which we remember the
> > last scanned node and always starting from the next one each time.
> > The simple round-robin fasion provide the fairness between nodes for
> > each memcg.
> >
> > changelog v4..v3:
> > 1. split off from the per-memcg background reclaim patch.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> Yeah, looks nice. Thank you for splitting.
>
>
> > ---
> >  include/linux/memcontrol.h |    3 +++
> >  mm/memcontrol.c            |   40
> ++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 43 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index f7ffd1f..d4ff7f2 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup
> *mem,
> >                                 struct kswapd *kswapd_p);
> >  extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
> >  extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup
> *mem);
> > +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
> > +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
> > +                                     const nodemask_t *nodes);
> >
> >  static inline
> >  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index c4e1904..e22351a 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -279,6 +279,11 @@ struct mem_cgroup {
> >       u64 high_wmark_distance;
> >       u64 low_wmark_distance;
> >
> > +     /* While doing per cgroup background reclaim, we cache the
> > +      * last node we reclaimed from
> > +      */
> > +     int last_scanned_node;
> > +
> >       wait_queue_head_t *kswapd_wait;
> >  };
> >
> > @@ -1536,6 +1541,32 @@ static int mem_cgroup_hierarchical_reclaim(struct
> mem_cgroup *root_mem,
> >  }
> >
> >  /*
> > + * Visit the first node after the last_scanned_node of @mem and use that
> to
> > + * reclaim free pages from.
> > + */
> > +int
> > +mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t
> *nodes)
> > +{
> > +     int next_nid;
> > +     int last_scanned;
> > +
> > +     last_scanned = mem->last_scanned_node;
> > +
> > +     /* Initial stage and start from node0 */
> > +     if (last_scanned == -1)
> > +             next_nid = 0;
> > +     else
> > +             next_nid = next_node(last_scanned, *nodes);
> > +
>
> IIUC, mem->last_scanned_node should be initialized to MAX_NUMNODES.
> Then, we can remove above check.
>

make sense. will make the change on next post.

--Ying

>
> Thanks,
> -Kame
>
> > +     if (next_nid == MAX_NUMNODES)
> > +             next_nid = first_node(*nodes);
> > +
> > +     mem->last_scanned_node = next_nid;
> > +
> > +     return next_nid;
> > +}
> > +
> > +/*
> >   * Check OOM-Killer is already running under our hierarchy.
> >   * If someone is running, return false.
> >   */
> > @@ -4693,6 +4724,14 @@ wait_queue_head_t *mem_cgroup_kswapd_wait(struct
> mem_cgroup *mem)
> >       return mem->kswapd_wait;
> >  }
> >
> > +int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
> > +{
> > +     if (!mem)
> > +             return -1;
> > +
> > +     return mem->last_scanned_node;
> > +}
> > +
> >  static int mem_cgroup_soft_limit_tree_init(void)
> >  {
> >       struct mem_cgroup_tree_per_node *rtpn;
> > @@ -4768,6 +4807,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct
> cgroup *cont)
> >               res_counter_init(&mem->memsw, NULL);
> >       }
> >       mem->last_scanned_child = 0;
> > +     mem->last_scanned_node = -1;
> >       INIT_LIST_HEAD(&mem->oom_notify);
> >
> >       if (parent)
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

--00248c6a84cadd63ea04a0ed9533
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 5:40 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Thu, 14 Apr 2011 15:54:24 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; This add the mechanism for background reclaim which we remember the<br=
>
&gt; last scanned node and always starting from the next one each time.<br>
&gt; The simple round-robin fasion provide the fairness between nodes for<b=
r>
&gt; each memcg.<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. split off from the per-memcg background reclaim patch.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div>Yeah, looks nice. Thank you for splitting.<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h | =A0 =A03 +++<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 40 +++++++++++++++++++=
+++++++++++++++++++++<br>
&gt; =A02 files changed, 43 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index f7ffd1f..d4ff7f2 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup =
*mem,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct=
 kswapd *kswapd_p);<br>
&gt; =A0extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);<br>
&gt; =A0extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup =
*mem);<br>
&gt; +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);<br>
&gt; +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 const nodemask_t *nodes);<br>
&gt;<br>
&gt; =A0static inline<br>
&gt; =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cg=
roup *cgroup)<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index c4e1904..e22351a 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -279,6 +279,11 @@ struct mem_cgroup {<br>
&gt; =A0 =A0 =A0 u64 high_wmark_distance;<br>
&gt; =A0 =A0 =A0 u64 low_wmark_distance;<br>
&gt;<br>
&gt; + =A0 =A0 /* While doing per cgroup background reclaim, we cache the<b=
r>
&gt; + =A0 =A0 =A0* last node we reclaimed from<br>
&gt; + =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 int last_scanned_node;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
&gt; =A0};<br>
&gt;<br>
&gt; @@ -1536,6 +1541,32 @@ static int mem_cgroup_hierarchical_reclaim(stru=
ct mem_cgroup *root_mem,<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; + * Visit the first node after the last_scanned_node of @mem and use t=
hat to<br>
&gt; + * reclaim free pages from.<br>
&gt; + */<br>
&gt; +int<br>
&gt; +mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_=
t *nodes)<br>
&gt; +{<br>
&gt; + =A0 =A0 int next_nid;<br>
&gt; + =A0 =A0 int last_scanned;<br>
&gt; +<br>
&gt; + =A0 =A0 last_scanned =3D mem-&gt;last_scanned_node;<br>
&gt; +<br>
&gt; + =A0 =A0 /* Initial stage and start from node0 */<br>
&gt; + =A0 =A0 if (last_scanned =3D=3D -1)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D 0;<br>
&gt; + =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D next_node(last_scanned, *nodes)=
;<br>
&gt; +<br>
<br>
</div></div>IIUC, mem-&gt;last_scanned_node should be initialized to MAX_NU=
MNODES.<br>
Then, we can remove above check.<br></blockquote><div><br></div><div>make s=
ense. will make the change on next post.</div><div><br></div><div>--Ying</d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex;">

<br>
Thanks,<br>
-Kame<br>
<div class=3D"im"><br>
&gt; + =A0 =A0 if (next_nid =3D=3D MAX_NUMNODES)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D first_node(*nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 mem-&gt;last_scanned_node =3D next_nid;<br>
&gt; +<br>
&gt; + =A0 =A0 return next_nid;<br>
&gt; +}<br>
&gt; +<br>
&gt; +/*<br>
&gt; =A0 * Check OOM-Killer is already running under our hierarchy.<br>
&gt; =A0 * If someone is running, return false.<br>
&gt; =A0 */<br>
&gt; @@ -4693,6 +4724,14 @@ wait_queue_head_t *mem_cgroup_kswapd_wait(struc=
t mem_cgroup *mem)<br>
&gt; =A0 =A0 =A0 return mem-&gt;kswapd_wait;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -1;<br>
&gt; +<br>
&gt; + =A0 =A0 return mem-&gt;last_scanned_node;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_soft_limit_tree_init(void)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rtpn;<br>
&gt; @@ -4768,6 +4807,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, stru=
ct cgroup *cont)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_init(&amp;mem-&gt;memsw, NULL)=
;<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 mem-&gt;last_scanned_child =3D 0;<br>
&gt; + =A0 =A0 mem-&gt;last_scanned_node =3D -1;<br>
&gt; =A0 =A0 =A0 INIT_LIST_HEAD(&amp;mem-&gt;oom_notify);<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (parent)<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
</div>&gt; --<br>
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

--00248c6a84cadd63ea04a0ed9533--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
