Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3AF56B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 20:20:36 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4H0KWAl021109
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:20:33 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz37.hot.corp.google.com with ESMTP id p4H0IEI5023075
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:20:31 -0700
Received: by qyk7 with SMTP id 7so94qyk.3
        for <linux-mm@kvack.org>; Mon, 16 May 2011 17:20:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110516231028.GV16531@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
	<1305212038-15445-5-git-send-email-hannes@cmpxchg.org>
	<BANLkTi=yCyAsOc_uTQLp1kWp5w0i9gomxg@mail.gmail.com>
	<20110516231028.GV16531@cmpxchg.org>
Date: Mon, 16 May 2011 17:20:31 -0700
Message-ID: <BANLkTimLNZfc-jcA3yBG5D3k2u=0_JnrhQ@mail.gmail.com>
Subject: Re: [rfc patch 4/6] memcg: reclaim statistics
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8663e4404a36dbddf
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--002354470aa8663e4404a36dbddf
Content-Type: text/plain; charset=ISO-8859-1

On Mon, May 16, 2011 at 4:10 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, May 12, 2011 at 12:33:50PM -0700, Ying Han wrote:
> > On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner <hannes@cmpxchg.org>
> wrote:
> >
> > > TODO: write proper changelog.  Here is an excerpt from
> > > http://lkml.kernel.org/r/20110428123652.GM12437@cmpxchg.org:
> > >
> > > : 1. Limit-triggered direct reclaim
> > > :
> > > : The memory cgroup hits its limit and the task does direct reclaim
> from
> > > : its own memcg.  We probably want statistics for this separately from
> > > : background reclaim to see how successful background reclaim is, the
> > > : same reason we have this separation in the global vmstat as well.
> > > :
> > > :       pgscan_direct_limit
> > > :       pgfree_direct_limit
> > >
> >
> > Can we use "pgsteal_" instead? Not big fan of the naming but want to make
> > them consistent to other stats.
>
> Actually, I thought what KAME-san said made sense.  'Stealing' is a
> good fit for reclaim due to outside pressure.  But if the memcg is
> target-reclaimed from the inside because it hit the limit, is
> 'stealing' the appropriate term?
>
> > > : 2. Limit-triggered background reclaim
> > > :
> > > : This is the watermark-based asynchroneous reclaim that is currently
> in
> > > : discussion.  It's triggered by the memcg breaching its watermark,
> > > : which is relative to its hard-limit.  I named it kswapd because I
> > > : still think kswapd should do this job, but it is all open for
> > > : discussion, obviously.  Treat it as meaning 'background' or
> > > : 'asynchroneous'.
> > > :
> > > :       pgscan_kswapd_limit
> > > :       pgfree_kswapd_limit
> > >
> >
> > Kame might have this stats on the per-memcg bg reclaim patch. Just
> mention
> > here since it will make later merge
> > a bit harder
>
> I'll have a look, thanks for the heads up.
>
> > > : 3. Hierarchy-triggered direct reclaim
> > > :
> > > : A condition outside the memcg leads to a task directly reclaiming
> from
> > > : this memcg.  This could be global memory pressure for example, but
> > > : also a parent cgroup hitting its limit.  It's probably helpful to
> > > : assume global memory pressure meaning that the root cgroup hit its
> > > : limit, conceptually.  We don't have that yet, but this could be the
> > > : direct softlimit reclaim Ying mentioned above.
> > > :
> > > :       pgscan_direct_hierarchy
> > > :       pgsteal_direct_hierarchy
> > >
> >
> >  The stats for soft_limit reclaim from global ttfp have been merged in
> mmotm
> > i believe as the following:
> >
> > "soft_direct_steal"
> > "soft_direct_scan"
> >
> > I wonder we might want to separate that out from the other case where the
> > reclaim is from the parent triggers its limit.
>
> The way I implemented soft limits in 6/6 is to increase pressure on
> exceeding children whenever hierarchical reclaim is taking place.
>
> This changes soft limit from
>
>        Global memory pressure: reclaim from exceeding memcg(s) first
>
> to
>
>        Memory pressure on a memcg: reclaim from all its children,
>        with increased pressure on those exceeding their soft limit
>        (where global memory pressure means root_mem_cgroup and all
>        existing memcgs are considered its children)
>
> which makes the soft limit much more generic and more powerful, as it
> allows the admin to prioritize reclaim throughout the hierarchy, not
> only for global memory pressure.  Consider one memcg with two
> subgroups.  You can now prioritize reclaim to prefer one subgroup over
> another through soft limiting.
>
> This is one reason why I think that the approach of maintaining a
> global list of memcgs that exceed their soft limits is an inferior
> approach; it does not take the hierarchy into account at all.
>


