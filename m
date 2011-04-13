Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BDDC3900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:40:37 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3DIeW6A008083
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:40:32 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by hpaq2.eem.corp.google.com with ESMTP id p3DIdgbO029314
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:40:27 -0700
Received: by qyk36 with SMTP id 36so3755940qyk.11
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:40:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110413172502.7f7edb2c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-3-git-send-email-yinghan@google.com>
	<20110413172502.7f7edb2c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 13 Apr 2011 11:40:26 -0700
Message-ID: <BANLkTi=z5F40qWgHWmzpJ6jseeGyBJ+fAQ@mail.gmail.com>
Subject: Re: [PATCH V3 2/7] Add per memcg reclaim watermarks
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00248c6a84ca6c783b04a0d1248c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--00248c6a84ca6c783b04a0d1248c
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 13, 2011 at 1:25 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 13 Apr 2011 00:03:02 -0700
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
> > no need for a "min_wmark". The current calculation of wmarks is a
> function of
> > "wmark_ratio" which is set to 0 by default. When the value is 0, the
> watermarks
> > are equal to the hard_limit.
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
> > ---
> >  include/linux/memcontrol.h  |    1 +
> >  include/linux/res_counter.h |   80
> +++++++++++++++++++++++++++++++++++++++++++
> >  kernel/res_counter.c        |    6 +++
> >  mm/memcontrol.c             |   52 ++++++++++++++++++++++++++++
> >  4 files changed, 139 insertions(+), 0 deletions(-)
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
> > index c9d625c..fa4181b 100644
> > --- a/include/linux/res_counter.h
> > +++ b/include/linux/res_counter.h
> > @@ -39,6 +39,16 @@ struct res_counter {
> >        */
> >       unsigned long long soft_limit;
> >       /*
> > +      * the limit that reclaim triggers. TODO: res_counter in mem
> > +      * or wmark_limit.
> > +      */
> > +     unsigned long long low_wmark_limit;
> > +     /*
> > +      * the limit that reclaim stops. TODO: res_counter in mem or
> > +      * wmark_limit.
> > +      */
>
> What does this TODO mean ?
>

Legacy comment. I will remove it.

>
>
> > +     unsigned long long high_wmark_limit;
> > +     /*
> >        * the number of unsuccessful attempts to consume the resource
> >        */
> >       unsigned long long failcnt;
> > @@ -55,6 +65,9 @@ struct res_counter {
> >
> >  #define RESOURCE_MAX (unsigned long long)LLONG_MAX
> >
> > +#define CHARGE_WMARK_LOW     0x01
> > +#define CHARGE_WMARK_HIGH    0x02
> > +
> >  /**
> >   * Helpers to interact with userspace
> >   * res_counter_read_u64() - returns the value of the specified member.
> > @@ -92,6 +105,8 @@ enum {
> >       RES_LIMIT,
> >       RES_FAILCNT,
> >       RES_SOFT_LIMIT,
> > +     RES_LOW_WMARK_LIMIT,
> > +     RES_HIGH_WMARK_LIMIT
> >  };
> >
> >  /*
> > @@ -147,6 +162,24 @@ static inline unsigned long long
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
> > +
>
>
> >  /**
> >   * Get the difference between the usage and the soft limit
> >   * @cnt: The counter
> > @@ -169,6 +202,30 @@ res_counter_soft_limit_excess(struct res_counter
> *cnt)
> >       return excess;
> >  }
> >
> > +static inline bool
> > +res_counter_check_under_low_wmark_limit(struct res_counter *cnt)
> > +{
> > +     bool ret;
> > +     unsigned long flags;
> > +
> > +     spin_lock_irqsave(&cnt->lock, flags);
> > +     ret = res_counter_low_wmark_limit_check_locked(cnt);
> > +     spin_unlock_irqrestore(&cnt->lock, flags);
> > +     return ret;
> > +}
> > +
> > +static inline bool
> > +res_counter_check_under_high_wmark_limit(struct res_counter *cnt)
> > +{
> > +     bool ret;
> > +     unsigned long flags;
> > +
> > +     spin_lock_irqsave(&cnt->lock, flags);
> > +     ret = res_counter_high_wmark_limit_check_locked(cnt);
> > +     spin_unlock_irqrestore(&cnt->lock, flags);
> > +     return ret;
> > +}
> > +
>
> Why internal functions are named as _check_ ? I like _under_.
>

Changed and will be on next post.

>
>
> >  static inline void res_counter_reset_max(struct res_counter *cnt)
> >  {
> >       unsigned long flags;
> > @@ -214,4 +271,27 @@ res_counter_set_soft_limit(struct res_counter *cnt,
> >       return 0;
> >  }
> >
> > +static inline int
> > +res_counter_set_high_wmark_limit(struct res_counter *cnt,
> > +                             unsigned long long wmark_limit)
> > +{
> > +     unsigned long flags;
> > +
> > +     spin_lock_irqsave(&cnt->lock, flags);
> > +     cnt->high_wmark_limit = wmark_limit;
> > +     spin_unlock_irqrestore(&cnt->lock, flags);
> > +     return 0;
> > +}
> > +
> > +static inline int
> > +res_counter_set_low_wmark_limit(struct res_counter *cnt,
> > +                             unsigned long long wmark_limit)
> > +{
> > +     unsigned long flags;
> > +
> > +     spin_lock_irqsave(&cnt->lock, flags);
> > +     cnt->low_wmark_limit = wmark_limit;
> > +     spin_unlock_irqrestore(&cnt->lock, flags);
> > +     return 0;
> > +}
> >  #endif
> > diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> > index 34683ef..206a724 100644
> > --- a/kernel/res_counter.c
> > +++ b/kernel/res_counter.c
> > @@ -19,6 +19,8 @@ void res_counter_init(struct res_counter *counter,
> struct res_counter *parent)
> >       spin_lock_init(&counter->lock);
> >       counter->limit = RESOURCE_MAX;
> >       counter->soft_limit = RESOURCE_MAX;
> > +     counter->low_wmark_limit = RESOURCE_MAX;
> > +     counter->high_wmark_limit = RESOURCE_MAX;
> >       counter->parent = parent;
> >  }
> >
> > @@ -103,6 +105,10 @@ res_counter_member(struct res_counter *counter, int
> member)
> >               return &counter->failcnt;
> >       case RES_SOFT_LIMIT:
> >               return &counter->soft_limit;
> > +     case RES_LOW_WMARK_LIMIT:
> > +             return &counter->low_wmark_limit;
> > +     case RES_HIGH_WMARK_LIMIT:
> > +             return &counter->high_wmark_limit;
> >       };
> >
> >       BUG();
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 4407dd0..664cdc5 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -272,6 +272,8 @@ struct mem_cgroup {
> >        */
> >       struct mem_cgroup_stat_cpu nocpu_base;
> >       spinlock_t pcp_counter_lock;
> > +
> > +     int wmark_ratio;
> >  };
> >
> >  /* Stuffs for move charges at task migration. */
> > @@ -353,6 +355,7 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> >  static void drain_all_stock_async(void);
> > +static unsigned long get_wmark_ratio(struct mem_cgroup *mem);
> >
> >  static struct mem_cgroup_per_zone *
> >  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
> > @@ -813,6 +816,27 @@ static inline bool mem_cgroup_is_root(struct
> mem_cgroup *mem)
> >       return (mem == root_mem_cgroup);
> >  }
> >
> > +static void setup_per_memcg_wmarks(struct mem_cgroup *mem)
> > +{
> > +     u64 limit;
> > +     unsigned long wmark_ratio;
> > +
> > +     wmark_ratio = get_wmark_ratio(mem);
> > +     limit = mem_cgroup_get_limit(mem);
> > +     if (wmark_ratio == 0) {
> > +             res_counter_set_low_wmark_limit(&mem->res, limit);
> > +             res_counter_set_high_wmark_limit(&mem->res, limit);
> > +     } else {
> > +             unsigned long low_wmark, high_wmark;
> > +             unsigned long long tmp = (wmark_ratio * limit) / 100;
>
> could you make this ratio as /1000 ? percent is too big.
> And, considering misc. cases, I don't think having per-memcg "ratio" is
> good.
>
> How about following ?
>
>  - provides an automatic wmark without knob. 0 wmark is okay, for me.
>  - provides 2 intrerfaces as
>        memory.low_wmark_distance_in_bytes,  # == hard_limit - low_wmark.
>        memory.high_wmark_in_bytes,          # == hard_limit - high_wmark.
>   (need to add sanity check into set_limit.)
>
> Hmm. Making the wmarks tunable individually make sense to me. One problem I
do notice is that making the hard_limit as the bar might not working well on
over-committing system. Which means the per-cgroup background reclaim might
not be triggered before global memory pressure. Ideally, we would like to do
more per-cgroup reclaim before triggering global memory pressure.

How about adding the two APIs but make the calculation based on:

-- by default, the wmarks are equal to hard_limit. ( no background reclaim)
-- provides 2 intrerfaces as
       memory.low_wmark_distance_in_bytes,  # == min(hard_limit, soft_limit)
- low_wmark.
       memory.high_wmark_in_bytes,          # == min(hard_limit, soft_limit)
- high_wmark.


> > +
> > +             low_wmark = tmp;
> > +             high_wmark = tmp - (tmp >> 8);
> > +             res_counter_set_low_wmark_limit(&mem->res, low_wmark);
> > +             res_counter_set_high_wmark_limit(&mem->res, high_wmark);
> > +     }
> > +}
>
> Could you explan what low_wmark/high_wmark means somewhere ?
>

