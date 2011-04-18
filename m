Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D7167900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 14:09:50 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p3II9i33022627
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:09:45 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by kpbe11.cbf.corp.google.com with ESMTP id p3II9erN010386
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:09:43 -0700
Received: by qwb8 with SMTP id 8so3235282qwb.25
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 11:09:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikgoSt4VUY63J+G6mUJJDCL+NWH8Q@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-2-git-send-email-yinghan@google.com>
	<BANLkTikgoSt4VUY63J+G6mUJJDCL+NWH8Q@mail.gmail.com>
Date: Mon, 18 Apr 2011 11:09:40 -0700
Message-ID: <BANLkTi=h5DUL1k-31WDP3KfjmiNR8FTckQ@mail.gmail.com>
Subject: Re: [PATCH V5 01/10] Add kswapd descriptor
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd082953c5904a1354b3b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd082953c5904a1354b3b
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Apr 17, 2011 at 5:57 PM, Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi Ying,
>
> I have some comments and nitpick about coding style.
>

Hi Minchan, thank you for your comments and reviews.

>
> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> > There is a kswapd kernel thread for each numa node. We will add a
> different
> > kswapd for each memcg. The kswapd is sleeping in the wait queue headed at
>
> Why?
>
> Easily, many kernel developers raise an eyebrow to increase kernel thread.
> So you should justify why we need new kernel thread, why we can't
> handle it with workqueue.
>
> Maybe you explained it and I didn't know it. If it is, sorry.
> But at least, the patch description included _why_ is much mergeable
> to maintainers and helpful to review the code to reviewers.
>

Here are the replies i posted on earlier version regarding on workqueue.

"
I did some study on workqueue after posting V2. There was a comment
suggesting workqueue instead of per-memcg kswapd thread, since it will cut
the number of kernel threads being created in host with lots of cgroups.
Each kernel thread allocates about 8K of stack and 8M in total w/ thousand
of cgroups.

The current workqueue model merged in 2.6.36 kernel is called "concurrency
managed workqueu(cmwq)", which is intended to provide flexible concurrency
without wasting resources. I studied a bit and here it is:

1. The workqueue is complicated and we need to be very careful of work items
in the workqueue. We've experienced in one workitem stucks and the rest of
the work item won't proceed. For example in dirty page writeback,  one
heavily writer cgroup could starve the other cgroups from flushing dirty
pages to the same disk. In the kswapd case, I can image we might have
similar scenario.

2. How to prioritize the workitems is another problem. The order of adding
the workitems in the queue reflects the order of cgroups being reclaimed. We
don't have that restriction currently but relying on the cpu scheduler to
put kswapd on the right cpu-core to run. We "might" introduce priority later
for reclaim and how are we gonna deal with that.

3. Based on what i observed, not many callers has migrated to the cmwq and I
don't have much data of how good it is.

Back to the current model, on machine with thousands of cgroups which it
will take 8M total for thousand of kswapd threads (8K stack for each
thread).  We are running system with fakenuma which each numa node has a
kswapd. So far we haven't noticed issue caused by "lots of" kswapd threads.
Also, there shouldn't be any performance overhead for kernel thread if it is
not running.

Based on the complexity of workqueue and the benefit it provides, I would
like to stick to the current model first. After we get the basic stuff in
and other targeting reclaim improvement, we can come back to this. What do
you think?
"

KAMEZAWA's reply:
"
Okay, fair enough. kthread_run() will win.

Then, I have another request. I'd like to kswapd-for-memcg to some cpu
cgroup to limit cpu usage.

- Could you show thread ID somewhere ? and
 confirm we can put it to some cpu cgroup ?
 (creating a auto cpu cgroup for memcg kswapd is a choice, I think.)
"


