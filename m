Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C488C60021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 22:23:53 -0500 (EST)
Received: by gxk24 with SMTP id 24so9157077gxk.6
        for <linux-mm@kvack.org>; Sun, 27 Dec 2009 19:23:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091228114325.e9b3b3d6.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1261858972.git.kirill@shutemov.name>
	 <3f29ccc3c93e2defd70fc1c4ca8c133908b70b0b.1261858972.git.kirill@shutemov.name>
	 <59a7f92356bf1508f06d12c501a7aa4feffb1bbc.1261858972.git.kirill@shutemov.name>
	 <c2379f3965225b6d62e64c64f8c0e67fee085d7f.1261858972.git.kirill@shutemov.name>
	 <7a4e1d758b98ca633a0be06e883644ad8813c077.1261858972.git.kirill@shutemov.name>
	 <20091228114325.e9b3b3d6.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 28 Dec 2009 05:23:51 +0200
Message-ID: <cc557aab0912271923v4a4ed8cco168193c63efd44f@mail.gmail.com>
Subject: Re: [PATCH v4 4/4] memcg: implement memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 28, 2009 at 4:43 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sun, 27 Dec 2009 04:09:02 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
>> It allows to register multiple memory and memsw thresholds and gets
>> notifications when it crosses.
>>
>> To register a threshold application need:
>> - create an eventfd;
>> - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
>> - write string like "<event_fd> <memory.usage_in_bytes> <threshold>" to
>> =C2=A0 cgroup.event_control.
>>
>> Application will be notified through eventfd when memory usage crosses
>> threshold in any direction.
>>
>> It's applicable for root and non-root cgroup.
>>
>> It uses stats to track memory usage, simmilar to soft limits. It checks
>> if we need to send event to userspace on every 100 page in/out. I guess
>> it's good compromise between performance and accuracy of thresholds.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
>> ---
>> =C2=A0Documentation/cgroups/memory.txt | =C2=A0 19 +++-
>> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0275 ++++++++++++++++++++++++++++++++++++++
>> =C2=A02 files changed, 293 insertions(+), 1 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/me=
mory.txt
>> index b871f25..195af07 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -414,7 +414,24 @@ NOTE1: Soft limits take effect over a long period o=
f time, since they involve
>> =C2=A0NOTE2: It is recommended to set the soft limit always below the ha=
rd limit,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 otherwise the hard limit will take precedenc=
e.
>>
>> -8. TODO
>> +8. Memory thresholds
>> +
>> +Memory controler implements memory thresholds using cgroups notificatio=
n
>> +API (see cgroups.txt). It allows to register multiple memory and memsw
>> +thresholds and gets notifications when it crosses.
>> +
>> +To register a threshold application need:
>> + - create an eventfd using eventfd(2);
>> + - open memory.usage_in_bytes or memory.memsw.usage_in_bytes;
>> + - write string like "<event_fd> <memory.usage_in_bytes> <threshold>" t=
o
>> + =C2=A0 cgroup.event_control.
>> +
>> +Application will be notified through eventfd when memory usage crosses
>> +threshold in any direction.
>> +
>> +It's applicable for root and non-root cgroup.
>> +
>> +9. TODO
>>
>> =C2=A01. Add support for accounting huge pages (as a separate controller=
)
>> =C2=A02. Make per-cgroup scanner reclaim not-shared pages first
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 36eb7af..3a0a6a1 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -6,6 +6,10 @@
>> =C2=A0 * Copyright 2007 OpenVZ SWsoft Inc
>> =C2=A0 * Author: Pavel Emelianov <xemul@openvz.org>
>> =C2=A0 *
>> + * Memory thresholds
>> + * Copyright (C) 2009 Nokia Corporation
>> + * Author: Kirill A. Shutemov
>> + *
>> =C2=A0 * This program is free software; you can redistribute it and/or m=
odify
>> =C2=A0 * it under the terms of the GNU General Public License as publish=
ed by
>> =C2=A0 * the Free Software Foundation; either version 2 of the License, =
or
>> @@ -39,6 +43,8 @@
>> =C2=A0#include <linux/mm_inline.h>
>> =C2=A0#include <linux/page_cgroup.h>
>> =C2=A0#include <linux/cpu.h>
>> +#include <linux/eventfd.h>
>> +#include <linux/sort.h>
>> =C2=A0#include "internal.h"
>>
>> =C2=A0#include <asm/uaccess.h>
>> @@ -56,6 +62,7 @@ static int really_do_swap_account __initdata =3D 1; /*=
 for remember boot option*/
