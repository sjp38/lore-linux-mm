Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 4941F6B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 21:13:38 -0400 (EDT)
Received: by obbta14 with SMTP id ta14so1402875obb.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 18:13:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALWz4iy+0VkNJx-KzmMRnWr656RNU7+xEJjiKeF05VT9Gfv=Vg@mail.gmail.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
 <1302821669-29862-8-git-send-email-yinghan@google.com> <20110415103240.3bea9069.kamezawa.hiroyu@jp.fujitsu.com>
 <CAC8teKVo-JYvKO_3VQNqgjXTWD-mbTQYMbEp2qvcDLCJokcCjA@mail.gmail.com> <CALWz4iy+0VkNJx-KzmMRnWr656RNU7+xEJjiKeF05VT9Gfv=Vg@mail.gmail.com>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Thu, 22 Mar 2012 09:13:16 +0800
Message-ID: <CAC8teKWxdRFBPw1DLABCrwBoEcuyk5NqD1+=TW6qchaK_8hcoQ@mail.gmail.com>
Subject: Re: [PATCH V4 07/10] Add per-memcg zone "unreclaimable"
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

2012/3/20 Ying Han <yinghan@google.com>:
> On Mon, Mar 19, 2012 at 1:27 AM, Zhu Yanhai <zhu.yanhai@gmail.com> wrote:
>> 2011/4/15 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
>>> On Thu, 14 Apr 2011 15:54:26 -0700
>>> Ying Han <yinghan@google.com> wrote:
>>>
>>>> After reclaiming each node per memcg, it checks mem_cgroup_watermark_o=
k()
>>>> and breaks the priority loop if it returns true. The per-memcg zone wi=
ll
>>>> be marked as "unreclaimable" if the scanning rate is much greater than=
 the
>>>> reclaiming rate on the per-memcg LRU. The bit is cleared when there is=
 a
>>>> page charged to the memcg being freed. Kswapd breaks the priority loop=
 if
>>>> all the zones are marked as "unreclaimable".
>>>>
>>>> changelog v4..v3:
>>>> 1. split off from the per-memcg background reclaim patch in V3.
>>>>
>>>> Signed-off-by: Ying Han <yinghan@google.com>
>>>> ---
>>>> =C2=A0include/linux/memcontrol.h | =C2=A0 30 ++++++++++++++
>>>> =C2=A0include/linux/swap.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +
>>>> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 96 ++++++++++++++++++++++++++++++++++++++++++++
>>>> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 19 +++++++++
>>>> =C2=A04 files changed, 147 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>>> index d4ff7f2..a8159f5 100644
>>>> --- a/include/linux/memcontrol.h
>>>> +++ b/include/linux/memcontrol.h
>>>> @@ -155,6 +155,12 @@ static inline void mem_cgroup_dec_page_stat(struc=
t page *page,
>>>> =C2=A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, i=
nt order,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 gfp_t gfp_mask);
>>>> =C2=A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>>>> +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct pa=
ge *page);
>>>> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int=
 zid);
>>>> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone =
*zone);
>>>> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct z=
one *zone);
>>>> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone*=
 zone,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long nr_scanned);
