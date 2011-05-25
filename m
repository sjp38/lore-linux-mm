Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5574F6B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 01:52:07 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4P5pwND021599
	for <linux-mm@kvack.org>; Tue, 24 May 2011 22:51:59 -0700
Received: from qyk35 (qyk35.prod.google.com [10.241.83.163])
	by wpaz29.hot.corp.google.com with ESMTP id p4P5pth5003750
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 May 2011 22:51:57 -0700
Received: by qyk35 with SMTP id 35so1908839qyk.20
        for <linux-mm@kvack.org>; Tue, 24 May 2011 22:51:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110523092557.30d322aa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124837.72978344.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520145115.d52f3693.akpm@linux-foundation.org>
	<BANLkTinwmtgh+p=aeZux3NuC2ftbR5OMgQ@mail.gmail.com>
	<20110520182640.7e71af33.akpm@linux-foundation.org>
	<20110523092557.30d322aa.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 24 May 2011 22:51:55 -0700
Message-ID: <BANLkTimpzLpGqtuNaPUP3hAhOS3eA_iG1A@mail.gmail.com>
Subject: Re: [PATCH 8/8] memcg asyncrhouns reclaim workqueue
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bc51627f04a4134de1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

--000e0ce008bc51627f04a4134de1
Content-Type: text/plain; charset=ISO-8859-1

On Sun, May 22, 2011 at 5:25 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 20 May 2011 18:26:40 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
> > On Sat, 21 May 2011 09:41:50 +0900 Hiroyuki Kamezawa <
> kamezawa.hiroyuki@gmail.com> wrote:
> >
> > > 2011/5/21 Andrew Morton <akpm@linux-foundation.org>:
> > > > On Fri, 20 May 2011 12:48:37 +0900
> > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > >
> > > >> workqueue for memory cgroup asynchronous memory shrinker.
> > > >>
> > > >> This patch implements the workqueue of async shrinker routine. each
> > > >> memcg has a work and only one work can be scheduled at the same
> time.
> > > >>
> > > >> If shrinking memory doesn't goes well, delay will be added to the
> work.
> > > >>
> > > >
> > > > When this code explodes (as it surely will), users will see large
> > > > amounts of CPU consumption in the work queue thread. __We want to
> make
> > > > this as easy to debug as possible, so we should try to make the
> > > > workqueue's names mappable back onto their memcg's. __And anything
> else
> > > > we can think of to help?
>

When we debug kswapd issues in the memory isolation environment, the first
step is to identify which cgroup
the kswapd thread is working on. We need a easy way to make the direct
mapping by reading a API or just
look at "top". So making the "kworkers" name mapped back to the memcg helps
here.

Also, we need a easy way to track the amount of cputime consumed by the
kswapd per-memcg basis. We probably
can export that number in the per-memcg memory.stats. Kame has the patch
from the last post.



> > > >
> > >
> > > I had a patch for showing per-memcg reclaim latency stats. It will be
> help.
> > > I'll add it again to this set. I just dropped it because there are many
> patches
> > > onto memory.stat in flight..
> >
> > Will that patch help us when users report the memcg equivalent of
> > "kswapd uses 99% of CPU"?
> >
> I think so. Each memcg shows what amount of cpu is used.
>
> But, maybe it's not an easy interface. I have several idea.
>
>
> An idea I have is to rename task->comm by overwrite from  kworker/u:%d as
> to memcg/%d when the work is scheduled. I think this can be implemented in
> very
> simple interface and flags to workqueue. Then, ps -elf can show what was
> goin on.
> If necessary, I'll add a hardlimit of cpu usage for a work or I'll limit
> the number of thread for memcg workqueue.
>

Does it make sense to have memcg/css->id as the name if that is not the case
yet? Otherwise,
there is hard to link the kworker/%d ( or memcg/% later) back to the memcg
it is working on.

On the last post of per-memcg-per-kswapd implementation, i have the thread
named "memcg-css_id",
and also has a API per-memcg to export its css_id. So we can easily identify
the kernel thread to its
owner.


> Considering there are user who uses 2000+ memcg on a system, a thread per a
> memcg
> was not a choice to me.


So that is only about 2000 * 8k = 16M worth of memory over the machine
capacity (probably a very large number by
have the 2000+ memcgs running). We've run systems w/ 1000+ kswapds w/o
noticing troubles on that. What that is
buying us is better visibility(more of cpu limit per memcg kswapd)
and debug-ability.

Sorry I know we have discussed this before on other thread, but I can not
prevent myself not repeating here again :(  Just want to provide a datapoint
where we have lots of kswapd threads (> 1000) per host and that is not
causing us any issues as you concerned. :)

--Ying


