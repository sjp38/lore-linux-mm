Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id B00CD6B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 01:45:45 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1919360qcs.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 22:45:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC8teKVo-JYvKO_3VQNqgjXTWD-mbTQYMbEp2qvcDLCJokcCjA@mail.gmail.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-8-git-send-email-yinghan@google.com>
	<20110415103240.3bea9069.kamezawa.hiroyu@jp.fujitsu.com>
	<CAC8teKVo-JYvKO_3VQNqgjXTWD-mbTQYMbEp2qvcDLCJokcCjA@mail.gmail.com>
Date: Mon, 19 Mar 2012 22:45:44 -0700
Message-ID: <CALWz4iy+0VkNJx-KzmMRnWr656RNU7+xEJjiKeF05VT9Gfv=Vg@mail.gmail.com>
Subject: Re: [PATCH V4 07/10] Add per-memcg zone "unreclaimable"
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

On Mon, Mar 19, 2012 at 1:27 AM, Zhu Yanhai <zhu.yanhai@gmail.com> wrote:
> 2011/4/15 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>> On Thu, 14 Apr 2011 15:54:26 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>>> After reclaiming each node per memcg, it checks mem_cgroup_watermark_ok=
()
>>> and breaks the priority loop if it returns true. The per-memcg zone wil=
l
>>> be marked as "unreclaimable" if the scanning rate is much greater than =
the
>>> reclaiming rate on the per-memcg LRU. The bit is cleared when there is =
a
>>> page charged to the memcg being freed. Kswapd breaks the priority loop =
if
>>> all the zones are marked as "unreclaimable".
>>>
>>> changelog v4..v3:
>>> 1. split off from the per-memcg background reclaim patch in V3.
>>>
>>> Signed-off-by: Ying Han <yinghan@google.com>
>>> ---
>>> =A0include/linux/memcontrol.h | =A0 30 ++++++++++++++
>>> =A0include/linux/swap.h =A0 =A0 =A0 | =A0 =A02 +
>>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 96 ++++++++++++++++++++=
++++++++++++++++++++++++
>>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 19 +++++++++
>>> =A04 files changed, 147 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>> index d4ff7f2..a8159f5 100644
>>> --- a/include/linux/memcontrol.h
>>> +++ b/include/linux/memcontrol.h
>>> @@ -155,6 +155,12 @@ static inline void mem_cgroup_dec_page_stat(struct=
 page *page,
>>> =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int o=
rder,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask);
>>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>>> +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct pag=
e *page);
>>> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int =
zid);
>>> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *=
zone);
>>> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zo=
ne *zone);
>>> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* =
zone,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long=
 nr_scanned);
>>>
>>> =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>> =A0void mem_cgroup_split_huge_fixup(struct page *head, struct page *tai=
l);
>>> @@ -345,6 +351,25 @@ static inline void mem_cgroup_dec_page_stat(struct=
 page *page,
>>> =A0{
>>> =A0}
>>>
>>> +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned)
>>> +{
>>> +}
>>> +
>>> +static inline void mem_cgroup_clear_unreclaimable(struct page *page,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)
>>> +{
>>> +}
>>> +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *=
mem,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone)
>>> +{
>>> +}
>>> +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 struct zone *zone)
>>> +{
>>> +}
>>> +
>>> =A0static inline
>>> =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int o=
rder,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 gfp_t gfp_mask)
>>> @@ -363,6 +388,11 @@ static inline void mem_cgroup_split_huge_fixup(str=
uct page *head,
>>> =A0{
>>> =A0}
>>>
>>> +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem,=
 int nid,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int zid)
