Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4168D6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 21:14:06 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4R1DxvE002732
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:13:59 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by wpaz24.hot.corp.google.com with ESMTP id p4R1DYuK031860
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 18:13:58 -0700
Received: by qwb8 with SMTP id 8so969607qwb.11
        for <linux-mm@kvack.org>; Thu, 26 May 2011 18:13:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110526143631.adc2c911.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526143631.adc2c911.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 May 2011 18:13:55 -0700
Message-ID: <BANLkTimL6cx2yfQ4azKMYq8WiTOttqyhzQ@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 10/10] memcg : reclaim statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5cd1684604a437a6f6
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

--0016360e3f5cd1684604a437a6f6
Content-Type: text/plain; charset=ISO-8859-1

Hi Kame:

I applied the patch on top of mmotm-2011-05-12-15-52. After boot up, i keep
getting the following crash by reading the
/dev/cgroup/memory/memory.reclaim_stat

[  200.776366] Kernel panic - not syncing: Fatal exception
[  200.781591] Pid: 7535, comm: cat Tainted: G      D W   2.6.39-mcg-DEV
#130
[  200.788463] Call Trace:
[  200.790916]  [<ffffffff81405a75>] panic+0x91/0x194
[  200.797096]  [<ffffffff81408ac8>] oops_end+0xae/0xbe
[  200.803450]  [<ffffffff810398d3>] die+0x5a/0x63
[  200.809366]  [<ffffffff81408561>] do_trap+0x121/0x130
[  200.814427]  [<ffffffff81037fe6>] do_divide_error+0x90/0x99
[#1] SMP
[  200.821395]  [<ffffffff81112bcb>] ?
mem_cgroup_reclaim_stat_read+0x28/0xf0
[  200.829624]  [<ffffffff81104509>] ? page_add_new_anon_rmap+0x7e/0x90
[  200.837372]  [<ffffffff810fb7f8>] ? handle_pte_fault+0x28a/0x775
[  200.844773]  [<ffffffff8140f0f5>] divide_error+0x15/0x20
[  200.851471]  [<ffffffff81112bcb>] ?
mem_cgroup_reclaim_stat_read+0x28/0xf0
[  200.859729]  [<ffffffff810a4a01>] cgroup_seqfile_show+0x38/0x46
[  200.867036]  [<ffffffff810a4d72>] ? cgroup_lock+0x17/0x17
[  200.872444]  [<ffffffff81133f2c>] seq_read+0x182/0x361
[  200.878984]  [<ffffffff8111a0c4>] vfs_read+0xab/0x107
[  200.885403]  [<ffffffff8111a1e0>] sys_read+0x4a/0x6e
[  200.891764]  [<ffffffff8140f469>] sysenter_dispatch+0x7/0x27

I will debug it, but like to post here in case i missed some patches in
between.

--Ying

On Wed, May 25, 2011 at 10:36 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

>
> This patch adds a file memory.reclaim_stat.
>
> This file shows following.
> ==
> recent_scan_success_ratio  12 # recent reclaim/scan ratio.
> limit_scan_pages 671          # scan caused by hitting limit.
> limit_freed_pages 538         # freed pages by limit_scan
> limit_elapsed_ns 518555076    # elapsed time in LRU scanning by limit.
> soft_scan_pages 0             # scan caused by softlimit.
> soft_freed_pages 0            # freed pages by soft_scan.
> soft_elapsed_ns 0             # elapsed time in LRU scanning by softlimit.
> margin_scan_pages 16744221    # scan caused by auto-keep-margin
> margin_freed_pages 565943     # freed pages by auto-keep-margin.
> margin_elapsed_ns 5545388791  # elapsed time in LRU scanning by
> auto-keep-margin
>
> This patch adds a new file rather than adding more stats to memory.stat. By
> it,
> this support "reset" accounting by
>
>  # echo 0 > .../memory.reclaim_stat
>
> This is good for debug and tuning.
>
> TODO:
>  - add Documentaion.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   87
> ++++++++++++++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 79 insertions(+), 8 deletions(-)
>
> Index: memcg_async/mm/memcontrol.c
> ===================================================================
> --- memcg_async.orig/mm/memcontrol.c
> +++ memcg_async/mm/memcontrol.c
> @@ -216,6 +216,13 @@ static void mem_cgroup_update_margin_to_
>  static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
>  static void mem_cgroup_reflesh_scan_ratio(struct mem_cgroup *mem);
>
> +enum scan_type {
> +       LIMIT_SCAN,     /* scan memory because memcg hits limit */
> +       SOFT_SCAN,      /* scan memory because of soft limit */
> +       MARGIN_SCAN,    /* scan memory for making margin to limit */
> +       NR_SCAN_TYPES,
> +};
> +
>  /*
>  * The memory controller data structure. The memory controller controls
> both
>  * page cache and RSS per cgroup. We would eventually like to provide
> @@ -300,6 +307,13 @@ struct mem_cgroup {
>        unsigned long   scanned;
>        unsigned long   reclaimed;
>        unsigned long   next_scanratio_update;
> +       /* For statistics */
> +       struct {
> +               unsigned long nr_scanned_pages;
> +               unsigned long nr_reclaimed_pages;
> +               unsigned long elapsed_ns;
> +       } scan_stat[NR_SCAN_TYPES];
> +
>        /*
>         * percpu counter.
>         */
> @@ -1426,7 +1440,9 @@ unsigned int mem_cgroup_swappiness(struc
>
>  static void __mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
>                                unsigned long scanned,
> -                               unsigned long reclaimed)
> +                               unsigned long reclaimed,
> +                               unsigned long elapsed,
> +                               enum scan_type type)
>  {
>        unsigned long limit;
>
> @@ -1439,6 +1455,9 @@ static void __mem_cgroup_update_scan_rat
>                mem->scanned /= 2;
>                mem->reclaimed /= 2;
>        }
> +       mem->scan_stat[type].nr_scanned_pages += scanned;
> +       mem->scan_stat[type].nr_reclaimed_pages += reclaimed;
> +       mem->scan_stat[type].elapsed_ns += elapsed;
>        spin_unlock(&mem->scan_stat_lock);
>  }
>
> @@ -1448,6 +1467,8 @@ static void __mem_cgroup_update_scan_rat
>  * @root : root memcg of hierarchy walk.
>  * @scanned : scanned pages
>  * @reclaimed: reclaimed pages.
> + * @elapsed: used time for memory reclaim
> + * @type : scan type as LIMIT_SCAN, SOFT_SCAN, MARGIN_SCAN.
>  *
>  * record scan/reclaim ratio to the memcg both to a child and it's root
>  * mem cgroup, which is a reclaim target. This value is used for
> @@ -1457,11 +1478,14 @@ static void __mem_cgroup_update_scan_rat
>  static void mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,
>                                  struct mem_cgroup *root,
>                                unsigned long scanned,
> -                               unsigned long reclaimed)
> +                               unsigned long reclaimed,
> +                               unsigned long elapsed,
> +                               int type)
>  {
> -       __mem_cgroup_update_scan_ratio(mem, scanned, reclaimed);
> +       __mem_cgroup_update_scan_ratio(mem, scanned, reclaimed, elapsed,
> type);
>        if (mem != root)
> -               __mem_cgroup_update_scan_ratio(root, scanned, reclaimed);
> +               __mem_cgroup_update_scan_ratio(root, scanned, reclaimed,
> +                                       elapsed, type);
>
>  }
>
> @@ -1906,6 +1930,7 @@ static int mem_cgroup_hierarchical_recla
>        bool is_kswapd = false;
>        unsigned long excess;
>        unsigned long nr_scanned;
> +       unsigned long start, end, elapsed;
>
>        excess = res_counter_soft_limit_excess(&root_mem->res) >>
> PAGE_SHIFT;
>
> @@ -1947,18 +1972,24 @@ static int mem_cgroup_hierarchical_recla
>                }
>                /* we use swappiness of local cgroup */
>                if (check_soft) {
> +                       start = sched_clock();
>                        ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
>                                noswap, zone, &nr_scanned);
> +                       end = sched_clock();
> +                       elapsed = end - start;
>                        *total_scanned += nr_scanned;
>                        mem_cgroup_soft_steal(victim, is_kswapd, ret);
>                        mem_cgroup_soft_scan(victim, is_kswapd, nr_scanned);
>                        mem_cgroup_update_scan_ratio(victim,
> -                                       root_mem, nr_scanned, ret);
> +                               root_mem, nr_scanned, ret, elapsed,
> SOFT_SCAN);
>                } else {
> +                       start = sched_clock();
>                        ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
>                                        noswap, &nr_scanned);
> +                       end = sched_clock();
> +                       elapsed = end - start;
>                        mem_cgroup_update_scan_ratio(victim,
> -                                       root_mem, nr_scanned, ret);
> +                               root_mem, nr_scanned, ret, elapsed,
> LIMIT_SCAN);
>                }
>                css_put(&victim->css);
>                /*
> @@ -4003,7 +4034,7 @@ static void mem_cgroup_async_shrink_work
>        struct delayed_work *dw = to_delayed_work(work);
>        struct mem_cgroup *mem, *victim;
>        long nr_to_reclaim;
> -       unsigned long nr_scanned, nr_reclaimed;
> +       unsigned long nr_scanned, nr_reclaimed, start, end;
>        int delay = 0;
>
>        mem = container_of(dw, struct mem_cgroup, async_work);
> @@ -4022,9 +4053,12 @@ static void mem_cgroup_async_shrink_work
>        if (!victim)
>                goto finish_scan;
>
> +       start = sched_clock();
>        nr_reclaimed = mem_cgroup_shrink_rate_limited(victim, nr_to_reclaim,
>                                        &nr_scanned);
> -       mem_cgroup_update_scan_ratio(victim, mem, nr_scanned,
> nr_reclaimed);
> +       end = sched_clock();
> +       mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr_reclaimed,
> +                       end - start, MARGIN_SCAN);
>        css_put(&victim->css);
>
>        /* If margin is enough big, stop */
> @@ -4680,6 +4714,38 @@ static int mem_control_stat_show(struct
>        return 0;
>  }
>
> +static int mem_cgroup_reclaim_stat_read(struct cgroup *cont, struct cftype
> *cft,
> +                                struct cgroup_map_cb *cb)
> +{
> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +       u64 val;
> +       int i; /* for indexing scan_stat[] */
> +
> +       val = mem->reclaimed * 100 / mem->scanned;
> +       cb->fill(cb, "recent_scan_success_ratio", val);
> +       i  = LIMIT_SCAN;
> +       cb->fill(cb, "limit_scan_pages",
> mem->scan_stat[i].nr_scanned_pages);
> +       cb->fill(cb, "limit_freed_pages",
> mem->scan_stat[i].nr_reclaimed_pages);
> +       cb->fill(cb, "limit_elapsed_ns", mem->scan_stat[i].elapsed_ns);
> +       i = SOFT_SCAN;
> +       cb->fill(cb, "soft_scan_pages",
> mem->scan_stat[i].nr_scanned_pages);
> +       cb->fill(cb, "soft_freed_pages",
> mem->scan_stat[i].nr_reclaimed_pages);
> +       cb->fill(cb, "soft_elapsed_ns", mem->scan_stat[i].elapsed_ns);
> +       i = MARGIN_SCAN;
> +       cb->fill(cb, "margin_scan_pages",
> mem->scan_stat[i].nr_scanned_pages);
> +       cb->fill(cb, "margin_freed_pages",
> mem->scan_stat[i].nr_reclaimed_pages);
> +       cb->fill(cb, "margin_elapsed_ns", mem->scan_stat[i].elapsed_ns);
> +       return 0;
> +}
> +
> +static int mem_cgroup_reclaim_stat_reset(struct cgroup *cgrp, unsigned int
> event)
> +{
> +       struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +       memset(mem->scan_stat, 0, sizeof(mem->scan_stat));
> +       return 0;
> +}
> +
> +
>  /*
>  * User flags for async_control is a subset of mem->async_flags. But
>  * this needs to be defined independently to hide implemation details.
> @@ -5163,6 +5229,11 @@ static struct cftype mem_cgroup_files[]
>                .open = mem_control_numa_stat_open,
>        },
>  #endif
> +       {
> +               .name = "reclaim_stat",
> +               .read_map = mem_cgroup_reclaim_stat_read,
> +               .trigger = mem_cgroup_reclaim_stat_reset,
> +       }
>  };
>
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>
>

--0016360e3f5cd1684604a437a6f6
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Kame:<div><br></div><div>I applied the patch on top of=A0mmotm-2011-05-1=
2-15-52. After boot up, i keep getting the following crash by reading the /=
dev/cgroup/memory/memory.reclaim_stat</div><div><br></div><div><div>[ =A020=
0.776366] Kernel panic - not syncing: Fatal exception</div>
<div>[ =A0200.781591] Pid: 7535, comm: cat Tainted: G =A0 =A0 =A0D W =A0 2.=
6.39-mcg-DEV #130</div><div>[ =A0200.788463] Call Trace:</div><div>[ =A0200=
.790916] =A0[&lt;ffffffff81405a75&gt;] panic+0x91/0x194</div><div>[ =A0200.=
797096] =A0[&lt;ffffffff81408ac8&gt;] oops_end+0xae/0xbe</div>
<div>[ =A0200.803450] =A0[&lt;ffffffff810398d3&gt;] die+0x5a/0x63</div><div=
>[ =A0200.809366] =A0[&lt;ffffffff81408561&gt;] do_trap+0x121/0x130</div><d=
iv>[ =A0200.814427] =A0[&lt;ffffffff81037fe6&gt;] do_divide_error+0x90/0x99=
</div><div>
[#1] SMP=A0</div><div>[ =A0200.821395] =A0[&lt;ffffffff81112bcb&gt;] ? mem_=
cgroup_reclaim_stat_read+0x28/0xf0</div><div>[ =A0200.829624] =A0[&lt;fffff=
fff81104509&gt;] ? page_add_new_anon_rmap+0x7e/0x90</div><div>[ =A0200.8373=
72] =A0[&lt;ffffffff810fb7f8&gt;] ? handle_pte_fault+0x28a/0x775</div>
<div>[ =A0200.844773] =A0[&lt;ffffffff8140f0f5&gt;] divide_error+0x15/0x20<=
/div><div>[ =A0200.851471] =A0[&lt;ffffffff81112bcb&gt;] ? mem_cgroup_recla=
im_stat_read+0x28/0xf0</div><div>[ =A0200.859729] =A0[&lt;ffffffff810a4a01&=
gt;] cgroup_seqfile_show+0x38/0x46</div>
<div>[ =A0200.867036] =A0[&lt;ffffffff810a4d72&gt;] ? cgroup_lock+0x17/0x17=
</div><div>[ =A0200.872444] =A0[&lt;ffffffff81133f2c&gt;] seq_read+0x182/0x=
361</div><div>[ =A0200.878984] =A0[&lt;ffffffff8111a0c4&gt;] vfs_read+0xab/=
0x107</div>
<div>[ =A0200.885403] =A0[&lt;ffffffff8111a1e0&gt;] sys_read+0x4a/0x6e</div=
><div>[ =A0200.891764] =A0[&lt;ffffffff8140f469&gt;] sysenter_dispatch+0x7/=
0x27</div></div><div><br></div><div>I will debug it, but like to post here =
in case i missed some patches in between.</div>
<div><br></div><div>--Ying<br><br><div class=3D"gmail_quote">On Wed, May 25=
, 2011 at 10:36 PM, KAMEZAWA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mail=
to:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</=
span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><br>
This patch adds a file memory.reclaim_stat.<br>
<br>
This file shows following.<br>
=3D=3D<br>
recent_scan_success_ratio =A012 # recent reclaim/scan ratio.<br>
limit_scan_pages 671 =A0 =A0 =A0 =A0 =A0# scan caused by hitting limit.<br>
limit_freed_pages 538 =A0 =A0 =A0 =A0 # freed pages by limit_scan<br>
limit_elapsed_ns 518555076 =A0 =A0# elapsed time in LRU scanning by limit.<=
br>
soft_scan_pages 0 =A0 =A0 =A0 =A0 =A0 =A0 # scan caused by softlimit.<br>
soft_freed_pages 0 =A0 =A0 =A0 =A0 =A0 =A0# freed pages by soft_scan.<br>
soft_elapsed_ns 0 =A0 =A0 =A0 =A0 =A0 =A0 # elapsed time in LRU scanning by=
 softlimit.<br>
margin_scan_pages 16744221 =A0 =A0# scan caused by auto-keep-margin<br>
margin_freed_pages 565943 =A0 =A0 # freed pages by auto-keep-margin.<br>
margin_elapsed_ns 5545388791 =A0# elapsed time in LRU scanning by auto-keep=
-margin<br>
<br>
This patch adds a new file rather than adding more stats to memory.stat. By=
 it,<br>
this support &quot;reset&quot; accounting by<br>
<br>
 =A0# echo 0 &gt; .../memory.reclaim_stat<br>
<br>
This is good for debug and tuning.<br>
<br>
TODO:<br>
=A0- add Documentaion.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0mm/memcontrol.c | =A0 87 +++++++++++++++++++++++++++++++++++++++++++++++=
+++------<br>
=A01 file changed, 79 insertions(+), 8 deletions(-)<br>
<br>
Index: memcg_async/mm/memcontrol.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg_async.orig/mm/memcontrol.c<br>
+++ memcg_async/mm/memcontrol.c<br>
@@ -216,6 +216,13 @@ static void mem_cgroup_update_margin_to_<br>
=A0static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);<br>
=A0static void mem_cgroup_reflesh_scan_ratio(struct mem_cgroup *mem);<br>
<br>
+enum scan_type {<br>
+ =A0 =A0 =A0 LIMIT_SCAN, =A0 =A0 /* scan memory because memcg hits limit *=
/<br>
+ =A0 =A0 =A0 SOFT_SCAN, =A0 =A0 =A0/* scan memory because of soft limit */=
<br>
+ =A0 =A0 =A0 MARGIN_SCAN, =A0 =A0/* scan memory for making margin to limit=
 */<br>
