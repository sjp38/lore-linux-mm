Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 394E58D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:49:10 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p3M4n7Ax013466
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 21:49:07 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq7.eem.corp.google.com with ESMTP id p3M4n5Nv001812
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 21:49:06 -0700
Received: by qyk7 with SMTP id 7so188113qyk.19
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 21:49:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-5-git-send-email-yinghan@google.com>
	<20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 21 Apr 2011 21:49:04 -0700
Message-ID: <BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0050450161c3d05a4c04a17a93aa
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0050450161c3d05a4c04a17a93aa
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 21 Apr 2011 21:24:15 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > This patch creates a thread pool for memcg-kswapd. All memcg which needs
> > background recalim are linked to a list and memcg-kswapd picks up a memcg
> > from the list and run reclaim.
> >
> > The concern of using per-memcg-kswapd thread is the system overhead
> including
> > memory and cputime.
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Ying Han <yinghan@google.com>
>
> Thank you for merging. This seems ok to me.
>
> Further development may make this better or change thread pools (to some
> other),
> but I think this is enough good.
>

Thank you for reviewing and Acking. At the same time, I do have wondering on
the thread-pool modeling which I posted on the cover-letter :)

The per-memcg-per-kswapd model
Pros:
1. memory overhead per thread, and The memory consumption would be 8k*1000 =
8M
with 1k cgroup.
2. we see lots of threads at 'ps -elf'

Cons:
1. the implementation is simply and straigh-forward.
2. we can easily isolate the background reclaim overhead between cgroups.
3. better latency from memory pressure to actual start reclaiming

The thread-pool model
Pros:
1. there is no isolation between memcg background reclaim, since the memcg
threads
are shared.
2. it is hard for visibility and debugability. I have been experienced a lot
when
some kswapds running creazy and we need a stright-forward way to identify
which
cgroup causing the reclaim.
3. potential starvation for some memcgs, if one workitem stucks and the rest
of work
won't proceed.

Cons:
1. save some memory resource.

In general, the per-memcg-per-kswapd implmentation looks sane to me at this
point, esepcially the sharing memcg thread model will make debugging issue
very hard later.

Comments?

--Ying

--0050450161c3d05a4c04a17a93aa
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
<div class=3D"im">On Thu, 21 Apr 2011 21:24:15 -0700<br>
Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google.com</a>&g=
t; wrote:<br>
<br>
&gt; This patch creates a thread pool for memcg-kswapd. All memcg which nee=
ds<br>
&gt; background recalim are linked to a list and memcg-kswapd picks up a me=
mcg<br>
&gt; from the list and run reclaim.<br>
&gt;<br>
&gt; The concern of using per-memcg-kswapd thread is the system overhead in=
cluding<br>
&gt; memory and cputime.<br>
&gt;<br>
&gt; Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu=
@jp.fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
&gt; Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt;<br>
<br>
</div>Thank you for merging. This seems ok to me.<br>
<br>
Further development may make this better or change thread pools (to some ot=
her),<br>
but I think this is enough good.<br></blockquote><div><br></div><div>Thank =
you for reviewing and Acking. At the same time, I do have wondering on the =
thread-pool modeling which I posted on the cover-letter :)</div><div><br>
</div><meta http-equiv=3D"content-type" content=3D"text/html; charset=3Dutf=
-8"><span class=3D"Apple-style-span" style=3D"border-collapse: collapse; fo=
nt-family: arial, sans-serif; font-size: 13px; ">The per-memcg-per-kswapd m=
odel<br>
Pros:<br>1. memory overhead per thread, and The memory consumption would be=
 8k*1000 =3D 8M<br>with 1k cgroup.<br>2. we see lots of threads at &#39;ps =
-elf&#39;<br><br>Cons:<br>1. the implementation is simply and straigh-forwa=
rd.<br>
2. we can easily isolate the background reclaim overhead between cgroups.<b=
r>3. better latency from memory pressure to actual start reclaiming<br><br>=
The thread-pool model<br>Pros:<br>1. there is no isolation between memcg ba=
ckground reclaim, since the memcg threads<br>
are shared.<br>2. it is hard for visibility and debugability. I have been e=
xperienced a lot when<br>some kswapds running creazy and we need a stright-=
forward way to identify which<br>cgroup causing the reclaim.<br>3. potentia=
l starvation for some memcgs, if one workitem stucks and the rest of work<b=
r>
won&#39;t proceed.<br><br>Cons:<br>1. save some memory resource.<br><br>In =
general, the per-memcg-per-kswapd implmentation looks sane to me at this po=
int,=A0</span><span class=3D"Apple-style-span" style=3D"border-collapse: co=
llapse; font-family: arial, sans-serif; font-size: 13px; ">esepcially the s=
haring memcg thread model will make debugging issue very hard later.</span>=
=A0</div>
<div class=3D"gmail_quote"><br></div><div class=3D"gmail_quote">Comments?</=
div><div class=3D"gmail_quote"><br></div><div class=3D"gmail_quote">--Ying<=
/div><br>

--0050450161c3d05a4c04a17a93aa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