Will add comments.

>
> In this patch, kswapd runs while
>
>        high_wmark < usage < low_wmark
> ?
>
> Hmm, I like
>        low_wmark < usage < high_wmark.
>
> ;) because it's kswapd.
>
> I adopt the same concept of global kswapd where low_wmark triggers the
kswpd and hight_wmark stop it. And here, we have

(limit - high_wmark) < free < (limit - low_wmark)

--Ying

>
> > +
> >  /*
> >   * Following LRU functions are allowed to be used without PCG_LOCK.
> >   * Operations are called by routine of global LRU independently from
> memcg.
> > @@ -1195,6 +1219,16 @@ static unsigned int get_swappiness(struct
> mem_cgroup *memcg)
> >       return memcg->swappiness;
> >  }
> >
> > +static unsigned long get_wmark_ratio(struct mem_cgroup *memcg)
> > +{
> > +     struct cgroup *cgrp = memcg->css.cgroup;
> > +
> > +     VM_BUG_ON(!cgrp);
> > +     VM_BUG_ON(!cgrp->parent);
> > +
>
> Does this happen ?
>
> > +     return memcg->wmark_ratio;
> > +}
> > +
> >  static void mem_cgroup_start_move(struct mem_cgroup *mem)
> >  {
> >       int cpu;
> > @@ -3205,6 +3239,7 @@ static int mem_cgroup_resize_limit(struct
> mem_cgroup *memcg,
> >                       else
> >                               memcg->memsw_is_minimum = false;
> >               }
> > +             setup_per_memcg_wmarks(memcg);
> >               mutex_unlock(&set_limit_mutex);
> >
> >               if (!ret)
> > @@ -3264,6 +3299,7 @@ static int mem_cgroup_resize_memsw_limit(struct
> mem_cgroup *memcg,
> >                       else
> >                               memcg->memsw_is_minimum = false;
> >               }
> > +             setup_per_memcg_wmarks(memcg);
> >               mutex_unlock(&set_limit_mutex);
> >
> >               if (!ret)
> > @@ -4521,6 +4557,22 @@ static void __init enable_swap_cgroup(void)
> >  }
> >  #endif
> >
> > +int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
> > +                             int charge_flags)
> > +{
> > +     long ret = 0;
> > +     int flags = CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;
> > +
> > +     VM_BUG_ON((charge_flags & flags) == flags);
> > +
> > +     if (charge_flags & CHARGE_WMARK_LOW)
> > +             ret = res_counter_check_under_low_wmark_limit(&mem->res);
> > +     if (charge_flags & CHARGE_WMARK_HIGH)
> > +             ret = res_counter_check_under_high_wmark_limit(&mem->res);
> > +
> > +     return ret;
> > +}
>
> Hmm, do we need this unified function ?
>
> Thanks,
> -Kame
>
>

--00248c6a84ca6c783b04a0d1248c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 13, 2011 at 1:25 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Wed, 13 Apr 2011 00:03:02 -0700<br>
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
 is a function of<br>
&gt; &quot;wmark_ratio&quot; which is set to 0 by default. When the value i=
s 0, the watermarks<br>
&gt; are equal to the hard_limit.<br>
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
&gt; ---<br>
&gt; =A0include/linux/memcontrol.h =A0| =A0 =A01 +<br>
&gt; =A0include/linux/res_counter.h | =A0 80 ++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A0kernel/res_counter.c =A0 =A0 =A0 =A0| =A0 =A06 +++<br>
&gt; =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 52 ++++++++++++++++++=
++++++++++<br>
&gt; =A04 files changed, 139 insertions(+), 0 deletions(-)<br>
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
&gt; index c9d625c..fa4181b 100644<br>
&gt; --- a/include/linux/res_counter.h<br>
&gt; +++ b/include/linux/res_counter.h<br>
&gt; @@ -39,6 +39,16 @@ struct res_counter {<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 unsigned long long soft_limit;<br>
&gt; =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0* the limit that reclaim triggers. TODO: res_counter in m=
em<br>
&gt; + =A0 =A0 =A0* or wmark_limit.<br>
&gt; + =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 unsigned long long low_wmark_limit;<br>
&gt; + =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0* the limit that reclaim stops. TODO: res_counter in mem =
or<br>
&gt; + =A0 =A0 =A0* wmark_limit.<br>
&gt; + =A0 =A0 =A0*/<br>
<br>
</div></div>What does this TODO mean ?<br></blockquote><div><br></div><div>=
Legacy comment. I will remove it.</div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
<br>
&gt; + =A0 =A0 unsigned long long high_wmark_limit;<br>
&gt; + =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0* the number of unsuccessful attempts to consume the re=
source<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 unsigned long long failcnt;<br>
&gt; @@ -55,6 +65,9 @@ struct res_counter {<br>
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
&gt; @@ -92,6 +105,8 @@ enum {<br>
&gt; =A0 =A0 =A0 RES_LIMIT,<br>
&gt; =A0 =A0 =A0 RES_FAILCNT,<br>
&gt; =A0 =A0 =A0 RES_SOFT_LIMIT,<br>
&gt; + =A0 =A0 RES_LOW_WMARK_LIMIT,<br>
&gt; + =A0 =A0 RES_HIGH_WMARK_LIMIT<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -147,6 +162,24 @@ static inline unsigned long long res_counter_marg=
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
&gt; +<br>
<br>
<br>
&gt; =A0/**<br>
&gt; =A0 * Get the difference between the usage and the soft limit<br>
&gt; =A0 * @cnt: The counter<br>
&gt; @@ -169,6 +202,30 @@ res_counter_soft_limit_excess(struct res_counter =
*cnt)<br>
&gt; =A0 =A0 =A0 return excess;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static inline bool<br>
&gt; +res_counter_check_under_low_wmark_limit(struct res_counter *cnt)<br>
&gt; +{<br>
&gt; + =A0 =A0 bool ret;<br>
&gt; + =A0 =A0 unsigned long flags;<br>
&gt; +<br>
&gt; + =A0 =A0 spin_lock_irqsave(&amp;cnt-&gt;lock, flags);<br>
&gt; + =A0 =A0 ret =3D res_counter_low_wmark_limit_check_locked(cnt);<br>
&gt; + =A0 =A0 spin_unlock_irqrestore(&amp;cnt-&gt;lock, flags);<br>
&gt; + =A0 =A0 return ret;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline bool<br>
&gt; +res_counter_check_under_high_wmark_limit(struct res_counter *cnt)<br>
&gt; +{<br>
&gt; + =A0 =A0 bool ret;<br>
&gt; + =A0 =A0 unsigned long flags;<br>
&gt; +<br>
&gt; + =A0 =A0 spin_lock_irqsave(&amp;cnt-&gt;lock, flags);<br>
&gt; + =A0 =A0 ret =3D res_counter_high_wmark_limit_check_locked(cnt);<br>
&gt; + =A0 =A0 spin_unlock_irqrestore(&amp;cnt-&gt;lock, flags);<br>
&gt; + =A0 =A0 return ret;<br>
&gt; +}<br>
&gt; +<br>
<br>
</div></div>Why internal functions are named as _check_ ? I like _under_.<b=
r></blockquote><div><br></div><div>Changed and will be on next post.=A0</di=
v><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex;">

<div><div></div><div class=3D"h5"><br>
<br>
&gt; =A0static inline void res_counter_reset_max(struct res_counter *cnt)<b=
r>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 unsigned long flags;<br>
&gt; @@ -214,4 +271,27 @@ res_counter_set_soft_limit(struct res_counter *cn=
t,<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static inline int<br>
&gt; +res_counter_set_high_wmark_limit(struct res_counter *cnt,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lon=
g long wmark_limit)<br>
&gt; +{<br>
&gt; + =A0 =A0 unsigned long flags;<br>
&gt; +<br>
&gt; + =A0 =A0 spin_lock_irqsave(&amp;cnt-&gt;lock, flags);<br>
&gt; + =A0 =A0 cnt-&gt;high_wmark_limit =3D wmark_limit;<br>
&gt; + =A0 =A0 spin_unlock_irqrestore(&amp;cnt-&gt;lock, flags);<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; +static inline int<br>
&gt; +res_counter_set_low_wmark_limit(struct res_counter *cnt,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lon=
g long wmark_limit)<br>
&gt; +{<br>
&gt; + =A0 =A0 unsigned long flags;<br>
&gt; +<br>
&gt; + =A0 =A0 spin_lock_irqsave(&amp;cnt-&gt;lock, flags);<br>
&gt; + =A0 =A0 cnt-&gt;low_wmark_limit =3D wmark_limit;<br>
&gt; + =A0 =A0 spin_unlock_irqrestore(&amp;cnt-&gt;lock, flags);<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; =A0#endif<br>
&gt; diff --git a/kernel/res_counter.c b/kernel/res_counter.c<br>
&gt; index 34683ef..206a724 100644<br>
&gt; --- a/kernel/res_counter.c<br>
&gt; +++ b/kernel/res_counter.c<br>
&gt; @@ -19,6 +19,8 @@ void res_counter_init(struct res_counter *counter, s=
truct res_counter *parent)<br>
&gt; =A0 =A0 =A0 spin_lock_init(&amp;counter-&gt;lock);<br>
&gt; =A0 =A0 =A0 counter-&gt;limit =3D RESOURCE_MAX;<br>
&gt; =A0 =A0 =A0 counter-&gt;soft_limit =3D RESOURCE_MAX;<br>
&gt; + =A0 =A0 counter-&gt;low_wmark_limit =3D RESOURCE_MAX;<br>
&gt; + =A0 =A0 counter-&gt;high_wmark_limit =3D RESOURCE_MAX;<br>
&gt; =A0 =A0 =A0 counter-&gt;parent =3D parent;<br>
&gt; =A0}<br>
&gt;<br>
&gt; @@ -103,6 +105,10 @@ res_counter_member(struct res_counter *counter, i=
nt member)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &amp;counter-&gt;failcnt;<br>
&gt; =A0 =A0 =A0 case RES_SOFT_LIMIT:<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &amp;counter-&gt;soft_limit;<br>
&gt; + =A0 =A0 case RES_LOW_WMARK_LIMIT:<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return &amp;counter-&gt;low_wmark_limit;<br>
&gt; + =A0 =A0 case RES_HIGH_WMARK_LIMIT:<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return &amp;counter-&gt;high_wmark_limit;<br=
>
&gt; =A0 =A0 =A0 };<br>
&gt;<br>
&gt; =A0 =A0 =A0 BUG();<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 4407dd0..664cdc5 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -272,6 +272,8 @@ struct mem_cgroup {<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 struct mem_cgroup_stat_cpu nocpu_base;<br>
&gt; =A0 =A0 =A0 spinlock_t pcp_counter_lock;<br>
&gt; +<br>
&gt; + =A0 =A0 int wmark_ratio;<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0/* Stuffs for move charges at task migration. */<br>
&gt; @@ -353,6 +355,7 @@ static void mem_cgroup_get(struct mem_cgroup *mem)=
;<br>
&gt; =A0static void mem_cgroup_put(struct mem_cgroup *mem);<br>
&gt; =A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem)=
;<br>
&gt; =A0static void drain_all_stock_async(void);<br>
&gt; +static unsigned long get_wmark_ratio(struct mem_cgroup *mem);<br>
&gt;<br>
&gt; =A0static struct mem_cgroup_per_zone *<br>
&gt; =A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)<br>
&gt; @@ -813,6 +816,27 @@ static inline bool mem_cgroup_is_root(struct mem_=
cgroup *mem)<br>
&gt; =A0 =A0 =A0 return (mem =3D=3D root_mem_cgroup);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static void setup_per_memcg_wmarks(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 u64 limit;<br>
&gt; + =A0 =A0 unsigned long wmark_ratio;<br>
&gt; +<br>
&gt; + =A0 =A0 wmark_ratio =3D get_wmark_ratio(mem);<br>
&gt; + =A0 =A0 limit =3D mem_cgroup_get_limit(mem);<br>
&gt; + =A0 =A0 if (wmark_ratio =3D=3D 0) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_low_wmark_limit(&amp;mem-&gt=
;res, limit);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_high_wmark_limit(&amp;mem-&g=
t;res, limit);<br>
&gt; + =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long low_wmark, high_wmark;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long long tmp =3D (wmark_ratio * li=
mit) / 100;<br>
<br>
</div></div>could you make this ratio as /1000 ? percent is too big.<br>
And, considering misc. cases, I don&#39;t think having per-memcg &quot;rati=
o&quot; is good.<br>
<br>
How about following ?<br>
<br>
=A0- provides an automatic wmark without knob. 0 wmark is okay, for me.<br>
=A0- provides 2 intrerfaces as<br>
 =A0 =A0 =A0 =A0memory.low_wmark_distance_in_bytes, =A0# =3D=3D hard_limit =
- low_wmark.<br>
 =A0 =A0 =A0 =A0memory.high_wmark_in_bytes, =A0 =A0 =A0 =A0 =A0# =3D=3D har=
d_limit - high_wmark.<br>
 =A0 (need to add sanity check into set_limit.)<br>
<div class=3D"im"><br></div></blockquote><div>Hmm. Making the wmarks tunabl=
e individually make sense to me. One problem I do notice is that making the=
 hard_limit as the bar might not working well on over-committing system. Wh=
ich means the per-cgroup background reclaim=A0might not be triggered before=
 global memory pressure. Ideally, we would like to do more per-cgroup recla=
im before triggering global memory pressure.</div>
<div><br></div><div>How about adding the two APIs but make the calculation =
based on:</div><div><br></div><div>-- by default, the wmarks are equal to h=
ard_limit. ( no background reclaim)</div><div><meta http-equiv=3D"content-t=
ype" content=3D"text/html; charset=3Dutf-8">-- provides 2 intrerfaces as<br=
>
=A0 =A0 =A0 =A0memory.low_wmark_distance_in_bytes, =A0# =3D=3D min(hard_lim=
it, soft_limit) - low_wmark.<br>=A0 =A0 =A0 =A0memory.high_wmark_in_bytes, =
=A0 =A0 =A0 =A0 =A0# =3D=3D min(hard_limit, soft_limit) - high_wmark.</div>=
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">
<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 low_wmark =3D tmp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 high_wmark =3D tmp - (tmp &gt;&gt; 8);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_low_wmark_limit(&amp;mem-&gt=
;res, low_wmark);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_high_wmark_limit(&amp;mem-&g=
t;res, high_wmark);<br>
&gt; + =A0 =A0 }<br>
&gt; +}<br>
<br>
</div>Could you explan what low_wmark/high_wmark means somewhere ?<br></blo=
ckquote><div>=A0</div><div>Will add comments.</div><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex;">

