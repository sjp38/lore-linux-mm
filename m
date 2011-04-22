Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3A9478D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 02:17:24 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p3M6HLJS018309
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:17:22 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by kpbe20.cbf.corp.google.com with ESMTP id p3M6HK5D026093
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:17:20 -0700
Received: by qwc9 with SMTP id 9so275276qwc.27
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:17:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422151420.FA72.A69D9226@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-9-git-send-email-yinghan@google.com>
	<20110422151420.FA72.A69D9226@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 23:17:19 -0700
Message-ID: <BANLkTinV_xj5jWFUdtCvPbk7VwkMV2gEqg@mail.gmail.com>
Subject: Re: [PATCH V7 8/9] Add per-memcg zone "unreclaimable"
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8693aed04a17bcf0d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470aa8693aed04a17bcf0d
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 11:13 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:

> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 98fc7ed..3370c5a 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1526,6 +1526,7 @@ struct task_struct {
> >               struct mem_cgroup *memcg; /* target memcg of uncharge */
> >               unsigned long nr_pages; /* uncharged usage */
> >               unsigned long memsw_nr_pages; /* uncharged mem+swap usage
> */
> > +             struct zone *zone; /* a zone page is last uncharged */
>
> "zone" is bad name for task_struct. :-/
>

Hmm. then "zone_uncharged" ?

>
>
> >       } memcg_batch;
> >  #endif
> >  };
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index a062f0b..b868e597 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -159,6 +159,8 @@ enum {
> >       SWP_SCANNING    = (1 << 8),     /* refcount in scan_swap_map */
> >  };
> >
> > +#define ZONE_RECLAIMABLE_RATE 6
> > +
>
> Need comment?
>

ok.

>
>
> >  #define SWAP_CLUSTER_MAX 32
> >  #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
> >
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 41eaa62..9e535b2 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -135,7 +135,10 @@ struct mem_cgroup_per_zone {
> >       bool                    on_tree;
> >       struct mem_cgroup       *mem;           /* Back pointer, we cannot
> */
> >                                               /* use container_of
>  */
> > +     unsigned long           pages_scanned;  /* since last reclaim */
> > +     bool                    all_unreclaimable;      /* All pages pinned
> */
> >  };
> > +
> >  /* Macro for accessing counter */
> >  #define MEM_CGROUP_ZSTAT(mz, idx)    ((mz)->count[(idx)])
> >
> > @@ -1162,6 +1165,103 @@ mem_cgroup_get_reclaim_stat_from_page(struct page
> *page)
> >       return &mz->reclaim_stat;
> >  }
> >
> > +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone
> *zone,
> > +                                             unsigned long nr_scanned)
>
> this names sound like pages_scanned value getting helper function.
>



> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +
> > +     if (!mem)
> > +             return;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz)
> > +             mz->pages_scanned += nr_scanned;
> > +}
> > +
> > +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, struct zone
> *zone)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +
> > +     if (!mem)
> > +             return 0;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz)
> > +             return mz->pages_scanned <
> > +                             mem_cgroup_zone_reclaimable_pages(mem,
> zone) *
> > +                             ZONE_RECLAIMABLE_RATE;
> > +     return 0;
> > +}
> > +
> > +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone
> *zone)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +
> > +     if (!mem)
> > +             return false;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz)
> > +             return mz->all_unreclaimable;
> > +
> > +     return false;
> > +}
> > +
> > +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone
> *zone)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +
> > +     if (!mem)
> > +             return;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz)
> > +             mz->all_unreclaimable = true;
> > +}
> > +
> > +void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
> > +                                    struct zone *zone)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +     int nid = zone_to_nid(zone);
> > +     int zid = zone_idx(zone);
> > +
> > +     if (!mem)
> > +             return;
> > +
> > +     mz = mem_cgroup_zoneinfo(mem, nid, zid);
> > +     if (mz) {
> > +             mz->pages_scanned = 0;
> > +             mz->all_unreclaimable = false;
> > +     }
> > +
> > +     return;
> > +}
> > +
> > +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page
> *page)
> > +{
> > +     struct mem_cgroup_per_zone *mz = NULL;
> > +
> > +     if (!mem)
> > +             return;
> > +
> > +     mz = page_cgroup_zoneinfo(mem, page);
> > +     if (mz) {
> > +             mz->pages_scanned = 0;
> > +             mz->all_unreclaimable = false;
> > +     }
> > +
> > +     return;
> > +}
> > +
> >  unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >                                       struct list_head *dst,
> >                                       unsigned long *scanned, int order,
> > @@ -2709,6 +2809,7 @@ void mem_cgroup_cancel_charge_swapin(struct
> mem_cgroup *mem)
> >
> >  static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
> >                                  unsigned int nr_pages,
> > +                                struct page *page,
> >                                  const enum charge_type ctype)
> >  {
> >       struct memcg_batch_info *batch = NULL;
> > @@ -2726,6 +2827,10 @@ static void mem_cgroup_do_uncharge(struct
> mem_cgroup *mem,
> >        */
> >       if (!batch->memcg)
> >               batch->memcg = mem;
> > +
> > +     if (!batch->zone)
> > +             batch->zone = page_zone(page);
> > +
> >       /*
> >        * do_batch > 0 when unmapping pages or inode invalidate/truncate.
> >        * In those cases, all pages freed continously can be expected to
> be in
> > @@ -2747,12 +2852,17 @@ static void mem_cgroup_do_uncharge(struct
> mem_cgroup *mem,
> >        */
> >       if (batch->memcg != mem)
> >               goto direct_uncharge;
> > +
> > +     if (batch->zone != page_zone(page))
> > +             mem_cgroup_mz_clear_unreclaimable(mem, page_zone(page));
> > +
> >       /* remember freed charge and uncharge it later */
> >       batch->nr_pages++;
> >       if (uncharge_memsw)
> >               batch->memsw_nr_pages++;
> >       return;
> >  direct_uncharge:
> > +     mem_cgroup_mz_clear_unreclaimable(mem, page_zone(page));
> >       res_counter_uncharge(&mem->res, nr_pages * PAGE_SIZE);
> >       if (uncharge_memsw)
> >               res_counter_uncharge(&mem->memsw, nr_pages * PAGE_SIZE);
> > @@ -2834,7 +2944,7 @@ __mem_cgroup_uncharge_common(struct page *page,
> enum charge_type ctype)
> >               mem_cgroup_get(mem);
> >       }
> >       if (!mem_cgroup_is_root(mem))
> > -             mem_cgroup_do_uncharge(mem, nr_pages, ctype);
> > +             mem_cgroup_do_uncharge(mem, nr_pages, page, ctype);
> >
> >       return mem;
> >
> > @@ -2902,6 +3012,10 @@ void mem_cgroup_uncharge_end(void)
> >       if (batch->memsw_nr_pages)
> >               res_counter_uncharge(&batch->memcg->memsw,
> >                                    batch->memsw_nr_pages * PAGE_SIZE);
> > +     if (batch->zone)
> > +             mem_cgroup_mz_clear_unreclaimable(batch->memcg,
> batch->zone);
> > +     batch->zone = NULL;
> > +
> >       memcg_oom_recover(batch->memcg);
> >       /* forget this pointer (for sanity check) */
> >       batch->memcg = NULL;
> > @@ -4667,6 +4781,8 @@ static int alloc_mem_cgroup_per_zone_info(struct
> mem_cgroup *mem, int node)
> >               mz->usage_in_excess = 0;
> >               mz->on_tree = false;
> >               mz->mem = mem;
> > +             mz->pages_scanned = 0;
> > +             mz->all_unreclaimable = false;
> >       }
> >       return 0;
> >  }
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index ba03a10..87653d6 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1414,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
> >                                       ISOLATE_BOTH : ISOLATE_INACTIVE,
> >                       zone, sc->mem_cgroup,
> >                       0, file);
> > +
> > +             mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone,
> nr_scanned);
> > +
> >               /*
> >                * mem_cgroup_isolate_pages() keeps track of
> >                * scanned pages on its own.
> > @@ -1533,6 +1536,7 @@ static void shrink_active_list(unsigned long
> nr_pages, struct zone *zone,
> >                * mem_cgroup_isolate_pages() keeps track of
> >                * scanned pages on its own.
> >                */
> > +             mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone,
> pgscanned);
> >       }
> >
> >       reclaim_stat->recent_scanned[file] += nr_taken;
> > @@ -1989,7 +1993,8 @@ static void shrink_zones(int priority, struct
> zonelist *zonelist,
> >
> >  static bool zone_reclaimable(struct zone *zone)
> >  {
> > -     return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
> > +     return zone->pages_scanned < zone_reclaimable_pages(zone) *
> > +                                     ZONE_RECLAIMABLE_RATE;
> >  }
> >
> >  /*
> > @@ -2651,10 +2656,20 @@ static void shrink_memcg_node(pg_data_t *pgdat,
> int order,
> >               if (!scan)
> >                       continue;
> >
> > +             if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
> > +                     priority != DEF_PRIORITY)
> > +                     continue;
> > +
> >               sc->nr_scanned = 0;
> >               shrink_zone(priority, zone, sc);
> >               total_scanned += sc->nr_scanned;
> >
> > +             if (mem_cgroup_mz_unreclaimable(mem_cont, zone))
> > +                     continue;
> > +
> > +             if (!mem_cgroup_zone_reclaimable(mem_cont, zone))
> > +                     mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
> > +
> >               /*
> >                * If we've done a decent amount of scanning and
> >                * the reclaim ratio is low, start doing writepage
> > @@ -2716,10 +2731,16 @@ static unsigned long shrink_mem_cgroup(struct
> mem_cgroup *mem_cont, int order)
> >                       shrink_memcg_node(pgdat, order, &sc);
> >                       total_scanned += sc.nr_scanned;
> >
> > +                     /*
> > +                      * Set the node which has at least one reclaimable
> > +                      * zone
> > +                      */
> >                       for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> >                               struct zone *zone = pgdat->node_zones + i;
> >
> > -                             if (populated_zone(zone))
> > +                             if (populated_zone(zone) &&
> > +                                 !mem_cgroup_mz_unreclaimable(mem_cont,
> > +                                                             zone))
> >                                       break;
>
> global reclaim call shrink_zone() when priority==DEF_PRIORITY even if
> all_unreclaimable is set. Is this intentional change?
> If so, please add some comments.
>
> Ok.

--Ying

--002354470aa8693aed04a17bcf0d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 11:13 PM, KOSAKI=
 Motohiro <span dir=3D"ltr">&lt;<a href=3D"mailto:kosaki.motohiro@jp.fujits=
u.com">kosaki.motohiro@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote =
class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid=
;padding-left:1ex;">
<div class=3D"im">&gt; diff --git a/include/linux/sched.h b/include/linux/s=
ched.h<br>
&gt; index 98fc7ed..3370c5a 100644<br>
&gt; --- a/include/linux/sched.h<br>
&gt; +++ b/include/linux/sched.h<br>
&gt; @@ -1526,6 +1526,7 @@ struct task_struct {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *memcg; /* target memcg =
of uncharge */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_pages; /* uncharged usage=
 */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long memsw_nr_pages; /* uncharged=
 mem+swap usage */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone; /* a zone page is last un=
charged */<br>
<br>
</div>&quot;zone&quot; is bad name for task_struct. :-/<br></blockquote><di=
v><br></div><div>Hmm. then &quot;zone_uncharged&quot; ?=A0</div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">

<div class=3D"im"><br>
<br>
&gt; =A0 =A0 =A0 } memcg_batch;<br>
&gt; =A0#endif<br>
&gt; =A0};<br>
&gt; diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
&gt; index a062f0b..b868e597 100644<br>
&gt; --- a/include/linux/swap.h<br>
&gt; +++ b/include/linux/swap.h<br>
&gt; @@ -159,6 +159,8 @@ enum {<br>
&gt; =A0 =A0 =A0 SWP_SCANNING =A0 =A0=3D (1 &lt;&lt; 8), =A0 =A0 /* refcoun=
t in scan_swap_map */<br>
&gt; =A0};<br>
&gt;<br>
&gt; +#define ZONE_RECLAIMABLE_RATE 6<br>
&gt; +<br>
<br>
</div>Need comment?<br></blockquote><div><br></div><div>ok.=A0</div><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex;">
<div class=3D"im"><br>
<br>
&gt; =A0#define SWAP_CLUSTER_MAX 32<br>
&gt; =A0#define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX<br>
&gt;<br>
&gt; diff --git a/mm/memcontrol.c b/mm/memcontrol.c<br>
&gt; index 41eaa62..9e535b2 100644<br>
&gt; --- a/mm/memcontrol.c<br>
&gt; +++ b/mm/memcontrol.c<br>
&gt; @@ -135,7 +135,10 @@ struct mem_cgroup_per_zone {<br>
&gt; =A0 =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0on_tree;<br>
&gt; =A0 =A0 =A0 struct mem_cgroup =A0 =A0 =A0 *mem; =A0 =A0 =A0 =A0 =A0 /*=
 Back pointer, we cannot */<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 /* use container_of =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 unsigned long =A0 =A0 =A0 =A0 =A0 pages_scanned; =A0/* since=
 last reclaim */<br>
&gt; + =A0 =A0 bool =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0all_unreclaimabl=
e; =A0 =A0 =A0/* All pages pinned */<br>
&gt; =A0};<br>
&gt; +<br>
&gt; =A0/* Macro for accessing counter */<br>
&gt; =A0#define MEM_CGROUP_ZSTAT(mz, idx) =A0 =A0((mz)-&gt;count[(idx)])<br=
>
&gt;<br>
&gt; @@ -1162,6 +1165,103 @@ mem_cgroup_get_reclaim_stat_from_page(struct p=
age *page)<br>
&gt; =A0 =A0 =A0 return &amp;mz-&gt;reclaim_stat;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone =
*zone,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 unsigned long nr_scanned)<br>
<br>
</div>this names sound like pages_scanned value getting helper function.<br=
></blockquote><div><br></div><div>=A0</div><blockquote class=3D"gmail_quote=
" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">=
<div>
<div class=3D"h5">
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;pages_scanned +=3D nr_scanned;<br>
&gt; +}<br>
&gt; +<br>
&gt; +bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, struct zone =
*zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return 0;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return mz-&gt;pages_scanned &lt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_z=
one_reclaimable_pages(mem, zone) *<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ZONE_RECLAIM=
ABLE_RATE;<br>
&gt; + =A0 =A0 return 0;<br>
&gt; +}<br>
&gt; +<br>
&gt; +bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone =
*zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return false;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return mz-&gt;all_unreclaimable;<br>
&gt; +<br>
&gt; + =A0 =A0 return false;<br>
&gt; +}<br>
&gt; +<br>
&gt; +void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct z=
one *zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;all_unreclaimable =3D true;<br>
&gt; +}<br>
&gt; +<br>
&gt; +void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0struct zone *zone)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; + =A0 =A0 int nid =3D zone_to_nid(zone);<br>
&gt; + =A0 =A0 int zid =3D zone_idx(zone);<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid);<br>
&gt; + =A0 =A0 if (mz) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;pages_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;all_unreclaimable =3D false;<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 return;<br>
&gt; +}<br>
&gt; +<br>
&gt; +void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct pa=
ge *page)<br>
&gt; +{<br>
&gt; + =A0 =A0 struct mem_cgroup_per_zone *mz =3D NULL;<br>
&gt; +<br>
&gt; + =A0 =A0 if (!mem)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 return;<br>
&gt; +<br>
&gt; + =A0 =A0 mz =3D page_cgroup_zoneinfo(mem, page);<br>
&gt; + =A0 =A0 if (mz) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;pages_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;all_unreclaimable =3D false;<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 return;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,<br=
>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 struct list_head *dst,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 unsigned long *scanned, int order,<br>
&gt; @@ -2709,6 +2809,7 @@ void mem_cgroup_cancel_charge_swapin(struct mem_=
cgroup *mem)<br>
&gt;<br>
&gt; =A0static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0uns=
igned int nr_pages,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struc=
t page *page,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0con=
st enum charge_type ctype)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct memcg_batch_info *batch =3D NULL;<br>
&gt; @@ -2726,6 +2827,10 @@ static void mem_cgroup_do_uncharge(struct mem_c=
group *mem,<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 if (!batch-&gt;memcg)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 batch-&gt;memcg =3D mem;<br>
&gt; +<br>
&gt; + =A0 =A0 if (!batch-&gt;zone)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 batch-&gt;zone =3D page_zone(page);<br>
&gt; +<br>
&gt; =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0* do_batch &gt; 0 when unmapping pages or inode invalid=
ate/truncate.<br>
&gt; =A0 =A0 =A0 =A0* In those cases, all pages freed continously can be ex=
pected to be in<br>
&gt; @@ -2747,12 +2852,17 @@ static void mem_cgroup_do_uncharge(struct mem_=
cgroup *mem,<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 if (batch-&gt;memcg !=3D mem)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto direct_uncharge;<br>
&gt; +<br>
&gt; + =A0 =A0 if (batch-&gt;zone !=3D page_zone(page))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_clear_unreclaimable(mem, page_=
zone(page));<br>
&gt; +<br>
&gt; =A0 =A0 =A0 /* remember freed charge and uncharge it later */<br>
&gt; =A0 =A0 =A0 batch-&gt;nr_pages++;<br>
&gt; =A0 =A0 =A0 if (uncharge_memsw)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 batch-&gt;memsw_nr_pages++;<br>
&gt; =A0 =A0 =A0 return;<br>
&gt; =A0direct_uncharge:<br>
&gt; + =A0 =A0 mem_cgroup_mz_clear_unreclaimable(mem, page_zone(page));<br>
&gt; =A0 =A0 =A0 res_counter_uncharge(&amp;mem-&gt;res, nr_pages * PAGE_SIZ=
E);<br>
&gt; =A0 =A0 =A0 if (uncharge_memsw)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_uncharge(&amp;mem-&gt;memsw, n=
r_pages * PAGE_SIZE);<br>
&gt; @@ -2834,7 +2944,7 @@ __mem_cgroup_uncharge_common(struct page *page, =
enum charge_type ctype)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_get(mem);<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 if (!mem_cgroup_is_root(mem))<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_do_uncharge(mem, nr_pages, ctype)=
;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_do_uncharge(mem, nr_pages, page, =
ctype);<br>
&gt;<br>
&gt; =A0 =A0 =A0 return mem;<br>
&gt;<br>
&gt; @@ -2902,6 +3012,10 @@ void mem_cgroup_uncharge_end(void)<br>
&gt; =A0 =A0 =A0 if (batch-&gt;memsw_nr_pages)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_uncharge(&amp;batch-&gt;memcg-=
&gt;memsw,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0batch-&gt;memsw_nr_pages * PAGE_SIZE);<br>
&gt; + =A0 =A0 if (batch-&gt;zone)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_clear_unreclaimable(batch-&gt;=
memcg, batch-&gt;zone);<br>
&gt; + =A0 =A0 batch-&gt;zone =3D NULL;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 memcg_oom_recover(batch-&gt;memcg);<br>
&gt; =A0 =A0 =A0 /* forget this pointer (for sanity check) */<br>
&gt; =A0 =A0 =A0 batch-&gt;memcg =3D NULL;<br>
&gt; @@ -4667,6 +4781,8 @@ static int alloc_mem_cgroup_per_zone_info(struct=
 mem_cgroup *mem, int node)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;usage_in_excess =3D 0;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;on_tree =3D false;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;mem =3D mem;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;pages_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mz-&gt;all_unreclaimable =3D false;<br>
&gt; =A0 =A0 =A0 }<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index ba03a10..87653d6 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -1414,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan, s=
truct zone *zone,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 ISOLATE_BOTH : ISOLATE_INACTIVE,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone, sc-&gt;mem_cgroup,<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, file);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc-&gt;mem_cgrou=
p, zone, nr_scanned);<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps trac=
k of<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.<br>
&gt; @@ -1533,6 +1536,7 @@ static void shrink_active_list(unsigned long nr_=
pages, struct zone *zone,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mem_cgroup_isolate_pages() keeps trac=
k of<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* scanned pages on its own.<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_pages_scanned(sc-&gt;mem_cgrou=
p, zone, pgscanned);<br>
&gt; =A0 =A0 =A0 }<br>
&gt;<br>
&gt; =A0 =A0 =A0 reclaim_stat-&gt;recent_scanned[file] +=3D nr_taken;<br>
&gt; @@ -1989,7 +1993,8 @@ static void shrink_zones(int priority, struct zo=
nelist *zonelist,<br>
&gt;<br>
&gt; =A0static bool zone_reclaimable(struct zone *zone)<br>
&gt; =A0{<br>
&gt; - =A0 =A0 return zone-&gt;pages_scanned &lt; zone_reclaimable_pages(zo=
ne) * 6;<br>
&gt; + =A0 =A0 return zone-&gt;pages_scanned &lt; zone_reclaimable_pages(zo=
ne) *<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 ZONE_RECLAIMABLE_RATE;<br>
&gt; =A0}<br>
&gt;<br>
&gt; =A0/*<br>
&gt; @@ -2651,10 +2656,20 @@ static void shrink_memcg_node(pg_data_t *pgdat=
, int order,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!scan)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zo=
ne) &amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority !=3D DEF_PRIORITY)<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_scanned;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_mz_unreclaimable(mem_cont, zo=
ne))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_zone_reclaimable(mem_cont, z=
one))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_mz_set_unreclaima=
ble(mem_cont, zone);<br>
&gt; +<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we&#39;ve done a decent amount of =
scanning and<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, start doing=
 writepage<br>
&gt; @@ -2716,10 +2731,16 @@ static unsigned long shrink_mem_cgroup(struct =
mem_cgroup *mem_cont, int order)<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_memcg_node(pgdat, o=
rder, &amp;sc);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_s=
canned;<br>
&gt;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Set the node which has =
at least one reclaimable<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* zone<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D pgdat-&gt;nr_zo=
nes - 1; i &gt;=3D 0; i--) {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zon=
e *zone =3D pgdat-&gt;node_zones + i;<br>
&gt;<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (populate=
d_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (populate=
d_zone(zone) &amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !mem=
_cgroup_mz_unreclaimable(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone))<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 break;<br>
<br>
</div></div>global reclaim call shrink_zone() when priority=3D=3DDEF_PRIORI=
TY even if<br>
all_unreclaimable is set. Is this intentional change?<br>
If so, please add some comments.<br>
<br></blockquote><div>Ok.</div><div><br></div><div>--Ying=A0</div></div><br=
>

--002354470aa8693aed04a17bcf0d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
