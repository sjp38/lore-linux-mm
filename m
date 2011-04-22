Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C000F8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 02:03:13 -0400 (EDT)
Received: by vws4 with SMTP id 4so455771vws.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 23:03:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422140023.949e5737.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
 <1303446260-21333-5-git-send-email-yinghan@google.com> <20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
 <BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com> <20110422140023.949e5737.kamezawa.hiroyu@jp.fujitsu.com>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Fri, 22 Apr 2011 14:02:51 +0800
Message-ID: <BANLkTinRyZyeJh-v2XeFRPCCd=x5OpWr+g@mail.gmail.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
Content-Type: multipart/alternative; boundary=bcaec517ab02d8df0c04a17b9cc1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org

--bcaec517ab02d8df0c04a17b9cc1
Content-Type: text/plain; charset=UTF-8

Hi Kame,

2011/4/22 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> On Thu, 21 Apr 2011 21:49:04 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > On Thu, 21 Apr 2011 21:24:15 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > This patch creates a thread pool for memcg-kswapd. All memcg which
> needs
> > > > background recalim are linked to a list and memcg-kswapd picks up a
> memcg
> > > > from the list and run reclaim.
> > > >
> > > > The concern of using per-memcg-kswapd thread is the system overhead
> > > including
> > > > memory and cputime.
> > > >
> > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > Signed-off-by: Ying Han <yinghan@google.com>
> > >
> > > Thank you for merging. This seems ok to me.
> > >
> > > Further development may make this better or change thread pools (to
> some
> > > other),
> > > but I think this is enough good.
> > >
> >
> > Thank you for reviewing and Acking. At the same time, I do have wondering
> on
> > the thread-pool modeling which I posted on the cover-letter :)
> >
> > The per-memcg-per-kswapd model
> > Pros:
> > 1. memory overhead per thread, and The memory consumption would be
> 8k*1000 =
> > 8M
> > with 1k cgroup.
> > 2. we see lots of threads at 'ps -elf'
> >
> > Cons:
> > 1. the implementation is simply and straigh-forward.
> > 2. we can easily isolate the background reclaim overhead between cgroups.
> > 3. better latency from memory pressure to actual start reclaiming
> >
> > The thread-pool model
> > Pros:
> > 1. there is no isolation between memcg background reclaim, since the
> memcg
> > threads
> > are shared.
> > 2. it is hard for visibility and debugability. I have been experienced a
> lot
> > when
> > some kswapds running creazy and we need a stright-forward way to identify
> > which
> > cgroup causing the reclaim.
> > 3. potential starvation for some memcgs, if one workitem stucks and the
> rest
> > of work
> > won't proceed.
> >
> > Cons:
> > 1. save some memory resource.
> >
> > In general, the per-memcg-per-kswapd implmentation looks sane to me at
> this
> > point, esepcially the sharing memcg thread model will make debugging
> issue
> > very hard later.
> >
> > Comments?
> >
> Pros <-> Cons ?
>
> My idea is adding trace point for memcg-kswapd and seeing what it's now
> doing.
> (We don't have too small trace point in memcg...)
>
> I don't think its sane to create kthread per memcg because we know there is
> a user
> who makes hundreds/thousands of memcg.
>

I think we need to think about the exact usage of  'thousands of cgroups' in
this case. Although not quite in detail, in Ying's previous email she did
say that they created thousands of cgroups on each box in Google's cluster
and most of them _slept_ in most of the time. So I guess actually what they
did is creating a larger number of cgroups, each of them has different
limits on various resources. Then on the time of job dispatching, they can
choose a suitable group from each box and submit the job into it - without
touching the other thousands of sleeping groups. That's to say, though
Google has a huge number of groups on each box, they have only few jobs on
it, so it's impossible to see too many busy groups at the same time.
If above is correct, then I think Ying can call kthread_stop at the moment
we find there's no tasks in the group anymore, to kill the memcg thread (as
this group is expected to sleep for a long time after all the job leave). In
this way we can keep the number of memcg threads small and don't lose the
debug-ability.
What do you think?

Regards,
Zhu Yanhai

>
> And, I think that creating threads, which does the same job, more than the
> number
> of cpus will cause much more difficult starvation, priority inversion
> issue.
> Keeping scheduling knob/chances of jobs in memcg is important. I don't want
> to
> give a hint to scheduler because of memcg internal issue.
>
> And, even if memcg-kswapd doesn't exist, memcg works (well?).
> memcg-kswapd just helps making things better but not do any critical jobs.
> So, it's okay to have this as best-effort service.
> Of course, better scheduling idea for picking up memcg is welcomed. It's
> now
> round-robin.
>
> Thanks,
> -Kame
>
>

--bcaec517ab02d8df0c04a17b9cc1
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Kame,<br><br><div class=3D"gmail_quote">2011/4/22 KAMEZAWA Hiroyuki <spa=
n dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezaw=
a.hiroyu@jp.fujitsu.com</a>&gt;</span><br><blockquote class=3D"gmail_quote"=
 style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

On Thu, 21 Apr 2011 21:49:04 -0700<br>
<div><div></div><div class=3D"h5">Ying Han &lt;<a href=3D"mailto:yinghan@go=
ogle.com">yinghan@google.com</a>&gt; wrote:<br>
<br>
&gt; On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Thu, 21 Apr 2011 21:24:15 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; This patch creates a thread pool for memcg-kswapd. All memcg=
 which needs<br>
