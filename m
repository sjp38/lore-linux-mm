Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 26C9A900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 00:27:10 -0400 (EDT)
Received: by iwg8 with SMTP id 8so5385266iwg.14
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 21:27:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1302909815-4362-8-git-send-email-yinghan@google.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-8-git-send-email-yinghan@google.com>
Date: Mon, 18 Apr 2011 13:27:08 +0900
Message-ID: <BANLkTincTDa3gvxiMeF6m0eGk=AcGzuQJw@mail.gmail.com>
Subject: Re: [PATCH V5 07/10] Add per-memcg zone "unreclaimable"
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> After reclaiming each node per memcg, it checks mem_cgroup_watermark_ok()
> and breaks the priority loop if it returns true. The per-memcg zone will
> be marked as "unreclaimable" if the scanning rate is much greater than th=
e
> reclaiming rate on the per-memcg LRU. The bit is cleared when there is a
> page charged to the memcg being freed. Kswapd breaks the priority loop if
> all the zones are marked as "unreclaimable".
>
> changelog v5..v4:
> 1. reduce the frequency of updating mz->unreclaimable bit by using the ex=
isting
> memcg batch in task struct.
> 2. add new function mem_cgroup_mz_clear_unreclaimable() for recoganizing =
zone.
>
> changelog v4..v3:
> 1. split off from the per-memcg background reclaim patch in V3.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0include/linux/memcontrol.h | =C2=A0 40 ++++++++++++++
> =C2=A0include/linux/sched.h =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
> =C2=A0include/linux/swap.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A013=
0 +++++++++++++++++++++++++++++++++++++++++++-
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
| =C2=A0 19 +++++++
> =C2=A05 files changed, 191 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d4ff7f2..b18435d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -155,6 +155,14 @@ static inline void mem_cgroup_dec_page_stat(struct p=
age *page,
> =C2=A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int =
order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0gfp_t gfp_mask);
> =C2=A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
> +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zi=
d);
> +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zo=
ne);
> +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone=
 *zone);
> +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page =
*page);
> +void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone =
*zone);
> +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zo=
ne,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned lon=
g nr_scanned);
>
> =C2=A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> =C2=A0void mem_cgroup_split_huge_fixup(struct page *head, struct page *ta=
il);
> @@ -345,6 +353,38 @@ static inline void mem_cgroup_dec_page_stat(struct p=
age *page,
> =C2=A0{
> =C2=A0}
>
> +static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, i=
nt nid,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 i=
nt zid)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return false;
> +}
> +
> +static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 struct zone *zone)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return false;
> +}
> +
> +static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *me=
m,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone)
> +{
> +}
> +
> +static inline void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem=
,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page)
> +{
> +}
> +
> +static inline void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *=
mem,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone);
> +{
> +}
> +static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 struct zone *zone,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 unsigned long nr_scanned)
> +{
> +}
> +
> =C2=A0static inline
> =C2=A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int =
order,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0gfp_t gfp_mask)
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 98fc7ed..3370c5a 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1526,6 +1526,7 @@ struct task_struct {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup =
*memcg; /* target memcg of uncharge */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_p=
ages; /* uncharged usage */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long mems=
w_nr_pages; /* uncharged mem+swap usage */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct zone *zone; /* =
a zone page is last uncharged */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} memcg_batch;
> =C2=A0#endif
> =C2=A0};
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 17e0511..319b800 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -160,6 +160,8 @@ enum {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0SWP_SCANNING =C2=A0 =C2=A0=3D (1 << 8), =C2=A0=
 =C2=A0 /* refcount in scan_swap_map */
> =C2=A0};
>
> +#define ZONE_RECLAIMABLE_RATE 6
> +

You can use ZONE_RECLAIMABLE_RATE in zone_reclaimable, too.
If you want to separate rate of memcg and global, please clear macro
name like ZONE_MEMCG_RECLAIMABLE_RATE.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
