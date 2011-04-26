Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE8B9000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 04:43:25 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p3Q8hJVZ021387
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:43:19 -0700
Received: from qyl38 (qyl38.prod.google.com [10.241.83.230])
	by hpaq1.eem.corp.google.com with ESMTP id p3Q8h4CY014126
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:43:18 -0700
Received: by qyl38 with SMTP id 38so318539qyl.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 01:43:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
	<20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 01:43:17 -0700
Message-ID: <BANLkTi=sSrrQCMXKJor95Cn-JmiQ=XUAkA@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0050450161c3ca64b704a1ce501e
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

--0050450161c3ca64b704a1ce501e
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 26, 2011 at 12:43 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 26 Apr 2011 00:19:46 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Mon, 25 Apr 2011 15:21:21 -0700
> > > Ying Han <yinghan@google.com> wrote:
>
> > >> Thank you for putting time on implementing the patch. I think it is
> > >> definitely a good idea to have the two alternatives on the table since
> > >> people has asked the questions. Before going down to the track, i have
> > >> thought about the two approaches and also discussed with Greg and Hugh
> > >> (cc-ed),  i would like to clarify some of the pros and cons on both
> > >> approaches.  In general, I think the workqueue is not the right answer
> > >> for this purpose.
> > >>
> > >> The thread-pool model
> > >> Pros:
> > >> 1. there is no isolation between memcg background reclaim, since the
> > >> memcg threads are shared. That isolation including all the resources
> > >> that the per-memcg background reclaim will need to access, like cpu
> > >> time. One thing we are missing for the shared worker model is the
> > >> individual cpu scheduling ability. We need the ability to isolate and
> > >> count the resource assumption per memcg, and including how much
> > >> cputime and where to run the per-memcg kswapd thread.
> > >>
> > >
> > > IIUC, new threads for workqueue will be created if necessary in
> automatic.
> > >
> > I read your patches today, but i might missed some details while I was
> > reading it. I will read them through tomorrow.
> >
>
> Thank you.
>
> > The question I was wondering here is
> > 1. how to do cpu cgroup limit per-memcg including the kswapd time.
>
> I'd like to add some limitation based on elapsed time. For example,
> only allow to run 10ms within 1sec. It's a background job should be
> limited. Or, simply adds static delay per memcg at queue_delayed_work().
> Then, the user can limit scan/sec. But what I wonder now is what is the
> good interface....msec/sec ? scan/sec, free/sec ? etc...
>
>
> > 2. how to do numa awareness cpu scheduling if i want to do cpumask on
> > the memcg-kswapd close to the numa node where all the pages of the
> > memcg allocated.
> >
> > I guess the second one should have been covered. If not, it shouldn't
> > be a big effort to fix that. And any suggestions on the first one.
> >
>
> Interesting. If we use WQ_CPU_INTENSIVE + queue_work_on() instead
> of WQ_UNBOUND, we can control which cpu to do jobs.
>
> "The default cpu" to run wmark-reclaim can by calculated by
> css_id(&mem->css) % num_online_cpus() or some round robin at
> memcg creation. Anyway, we'll need to use WQ_CPU_INTENSIVE.
> It may give us good result than WQ_UNBOUND...
>
> Adding an interface for limiting cpu is...hmm. per memcg ? or
> as the generic memcg param ? It will a memcg parameter not
> a threads's.
>


> To clarify a bit, my question was meant to account it but not necessary to
> limit it. We can use existing cpu cgroup to do the cpu limiting, and I am
>
just wondering how to configure it for the memcg kswapd thread.

   Let's say in the per-memcg-kswapd model, i can echo the kswapd thread pid
into the cpu cgroup ( the same set of process of memcg, but in a cpu
limiting cgroup instead).  If the kswapd is shared, we might need extra work
to account the cpu cycles correspondingly.