> > kswapd_wait field of a kswapd descriptor. The kswapd descriptor stores
> > information of node or memcg and it allows the global and per-memcg
> background
> > reclaim to share common reclaim algorithms.
> >
> > This patch adds the kswapd descriptor and moves the per-node kswapd to
> use the
> > new structure.
> >
> > changelog v5..v4:
> > 1. add comment on kswapds_spinlock
> > 2. remove the kswapds_spinlock. we don't need it here since the kswapd
> and pgdat
> > have 1:1 mapping.
> >
> > changelog v3..v2:
> > 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later patch.
> > 2. rename thr in kswapd_run to something else.
> >
> > changelog v2..v1:
> > 1. dynamic allocate kswapd descriptor and initialize the wait_queue_head
> of pgdat
> > at kswapd_run.
> > 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup
> kswapd
> > descriptor.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  include/linux/mmzone.h |    3 +-
> >  include/linux/swap.h   |    7 ++++
> >  mm/page_alloc.c        |    1 -
> >  mm/vmscan.c            |   89
> +++++++++++++++++++++++++++++++++++------------
> >  4 files changed, 74 insertions(+), 26 deletions(-)
> >
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 628f07b..6cba7d2 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -640,8 +640,7 @@ typedef struct pglist_data {
> >        unsigned long node_spanned_pages; /* total size of physical page
> >                                             range, including holes */
> >        int node_id;
> > -       wait_queue_head_t kswapd_wait;
> > -       struct task_struct *kswapd;
> > +       wait_queue_head_t *kswapd_wait;
>
> Personally, I prefer kswapd not kswapd_wait.
> It's more readable and straightforward.
>

hmm. I would like to keep as it is for this version, and improve it after
the basic stuff are in. Hope that works for you?


> >        int kswapd_max_order;
> >        enum zone_type classzone_idx;
> >  } pg_data_t;
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index ed6ebe6..f43d406 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -26,6 +26,13 @@ static inline int current_is_kswapd(void)
> >        return current->flags & PF_KSWAPD;
> >  }
> >
> > +struct kswapd {
> > +       struct task_struct *kswapd_task;
> > +       wait_queue_head_t kswapd_wait;
> > +       pg_data_t *kswapd_pgdat;
> > +};
> > +
> > +int kswapd(void *p);
> >  /*
> >  * MAX_SWAPFILES defines the maximum number of swaptypes: things which
> can
> >  * be swapped to.  The swap type and the offset into that swap type are
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 6e1b52a..6340865 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4205,7 +4205,6 @@ static void __paginginit free_area_init_core(struct
> pglist_data *pgdat,
> >
> >        pgdat_resize_init(pgdat);
> >        pgdat->nr_zones = 0;
> > -       init_waitqueue_head(&pgdat->kswapd_wait);
> >        pgdat->kswapd_max_order = 0;
> >        pgdat_page_cgroup_init(pgdat);
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 060e4c1..61fb96e 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2242,12 +2242,13 @@ static bool pgdat_balanced(pg_data_t *pgdat,
> unsigned long balanced_pages,
> >  }
> >
> >  /* is kswapd sleeping prematurely? */
> > -static bool sleeping_prematurely(pg_data_t *pgdat, int order, long
> remaining,
> > -                                       int classzone_idx)
> > +static int sleeping_prematurely(struct kswapd *kswapd, int order,
> > +                               long remaining, int classzone_idx)
> >  {
> >        int i;
> >        unsigned long balanced = 0;
> >        bool all_zones_ok = true;
> > +       pg_data_t *pgdat = kswapd->kswapd_pgdat;
> >
> >        /* If a direct reclaimer woke kswapd within HZ/10, it's premature
> */
> >        if (remaining)
> > @@ -2570,28 +2571,31 @@ out:
> >        return order;
> >  }
> >
> > -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int
> classzone_idx)
> > +static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
> > +                               int classzone_idx)
> >  {
> >        long remaining = 0;
> >        DEFINE_WAIT(wait);
> > +       pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> > +       wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
>
> kswapd_p? p means pointer?
>
yes,

> wait_h? h means header?
>
 yes,

Hmm.. Of course, it's trivial and we can understand easily in such
> context but we don't have been used such words so it's rather awkward
> to me.
>
> How about kswapd instead of kswapd_p, kswapd_wait instead of wait_h?
>

that sounds ok for me for the change. however i would like to make the
change as sperate patch after the basic stuff are in. Is that ok?

>
> >
> >        if (freezing(current) || kthread_should_stop())
> >                return;
> >
> > -       prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > +       prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> >
> >        /* Try to sleep for a short interval */
> > -       if (!sleeping_prematurely(pgdat, order, remaining,
> classzone_idx)) {
> > +       if (!sleeping_prematurely(kswapd_p, order, remaining,
> classzone_idx)) {
> >                remaining = schedule_timeout(HZ/10);
> > -               finish_wait(&pgdat->kswapd_wait, &wait);
> > -               prepare_to_wait(&pgdat->kswapd_wait, &wait,
> TASK_INTERRUPTIBLE);
> > +               finish_wait(wait_h, &wait);
> > +               prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE);
> >        }
> >
> >        /*
> >         * After a short sleep, check if it was a premature sleep. If not,
> then
> >         * go fully to sleep until explicitly woken up.
> >         */
> > -       if (!sleeping_prematurely(pgdat, order, remaining,
> classzone_idx)) {
> > +       if (!sleeping_prematurely(kswapd_p, order, remaining,
> classzone_idx)) {
> >                trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> >
> >                /*
> > @@ -2611,7 +2615,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat,
> int order, int classzone_idx)
> >                else
> >                        count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> >        }
> > -       finish_wait(&pgdat->kswapd_wait, &wait);
> > +       finish_wait(wait_h, &wait);
> >  }
> >
> >  /*
> > @@ -2627,20 +2631,24 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat,
> int order, int classzone_idx)
> >  * If there are applications that are active memory-allocators
> >  * (most normal use), this basically shouldn't matter.
> >  */
> > -static int kswapd(void *p)
> > +int kswapd(void *p)
> >  {
> >        unsigned long order;
> >        int classzone_idx;
> > -       pg_data_t *pgdat = (pg_data_t*)p;
> > +       struct kswapd *kswapd_p = (struct kswapd *)p;
> > +       pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> > +       wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
> >        struct task_struct *tsk = current;
> >
> >        struct reclaim_state reclaim_state = {
> >                .reclaimed_slab = 0,
> >        };
> > -       const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
> > +       const struct cpumask *cpumask;
> >
> >        lockdep_set_current_reclaim_state(GFP_KERNEL);
> >
> > +       BUG_ON(pgdat->kswapd_wait != wait_h);
>
> If we include kswapd instead of kswapd_wait in pgdat, maybe we could
> remove the check?
>
> > +       cpumask = cpumask_of_node(pgdat->node_id);
> >        if (!cpumask_empty(cpumask))
> >                set_cpus_allowed_ptr(tsk, cpumask);
> >        current->reclaim_state = &reclaim_state;
> > @@ -2679,7 +2687,7 @@ static int kswapd(void *p)
> >                        order = new_order;
> >                        classzone_idx = new_classzone_idx;
> >                } else {
> > -                       kswapd_try_to_sleep(pgdat, order, classzone_idx);
> > +                       kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> >                        order = pgdat->kswapd_max_order;
> >                        classzone_idx = pgdat->classzone_idx;
> >                        pgdat->kswapd_max_order = 0;
> > @@ -2719,13 +2727,13 @@ void wakeup_kswapd(struct zone *zone, int order,
> enum zone_type classzone_idx)
> >                pgdat->kswapd_max_order = order;
> >                pgdat->classzone_idx = min(pgdat->classzone_idx,
> classzone_idx);
> >        }
> > -       if (!waitqueue_active(&pgdat->kswapd_wait))
> > +       if (!waitqueue_active(pgdat->kswapd_wait))
> >                return;
> >        if (zone_watermark_ok_safe(zone, order, low_wmark_pages(zone), 0,
> 0))
> >                return;
> >
> >        trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone),
> order);
> > -       wake_up_interruptible(&pgdat->kswapd_wait);
> > +       wake_up_interruptible(pgdat->kswapd_wait);
> >  }
> >
> >  /*
> > @@ -2817,12 +2825,21 @@ static int __devinit cpu_callback(struct
> notifier_block *nfb,
> >                for_each_node_state(nid, N_HIGH_MEMORY) {
> >                        pg_data_t *pgdat = NODE_DATA(nid);
> >                        const struct cpumask *mask;
> > +                       struct kswapd *kswapd_p;
> > +                       struct task_struct *kswapd_thr;
> > +                       wait_queue_head_t *wait;
> >
> >                        mask = cpumask_of_node(pgdat->node_id);
> >
> > +                       wait = pgdat->kswapd_wait;
> > +                       kswapd_p = container_of(wait, struct kswapd,
> > +                                               kswapd_wait);
> > +                       kswapd_thr = kswapd_p->kswapd_task;
>
> kswapd_thr? thr means thread?
> How about tsk?
>

ok. I made the change and will be included in the next post.

>
> > +
> If we include kswapd instead of kswapd_wait in pgdat, don't we make this
> simple?
>
> struct kswapd *kswapd = pgdat->kswapd;
> struct task_struct *kswapd_tsk = kswapd->kswapd_task;
>
>
> >                        if (cpumask_any_and(cpu_online_mask, mask) <
> nr_cpu_ids)
> >                                /* One of our CPUs online: restore mask */
> > -                               set_cpus_allowed_ptr(pgdat->kswapd,
> mask);
> > +                               if (kswapd_thr)
> > +                                       set_cpus_allowed_ptr(kswapd_thr,
> mask);
> >                }
> >        }
> >        return NOTIFY_OK;
> > @@ -2835,18 +2852,31 @@ static int __devinit cpu_callback(struct
> notifier_block *nfb,
> >  int kswapd_run(int nid)
> >  {
> >        pg_data_t *pgdat = NODE_DATA(nid);
> > +       struct task_struct *kswapd_thr;
> > +       struct kswapd *kswapd_p;
> >        int ret = 0;
> >
> > -       if (pgdat->kswapd)
> > +       if (pgdat->kswapd_wait)
> >                return 0;
> >
> > -       pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
> > -       if (IS_ERR(pgdat->kswapd)) {
> > +       kswapd_p = kzalloc(sizeof(struct kswapd), GFP_KERNEL);
> > +       if (!kswapd_p)
> > +               return -ENOMEM;
> > +
> > +       init_waitqueue_head(&kswapd_p->kswapd_wait);
> > +       pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
> > +       kswapd_p->kswapd_pgdat = pgdat;
> > +
> > +       kswapd_thr = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
> > +       if (IS_ERR(kswapd_thr)) {
> >                /* failure at boot is fatal */
> >                BUG_ON(system_state == SYSTEM_BOOTING);
> >                printk("Failed to start kswapd on node %d\n",nid);
> > +               pgdat->kswapd_wait = NULL;
> > +               kfree(kswapd_p);
> >                ret = -1;
> > -       }
> > +       } else
> > +               kswapd_p->kswapd_task = kswapd_thr;
> >        return ret;
> >  }
> >
> > @@ -2855,10 +2885,23 @@ int kswapd_run(int nid)
> >  */
> >  void kswapd_stop(int nid)
> >  {
> > -       struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
> > +       struct task_struct *kswapd_thr = NULL;
> > +       struct kswapd *kswapd_p = NULL;
> > +       wait_queue_head_t *wait;
> > +
> > +       pg_data_t *pgdat = NODE_DATA(nid);
> > +
> > +       wait = pgdat->kswapd_wait;
> > +       if (wait) {
> > +               kswapd_p = container_of(wait, struct kswapd,
> kswapd_wait);
> > +               kswapd_thr = kswapd_p->kswapd_task;
> > +               kswapd_p->kswapd_task = NULL;
> > +       }
> > +
> > +       if (kswapd_thr)
> > +               kthread_stop(kswapd_thr);
> >
> > -       if (kswapd)
> > -               kthread_stop(kswapd);
> > +       kfree(kswapd_p);
> >  }
> >
> >  static int __init kswapd_init(void)
> > --
> > 1.7.3.1
> >
> >
>
> Hmm, I don't like kswapd_p, kswapd_thr, wait_h and kswapd_wait of pgdat.
> But it's just my personal opinion. :)
>

Thank you for your comments :)

