Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B6C3F8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:23:47 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p3L6NfQP027477
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:23:41 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by hpaq7.eem.corp.google.com with ESMTP id p3L6NdiA024302
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:23:40 -0700
Received: by qwb8 with SMTP id 8so1188599qwb.11
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:23:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421144156.fc1ce9ec.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421050851.GI2333@cmpxchg.org>
	<20110421144156.fc1ce9ec.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 20 Apr 2011 23:23:38 -0700
Message-ID: <BANLkTimi-hM6Qr0Pqjw7gh5KqGeaO5zVAg@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa82adc1104a167c824
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470aa82adc1104a167c824
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 10:41 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 21 Apr 2011 07:08:51 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> > On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 21 Apr 2011 04:51:07 +0200
> > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > >
> > > > > If the cgroup is configured to use per cgroup background reclaim, a
> kswapd
> > > > > thread is created which only scans the per-memcg LRU list.
> > > >
> > > > We already have direct reclaim, direct reclaim on behalf of a memcg,
> > > > and global kswapd-reclaim.  Please don't add yet another reclaim path
> > > > that does its own thing and interacts unpredictably with the rest of
> > > > them.
> > > >
> > > > As discussed on LSF, we want to get rid of the global LRU.  So the
> > > > goal is to have each reclaim entry end up at the same core part of
> > > > reclaim that round-robin scans a subset of zones from a subset of
> > > > memory control groups.
> > >
> > > It's not related to this set. And I think even if we remove global LRU,
> > > global-kswapd and memcg-kswapd need to do independent work.
> > >
> > > global-kswapd : works for zone/node balancing and making free pages,
> > >                 and compaction. select a memcg vicitm and ask it
> > >                 to reduce memory with regard to gfp_mask. Starts its
> work
> > >                 when zone/node is unbalanced.
> >
> > For soft limit reclaim (which is triggered by global memory pressure),
> > we want to scan a group of memory cgroups equally in round robin
> > fashion.  I think at LSF we established that it is not fair to find
> > the one that exceeds its limit the most and hammer it until memory
> > pressure is resolved or there is another group with more excess.
> >
>
> Why do you guys like to make a mixture discussion of softlimit and
> high/low watermarks ?
>
> Yes, we've been talking about soft_limit discussion in LSF but I haven't
mentioned this per-memcg-kswapd
effort enough. They are indeed independent effort.

>
> > So even for global kswapd, sooner or later we need a mechanism to
> > apply equal pressure to a set of memcgs.
> >
>
> yes, please do rework.
>
>
> > With the removal of the global LRU, we ALWAYS operate on a set of
> > memcgs in a round-robin fashion, not just for soft limit reclaim.
> >
> > So yes, these are two different things, but they have the same
> > requirements.
> >
>
> Please do make changes all again.
>
>
> > > memcg-kswapd  : works for reducing usage of memory, no interests on
> > >                 zone/nodes. Starts when high/low watermaks hits.
> >
> > When the watermark is hit in the charge path, we want to wake up the
> > daemon to reclaim from a specific memcg.
> >
> > When multiple memcgs exceed their watermarks in parallel (after all,
> > we DO allow concurrency), we again have a group of memcgs we want to
> > reclaim from in a fair fashion until their watermarks are met again.
> >
>
> It's never be reason to make kswapd wake up.
>
>
> > And memcg reclaim is not oblivious to nodes and zones, right now, we
> > also do mind the current node and respect the zone balancing when we
> > do direct reclaim on behalf of a memcg.
> >
> If you find problem, please fix.
>
>
> > So, to be honest, I really don't see how both cases should be
> > independent from each other.  On the contrary, I see very little
> > difference between them.  The entry path differs slightly as well as
> > the predicate for the set of memcgs to scan.  But most of the worker
> > code is exactly the same, no?
> >
>
> No. memcg-background-reclaim will need to have more better algorithm
> finally
> as using file/anon ratio, swapiness, dirty-ratio on memecg. And it works
> as a service for helping performance by kernel.
>
> global-background-reclaim will need to depends on global file/anon ratio
> and swapiness, dirty-ratio. This works as a service for maintaining free
> memory, by kernel.
>
> I don't want to make mixture here until we convice we can do that.
>
> memcg-kswapd does.
>  1. pick up memcg
>  2. do scan and reclaim
>
> global-kswapd does
>  1. pick up zone.
>  2. pick up suitable memcg for reclaiming this zone's page
>  3. check zone balancing.
>
> We _may_ be able to finally merge them, but I'm unsure. Total rework after
> implementing nicely-work-memcg-kswapd is welcomed.
>
> I want to fix problems one by one. Reworking around this at removing LRU is
> not heavy burden, but will be a interesting job. At rework,
> global kswapd/global direct-reclaim need to consider
>  - get free memory
>  - compaction of multi-order pages.
>
this is interesting part. we don't deal w/ high order page reclaim in memcg.
So, there will be no lumpy reclaim in the soft_limit reclaim under global
kswapd. I also mentioned that in:
http://permalink.gmane.org/gmane.linux.kernel.mm/60966