>> =C2=A0#endif
>>
>> =C2=A0#define SOFTLIMIT_EVENTS_THRESH (1000)
>> +#define THRESHOLDS_EVENTS_THRESH (100)
>>
>> =C2=A0/*
>> =C2=A0 * Statistics for memory cgroup.
>> @@ -72,6 +79,8 @@ enum mem_cgroup_stat_index {
>> =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out=
 */
>> =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each pa=
ge in/out.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used by soft=
 limit implementation */
>> + =C2=A0 =C2=A0 MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page i=
n/out.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used by threshold i=
mplementation */
>>
>> =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_NSTATS,
>> =C2=A0};
>> @@ -182,6 +191,20 @@ struct mem_cgroup_tree {
>>
>> =C2=A0static struct mem_cgroup_tree soft_limit_tree __read_mostly;
>>
>> +struct mem_cgroup_threshold {
>> + =C2=A0 =C2=A0 struct eventfd_ctx *eventfd;
>> + =C2=A0 =C2=A0 u64 threshold;
>> +};
>> +
>> +struct mem_cgroup_threshold_ary {
>> + =C2=A0 =C2=A0 unsigned int size;
>> + =C2=A0 =C2=A0 atomic_t cur;
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold entries[0];
>> +};
>> +
> Why "array" is a choice here ? IOW, why not list ?

We need be able to walk by thresholds in both directions to be fast.
AFAIK, It's impossible with RCU-protected list.

> How many waiters are expected as usual workload ?

Array of thresholds reads every 100 page in/out for every CPU.
Write access only when registering new threshold.

>> +static bool mem_cgroup_threshold_check(struct mem_cgroup* mem);
>> +static void mem_cgroup_threshold(struct mem_cgroup* mem);
>> +
>> =C2=A0/*
>> =C2=A0 * The memory controller data structure. The memory controller con=
trols both
>> =C2=A0 * page cache and RSS per cgroup. We would eventually like to prov=
ide
>> @@ -233,6 +256,15 @@ struct mem_cgroup {
>> =C2=A0 =C2=A0 =C2=A0 /* set when res.limit =3D=3D memsw.limit */
>> =C2=A0 =C2=A0 =C2=A0 bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memsw=
_is_minimum;
>>
>> + =C2=A0 =C2=A0 /* protect arrays of thresholds */
>> + =C2=A0 =C2=A0 struct mutex thresholds_lock;
>> +
>> + =C2=A0 =C2=A0 /* thresholds for memory usage. RCU-protected */
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *thresholds;
>> +
>> + =C2=A0 =C2=A0 /* thresholds for mem+swap usage. RCU-protected */
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *memsw_thresholds;
>> +
>> =C2=A0 =C2=A0 =C2=A0 /*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* statistics. This must be placed at the end =
of memcg.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> @@ -525,6 +557,8 @@ static void mem_cgroup_charge_statistics(struct mem_=
cgroup *mem,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_stat_add_s=
afe(cpustat,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_PGPGOUT_COUNT, 1);
>> =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT=
_SOFTLIMIT, -1);
>> + =C2=A0 =C2=A0 __mem_cgroup_stat_add_safe(cpustat, MEM_CGROUP_STAT_THRE=
SHOLDS, -1);
>> +
>> =C2=A0 =C2=A0 =C2=A0 put_cpu();
>> =C2=A0}
>>
>> @@ -1510,6 +1544,8 @@ charged:
>> =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_soft_limit_check(mem))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_tree(=
mem, page);
>> =C2=A0done:
>> + =C2=A0 =C2=A0 if (mem_cgroup_threshold_check(mem))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(mem);
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0nomem:
>> =C2=A0 =C2=A0 =C2=A0 css_put(&mem->css);
>> @@ -2075,6 +2111,8 @@ __mem_cgroup_uncharge_common(struct page *page, en=
um charge_type ctype)
>>
>> =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_soft_limit_check(mem))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_tree(=
mem, page);
>> + =C2=A0 =C2=A0 if (mem_cgroup_threshold_check(mem))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(mem);
>> =C2=A0 =C2=A0 =C2=A0 /* at swapout, this memcg will be accessed to recor=
d to swap */
>> =C2=A0 =C2=A0 =C2=A0 if (ctype !=3D MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 css_put(&mem->css);
>> @@ -3071,12 +3109,246 @@ static int mem_cgroup_swappiness_write(struct c=
group *cgrp, struct cftype *cft,
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0}
>>
>> +static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
>> +{
>> + =C2=A0 =C2=A0 bool ret =3D false;
>> + =C2=A0 =C2=A0 int cpu;
>> + =C2=A0 =C2=A0 s64 val;
>> + =C2=A0 =C2=A0 struct mem_cgroup_stat_cpu *cpustat;
>> +
>> + =C2=A0 =C2=A0 cpu =3D get_cpu();
>> + =C2=A0 =C2=A0 cpustat =3D &mem->stat.cpustat[cpu];
>> + =C2=A0 =C2=A0 val =3D __mem_cgroup_stat_read_local(cpustat, MEM_CGROUP=
_STAT_THRESHOLDS);
>> + =C2=A0 =C2=A0 if (unlikely(val < 0)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_stat_set(cpusta=
t, MEM_CGROUP_STAT_THRESHOLDS,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 THRESHOLDS_EVENTS_THRESH);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D true;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 put_cpu();
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
>> +{
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *thresholds;
>> + =C2=A0 =C2=A0 u64 usage =3D mem_cgroup_usage(memcg, swap);
>> + =C2=A0 =C2=A0 int i, cur;
>> +
>> + =C2=A0 =C2=A0 rcu_read_lock();
>> + =C2=A0 =C2=A0 if (!swap) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D rcu_dereferen=
ce(memcg->thresholds);
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D rcu_dereferen=
ce(memcg->memsw_thresholds);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (!thresholds)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
>> +
>> + =C2=A0 =C2=A0 cur =3D atomic_read(&thresholds->cur);
>> +
>> + =C2=A0 =C2=A0 /* Check if a threshold crossed in any direction */
>> +
>> + =C2=A0 =C2=A0 for(i =3D cur; i >=3D 0 &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlikely(thresholds->entries=
[i].threshold > usage); i--) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_dec(&thresholds->cur)=
;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_signal(thresholds->e=
ntries[i].eventfd, 1);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 for(i =3D cur + 1; i < thresholds->size &&
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlikely(thresholds->entries=
[i].threshold <=3D usage); i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_inc(&thresholds->cur)=
;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_signal(thresholds->e=
ntries[i].eventfd, 1);
>> + =C2=A0 =C2=A0 }
>> +unlock:
>> + =C2=A0 =C2=A0 rcu_read_unlock();
>> +}
>> +
>> +static void mem_cgroup_threshold(struct mem_cgroup *memcg)
>> +{
>> + =C2=A0 =C2=A0 __mem_cgroup_threshold(memcg, false);
>> + =C2=A0 =C2=A0 if (do_swap_account)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_threshold(memcg=
, true);
>> +}
>> +
>> +static int compare_thresholds(const void *a, const void *b)
>> +{
>> + =C2=A0 =C2=A0 const struct mem_cgroup_threshold *_a =3D a;
>> + =C2=A0 =C2=A0 const struct mem_cgroup_threshold *_b =3D b;
>> +
>> + =C2=A0 =C2=A0 return _a->threshold - _b->threshold;
>> +}
>> +
>> +static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype=
 *cft,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct eventfd_ctx *eventfd,=
 const char *args)
>> +{
>> + =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *thresholds, *thresholds=
_new;
>> + =C2=A0 =C2=A0 int type =3D MEMFILE_TYPE(cft->private);
>> + =C2=A0 =C2=A0 u64 threshold, usage;
>> + =C2=A0 =C2=A0 int size;
>> + =C2=A0 =C2=A0 int i, ret;
>> +
>> + =C2=A0 =C2=A0 ret =3D res_counter_memparse_write_strategy(args, &thres=
hold);
>> + =C2=A0 =C2=A0 if (ret)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
>> +
>> + =C2=A0 =C2=A0 mutex_lock(&memcg->thresholds_lock);
>> + =C2=A0 =C2=A0 if (type =3D=3D _MEM)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D memcg->thresh=
olds;
>> + =C2=A0 =C2=A0 else if (type =3D=3D _MEMSWAP)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D memcg->memsw_=
thresholds;
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();
>> +
>> + =C2=A0 =C2=A0 usage =3D mem_cgroup_usage(memcg, type =3D=3D _MEMSWAP);
>> +
>> + =C2=A0 =C2=A0 /* Check if a threshold crossed before adding a new one =
*/
>> + =C2=A0 =C2=A0 if (thresholds)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_threshold(memcg=
, type =3D=3D _MEMSWAP);
>> +
>> + =C2=A0 =C2=A0 if (thresholds)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size =3D thresholds->size + =
1;
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size =3D 1;
>> +
>> + =C2=A0 =C2=A0 /* Allocate memory for new array of thresholds */
>> + =C2=A0 =C2=A0 thresholds_new =3D kmalloc(sizeof(*thresholds_new) +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
size * sizeof(struct mem_cgroup_threshold),
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!thresholds_new) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ENOMEM;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 thresholds_new->size =3D size;
>> +
>> + =C2=A0 =C2=A0 /* Copy thresholds (if any) to new array */
>> + =C2=A0 =C2=A0 if (thresholds)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(thresholds_new->entri=
es, thresholds->entries,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds->size *
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 sizeof(struct mem_cgroup_threshold));
>> + =C2=A0 =C2=A0 /* Add new threshold */
>> + =C2=A0 =C2=A0 thresholds_new->entries[size - 1].eventfd =3D eventfd;
>> + =C2=A0 =C2=A0 thresholds_new->entries[size - 1].threshold =3D threshol=
d;
>> +
>> + =C2=A0 =C2=A0 /* Sort thresholds. Registering of new threshold isn't t=
ime-critical */
>> + =C2=A0 =C2=A0 sort(thresholds_new->entries, size,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
sizeof(struct mem_cgroup_threshold),
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
compare_thresholds, NULL);
>> +
>> + =C2=A0 =C2=A0 /* Find current threshold */
>> + =C2=A0 =C2=A0 atomic_set(&thresholds_new->cur, -1);
>> + =C2=A0 =C2=A0 for(i =3D 0; i < size; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (thresholds_new->entries[=
i].threshold < usage)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
atomic_inc(&thresholds_new->cur);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* We need to increment refcnt to be sure that all =
thresholds
>> + =C2=A0 =C2=A0 =C2=A0* will be unregistered before calling __mem_cgroup=
_free()
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 mem_cgroup_get(memcg);
>> +
>> + =C2=A0 =C2=A0 if (type =3D=3D _MEM)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(memcg->th=
resholds, thresholds_new);
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(memcg->me=
msw_thresholds, thresholds_new);
>> +
>> + =C2=A0 =C2=A0 synchronize_rcu();
>
> Could you add explanation when you use synchronize_rcu() ?

It uses before freeing old array of thresholds to be sure than nobody uses =
it.

>> + =C2=A0 =C2=A0 kfree(thresholds);
>
> Can't this be freed by RCU instead of synchronize_rcu() ?

Yes, this can. But I don't think that (un)registering os thresholds is
time critical.
I think my variant is more clean.

>> +unlock:
>> + =C2=A0 =C2=A0 mutex_unlock(&memcg->thresholds_lock);
>> +
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cfty=
pe *cft,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct eventfd_ctx *eventfd)
>> +{
>> + =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *thresholds, *thresholds=
_new;
>> + =C2=A0 =C2=A0 int type =3D MEMFILE_TYPE(cft->private);
>> + =C2=A0 =C2=A0 u64 usage;
>> + =C2=A0 =C2=A0 int size =3D 0;
>> + =C2=A0 =C2=A0 int i, j, ret;
>> +
>> + =C2=A0 =C2=A0 mutex_lock(&memcg->thresholds_lock);
>> + =C2=A0 =C2=A0 if (type =3D=3D _MEM)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D memcg->thresh=
olds;
>> + =C2=A0 =C2=A0 else if (type =3D=3D _MEMSWAP)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D memcg->memsw_=
thresholds;
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();
>> +
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* Something went wrong if we trying to unregister =
a threshold
>> + =C2=A0 =C2=A0 =C2=A0* if we don't have thresholds
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 BUG_ON(!thresholds);
>> +
>> + =C2=A0 =C2=A0 usage =3D mem_cgroup_usage(memcg, type =3D=3D _MEMSWAP);
>> +
>> + =C2=A0 =C2=A0 /* Check if a threshold crossed before removing */
>> + =C2=A0 =C2=A0 __mem_cgroup_threshold(memcg, type =3D=3D _MEMSWAP);
>> +
>> + =C2=A0 =C2=A0 /* Calculate new number of threshold */
>> + =C2=A0 =C2=A0 for(i =3D 0; i < thresholds->size; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (thresholds->entries[i].e=
ventfd !=3D eventfd)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
size++;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* Set thresholds array to NULL if we don't have thresho=
lds */
>> + =C2=A0 =C2=A0 if (!size) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds_new =3D NULL;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto assign;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* Allocate memory for new array of thresholds */
>> + =C2=A0 =C2=A0 thresholds_new =3D kmalloc(sizeof(*thresholds_new) +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
size * sizeof(struct mem_cgroup_threshold),
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (!thresholds_new) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ENOMEM;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 thresholds_new->size =3D size;
>> +
>> + =C2=A0 =C2=A0 /* Copy thresholds and find current threshold */
>> + =C2=A0 =C2=A0 atomic_set(&thresholds_new->cur, -1);
>> + =C2=A0 =C2=A0 for(i =3D 0, j =3D 0; i < thresholds->size; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (thresholds->entries[i].e=
ventfd =3D=3D eventfd)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
continue;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds_new->entries[j] =
=3D thresholds->entries[i];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (thresholds_new->entries[=
j].threshold < usage)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
atomic_inc(&thresholds_new->cur);
> It's better to do atomic set after loop.

We need one more counter to do this. Do you like it?

>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 j++;
>> + =C2=A0 =C2=A0 }
>
> Hmm..is this "copy array" usual coding style for handling eventfd ?

Since we store only pointer to struct eventfd_ctx, I don't see a problem.

>> +
>> +assign:
>> + =C2=A0 =C2=A0 if (type =3D=3D _MEM)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(memcg->th=
resholds, thresholds_new);
>> + =C2=A0 =C2=A0 else
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(memcg->me=
msw_thresholds, thresholds_new);
>> +
>> + =C2=A0 =C2=A0 synchronize_rcu();
>> +
>> + =C2=A0 =C2=A0 for(i =3D 0; i < thresholds->size - size; i++)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_put(memcg);
>> +
>> + =C2=A0 =C2=A0 kfree(thresholds);
>> +unlock:
>> + =C2=A0 =C2=A0 mutex_unlock(&memcg->thresholds_lock);
>> +
>> + =C2=A0 =C2=A0 return ret;
>> +}
>>
>> =C2=A0static struct cftype mem_cgroup_files[] =3D {
>> =C2=A0 =C2=A0 =C2=A0 {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "usage_in_byt=
es",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .private =3D MEMFILE_PR=
IVATE(_MEM, RES_USAGE),
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgrou=
p_read,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .register_event =3D mem_cgro=
up_register_event,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .unregister_event =3D mem_cg=
roup_unregister_event,
>> =C2=A0 =C2=A0 =C2=A0 },
>> =C2=A0 =C2=A0 =C2=A0 {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "max_usage_in=
_bytes",
>> @@ -3128,6 +3400,8 @@ static struct cftype memsw_cgroup_files[] =3D {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "memsw.usage_=
in_bytes",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .private =3D MEMFILE_PR=
IVATE(_MEMSWAP, RES_USAGE),
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .read_u64 =3D mem_cgrou=
p_read,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .register_event =3D mem_cgro=
up_register_event,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .unregister_event =3D mem_cg=
roup_unregister_event,
>> =C2=A0 =C2=A0 =C2=A0 },
>> =C2=A0 =C2=A0 =C2=A0 {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "memsw.max_us=
age_in_bytes",
>> @@ -3367,6 +3641,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct=
 cgroup *cont)
>> =C2=A0 =C2=A0 =C2=A0 if (parent)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem->swappiness =3D get=
_swappiness(parent);
>> =C2=A0 =C2=A0 =C2=A0 atomic_set(&mem->refcnt, 1);
>> + =C2=A0 =C2=A0 mutex_init(&mem->thresholds_lock);
>> =C2=A0 =C2=A0 =C2=A0 return &mem->css;
>> =C2=A0free_out:
>> =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_free(mem);
>> --
>> 1.6.5.7
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
