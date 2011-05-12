Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 36C656B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 22:11:45 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p4C2BgBc022418
	for <linux-mm@kvack.org>; Wed, 11 May 2011 19:11:42 -0700
Received: from qyk32 (qyk32.prod.google.com [10.241.83.160])
	by wpaz1.hot.corp.google.com with ESMTP id p4C2BexD014730
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 19:11:41 -0700
Received: by qyk32 with SMTP id 32so3179662qyk.15
        for <linux-mm@kvack.org>; Wed, 11 May 2011 19:11:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110511182844.d128c995.akpm@linux-foundation.org>
	<20110512103503.717f4a96.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 11 May 2011 19:11:40 -0700
Message-ID: <BANLkTinBH7jJDNC34Xdx1DDgVu3J4hkBmA@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/7] memcg async reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=002354470aa8b4a54304a30ab582
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

--002354470aa8b4a54304a30ab582
Content-Type: text/plain; charset=ISO-8859-1

On Wed, May 11, 2011 at 6:35 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 11 May 2011 18:28:44 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
> > On Tue, 10 May 2011 19:02:16 +0900 KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > Hi, thank you for all comments on previous patches for watermarks for
> memcg.
> > >
> > > This is a new series as 'async reclaim', no watermark.
> > > This version is a RFC again and I don't ask anyone to test this...but
> > > comments/review are appreciated.
> > >
> > > Major changes are
> > >   - no configurable watermark
> > >   - hierarchy support
> > >   - more fix for static scan rate round robin scanning of memcg.
> > >
> > > (assume x86-64 in following.)
> > >
> > > 'async reclaim' works when
> > >    - usage > limit - 4MB.
> > > until
> > >    - usage < limit - 8MB.
> > >
> > > when the limit is larger than 128MB. This value of margin to limit
> > > has some purpose for helping to reduce page fault latency at using
> > > Transparent hugepage.
> > >
> > > Considering THP, we need to reclaim HPAGE_SIZE(2MB) of pages when we
> hit
> > > limit and consume HPAGE_SIZE(2MB) immediately. Then, the application
> need to
> > > scan 2MB per each page fault and get big latency. So, some margin >
> HPAGE_SIZE
> > > is required. I set it as 2*HPAGE_SIZE/4*HPAGE_SIZE, here. The kernel
> > > will do async reclaim and reduce usage to limit - 8MB in background.
> > >
> > > BTW, when an application gets a page, it tend to do some action to fill
> the
> > > gotton page. For example, reading data from file/network and fill
> buffer.
> > > This implies the application will have a wait or consumes cpu other
> than
> > > reclaiming memory. So, if the kernel can help memory freeing in
> background
> > > while application does another jobs, application latency can be
> reduced.
> > > Then, this kind of asyncronous reclaim of memory will be a help for
> reduce
> > > memory reclaim latency by memcg. But the total amount of cpu time
> consumed
> > > will not have any difference.
> > >
> > > This patch series implements
> > >   - a logic for trigger async reclaim
> > >   - help functions for async reclaim
> > >   - core logic for async reclaim, considering memcg's hierarchy.
> > >   - static scan rate memcg reclaim.
> > >   - workqueue for async reclaim.
> > >
> > > Some concern is that I didn't implement a code for handle the case
> > > most of pages are mlocked or anon memory in swapless system. I need
> some
> > > detection logic to avoid hopless async reclaim.
> > >
> >
> > What (user-visible) problem is this patchset solving?
> >
> > IOW, what is the current behaviour, what is wrong with that behaviour
> > and what effects does the patchset have upon that behaviour?
> >
> > The sole answer from the above is "latency spikes".  Anything else?
> >
>
> I think this set has possibility to fix latency spike.
>
> For example, in previous set, (which has tuning knobs), do a file copy
> of 400M file under 400M limit.
> ==
> 1) == hard limit = 400M ==
> [root@rhel6-test hilow]# time cp ./tmpfile xxx
> real    0m7.353s
> user    0m0.009s
> sys     0m3.280s
>
> 2) == hard limit 500M/ hi_watermark = 400M ==
> [root@rhel6-test hilow]# time cp ./tmpfile xxx
>
> real    0m6.421s
> user    0m0.059s
> sys     0m2.707s
> ==
> and in both case, memory usage after test was 400M.
>
> IIUC, this speed up is because memory reclaim runs in background file 'cp'
> read/write files. But above test uses 100MB of margin. I gues we don't need
> 100MB of margin as above but will not get full speed with 8MB margin. There
> will be trade-off because users may want to use memory up to the limit.
>
> So, this set tries to set some 'default' margin, which is not too big and
> has
> idea that implements async reclaim without tuning knobs. I'll measure
> some more and report it in the next post.
>
> I can also try to run some workload to measure the performance impact.
> Kame, just let me know
>
when you have patch ready for testing.


