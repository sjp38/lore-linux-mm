Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 93DD06B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 14:21:11 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id oB7JL8Hw016523
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 11:21:08 -0800
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by wpaz37.hot.corp.google.com with ESMTP id oB7JKrbm030980
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 7 Dec 2010 11:21:07 -0800
Received: by qyk36 with SMTP id 36so263336qyk.6
        for <linux-mm@kvack.org>; Tue, 07 Dec 2010 11:21:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101207065242.GI3158@balbir.in.ibm.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101207065242.GI3158@balbir.in.ibm.com>
Date: Tue, 7 Dec 2010 11:21:01 -0800
Message-ID: <AANLkTikJbePBKiHeo5ALqRn9V7+RCe0LO+K5F=Rq4pYC@mail.gmail.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 6, 2010 at 10:52 PM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * Ying Han <yinghan@google.com> [2010-11-29 22:49:42]:
>
>> There is a kswapd kernel thread for each memory node. We add a different=
 kswapd
>> for each cgroup.
>
> Could you please elaborate on this, what is adding? creating a thread?

Ok, better descriptor on the V2.

>
> The kswapd is sleeping in the wait queue headed at kswapd_wait
>> field of a kswapd descriptor. The kswapd descriptor stores information o=
f node
>> or cgroup and it allows the global and per cgroup background reclaim to =
share
>> common reclaim algorithms.
>>
>> This patch addes the kswapd descriptor and changes per zone kswapd_wait =
to the
>> common data structure.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>
> The performance data you posted earlier is helpful, do you have any
> additional insights on the the CPU overheads if any?

I haven't measured the kswapd cputime overhead, numbers will be posted
on the next patch.