>  - balancing zones
>

this should be covered in current soft_limit reclaim proposal above. don't
want to go to much detail in this thread.

 - balancing nodes
>
not sure about this.


>  - OOM.
>  + balancing memcgs (with softlimit) and LRU ordering
>

agree, and i would like to start with round-robin.


>  + dirty-ratio (it may be better to avoid picking busy memcg by kswapd.)
>  + hi/low watermak (if you want).
>

 I assume this is the zone wmarks.

>
> "+" is new things added by memcg.
> We need to establish each ones and needs performance/statistics check for
> each.
>
> I don't think we can implement them all perfectly with a rush. I think I'll
> see unexpected problems on my way to realistic solution
>

I will review the 3 patch you just posted and test them with my V7.

--Ying

>
> > > > > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > > > > background reclaim and stop it. The watermarks are calculated based
> > > > > on the cgroup's limit_in_bytes.
> > > >
> > > > Which brings me to the next issue: making the watermarks
> configurable.
> > > >
> > > > You argued that having them adjustable from userspace is required for
> > > > overcommitting the hardlimits and per-memcg kswapd reclaim not
> kicking
> > > > in in case of global memory pressure.  But that is only a problem
> > > > because global kswapd reclaim is (apart from soft limit reclaim)
> > > > unaware of memory control groups.
> > > >
> > > > I think the much better solution is to make global kswapd memcg aware
> > > > (with the above mentioned round-robin reclaim scheduler), compared to
> > > > adding new (and final!) kernel ABI to avoid an internal shortcoming.
> > >
> > > I don't think its a good idea to kick kswapd even when free memory is
> enough.
> >
> > This depends on what kswapd is supposed to be doing.  I don't say we
> > should reclaim from all memcgs (i.e. globally) just because one memcg
> > hits its watermark, of course.
> >
> > But the argument was that we need the watermarks configurable to force
> > per-memcg reclaim even when the hard limits are overcommitted, because
> > global reclaim does not do a fair job to balance memcgs.
>
> I cannot understand here. Why global reclaim need to do works other than
> balancing zones ? And what is balancing memcg ? Mentioning softlimit ?
>
> > My counter
> > proposal is to fix global reclaim instead and apply equal pressure on
> > memcgs, such that we never have to tweak per-memcg watermarks to
> > achieve the same thing.
> >
>
> I cannot undestand this, either. Don't you make a mixture of discussion
> with softlimit ? Making global kswapd better is another discussion.
>
> Hi/Low watermak is a feature as it is. It the 3rd way to limit memory
> usage. Comaparing hard_limit, soft_limit, it works in moderate way in
> background
> and works regardless of usage of global memory. I think it's valid to have
> ineterfaces to tuning this.
>
>
> Thanks,
> -Kame
>
>
>
>

--002354470aa82adc1104a167c824
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 10:41 PM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
On Thu, 21 Apr 2011 07:08:51 +0200<br>
<div><div></div><div class=3D"h5">Johannes Weiner &lt;<a href=3D"mailto:han=
nes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
<br>
&gt; On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyuki wrote:<br>
&gt; &gt; On Thu, 21 Apr 2011 04:51:07 +0200<br>
&gt; &gt; Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@=
cmpxchg.org</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; &gt; If the cgroup is configured to use per cgroup backgroun=
d reclaim, a kswapd<br>
&gt; &gt; &gt; &gt; thread is created which only scans the per-memcg LRU li=
st.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; We already have direct reclaim, direct reclaim on behalf of =
a memcg,<br>
&gt; &gt; &gt; and global kswapd-reclaim. =A0Please don&#39;t add yet anoth=
er reclaim path<br>
&gt; &gt; &gt; that does its own thing and interacts unpredictably with the=
 rest of<br>
