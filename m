Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB4F5900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 15:33:56 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4CJXroZ019193
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:33:53 -0700
Received: from qwj9 (qwj9.prod.google.com [10.241.195.73])
	by hpaq3.eem.corp.google.com with ESMTP id p4CJXJun028342
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:33:52 -0700
Received: by qwj9 with SMTP id 9so1380962qwj.21
        for <linux-mm@kvack.org>; Thu, 12 May 2011 12:33:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305212038-15445-5-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-5-git-send-email-hannes@cmpxchg.org>
Date: Thu, 12 May 2011 12:33:50 -0700
Message-ID: <BANLkTi=yCyAsOc_uTQLp1kWp5w0i9gomxg@mail.gmail.com>
Subject: Re: [rfc patch 4/6] memcg: reclaim statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefdaca660a04a31944f4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--0016e64aefdaca660a04a31944f4
Content-Type: text/plain; charset=ISO-8859-1

On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> TODO: write proper changelog.  Here is an excerpt from
> http://lkml.kernel.org/r/20110428123652.GM12437@cmpxchg.org:
>
> : 1. Limit-triggered direct reclaim
> :
> : The memory cgroup hits its limit and the task does direct reclaim from
> : its own memcg.  We probably want statistics for this separately from
> : background reclaim to see how successful background reclaim is, the
> : same reason we have this separation in the global vmstat as well.
> :
> :       pgscan_direct_limit
> :       pgfree_direct_limit
>

Can we use "pgsteal_" instead? Not big fan of the naming but want to make
them consistent to other stats.

> :
> : 2. Limit-triggered background reclaim
> :
> : This is the watermark-based asynchroneous reclaim that is currently in
> : discussion.  It's triggered by the memcg breaching its watermark,
> : which is relative to its hard-limit.  I named it kswapd because I
> : still think kswapd should do this job, but it is all open for
> : discussion, obviously.  Treat it as meaning 'background' or
> : 'asynchroneous'.
> :
> :       pgscan_kswapd_limit
> :       pgfree_kswapd_limit
>

Kame might have this stats on the per-memcg bg reclaim patch. Just mention
here since it will make later merge
a bit harder

> :
> : 3. Hierarchy-triggered direct reclaim
> :
> : A condition outside the memcg leads to a task directly reclaiming from
> : this memcg.  This could be global memory pressure for example, but
> : also a parent cgroup hitting its limit.  It's probably helpful to
> : assume global memory pressure meaning that the root cgroup hit its
> : limit, conceptually.  We don't have that yet, but this could be the
> : direct softlimit reclaim Ying mentioned above.
> :
> :       pgscan_direct_hierarchy
> :       pgsteal_direct_hierarchy
>

 The stats for soft_limit reclaim from global ttfp have been merged in mmotm
i believe as the following:

"soft_direct_steal"
"soft_direct_scan"

I wonder we might want to separate that out from the other case where the
reclaim is from the parent triggers its limit.

> :
> : 4. Hierarchy-triggered background reclaim
> :
> : An outside condition leads to kswapd reclaiming from this memcg, like
> : kswapd doing softlimit pushback due to global memory pressure.
> :
> :       pgscan_kswapd_hierarchy
> :       pgsteal_kswapd_hierarchy
>

The stats for soft_limit reclaim from global bg reclaim have been merged in
mmotm I believe as the following:
"soft_kswapd_steal"
"soft_kswapd_scan"

 --Ying