> > Have these spikes been observed and measured?  We should have a
> > testcase/worload with quantitative results to demonstrate and measure
> > the problem(s), so the effectiveness of the proposed solution can be
> > understood.
> >
> >
>
> Yes, you're right, of course.
> This set just shows the design changes caused by removing tuning knobs as
> a result of long discussion.
>
> As an output of it, we do
>  1. impleimenting async reclaim without tuning knobs.
>  2. add some on-demand background reclaim as 'active softlimit', which
> means
>    a mode of softlimit, shrinking memory always even if the system has
> plenty of
>    free memory. And current softlimit, which works only when memory are in
> short,
>    will be called as 'passive softlimit'.
>

The second one is a useful feature not only doing watermark based reclaim,
but proactively reclaiming
pages down to the soft_limit. We at google are talking about adopting it
to guarantee more predictability
for applications where the soft_limit could be configured to the actual
working_set_size.

--Ying




>
> Thanks,
> -Kame
>
>
>
>
>

--002354470aa8b4a54304a30ab582
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, May 11, 2011 at 6:35 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div><div></div><div class=3D"h5">On Wed, 11 May 2011 18:28:44 -0700<br>
Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.org">akpm@linux-f=
oundation.org</a>&gt; wrote:<br>
<br>
&gt; On Tue, 10 May 2011 19:02:16 +0900 KAMEZAWA Hiroyuki &lt;<a href=3D"ma=
ilto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;=
 wrote:<br>
&gt;<br>
&gt; &gt; Hi, thank you for all comments on previous patches for watermarks=
 for memcg.<br>
&gt; &gt;<br>
&gt; &gt; This is a new series as &#39;async reclaim&#39;, no watermark.<br=
>
&gt; &gt; This version is a RFC again and I don&#39;t ask anyone to test th=
is...but<br>
&gt; &gt; comments/review are appreciated.<br>
&gt; &gt;<br>
&gt; &gt; Major changes are<br>
&gt; &gt; =A0 - no configurable watermark<br>
&gt; &gt; =A0 - hierarchy support<br>
&gt; &gt; =A0 - more fix for static scan rate round robin scanning of memcg=
.<br>
&gt; &gt;<br>
&gt; &gt; (assume x86-64 in following.)<br>
&gt; &gt;<br>
&gt; &gt; &#39;async reclaim&#39; works when<br>
&gt; &gt; =A0 =A0- usage &gt; limit - 4MB.<br>
&gt; &gt; until<br>
&gt; &gt; =A0 =A0- usage &lt; limit - 8MB.<br>
&gt; &gt;<br>
&gt; &gt; when the limit is larger than 128MB. This value of margin to limi=
t<br>
&gt; &gt; has some purpose for helping to reduce page fault latency at usin=
g<br>
&gt; &gt; Transparent hugepage.<br>
&gt; &gt;<br>
&gt; &gt; Considering THP, we need to reclaim HPAGE_SIZE(2MB) of pages when=
 we hit<br>
&gt; &gt; limit and consume HPAGE_SIZE(2MB) immediately. Then, the applicat=
ion need to<br>
&gt; &gt; scan 2MB per each page fault and get big latency. So, some margin=
 &gt; HPAGE_SIZE<br>
&gt; &gt; is required. I set it as 2*HPAGE_SIZE/4*HPAGE_SIZE, here. The ker=
nel<br>
&gt; &gt; will do async reclaim and reduce usage to limit - 8MB in backgrou=
nd.<br>
&gt; &gt;<br>
&gt; &gt; BTW, when an application gets a page, it tend to do some action t=
o fill the<br>
&gt; &gt; gotton page. For example, reading data from file/network and fill=
 buffer.<br>
&gt; &gt; This implies the application will have a wait or consumes cpu oth=
er than<br>
&gt; &gt; reclaiming memory. So, if the kernel can help memory freeing in b=
ackground<br>
&gt; &gt; while application does another jobs, application latency can be r=
educed.<br>
&gt; &gt; Then, this kind of asyncronous reclaim of memory will be a help f=
or reduce<br>
&gt; &gt; memory reclaim latency by memcg. But the total amount of cpu time=
 consumed<br>