&gt; &gt; &gt; them.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; As discussed on LSF, we want to get rid of the global LRU. =
=A0So the<br>
&gt; &gt; &gt; goal is to have each reclaim entry end up at the same core p=
art of<br>
&gt; &gt; &gt; reclaim that round-robin scans a subset of zones from a subs=
et of<br>
&gt; &gt; &gt; memory control groups.<br>
&gt; &gt;<br>
&gt; &gt; It&#39;s not related to this set. And I think even if we remove g=
lobal LRU,<br>
&gt; &gt; global-kswapd and memcg-kswapd need to do independent work.<br>
&gt; &gt;<br>
&gt; &gt; global-kswapd : works for zone/node balancing and making free pag=
es,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 and compaction. select a memcg vi=
citm and ask it<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 to reduce memory with regard to g=
fp_mask. Starts its work<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 when zone/node is unbalanced.<br>
&gt;<br>
&gt; For soft limit reclaim (which is triggered by global memory pressure),=
<br>
&gt; we want to scan a group of memory cgroups equally in round robin<br>
&gt; fashion. =A0I think at LSF we established that it is not fair to find<=
br>
&gt; the one that exceeds its limit the most and hammer it until memory<br>
&gt; pressure is resolved or there is another group with more excess.<br>
&gt;<br>
<br>
</div></div>Why do you guys like to make a mixture discussion of softlimit =
and<br>
high/low watermarks ?<br>
<div class=3D"im"><br></div></blockquote><div>Yes, we&#39;ve been talking a=
bout soft_limit discussion in LSF but I haven&#39;t mentioned this per-memc=
g-kswapd</div><div>effort enough. They are indeed independent effort.=A0</d=
iv>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div class=3D"im">
<br>
&gt; So even for global kswapd, sooner or later we need a mechanism to<br>
&gt; apply equal pressure to a set of memcgs.<br>
&gt;<br>
<br>
</div>yes, please do rework.<br>
<div class=3D"im"><br>
<br>
&gt; With the removal of the global LRU, we ALWAYS operate on a set of<br>
&gt; memcgs in a round-robin fashion, not just for soft limit reclaim.<br>
&gt;<br>
&gt; So yes, these are two different things, but they have the same<br>
&gt; requirements.<br>
&gt;<br>
<br>
</div>Please do make changes all again.<br>
<div class=3D"im"><br>
<br>
&gt; &gt; memcg-kswapd =A0: works for reducing usage of memory, no interest=
s on<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone/nodes. Starts when high/low =
watermaks hits.<br>
&gt;<br>
&gt; When the watermark is hit in the charge path, we want to wake up the<b=
r>
&gt; daemon to reclaim from a specific memcg.<br>
&gt;<br>
&gt; When multiple memcgs exceed their watermarks in parallel (after all,<b=
r>
&gt; we DO allow concurrency), we again have a group of memcgs we want to<b=
r>
&gt; reclaim from in a fair fashion until their watermarks are met again.<b=
r>
&gt;<br>
<br>
</div>It&#39;s never be reason to make kswapd wake up.<br>
<div class=3D"im"><br>
<br>
&gt; And memcg reclaim is not oblivious to nodes and zones, right now, we<b=
r>
&gt; also do mind the current node and respect the zone balancing when we<b=
r>
&gt; do direct reclaim on behalf of a memcg.<br>
&gt;<br>
</div>If you find problem, please fix.<br>
<div class=3D"im"><br>
<br>
&gt; So, to be honest, I really don&#39;t see how both cases should be<br>
&gt; independent from each other. =A0On the contrary, I see very little<br>
&gt; difference between them. =A0The entry path differs slightly as well as=
<br>
&gt; the predicate for the set of memcgs to scan. =A0But most of the worker=
<br>
&gt; code is exactly the same, no?<br>
&gt;<br>
<br>
</div>No. memcg-background-reclaim will need to have more better algorithm =
finally<br>
as using file/anon ratio, swapiness, dirty-ratio on memecg. And it works<br=
>
as a service for helping performance by kernel.<br>
<br>
global-background-reclaim will need to depends on global file/anon ratio<br=
>
and swapiness, dirty-ratio. This works as a service for maintaining free<br=
>
memory, by kernel.<br>
<br>
I don&#39;t want to make mixture here until we convice we can do that.<br>
<br>
memcg-kswapd does.<br>
=A01. pick up memcg<br>
=A02. do scan and reclaim<br>
<br>
global-kswapd does<br>
=A01. pick up zone.<br>
=A02. pick up suitable memcg for reclaiming this zone&#39;s page<br>
=A03. check zone balancing.<br>
<br>
We _may_ be able to finally merge them, but I&#39;m unsure. Total rework af=
ter<br>
implementing nicely-work-memcg-kswapd is welcomed.<br>
<br>
I want to fix problems one by one. Reworking around this at removing LRU is=
<br>
not heavy burden, but will be a interesting job. At rework,<br>
global kswapd/global direct-reclaim need to consider<br>
 =A0- get free memory<br>
 =A0- compaction of multi-order pages.<br></blockquote><div>this is interes=
