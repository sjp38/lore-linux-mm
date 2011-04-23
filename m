Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 948E38D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 22:10:34 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p3N2ARXE023308
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 19:10:27 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by hpaq3.eem.corp.google.com with ESMTP id p3N2A61T012572
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 19:10:25 -0700
Received: by qyk36 with SMTP id 36so84338qyk.11
        for <linux-mm@kvack.org>; Fri, 22 Apr 2011 19:10:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110423013534.GK2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
	<20110421050851.GI2333@cmpxchg.org>
	<BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>
	<20110423013534.GK2333@cmpxchg.org>
Date: Fri, 22 Apr 2011 19:10:25 -0700
Message-ID: <BANLkTi=UgLihmoRwdA4E4MXmGc4BmqkqTg@mail.gmail.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0050450161c33d79ce04a18c7a50
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0050450161c33d79ce04a18c7a50
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 22, 2011 at 6:35 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Apr 20, 2011 at 10:28:17PM -0700, Ying Han wrote:
> > On Wed, Apr 20, 2011 at 10:08 PM, Johannes Weiner <hannes@cmpxchg.org
> >wrote:
> > > On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > I don't think its a good idea to kick kswapd even when free memory is
> > > enough.
> > >
> > > This depends on what kswapd is supposed to be doing.  I don't say we
> > > should reclaim from all memcgs (i.e. globally) just because one memcg
> > > hits its watermark, of course.
> > >
> > > But the argument was that we need the watermarks configurable to force
> > > per-memcg reclaim even when the hard limits are overcommitted, because
> > > global reclaim does not do a fair job to balance memcgs.
> >
> > There seems to be some confusion here. The watermark we defined is
> > per-memcg, and that is calculated
> > based on the hard_limit. We need the per-memcg wmark the same reason of
> > per-zone wmart which triggers
> > the background reclaim before direct reclaim.
>
> Of course, I am not arguing against the watermarks.  I am just
> (violently) against making them configurable from userspace.
>
> > There is a patch in my patchset which adds the tunable for both
> > high/low_mark, which gives more flexibility to admin to config the host.
> In
> > over-commit environment, we might never hit the wmark if all the wmarks
> are
> > set internally.
>
> And my point is that this should not be a problem at all!  If the
> watermarks are not physically reachable, there is no reason to reclaim
> on behalf of them.
>
> In such an environment, global memory pressure arises before the
> memcgs get close to their hard limit, and global memory pressure
> reduction should do the right thing and equally push back all memcgs.
>
> Flexibility in itself is not an argument.  On the contrary.  We commit
> ourselves to that ABI and have to maintain this flexibility forever.
> Instead, please find a convincing argument for the flexibility itself,
> other than the need to workaround the current global kswapd reclaim.
>
> Ok, I tend to agree with you now that the over-commit example i gave early
is a weak argument. We don't need to provide the ability to reclaim from a
memcg before it is reaching its wmarks in over-commit environment.

However, i still think there is a need from the admin to have some controls
of which memcg to do background reclaim proactively (before global memory
pressure) and that was the initial logic behind the API.

I used to have per-memcg wmark_ratio api which controls both high/low_wmark
based on hard_limit, but the two APIs seems give finer granularity.

--Ying


> (I fixed up the following quotation, please be more careful when
> replying, this makes it so hard to follow your emails.  thanks!)
>
> > > My counter proposal is to fix global reclaim instead and apply equal
> > > pressure on memcgs, such that we never have to tweak per-memcg
> watermarks
> > > to achieve the same thing.
> >
> > We still need this and that is the soft_limit reclaim under global
> > background reclaim.
>
> I don't understand what you mean by that.  Could you elaborate?
>

Sorry I think I misunderstood your early comment. What I pointed out here
was that we need both per-memcg
background reclaim and global soft_limit reclaim. I don't think we have
disagreement on that at this point.

>
> Thanks,
>
>        Hannes
>

--0050450161c33d79ce04a18c7a50
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 22, 2011 at 6:35 PM, Johanne=
s Weiner <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes=
@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Wed, Apr 20, 2011 at 10:28:17PM -0700, Ying Han wrote:=
<br>
&gt; On Wed, Apr 20, 2011 at 10:08 PM, Johannes Weiner &lt;<a href=3D"mailt=
o:hannes@cmpxchg.org">hannes@cmpxchg.org</a>&gt;wrote:<br>
&gt; &gt; On Thu, Apr 21, 2011 at 01:00:16PM +0900, KAMEZAWA Hiroyuki wrote=
:<br>
</div><div class=3D"im">&gt; &gt; &gt; I don&#39;t think its a good idea to=
 kick kswapd even when free memory is<br>