>>>>
>>>> =C2=A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>>> =C2=A0void mem_cgroup_split_huge_fixup(struct page *head, struct page =
*tail);
>>>> @@ -345,6 +351,25 @@ static inline void mem_cgroup_dec_page_stat(struc=
t page *page,
>>>> =C2=A0{
>>>> =C2=A0}
>>>>
>>>> +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem=
,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 struct zone *zone,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 unsigned long nr_scanned)
>>>> +{
>>>> +}
>>>> +
>>>> +static inline void mem_cgroup_clear_unreclaimable(struct page *page,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone)
>>>> +{
>>>> +}
>>>> +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup =
*mem,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone)
>>>> +{
>>>> +}
>>>> +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem=
,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 struct zone *zone)
>>>> +{
>>>> +}
>>>> +
>>>> =C2=A0static inline
>>>> =C2=A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, i=
nt order,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 gfp_t gfp_mask)
>>>> @@ -363,6 +388,11 @@ static inline void mem_cgroup_split_huge_fixup(st=
ruct page *head,
>>>> =C2=A0{
>>>> =C2=A0}
>>>>
>>>> +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem=
, int nid,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int z=
id)
>>>> +{
>>>> + =C2=A0 =C2=A0 return false;
>>>> +}
>>>> =C2=A0#endif /* CONFIG_CGROUP_MEM_CONT */
>>>>
>>>> =C2=A0#if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBU=
G_VM)
>>>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>>>> index 17e0511..319b800 100644
>>>> --- a/include/linux/swap.h
>>>> +++ b/include/linux/swap.h
>>>> @@ -160,6 +160,8 @@ enum {
>>>> =C2=A0 =C2=A0 =C2=A0 SWP_SCANNING =C2=A0 =C2=A0=3D (1 << 8), =C2=A0 =
=C2=A0 /* refcount in scan_swap_map */
>>>> =C2=A0};
>>>>
>>>> +#define ZONE_RECLAIMABLE_RATE 6
>>>> +
>>>> =C2=A0#define SWAP_CLUSTER_MAX 32
>>>> =C2=A0#define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
>>>>
>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>>> index e22351a..da6a130 100644
>>>> --- a/mm/memcontrol.c
>>>> +++ b/mm/memcontrol.c
>>>> @@ -133,7 +133,10 @@ struct mem_cgroup_per_zone {
>>>> =C2=A0 =C2=A0 =C2=A0 bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0on_tree;
>>>> =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup =C2=A0 =C2=A0 =C2=A0 *mem; =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Back pointer, we cannot */
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 /* use container_of =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>>> + =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pages=
_scanned; =C2=A0/* since last reclaim */
>>>> + =C2=A0 =C2=A0 bool =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0all_unreclaimable; =C2=A0 =C2=A0 =C2=A0/* All pages pin=
ned */
>>>> =C2=A0};
>>>> +
>>>> =C2=A0/* Macro for accessing counter */
>>>> =C2=A0#define MEM_CGROUP_ZSTAT(mz, idx) =C2=A0 =C2=A0((mz)->count[(idx=
)])
>>>>
>>>> @@ -1135,6 +1138,96 @@ mem_cgroup_get_reclaim_stat_from_page(struct pa=
ge *page)
>>>> =C2=A0 =C2=A0 =C2=A0 return &mz->reclaim_stat;
>>>> =C2=A0}
>>>>
>>>> +static unsigned long mem_cgroup_zone_reclaimable_pages(
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mem_cgro=
up_per_zone *mz)
>>>> +{
>>>> + =C2=A0 =C2=A0 int nr;
>>>> + =C2=A0 =C2=A0 nr =3D MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_ZSTAT(mz, LRU_I=
NACTIVE_FILE);
>>>> +
>>>> + =C2=A0 =C2=A0 if (nr_swap_pages > 0)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr +=3D MEM_CGROUP_ZSTAT(m=
z, LRU_ACTIVE_ANON) +
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
>>>> +
>>>> + =C2=A0 =C2=A0 return nr;
>>>> +}
>>>> +
>>>> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone*=
 zone,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 unsigned long nr_scanned)
>>>> +{
>>>> + =C2=A0 =C2=A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>>> + =C2=A0 =C2=A0 int nid =3D zone_to_nid(zone);
>>>> + =C2=A0 =C2=A0 int zid =3D zone_idx(zone);
>>>> +
>>>> + =C2=A0 =C2=A0 if (!mem)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>>>> +
>>>> + =C2=A0 =C2=A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>>>> + =C2=A0 =C2=A0 if (mz)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->pages_scanned +=3D nr_=
scanned;
>>>> +}
>>>> +
>>>> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int=
 zid)
