Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4254F8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 23:34:07 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p3N3Y4kU005861
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 20:34:04 -0700
Received: from qyk32 (qyk32.prod.google.com [10.241.83.160])
	by kpbe15.cbf.corp.google.com with ESMTP id p3N3XwiQ023557
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 20:34:03 -0700
Received: by qyk32 with SMTP id 32so122129qyk.1
        for <linux-mm@kvack.org>; Fri, 22 Apr 2011 20:33:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110423023407.GN2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421050851.GI2333@cmpxchg.org>
	<BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>
	<20110423013534.GK2333@cmpxchg.org>
	<BANLkTi=UgLihmoRwdA4E4MXmGc4BmqkqTg@mail.gmail.com>
	<20110423023407.GN2333@cmpxchg.org>
Date: Fri, 22 Apr 2011 20:33:58 -0700
Message-ID: <BANLkTimwMcBwTvi8aNDPXkS_Vu+bxdciMg@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc0a900f04a18da590
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--000e0ce008bc0a900f04a18da590
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 22, 2011 at 7:34 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, Apr 22, 2011 at 07:10:25PM -0700, Ying Han wrote:
> > On Fri, Apr 22, 2011 at 6:35 PM, Johannes Weiner <hannes@cmpxchg.org>
> wrote:
> >
> > > On Wed, Apr 20, 2011 at 10:28:17PM -0700, Ying Han wrote:
> > > > On Wed, Apr 20, 2011 at 10:08 PM, Johannes Weiner <
> hannes@cmpxchg.org
> > > >wrote:
> > > > > On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > > I don't think its a good idea to kick kswapd even when free
> memory is
> > > > > enough.
> > > > >
> > > > > This depends on what kswapd is supposed to be doing.  I don't say
> we
> > > > > should reclaim from all memcgs (i.e. globally) just because one
> memcg
> > > > > hits its watermark, of course.
> > > > >
> > > > > But the argument was that we need the watermarks configurable to
> force
> > > > > per-memcg reclaim even when the hard limits are overcommitted,
> because
> > > > > global reclaim does not do a fair job to balance memcgs.
> > > >
> > > > There seems to be some confusion here. The watermark we defined is
> > > > per-memcg, and that is calculated
> > > > based on the hard_limit. We need the per-memcg wmark the same reason
> of
> > > > per-zone wmart which triggers
> > > > the background reclaim before direct reclaim.
> > >
> > > Of course, I am not arguing against the watermarks.  I am just
> > > (violently) against making them configurable from userspace.
> > >
> > > > There is a patch in my patchset which adds the tunable for both
> > > > high/low_mark, which gives more flexibility to admin to config the
> host.
> > > In
> > > > over-commit environment, we might never hit the wmark if all the
> wmarks
> > > are
> > > > set internally.
> > >
> > > And my point is that this should not be a problem at all!  If the
> > > watermarks are not physically reachable, there is no reason to reclaim
> > > on behalf of them.
> > >
> > > In such an environment, global memory pressure arises before the
> > > memcgs get close to their hard limit, and global memory pressure
> > > reduction should do the right thing and equally push back all memcgs.
> > >
> > > Flexibility in itself is not an argument.  On the contrary.  We commit
> > > ourselves to that ABI and have to maintain this flexibility forever.
> > > Instead, please find a convincing argument for the flexibility itself,
> > > other than the need to workaround the current global kswapd reclaim.
>
> [fixed following quotation]
>
> > Ok, I tend to agree with you now that the over-commit example i gave
> > early is a weak argument. We don't need to provide the ability to
> > reclaim from a memcg before it is reaching its wmarks in over-commit
> > environment.
>
> Yep.  If it is impossible to reach the hard limit, it can't possibly
> be a source of latency.
>
> > However, i still think there is a need from the admin to have some
> controls
> > of which memcg to do background reclaim proactively (before global memory
> > pressure) and that was the initial logic behind the API.
>
> That sounds more interesting.  Do you have a specific use case that
> requires this?
>
> There might be more interesting use cases there, and here is one I can
think of:

let's say we three jobs A, B and C, and one host with 32G of RAM. We
configure each job's hard_limit as their peak memory usage.
A: 16G
B: 16G
C: 10G

1. we start running A with hard_limit 15G, and start running B with
hard_limit 15G.
2. we set A and B's soft_limit based on their "hot" memory. Let's say
setting A's soft_limit 10G and B's soft_limit 10G.
(The soft_limit will be changing based on their runtime memory usage)

If no more jobs running on the system, A and B will easily fill up the whole
system with pagecache pages. Since we are not over-committing the machine
with their hard_limit, there will be no pressure to push their memory usage
down to soft_limit.