+ =A0 =A0 =A0 NR_SCAN_TYPES,<br>
+};<br>
+<br>
=A0/*<br>
 =A0* The memory controller data structure. The memory controller controls =
both<br>
 =A0* page cache and RSS per cgroup. We would eventually like to provide<br=
>
@@ -300,6 +307,13 @@ struct mem_cgroup {<br>
 =A0 =A0 =A0 =A0unsigned long =A0 scanned;<br>
 =A0 =A0 =A0 =A0unsigned long =A0 reclaimed;<br>
 =A0 =A0 =A0 =A0unsigned long =A0 next_scanratio_update;<br>
+ =A0 =A0 =A0 /* For statistics */<br>
+ =A0 =A0 =A0 struct {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned_pages;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed_pages;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long elapsed_ns;<br>
+ =A0 =A0 =A0 } scan_stat[NR_SCAN_TYPES];<br>
+<br>
 =A0 =A0 =A0 =A0/*<br>
 =A0 =A0 =A0 =A0 * percpu counter.<br>
 =A0 =A0 =A0 =A0 */<br>
@@ -1426,7 +1440,9 @@ unsigned int mem_cgroup_swappiness(struc<br>
<br>
=A0static void __mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned lo=
ng scanned,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 reclaimed)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 reclaimed,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 elapsed,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum scan_typ=
e type)<br>
=A0{<br>
 =A0 =A0 =A0 =A0unsigned long limit;<br>
<br>
@@ -1439,6 +1455,9 @@ static void __mem_cgroup_update_scan_rat<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem-&gt;scanned /=3D 2;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem-&gt;reclaimed /=3D 2;<br>
 =A0 =A0 =A0 =A0}<br>