> Another idea was thread poll or workqueue. Because thread
> pool can be a poor reimplemenation of workqueue, I used workqueue.
>



>
> I'll implement some idea in above to the next version.
>
>
> > > >
> > > >> + __ __ limit = res_counter_read_u64(&mem->res, RES_LIMIT);
> > > >> + __ __ shrink_to = limit - MEMCG_ASYNC_MARGIN - PAGE_SIZE;
> > > >> + __ __ usage = res_counter_read_u64(&mem->res, RES_USAGE);
> > > >> + __ __ if (shrink_to <= usage) {
> > > >> + __ __ __ __ __ __ required = usage - shrink_to;
> > > >> + __ __ __ __ __ __ required = (required >> PAGE_SHIFT) + 1;
> > > >> + __ __ __ __ __ __ /*
> > > >> + __ __ __ __ __ __ __* This scans some number of pages and returns
> that memory
> > > >> + __ __ __ __ __ __ __* reclaim was slow or now. If slow, we add a
> delay as
> > > >> + __ __ __ __ __ __ __* congestion_wait() in vmscan.c
> > > >> + __ __ __ __ __ __ __*/
> > > >> + __ __ __ __ __ __ congested = mem_cgroup_shrink_static_scan(mem,
> (long)required);
> > > >> + __ __ }
> > > >> + __ __ if (test_bit(ASYNC_NORESCHED, &mem->async_flags)
> > > >> + __ __ __ __ || mem_cgroup_async_should_stop(mem))
> > > >> + __ __ __ __ __ __ goto finish_scan;
> > > >> + __ __ /* If memory reclaim couldn't go well, add delay */
> > > >> + __ __ if (congested)
> > > >> + __ __ __ __ __ __ delay = HZ/10;
> > > >
> > > > Another magic number.
> > > >
> > > > If Moore's law holds, we need to reduce this number by 1.4 each year.
> > > > Is this good?
> > > >
> > >
> > > not good.  I just used the same magic number now used with
> wait_iff_congested.
> > > Other than timer, I can use pagein/pageout event counter. If we have
> > > dirty_ratio,
> > > I may able to link this to dirty_ratio and wait until dirty_ratio is
> enough low.
> > > Or, wake up again hit limit.
> > >
> > > Do you have suggestion ?
> > >
> >
> > mm..  It would be pretty easy to generate an estimate of "pages scanned
> > per second" from the contents of (and changes in) the scan_control.
>
> Hmm.
>
> > Konwing that datum and knowing the number of pages in the memcg, we
> > should be able to come up with a delay period which scales
> > appropriately with CPU speed and with memory size?
> >
> > Such a thing could be used to rationalise magic delays in other places,
> > hopefully.
> >
>
> Ok, I'll conder that. Thank you for nice idea.
>
>
> > >
> > > >> + __ __ queue_delayed_work(memcg_async_shrinker, &mem->async_work,
> delay);
> > > >> + __ __ return;
> > > >> +finish_scan:
> > > >> + __ __ cgroup_release_and_wakeup_rmdir(&mem->css);
> > > >> + __ __ clear_bit(ASYNC_RUNNING, &mem->async_flags);
> > > >> + __ __ return;
> > > >> +}
> > > >> +
> > > >> +static void run_mem_cgroup_async_shrinker(struct mem_cgroup *mem)
> > > >> +{
> > > >> + __ __ if (test_bit(ASYNC_NORESCHED, &mem->async_flags))
> > > >> + __ __ __ __ __ __ return;
> > > >
> > > > I can't work out what ASYNC_NORESCHED does. __Is its name
> well-chosen?
> > > >
> > > how about BLOCK/STOP_ASYNC_RECLAIM ?
> >
> > I can't say - I don't know what it does!  Or maybe I did, and immediately
> > forgot ;)
> >
>
> I'll find a better name ;)
>
> Thanks,
> -Kame
>
>

--000e0ce008bc51627f04a4134de1
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, May 22, 2011 at 5:25 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Fri, 20 May 2011 18:26:40 -0700<br>
Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundation.org">akpm@linux-f=
oundation.org</a>&gt; wrote:<br>
<br>
&gt; On Sat, 21 May 2011 09:41:50 +0900 Hiroyuki Kamezawa &lt;<a href=3D"ma=
ilto:kamezawa.hiroyuki@gmail.com">kamezawa.hiroyuki@gmail.com</a>&gt; wrote=
:<br>
&gt;<br>
&gt; &gt; 2011/5/21 Andrew Morton &lt;<a href=3D"mailto:akpm@linux-foundati=
on.org">akpm@linux-foundation.org</a>&gt;:<br>
&gt; &gt; &gt; On Fri, 20 May 2011 12:48:37 +0900<br>
&gt; &gt; &gt; KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;&gt; workqueue for memory cgroup asynchronous memory shrinker=
.<br>
&gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt;&gt; This patch implements the workqueue of async shrinker ro=
utine. each<br>
&gt; &gt; &gt;&gt; memcg has a work and only one work can be scheduled at t=
he same time.<br>
&gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt;&gt; If shrinking memory doesn&#39;t goes well, delay will be=
 added to the work.<br>
