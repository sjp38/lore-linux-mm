Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 22DD990010D
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 19:19:47 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p3QNJhS9014130
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:19:43 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by wpaz33.hot.corp.google.com with ESMTP id p3QNIocJ009847
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:19:42 -0700
Received: by qwf7 with SMTP id 7so693360qwf.24
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:19:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425184219.285c2396.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425184219.285c2396.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 16:19:41 -0700
Message-ID: <BANLkTikB_4DXw2hPkBW4DDB1ZnXAJuSLKQ@mail.gmail.com>
Subject: Re: [PATCH 7/7] memcg watermark reclaim workqueue.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c0e58e104a1da8f14
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

--0016360e3f5c0e58e104a1da8f14
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Apr 25, 2011 at 2:42 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> By default the per-memcg background reclaim is disabled when the
> limit_in_bytes
> is set the maximum. The kswapd_run() is called when the memcg is being
> resized,
> and kswapd_stop() is called when the memcg is being deleted.
>
> The per-memcg kswapd is waked up based on the usage and low_wmark, which is
> checked once per 1024 increments per cpu. The memcg's kswapd is waked up if
> the
> usage is larger than the low_wmark.
>
> At each iteration of work, the work frees memory at most 2048 pages and
> switch
> to next work for round robin. And if the memcg seems congested, it adds
> delay for the next work.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    2 -
>  mm/memcontrol.c            |   86
> +++++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                |   23 +++++++-----
>  3 files changed, 102 insertions(+), 9 deletions(-)
>
> Index: memcg/mm/memcontrol.c
> ===================================================================
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -111,10 +111,12 @@ enum mem_cgroup_events_index {
>  enum mem_cgroup_events_target {
>        MEM_CGROUP_TARGET_THRESH,
>        MEM_CGROUP_TARGET_SOFTLIMIT,
> +       MEM_CGROUP_WMARK_EVENTS_THRESH,
>        MEM_CGROUP_NTARGETS,
>  };
>  #define THRESHOLDS_EVENTS_TARGET (128)
>  #define SOFTLIMIT_EVENTS_TARGET (1024)
> +#define WMARK_EVENTS_TARGET (1024)
>
>  struct mem_cgroup_stat_cpu {
>        long count[MEM_CGROUP_STAT_NSTATS];
> @@ -267,6 +269,11 @@ struct mem_cgroup {
>        struct list_head oom_notify;
>
>        /*
> +        * For high/low watermark.
> +        */
> +       bool                    bgreclaim_resched;
> +       struct delayed_work     bgreclaim_work;
> +       /*
>         * Should we move charges of a task when a task is moved into this
>         * mem_cgroup ? And what type of charges should we move ?
>         */
> @@ -374,6 +381,8 @@ static void mem_cgroup_put(struct mem_cg
>  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
>  static void drain_all_stock_async(void);
>
> +static void wake_memcg_kswapd(struct mem_cgroup *mem);
> +
>  static struct mem_cgroup_per_zone *
>  mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
>  {
> @@ -552,6 +561,12 @@ mem_cgroup_largest_soft_limit_node(struc
>        return mz;
>  }
>
> +static void mem_cgroup_check_wmark(struct mem_cgroup *mem)
> +{
> +       if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_LOW))
> +               wake_memcg_kswapd(mem);
> +}
> +
>  /*
>  * Implementation Note: reading percpu statistics for memcg.
>  *
> @@ -702,6 +717,9 @@ static void __mem_cgroup_target_update(s
>        case MEM_CGROUP_TARGET_SOFTLIMIT:
>                next = val + SOFTLIMIT_EVENTS_TARGET;
>                break;
> +       case MEM_CGROUP_WMARK_EVENTS_THRESH:
> +               next = val + WMARK_EVENTS_TARGET;
> +               break;
>        default:
>                return;
>        }
> @@ -725,6 +743,10 @@ static void memcg_check_events(struct me
>                        __mem_cgroup_target_update(mem,
>                                MEM_CGROUP_TARGET_SOFTLIMIT);
>                }
> +               if (unlikely(__memcg_event_check(mem,
> +                       MEM_CGROUP_WMARK_EVENTS_THRESH))){
> +                       mem_cgroup_check_wmark(mem);
> +               }
>        }
>  }
>
> @@ -3661,6 +3683,67 @@ unsigned long mem_cgroup_soft_limit_recl
>        return nr_reclaimed;
>  }
>
> +struct workqueue_struct *memcg_bgreclaimq;
> +
> +static int memcg_bgreclaim_init(void)
> +{
> +       /*
> +        * use UNBOUND workqueue because we traverse nodes (no locality)
> and
> +        * the work is cpu-intensive.
> +        */
> +       memcg_bgreclaimq = alloc_workqueue("memcg",
> +                       WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_FREEZABLE, 0);
> +       return 0;
> +}
>

I read about the documentation of workqueue. So the WQ_UNBOUND support the
max 512 execution contexts per CPU. Does the execution context means thread?

I think I understand the motivation of that flag, so we can have more
concurrency of bg reclaim workitems. But one question is on the workqueue
scheduling mechanism. If we can queue the item anywhere as long as they are
inserted in the queue, do we have mechanism to support the load balancing
like the system scheduler? The scenario I am thinking is that one CPU has
512 work items and the other one has 1.

I don't think this is directly related issue for this patch, and I just hope
the workqueue mechanism already support something like that for load
balancing.

--Ying



> +module_init(memcg_bgreclaim_init);
> +
> +static void memcg_bgreclaim(struct work_struct *work)
> +{
> +       struct delayed_work *dw = to_delayed_work(work);
> +       struct mem_cgroup *mem =
> +               container_of(dw, struct mem_cgroup, bgreclaim_work);
> +       int delay = 0;
> +       unsigned long long required, usage, hiwat;
> +
> +       hiwat = res_counter_read_u64(&mem->res, RES_HIGH_WMARK_LIMIT);
> +       usage = res_counter_read_u64(&mem->res, RES_USAGE);
> +       required = usage - hiwat;
> +       if (required >= 0)  {
> +               required = ((usage - hiwat) >> PAGE_SHIFT) + 1;
> +               delay = shrink_mem_cgroup(mem, (long)required);
> +       }
> +       if (!mem->bgreclaim_resched  ||
> +               mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH)) {
> +               cgroup_release_and_wakeup_rmdir(&mem->css);
> +               return;
> +       }
> +       /* need reschedule */
> +       if (!queue_delayed_work(memcg_bgreclaimq, &mem->bgreclaim_work,
> delay))
> +               cgroup_release_and_wakeup_rmdir(&mem->css);
> +}
> +
> +static void wake_memcg_kswapd(struct mem_cgroup *mem)
> +{
> +       if (delayed_work_pending(&mem->bgreclaim_work))
> +               return;
> +       cgroup_exclude_rmdir(&mem->css);
> +       if (!queue_delayed_work(memcg_bgreclaimq, &mem->bgreclaim_work, 0))
> +               cgroup_release_and_wakeup_rmdir(&mem->css);
> +       return;
> +}
> +
> +static void stop_memcg_kswapd(struct mem_cgroup *mem)
> +{
> +       /*
> +        * at destroy(), there is no task and we don't need to take care of
> +        * new bgreclaim work queued. But we need to prevent it from
> reschedule
> +        * use bgreclaim_resched to tell no more reschedule.
> +        */
> +       mem->bgreclaim_resched = false;
> +       flush_delayed_work(&mem->bgreclaim_work);
> +       mem->bgreclaim_resched = true;
> +}
> +
>  /*
>  * This routine traverse page_cgroup in given list and drop them all.
>  * *And* this routine doesn't reclaim page itself, just removes
> page_cgroup.
> @@ -3742,6 +3825,7 @@ move_account:
>                ret = -EBUSY;
>                if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
>                        goto out;
> +               stop_memcg_kswapd(mem);
>                ret = -EINTR;
>                if (signal_pending(current))
>                        goto out;
> @@ -4804,6 +4888,8 @@ static struct mem_cgroup *mem_cgroup_all
>        if (!mem->stat)
>                goto out_free;
>        spin_lock_init(&mem->pcp_counter_lock);
> +       INIT_DELAYED_WORK(&mem->bgreclaim_work, memcg_bgreclaim);
> +       mem->bgreclaim_resched = true;
>        return mem;
>
>  out_free:
> Index: memcg/include/linux/memcontrol.h
> ===================================================================
> --- memcg.orig/include/linux/memcontrol.h
> +++ memcg/include/linux/memcontrol.h
> @@ -89,7 +89,7 @@ extern int mem_cgroup_last_scanned_node(
>  extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
>                                        const nodemask_t *nodes);
>
> -unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);
> +int shrink_mem_cgroup(struct mem_cgroup *mem, long required);
>
>  static inline
>  int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup
> *cgroup)
> Index: memcg/mm/vmscan.c
> ===================================================================
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -2373,20 +2373,19 @@ shrink_memcg_node(int nid, int priority,
>  /*
>  * Per cgroup background reclaim.
>  */
> -unsigned long shrink_mem_cgroup(struct mem_cgroup *mem)
> +int shrink_mem_cgroup(struct mem_cgroup *mem, long required)
>  {
> -       int nid, priority, next_prio;
> +       int nid, priority, next_prio, delay;
>        nodemask_t nodes;
>        unsigned long total_scanned;
>        struct scan_control sc = {
>                .gfp_mask = GFP_HIGHUSER_MOVABLE,
>                .may_unmap = 1,
>                .may_swap = 1,
> -               .nr_to_reclaim = SWAP_CLUSTER_MAX,
>                .order = 0,
>                .mem_cgroup = mem,
>        };
> -
> +       /* writepage will be set later per zone */
>        sc.may_writepage = 0;
>        sc.nr_reclaimed = 0;
>        total_scanned = 0;
> @@ -2400,9 +2399,12 @@ unsigned long shrink_mem_cgroup(struct m
>         * Now, we scan MEMCG_BGRECLAIM_SCAN_LIMIT pages per scan.
>         * We use static priority 0.
>         */
> +       sc.nr_to_reclaim = min(required, (long)MEMCG_BGSCAN_LIMIT/2);
>        next_prio = min(SWAP_CLUSTER_MAX * num_node_state(N_HIGH_MEMORY),
>                        MEMCG_BGSCAN_LIMIT/8);
>        priority = DEF_PRIORITY;
> +       /* delay for next work at congestion */
> +       delay = HZ/10;
>        while ((total_scanned < MEMCG_BGSCAN_LIMIT) &&
>               !nodes_empty(nodes) &&
>               (sc.nr_to_reclaim > sc.nr_reclaimed)) {
> @@ -2423,12 +2425,17 @@ unsigned long shrink_mem_cgroup(struct m
>                        priority--;
>                        next_prio <<= 1;
>                }
> -               if (sc.nr_scanned &&
> -                   total_scanned > sc.nr_reclaimed * 2)
> -                       congestion_wait(WRITE, HZ/10);
> +               /* give up early ? */
> +               if (total_scanned > MEMCG_BGSCAN_LIMIT/8 &&
> +                   total_scanned > sc.nr_reclaimed * 4)
> +                       goto out;
>        }
> +       /* We scanned enough...If we reclaimed half of requested, no delay
> */
> +       if (sc.nr_reclaimed > sc.nr_to_reclaim/2)
> +               delay = 0;
> +out:
>        current->flags &= ~PF_SWAPWRITE;
> -       return sc.nr_reclaimed;
> +       return delay;
>  }
>  #endif
>
>
>

--0016360e3f5c0e58e104a1da8f14
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, Apr 25, 2011 at 2:42 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
By default the per-memcg background reclaim is disabled when the limit_in_b=
ytes<br>
is set the maximum. The kswapd_run() is called when the memcg is being resi=
zed,<br>
and kswapd_stop() is called when the memcg is being deleted.<br>
<br>
The per-memcg kswapd is waked up based on the usage and low_wmark, which is=
<br>
checked once per 1024 increments per cpu. The memcg&#39;s kswapd is waked u=
p if the<br>
usage is larger than the low_wmark.<br>
<br>
At each iteration of work, the work frees memory at most 2048 pages and swi=
tch<br>
to next work for round robin. And if the memcg seems congested, it adds<br>
delay for the next work.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 =A02 -<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 86 ++++++++++++++++++++++++=
+++++++++++++++++++++<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 23 +++++++-----<br>
=A03 files changed, 102 insertions(+), 9 deletions(-)<br>
<br>
Index: memcg/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/memcontrol.c<br>
+++ memcg/mm/memcontrol.c<br>
@@ -111,10 +111,12 @@ enum mem_cgroup_events_index {<br>
=A0enum mem_cgroup_events_target {<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_THRESH,<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_TARGET_SOFTLIMIT,<br>
+ =A0 =A0 =A0 MEM_CGROUP_WMARK_EVENTS_THRESH,<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_NTARGETS,<br>
=A0};<br>
=A0#define THRESHOLDS_EVENTS_TARGET (128)<br>
=A0#define SOFTLIMIT_EVENTS_TARGET (1024)<br>
+#define WMARK_EVENTS_TARGET (1024)<br>
<br>
=A0struct mem_cgroup_stat_cpu {<br>
 =A0 =A0 =A0 =A0long count[MEM_CGROUP_STAT_NSTATS];<br>
@@ -267,6 +269,11 @@ struct mem_cgroup {<br>
 =A0 =A0 =A0 =A0struct list_head oom_notify;<br>
<br>
 =A0 =A0 =A0 =A0/*<br>
+ =A0 =A0 =A0 =A0* For high/low watermark.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bgreclaim_resched=
;<br>
+ =A0 =A0 =A0 struct delayed_work =A0 =A0 bgreclaim_work;<br>
+ =A0 =A0 =A0 /*<br>
 =A0 =A0 =A0 =A0 * Should we move charges of a task when a task is moved in=
to this<br>
 =A0 =A0 =A0 =A0 * mem_cgroup ? And what type of charges should we move ?<b=
r>
 =A0 =A0 =A0 =A0 */<br>
@@ -374,6 +381,8 @@ static void mem_cgroup_put(struct mem_cg<br>
=A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);<br>
=A0static void drain_all_stock_async(void);<br>
<br>
+static void wake_memcg_kswapd(struct mem_cgroup *mem);<br>
+<br>
=A0static struct mem_cgroup_per_zone *<br>
=A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)<br>
=A0{<br>
@@ -552,6 +561,12 @@ mem_cgroup_largest_soft_limit_node(struc<br>
 =A0 =A0 =A0 =A0return mz;<br>
=A0}<br>
<br>
+static void mem_cgroup_check_wmark(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_LOW))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_memcg_kswapd(mem);<br>
+}<br>
+<br>
=A0/*<br>
 =A0* Implementation Note: reading percpu statistics for memcg.<br>
 =A0*<br>
@@ -702,6 +717,9 @@ static void __mem_cgroup_target_update(s<br>
 =A0 =A0 =A0 =A0case MEM_CGROUP_TARGET_SOFTLIMIT:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next =3D val + SOFTLIMIT_EVENTS_TARGET;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
+ =A0 =A0 =A0 case MEM_CGROUP_WMARK_EVENTS_THRESH:<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D val + WMARK_EVENTS_TARGET;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
 =A0 =A0 =A0 =A0default:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
 =A0 =A0 =A0 =A0}<br>
@@ -725,6 +743,10 @@ static void memcg_check_events(struct me<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgroup_target_update(=
mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_=
TARGET_SOFTLIMIT);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(__memcg_event_check(mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_WMARK_EVENTS_THRES=
H))){<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_check_wmark(mem);<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
 =A0 =A0 =A0 =A0}<br>
=A0}<br>
<br>
@@ -3661,6 +3683,67 @@ unsigned long mem_cgroup_soft_limit_recl<br>
 =A0 =A0 =A0 =A0return nr_reclaimed;<br>
=A0}<br>
<br>
+struct workqueue_struct *memcg_bgreclaimq;<br>
+<br>
+static int memcg_bgreclaim_init(void)<br>
+{<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* use UNBOUND workqueue because we traverse nodes (no loca=
lity) and<br>
+ =A0 =A0 =A0 =A0* the work is cpu-intensive.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 memcg_bgreclaimq =3D alloc_workqueue(&quot;memcg&quot;,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WQ_MEM_RECLAIM | WQ_UNBOUND |=
 WQ_FREEZABLE, 0);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br></blockquote><div><br></div><div>I read about the=A0documentation=A0o=
f workqueue. So the WQ_UNBOUND support the max 512=A0execution contexts per=
 CPU. Does the execution context means thread?</div><div><br></div><div>I t=
hink I understand the motivation of that flag, so we can have more concurre=
ncy of bg reclaim workitems. But one question is on the workqueue schedulin=
g mechanism. If we can queue the item anywhere as long as they are inserted=
 in the queue, do we have=A0mechanism=A0to support the load balancing like =
the system scheduler? The=A0scenario I am thinking is that one CPU has 512 =
work items and the other one has 1.=A0</div>
<div><br></div><div>I don&#39;t think this is directly related issue for th=
is patch, and I just hope the workqueue mechanism already support something=
 like that for load balancing.</div><div><br></div><div>--Ying</div><div>
=A0</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 =
0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
+module_init(memcg_bgreclaim_init);<br>
+<br>
+static void memcg_bgreclaim(struct work_struct *work)<br>
+{<br>
+ =A0 =A0 =A0 struct delayed_work *dw =3D to_delayed_work(work);<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 container_of(dw, struct mem_cgroup, bgreclaim=
_work);<br>
+ =A0 =A0 =A0 int delay =3D 0;<br>
+ =A0 =A0 =A0 unsigned long long required, usage, hiwat;<br>
+<br>
+ =A0 =A0 =A0 hiwat =3D res_counter_read_u64(&amp;mem-&gt;res, RES_HIGH_WMA=
RK_LIMIT);<br>
+ =A0 =A0 =A0 usage =3D res_counter_read_u64(&amp;mem-&gt;res, RES_USAGE);<=
br>
+ =A0 =A0 =A0 required =3D usage - hiwat;<br>
+ =A0 =A0 =A0 if (required &gt;=3D 0) =A0{<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 required =3D ((usage - hiwat) &gt;&gt; PAGE_S=
HIFT) + 1;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 delay =3D shrink_mem_cgroup(mem, (long)requir=
ed);<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 if (!mem-&gt;bgreclaim_resched =A0||<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIG=
H)) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_release_and_wakeup_rmdir(&amp;mem-&gt;=
css);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 /* need reschedule */<br>
+ =A0 =A0 =A0 if (!queue_delayed_work(memcg_bgreclaimq, &amp;mem-&gt;bgrecl=
aim_work, delay))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_release_and_wakeup_rmdir(&amp;mem-&gt;=
css);<br>
+}<br>
+<br>
+static void wake_memcg_kswapd(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 if (delayed_work_pending(&amp;mem-&gt;bgreclaim_work))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
+ =A0 =A0 =A0 cgroup_exclude_rmdir(&amp;mem-&gt;css);<br>
+ =A0 =A0 =A0 if (!queue_delayed_work(memcg_bgreclaimq, &amp;mem-&gt;bgrecl=
aim_work, 0))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_release_and_wakeup_rmdir(&amp;mem-&gt;=
css);<br>
+ =A0 =A0 =A0 return;<br>
+}<br>
+<br>
+static void stop_memcg_kswapd(struct mem_cgroup *mem)<br>
+{<br>
+ =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0* at destroy(), there is no task and we don&#39;t need to =
take care of<br>
+ =A0 =A0 =A0 =A0* new bgreclaim work queued. But we need to prevent it fro=
m reschedule<br>
+ =A0 =A0 =A0 =A0* use bgreclaim_resched to tell no more reschedule.<br>
+ =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 mem-&gt;bgreclaim_resched =3D false;<br>
+ =A0 =A0 =A0 flush_delayed_work(&amp;mem-&gt;bgreclaim_work);<br>
+ =A0 =A0 =A0 mem-&gt;bgreclaim_resched =3D true;<br>
+}<br>
+<br>
=A0/*<br>
 =A0* This routine traverse page_cgroup in given list and drop them all.<br=
>
 =A0* *And* this routine doesn&#39;t reclaim page itself, just removes page=
_cgroup.<br>
@@ -3742,6 +3825,7 @@ move_account:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EBUSY;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cgroup_task_count(cgrp) || !list_empty(=
&amp;cgrp-&gt;children))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 stop_memcg_kswapd(mem);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EINTR;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (signal_pending(current))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
@@ -4804,6 +4888,8 @@ static struct mem_cgroup *mem_cgroup_all<br>
 =A0 =A0 =A0 =A0if (!mem-&gt;stat)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free;<br>
 =A0 =A0 =A0 =A0spin_lock_init(&amp;mem-&gt;pcp_counter_lock);<br>
+ =A0 =A0 =A0 INIT_DELAYED_WORK(&amp;mem-&gt;bgreclaim_work, memcg_bgreclai=
m);<br>
+ =A0 =A0 =A0 mem-&gt;bgreclaim_resched =3D true;<br>
 =A0 =A0 =A0 =A0return mem;<br>
<br>
=A0out_free:<br>
Index: memcg/include/linux/memcontrol.h<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/include/linux/memcontrol.h<br>
+++ memcg/include/linux/memcontrol.h<br>
@@ -89,7 +89,7 @@ extern int mem_cgroup_last_scanned_node(<br>
=A0extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0const nodemask_t *nodes);<br>
<br>
-unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);<br>
+int shrink_mem_cgroup(struct mem_cgroup *mem, long required);<br>
<br>
=A0static inline<br>
=A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup =
*cgroup)<br>
Index: memcg/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/vmscan.c<br>
+++ memcg/mm/vmscan.c<br>
@@ -2373,20 +2373,19 @@ shrink_memcg_node(int nid, int priority,<br>
=A0/*<br>
 =A0* Per cgroup background reclaim.<br>
 =A0*/<br>
-unsigned long shrink_mem_cgroup(struct mem_cgroup *mem)<br>
+int shrink_mem_cgroup(struct mem_cgroup *mem, long required)<br>
=A0{<br>
- =A0 =A0 =A0 int nid, priority, next_prio;<br>
+ =A0 =A0 =A0 int nid, priority, next_prio, delay;<br>
 =A0 =A0 =A0 =A0nodemask_t nodes;<br>
 =A0 =A0 =A0 =A0unsigned long total_scanned;<br>
 =A0 =A0 =A0 =A0struct scan_control sc =3D {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.gfp_mask =3D GFP_HIGHUSER_MOVABLE,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_unmap =3D 1,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.may_swap =3D 1,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.order =3D 0,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mem_cgroup =3D mem,<br>
 =A0 =A0 =A0 =A0};<br>
-<br>
+ =A0 =A0 =A0 /* writepage will be set later per zone */<br>
 =A0 =A0 =A0 =A0sc.may_writepage =3D 0;<br>
 =A0 =A0 =A0 =A0sc.nr_reclaimed =3D 0;<br>
 =A0 =A0 =A0 =A0total_scanned =3D 0;<br>
@@ -2400,9 +2399,12 @@ unsigned long shrink_mem_cgroup(struct m<br>
 =A0 =A0 =A0 =A0 * Now, we scan MEMCG_BGRECLAIM_SCAN_LIMIT pages per scan.<=
br>
 =A0 =A0 =A0 =A0 * We use static priority 0.<br>
 =A0 =A0 =A0 =A0 */<br>
+ =A0 =A0 =A0 sc.nr_to_reclaim =3D min(required, (long)MEMCG_BGSCAN_LIMIT/2=
);<br>
 =A0 =A0 =A0 =A0next_prio =3D min(SWAP_CLUSTER_MAX * num_node_state(N_HIGH_=
MEMORY),<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MEMCG_BGSCAN_LIMIT/8);<br>
 =A0 =A0 =A0 =A0priority =3D DEF_PRIORITY;<br>
+ =A0 =A0 =A0 /* delay for next work at congestion */<br>
+ =A0 =A0 =A0 delay =3D HZ/10;<br>
 =A0 =A0 =A0 =A0while ((total_scanned &lt; MEMCG_BGSCAN_LIMIT) &amp;&amp;<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !nodes_empty(nodes) &amp;&amp;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (sc.nr_to_reclaim &gt; sc.nr_reclaimed)) {<br>
@@ -2423,12 +2425,17 @@ unsigned long shrink_mem_cgroup(struct m<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priority--;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0next_prio &lt;&lt;=3D 1;<br=
>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_scanned &amp;&amp;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc.nr_reclaimed * =
2)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, HZ/10)=
;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* give up early ? */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; MEMCG_BGSCAN_LIMIT/8 &=
amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc.nr_reclaimed * =
4)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 /* We scanned enough...If we reclaimed half of requested, no =
delay */<br>
+ =A0 =A0 =A0 if (sc.nr_reclaimed &gt; sc.nr_to_reclaim/2)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 delay =3D 0;<br>
+out:<br>
 =A0 =A0 =A0 =A0current-&gt;flags &amp;=3D ~PF_SWAPWRITE;<br>
- =A0 =A0 =A0 return sc.nr_reclaimed;<br>
+ =A0 =A0 =A0 return delay;<br>
=A0}<br>
=A0#endif<br>
<br>
<br>
</blockquote></div><br>

--0016360e3f5c0e58e104a1da8f14--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