&gt; &gt; will not have any difference.<br>
&gt; &gt;<br>
&gt; &gt; This patch series implements<br>
&gt; &gt; =A0 - a logic for trigger async reclaim<br>
&gt; &gt; =A0 - help functions for async reclaim<br>
&gt; &gt; =A0 - core logic for async reclaim, considering memcg&#39;s hiera=
rchy.<br>
&gt; &gt; =A0 - static scan rate memcg reclaim.<br>
&gt; &gt; =A0 - workqueue for async reclaim.<br>
&gt; &gt;<br>
&gt; &gt; Some concern is that I didn&#39;t implement a code for handle the=
 case<br>
&gt; &gt; most of pages are mlocked or anon memory in swapless system. I ne=
ed some<br>
&gt; &gt; detection logic to avoid hopless async reclaim.<br>
&gt; &gt;<br>
&gt;<br>
&gt; What (user-visible) problem is this patchset solving?<br>
&gt;<br>
&gt; IOW, what is the current behaviour, what is wrong with that behaviour<=
br>
&gt; and what effects does the patchset have upon that behaviour?<br>
&gt;<br>
&gt; The sole answer from the above is &quot;latency spikes&quot;. =A0Anyth=
ing else?<br>
&gt;<br>
<br>
</div></div>I think this set has possibility to fix latency spike.<br>
<br>
For example, in previous set, (which has tuning knobs), do a file copy<br>
of 400M file under 400M limit.<br>
=3D=3D<br>
1) =3D=3D hard limit =3D 400M =3D=3D<br>
[root@rhel6-test hilow]# time cp ./tmpfile xxx<br>
real =A0 =A00m7.353s<br>
user =A0 =A00m0.009s<br>
sys =A0 =A0 0m3.280s<br>
<br>
2) =3D=3D hard limit 500M/ hi_watermark =3D 400M =3D=3D<br>
[root@rhel6-test hilow]# time cp ./tmpfile xxx<br>
<br>
real =A0 =A00m6.421s<br>
user =A0 =A00m0.059s<br>
sys =A0 =A0 0m2.707s<br>
=3D=3D<br>
and in both case, memory usage after test was 400M.<br>
<br>
IIUC, this speed up is because memory reclaim runs in background file &#39;=
cp&#39;<br>
read/write files. But above test uses 100MB of margin. I gues we don&#39;t =
need<br>
100MB of margin as above but will not get full speed with 8MB margin. There=
<br>
will be trade-off because users may want to use memory up to the limit.<br>
<br>
So, this set tries to set some &#39;default&#39; margin, which is not too b=
ig and has<br>
idea that implements async reclaim without tuning knobs. I&#39;ll measure<b=
r>
some more and report it in the next post.<br>
<div class=3D"im"><br>
I can also try to run some workload to measure the performance impact. Kame=
, just let me know<br></div></blockquote><div>when you have patch ready for=
 testing.=A0</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">
&gt; Have these spikes been observed and measured? =A0We should have a<br>
&gt; testcase/worload with quantitative results to demonstrate and measure<=
br>
&gt; the problem(s), so the effectiveness of the proposed solution can be<b=
r>
&gt; understood.<br>
&gt;<br>
&gt;<br>
<br>
</div>Yes, you&#39;re right, of course.<br>
This set just shows the design changes caused by removing tuning knobs as<b=
r>
a result of long discussion.<br>
<br>
As an output of it, we do<br>
=A01. impleimenting async reclaim without tuning knobs.<br>
=A02. add some on-demand background reclaim as &#39;active softlimit&#39;, =
which means<br>
 =A0 =A0a mode of softlimit, shrinking memory always even if the system has=
 plenty of<br>
 =A0 =A0free memory. And current softlimit, which works only when memory ar=
e in short,<br>
 =A0 =A0will be called as &#39;passive softlimit&#39;.<br></blockquote><div=
>=A0</div><div>The second one is a useful feature not only doing watermark =
based reclaim, but proactively reclaiming</div><div>pages down to the soft_=
limit. We at google are talking about adopting it to=A0guarantee=A0more=A0p=
redictability</div>
<div>for applications where the soft_limit could be configured to the actua=
l working_set_size.=A0</div><div><br></div><div>--Ying</div><div>=A0</div><=
div><br></div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>

--002354470aa8b4a54304a30ab582--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
