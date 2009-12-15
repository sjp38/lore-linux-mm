Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C677B6B0093
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 05:46:35 -0500 (EST)
Received: by fxm25 with SMTP id 25so4127110fxm.6
        for <linux-mm@kvack.org>; Tue, 15 Dec 2009 02:46:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091215105850.87203454.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	 <c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	 <747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	 <9e6e8d687224c6cbc54281f7c3d07983f701f93d.1260571675.git.kirill@shutemov.name>
	 <20091215105850.87203454.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 15 Dec 2009 12:46:32 +0200
Message-ID: <cc557aab0912150246k476aa85m6c1b61045fb0b26e@mail.gmail.com>
Subject: Re: [PATCH RFC v2 4/4] memcg: implement memory thresholds
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 15, 2009 at 3:58 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Sat, 12 Dec 2009 00:59:19 +0200
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
>> =C2=A0mm/memcontrol.c | =C2=A0263 ++++++++++++++++++++++++++++++++++++++=
+++++++++++++++++
>> =C2=A01 files changed, 263 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index c6081cc..5ba2140 100644
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
>> @@ -38,6 +42,7 @@
>> =C2=A0#include <linux/vmalloc.h>
>> =C2=A0#include <linux/mm_inline.h>
>> =C2=A0#include <linux/page_cgroup.h>
>> +#include <linux/eventfd.h>
>> =C2=A0#include "internal.h"
>>
>> =C2=A0#include <asm/uaccess.h>
>> @@ -56,6 +61,7 @@ static int really_do_swap_account __initdata =3D 1; /*=
 for remember boot option*/
>>
>> =C2=A0static DEFINE_MUTEX(memcg_tasklist); /* can be hold under cgroup_m=
utex */
>> =C2=A0#define SOFTLIMIT_EVENTS_THRESH (1000)
>> +#define THRESHOLDS_EVENTS_THRESH (100)
>>
>> =C2=A0/*
>> =C2=A0 * Statistics for memory cgroup.
>> @@ -72,6 +78,8 @@ enum mem_cgroup_stat_index {
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
>> @@ -182,6 +190,15 @@ struct mem_cgroup_tree {
>>
>> =C2=A0static struct mem_cgroup_tree soft_limit_tree __read_mostly;
>>
>> +struct mem_cgroup_threshold {
>> + =C2=A0 =C2=A0 struct list_head list;
>> + =C2=A0 =C2=A0 struct eventfd_ctx *eventfd;
>> + =C2=A0 =C2=A0 u64 threshold;
>> +};
>> +
>> +static bool mem_cgroup_threshold_check(struct mem_cgroup* mem);
>> +static void mem_cgroup_threshold(struct mem_cgroup* mem, bool swap);
>> +
>> =C2=A0/*
>> =C2=A0 * The memory controller data structure. The memory controller con=
trols both
>> =C2=A0 * page cache and RSS per cgroup. We would eventually like to prov=
ide
>> @@ -233,6 +250,19 @@ struct mem_cgroup {
>> =C2=A0 =C2=A0 =C2=A0 /* set when res.limit =3D=3D memsw.limit */
>> =C2=A0 =C2=A0 =C2=A0 bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memsw=
_is_minimum;
>>
>> + =C2=A0 =C2=A0 /* protect lists of thresholds*/
>> + =C2=A0 =C2=A0 spinlock_t thresholds_lock;
>> +
>> + =C2=A0 =C2=A0 /* thresholds for memory usage */
>> + =C2=A0 =C2=A0 struct list_head thresholds;
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold *below_threshold;
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold *above_threshold;
>> +
>> + =C2=A0 =C2=A0 /* thresholds for mem+swap usage */
>> + =C2=A0 =C2=A0 struct list_head memsw_thresholds;
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold *memsw_below_threshold;
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold *memsw_above_threshold;
>> +
>> =C2=A0 =C2=A0 =C2=A0 /*
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* statistics. This must be placed at the end =
of memcg.
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> @@ -519,6 +549,8 @@ static void mem_cgroup_charge_statistics(struct mem_=
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
>> @@ -1363,6 +1395,11 @@ static int __mem_cgroup_try_charge(struct mm_stru=
ct *mm,
>> =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_soft_limit_check(mem))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_tree(=
mem, page);
>> =C2=A0done:
>> + =C2=A0 =C2=A0 if (mem_cgroup_threshold_check(mem)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(mem, fa=
lse);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (do_swap_account)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
mem_cgroup_threshold(mem, true);
>> + =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0nomem:
>> =C2=A0 =C2=A0 =C2=A0 css_put(&mem->css);
>> @@ -1906,6 +1943,11 @@ __mem_cgroup_uncharge_common(struct page *page, e=
num charge_type ctype)
>>
>> =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_soft_limit_check(mem))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_tree(=
mem, page);
>> + =C2=A0 =C2=A0 if (mem_cgroup_threshold_check(mem)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_threshold(mem, fa=
lse);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (do_swap_account)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
mem_cgroup_threshold(mem, true);
>> + =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 /* at swapout, this memcg will be accessed to recor=
d to swap */
>> =C2=A0 =C2=A0 =C2=A0 if (ctype !=3D MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 css_put(&mem->css);
>> @@ -2860,11 +2902,181 @@ static int mem_cgroup_swappiness_write(struct c=
group *cgrp, struct cftype *cft,
>> =C2=A0}
>>
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
>
> Hmm. please check
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(list_empty(&mem->thesholds) &&
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_empty=
(&mem->memsw_thresholds)))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;

