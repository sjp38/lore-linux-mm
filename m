Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1EDC96B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 17:02:41 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id oAUM1FUH014081
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:01:44 -0800
Received: from vws20 (vws20.prod.google.com [10.241.21.148])
	by kpbe17.cbf.corp.google.com with ESMTP id oAUM0sma003490
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:00:55 -0800
Received: by vws20 with SMTP id 20so903810vws.24
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:00:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130165142.bff427b0.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-4-git-send-email-yinghan@google.com>
	<20101130165142.bff427b0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Nov 2010 14:00:54 -0800
Message-ID: <AANLkTikWE37Gt_Z40+4ao2X8ah0UUgBNmx89CJJHKHUe@mail.gmail.com>
Subject: Re: [PATCH 3/4] Per cgroup background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 11:51 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 29 Nov 2010 22:49:44 -0800
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
>> background reclaim per node. After reclaiming each node, it checks
>> mem_cgroup_watermark_ok() and breaks the priority loop if returns true. =
A per
>> memcg zone will be marked as "unreclaimable" if the scanning rate is muc=
h
>> greater than the reclaiming rate on the per cgroup LRU. The bit is clear=
ed when
>> there is a page charged to the cgroup being freed. Kswapd breaks the pri=
ority
>> loop if all the zones are marked as "unreclaimable".
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/memcontrol.h | =A0 30 +++++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0182 +++++++++++++++++++++=
+++++++++++++++++-
>> =A0mm/page_alloc.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0205 +++++++++++++++++=
++++++++++++++++++++++++++-
>> =A04 files changed, 416 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 90fe7fe..dbed45d 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -127,6 +127,12 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct =
zone *zone, int order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask);
>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>>
>> +void mem_cgroup_clear_unreclaimable(struct page *page, struct zone *zon=
e);
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
>> @@ -299,6 +305,25 @@ static inline void mem_cgroup_update_file_mapped(st=
ruct page *page,
>> =A0{
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
>> @@ -312,6 +337,11 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
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
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index a0c6ed9..1d39b65 100644
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
>> @@ -118,7 +120,10 @@ struct mem_cgroup_per_zone {
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
>> @@ -372,6 +377,7 @@ static void mem_cgroup_put(struct mem_cgroup *mem);
>> =A0static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
>> =A0static void drain_all_stock_async(void);
>> =A0static unsigned long get_min_free_kbytes(struct mem_cgroup *mem);
>> +static inline void wake_memcg_kswapd(struct mem_cgroup *mem);
>>
>> =A0static struct mem_cgroup_per_zone *
>> =A0mem_cgroup_zoneinfo(struct mem_cgroup *mem, int nid, int zid)
>> @@ -1086,6 +1092,106 @@ mem_cgroup_get_reclaim_stat_from_page(struct pag=
e *page)
>> =A0 =A0 =A0 return &mz->reclaim_stat;
>> =A0}
>>
>> +unsigned long mem_cgroup_zone_reclaimable_pages(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct mem_cgroup_per_zone *mz)
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
>> +
>> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *z=
one)
>> +{
>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>> + =A0 =A0 int nid =3D zone_to_nid(zone);
>> + =A0 =A0 int zid =3D zone_idx(zone);
>> +
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> +
>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>> + =A0 =A0 if (mz)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return mz->all_unreclaimable;
>> +
>> + =A0 =A0 return 0;
>> +}
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
>> +
>> +void mem_cgroup_clear_unreclaimable(struct page *page, struct zone *zon=
e)
>> +{
>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>> + =A0 =A0 struct mem_cgroup *mem =3D NULL;
>> + =A0 =A0 int nid =3D zone_to_nid(zone);
>> + =A0 =A0 int zid =3D zone_idx(zone);
>> + =A0 =A0 struct page_cgroup *pc =3D lookup_page_cgroup(page);
>> +
>> + =A0 =A0 if (unlikely(!pc))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 rcu_read_lock();
>> + =A0 =A0 mem =3D pc->mem_cgroup;
>
> This is incorrect. you have to do css_tryget(&mem->css) before rcu_read_u=
nlock.

Thanks. This will be changed in the next post.

>
>> + =A0 =A0 rcu_read_unlock();
>> +
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
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
>> @@ -1887,6 +1993,20 @@ static int __mem_cgroup_do_charge(struct mem_cgro=
up *mem, gfp_t gfp_mask,
>> =A0 =A0 =A0 struct res_counter *fail_res;
>> =A0 =A0 =A0 unsigned long flags =3D 0;
>> =A0 =A0 =A0 int ret;
>> + =A0 =A0 unsigned long min_free_kbytes =3D 0;
>> +
>> + =A0 =A0 min_free_kbytes =3D get_min_free_kbytes(mem);
>> + =A0 =A0 if (min_free_kbytes) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_charge(&mem->res, csize, C=
HARGE_WMARK_LOW,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 &fail_res);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (likely(!ret)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return CHARGE_OK;
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_over_limit =3D mem_cgroup_=
from_res_counter(fail_res,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_memcg_kswapd(mem_over_lim=
it);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>
> I think this check can be moved out to periodic-check as threshould notif=
iers.

I have to check how the threshold notifier works. If the
periodic-check causes delay of triggering
kswapd, we might end up relying on ttfp as we do now.


>
>
>
>>
>> =A0 =A0 =A0 ret =3D res_counter_charge(&mem->res, csize, CHARGE_WMARK_MI=
N, &fail_res);
>>
>> @@ -3037,6 +3157,7 @@ static int mem_cgroup_resize_limit(struct mem_cgro=
up *memcg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->memsw=
_is_minimum =3D false;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&set_limit_mutex);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
>> @@ -3046,7 +3167,7 @@ static int mem_cgroup_resize_limit(struct mem_cgro=
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
> What's changed here ?
Hmm. will change in the next patch.
>
>> @@ -3096,6 +3217,7 @@ static int mem_cgroup_resize_memsw_limit(struct me=
m_cgroup *memcg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->memsw=
_is_minimum =3D false;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 setup_per_memcg_wmarks(memcg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&set_limit_mutex);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
>> @@ -4352,6 +4474,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>> =A0static void __mem_cgroup_free(struct mem_cgroup *mem)
>> =A0{
>> =A0 =A0 =A0 int node;
>> + =A0 =A0 struct kswapd *kswapd_p;
>> + =A0 =A0 wait_queue_head_t *wait;
>>
>> =A0 =A0 =A0 mem_cgroup_remove_from_trees(mem);
>> =A0 =A0 =A0 free_css_id(&mem_cgroup_subsys, &mem->css);
>> @@ -4360,6 +4484,15 @@ static void __mem_cgroup_free(struct mem_cgroup *=
mem)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_mem_cgroup_per_zone_info(mem, node);
>>
>> =A0 =A0 =A0 free_percpu(mem->stat);
>> +
>> + =A0 =A0 wait =3D mem->kswapd_wait;
>> + =A0 =A0 kswapd_p =3D container_of(wait, struct kswapd, kswapd_wait);
>> + =A0 =A0 if (kswapd_p) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (kswapd_p->kswapd_task)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kthread_stop(kswapd_p->kswapd_=
task);
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(kswapd_p);
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 if (sizeof(struct mem_cgroup) < PAGE_SIZE)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(mem);
>> =A0 =A0 =A0 else
>> @@ -4421,6 +4554,39 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *me=
m,
>> =A0 =A0 =A0 return ret;
>> =A0}
>>
>> +static inline
>> +void wake_memcg_kswapd(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 wait_queue_head_t *wait;
>> + =A0 =A0 struct kswapd *kswapd_p;
>> + =A0 =A0 struct task_struct *thr;
>> + =A0 =A0 static char memcg_name[PATH_MAX];
>> +
>> + =A0 =A0 if (!mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> +
>> + =A0 =A0 wait =3D mem->kswapd_wait;
>> + =A0 =A0 kswapd_p =3D container_of(wait, struct kswapd, kswapd_wait);
>> + =A0 =A0 if (!kswapd_p->kswapd_task) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem->css.cgroup)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_path(mem->css.cgroup, m=
emcg_name, PATH_MAX);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(memcg_name, "no_name")=
;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 thr =3D kthread_run(kswapd, kswapd_p, "kswapd%=
s", memcg_name);
>
> I don't think reusing the name of "kswapd" isn't good. and this name cann=
ot
> be long as PATH_MAX...IIUC, this name is for comm[] field which is 16byte=
s long.
>
> So, how about naming this as
>
> =A0"memcg%d", mem->css.id ?

No strong objection with the name. :)
>
> Exporing css.id will be okay if necessary.
>
>
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(thr))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "Failed to st=
art kswapd on memcg %d\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p->kswapd_task =3D thr;
>> + =A0 =A0 }
>
> Hmm, ok, then, kswapd-for-memcg is created when someone go over watermark=