+ =A0 =A0 =A0 mem-&gt;scan_stat[type].nr_scanned_pages +=3D scanned;<br>
+ =A0 =A0 =A0 mem-&gt;scan_stat[type].nr_reclaimed_pages +=3D reclaimed;<br=
>
+ =A0 =A0 =A0 mem-&gt;scan_stat[type].elapsed_ns +=3D elapsed;<br>
 =A0 =A0 =A0 =A0spin_unlock(&amp;mem-&gt;scan_stat_lock);<br>
=A0}<br>
<br>
@@ -1448,6 +1467,8 @@ static void __mem_cgroup_update_scan_rat<br>
 =A0* @root : root memcg of hierarchy walk.<br>
 =A0* @scanned : scanned pages<br>
 =A0* @reclaimed: reclaimed pages.<br>
+ * @elapsed: used time for memory reclaim<br>
+ * @type : scan type as LIMIT_SCAN, SOFT_SCAN, MARGIN_SCAN.<br>
 =A0*<br>
 =A0* record scan/reclaim ratio to the memcg both to a child and it&#39;s r=
oot<br>
 =A0* mem cgroup, which is a reclaim target. This value is used for<br>
@@ -1457,11 +1478,14 @@ static void __mem_cgroup_update_scan_rat<br>
=A0static void mem_cgroup_update_scan_ratio(struct mem_cgroup *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct =
mem_cgroup *root,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned lo=
ng scanned,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 reclaimed)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 reclaimed,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 elapsed,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int type)<br>
=A0{<br>
- =A0 =A0 =A0 __mem_cgroup_update_scan_ratio(mem, scanned, reclaimed);<br>
+ =A0 =A0 =A0 __mem_cgroup_update_scan_ratio(mem, scanned, reclaimed, elaps=
ed, type);<br>
 =A0 =A0 =A0 =A0if (mem !=3D root)<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_update_scan_ratio(root, scanned,=
 reclaimed);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_update_scan_ratio(root, scanned,=
 reclaimed,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 elapsed, type);<br>
<br>
=A0}<br>
<br>
@@ -1906,6 +1930,7 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0bool is_kswapd =3D false;<br>
 =A0 =A0 =A0 =A0unsigned long excess;<br>
 =A0 =A0 =A0 =A0unsigned long nr_scanned;<br>
