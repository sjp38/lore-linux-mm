Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C1CB0900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 17:38:29 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3ILcPb8015913
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 14:38:25 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by hpaq1.eem.corp.google.com with ESMTP id p3ILcNEt021749
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 14:38:23 -0700
Received: by qwf7 with SMTP id 7so2688866qwf.10
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 14:38:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=2yQZXhHrDxjPvpKJ-KpmQ242cVQ@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-7-git-send-email-yinghan@google.com>
	<BANLkTi=2yQZXhHrDxjPvpKJ-KpmQ242cVQ@mail.gmail.com>
Date: Mon, 18 Apr 2011 14:38:22 -0700
Message-ID: <BANLkTikZcTj9GAGrsTnMMCq1b9HjnDnGWA@mail.gmail.com>
Subject: Re: [PATCH V5 06/10] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd082f7ed9604a138350d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd082f7ed9604a138350d
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Apr 17, 2011 at 8:51 PM, Minchan Kim <minchan.kim@gmail.com> wrote:

> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
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
> > changelog v5..v4:
> > 1. remove duplicate check on nodes_empty()
> > 2. add logic to check if the per-memcg lru is empty on the zone.
> > 3. make per-memcg kswapd to reclaim SWAP_CLUSTER_MAX per zone. It make
> senses
> > since it helps to balance the pressure across zones within the memcg.
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
> >  mm/vmscan.c |  157
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 157 insertions(+), 0 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 06036d2..39e6300 100644
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
> >         * are scanned.
> >         */
> >        nodemask_t      *nodemask;
> > +
> > +       int priority;
> >  };
> >
> >  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> > @@ -2631,11 +2635,164 @@ static void kswapd_try_to_sleep(struct kswapd
> *kswapd_p, int order,
> >        finish_wait(wait_h, &wait);
> >  }
> >
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> > +/*
> > + * The function is used for per-memcg LRU. It scanns all the zones of
> the
> > + * node and returns the nr_scanned and nr_reclaimed.
> > + */
> > +static void balance_pgdat_node(pg_data_t *pgdat, int order,
> > +                                       struct scan_control *sc)
> > +{
> > +       int i;
> > +       unsigned long total_scanned = 0;
> > +       struct mem_cgroup *mem_cont = sc->mem_cgroup;
> > +       int priority = sc->priority;
> > +       enum lru_list l;
> > +
> > +       /*
> > +        * This dma->highmem order is consistant with global reclaim.
> > +        * We do this because the page allocator works in the opposite
> > +        * direction although memcg user pages are mostly allocated at
> > +        * highmem.
> > +        */
> > +       for (i = 0; i < pgdat->nr_zones; i++) {
> > +               struct zone *zone = pgdat->node_zones + i;
> > +               unsigned long scan = 0;
> > +
> > +               for_each_evictable_lru(l)
> > +                       scan += mem_cgroup_zone_nr_pages(mem_cont, zone,
> l);
> > +
> > +               if (!populated_zone(zone) || !scan)
> > +                       continue;
>
> Do we really need this double check?

Isn't only _scan_ check enough?
>

yes. will change on next post.


> And shouldn't we consider non-swap case?
>

good point. we don't need to count the anon lru in non-swap case. A new
function will be added to count the memcg_zone_reclaimable per zone.


>
> > +
> > +               sc->nr_scanned = 0;
> > +               shrink_zone(priority, zone, sc);
> > +               total_scanned += sc->nr_scanned;
> > +
> > +               /*
> > +                * If we've done a decent amount of scanning and
> > +                * the reclaim ratio is low, start doing writepage
> > +                * even in laptop mode
> > +                */
> > +               if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> > +                   total_scanned > sc->nr_reclaimed + sc->nr_reclaimed /
> 2) {
> > +                       sc->may_writepage = 1;
>
> I don't want to add more random write any more although we don't have
> a trouble of real memory shortage.
>


> Do you have any reason to reclaim memory urgently as writing dirty pages?
> Maybe if we wait a little bit of time, flusher would write out the page.
>

We would like to reduce the writing dirty pages from page reclaim,
especially from direct reclaim. AFAIK, the try_to_free_mem_cgroup_pages()
still need to write dirty pages when there is a need. removing this from the
per-memcg kswap will only add more pressure to the per-memcg direct reclaim,
which seems to be worse. (stack overflow as one example which we would like
to get rid of)


>
> > +               }
> > +       }
> > +
> > +       sc->nr_scanned = total_scanned;
> > +       return;
>
> unnecessary return.
>
> removed.