This scheme would not provide a natural way of counting pages that
> were reclaimed because of the soft limit, and thus I still oppose the
> merging of soft limit counters.
>
> The proposal we discussed during LSF ( implemented in the patch " memcg:
revisit soft_limit reclaim on contention") takes consideration
of hierarchical reclaim. The memcg is linked in the list if it exceeds the
soft_limit, and the soft_limit reclaim per-memcg is calling
mem_cgroup_hierarchical_reclaim().

The current "soft_steal" and "soft_scan" is counting pages being steal/scan
 inside mem_cgroup_hierarchical_reclaim() w check_soft checking, which then
counts pages being reclaimed because of soft_limit and also counting the
hierarchical reclaim.

Sorry If i missed something before reading through your whole patch set.

--Ying

       Hannes
>

--002354470aa8663e4404a36dbddf
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Mon, May 16, 2011 at 4:10 PM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Thu, May 12, 2011 at 12:33:50PM -0700, Ying Han wrote:=
<br>
&gt; On Thu, May 12, 2011 at 7:53 AM, Johannes Weiner &lt;<a href=3D"mailto=
:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; TODO: write proper changelog. =A0Here is an excerpt from<br>
&gt; &gt; <a href=3D"http://lkml.kernel.org/r/20110428123652.GM12437@cmpxch=
g.org" target=3D"_blank">http://lkml.kernel.org/r/20110428123652.GM12437@cm=
pxchg.org</a>:<br>
&gt; &gt;<br>
&gt; &gt; : 1. Limit-triggered direct reclaim<br>
&gt; &gt; :<br>
&gt; &gt; : The memory cgroup hits its limit and the task does direct recla=
im from<br>
&gt; &gt; : its own memcg. =A0We probably want statistics for this separate=
ly from<br>
&gt; &gt; : background reclaim to see how successful background reclaim is,=
 the<br>
&gt; &gt; : same reason we have this separation in the global vmstat as wel=
l.<br>
&gt; &gt; :<br>
&gt; &gt; : =A0 =A0 =A0 pgscan_direct_limit<br>
&gt; &gt; : =A0 =A0 =A0 pgfree_direct_limit<br>
&gt; &gt;<br>
&gt;<br>
&gt; Can we use &quot;pgsteal_&quot; instead? Not big fan of the naming but=
 want to make<br>
&gt; them consistent to other stats.<br>
<br>
</div>Actually, I thought what KAME-san said made sense. =A0&#39;Stealing&#=
39; is a<br>
good fit for reclaim due to outside pressure. =A0But if the memcg is<br>
target-reclaimed from the inside because it hit the limit, is<br>
&#39;stealing&#39; the appropriate term?<br>
<div class=3D"im"><br>
&gt; &gt; : 2. Limit-triggered background reclaim<br>
&gt; &gt; :<br>
&gt; &gt; : This is the watermark-based asynchroneous reclaim that is curre=
ntly in<br>
&gt; &gt; : discussion. =A0It&#39;s triggered by the memcg breaching its wa=
termark,<br>
&gt; &gt; : which is relative to its hard-limit. =A0I named it kswapd becau=
se I<br>
&gt; &gt; : still think kswapd should do this job, but it is all open for<b=
r>
&gt; &gt; : discussion, obviously. =A0Treat it as meaning &#39;background&#=
39; or<br>
&gt; &gt; : &#39;asynchroneous&#39;.<br>
&gt; &gt; :<br>
&gt; &gt; : =A0 =A0 =A0 pgscan_kswapd_limit<br>
&gt; &gt; : =A0 =A0 =A0 pgfree_kswapd_limit<br>
&gt; &gt;<br>
&gt;<br>
&gt; Kame might have this stats on the per-memcg bg reclaim patch. Just men=
tion<br>
&gt; here since it will make later merge<br>
&gt; a bit harder<br>
<br>
</div>I&#39;ll have a look, thanks for the heads up.<br>
<div class=3D"im"><br>
&gt; &gt; : 3. Hierarchy-triggered direct reclaim<br>
&gt; &gt; :<br>
&gt; &gt; : A condition outside the memcg leads to a task directly reclaimi=
ng from<br>
&gt; &gt; : this memcg. =A0This could be global memory pressure for example=
, but<br>
&gt; &gt; : also a parent cgroup hitting its limit. =A0It&#39;s probably he=
lpful to<br>
&gt; &gt; : assume global memory pressure meaning that the root cgroup hit =
its<br>
&gt; &gt; : limit, conceptually. =A0We don&#39;t have that yet, but this co=
uld be the<br>
&gt; &gt; : direct softlimit reclaim Ying mentioned above.<br>
&gt; &gt; :<br>
&gt; &gt; : =A0 =A0 =A0 pgscan_direct_hierarchy<br>
&gt; &gt; : =A0 =A0 =A0 pgsteal_direct_hierarchy<br>
&gt; &gt;<br>
&gt;<br>
&gt; =A0The stats for soft_limit reclaim from global ttfp have been merged =
in mmotm<br>
&gt; i believe as the following:<br>
&gt;<br>
&gt; &quot;soft_direct_steal&quot;<br>
&gt; &quot;soft_direct_scan&quot;<br>
&gt;<br>
&gt; I wonder we might want to separate that out from the other case where =
the<br>
&gt; reclaim is from the parent triggers its limit.<br>
<br>
</div>The way I implemented soft limits in 6/6 is to increase pressure on<b=
r>
exceeding children whenever hierarchical reclaim is taking place.<br>
<br>
This changes soft limit from<br>
<br>
 =A0 =A0 =A0 =A0Global memory pressure: reclaim from exceeding memcg(s) fir=
st<br>
<br>
to<br>
<br>
 =A0 =A0 =A0 =A0Memory pressure on a memcg: reclaim from all its children,<=
br>
 =A0 =A0 =A0 =A0with increased pressure on those exceeding their soft limit=
<br>
 =A0 =A0 =A0 =A0(where global memory pressure means root_mem_cgroup and all=
<br>
 =A0 =A0 =A0 =A0existing memcgs are considered its children)<br>
<br>
which makes the soft limit much more generic and more powerful, as it<br>
allows the admin to prioritize reclaim throughout the hierarchy, not<br>
only for global memory pressure. =A0Consider one memcg with two<br>
subgroups. =A0You can now prioritize reclaim to prefer one subgroup over<br=
>
another through soft limiting.<br>
<br>
This is one reason why I think that the approach of maintaining a<br>
global list of memcgs that exceed their soft limits is an inferior<br>
approach; it does not take the hierarchy into account at all.<br></blockquo=
te><div><br></div><div><br></div><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">This schem=
e would not provide a natural way of counting pages that<br>

were reclaimed because of the soft limit, and thus I still oppose the<br>
merging of soft limit counters.<br>
<br></blockquote><meta http-equiv=3D"content-type" content=3D"text/html; ch=
arset=3Dutf-8"><div>The proposal we discussed during LSF ( implemented in t=
he patch &quot; memcg: revisit soft_limit reclaim on contention&quot;) take=
s consideration of=A0hierarchical=A0reclaim. The memcg is linked in the lis=
t if it exceeds the</div>
<div>soft_limit, and the soft_limit reclaim per-memcg is calling mem_cgroup=
_hierarchical_reclaim().=A0</div><div><br></div><div>The current &quot;soft=
_steal&quot; and &quot;soft_scan&quot; is counting pages being steal/scan =
=A0inside mem_cgroup_hierarchical_reclaim() w check_soft checking, which th=
en counts pages being reclaimed because of soft_limit and also counting the=
 hierarchical reclaim.=A0</div>
<div><br></div><div>Sorry If i missed something before reading through your=
 whole patch set.</div><div><br></div><div>--Ying</div><div><br></div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #cc=
c solid;padding-left:1ex;">

 =A0 =A0 =A0 =A0Hannes<br>
</blockquote></div><br>

--002354470aa8663e4404a36dbddf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