> :
> : ---
> :
> : With these stats in place, you can see how much pressure there is on
> : your memcg hierarchy.  This includes machine utilization and if you
> : overcommitted too much on a global level if there is a lot of reclaim
> : activity indicated in the hierarchical stats.
> :
> : With the limit-based stats, you can see the amount of internal
> : pressure of memcgs, which shows you if you overcommitted on a local
> : level.
> :
> : And for both cases, you can also see the effectiveness of background
> : reclaim by comparing the direct and the kswapd stats.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |    9 ++++++
>  mm/memcontrol.c            |   63
> ++++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                |    7 +++++
>  3 files changed, 79 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 58728c7..a4c84db 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -105,6 +105,8 @@ extern void mem_cgroup_end_migration(struct mem_cgroup
> *mem,
>  * For memory reclaim.
>  */
>  void mem_cgroup_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup **);
> +void mem_cgroup_count_reclaim(struct mem_cgroup *, bool, bool,
> +                             unsigned long, unsigned long);
>  int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>  int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
>  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> @@ -296,6 +298,13 @@ static inline void mem_cgroup_hierarchy_walk(struct
> mem_cgroup *start,
>        *iter = start;
>  }
>
> +static inline void mem_cgroup_count_reclaim(struct mem_cgroup *mem,
> +                                           bool kswapd, bool hierarchy,
> +                                           unsigned long scanned,
> +                                           unsigned long reclaimed)
> +{
> +}
> +
>  static inline int
>  mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index edcd55a..d762706 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -90,10 +90,24 @@ enum mem_cgroup_stat_index {
>        MEM_CGROUP_STAT_NSTATS,
>  };
>
> +#define RECLAIM_RECLAIMED 1
> +#define RECLAIM_HIERARCHY 2
> +#define RECLAIM_KSWAPD 4
> +
>  enum mem_cgroup_events_index {
>        MEM_CGROUP_EVENTS_PGPGIN,       /* # of pages paged in */
>        MEM_CGROUP_EVENTS_PGPGOUT,      /* # of pages paged out */
>        MEM_CGROUP_EVENTS_COUNT,        /* # of pages paged in/out */
> +       RECLAIM_BASE,
> +       PGSCAN_DIRECT_LIMIT = RECLAIM_BASE,
> +       PGFREE_DIRECT_LIMIT = RECLAIM_BASE + RECLAIM_RECLAIMED,
> +       PGSCAN_DIRECT_HIERARCHY = RECLAIM_BASE + RECLAIM_HIERARCHY,
> +       PGSTEAL_DIRECT_HIERARCHY = RECLAIM_BASE + RECLAIM_HIERARCHY +
> RECLAIM_RECLAIMED,
> +       /* you know the drill... */
> +       PGSCAN_KSWAPD_LIMIT,
> +       PGFREE_KSWAPD_LIMIT,
> +       PGSCAN_KSWAPD_HIERARCHY,
> +       PGSTEAL_KSWAPD_HIERARCHY,
>        MEM_CGROUP_EVENTS_NSTATS,
>  };
>  /*
> @@ -575,6 +589,23 @@ static void mem_cgroup_swap_statistics(struct
> mem_cgroup *mem,
>        this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
>  }
>
> +void mem_cgroup_count_reclaim(struct mem_cgroup *mem,
> +                             bool kswapd, bool hierarchy,
> +                             unsigned long scanned, unsigned long
> reclaimed)
> +{
> +       unsigned int base = RECLAIM_BASE;
> +
> +       if (!mem)
> +               mem = root_mem_cgroup;
> +       if (kswapd)
> +               base += RECLAIM_KSWAPD;
> +       if (hierarchy)
> +               base += RECLAIM_HIERARCHY;
> +
> +       this_cpu_add(mem->stat->events[base], scanned);
> +       this_cpu_add(mem->stat->events[base + RECLAIM_RECLAIMED],
> reclaimed);
> +}
> +
>  static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
>                                            enum mem_cgroup_events_index
> idx)
>  {
> @@ -3817,6 +3848,14 @@ enum {
>        MCS_FILE_MAPPED,
>        MCS_PGPGIN,
>        MCS_PGPGOUT,
> +       MCS_PGSCAN_DIRECT_LIMIT,
> +       MCS_PGFREE_DIRECT_LIMIT,
> +       MCS_PGSCAN_DIRECT_HIERARCHY,
> +       MCS_PGSTEAL_DIRECT_HIERARCHY,
> +       MCS_PGSCAN_KSWAPD_LIMIT,
> +       MCS_PGFREE_KSWAPD_LIMIT,
> +       MCS_PGSCAN_KSWAPD_HIERARCHY,
> +       MCS_PGSTEAL_KSWAPD_HIERARCHY,
>        MCS_SWAP,
>        MCS_INACTIVE_ANON,
>        MCS_ACTIVE_ANON,
> @@ -3839,6 +3878,14 @@ struct {
>        {"mapped_file", "total_mapped_file"},
>        {"pgpgin", "total_pgpgin"},
>        {"pgpgout", "total_pgpgout"},
> +       {"pgscan_direct_limit", "total_pgscan_direct_limit"},
> +       {"pgfree_direct_limit", "total_pgfree_direct_limit"},
> +       {"pgscan_direct_hierarchy", "total_pgscan_direct_hierarchy"},
> +       {"pgsteal_direct_hierarchy", "total_pgsteal_direct_hierarchy"},
> +       {"pgscan_kswapd_limit", "total_pgscan_kswapd_limit"},
> +       {"pgfree_kswapd_limit", "total_pgfree_kswapd_limit"},
> +       {"pgscan_kswapd_hierarchy", "total_pgscan_kswapd_hierarchy"},
> +       {"pgsteal_kswapd_hierarchy", "total_pgsteal_kswapd_hierarchy"},
>        {"swap", "total_swap"},
>        {"inactive_anon", "total_inactive_anon"},
>        {"active_anon", "total_active_anon"},
> @@ -3864,6 +3911,22 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem,
> struct mcs_total_stat *s)
>        s->stat[MCS_PGPGIN] += val;
>        val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGPGOUT);
>        s->stat[MCS_PGPGOUT] += val;
> +       val = mem_cgroup_read_events(mem, PGSCAN_DIRECT_LIMIT);
> +       s->stat[MCS_PGSCAN_DIRECT_LIMIT] += val;
> +       val = mem_cgroup_read_events(mem, PGFREE_DIRECT_LIMIT);
> +       s->stat[MCS_PGFREE_DIRECT_LIMIT] += val;
> +       val = mem_cgroup_read_events(mem, PGSCAN_DIRECT_HIERARCHY);
> +       s->stat[MCS_PGSCAN_DIRECT_HIERARCHY] += val;
> +       val = mem_cgroup_read_events(mem, PGSTEAL_DIRECT_HIERARCHY);
> +       s->stat[MCS_PGSTEAL_DIRECT_HIERARCHY] += val;
> +       val = mem_cgroup_read_events(mem, PGSCAN_KSWAPD_LIMIT);
> +       s->stat[MCS_PGSCAN_KSWAPD_LIMIT] += val;
> +       val = mem_cgroup_read_events(mem, PGFREE_KSWAPD_LIMIT);
> +       s->stat[MCS_PGFREE_KSWAPD_LIMIT] += val;
> +       val = mem_cgroup_read_events(mem, PGSCAN_KSWAPD_HIERARCHY);
> +       s->stat[MCS_PGSCAN_KSWAPD_HIERARCHY] += val;
> +       val = mem_cgroup_read_events(mem, PGSTEAL_KSWAPD_HIERARCHY);
> +       s->stat[MCS_PGSTEAL_KSWAPD_HIERARCHY] += val;
>        if (do_swap_account) {
>                val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
>                s->stat[MCS_SWAP] += val * PAGE_SIZE;
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e2a3647..0e45ceb 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1961,9 +1961,16 @@ static void shrink_zone(int priority, struct zone
> *zone,
>        struct mem_cgroup *mem = NULL;
>
>        do {
> +               unsigned long reclaimed = sc->nr_reclaimed;
> +               unsigned long scanned = sc->nr_scanned;
> +
>                mem_cgroup_hierarchy_walk(root, &mem);
>                sc->current_memcg = mem;
>                do_shrink_zone(priority, zone, sc);
> +               mem_cgroup_count_reclaim(mem, current_is_kswapd(),
> +                                        mem != root, /* limit or
> hierarchy? */
> +                                        sc->nr_scanned - scanned,
> +                                        sc->nr_reclaimed - reclaimed);
>        } while (mem != root);
>
>        /* For good measure, noone higher up the stack should look at it */
> --
> 1.7.5.1
>
>