>
> My general overall comment is that this patch needs to be refactored
> to bring out the change the patch makes.
>
>> =A0include/linux/mmzone.h | =A0 =A03 +-
>> =A0include/linux/swap.h =A0 | =A0 10 +++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0| =A0 =A02 +
>> =A0mm/mmzone.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
>> =A0mm/page_alloc.c =A0 =A0 =A0 =A0| =A0 =A09 +++-
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 98 +++++++++++++++++++++++++=
++++++++--------------
>> =A06 files changed, 90 insertions(+), 34 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 39c24eb..c77dfa2 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -642,8 +642,7 @@ typedef struct pglist_data {
>> =A0 =A0 =A0 unsigned long node_spanned_pages; /* total size of physical =
page
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0range, including holes */
>> =A0 =A0 =A0 int node_id;
>> - =A0 =A0 wait_queue_head_t kswapd_wait;
>> - =A0 =A0 struct task_struct *kswapd;
>> + =A0 =A0 wait_queue_head_t *kswapd_wait;
>> =A0 =A0 =A0 int kswapd_max_order;
>> =A0} pg_data_t;
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index eba53e7..2e6cb58 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -26,6 +26,16 @@ static inline int current_is_kswapd(void)
>> =A0 =A0 =A0 return current->flags & PF_KSWAPD;
>> =A0}
>>
>> +struct kswapd {
>> + =A0 =A0 struct task_struct *kswapd_task;
>> + =A0 =A0 wait_queue_head_t kswapd_wait;
>> + =A0 =A0 struct mem_cgroup *kswapd_mem;
>
> Is this field being used anywhere in this patch?

will move this to the patch3.

>
>> + =A0 =A0 pg_data_t *kswapd_pgdat;
>> +};
>> +
>> +#define MAX_KSWAPDS MAX_NUMNODES
>> +extern struct kswapd kswapds[MAX_KSWAPDS];
>> +int kswapd(void *p);
>> =A0/*
>> =A0 * MAX_SWAPFILES defines the maximum number of swaptypes: things whic=
h can
>> =A0 * be swapped to. =A0The swap type and the offset into that swap type=
 are
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index a4034b6..dca3590 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -263,6 +263,8 @@ struct mem_cgroup {
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 struct mem_cgroup_stat_cpu nocpu_base;
>> =A0 =A0 =A0 spinlock_t pcp_counter_lock;
>> +
>> + =A0 =A0 wait_queue_head_t *kswapd_wait;
>> =A0};
>>
>> =A0/* Stuffs for move charges at task migration. */
>> diff --git a/mm/mmzone.c b/mm/mmzone.c
>> index e35bfb8..c7cbed5 100644
>> --- a/mm/mmzone.c
>> +++ b/mm/mmzone.c
>> @@ -102,7 +102,7 @@ unsigned long zone_nr_free_pages(struct zone *zone)
>> =A0 =A0 =A0 =A0* free pages are low, get a better estimate for free page=
s
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 if (nr_free_pages < zone->percpu_drift_mark &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !waitqueue_active(&zone->zone_=
pgdat->kswapd_wait))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !waitqueue_active(zone->zone_p=
gdat->kswapd_wait))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return zone_page_state_snapshot(zone, NR_FRE=
E_PAGES);
>>
>> =A0 =A0 =A0 return nr_free_pages;
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index b48dea2..a15bc1c 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -4070,13 +4070,18 @@ static void __paginginit free_area_init_core(str=
uct pglist_data *pgdat,
>> =A0 =A0 =A0 int nid =3D pgdat->node_id;
>> =A0 =A0 =A0 unsigned long zone_start_pfn =3D pgdat->node_start_pfn;
>> =A0 =A0 =A0 int ret;
>> + =A0 =A0 struct kswapd *kswapd_p;
>
> _p is sort of ugly, do we really need it?

will change.

>
>>
>> =A0 =A0 =A0 pgdat_resize_init(pgdat);
>> =A0 =A0 =A0 pgdat->nr_zones =3D 0;
>> - =A0 =A0 init_waitqueue_head(&pgdat->kswapd_wait);
>> =A0 =A0 =A0 pgdat->kswapd_max_order =3D 0;
>> =A0 =A0 =A0 pgdat_page_cgroup_init(pgdat);
>> -
>
> Thanks for the whitspace cleanup, but I don't know if that should be
> done here.

done.

>
>> +
>> + =A0 =A0 kswapd_p =3D &kswapds[nid];
>> + =A0 =A0 init_waitqueue_head(&kswapd_p->kswapd_wait);
>> + =A0 =A0 pgdat->kswapd_wait =3D &kswapd_p->kswapd_wait;
>> + =A0 =A0 kswapd_p->kswapd_pgdat =3D pgdat;
>> +
>> =A0 =A0 =A0 for (j =3D 0; j < MAX_NR_ZONES; j++) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat->node_zones + j;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long size, realsize, memmap_pages;
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index b8a6fdc..e08005e 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2115,12 +2115,18 @@ unsigned long try_to_free_mem_cgroup_pages(struc=
t mem_cgroup *mem_cont,
>>
>> =A0 =A0 =A0 return nr_reclaimed;
>> =A0}
>> +
>> =A0#endif
>>
>> +DEFINE_SPINLOCK(kswapds_spinlock);
>> +struct kswapd kswapds[MAX_KSWAPDS];
>> +
>> =A0/* is kswapd sleeping prematurely? */
>> -static int sleeping_prematurely(pg_data_t *pgdat, int order, long remai=
ning)
>> +static int sleeping_prematurely(struct kswapd *kswapd, int order,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long remaining=
)
>> =A0{
>> =A0 =A0 =A0 int i;
>> + =A0 =A0 pg_data_t *pgdat =3D kswapd->kswapd_pgdat;
>>
>> =A0 =A0 =A0 /* If a direct reclaimer woke kswapd within HZ/10, it's prem=
ature */
>> =A0 =A0 =A0 if (remaining)
>> @@ -2377,21 +2383,28 @@ out:
>> =A0 * If there are applications that are active memory-allocators
>> =A0 * (most normal use), this basically shouldn't matter.
>> =A0 */
>> -static int kswapd(void *p)
>> +int kswapd(void *p)
>> =A0{
>> =A0 =A0 =A0 unsigned long order;
>> - =A0 =A0 pg_data_t *pgdat =3D (pg_data_t*)p;
>> + =A0 =A0 struct kswapd *kswapd_p =3D (struct kswapd *)p;
>> + =A0 =A0 pg_data_t *pgdat =3D kswapd_p->kswapd_pgdat;
>> + =A0 =A0 struct mem_cgroup *mem =3D kswapd_p->kswapd_mem;
>
> Do we use mem anywhere?

move to patch3.
>
>> + =A0 =A0 wait_queue_head_t *wait_h =3D &kswapd_p->kswapd_wait;
>
> _p, _h almost look like hungarian notation in reverse :)
>
>> =A0 =A0 =A0 struct task_struct *tsk =3D current;
>> =A0 =A0 =A0 DEFINE_WAIT(wait);
>> =A0 =A0 =A0 struct reclaim_state reclaim_state =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .reclaimed_slab =3D 0,
>> =A0 =A0 =A0 };
>> - =A0 =A0 const struct cpumask *cpumask =3D cpumask_of_node(pgdat->node_=
id);
>> + =A0 =A0 const struct cpumask *cpumask;
>>
>> =A0 =A0 =A0 lockdep_set_current_reclaim_state(GFP_KERNEL);
>>
>> - =A0 =A0 if (!cpumask_empty(cpumask))
>> - =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk, cpumask);
>> + =A0 =A0 if (pgdat) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(pgdat->kswapd_wait !=3D wait_h);
>> + =A0 =A0 =A0 =A0 =A0 =A0 cpumask =3D cpumask_of_node(pgdat->node_id);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!cpumask_empty(cpumask))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allowed_ptr(tsk, cpum=
ask);
>> + =A0 =A0 }
>> =A0 =A0 =A0 current->reclaim_state =3D &reclaim_state;
>>
>> =A0 =A0 =A0 /*
>> @@ -2414,9 +2427,13 @@ static int kswapd(void *p)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long new_order;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(&pgdat->kswapd_wait, &wait, TA=
SK_INTERRUPTIBLE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D pgdat->kswapd_max_order;
>> - =A0 =A0 =A0 =A0 =A0 =A0 pgdat->kswapd_max_order =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(wait_h, &wait, TASK_INTERRUPTI=
BLE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pgdat) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D pgdat->kswapd_ma=
x_order;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat->kswapd_max_order =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_order =3D 0;
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (order < new_order) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Don't sleep if someone =
wants a larger 'order'
>> @@ -2428,10 +2445,12 @@ static int kswapd(void *p)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long remaini=
ng =3D 0;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Try to sl=
eep for a short interval */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_=
prematurely(pgdat, order, remaining)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_=
prematurely(kswapd_p, order,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 remaining)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 remaining =3D schedule_timeout(HZ/10);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 finish_wait(&pgdat->kswapd_wait, &wait);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 finish_wait(wait_h, &wait);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 prepare_to_wait(wait_h, &wait,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TASK_INTERRUPTIBLE);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> @@ -2439,20 +2458,25 @@ static int kswapd(void *p)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* prematu=
re sleep. If not, then go fully
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to slee=
p until explicitly woken up
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_=
prematurely(pgdat, order, remaining)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_=
prematurely(kswapd_p, order,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 remaining)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 if (pgdat)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 trace_mm_vmscan_kswapd_sleep(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat->node_id);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 schedule();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 if (remaining)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 count_vm_event(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 KSWAPD_LOW_WMARK_HIT_QUICKLY);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 count_vm_event(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 KSWAPD_HIGH_WMARK_HIT_QUICKLY);
>
> Sorry, but the coding style hits me here do we really need to change
> this?
done.
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat->kswapd_max_or=
der;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pgdat)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgda=
t->kswapd_max_order;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(&pgdat->kswapd_wait, &wait);
>> + =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(wait_h, &wait);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D try_to_freeze();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kthread_should_stop())
>> @@ -2476,6 +2500,7 @@ static int kswapd(void *p)
>> =A0void wakeup_kswapd(struct zone *zone, int order)
>> =A0{
>> =A0 =A0 =A0 pg_data_t *pgdat;
>> + =A0 =A0 wait_queue_head_t *wait;
>>
>> =A0 =A0 =A0 if (!populated_zone(zone))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> @@ -2488,9 +2513,10 @@ void wakeup_kswapd(struct zone *zone, int order)
>> =A0 =A0 =A0 trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone)=
, order);
>> =A0 =A0 =A0 if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> - =A0 =A0 if (!waitqueue_active(&pgdat->kswapd_wait))
>> + =A0 =A0 wait =3D pgdat->kswapd_wait;
>> + =A0 =A0 if (!waitqueue_active(wait))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> - =A0 =A0 wake_up_interruptible(&pgdat->kswapd_wait);
>> + =A0 =A0 wake_up_interruptible(wait);
>> =A0}
>>
>> =A0/*
>> @@ -2587,7 +2613,10 @@ static int __devinit cpu_callback(struct notifier=
_block *nfb,
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpumask_any_and(cpu_onli=
ne_mask, mask) < nr_cpu_ids)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* One of ou=
r CPUs online: restore mask */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_cpus_allow=
ed_ptr(pgdat->kswapd, mask);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (kswapds[ni=
d].kswapd_task)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 set_cpus_allowed_ptr(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 kswapds[nid].kswapd_task,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 mask);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 return NOTIFY_OK;
>> @@ -2599,19 +2628,20 @@ static int __devinit cpu_callback(struct notifie=
r_block *nfb,
>> =A0 */
>> =A0int kswapd_run(int nid)
>> =A0{
>> - =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);
>> + =A0 =A0 struct task_struct *thr;
>
> thr is an ugly name for task_struct instance

>
>> =A0 =A0 =A0 int ret =3D 0;
>>
>> - =A0 =A0 if (pgdat->kswapd)
>> + =A0 =A0 if (kswapds[nid].kswapd_task)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>
>> - =A0 =A0 pgdat->kswapd =3D kthread_run(kswapd, pgdat, "kswapd%d", nid);
>> - =A0 =A0 if (IS_ERR(pgdat->kswapd)) {
>> + =A0 =A0 thr =3D kthread_run(kswapd, &kswapds[nid], "kswapd%d", nid);
>> + =A0 =A0 if (IS_ERR(thr)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* failure at boot is fatal */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(system_state =3D=3D SYSTEM_BOOTING);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk("Failed to start kswapd on node %d\n"=
,nid);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -1;
>
> What happens to the threads started?

Can you elaborate this little bit more?
>
>> =A0 =A0 =A0 }
>> + =A0 =A0 kswapds[nid].kswapd_task =3D thr;
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>> @@ -2620,10 +2650,20 @@ int kswapd_run(int nid)
>> =A0 */
>> =A0void kswapd_stop(int nid)
>> =A0{
>> - =A0 =A0 struct task_struct *kswapd =3D NODE_DATA(nid)->kswapd;
>> + =A0 =A0 struct task_struct *thr;
>> + =A0 =A0 struct kswapd *kswapd_p;
>> + =A0 =A0 wait_queue_head_t *wait;
>> +
>> + =A0 =A0 pg_data_t *pgdat =3D NODE_DATA(nid);
>> +
>> + =A0 =A0 spin_lock(&kswapds_spinlock);
>> + =A0 =A0 wait =3D pgdat->kswapd_wait;
>> + =A0 =A0 kswapd_p =3D container_of(wait, struct kswapd, kswapd_wait);
>> + =A0 =A0 thr =3D kswapd_p->kswapd_task;
>
> Sorry, but thr is just an ugly name to use.

>
>> + =A0 =A0 spin_unlock(&kswapds_spinlock);
>>
>> - =A0 =A0 if (kswapd)
>> - =A0 =A0 =A0 =A0 =A0 =A0 kthread_stop(kswapd);
>> + =A0 =A0 if (thr)
>> + =A0 =A0 =A0 =A0 =A0 =A0 kthread_stop(thr);
>> =A0}
>>
>> =A0static int __init kswapd_init(void)
>> --
>> 1.7.3.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
