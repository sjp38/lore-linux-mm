Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2AF8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:05:11 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p3L357w8009488
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 20:05:08 -0700
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by hpaq6.eem.corp.google.com with ESMTP id p3L34etV026455
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 20:05:06 -0700
Received: by qwa26 with SMTP id 26so1000869qwa.14
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 20:05:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110421025107.GG2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
Date: Wed, 20 Apr 2011 20:05:05 -0700
Message-ID: <BANLkTi=JTGngiosgEsWEo5A-xGAOeEpVGQ@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa81c45ee04a165023f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--002354470aa81c45ee04a165023f
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 20, 2011 at 7:51 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hello Ying,
>
> I'm sorry that I chime in so late, I was still traveling until Monday.
>

Hey, hope you had a great trip :)

>
> On Mon, Apr 18, 2011 at 08:57:36PM -0700, Ying Han wrote:
> > The current implementation of memcg supports targeting reclaim when the
> > cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
> > Per cgroup background reclaim is needed which helps to spread out memory
> > pressure over longer period of time and smoothes out the cgroup
> performance.
>
> Latency reduction makes perfect sense, the reasons kswapd exists apply
> to memory control groups as well.  But I disagree with the design
> choices you made.
>
> > If the cgroup is configured to use per cgroup background reclaim, a
> kswapd
> > thread is created which only scans the per-memcg LRU list.
>
> We already have direct reclaim, direct reclaim on behalf of a memcg,
> and global kswapd-reclaim.  Please don't add yet another reclaim path
> that does its own thing and interacts unpredictably with the rest of
> them.
>

Yes, we do have per-memcg direct reclaim and kswapd-reclaim. but the later
one is global and we don't want to start reclaiming from each memcg until we
reach the global memory pressure.

>
> As discussed on LSF, we want to get rid of the global LRU.  So the
> goal is to have each reclaim entry end up at the same core part of
> reclaim that round-robin scans a subset of zones from a subset of
> memory control groups.
>

True, but that is for system under global memory pressure and we would like
to do targeting reclaim instead of reclaiming from the global LRU. That is
not the same in this patch, which is doing targeting reclaim proactively
per-memcg based on their hard_limit.

>
> > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > background reclaim and stop it. The watermarks are calculated based
> > on the cgroup's limit_in_bytes.
>
> Which brings me to the next issue: making the watermarks configurable.
>
> You argued that having them adjustable from userspace is required for
> overcommitting the hardlimits and per-memcg kswapd reclaim not kicking
> in in case of global memory pressure.  But that is only a problem
> because global kswapd reclaim is (apart from soft limit reclaim)
> unaware of memory control groups.
>
> I think the much better solution is to make global kswapd memcg aware
> (with the above mentioned round-robin reclaim scheduler), compared to
> adding new (and final!) kernel ABI to avoid an internal shortcoming.
>

We need to make the global kswapd memcg aware and that is the
soft_limit hierarchical reclaim.
It is different from doing per-memcg background reclaim which we want to
reclaim memory per-memcg
before they goes to per-memcg direct reclaim.

>
> The whole excercise of asynchroneous background reclaim is to reduce
> reclaim latency.  We already have a mechanism for global memory
> pressure in place.  Per-memcg watermarks should only exist to avoid
> direct reclaim due to hitting the hardlimit, nothing else.
>

Yes, but we have per-memcg direct reclaim which is based on the hard_limit.
The latency we need to reduce is the direct reclaim which is different from
global memory pressure.

>
> So in summary, I think converting the reclaim core to this round-robin
> scheduler solves all these problems at once: a single code path for
> reclaim, breaking up of the global lru lock, fair soft limit reclaim,
> and a mechanism for latency reduction that just DTRT without any
> user-space configuration necessary.
>

Not exactly. We will have cases where only few cgroups configured and the
total hard_limit always less than the machine capacity. So we will never
trigger the global memory pressure. However, we still need to smooth out the
performance per-memcg by doing background page reclaim proactively before
they hit their hard_limit (direct reclaim)

--Ying


>
>        Hannes
>

--002354470aa81c45ee04a165023f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 20, 2011 at 7:51 PM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Hello Ying,<br>
<br>
I&#39;m sorry that I chime in so late, I was still traveling until Monday.<=
br></blockquote><div><br></div><div>Hey, hope you had a great trip :)=A0</d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex;">

