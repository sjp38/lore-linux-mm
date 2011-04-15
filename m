Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B878C900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 02:08:51 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p3F68g4n008324
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:08:42 -0700
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by wpaz17.hot.corp.google.com with ESMTP id p3F67cRi022498
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:08:41 -0700
Received: by qwa26 with SMTP id 26so1794085qwa.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 23:08:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415101148.80cb6721.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-7-git-send-email-yinghan@google.com>
	<20110415101148.80cb6721.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 14 Apr 2011 23:08:40 -0700
Message-ID: <BANLkTin0r26b2JgRJkXwLxP4m5HGAaxH=A@mail.gmail.com>
Subject: Re: [PATCH V4 06/10] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470674947b7c04a0eedfa3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470674947b7c04a0eedfa3
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 14, 2011 at 6:11 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 15:54:25 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > This is the main loop of per-memcg background reclaim which is
> implemented in
> > function balance_mem_cgroup_pgdat().
> >
> > The function performs a priority loop similar to global reclaim. During
> each
> > iteration it invokes balance_pgdat_node() for all nodes on the system,
> which
> > is another new function performs background reclaim per node. After
> reclaiming
> > each node, it checks mem_cgroup_watermark_ok() and breaks the priority
> loop if
> > it returns true.
> >
> > changelog v4..v3:
> > 1. split the select_victim_node and zone_unreclaimable to a seperate
> patches
> > 2. remove the logic tries to do zone balancing.
> >
> > changelog v3..v2:
> > 1. change mz->all_unreclaimable to be boolean.
> > 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg
> reclaim.
> > 3. some more clean-up.
> >
> > changelog v2..v1:
> > 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage.
> > 2. shared the kswapd_run/kswapd_stop for per-memcg and global background
> > reclaim.
> > 3. name the per-memcg memcg as "memcg-id" (css->id). And the global
> kswapd
> > keeps the same name.
> > 4. fix a race on kswapd_stop while the per-memcg-per-zone info could be
> accessed
> > after freeing.
> > 5. add the fairness in zonelist where memcg remember the last zone
> reclaimed
> > from.
> >
> > Signed-off-by: Ying Han <yinghan@google.com>
> > ---
> >  mm/vmscan.c |  161
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 161 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 4deb9c8..b8345d2 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -47,6 +47,8 @@
> >
> >  #include <linux/swapops.h>
> >
> > +#include <linux/res_counter.h>
> > +
> >  #include "internal.h"
> >
> >  #define CREATE_TRACE_POINTS
> > @@ -111,6 +113,8 @@ struct scan_control {
> >        * are scanned.
> >        */
> >       nodemask_t      *nodemask;
> > +
> > +     int priority;
> >  };
> >
> >  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> > @@ -2632,11 +2636,168 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >       finish_wait(wait_h, &wait);
> >  }
> >
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/*
> > + * The function is used for per-memcg LRU. It scanns all the zones of
> the
> > + * node and returns the nr_scanned and nr_reclaimed.
> > + */
> > +static void balance_pgdat_node(pg_data_t *pgdat, int order,
> > +                                     struct scan_control *sc)
> > +{
> > +     int i;
> > +     unsigned long total_scanned = 0;
> > +     struct mem_cgroup *mem_cont = sc->mem_cgroup;
> > +     int priority = sc->priority;
> > +
> > +     /*
> > +      * Now scan the zone in the dma->highmem direction, and we scan
> > +      * every zones for each node.
> > +      *
> > +      * We do this because the page allocator works in the opposite
> > +      * direction.  This prevents the page allocator from allocating
> > +      * pages behind kswapd's direction of progress, which would
> > +      * cause too much scanning of the lower zones.
> > +      */
>
> I guess this comment is a cut-n-paste from global kswapd. It works when
> alloc_page() stalls....hmm, I'd like to think whether dma->highmem
> direction
> is good in this case.
>

This is a legacy comment and the actual logic of zone balancing has been
removed from this patch.

>
> As you know, memcg works against user's memory, memory should be in highmem
> zone.
> Memcg-kswapd is not for memory-shortage, but for voluntary page dropping by
> _user_.
>

in some sense, yes. but it would also related to memory-shortage on fully
packed machines.

>
> If this memcg-kswapd drops pages from lower zones first, ah, ok, it's good
> for
> the system because memcg's pages should be on higher zone if we have free
> memory.
>
> So, I think the reason for dma->highmem is different from global kswapd.
>

yes. I agree that the logic of dma->highmem ordering is not exactly the same
from per-memcg kswapd and per-node kswapd. But still the page allocation
happens on the other side, and this is still good for the system as you
pointed out.

>
>
>
>
> > +     for (i = 0; i < pgdat->nr_zones; i++) {
> > +             struct zone *zone = pgdat->node_zones + i;
> > +
> > +             if (!populated_zone(zone))
> > +                     continue;
> > +
> > +             sc->nr_scanned = 0;
> > +             shrink_zone(priority, zone, sc);
> > +             total_scanned += sc->nr_scanned;
> > +
> > +             /*
> > +              * If we've done a decent amount of scanning and
> > +              * the reclaim ratio is low, start doing writepage
> > +              * even in laptop mode
> > +              */
> > +             if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> > +                 total_scanned > sc->nr_reclaimed + sc->nr_reclaimed /
> 2) {
> > +                     sc->may_writepage = 1;
> > +             }
> > +     }
> > +
> > +     sc->nr_scanned = total_scanned;
> > +     return;
> > +}
> > +
> > +/*
> > + * Per cgroup background reclaim.
> > + * TODO: Take off the order since memcg always do order 0
> > + */
> > +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> > +                                           int order)
> > +{
> > +     int i, nid;
> > +     int start_node;
> > +     int priority;
> > +     bool wmark_ok;
> > +     int loop;
> > +     pg_data_t *pgdat;
> > +     nodemask_t do_nodes;
> > +     unsigned long total_scanned;
> > +     struct scan_control sc = {
> > +             .gfp_mask = GFP_KERNEL,
> > +             .may_unmap = 1,
> > +             .may_swap = 1,
> > +             .nr_to_reclaim = ULONG_MAX,
> > +             .swappiness = vm_swappiness,
> > +             .order = order,
> > +             .mem_cgroup = mem_cont,
> > +     };
> > +
> > +loop_again:
> > +     do_nodes = NODE_MASK_NONE;
> > +     sc.may_writepage = !laptop_mode;
>
> I think may_writepage should start from '0' always. We're not sure
> the system is in memory shortage...we just want to release memory
> volunatary. write_page will add huge costs, I guess.
>
> For exmaple,
>        sc.may_writepage = !!loop
> may be better for memcg.
>
> BTW, you set nr_to_reclaim as ULONG_MAX here and doesn't modify it later.
>
> I think you should add some logic to fix it to right value.
>
> For example, before calling shrink_zone(),
>
> sc->nr_to_reclaim = min(SWAP_CLUSETR_MAX, memcg_usage_in_this_zone() /
> 100);  # 1% in this zone.
>
> if we love 'fair pressure for each zone'.
>

Hmm. I don't get it. Leaving the nr_to_reclaim to be ULONG_MAX in kswapd
case which is intended to add equal memory pressure for each zone. So in the
shrink_zone, we won't bail out in the following condition:


>-------while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> >------->------->------->------->-------nr[LRU_INACTIVE_FILE]) {
>

 >------->-------if (nr_reclaimed >= nr_to_reclaim && priority <
DEF_PRIORITY)
>------->------->-------break;

}
>
> --Ying

