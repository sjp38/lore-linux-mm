Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C49CF8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 01:59:16 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p3M5x8mh029179
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 22:59:08 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by kpbe11.cbf.corp.google.com with ESMTP id p3M5x6dX031794
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 22:59:06 -0700
Received: by qyk36 with SMTP id 36so257160qyk.11
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 22:59:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422141220.FA62.A69D9226@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-6-git-send-email-yinghan@google.com>
	<20110422141220.FA62.A69D9226@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 22:59:05 -0700
Message-ID: <BANLkTimNkteiHj7vhnc0vCysozG6j=k0mQ@mail.gmail.com>
Subject: Re: [PATCH V7 5/9] Infrastructure to support per-memcg reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa837808604a17b8ea4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470aa837808604a17b8ea4
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 10:11 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

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
> > change v7..v6:
> > 1. change the threading model of memcg from per-memcg-per-thread to
> thread-pool.
> > this is based on the patch from KAMAZAWA.
> >
> > change v6..v5:
> > 1. rename is_node_kswapd to is_global_kswapd to match the
> scanning_global_lru.
> > 2. revert the sleeping_prematurely change, but keep the
> kswapd_try_to_sleep()
> > for memcg.
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
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Looks ok. but this one have some ugly coding style.
>
> functioon()
> {
>        if (is_global_kswapd()) {
>                looooooooong lines
>                ...
>                ..
>        } else {
>                another looooooong lines
>                ...
>                ..
>        }
> }
>
> please pay attention more to keep simpler code.
> However, I don't think this patch has major issue. I expect I can ack next
> version.
>
>
> Thank you for reviewing.

>
> > ---
> >  include/linux/swap.h |    2 +-
> >  mm/memory_hotplug.c  |    2 +-
> >  mm/vmscan.c          |  156
> +++++++++++++++++++++++++++++++-------------------
> >  3 files changed, 100 insertions(+), 60 deletions(-)
> >
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 9b91ca4..a062f0b 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -303,7 +303,7 @@ static inline void
> scan_unevictable_unregister_node(struct node *node)
> >  }
> >  #endif
> >
> > -extern int kswapd_run(int nid);
> > +extern int kswapd_run(int nid, int id);
>
> "id" is bad name. there is no information. please use memcg-id or so on.
>

will change .

>
>
> >  extern void kswapd_stop(int nid);
> >
> >  #ifdef CONFIG_MMU
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 321fc74..36b4eed 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -462,7 +462,7 @@ int online_pages(unsigned long pfn, unsigned long
> nr_pages)
> >       setup_per_zone_wmarks();
> >       calculate_zone_inactive_ratio(zone);
> >       if (onlined_pages) {
> > -             kswapd_run(zone_to_nid(zone));
> > +             kswapd_run(zone_to_nid(zone), 0);
> >               node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> >       }
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 7aba681..63c557e 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2241,6 +2241,8 @@ static bool pgdat_balanced(pg_data_t *pgdat,
> unsigned long balanced_pages,
> >       return balanced_pages > (present_pages >> 2);
> >  }
> >
> > +#define is_global_kswapd(kswapd_p) ((kswapd_p)->kswapd_pgdat)
>
> please use inline function.
>

Hmm.  see will change next/

>
>