> > +}
> > +
> > +/*
> > + * Per cgroup background reclaim.
> > + * TODO: Take off the order since memcg always do order 0
> > + */
> > +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> > +                                             int order)
> > +{
> > +       int i, nid;
> > +       int start_node;
> > +       int priority;
> > +       bool wmark_ok;
> > +       int loop;
> > +       pg_data_t *pgdat;
> > +       nodemask_t do_nodes;
> > +       unsigned long total_scanned;
> > +       struct scan_control sc = {
> > +               .gfp_mask = GFP_KERNEL,
> > +               .may_unmap = 1,
> > +               .may_swap = 1,
> > +               .nr_to_reclaim = SWAP_CLUSTER_MAX,
> > +               .swappiness = vm_swappiness,
> > +               .order = order,
> > +               .mem_cgroup = mem_cont,
> > +       };
> > +
> > +loop_again:
> > +       do_nodes = NODE_MASK_NONE;
> > +       sc.may_writepage = !laptop_mode;
>
> I think it depends on urgency(ie, priority, reclaim
> ratio(#reclaim/#scanning) or something), not laptop_mode in case of
> memcg.
> As I said earlier,it wold be better to avoid random write.
>

I agree that we would like to avoid it. but not sure if we should remove it
here, since it add more pressure to the direct reclaim case.

>
> > +       sc.nr_reclaimed = 0;
> > +       total_scanned = 0;
> > +
> > +       for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> > +               sc.priority = priority;
> > +               wmark_ok = false;
> > +               loop = 0;
> > +
> > +               /* The swap token gets in the way of swapout... */
> > +               if (!priority)
> > +                       disable_swap_token();
> > +
> > +               if (priority == DEF_PRIORITY)
> > +                       do_nodes = node_states[N_ONLINE];
> > +
> > +               while (1) {
> > +                       nid = mem_cgroup_select_victim_node(mem_cont,
> > +                                                       &do_nodes);
> > +
> > +                       /* Indicate we have cycled the nodelist once
>
> Fix comment style.
>

Fixed.

>
> > +                        * TODO: we might add MAX_RECLAIM_LOOP for
> preventing
> > +                        * kswapd burning cpu cycles.
> > +                        */
> > +                       if (loop == 0) {
> > +                               start_node = nid;
> > +                               loop++;
> > +                       } else if (nid == start_node)
> > +                               break;
> > +
> > +                       pgdat = NODE_DATA(nid);
> > +                       balance_pgdat_node(pgdat, order, &sc);
> > +                       total_scanned += sc.nr_scanned;
> > +
> > +                       /* Set the node which has at least
>
> Fix comment style.
>
> Fixed.


> > +                        * one reclaimable zone
> > +                        */
> > +                       for (i = pgdat->nr_zones - 1; i >= 0; i--) {
> > +                               struct zone *zone = pgdat->node_zones +
> i;
> > +
> > +                               if (!populated_zone(zone))
> > +                                       continue;
> > +                       }
>
> I can't understand your comment and logic.
> The comment mentioned reclaimable zone but the logic checks just
> populated_zone. What's meaning?
>

I will move the comment to another patch which adds the zone unreclaimable.

--Ying

>
> > +                       if (i < 0)
> > +                               node_clear(nid, do_nodes);
> > +
> > +                       if (mem_cgroup_watermark_ok(mem_cont,
> > +
> CHARGE_WMARK_HIGH)) {
> > +                               wmark_ok = true;
> > +                               goto out;
> > +                       }
> > +
> > +                       if (nodes_empty(do_nodes)) {
> > +                               wmark_ok = true;
> > +                               goto out;
> > +                       }
> > +               }
> > +
> > +               if (total_scanned && priority < DEF_PRIORITY - 2)
> > +                       congestion_wait(WRITE, HZ/10);
> > +
> > +               if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
> > +                       break;
> > +       }
> > +out:
> > +       if (!wmark_ok) {
> > +               cond_resched();
> > +
> > +               try_to_freeze();
> > +
> > +               goto loop_again;
> > +       }
> > +
> > +       return sc.nr_reclaimed;
> > +}
> > +#else
> >  static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> *mem_cont,
> >                                                        int order)
> >  {
> >        return 0;
> >  }
> > +#endif
> >
> >  /*
> >  * The background pageout daemon, started as a kernel thread
> > --
> > 1.7.3.1
> >
> >
>
>
>
> --
> Kind regards,
> Minchan Kim
>

--000e0cdfd082f7ed9604a138350d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, Apr 17, 2011 at 8:51 PM, Minchan=
 Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan=
.kim@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Sat, Apr 16, 2011 at 8:23 AM, Ying Han=
 &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&gt; wrote=
:<br>
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
&gt; changelog v5..v4:<br>
&gt; 1. remove duplicate check on nodes_empty()<br>
&gt; 2. add logic to check if the per-memcg lru is empty on the zone.<br>
&gt; 3. make per-memcg kswapd to reclaim SWAP_CLUSTER_MAX per zone. It make=
 senses<br>
&gt; since it helps to balance the pressure across zones within the memcg.<=
br>
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
&gt; =A0mm/vmscan.c | =A0157 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++<br>
&gt; =A01 files changed, 157 insertions(+), 0 deletions(-)<br>
&gt;<br>
&gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; index 06036d2..39e6300 100644<br>
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
&gt; =A0 =A0 =A0 =A0 * are scanned.<br>
&gt; =A0 =A0 =A0 =A0 */<br>
&gt; =A0 =A0 =A0 =A0nodemask_t =A0 =A0 =A0*nodemask;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 int priority;<br>
&gt; =A0};<br>
&gt;<br>
&gt; =A0#define lru_to_page(_head) (list_entry((_head)-&gt;prev, struct pag=
e, lru))<br>
&gt; @@ -2631,11 +2635,164 @@ static void kswapd_try_to_sleep(struct kswapd=
 *kswapd_p, int order,<br>
&gt; =A0 =A0 =A0 =A0finish_wait(wait_h, &amp;wait);<br>
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
=A0 =A0 struct scan_control *sc)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 int i;<br>
&gt; + =A0 =A0 =A0 unsigned long total_scanned =3D 0;<br>
&gt; + =A0 =A0 =A0 struct mem_cgroup *mem_cont =3D sc-&gt;mem_cgroup;<br>
&gt; + =A0 =A0 =A0 int priority =3D sc-&gt;priority;<br>
&gt; + =A0 =A0 =A0 enum lru_list l;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0* This dma-&gt;highmem order is consistant with globa=
l reclaim.<br>
&gt; + =A0 =A0 =A0 =A0* We do this because the page allocator works in the =
opposite<br>
&gt; + =A0 =A0 =A0 =A0* direction although memcg user pages are mostly allo=
cated at<br>
&gt; + =A0 =A0 =A0 =A0* highmem.<br>
&gt; + =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 for (i =3D 0; i &lt; pgdat-&gt;nr_zones; i++) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat-&gt;node_zon=
es + i;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scan =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_evictable_lru(l)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan +=3D mem_cgroup_zon=
e_nr_pages(mem_cont, zone, l);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone) || !scan)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
<br>
</div></div>Do we really need this double check?=A0</blockquote><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
Isn&#39;t only _scan_ check enough?<br></blockquote><div><br></div><div>yes=
. will change on next post.</div><div>=A0</div><blockquote class=3D"gmail_q=
uote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1e=
x;">

