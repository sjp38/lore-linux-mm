Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D78186B0078
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 17:56:12 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p52LtwOm018875
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 14:55:58 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by kpbe12.cbf.corp.google.com with ESMTP id p52LqUqZ019917
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 14:55:57 -0700
Received: by qyk7 with SMTP id 7so754087qyk.17
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 14:55:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306909519-7286-5-git-send-email-hannes@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-5-git-send-email-hannes@cmpxchg.org>
Date: Thu, 2 Jun 2011 14:55:56 -0700
Message-ID: <BANLkTim5TSWpBfeF2dugGZwQmNC-Cf+GCNctraq8FtziJxsd2g@mail.gmail.com>
Subject: Re: [patch 4/8] memcg: rework soft limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.org> wrot=
e:
> Currently, soft limit reclaim is entered from kswapd, where it selects
> the memcg with the biggest soft limit excess in absolute bytes, and
> reclaims pages from it with maximum aggressiveness (priority 0).
>
> This has the following disadvantages:
>
> =A0 =A01. because of the aggressiveness, kswapd can be stalled on a memcg
> =A0 =A0that is hard to reclaim from for a long time, sending the rest of
> =A0 =A0the allocators into direct reclaim in the meantime.
>
> =A0 =A02. it only considers the biggest offender (in absolute bytes, no
> =A0 =A0less, so very unhandy for setups with different-sized memcgs) and
> =A0 =A0does not apply any pressure at all on other memcgs in excess.
>
> =A0 =A03. because it is only invoked from kswapd, the soft limit is
> =A0 =A0meaningful during global memory pressure, but it is not taken into
> =A0 =A0account during hierarchical target reclaim where it could allow
> =A0 =A0prioritizing memcgs as well. =A0So while it does hierarchical
> =A0 =A0reclaim once triggered, it is not a truly hierarchical mechanism.
>
> Here is a different approach. =A0Instead of having a soft limit reclaim
> cycle separate from the rest of reclaim, this patch ensures that each
> time a group of memcgs is reclaimed - be it because of global memory
> pressure or because of a hard limit - memcgs that exceed their soft
> limit, or contribute to the soft limit excess of one their parents,
> are reclaimed from at a higher priority than their siblings.
>
> This results in the following:
>
> =A0 =A01. all relevant memcgs are scanned with increasing priority during
> =A0 =A0memory pressure. =A0The primary goal is to free pages, not to puni=
sh
> =A0 =A0soft limit offenders.
>
> =A0 =A02. increased pressure is applied to all memcgs in excess of their
> =A0 =A0soft limit, not only the biggest offender.
>
> =A0 =A03. the soft limit becomes meaningful for target reclaim as well,
> =A0 =A0where it allows prioritizing children of a hierarchy when the
> =A0 =A0parent hits its limit.
>
> =A0 =A04. direct reclaim now also applies increased soft limit pressure,
> =A0 =A0not just kswapd anymore.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0include/linux/memcontrol.h | =A0 =A07 +++++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 26 ++++++++++++++++++++++=
++++
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A08 ++++++--
> =A03 files changed, 39 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 8f402b9..7d99e87 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -104,6 +104,7 @@ extern void mem_cgroup_end_migration(struct mem_cgrou=
p *mem,
> =A0struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 struct mem_cgroup *);
> =A0void mem_cgroup_stop_hierarchy_walk(struct mem_cgroup *, struct mem_cg=
roup *);
> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *, struct mem_cgro=
up *);
>
> =A0/*
> =A0* For memory reclaim.
> @@ -345,6 +346,12 @@ static inline void mem_cgroup_stop_hierarchy_walk(st=
ruct mem_cgroup *r,
> =A0{
> =A0}
>
> +static inline bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *roo=
t,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 return false;
> +}
> +
> =A0static inline void
> =A0mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct=
 *p)
> =A0{
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 983efe4..94f77cc3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1460,6 +1460,32 @@ void mem_cgroup_stop_hierarchy_walk(struct mem_cgr=
oup *root,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&mem->css);
> =A0}
>
> +/**
> + * mem_cgroup_soft_limit_exceeded - check if a memcg (hierarchically)
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ex=
ceeds a soft limit
> + * @root: highest ancestor of @mem to consider
> + * @mem: memcg to check for excess
> + *
> + * The function indicates whether @mem has exceeded its own soft
> + * limit, or contributes to the soft limit excess of one of its
> + * parents in the hierarchy below @root.
> + */
> +bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *root,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 str=
uct mem_cgroup *mem)
> +{
> + =A0 =A0 =A0 for (;;) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem =3D=3D root_mem_cgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res_counter_soft_limit_excess(&mem->res=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem =3D=3D root)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D parent_mem_cgroup(mem);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 }
> +}
> +
> =A0static unsigned long mem_cgroup_reclaim(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_t gfp_mask,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0unsigned long flags)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c7d4b44..0163840 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1988,9 +1988,13 @@ static void shrink_zone(int priority, struct zone =
*zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long reclaimed =3D sc->nr_reclaim=
ed;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long scanned =3D sc->nr_scanned;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_reclaimed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int epriority =3D priority;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_exceeded(root, me=
m))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority -=3D 1;

Here we grant the ability to shrink from all the memcgs, but only
higher the priority for those exceed the soft_limit. That is a design
change
for the "soft_limit" which giving a hint to which memcgs to reclaim
from first under global memory pressure.

--Ying


>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->mem_cgroup =3D mem;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_shrink_zone(priority, zone, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_shrink_zone(epriority, zone, sc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_count_reclaim(mem, current_is_k=
swapd(),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 mem !=3D root, /* limit or hierarchy? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 sc->nr_scanned - scanned,
> @@ -2480,7 +2484,7 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Call soft limit reclaim=
 before calling shrink_zone.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * For now we ignore the r=
eturn value
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_limit_recla=
im(zone, order, sc.gfp_mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 //mem_cgroup_soft_limit_rec=
laim(zone, order, sc.gfp_mask);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We put equal pressure o=
n every zone, unless
> --
> 1.7.5.2
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