>
> > +
> >  /* is kswapd sleeping prematurely? */
> >  static bool sleeping_prematurely(pg_data_t *pgdat, int order, long
> remaining,
> >                                       int classzone_idx)
> > @@ -2583,40 +2585,46 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >
> >       prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> >
> > -     /* Try to sleep for a short interval */
> > -     if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx))
> {
> > -             remaining = schedule_timeout(HZ/10);
> > -             finish_wait(wait_h, &wait);
> > -             prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> > -     }
> > -
> > -     /*
> > -      * After a short sleep, check if it was a premature sleep. If not,
> then
> > -      * go fully to sleep until explicitly woken up.
> > -      */
> > -     if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx))
> {
> > -             trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > +     if (is_global_kswapd(kswapd_p)) {
>
> bad indentation. :-/
> please don't increase coding mess.
>
>        if (!is_global_kswapd(kswapd_p)) {
>                 kswapd_try_to_sleep_memcg();
>                return;
>        }
>
> is simpler.
>
> Ok. I will check on next post.

>
> > +             /* Try to sleep for a short interval */
> > +             if (!sleeping_prematurely(pgdat, order,
> > +                             remaining, classzone_idx)) {
> > +                     remaining = schedule_timeout(HZ/10);
> > +                     finish_wait(wait_h, &wait);
> > +                     prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> > +             }
> >
> >               /*
> > -              * vmstat counters are not perfectly accurate and the
> estimated
> > -              * value for counters such as NR_FREE_PAGES can deviate
> from the
> > -              * true value by nr_online_cpus * threshold. To avoid the
> zone
> > -              * watermarks being breached while under pressure, we
> reduce the
> > -              * per-cpu vmstat threshold while kswapd is awake and
> restore
> > -              * them before going back to sleep.
> > +              * After a short sleep, check if it was a premature sleep.
> > +              * If not, then go fully to sleep until explicitly woken
> up.
> >                */
> > -             set_pgdat_percpu_threshold(pgdat,
> calculate_normal_threshold);
> > -             schedule();
> > -             set_pgdat_percpu_threshold(pgdat,
> calculate_pressure_threshold);
> > +             if (!sleeping_prematurely(pgdat, order,
> > +                                     remaining, classzone_idx)) {
> > +                     trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > +                     set_pgdat_percpu_threshold(pgdat,
> > +                                     calculate_normal_threshold);
> > +                     schedule();
> > +                     set_pgdat_percpu_threshold(pgdat,
> > +                                     calculate_pressure_threshold);
> > +             } else {
> > +                     if (remaining)
> > +
> count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> > +                     else
> > +
> count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> > +             }
> >       } else {
> > -             if (remaining)
> > -                     count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> > -             else
> > -                     count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> > +             /* For now, we just check the remaining works.*/
> > +             if (mem_cgroup_kswapd_can_sleep())
> > +                     schedule();
> >       }
> >       finish_wait(wait_h, &wait);
>
>
> >  }
> >
> > +static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, int
> order)
> > +{
> > +     return 0;
> > +}
> > +
> >  /*
> >   * The background pageout daemon, started as a kernel thread
> >   * from the init process.
> > @@ -2636,6 +2644,7 @@ int kswapd(void *p)
> >       int classzone_idx;
> >       struct kswapd *kswapd_p = (struct kswapd *)p;
> >       pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> > +     struct mem_cgroup *mem;
> >       struct task_struct *tsk = current;
> >
> >       struct reclaim_state reclaim_state = {
> > @@ -2645,9 +2654,11 @@ int kswapd(void *p)
> >
> >       lockdep_set_current_reclaim_state(GFP_KERNEL);
> >
> > -     cpumask = cpumask_of_node(pgdat->node_id);
> > -     if (!cpumask_empty(cpumask))
> > -             set_cpus_allowed_ptr(tsk, cpumask);
> > +     if (is_global_kswapd(kswapd_p)) {
> > +             cpumask = cpumask_of_node(pgdat->node_id);
> > +             if (!cpumask_empty(cpumask))
> > +                     set_cpus_allowed_ptr(tsk, cpumask);
> > +     }
> >       current->reclaim_state = &reclaim_state;
> >
> >       /*
> > @@ -2662,7 +2673,10 @@ int kswapd(void *p)
> >        * us from recursively trying to free more memory as we're
> >        * trying to free the first piece of memory in the first place).
> >        */
> > -     tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> > +     if (is_global_kswapd(kswapd_p))
> > +             tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> > +     else
> > +             tsk->flags |= PF_SWAPWRITE | PF_KSWAPD;
> >       set_freezable();
> >
> >       order = 0;
> > @@ -2672,36 +2686,48 @@ int kswapd(void *p)
> >               int new_classzone_idx;
> >               int ret;
> >
> > -             new_order = pgdat->kswapd_max_order;
> > -             new_classzone_idx = pgdat->classzone_idx;
> > -             pgdat->kswapd_max_order = 0;
> > -             pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > -             if (order < new_order || classzone_idx > new_classzone_idx)
> {
> > -                     /*
> > -                      * Don't sleep if someone wants a larger 'order'
> > -                      * allocation or has tigher zone constraints
> > -                      */
> > -                     order = new_order;
> > -                     classzone_idx = new_classzone_idx;
> > -             } else {
> > -                     kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> > -                     order = pgdat->kswapd_max_order;
> > -                     classzone_idx = pgdat->classzone_idx;
> > +             if (is_global_kswapd(kswapd_p)) {
> > +                     new_order = pgdat->kswapd_max_order;
> > +                     new_classzone_idx = pgdat->classzone_idx;
> >                       pgdat->kswapd_max_order = 0;
> >                       pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > -             }
> > +                     if (order < new_order ||
> > +                                     classzone_idx > new_classzone_idx)
> {
> > +                             /*
> > +                              * Don't sleep if someone wants a larger
> 'order'
> > +                              * allocation or has tigher zone
> constraints
> > +                              */
> > +                             order = new_order;
> > +                             classzone_idx = new_classzone_idx;
> > +                     } else {
> > +                             kswapd_try_to_sleep(kswapd_p, order,
> > +                                                 classzone_idx);
> > +                             order = pgdat->kswapd_max_order;
> > +                             classzone_idx = pgdat->classzone_idx;
> > +                             pgdat->kswapd_max_order = 0;
> > +                             pgdat->classzone_idx = MAX_NR_ZONES - 1;
>
> -ETOODEEPNEST.
>
>
> > +                     }
> > +             } else
> > +                     kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> >
> >               ret = try_to_freeze();
> >               if (kthread_should_stop())
> >                       break;
> >
> > +             if (ret)
> > +                     continue;
> >               /*
> >                * We can speed up thawing tasks if we don't call
> balance_pgdat
> >                * after returning from the refrigerator
> >                */
> > -             if (!ret) {
> > +             if (is_global_kswapd(kswapd_p)) {
> >                       trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> >                       order = balance_pgdat(pgdat, order,
> &classzone_idx);
> > +             } else {
> > +                     mem = mem_cgroup_get_shrink_target();
> > +                     if (mem)
> > +                             shrink_mem_cgroup(mem, order);
> > +                     mem_cgroup_put_shrink_target(mem);
> >               }
>
>
>
> >       }
> >       return 0;
> > @@ -2845,30 +2871,44 @@ static int __devinit cpu_callback(struct
> notifier_block *nfb,
> >   * This kswapd start function will be called by init and node-hot-add.
> >   * On node-hot-add, kswapd will moved to proper cpus if cpus are
> hot-added.
> >   */
> > -int kswapd_run(int nid)
> > +int kswapd_run(int nid, int memcgid)
> >  {
> > -     pg_data_t *pgdat = NODE_DATA(nid);
> >       struct task_struct *kswapd_tsk;
> > +     pg_data_t *pgdat = NULL;
> >       struct kswapd *kswapd_p;
> > +     static char name[TASK_COMM_LEN];
> >       int ret = 0;
> >
> > -     if (pgdat->kswapd)
> > -             return 0;
> > +     if (!memcgid) {
> > +             pgdat = NODE_DATA(nid);
> > +             if (pgdat->kswapd)
> > +                     return ret;
> > +     }
> >
> >       kswapd_p = kzalloc(sizeof(struct kswapd), GFP_KERNEL);
> >       if (!kswapd_p)
> >               return -ENOMEM;
> >
> > -     pgdat->kswapd = kswapd_p;
> > -     kswapd_p->kswapd_wait = &pgdat->kswapd_wait;
> > -     kswapd_p->kswapd_pgdat = pgdat;
> > +     if (!memcgid) {
> > +             pgdat->kswapd = kswapd_p;
> > +             kswapd_p->kswapd_wait = &pgdat->kswapd_wait;
> > +             kswapd_p->kswapd_pgdat = pgdat;
> > +             snprintf(name, TASK_COMM_LEN, "kswapd_%d", nid);
> > +     } else {
> > +             kswapd_p->kswapd_wait = mem_cgroup_kswapd_waitq();
> > +             snprintf(name, TASK_COMM_LEN, "memcg_%d", memcgid);
> > +     }
> >
> > -     kswapd_tsk = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
>
> You seems to change kswapd name slightly.
>
>
>
> > +     kswapd_tsk = kthread_run(kswapd, kswapd_p, name);
> >       if (IS_ERR(kswapd_tsk)) {
> >               /* failure at boot is fatal */
> >               BUG_ON(system_state == SYSTEM_BOOTING);
> > -             printk("Failed to start kswapd on node %d\n",nid);
> > -             pgdat->kswapd = NULL;
> > +             if (!memcgid) {
> > +                     printk(KERN_ERR "Failed to start kswapd on node
> %d\n",
> > +                                                             nid);
> > +                     pgdat->kswapd = NULL;
> > +             } else
> > +                     printk(KERN_ERR "Failed to start kswapd on
> memcg\n");
>
> Why don't you show memcg-id here?
>

will change.

>
>
> >               kfree(kswapd_p);
> >               ret = -1;
> >       } else
> > @@ -2899,7 +2939,7 @@ static int __init kswapd_init(void)
> >
> >       swap_setup();
> >       for_each_node_state(nid, N_HIGH_MEMORY)
> > -             kswapd_run(nid);
> > +             kswapd_run(nid, 0);
> >       hotcpu_notifier(cpu_callback, 0);
> >       return 0;
> >  }
> > --
> > 1.7.3.1
> >
>
>
>
>

--002354470aa837808604a17b8ea4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 10:11 PM, KOSAKI=
 Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujits=
u.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid=
;padding-left:1ex;">
<div class=3D"im">&gt; Add the kswapd_mem field in kswapd descriptor which =
links the kswapd<br>
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
&gt; change v7..v6:<br>
&gt; 1. change the threading model of memcg from per-memcg-per-thread to th=
read-pool.<br>
&gt; this is based on the patch from KAMAZAWA.<br>
&gt;<br>
&gt; change v6..v5:<br>
&gt; 1. rename is_node_kswapd to is_global_kswapd to match the scanning_glo=
bal_lru.<br>
&gt; 2. revert the sleeping_prematurely change, but keep the kswapd_try_to_=
sleep()<br>
&gt; for memcg.<br>
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
&gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu=
@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
<br>
</div>Looks ok. but this one have some ugly coding style.<br>
<br>
functioon()<br>
{<br>
 =A0 =A0 =A0 =A0if (is_global_kswapd()) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0looooooooong lines<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0...<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0..<br>
 =A0 =A0 =A0 =A0} else {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0another looooooong lines<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0...<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0..<br>
 =A0 =A0 =A0 =A0}<br>
}<br>
<br>
please pay attention more to keep simpler code.<br>
However, I don&#39;t think this patch has major issue. I expect I can ack n=
ext version.<br>
<div class=3D"im"><br>
<br></div></blockquote><div>Thank you for reviewing.=A0</div><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex;"><div class=3D"im">
<br>
&gt; ---<br>
&gt; =A0include/linux/swap.h | =A0 =A02 +-<br>
&gt; =A0mm/memory_hotplug.c =A0| =A0 =A02 +-<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0| =A0156 +++++++++++++++++++++++++++=
++++-------------------<br>
&gt; =A03 files changed, 100 insertions(+), 60 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index 9b91ca4..a062f0b 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -303,7 +303,7 @@ static inline void scan_unevictable_unregister_nod=
e(struct node *node)<br>
&gt; =A0}<br>
&gt; =A0#endif<br>
&gt;<br>
&gt; -extern int kswapd_run(int nid);<br>
&gt; +extern int kswapd_run(int nid, int id);<br>
<br>
</div>&quot;id&quot; is bad name. there is no information. please use memcg=
-id or so on.<br></blockquote><div><br></div><div>will change .=A0</div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #=
ccc solid;padding-left:1ex;">

