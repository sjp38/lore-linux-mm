Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9446B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 13:41:54 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3RHfnSP016308
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:41:49 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz5.hot.corp.google.com with ESMTP id p3RHflNl018089
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:41:48 -0700
Received: by qyk7 with SMTP id 7so2256825qyk.5
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:41:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427073618.GC6152@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421050851.GI2333@cmpxchg.org>
	<BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>
	<20110423013534.GK2333@cmpxchg.org>
	<BANLkTi=UgLihmoRwdA4E4MXmGc4BmqkqTg@mail.gmail.com>
	<20110423023407.GN2333@cmpxchg.org>
	<BANLkTimwMcBwTvi8aNDPXkS_Vu+bxdciMg@mail.gmail.com>
	<20110427073618.GC6152@cmpxchg.org>
Date: Wed, 27 Apr 2011 10:41:47 -0700
Message-ID: <BANLkTikuEm6NjMpoDC_Wy3r061+rdhApFA@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5c742eb204a1e9f414
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5c742eb204a1e9f414
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 27, 2011 at 12:36 AM, Johannes Weiner <hannes@cmpxchg.org>wrote:

> On Fri, Apr 22, 2011 at 08:33:58PM -0700, Ying Han wrote:
> > On Fri, Apr 22, 2011 at 7:34 PM, Johannes Weiner <hannes@cmpxchg.org>
> wrote:
> >
> > > On Fri, Apr 22, 2011 at 07:10:25PM -0700, Ying Han wrote: >
> > > However, i still think there is a need from the admin to have some
> > > controls > of which memcg to do background reclaim proactively
> > > (before global memory > pressure) and that was the initial logic
> > > behind the API.
> > >
> > > That sounds more interesting.  Do you have a specific use case
> > > that requires this?
> >
> > There might be more interesting use cases there, and here is one I
> > can think of:
> >
> > let's say we three jobs A, B and C, and one host with 32G of RAM. We
> > configure each job's hard_limit as their peak memory usage.
> > A: 16G
> > B: 16G
> > C: 10G
> >
> > 1. we start running A with hard_limit 15G, and start running B with
> > hard_limit 15G.
> > 2. we set A and B's soft_limit based on their "hot" memory. Let's say
> > setting A's soft_limit 10G and B's soft_limit 10G.
> > (The soft_limit will be changing based on their runtime memory usage)
> >
> > If no more jobs running on the system, A and B will easily fill up the
> whole
> > system with pagecache pages. Since we are not over-committing the machine
> > with their hard_limit, there will be no pressure to push their memory
> usage
> > down to soft_limit.
> >
> > Now we would like to launch another job C, since we know there are A(16G
> -
> > 10G) + B(16G - 10G)  = 12G "cold" memory can be reclaimed (w/o impacting
> the
> > A and B's performance). So what will happen
> >
> > 1. start running C on the host, which triggers global memory pressure
> right
> > away. If the reclaim is fast, C start growing with the free pages from A
> and
> > B.
> >
> > However, it might be possible that the reclaim can not catch-up with the
> > job's page allocation. We end up with either OOM condition or performance
> > spike on any of the running jobs.
>
> If background reclaim can not catch up, C will go into direct reclaim,
> which will have exactly the same effect, only that C will have to do
> the work itself.
>
> > One way to improve it is to set a wmark on either A/B to be proactively
> > reclaiming pages before launching C. The global memory pressure won't
> help
> > much here since we won't trigger that.
>
> Ok, so you want to use the watermarks to push back and limit the usage
> of A and B to make room for C.  Isn't this exactly what the hard limit
> is for?
>
> similar, but not exactly the same. there is no need to hard cap the memory
usage for A and B in that case.
what we need is to have some period of time that A and B slowly reclaim
pages and leaves some room to
launch C smoothly.


> I don't understand the second sentence: global memory pressure won't
> kick in with only A and B, but it will once C starts up.
>
> In my example, the hard_limit of A+B is less than the machine capacity. And
after we have
per-memcg bg reclaim, ideally we won't trigger global reclaim much.

But when we launch C, we end up over-committing the machine. So the global
reclaim will
fire up quickly.

Anyway, i agree that less newly invented kernel API is good. If you check
the latest past V8 from
Kame, we reduced the two API to one which we only allow setting the
high_wmark_distance and the
low_wmark_distance is set internally. I think this is good enough.

--Ying



> > > min_free_kbytes more or less indirectly provides the same on a global
> > > level, but I don't think anybody tunes it just for aggressiveness of
> > > background reclaim.
> > >
> >
> > Hmm, we do scale that in google workload. With large machines under lots
> of
> > memory pressure and heavily network traffic workload, we would like to
> > reduce the likelyhood of page alloc failure. But this is kind of
> different
> > from what we are talking about here.
>
> My point indeed ;-)
>
>        Hannes
>