>
>
> --
> Kind regards,
> Minchan Kim
>

--000e0cdfd082953c5904a1354b3b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, Apr 17, 2011 at 5:57 PM, Minchan=
 Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan=
.kim@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hi Ying,<br>
<br>
I have some comments and nitpick about coding style.<br></blockquote><div><=
br></div><div>Hi Minchan, thank you for your comments and reviews.=A0=A0</d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex;">

<div class=3D"im"><br>
On Sat, Apr 16, 2011 at 8:23 AM, Ying Han &lt;<a href=3D"mailto:yinghan@goo=
gle.com">yinghan@google.com</a>&gt; wrote:<br>
&gt; There is a kswapd kernel thread for each numa node. We will add a diff=
erent<br>
&gt; kswapd for each memcg. The kswapd is sleeping in the wait queue headed=
 at<br>
<br>
</div>Why?<br>
<br>
Easily, many kernel developers raise an eyebrow to increase kernel thread.<=
br>
So you should justify why we need new kernel thread, why we can&#39;t<br>
handle it with workqueue.<br>
<br>
Maybe you explained it and I didn&#39;t know it. If it is, sorry.<br>
But at least, the patch description included _why_ is much mergeable<br>
to maintainers and helpful to review the code to reviewers.<br></blockquote=
><div><br></div><div>Here are the replies i posted on earlier version regar=
ding on workqueue.</div><div><br></div><div>&quot;</div><meta http-equiv=3D=
"content-type" content=3D"text/html; charset=3Dutf-8"><span class=3D"Apple-=
style-span" style=3D"border-collapse: collapse; font-family: arial, sans-se=
rif; font-size: 13px; "><div>
I did some study on=A0<span class=3D"il" style=3D"background-image: initial=
; background-attachment: initial; background-origin: initial; background-cl=
ip: initial; background-color: rgb(207, 223, 229); color: rgb(82, 81, 81); =
background-position: initial initial; background-repeat: initial initial; "=
>workqueue</span>=A0after posting V2. There was a comment=A0<span style=3D"=
border-collapse: collapse; font-family: arial, sans-serif; font-size: 13px;=
 ">suggesting=A0<span class=3D"il" style=3D"background-image: initial; back=
