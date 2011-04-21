Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED8E8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 01:28:28 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3L5SOPn007190
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:28:24 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by wpaz21.hot.corp.google.com with ESMTP id p3L5SD8G007531
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:28:22 -0700
Received: by qwk3 with SMTP id 3so681234qwk.19
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:28:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421050851.GI2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421050851.GI2333@cmpxchg.org>
Date: Wed, 20 Apr 2011 22:28:17 -0700
Message-ID: <BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefda2f017a04a167021d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016e64aefda2f017a04a167021d
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 10:08 PM, Johannes Weiner <hannes@cmpxchg.org>wrote:

> On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 21 Apr 2011 04:51:07 +0200
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> >
> > > > If the cgroup is configured to use per cgroup background reclaim, a
> kswapd
> > > > thread is created which only scans the per-memcg LRU list.
> > >
> > > We already have direct reclaim, direct reclaim on behalf of a memcg,
> > > and global kswapd-reclaim.  Please don't add yet another reclaim path
> > > that does its own thing and interacts unpredictably with the rest of
> > > them.
> > >
> > > As discussed on LSF, we want to get rid of the global LRU.  So the
> > > goal is to have each reclaim entry end up at the same core part of
> > > reclaim that round-robin scans a subset of zones from a subset of
> > > memory control groups.
> >
> > It's not related to this set. And I think even if we remove global LRU,
> > global-kswapd and memcg-kswapd need to do independent work.
> >
> > global-kswapd : works for zone/node balancing and making free pages,
> >                 and compaction. select a memcg vicitm and ask it
> >                 to reduce memory with regard to gfp_mask. Starts its work
> >                 when zone/node is unbalanced.
>
> For soft limit reclaim (which is triggered by global memory pressure),
> we want to scan a group of memory cgroups equally in round robin
> fashion.  I think at LSF we established that it is not fair to find
> the one that exceeds its limit the most and hammer it until memory
> pressure is resolved or there is another group with more excess.
>
> So even for global kswapd, sooner or later we need a mechanism to
> apply equal pressure to a set of memcgs.
>
> With the removal of the global LRU, we ALWAYS operate on a set of
> memcgs in a round-robin fashion, not just for soft limit reclaim.
>
> So yes, these are two different things, but they have the same
> requirements.
>

Hmm. I don't see we have disagreement on the global-kswapd. The plan now is
to do the round-robin based
on their soft_limit. (note, this is not how it is implemented now, and I am
working on the patch now)

>
> > memcg-kswapd  : works for reducing usage of memory, no interests on
> >                 zone/nodes. Starts when high/low watermaks hits.
>
> When the watermark is hit in the charge path, we want to wake up the
> daemon to reclaim from a specific memcg.
>
> When multiple memcgs exceed their watermarks in parallel (after all,
> we DO allow concurrency), we again have a group of memcgs we want to
> reclaim from in a fair fashion until their watermarks are met again.
>
> And memcg reclaim is not oblivious to nodes and zones, right now, we
> also do mind the current node and respect the zone balancing when we
> do direct reclaim on behalf of a memcg.
>
> So, to be honest, I really don't see how both cases should be
> independent from each other.  On the contrary, I see very little
> difference between them.  The entry path differs slightly as well as
> the predicate for the set of memcgs to scan.  But most of the worker
> code is exactly the same, no?
>

They are triggered at different point and the target are different. One is
triggered under global pressure,
and the calculation of which memcg and how much to reclaim are based on
soft_limit. Also, the target is to bring the zone under the wmark, as well
as the zone balancing. The other one is triggered per-memcg on wmarks, and
the target is to bring the memcg usage below the wmark.

>
> > > > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > > > background reclaim and stop it. The watermarks are calculated based
> > > > on the cgroup's limit_in_bytes.
> > >
> > > Which brings me to the next issue: making the watermarks configurable.
> > >
> > > You argued that having them adjustable from userspace is required for
> > > overcommitting the hardlimits and per-memcg kswapd reclaim not kicking
> > > in in case of global memory pressure.  But that is only a problem
> > > because global kswapd reclaim is (apart from soft limit reclaim)
> > > unaware of memory control groups.
> > >
> > > I think the much better solution is to make global kswapd memcg aware
> > > (with the above mentioned round-robin reclaim scheduler), compared to
> > > adding new (and final!) kernel ABI to avoid an internal shortcoming.
> >
> > I don't think its a good idea to kick kswapd even when free memory is
> enough.
>
> This depends on what kswapd is supposed to be doing.  I don't say we
> should reclaim from all memcgs (i.e. globally) just because one memcg
> hits its watermark, of course.
>
> But the argument was that we need the watermarks configurable to force
> per-memcg reclaim even when the hard limits are overcommitted, because
> global reclaim does not do a fair job to balance memcgs.