<div class=3D"im"><br>
<br>
&gt; =A0extern void kswapd_stop(int nid);<br>
&gt;<br>
&gt; =A0#ifdef CONFIG_MMU<br>
&gt; diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c<br>
&gt; index 321fc74..36b4eed 100644<br>
&gt; --- a/mm/memory_hotplug.c<br>
&gt; +++ b/mm/memory_hotplug.c<br>
&gt; @@ -462,7 +462,7 @@ int online_pages(unsigned long pfn, unsigned long =
nr_pages)<br>
&gt; =A0 =A0 =A0 setup_per_zone_wmarks();<br>
&gt; =A0 =A0 =A0 calculate_zone_inactive_ratio(zone);<br>
&gt; =A0 =A0 =A0 if (onlined_pages) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(zone_to_nid(zone));<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(zone_to_nid(zone), 0);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_set_state(zone_to_nid(zone), N_HIGH_M=
EMORY);<br>
&gt; =A0 =A0 =A0 }<br>
&gt;<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 7aba681..63c557e 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -2241,6 +2241,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, uns=
igned long balanced_pages,<br>
&gt; =A0 =A0 =A0 return balanced_pages &gt; (present_pages &gt;&gt; 2);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +#define is_global_kswapd(kswapd_p) ((kswapd_p)-&gt;kswapd_pgdat)<br>
<br>
</div>please use inline function.<br></blockquote><div>=A0</div><div>Hmm. =
=A0see will change next/</div><blockquote class=3D"gmail_quote" style=3D"ma=
rgin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;"><div class=3D=
"im">=A0</div>
</blockquote><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;b=
order-left:1px #ccc solid;padding-left:1ex;"><div class=3D"im">
<br>
<br>
&gt; +<br>
&gt; =A0/* is kswapd sleeping prematurely? */<br>
&gt; =A0static bool sleeping_prematurely(pg_data_t *pgdat, int order, long =
remaining,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 int classzone_idx)<br>
&gt; @@ -2583,40 +2585,46 @@ static void kswapd_try_to_sleep(struct kswapd =
*kswapd_p, int order,<br>
&gt;<br>
&gt; =A0 =A0 =A0 prepare_to_wait(wait_h, &amp;wait, TASK_INTERRUPTIBLE);<br=
>
&gt;<br>
&gt; - =A0 =A0 /* Try to sleep for a short interval */<br>
&gt; - =A0 =A0 if (!sleeping_prematurely(pgdat, order, remaining, classzone=
_idx)) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 remaining =3D schedule_timeout(HZ/10);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(wait_h, &amp;wait, TASK_INTE=
RRUPTIBLE);<br>
&gt; - =A0 =A0 }<br>
&gt; -<br>
&gt; - =A0 =A0 /*<br>
&gt; - =A0 =A0 =A0* After a short sleep, check if it was a premature sleep.=
 If not, then<br>
&gt; - =A0 =A0 =A0* go fully to sleep until explicitly woken up.<br>
&gt; - =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 if (!sleeping_prematurely(pgdat, order, remaining, classzone=
_idx)) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_sleep(pgdat-&gt;node_=
id);<br>
&gt; + =A0 =A0 if (is_global_kswapd(kswapd_p)) {<br>
<br>
</div>bad indentation. :-/<br>
please don&#39;t increase coding mess.<br>
<div class=3D"im"><br>
 =A0 =A0 =A0 =A0if (!is_global_kswapd(kswapd_p)) {<br>
</div> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_try_to_sleep_memcg();<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
 =A0 =A0 =A0 =A0}<br>
<br>
is simpler.<br>
<div><div></div><div class=3D"h5"><br></div></div></blockquote><div>Ok. I w=
ill check on next post.=A0</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;"><div><div c=
lass=3D"h5">

<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* Try to sleep for a short interval */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_prematurely(pgdat, order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 remaining, c=
lasszone_idx)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 remaining =3D schedule_timeo=
ut(HZ/10);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(wait_h, &amp;wai=
t);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(wait_h, &amp=
;wait, TASK_INTERRUPTIBLE);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat counters are not perfectly accur=
ate and the estimated<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0* value for counters such as NR_FREE_PAGE=
S can deviate from the<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0* true value by nr_online_cpus * threshol=
d. To avoid the zone<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0* watermarks being breached while under p=
ressure, we reduce the<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0* per-cpu vmstat threshold while kswapd i=
s awake and restore<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0* them before going back to sleep.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* After a short sleep, check if it was a =
premature sleep.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* If not, then go fully to sleep until ex=
plicitly woken up.<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pgdat, calculate_=
normal_threshold);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pgdat, calculate_=
pressure_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_prematurely(pgdat, order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 remaining, classzone_idx)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_sleep=
(pgdat-&gt;node_id);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(p=
gdat,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 calculate_normal_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(p=
gdat,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 calculate_pressure_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (remaining)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_eve=
nt(KSWAPD_LOW_WMARK_HIT_QUICKLY);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_eve=
nt(KSWAPD_HIGH_WMARK_HIT_QUICKLY);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 } else {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 if (remaining)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(KSWAPD_LOW_WM=
ARK_HIT_QUICKLY);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 else<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(KSWAPD_HIGH_W=
MARK_HIT_QUICKLY);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* For now, we just check the remaining work=
s.*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_kswapd_can_sleep())<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
<br>
<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static unsigned long shrink_mem_cgroup(struct mem_cgroup *mem_cont, i=
nt order)<br>
&gt; +{<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0/*<br>
&gt; =A0 * The background pageout daemon, started as a kernel thread<br>
&gt; =A0 * from the init process.<br>
&gt; @@ -2636,6 +2644,7 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 int classzone_idx;<br>
&gt; =A0 =A0 =A0 struct kswapd *kswapd_p =3D (struct kswapd *)p;<br>
&gt; =A0 =A0 =A0 pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 struct mem_cgroup *mem;<br>
&gt; =A0 =A0 =A0 struct task_struct *tsk =3D current;<br>
&gt;<br>
&gt; =A0 =A0 =A0 struct reclaim_state reclaim_state =3D {<br>
&gt; @@ -2645,9 +2654,11 @@ int kswapd(void *p)<br>
&gt;<br>
&gt; =A0 =A0 =A0 lockdep_set_current_reclaim_state(GFP_KERNEL);<br>
&gt;<br>
&gt; - =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;node_id);<br>
&gt; - =A0 =A0 if (!cpumask_empty(cpumask))<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk, cpumask);<br>
&gt; + =A0 =A0 if (is_global_kswapd(kswapd_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;node_i=
d);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!cpumask_empty(cpumask))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk, cp=
umask);<br>
&gt; + =A0 =A0 }<br>
&gt; =A0 =A0 =A0 current-&gt;reclaim_state =3D &amp;reclaim_state;<br>
&gt;<br>
&gt; =A0 =A0 =A0 /*<br>
&gt; @@ -2662,7 +2673,10 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0* us from recursively trying to free more memory as we&=
#39;re<br>
&gt; =A0 =A0 =A0 =A0* trying to free the first piece of memory in the first=
 place).<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 tsk-&gt;flags |=3D PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;<b=
r>
&gt; + =A0 =A0 if (is_global_kswapd(kswapd_p))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 tsk-&gt;flags |=3D PF_MEMALLOC | PF_SWAPWRIT=
E | PF_KSWAPD;<br>
&gt; + =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 tsk-&gt;flags |=3D PF_SWAPWRITE | PF_KSWAPD;=
<br>
&gt; =A0 =A0 =A0 set_freezable();<br>
&gt;<br>
&gt; =A0 =A0 =A0 order =3D 0;<br>
&gt; @@ -2672,36 +2686,48 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 int new_classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D pgdat-&gt;kswapd_max_order;<br=
>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 new_classzone_idx =3D pgdat-&gt;classzone_id=
x;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_max_order =3D 0;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;classzone_idx =3D MAX_NR_ZONES - 1=
;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 if (order &lt; new_order || classzone_idx &g=
t; new_classzone_idx) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don&#39;t sleep if some=
one wants a larger &#39;order&#39;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* allocation or has tighe=
r zone constraints<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D new_order;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D new_classz=
one_idx;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswapd_p=
, order, classzone_idx);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat-&gt;kswapd_m=
ax_order;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D pgdat-&gt;=
classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (is_global_kswapd(kswapd_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D pgdat-&gt;kswa=
pd_max_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_classzone_idx =3D pgdat-=
&gt;classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_max_order=
 =3D 0;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;classzone_idx =
=3D MAX_NR_ZONES - 1;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (order &lt; new_order ||<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 classzone_idx &gt; new_classzone_idx) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don&#39=
;t sleep if someone wants a larger &#39;order&#39;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* allocat=
ion or has tigher zone constraints<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D ne=
w_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_id=
x =3D new_classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_t=
o_sleep(kswapd_p, order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pg=
dat-&gt;kswapd_max_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_id=
x =3D pgdat-&gt;classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;ks=
wapd_max_order =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;cl=
asszone_idx =3D MAX_NR_ZONES - 1;<br>
<br>
</div></div>-ETOODEEPNEST.<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswapd_p=
, order, classzone_idx);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D try_to_freeze();<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kthread_should_stop())<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (ret)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We can speed up thawing tasks if we d=
on&#39;t call balance_pgdat<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* after returning from the refrigerator=
<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 if (!ret) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (is_global_kswapd(kswapd_p)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_wak=
e(pgdat-&gt;node_id, order);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D balance_pgdat(pg=
dat, order, &amp;classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_get_shrin=
k_target();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_mem_c=
group(mem, order);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_put_shrink_target=
(mem);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
<br>
<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; @@ -2845,30 +2871,44 @@ static int __devinit cpu_callback(struct notif=
ier_block *nfb,<br>
&gt; =A0 * This kswapd start function will be called by init and node-hot-a=
dd.<br>
&gt; =A0 * On node-hot-add, kswapd will moved to proper cpus if cpus are ho=
t-added.<br>
&gt; =A0 */<br>
&gt; -int kswapd_run(int nid)<br>
&gt; +int kswapd_run(int nid, int memcgid)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; =A0 =A0 =A0 struct task_struct *kswapd_tsk;<br>
&gt; + =A0 =A0 pg_data_t *pgdat =3D NULL;<br>
&gt; =A0 =A0 =A0 struct kswapd *kswapd_p;<br>
&gt; + =A0 =A0 static char name[TASK_COMM_LEN];<br>
&gt; =A0 =A0 =A0 int ret =3D 0;<br>
&gt;<br>
&gt; - =A0 =A0 if (pgdat-&gt;kswapd)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; + =A0 =A0 if (!memcgid) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (pgdat-&gt;kswapd)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
&gt; + =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 kswapd_p =3D kzalloc(sizeof(struct kswapd), GFP_KERNEL);<b=
r>
&gt; =A0 =A0 =A0 if (!kswapd_p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt;<br>
&gt; - =A0 =A0 pgdat-&gt;kswapd =3D kswapd_p;<br>
&gt; - =A0 =A0 kswapd_p-&gt;kswapd_wait =3D &amp;pgdat-&gt;kswapd_wait;<br>
&gt; - =A0 =A0 kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
&gt; + =A0 =A0 if (!memcgid) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd =3D kswapd_p;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_wait =3D &amp;pgdat-&gt;=
kswapd_wait;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, TASK_COMM_LEN, &quot;kswapd_%=
d&quot;, nid);<br>
&gt; + =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_wait =3D mem_cgroup_kswa=
pd_waitq();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, TASK_COMM_LEN, &quot;memcg_%d=
&quot;, memcgid);<br>
&gt; + =A0 =A0 }<br>
&gt;<br>
&gt; - =A0 =A0 kswapd_tsk =3D kthread_run(kswapd, kswapd_p, &quot;kswapd%d&=
quot;, nid);<br>
<br>
</div></div>You seems to change kswapd name slightly.<br>
<div class=3D"im"><br>
<br>
<br>
&gt; + =A0 =A0 kswapd_tsk =3D kthread_run(kswapd, kswapd_p, name);<br>
&gt; =A0 =A0 =A0 if (IS_ERR(kswapd_tsk)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* failure at boot is fatal */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(system_state =3D=3D SYSTEM_BOOTING)=
;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 printk(&quot;Failed to start kswapd on node =
%d\n&quot;,nid);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd =3D NULL;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!memcgid) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR &quot;Failed=
 to start kswapd on node %d\n&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd =3D NULL;<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR &quot;Failed=
 to start kswapd on memcg\n&quot;);<br>
<br>
</div>Why don&#39;t you show memcg-id here?<br></blockquote><div><br></div>=
<div>will change.=A0</div><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(kswapd_p);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -1;<br>
&gt; =A0 =A0 =A0 } else<br>
&gt; @@ -2899,7 +2939,7 @@ static int __init kswapd_init(void)<br>
&gt;<br>
&gt; =A0 =A0 =A0 swap_setup();<br>
&gt; =A0 =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(nid, 0);<br>
&gt; =A0 =A0 =A0 hotcpu_notifier(cpu_callback, 0);<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
<br>
<br>
<br>
</div></div></blockquote></div><br>

--002354470aa837808604a17b8ea4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