>
>
>
>
> > +     sc.nr_reclaimed = 0;
> > +     total_scanned = 0;
> > +
> > +     for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > +             sc.priority = priority;
> > +             wmark_ok = false;
> > +             loop = 0;
> > +
> > +             /* The swap token gets in the way of swapout... */
> > +             if (!priority)
> > +                     disable_swap_token();
> > +
> > +             if (priority == DEF_PRIORITY)
> > +                     do_nodes = node_states[N_ONLINE];
> > +
> > +             while (1) {
> > +                     nid = mem_cgroup_select_victim_node(mem_cont,
> > +                                                     &do_nodes);
> > +
> > +                     /* Indicate we have cycled the nodelist once
> > +                      * TODO: we might add MAX_RECLAIM_LOOP for
> preventing
> > +                      * kswapd burning cpu cycles.
> > +                      */
> > +                     if (loop == 0) {
> > +                             start_node = nid;
> > +                             loop++;
> > +                     } else if (nid == start_node)
> > +                             break;
> > +
> > +                     pgdat = NODE_DATA(nid);
> > +                     balance_pgdat_node(pgdat, order, &sc);
> > +                     total_scanned += sc.nr_scanned;
> > +
> > +                     /* Set the node which has at least
> > +                      * one reclaimable zone
> > +                      */
> > +                     for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > +                             struct zone *zone = pgdat->node_zones + i;
> > +
> > +                             if (!populated_zone(zone))
> > +                                     continue;
>
> How about checking whether memcg has pages on this node ?
>



> > +                     }
> > +                     if (i < 0)
> > +                             node_clear(nid, do_nodes);
> > +
> > +                     if (mem_cgroup_watermark_ok(mem_cont,
> > +                                                     CHARGE_WMARK_HIGH))
> {
> > +                             wmark_ok = true;
> > +                             goto out;
> > +                     }
> > +
> > +                     if (nodes_empty(do_nodes)) {
> > +                             wmark_ok = true;
> > +                             goto out;
> > +                     }
> > +             }
> > +
> > +             /* All the nodes are unreclaimable, kswapd is done */
> > +             if (nodes_empty(do_nodes)) {
> > +                     wmark_ok = true;
> > +                     goto out;
> > +             }
>
> Can this happen ?
>
>
> > +
> > +             if (total_scanned && priority < DEF_PRIORITY - 2)
> > +                     congestion_wait(WRITE, HZ/10);
> > +
> > +             if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> > +                     break;
> > +     }
> > +out:
> > +     if (!wmark_ok) {
> > +             cond_resched();
> > +
> > +             try_to_freeze();
> > +
> > +             goto loop_again;
> > +     }
> > +
> > +     return sc.nr_reclaimed;
> > +}
> > +#else
> >  static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> >                                                       int order)
> >  {
> >       return 0;
> >  }
> > +#endif
> >
>
>
> Thanks,
> -Kame
>
>

