Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 05D286B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 21:12:49 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p0J2Cj4c003586
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:12:45 -0800
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by wpaz13.hot.corp.google.com with ESMTP id p0J2CA65016767
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:12:44 -0800
Received: by qwj9 with SMTP id 9so343463qwj.22
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:12:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110114095241.80cf5796.kamezawa.hiroyu@jp.fujitsu.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
	<1294956035-12081-5-git-send-email-yinghan@google.com>
	<20110114095241.80cf5796.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 18 Jan 2011 18:12:42 -0800
Message-ID: <AANLkTik+D1a2rko1uWweuY-T6MVvUr1QpEkYhGuRL+G5@mail.gmail.com>
Subject: Re: [PATCH 4/5] Per cgroup background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2011 at 4:52 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 13 Jan 2011 14:00:34 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> The current implementation of memcg only supports direct reclaim and thi=
s
>> patch adds the support for background reclaim. Per cgroup background rec=
laim
>> is needed which spreads out the memory pressure over longer period of ti=
me
>> and smoothes out the system performance.
>>
>> There is a kswapd kernel thread for each memory node. We add a different=
 kswapd
>> for each cgroup. The kswapd is sleeping in the wait queue headed at kswa=
pd_wait
>> field of a kswapd descriptor.
>>
>> The kswapd() function now is shared between global and per cgroup kswapd=
 thread.
>> It is passed in with the kswapd descriptor which contains the informatio=
n of
>> either node or cgroup. Then the new function balance_mem_cgroup_pgdat is=
 invoked
>> if it is per cgroup kswapd thread. The balance_mem_cgroup_pgdat performs=
 a
>> priority loop similar to global reclaim. In each iteration it invokes
>> balance_pgdat_node for all nodes on the system, which is a new function =
performs
>> background reclaim per node. A fairness mechanism is implemented to reme=
mber the
>> last node it was reclaiming from and always start at the next one. After=
 reclaiming
>> each node, it checks mem_cgroup_watermark_ok() and breaks the priority l=
oop if
>> returns true. A per memcg zone will be marked as "unreclaimable" if the =
scanning
>> rate is much greater than the reclaiming rate on the per cgroup LRU. The=
 bit is
>> cleared when there is a page charged to the cgroup being freed. Kswapd b=
reaks the
>> priority loop if all the zones are marked as "unreclaimable".
>>
>> Change log v2...v1:
>> 1. start/stop the per-cgroup kswapd at create/delete cgroup stage.
>> 2. remove checking the wmark from per-page charging. now it checks the w=
mark
>> periodically based on the event counter.
>> 3. move the per-cgroup per-zone clear_unreclaimable into uncharge stage.
>> 4. shared the kswapd_run/kswapd_stop for per-cgroup and global backgroun=
d
>> reclaim.
>> 5. name the per-cgroup memcg as "memcg-id" (css->id). And the global ksw=
apd
>> keeps the same name.
>> 6. fix a race on kswapd_stop while the per-memcg-per-zone info could be =
accessed
>> after freeing.
>> 7. add the fairness in zonelist where memcg remember the last zone recla=
imed
>> from.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>

Thank you for your comments ~

> Hmm...at first, I like using workqueue rather than using a thread per mem=
cg.

I plan this as part of performance optimization effort which mainly
focus on reducing
the lock contention between the threads.