ting part. we don&#39;t deal w/ high order page reclaim in memcg. So, there=
 will be no lumpy reclaim in the soft_limit reclaim under global kswapd. I =
also mentioned that in:</div>
<div><meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-=
8"><a href=3D"http://permalink.gmane.org/gmane.linux.kernel.mm/60966">http:=
//permalink.gmane.org/gmane.linux.kernel.mm/60966</a></div><div>=A0</div><b=
lockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px =
#ccc solid;padding-left:1ex;">

 =A0- balancing zones<br></blockquote><div><br></div><div>this should be co=
vered in current soft_limit reclaim proposal above. don&#39;t want to go to=
 much detail in this thread.</div><div><br></div><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">

 =A0- balancing nodes<br></blockquote><div>not sure about this.</div><div>=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex;">
 =A0- OOM.<br>
 =A0+ balancing memcgs (with softlimit) and LRU ordering<br></blockquote><d=
iv><br></div><div>agree, and i would like to start with round-robin.=A0</di=
v><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex;">

 =A0+ dirty-ratio (it may be better to avoid picking busy memcg by kswapd.)=
<br>
 =A0+ hi/low watermak (if you want).<br></blockquote><div>=A0</div><div>=A0=
I assume this is the zone wmarks.</div><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
&quot;+&quot; is new things added by memcg.<br>
We need to establish each ones and needs performance/statistics check for e=
ach.<br>
<br>
I don&#39;t think we can implement them all perfectly with a rush. I think =
I&#39;ll<br>
see unexpected problems on my way to realistic solution<br></blockquote><di=
v><br></div><div>I will review the 3 patch you just posted and test them wi=
th my V7.</div><div><br></div><div>--Ying=A0</div><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex;">

<div class=3D"im"><br>
&gt; &gt; &gt; &gt; Two watermarks (&quot;high_wmark&quot;, &quot;low_wmark=
&quot;) are added to trigger the<br>
&gt; &gt; &gt; &gt; background reclaim and stop it. The watermarks are calc=
ulated based<br>
&gt; &gt; &gt; &gt; on the cgroup&#39;s limit_in_bytes.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Which brings me to the next issue: making the watermarks con=
figurable.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; You argued that having them adjustable from userspace is req=
uired for<br>
&gt; &gt; &gt; overcommitting the hardlimits and per-memcg kswapd reclaim n=
ot kicking<br>
&gt; &gt; &gt; in in case of global memory pressure. =A0But that is only a =
problem<br>
&gt; &gt; &gt; because global kswapd reclaim is (apart from soft limit recl=
aim)<br>
&gt; &gt; &gt; unaware of memory control groups.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; I think the much better solution is to make global kswapd me=
mcg aware<br>
&gt; &gt; &gt; (with the above mentioned round-robin reclaim scheduler), co=
mpared to<br>
&gt; &gt; &gt; adding new (and final!) kernel ABI to avoid an internal shor=
tcoming.<br>
&gt; &gt;<br>
&gt; &gt; I don&#39;t think its a good idea to kick kswapd even when free m=
emory is enough.<br>
&gt;<br>
&gt; This depends on what kswapd is supposed to be doing. =A0I don&#39;t sa=
y we<br>
&gt; should reclaim from all memcgs (i.e. globally) just because one memcg<=
br>
&gt; hits its watermark, of course.<br>
&gt;<br>
&gt; But the argument was that we need the watermarks configurable to force=
<br>
&gt; per-memcg reclaim even when the hard limits are overcommitted, because=
<br>
&gt; global reclaim does not do a fair job to balance memcgs.<br>
<br>
</div>I cannot understand here. Why global reclaim need to do works other t=
han<br>
balancing zones ? And what is balancing memcg ? Mentioning softlimit ?<br>
<div class=3D"im"><br>
&gt; My counter<br>
&gt; proposal is to fix global reclaim instead and apply equal pressure on<=
br>
&gt; memcgs, such that we never have to tweak per-memcg watermarks to<br>
&gt; achieve the same thing.<br>
&gt;<br>
<br>
</div>I cannot undestand this, either. Don&#39;t you make a mixture of disc=
ussion<br>
with softlimit ? Making global kswapd better is another discussion.<br>
<br>
Hi/Low watermak is a feature as it is. It the 3rd way to limit memory<br>
usage. Comaparing hard_limit, soft_limit, it works in moderate way in backg=
round<br>
and works regardless of usage of global memory. I think it&#39;s valid to h=
ave<br>
ineterfaces to tuning this.<br>
<br>
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
</blockquote></div><br>

--002354470aa82adc1104a167c824--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
