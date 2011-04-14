Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 98ED4900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 02:32:57 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p3E6Wrea016334
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 23:32:53 -0700
Received: from gwj15 (gwj15.prod.google.com [10.200.10.15])
	by wpaz13.hot.corp.google.com with ESMTP id p3E6Wp4W023820
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 23:32:52 -0700
Received: by gwj15 with SMTP id 15so720397gwj.39
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 23:32:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=Qdv3RZuhN++OX2-S8OZqrL7=KBg@mail.gmail.com>
References: <1302678187-24154-1-git-send-email-yinghan@google.com>
	<1302678187-24154-5-git-send-email-yinghan@google.com>
	<BANLkTi=Qdv3RZuhN++OX2-S8OZqrL7=KBg@mail.gmail.com>
Date: Wed, 13 Apr 2011 23:32:51 -0700
Message-ID: <BANLkTing9_Y6EcFEcQFmFBZTzB+_FmsubA@mail.gmail.com>
Subject: Re: [PATCH V3 4/7] Infrastructure to support per-memcg reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cd37a7e37a35004a0db184f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--000e0cd37a7e37a35004a0db184f
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 13, 2011 at 8:57 PM, Zhu Yanhai <zhu.yanhai@gmail.com> wrote:

> Hi Ying,
>
> 2011/4/13 Ying Han <yinghan@google.com>:
> > -extern int kswapd_run(int nid);
> > -extern void kswapd_stop(int nid);
> > +extern int kswapd_run(int nid, struct mem_cgroup *mem);
> > +extern void kswapd_stop(int nid, struct mem_cgroup *mem);
>
> This breaks online_pages() and offline_pages(), which are also
> the caller of kswaped_run() and kswaped_stop().
>

Thanks, that will be fixed in the next post.

--Ying