+ =A0 =A0 =A0 unsigned long start, end, elapsed;<br>
<br>
 =A0 =A0 =A0 =A0excess =3D res_counter_soft_limit_excess(&amp;root_mem-&gt;=
res) &gt;&gt; PAGE_SHIFT;<br>
<br>
@@ -1947,18 +1972,24 @@ static int mem_cgroup_hierarchical_recla<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_n=
ode_zone(victim, gfp_mask,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0noswap, zon=
e, &amp;nr_scanned);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D sched_clock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elapsed =3D end - start;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*total_scanned +=3D nr_scan=
ned;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_steal(victi=
m, is_kswapd, ret);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_scan(victim=
, is_kswapd, nr_scanned);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_update_scan_rati=
o(victim,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 root_mem, nr_scanned, ret);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem, nr_=
scanned, ret, elapsed, SOFT_SCAN);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D try_to_free_mem_cgr=
oup_pages(victim, gfp_mask,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0noswap, &amp;nr_scanned);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end =3D sched_clock();<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elapsed =3D end - start;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_update_scan_rati=
o(victim,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 root_mem, nr_scanned, ret);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem, nr_=
scanned, ret, elapsed, LIMIT_SCAN);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*<br>
@@ -4003,7 +4034,7 @@ static void mem_cgroup_async_shrink_work<br>
 =A0 =A0 =A0 =A0struct delayed_work *dw =3D to_delayed_work(work);<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem, *victim;<br>
 =A0 =A0 =A0 =A0long nr_to_reclaim;<br>
