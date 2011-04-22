Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE478D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 03:59:30 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p3M7xSae032156
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:59:28 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by wpaz17.hot.corp.google.com with ESMTP id p3M7xQnl027080
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:59:27 -0700
Received: by qwf7 with SMTP id 7so193954qwf.10
        for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:59:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110422164622.a8350bc5.kamezawa.hiroyu@jp.fujitsu.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
	<1303446260-21333-5-git-send-email-yinghan@google.com>
	<20110422133643.6a36d838.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinkJC2-HiGtxgTTo8RvRjZqYuq2pA@mail.gmail.com>
	<20110422140023.949e5737.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim91aHXjqfukn6rJxK0SDSSG2wrrg@mail.gmail.com>
	<20110422145943.a8f5a4ef.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikRvjNR94tUf2p9UPQFGLUYp41Twg@mail.gmail.com>
	<20110422164622.a8350bc5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 22 Apr 2011 00:59:26 -0700
Message-ID: <BANLkTikfsLB8kTFZe+qj_jK=psgtFMfBMA@mail.gmail.com>
Subject: Re: [PATCH V7 4/9] Add memcg kswapd thread pool
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefda993a0904a17d3cd2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016e64aefda993a0904a17d3cd2
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Apr 22, 2011 at 12:46 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 21 Apr 2011 23:10:58 -0700
> Ying Han <yinghan@google.com> wrote:
>
> > On Thu, Apr 21, 2011 at 10:59 PM, KAMEZAWA Hiroyuki <
> > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > > On Thu, 21 Apr 2011 22:53:19 -0700
> > > Ying Han <yinghan@google.com> wrote:
> > >
> > > > On Thu, Apr 21, 2011 at 10:00 PM, KAMEZAWA Hiroyuki <
> > > > kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > >
> > > > > On Thu, 21 Apr 2011 21:49:04 -0700
> > > > > Ying Han <yinghan@google.com> wrote:
> > > > >
> > > > > > On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki <
> > > > > > kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> > > add a counter for kswapd-scan and kswapd-reclaim, kswapd-pickup will
> show
> > > you information, if necessary it's good to show some latecy stat. I
> think
> > > we can add enough information by adding stats (or debug by perf tools.)
> > > I'll consider this a a bit more.
> > >
> >
> > Something like "kswapd_pgscan" and "kswapd_steal" per memcg? If we are
> going
> > to the thread-pool, we definitely need to add more stats to give us
> enough
> > visibility of per-memcg background reclaim activity. Still, not sure
> about
> > the cpu-cycles.
> >
>
> BTW, Kosaki requeted me not to have private thread pool implementation and
> use workqueue. I think he is right. So, I'd like to write a patch to
> enhance
> workqueue for using it for memcg (Of couse, I'll make a private workqueue.)
>
> Hmm. Can you give a bit more details of the logic behind? and what's about
the private workqueue? Also, how
we plan to solve the better debug-ability issue.


>
> ==
> 2. regarding to the alternative workqueue, which is more complicated and we
> need to be very careful of work items in the workqueue. We've experienced
> in
> one workitem stucks and the rest of the work item won't proceed. For
> example
> in dirty page writeback, one heavily writer cgroup could starve the other
> cgroups from flushing dirty pages to the same disk. In the kswapd case, I
> can
> imagine we might have similar senario. How to prioritize the workitems is
> another problem. The order of adding the workitems in the queue reflects
> the
> order of cgroups being reclaimed. We don't have that restriction currently
> but
> relying on the cpu scheduler to put kswapd on the right cpu-core to run. We
> "might" introduce priority later for reclaim and how are we gonna deal with
> that.
> ==
>
> From this, I feel I need to use unbound workqueue. BTW, with patches for
> current thread pool model, I think starvation problem by dirty pages
> cannot be seen.
> Anyway, I'll give a try.
>

Then do you suggest me to wait for your patch for my next post?

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

--0016e64aefda993a0904a17d3cd2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Apr 22, 2011 at 12:46 AM, KAMEZA=
WA Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fuji=
tsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc sol=
id;padding-left:1ex;">
On Thu, 21 Apr 2011 23:10:58 -0700<br>
<div class=3D"im">Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yingha=
n@google.com</a>&gt; wrote:<br>
<br>
&gt; On Thu, Apr 21, 2011 at 10:59 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.f=
ujitsu.com</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Thu, 21 Apr 2011 22:53:19 -0700<br>
&gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@google=
.com</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; &gt; On Thu, Apr 21, 2011 at 10:00 PM, KAMEZAWA Hiroyuki &lt;<br>
&gt; &gt; &gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.h=
iroyu@jp.fujitsu.com</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; On Thu, 21 Apr 2011 21:49:04 -0700<br>
&gt; &gt; &gt; &gt; Ying Han &lt;<a href=3D"mailto:yinghan@google.com">ying=
han@google.com</a>&gt; wrote:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; &gt; On Thu, Apr 21, 2011 at 9:36 PM, KAMEZAWA Hiroyuki=
 &lt;<br>
&gt; &gt; &gt; &gt; &gt; <a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">=
kamezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
<br>
</div><div class=3D"im">&gt; &gt; add a counter for kswapd-scan and kswapd-=
reclaim, kswapd-pickup will show<br>
&gt; &gt; you information, if necessary it&#39;s good to show some latecy s=
tat. I think<br>
&gt; &gt; we can add enough information by adding stats (or debug by perf t=
ools.)<br>
&gt; &gt; I&#39;ll consider this a a bit more.<br>
&gt; &gt;<br>
&gt;<br>
&gt; Something like &quot;kswapd_pgscan&quot; and &quot;kswapd_steal&quot; =
per memcg? If we are going<br>
&gt; to the thread-pool, we definitely need to add more stats to give us en=
ough<br>
&gt; visibility of per-memcg background reclaim activity. Still, not sure a=
bout<br>
&gt; the cpu-cycles.<br>
&gt;<br>
<br>
</div>BTW, Kosaki requeted me not to have private thread pool implementatio=
n and<br>
use workqueue. I think he is right. So, I&#39;d like to write a patch to en=
hance<br>
workqueue for using it for memcg (Of couse, I&#39;ll make a private workque=
ue.)<br>
<br></blockquote><div>Hmm. Can you give a bit more details of the logic beh=
ind? and what&#39;s about the private workqueue? Also, how</div><div>we pla=
n to solve the better=A0debug-ability issue.</div><div>=A0=A0</div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex;">

<br>
=3D=3D<br>
2. regarding to the alternative workqueue, which is more complicated and we=
<br>
need to be very careful of work items in the workqueue. We&#39;ve experienc=
ed in<br>
one workitem stucks and the rest of the work item won&#39;t proceed. For ex=
ample<br>
in dirty page writeback, one heavily writer cgroup could starve the other<b=
r>
cgroups from flushing dirty pages to the same disk. In the kswapd case, I c=
an<br>
imagine we might have similar senario. How to prioritize the workitems is<b=
r>
another problem. The order of adding the workitems in the queue reflects th=
e<br>
order of cgroups being reclaimed. We don&#39;t have that restriction curren=
tly but<br>
relying on the cpu scheduler to put kswapd on the right cpu-core to run. We=
<br>
&quot;might&quot; introduce priority later for reclaim and how are we gonna=
 deal with<br>
that.<br>
=3D=3D<br>
<br>
>From this, I feel I need to use unbound workqueue. BTW, with patches for<br=
>
current thread pool model, I think starvation problem by dirty pages<br>
cannot be seen.<br>
Anyway, I&#39;ll give a try.<br></blockquote><div><br></div><div>Then do yo=
u suggest me to wait for your patch for my next post?=A0</div><div><br></di=
v><div>--Ying=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0=
 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">

<br>
Thanks,<br>
-Kame<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>

--0016e64aefda993a0904a17d3cd2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