ground-attachment: initial; background-origin: initial; background-clip: in=
itial; background-color: rgb(207, 223, 229); color: rgb(82, 81, 81); backgr=
ound-position: initial initial; background-repeat: initial initial; ">workq=
ueue</span>=A0instead of per-memcg kswapd thread, since it will cut the num=
ber of kernel threads being created in host with lots of cgroups. Each kern=
el thread allocates about 8K of stack and 8M in total w/ thousand of cgroup=
s.</span></div>
<br><font face=3D"arial, sans-serif"><span style=3D"border-collapse: collap=
se; ">The current=A0<span class=3D"il" style=3D"background-image: initial; =
background-attachment: initial; background-origin: initial; background-clip=
: initial; background-color: rgb(207, 223, 229); color: rgb(82, 81, 81); ba=
ckground-position: initial initial; background-repeat: initial initial; ">w=
orkqueue</span>=A0model merged in 2.6.36 kernel is called &quot;concurrency=
 managed workqueu(cmwq)&quot;, which is intended to provide flexible concur=
rency without wasting resources. I studied a bit and here it is:</span></fo=
nt><br>
<br><font face=3D"arial, sans-serif"><span style=3D"border-collapse: collap=
se; ">1. The=A0<span class=3D"il" style=3D"background-image: initial; backg=
round-attachment: initial; background-origin: initial; background-clip: ini=
tial; background-color: rgb(207, 223, 229); color: rgb(82, 81, 81); backgro=
und-position: initial initial; background-repeat: initial initial; ">workqu=
eue</span>=A0is complicated and we need to be very careful of=A0<span class=
=3D"il" style=3D"background-image: initial; background-attachment: initial;=
 background-origin: initial; background-clip: initial; background-color: rg=
b(207, 223, 229); color: rgb(82, 81, 81); background-position: initial init=
ial; background-repeat: initial initial; ">work</span>=A0items in the=A0<sp=
an class=3D"il" style=3D"background-image: initial; background-attachment: =
initial; background-origin: initial; background-clip: initial; background-c=
olor: rgb(207, 223, 229); color: rgb(82, 81, 81); background-position: init=
ial initial; background-repeat: initial initial; ">workqueue</span>. We&#39=
;ve experienced in one workitem stucks and the rest of the=A0<span class=3D=
"il" style=3D"background-image: initial; background-attachment: initial; ba=
ckground-origin: initial; background-clip: initial; background-color: rgb(2=
07, 223, 229); color: rgb(82, 81, 81); background-position: initial initial=
; background-repeat: initial initial; ">work</span>=A0item won&#39;t procee=
d. For example in dirty page writeback, =A0one heavily writer cgroup could =
starve the other cgroups from flushing dirty pages to the same disk. In the=
 kswapd case, I can image we might have similar scenario.</span></font><br>