<br>
In this patch, kswapd runs while<br>
<br>
 =A0 =A0 =A0 =A0high_wmark &lt; usage &lt; low_wmark<br>
?<br>
<br>
Hmm, I like<br>
 =A0 =A0 =A0 =A0low_wmark &lt; usage &lt; high_wmark.<br>
<br>
;) because it&#39;s kswapd.<br>
<div class=3D"im"><br></div></blockquote><div>I adopt the same concept of g=
lobal kswapd where low_wmark triggers the kswpd and hight_wmark stop it. An=
d here, we have</div><div><br></div><div>(limit - high_wmark) &lt; free &lt=
; (limit - low_wmark)</div>
<div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;"><div class=
=3D"im">
<br>
&gt; +<br>
&gt; =A0/*<br>
&gt; =A0 * Following LRU functions are allowed to be used without PCG_LOCK.=
<br>
&gt; =A0 * Operations are called by routine of global LRU independently fro=
m memcg.<br>
&gt; @@ -1195,6 +1219,16 @@ static unsigned int get_swappiness(struct mem_c=
group *memcg)<br>
&gt; =A0 =A0 =A0 return memcg-&gt;swappiness;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static unsigned long get_wmark_ratio(struct mem_cgroup *memcg)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct cgroup *cgrp =3D memcg-&gt;css.cgroup;<br>
&gt; +<br>
&gt; + =A0 =A0 VM_BUG_ON(!cgrp);<br>
&gt; + =A0 =A0 VM_BUG_ON(!cgrp-&gt;parent);<br>
&gt; +<br>
<br>
</div>Does this happen ?<br>
<div><div></div><div class=3D"h5"><br>
&gt; + =A0 =A0 return memcg-&gt;wmark_ratio;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static void mem_cgroup_start_move(struct mem_cgroup *mem)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 int cpu;<br>
&gt; @@ -3205,6 +3239,7 @@ static int mem_cgroup_resize_limit(struct mem_cg=
roup *memcg,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg-&gt;=
memsw_is_minimum =3D false;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&amp;set_limit_mutex);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)<br>
&gt; @@ -3264,6 +3299,7 @@ static int mem_cgroup_resize_memsw_limit(struct =
mem_cgroup *memcg,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg-&gt;=
memsw_is_minimum =3D false;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&amp;set_limit_mutex);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)<br>
&gt; @@ -4521,6 +4557,22 @@ static void __init enable_swap_cgroup(void)<br>
&gt; =A0}<br>
&gt; =A0#endif<br>
&gt;<br>
&gt; +int mem_cgroup_watermark_ok(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int charge_f=
lags)<br>
&gt; +{<br>
&gt; + =A0 =A0 long ret =3D 0;<br>
&gt; + =A0 =A0 int flags =3D CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;<br>
&gt; +<br>
&gt; + =A0 =A0 VM_BUG_ON((charge_flags &amp; flags) =3D=3D flags);<br>
&gt; +<br>
&gt; + =A0 =A0 if (charge_flags &amp; CHARGE_WMARK_LOW)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_check_under_low_wmark_li=
mit(&amp;mem-&gt;res);<br>
&gt; + =A0 =A0 if (charge_flags &amp; CHARGE_WMARK_HIGH)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_check_under_high_wmark_l=
imit(&amp;mem-&gt;res);<br>
&gt; +<br>
&gt; + =A0 =A0 return ret;<br>
&gt; +}<br>
<br>
</div></div>Hmm, do we need this unified function ?<br>
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--00248c6a84ca6c783b04a0d1248c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
