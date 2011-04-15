Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DE149900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 17:47:07 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p3FLl19X022400
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:47:05 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by hpaq12.eem.corp.google.com with ESMTP id p3FLkTWU019614
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:47:00 -0700
Received: by qyk36 with SMTP id 36so7548qyk.4
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:46:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415131617.91b0485c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-2-git-send-email-yinghan@google.com>
	<20110415090445.4578f987.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikE6dyLJVebk65-6A8RdF-fpTFQ+g@mail.gmail.com>
	<20110415131617.91b0485c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 15 Apr 2011 14:46:59 -0700
Message-ID: <BANLkTikRTuqvSaf9=KYndtBV8VBSd4e6SA@mail.gmail.com>
Subject: Re: [PATCH V4 01/10] Add kswapd descriptor
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd68ee03dbcbf04a0fbfb95
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cd68ee03dbcbf04a0fbfb95
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 9:16 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 20:35:00 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Thu, Apr 14, 2011 at 5:04 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > On Thu, 14 Apr 2011 15:54:20 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > There is a kswapd kernel thread for each numa node. We will add a
> > > different
> > > > kswapd for each memcg. The kswapd is sleeping in the wait queue
> headed at
> > > > kswapd_wait field of a kswapd descriptor. The kswapd descriptor
> stores
> > > > information of node or memcg and it allows the global and per-memcg
> > > background
> > > > reclaim to share common reclaim algorithms.
> > > >
> > > > This patch adds the kswapd descriptor and moves the per-node kswapd
> to
> > > use the
> > > > new structure.
> > > >
> > >
> > > No objections to your direction but some comments.
> > >
> > > > changelog v2..v1:
> > > > 1. dynamic allocate kswapd descriptor and initialize the
> wait_queue_head
> > > of pgdat
> > > > at kswapd_run.
> > > > 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup
> > > kswapd
> > > > descriptor.
> > > >
> > > > changelog v3..v2:
> > > > 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later
> patch.
> > > > 2. rename thr in kswapd_run to something else.
> > > >
> > > > Signed-off-by: Ying Han <yinghan@google.com>
> > > > ---
> > > >  include/linux/mmzone.h |    3 +-
> > > >  include/linux/swap.h   |    7 ++++
> > > >  mm/page_alloc.c        |    1 -
> > > >  mm/vmscan.c            |   95
> > > ++++++++++++++++++++++++++++++++++++------------
> > > >  4 files changed, 80 insertions(+), 26 deletions(-)
> > > >
> > > > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > > > index 628f07b..6cba7d2 100644
> > > > --- a/include/linux/mmzone.h
> > > > +++ b/include/linux/mmzone.h
> > > > @@ -640,8 +640,7 @@ typedef struct pglist_data {
> > > >       unsigned long node_spanned_pages; /* total size of physical
> page
> > > >                                            range, including holes */
> > > >       int node_id;
> > > > -     wait_queue_head_t kswapd_wait;
> > > > -     struct task_struct *kswapd;
> > > > +     wait_queue_head_t *kswapd_wait;
> > > >       int kswapd_max_order;
> > > >       enum zone_type classzone_idx;
> > >
> > > I think pg_data_t should include struct kswapd in it, as
> > >
> > >        struct pglist_data {
> > >        .....
> > >                struct kswapd   kswapd;
> > >        };
> > > and you can add a macro as
> > >
> > > #define kswapd_waitqueue(kswapd)        (&(kswapd)->kswapd_wait)
> > > if it looks better.
> > >
> > > Why I recommend this is I think it's better to have 'struct kswapd'
> > > on the same page of pg_data_t or struct memcg.
> > > Do you have benefits to kmalloc() struct kswapd on damand ?
> > >
> >
> > So we don't end of have kswapd struct on memcgs' which doesn't have
> > per-memcg kswapd enabled. I don't see one is strongly better than the
> other
> > for the two approaches. If ok, I would like to keep as it is for this
> > verion. Hope this is ok for now.
> >
>
> My intension is to remove kswapd_spinlock. Can we remove it with
> dynamic allocation ? IOW, static allocation still requires spinlock ?
>

Thank you for pointing that out which made me thinking a little harder on
this. I don't think we need the spinlock
in this patch.

This is something I inherited from another kswapd patch we did where we
allow one kswapd to reclaim from multiple pgdat. We need the spinlock there
since we need to protect the pgdat list per kswapd. However, we have
one-to-one
mapping here and we can get rid of the lock. I will remove it on the next
post.

--Ying

>
> Thanks,
> -Kame
>
>
>

--000e0cd68ee03dbcbf04a0fbfb95
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 9:16 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
On Thu, 14 Apr 2011 20:35:00 -0700<br>
<div><div></div><div class=3D"h5">Ying Han &lt;<a href=3D"mailto:yinghan@go=
ogle.com">yinghan@google.com</a>&gt; wrote:<br>
<br>
&gt; On Thu, Apr 14, 2011 at 5:04 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Thu, 14 Apr 2011 15:54:20 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; There is a kswapd kernel thread for each numa node. We will =
add a<br>
&gt; &gt; different<br>
&gt; &gt; &gt; kswapd for each memcg. The kswapd is sleeping in the wait qu=
eue headed at<br>
&gt; &gt; &gt; kswapd_wait field of a kswapd descriptor. The kswapd descrip=
tor stores<br>
&gt; &gt; &gt; information of node or memcg and it allows the global and pe=
r-memcg<br>
&gt; &gt; background<br>
&gt; &gt; &gt; reclaim to share common reclaim algorithms.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; This patch adds the kswapd descriptor and moves the per-node=
 kswapd to<br>
&gt; &gt; use the<br>
&gt; &gt; &gt; new structure.<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; No objections to your direction but some comments.<br>
&gt; &gt;<br>
&gt; &gt; &gt; changelog v2..v1:<br>
&gt; &gt; &gt; 1. dynamic allocate kswapd descriptor and initialize the wai=
t_queue_head<br>
&gt; &gt; of pgdat<br>
&gt; &gt; &gt; at kswapd_run.<br>
&gt; &gt; &gt; 2. add helper macro is_node_kswapd to distinguish per-node/p=
er-cgroup<br>
&gt; &gt; kswapd<br>
&gt; &gt; &gt; descriptor.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; changelog v3..v2:<br>
&gt; &gt; &gt; 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to=
 later patch.<br>
&gt; &gt; &gt; 2. rename thr in kswapd_run to something else.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google=
.com">yinghan@google.com</a>&gt;<br>
&gt; &gt; &gt; ---<br>
&gt; &gt; &gt; =A0include/linux/mmzone.h | =A0 =A03 +-<br>
&gt; &gt; &gt; =A0include/linux/swap.h =A0 | =A0 =A07 ++++<br>
&gt; &gt; &gt; =A0mm/page_alloc.c =A0 =A0 =A0 =A0| =A0 =A01 -<br>
&gt; &gt; &gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 95<br>
&gt; &gt; ++++++++++++++++++++++++++++++++++++------------<br>
&gt; &gt; &gt; =A04 files changed, 80 insertions(+), 26 deletions(-)<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h=
<br>
&gt; &gt; &gt; index 628f07b..6cba7d2 100644<br>
&gt; &gt; &gt; --- a/include/linux/mmzone.h<br>
&gt; &gt; &gt; +++ b/include/linux/mmzone.h<br>
&gt; &gt; &gt; @@ -640,8 +640,7 @@ typedef struct pglist_data {<br>
&gt; &gt; &gt; =A0 =A0 =A0 unsigned long node_spanned_pages; /* total size =
of physical page<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0range, including holes */<br>
&gt; &gt; &gt; =A0 =A0 =A0 int node_id;<br>
&gt; &gt; &gt; - =A0 =A0 wait_queue_head_t kswapd_wait;<br>
&gt; &gt; &gt; - =A0 =A0 struct task_struct *kswapd;<br>
&gt; &gt; &gt; + =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
&gt; &gt; &gt; =A0 =A0 =A0 int kswapd_max_order;<br>
&gt; &gt; &gt; =A0 =A0 =A0 enum zone_type classzone_idx;<br>
&gt; &gt;<br>
&gt; &gt; I think pg_data_t should include struct kswapd in it, as<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0struct pglist_data {<br>
&gt; &gt; =A0 =A0 =A0 =A0.....<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kswapd =A0 kswapd;<br>
&gt; &gt; =A0 =A0 =A0 =A0};<br>
&gt; &gt; and you can add a macro as<br>
&gt; &gt;<br>
&gt; &gt; #define kswapd_waitqueue(kswapd) =A0 =A0 =A0 =A0(&amp;(kswapd)-&g=
t;kswapd_wait)<br>
&gt; &gt; if it looks better.<br>
&gt; &gt;<br>
&gt; &gt; Why I recommend this is I think it&#39;s better to have &#39;stru=
ct kswapd&#39;<br>
&gt; &gt; on the same page of pg_data_t or struct memcg.<br>
&gt; &gt; Do you have benefits to kmalloc() struct kswapd on damand ?<br>
&gt; &gt;<br>
&gt;<br>
&gt; So we don&#39;t end of have kswapd struct on memcgs&#39; which doesn&#=
39;t have<br>
&gt; per-memcg kswapd enabled. I don&#39;t see one is strongly better than =
the other<br>
&gt; for the two approaches. If ok, I would like to keep as it is for this<=
br>
&gt; verion. Hope this is ok for now.<br>
&gt;<br>
<br>
</div></div>My intension is to remove kswapd_spinlock. Can we remove it wit=
h<br>
dynamic allocation ? IOW, static allocation still requires spinlock ?<br></=
blockquote><div><br></div><div>Thank you for pointing that out which made m=
e thinking a little harder on this. I don&#39;t think we need the spinlock<=
/div>
<div>in this patch.</div><div><br></div><div>This is something I=A0inherite=
d=A0from another kswapd patch we did where we allow one kswapd to reclaim f=
rom multiple pgdat. We need the spinlock there since we need to protect the=
 pgdat list per kswapd. However, we have one-to-one</div>
<div>mapping here and we can get rid of the lock. I will remove it on the n=
ext post.</div><div><br></div><div>--Ying</div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x;">

<br>
Thanks,<br>
-Kame<br>
<br>
<br>
</blockquote></div><br>

--000e0cd68ee03dbcbf04a0fbfb95--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
