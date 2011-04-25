Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2B68D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:36:36 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p3PMaY7J026395
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:36:34 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by wpaz9.hot.corp.google.com with ESMTP id p3PMZRkf014986
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:36:33 -0700
Received: by qwc9 with SMTP id 9so51231qwc.27
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:36:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425182953.fd33f261.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425182953.fd33f261.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 25 Apr 2011 15:36:32 -0700
Message-ID: <BANLkTimoMah2T3Ud9q+3TA6m5py2EwuhUg@mail.gmail.com>
Subject: Re: [PATCH 2/7] memcg high watermark interface
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

On Mon, Apr 25, 2011 at 2:29 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Add memory.high_wmark_distance and reclaim_wmarks API per memcg.
> The first adjust the internal low/high wmark calculation and
> the reclaim_wmarks exports the current value of watermarks.
> low_wmark is caclurated in automatic.
>
> $ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
> $ cat /dev/cgroup/A/memory.limit_in_bytes
> 524288000
>
> $ echo 50m >/dev/cgroup/A/memory.high_wmark_distance
>
> $ cat /dev/cgroup/A/memory.reclaim_wmarks
> low_wmark 476053504
> high_wmark 471859200
>
> Change v8a..v7
> =A0 1. removed low_wmark_distance it's now automatic.
> =A0 2. added Documenation.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0Documentation/cgroups/memory.txt | =A0 43 ++++++++++++++++++++++++++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 58 ++++++++++=
+++++++++++++++++++++++++++++
> =A02 files changed, 100 insertions(+), 1 deletion(-)
>
> Index: memcg/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/mm/memcontrol.c
> +++ memcg/mm/memcontrol.c
> @@ -4074,6 +4074,40 @@ static int mem_cgroup_swappiness_write(s
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static u64 mem_cgroup_high_wmark_distance_read(struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0struct cftype *cft)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> +
> + =A0 =A0 =A0 return memcg->high_wmark_distance;
> +}
> +
> +static int mem_cgroup_high_wmark_distance_write(struct cgroup *cont,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct cftype *cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 const char *buffer)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cont);
> + =A0 =A0 =A0 unsigned long long val;
> + =A0 =A0 =A0 u64 limit;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 if (!cont->parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 ret =3D res_counter_memparse_write_strategy(buffer, &val);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 limit =3D res_counter_read_u64(&memcg->res, RES_LIMIT);
> + =A0 =A0 =A0 if (val >=3D limit)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 memcg->high_wmark_distance =3D val;
> +
> + =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap=
)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup_threshold_ary *t;
> @@ -4365,6 +4399,21 @@ static void mem_cgroup_oom_unregister_ev
> =A0 =A0 =A0 =A0mutex_unlock(&memcg_oom_mutex);
> =A0}
>
> +static int mem_cgroup_wmark_read(struct cgroup *cgrp,
> + =A0 =A0 =A0 struct cftype *cft, =A0struct cgroup_map_cb *cb)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgrp);
> + =A0 =A0 =A0 u64 low_wmark, high_wmark;
> +
> + =A0 =A0 =A0 low_wmark =3D res_counter_read_u64(&mem->res, RES_LOW_WMARK=
_LIMIT);
> + =A0 =A0 =A0 high_wmark =3D res_counter_read_u64(&mem->res, RES_HIGH_WMA=
RK_LIMIT);
> +
> + =A0 =A0 =A0 cb->fill(cb, "low_wmark", low_wmark);
> + =A0 =A0 =A0 cb->fill(cb, "high_wmark", high_wmark);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
> =A0 =A0 =A0 =A0struct cftype *cft, =A0struct cgroup_map_cb *cb)
> =A0{
> @@ -4468,6 +4517,15 @@ static struct cftype mem_cgroup_files[]
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.unregister_event =3D mem_cgroup_oom_unreg=
ister_event,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.private =3D MEMFILE_PRIVATE(_OOM_TYPE, OO=
M_CONTROL),
> =A0 =A0 =A0 =A0},
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "high_wmark_distance",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_string =3D mem_cgroup_high_wmark_dis=
tance_write,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D mem_cgroup_high_wmark_distanc=
e_read,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "reclaim_wmarks",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D mem_cgroup_wmark_read,
> + =A0 =A0 =A0 },
> =A0};
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> Index: memcg/Documentation/cgroups/memory.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg.orig/Documentation/cgroups/memory.txt
> +++ memcg/Documentation/cgroups/memory.txt
> @@ -68,6 +68,8 @@ Brief summary of control files.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (See sysc=
tl's vm.swappiness)
> =A0memory.move_charge_at_immigrate # set/show controls of moving charges
> =A0memory.oom_control =A0 =A0 =A0 =A0 =A0 =A0 # set/show oom controls.
> + memory.hiwmark_distance =A0 =A0 =A0 =A0# set/show watermark control
> + memory.reclaim_wmarks =A0 =A0 =A0 =A0 =A0# show watermark details.
>
> =A01. History
>
> @@ -501,6 +503,7 @@ NOTE2: When panic_on_oom is set to "2",
> =A0 =A0 =A0 =A0case of an OOM event in any cgroup.
>
> =A07. Soft limits
> +(See Watermarks, too.)
>
> =A0Soft limits allow for greater sharing of memory. The idea behind soft =
limits
> =A0is to allow control groups to use as much of the memory as needed, pro=
vided
> @@ -649,7 +652,45 @@ At reading, current status of OOM is sho
> =A0 =A0 =A0 =A0under_oom =A0 =A0 =A0 =A00 or 1 (if 1, the memory cgroup i=
s under OOM, tasks may
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 be stoppe=
d.)
>
> -11. TODO
> +11. Watermarks
> +
> +Tasks gets big overhead when it hits memory limit because it needs to sc=
an
> +memory and free them. To avoid that, some background memory freeing by
> +kernel will be helpful. Memory cgroup supports background memory freeing
> +by threshold called Watermarks. It can be used for fuzzy limiting of mem=
ory.
> +
> +For example, if you have 1G limit and set
> + =A0- high_watermark ....980M
> + =A0- low_watermark =A0....984M
> +Memory freeing work by kernel starts when usage goes over 984M until mem=
ory
> +usage goes down to 980M. Of course, this cousumes CPU. So, the kernel co=
ntrols
> +this work to avoid too much cpu hogging.
> +
> +11.1 memory.high_wmark_distance
> +
> +This is an interface for high_wmark. You can specify the distance betwee=
n
> +the limit of memory and high_watemark here. For example, under 1G limit =
memroy
> +cgroup,
> + =A0# echo 20M > memory.high_wmark_distance
> +will set high_watermark as 980M. low_watermark is _automatically_ determ=
ined
> +because big distance between high-low watermark tend to use too much CPU=
 and
> +it's difficult to determine low_watermark by users.
> +
> +With this, memory usage will be reduced to 980M as time goes by.
> +After setting memory.high_wmark_distance to be 20M, assume you update
> +memory.limit_in_bytes to be 2G bytes. In this case, hiwh_watermak is 198=
0M.
> +
> +Another thinking, assume you have memory.limit_in_bytes to be 1G.
> +Then, set memory.high_wmark_distance as 300M. Then, you can limit memory
> +usage under 700M in moderate way and you can limit it under 1G with hard
> +limit.
> +
> +11.2 memory.reclaim_wmarks
> +
> +This interface shows high_watermark and low_watermark in bytes. Maybe
> +useful at compareing usage/watermarks.
> +
> +12. TODO
>
> =A01. Add support for accounting huge pages (as a separate controller)
> =A02. Make per-cgroup scanner reclaim not-shared pages first
>
Thank you and this looks good me, and I can certainly apply that on
the next post.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