>
> Thanks,
> Zhu Yanhai
>
> >
> >  #ifdef CONFIG_MMU
> >  /* linux/mm/shmem.c */
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 36ae377..acd84a8 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -274,6 +274,8 @@ struct mem_cgroup {
> >        spinlock_t pcp_counter_lock;
> >
> >        int wmark_ratio;
> > +
> > +       wait_queue_head_t *kswapd_wait;
> >  };
> >
> >  /* Stuffs for move charges at task migration. */
> > @@ -4622,6 +4624,33 @@ int mem_cgroup_watermark_ok(struct mem_cgroup
> *mem,
> >        return ret;
> >  }
> >
> > +int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd
> *kswapd_p)
> > +{
> > +       if (!mem || !kswapd_p)
> > +               return 0;
> > +
> > +       mem->kswapd_wait = &kswapd_p->kswapd_wait;
> > +       kswapd_p->kswapd_mem = mem;
> > +
> > +       return css_id(&mem->css);
> > +}
> > +
> > +void mem_cgroup_clear_kswapd(struct mem_cgroup *mem)
> > +{
> > +       if (mem)
> > +               mem->kswapd_wait = NULL;
> > +
> > +       return;
> > +}
> > +
> > +wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
> > +{
> > +       if (!mem)
> > +               return NULL;
> > +
> > +       return mem->kswapd_wait;
> > +}
> > +
> >  static int mem_cgroup_soft_limit_tree_init(void)
> >  {
> >        struct mem_cgroup_tree_per_node *rtpn;
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 77ac74f..a1a1211 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2242,6 +2242,7 @@ static bool pgdat_balanced(pg_data_t *pgdat,
> unsigned long balanced_pages,
> >  }
> >
> >  static DEFINE_SPINLOCK(kswapds_spinlock);
> > +#define is_node_kswapd(kswapd_p) (!(kswapd_p)->kswapd_mem)
> >
> >  /* is kswapd sleeping prematurely? */
> >  static int sleeping_prematurely(struct kswapd *kswapd, int order,
> > @@ -2251,11 +2252,16 @@ static int sleeping_prematurely(struct kswapd
> *kswapd, int order,
> >        unsigned long balanced = 0;
> >        bool all_zones_ok = true;
> >        pg_data_t *pgdat = kswapd->kswapd_pgdat;
> > +       struct mem_cgroup *mem = kswapd->kswapd_mem;
> >
> >        /* If a direct reclaimer woke kswapd within HZ/10, it's premature
> */
> >        if (remaining)
> >                return true;
> >
> > +       /* Doesn't support for per-memcg reclaim */
> > +       if (mem)
> > +               return false;
> > +
> >        /* Check the watermark levels */
> >        for (i = 0; i < pgdat->nr_zones; i++) {
> >                struct zone *zone = pgdat->node_zones + i;
> > @@ -2598,19 +2604,25 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >         * go fully to sleep until explicitly woken up.
> >         */
> >        if (!sleeping_prematurely(kswapd_p, order, remaining,
> classzone_idx)) {
> > -               trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > +               if (is_node_kswapd(kswapd_p)) {
> > +                       trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> >
> > -               /*
> > -                * vmstat counters are not perfectly accurate and the
> estimated
> > -                * value for counters such as NR_FREE_PAGES can deviate
> from the
> > -                * true value by nr_online_cpus * threshold. To avoid the
> zone
> > -                * watermarks being breached while under pressure, we
> reduce the
> > -                * per-cpu vmstat threshold while kswapd is awake and
> restore
> > -                * them before going back to sleep.
> > -                */
> > -               set_pgdat_percpu_threshold(pgdat,
> calculate_normal_threshold);
> > -               schedule();
> > -               set_pgdat_percpu_threshold(pgdat,
> calculate_pressure_threshold);
> > +                       /*
> > +                        * vmstat counters are not perfectly accurate and
> the
> > +                        * estimated value for counters such as
> NR_FREE_PAGES
> > +                        * can deviate from the true value by
> nr_online_cpus *
> > +                        * threshold. To avoid the zone watermarks being
> > +                        * breached while under pressure, we reduce the
> per-cpu
> > +                        * vmstat threshold while kswapd is awake and
> restore
> > +                        * them before going back to sleep.
> > +                        */
> > +                       set_pgdat_percpu_threshold(pgdat,
> > +
>  calculate_normal_threshold);
> > +                       schedule();
> > +                       set_pgdat_percpu_threshold(pgdat,
> > +
> calculate_pressure_threshold);
> > +               } else
> > +                       schedule();
> >        } else {
> >                if (remaining)
> >                        count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
> > @@ -2620,6 +2632,12 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >        finish_wait(wait_h, &wait);
> >  }
> >
> > +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> > +                                                       int order)
> > +{
> > +       return 0;
> > +}
> > +
> >  /*
> >  * The background pageout daemon, started as a kernel thread
> >  * from the init process.
> > @@ -2639,6 +2657,7 @@ int kswapd(void *p)
> >        int classzone_idx;
> >        struct kswapd *kswapd_p = (struct kswapd *)p;
> >        pg_data_t *pgdat = kswapd_p->kswapd_pgdat;
> > +       struct mem_cgroup *mem = kswapd_p->kswapd_mem;
> >        wait_queue_head_t *wait_h = &kswapd_p->kswapd_wait;
> >        struct task_struct *tsk = current;
> >
> > @@ -2649,10 +2668,12 @@ int kswapd(void *p)
> >
> >        lockdep_set_current_reclaim_state(GFP_KERNEL);
> >
> > -       BUG_ON(pgdat->kswapd_wait != wait_h);
> > -       cpumask = cpumask_of_node(pgdat->node_id);
> > -       if (!cpumask_empty(cpumask))
> > -               set_cpus_allowed_ptr(tsk, cpumask);
> > +       if (is_node_kswapd(kswapd_p)) {
> > +               BUG_ON(pgdat->kswapd_wait != wait_h);
> > +               cpumask = cpumask_of_node(pgdat->node_id);
> > +               if (!cpumask_empty(cpumask))
> > +                       set_cpus_allowed_ptr(tsk, cpumask);
> > +       }
> >        current->reclaim_state = &reclaim_state;
> >
> >        /*
> > @@ -2677,24 +2698,29 @@ int kswapd(void *p)
> >                int new_classzone_idx;
> >                int ret;
> >
> > -               new_order = pgdat->kswapd_max_order;
> > -               new_classzone_idx = pgdat->classzone_idx;
> > -               pgdat->kswapd_max_order = 0;
> > -               pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > -               if (order < new_order || classzone_idx >
> new_classzone_idx) {
> > -                       /*
> > -                        * Don't sleep if someone wants a larger 'order'
> > -                        * allocation or has tigher zone constraints
> > -                        */
> > -                       order = new_order;
> > -                       classzone_idx = new_classzone_idx;
> > -               } else {
> > -                       kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> > -                       order = pgdat->kswapd_max_order;
> > -                       classzone_idx = pgdat->classzone_idx;
> > +               if (is_node_kswapd(kswapd_p)) {
> > +                       new_order = pgdat->kswapd_max_order;
> > +                       new_classzone_idx = pgdat->classzone_idx;
> >                        pgdat->kswapd_max_order = 0;
> >                        pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > -               }
> > +                       if (order < new_order ||
> > +                                       classzone_idx >
> new_classzone_idx) {
> > +                               /*
> > +                                * Don't sleep if someone wants a larger
> 'order'
> > +                                * allocation or has tigher zone
> constraints
> > +                                */
> > +                               order = new_order;
> > +                               classzone_idx = new_classzone_idx;
> > +                       } else {
> > +                               kswapd_try_to_sleep(kswapd_p, order,
> > +                                                   classzone_idx);
> > +                               order = pgdat->kswapd_max_order;
> > +                               classzone_idx = pgdat->classzone_idx;
> > +                               pgdat->kswapd_max_order = 0;
> > +                               pgdat->classzone_idx = MAX_NR_ZONES - 1;
> > +                       }
> > +               } else
> > +                       kswapd_try_to_sleep(kswapd_p, order,
> classzone_idx);
> >
> >                ret = try_to_freeze();
> >                if (kthread_should_stop())
> > @@ -2705,8 +2731,13 @@ int kswapd(void *p)
> >                 * after returning from the refrigerator
> >                 */
> >                if (!ret) {
> > -                       trace_mm_vmscan_kswapd_wake(pgdat->node_id,
> order);
> > -                       order = balance_pgdat(pgdat, order,
> &classzone_idx);
> > +                       if (is_node_kswapd(kswapd_p)) {
> > +
> trace_mm_vmscan_kswapd_wake(pgdat->node_id,
> > +                                                               order);
> > +                               order = balance_pgdat(pgdat, order,
> > +                                                       &classzone_idx);
> > +                       } else
> > +                               balance_mem_cgroup_pgdat(mem, order);
> >                }
> >        }
> >        return 0;
> > @@ -2853,30 +2884,53 @@ static int __devinit cpu_callback(struct
> notifier_block *nfb,
> >  * This kswapd start function will be called by init and node-hot-add.
> >  * On node-hot-add, kswapd will moved to proper cpus if cpus are
> hot-added.
> >  */
> > -int kswapd_run(int nid)
> > +int kswapd_run(int nid, struct mem_cgroup *mem)
> >  {
> > -       pg_data_t *pgdat = NODE_DATA(nid);
> >        struct task_struct *kswapd_thr;
> > +       pg_data_t *pgdat = NULL;
> >        struct kswapd *kswapd_p;
> > +       static char name[TASK_COMM_LEN];
> > +       int memcg_id;
> >        int ret = 0;
> >
> > -       if (pgdat->kswapd_wait)
> > -               return 0;
> > +       if (!mem) {
> > +               pgdat = NODE_DATA(nid);
> > +               if (pgdat->kswapd_wait)
> > +                       return ret;
> > +       }
> >
> >        kswapd_p = kzalloc(sizeof(struct kswapd), GFP_KERNEL);
> >        if (!kswapd_p)
> >                return -ENOMEM;
> >
> >        init_waitqueue_head(&kswapd_p->kswapd_wait);
> > -       pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
> > -       kswapd_p->kswapd_pgdat = pgdat;
> >
> > -       kswapd_thr = kthread_run(kswapd, kswapd_p, "kswapd%d", nid);
> > +       if (!mem) {
> > +               pgdat->kswapd_wait = &kswapd_p->kswapd_wait;
> > +               kswapd_p->kswapd_pgdat = pgdat;
> > +               snprintf(name, TASK_COMM_LEN, "kswapd_%d", nid);
> > +       } else {
> > +               memcg_id = mem_cgroup_init_kswapd(mem, kswapd_p);
> > +               if (!memcg_id) {
> > +                       kfree(kswapd_p);
> > +                       return ret;
> > +               }
> > +               snprintf(name, TASK_COMM_LEN, "memcg_%d", memcg_id);
> > +       }
> > +
> > +       kswapd_thr = kthread_run(kswapd, kswapd_p, name);
> >        if (IS_ERR(kswapd_thr)) {
> >                /* failure at boot is fatal */
> >                BUG_ON(system_state == SYSTEM_BOOTING);
> > -               printk("Failed to start kswapd on node %d\n",nid);
> > -               pgdat->kswapd_wait = NULL;
> > +               if (!mem) {
> > +                       printk(KERN_ERR "Failed to start kswapd on node
> %d\n",
> > +                                                               nid);
> > +                       pgdat->kswapd_wait = NULL;
> > +               } else {
> > +                       printk(KERN_ERR "Failed to start kswapd on memcg
> %d\n",
> > +
> memcg_id);
> > +                       mem_cgroup_clear_kswapd(mem);
> > +               }
> >                kfree(kswapd_p);
> >                ret = -1;
> >        } else
> > @@ -2887,16 +2941,18 @@ int kswapd_run(int nid)
> >  /*
> >  * Called by memory hotplug when all memory in a node is offlined.
> >  */
> > -void kswapd_stop(int nid)
> > +void kswapd_stop(int nid, struct mem_cgroup *mem)
> >  {
> >        struct task_struct *kswapd_thr = NULL;
> >        struct kswapd *kswapd_p = NULL;
> >        wait_queue_head_t *wait;
> >
> > -       pg_data_t *pgdat = NODE_DATA(nid);
> > -
> >        spin_lock(&kswapds_spinlock);
> > -       wait = pgdat->kswapd_wait;
> > +       if (!mem)
> > +               wait = NODE_DATA(nid)->kswapd_wait;
> > +       else
> > +               wait = mem_cgroup_kswapd_wait(mem);
> > +
> >        if (wait) {
> >                kswapd_p = container_of(wait, struct kswapd, kswapd_wait);
> >                kswapd_thr = kswapd_p->kswapd_task;
> > @@ -2916,7 +2972,7 @@ static int __init kswapd_init(void)
> >
> >        swap_setup();
> >        for_each_node_state(nid, N_HIGH_MEMORY)
> > -               kswapd_run(nid);
> > +               kswapd_run(nid, NULL);
> >        hotcpu_notifier(cpu_callback, 0);
> >        return 0;
> >  }
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

--000e0cd37a7e37a35004a0db184f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 13, 2011 at 8:57 PM, Zhu Yan=
hai <span dir=3D"ltr">&lt;<a href=3D"mailto:zhu.yanhai@gmail.com">zhu.yanha=
i@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hi Ying,<br>
<br>
2011/4/13 Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt;:<br>
<div class=3D"im">&gt; -extern int kswapd_run(int nid);<br>
&gt; -extern void kswapd_stop(int nid);<br>
&gt; +extern int kswapd_run(int nid, struct mem_cgroup *mem);<br>
&gt; +extern void kswapd_stop(int nid, struct mem_cgroup *mem);<br>
<br>
</div>This breaks online_pages() and offline_pages(), which are also<br>
the caller of kswaped_run() and kswaped_stop().<br></blockquote><div><br></=
div><div>Thanks, that will be fixed in the next post.</div><div><br></div><=
div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 =
.8ex;border-left:1px #ccc solid;padding-left:1ex;">

<br>
Thanks,<br>
Zhu Yanhai<br>
<div><div></div><div class=3D"h5"><br>
&gt;<br>
&gt; =A0#ifdef CONFIG_MMU<br>
&gt; =A0/* linux/mm/shmem.c */<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 36ae377..acd84a8 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -274,6 +274,8 @@ struct mem_cgroup {<br>
&gt; =A0 =A0 =A0 =A0spinlock_t pcp_counter_lock;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0int wmark_ratio;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 wait_queue_head_t *kswapd_wait;<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0/* Stuffs for move charges at task migration. */<br>
&gt; @@ -4622,6 +4624,33 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *=
mem,<br>
&gt; =A0 =A0 =A0 =A0return ret;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd *ksw=
apd_p)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 if (!mem || !kswapd_p)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 mem-&gt;kswapd_wait =3D &amp;kswapd_p-&gt;kswapd_wait;<b=
r>
&gt; + =A0 =A0 =A0 kswapd_p-&gt;kswapd_mem =3D mem;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return css_id(&amp;mem-&gt;css);<br>
&gt; +}<br>
&gt; +<br>
&gt; +void mem_cgroup_clear_kswapd(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 if (mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem-&gt;kswapd_wait =3D NULL;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return;<br>
&gt; +}<br>
&gt; +<br>
&gt; +wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return mem-&gt;kswapd_wait;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static int mem_cgroup_soft_limit_tree_init(void)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0struct mem_cgroup_tree_per_node *rtpn;<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 77ac74f..a1a1211 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -2242,6 +2242,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, uns=
igned long balanced_pages,<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0static DEFINE_SPINLOCK(kswapds_spinlock);<br>
&gt; +#define is_node_kswapd(kswapd_p) (!(kswapd_p)-&gt;kswapd_mem)<br>
&gt;<br>
&gt; =A0/* is kswapd sleeping prematurely? */<br>
&gt; =A0static int sleeping_prematurely(struct kswapd *kswapd, int order,<b=
r>
&gt; @@ -2251,11 +2252,16 @@ static int sleeping_prematurely(struct kswapd =
*kswapd, int order,<br>
&gt; =A0 =A0 =A0 =A0unsigned long balanced =3D 0;<br>
&gt; =A0 =A0 =A0 =A0bool all_zones_ok =3D true;<br>
&gt; =A0 =A0 =A0 =A0pg_data_t *pgdat =3D kswapd-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 =A0 struct mem_cgroup *mem =3D kswapd-&gt;kswapd_mem;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0/* If a direct reclaimer woke kswapd within HZ/10, it&#=
39;s premature */<br>
&gt; =A0 =A0 =A0 =A0if (remaining)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 /* Doesn&#39;t support for per-memcg reclaim */<br>
&gt; + =A0 =A0 =A0 if (mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0/* Check the watermark levels */<br>
&gt; =A0 =A0 =A0 =A0for (i =3D 0; i &lt; pgdat-&gt;nr_zones; i++) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone =3D pgdat-&gt;node_zo=
nes + i;<br>
&gt; @@ -2598,19 +2604,25 @@ static void kswapd_try_to_sleep(struct kswapd =
*kswapd_p, int order,<br>
&gt; =A0 =A0 =A0 =A0 * go fully to sleep until explicitly woken up.<br>
&gt; =A0 =A0 =A0 =A0 */<br>
&gt; =A0 =A0 =A0 =A0if (!sleeping_prematurely(kswapd_p, order, remaining, c=
lasszone_idx)) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_sleep(pgdat-&gt;n=
ode_id);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_node_kswapd(kswapd_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_s=
leep(pgdat-&gt;node_id);<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat counters are not perfectly a=
ccurate and the estimated<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* value for counters such as NR_FREE_=
PAGES can deviate from the<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* true value by nr_online_cpus * thre=
shold. To avoid the zone<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* watermarks being breached while und=
er pressure, we reduce the<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* per-cpu vmstat threshold while kswa=
pd is awake and restore<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* them before going back to sleep.<br=
>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pgdat, calcul=
ate_normal_threshold);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_threshold(pgdat, calcul=
ate_pressure_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat counters are=
 not perfectly accurate and the<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* estimated value for=
 counters such as NR_FREE_PAGES<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* can deviate from th=
e true value by nr_online_cpus *<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* threshold. To avoid=
 the zone watermarks being<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* breached while unde=
r pressure, we reduce the per-cpu<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vmstat threshold wh=
ile kswapd is awake and restore<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* them before going b=
ack to sleep.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_thresho=
ld(pgdat,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0calculate_normal_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pgdat_percpu_thresho=
ld(pgdat,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 calculate_pressure_threshold);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();<br>
&gt; =A0 =A0 =A0 =A0} else {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (remaining)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count_vm_event(KSWAPD_L=
OW_WMARK_HIT_QUICKLY);<br>
&gt; @@ -2620,6 +2632,12 @@ static void kswapd_try_to_sleep(struct kswapd *=
kswapd_p, int order,<br>
&gt; =A0 =A0 =A0 =A0finish_wait(wait_h, &amp;wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_=
cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int order)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0/*<br>
&gt; =A0* The background pageout daemon, started as a kernel thread<br>
&gt; =A0* from the init process.<br>
&gt; @@ -2639,6 +2657,7 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0int classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0struct kswapd *kswapd_p =3D (struct kswapd *)p;<br>
&gt; =A0 =A0 =A0 =A0pg_data_t *pgdat =3D kswapd_p-&gt;kswapd_pgdat;<br>
&gt; + =A0 =A0 =A0 struct mem_cgroup *mem =3D kswapd_p-&gt;kswapd_mem;<br>
&gt; =A0 =A0 =A0 =A0wait_queue_head_t *wait_h =3D &amp;kswapd_p-&gt;kswapd_=
wait;<br>
&gt; =A0 =A0 =A0 =A0struct task_struct *tsk =3D current;<br>
&gt;<br>
&gt; @@ -2649,10 +2668,12 @@ int kswapd(void *p)<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0lockdep_set_current_reclaim_state(GFP_KERNEL);<br>
&gt;<br>
&gt; - =A0 =A0 =A0 BUG_ON(pgdat-&gt;kswapd_wait !=3D wait_h);<br>
&gt; - =A0 =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;node_id);<br>
&gt; - =A0 =A0 =A0 if (!cpumask_empty(cpumask))<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk, cpumask);<br>
&gt; + =A0 =A0 =A0 if (is_node_kswapd(kswapd_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(pgdat-&gt;kswapd_wait !=3D wait_h=
);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask =3D cpumask_of_node(pgdat-&gt;no=
de_id);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cpumask_empty(cpumask))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk=
, cpumask);<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 =A0current-&gt;reclaim_state =3D &amp;reclaim_state;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0/*<br>
&gt; @@ -2677,24 +2698,29 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int new_classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int ret;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D pgdat-&gt;kswapd_max_order=
;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_classzone_idx =3D pgdat-&gt;classzon=
e_idx;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_max_order =3D 0;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;classzone_idx =3D MAX_NR_ZONES=
 - 1;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (order &lt; new_order || classzone_id=
x &gt; new_classzone_idx) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don&#39;t sleep if =
someone wants a larger &#39;order&#39;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* allocation or has t=
igher zone constraints<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D new_order;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D new_cl=
asszone_idx;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswa=
pd_p, order, classzone_idx);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat-&gt;kswa=
pd_max_order;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx =3D pgdat-=
&gt;classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_node_kswapd(kswapd_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D pgdat-&gt;=
kswapd_max_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_classzone_idx =3D pg=
dat-&gt;classzone_idx;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;kswapd_max_or=
der =3D 0;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgdat-&gt;classzone_idx=
 =3D MAX_NR_ZONES - 1;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (order &lt; new_order=
 ||<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 classzone_idx &gt; new_classzone_idx) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don=
&#39;t sleep if someone wants a larger &#39;order&#39;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* all=
ocation or has tigher zone constraints<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =
=3D new_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzon=
e_idx =3D new_classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_t=
ry_to_sleep(kswapd_p, order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =
=3D pgdat-&gt;kswapd_max_order;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 classzon=
e_idx =3D pgdat-&gt;classzone_idx;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&g=
t;kswapd_max_order =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&g=
t;classzone_idx =3D MAX_NR_ZONES - 1;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_try_to_sleep(kswa=
pd_p, order, classzone_idx);<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_freeze();<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (kthread_should_stop())<br>
&gt; @@ -2705,8 +2731,13 @@ int kswapd(void *p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * after returning from the refrigerato=
r<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ret) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_w=
ake(pgdat-&gt;node_id, order);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D balance_pgdat(=
pgdat, order, &amp;classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_node_kswapd(kswap=
d_p)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm=
_vmscan_kswapd_wake(pgdat-&gt;node_id,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =
=3D balance_pgdat(pgdat, order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;classzone_idx);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_=
mem_cgroup_pgdat(mem, order);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
&gt; =A0 =A0 =A0 =A0}<br>
&gt; =A0 =A0 =A0 =A0return 0;<br>
&gt; @@ -2853,30 +2884,53 @@ static int __devinit cpu_callback(struct notif=
ier_block *nfb,<br>
&gt; =A0* This kswapd start function will be called by init and node-hot-ad=
d.<br>
&gt; =A0* On node-hot-add, kswapd will moved to proper cpus if cpus are hot=
-added.<br>
&gt; =A0*/<br>
&gt; -int kswapd_run(int nid)<br>
&gt; +int kswapd_run(int nid, struct mem_cgroup *mem)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; =A0 =A0 =A0 =A0struct task_struct *kswapd_thr;<br>
&gt; + =A0 =A0 =A0 pg_data_t *pgdat =3D NULL;<br>
&gt; =A0 =A0 =A0 =A0struct kswapd *kswapd_p;<br>
&gt; + =A0 =A0 =A0 static char name[TASK_COMM_LEN];<br>
&gt; + =A0 =A0 =A0 int memcg_id;<br>
&gt; =A0 =A0 =A0 =A0int ret =3D 0;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 if (pgdat-&gt;kswapd_wait)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; + =A0 =A0 =A0 if (!mem) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pgdat-&gt;kswapd_wait)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
&gt; + =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0kswapd_p =3D kzalloc(sizeof(struct kswapd), GFP_KERNEL)=
;<br>
&gt; =A0 =A0 =A0 =A0if (!kswapd_p)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0init_waitqueue_head(&amp;kswapd_p-&gt;kswapd_wait);<br>
&gt; - =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D &amp;kswapd_p-&gt;kswapd_wait;=
<br>
&gt; - =A0 =A0 =A0 kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 kswapd_thr =3D kthread_run(kswapd, kswapd_p, &quot;kswap=
d%d&quot;, nid);<br>
&gt; + =A0 =A0 =A0 if (!mem) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D &amp;kswapd_p-=
&gt;kswapd_wait;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p-&gt;kswapd_pgdat =3D pgdat;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, TASK_COMM_LEN, &quot;kswa=
pd_%d&quot;, nid);<br>
&gt; + =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_id =3D mem_cgroup_init_kswapd(mem,=
 kswapd_p);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcg_id) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(kswapd_p);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, TASK_COMM_LEN, &quot;memc=
g_%d&quot;, memcg_id);<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 kswapd_thr =3D kthread_run(kswapd, kswapd_p, name);<br>
&gt; =A0 =A0 =A0 =A0if (IS_ERR(kswapd_thr)) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* failure at boot is fatal */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(system_state =3D=3D SYSTEM_BOOTI=
NG);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(&quot;Failed to start kswapd on n=
ode %d\n&quot;,nid);<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =3D NULL;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR &quot;Fa=
iled to start kswapd on node %d\n&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat-&gt;kswapd_wait =
=3D NULL;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR &quot;Fa=
iled to start kswapd on memcg %d\n&quot;,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_id);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_clear_kswapd(=
mem);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(kswapd_p);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -1;<br>
&gt; =A0 =A0 =A0 =A0} else<br>
&gt; @@ -2887,16 +2941,18 @@ int kswapd_run(int nid)<br>
&gt; =A0/*<br>
&gt; =A0* Called by memory hotplug when all memory in a node is offlined.<b=
r>
&gt; =A0*/<br>
&gt; -void kswapd_stop(int nid)<br>
&gt; +void kswapd_stop(int nid, struct mem_cgroup *mem)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0struct task_struct *kswapd_thr =3D NULL;<br>
&gt; =A0 =A0 =A0 =A0struct kswapd *kswapd_p =3D NULL;<br>
&gt; =A0 =A0 =A0 =A0wait_queue_head_t *wait;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);<br>
&gt; -<br>
&gt; =A0 =A0 =A0 =A0spin_lock(&amp;kswapds_spinlock);<br>
&gt; - =A0 =A0 =A0 wait =3D pgdat-&gt;kswapd_wait;<br>
&gt; + =A0 =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D NODE_DATA(nid)-&gt;kswapd_wait;=
<br>
&gt; + =A0 =A0 =A0 else<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait =3D mem_cgroup_kswapd_wait(mem);<br=
>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0if (wait) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_p =3D container_of(wait, struct =
kswapd, kswapd_wait);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kswapd_thr =3D kswapd_p-&gt;kswapd_task=
;<br>
&gt; @@ -2916,7 +2972,7 @@ static int __init kswapd_init(void)<br>
&gt;<br>
&gt; =A0 =A0 =A0 =A0swap_setup();<br>
&gt; =A0 =A0 =A0 =A0for_each_node_state(nid, N_HIGH_MEMORY)<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(nid);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(nid, NULL);<br>
&gt; =A0 =A0 =A0 =A0hotcpu_notifier(cpu_callback, 0);<br>
&gt; =A0 =A0 =A0 =A0return 0;<br>
&gt; =A0}<br>
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
</blockquote></div><br>

--000e0cd37a7e37a35004a0db184f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