- =A0 =A0 =A0 unsigned long nr_scanned, nr_reclaimed;<br>
+ =A0 =A0 =A0 unsigned long nr_scanned, nr_reclaimed, start, end;<br>
 =A0 =A0 =A0 =A0int delay =3D 0;<br>
<br>
 =A0 =A0 =A0 =A0mem =3D container_of(dw, struct mem_cgroup, async_work);<br=
>
@@ -4022,9 +4053,12 @@ static void mem_cgroup_async_shrink_work<br>
 =A0 =A0 =A0 =A0if (!victim)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto finish_scan;<br>
<br>
+ =A0 =A0 =A0 start =3D sched_clock();<br>
 =A0 =A0 =A0 =A0nr_reclaimed =3D mem_cgroup_shrink_rate_limited(victim, nr_=
to_reclaim,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0&amp;nr_scanned);<br>
- =A0 =A0 =A0 mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr_recl=
aimed);<br>
+ =A0 =A0 =A0 end =3D sched_clock();<br>
+ =A0 =A0 =A0 mem_cgroup_update_scan_ratio(victim, mem, nr_scanned, nr_recl=
aimed,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 end - start, MARGIN_SCAN);<br=
>
 =A0 =A0 =A0 =A0css_put(&amp;victim-&gt;css);<br>