>>> +{
>>> + =A0 =A0 return false;
>>> +}
>>> =A0#endif /* CONFIG_CGROUP_MEM_CONT */
>>>
>>> =A0#if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM=
)
>>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>>> index 17e0511..319b800 100644
>>> --- a/include/linux/swap.h
>>> +++ b/include/linux/swap.h
>>> @@ -160,6 +160,8 @@ enum {
>>> =A0 =A0 =A0 SWP_SCANNING =A0 =A0=3D (1 << 8), =A0 =A0 /* refcount in sc=
an_swap_map */
>>> =A0};
>>>
>>> +#define ZONE_RECLAIMABLE_RATE 6
>>> +
>>> =A0#define SWAP_CLUSTER_MAX 32
>>> =A0#define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index e22351a..da6a130 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -133,7 +133,10 @@ struct mem_cgroup_per_zone {
>>> =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0on_tree;
>>> =A0 =A0 =A0 struct mem_cgroup =A0 =A0 =A0 *mem; =A0 =A0 =A0 =A0 =A0 /* =
Back pointer, we cannot */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 /* use container_of =A0 =A0 =A0 =A0*/
>>> + =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 pages_scanned; =A0/* since =
last reclaim */
>>> + =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0all_unreclaimable=
; =A0 =A0 =A0/* All pages pinned */
>>> =A0};
>>> +
>>> =A0/* Macro for accessing counter */
>>> =A0#define MEM_CGROUP_ZSTAT(mz, idx) =A0 =A0((mz)->count[(idx)])
>>>
>>> @@ -1135,6 +1138,96 @@ mem_cgroup_get_reclaim_stat_from_page(struct pag=
e *page)
>>> =A0 =A0 =A0 return &mz->reclaim_stat;
>>> =A0}
>>>
>>> +static unsigned long mem_cgroup_zone_reclaimable_pages(
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct mem_cgroup_per_zone *mz)
>>> +{
>>> + =A0 =A0 int nr;
>>> + =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
>>> +
>>> + =A0 =A0 if (nr_swap_pages > 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON)=
 +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, LRU_INAC=
TIVE_ANON);
>>> +
>>> + =A0 =A0 return nr;
>>> +}
>>> +
>>> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* =
zone,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned)
>>> +{
>>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>> + =A0 =A0 int nid =3D zone_to_nid(zone);
>>> + =A0 =A0 int zid =3D zone_idx(zone);
>>> +
>>> + =A0 =A0 if (!mem)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> +
>>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>>> + =A0 =A0 if (mz)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->pages_scanned +=3D nr_scanned;
>>> +}
>>> +
>>> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int =
zid)
>>> +{
>>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>> +
>>> + =A0 =A0 if (!mem)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>>> +
>>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>>> + =A0 =A0 if (mz)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return mz->pages_scanned <
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_zo=
ne_reclaimable_pages(mz) *
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ZONE_RECLAIMA=
BLE_RATE;
>>> + =A0 =A0 return 0;
>>> +}
>>> +
>>> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *=
zone)
>>> +{
>>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>> + =A0 =A0 int nid =3D zone_to_nid(zone);
>>> + =A0 =A0 int zid =3D zone_idx(zone);
>>> +
>>> + =A0 =A0 if (!mem)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return false;
>>> +
>>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>>> + =A0 =A0 if (mz)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return mz->all_unreclaimable;
>>> +
>>> + =A0 =A0 return false;
>>> +}
>>> +
>>> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zo=
ne *zone)
>>> +{
>>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>> + =A0 =A0 int nid =3D zone_to_nid(zone);
>>> + =A0 =A0 int zid =3D zone_idx(zone);
>>> +
>>> + =A0 =A0 if (!mem)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> +
>>> + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>>> + =A0 =A0 if (mz)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->all_unreclaimable =3D true;
>>> +}
>>> +
>>> +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct pag=
e *page)
>>> +{
>>> + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>> +
>>> + =A0 =A0 if (!mem)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>>> +
>>> + =A0 =A0 mz =3D page_cgroup_zoneinfo(mem, page);
>>> + =A0 =A0 if (mz) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->pages_scanned =3D 0;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->all_unreclaimable =3D false;
>>> + =A0 =A0 }
>>> +
>>> + =A0 =A0 return;
>>> +}
>>> +
>>> =A0unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct list_head *dst,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long *scanned, int order,
>>> @@ -2801,6 +2894,7 @@ __mem_cgroup_uncharge_common(struct page *page, e=
num charge_type ctype)
>>> =A0 =A0 =A0 =A0* special functions.
>>> =A0 =A0 =A0 =A0*/
>>>
>>> + =A0 =A0 mem_cgroup_clear_unreclaimable(mem, page);
>>
>> Hmm, this will easily cause cache ping-pong. (free_page() clears it afte=
r taking
>> zone->lock....in batched manner.)
>>
>> Could you consider a way to make this low cost ?
>>
>> One way is using memcg_check_event() with some low event trigger.
>> Second way is usign memcg_batch.
>> In many case, we can expect a chunk of free pages are from the same zone=
.
>> Then, add a new member to batch_memcg as
>>
>> struct memcg_batch_info {
>> =A0 =A0 =A0 =A0.....
>> =A0 =A0 =A0 =A0struct zone *zone; =A0 =A0 =A0# a zone page is last uncha=
rged.
>> =A0 =A0 =A0 =A0...
>> }
>>
>> Then,
>> =3D=3D
>> static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsi=
gned int nr_pages,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0str=
uct page *page,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cons=
t enum charge_type ctype)
>> {
>> =A0 =A0 =A0 =A0struct memcg_batch_info *batch =3D NULL;
>> .....
>>
>> =A0 =A0 =A0 =A0if (batch->zone !=3D page_zone(page)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_clear_unreclaimable(mem, page)=
;
>> =A0 =A0 =A0 =A0}
>> direct_uncharge:
>> =A0 =A0 =A0 =A0mem_cgroup_clear_unreclaimable(mem, page);
>> ....
>> }
>> =3D=3D
>>
>> This will reduce overhead dramatically.
>>
>
> Excuse me but I don't quite understand this part, IMHO this is to
> avoid call mem_cgroup_clear_unreclaimable() against each single page
> during a munmap()/free_pages() including many pages to free, which is
> unnecessary because the zone will turn into 'reclaimable' at the first
> page uncharged.
> Then why can't we just say,
> =A0 if (mem_cgroup_zoneinfo(mem, page_to_nid(page), page_zonenum(page))->=
all_unreclaimable) {
> =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_clear_unreclaimable(mem, page);
> =A0 =A0}