There seems to be some confusion here. The watermark we defined is
per-memcg, and that is calculated
based on the hard_limit. We need the per-memcg wmark the same reason of
per-zone wmart which triggers
the background reclaim before direct reclaim.

There is a patch in my patchset which adds the tunable for both
high/low_mark, which gives more flexibility to admin to config the host. In
over-commit environment, we might never hit the wmark if all the wmarks are
set internally.

My counter proposal is to fix global reclaim instead and apply equal
pressure on memcgs, such that we never have to tweak per-memcg watermarks
to achieve the same thing.

We still need this and that is the soft_limit reclaim under global
background reclaim.

--Ying

--0016e64aefda2f017a04a167021d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 10:08 PM, Johann=
es Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hanne=
s@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyu=
ki wrote:<br>
&gt; On Thu, 21 Apr 2011 04:51:07 +0200<br>
&gt; Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@cmpxc=
hg.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; &gt; If the cgroup is configured to use per cgroup background rec=
laim, a kswapd<br>
&gt; &gt; &gt; thread is created which only scans the per-memcg LRU list.<b=
r>
&gt; &gt;<br>
&gt; &gt; We already have direct reclaim, direct reclaim on behalf of a mem=
cg,<br>
&gt; &gt; and global kswapd-reclaim. =A0Please don&#39;t add yet another re=
claim path<br>
&gt; &gt; that does its own thing and interacts unpredictably with the rest=
 of<br>
&gt; &gt; them.<br>
&gt; &gt;<br>
&gt; &gt; As discussed on LSF, we want to get rid of the global LRU. =A0So =
the<br>
&gt; &gt; goal is to have each reclaim entry end up at the same core part o=
f<br>
&gt; &gt; reclaim that round-robin scans a subset of zones from a subset of=
<br>
&gt; &gt; memory control groups.<br>
&gt;<br>
&gt; It&#39;s not related to this set. And I think even if we remove global=
 LRU,<br>
&gt; global-kswapd and memcg-kswapd need to do independent work.<br>
&gt;<br>
&gt; global-kswapd : works for zone/node balancing and making free pages,<b=
r>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 and compaction. select a memcg vicitm =
and ask it<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 to reduce memory with regard to gfp_ma=
sk. Starts its work<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 when zone/node is unbalanced.<br>
<br>
</div>For soft limit reclaim (which is triggered by global memory pressure)=
,<br>
we want to scan a group of memory cgroups equally in round robin<br>
fashion. =A0I think at LSF we established that it is not fair to find<br>
the one that exceeds its limit the most and hammer it until memory<br>
pressure is resolved or there is another group with more excess.<br>
<br>
So even for global kswapd, sooner or later we need a mechanism to<br>
apply equal pressure to a set of memcgs.<br>
<br>
With the removal of the global LRU, we ALWAYS operate on a set of<br>
memcgs in a round-robin fashion, not just for soft limit reclaim.<br>
<br>
So yes, these are two different things, but they have the same<br>
requirements.<br></blockquote><div><br></div><div>Hmm. I don&#39;t see we h=
ave disagreement on the global-kswapd. The plan now is to do the round-robi=
n based</div><div>on their soft_limit. (note, this is not how it is impleme=
nted now, and I am working on the patch now)</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; memcg-kswapd =A0: works for reducing usage of memory, no interests on<=
br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone/nodes. Starts when high/low water=
maks hits.<br>
<br>
</div>When the watermark is hit in the charge path, we want to wake up the<=
br>
daemon to reclaim from a specific memcg.<br>
<br>
When multiple memcgs exceed their watermarks in parallel (after all,<br>
we DO allow concurrency), we again have a group of memcgs we want to<br>
reclaim from in a fair fashion until their watermarks are met again.<br>
<br>
And memcg reclaim is not oblivious to nodes and zones, right now, we<br>
also do mind the current node and respect the zone balancing when we<br>
do direct reclaim on behalf of a memcg.<br>
<br>
So, to be honest, I really don&#39;t see how both cases should be<br>
independent from each other. =A0On the contrary, I see very little<br>
difference between them. =A0The entry path differs slightly as well as<br>
the predicate for the set of memcgs to scan. =A0But most of the worker<br>
code is exactly the same, no?<br></blockquote><div><br></div><div>They are =
triggered at different point and the target are different. One is triggered=
 under global pressure,</div><div>and the calculation of which memcg and ho=