<div class=3D"im"><br>
On Mon, Apr 18, 2011 at 08:57:36PM -0700, Ying Han wrote:<br>
&gt; The current implementation of memcg supports targeting reclaim when th=
e<br>
&gt; cgroup is reaching its hard_limit and we do direct reclaim per cgroup.=
<br>
&gt; Per cgroup background reclaim is needed which helps to spread out memo=
ry<br>
&gt; pressure over longer period of time and smoothes out the cgroup perfor=
mance.<br>
<br>
</div>Latency reduction makes perfect sense, the reasons kswapd exists appl=
y<br>
to memory control groups as well. =A0But I disagree with the design<br>
choices you made.<br>
<div class=3D"im"><br>
&gt; If the cgroup is configured to use per cgroup background reclaim, a ks=
wapd<br>
&gt; thread is created which only scans the per-memcg LRU list.<br>
<br>
</div>We already have direct reclaim, direct reclaim on behalf of a memcg,<=
br>
and global kswapd-reclaim. =A0Please don&#39;t add yet another reclaim path=
<br>
that does its own thing and interacts unpredictably with the rest of<br>
them.<br></blockquote><div><br></div><div>Yes, we do have per-memcg direct =
reclaim and kswapd-reclaim. but the later one is global and we don&#39;t wa=
nt to start reclaiming from each memcg until we reach the global memory pre=
ssure.</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
As discussed on LSF, we want to get rid of the global LRU. =A0So the<br>
goal is to have each reclaim entry end up at the same core part of<br>
reclaim that round-robin scans a subset of zones from a subset of<br>
memory control groups.<br></blockquote><div><br></div><div>True, but that i=
s for system under global memory pressure and we would like to do targeting=
 reclaim instead of reclaiming from the global LRU. That is not the same in=
 this patch, which is doing targeting reclaim proactively per-memcg based o=
n their hard_limit.=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<div class=3D"im"><br>
&gt; Two watermarks (&quot;high_wmark&quot;, &quot;low_wmark&quot;) are add=
ed to trigger the<br>
&gt; background reclaim and stop it. The watermarks are calculated based<br=
>
&gt; on the cgroup&#39;s limit_in_bytes.<br>
<br>
</div>Which brings me to the next issue: making the watermarks configurable=
.<br>
<br>
You argued that having them adjustable from userspace is required for<br>
overcommitting the hardlimits and per-memcg kswapd reclaim not kicking<br>
in in case of global memory pressure. =A0But that is only a problem<br>
because global kswapd reclaim is (apart from soft limit reclaim)<br>
unaware of memory control groups.<br>
<br>
I think the much better solution is to make global kswapd memcg aware<br>
(with the above mentioned round-robin reclaim scheduler), compared to<br>
adding new (and final!) kernel ABI to avoid an internal shortcoming.<br></b=
lockquote><div><br></div><div>We need to make the global kswapd memcg aware=
 and that is the soft_limit=A0hierarchical reclaim.</div><div>It is differe=
nt from doing per-memcg background reclaim which we want to reclaim memory =
per-memcg</div>
<div>before they goes to per-memcg direct reclaim. =A0</div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex;">
<br>
The whole excercise of asynchroneous background reclaim is to reduce<br>
reclaim latency. =A0We already have a mechanism for global memory<br>
pressure in place. =A0Per-memcg watermarks should only exist to avoid<br>
direct reclaim due to hitting the hardlimit, nothing else.<br></blockquote>=
<div><br></div><div>Yes, but we have per-memcg direct reclaim which is base=
d on the hard_limit. The latency we need to reduce is the direct reclaim wh=
ich is different from global memory pressure.</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
So in summary, I think converting the reclaim core to this round-robin<br>
scheduler solves all these problems at once: a single code path for<br>
reclaim, breaking up of the global lru lock, fair soft limit reclaim,<br>
and a mechanism for latency reduction that just DTRT without any<br>
user-space configuration necessary.<br></blockquote><div><br></div><div>Not=
 exactly. We will have cases where only few cgroups configured and the tota=
l hard_limit always less than the machine capacity. So we will never trigge=
r the global memory pressure. However, we still need to smooth out the perf=
ormance per-memcg by doing background page reclaim proactively before they =
hit their hard_limit (direct reclaim)</div>
<div><br></div><div>--Ying</div><div>=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">
<br>
 =A0 =A0 =A0 =A0Hannes<br>
</blockquote></div><br>

--002354470aa81c45ee04a165023f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
