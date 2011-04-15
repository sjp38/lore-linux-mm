Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 76EB5900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 14:00:27 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p3FI0ARN010295
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:00:10 -0700
Received: from qyk30 (qyk30.prod.google.com [10.241.83.158])
	by wpaz17.hot.corp.google.com with ESMTP id p3FHwc77028220
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:00:09 -0700
Received: by qyk30 with SMTP id 30so1876576qyk.7
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 11:00:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110415171437.098392da.kamezawa.hiroyu@jp.fujitsu.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-7-git-send-email-yinghan@google.com>
	<20110415101148.80cb6721.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin0r26b2JgRJkXwLxP4m5HGAaxH=A@mail.gmail.com>
	<20110415171437.098392da.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 15 Apr 2011 11:00:08 -0700
Message-ID: <BANLkTi=wV7qfVnic2chx40rLCR5Wiwhhwg@mail.gmail.com>
Subject: Re: [PATCH V4 06/10] Per-memcg background reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0cdfd082fdede604a0f8cf65
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0cdfd082fdede604a0f8cf65
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 15, 2011 at 1:14 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 14 Apr 2011 23:08:40 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Thu, Apr 14, 2011 at 6:11 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> > >
> > > As you know, memcg works against user's memory, memory should be in
> highmem
> > > zone.
> > > Memcg-kswapd is not for memory-shortage, but for voluntary page
> dropping by
> > > _user_.
> > >
> >
> > in some sense, yes. but it would also related to memory-shortage on fully
> > packed machines.
> >
>
> No. _at this point_, this is just for freeing volutary before hitting limit
> to gain performance. Anyway, this understainding is not affecting the patch
> itself.
>
> > >
> > > If this memcg-kswapd drops pages from lower zones first, ah, ok, it's
> good
> > > for
> > > the system because memcg's pages should be on higher zone if we have
> free
> > > memory.
> > >
> > > So, I think the reason for dma->highmem is different from global
> kswapd.
> > >
> >
> > yes. I agree that the logic of dma->highmem ordering is not exactly the
> same
> > from per-memcg kswapd and per-node kswapd. But still the page allocation
> > happens on the other side, and this is still good for the system as you
> > pointed out.
> >
> > >
> > >
> > >
> > >
> > > > +     for (i = 0; i < pgdat->nr_zones; i++) {
> > > > +             struct zone *zone = pgdat->node_zones + i;
> > > > +
> > > > +             if (!populated_zone(zone))
> > > > +                     continue;
> > > > +
> > > > +             sc->nr_scanned = 0;
> > > > +             shrink_zone(priority, zone, sc);
> > > > +             total_scanned += sc->nr_scanned;
> > > > +
> > > > +             /*
> > > > +              * If we've done a decent amount of scanning and
> > > > +              * the reclaim ratio is low, start doing writepage
> > > > +              * even in laptop mode
> > > > +              */
> > > > +             if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
> > > > +                 total_scanned > sc->nr_reclaimed + sc->nr_reclaimed
> /
> > > 2) {
> > > > +                     sc->may_writepage = 1;
> > > > +             }
> > > > +     }
> > > > +
> > > > +     sc->nr_scanned = total_scanned;
> > > > +     return;
> > > > +}
> > > > +
> > > > +/*
> > > > + * Per cgroup background reclaim.
> > > > + * TODO: Take off the order since memcg always do order 0
> > > > + */
> > > > +static unsigned long balance_mem_cgroup_pgdat(struct mem_cgroup
> > > *mem_cont,
> > > > +                                           int order)
> > > > +{
> > > > +     int i, nid;
> > > > +     int start_node;
> > > > +     int priority;
> > > > +     bool wmark_ok;
> > > > +     int loop;
> > > > +     pg_data_t *pgdat;
> > > > +     nodemask_t do_nodes;
> > > > +     unsigned long total_scanned;
> > > > +     struct scan_control sc = {
> > > > +             .gfp_mask = GFP_KERNEL,
> > > > +             .may_unmap = 1,
> > > > +             .may_swap = 1,
> > > > +             .nr_to_reclaim = ULONG_MAX,
> > > > +             .swappiness = vm_swappiness,
> > > > +             .order = order,
> > > > +             .mem_cgroup = mem_cont,
> > > > +     };
> > > > +
> > > > +loop_again:
> > > > +     do_nodes = NODE_MASK_NONE;
> > > > +     sc.may_writepage = !laptop_mode;
> > >
> > > I think may_writepage should start from '0' always. We're not sure
> > > the system is in memory shortage...we just want to release memory
> > > volunatary. write_page will add huge costs, I guess.
> > >
> > > For exmaple,
> > >        sc.may_writepage = !!loop
> > > may be better for memcg.
> > >
> > > BTW, you set nr_to_reclaim as ULONG_MAX here and doesn't modify it
> later.
> > >
> > > I think you should add some logic to fix it to right value.
> > >
> > > For example, before calling shrink_zone(),
> > >
> > > sc->nr_to_reclaim = min(SWAP_CLUSETR_MAX, memcg_usage_in_this_zone() /
> > > 100);  # 1% in this zone.
> > >
> > > if we love 'fair pressure for each zone'.
> > >
> >
> > Hmm. I don't get it. Leaving the nr_to_reclaim to be ULONG_MAX in kswapd
> > case which is intended to add equal memory pressure for each zone.
>
> And it need to reclaim memory from the zone.
> memcg can visit other zone/node because it's not work for zone/pgdat.
>
> > So in the shrink_zone, we won't bail out in the following condition:
> >
> >
> > >-------while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
> > > >------->------->------->------->-------nr[LRU_INACTIVE_FILE]) {
> > >
> >
> >  >------->-------if (nr_reclaimed >= nr_to_reclaim && priority <
> > DEF_PRIORITY)
> > >------->------->-------break;
> >
> > }
>
> Yes. So, by setting nr_to_reclaim to be proper value for a zone,
> we can visit next zone/node sooner. memcg's kswapd is not requrested to
> free memory from a node/zone. (But we'll need a hint for bias, later.)
>
> By making nr_reclaimed to be ULONG_MAX, to quit this loop, we need to
> loop until all nr[lru] to be 0. When memcg kswapd finds that memcg's usage
> is difficult to be reduced under high_wmark, priority goes up dramatically
> and we'll see long loop in this zone if zone is busy.
>
> For memcg kswapd, it can visit next zone rather than loop more. Then,
> we'll be able to reduce cpu usage and contention by memcg_kswapd.
>
> I think this do-more/skip-and-next logic will be a difficult issue
> and need to be maintained with long time research. For now, I bet
> ULONG_MAX is not a choice. As usual try_to_free_page() does,
> SWAP_CLUSTER_MAX will be enough. As it is, we can visit next node.
>

fair enough and make sense. I will make the change on the next post.

--Ying

>
> Thanks,
> -Kame
>
>
>
>

--000e0cdfd082fdede604a0f8cf65
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 15, 2011 at 1:14 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
On Thu, 14 Apr 2011 23:08:40 -0700<br>
<div class=3D"im">Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
</div><div class=3D"im">&gt; On Thu, Apr 14, 2011 at 6:11 PM, KAMEZAWA Hiro=
yuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
<br>
&gt; &gt;<br>
</div><div class=3D"im">&gt; &gt; As you know, memcg works against user&#39=
;s memory, memory should be in highmem<br>
&gt; &gt; zone.<br>
&gt; &gt; Memcg-kswapd is not for memory-shortage, but for voluntary page d=
ropping by<br>
&gt; &gt; _user_.<br>
&gt; &gt;<br>
&gt;<br>
&gt; in some sense, yes. but it would also related to memory-shortage on fu=
lly<br>
&gt; packed machines.<br>
&gt;<br>
<br>
</div>No. _at this point_, this is just for freeing volutary before hitting=
 limit<br>
to gain performance. Anyway, this understainding is not affecting the patch=
<br>
itself.<br>
<div><div></div><div class=3D"h5"><br>
&gt; &gt;<br>
&gt; &gt; If this memcg-kswapd drops pages from lower zones first, ah, ok, =
it&#39;s good<br>
&gt; &gt; for<br>
&gt; &gt; the system because memcg&#39;s pages should be on higher zone if =
we have free<br>
&gt; &gt; memory.<br>
&gt; &gt;<br>
&gt; &gt; So, I think the reason for dma-&gt;highmem is different from glob=
al kswapd.<br>
&gt; &gt;<br>
&gt;<br>
&gt; yes. I agree that the logic of dma-&gt;highmem ordering is not exactly=
 the same<br>
&gt; from per-memcg kswapd and per-node kswapd. But still the page allocati=
on<br>
&gt; happens on the other side, and this is still good for the system as yo=
u<br>
&gt; pointed out.<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; &gt; + =A0 =A0 for (i =3D 0; i &lt; pgdat-&gt;nr_zones; i++) {<br=
>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat-&gt;no=
de_zones + i;<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;nr_scanned =3D 0;<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 shrink_zone(priority, zone, sc);<b=
r>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D sc-&gt;nr_scann=
ed;<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we&#39;ve done a decent am=
ount of scanning and<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* the reclaim ratio is low, sta=
rt doing writepage<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0* even in laptop mode<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned &gt; SWAP_CLUSTE=
R_MAX * 2 &amp;&amp;<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned &gt; sc-&gt;=
nr_reclaimed + sc-&gt;nr_reclaimed /<br>
&gt; &gt; 2) {<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-&gt;may_writepa=
ge =3D 1;<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; &gt; &gt; + =A0 =A0 }<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; + =A0 =A0 sc-&gt;nr_scanned =3D total_scanned;<br>
&gt; &gt; &gt; + =A0 =A0 return;<br>
&gt; &gt; &gt; +}<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; +/*<br>
&gt; &gt; &gt; + * Per cgroup background reclaim.<br>
&gt; &gt; &gt; + * TODO: Take off the order since memcg always do order 0<b=
r>
&gt; &gt; &gt; + */<br>
&gt; &gt; &gt; +static unsigned long balance_mem_cgroup_pgdat(struct mem_cg=
roup<br>
&gt; &gt; *mem_cont,<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 int order)<br>
&gt; &gt; &gt; +{<br>
&gt; &gt; &gt; + =A0 =A0 int i, nid;<br>
&gt; &gt; &gt; + =A0 =A0 int start_node;<br>
&gt; &gt; &gt; + =A0 =A0 int priority;<br>
&gt; &gt; &gt; + =A0 =A0 bool wmark_ok;<br>
&gt; &gt; &gt; + =A0 =A0 int loop;<br>
&gt; &gt; &gt; + =A0 =A0 pg_data_t *pgdat;<br>
&gt; &gt; &gt; + =A0 =A0 nodemask_t do_nodes;<br>
&gt; &gt; &gt; + =A0 =A0 unsigned long total_scanned;<br>
&gt; &gt; &gt; + =A0 =A0 struct scan_control sc =3D {<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 .may_swap =3D 1,<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 .nr_to_reclaim =3D ULONG_MAX,<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 .swappiness =3D vm_swappiness,<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 .order =3D order,<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 .mem_cgroup =3D mem_cont,<br>
&gt; &gt; &gt; + =A0 =A0 };<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt; +loop_again:<br>
&gt; &gt; &gt; + =A0 =A0 do_nodes =3D NODE_MASK_NONE;<br>
&gt; &gt; &gt; + =A0 =A0 sc.may_writepage =3D !laptop_mode;<br>
&gt; &gt;<br>
&gt; &gt; I think may_writepage should start from &#39;0&#39; always. We&#3=
9;re not sure<br>
&gt; &gt; the system is in memory shortage...we just want to release memory=
<br>
&gt; &gt; volunatary. write_page will add huge costs, I guess.<br>
&gt; &gt;<br>
&gt; &gt; For exmaple,<br>
&gt; &gt; =A0 =A0 =A0 =A0sc.may_writepage =3D !!loop<br>
&gt; &gt; may be better for memcg.<br>
&gt; &gt;<br>
&gt; &gt; BTW, you set nr_to_reclaim as ULONG_MAX here and doesn&#39;t modi=
fy it later.<br>
&gt; &gt;<br>
&gt; &gt; I think you should add some logic to fix it to right value.<br>
&gt; &gt;<br>
&gt; &gt; For example, before calling shrink_zone(),<br>
&gt; &gt;<br>
&gt; &gt; sc-&gt;nr_to_reclaim =3D min(SWAP_CLUSETR_MAX, memcg_usage_in_thi=
s_zone() /<br>
&gt; &gt; 100); =A0# 1% in this zone.<br>
&gt; &gt;<br>
&gt; &gt; if we love &#39;fair pressure for each zone&#39;.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Hmm. I don&#39;t get it. Leaving the nr_to_reclaim to be ULONG_MAX in =
kswapd<br>
&gt; case which is intended to add equal memory pressure for each zone.<br>
<br>
</div></div>And it need to reclaim memory from the zone.<br>
memcg can visit other zone/node because it&#39;s not work for zone/pgdat.<b=
r>
<div class=3D"im"><br>
&gt; So in the shrink_zone, we won&#39;t bail out in the following conditio=
n:<br>
&gt;<br>
&gt;<br>
&gt; &gt;-------while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||<br>
&gt; &gt; &gt;-------&gt;-------&gt;-------&gt;-------&gt;-------nr[LRU_INA=
CTIVE_FILE]) {<br>
&gt; &gt;<br>
&gt;<br>
&gt; =A0&gt;-------&gt;-------if (nr_reclaimed &gt;=3D nr_to_reclaim &amp;&=
amp; priority &lt;<br>
&gt; DEF_PRIORITY)<br>
&gt; &gt;-------&gt;-------&gt;-------break;<br>
&gt;<br>
&gt; }<br>
<br>
</div>Yes. So, by setting nr_to_reclaim to be proper value for a zone,<br>
we can visit next zone/node sooner. memcg&#39;s kswapd is not requrested to=
<br>
free memory from a node/zone. (But we&#39;ll need a hint for bias, later.)<=
br>
<br>
By making nr_reclaimed to be ULONG_MAX, to quit this loop, we need to<br>
loop until all nr[lru] to be 0. When memcg kswapd finds that memcg&#39;s us=
age<br>
is difficult to be reduced under high_wmark, priority goes up dramatically<=
br>
and we&#39;ll see long loop in this zone if zone is busy.<br>
<br>
For memcg kswapd, it can visit next zone rather than loop more. Then,<br>
we&#39;ll be able to reduce cpu usage and contention by memcg_kswapd.<br>
<br>
I think this do-more/skip-and-next logic will be a difficult issue<br>
and need to be maintained with long time research. For now, I bet<br>
ULONG_MAX is not a choice. As usual try_to_free_page() does,<br>
SWAP_CLUSTER_MAX will be enough. As it is, we can visit next node.<br></blo=
ckquote><div><br></div><div>fair enough and make sense. I will make the cha=
nge on the next post.</div><div><br></div><div>--Ying=A0</div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex;">

<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
</blockquote></div><br>

--000e0cdfd082fdede604a0f8cf65--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