These lists are never be empty. They have at least two fake threshold for 0
and RESOURCE_MAX.

>
> or adds a flag as mem->no_threshold_check to skip this routine quickly.
>
> _OR_
> I personally don't like to have 2 counters to catch events.
>
> How about this ?
>
> =C2=A0 adds
> =C2=A0 struct mem_cgroup {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_t =C2=A0 =C2=A0 =C2=A0 =C2=A0event_coun=
ter; // this is incremented per 32
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 p=
age-in/out
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_t last_softlimit_check;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_t last_thresh_check;
> =C2=A0 };
>
> static bool mem_cgroup_threshold_check(struct mem_cgroup *mem)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0decrement percpu event counter.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (percpu counter reaches 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if =C2=A0(atomic_d=
ec_and_test(&mem->check_thresh) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0check threashold.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0reset counter.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if =C2=A0(atomic_d=
ec_and_test(&memc->check_softlimit) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0update softlimit tree.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0reset counter.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reset percpu count=
er.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> }
>
> Then, you can have a counter like system-wide event counter.

I leave it as is for now, as you mention in other letter.

>> +static void mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
>> +{
>> + =C2=A0 =C2=A0 struct mem_cgroup_threshold **below, **above;
>> + =C2=A0 =C2=A0 struct list_head *thresholds;
>> + =C2=A0 =C2=A0 u64 usage =3D mem_cgroup_usage(memcg, swap);
>> +
>> + =C2=A0 =C2=A0 if (!swap) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D &memcg->thres=
holds;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 above =3D &memcg->above_thre=
shold;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 below =3D &memcg->below_thre=
shold;
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D &memcg->memsw=
_thresholds;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 above =3D &memcg->memsw_abov=
e_threshold;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 below =3D &memcg->memsw_belo=
w_threshold;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 spin_lock(&memcg->thresholds_lock);
>> + =C2=A0 =C2=A0 if ((*above)->threshold <=3D usage) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *below =3D *above;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_continue=
((*above), thresholds, list) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
eventfd_signal((*below)->eventfd, 1);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if ((*above)->threshold > usage)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
*below =3D *above;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 } else if ((*below)->threshold > usage) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *above =3D *below;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_continue=
_reverse((*below), thresholds,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 list) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
eventfd_signal((*above)->eventfd, 1);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
if ((*below)->threshold <=3D usage)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
*above =3D *below;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 spin_unlock(&memcg->thresholds_lock);
>> +}
>
> Could you adds comment on above check ?

I'll add comments in next version of patchset.

> And do we need *spin_lock* here ? Can't you use RCU list walk ?

I'll play with it.

> If you use have to use spinlock here, this is a system-wide spinlock,
> threshold as "100" is too small, I think.

What is reasonable value for THRESHOLDS_EVENTS_THRESH for you?

In most cases spinlock taken only for two checks. Is it significant time?

Unfortunately, I can't test it on a big box. I have only dual-core system.
It's not enough to test scalability.

> Even if you can't use spinlock, please use mutex. (with checking gfp_mask=
).
>
> Thanks,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