> >
> > >> 4. the kswapd threads are created and destroyed dynamically. are we
> > >> talking about allocating 8k of stack for kswapd when we are under
> > >> memory pressure? In the other case, all the memory are preallocated.
> > >>
> > >
> > > I think workqueue is there for avoiding 'making kthread dynamically'.
> > > We can save much codes.
> >
> > So right now, the workqueue is configured as unbounded. which means
> > the worse case we might create
> > the same number of workers as the number of memcgs. ( if each memcg
> > takes long time to do the reclaim). So this might not be a problem,
> > but I would like to confirm.
> >
> From documenation, max_active unbound workqueue (default) is
> ==
> Currently, for a bound wq, the maximum limit for @max_active is 512
> and the default value used when 0 is specified is 256.  For an unbound
> wq, the limit is higher of 512 and 4 * num_possible_cpus().  These
> values are chosen sufficiently high such that they are not the
> limiting factor while providing protection in runaway cases.
> ==
> 512 ?  If wmark-reclaim burns cpu (and get rechedule), new kthread will
> be created.
>
> Ok, so we have here max(512, 4*num_possible_cpus) execution context per
cpu, and that should be
less or equal to the number of memcgs on the system. (since we have one work
item per memcg).

>
> > >
> > >> 5. the workqueue is scary and might introduce issues sooner or later.
> > >> Also, why we think the background reclaim fits into the workqueue
> > >> model, and be more specific, how that share the same logic of other
> > >> parts of the system using workqueue.
> > >>
> > >
> > > Ok, with using workqueue.
> > >
> > >  1. The number of threads can be changed dynamically with regard to
> system
> > >     workload without adding any codes. workqueue is for this kind of
> > >     background jobs. gcwq has a hooks to scheduler and it works well.
> > >     With per-memcg thread model, we'll never be able to do such.
> > >
> > >  2. We can avoid having unncessary threads.
> > >     If it sleeps most of time, why we need to keep it ? No, it's
> unnecessary.
> > >     It should be on-demand. freezer() etc need to stop all threads and
> > >     thousands of sleeping threads will be harmful.
> > >     You can see how 'ps -elf' gets slow when the number of threads
> increases.
> >
> > In general, i am not strongly against the workqueue but trying to
> > understand the procs and cons between the two approaches. The first
> > one is definitely simpler and more straight-forward, and I was
> > suggesting to start with something simple and improve it later if we
> > see problems. But I will read your path through tomorrow and also
> > willing to see comments from others.
> >
> > Thank you for the efforts!
> >
>
> you, too.
>
> Anyway, get_scan_count() seems to be a big problem and I'll cut out it
> as independent patch.
>

sounds good to me.

--Ying


> Thanks,
> -Kame
>
>
>
>
>
>

--0050450161c3ca64b704a1ce501e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 26, 2011 at 12:43 AM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
On Tue, 26 Apr 2011 00:19:46 -0700<br>
<div class=3D"im">Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
&gt; On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki<br>
&gt; &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@=
jp.fujitsu.com</a>&gt; wrote:<br>
&gt; &gt; On Mon, 25 Apr 2011 15:21:21 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
<br>
</div><div class=3D"im">&gt; &gt;&gt; Thank you for putting time on impleme=
nting the patch. I think it is<br>
&gt; &gt;&gt; definitely a good idea to have the two alternatives on the ta=
ble since<br>
&gt; &gt;&gt; people has asked the questions. Before going down to the trac=
k, i have<br>
&gt; &gt;&gt; thought about the two approaches and also discussed with Greg=
 and Hugh<br>
&gt; &gt;&gt; (cc-ed), =A0i would like to clarify some of the pros and cons=
 on both<br>