&gt; &gt; enough.<br>
&gt; &gt;<br>
&gt; &gt; This depends on what kswapd is supposed to be doing. =A0I don&#39=
;t say we<br>
&gt; &gt; should reclaim from all memcgs (i.e. globally) just because one m=
emcg<br>
&gt; &gt; hits its watermark, of course.<br>
&gt; &gt;<br>
&gt; &gt; But the argument was that we need the watermarks configurable to =
force<br>
&gt; &gt; per-memcg reclaim even when the hard limits are overcommitted, be=
cause<br>
&gt; &gt; global reclaim does not do a fair job to balance memcgs.<br>
&gt;<br>
&gt; There seems to be some confusion here. The watermark we defined is<br>
&gt; per-memcg, and that is calculated<br>
&gt; based on the hard_limit. We need the per-memcg wmark the same reason o=
f<br>
&gt; per-zone wmart which triggers<br>
&gt; the background reclaim before direct reclaim.<br>
<br>
</div>Of course, I am not arguing against the watermarks. =A0I am just<br>
(violently) against making them configurable from userspace.<br>
<div class=3D"im"><br>
&gt; There is a patch in my patchset which adds the tunable for both<br>
&gt; high/low_mark, which gives more flexibility to admin to config the hos=
t. In<br>
&gt; over-commit environment, we might never hit the wmark if all the wmark=
s are<br>
&gt; set internally.<br>
<br>
</div>And my point is that this should not be a problem at all! =A0If the<b=
r>
watermarks are not physically reachable, there is no reason to reclaim<br>
on behalf of them.<br>
<br>
In such an environment, global memory pressure arises before the<br>
memcgs get close to their hard limit, and global memory pressure<br>
reduction should do the right thing and equally push back all memcgs.<br>
<br>
Flexibility in itself is not an argument. =A0On the contrary. =A0We commit<=
br>
ourselves to that ABI and have to maintain this flexibility forever.<br>
Instead, please find a convincing argument for the flexibility itself,<br>
other than the need to workaround the current global kswapd reclaim.<br>
<br></blockquote><div>Ok,=A0<meta http-equiv=3D"content-type" content=3D"te=
xt/html; charset=3Dutf-8">I tend to agree with you now that the over-commit=
 example i gave early is a weak argument. We don&#39;t need to provide the =
ability to reclaim from a memcg before it is reaching its wmarks in over-co=
mmit=A0environment.=A0</div>
<div><br></div><div>However, i still think there is a need from the admin t=
o have some controls of which memcg to do background reclaim proactively (b=
efore global memory pressure) and that was the initial logic behind the API=
.=A0</div>
<div><br></div><div>I used to have per-memcg wmark_ratio api which controls=
 both high/low_wmark based on hard_limit, but the two APIs seems give finer=
 granularity.</div><div><br></div><div>--Ying</div><div>=A0</div><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">

(I fixed up the following quotation, please be more careful when<br>
replying, this makes it so hard to follow your emails. =A0thanks!)<br>
<div class=3D"im"><br>
&gt; &gt; My counter proposal is to fix global reclaim instead and apply eq=
ual<br>
&gt; &gt; pressure on memcgs, such that we never have to tweak per-memcg wa=
termarks<br>
&gt; &gt; to achieve the same thing.<br>
&gt;<br>
&gt; We still need this and that is the soft_limit reclaim under global<br>
&gt; background reclaim.<br>
<br>
</div>I don&#39;t understand what you mean by that. =A0Could you elaborate?=
<br></blockquote><div><br></div><div>Sorry I think I misunderstood your ear=
ly comment. What I pointed out here was that we need both per-memcg</div>
<div>background reclaim and global soft_limit reclaim. I don&#39;t think we=
 have disagreement on that at this point.=A0</div><blockquote class=3D"gmai=
l_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left=
:1ex;">

<br>
Thanks,<br>
<br>
 =A0 =A0 =A0 =A0Hannes<br>
</blockquote></div><br>

--0050450161c33d79ce04a18c7a50--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