&gt; &gt; &gt;&gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; When this code explodes (as it surely will), users will see =
large<br>
&gt; &gt; &gt; amounts of CPU consumption in the work queue thread. __We wa=
nt to make<br>
&gt; &gt; &gt; this as easy to debug as possible, so we should try to make =
the<br>
&gt; &gt; &gt; workqueue&#39;s names mappable back onto their memcg&#39;s. =
__And anything else<br>
&gt; &gt; &gt; we can think of to help?<br></div></blockquote><div><br></di=
v><div>When we debug kswapd issues in the memory isolation=A0environment, t=
he first step is to identify which cgroup</div><div>the kswapd thread is wo=
rking on. We need a easy way to make the direct mapping by reading a API or=
 just</div>
<div>look at=A0&quot;top&quot;. So making the &quot;kworkers&quot; name map=
ped back to the memcg helps here.</div><div><br></div><div>Also, we need a =
easy way to track the amount of cputime consumed by the kswapd per-memcg ba=
sis. We probably</div>
<div>can export that number in the per-memcg memory.stats. Kame has the pat=
ch from the last post.</div><div><br></div><div>=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">
<div class=3D"im">
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; I had a patch for showing per-memcg reclaim latency stats. It wil=
l be help.<br>
&gt; &gt; I&#39;ll add it again to this set. I just dropped it because ther=
e are many patches<br>
&gt; &gt; onto memory.stat in flight..<br>
&gt;<br>
&gt; Will that patch help us when users report the memcg equivalent of<br>
&gt; &quot;kswapd uses 99% of CPU&quot;?<br>
&gt;<br>
</div>I think so. Each memcg shows what amount of cpu is used.<br>
<br>
But, maybe it&#39;s not an easy interface. I have several idea.<br>
<br>
<br>
An idea I have is to rename task-&gt;comm by overwrite from =A0kworker/u:%d=
 as<br>
to memcg/%d when the work is scheduled. I think this can be implemented in =
very<br>
simple interface and flags to workqueue. Then, ps -elf can show what was go=
in on.<br>
If necessary, I&#39;ll add a hardlimit of cpu usage for a work or I&#39;ll =
limit<br>
the number of thread for memcg workqueue.<br></blockquote><div><br></div><d=
iv>Does it make sense to have memcg/css-&gt;id as the name if that is not t=
he case yet? Otherwise,=A0</div><div>there is hard to link the kworker/%d (=
 or memcg/% later) back to the memcg it is working on.</div>
<div><br></div><div>On the last post of per-memcg-per-kswapd implementation=
, i have the thread named &quot;memcg-css_id&quot;,</div><div>and also has =
a API per-memcg to export its css_id. So we can easily identify the kernel =
thread to its</div>
<div>owner.</div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
Considering there are user who uses 2000+ memcg on a system, a thread per a=
 memcg<br>
was not a choice to me.</blockquote><div>=A0</div><div>So that is only abou=
t 2000 * 8k =3D 16M worth of memory over the machine capacity (probably a v=
ery large number by</div><div>have the 2000+ memcgs running). We&#39;ve run=
 systems w/ 1000+ kswapds w/o noticing troubles on that. What that is</div>
<div>buying us is better visibility(more of cpu limit per memcg kswapd) and=
=A0debug-ability.</div><div><br></div><div>Sorry I know we have discussed t=
his before on other thread, but I can not prevent myself not repeating here=
 again :( =A0Just want to provide a datapoint where we have lots of kswapd =
threads (&gt; 1000) per host and that is not causing us any issues as you c=
oncerned. :)</div>
<div><br></div><div>--Ying</div><div>=A0</div><blockquote class=3D"gmail_qu=
ote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex=
;">Another idea was thread poll or workqueue. Because thread<br>
pool can be a poor reimplemenation of workqueue, I used workqueue.<br></blo=
ckquote><div><br></div><div>=A0</div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
I&#39;ll implement some idea in above to the next version.<br>
<div><div></div><div class=3D"h5"><br>
<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt;&gt; + __ __ limit =3D res_counter_read_u64(&amp;mem-&gt;res,=
 RES_LIMIT);<br>