>
>
>
>
>> ---
>> =A0include/linux/memcontrol.h | =A0 37 ++++++
>> =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A04 +-
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0192 +++++++++++++++++++++=
+++++++-
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0298 +++++++++++++++++=
+++++++++++++++++++++++----
>> =A04 files changed, 504 insertions(+), 27 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 80a605f..69c6e41 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -25,6 +25,7 @@ struct mem_cgroup;
>> =A0struct page_cgroup;
>> =A0struct page;
>> =A0struct mm_struct;
>> +struct kswapd;
>>
>> =A0/* Stats that can be updated by kernel. */
>> =A0enum mem_cgroup_page_stat_item {
>> @@ -94,6 +95,12 @@ int task_in_mem_cgroup(struct task_struct *task, cons=
t struct mem_cgroup *mem);
>> =A0extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *p=
age);
>> =A0extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)=
;
>> =A0extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge=
_flags);
>> +extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ksw=
apd *kswapd_p);
>> +extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem=
);
>> +extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
>> +extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 nodemask_t *nodes);
>>
>> =A0static inline
>> =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgro=
up *cgroup)
>> @@ -166,6 +173,12 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct =
zone *zone, int order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask);
>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>>
>> +void mem_cgroup_clear_unreclaimable(struct page_cgroup *pc);
>> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int z=
id);
>> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *z=
one);
>> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zon=
e *zone);
>> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* z=
one,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long nr_scanned);
>> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
>> =A0struct mem_cgroup;
>>
>> @@ -361,6 +374,25 @@ static inline unsigned long mem_cgroup_page_stat(st=
ruct mem_cgroup *mem,
>> =A0 =A0 =A0 return -ENOSYS;
>> =A0}
>>
>> +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned)
>> +{
>> +}
>> +
>> +static inline void mem_cgroup_clear_unreclaimable(struct page *page,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)
>> +{
>> +}
>> +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *m=
em,
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)
>> +{
>> +}
>> +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone)
>> +{
>> +}
>> +
>> =A0static inline
>> =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int or=
der,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 gfp_t gfp_mask)
>> @@ -374,6 +406,11 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, =
int nid,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int zid)
>> +{
>> + =A0 =A0 return false;
>> +}
>> =A0#endif /* CONFIG_CGROUP_MEM_CONT */
>>
>> =A0#endif /* _LINUX_MEMCONTROL_H */
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 52122fa..b6b5cbb 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -292,8 +292,8 @@ static inline void scan_unevictable_unregister_node(=
struct node *node)
>> =A0}
>> =A0#endif
>>
>> -extern int kswapd_run(int nid);
>> -extern void kswapd_stop(int nid);
>> +extern int kswapd_run(int nid, struct mem_cgroup *mem);
>> +extern void kswapd_stop(int nid, struct mem_cgroup *mem);
>>
>> =A0#ifdef CONFIG_MMU
>> =A0/* linux/mm/shmem.c */
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 6ef26a7..e716ece 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -48,6 +48,8 @@
>> =A0#include <linux/page_cgroup.h>
>> =A0#include <linux/cpu.h>
>> =A0#include <linux/oom.h>
>> +#include <linux/kthread.h>
>> +
>> =A0#include "internal.h"
>>
>> =A0#include <asm/uaccess.h>
>> @@ -75,6 +77,7 @@ static int really_do_swap_account __initdata =3D 1; /*=
 for remember boot option*/
>> =A0 */
>> =A0#define THRESHOLDS_EVENTS_THRESH (7) /* once in 128 */
>> =A0#define SOFTLIMIT_EVENTS_THRESH (10) /* once in 1024 */
>> +#define WMARK_EVENTS_THRESH (10) /* once in 1024 */
>>
>> =A0/*
>> =A0 * Statistics for memory cgroup.
>> @@ -131,7 +134,10 @@ struct mem_cgroup_per_zone {
>> =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0on_tree;
>> =A0 =A0 =A0 struct mem_cgroup =A0 =A0 =A0 *mem; =A0 =A0 =A0 =A0 =A0 /* B=
ack pointer, we cannot */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 /* use container_of =A0 =A0 =A0 =A0*/
>> + =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 pages_scanned; =A0/* since l=
ast reclaim */
>> + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 all_unreclaimable;=
 =A0 =A0 =A0/* All pages pinned */