<br>
 =A0 =A0 =A0 =A0/* If margin is enough big, stop */<br>
@@ -4680,6 +4714,38 @@ static int mem_control_stat_show(struct<br>
 =A0 =A0 =A0 =A0return 0;<br>
=A0}<br>
<br>
+static int mem_cgroup_reclaim_stat_read(struct cgroup *cont, struct cftype=
 *cft,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup_map_cb *cb)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cont);<br>
+ =A0 =A0 =A0 u64 val;<br>
+ =A0 =A0 =A0 int i; /* for indexing scan_stat[] */<br>
+<br>
+ =A0 =A0 =A0 val =3D mem-&gt;reclaimed * 100 / mem-&gt;scanned;<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;recent_scan_success_ratio&quot;, val);<=
br>
+ =A0 =A0 =A0 i =A0=3D LIMIT_SCAN;<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;limit_scan_pages&quot;, mem-&gt;scan_st=
at[i].nr_scanned_pages);<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;limit_freed_pages&quot;, mem-&gt;scan_s=
tat[i].nr_reclaimed_pages);<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;limit_elapsed_ns&quot;, mem-&gt;scan_st=
at[i].elapsed_ns);<br>
+ =A0 =A0 =A0 i =3D SOFT_SCAN;<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;soft_scan_pages&quot;, mem-&gt;scan_sta=
t[i].nr_scanned_pages);<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;soft_freed_pages&quot;, mem-&gt;scan_st=
at[i].nr_reclaimed_pages);<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;soft_elapsed_ns&quot;, mem-&gt;scan_sta=
t[i].elapsed_ns);<br>
+ =A0 =A0 =A0 i =3D MARGIN_SCAN;<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;margin_scan_pages&quot;, mem-&gt;scan_s=
tat[i].nr_scanned_pages);<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;margin_freed_pages&quot;, mem-&gt;scan_=
stat[i].nr_reclaimed_pages);<br>
+ =A0 =A0 =A0 cb-&gt;fill(cb, &quot;margin_elapsed_ns&quot;, mem-&gt;scan_s=
tat[i].elapsed_ns);<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+static int mem_cgroup_reclaim_stat_reset(struct cgroup *cgrp, unsigned int=
 event)<br>
+{<br>
+ =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);<br>
+ =A0 =A0 =A0 memset(mem-&gt;scan_stat, 0, sizeof(mem-&gt;scan_stat));<br>
+ =A0 =A0 =A0 return 0;<br>
+}<br>
+<br>
+<br>
=A0/*<br>
 =A0* User flags for async_control is a subset of mem-&gt;async_flags. But<=
br>
 =A0* this needs to be defined independently to hide implemation details.<b=
r>
@@ -5163,6 +5229,11 @@ static struct cftype mem_cgroup_files[]<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.open =3D mem_control_numa_stat_open,<br>
 =A0 =A0 =A0 =A0},<br>
=A0#endif<br>
+ =A0 =A0 =A0 {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D &quot;reclaim_stat&quot;,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_reclaim_stat_read,<b=
r>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .trigger =3D mem_cgroup_reclaim_stat_reset,<b=
r>
+ =A0 =A0 =A0 }<br>
=A0};<br>
<br>
=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP<br>
<br>
</blockquote></div><br></div>

--0016360e3f5cd1684604a437a6f6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