>>>> +{
>>>> + =C2=A0 =C2=A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>>> +
>>>> + =C2=A0 =C2=A0 if (!mem)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>>>> +
>>>> + =C2=A0 =C2=A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>>>> + =C2=A0 =C2=A0 if (mz)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return mz->pages_scanned <
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_zone_reclaimable_pages(mz) *
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ZONE_RECLAIMABLE_RATE;
>>>> + =C2=A0 =C2=A0 return 0;
>>>> +}
>>>> +
>>>> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone =
*zone)
>>>> +{
>>>> + =C2=A0 =C2=A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>>> + =C2=A0 =C2=A0 int nid =3D zone_to_nid(zone);
>>>> + =C2=A0 =C2=A0 int zid =3D zone_idx(zone);
>>>> +
>>>> + =C2=A0 =C2=A0 if (!mem)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>>>> +
>>>> + =C2=A0 =C2=A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>>>> + =C2=A0 =C2=A0 if (mz)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return mz->all_unreclaimab=
le;
>>>> +
>>>> + =C2=A0 =C2=A0 return false;
>>>> +}
>>>> +
>>>> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct z=
one *zone)
>>>> +{
>>>> + =C2=A0 =C2=A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>>> + =C2=A0 =C2=A0 int nid =3D zone_to_nid(zone);
>>>> + =C2=A0 =C2=A0 int zid =3D zone_idx(zone);
>>>> +
>>>> + =C2=A0 =C2=A0 if (!mem)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>>>> +
>>>> + =C2=A0 =C2=A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
>>>> + =C2=A0 =C2=A0 if (mz)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->all_unreclaimable =3D =
true;
>>>> +}
>>>> +
>>>> +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct pa=
ge *page)
>>>> +{
>>>> + =C2=A0 =C2=A0 struct mem_cgroup_per_zone *mz =3D NULL;
>>>> +
>>>> + =C2=A0 =C2=A0 if (!mem)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>>>> +
>>>> + =C2=A0 =C2=A0 mz =3D page_cgroup_zoneinfo(mem, page);
>>>> + =C2=A0 =C2=A0 if (mz) {
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->pages_scanned =3D 0;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->all_unreclaimable =3D =
false;
>>>> + =C2=A0 =C2=A0 }
>>>> +
>>>> + =C2=A0 =C2=A0 return;
>>>> +}
>>>> +
>>>> =C2=A0unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_=
head *dst,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned lon=
g *scanned, int order,
>>>> @@ -2801,6 +2894,7 @@ __mem_cgroup_uncharge_common(struct page *page, =
enum charge_type ctype)
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* special functions.
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>>>
>>>> + =C2=A0 =C2=A0 mem_cgroup_clear_unreclaimable(mem, page);
>>>
>>> Hmm, this will easily cause cache ping-pong. (free_page() clears it aft=
er taking
>>> zone->lock....in batched manner.)
>>>
>>> Could you consider a way to make this low cost ?
>>>
>>> One way is using memcg_check_event() with some low event trigger.
>>> Second way is usign memcg_batch.
>>> In many case, we can expect a chunk of free pages are from the same zon=
e.
>>> Then, add a new member to batch_memcg as
>>>
>>> struct memcg_batch_info {
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.....
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone; =C2=A0 =C2=A0 =C2=A0# a z=
one page is last uncharged.
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>>> }
>>>
>>> Then,
>>> =3D=3D
>>> static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int nr_pages,
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const enum charge_type cty=
pe)
>>> {
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct memcg_batch_info *batch =3D NULL;
>>> .....
>>>
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (batch->zone !=3D page_zone(page)) {
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_clear=
_unreclaimable(mem, page);
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>> direct_uncharge:
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_clear_unreclaimable(mem, page);
>>> ....
>>> }
>>> =3D=3D
>>>
>>> This will reduce overhead dramatically.
>>>
>>
>> Excuse me but I don't quite understand this part, IMHO this is to
>> avoid call mem_cgroup_clear_unreclaimable() against each single page
>> during a munmap()/free_pages() including many pages to free, which is
>> unnecessary because the zone will turn into 'reclaimable' at the first
>> page uncharged.
>> Then why can't we just say,
>> =C2=A0 if (mem_cgroup_zoneinfo(mem, page_to_nid(page), page_zonenum(page=
))->all_unreclaimable) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_clear_unreclaimable(=
mem, page);
>> =C2=A0 =C2=A0}
>
> Are you suggesting to replace the batching w/ the code above?
err...never mind, I got it, it was designed to avoid to touch
mem_cgroup_per_zone and its flag. sorry for the noise :)