And shouldn&#39;t we consider non-swap case?<br></blockquote><div><br></div=
><div>good point. we don&#39;t need to count the anon lru in non-swap case.=
 A new function will be added to count the memcg_zone_reclaimable per zone.=
</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
<div class=3D"im">&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, =
zone, sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_scanned;<br=
>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we&#39;ve done a decent amount o=
f scanning and<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, start doi=
ng writepage<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; SWAP_CLUSTER_MAX =
* 2 &amp;&amp;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc-&gt;nr_rec=
laimed + sc-&gt;nr_reclaimed / 2) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepage =3D=
 1;<br>
<br>
</div>I don&#39;t want to add more random write any more although we don&#3=
9;t have<br>
a trouble of real memory shortage.<br></blockquote><div>=A0</div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
Do you have any reason to reclaim memory urgently as writing dirty pages?<b=
r>
Maybe if we wait a little bit of time, flusher would write out the page.<br=
></blockquote><div><br></div><div>We would like to reduce the writing dirty=
 pages from page reclaim, especially from direct reclaim. AFAIK, the=A0try_=
to_free_mem_cgroup_pages() still need to write dirty pages when there is a =
need. removing this from the per-memcg kswap will only add more pressure to=
 the per-memcg direct reclaim, which seems to be worse. (stack overflow as =
one example which we would like to get rid of)</div>
<div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;=
border-left:1px #ccc solid;padding-left:1ex;">
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 sc-&gt;nr_scanned =3D total_scanned;<br>
&gt; + =A0 =A0 =A0 return;<br>
<br>
unnecessary return.<br>
<div class=3D"im"><br></div></blockquote><div>removed.</div><div>=A0</div><=
blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px=
 #ccc solid;padding-left:1ex;"><div class=3D"im">
