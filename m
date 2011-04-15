Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BF42A900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:35:09 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p3F3Z3rx024416
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:35:03 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by hpaq7.eem.corp.google.com with ESMTP id p3F3Z1Q8028371
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:35:02 -0700
Received: by qwb8 with SMTP id 8so1774725qwb.25
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:35:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415090445.4578f987.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-2-git-send-email-yinghan@google.com>
	<20110415090445.4578f987.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Apr 2011 20:35:00 -0700
Message-ID: <BANLkTikE6dyLJVebk65-6A8RdF-fpTFQ+g@mail.gmail.com>
Subject: Re: [PATCH V4 01/10] Add kswapd descriptor
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00248c6a84ca09d7c104a0ecba6d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--00248c6a84ca09d7c104a0ecba6d
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 5:04 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 15:54:20 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > There is a kswapd kernel thread for each numa node. We will add a
> different
> > kswapd for each memcg. The kswapd is sleeping in the wait queue headed at
> > kswapd_wait field of a kswapd descriptor. The kswapd descriptor stores
> > information of node or memcg and it allows the global and per-memcg
> background
> > reclaim to share common reclaim algorithms.
> >
> > This patch adds the kswapd descriptor and moves the per-node kswapd to
> use the
> > new structure.
> >
>
> No objections to your direction but some comments.
>
> > changelog v2..v1:
> > 1. dynamic allocate kswapd descriptor and initialize the wait_queue_head
> of pgdat
> > at kswapd_run.
> > 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup
> kswapd
> > descriptor.
> >
> > changelog v3..v2:
> > 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later patch.
> > 2. rename thr in kswapd_run to something else.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/mmzone.h |    3 +-
> >  include/linux/swap.h   |    7 ++++
> >  mm/page_alloc.c        |    1 -
> >  mm/vmscan.c            |   95
> ++++++++++++++++++++++++++++++++++++------------
> >  4 files changed, 80 insertions(+), 26 deletions(-)
> >
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 628f07b..6cba7d2 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -640,8 +640,7 @@ typedef struct pglist_data {
> >       unsigned long node_spanned_pages; /* total size of physical page
> >                                            range, including holes */
> >       int node_id;
> > -     wait_queue_head_t kswapd_wait;
> > -     struct task_struct *kswapd;
> > +     wait_queue_head_t *kswapd_wait;
> >       int kswapd_max_order;
> >       enum zone_type classzone_idx;
>
> I think pg_data_t should include struct kswapd in it, as
>
>        struct pglist_data {
>        .....
>                struct kswapd   kswapd;
>        };
> and you can add a macro as
>
> #define kswapd_waitqueue(kswapd)        (&(kswapd)->kswapd_wait)
> if it looks better.
>
> Why I recommend this is I think it's better to have 'struct kswapd'
> on the same page of pg_data_t or struct memcg.
> Do you have benefits to kmalloc() struct kswapd on damand ?
>

So we don't end of have kswapd struct on memcgs' which doesn't have
per-memcg kswapd enabled. I don't see one is strongly better than the other
for the two approaches. If ok, I would like to keep as it is for this
verion. Hope this is ok for now.


>
>
>
> >  } pg_data_t;
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index ed6ebe6..f43d406 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -26,6 +26,13 @@ static inline int current_is_kswapd(void)
> >       return current->flags & PF_KSWAPD;
> >  }
> >
> > +struct kswapd {
> > +     struct task_struct *kswapd_task;
> > +     wait_queue_head_t kswapd_wait;
> > +     pg_data_t *kswapd_pgdat;
> > +};
> > +
> > +int kswapd(void *p);
> >  /*
> >   * MAX_SWAPFILES defines the maximum number of swaptypes: things which
> can
> >   * be swapped to.  The swap type and the offset into that swap type are
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6e1b52a..6340865 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4205,7 +4205,6 @@ static void __paginginit free_area_init_core(struct
> pglist_data *pgdat,
> >
> >       pgdat_resize_init(pgdat);
> >       pgdat->nr_zones = 0;
> > -     init_waitqueue_head(&pgdat->kswapd_wait);
> >       pgdat->kswapd_max_order = 0;
> >       pgdat_page_cgroup_init(pgdat);
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 060e4c1..77ac74f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2241,13 +2241,16 @@ static bool pgdat_balanced(pg_data_t *pgdat,
> unsigned long balanced_pages,
> >       return balanced_pages > (present_pages >> 2);
> >  }
> >
> > +static DEFINE_SPINLOCK(kswapds_spinlock);
> > +
> Maybe better to explain this lock is for what.
>
> It seems we need this because we allocate kswapd descriptor after NODE is
> online..
> right ?
>
>  true. I will put comment there.

--Ying

Thanks,
> -Kame
>
> >  /* is kswapd sleeping prematurely? */
> > -static bool sleeping_prematurely(pg_data_t *pgdat, int order, long
> remaining,
> > -                                     int classzone_idx)
> > +static int sleeping_prematurely(struct kswapd *kswapd, int order,
> > +                             long remaining, int classzone_idx)
> >  {
> >       int i;
> >       unsigned long balanced = 0;
> >       bool all_zones_ok = true;
> > +     pg_data_t *pgdat = kswapd->kswapd_pgdat;
> >
> >       /* If a direct reclaimer woke kswapd within HZ/10, it's premature
> */
> >       if (remaining)
> > @@ -2570,28 +2573,31 @@ out:
> >       return order;
> >  }
> >
> > -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int
> classzone_idx)
> > +static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
> > +                             int classzone_idx)
> >  {
> >       long remaining = 0;
> >       DEFINE_WAIT(wait);
> > +     pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> > +     wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
> >
> >       if (freezing(current) || kthread_should_stop())
> >               return;
> >
> > -     prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > +     prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> >
> >       /* Try to sleep for a short interval */
> > -     if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx))
> {
> > +     if (!sleeping_prematurely(kswapd_p, order, remaining,
> classzone_idx)) {
> >               remaining = schedule_timeout(HZ/10);
> > -             finish_wait(&pgdat->kswapd_wait, &wait);
> > -             prepare_to_wait(&pgdat->kswapd_wait, &wait,
> TASK_INTERRUPTIBLE);
> > +             finish_wait(wait_h, &wait);
> > +             prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> >       }
> >
> >       /*
> >        * After a short sleep, check if it was a premature sleep. If not,
> then
> >        * go fully to sleep until explicitly woken up.
> >        */
> > -     if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx))
> {
> > +     if (!sleeping_prematurely(kswapd_p, order, remaining,
> classzone_idx)) {
> >               trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> >
> >               /*
> > @@ -2611,7 +2617,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat,
> int order, int classzone_idx)
> >               else
> >                       count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> >       }
> > -     finish_wait(&pgdat->kswapd_wait, &wait);
> > +     finish_wait(wait_h, &wait);
> >  }
> >
> >  /*
> > @@ -2627,20 +2633,24 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat,
> int order, int classzone_idx)
> >   * If there are applications that are active memory-allocators
> >   * (most normal use), this basically shouldn't matter.
> >   */
> > -static int kswapd(void *p)
> > +int kswapd(void *p)
> >  {
> >       unsigned long order;
> >       int classzone_idx;
> > -     pg_data_t *pgdat = (pg_data_t*)p;
> > +     struct kswapd *kswapd_p = (struct kswapd *)p;
> > +     pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> > +     wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
> >       struct task_struct *tsk = current;
> >
> >       struct reclaim_state reclaim_state = {
> >               .reclaimed_slab = 0,
> >       };
> > -     const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> > +     const struct cpumask *cpumask;
> >
> >       lockdep_set_current_reclaim_state(GFP_KERNEL);
> >
> > +     BUG_ON(pgdat->kswapd_wait != wait_h);
> > +     cpumask = cpumask_of_node(pgdat->node_id);
> >       if (!cpumask_empty(cpumask))
> >               set_cpus_allowed_ptr(tsk, cpumask);
> >       current->reclaim_state = &reclaim_state;
> > @@ -2679,7 +2689,7 @@ static int kswapd(void *p)
> >                       order = new_order;
> >                       classzone_idx = new_classzone_idx;
> >               } else {
> > -                     kswapd_try_to_sleep(pgdat, order, classzone_idx);
> > +                     kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> >                       order = pgdat->kswapd_max_order;
> >                       classzone_idx = pgdat->classzone_idx;
> >                       pgdat->kswapd_max_order = 0;
> > @@ -2719,13 +2729,13 @@ void wakeup_kswapd(struct zone *zone, int order,
> enum zone_type classzone_idx)
> >               pgdat->kswapd_max_order = order;
> >               pgdat->classzone_idx = min(pgdat->classzone_idx,
> classzone_idx);
> >       }
> > -     if (!waitqueue_active(&pgdat->kswapd_wait))
> > +     if (!waitqueue_active(pgdat->kswapd_wait))
> >               return;
> >       if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0,
> 0))
> >               return;
> >
> >       trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone),
> order);
> > -     wake_up_interruptible(&pgdat->kswapd_wait);
> > +     wake_up_interruptible(pgdat->kswapd_wait);
> >  }
> >
> >  /*
> > @@ -2817,12 +2827,23 @@ static int __devinit cpu_callback(struct
> notifier_block *nfb,
> >               for_each_node_state(nid, N_HIGH_MEMORY) {
> >                       pg_data_t *pgdat = NODE_DATA(nid);
> >                       const struct cpumask *mask;
> > +                     struct kswapd *kswapd_p;
> > +                     struct task_struct *kswapd_thr;
> > +                     wait_queue_head_t *wait;
> >
> >                       mask = cpumask_of_node(pgdat->node_id);
> >
> > +                     spin_lock(&kswapds_spinlock);
> > +                     wait = pgdat->kswapd_wait;
> > +                     kswapd_p = container_of(wait, struct kswapd,
> > +                                             kswapd_wait);
> > +                     kswapd_thr = kswapd_p->kswapd_task;
> > +                     spin_unlock(&kswapds_spinlock);
> > +
> >                       if (cpumask_any_and(cpu_online_mask, mask) <
> nr_cpu_ids)
> >                               /* One of our CPUs online: restore mask */
> > -                             set_cpus_allowed_ptr(pgdat->kswapd, mask);
> > +                             if (kswapd_thr)
> > +                                     set_cpus_allowed_ptr(kswapd_thr,
> mask);
> >               }
> >       }
> >       return NOTIFY_OK;
> > @@ -2835,18 +2856,31 @@ static int __devinit cpu_callback(struct
> notifier_block *nfb,
> >  int kswapd_run(int nid)
> >  {
> >       pg_data_t *pgdat = NODE_DATA(nid);
> > +     struct task_struct *kswapd_thr;
> > +     struct kswapd *kswapd_p;
> >       int ret = 0;
> >
> > -     if (pgdat->kswapd)
> > +     if (pgdat->kswapd_wait)
> >               return 0;
> >
> > -     pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
> > -     if (IS_ERR(pgdat->kswapd)) {
> > +     kswapd_p = kzalloc(sizeof(struct kswapd), GFP_KERNEL);
> > +     if (!kswapd_p)
> > +             return -ENOMEM;
> > +
> > +     init_waitqueue_head(&kswapd_p->kswapd_wait);
> > +     pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
> > +     kswapd_p->kswapd_pgdat = pgdat;
> > +
> > +     kswapd_thr = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
> > +     if (IS_ERR(kswapd_thr)) {
> >               /* failure at boot is fatal */
> >               BUG_ON(system_state == SYSTEM_BOOTING);
> >               printk("Failed to start kswapd on node %d\n",nid);
> > +             pgdat->kswapd_wait = NULL;
> > +             kfree(kswapd_p);
> >               ret = -1;
> > -     }
> > +     } else
> > +             kswapd_p->kswapd_task = kswapd_thr;
> >       return ret;
> >  }
> >
> > @@ -2855,10 +2889,25 @@ int kswapd_run(int nid)
> >   */
> >  void kswapd_stop(int nid)
> >  {
> > -     struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
> > +     struct task_struct *kswapd_thr = NULL;
> > +     struct kswapd *kswapd_p = NULL;
> > +     wait_queue_head_t *wait;
> > +
> > +     pg_data_t *pgdat = NODE_DATA(nid);
> > +
> > +     spin_lock(&kswapds_spinlock);
> > +     wait = pgdat->kswapd_wait;
> > +     if (wait) {
> > +             kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> > +             kswapd_thr = kswapd_p->kswapd_task;
> > +             kswapd_p->kswapd_task = NULL;
> > +     }
> > +     spin_unlock(&kswapds_spinlock);
> > +
> > +     if (kswapd_thr)
> > +             kthread_stop(kswapd_thr);
> >
> > -     if (kswapd)
> > -             kthread_stop(kswapd);
> > +     kfree(kswapd_p);
> >  }
> >
> >  static int __init kswapd_init(void)
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

--00248c6a84ca09d7c104a0ecba6d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 5:04 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Thu, 14 Apr 2011 15:54:20 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; There is a kswapd kernel thread for each numa node. We will add a diff=
erent<br>
&gt; kswapd for each memcg. The kswapd is sleeping in the wait queue headed=
 at<br>
&gt; kswapd_wait field of a kswapd descriptor. The kswapd descriptor stores=
<br>
&gt; information of node or memcg and it allows the global and per-memcg ba=
ckground<br>
&gt; reclaim to share common reclaim algorithms.<br>
&gt;<br>
&gt; This patch adds the kswapd descriptor and moves the per-node kswapd to=
 use the<br>
&gt; new structure.<br>
&gt;<br>
<br>
</div>No objections to your direction but some comments.<br>
<div><div></div><div class=3D"h5"><br>
&gt; changelog v2..v1:<br>
&gt; 1. dynamic allocate kswapd descriptor and initialize the wait_queue_he=
ad of pgdat<br>
&gt; at kswapd_run.<br>
&gt; 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup =
kswapd<br>
&gt; descriptor.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later pat=
ch.<br>
&gt; 2. rename thr in kswapd_run to something else.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/mmzone.h | =A0 =A03 +-<br>
&gt; =A0include/linux/swap.h =A0 | =A0 =A07 ++++<br>
&gt; =A0mm/page_alloc.c =A0 =A0 =A0 =A0| =A0 =A01 -<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 95 +++++++++++++++++++++++=
+++++++++++++------------<br>
&gt; =A04 files changed, 80 insertions(+), 26 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h<br>
&gt; index 628f07b..6cba7d2 100644<br>
&gt; --- a/include/linux/mmzone.h<br>
&gt; +++ b/include/linux/mmzone.h<br>
&gt; @@ -640,8 +640,7 @@ typedef struct pglist_data {<br>
&gt; =A0 =A0 =A0 unsigned long node_spanned_pages; /* total size of physica=
l page<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0range, including holes */<br>
&gt; =A0 =A0 =A0 int node_id;<br>
&gt; - =A0 =A0 wait_queue_head_t kswapd_wait;<br>
&gt; - =A0 =A0 struct task_struct *kswapd;<br>
&gt; + =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
&gt; =A0 =A0 =A0 int kswapd_max_order;<br>
&gt; =A0 =A0 =A0 enum zone_type classzone_idx;<br>
<br>
</div></div>I think pg_data_t should include struct kswapd in it, as<br>
<br>
 =A0 =A0 =A0 =A0struct pglist_data {<br>
 =A0 =A0 =A0 =A0.....<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kswapd =A0 kswapd;<br>
 =A0 =A0 =A0 =A0};<br>
and you can add a macro as<br>
<br>
#define kswapd_waitqueue(kswapd) =A0 =A0 =A0 =A0(&amp;(kswapd)-&gt;kswapd_w=
ait)<br>
if it looks better.<br>
<br>
Why I recommend this is I think it&#39;s better to have &#39;struct kswapd&=
#39;<br>
on the same page of pg_data_t or struct memcg.<br>
Do you have benefits to kmalloc() struct kswapd on damand ?<br></blockquote=
><div><br></div><div>So we don&#39;t end of have kswapd struct on memcgs&#3=
9; which doesn&#39;t have per-memcg kswapd enabled. I don&#39;t see one is =
strongly better than the other for the two approaches. If ok, I would like =
to keep as it is for this verion. Hope this is ok for now.</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
<br>
<br>
&gt; =A0} pg_data_t;<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index ed6ebe6..f43d406 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -26,6 +26,13 @@ static inline int current_is_kswapd(void)<br>
&gt; =A0 =A0 =A0 return current-&gt;flags &amp; PF_KSWAPD;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +struct kswapd {<br>
&gt; + =A0 =A0 struct task_struct *kswapd_task;<br>
&gt; + =A0 =A0 wait_queue_head_t kswapd_wait;<br>
&gt; + =A0 =A0 pg_data_t *kswapd_pgdat;<br>
&gt; +};<br>
&gt; +<br>
&gt; +int kswapd(void *p);<br>
&gt; =A0/*<br>
&gt; =A0 * MAX_SWAPFILES defines the maximum number of swaptypes: things wh=
ich can<br>
&gt; =A0 * be swapped to. =A0The swap type and the offset into that swap ty=
pe are<br>
&gt; diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
&gt; index 6e1b52a..6340865 100644<br>
&gt; --- a/mm/page_alloc.c<br>
&gt; +++ b/mm/page_alloc.c<br>
&gt; @@ -4205,7 +4205,6 @@ static void __paginginit free_area_init_core(str=
uct pglist_data *pgdat,<br>
&gt;<br>
&gt; =A0 =A0 =A0 pgdat_resize_init(pgdat);<br>
&gt; =A0 =A0 =A0 pgdat-&gt;nr_zones =3D 0;<br>
&gt; - =A0 =A0 init_waitqueue_head(&amp;pgdat-&gt;kswapd_wait);<br>
&gt; =A0 =A0 =A0 pgdat-&gt;kswapd_max_order =3D 0;<br>
&gt; =A0 =A0 =A0 pgdat_page_cgroup_init(pgdat);<br>
&gt;<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 060e4c1..77ac74f 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -2241,13 +2241,16 @@ static bool pgdat_balanced(pg_data_t *pgdat, u=
nsigned long balanced_pages,<br>
&gt; =A0 =A0 =A0 return balanced_pages &gt; (present_pages &gt;&gt; 2);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static DEFINE_SPINLOCK(kswapds_spinlock);<br>
&gt; +<br>
</div></div>Maybe better to explain this lock is for what.<br>
<br>
It seems we need this because we allocate kswapd descriptor after NODE is o=
nline..<br>
right ?<br>
<br></blockquote><div>=A0true. I will put comment there.</div><div><br></di=
v><div>--Ying</div><div><br></div><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Thanks,<br>
-Kame<br>
<div><div></div><div class=3D"h5"><br>
&gt; =A0/* is kswapd sleeping prematurely? */<br>
&gt; -static bool sleeping_prematurely(pg_data_t *pgdat, int order, long re=
maining,<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 int classzone_idx)<br>
&gt; +static int sleeping_prematurely(struct kswapd *kswapd, int order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long remaini=
ng, int classzone_idx)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 int i;<br>
&gt; =A0 =A0 =A0 unsigned long balanced =3D 0;<br>
&gt; =A0 =A0 =A0 bool all_zones_ok =3D true;<br>
&gt; + =A0 =A0 pg_data_t *pgdat =3D kswapd-&gt;kswapd_pgdat;<br>
&gt;<br>
&gt; =A0 =A0 =A0 /* If a direct reclaimer woke kswapd within HZ/10, it&#39;=
s premature */<br>
&gt; =A0 =A0 =A0 if (remaining)<br>
&gt; @@ -2570,28 +2573,31 @@ out:<br>
&gt; =A0 =A0 =A0 return order;<br>
&gt; =A0}<br>
&gt;<br>
&gt; -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int clas=
szone_idx)<br>
&gt; +static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int classzon=
e_idx)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 long remaining =3D 0;<br>
&gt; =A0 =A0 =A0 DEFINE_WAIT(wait);<br>
&gt; + =A0 =A0 pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 wait_queue_head_t *wait_h =3D &amp;kswapd_p-&gt;kswapd_wait;=
<br>
&gt;<br>
&gt; =A0 =A0 =A0 if (freezing(current) || kthread_should_stop())<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt;<br>
&gt; - =A0 =A0 prepare_to_wait(&amp;pgdat-&gt;kswapd_wait, &amp;wait, TASK_=
INTERRUPTIBLE);<br>
&gt; + =A0 =A0 prepare_to_wait(wait_h, &amp;wait, TASK_INTERRUPTIBLE);<br>
&gt;<br>
&gt; =A0 =A0 =A0 /* Try to sleep for a short interval */<br>
&gt; - =A0 =A0 if (!sleeping_prematurely(pgdat, order, remaining, classzone=
_idx)) {<br>
&gt; + =A0 =A0 if (!sleeping_prematurely(kswapd_p, order, remaining, classz=
one_idx)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 remaining =3D schedule_timeout(HZ/10);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(&amp;pgdat-&gt;kswapd_wait, &amp=
;wait);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(&amp;pgdat-&gt;kswapd_wait, =
&amp;wait, TASK_INTERRUPTIBLE);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(wait_h, &amp;wait, TASK_INTE=
RRUPTIBLE);<br>
&gt; =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0* After a short sleep, check if it was a premature slee=
p. If not, then<br>
&gt; =A0 =A0 =A0 =A0* go fully to sleep until explicitly woken up.<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 if (!sleeping_prematurely(pgdat, order, remaining, classzone=
_idx)) {<br>
&gt; + =A0 =A0 if (!sleeping_prematurely(kswapd_p, order, remaining, classz=
one_idx)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_sleep(pgdat-&gt;nod=
e_id);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; @@ -2611,7 +2617,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat=
, int order, int classzone_idx)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(KSWAPD_HIGH=
_WMARK_HIT_QUICKLY);<br>
&gt; =A0 =A0 =A0 }<br>
&gt; - =A0 =A0 finish_wait(&amp;pgdat-&gt;kswapd_wait, &amp;wait);<br>
&gt; + =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -2627,20 +2633,24 @@ static void kswapd_try_to_sleep(pg_data_t *pgd=
at, int order, int classzone_idx)<br>
&gt; =A0 * If there are applications that are active memory-allocators<br>
&gt; =A0 * (most normal use), this basically shouldn&#39;t matter.<br>
&gt; =A0 */<br>
&gt; -static int kswapd(void *p)<br>
&gt; +int kswapd(void *p)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 unsigned long order;<br>
&gt; =A0 =A0 =A0 int classzone_idx;<br>
&gt; - =A0 =A0 pg_data_t *pgdat =3D (pg_data_t*)p;<br>
&gt; + =A0 =A0 struct kswapd *kswapd_p =3D (struct kswapd *)p;<br>
&gt; + =A0 =A0 pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 wait_queue_head_t *wait_h =3D &amp;kswapd_p-&gt;kswapd_wait;=
<br>
&gt; =A0 =A0 =A0 struct task_struct *tsk =3D current;<br>
&gt;<br>
&gt; =A0 =A0 =A0 struct reclaim_state reclaim_state =3D {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reclaimed_slab =3D 0,<br>
&gt; =A0 =A0 =A0 };<br>
&gt; - =A0 =A0 const struct cpumask *cpumask =3D cpumask_of_node(pgdat-&gt;=
node_id);<br>
&gt; + =A0 =A0 const struct cpumask *cpumask;<br>
&gt;<br>
&gt; =A0 =A0 =A0 lockdep_set_current_reclaim_state(GFP_KERNEL);<br>
&gt;<br>
&gt; + =A0 =A0 BUG_ON(pgdat-&gt;kswapd_wait !=3D wait_h);<br>
&gt; + =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;node_id);<br>
&gt; =A0 =A0 =A0 if (!cpumask_empty(cpumask))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk, cpumask);<br>
&gt; =A0 =A0 =A0 current-&gt;reclaim_state =3D &amp;reclaim_state;<br>
&gt; @@ -2679,7 +2689,7 @@ static int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D new_order;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D new_clas=
szone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(pgdat, o=
rder, classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswapd_p=
, order, classzone_idx);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat-&gt;kswapd=
_max_order;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D pgdat-&g=
t;classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_max_order=
 =3D 0;<br>