Are you suggesting to replace the batching w/ the code above?

--Ying
> --
> Thanks,
> Zhu Yanhai
>
>
>>
>>
>>> =A0 =A0 =A0 unlock_page_cgroup(pc);
>>> =A0 =A0 =A0 /*
>>> =A0 =A0 =A0 =A0* even after unlock, we have mem->res.usage here and thi=
s memcg
>>> @@ -4569,6 +4663,8 @@ static int alloc_mem_cgroup_per_zone_info(struct =
mem_cgroup *mem, int node)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->usage_in_excess =3D 0;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->on_tree =3D false;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->mem =3D mem;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->pages_scanned =3D 0;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 mz->all_unreclaimable =3D false;
>>> =A0 =A0 =A0 }
>>> =A0 =A0 =A0 return 0;
>>> =A0}
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index b8345d2..c081112 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -1414,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan, st=
ruct zone *zone,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ISOLATE_BOTH : ISOLATE_INACTIVE,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, sc->mem_cgroup,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, file);
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc->mem_cgroup, z=
one, nr_scanned);
>>> +
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track=
 of
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.
>>> @@ -1533,6 +1536,7 @@ static void shrink_active_list(unsigned long nr_p=
ages, struct zone *zone,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track=
 of
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc->mem_cgroup, z=
one, pgscanned);
>>> =A0 =A0 =A0 }
>>>
>>> =A0 =A0 =A0 reclaim_stat->recent_scanned[file] +=3D nr_taken;
>>> @@ -2648,6 +2652,7 @@ static void balance_pgdat_node(pg_data_t *pgdat, =
int order,
>>> =A0 =A0 =A0 unsigned long total_scanned =3D 0;
>>> =A0 =A0 =A0 struct mem_cgroup *mem_cont =3D sc->mem_cgroup;
>>> =A0 =A0 =A0 int priority =3D sc->priority;
>>> + =A0 =A0 int nid =3D pgdat->node_id;
>>>
>>> =A0 =A0 =A0 /*
>>> =A0 =A0 =A0 =A0* Now scan the zone in the dma->highmem direction, and w=
e scan
>>> @@ -2664,10 +2669,20 @@ static void balance_pgdat_node(pg_data_t *pgdat=
, int order,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>>
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zon=
e) &&
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority !=3D DEF_PRIORITY)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>> +
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D 0;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc->nr_scanned;
>>>
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zon=
e))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_zone_reclaimable(mem_cont, ni=
d, i))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_set_unreclaimab=
le(mem_cont, zone);
>>> +
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we've done a decent amount of scann=
ing and
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, start doing =
writepage
>>> @@ -2752,6 +2767,10 @@ loop_again:
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!popula=
ted_zone(zone))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 continue;
>>> +
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgro=
up_mz_unreclaimable(mem_cont,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone))
>>> +
>>
>> Ah, okay. this will work.
>>
>> Thanks,
>> -Kame
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