--
Thanks
Zhu Yanhai

>
> --Ying
>> --
>> Thanks,
>> Zhu Yanhai
>>
>>
>>>
>>>
>>>> =C2=A0 =C2=A0 =C2=A0 unlock_page_cgroup(pc);
>>>> =C2=A0 =C2=A0 =C2=A0 /*
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* even after unlock, we have mem->res.usage=
 here and this memcg
>>>> @@ -4569,6 +4663,8 @@ static int alloc_mem_cgroup_per_zone_info(struct=
 mem_cgroup *mem, int node)
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->usage_in_excess =
=3D 0;
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->on_tree =3D false=
;
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->mem =3D mem;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->pages_scanned =3D 0;
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mz->all_unreclaimable =3D =
false;
>>>> =C2=A0 =C2=A0 =C2=A0 }
>>>> =C2=A0 =C2=A0 =C2=A0 return 0;
>>>> =C2=A0}
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index b8345d2..c081112 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -1414,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan, s=
truct zone *zone,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ISOLATE_BOTH=
 : ISOLATE_INACTIVE,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 zone, sc->mem_cgroup,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 0, file);
>>>> +
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_mz_pages_scanne=
d(sc->mem_cgroup, zone, nr_scanned);
>>>> +
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* mem_cgroup_is=
olate_pages() keeps track of
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* scanned pages=
 on its own.
>>>> @@ -1533,6 +1536,7 @@ static void shrink_active_list(unsigned long nr_=
pages, struct zone *zone,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* mem_cgroup_is=
olate_pages() keeps track of
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* scanned pages=
 on its own.
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_mz_pages_scanne=
d(sc->mem_cgroup, zone, pgscanned);
>>>> =C2=A0 =C2=A0 =C2=A0 }
>>>>
>>>> =C2=A0 =C2=A0 =C2=A0 reclaim_stat->recent_scanned[file] +=3D nr_taken;
>>>> @@ -2648,6 +2652,7 @@ static void balance_pgdat_node(pg_data_t *pgdat,=
 int order,
>>>> =C2=A0 =C2=A0 =C2=A0 unsigned long total_scanned =3D 0;
>>>> =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *mem_cont =3D sc->mem_cgroup;
>>>> =C2=A0 =C2=A0 =C2=A0 int priority =3D sc->priority;
>>>> + =C2=A0 =C2=A0 int nid =3D pgdat->node_id;
>>>>
>>>> =C2=A0 =C2=A0 =C2=A0 /*
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0* Now scan the zone in the dma->highmem dir=
ection, and we scan
>>>> @@ -2664,10 +2669,20 @@ static void balance_pgdat_node(pg_data_t *pgda=
t, int order,
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!populated_zone(z=
one))
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
>>>>
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_mz_unreclai=
mable(mem_cont, zone) &&
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 priority !=3D DEF_PRIORITY)
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 continue;
>>>> +
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->nr_scanned =3D 0;
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrink_zone(priority,=
 zone, sc);
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total_scanned +=3D sc=
->nr_scanned;
>>>>
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem_cgroup_mz_unreclai=
mable(mem_cont, zone))
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 continue;
>>>> +
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mem_cgroup_zone_recla=
imable(mem_cont, nid, i))
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
>>>> +
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we've done=
 a decent amount of scanning and
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the reclaim r=
atio is low, start doing writepage
>>>> @@ -2752,6 +2767,10 @@ loop_again:
>>>>
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!populated_zone(zone))
>>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>>>> +
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mem_cgroup_mz_unreclaimable(mem_cont,
>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone)=
)
>>>> +
>>>
>>> Ah, okay. this will work.
>>>
>>> Thanks,
>>> -Kame
>>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