&gt; &gt; &gt;&gt; + __ __ shrink_to =3D limit - MEMCG_ASYNC_MARGIN - PAGE_=
SIZE;<br>
&gt; &gt; &gt;&gt; + __ __ usage =3D res_counter_read_u64(&amp;mem-&gt;res,=
 RES_USAGE);<br>
&gt; &gt; &gt;&gt; + __ __ if (shrink_to &lt;=3D usage) {<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ required =3D usage - shrink_to;<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ required =3D (required &gt;&gt; PAGE=
_SHIFT) + 1;<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ /*<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ __* This scans some number of pages =
and returns that memory<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ __* reclaim was slow or now. If slow=
, we add a delay as<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ __* congestion_wait() in vmscan.c<br=
>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ __*/<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ congested =3D mem_cgroup_shrink_stat=
ic_scan(mem, (long)required);<br>
&gt; &gt; &gt;&gt; + __ __ }<br>
&gt; &gt; &gt;&gt; + __ __ if (test_bit(ASYNC_NORESCHED, &amp;mem-&gt;async=
_flags)<br>
&gt; &gt; &gt;&gt; + __ __ __ __ || mem_cgroup_async_should_stop(mem))<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ goto finish_scan;<br>
&gt; &gt; &gt;&gt; + __ __ /* If memory reclaim couldn&#39;t go well, add d=
elay */<br>
&gt; &gt; &gt;&gt; + __ __ if (congested)<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ delay =3D HZ/10;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Another magic number.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; If Moore&#39;s law holds, we need to reduce this number by 1=
.4 each year.<br>
&gt; &gt; &gt; Is this good?<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; not good. =A0I just used the same magic number now used with wait=
_iff_congested.<br>
&gt; &gt; Other than timer, I can use pagein/pageout event counter. If we h=
ave<br>
&gt; &gt; dirty_ratio,<br>
&gt; &gt; I may able to link this to dirty_ratio and wait until dirty_ratio=
 is enough low.<br>
&gt; &gt; Or, wake up again hit limit.<br>
&gt; &gt;<br>
&gt; &gt; Do you have suggestion ?<br>
&gt; &gt;<br>
&gt;<br>
&gt; mm.. =A0It would be pretty easy to generate an estimate of &quot;pages=
 scanned<br>
&gt; per second&quot; from the contents of (and changes in) the scan_contro=
l.<br>
<br>
</div></div>Hmm.<br>
<div class=3D"im"><br>
&gt; Konwing that datum and knowing the number of pages in the memcg, we<br=
>
&gt; should be able to come up with a delay period which scales<br>
&gt; appropriately with CPU speed and with memory size?<br>
&gt;<br>
&gt; Such a thing could be used to rationalise magic delays in other places=
,<br>
&gt; hopefully.<br>
&gt;<br>
<br>
</div>Ok, I&#39;ll conder that. Thank you for nice idea.<br>
<div class=3D"im"><br>
<br>
&gt; &gt;<br>
&gt; &gt; &gt;&gt; + __ __ queue_delayed_work(memcg_async_shrinker, &amp;me=
m-&gt;async_work, delay);<br>
&gt; &gt; &gt;&gt; + __ __ return;<br>
&gt; &gt; &gt;&gt; +finish_scan:<br>
&gt; &gt; &gt;&gt; + __ __ cgroup_release_and_wakeup_rmdir(&amp;mem-&gt;css=
);<br>
&gt; &gt; &gt;&gt; + __ __ clear_bit(ASYNC_RUNNING, &amp;mem-&gt;async_flag=
s);<br>
&gt; &gt; &gt;&gt; + __ __ return;<br>
&gt; &gt; &gt;&gt; +}<br>
&gt; &gt; &gt;&gt; +<br>
&gt; &gt; &gt;&gt; +static void run_mem_cgroup_async_shrinker(struct mem_cg=
roup *mem)<br>
&gt; &gt; &gt;&gt; +{<br>
&gt; &gt; &gt;&gt; + __ __ if (test_bit(ASYNC_NORESCHED, &amp;mem-&gt;async=
_flags))<br>
&gt; &gt; &gt;&gt; + __ __ __ __ __ __ return;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; I can&#39;t work out what ASYNC_NORESCHED does. __Is its nam=
e well-chosen?<br>
&gt; &gt; &gt;<br>
&gt; &gt; how about BLOCK/STOP_ASYNC_RECLAIM ?<br>
&gt;<br>
&gt; I can&#39;t say - I don&#39;t know what it does! =A0Or maybe I did, an=
d immediately<br>
&gt; forgot ;)<br>
&gt;<br>
<br>
</div>I&#39;ll find a better name ;)<br>
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--000e0ce008bc51627f04a4134de1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
