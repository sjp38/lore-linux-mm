Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 885F26B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 13:22:22 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oAUIMHij017373
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:22:17 -0800
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by hpaq12.eem.corp.google.com with ESMTP id oAUIMFkA010257
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:22:15 -0800
Received: by qwk3 with SMTP id 3so506827qwk.16
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 10:22:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101130165324.f0c00b47.kamezawa.hiroyu@jp.fujitsu.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-5-git-send-email-yinghan@google.com>
	<20101130165324.f0c00b47.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Nov 2010 10:22:14 -0800
Message-ID: <AANLkTi=0feXH-eFj+E3nEdExp5MvBiiMLn_EAFHo9GHk@mail.gmail.com>
Subject: Re: [PATCH 4/4] Add more per memcg stats.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 11:53 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 29 Nov 2010 22:49:45 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> A bunch of statistics are added in memory.stat to monitor per cgroup
>> kswapd performance.
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>
> No objections. But please update the documenation and add more comments.

Sure. will do.

Thanks

--Ying
>
> Thanks,
> -Kame
>
>> ---
>> =A0include/linux/memcontrol.h | =A0 81 +++++++++++++++++++++++++
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0140 +++++++++++++++++++++=
+++++++++++++++++++++++
>> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 33 +++++++++-
>> =A03 files changed, 250 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index dbed45d..893ca62 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -127,6 +127,19 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct =
zone *zone, int order,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask);
>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>>
>> +/* background reclaim stats */
>> +void mem_cgroup_kswapd_steal(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_pg_steal(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_kswapd_pgscan(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_pg_pgscan(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_pgrefill(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_pg_outrun(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_alloc_stall(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_balance_wmark_ok(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_balance_swap_max(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_kswapd_shrink_zone(struct mem_cgroup *memcg, int val);
>> +void mem_cgroup_kswapd_may_writepage(struct mem_cgroup *memcg, int val)=
;
>> +
>> =A0void mem_cgroup_clear_unreclaimable(struct page *page, struct zone *z=
one);
>> =A0bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int=
 zid);
>> =A0bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone =
*zone);
>> @@ -337,6 +350,74 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> +/* background reclaim stats */
>> +static inline void mem_cgroup_kswapd_steal(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_pg_steal(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_kswapd_pgscan(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_pg_pgscan(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_pgrefill(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_pg_outrun(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_alloc_stall(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_balance_wmark_ok(struct mem_cgroup *memcg=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_balance_swap_max(struct mem_cgroup *memcg=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static inline void mem_cgroup_kswapd_shrink_zone(struct mem_cgroup *mem=
cg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> +
>> +static inline void mem_cgroup_kswapd_may_writepage(struct mem_cgroup *m=
emcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
>> +{
>> + =A0 =A0 return 0;
>> +}
>> +
>> =A0static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem=
, int nid,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int zid)
>> =A0{
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 1d39b65..97df6dd 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -91,6 +91,21 @@ enum mem_cgroup_stat_index {
>> =A0 =A0 =A0 MEM_CGROUP_STAT_PGPGIN_COUNT, =A0 /* # of pages paged in */
>> =A0 =A0 =A0 MEM_CGROUP_STAT_PGPGOUT_COUNT, =A0/* # of pages paged out */
>> =A0 =A0 =A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
>> + =A0 =A0 MEM_CGROUP_STAT_KSWAPD_INVOKE, /* # of times invokes kswapd */
>> + =A0 =A0 MEM_CGROUP_STAT_KSWAPD_STEAL, /* # of pages reclaimed from ksw=
apd */
>> + =A0 =A0 MEM_CGROUP_STAT_PG_PGSTEAL, /* # of pages reclaimed from ttfp =
*/
>> + =A0 =A0 MEM_CGROUP_STAT_KSWAPD_PGSCAN, /* # of pages scanned from kswa=
pd */
>> + =A0 =A0 MEM_CGROUP_STAT_PG_PGSCAN, /* # of pages scanned from ttfp */
>> + =A0 =A0 MEM_CGROUP_STAT_PGREFILL, /* # of pages scanned on active list=
 */
>> + =A0 =A0 MEM_CGROUP_STAT_WMARK_LOW_OK,
>> + =A0 =A0 MEM_CGROUP_STAT_KSWAP_CREAT,
>> + =A0 =A0 MEM_CGROUP_STAT_PGOUTRUN,
>> + =A0 =A0 MEM_CGROUP_STAT_ALLOCSTALL,
>> + =A0 =A0 MEM_CGROUP_STAT_BALANCE_WMARK_OK,
>> + =A0 =A0 MEM_CGROUP_STAT_BALANCE_SWAP_MAX,
>> + =A0 =A0 MEM_CGROUP_STAT_WAITQUEUE,
>> + =A0 =A0 MEM_CGROUP_STAT_KSWAPD_SHRINK_ZONE,
>> + =A0 =A0 MEM_CGROUP_STAT_KSWAPD_MAY_WRITEPAGE,
>> =A0 =A0 =A0 MEM_CGROUP_STAT_DATA, /* end of data requires synchronizatio=
n */
>> =A0 =A0 =A0 /* incremented at every =A0pagein/pageout */
>> =A0 =A0 =A0 MEM_CGROUP_EVENTS =3D MEM_CGROUP_STAT_DATA,
>> @@ -619,6 +634,62 @@ static void mem_cgroup_swap_statistics(struct mem_c=
group *mem,
>> =A0 =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val)=
;
>> =A0}
>>
>> +void mem_cgroup_kswapd_steal(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAPD_STEAL], v=
al);
>> +}
>> +
>> +void mem_cgroup_pg_steal(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_PG_PGSTEAL], val=
);
>> +}
>> +
>> +void mem_cgroup_kswapd_pgscan(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAPD_PGSCAN], =
val);
>> +}
>> +
>> +void mem_cgroup_pg_pgscan(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_PG_PGSCAN], val)=
;
>> +}
>> +
>> +void mem_cgroup_pgrefill(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_PGREFILL], val);
>> +}
>> +
>> +void mem_cgroup_pg_outrun(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_PGOUTRUN], val);
>> +}
>> +
>> +void mem_cgroup_alloc_stall(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_ALLOCSTALL], val=
);
>> +}
>> +
>> +void mem_cgroup_balance_wmark_ok(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_BALANCE_WMARK_OK=
], val);
>> +}
>> +
>> +void mem_cgroup_balance_swap_max(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_BALANCE_SWAP_MAX=
], val);
>> +}
>> +
>> +void mem_cgroup_kswapd_shrink_zone(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAPD_SHRINK_ZO=
NE], val);
>> +}
>> +
>> +void mem_cgroup_kswapd_may_writepage(struct mem_cgroup *mem, int val)
>> +{
>> + =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAPD_MAY_WRITE=
PAGE],
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 val);
>> +}
>> +
>> =A0static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct page_cgroup *pc,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0bool charge)
>> @@ -2000,8 +2071,14 @@ static int __mem_cgroup_do_charge(struct mem_cgro=
up *mem, gfp_t gfp_mask,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_charge(&mem->res, csize,=
 CHARGE_WMARK_LOW,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 &fail_res);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(!ret)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->stat->cou=
nt[MEM_CGROUP_STAT_WMARK_LOW_OK],
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return CHARGE_OK;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->stat->cou=
nt[MEM_CGROUP_STAT_KSWAPD_INVOKE],
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_over_limit =3D mem_cgrou=
p_from_res_counter(fail_res,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_memcg_kswapd(mem_over_l=
imit);
>> @@ -3723,6 +3800,21 @@ enum {
>> =A0 =A0 =A0 MCS_PGPGIN,
>> =A0 =A0 =A0 MCS_PGPGOUT,
>> =A0 =A0 =A0 MCS_SWAP,
>> + =A0 =A0 MCS_KSWAPD_INVOKE,
>> + =A0 =A0 MCS_KSWAPD_STEAL,
>> + =A0 =A0 MCS_PG_PGSTEAL,
>> + =A0 =A0 MCS_KSWAPD_PGSCAN,
>> + =A0 =A0 MCS_PG_PGSCAN,
>> + =A0 =A0 MCS_PGREFILL,
>> + =A0 =A0 MCS_WMARK_LOW_OK,
>> + =A0 =A0 MCS_KSWAP_CREAT,
>> + =A0 =A0 MCS_PGOUTRUN,
>> + =A0 =A0 MCS_ALLOCSTALL,
>> + =A0 =A0 MCS_BALANCE_WMARK_OK,
>> + =A0 =A0 MCS_BALANCE_SWAP_MAX,
>> + =A0 =A0 MCS_WAITQUEUE,
>> + =A0 =A0 MCS_KSWAPD_SHRINK_ZONE,
>> + =A0 =A0 MCS_KSWAPD_MAY_WRITEPAGE,
>> =A0 =A0 =A0 MCS_INACTIVE_ANON,
>> =A0 =A0 =A0 MCS_ACTIVE_ANON,
>> =A0 =A0 =A0 MCS_INACTIVE_FILE,
>> @@ -3745,6 +3837,21 @@ struct {
>> =A0 =A0 =A0 {"pgpgin", "total_pgpgin"},
>> =A0 =A0 =A0 {"pgpgout", "total_pgpgout"},
>> =A0 =A0 =A0 {"swap", "total_swap"},
>> + =A0 =A0 {"kswapd_invoke", "total_kswapd_invoke"},
>> + =A0 =A0 {"kswapd_steal", "total_kswapd_steal"},
>> + =A0 =A0 {"pg_pgsteal", "total_pg_pgsteal"},
>> + =A0 =A0 {"kswapd_pgscan", "total_kswapd_pgscan"},
>> + =A0 =A0 {"pg_scan", "total_pg_scan"},
>> + =A0 =A0 {"pgrefill", "total_pgrefill"},
>> + =A0 =A0 {"wmark_low_ok", "total_wmark_low_ok"},
>> + =A0 =A0 {"kswapd_create", "total_kswapd_create"},
>> + =A0 =A0 {"pgoutrun", "total_pgoutrun"},
>> + =A0 =A0 {"allocstall", "total_allocstall"},
>> + =A0 =A0 {"balance_wmark_ok", "total_balance_wmark_ok"},
>> + =A0 =A0 {"balance_swap_max", "total_balance_swap_max"},
>> + =A0 =A0 {"waitqueue", "total_waitqueue"},
>> + =A0 =A0 {"kswapd_shrink_zone", "total_kswapd_shrink_zone"},
>> + =A0 =A0 {"kswapd_may_writepage", "total_kswapd_may_writepage"},
>> =A0 =A0 =A0 {"inactive_anon", "total_inactive_anon"},
>> =A0 =A0 =A0 {"active_anon", "total_active_anon"},
>> =A0 =A0 =A0 {"inactive_file", "total_inactive_file"},
>> @@ -3773,6 +3880,37 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem,=
 struct mcs_total_stat *s)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP=
_STAT_SWAPOUT);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->stat[MCS_SWAP] +=3D val * PAGE_SIZE;
>> =A0 =A0 =A0 }
>> + =A0 =A0 /* kswapd stat */
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_INVOK=
E);
>> + =A0 =A0 s->stat[MCS_KSWAPD_INVOKE] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_STEAL=
);
>> + =A0 =A0 s->stat[MCS_KSWAPD_STEAL] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PG_PGSTEAL);
>> + =A0 =A0 s->stat[MCS_PG_PGSTEAL] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_PGSCA=
N);
>> + =A0 =A0 s->stat[MCS_KSWAPD_PGSCAN] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PG_PGSCAN);
>> + =A0 =A0 s->stat[MCS_PG_PGSCAN] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGREFILL);
>> + =A0 =A0 s->stat[MCS_PGREFILL] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WMARK_LOW_OK=
);
>> + =A0 =A0 s->stat[MCS_WMARK_LOW_OK] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAP_CREAT)=
;
>> + =A0 =A0 s->stat[MCS_KSWAP_CREAT] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGOUTRUN);
>> + =A0 =A0 s->stat[MCS_PGOUTRUN] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_ALLOCSTALL);
>> + =A0 =A0 s->stat[MCS_ALLOCSTALL] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_BALANCE_WMAR=
K_OK);
>> + =A0 =A0 s->stat[MCS_BALANCE_WMARK_OK] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_BALANCE_SWAP=
_MAX);
>> + =A0 =A0 s->stat[MCS_BALANCE_SWAP_MAX] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WAITQUEUE);
>> + =A0 =A0 s->stat[MCS_WAITQUEUE] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_SHRIN=
K_ZONE);
>> + =A0 =A0 s->stat[MCS_KSWAPD_SHRINK_ZONE] +=3D val;
>> + =A0 =A0 val =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_MAY_W=
RITEPAGE);
>> + =A0 =A0 s->stat[MCS_KSWAPD_MAY_WRITEPAGE] +=3D val;
>>
>> =A0 =A0 =A0 /* per zone stat */
>> =A0 =A0 =A0 val =3D mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON=
);
>> @@ -4579,9 +4717,11 @@ void wake_memcg_kswapd(struct mem_cgroup *mem)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kswapd_p->kswapd_task =3D th=
r;
>> + =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_=
KSWAP_CREAT], 1);
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 if (!waitqueue_active(wait)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_=
WAITQUEUE], 1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 wake_up_interruptible(wait);
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index f8430c4..5b0c349 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1389,10 +1389,15 @@ shrink_inactive_list(unsigned long nr_to_scan, s=
truct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 ISOLATE_INACTIVE : ISOLATE_BOTH,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, sc->mem_cgroup,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, file);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zo=
ne, nr_scanned);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track =
of
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_kswapd_pgscan(sc->m=
em_cgroup, nr_scanned);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_pg_pgscan(sc->mem_c=
group, nr_scanned);
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 if (nr_taken =3D=3D 0) {
>> @@ -1413,9 +1418,16 @@ shrink_inactive_list(unsigned long nr_to_scan, st=
ruct zone *zone,
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 local_irq_disable();
>> - =A0 =A0 if (current_is_kswapd())
>> - =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_events(KSWAPD_STEAL, nr_reclaimed);
>> - =A0 =A0 __count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
>> + =A0 =A0 if (scanning_global_lru(sc)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __count_vm_events(KSWAPD_STEAL=
, nr_reclaimed);
>> + =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGSTEAL, zone, nr_recla=
imed);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (current_is_kswapd())
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_kswapd_steal(sc->me=
m_cgroup, nr_reclaimed);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_pg_steal(sc->mem_cg=
roup, nr_reclaimed);
>> + =A0 =A0 }
>>
>> =A0 =A0 =A0 putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
>>
>> @@ -1508,11 +1520,16 @@ static void shrink_active_list(unsigned long nr_=
pages, struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps track =
of
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zo=
ne, pgscanned);
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 reclaim_stat->recent_scanned[file] +=3D nr_taken;
>>
>> - =A0 =A0 __count_zone_vm_events(PGREFILL, zone, pgscanned);
>> + =A0 =A0 if (scanning_global_lru(sc))
>> + =A0 =A0 =A0 =A0 =A0 =A0 __count_zone_vm_events(PGREFILL, zone, pgscann=
ed);
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_pgrefill(sc->mem_cgroup, pgscanned)=
;
>> +
>> =A0 =A0 =A0 if (file)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mod_zone_page_state(zone, NR_ACTIVE_FILE, =
-nr_taken);
>> =A0 =A0 =A0 else
>> @@ -1955,6 +1972,8 @@ static unsigned long do_try_to_free_pages(struct z=
onelist *zonelist,
>>
>> =A0 =A0 =A0 if (scanning_global_lru(sc))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_event(ALLOCSTALL);
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_alloc_stall(sc->mem_cgroup, 1);
>>
>> =A0 =A0 =A0 for (priority =3D DEF_PRIORITY; priority >=3D 0; priority--)=
 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D 0;
>> @@ -2444,6 +2463,8 @@ scan:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority !=3D DEF_PRIORITY)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_kswapd_shrink_zone(mem_cont, 1);
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_scanned =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc->nr_scanned;
>> @@ -2462,6 +2483,7 @@ scan:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned > sc->nr_reclaimed + s=
c->nr_reclaimed / 2) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->may_writepage =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_kswapd_may_writepag=
e(mem_cont, 1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 }
>>
>> @@ -2504,6 +2526,8 @@ loop_again:
>> =A0 =A0 =A0 sc.nr_reclaimed =3D 0;
>> =A0 =A0 =A0 total_scanned =3D 0;
>>
>> + =A0 =A0 mem_cgroup_pg_outrun(mem_cont, 1);
>> +
>> =A0 =A0 =A0 for (priority =3D DEF_PRIORITY; priority >=3D 0; priority--)=
 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;
>>
>> @@ -2544,6 +2568,7 @@ loop_again:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D=
 0;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wmark_ok) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_bal=
ance_wmark_ok(sc.mem_cgroup, 1);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> --
>> 1.7.3.1
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
