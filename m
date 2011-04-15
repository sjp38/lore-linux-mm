Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2A6900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:46:16 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3F3k7XT003775
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:46:07 -0700
Received: from qyk30 (qyk30.prod.google.com [10.241.83.158])
	by wpaz5.hot.corp.google.com with ESMTP id p3F3k1Xu023909
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:46:06 -0700
Received: by qyk30 with SMTP id 30so1868668qyk.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:45:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415091640.5876f737.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-3-git-send-email-yinghan@google.com>
	<20110415091640.5876f737.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Apr 2011 20:45:59 -0700
Message-ID: <BANLkTimy8+MNaz6oHfJ1DwG=0Tt3x6d_Kw@mail.gmail.com>
Subject: Re: [PATCH V4 02/10] Add per memcg reclaim watermarks
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470f884cb63904a0ece16b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470f884cb63904a0ece16b
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 5:16 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 15:54:21 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > There are two watermarks added per-memcg including "high_wmark" and
> "low_wmark".
> > The per-memcg kswapd is invoked when the memcg's memory
> usage(usage_in_bytes)
> > is higher than the low_wmark. Then the kswapd thread starts to reclaim
> pages
> > until the usage is lower than the high_wmark.
> >
> > Each watermark is calculated based on the hard_limit(limit_in_bytes) for
> each
> > memcg. Each time the hard_limit is changed, the corresponding wmarks are
> > re-calculated. Since memory controller charges only user pages, there is
> > no need for a "min_wmark". The current calculation of wmarks is based on
> > individual tunable low/high_wmark_distance, which are set to 0 by
> default.
> >
> > changelog v4..v3:
> > 1. remove legacy comments
> > 2. rename the res_counter_check_under_high_wmark_limit
> > 3. replace the wmark_ratio per-memcg by individual tunable for both
> wmarks.
> > 4. add comments on low/high_wmark
> > 5. add individual tunables for low/high_wmarks and remove wmark_ratio
> > 6. replace the mem_cgroup_get_limit() call by res_count_read_u64(). The
> first
> > one returns large value w/ swapon.
> >
> > changelog v3..v2:
> > 1. Add VM_BUG_ON() on couple of places.
> > 2. Remove the spinlock on the min_free_kbytes since the consequence of
> reading
> > stale data.
> > 3. Remove the "min_free_kbytes" API and replace it with wmark_ratio based
> on
> > hard_limit.
> >
> > changelog v2..v1:
> > 1. Remove the res_counter_charge on wmark due to performance concern.
> > 2. Move the new APIs min_free_kbytes, reclaim_wmarks into seperate
> commit.
> > 3. Calculate the min_free_kbytes automatically based on the
> limit_in_bytes.
> > 4. make the wmark to be consistant with core VM which checks the free
> pages
> > instead of usage.
> > 5. changed wmark to be boolean
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> some nitpick below.
>
>
>
> > ---
> >  include/linux/memcontrol.h  |    1 +
> >  include/linux/res_counter.h |   78
> +++++++++++++++++++++++++++++++++++++++++++
> >  kernel/res_counter.c        |    6 +++
> >  mm/memcontrol.c             |   48 ++++++++++++++++++++++++++
> >  4 files changed, 133 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 5a5ce70..3ece36d 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -82,6 +82,7 @@ int task_in_mem_cgroup(struct task_struct *task, const
> struct mem_cgroup *mem);
> >
> >  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page
> *page);
> >  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> > +extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int
> charge_flags);
> >
> >  static inline
> >  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> > diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> > index c9d625c..77eaaa9 100644
> > --- a/include/linux/res_counter.h
> > +++ b/include/linux/res_counter.h
> > @@ -39,6 +39,14 @@ struct res_counter {
> >        */
> >       unsigned long long soft_limit;
> >       /*
> > +      * the limit that reclaim triggers.
> > +      */
> > +     unsigned long long low_wmark_limit;
> > +     /*
> > +      * the limit that reclaim stops.
> > +      */
> > +     unsigned long long high_wmark_limit;
> > +     /*
> >        * the number of unsuccessful attempts to consume the resource
> >        */
> >       unsigned long long failcnt;
> > @@ -55,6 +63,9 @@ struct res_counter {
> >
> >  #define RESOURCE_MAX (unsigned long long)LLONG_MAX
> >
> > +#define CHARGE_WMARK_LOW     0x01
> > +#define CHARGE_WMARK_HIGH    0x02
> > +
> >  /**
> >   * Helpers to interact with userspace
> >   * res_counter_read_u64() - returns the value of the specified member.
> > @@ -92,6 +103,8 @@ enum {
> >       RES_LIMIT,
> >       RES_FAILCNT,
> >       RES_SOFT_LIMIT,
> > +     RES_LOW_WMARK_LIMIT,
> > +     RES_HIGH_WMARK_LIMIT
> >  };
> >
> >  /*
> > @@ -147,6 +160,24 @@ static inline unsigned long long
> res_counter_margin(struct res_counter *cnt)
> >       return margin;
> >  }
> >
> > +static inline bool
> > +res_counter_high_wmark_limit_check_locked(struct res_counter *cnt)
> > +{
> > +     if (cnt->usage < cnt->high_wmark_limit)
> > +             return true;
> > +
> > +     return false;
> > +}
> > +
> > +static inline bool
> > +res_counter_low_wmark_limit_check_locked(struct res_counter *cnt)
> > +{
> > +     if (cnt->usage < cnt->low_wmark_limit)
> > +             return true;
> > +
> > +     return false;
> > +}
>
> I like res_counter_under_low_wmark_limit_locked() rather than this name.
>

Thanks for review. Will change this on the next post.

--Ying

>
> Thanks,
> -Kame
>
>

--002354470f884cb63904a0ece16b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 5:16 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Thu, 14 Apr 2011 15:54:21 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; There are two watermarks added per-memcg including &quot;high_wmark&qu=
ot; and &quot;low_wmark&quot;.<br>
&gt; The per-memcg kswapd is invoked when the memcg&#39;s memory usage(usag=
e_in_bytes)<br>
&gt; is higher than the low_wmark. Then the kswapd thread starts to reclaim=
 pages<br>
&gt; until the usage is lower than the high_wmark.<br>
&gt;<br>
&gt; Each watermark is calculated based on the hard_limit(limit_in_bytes) f=
or each<br>
&gt; memcg. Each time the hard_limit is changed, the corresponding wmarks a=
re<br>
&gt; re-calculated. Since memory controller charges only user pages, there =
is<br>
&gt; no need for a &quot;min_wmark&quot;. The current calculation of wmarks=
 is based on<br>
&gt; individual tunable low/high_wmark_distance, which are set to 0 by defa=
ult.<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. remove legacy comments<br>
&gt; 2. rename the res_counter_check_under_high_wmark_limit<br>
&gt; 3. replace the wmark_ratio per-memcg by individual tunable for both wm=
arks.<br>
&gt; 4. add comments on low/high_wmark<br>
&gt; 5. add individual tunables for low/high_wmarks and remove wmark_ratio<=
br>
&gt; 6. replace the mem_cgroup_get_limit() call by res_count_read_u64(). Th=
e first<br>
&gt; one returns large value w/ swapon.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. Add VM_BUG_ON() on couple of places.<br>
&gt; 2. Remove the spinlock on the min_free_kbytes since the consequence of=
 reading<br>
&gt; stale data.<br>
&gt; 3. Remove the &quot;min_free_kbytes&quot; API and replace it with wmar=
k_ratio based on<br>
&gt; hard_limit.<br>
&gt;<br>
&gt; changelog v2..v1:<br>
&gt; 1. Remove the res_counter_charge on wmark due to performance concern.<=
br>
&gt; 2. Move the new APIs min_free_kbytes, reclaim_wmarks into seperate com=
mit.<br>
&gt; 3. Calculate the min_free_kbytes automatically based on the limit_in_b=
ytes.<br>
&gt; 4. make the wmark to be consistant with core VM which checks the free =
pages<br>
&gt; instead of usage.<br>
&gt; 5. changed wmark to be boolean<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div></div>Acked-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiro=
yu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
<br>
some nitpick below.<br>
<div><div></div><div class=3D"h5"><br>
<br>
<br>
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h =A0| =A0 =A01 +<br>
&gt; =A0include/linux/res_counter.h | =A0 78 ++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A0kernel/res_counter.c =A0 =A0 =A0 =A0| =A0 =A06 +++<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 48 ++++++++++++++++++=
++++++++<br>
&gt; =A04 files changed, 133 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<b=
r>
&gt; index 5a5ce70..3ece36d 100644<br>
&gt; --- a/include/linux/memcontrol.h<br>
&gt; +++ b/include/linux/memcontrol.h<br>
&gt; @@ -82,6 +82,7 @@ int task_in_mem_cgroup(struct task_struct *task, con=
st struct mem_cgroup *mem);<br>
&gt;<br>
&gt; =A0extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page =
*page);<br>
&gt; =A0extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *=
p);<br>
&gt; +extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge=
_flags);<br>
&gt;<br>
&gt; =A0static inline<br>
&gt; =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cg=
roup *cgroup)<br>
&gt; diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h=
<br>
&gt; index c9d625c..77eaaa9 100644<br>
&gt; --- a/include/linux/res_counter.h<br>
&gt; +++ b/include/linux/res_counter.h<br>
&gt; @@ -39,6 +39,14 @@ struct res_counter {<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 unsigned long long soft_limit;<br>
&gt; =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0* the limit that reclaim triggers.<br>
&gt; + =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 unsigned long long low_wmark_limit;<br>
&gt; + =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0* the limit that reclaim stops.<br>
&gt; + =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 unsigned long long high_wmark_limit;<br>
&gt; + =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0* the number of unsuccessful attempts to consume the re=
source<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 unsigned long long failcnt;<br>
&gt; @@ -55,6 +63,9 @@ struct res_counter {<br>
&gt;<br>
&gt; =A0#define RESOURCE_MAX (unsigned long long)LLONG_MAX<br>
&gt;<br>
&gt; +#define CHARGE_WMARK_LOW =A0 =A0 0x01<br>
&gt; +#define CHARGE_WMARK_HIGH =A0 =A00x02<br>
&gt; +<br>
&gt; =A0/**<br>
&gt; =A0 * Helpers to interact with userspace<br>
&gt; =A0 * res_counter_read_u64() - returns the value of the specified memb=
er.<br>
&gt; @@ -92,6 +103,8 @@ enum {<br>
&gt; =A0 =A0 =A0 RES_LIMIT,<br>
&gt; =A0 =A0 =A0 RES_FAILCNT,<br>
&gt; =A0 =A0 =A0 RES_SOFT_LIMIT,<br>
&gt; + =A0 =A0 RES_LOW_WMARK_LIMIT,<br>
&gt; + =A0 =A0 RES_HIGH_WMARK_LIMIT<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -147,6 +160,24 @@ static inline unsigned long long res_counter_marg=
in(struct res_counter *cnt)<br>
&gt; =A0 =A0 =A0 return margin;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static inline bool<br>
&gt; +res_counter_high_wmark_limit_check_locked(struct res_counter *cnt)<br=
>
&gt; +{<br>
&gt; + =A0 =A0 if (cnt-&gt;usage &lt; cnt-&gt;high_wmark_limit)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return true;<br>
&gt; +<br>
&gt; + =A0 =A0 return false;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline bool<br>
&gt; +res_counter_low_wmark_limit_check_locked(struct res_counter *cnt)<br>
&gt; +{<br>
&gt; + =A0 =A0 if (cnt-&gt;usage &lt; cnt-&gt;low_wmark_limit)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return true;<br>
&gt; +<br>
&gt; + =A0 =A0 return false;<br>
&gt; +}<br>
<br>
</div></div>I like res_counter_under_low_wmark_limit_locked() rather than t=
his name.<br></blockquote><div><br></div><div>Thanks for review. Will chang=
e this on the next post.</div><div><br></div><div>--Ying=A0</div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">

<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--002354470f884cb63904a0ece16b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