<br><font face=3D"arial, sans-serif"><span style=3D"border-collapse: collap=
se; ">2. How to prioritize the workitems is another problem. The order of a=
dding the workitems in the=A0<span class=3D"il" style=3D"background-image: =
initial; background-attachment: initial; background-origin: initial; backgr=
ound-clip: initial; background-color: rgb(207, 223, 229); color: rgb(82, 81=
, 81); background-position: initial initial; background-repeat: initial ini=
tial; ">queue</span>=A0reflects the order of cgroups being reclaimed. We do=
n&#39;t have that restriction currently but relying on the cpu scheduler to=
 put kswapd on the right cpu-core to run. We &quot;might&quot; introduce pr=
iority later for reclaim and how are we gonna deal with that.</span></font>=
<br>
<br></span><div><span class=3D"Apple-style-span" style=3D"border-collapse: =
collapse; font-family: arial, sans-serif; font-size: 13px; ">3. Based on wh=
at i observed, not many callers has migrated to the cmwq and I don&#39;t ha=
ve much data of how good it is.</span>=A0</div>
<div><br></div><div><meta http-equiv=3D"content-type" content=3D"text/html;=
 charset=3Dutf-8"><span class=3D"Apple-style-span" style=3D"border-collapse=
: collapse; font-family: arial, sans-serif; font-size: 13px; "><font face=
=3D"arial, sans-serif"><span style=3D"border-collapse: collapse; ">Back to =
the current model, on machine with thousands of cgroups which it will take =
8M total for thousand of kswapd threads (8K stack for each thread). =A0We a=
re running system with fakenuma which each numa node has a kswapd. So far w=
e haven&#39;t noticed issue caused by &quot;lots of&quot;=A0kswapd threads.=
 Also, there shouldn&#39;t be any performance overhead for kernel thread if=
 it is not running.</span></font><br>
<br><div><span style=3D"border-collapse: collapse; font-family: arial, sans=
-serif; ">Based on the complexity of=A0<span class=3D"il" style=3D"backgrou=
nd-image: initial; background-attachment: initial; background-origin: initi=
al; background-clip: initial; background-color: rgb(207, 223, 229); color: =
rgb(82, 81, 81); background-position: initial initial; background-repeat: i=
nitial initial; ">workqueue</span>=A0and the benefit it provides, I would l=
ike to stick to the current model first. After we get the basic stuff in an=
d other=A0targeting=A0reclaim improvement, we can come back to this. What d=
o you think?</span></div>
<div><span style=3D"border-collapse: collapse; font-family: arial, sans-ser=
if; ">&quot;</span></div><div><span style=3D"border-collapse: collapse; fon=
t-family: arial, sans-serif; "><br></span></div><div><span style=3D"border-=
collapse: collapse; font-family: arial, sans-serif; ">KAMEZAWA&#39;s reply:=
=A0</span></div>
<div><span style=3D"border-collapse: collapse; font-family: arial, sans-ser=
if; ">&quot;</span></div><div><span style=3D"border-collapse: collapse; fon=
t-family: arial, sans-serif; "><meta http-equiv=3D"content-type" content=3D=
"text/html; charset=3Dutf-8">Okay, fair enough. kthread_run() will win.<br>
<br>Then, I have another request. I&#39;d like to kswapd-for-memcg to some =
cpu<br>cgroup to limit cpu usage.<br><br>- Could you show thread ID somewhe=
re ? and<br>=A0confirm we can put it to some cpu cgroup ?<br>=A0(creating a=
 auto cpu cgroup for memcg kswapd is a choice, I think.)</span></div>
<div><span style=3D"border-collapse: collapse; font-family: arial, sans-ser=
if; ">&quot;</span></div><div><span style=3D"border-collapse: collapse; fon=
t-family: arial, sans-serif; "><br></span></div></span></div><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex;">