--002354470674947b7c04a0eedfa3
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 14, 2011 at 6:11 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Thu, 14 Apr 2011 15:54:25 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; This is the main loop of per-memcg background reclaim which is impleme=
nted in<br>
&gt; function balance_mem_cgroup_pgdat().<br>
&gt;<br>
&gt; The function performs a priority loop similar to global reclaim. Durin=
g each<br>
&gt; iteration it invokes balance_pgdat_node() for all nodes on the system,=
 which<br>
&gt; is another new function performs background reclaim per node. After re=
claiming<br>
&gt; each node, it checks mem_cgroup_watermark_ok() and breaks the priority=
 loop if<br>
&gt; it returns true.<br>
&gt;<br>
&gt; changelog v4..v3:<br>
&gt; 1. split the select_victim_node and zone_unreclaimable to a seperate p=
atches<br>
&gt; 2. remove the logic tries to do zone balancing.<br>
&gt;<br>
&gt; changelog v3..v2:<br>
&gt; 1. change mz-&gt;all_unreclaimable to be boolean.<br>
&gt; 2. define ZONE_RECLAIMABLE_RATE macro shared by zone and per-memcg rec=
laim.<br>
&gt; 3. some more clean-up.<br>
&gt;<br>
&gt; changelog v2..v1:<br>
&gt; 1. move the per-memcg per-zone clear_unreclaimable into uncharge stage=
.<br>
&gt; 2. shared the kswapd_run/kswapd_stop for per-memcg and global backgrou=
nd<br>
&gt; reclaim.<br>
&gt; 3. name the per-memcg memcg as &quot;memcg-id&quot; (css-&gt;id). And =
the global kswapd<br>
&gt; keeps the same name.<br>
&gt; 4. fix a race on kswapd_stop while the per-memcg-per-zone info could b=
e accessed<br>
&gt; after freeing.<br>
&gt; 5. add the fairness in zonelist where memcg remember the last zone rec=
laimed<br>
&gt; from.<br>
&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/vmscan.c | =A0161 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A01 files changed, 161 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 4deb9c8..b8345d2 100644<br>
&gt; --- a/mm/vmscan.c<br>
&gt; +++ b/mm/vmscan.c<br>
&gt; @@ -47,6 +47,8 @@<br>
&gt;<br>
&gt; =A0#include &lt;linux/swapops.h&gt;<br>
&gt;<br>
&gt; +#include &lt;linux/res_counter.h&gt;<br>
&gt; +<br>
&gt; =A0#include &quot;internal.h&quot;<br>
&gt;<br>
&gt; =A0#define CREATE_TRACE_POINTS<br>
&gt; @@ -111,6 +113,8 @@ struct scan_control {<br>
&gt; =A0 =A0 =A0 =A0* are scanned.<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 nodemask_t =A0 =A0 =A0*nodemask;<br>
&gt; +<br>
&gt; + =A0 =A0 int priority;<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#define lru_to_page(_head) (list_entry((_head)-&gt;prev, struct pag=
e, lru))<br>
&gt; @@ -2632,11 +2636,168 @@ static void kswapd_try_to_sleep(struct kswapd=
 *kswapd_p, int order,<br>
&gt; =A0 =A0 =A0 finish_wait(wait_h, &amp;wait);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +#ifdef CONFIG_CGROUP_MEM_RES_CTLR<br>
&gt; +/*<br>
&gt; + * The function is used for per-memcg LRU. It scanns all the zones of=
 the<br>
&gt; + * node and returns the nr_scanned and nr_reclaimed.<br>
&gt; + */<br>
&gt; +static void balance_pgdat_node(pg_data_t *pgdat, int order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 struct scan_control *sc)<br>
&gt; +{<br>
&gt; + =A0 =A0 int i;<br>
&gt; + =A0 =A0 unsigned long total_scanned =3D 0;<br>
&gt; + =A0 =A0 struct mem_cgroup *mem_cont =3D sc-&gt;mem_cgroup;<br>
&gt; + =A0 =A0 int priority =3D sc-&gt;priority;<br>
&gt; +<br>
&gt; + =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0* Now scan the zone in the dma-&gt;highmem direction, and=
 we scan<br>
&gt; + =A0 =A0 =A0* every zones for each node.<br>
&gt; + =A0 =A0 =A0*<br>
&gt; + =A0 =A0 =A0* We do this because the page allocator works in the oppo=
site<br>
&gt; + =A0 =A0 =A0* direction. =A0This prevents the page allocator from all=
ocating<br>
&gt; + =A0 =A0 =A0* pages behind kswapd&#39;s direction of progress, which =
would<br>
&gt; + =A0 =A0 =A0* cause too much scanning of the lower zones.<br>
&gt; + =A0 =A0 =A0*/<br>
<br>
</div></div>I guess this comment is a cut-n-paste from global kswapd. It wo=
rks when<br>
alloc_page() stalls....hmm, I&#39;d like to think whether dma-&gt;highmem d=
irection<br>
is good in this case.<br></blockquote><div><br></div><meta http-equiv=3D"co=
ntent-type" content=3D"text/html; charset=3Dutf-8"><div>This is a legacy co=
mment and the actual logic of zone balancing has been removed from this pat=
ch.=A0=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
As you know, memcg works against user&#39;s memory, memory should be in hig=
hmem zone.<br>
Memcg-kswapd is not for memory-shortage, but for voluntary page dropping by=
<br>
_user_.<br></blockquote><div><br></div><div>in some sense, yes. but it woul=
d also related to memory-shortage on fully packed machines.=A0</div><blockq=
uote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc =
solid;padding-left:1ex;">

<br>
If this memcg-kswapd drops pages from lower zones first, ah, ok, it&#39;s g=
ood for<br>
the system because memcg&#39;s pages should be on higher zone if we have fr=
ee memory.<br>
<br>
So, I think the reason for dma-&gt;highmem is different from global kswapd.=
<br></blockquote><div><br></div><div>yes. I agree that the logic of dma-&gt=
;highmem ordering is not exactly the same from per-memcg kswapd and per-nod=
e kswapd. But still the page allocation happens on the other side, and this=
 is still good for the system as you pointed out.</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5"><br>
<br>
<br>
<br>
&gt; + =A0 =A0 for (i =3D 0; i &lt; pgdat-&gt;nr_zones; i++) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat-&gt;node_zones +=
 i;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_scanned;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we&#39;ve done a decent amount of sc=
anning and<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, start doing w=
ritepage<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; SWAP_CLUSTER_MAX * 2 =
&amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc-&gt;nr_reclaim=
ed + sc-&gt;nr_reclaimed / 2) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepage =3D 1;<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 sc-&gt;nr_scanned =3D total_scanned;<br>
&gt; + =A0 =A0 return;<br>
&gt; +}<br>
&gt; +<br>
&gt; +/*<br>
&gt; + * Per cgroup background reclaim.<br>
&gt; + * TODO: Take off the order since memcg always do order 0<br>
&gt; + */<br>
&gt; +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_=
cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 int order)<br>
&gt; +{<br>
&gt; + =A0 =A0 int i, nid;<br>
&gt; + =A0 =A0 int start_node;<br>
&gt; + =A0 =A0 int priority;<br>
&gt; + =A0 =A0 bool wmark_ok;<br>
&gt; + =A0 =A0 int loop;<br>
&gt; + =A0 =A0 pg_data_t *pgdat;<br>
&gt; + =A0 =A0 nodemask_t do_nodes;<br>
&gt; + =A0 =A0 unsigned long total_scanned;<br>
&gt; + =A0 =A0 struct scan_control sc =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D ULONG_MAX,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,<br>
&gt; + =A0 =A0 };<br>
&gt; +<br>
&gt; +loop_again:<br>
&gt; + =A0 =A0 do_nodes =3D NODE_MASK_NONE;<br>
&gt; + =A0 =A0 sc.may_writepage =3D !laptop_mode;<br>
<br>
</div></div>I think may_writepage should start from &#39;0&#39; always. We&=
#39;re not sure<br>
the system is in memory shortage...we just want to release memory<br>
volunatary. write_page will add huge costs, I guess.<br>
<br>
For exmaple,<br>
 =A0 =A0 =A0 =A0sc.may_writepage =3D !!loop<br>