&gt; &gt;&gt; approaches. =A0In general, I think the workqueue is not the r=
ight answer<br>
&gt; &gt;&gt; for this purpose.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; The thread-pool model<br>
&gt; &gt;&gt; Pros:<br>
&gt; &gt;&gt; 1. there is no isolation between memcg background reclaim, si=
nce the<br>
&gt; &gt;&gt; memcg threads are shared. That isolation including all the re=
sources<br>
&gt; &gt;&gt; that the per-memcg background reclaim will need to access, li=
ke cpu<br>
&gt; &gt;&gt; time. One thing we are missing for the shared worker model is=
 the<br>
&gt; &gt;&gt; individual cpu scheduling ability. We need the ability to iso=
late and<br>
&gt; &gt;&gt; count the resource assumption per memcg, and including how mu=
ch<br>
&gt; &gt;&gt; cputime and where to run the per-memcg kswapd thread.<br>
&gt; &gt;&gt;<br>
&gt; &gt;<br>
&gt; &gt; IIUC, new threads for workqueue will be created if necessary in a=
utomatic.<br>
&gt; &gt;<br>
&gt; I read your patches today, but i might missed some details while I was=
<br>
&gt; reading it. I will read them through tomorrow.<br>
&gt;<br>
<br>
</div>Thank you.<br>
<div class=3D"im"><br>
&gt; The question I was wondering here is<br>
&gt; 1. how to do cpu cgroup limit per-memcg including the kswapd time.<br>
<br>
</div>I&#39;d like to add some limitation based on elapsed time. For exampl=
e,<br>
only allow to run 10ms within 1sec. It&#39;s a background job should be<br>
limited. Or, simply adds static delay per memcg at queue_delayed_work().<br=
>
Then, the user can limit scan/sec. But what I wonder now is what is the<br>
good interface....msec/sec ? scan/sec, free/sec ? etc...<br>
<div class=3D"im"><br>
<br>
&gt; 2. how to do numa awareness cpu scheduling if i want to do cpumask on<=
br>
&gt; the memcg-kswapd close to the numa node where all the pages of the<br>
&gt; memcg allocated.<br>
&gt;<br>
&gt; I guess the second one should have been covered. If not, it shouldn&#3=
9;t<br>
&gt; be a big effort to fix that. And any suggestions on the first one.<br>
&gt;<br>
<br>
</div>Interesting. If we use WQ_CPU_INTENSIVE + queue_work_on() instead<br>
of WQ_UNBOUND, we can control which cpu to do jobs.<br>
<br>
&quot;The default cpu&quot; to run wmark-reclaim can by calculated by<br>
css_id(&amp;mem-&gt;css) % num_online_cpus() or some round robin at<br>
memcg creation. Anyway, we&#39;ll need to use WQ_CPU_INTENSIVE.<br>
It may give us good result than WQ_UNBOUND...<br>
<br>
Adding an interface for limiting cpu is...hmm. per memcg ? or<br>
as the generic memcg param ? It will a memcg parameter not<br>
a threads&#39;s.<br>
<div class=3D"im"></div></blockquote><div>=A0</div><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex;"><div class=3D"im">To clarify a bit, my question was meant to accoun=
t it but not necessary to limit it. We can use existing cpu cgroup to do th=
e cpu limiting, and I am<br>
</div></blockquote><div>just wondering how to configure it for the memcg ks=
wapd thread.</div><div><br></div><div>=A0=A0 Let&#39;s say in the per-memcg=
-kswapd model, i can echo the kswapd thread pid into the cpu cgroup ( the s=
ame set of process of memcg, but in a cpu limiting cgroup instead). =A0If t=
he kswapd is shared, we might need extra work to account the cpu cycles cor=
respondingly.</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;"><div class=3D"im">
&gt; &gt;<br>
&gt; &gt;&gt; 4. the kswapd threads are created and destroyed dynamically. =
are we<br>
&gt; &gt;&gt; talking about allocating 8k of stack for kswapd when we are u=
nder<br>
&gt; &gt;&gt; memory pressure? In the other case, all the memory are preall=
ocated.<br>
&gt; &gt;&gt;<br>
&gt; &gt;<br>
&gt; &gt; I think workqueue is there for avoiding &#39;making kthread dynam=
ically&#39;.<br>
&gt; &gt; We can save much codes.<br>
&gt;<br>
&gt; So right now, the workqueue is configured as unbounded. which means<br=
>
&gt; the worse case we might create<br>
&gt; the same number of workers as the number of memcgs. ( if each memcg<br=
>
&gt; takes long time to do the reclaim). So this might not be a problem,<br=
>
&gt; but I would like to confirm.<br>
&gt;<br>
</div>From documenation, max_active unbound workqueue (default) is<br>
=3D=3D<br>
Currently, for a bound wq, the maximum limit for @max_active is 512<br>
and the default value used when 0 is specified is 256. =A0For an unbound<br=
>
wq, the limit is higher of 512 and 4 * num_possible_cpus(). =A0These<br>
values are chosen sufficiently high such that they are not the<br>
limiting factor while providing protection in runaway cases.<br>
=3D=3D<br>
512 ? =A0If wmark-reclaim burns cpu (and get rechedule), new kthread will<b=
r>
be created.<br>
<div class=3D"im"><br></div></blockquote><div>Ok, so we have here max(512, =
4*num_possible_cpus)=A0execution context per cpu, and that should be</div><=
div>less or equal to the number of memcgs on the system. (since we have one=
 work item per memcg).=A0=A0</div>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;"><div class=3D"im">