&gt; +}<br>
&gt; +<br>
&gt; +/*<br>
&gt; + * Per cgroup background reclaim.<br>
&gt; + * TODO: Take off the order since memcg always do order 0<br>
&gt; + */<br>
&gt; +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *mem_=
cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 int order)<br>
&gt; +{<br>
&gt; + =A0 =A0 =A0 int i, nid;<br>
&gt; + =A0 =A0 =A0 int start_node;<br>
&gt; + =A0 =A0 =A0 int priority;<br>
&gt; + =A0 =A0 =A0 bool wmark_ok;<br>
&gt; + =A0 =A0 =A0 int loop;<br>
&gt; + =A0 =A0 =A0 pg_data_t *pgdat;<br>
&gt; + =A0 =A0 =A0 nodemask_t do_nodes;<br>
&gt; + =A0 =A0 =A0 unsigned long total_scanned;<br>
&gt; + =A0 =A0 =A0 struct scan_control sc =3D {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D SWAP_CLUSTER_MAX,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,<br>
&gt; + =A0 =A0 =A0 };<br>
&gt; +<br>
&gt; +loop_again:<br>
&gt; + =A0 =A0 =A0 do_nodes =3D NODE_MASK_NONE;<br>
&gt; + =A0 =A0 =A0 sc.may_writepage =3D !laptop_mode;<br>
<br>
</div>I think it depends on urgency(ie, priority, reclaim<br>
ratio(#reclaim/#scanning) or something), not laptop_mode in case of<br>
memcg.<br>
As I said earlier,it wold be better to avoid random write.<br></blockquote>=
<div><br></div><div>I agree that we would like to avoid it. but not sure if=
 we should remove it here, since it add more pressure to the direct reclaim=
 case.=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
&gt; + =A0 =A0 =A0 sc.nr_reclaimed =3D 0;<br>
<div class=3D"im">&gt; + =A0 =A0 =A0 total_scanned =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 for (priority =3D DEF_PRIORITY; priority &gt;=3D 0; prio=
rity--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok =3D false;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop =3D 0;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way of swa=
pout... */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();<br=
>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priority =3D=3D DEF_PRIORITY)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_nodes =3D node_states=
[N_ONLINE];<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (1) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid =3D mem_cgroup_selec=
t_victim_node(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &amp;do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Indicate we have cycl=
ed the nodelist once<br>
<br>
</div>Fix comment style.<br></blockquote><div><br></div><div>Fixed.=A0</div=
><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1=
px #ccc solid;padding-left:1ex;">
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* TODO: we might add =
MAX_RECLAIM_LOOP for preventing<br>
<div class=3D"im">&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* k=
swapd burning cpu cycles.<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (loop =3D=3D 0) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 start_no=
de =3D nid;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 loop++;<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (nid =3D=3D st=
art_node)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<b=
r>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgdat =3D NODE_DATA(nid)=
;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_pgdat_node(pgdat=
, order, &amp;sc);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc.nr=
_scanned;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Set the node which ha=
s at least<br>
<br>
</div>Fix comment style.<br>
<br></blockquote><div>Fixed.</div><div>=A0</div><blockquote class=3D"gmail_=
quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1=
ex;">
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* one reclaimable zon=
e<br>
<div class=3D"im">&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<=
br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D pgdat-&gt;nr_=
zones - 1; i &gt;=3D 0; i--) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct z=
one *zone =3D pgdat-&gt;node_zones + i;<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pop=
ulated_zone(zone))<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 continue;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
<br>
</div>I can&#39;t understand your comment and logic.<br>
The comment mentioned reclaimable zone but the logic checks just<br>
populated_zone. What&#39;s meaning?<br></blockquote><div><br></div><div>I w=
ill move the comment to another patch which adds the zone unreclaimable.</d=
iv><div><br></div><div>--Ying=A0</div><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i &lt; 0)<br>
<div><div></div><div class=3D"h5">&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear(nid, do_nodes);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_watermark=
_ok(mem_cont,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CHARGE_WMARK_HIGH)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok=
 =3D true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out=
;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nodes_empty(do_nodes=
)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wmark_ok=
 =3D true;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out=
;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &amp;&amp; priority &l=
t; DEF_PRIORITY - 2)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(WRITE, H=
Z/10);<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc.nr_reclaimed &gt;=3D SWAP_CLUSTER=
_MAX)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; +out:<br>
&gt; + =A0 =A0 =A0 if (!wmark_ok) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_freeze();<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto loop_again;<br>
&gt; + =A0 =A0 =A0 }<br>
&gt; +<br>
&gt; + =A0 =A0 =A0 return sc.nr_reclaimed;<br>
&gt; +}<br>
&gt; +#else<br>
&gt; =A0static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup *me=
m_cont,<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int order)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 =A0return 0;<br>
&gt; =A0}<br>
&gt; +#endif<br>
&gt;<br>
&gt; =A0/*<br>
&gt; =A0* The background pageout daemon, started as a kernel thread<br>
&gt; --<br>
&gt; 1.7.3.1<br>
&gt;<br>
&gt;<br>
<br>
<br>
<br>
</div></div>--<br>
Kind regards,<br>
<font color=3D"#888888">Minchan Kim<br>
</font></blockquote></div><br>

--000e0cdfd082f7ed9604a138350d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