>> =A0};
>> +
>> =A0/* Macro for accessing counter */
>> =A0#define MEM_CGROUP_ZSTAT(mz, idx) =A0 =A0((mz)->count[(idx)])
>>
>> @@ -289,8 +295,16 @@ struct mem_cgroup {
>> =A0 =A0 =A0 struct mem_cgroup_stat_cpu nocpu_base;
>> =A0 =A0 =A0 spinlock_t pcp_counter_lock;
>>
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* per cgroup background reclaim.
>> + =A0 =A0 =A0*/
>> =A0 =A0 =A0 wait_queue_head_t *kswapd_wait;
>> =A0 =A0 =A0 unsigned long min_free_kbytes;
>> +
>> + =A0 =A0 /* While doing per cgroup background reclaim, we cache the
>> + =A0 =A0 =A0* last node we reclaimed from
>> + =A0 =A0 =A0*/
>> + =A0 =A0 int last_scanned_node;
>> =A0};
>>
>> =A0/* Stuffs for move charges at task migration. */
>> @@ -380,6 +394,7 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
>> =A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
>> =A0static void drain_all_stock_async(void);
>> =A0static unsigned long get_min_free_kbytes(struct mem_cgroup *mem);
>> +static void wake_memcg_kswapd(struct mem_cgroup *mem);
>>
>> =A0static struct mem_cgroup_per_zone *
>> =A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
>> @@ -568,6 +583,12 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgrou=
p_tree_per_zone *mctz)
>> =A0 =A0 =A0 return mz;
>> =A0}
>>
>> +static void mem_cgroup_check_wmark(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK_LOW))
>> + =A0 =A0 =A0 =A0 =A0 =A0 wake_memcg_kswapd(mem);
>> +}
>> +
>
> Low for trigger, High for stop ?
>
>
>> =A0/*
>> =A0 * Implementation Note: reading percpu statistics for memcg.
>> =A0 *
>> @@ -692,6 +713,8 @@ static void memcg_check_events(struct mem_cgroup *me=
m, struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_threshold(mem);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(__memcg_event_check(mem, SOFTLI=
MIT_EVENTS_THRESH)))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_update_tree(mem, =
page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(__memcg_event_check(mem, WMARK_EV=
ENTS_THRESH)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_check_wmark(mem);
>> =A0 =A0 =A0 }
>
> This is nice.

>
>
>> =A0}
>>
>> @@ -1121,6 +1144,95 @@ mem_cgroup_get_reclaim_stat_from_page(struct page=
 *page)
>> =A0 =A0 =A0 return &mz->reclaim_stat;
>> =A0}
>>
>> +static unsigned long mem_cgroup_zone_reclaimable_pages(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct mem_cgroup_per_zone *mz)
>> +{
>> + =A0 =A0 int nr;
>> + =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
>> +
>> + =A0 =A0 if (nr_swap_pages > 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON) =
+
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, LRU_INACT=
IVE_ANON);
>> +
>> + =A0 =A0 return nr;
>> +}
>> +
>> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* z=
one,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned)
>> +{
>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>> + =A0 =A0 int nid =3D zone_to_nid(zone);
>> + =A0 =A0 int zid =3D zone_idx(zone);
>> +
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>> + =A0 =A0 if (mz)
>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->pages_scanned +=3D nr_scanned;
>> +}
>> +
>> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int z=
id)
>> +{
>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>> +
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>> + =A0 =A0 if (mz)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return mz->pages_scanned <
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_zon=
e_reclaimable_pages(mz) * 6;
>> + =A0 =A0 return 0;
>> +}
>
> Where does this "*6" come from ? please add comment. Or add macro in head=
er
> file and share the value with original.

This will be changed on next post, and I plan to define a macro of the
magic number
shared between per-zone & per-memcg reclaim.

>
>
>
>> +
>> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *z=
one)
>> +{
>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>> + =A0 =A0 int nid =3D zone_to_nid(zone);
>> + =A0 =A0 int zid =3D zone_idx(zone);
>> +
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return false;
>> +
>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>> + =A0 =A0 if (mz)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return mz->all_unreclaimable;
>> +
>> + =A0 =A0 return false;
>> +}
>
> I think you should check whether this zone has any page.
> If no pages in this zone, you can't reclaim any.

I think that has been covered in the mem_cgroup_zone_reclaimable():
>-------if (mz)
>------->-------return mz->pages_scanned <
>------->------->------->-------mem_cgroup_zone_reclaimable_pages(mz) *
>------->------->------->-------ZONE_RECLAIMABLE_RATE;

In this case, the mem_cgroup_zone_reclaimable_pages(mz) =3D=3D 0 and the
function returns false.

>
>
>> +
>> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zon=
e *zone)
>> +{
>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>> + =A0 =A0 int nid =3D zone_to_nid(zone);
>> + =A0 =A0 int zid =3D zone_idx(zone);
>> +
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>> + =A0 =A0 if (mz)
>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->all_unreclaimable =3D 1;
>> +}
>
> I like boolean for this kind ot true/false value.

Changed in the next post.

>
>
>
>> +
>> +void mem_cgroup_clear_unreclaimable(struct page_cgroup *pc)
>> +{
>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>> +
>> + =A0 =A0 if (!pc)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 mz =3D page_cgroup_zoneinfo(pc);
>> + =A0 =A0 if (mz) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->pages_scanned =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->all_unreclaimable =3D 0;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return;
>> +}
>> +
>> =A0unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct list_head *dst,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned long *scanned, int order,
>> @@ -1773,6 +1885,34 @@ static int mem_cgroup_hierarchical_reclaim(struct=
 mem_cgroup *root_mem,
>> =A0}
>>
>> =A0/*
>> + * Visit the first node after the last_scanned_node of @mem and use tha=
t to
>> + * reclaim free pages from.
>> + */
>> +int
>> +mem_cgroup_select_victim_node(struct mem_cgroup *mem, nodemask_t *nodes=
)
>> +{
>> + =A0 =A0 int next_nid;
>> + =A0 =A0 int last_scanned;
>> +
>> + =A0 =A0 last_scanned =3D mem->last_scanned_node;
>> +
>> + =A0 =A0 /* Initial stage and start from node0 */
>> + =A0 =A0 if (last_scanned =3D=3D -1)
>> + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D 0;
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D next_node(last_scanned, *nodes);
>> +
>> + =A0 =A0 if (next_nid =3D=3D MAX_NUMNODES)
>> + =A0 =A0 =A0 =A0 =A0 =A0 next_nid =3D first_node(*nodes);
>> +
>> + =A0 =A0 spin_lock(&mem->reclaim_param_lock);
>> + =A0 =A0 mem->last_scanned_node =3D next_nid;
>> + =A0 =A0 spin_unlock(&mem->reclaim_param_lock);
>> +
>
> Is this 'lock' required ?

Changed in the next post.

>
>> + =A0 =A0 return next_nid;
>> +}
>> +
>> +/*
>> =A0 * Check OOM-Killer is already running under our hierarchy.
>> =A0 * If someone is running, return false.
>> =A0 */
>> @@ -2955,6 +3095,7 @@ __mem_cgroup_uncharge_common(struct page *page, en=
um charge_type ctype)
>> =A0 =A0 =A0 =A0* special functions.
>> =A0 =A0 =A0 =A0*/
>>
>> + =A0 =A0 mem_cgroup_clear_unreclaimable(pc);
>> =A0 =A0 =A0 unlock_page_cgroup(pc);
>
> This kind of hook is not good....Can't you do this 'clear' by kswapd in
> lazy way ?