Now we would like to launch another job C, since we know there are A(16G -
10G) + B(16G - 10G)  = 12G "cold" memory can be reclaimed (w/o impacting the
A and B's performance). So what will happen

1. start running C on the host, which triggers global memory pressure right
away. If the reclaim is fast, C start growing with the free pages from A and
B.

However, it might be possible that the reclaim can not catch-up with the
job's page allocation. We end up with either OOM condition or performance
spike on any of the running jobs.

One way to improve it is to set a wmark on either A/B to be proactively
reclaiming pages before launching C. The global memory pressure won't help
much here since we won't trigger that.



> min_free_kbytes more or less indirectly provides the same on a global
> level, but I don't think anybody tunes it just for aggressiveness of
> background reclaim.
>

Hmm, we do scale that in google workload. With large machines under lots of
memory pressure and heavily network traffic workload, we would like to
reduce the likelyhood of page alloc failure. But this is kind of different
from what we are talking about here.

--Ying



>
> > > (I fixed up the following quotation, please be more careful when
> > > replying, this makes it so hard to follow your emails.  thanks!)
>
> ^^^^
>
> > > > > My counter proposal is to fix global reclaim instead and apply
> > > > > equal pressure on memcgs, such that we never have to tweak
> > > > > per-memcg > > watermarks to achieve the same thing.
> > > >
> > > > We still need this and that is the soft_limit reclaim under global
> > > > background reclaim.
> > >
> > > I don't understand what you mean by that.  Could you elaborate?
> >
> > Sorry I think I misunderstood your early comment. What I pointed out here
> > was that we need both per-memcg
> > background reclaim and global soft_limit reclaim. I don't think we have
> > disagreement on that at this point.
>
> Ah, got you, thanks.
>
>        Hannes
>

--000e0ce008bc0a900f04a18da590
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 22, 2011 at 7:34 PM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Fri, Apr 22, 2011 at 07:10:25PM -0700,=
 Ying Han wrote:<br>
&gt; On Fri, Apr 22, 2011 at 6:35 PM, Johannes Weiner &lt;<a href=3D"mailto=
:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Wed, Apr 20, 2011 at 10:28:17PM -0700, Ying Han wrote:<br>
&gt; &gt; &gt; On Wed, Apr 20, 2011 at 10:08 PM, Johannes Weiner &lt;<a hre=
f=3D"mailto:hannes@cmpxchg.org">hannes@cmpxchg.org</a><br>
&gt; &gt; &gt;wrote:<br>
&gt; &gt; &gt; &gt; On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiro=
yuki wrote:<br>
&gt; &gt; &gt; &gt; &gt; I don&#39;t think its a good idea to kick kswapd e=
ven when free memory is<br>
&gt; &gt; &gt; &gt; enough.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; This depends on what kswapd is supposed to be doing. =
=A0I don&#39;t say we<br>
&gt; &gt; &gt; &gt; should reclaim from all memcgs (i.e. globally) just bec=
ause one memcg<br>
&gt; &gt; &gt; &gt; hits its watermark, of course.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; But the argument was that we need the watermarks config=
urable to force<br>
&gt; &gt; &gt; &gt; per-memcg reclaim even when the hard limits are overcom=
mitted, because<br>
&gt; &gt; &gt; &gt; global reclaim does not do a fair job to balance memcgs=
.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; There seems to be some confusion here. The watermark we defi=
ned is<br>
&gt; &gt; &gt; per-memcg, and that is calculated<br>
&gt; &gt; &gt; based on the hard_limit. We need the per-memcg wmark the sam=
e reason of<br>
&gt; &gt; &gt; per-zone wmart which triggers<br>
&gt; &gt; &gt; the background reclaim before direct reclaim.<br>
&gt; &gt;<br>
&gt; &gt; Of course, I am not arguing against the watermarks. =A0I am just<=
br>
&gt; &gt; (violently) against making them configurable from userspace.<br>
&gt; &gt;<br>
&gt; &gt; &gt; There is a patch in my patchset which adds the tunable for b=
oth<br>
&gt; &gt; &gt; high/low_mark, which gives more flexibility to admin to conf=
ig the host.<br>
&gt; &gt; In<br>
&gt; &gt; &gt; over-commit environment, we might never hit the wmark if all=
 the wmarks<br>
&gt; &gt; are<br>
&gt; &gt; &gt; set internally.<br>
&gt; &gt;<br>
&gt; &gt; And my point is that this should not be a problem at all! =A0If t=
he<br>
&gt; &gt; watermarks are not physically reachable, there is no reason to re=
claim<br>
&gt; &gt; on behalf of them.<br>
&gt; &gt;<br>
&gt; &gt; In such an environment, global memory pressure arises before the<=
br>
&gt; &gt; memcgs get close to their hard limit, and global memory pressure<=
br>
&gt; &gt; reduction should do the right thing and equally push back all mem=
cgs.<br>
&gt; &gt;<br>
&gt; &gt; Flexibility in itself is not an argument. =A0On the contrary. =A0=
We commit<br>
&gt; &gt; ourselves to that ABI and have to maintain this flexibility forev=
er.<br>
&gt; &gt; Instead, please find a convincing argument for the flexibility it=
self,<br>
&gt; &gt; other than the need to workaround the current global kswapd recla=
im.<br>
<br>
</div></div>[fixed following quotation]<br>
<div class=3D"im"><br>
&gt; Ok, I tend to agree with you now that the over-commit example i gave<b=
r>
&gt; early is a weak argument. We don&#39;t need to provide the ability to<=
br>
&gt; reclaim from a memcg before it is reaching its wmarks in over-commit<b=
r>
&gt; environment.<br>
<br>
</div>Yep. =A0If it is impossible to reach the hard limit, it can&#39;t pos=
sibly<br>
be a source of latency.<br>
<div class=3D"im"><br>
&gt; However, i still think there is a need from the admin to have some con=
trols<br>
&gt; of which memcg to do background reclaim proactively (before global mem=
ory<br>
&gt; pressure) and that was the initial logic behind the API.<br>
<br>
</div>That sounds more interesting. =A0Do you have a specific use case that=
<br>
requires this?<br>
<br></blockquote><div>There might be more interesting use cases there, and =
here is one I can think of:</div><div><br></div><div>let&#39;s say we three=
 jobs A, B and C, and one host with 32G of RAM. We configure each job&#39;s=
 hard_limit as their peak memory usage.</div>
<div>A: 16G</div><div>B: 16G</div><div>C: 10G</div><div><br></div><div>1. w=
e start running A with hard_limit 15G, and start running B with hard_limit =
15G.</div><div>2. we set A and B&#39;s soft_limit based on their &quot;hot&=
quot; memory. Let&#39;s say setting A&#39;s soft_limit 10G and B&#39;s soft=
_limit 10G.=A0</div>
<div>(The soft_limit will be changing based on their runtime memory usage)<=
/div><div><br></div><div>If no more jobs running on the system, A and B wil=
l easily fill up the whole system with pagecache pages. Since we are not ov=
er-committing the machine with their hard_limit, there will be no pressure =
to push their memory usage down to soft_limit.=A0</div>
<div><br></div><div>Now we would like to launch another job C, since we kno=
w there are A(16G - 10G) + B(16G - 10G) =A0=3D 12G &quot;cold&quot; memory =
can be reclaimed (w/o impacting the A and B&#39;s performance). So what wil=
l happen</div>
<div><br></div><div>1. start running C on the host, which triggers global m=
emory pressure right away. If the reclaim is fast, C start growing with the=
 free pages from A and B.</div><div><br></div><div>However, it might be pos=
sible that the reclaim can not catch-up with the job&#39;s page allocation.=
 We end up with either OOM condition or performance spike on any of the run=
ning jobs.</div>
<div><br></div><div>One way to improve it is to set a wmark on either A/B t=
o be proactively reclaiming pages before launching C. The global memory pre=
ssure won&#39;t help much here since we won&#39;t trigger that.</div><div>
<br></div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0=
 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
min_free_kbytes more or less indirectly provides the same on a global<br>
level, but I don&#39;t think anybody tunes it just for aggressiveness of<br=
>
background reclaim.<br></blockquote><div><br></div><div>Hmm, we do scale th=
at in google workload. With large machines under lots of memory pressure an=
d heavily network traffic workload, we would like to reduce the likelyhood =
of page alloc failure. But this is kind of different from what we are talki=
ng about here.</div>
<div><br></div><div><meta http-equiv=3D"content-type" content=3D"text/html;=
 charset=3Dutf-8"><div>--Ying=A0</div></div><div><br></div><div>=A0</div><b=
lockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px =
#ccc solid;padding-left:1ex;">

<div class=3D"im"><br>
&gt; &gt; (I fixed up the following quotation, please be more careful when<=
br>
&gt; &gt; replying, this makes it so hard to follow your emails. =A0thanks!=
)<br>
<br>
^^^^<br>
<br>
&gt; &gt; &gt; &gt; My counter proposal is to fix global reclaim instead an=
d apply<br>
&gt; &gt; &gt; &gt; equal pressure on memcgs, such that we never have to tw=
eak<br>
&gt; &gt; &gt; &gt; per-memcg &gt; &gt; watermarks to achieve the same thin=
g.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; We still need this and that is the soft_limit reclaim under =
global<br>
&gt; &gt; &gt; background reclaim.<br>
&gt; &gt;<br>
&gt; &gt; I don&#39;t understand what you mean by that. =A0Could you elabor=
ate?<br>
&gt;<br>
&gt; Sorry I think I misunderstood your early comment. What I pointed out h=
ere<br>
&gt; was that we need both per-memcg<br>
&gt; background reclaim and global soft_limit reclaim. I don&#39;t think we=
 have<br>
&gt; disagreement on that at this point.<br>
<br>
</div>Ah, got you, thanks.<br>
<br>
 =A0 =A0 =A0 =A0Hannes<br>
</blockquote></div><br>

--000e0ce008bc0a900f04a18da590--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