--0016e64aefdaca660a04a31944f4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, May 12, 2011 at 7:53 AM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
TODO: write proper changelog. =A0Here is an excerpt from<br>
<a href=3D"http://lkml.kernel.org/r/20110428123652.GM12437@cmpxchg.org" tar=
get=3D"_blank">http://lkml.kernel.org/r/20110428123652.GM12437@cmpxchg.org<=
/a>:<br>
<br>
: 1. Limit-triggered direct reclaim<br>
:<br>
: The memory cgroup hits its limit and the task does direct reclaim from<br=
>
: its own memcg. =A0We probably want statistics for this separately from<br=
>
: background reclaim to see how successful background reclaim is, the<br>
: same reason we have this separation in the global vmstat as well.<br>
:<br>
: =A0 =A0 =A0 pgscan_direct_limit<br>
: =A0 =A0 =A0 pgfree_direct_limit<br></blockquote><div><br></div><div>Can w=
e use &quot;pgsteal_&quot; instead? Not big fan of the naming but want to m=
ake them=A0consistent to other stats.=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">

:<br>
: 2. Limit-triggered background reclaim<br>
:<br>
: This is the watermark-based asynchroneous reclaim that is currently in<br=
>
: discussion. =A0It&#39;s triggered by the memcg breaching its watermark,<b=
r>
: which is relative to its hard-limit. =A0I named it kswapd because I<br>
: still think kswapd should do this job, but it is all open for<br>
: discussion, obviously. =A0Treat it as meaning &#39;background&#39; or<br>
: &#39;asynchroneous&#39;.<br>
:<br>
: =A0 =A0 =A0 pgscan_kswapd_limit<br>
: =A0 =A0 =A0 pgfree_kswapd_limit<br></blockquote><div>=A0</div><div>Kame m=
ight have this stats on the per-memcg bg reclaim patch. Just mention here s=
ince it will make later merge</div><div>a bit harder=A0</div><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;p=
adding-left:1ex;">