I can look into that.

>
>
>
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* even after unlock, we have mem->res.usage here and this=
 memcg
>> @@ -3377,7 +3518,7 @@ static int mem_cgroup_resize_limit(struct mem_cgro=
up *memcg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 MEM_CGROUP_RECLAIM_SHRINK);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 curusage =3D res_counter_read_u64(&memcg->re=
s, RES_USAGE);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Usage is reduced ? */
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (curusage >=3D oldusage)
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (curusage >=3D oldusage)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retry_count--;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 oldusage =3D curusage;
>
> ?
>
>
>> @@ -3385,6 +3526,9 @@ static int mem_cgroup_resize_limit(struct mem_cgro=
up *memcg,
>> =A0 =A0 =A0 if (!ret && enlarge)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_oom_recover(memcg);
>>
>> + =A0 =A0 if (!mem_cgroup_is_root(memcg) && !memcg->kswapd_wait)
>> + =A0 =A0 =A0 =A0 =A0 =A0 kswapd_run(0, memcg);
>> +
>> =A0 =A0 =A0 return ret;
>> =A0}
>
> Hmm, this creates a thread when limit is set....So, tons of threads can b=
e
> created. Can't we do this by work_queue ?
> Then, the number of threads will be scaled automatically.

Some effort I plan to do next for reducing the lock contention.

