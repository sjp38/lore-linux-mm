Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 244668D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:11:52 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p3L6BjEE016271
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:11:47 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by hpaq6.eem.corp.google.com with ESMTP id p3L69oGd000843
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:11:43 -0700
Received: by qyk10 with SMTP id 10so1065353qyk.11
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:11:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421124836.16769ffc.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124059.79990661.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421124836.16769ffc.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 20 Apr 2011 23:11:42 -0700
Message-ID: <BANLkTimFASy=jsEk=1rZSH2o386-gDgvxA@mail.gmail.com>
Subject: Re: [PATCH 2/3] weight for memcg background reclaim (Was Re: [PATCH
 V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c82657f04a1679dcb
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5c82657f04a1679dcb
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 8:48 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> memcg-kswapd visits each memcg in round-robin. But required
> amounts of works depends on memcg' usage and hi/low watermark
> and taking it into account will be good.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    1 +
>  mm/memcontrol.c            |   17 +++++++++++++++++
>  mm/vmscan.c                |    2 ++
>  3 files changed, 20 insertions(+)
>
> Index: mmotm-Apr14/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-Apr14.orig/include/linux/memcontrol.h
> +++ mmotm-Apr14/include/linux/memcontrol.h
> @@ -98,6 +98,7 @@ extern bool mem_cgroup_kswapd_can_sleep(
>  extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);
>  extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
>  extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
> +extern int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem);
>
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> Index: mmotm-Apr14/mm/memcontrol.c
> ===================================================================
> --- mmotm-Apr14.orig/mm/memcontrol.c
> +++ mmotm-Apr14/mm/memcontrol.c
> @@ -4673,6 +4673,23 @@ struct memcg_kswapd_work
>
>  struct memcg_kswapd_work       memcg_kswapd_control;
>
> +int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem)
> +{
> +       unsigned long long usage, lowat, hiwat;
> +       int rate;
> +
> +       usage = res_counter_read_u64(&mem->res, RES_USAGE);
> +       lowat = res_counter_read_u64(&mem->res, RES_LOW_WMARK_LIMIT);
> +       hiwat = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
> +       if (lowat == hiwat)
> +               return 0;
> +
> +       rate = (usage - hiwat) * 10 / (lowat - hiwat);
> +       /* If usage is big, we reclaim more */
> +       return rate * SWAP_CLUSTER_MAX;
> +}
> +
>


> I understand the logic in general, which we would like to reclaim more each
> time if more work needs to be done. But not quite sure the calculation here,
> the (usage - hiwat) determines the amount of work of kswapd. And why divide
> by (lowat - hiwat)? My guess is because the larger the value, the later we
> will trigger kswapd?


--Ying



>


>


>  static void wake_memcg_kswapd(struct mem_cgroup *mem)
>  {
>        if (atomic_read(&mem->kswapd_running)) /* already running */
> Index: mmotm-Apr14/mm/vmscan.c
> ===================================================================
> --- mmotm-Apr14.orig/mm/vmscan.c
> +++ mmotm-Apr14/mm/vmscan.c
> @@ -2732,6 +2732,8 @@ static int shrink_mem_cgroup(struct mem_
>        sc.nr_reclaimed = 0;
>        total_scanned = 0;
>
> +       sc.nr_to_reclaim += mem_cgroup_kswapd_bonus(mem_cont);
> +
>        do_nodes = node_states[N_ONLINE];
>
>        for (priority = DEF_PRIORITY;
>
>

--0016360e3f5c82657f04a1679dcb
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 8:48 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<br>
memcg-kswapd visits each memcg in round-robin. But required<br>
amounts of works depends on memcg&#39; usage and hi/low watermark<br>
and taking it into account will be good.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 =A01 +<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 17 +++++++++++++++++<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 ++<br>
=A03 files changed, 20 insertions(+)<br>
<br>
Index: mmotm-Apr14/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/include/linux/memcontrol.h<br>
+++ mmotm-Apr14/include/linux/memcontrol.h<br>
@@ -98,6 +98,7 @@ extern bool mem_cgroup_kswapd_can_sleep(<br>
=A0extern struct mem_cgroup *mem_cgroup_get_shrink_target(void);<br>
=A0extern void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);<br>
=A0extern wait_queue_head_t *mem_cgroup_kswapd_waitq(void);<br>
+extern int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem);<br>
<br>
=A0static inline<br>
=A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup =
*cgroup)<br>
Index: mmotm-Apr14/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/mm/memcontrol.c<br>
+++ mmotm-Apr14/mm/memcontrol.c<br>
@@ -4673,6 +4673,23 @@ struct memcg_kswapd_work<br>
<br>
=A0struct memcg_kswapd_work =A0 =A0 =A0 memcg_kswapd_control;<br>
<br>
+int mem_cgroup_kswapd_bonus(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 unsigned long long usage, lowat, hiwat;<br>
+ =A0 =A0 =A0 int rate;<br>
+<br>
+ =A0 =A0 =A0 usage =3D res_counter_read_u64(&amp;mem-&gt;res, RES_USAGE);<=
br>
+ =A0 =A0 =A0 lowat =3D res_counter_read_u64(&amp;mem-&gt;res, RES_LOW_WMAR=
K_LIMIT);<br>
+ =A0 =A0 =A0 hiwat =3D res_counter_read_u64(&amp;mem-&gt;res, RES_HIGH_WMA=
RK_LIMIT);<br>
+ =A0 =A0 =A0 if (lowat =3D=3D hiwat)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
+<br>
+ =A0 =A0 =A0 rate =3D (usage - hiwat) * 10 / (lowat - hiwat);<br>
+ =A0 =A0 =A0 /* If usage is big, we reclaim more */<br>
+ =A0 =A0 =A0 return rate * SWAP_CLUSTER_MAX;<br>
+}<br>
+<br></blockquote><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">I understan=
d the logic in general, which we would like to reclaim more each time if mo=
re work needs to be done. But not quite sure the calculation here, the (usa=
ge - hiwat)=A0determines the amount of work of kswapd. And why divide by (l=
owat - hiwat)? My guess is because the larger the value, the later we will =
trigger kswapd?=A0</blockquote>
<div><br></div><div>--Ying=A0</div><div><br></div><div>=A0</div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">=A0</blockquote><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
=A0<br></blockquote><div>=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
=A0static void wake_memcg_kswapd(struct mem_cgroup *mem)<br>
=A0{<br>
 =A0 =A0 =A0 =A0if (atomic_read(&amp;mem-&gt;kswapd_running)) /* already ru=
nning */<br>
Index: mmotm-Apr14/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- mmotm-Apr14.orig/mm/vmscan.c<br>
+++ mmotm-Apr14/mm/vmscan.c<br>
@@ -2732,6 +2732,8 @@ static int shrink_mem_cgroup(struct mem_<br>
 =A0 =A0 =A0 =A0sc.nr_reclaimed =3D 0;<br>
 =A0 =A0 =A0 =A0total_scanned =3D 0;<br>
<br>
+ =A0 =A0 =A0 sc.nr_to_reclaim +=3D mem_cgroup_kswapd_bonus(mem_cont);<br>
+<br>
 =A0 =A0 =A0 =A0do_nodes =3D node_states[N_ONLINE];<br>
<br>
 =A0 =A0 =A0 =A0for (priority =3D DEF_PRIORITY;<br>
<br>
</blockquote></div><br>

--0016360e3f5c82657f04a1679dcb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