:<br>
: 3. Hierarchy-triggered direct reclaim<br>
:<br>
: A condition outside the memcg leads to a task directly reclaiming from<br=
>
: this memcg. =A0This could be global memory pressure for example, but<br>
: also a parent cgroup hitting its limit. =A0It&#39;s probably helpful to<b=
r>
: assume global memory pressure meaning that the root cgroup hit its<br>
: limit, conceptually. =A0We don&#39;t have that yet, but this could be the=
<br>
: direct softlimit reclaim Ying mentioned above.<br>
:<br>
: =A0 =A0 =A0 pgscan_direct_hierarchy<br>
: =A0 =A0 =A0 pgsteal_direct_hierarchy<br></blockquote><div><br></div><div>=
=A0The stats for soft_limit reclaim from global ttfp have been merged in mm=
otm i believe as the following:</div><div><br></div><div>&quot;soft_direct_=
steal&quot;</div>
<div>&quot;soft_direct_scan&quot;</div><div><br></div><div>I wonder we migh=
t want to=A0separate=A0that out from the other case where the reclaim is fr=
om the parent triggers its limit.</div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

:<br>
: 4. Hierarchy-triggered background reclaim<br>
:<br>
: An outside condition leads to kswapd reclaiming from this memcg, like<br>
: kswapd doing softlimit pushback due to global memory pressure.<br>
:<br>
: =A0 =A0 =A0 pgscan_kswapd_hierarchy<br>
: =A0 =A0 =A0 pgsteal_kswapd_hierarchy<br></blockquote><div><br></div><div>=
The stats for soft_limit reclaim from global bg reclaim have been merged in=
 mmotm I believe as the following:</div><div>&quot;soft_kswapd_steal&quot;<=
/div>
<div>&quot;soft_kswapd_scan&quot;</div><div><br></div><div>=A0--Ying</div><=
blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px=
 #ccc solid;padding-left:1ex;">