>
>
>>
>> @@ -4747,6 +4891,8 @@ static int alloc_mem_cgroup_per_zone_info(struct m=
em_cgroup *mem, int node)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->usage_in_excess =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->on_tree =3D false;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->mem =3D mem;
>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->pages_scanned =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->all_unreclaimable =3D 0;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 return 0;
>> =A0}
>> @@ -4799,6 +4945,7 @@ static void __mem_cgroup_free(struct mem_cgroup *m=
em)
>> =A0{
>> =A0 =A0 =A0 int node;
>>
>> + =A0 =A0 kswapd_stop(0, mem);
>> =A0 =A0 =A0 mem_cgroup_remove_from_trees(mem);
>> =A0 =A0 =A0 free_css_id(&mem_cgroup_subsys, &mem->css);
>>
>> @@ -4867,6 +5014,48 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *me=
m,
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>> +int mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd *kswap=
d_p)
>> +{
>> + =A0 =A0 if (!mem || !kswapd_p)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> + =A0 =A0 mem->kswapd_wait =3D &kswapd_p->kswapd_wait;
>> + =A0 =A0 kswapd_p->kswapd_mem =3D mem;
>> +
>> + =A0 =A0 return css_id(&mem->css);
>> +}
>> +
>> +wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> +
>> + =A0 =A0 return mem->kswapd_wait;
>> +}
>> +
>> +int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> +
>> + =A0 =A0 return mem->last_scanned_node;
>> +}
>> +
>> +static void wake_memcg_kswapd(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 wait_queue_head_t *wait;
>> +
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 wait =3D mem->kswapd_wait;
>> +
>> + =A0 =A0 if (!waitqueue_active(wait))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 wake_up_interruptible(wait);
>> +}
>> +
>> =A0static int mem_cgroup_soft_limit_tree_init(void)
>> =A0{
>> =A0 =A0 =A0 struct mem_cgroup_tree_per_node *rtpn;
>> @@ -4942,6 +5131,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct=
 cgroup *cont)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_init(&mem->memsw, NULL);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 mem->last_scanned_child =3D 0;
