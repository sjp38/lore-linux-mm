Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0FF8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 02:11:07 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p3M6B0U8019943
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:11:00 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by wpaz1.hot.corp.google.com with ESMTP id p3M6Avag030443
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:10:59 -0700
Received: by qwk3 with SMTP id 3so161692qwk.19
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:10:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422145943.a8f5a4ef.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-5-git-send-email-yinghan@google.com>
	<20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com>
	<20110422140023.949e5737.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim91aHXjqfukn6rJxK0SDSSG2wrrg@mail.gmail.com>
	<20110422145943.a8f5a4ef.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 23:10:58 -0700
Message-ID: <BANLkTikRvjNR94tUf2p9UPQFGLUYp41Twg@mail.gmail.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016360e3f5cb3ef5304a17bb873
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016360e3f5cb3ef5304a17bb873
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 10:59 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 21 Apr 2011 22:53:19 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Thu, Apr 21, 2011 at 10:00 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > On Thu, 21 Apr 2011 21:49:04 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki <
> > > > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > >
> > > > > On Thu, 21 Apr 2011 21:24:15 -0700
> > > > > Ying Han <yinghan@google.com> wrote:
> > > > >
> > > > > > This patch creates a thread pool for memcg-kswapd. All memcg
> which
> > > needs
> > > > > > background recalim are linked to a list and memcg-kswapd picks up
> a
> > > memcg
> > > > > > from the list and run reclaim.
> > > > > >
> > > > > > The concern of using per-memcg-kswapd thread is the system
> overhead
> > > > > including
> > > > > > memory and cputime.
> > > > > >
> > > > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com
> >
> > > > > > Signed-off-by: Ying Han <yinghan@google.com>
> > > > >
> > > > > Thank you for merging. This seems ok to me.
> > > > >
> > > > > Further development may make this better or change thread pools (to
> > > some
> > > > > other),
> > > > > but I think this is enough good.
> > > > >
> > > >
> > > > Thank you for reviewing and Acking. At the same time, I do have
> wondering
> > > on
> > > > the thread-pool modeling which I posted on the cover-letter :)
> > > >
> > > > The per-memcg-per-kswapd model
> > > > Pros:
> > > > 1. memory overhead per thread, and The memory consumption would be
> > > 8k*1000 =
> > > > 8M
> > > > with 1k cgroup.
> > > > 2. we see lots of threads at 'ps -elf'
> > > >
> > > > Cons:
> > > > 1. the implementation is simply and straigh-forward.
> > > > 2. we can easily isolate the background reclaim overhead between
> cgroups.
> > > > 3. better latency from memory pressure to actual start reclaiming
> > > >
> > > > The thread-pool model
> > > > Pros:
> > > > 1. there is no isolation between memcg background reclaim, since the
> > > memcg
> > > > threads
> > > > are shared.
> > > > 2. it is hard for visibility and debugability. I have been
> experienced a
> > > lot
> > > > when
> > > > some kswapds running creazy and we need a stright-forward way to
> identify
> > > > which
> > > > cgroup causing the reclaim.
> > > > 3. potential starvation for some memcgs, if one workitem stucks and
> the
> > > rest
> > > > of work
> > > > won't proceed.
> > > >
> > > > Cons:
> > > > 1. save some memory resource.
> > > >
> > > > In general, the per-memcg-per-kswapd implmentation looks sane to me
> at
> > > this
> > > > point, esepcially the sharing memcg thread model will make debugging
> > > issue
> > > > very hard later.
> > > >
> > > > Comments?
> > > >
> > > Pros <-> Cons ?
> > >
> > > My idea is adding trace point for memcg-kswapd and seeing what it's now
> > > doing.
> > > (We don't have too small trace point in memcg...)
> > >
> > > I don't think its sane to create kthread per memcg because we know
> there is
> > > a user
> > > who makes hundreds/thousands of memcg.
> > >
> > > And, I think that creating threads, which does the same job, more than
> the
> > > number
> > > of cpus will cause much more difficult starvation, priority inversion
> > > issue.
> > > Keeping scheduling knob/chances of jobs in memcg is important. I don't
> want
> > > to
> > > give a hint to scheduler because of memcg internal issue.
> > >
> > > And, even if memcg-kswapd doesn't exist, memcg works (well?).
> > > memcg-kswapd just helps making things better but not do any critical
> jobs.
> > > So, it's okay to have this as best-effort service.
> > > Of course, better scheduling idea for picking up memcg is welcomed.
> It's
> > > now
> > > round-robin.
> > >
> > > Hmm. The concern I have is the debug-ability. Let's say I am running a
> > system and found memcg-3 running crazy. Is there a way to find out which
> > memcg it is trying to reclaim pages from? Also, how to count cputime for
> the
> > shared memcg to the memcgs if we wanted to.
> >
>
> add a counter for kswapd-scan and kswapd-reclaim, kswapd-pickup will show
> you information, if necessary it's good to show some latecy stat. I think
> we can add enough information by adding stats (or debug by perf tools.)
> I'll consider this a a bit more.
>

Something like "kswapd_pgscan" and "kswapd_steal" per memcg? If we are going
to the thread-pool, we definitely need to add more stats to give us enough
visibility of per-memcg background reclaim activity. Still, not sure about
the cpu-cycles.

--Ying

>
> Thanks,
> -Kame
>
>
>
>
>
>

--0016360e3f5cb3ef5304a17bb873
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 10:59 PM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
On Thu, 21 Apr 2011 22:53:19 -0700<br>
<div><div></div><div class=3D"h5">Ying Han &lt;<a href=3D"mailto:yinghan@go=
ogle.com">yinghan@google.com</a>&gt; wrote:<br>
<br>
&gt; On Thu, Apr 21, 2011 at 10:00 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Thu, 21 Apr 2011 21:49:04 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; &gt; &gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.h=
iroyu@jp.fujitsu.com</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; On Thu, 21 Apr 2011 21:24:15 -0700<br>
&gt; &gt; &gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt; wrote:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; This patch creates a thread pool for memcg-kswapd.=
 All memcg which<br>
&gt; &gt; needs<br>
&gt; &gt; &gt; &gt; &gt; background recalim are linked to a list and memcg-=
kswapd picks up a<br>
&gt; &gt; memcg<br>
&gt; &gt; &gt; &gt; &gt; from the list and run reclaim.<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; The concern of using per-memcg-kswapd thread is th=
e system overhead<br>
&gt; &gt; &gt; &gt; including<br>
&gt; &gt; &gt; &gt; &gt; memory and cputime.<br>
&gt; &gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"ma=
ilto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;=
<br>
&gt; &gt; &gt; &gt; &gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:ying=
han@google.com">yinghan@google.com</a>&gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Thank you for merging. This seems ok to me.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Further development may make this better or change thre=
ad pools (to<br>
&gt; &gt; some<br>
&gt; &gt; &gt; &gt; other),<br>
&gt; &gt; &gt; &gt; but I think this is enough good.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Thank you for reviewing and Acking. At the same time, I do h=
ave wondering<br>
&gt; &gt; on<br>
&gt; &gt; &gt; the thread-pool modeling which I posted on the cover-letter =
:)<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; The per-memcg-per-kswapd model<br>
&gt; &gt; &gt; Pros:<br>
&gt; &gt; &gt; 1. memory overhead per thread, and The memory consumption wo=
uld be<br>
&gt; &gt; 8k*1000 =3D<br>
&gt; &gt; &gt; 8M<br>
&gt; &gt; &gt; with 1k cgroup.<br>
&gt; &gt; &gt; 2. we see lots of threads at &#39;ps -elf&#39;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Cons:<br>
&gt; &gt; &gt; 1. the implementation is simply and straigh-forward.<br>
&gt; &gt; &gt; 2. we can easily isolate the background reclaim overhead bet=
ween cgroups.<br>
&gt; &gt; &gt; 3. better latency from memory pressure to actual start recla=
iming<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; The thread-pool model<br>
&gt; &gt; &gt; Pros:<br>
&gt; &gt; &gt; 1. there is no isolation between memcg background reclaim, s=
ince the<br>
&gt; &gt; memcg<br>
&gt; &gt; &gt; threads<br>
&gt; &gt; &gt; are shared.<br>
&gt; &gt; &gt; 2. it is hard for visibility and debugability. I have been e=
xperienced a<br>
&gt; &gt; lot<br>
&gt; &gt; &gt; when<br>
&gt; &gt; &gt; some kswapds running creazy and we need a stright-forward wa=
y to identify<br>
&gt; &gt; &gt; which<br>
&gt; &gt; &gt; cgroup causing the reclaim.<br>
&gt; &gt; &gt; 3. potential starvation for some memcgs, if one workitem stu=
cks and the<br>
&gt; &gt; rest<br>
&gt; &gt; &gt; of work<br>
&gt; &gt; &gt; won&#39;t proceed.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Cons:<br>
&gt; &gt; &gt; 1. save some memory resource.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; In general, the per-memcg-per-kswapd implmentation looks san=
e to me at<br>
&gt; &gt; this<br>
&gt; &gt; &gt; point, esepcially the sharing memcg thread model will make d=
ebugging<br>
&gt; &gt; issue<br>
&gt; &gt; &gt; very hard later.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Comments?<br>
&gt; &gt; &gt;<br>
&gt; &gt; Pros &lt;-&gt; Cons ?<br>
&gt; &gt;<br>
&gt; &gt; My idea is adding trace point for memcg-kswapd and seeing what it=
&#39;s now<br>
&gt; &gt; doing.<br>
&gt; &gt; (We don&#39;t have too small trace point in memcg...)<br>
&gt; &gt;<br>
&gt; &gt; I don&#39;t think its sane to create kthread per memcg because we=
 know there is<br>
&gt; &gt; a user<br>
&gt; &gt; who makes hundreds/thousands of memcg.<br>
&gt; &gt;<br>
&gt; &gt; And, I think that creating threads, which does the same job, more=
 than the<br>
&gt; &gt; number<br>
&gt; &gt; of cpus will cause much more difficult starvation, priority inver=
sion<br>
&gt; &gt; issue.<br>
&gt; &gt; Keeping scheduling knob/chances of jobs in memcg is important. I =
don&#39;t want<br>
&gt; &gt; to<br>
&gt; &gt; give a hint to scheduler because of memcg internal issue.<br>
&gt; &gt;<br>
&gt; &gt; And, even if memcg-kswapd doesn&#39;t exist, memcg works (well?).=
<br>
&gt; &gt; memcg-kswapd just helps making things better but not do any criti=
cal jobs.<br>
&gt; &gt; So, it&#39;s okay to have this as best-effort service.<br>
&gt; &gt; Of course, better scheduling idea for picking up memcg is welcome=
d. It&#39;s<br>
&gt; &gt; now<br>
&gt; &gt; round-robin.<br>
&gt; &gt;<br>
&gt; &gt; Hmm. The concern I have is the debug-ability. Let&#39;s say I am =
running a<br>
&gt; system and found memcg-3 running crazy. Is there a way to find out whi=
ch<br>
&gt; memcg it is trying to reclaim pages from? Also, how to count cputime f=
or the<br>
&gt; shared memcg to the memcgs if we wanted to.<br>
&gt;<br>
<br>
</div></div>add a counter for kswapd-scan and kswapd-reclaim, kswapd-pickup=
 will show<br>
you information, if necessary it&#39;s good to show some latecy stat. I thi=
nk<br>
we can add enough information by adding stats (or debug by perf tools.)<br>
I&#39;ll consider this a a bit more.<br></blockquote><div><br></div><div>So=
mething like &quot;kswapd_pgscan&quot; and &quot;kswapd_steal&quot; per mem=
cg? If we are going to the thread-pool, we definitely need to add more stat=
s to give us enough visibility of per-memcg background reclaim activity. St=
ill, not sure about the cpu-cycles.</div>
<div><br></div><div>--Ying</div><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>

--0016360e3f5cb3ef5304a17bb873--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