:<br>
: ---<br>
:<br>
: With these stats in place, you can see how much pressure there is on<br>
: your memcg hierarchy. =A0This includes machine utilization and if you<br>
: overcommitted too much on a global level if there is a lot of reclaim<br>
: activity indicated in the hierarchical stats.<br>
:<br>
: With the limit-based stats, you can see the amount of internal<br>
: pressure of memcgs, which shows you if you overcommitted on a local<br>
: level.<br>
:<br>
: And for both cases, you can also see the effectiveness of background<br>
: reclaim by comparing the direct and the kswapd stats.<br>
<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">ha=
nnes@cmpxchg.org</a>&gt;<br>
---<br>
=A0include/linux/memcontrol.h | =A0 =A09 ++++++<br>
=A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 63 ++++++++++++++++++++++++=
++++++++++++++++++++<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A07 +++++<br>
=A03 files changed, 79 insertions(+), 0 deletions(-)<br>
<br>
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h<br>
index 58728c7..a4c84db 100644<br>
--- a/include/linux/memcontrol.h<br>
+++ b/include/linux/memcontrol.h<br>
@@ -105,6 +105,8 @@ extern void mem_cgroup_end_migration(struct mem_cgroup =
*mem,<br>
 =A0* For memory reclaim.<br>
 =A0*/<br>
=A0void mem_cgroup_hierarchy_walk(struct mem_cgroup *, struct mem_cgroup **=
);<br>
+void mem_cgroup_count_reclaim(struct mem_cgroup *, bool, bool,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long, un=
signed long);<br>
=A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);<br>
=A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);<br>
=A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,<br>
@@ -296,6 +298,13 @@ static inline void mem_cgroup_hierarchy_walk(struct me=
m_cgroup *start,<br>
 =A0 =A0 =A0 =A0*iter =3D start;<br>
=A0}<br>
<br>
+static inline void mem_cgroup_count_reclaim(struct mem_cgroup *mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 bool kswapd, bool hierarchy,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 unsigned long scanned,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 unsigned long reclaimed)<br>
+{<br>
+}<br>
+<br>
=A0static inline int<br>
=A0mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)<br>
=A0{<br>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
index edcd55a..d762706 100644<br>
--- a/mm/memcontrol.c<br>
+++ b/mm/memcontrol.c<br>
@@ -90,10 +90,24 @@ enum mem_cgroup_stat_index {<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_STAT_NSTATS,<br>
=A0};<br>
<br>
+#define RECLAIM_RECLAIMED 1<br>
+#define RECLAIM_HIERARCHY 2<br>
+#define RECLAIM_KSWAPD 4<br>
+<br>
=A0enum mem_cgroup_events_index {<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_PGPGIN, =A0 =A0 =A0 /* # of pages paged i=
n */<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_PGPGOUT, =A0 =A0 =A0/* # of pages paged o=
ut */<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_COUNT, =A0 =A0 =A0 =A0/* # of pages paged=
 in/out */<br>
+ =A0 =A0 =A0 RECLAIM_BASE,<br>
+ =A0 =A0 =A0 PGSCAN_DIRECT_LIMIT =3D RECLAIM_BASE,<br>
+ =A0 =A0 =A0 PGFREE_DIRECT_LIMIT =3D RECLAIM_BASE + RECLAIM_RECLAIMED,<br>
+ =A0 =A0 =A0 PGSCAN_DIRECT_HIERARCHY =3D RECLAIM_BASE + RECLAIM_HIERARCHY,=
<br>
+ =A0 =A0 =A0 PGSTEAL_DIRECT_HIERARCHY =3D RECLAIM_BASE + RECLAIM_HIERARCHY=
 + RECLAIM_RECLAIMED,<br>
+ =A0 =A0 =A0 /* you know the drill... */<br>
+ =A0 =A0 =A0 PGSCAN_KSWAPD_LIMIT,<br>
+ =A0 =A0 =A0 PGFREE_KSWAPD_LIMIT,<br>
+ =A0 =A0 =A0 PGSCAN_KSWAPD_HIERARCHY,<br>
+ =A0 =A0 =A0 PGSTEAL_KSWAPD_HIERARCHY,<br>
 =A0 =A0 =A0 =A0MEM_CGROUP_EVENTS_NSTATS,<br>
=A0};<br>
=A0/*<br>
@@ -575,6 +589,23 @@ static void mem_cgroup_swap_statistics(struct mem_cgro=
up *mem,<br>
 =A0 =A0 =A0 =A0this_cpu_add(mem-&gt;stat-&gt;count[MEM_CGROUP_STAT_SWAPOUT=
], val);<br>
=A0}<br>
<br>
+void mem_cgroup_count_reclaim(struct mem_cgroup *mem,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool kswapd, bool=
 hierarchy,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long sca=
nned, unsigned long reclaimed)<br>
+{<br>
+ =A0 =A0 =A0 unsigned int base =3D RECLAIM_BASE;<br>
+<br>
+ =A0 =A0 =A0 if (!mem)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D root_mem_cgroup;<br>
+ =A0 =A0 =A0 if (kswapd)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 base +=3D RECLAIM_KSWAPD;<br>
+ =A0 =A0 =A0 if (hierarchy)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 base +=3D RECLAIM_HIERARCHY;<br>
+<br>
+ =A0 =A0 =A0 this_cpu_add(mem-&gt;stat-&gt;events[base], scanned);<br>
+ =A0 =A0 =A0 this_cpu_add(mem-&gt;stat-&gt;events[base + RECLAIM_RECLAIMED=
], reclaimed);<br>
+}<br>
+<br>
=A0static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0enum mem_cgroup_events_index idx)<br>
=A0{<br>
@@ -3817,6 +3848,14 @@ enum {<br>
 =A0 =A0 =A0 =A0MCS_FILE_MAPPED,<br>
 =A0 =A0 =A0 =A0MCS_PGPGIN,<br>
 =A0 =A0 =A0 =A0MCS_PGPGOUT,<br>
+ =A0 =A0 =A0 MCS_PGSCAN_DIRECT_LIMIT,<br>
+ =A0 =A0 =A0 MCS_PGFREE_DIRECT_LIMIT,<br>
+ =A0 =A0 =A0 MCS_PGSCAN_DIRECT_HIERARCHY,<br>
+ =A0 =A0 =A0 MCS_PGSTEAL_DIRECT_HIERARCHY,<br>
+ =A0 =A0 =A0 MCS_PGSCAN_KSWAPD_LIMIT,<br>
+ =A0 =A0 =A0 MCS_PGFREE_KSWAPD_LIMIT,<br>
+ =A0 =A0 =A0 MCS_PGSCAN_KSWAPD_HIERARCHY,<br>
+ =A0 =A0 =A0 MCS_PGSTEAL_KSWAPD_HIERARCHY,<br>
 =A0 =A0 =A0 =A0MCS_SWAP,<br>
 =A0 =A0 =A0 =A0MCS_INACTIVE_ANON,<br>
 =A0 =A0 =A0 =A0MCS_ACTIVE_ANON,<br>
@@ -3839,6 +3878,14 @@ struct {<br>
 =A0 =A0 =A0 =A0{&quot;mapped_file&quot;, &quot;total_mapped_file&quot;},<b=
r>
 =A0 =A0 =A0 =A0{&quot;pgpgin&quot;, &quot;total_pgpgin&quot;},<br>
 =A0 =A0 =A0 =A0{&quot;pgpgout&quot;, &quot;total_pgpgout&quot;},<br>
+ =A0 =A0 =A0 {&quot;pgscan_direct_limit&quot;, &quot;total_pgscan_direct_l=
imit&quot;},<br>
+ =A0 =A0 =A0 {&quot;pgfree_direct_limit&quot;, &quot;total_pgfree_direct_l=
imit&quot;},<br>
+ =A0 =A0 =A0 {&quot;pgscan_direct_hierarchy&quot;, &quot;total_pgscan_dire=
ct_hierarchy&quot;},<br>
+ =A0 =A0 =A0 {&quot;pgsteal_direct_hierarchy&quot;, &quot;total_pgsteal_di=
rect_hierarchy&quot;},<br>
+ =A0 =A0 =A0 {&quot;pgscan_kswapd_limit&quot;, &quot;total_pgscan_kswapd_l=
imit&quot;},<br>
+ =A0 =A0 =A0 {&quot;pgfree_kswapd_limit&quot;, &quot;total_pgfree_kswapd_l=
imit&quot;},<br>
+ =A0 =A0 =A0 {&quot;pgscan_kswapd_hierarchy&quot;, &quot;total_pgscan_kswa=
pd_hierarchy&quot;},<br>
+ =A0 =A0 =A0 {&quot;pgsteal_kswapd_hierarchy&quot;, &quot;total_pgsteal_ks=
wapd_hierarchy&quot;},<br>
 =A0 =A0 =A0 =A0{&quot;swap&quot;, &quot;total_swap&quot;},<br>
 =A0 =A0 =A0 =A0{&quot;inactive_anon&quot;, &quot;total_inactive_anon&quot;=
},<br>
 =A0 =A0 =A0 =A0{&quot;active_anon&quot;, &quot;total_active_anon&quot;},<b=
r>
@@ -3864,6 +3911,22 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, st=
ruct mcs_total_stat *s)<br>
 =A0 =A0 =A0 =A0s-&gt;stat[MCS_PGPGIN] +=3D val;<br>
 =A0 =A0 =A0 =A0val =3D mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGPGO=
UT);<br>
 =A0 =A0 =A0 =A0s-&gt;stat[MCS_PGPGOUT] +=3D val;<br>
+ =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, PGSCAN_DIRECT_LIMIT);<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_PGSCAN_DIRECT_LIMIT] +=3D val;<br>
+ =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, PGFREE_DIRECT_LIMIT);<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_PGFREE_DIRECT_LIMIT] +=3D val;<br>
+ =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, PGSCAN_DIRECT_HIERARCHY);=
<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_PGSCAN_DIRECT_HIERARCHY] +=3D val;<br>
+ =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, PGSTEAL_DIRECT_HIERARCHY)=
;<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_PGSTEAL_DIRECT_HIERARCHY] +=3D val;<br>
+ =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, PGSCAN_KSWAPD_LIMIT);<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_PGSCAN_KSWAPD_LIMIT] +=3D val;<br>
+ =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, PGFREE_KSWAPD_LIMIT);<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_PGFREE_KSWAPD_LIMIT] +=3D val;<br>
+ =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, PGSCAN_KSWAPD_HIERARCHY);=
<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_PGSCAN_KSWAPD_HIERARCHY] +=3D val;<br>
+ =A0 =A0 =A0 val =3D mem_cgroup_read_events(mem, PGSTEAL_KSWAPD_HIERARCHY)=
;<br>
+ =A0 =A0 =A0 s-&gt;stat[MCS_PGSTEAL_KSWAPD_HIERARCHY] +=3D val;<br>
 =A0 =A0 =A0 =A0if (do_swap_account) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val =3D mem_cgroup_read_stat(mem, MEM_CGROU=
P_STAT_SWAPOUT);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s-&gt;stat[MCS_SWAP] +=3D val * PAGE_SIZE;<=
br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
index e2a3647..0e45ceb 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -1961,9 +1961,16 @@ static void shrink_zone(int priority, struct zone *z=
one,<br>
 =A0 =A0 =A0 =A0struct mem_cgroup *mem =3D NULL;<br>
<br>
 =A0 =A0 =A0 =A0do {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long reclaimed =3D sc-&gt;nr_reclaim=
ed;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scanned =3D sc-&gt;nr_scanned;<=
br>
+<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_hierarchy_walk(root, &amp;mem);<=
br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc-&gt;current_memcg =3D mem;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_shrink_zone(priority, zone, sc);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_count_reclaim(mem, current_is_kswa=
pd(),<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0mem !=3D root, /* limit or hierarchy? */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0sc-&gt;nr_scanned - scanned,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0sc-&gt;nr_reclaimed - reclaimed);<br>
 =A0 =A0 =A0 =A0} while (mem !=3D root);<br>
<br>
 =A0 =A0 =A0 =A0/* For good measure, noone higher up the stack should look =
at it */<br>
<font color=3D"#888888">--<br>
1.7.5.1<br>
<br>
</font></blockquote></div><br>

--0016e64aefdaca660a04a31944f4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