&gt; &gt; &gt; background recalim are linked to a list and memcg-kswapd pic=
ks up a memcg<br>
&gt; &gt; &gt; from the list and run reclaim.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; The concern of using per-memcg-kswapd thread is the system o=
verhead<br>
&gt; &gt; including<br>
&gt; &gt; &gt; memory and cputime.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamez=
awa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; &gt; &gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google=
.com">yinghan@google.com</a>&gt;<br>
&gt; &gt;<br>
&gt; &gt; Thank you for merging. This seems ok to me.<br>
&gt; &gt;<br>
&gt; &gt; Further development may make this better or change thread pools (=
to some<br>
&gt; &gt; other),<br>
&gt; &gt; but I think this is enough good.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Thank you for reviewing and Acking. At the same time, I do have wonder=
ing on<br>
&gt; the thread-pool modeling which I posted on the cover-letter :)<br>
&gt;<br>
&gt; The per-memcg-per-kswapd model<br>
&gt; Pros:<br>
&gt; 1. memory overhead per thread, and The memory consumption would be 8k*=
1000 =3D<br>
&gt; 8M<br>
&gt; with 1k cgroup.<br>
&gt; 2. we see lots of threads at &#39;ps -elf&#39;<br>
&gt;<br>
&gt; Cons:<br>
&gt; 1. the implementation is simply and straigh-forward.<br>
&gt; 2. we can easily isolate the background reclaim overhead between cgrou=
ps.<br>
&gt; 3. better latency from memory pressure to actual start reclaiming<br>
&gt;<br>
&gt; The thread-pool model<br>
&gt; Pros:<br>
&gt; 1. there is no isolation between memcg background reclaim, since the m=
emcg<br>
&gt; threads<br>
&gt; are shared.<br>
&gt; 2. it is hard for visibility and debugability. I have been experienced=
 a lot<br>
&gt; when<br>
&gt; some kswapds running creazy and we need a stright-forward way to ident=
ify<br>
&gt; which<br>
&gt; cgroup causing the reclaim.<br>
&gt; 3. potential starvation for some memcgs, if one workitem stucks and th=
e rest<br>
&gt; of work<br>
&gt; won&#39;t proceed.<br>
&gt;<br>
&gt; Cons:<br>
&gt; 1. save some memory resource.<br>
&gt;<br>
&gt; In general, the per-memcg-per-kswapd implmentation looks sane to me at=
 this<br>
&gt; point, esepcially the sharing memcg thread model will make debugging i=
ssue<br>
&gt; very hard later.<br>
&gt;<br>
&gt; Comments?<br>
&gt;<br>
</div></div>Pros &lt;-&gt; Cons ?<br>
<br>
My idea is adding trace point for memcg-kswapd and seeing what it&#39;s now=
 doing.<br>
(We don&#39;t have too small trace point in memcg...)<br>
<br>
I don&#39;t think its sane to create kthread per memcg because we know ther=
e is a user<br>
who makes hundreds/thousands of memcg.<br></blockquote><div><br></div><div>=
I think we need to think about the exact usage of =C2=A0&#39;thousands of c=
groups&#39; in this case. Although not quite in detail, in Ying&#39;s previ=
ous email she did say that they created thousands of cgroups on each box in=
 Google&#39;s cluster and most of them _slept_ in most of the time. So I gu=
ess=C2=A0actually what they did is creating a larger number of cgroups, eac=
h of them has different limits on various resources. Then on the time of jo=
b dispatching, they can choose a suitable group from each box and submit th=
e job into it - without touching the other thousands of sleeping groups. Th=
at&#39;s to say, though Google has a huge number of groups on each box, the=
y have only few jobs on it, so it&#39;s impossible to see too many busy gro=
ups at the same time.</div>

<div>If above is correct, then I think Ying can call kthread_stop at the mo=
ment we find there&#39;s no tasks in the group anymore, to kill the memcg t=
hread (as this group is expected to sleep for a long time after all the job=
 leave). In this way we can keep the number of memcg threads small and don&=
#39;t lose the=C2=A0<span class=3D"Apple-style-span" style=3D"border-collap=
se: collapse; font-family: arial, sans-serif; font-size: 13px; ">debug-abil=
ity.</span></div>

<div><font class=3D"Apple-style-span" face=3D"arial, sans-serif"><span clas=
s=3D"Apple-style-span" style=3D"border-collapse: collapse;">What do you thi=
nk?</span></font></div><div><font class=3D"Apple-style-span" face=3D"arial,=
 sans-serif"><span class=3D"Apple-style-span" style=3D"border-collapse: col=
lapse;"><br>

</span></font></div><div><font class=3D"Apple-style-span" face=3D"arial, sa=
ns-serif"><span class=3D"Apple-style-span" style=3D"border-collapse: collap=
se;">Regards,</span></font></div><div><font class=3D"Apple-style-span" face=
=3D"arial, sans-serif"><span class=3D"Apple-style-span" style=3D"border-col=
lapse: collapse;">Zhu Yanhai</span></font></div>

<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex;">
<br>
And, I think that creating threads, which does the same job, more than the =
number<br>
of cpus will cause much more difficult starvation, priority inversion issue=
.<br>
Keeping scheduling knob/chances of jobs in memcg is important. I don&#39;t =
want to<br>
give a hint to scheduler because of memcg internal issue.<br>
<br>
And, even if memcg-kswapd doesn&#39;t exist, memcg works (well?).<br>
memcg-kswapd just helps making things better but not do any critical jobs.<=
br>
So, it&#39;s okay to have this as best-effort service.<br>
Of course, better scheduling idea for picking up memcg is welcomed. It&#39;=
s now<br>
round-robin.<br>
<br>
Thanks,<br>
-Kame<br>
<br>
</blockquote></div><br>

--bcaec517ab02d8df0c04a17b9cc1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
