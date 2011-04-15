Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B7F3A900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 00:04:14 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p3F44BIW031861
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:04:12 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by kpbe19.cbf.corp.google.com with ESMTP id p3F43dg5016071
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:04:10 -0700
Received: by qyg14 with SMTP id 14so1628609qyg.12
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:04:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415093451.1f701df8.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-5-git-send-email-yinghan@google.com>
	<20110415093451.1f701df8.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Apr 2011 21:04:10 -0700
Message-ID: <BANLkTi=cxO4Wn_7YZgeYGVeAxxhqKS52ow@mail.gmail.com>
Subject: Re: [PATCH V4 04/10] Infrastructure to support per-memcg reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd08253e77a04a0ed226b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd08253e77a04a0ed226b
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 5:34 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 15:54:23 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > Add the kswapd_mem field in kswapd descriptor which links the kswapd
> > kernel thread to a memcg. The per-memcg kswapd is sleeping in the wait
> > queue headed at kswapd_wait field of the kswapd descriptor.
> >
> > The kswapd() function is now shared between global and per-memcg kswapd.
> It
> > is passed in with the kswapd descriptor which contains the information of
> > either node or memcg. Then the new function balance_mem_cgroup_pgdat is
> > invoked if it is per-mem kswapd thread, and the implementation of the
> function
> > is on the following patch.
> >
> > changelog v4..v3:
> > 1. fix up the kswapd_run and kswapd_stop for online_pages() and
> offline_pages.
> > 2. drop the PF_MEMALLOC flag for memcg kswapd for now per KAMAZAWA's
> request.
> >
> > changelog v3..v2:
> > 1. split off from the initial patch which includes all changes of the
> following
> > three patches.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
>
> > ---
> >  include/linux/memcontrol.h |    5 ++
> >  include/linux/swap.h       |    5 +-
> >  mm/memcontrol.c            |   29 ++++++++
> >  mm/memory_hotplug.c        |    4 +-
> >  mm/vmscan.c                |  157
> ++++++++++++++++++++++++++++++--------------
> >  5 files changed, 147 insertions(+), 53 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 3ece36d..f7ffd1f 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -24,6 +24,7 @@ struct mem_cgroup;
> >  struct page_cgroup;
> >  struct page;
> >  struct mm_struct;
> > +struct kswapd;
> >
> >  /* Stats that can be updated by kernel. */
> >  enum mem_cgroup_page_stat_item {
> > @@ -83,6 +84,10 @@ int task_in_mem_cgroup(struct task_struct *task, const
> struct mem_cgroup *mem);
> >  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page
> *page);
> >  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> >  extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int
> charge_flags);
> > +extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
> > +                               struct kswapd *kswapd_p);
> > +extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
> > +extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup
> *mem);
> >
> >  static inline
> >  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index f43d406..17e0511 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -30,6 +30,7 @@ struct kswapd {
> >       struct task_struct *kswapd_task;
> >       wait_queue_head_t kswapd_wait;
> >       pg_data_t *kswapd_pgdat;
> > +     struct mem_cgroup *kswapd_mem;
> >  };
> >
> >  int kswapd(void *p);
> > @@ -303,8 +304,8 @@ static inline void
> scan_unevictable_unregister_node(struct node *node)
> >  }
> >  #endif
> >
> > -extern int kswapd_run(int nid);
> > -extern void kswapd_stop(int nid);
> > +extern int kswapd_run(int nid, struct mem_cgroup *mem);
> > +extern void kswapd_stop(int nid, struct mem_cgroup *mem);
> >
> >  #ifdef CONFIG_MMU
> >  /* linux/mm/shmem.c */
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 685645c..c4e1904 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -278,6 +278,8 @@ struct mem_cgroup {
> >        */
> >       u64 high_wmark_distance;
> >       u64 low_wmark_distance;
> > +
> > +     wait_queue_head_t *kswapd_wait;
> >  };
>
> I think mem_cgroup can include 'struct kswapd' itself and don't need to
> alloc it dynamically.
>
> Other parts seems ok to me.
>

The same for the previous post. I would like to keep the implementation for
the first version if not one is strongly better than the other. Hope that
works.

--Ying

>
> Thanks,
> -Kame
>
>