<div><div></div><div class=3D"h5"><br>
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
&gt; changelog v5..v4:<br>
&gt; 1. add comment on kswapds_spinlock<br>
&gt; 2. remove the kswapds_spinlock. we don&#39;t need it here since the ks=
wapd and pgdat<br>
&gt; have 1:1 mapping.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later pat=
ch.<br>
&gt; 2. rename thr in kswapd_run to something else.<br>
&gt;<br>
&gt; changelog v2..v1:<br>
&gt; 1. dynamic allocate kswapd descriptor and initialize the wait_queue_he=
ad of pgdat<br>
&gt; at kswapd_run.<br>
&gt; 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup =
kswapd<br>
&gt; descriptor.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0include/linux/mmzone.h | =A0 =A03 +-<br>
&gt; =A0include/linux/swap.h =A0 | =A0 =A07 ++++<br>
&gt; =A0mm/page_alloc.c =A0 =A0 =A0 =A0| =A0 =A01 -<br>
&gt; =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 89 +++++++++++++++++++++++=
++++++++++++------------<br>
&gt; =A04 files changed, 74 insertions(+), 26 deletions(-)<br>
&gt;<br>
&gt; diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h<br>
&gt; index 628f07b..6cba7d2 100644<br>
&gt; --- a/include/linux/mmzone.h<br>
&gt; +++ b/include/linux/mmzone.h<br>
&gt; @@ -640,8 +640,7 @@ typedef struct pglist_data {<br>
&gt; =A0 =A0 =A0 =A0unsigned long node_spanned_pages; /* total size of phys=
ical page<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 range, including holes */<br>
&gt; =A0 =A0 =A0 =A0int node_id;<br>
&gt; - =A0 =A0 =A0 wait_queue_head_t kswapd_wait;<br>
&gt; - =A0 =A0 =A0 struct task_struct *kswapd;<br>
&gt; + =A0 =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
<br>
</div></div>Personally, I prefer kswapd not kswapd_wait.<br>
It&#39;s more readable and straightforward.<br></blockquote><div><br></div>=
<div>hmm. I would like to keep as it is for this version, and improve it af=
ter the basic stuff are in. Hope that works for you?=A0</div><div><br></div=
>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div><div class=3D"h5"><br>
&gt; =A0 =A0 =A0 =A0int kswapd_max_order;<br>
&gt; =A0 =A0 =A0 =A0enum zone_type classzone_idx;<br>
&gt; =A0} pg_data_t;<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index ed6ebe6..f43d406 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -26,6 +26,13 @@ static inline int current_is_kswapd(void)<br>
&gt; =A0 =A0 =A0 =A0return current-&gt;flags &amp; PF_KSWAPD;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +struct kswapd {<br>
&gt; + =A0 =A0 =A0 struct task_struct *kswapd_task;<br>
&gt; + =A0 =A0 =A0 wait_queue_head_t kswapd_wait;<br>
&gt; + =A0 =A0 =A0 pg_data_t *kswapd_pgdat;<br>
&gt; +};<br>
&gt; +<br>
&gt; +int kswapd(void *p);<br>
&gt; =A0/*<br>
&gt; =A0* MAX_SWAPFILES defines the maximum number of swaptypes: things whi=
ch can<br>
&gt; =A0* be swapped to. =A0The swap type and the offset into that swap typ=
e are<br>
&gt; diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
&gt; index 6e1b52a..6340865 100644<br>
&gt; --- a/mm/page_alloc.c<br>
&gt; +++ b/mm/page_alloc.c<br>
&gt; @@ -4205,7 +4205,6 @@ static void __paginginit free_area_init_core(str=
uct pglist_data *pgdat,<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0pgdat_resize_init(pgdat);<br>
&gt; =A0 =A0 =A0 =A0pgdat-&gt;nr_zones =3D 0;<br>
&gt; - =A0 =A0 =A0 init_waitqueue_head(&amp;pgdat-&gt;kswapd_wait);<br>
&gt; =A0 =A0 =A0 =A0pgdat-&gt;kswapd_max_order =3D 0;<br>
&gt; =A0 =A0 =A0 =A0pgdat_page_cgroup_init(pgdat);<br>
&gt;<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 060e4c1..61fb96e 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -2242,12 +2242,13 @@ static bool pgdat_balanced(pg_data_t *pgdat, u=
nsigned long balanced_pages,<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/* is kswapd sleeping prematurely? */<br>
&gt; -static bool sleeping_prematurely(pg_data_t *pgdat, int order, long re=
maining,<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 int classzone_idx)<br>
&gt; +static int sleeping_prematurely(struct kswapd *kswapd, int order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long rem=
aining, int classzone_idx)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0int i;<br>
&gt; =A0 =A0 =A0 =A0unsigned long balanced =3D 0;<br>
&gt; =A0 =A0 =A0 =A0bool all_zones_ok =3D true;<br>
&gt; + =A0 =A0 =A0 pg_data_t *pgdat =3D kswapd-&gt;kswapd_pgdat;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0/* If a direct reclaimer woke kswapd within HZ/10, it&#=
39;s premature */<br>
&gt; =A0 =A0 =A0 =A0if (remaining)<br>
&gt; @@ -2570,28 +2571,31 @@ out:<br>
&gt; =A0 =A0 =A0 =A0return order;<br>
&gt; =A0}<br>
&gt;<br>
&gt; -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int clas=
szone_idx)<br>
&gt; +static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,<b=
r>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int clas=
szone_idx)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0long remaining =3D 0;<br>
&gt; =A0 =A0 =A0 =A0DEFINE_WAIT(wait);<br>
&gt; + =A0 =A0 =A0 pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 =A0 wait_queue_head_t *wait_h =3D &amp;kswapd_p-&gt;kswapd_w=
ait;<br>
<br>
</div></div>kswapd_p? p means pointer?<br></blockquote><div>yes,=A0</div><b=
lockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px =
#ccc solid;padding-left:1ex;">
wait_h? h means header?<br>
</blockquote><div>=A0yes,</div><div><br></div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">Hmm.. Of course, it&#39;s trivial and we can understand easily in such<b=
r>

