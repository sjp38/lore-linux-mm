Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1529000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 13:54:21 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p3QHsHF4008360
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:54:17 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by hpaq14.eem.corp.google.com with ESMTP id p3QHs0Ot007509
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:54:16 -0700
Received: by qyk10 with SMTP id 10so533541qyk.11
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:54:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 10:54:15 -0700
Message-ID: <BANLkTi=Q+AgWU=CXG2dr7=1kaZBm6FsrSA@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc2f00a404a1d6031a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

--000e0ce008bc2f00a404a1d6031a
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 25, 2011 at 2:28 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> There are two watermarks added per-memcg including "high_wmark" and
> "low_wmark".
> The per-memcg kswapd is invoked when the memcg's memory
> usage(usage_in_bytes)
> is higher than the low_wmark. Then the kswapd thread starts to reclaim
> pages
> until the usage is lower than the high_wmark.
>
> Each watermark is calculated based on the hard_limit(limit_in_bytes) for
> each
> memcg. Each time the hard_limit is changed, the corresponding wmarks are
> re-calculated. Since memory controller charges only user pages, there is
> no need for a "min_wmark". The current calculation of wmarks is based on
> individual tunable high_wmark_distance, which are set to 0 by default.
> low_wmark is calculated in automatic way.
>
> Changelog:v8b...v7
> 1. set low_wmark_distance in automatic using fixed HILOW_DISTANCE.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h  |    1
>  include/linux/res_counter.h |   78
> ++++++++++++++++++++++++++++++++++++++++++++
>  kernel/res_counter.c        |    6 +++
>  mm/memcontrol.c             |   69 ++++++++++++++++++++++++++++++++++++++
>  4 files changed, 154 insertions(+)
>
> Index: memcg/include/linux/memcontrol.h
> ===================================================================
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -84,6 +84,7 @@ int task_in_mem_cgroup(struct task_struc
>
>  extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> +extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int
> charge_flags);
>
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> Index: memcg/include/linux/res_counter.h
> ===================================================================
> --- memcg.orig/include/linux/res_counter.h
> +++ memcg/include/linux/res_counter.h
> @@ -39,6 +39,14 @@ struct res_counter {
>         */
>        unsigned long long soft_limit;
>        /*
> +        * the limit that reclaim triggers.
> +        */
> +       unsigned long long low_wmark_limit;
> +       /*
> +        * the limit that reclaim stops.
> +        */
> +       unsigned long long high_wmark_limit;
> +       /*
>         * the number of unsuccessful attempts to consume the resource
>         */
>        unsigned long long failcnt;
> @@ -55,6 +63,9 @@ struct res_counter {
>
>  #define RESOURCE_MAX (unsigned long long)LLONG_MAX
>
> +#define CHARGE_WMARK_LOW       0x01
> +#define CHARGE_WMARK_HIGH      0x02
> +
>  /**
>  * Helpers to interact with userspace
>  * res_counter_read_u64() - returns the value of the specified member.
> @@ -92,6 +103,8 @@ enum {
>        RES_LIMIT,
>        RES_FAILCNT,
>        RES_SOFT_LIMIT,
> +       RES_LOW_WMARK_LIMIT,
> +       RES_HIGH_WMARK_LIMIT
>  };
>
>  /*
> @@ -147,6 +160,24 @@ static inline unsigned long long res_cou
>        return margin;
>  }
>
> +static inline bool
> +res_counter_under_high_wmark_limit_check_locked(struct res_counter *cnt)
> +{
> +       if (cnt->usage < cnt->high_wmark_limit)
> +               return true;
> +
> +       return false;
> +}
> +
> +static inline bool
> +res_counter_under_low_wmark_limit_check_locked(struct res_counter *cnt)
> +{
> +       if (cnt->usage < cnt->low_wmark_limit)
> +               return true;
> +
> +       return false;
> +}
> +
>  /**
>  * Get the difference between the usage and the soft limit
>  * @cnt: The counter
> @@ -169,6 +200,30 @@ res_counter_soft_limit_excess(struct res
>        return excess;
>  }
>
> +static inline bool
> +res_counter_under_low_wmark_limit(struct res_counter *cnt)
> +{
> +       bool ret;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&cnt->lock, flags);
> +       ret = res_counter_under_low_wmark_limit_check_locked(cnt);
> +       spin_unlock_irqrestore(&cnt->lock, flags);
> +       return ret;
> +}
> +
> +static inline bool
> +res_counter_under_high_wmark_limit(struct res_counter *cnt)
> +{
> +       bool ret;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&cnt->lock, flags);
> +       ret = res_counter_under_high_wmark_limit_check_locked(cnt);
> +       spin_unlock_irqrestore(&cnt->lock, flags);
> +       return ret;
> +}
> +
>  static inline void res_counter_reset_max(struct res_counter *cnt)
>  {
>        unsigned long flags;
> @@ -214,4 +269,27 @@ res_counter_set_soft_limit(struct res_co
>        return 0;
>  }
>
> +static inline int
> +res_counter_set_high_wmark_limit(struct res_counter *cnt,
> +                               unsigned long long wmark_limit)
> +{
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&cnt->lock, flags);
> +       cnt->high_wmark_limit = wmark_limit;
> +       spin_unlock_irqrestore(&cnt->lock, flags);
> +       return 0;
> +}
> +
> +static inline int
> +res_counter_set_low_wmark_limit(struct res_counter *cnt,
> +                               unsigned long long wmark_limit)
> +{
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&cnt->lock, flags);
> +       cnt->low_wmark_limit = wmark_limit;
> +       spin_unlock_irqrestore(&cnt->lock, flags);
> +       return 0;
> +}
>  #endif
> Index: memcg/kernel/res_counter.c
> ===================================================================
> --- memcg.orig/kernel/res_counter.c
> +++ memcg/kernel/res_counter.c
> @@ -19,6 +19,8 @@ void res_counter_init(struct res_counter
>        spin_lock_init(&counter->lock);
>        counter->limit = RESOURCE_MAX;
>        counter->soft_limit = RESOURCE_MAX;
> +       counter->low_wmark_limit = RESOURCE_MAX;
> +       counter->high_wmark_limit = RESOURCE_MAX;
>        counter->parent = parent;
>  }
>
> @@ -103,6 +105,10 @@ res_counter_member(struct res_counter *c
>                return &counter->failcnt;
>        case RES_SOFT_LIMIT:
>                return &counter->soft_limit;
> +       case RES_LOW_WMARK_LIMIT:
> +               return &counter->low_wmark_limit;
> +       case RES_HIGH_WMARK_LIMIT:
> +               return &counter->high_wmark_limit;
>        };
>
>        BUG();
> Index: memcg/mm/memcontrol.c
> ===================================================================
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -278,6 +278,11 @@ struct mem_cgroup {
>         */
>        struct mem_cgroup_stat_cpu nocpu_base;
>        spinlock_t pcp_counter_lock;
> +
> +       /*
> +        * used to calculate the low/high_wmarks based on the
> limit_in_bytes.
> +        */
> +       u64 high_wmark_distance;
>  };
>
>  /* Stuffs for move charges at task migration. */
> @@ -867,6 +872,44 @@ out:
>  EXPORT_SYMBOL(mem_cgroup_count_vm_event);
>
>  /*
> + * If Hi-Low distance is too big, background reclaim tend to be cpu
> hogging.
> + * If Hi-Low distance is too small, small memory usage spike (by temporal
> + * shell scripts) causes background reclaim and make thing worse. But
> memory
> + * spike can be avoided by setting high-wmark a bit higier. We use fixed
> size
> + * size of HiLow Distance, this will be easy to use.
> + */
> +#ifdef CONFIG_64BIT /* object size tend do be twice */
> +#define HILOW_DISTANCE (4 * 1024 * 1024)
> +#else
> +#define HILOW_DISTANCE (2 * 1024 * 1024)
> +#endif
> +
> +static void setup_per_memcg_wmarks(struct mem_cgroup *mem)
> +{
> +       u64 limit;
> +
> +       limit = res_counter_read_u64(&mem->res, RES_LIMIT);
> +       if (mem->high_wmark_distance == 0) {
> +               res_counter_set_low_wmark_limit(&mem->res, limit);
> +               res_counter_set_high_wmark_limit(&mem->res, limit);
> +       } else {
> +               u64 low_wmark, high_wmark, low_distance;
> +               if (mem->high_wmark_distance <= HILOW_DISTANCE)
> +                       low_distance = mem->high_wmark_distance / 2;
> +               else
> +                       low_distance = HILOW_DISTANCE;

+               if (low_distance < PAGE_SIZE * 2)
> +                       low_distance = PAGE_SIZE * 2;
> +
> +               low_wmark = limit - low_distance;
>

So the low_distance here is the distance between limit and the low_wmark.
Then, i missed the point where we control the distance between Hi-Low wmark
as in the comments. So here we might have
mem->high_wmark_distance = 4M + 1page
low_distance = 4M

--Ying


> +               high_wmark = limit - mem->high_wmark_distance;
> +
> +               res_counter_set_low_wmark_limit(&mem->res, low_wmark);
> +               res_counter_set_high_wmark_limit(&mem->res, high_wmark);
> +       }
> +}
> +
> +/*
>  * Following LRU functions are allowed to be used without PCG_LOCK.
>  * Operations are called by routine of global LRU independently from memcg.
>  * What we have to take care of here is validness of pc->mem_cgroup.
> @@ -3264,6 +3307,7 @@ static int mem_cgroup_resize_limit(struc
>                        else
>                                memcg->memsw_is_minimum = false;
>                }
> +               setup_per_memcg_wmarks(memcg);
>                mutex_unlock(&set_limit_mutex);
>
>                if (!ret)
> @@ -3324,6 +3368,7 @@ static int mem_cgroup_resize_memsw_limit
>                        else
>                                memcg->memsw_is_minimum = false;
>                }
> +               setup_per_memcg_wmarks(memcg);
>                mutex_unlock(&set_limit_mutex);
>
>                if (!ret)
> @@ -4603,6 +4648,30 @@ static void __init enable_swap_cgroup(vo
>  }
>  #endif
>
> +/*
> + * We use low_wmark and high_wmark for triggering per-memcg kswapd.
> + * The reclaim is triggered by low_wmark (usage > low_wmark) and stopped
> + * by high_wmark (usage < high_wmark).
> + */
> +int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
> +                               int charge_flags)
> +{
> +       long ret = 0;
> +       int flags = CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;
> +
> +       if (!mem->high_wmark_distance)
> +               return 1;
> +
> +       VM_BUG_ON((charge_flags & flags) == flags);
> +
> +       if (charge_flags & CHARGE_WMARK_LOW)
> +               ret = res_counter_under_low_wmark_limit(&mem->res);
> +       if (charge_flags & CHARGE_WMARK_HIGH)
> +               ret = res_counter_under_high_wmark_limit(&mem->res);
> +
> +       return ret;
> +}
> +
>  static int mem_cgroup_soft_limit_tree_init(void)
>  {
>        struct mem_cgroup_tree_per_node *rtpn;
>
>

--000e0ce008bc2f00a404a1d6031a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 25, 2011 at 2:28 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
There are two watermarks added per-memcg including &quot;high_wmark&quot; a=
nd &quot;low_wmark&quot;.<br>
The per-memcg kswapd is invoked when the memcg&#39;s memory usage(usage_in_=
bytes)<br>
is higher than the low_wmark. Then the kswapd thread starts to reclaim page=
s<br>
until the usage is lower than the high_wmark.<br>
<br>
Each watermark is calculated based on the hard_limit(limit_in_bytes) for ea=
ch<br>
memcg. Each time the hard_limit is changed, the corresponding wmarks are<br=
>
re-calculated. Since memory controller charges only user pages, there is<br=
>
no need for a &quot;min_wmark&quot;. The current calculation of wmarks is b=
ased on<br>
individual tunable high_wmark_distance, which are set to 0 by default.<br>
low_wmark is calculated in automatic way.<br>
<br>
Changelog:v8b...v7<br>
1. set low_wmark_distance in automatic using fixed HILOW_DISTANCE.<br>
<br>
Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@g=
oogle.com</a>&gt;<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h =A0| =A0 =A01<br>
=A0include/linux/res_counter.h | =A0 78 +++++++++++++++++++++++++++++++++++=
+++++++++<br>
=A0kernel/res_counter.c =A0 =A0 =A0 =A0| =A0 =A06 +++<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 69 +++++++++++++++++++++++=
+++++++++++++++<br>
=A04 files changed, 154 insertions(+)<br>
<br>
Index: memcg/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/include/linux/memcontrol.h<br>
+++ memcg/include/linux/memcontrol.h<br>
@@ -84,6 +84,7 @@ int task_in_mem_cgroup(struct task_struc<br>
<br>
=A0extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page=
);<br>
=A0extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);<b=
r>
+extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flag=
s);<br>
<br>
=A0static inline<br>
=A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup =
*cgroup)<br>
Index: memcg/include/linux/res_counter.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/include/linux/res_counter.h<br>
+++ memcg/include/linux/res_counter.h<br>
@@ -39,6 +39,14 @@ struct res_counter {<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0unsigned long long soft_limit;<br>
 =A0 =A0 =A0 =A0/*<br>
+ =A0 =A0 =A0 =A0* the limit that reclaim triggers.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 unsigned long long low_wmark_limit;<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* the limit that reclaim stops.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 unsigned long long high_wmark_limit;<br>
+ =A0 =A0 =A0 /*<br>
 =A0 =A0 =A0 =A0 * the number of unsuccessful attempts to consume the resou=
rce<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0unsigned long long failcnt;<br>
@@ -55,6 +63,9 @@ struct res_counter {<br>
<br>
=A0#define RESOURCE_MAX (unsigned long long)LLONG_MAX<br>
<br>
+#define CHARGE_WMARK_LOW =A0 =A0 =A0 0x01<br>
+#define CHARGE_WMARK_HIGH =A0 =A0 =A00x02<br>
+<br>
=A0/**<br>
 =A0* Helpers to interact with userspace<br>
 =A0* res_counter_read_u64() - returns the value of the specified member.<b=
r>
@@ -92,6 +103,8 @@ enum {<br>
 =A0 =A0 =A0 =A0RES_LIMIT,<br>
 =A0 =A0 =A0 =A0RES_FAILCNT,<br>
 =A0 =A0 =A0 =A0RES_SOFT_LIMIT,<br>
+ =A0 =A0 =A0 RES_LOW_WMARK_LIMIT,<br>
+ =A0 =A0 =A0 RES_HIGH_WMARK_LIMIT<br>
=A0};<br>
<br>
=A0/*<br>
@@ -147,6 +160,24 @@ static inline unsigned long long res_cou<br>
 =A0 =A0 =A0 =A0return margin;<br>
=A0}<br>
<br>
+static inline bool<br>
+res_counter_under_high_wmark_limit_check_locked(struct res_counter *cnt)<b=
r>
+{<br>
+ =A0 =A0 =A0 if (cnt-&gt;usage &lt; cnt-&gt;high_wmark_limit)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;<br>
+<br>
+ =A0 =A0 =A0 return false;<br>
+}<br>
+<br>
+static inline bool<br>
+res_counter_under_low_wmark_limit_check_locked(struct res_counter *cnt)<br=
>
+{<br>
+ =A0 =A0 =A0 if (cnt-&gt;usage &lt; cnt-&gt;low_wmark_limit)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;<br>
+<br>
+ =A0 =A0 =A0 return false;<br>
+}<br>
+<br>
=A0/**<br>
 =A0* Get the difference between the usage and the soft limit<br>
 =A0* @cnt: The counter<br>
@@ -169,6 +200,30 @@ res_counter_soft_limit_excess(struct res<br>
 =A0 =A0 =A0 =A0return excess;<br>
=A0}<br>
<br>
+static inline bool<br>
+res_counter_under_low_wmark_limit(struct res_counter *cnt)<br>
+{<br>
+ =A0 =A0 =A0 bool ret;<br>
+ =A0 =A0 =A0 unsigned long flags;<br>
+<br>
+ =A0 =A0 =A0 spin_lock_irqsave(&amp;cnt-&gt;lock, flags);<br>
+ =A0 =A0 =A0 ret =3D res_counter_under_low_wmark_limit_check_locked(cnt);<=
br>
+ =A0 =A0 =A0 spin_unlock_irqrestore(&amp;cnt-&gt;lock, flags);<br>
+ =A0 =A0 =A0 return ret;<br>
+}<br>
+<br>
+static inline bool<br>
+res_counter_under_high_wmark_limit(struct res_counter *cnt)<br>
+{<br>
+ =A0 =A0 =A0 bool ret;<br>
+ =A0 =A0 =A0 unsigned long flags;<br>
+<br>
+ =A0 =A0 =A0 spin_lock_irqsave(&amp;cnt-&gt;lock, flags);<br>
+ =A0 =A0 =A0 ret =3D res_counter_under_high_wmark_limit_check_locked(cnt);=
<br>
+ =A0 =A0 =A0 spin_unlock_irqrestore(&amp;cnt-&gt;lock, flags);<br>
+ =A0 =A0 =A0 return ret;<br>
+}<br>
+<br>
=A0static inline void res_counter_reset_max(struct res_counter *cnt)<br>
=A0{<br>
 =A0 =A0 =A0 =A0unsigned long flags;<br>
@@ -214,4 +269,27 @@ res_counter_set_soft_limit(struct res_co<br>
 =A0 =A0 =A0 =A0return 0;<br>
=A0}<br>
<br>
+static inline int<br>
+res_counter_set_high_wmark_limit(struct res_counter *cnt,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 long wmark_limit)<br>
+{<br>
+ =A0 =A0 =A0 unsigned long flags;<br>
+<br>
+ =A0 =A0 =A0 spin_lock_irqsave(&amp;cnt-&gt;lock, flags);<br>
+ =A0 =A0 =A0 cnt-&gt;high_wmark_limit =3D wmark_limit;<br>
+ =A0 =A0 =A0 spin_unlock_irqrestore(&amp;cnt-&gt;lock, flags);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+static inline int<br>
+res_counter_set_low_wmark_limit(struct res_counter *cnt,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 long wmark_limit)<br>
+{<br>
+ =A0 =A0 =A0 unsigned long flags;<br>
+<br>
+ =A0 =A0 =A0 spin_lock_irqsave(&amp;cnt-&gt;lock, flags);<br>
+ =A0 =A0 =A0 cnt-&gt;low_wmark_limit =3D wmark_limit;<br>
+ =A0 =A0 =A0 spin_unlock_irqrestore(&amp;cnt-&gt;lock, flags);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
=A0#endif<br>
Index: memcg/kernel/res_counter.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/kernel/res_counter.c<br>
+++ memcg/kernel/res_counter.c<br>
@@ -19,6 +19,8 @@ void res_counter_init(struct res_counter<br>
 =A0 =A0 =A0 =A0spin_lock_init(&amp;counter-&gt;lock);<br>
 =A0 =A0 =A0 =A0counter-&gt;limit =3D RESOURCE_MAX;<br>
 =A0 =A0 =A0 =A0counter-&gt;soft_limit =3D RESOURCE_MAX;<br>
+ =A0 =A0 =A0 counter-&gt;low_wmark_limit =3D RESOURCE_MAX;<br>
+ =A0 =A0 =A0 counter-&gt;high_wmark_limit =3D RESOURCE_MAX;<br>
 =A0 =A0 =A0 =A0counter-&gt;parent =3D parent;<br>
=A0}<br>
<br>
@@ -103,6 +105,10 @@ res_counter_member(struct res_counter *c<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return &amp;counter-&gt;failcnt;<br>
 =A0 =A0 =A0 =A0case RES_SOFT_LIMIT:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return &amp;counter-&gt;soft_limit;<br>
+ =A0 =A0 =A0 case RES_LOW_WMARK_LIMIT:<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &amp;counter-&gt;low_wmark_limit;<br>
+ =A0 =A0 =A0 case RES_HIGH_WMARK_LIMIT:<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return &amp;counter-&gt;high_wmark_limit;<br>
 =A0 =A0 =A0 =A0};<br>
<br>
 =A0 =A0 =A0 =A0BUG();<br>
Index: memcg/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/memcontrol.c<br>
+++ memcg/mm/memcontrol.c<br>
@@ -278,6 +278,11 @@ struct mem_cgroup {<br>
 =A0 =A0 =A0 =A0 */<br>
 =A0 =A0 =A0 =A0struct mem_cgroup_stat_cpu nocpu_base;<br>
 =A0 =A0 =A0 =A0spinlock_t pcp_counter_lock;<br>
+<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* used to calculate the low/high_wmarks based on the limit=
_in_bytes.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 u64 high_wmark_distance;<br>
=A0};<br>
<br>
=A0/* Stuffs for move charges at task migration. */<br>
@@ -867,6 +872,44 @@ out:<br>
=A0EXPORT_SYMBOL(mem_cgroup_count_vm_event);<br>
<br>
=A0/*<br>
+ * If Hi-Low distance is too big, background reclaim tend to be cpu hoggin=
g.<br>
+ * If Hi-Low distance is too small, small memory usage spike (by temporal<=
br>
+ * shell scripts) causes background reclaim and make thing worse. But memo=
ry<br>
+ * spike can be avoided by setting high-wmark a bit higier. We use fixed s=
ize<br>
+ * size of HiLow Distance, this will be easy to use.<br>
+ */<br>
+#ifdef CONFIG_64BIT /* object size tend do be twice */<br>
+#define HILOW_DISTANCE (4 * 1024 * 1024)<br>
+#else<br>
+#define HILOW_DISTANCE (2 * 1024 * 1024)<br>
+#endif<br>
+<br>
+static void setup_per_memcg_wmarks(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 u64 limit;<br>
+<br>
+ =A0 =A0 =A0 limit =3D res_counter_read_u64(&amp;mem-&gt;res, RES_LIMIT);<=
br>
+ =A0 =A0 =A0 if (mem-&gt;high_wmark_distance =3D=3D 0) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_low_wmark_limit(&amp;mem-&gt;=
res, limit);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_high_wmark_limit(&amp;mem-&gt=
;res, limit);<br>
+ =A0 =A0 =A0 } else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 low_wmark, high_wmark, low_distance;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem-&gt;high_wmark_distance &lt;=3D HILOW=
_DISTANCE)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 low_distance =3D mem-&gt;high=
_wmark_distance / 2;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 low_distance =3D HILOW_DISTAN=
CE;=A0</blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex;">
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (low_distance &lt; PAGE_SIZE * 2)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 low_distance =3D PAGE_SIZE * =
2;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 low_wmark =3D limit - low_distance;<br></bloc=
kquote><div><br></div><div>So the low_distance here is the distance between=
 limit and the low_wmark. Then, i missed the point where we control the dis=
