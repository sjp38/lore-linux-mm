Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4F24E6B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 13:20:09 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p7VHK5Hk031723
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 10:20:05 -0700
Received: from qyk15 (qyk15.prod.google.com [10.241.83.143])
	by wpaz13.hot.corp.google.com with ESMTP id p7VHJxQA007988
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 10:20:03 -0700
Received: by qyk15 with SMTP id 15so2549221qyk.5
        for <linux-mm@kvack.org>; Wed, 31 Aug 2011 10:19:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110831090850.GA27345@redhat.com>
References: <20110831090850.GA27345@redhat.com>
Date: Wed, 31 Aug 2011 10:19:57 -0700
Message-ID: <CALWz4iwyQ=tLnjx5=KH5kjgJbcjfNVyxS97V0KzXZUenrLAcnA@mail.gmail.com>
Subject: Re: [patch] memcg: skip scanning active lists based on individual size
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 31, 2011 at 2:08 AM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> Reclaim decides to skip scanning an active list when the corresponding
> inactive list is above a certain size in comparison to leave the
> assumed working set alone while there are still enough reclaim
> candidates around.
>
> The memcg implementation of comparing those lists instead reports
> whether the whole memcg is low on the requested type of inactive
> pages, considering all nodes and zones.
>
> This can lead to an oversized active list not being scanned because of
> the state of the other lists in the memcg, as well as an active list
> being scanned while its corresponding inactive list has enough pages.
>
> Not only is this wrong, it's also a scalability hazard, because the
> global memory state over all nodes and zones has to be gathered for
> each memcg and zone scanned.
>
> Make these calculations purely based on the size of the two LRU lists
> that are actually affected by the outcome of the decision.
>
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <bsingharora@gmail.com>
> ---
> =A0include/linux/memcontrol.h | =A0 10 +++++---
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 51 ++++++++++++++--------=
---------------------
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A03 files changed, 25 insertions(+), 40 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 343bd76..cbb45ce 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -105,8 +105,10 @@ extern void mem_cgroup_end_migration(struct mem_cgro=
up *mem,
> =A0/*
> =A0* For memory reclaim.
> =A0*/
> -int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> -int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> +int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct zone *zone);
> +int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct zone *zone);
> =A0int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> =A0unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0int nid, int zid, unsigned int lrumask);
> @@ -292,13 +294,13 @@ static inline bool mem_cgroup_disabled(void)
> =A0}
>
> =A0static inline int
> -mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
> +mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zone *z=
one)
> =A0{
> =A0 =A0 =A0 =A0return 1;
> =A0}
>
> =A0static inline int
> -mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
> +mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zone *z=
one)
> =A0{
> =A0 =A0 =A0 =A0return 1;
> =A0}
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3508777..d63dfb2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1101,15 +1101,19 @@ int task_in_mem_cgroup(struct task_struct *task, =
const struct mem_cgroup *mem)
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *=
present_pages)
> +int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg, struct zon=
e *zone)
> =A0{
> - =A0 =A0 =A0 unsigned long active;
> + =A0 =A0 =A0 unsigned long inactive_ratio;
> + =A0 =A0 =A0 int nid =3D zone_to_nid(zone);
> + =A0 =A0 =A0 int zid =3D zone_idx(zone);
> =A0 =A0 =A0 =A0unsigned long inactive;
> + =A0 =A0 =A0 unsigned long active;
> =A0 =A0 =A0 =A0unsigned long gb;
> - =A0 =A0 =A0 unsigned long inactive_ratio;
>
> - =A0 =A0 =A0 inactive =3D mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIV=
E_ANON));
> - =A0 =A0 =A0 active =3D mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_AN=
ON));
> + =A0 =A0 =A0 inactive =3D mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 BIT(LRU_INACTIVE_ANON));
> + =A0 =A0 =A0 active =3D mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 BIT(LRU_ACTIVE_ANON));
>
> =A0 =A0 =A0 =A0gb =3D (inactive + active) >> (30 - PAGE_SHIFT);
> =A0 =A0 =A0 =A0if (gb)
> @@ -1117,39 +1121,20 @@ static int calc_inactive_ratio(struct mem_cgroup =
*memcg, unsigned long *present_
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inactive_ratio =3D 1;
>
> - =A0 =A0 =A0 if (present_pages) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 present_pages[0] =3D inactive;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 present_pages[1] =3D active;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 return inactive_ratio;
> + =A0 =A0 =A0 return inactive * inactive_ratio < active;
> =A0}
>
> -int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
> -{
> - =A0 =A0 =A0 unsigned long active;
> - =A0 =A0 =A0 unsigned long inactive;
> - =A0 =A0 =A0 unsigned long present_pages[2];
> - =A0 =A0 =A0 unsigned long inactive_ratio;
> -
> - =A0 =A0 =A0 inactive_ratio =3D calc_inactive_ratio(memcg, present_pages=
);
> -
> - =A0 =A0 =A0 inactive =3D present_pages[0];
> - =A0 =A0 =A0 active =3D present_pages[1];
> -
> - =A0 =A0 =A0 if (inactive * inactive_ratio < active)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> -
> - =A0 =A0 =A0 return 0;
> -}
> -
> -int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
> +int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg, struct zon=
e *zone)
> =A0{
> =A0 =A0 =A0 =A0unsigned long active;
> =A0 =A0 =A0 =A0unsigned long inactive;
> + =A0 =A0 =A0 int zid =3D zone_idx(zone);
> + =A0 =A0 =A0 int nid =3D zone_to_nid(zone);
>
> - =A0 =A0 =A0 inactive =3D mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIV=
E_FILE));
> - =A0 =A0 =A0 active =3D mem_cgroup_nr_lru_pages(memcg, BIT(LRU_ACTIVE_FI=
LE));
> + =A0 =A0 =A0 inactive =3D mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 BIT(LRU_INACTIVE_FILE));
> + =A0 =A0 =A0 active =3D mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 BIT(LRU_ACTIVE_FILE));
>
> =A0 =A0 =A0 =A0return (active > inactive);
> =A0}
> @@ -4188,8 +4173,6 @@ static int mem_control_stat_show(struct cgroup *con=
t, struct cftype *cft,
> =A0 =A0 =A0 =A0}
>
> =A0#ifdef CONFIG_DEBUG_VM
> - =A0 =A0 =A0 cb->fill(cb, "inactive_ratio", calc_inactive_ratio(mem_cont=
, NULL));
> -
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int nid, zid;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6588746..a023778 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1699,7 +1699,7 @@ static int inactive_anon_is_low(struct zone *zone, =
struct scan_control *sc)
> =A0 =A0 =A0 =A0if (scanning_global_lru(sc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0low =3D inactive_anon_is_low_global(zone);
> =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 low =3D mem_cgroup_inactive_anon_is_low(sc-=
>mem_cgroup);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 low =3D mem_cgroup_inactive_anon_is_low(sc-=
>mem_cgroup, zone);
> =A0 =A0 =A0 =A0return low;
> =A0}
> =A0#else
> @@ -1742,7 +1742,7 @@ static int inactive_file_is_low(struct zone *zone, =
struct scan_control *sc)
> =A0 =A0 =A0 =A0if (scanning_global_lru(sc))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0low =3D inactive_file_is_low_global(zone);
> =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 low =3D mem_cgroup_inactive_file_is_low(sc-=
>mem_cgroup);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 low =3D mem_cgroup_inactive_file_is_low(sc-=
>mem_cgroup, zone);
> =A0 =A0 =A0 =A0return low;
> =A0}
>
> --
> 1.7.6
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

Reviewed-by: Ying Han <yinghan@google.com>

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