may be better for memcg.<br>
<br>
BTW, you set nr_to_reclaim as ULONG_MAX here and doesn&#39;t modify it late=
r.<br>
<br>
I think you should add some logic to fix it to right value.<br>
<br>
For example, before calling shrink_zone(),<br>
<br>
sc-&gt;nr_to_reclaim =3D min(SWAP_CLUSETR_MAX, memcg_usage_in_this_zone() /=
 100); =A0# 1% in this zone.<br>
<br>
if we love &#39;fair pressure for each zone&#39;.<br></blockquote><div><br>=
</div><div>Hmm. I don&#39;t get it. Leaving the=A0nr_to_reclaim to be=A0ULO=
NG_MAX in kswapd case which is intended to add equal memory pressure for ea=
ch zone. So in the shrink_zone, we won&#39;t bail out in the following cond=
ition:</div>
<div><br></div><div><br></div><meta http-equiv=3D"content-type" content=3D"=
text/html; charset=3Dutf-8"><meta http-equiv=3D"content-type" content=3D"te=
xt/html; charset=3Dutf-8"><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<div><div></div><div class=3D"h5"><div class=3D"h5">&gt;-------while (nr[LR=
U_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||</div><div class=3D"h5">&gt;-----=
--&gt;-------&gt;-------&gt;-------&gt;-------nr[LRU_INACTIVE_FILE]) {</div=
>
<div></div></div></div></blockquote><div><br></div><div>=A0&gt;-------&gt;-=
------if (nr_reclaimed &gt;=3D nr_to_reclaim &amp;&amp; priority &lt; DEF_P=
RIORITY)</div><div>&gt;-------&gt;-------&gt;-------break;</div><div><br></=
div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div><div class=3D"h5"><div>}</div>
<br></div></div></blockquote><div>--Ying=A0</div><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;"><div><div class=3D"h5">
<br>
<br>
<br>
<br>
&gt; + =A0 =A0 sc.nr_reclaimed =3D 0;<br>
&gt; + =A0 =A0 total_scanned =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 for (priority =3D DEF_PRIORITY; priority &gt;=3D 0; priority=
--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D false;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 loop =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way of swapout=
... */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (priority =3D=3D DEF_PRIORITY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_nodes =3D node_states[N_O=
NLINE];<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 while (1) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_select_vi=
ctim_node(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Indicate we have cycled t=
he nodelist once<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: we might add MAX_=
RECLAIM_LOOP for preventing<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* kswapd burning cpu cycl=
es.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop =3D=3D 0) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_node =
=3D nid;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (nid =3D=3D start_=
node)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid);<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_pgdat_node(pgdat, or=
der, &amp;sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr_sca=
nned;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Set the node which has at=
 least<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* one reclaimable zone<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D pgdat-&gt;nr_zone=
s - 1; i &gt;=3D 0; i--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone =
*zone =3D pgdat-&gt;node_zones + i;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populat=
ed_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 continue;<br>
<br>
</div></div>How about checking whether memcg has pages on this node ?<br></=
blockquote><div><br></div><div><br></div><blockquote class=3D"gmail_quote" =
style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i &lt; 0)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear(n=
id, do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_watermark_ok(=
mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CHARGE_WMARK_HIGH)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D=
 true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nodes_empty(do_nodes)) {=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D=
 true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br=
>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* All the nodes are unreclaimable, kswapd i=
s done */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (nodes_empty(do_nodes)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
</div>Can this happen ?<br>
<div class=3D"im"><br>
<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &amp;&amp; priority &lt; D=
EF_PRIORITY - 2)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, HZ/10=
);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_reclaimed &gt;=3D SWAP_CLUSTER_MAX=
)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 }<br>
&gt; +out:<br>
&gt; + =A0 =A0 if (!wmark_ok) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 try_to_freeze();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 goto loop_again;<br>
&gt; + =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 return sc.nr_reclaimed;<br>
&gt; +}<br>
&gt; +#else<br>
&gt; =A0static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *me=
m_cont,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int order)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 return 0;<br>
&gt; =A0}<br>
&gt; +#endif<br>
&gt;<br>
<br>
<br>
</div>Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--002354470674947b7c04a0eedfa3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