>> + =A0 =A0 mem->last_scanned_node =3D -1;
>
> If we always start from 0 at the first run, I think this can be 0 at defa=
ult.
>
>> =A0 =A0 =A0 spin_lock_init(&mem->reclaim_param_lock);
>> =A0 =A0 =A0 INIT_LIST_HEAD(&mem->oom_notify);
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index a53d91d..34f6165 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -46,6 +46,8 @@
>>
>> =A0#include <linux/swapops.h>
>>
>> +#include <linux/res_counter.h>
>> +
>> =A0#include "internal.h"
>>
>> =A0#define CREATE_TRACE_POINTS
>> @@ -98,6 +100,8 @@ struct scan_control {
>> =A0 =A0 =A0 =A0* are scanned.
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 nodemask_t =A0 =A0 =A0*nodemask;
>> +
>> + =A0 =A0 int priority;
>> =A0};
>>
>> =A0#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lr=
u))
>> @@ -1385,6 +1389,9 @@ shrink_inactive_list(unsigned long nr_to_scan, str=
uct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 ISOLATE_INACTIVE : ISOLATE_BOTH,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, sc->mem_cgroup,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, file);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zo=
ne, nr_scanned);
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track =
of
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.
>> @@ -1504,6 +1511,7 @@ static void shrink_active_list(unsigned long nr_pa=
ges, struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track =
of
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zo=
ne, pgscanned);
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 reclaim_stat->recent_scanned[file] +=3D nr_taken;
>> @@ -2127,11 +2135,19 @@ static int sleeping_prematurely(struct kswapd *k=
swapd, int order,
>> =A0{
>> =A0 =A0 =A0 int i;
>> =A0 =A0 =A0 pg_data_t *pgdat =3D kswapd->kswapd_pgdat;
>> + =A0 =A0 struct mem_cgroup *mem =3D kswapd->kswapd_mem;
>>
>> =A0 =A0 =A0 /* If a direct reclaimer woke kswapd within HZ/10, it's prem=
ature */
>> =A0 =A0 =A0 if (remaining)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>>
>> + =A0 =A0 /* If after HZ/10, the cgroup is below the high wmark, it's pr=
emature */
>> + =A0 =A0 if (mem) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_watermark_ok(mem, CHARGE_WMARK=
_HIGH))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 /* If after HZ/10, a zone is below the high mark, it's prema=
ture */
>> =A0 =A0 =A0 for (i =3D 0; i < pgdat->nr_zones; i++) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat->node_zones + i;
>> @@ -2370,6 +2386,212 @@ out:
>> =A0 =A0 =A0 return sc.nr_reclaimed;
>> =A0}
>>
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>> +/*
>> + * The function is used for per-memcg LRU. It scanns all the zones of t=
he
>> + * node and returns the nr_scanned and nr_reclaimed.
>> + */
>> +static void balance_pgdat_node(pg_data_t *pgdat, int order,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc)
>> +{
>> + =A0 =A0 int i, end_zone;
>> + =A0 =A0 unsigned long total_scanned;
>> + =A0 =A0 struct mem_cgroup *mem_cont =3D sc->mem_cgroup;
>> + =A0 =A0 int priority =3D sc->priority;
>> + =A0 =A0 int nid =3D pgdat->node_id;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Scan in the highmem->dma direction for the highest
>> + =A0 =A0 =A0* zone which needs scanning
>> + =A0 =A0 =A0*/
>> + =A0 =A0 for (i =3D pgdat->nr_zones - 1; i >=3D 0; i--) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat->node_zones + i;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zone=
) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority !=3D =
DEF_PRIORITY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do some background aging of the anon list=
, to give
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages a chance to be referenced before re=
claiming.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (inactive_anon_is_low(zone, sc))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_active_list(SWAP_CLUSTE=
R_MAX, zone,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc, priority, 0);
>
> I think you can check per-zone memory usage here and compare it with
> the value in previous run which set mz->all_unreclaimable.
>
> If current_zone_usage < mz->usage_in_previous_run, you can clear
> all_unreclaimable without hooks.
>
> But please note that 'uncharge' doesn't mean pages turned to be reclaimab=
le.
> I'm not sure there are better hint or not.
>
>
>
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 end_zone =3D i;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto scan;
>> + =A0 =A0 }
>> + =A0 =A0 return;
>> +
>> +scan:
>> + =A0 =A0 total_scanned =3D 0;
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Now scan the zone in the dma->highmem direction, stopping
>> + =A0 =A0 =A0* at the last zone which needs scanning.
>> + =A0 =A0 =A0*
>> + =A0 =A0 =A0* We do this because the page allocator works in the opposi=
te
>> + =A0 =A0 =A0* direction. =A0This prevents the page allocator from alloc=
ating
>> + =A0 =A0 =A0* pages behind kswapd's direction of progress, which would
>> + =A0 =A0 =A0* cause too much scanning of the lower zones.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 for (i =3D 0; i <=3D end_zone; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat->node_zones + i;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zone=
) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority !=3D DEF_PRIORITY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc->nr_scanned;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zone=
))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_zone_reclaimable(mem_cont, nid=
, i))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_set_unreclaimabl=
e(mem_cont, zone);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we've done a decent amount of scanning=
 and
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, start doing wri=
tepage
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned > sc->nr_reclaimed + sc-=
>nr_reclaimed / 2) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->may_writepage =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>> +
>> + =A0 =A0 sc->nr_scanned =3D total_scanned;
>> + =A0 =A0 return;
>> +}
>> +
>> +/*
>> + * Per cgroup background reclaim.
>> + * TODO: Take off the order since memcg always do order 0
>> + */
>> +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_co=
nt,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 int order)
>> +{
>> + =A0 =A0 int i, nid;
>> + =A0 =A0 int start_node;
>> + =A0 =A0 int priority;
>> + =A0 =A0 int wmark_ok;
>> + =A0 =A0 int loop =3D 0;
>> + =A0 =A0 pg_data_t *pgdat;
>> + =A0 =A0 nodemask_t do_nodes;
>> + =A0 =A0 unsigned long total_scanned =3D 0;
>> + =A0 =A0 struct scan_control sc =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D ULONG_MAX,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,
>> + =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,
>> + =A0 =A0 };
>> +
>> +loop_again:
>> + =A0 =A0 do_nodes =3D NODE_MASK_NONE;
>> + =A0 =A0 sc.may_writepage =3D !laptop_mode;
>> + =A0 =A0 sc.nr_reclaimed =3D 0;
>> + =A0 =A0 total_scanned =3D 0;
>> +
>> + =A0 =A0 for (priority =3D DEF_PRIORITY; priority >=3D 0; priority--) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;
>> + =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 loop =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way of swapout..=
. */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (priority =3D=3D DEF_PRIORITY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_nodes =3D node_states[N_ONL=
INE];
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 while (1) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_vict=
im_node(mem_cont,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &do_nodes);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Indicate we have cycled the=
 nodelist once
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: we might add MAX_RE=
CLAIM_LOOP for preventing
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* kswapd burning cpu cycles=