--000e0cdfd08253e77a04a0ed226b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 5:34 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Thu, 14 Apr 2011 15:54:23 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; Add the kswapd_mem field in kswapd descriptor which links the kswapd<b=
r>
&gt; kernel thread to a memcg. The per-memcg kswapd is sleeping in the wait=
<br>
&gt; queue headed at kswapd_wait field of the kswapd descriptor.<br>
&gt;<br>
&gt; The kswapd() function is now shared between global and per-memcg kswap=
d. It<br>
&gt; is passed in with the kswapd descriptor which contains the information=
 of<br>
&gt; either node or memcg. Then the new function balance_mem_cgroup_pgdat i=
s<br>
&gt; invoked if it is per-mem kswapd thread, and the implementation of the =
function<br>
&gt; is on the following patch.<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. fix up the kswapd_run and kswapd_stop for online_pages() and offlin=
e_pages.<br>
&gt; 2. drop the PF_MEMALLOC flag for memcg kswapd for now per KAMAZAWA&#39=
;s request.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. split off from the initial patch which includes all changes of the =
following<br>
&gt; three patches.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h | =A0 =A05 ++<br>
&gt; =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A05 +-<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 29 ++++++++<br>
&gt; =A0mm/memory_hotplug.c =A0 =A0 =A0 =A0| =A0 =A04 +-<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0157 +++++++++++++++=
+++++++++++++++--------------<br>
&gt; =A05 files changed, 147 insertions(+), 53 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index 3ece36d..f7ffd1f 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -24,6 +24,7 @@ struct mem_cgroup;<br>
&gt; =A0struct page_cgroup;<br>
&gt; =A0struct page;<br>
&gt; =A0struct mm_struct;<br>
&gt; +struct kswapd;<br>
&gt;<br>
&gt; =A0/* Stats that can be updated by kernel. */<br>
&gt; =A0enum mem_cgroup_page_stat_item {<br>
&gt; @@ -83,6 +84,10 @@ int task_in_mem_cgroup(struct task_struct *task, co=
nst struct mem_cgroup *mem);<br>
&gt; =A0extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page =
*page);<br>
&gt; =A0extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *=
p);<br>
&gt; =A0extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int char=
ge_flags);<br>
&gt; +extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct k=
swapd *kswapd_p);<br>
&gt; +extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);<br>
&gt; +extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *m=
em);<br>
&gt;<br>
&gt; =A0static inline<br>
&gt; =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cg=
roup *cgroup)<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index f43d406..17e0511 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -30,6 +30,7 @@ struct kswapd {<br>
&gt; =A0 =A0 =A0 struct task_struct *kswapd_task;<br>
&gt; =A0 =A0 =A0 wait_queue_head_t kswapd_wait;<br>
&gt; =A0 =A0 =A0 pg_data_t *kswapd_pgdat;<br>
&gt; + =A0 =A0 struct mem_cgroup *kswapd_mem;<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0int kswapd(void *p);<br>
&gt; @@ -303,8 +304,8 @@ static inline void scan_unevictable_unregister_nod=
e(struct node *node)<br>
&gt; =A0}<br>
&gt; =A0#endif<br>
&gt;<br>
&gt; -extern int kswapd_run(int nid);<br>
&gt; -extern void kswapd_stop(int nid);<br>
&gt; +extern int kswapd_run(int nid, struct mem_cgroup *mem);<br>
&gt; +extern void kswapd_stop(int nid, struct mem_cgroup *mem);<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_MMU<br>
&gt; =A0/* linux/mm/shmem.c */<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 685645c..c4e1904 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -278,6 +278,8 @@ struct mem_cgroup {<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 u64 high_wmark_distance;<br>
&gt; =A0 =A0 =A0 u64 low_wmark_distance;<br>
&gt; +<br>
&gt; + =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
&gt; =A0};<br>
<br>
</div></div>I think mem_cgroup can include &#39;struct kswapd&#39; itself a=
nd don&#39;t need to<br>
alloc it dynamically.<br>
<br>
Other parts seems ok to me.<br></blockquote><div><br></div><div>The same fo=
r the previous post. I would like to keep the implementation for the first =
version if not one is strongly better than the other. Hope that works.</div=
>
<div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--000e0cdfd08253e77a04a0ed226b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