tance between Hi-Low wmark as in the comments. So here we might have=A0</di=
v>
<div><meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-=
8">mem-&gt;high_wmark_distance =3D 4M + 1page</div><div>low_distance =3D 4M=
</div><div><br></div><div>--Ying</div><div>=A0</div><blockquote class=3D"gm=
ail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex;">

+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 high_wmark =3D limit - mem-&gt;high_wmark_dis=
tance;<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_low_wmark_limit(&amp;mem-&gt;=
res, low_wmark);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_set_high_wmark_limit(&amp;mem-&gt=
;res, high_wmark);<br>
+ =A0 =A0 =A0 }<br>
+}<br>
+<br>
+/*<br>
 =A0* Following LRU functions are allowed to be used without PCG_LOCK.<br>
 =A0* Operations are called by routine of global LRU independently from mem=
cg.<br>
 =A0* What we have to take care of here is validness of pc-&gt;mem_cgroup.<=
br>
@@ -3264,6 +3307,7 @@ static int mem_cgroup_resize_limit(struc<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg-&gt;m=
emsw_is_minimum =3D false;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&amp;set_limit_mutex);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)<br>
@@ -3324,6 +3368,7 @@ static int mem_cgroup_resize_memsw_limit<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg-&gt;m=
emsw_is_minimum =3D false;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&amp;set_limit_mutex);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret)<br>
@@ -4603,6 +4648,30 @@ static void __init enable_swap_cgroup(vo<br>
=A0}<br>
=A0#endif<br>
<br>
+/*<br>
+ * We use low_wmark and high_wmark for triggering per-memcg kswapd.<br>
+ * The reclaim is triggered by low_wmark (usage &gt; low_wmark) and stoppe=
d<br>
+ * by high_wmark (usage &lt; high_wmark).<br>
+ */<br>
+int mem_cgroup_watermark_ok(struct mem_cgroup *mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int charge_fl=
ags)<br>
+{<br>
+ =A0 =A0 =A0 long ret =3D 0;<br>
+ =A0 =A0 =A0 int flags =3D CHARGE_WMARK_LOW | CHARGE_WMARK_HIGH;<br>
+<br>
+ =A0 =A0 =A0 if (!mem-&gt;high_wmark_distance)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;<br>
+<br>
+ =A0 =A0 =A0 VM_BUG_ON((charge_flags &amp; flags) =3D=3D flags);<br>
+<br>
+ =A0 =A0 =A0 if (charge_flags &amp; CHARGE_WMARK_LOW)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_under_low_wmark_limit(&am=
p;mem-&gt;res);<br>
+ =A0 =A0 =A0 if (charge_flags &amp; CHARGE_WMARK_HIGH)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_under_high_wmark_limit(&a=
mp;mem-&gt;res);<br>
+<br>
+ =A0 =A0 =A0 return ret;<br>
+}<br>
+<br>
=A0static int mem_cgroup_soft_limit_tree_init(void)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct mem_cgroup_tree_per_node *rtpn;<br>
<br>
</blockquote></div><br>

--000e0ce008bc2f00a404a1d6031a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
