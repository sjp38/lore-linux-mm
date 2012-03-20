Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 65C426B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 01:37:29 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1917026qcs.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 22:37:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC8teKVquCsdoyg6qJ-Cre0STLqHov7sDwEgB+nJ71-_T+F__w@mail.gmail.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<1303185466-2532-7-git-send-email-yinghan@google.com>
	<CAC8teKVquCsdoyg6qJ-Cre0STLqHov7sDwEgB+nJ71-_T+F__w@mail.gmail.com>
Date: Mon, 19 Mar 2012 22:37:27 -0700
Message-ID: <CALWz4izLs-bLj3S0+hqOXA0PY6ePJJ9d=hmSK=Ffh7-QQAY-UQ@mail.gmail.com>
Subject: Re: [PATCH V6 06/10] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

On Mon, Mar 19, 2012 at 1:14 AM, Zhu Yanhai <zhu.yanhai@gmail.com> wrote:
> 2011/4/19 Ying Han <yinghan@google.com>:
>> This is the main loop of per-memcg background reclaim which is implement=
ed in
>> function balance_mem_cgroup_pgdat().
>>
>> The function performs a priority loop similar to global reclaim. During =
each
>> iteration it invokes balance_pgdat_node() for all nodes on the system, w=
hich
>> is another new function performs background reclaim per node. After recl=
aiming
>> each node, it checks mem_cgroup_watermark_ok() and breaks the priority l=
oop if
>> it returns true.
>>
>> changelog v6..v5:
>> 1. add mem_cgroup_zone_reclaimable_pages()
>> 2. fix some comment style.
>>
>> changelog v5..v4:
>> 1. remove duplicate check on nodes_empty()
>> 2. add logic to check if the per-memcg lru is empty on the zone.
>>
>> changelog v4..v3:
>> 1. split the select_victim_node and zone_unreclaimable to a seperate pat=
ches
>> 2. remove the logic tries to do zone balancing.
>>
>> changelog v3..v2:
>> 1. change mz->all_unreclaimable to be boolean.
>> 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg recla=
im.
>> 3. some more clean-up.
>>
>> changelog v2..v1:
>> 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage.
>> 2. shared the kswapd_run/kswapd_stop for per-memcg and global background
>> reclaim.
>> 3. name the per-memcg memcg as "memcg-id" (css->id). And the global kswa=
pd
>> keeps the same name.
>> 4. fix a race on kswapd_stop while the per-memcg-per-zone info could be =
accessed
>> after freeing.
>> 5. add the fairness in zonelist where memcg remember the last zone recla=
imed
>> from.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> ---
>> =A0include/linux/memcontrol.h | =A0 =A09 +++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 18 +++++
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0151 +++++++++++++++++=
+++++++++++++++++++++++++++
>> =A03 files changed, 178 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index d4ff7f2..a4747b0 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -115,6 +115,8 @@ extern void mem_cgroup_end_migration(struct mem_cgro=
up *mem,
>> =A0*/
>> =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>> =A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
>> +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memc=
g,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone);
>> =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list lru);
>> @@ -311,6 +313,13 @@ mem_cgroup_inactive_file_is_low(struct mem_cgroup *=
memcg)
>> =A0}
>>
>> =A0static inline unsigned long
>> +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 st=
ruct zone *zone)
>> +{
>> + =A0 =A0 =A0 return 0;
>> +}
>> +
>> +static inline unsigned long
>> =A0mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum lru_list lru)
>> =A0{
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 06fddd2..7490147 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -1097,6 +1097,24 @@ int mem_cgroup_inactive_file_is_low(struct mem_cg=
roup *memcg)
>> =A0 =A0 =A0 =A0return (active > inactive);
>> =A0}
>>
>> +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memc=
g,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)
>> +{
>> + =A0 =A0 =A0 int nr;
>> + =A0 =A0 =A0 int nid =3D zone_to_nid(zone);
>> + =A0 =A0 =A0 int zid =3D zone_idx(zone);
>> + =A0 =A0 =A0 struct mem_cgroup_per_zone *mz =3D mem_cgroup_zoneinfo(mem=
cg, nid, zid);
>> +
>> + =A0 =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
>> + =A0 =A0 =A0 =A0 =A0 =A0MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
>> +
>> + =A0 =A0 =A0 if (nr_swap_pages > 0)
>
> Do we also need to check memcg->memsw_is_minimum here? That's to say,
> =A0 =A0 =A0 if (nr_swap_pages > 0 && !memcg->memsw_is_minimum)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.....

That sounds about right. By given that swapon isn't common in our test
environment, I am not surprised to miss that condition by that time.

--Ying

> --
> Thanks,
> Zhu Yanhai
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANO=
N) +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, NR_INACTI=
VE_ANON);
>> +
>> + =A0 =A0 =A0 return nr;
>> +}
>> +
>> =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 enum lru_list lru)
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 0060d1e..2a5c734 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -47,6 +47,8 @@
>>
>> =A0#include <linux/swapops.h>
>>
>> +#include <linux/res_counter.h>
>> +
>> =A0#include "internal.h"
>>
>> =A0#define CREATE_TRACE_POINTS
>> @@ -111,6 +113,8 @@ struct scan_control {
>> =A0 =A0 =A0 =A0 * are scanned.
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0nodemask_t =A0 =A0 =A0*nodemask;
>> +
>> + =A0 =A0 =A0 int priority;
>> =A0};
>>
>> =A0#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lr=
u))
>> @@ -2625,11 +2629,158 @@ out:
>> =A0 =A0 =A0 =A0finish_wait(wait_h, &wait);
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
=A0 =A0 struct scan_control *sc)
>> +{
>> + =A0 =A0 =A0 int i;
>> + =A0 =A0 =A0 unsigned long total_scanned =3D 0;
>> + =A0 =A0 =A0 struct mem_cgroup *mem_cont =3D sc->mem_cgroup;
>> + =A0 =A0 =A0 int priority =3D sc->priority;
>> +
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* This dma->highmem order is consistant with global rec=
laim.
>> + =A0 =A0 =A0 =A0* We do this because the page allocator works in the op=
posite
>> + =A0 =A0 =A0 =A0* direction although memcg user pages are mostly alloca=
ted at
>> + =A0 =A0 =A0 =A0* highmem.
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 for (i =3D 0; i < pgdat->nr_zones; i++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat->node_zones + =
i;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scan =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D mem_cgroup_zone_reclaimable_pages=
(mem_cont, zone);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!scan)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc->nr_scanned;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we've done a decent amount of scan=
ning and
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, start doing=
 writepage
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned > SWAP_CLUSTER_MAX * 2 &=
&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned > sc->nr_reclaimed +=
 sc->nr_reclaimed / 2) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->may_writepage =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 sc->nr_scanned =3D total_scanned;