--0016360e3f5c742eb204a1e9f414
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Apr 27, 2011 at 12:36 AM, Johann=
es Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hanne=
s@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" st=
yle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Fri, Apr 22, 2011 at 08:33:58PM -0700, Ying Han wrote:=
<br>
&gt; On Fri, Apr 22, 2011 at 7:34 PM, Johannes Weiner &lt;<a href=3D"mailto=
:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Fri, Apr 22, 2011 at 07:10:25PM -0700, Ying Han wrote: &gt;<br=
>
</div><div><div></div><div class=3D"h5">&gt; &gt; However, i still think th=
ere is a need from the admin to have some<br>
&gt; &gt; controls &gt; of which memcg to do background reclaim proactively=
<br>
&gt; &gt; (before global memory &gt; pressure) and that was the initial log=
ic<br>
&gt; &gt; behind the API.<br>
&gt; &gt;<br>
&gt; &gt; That sounds more interesting. =A0Do you have a specific use case<=
br>
&gt; &gt; that requires this?<br>
&gt;<br>
&gt; There might be more interesting use cases there, and here is one I<br>
&gt; can think of:<br>
&gt;<br>
&gt; let&#39;s say we three jobs A, B and C, and one host with 32G of RAM. =
We<br>
&gt; configure each job&#39;s hard_limit as their peak memory usage.<br>
&gt; A: 16G<br>
&gt; B: 16G<br>
&gt; C: 10G<br>
&gt;<br>
&gt; 1. we start running A with hard_limit 15G, and start running B with<br=
>
&gt; hard_limit 15G.<br>
&gt; 2. we set A and B&#39;s soft_limit based on their &quot;hot&quot; memo=
ry. Let&#39;s say<br>
&gt; setting A&#39;s soft_limit 10G and B&#39;s soft_limit 10G.<br>
&gt; (The soft_limit will be changing based on their runtime memory usage)<=
br>
&gt;<br>
&gt; If no more jobs running on the system, A and B will easily fill up the=
 whole<br>
&gt; system with pagecache pages. Since we are not over-committing the mach=
ine<br>
&gt; with their hard_limit, there will be no pressure to push their memory =
usage<br>
&gt; down to soft_limit.<br>
&gt;<br>
&gt; Now we would like to launch another job C, since we know there are A(1=
6G -<br>
&gt; 10G) + B(16G - 10G) =A0=3D 12G &quot;cold&quot; memory can be reclaime=
d (w/o impacting the<br>
&gt; A and B&#39;s performance). So what will happen<br>
&gt;<br>
&gt; 1. start running C on the host, which triggers global memory pressure =
right<br>
&gt; away. If the reclaim is fast, C start growing with the free pages from=
 A and<br>
&gt; B.<br>
&gt;<br>
&gt; However, it might be possible that the reclaim can not catch-up with t=
he<br>
&gt; job&#39;s page allocation. We end up with either OOM condition or perf=
ormance<br>
&gt; spike on any of the running jobs.<br>
<br>
</div></div>If background reclaim can not catch up, C will go into direct r=
eclaim,<br>
which will have exactly the same effect, only that C will have to do<br>
the work itself.<br>
<div class=3D"im"><br>
&gt; One way to improve it is to set a wmark on either A/B to be proactivel=
y<br>
&gt; reclaiming pages before launching C. The global memory pressure won&#3=
9;t help<br>
&gt; much here since we won&#39;t trigger that.<br>
<br>
</div>Ok, so you want to use the watermarks to push back and limit the usag=
e<br>
of A and B to make room for C. =A0Isn&#39;t this exactly what the hard limi=
t<br>
is for?<br>
<br></blockquote><div>similar, but not exactly the same. there is no need t=
o hard cap the memory usage for A and B in that case.</div><div>what we nee=
d is to have some period of time that A and B slowly reclaim pages and leav=
es some room to=A0</div>
<div>launch C smoothly.=A0</div><div>=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">I don&#39;t understand the second sentence: global memory pressure won&#=
39;t<br>

kick in with only A and B, but it will once C starts up.<br>
<div class=3D"im"><br></div></blockquote><div>In my example, the hard_limit=
 of A+B is less than the machine capacity. And after we have</div><div>per-=
memcg bg reclaim, ideally we won&#39;t trigger global reclaim much.</div>
<div><br></div><div>But when we launch C, we end up over-committing=A0the m=
achine. So the global reclaim will</div><div>fire up quickly.</div><div><br=
></div><div>Anyway, i agree that less newly invented kernel API is good. If=
 you check the latest past V8 from</div>
<div>Kame, we reduced the two API to one which we only allow setting the hi=
gh_wmark_distance and the</div><div>low_wmark_distance is set internally. I=
 think this is good enough.</div><div><br></div><div>--Ying</div><div><br>
</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex;"><div class=3D"im">
&gt; &gt; min_free_kbytes more or less indirectly provides the same on a gl=
obal<br>
&gt; &gt; level, but I don&#39;t think anybody tunes it just for aggressive=
ness of<br>
&gt; &gt; background reclaim.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Hmm, we do scale that in google workload. With large machines under lo=
ts of<br>
&gt; memory pressure and heavily network traffic workload, we would like to=
<br>
&gt; reduce the likelyhood of page alloc failure. But this is kind of diffe=
rent<br>
&gt; from what we are talking about here.<br>
<br>
</div>My point indeed ;-)<br>
<br>
 =A0 =A0 =A0 =A0Hannes<br>
</blockquote></div><br>

--0016360e3f5c742eb204a1e9f414--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