w much to reclaim are based on soft_limit. Also, the target is to bring the=
 zone under the wmark, as well as the zone balancing. The other one is=A0tr=
iggered per-memcg on wmarks, and the target is to bring the memcg usage bel=
ow the wmark.=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; &gt; &gt; Two watermarks (&quot;high_wmark&quot;, &quot;low_wmark&quot=
;) are added to trigger the<br>
&gt; &gt; &gt; background reclaim and stop it. The watermarks are calculate=
d based<br>
&gt; &gt; &gt; on the cgroup&#39;s limit_in_bytes.<br>
&gt; &gt;<br>
&gt; &gt; Which brings me to the next issue: making the watermarks configur=
able.<br>
&gt; &gt;<br>
&gt; &gt; You argued that having them adjustable from userspace is required=
 for<br>
&gt; &gt; overcommitting the hardlimits and per-memcg kswapd reclaim not ki=
cking<br>
&gt; &gt; in in case of global memory pressure. =A0But that is only a probl=
em<br>
&gt; &gt; because global kswapd reclaim is (apart from soft limit reclaim)<=
br>
&gt; &gt; unaware of memory control groups.<br>
&gt; &gt;<br>
&gt; &gt; I think the much better solution is to make global kswapd memcg a=
ware<br>
&gt; &gt; (with the above mentioned round-robin reclaim scheduler), compare=
d to<br>
&gt; &gt; adding new (and final!) kernel ABI to avoid an internal shortcomi=
ng.<br>
&gt;<br>
&gt; I don&#39;t think its a good idea to kick kswapd even when free memory=
 is enough.<br>
<br>
</div>This depends on what kswapd is supposed to be doing. =A0I don&#39;t s=
ay we<br>
should reclaim from all memcgs (i.e. globally) just because one memcg<br>
hits its watermark, of course.<br>
<br>
But the argument was that we need the watermarks configurable to force<br>
per-memcg reclaim even when the hard limits are overcommitted, because<br>
global reclaim does not do a fair job to balance memcgs.</blockquote><div>=
=A0</div><div>There seems to be some confusion here. The watermark we defin=
ed is per-memcg, and that is calculated</div><div>based on the hard_limit. =
We need the per-memcg wmark the same reason of per-zone wmart which trigger=
s</div>
<div>the background reclaim before direct reclaim.=A0</div><div><br></div><=
div>There is a patch in my patchset which adds the tunable for both high/lo=
w_mark, which gives more flexibility to admin to config the host. In over-c=
ommit=A0environment, we might never hit the wmark if all the wmarks are set=
 internally.=A0</div>
<div><br></div><div><meta http-equiv=3D"content-type" content=3D"text/html;=
 charset=3Dutf-8"><span class=3D"Apple-style-span" style=3D"border-collapse=
: collapse; font-family: arial, sans-serif; font-size: 13px; ">My counter=
=A0proposal is to fix global reclaim instead and apply equal pressure on=A0=
memcgs, such that we never have to tweak per-memcg watermarks to=A0achieve =
the same thing.</span></div>
<div><span class=3D"Apple-style-span" style=3D"border-collapse: collapse; f=
ont-family: arial, sans-serif; font-size: 13px; "><br></span></div><div><sp=
an class=3D"Apple-style-span" style=3D"border-collapse: collapse; font-fami=
ly: arial, sans-serif; font-size: 13px; ">We still need this and that is th=
e soft_limit reclaim under global background reclaim.</span></div>
<div><span class=3D"Apple-style-span" style=3D"border-collapse: collapse; f=
ont-family: arial, sans-serif; font-size: 13px; "><br></span></div><div><sp=
an class=3D"Apple-style-span" style=3D"border-collapse: collapse; font-fami=
ly: arial, sans-serif; font-size: 13px; ">--Ying</span></div>
</div>

--0016e64aefda2f017a04a167021d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