>> +}
>> +
>> +/*
>> + * Per cgroup background reclaim.
>> + * TODO: Take off the order since memcg always do order 0
>> + */
>> +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_co=
nt,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 int order)
>> +{
>> + =A0 =A0 =A0 int i, nid;
>> + =A0 =A0 =A0 int start_node;
>> + =A0 =A0 =A0 int priority;
>> + =A0 =A0 =A0 bool wmark_ok;
>> + =A0 =A0 =A0 int loop;
>> + =A0 =A0 =A0 pg_data_t *pgdat;
>> + =A0 =A0 =A0 nodemask_t do_nodes;
>> + =A0 =A0 =A0 unsigned long total_scanned;
>> + =A0 =A0 =A0 struct scan_control sc =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,
>> + =A0 =A0 =A0 };
>> +
>> +loop_again:
>> + =A0 =A0 =A0 do_nodes =3D NODE_MASK_NONE;
>> + =A0 =A0 =A0 sc.may_writepage =3D !laptop_mode;
>> + =A0 =A0 =A0 sc.nr_reclaimed =3D 0;
>> + =A0 =A0 =A0 total_scanned =3D 0;
>> +
>> + =A0 =A0 =A0 for (priority =3D DEF_PRIORITY; priority >=3D 0; priority-=
-) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D false;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way of swapo=
ut... */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priority =3D=3D DEF_PRIORITY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_nodes =3D node_states[N=
_ONLINE];
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (1) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_=
victim_node(mem_cont,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &do_nodes);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Indicate we have cycl=
ed the nodelist once
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: we might add MA=
X_RECLAIM_LOOP for preventing
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* kswapd burning cpu cy=
cles.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_node=
 =3D nid;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (nid =3D=3D star=
t_node)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_pgdat_node(pgdat, =
order, &sc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_s=
canned;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D pgdat->nr_zones=
 - 1; i >=3D 0; i--) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zon=
e *zone =3D pgdat->node_zones + i;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!popul=
ated_zone(zone))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i < 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear=
(nid, do_nodes);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_watermark_o=
k(mem_cont,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CHARGE_WMARK_HIGH)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =
=3D true;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nodes_empty(do_nodes))=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =
=3D true;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned && priority < DEF_PRIORI=
TY - 2)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, HZ/=
10);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_reclaimed >=3D SWAP_CLUSTER_MAX)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 }
>> +out:
>> + =A0 =A0 =A0 if (!wmark_ok) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_freeze();
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto loop_again;
>> + =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 return sc.nr_reclaimed;
>> +}
>> +#else
>> =A0static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_=
cont,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int order)
>> =A0{
>> =A0 =A0 =A0 =A0return 0;
>> =A0}
>> +#endif
>>
>> =A0/*
>> =A0* The background pageout daemon, started as a kernel thread
>> --
>> 1.7.3.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