<br>
&gt; &gt;<br>
&gt; &gt;&gt; 5. the workqueue is scary and might introduce issues sooner o=
r later.<br>
&gt; &gt;&gt; Also, why we think the background reclaim fits into the workq=
ueue<br>
&gt; &gt;&gt; model, and be more specific, how that share the same logic of=
 other<br>
&gt; &gt;&gt; parts of the system using workqueue.<br>
&gt; &gt;&gt;<br>
&gt; &gt;<br>
&gt; &gt; Ok, with using workqueue.<br>
&gt; &gt;<br>
&gt; &gt; =A01. The number of threads can be changed dynamically with regar=
d to system<br>
&gt; &gt; =A0 =A0 workload without adding any codes. workqueue is for this =
kind of<br>
&gt; &gt; =A0 =A0 background jobs. gcwq has a hooks to scheduler and it wor=
ks well.<br>
&gt; &gt; =A0 =A0 With per-memcg thread model, we&#39;ll never be able to d=
o such.<br>
&gt; &gt;<br>
&gt; &gt; =A02. We can avoid having unncessary threads.<br>
&gt; &gt; =A0 =A0 If it sleeps most of time, why we need to keep it ? No, i=
t&#39;s unnecessary.<br>
&gt; &gt; =A0 =A0 It should be on-demand. freezer() etc need to stop all th=
reads and<br>
&gt; &gt; =A0 =A0 thousands of sleeping threads will be harmful.<br>
&gt; &gt; =A0 =A0 You can see how &#39;ps -elf&#39; gets slow when the numb=
er of threads increases.<br>
&gt;<br>
&gt; In general, i am not strongly against the workqueue but trying to<br>
&gt; understand the procs and cons between the two approaches. The first<br=
>
&gt; one is definitely simpler and more straight-forward, and I was<br>
&gt; suggesting to start with something simple and improve it later if we<b=
r>
&gt; see problems. But I will read your path through tomorrow and also<br>
&gt; willing to see comments from others.<br>
&gt;<br>
&gt; Thank you for the efforts!<br>
&gt;<br>
<br>
</div>you, too.<br>
<br>
Anyway, get_scan_count() seems to be a big problem and I&#39;ll cut out it<=
br>
as independent patch.<br></blockquote><div><br></div><div>sounds good to me=
.=A0</div><div><br></div><div>--Ying</div><div>=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex;">

Thanks,<br>
-Kame<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>

--0050450161c3ca64b704a1ce501e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