context but we don&#39;t have been used such words so it&#39;s rather awkwa=
rd<br>
to me.<br>
<br>
How about kswapd instead of kswapd_p, kswapd_wait instead of wait_h?<br></b=
lockquote><div><br></div><div>that sounds ok for me for the change. however=
 i would like to make the change as sperate patch after the basic stuff are=
 in. Is that ok?=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div><div class=3D"h5"><br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0if (freezing(current) || kthread_should_stop())<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 prepare_to_wait(&amp;pgdat-&gt;kswapd_wait, &amp;wait, T=
ASK_INTERRUPTIBLE);<br>
&gt; + =A0 =A0 =A0 prepare_to_wait(wait_h, &amp;wait, TASK_INTERRUPTIBLE);<=
br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0/* Try to sleep for a short interval */<br>
&gt; - =A0 =A0 =A0 if (!sleeping_prematurely(pgdat, order, remaining, class=
zone_idx)) {<br>
&gt; + =A0 =A0 =A0 if (!sleeping_prematurely(kswapd_p, order, remaining, cl=
asszone_idx)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0remaining =3D schedule_timeout(HZ/10);<=
br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(&amp;pgdat-&gt;kswapd_wait, =
&amp;wait);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(&amp;pgdat-&gt;kswapd_wa=
it, &amp;wait, TASK_INTERRUPTIBLE);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(wait_h, &amp;wait, TASK_=
INTERRUPTIBLE);<br>
&gt; =A0 =A0 =A0 =A0}<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0/*<br>
&gt; =A0 =A0 =A0 =A0 * After a short sleep, check if it was a premature sle=
ep. If not, then<br>
&gt; =A0 =A0 =A0 =A0 * go fully to sleep until explicitly woken up.<br>
&gt; =A0 =A0 =A0 =A0 */<br>
&gt; - =A0 =A0 =A0 if (!sleeping_prematurely(pgdat, order, remaining, class=
zone_idx)) {<br>
&gt; + =A0 =A0 =A0 if (!sleeping_prematurely(kswapd_p, order, remaining, cl=
asszone_idx)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0trace_mm_vmscan_kswapd_sleep(pgdat-&gt;=
node_id);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
&gt; @@ -2611,7 +2615,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat=
, int order, int classzone_idx)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count_vm_event(KSWAPD_H=
IGH_WMARK_HIT_QUICKLY);<br>
&gt; =A0 =A0 =A0 =A0}<br>
&gt; - =A0 =A0 =A0 finish_wait(&amp;pgdat-&gt;kswapd_wait, &amp;wait);<br>
&gt; + =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -2627,20 +2631,24 @@ static void kswapd_try_to_sleep(pg_data_t *pgd=
at, int order, int classzone_idx)<br>
&gt; =A0* If there are applications that are active memory-allocators<br>
&gt; =A0* (most normal use), this basically shouldn&#39;t matter.<br>
&gt; =A0*/<br>
&gt; -static int kswapd(void *p)<br>
&gt; +int kswapd(void *p)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0unsigned long order;<br>
&gt; =A0 =A0 =A0 =A0int classzone_idx;<br>
&gt; - =A0 =A0 =A0 pg_data_t *pgdat =3D (pg_data_t*)p;<br>
&gt; + =A0 =A0 =A0 struct kswapd *kswapd_p =3D (struct kswapd *)p;<br>
&gt; + =A0 =A0 =A0 pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 =A0 wait_queue_head_t *wait_h =3D &amp;kswapd_p-&gt;kswapd_w=
ait;<br>
&gt; =A0 =A0 =A0 =A0struct task_struct *tsk =3D current;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0struct reclaim_state reclaim_state =3D {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.reclaimed_slab =3D 0,<br>
&gt; =A0 =A0 =A0 =A0};<br>
&gt; - =A0 =A0 =A0 const struct cpumask *cpumask =3D cpumask_of_node(pgdat-=
&gt;node_id);<br>
&gt; + =A0 =A0 =A0 const struct cpumask *cpumask;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0lockdep_set_current_reclaim_state(GFP_KERNEL);<br>
&gt;<br>
&gt; + =A0 =A0 =A0 BUG_ON(pgdat-&gt;kswapd_wait !=3D wait_h);<br>
<br>
</div></div>If we include kswapd instead of kswapd_wait in pgdat, maybe we =
could<br>
remove the check?<br>
<br>
&gt; + =A0 =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;node_id);<br>
<div><div></div><div class=3D"h5">&gt; =A0 =A0 =A0 =A0if (!cpumask_empty(cp=
umask))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_cpus_allowed_ptr(tsk, cpumask);<br>
&gt; =A0 =A0 =A0 =A0current-&gt;reclaim_state =3D &amp;reclaim_state;<br>
&gt; @@ -2679,7 +2687,7 @@ static int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0order =3D new_order;<br=
>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0classzone_idx =3D new_c=
lasszone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(pgda=
t, order, classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswa=
pd_p, order, classzone_idx);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0order =3D pgdat-&gt;ksw=
apd_max_order;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0classzone_idx =3D pgdat=
-&gt;classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;kswapd_max_or=
der =3D 0;<br>
&gt; @@ -2719,13 +2727,13 @@ void wakeup_kswapd(struct zone *zone, int orde=
r, enum zone_type classzone_idx)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;kswapd_max_order =3D order;<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;classzone_idx =3D min(pgdat-&=
gt;classzone_idx, classzone_idx);<br>
&gt; =A0 =A0 =A0 =A0}<br>
&gt; - =A0 =A0 =A0 if (!waitqueue_active(&amp;pgdat-&gt;kswapd_wait))<br>
&gt; + =A0 =A0 =A0 if (!waitqueue_active(pgdat-&gt;kswapd_wait))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
&gt; =A0 =A0 =A0 =A0if (zone_watermark_ok_safe(zone, order, low_wmark_pages=
(zone), 0, 0))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0trace_mm_vmscan_wakeup_kswapd(pgdat-&gt;node_id, zone_i=
dx(zone), order);<br>
&gt; - =A0 =A0 =A0 wake_up_interruptible(&amp;pgdat-&gt;kswapd_wait);<br>
&gt; + =A0 =A0 =A0 wake_up_interruptible(pgdat-&gt;kswapd_wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -2817,12 +2825,21 @@ static int __devinit cpu_callback(struct notif=
ier_block *nfb,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_node_state(nid, N_HIGH_MEMORY)=
 {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pg_data_t *pgdat =3D NO=
DE_DATA(nid);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct cpumask *m=
ask;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct kswapd *kswapd_p;=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *kswa=
pd_thr;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait_queue_head_t *wait;=
<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mask =3D cpumask_of_nod=
e(pgdat-&gt;node_id);<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D pgdat-&gt;kswap=
d_wait;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D container_o=
f(wait, struct kswapd,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 kswapd_wait);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_thr =3D kswapd_p-=
&gt;kswapd_task;<br>
<br>
</div></div>kswapd_thr? thr means thread?<br>
How about tsk?<br></blockquote><div><br></div><div>ok. I made the change an=
d will be included in the next post.</div><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<br>
&gt; +<br>
If we include kswapd instead of kswapd_wait in pgdat, don&#39;t we make thi=
s simple?<br>
<br>
struct kswapd *kswapd =3D pgdat-&gt;kswapd;<br>
struct task_struct *kswapd_tsk =3D kswapd-&gt;kswapd_task;<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cpumask_any_and(cpu=
_online_mask, mask) &lt; nr_cpu_ids)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* One =
of our CPUs online: restore mask */<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus=
_allowed_ptr(pgdat-&gt;kswapd, mask);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kswa=
pd_thr)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 set_cpus_allowed_ptr(kswapd_thr, mask);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
&gt; =A0 =A0 =A0 =A0}<br>
&gt; =A0 =A0 =A0 =A0return NOTIFY_OK;<br>
&gt; @@ -2835,18 +2852,31 @@ static int __devinit cpu_callback(struct notif=
ier_block *nfb,<br>
&gt; =A0int kswapd_run(int nid)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; + =A0 =A0 =A0 struct task_struct *kswapd_thr;<br>
&gt; + =A0 =A0 =A0 struct kswapd *kswapd_p;<br>
&gt; =A0 =A0 =A0 =A0int ret =3D 0;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 if (pgdat-&gt;kswapd)<br>
&gt; + =A0 =A0 =A0 if (pgdat-&gt;kswapd_wait)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 pgdat-&gt;kswapd =3D kthread_run(kswapd, pgdat, &quot;ks=
wapd%d&quot;, nid);<br>
&gt; - =A0 =A0 =A0 if (IS_ERR(pgdat-&gt;kswapd)) {<br>
&gt; + =A0 =A0 =A0 kswapd_p =3D kzalloc(sizeof(struct kswapd), GFP_KERNEL);=
<br>
&gt; + =A0 =A0 =A0 if (!kswapd_p)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 init_waitqueue_head(&amp;kswapd_p-&gt;kswapd_wait);<br>
&gt; + =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D &amp;kswapd_p-&gt;kswapd_wait;=
<br>
&gt; + =A0 =A0 =A0 kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 kswapd_thr =3D kthread_run(kswapd, kswapd_p, &quot;kswap=
d%d&quot;, nid);<br>
&gt; + =A0 =A0 =A0 if (IS_ERR(kswapd_thr)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* failure at boot is fatal */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(system_state =3D=3D SYSTEM_BOOTI=
NG);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(&quot;Failed to start kswapd on =
node %d\n&quot;,nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D NULL;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(kswapd_p);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -1;<br>
&gt; - =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_task =3D kswapd_thr;=
<br>
&gt; =A0 =A0 =A0 =A0return ret;<br>
&gt; =A0}<br>
&gt;<br>
&gt; @@ -2855,10 +2885,23 @@ int kswapd_run(int nid)<br>
&gt; =A0*/<br>
&gt; =A0void kswapd_stop(int nid)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 =A0 struct task_struct *kswapd =3D NODE_DATA(nid)-&gt;kswapd=
;<br>
&gt; + =A0 =A0 =A0 struct task_struct *kswapd_thr =3D NULL;<br>
&gt; + =A0 =A0 =A0 struct kswapd *kswapd_p =3D NULL;<br>
&gt; + =A0 =A0 =A0 wait_queue_head_t *wait;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 wait =3D pgdat-&gt;kswapd_wait;<br>
&gt; + =A0 =A0 =A0 if (wait) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p =3D container_of(wait, struct k=
swapd, kswapd_wait);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_thr =3D kswapd_p-&gt;kswapd_task;=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_task =3D NULL;<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 if (kswapd_thr)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kthread_stop(kswapd_thr);<br>
&gt;<br>
&gt; - =A0 =A0 =A0 if (kswapd)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kthread_stop(kswapd);<br>
&gt; + =A0 =A0 =A0 kfree(kswapd_p);<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0static int __init kswapd_init(void)<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
&gt;<br>
<br>
</div></div>Hmm, I don&#39;t like kswapd_p, kswapd_thr, wait_h and kswapd_w=
ait of pgdat.<br>
But it&#39;s just my personal opinion. :)<br></blockquote><div><br></div><d=
iv>Thank you for your comments :)=A0</div><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
<br>
--<br>
Kind regards,<br>
<font color=3D"#888888">Minchan Kim<br>
</font></blockquote></div><br>

--000e0cdfd082953c5904a1354b3b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
