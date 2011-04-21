Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 87E4D8D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:56:56 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p3LGupvr012666
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:56:51 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by wpaz5.hot.corp.google.com with ESMTP id p3LGtZQs020947
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:56:50 -0700
Received: by qyk2 with SMTP id 2so1341817qyk.16
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:56:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimueD3mNTKx6JsgRgAkB3WkGU7GrA@mail.gmail.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421124357.c94a03a5.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=a967ofJGV1_i2vMb9QDGuK7vtog@mail.gmail.com>
	<20110421174616.4fd79c5e.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTimueD3mNTKx6JsgRgAkB3WkGU7GrA@mail.gmail.com>
Date: Thu, 21 Apr 2011 09:56:48 -0700
Message-ID: <BANLkTi=_-rTst9OH0CSmk=n9LW2jGY5whQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] memcg kswapd thread pool (Was Re: [PATCH V6 00/10]
 memcg: per cgroup background reclaim
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016e64aefda8c629d04a170a0dd
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

--0016e64aefda8c629d04a170a0dd
Content-Type: text/plain; charset=ISO-8859-1

On Thu, Apr 21, 2011 at 2:05 AM, Minchan Kim <minchan.kim@gmail.com> wrote:

> On Thu, Apr 21, 2011 at 5:46 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 21 Apr 2011 17:10:23 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> Hi Kame,
> >>
> >> On Thu, Apr 21, 2011 at 12:43 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > Ying, please take this just a hint, you don't need to implement this
> as is.
> >> > ==
> >> > Now, memcg-kswapd is created per a cgroup. Considering there are users
> >> > who creates hundreds on cgroup on a system, it consumes too much
> >> > resources, memory, cputime.
> >> >
> >> > This patch creates a thread pool for memcg-kswapd. All memcg which
> >> > needs background recalim are linked to a list and memcg-kswapd
> >> > picks up a memcg from the list and run reclaim. This reclaimes
> >> > SWAP_CLUSTER_MAX of pages and putback the memcg to the lail of
> >> > list. memcg-kswapd will visit memcgs in round-robin manner and
> >> > reduce usages.
> >> >
> >>
> >> I didn't look at code yet but as I just look over the description, I
> >> have a concern.
> >> We have discussed LRU separation between global and memcg.
> >
> > Please discuss global LRU in other thread. memcg-kswapd is not related
> > to global LRU _at all_.
> >
> > And this patch set is independent from the things we discussed at LSF.
> >
> >
> >> The clear goal is that how to keep _fairness_.
> >>
> >> For example,
> >>
> >> memcg-1 : # pages of LRU : 64
> >> memcg-2 : # pages of LRU : 128
> >> memcg-3 : # pages of LRU : 256
> >>
> >> If we have to reclaim 96 pages, memcg-1 would be lost half of pages.
> >> It's much greater than others so memcg 1's page LRU rotation cycle
> >> would be very fast, then working set pages in memcg-1 don't have a
> >> chance to promote.
> >> Is it fair?
> >>
> >> I think we should consider memcg-LRU size as doing round-robin.
> >>
> >
> > This set doesn't implement a feature to handle your example case, at all.
>
> Sure. Sorry for the confusing.
> I don't mean global LRU but it a fairness although this series is
> based on per-memcg targeting.
>
> >
> > This patch set handles
> >
> > memcg-1: # pages of over watermark : 64
> > memcg-2: # pages of over watermark : 128
> > memcg-3: # pages of over watermark : 256
> >
> > And finally reclaim all pages over watermarks which user requested.
> > Considering fairness, what we consider is in what order we reclaim
> > memory memcg-1, memcg-2, memcg-3 and how to avoid unnecessary cpu
> > hogging at reclaiming memory all (64+128+256)
> >
> > This thread pool reclaim 32 pages per iteration with patch-1 and visit
> all
> > in round-robin.
> > With patch-2, reclaim 32*weight pages per iteration on each memcg.
> >
>
> I should have seen the patch [2/3] before posting the comment.
> Maybe you seem consider my concern.
> Okay. I will look the idea.
>

For any ideas on global kswapd and soft_limit reclaim based on round-robin (
discussed in LSF), please move the discussion to :

[RFC no patch yet] memcg: revisit soft_limit reclaim on contention:
http://permalink.gmane.org/gmane.linux.kernel.mm/60966"
I already started with the patch and hopefully to post some result soon.

--Ying


> >
> > Thanks,
> > -Kame
> >
> >
>
>
>
> --
> Kind regards,
> Minchan Kim
>

--0016e64aefda8c629d04a170a0dd
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Thu, Apr 21, 2011 at 2:05 AM, Minchan=
 Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan=
.kim@gmail.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
On Thu, Apr 21, 2011 at 5:46 PM, KAMEZAWA Hiroyuki<br>
<div><div></div><div class=3D"h5">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.=
fujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt; wrote:<br>
&gt; On Thu, 21 Apr 2011 17:10:23 +0900<br>
&gt; Minchan Kim &lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan.kim@g=
mail.com</a>&gt; wrote:<br>
&gt;<br>
&gt;&gt; Hi Kame,<br>
&gt;&gt;<br>
&gt;&gt; On Thu, Apr 21, 2011 at 12:43 PM, KAMEZAWA Hiroyuki<br>
&gt;&gt; &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hir=
oyu@jp.fujitsu.com</a>&gt; wrote:<br>
&gt;&gt; &gt; Ying, please take this just a hint, you don&#39;t need to imp=
lement this as is.<br>
&gt;&gt; &gt; =3D=3D<br>
&gt;&gt; &gt; Now, memcg-kswapd is created per a cgroup. Considering there =
are users<br>
&gt;&gt; &gt; who creates hundreds on cgroup on a system, it consumes too m=
uch<br>
&gt;&gt; &gt; resources, memory, cputime.<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; This patch creates a thread pool for memcg-kswapd. All memcg =
which<br>
&gt;&gt; &gt; needs background recalim are linked to a list and memcg-kswap=
d<br>
&gt;&gt; &gt; picks up a memcg from the list and run reclaim. This reclaime=
s<br>
&gt;&gt; &gt; SWAP_CLUSTER_MAX of pages and putback the memcg to the lail o=
f<br>
&gt;&gt; &gt; list. memcg-kswapd will visit memcgs in round-robin manner an=
d<br>
&gt;&gt; &gt; reduce usages.<br>
&gt;&gt; &gt;<br>
&gt;&gt;<br>
&gt;&gt; I didn&#39;t look at code yet but as I just look over the descript=
ion, I<br>
&gt;&gt; have a concern.<br>
&gt;&gt; We have discussed LRU separation between global and memcg.<br>
&gt;<br>
&gt; Please discuss global LRU in other thread. memcg-kswapd is not related=
<br>
&gt; to global LRU _at all_.<br>
&gt;<br>
&gt; And this patch set is independent from the things we discussed at LSF.=
<br>
&gt;<br>
&gt;<br>
&gt;&gt; The clear goal is that how to keep _fairness_.<br>
&gt;&gt;<br>
&gt;&gt; For example,<br>
&gt;&gt;<br>
&gt;&gt; memcg-1 : # pages of LRU : 64<br>
&gt;&gt; memcg-2 : # pages of LRU : 128<br>
&gt;&gt; memcg-3 : # pages of LRU : 256<br>
&gt;&gt;<br>
&gt;&gt; If we have to reclaim 96 pages, memcg-1 would be lost half of page=
s.<br>
&gt;&gt; It&#39;s much greater than others so memcg 1&#39;s page LRU rotati=
on cycle<br>
&gt;&gt; would be very fast, then working set pages in memcg-1 don&#39;t ha=
ve a<br>
&gt;&gt; chance to promote.<br>
&gt;&gt; Is it fair?<br>
&gt;&gt;<br>
&gt;&gt; I think we should consider memcg-LRU size as doing round-robin.<br=
>
&gt;&gt;<br>
&gt;<br>
&gt; This set doesn&#39;t implement a feature to handle your example case, =
at all.<br>
<br>
</div></div>Sure. Sorry for the confusing.<br>
I don&#39;t mean global LRU but it a fairness although this series is<br>
based on per-memcg targeting.<br>
<div class=3D"im"><br>
&gt;<br>
&gt; This patch set handles<br>
&gt;<br>
&gt; memcg-1: # pages of over watermark : 64<br>
&gt; memcg-2: # pages of over watermark : 128<br>
&gt; memcg-3: # pages of over watermark : 256<br>
&gt;<br>
&gt; And finally reclaim all pages over watermarks which user requested.<br=
>
&gt; Considering fairness, what we consider is in what order we reclaim<br>
&gt; memory memcg-1, memcg-2, memcg-3 and how to avoid unnecessary cpu<br>
&gt; hogging at reclaiming memory all (64+128+256)<br>
&gt;<br>
&gt; This thread pool reclaim 32 pages per iteration with patch-1 and visit=
 all<br>
&gt; in round-robin.<br>
&gt; With patch-2, reclaim 32*weight pages per iteration on each memcg.<br>
&gt;<br>
<br>
</div>I should have seen the patch [2/3] before posting the comment.<br>
Maybe you seem consider my concern.<br>
Okay. I will look the idea.<br></blockquote><div><br></div><div>For any ide=
as on global kswapd and soft_limit reclaim based on round-robin ( discussed=
 in LSF), please move the discussion to :</div><div><br></div><div><meta ht=
tp-equiv=3D"content-type" content=3D"text/html; charset=3Dutf-8"><span clas=
s=3D"Apple-style-span" style=3D"color: rgb(34, 34, 34); font-family: palati=
no, georgia, verdana, arial, sans-serif; line-height: 19px; "><h2 class=3D"=
title" style=3D"margin-top: 0px; margin-right: 0px; margin-bottom: 20px; ma=
rgin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; =
padding-left: 0px; font-family: palatino, georgia, &#39;times new roman&#39=
;, serif; font-size: large; color: rgb(0, 51, 102); ">
<span class=3D"Apple-style-span" style=3D"font-family: arial; font-size: sm=
all; color: rgb(0, 0, 0); font-weight: normal; line-height: normal; ">[RFC =
no patch yet] memcg: revisit soft_limit reclaim on contention:</span></h2><=
h2 class=3D"title" style=3D"margin-top: 0px; margin-right: 0px; margin-bott=
om: 20px; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-b=
ottom: 0px; padding-left: 0px; font-family: palatino, georgia, &#39;times n=
ew roman&#39;, serif; font-size: large; color: rgb(0, 51, 102); ">
<span class=3D"Apple-style-span" style=3D"font-family: arial; font-size: sm=
all; color: rgb(0, 0, 0); font-weight: normal; line-height: normal; "></spa=
n><span class=3D"Apple-style-span" style=3D"font-family: arial; font-size: =
small; color: rgb(0, 0, 0); font-weight: normal; line-height: normal; "><a =
href=3D"http://permalink.gmane.org/gmane.linux.kernel.mm/60966">http://perm=
alink.gmane.org/gmane.linux.kernel.mm/60966</a>&quot;</span></h2>
</span></div><div>I already started with the patch and hopefully to post so=
me result soon.</div><div><br></div><div>--Ying</div><div>=A0</div><blockqu=
ote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc s=
olid;padding-left:1ex;">

&gt;<br>
&gt; Thanks,<br>
&gt; -Kame<br>
&gt;<br>
&gt;<br>
<br>
<br>
<br>
--<br>
Kind regards,<br>
<font color=3D"#888888">Minchan Kim<br>
</font></blockquote></div><br>

--0016e64aefda8c629d04a170a0dd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