&gt; @@ -2719,13 +2729,13 @@ void wakeup_kswapd(struct zone *zone, int orde=
r, enum zone_type classzone_idx)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_max_order =3D order;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;classzone_idx =3D min(pgdat-&gt;=
classzone_idx, classzone_idx);<br>
&gt; =A0 =A0 =A0 }<br>
&gt; - =A0 =A0 if (!waitqueue_active(&amp;pgdat-&gt;kswapd_wait))<br>
&gt; + =A0 =A0 if (!waitqueue_active(pgdat-&gt;kswapd_wait))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; =A0 =A0 =A0 if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zo=
ne), 0, 0))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt;<br>
&gt; =A0 =A0 =A0 trace_mm_vmscan_wakeup_kswapd(pgdat-&gt;node_id, zone_idx(=
zone), order);<br>
&gt; - =A0 =A0 wake_up_interruptible(&amp;pgdat-&gt;kswapd_wait);<br>
&gt; + =A0 =A0 wake_up_interruptible(pgdat-&gt;kswapd_wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -2817,12 +2827,23 @@ static int __devinit cpu_callback(struct notif=
ier_block *nfb,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY) {<=
br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pg_data_t *pgdat =3D NODE_=
DATA(nid);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct cpumask *mask=
;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct kswapd *kswapd_p;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *kswapd_t=
hr;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait_queue_head_t *wait;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D cpumask_of_node(p=
gdat-&gt;node_id);<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&amp;kswapds_spinl=
ock);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D pgdat-&gt;kswapd_wa=
it;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D container_of(wa=
it, struct kswapd,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 kswapd_wait);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_thr =3D kswapd_p-&gt;=
kswapd_task;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&amp;kswapds_spi=
nlock);<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpumask_any_and(cpu_on=
line_mask, mask) &lt; nr_cpu_ids)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* One of =
our CPUs online: restore mask */<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_all=
owed_ptr(pgdat-&gt;kswapd, mask);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kswapd_t=
hr)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 set_cpus_allowed_ptr(kswapd_thr, mask);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 return NOTIFY_OK;<br>
&gt; @@ -2835,18 +2856,31 @@ static int __devinit cpu_callback(struct notif=
ier_block *nfb,<br>
&gt; =A0int kswapd_run(int nid)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; + =A0 =A0 struct task_struct *kswapd_thr;<br>
&gt; + =A0 =A0 struct kswapd *kswapd_p;<br>
&gt; =A0 =A0 =A0 int ret =3D 0;<br>
&gt;<br>
&gt; - =A0 =A0 if (pgdat-&gt;kswapd)<br>
&gt; + =A0 =A0 if (pgdat-&gt;kswapd_wait)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt;<br>
&gt; - =A0 =A0 pgdat-&gt;kswapd =3D kthread_run(kswapd, pgdat, &quot;kswapd=
%d&quot;, nid);<br>
&gt; - =A0 =A0 if (IS_ERR(pgdat-&gt;kswapd)) {<br>
&gt; + =A0 =A0 kswapd_p =3D kzalloc(sizeof(struct kswapd), GFP_KERNEL);<br>
&gt; + =A0 =A0 if (!kswapd_p)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt; +<br>
&gt; + =A0 =A0 init_waitqueue_head(&amp;kswapd_p-&gt;kswapd_wait);<br>
&gt; + =A0 =A0 pgdat-&gt;kswapd_wait =3D &amp;kswapd_p-&gt;kswapd_wait;<br>
&gt; + =A0 =A0 kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
&gt; +<br>
&gt; + =A0 =A0 kswapd_thr =3D kthread_run(kswapd, kswapd_p, &quot;kswapd%d&=
quot;, nid);<br>
&gt; + =A0 =A0 if (IS_ERR(kswapd_thr)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* failure at boot is fatal */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(system_state =3D=3D SYSTEM_BOOTING)=
;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(&quot;Failed to start kswapd on nod=
e %d\n&quot;,nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D NULL;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kfree(kswapd_p);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -1;<br>
&gt; - =A0 =A0 }<br>
&gt; + =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_task =3D kswapd_thr;<br>
&gt; =A0 =A0 =A0 return ret;<br>
&gt; =A0}<br>
&gt;<br>
&gt; @@ -2855,10 +2889,25 @@ int kswapd_run(int nid)<br>
&gt; =A0 */<br>
&gt; =A0void kswapd_stop(int nid)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 struct task_struct *kswapd =3D NODE_DATA(nid)-&gt;kswapd;<br=
>
&gt; + =A0 =A0 struct task_struct *kswapd_thr =3D NULL;<br>
&gt; + =A0 =A0 struct kswapd *kswapd_p =3D NULL;<br>
&gt; + =A0 =A0 wait_queue_head_t *wait;<br>
&gt; +<br>
&gt; + =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; +<br>
&gt; + =A0 =A0 spin_lock(&amp;kswapds_spinlock);<br>
&gt; + =A0 =A0 wait =3D pgdat-&gt;kswapd_wait;<br>
&gt; + =A0 =A0 if (wait) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D container_of(wait, struct kswap=
d, kswapd_wait);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_thr =3D kswapd_p-&gt;kswapd_task;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_task =3D NULL;<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 spin_unlock(&amp;kswapds_spinlock);<br>
&gt; +<br>
&gt; + =A0 =A0 if (kswapd_thr)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kthread_stop(kswapd_thr);<br>
&gt;<br>
&gt; - =A0 =A0 if (kswapd)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 kthread_stop(kswapd);<br>
&gt; + =A0 =A0 kfree(kswapd_p);<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0static int __init kswapd_init(void)<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
</div></div>&gt; --<br>
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

--00248c6a84ca09d7c104a0ecba6d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
