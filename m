Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4884A6B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 20:32:30 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o83LjjHk006989
	for <linux-mm@kvack.org>; Fri, 3 Sep 2010 14:45:45 -0700
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by hpaq3.eem.corp.google.com with ESMTP id o83LjC4u010878
	for <linux-mm@kvack.org>; Fri, 3 Sep 2010 14:45:43 -0700
Received: by qwk3 with SMTP id 3so2822662qwk.35
        for <linux-mm@kvack.org>; Fri, 03 Sep 2010 14:45:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100903140649.09dee316.akpm@linux-foundation.org>
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com>
	<20100903140649.09dee316.akpm@linux-foundation.org>
Date: Fri, 3 Sep 2010 14:45:42 -0700
Message-ID: <AANLkTinOd87vJdPxfFiFcgqKKbKjCbv7MZ7NhhCnwUjH@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016363b84da408b99048f61dae9
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

--0016363b84da408b99048f61dae9
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Sep 3, 2010 at 2:06 PM, Andrew Morton <akpm@linux-foundation.org>wrote:

> On Mon, 30 Aug 2010 00:43:48 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
> > Ying Han reported that backing aging of anon pages in no swap system
> > causes unnecessary TLB flush.
> >
> > When I sent a patch(69c8548175), I wanted this patch but Rik pointed out
> > and allowed aging of anon pages to give a chance to promote from inactive
> > to active LRU.
> >
> > It has a two problem.
> >
> > 1) non-swap system
> >
> > Never make sense to age anon pages.
> >
> > 2) swap configured but still doesn't swapon
> >
> > It doesn't make sense to age anon pages until swap-on time.
> > But it's arguable. If we have aged anon pages by swapon, VM have moved
> > anon pages from active to inactive. And in the time swapon by admin,
> > the VM can't reclaim hot pages so we can protect hot pages swapout.
> >
> > But let's think about it. When does swap-on happen? It depends on admin.
> > we can't expect it. Nonetheless, we have done aging of anon pages to
> > protect hot pages swapout. It means we lost run time overhead when
> > below high watermark but gain hot page swap-[in/out] overhead when VM
> > decide swapout. Is it true? Let's think more detail.
> > We don't promote anon pages in case of non-swap system. So even though
> > VM does aging of anon pages, the pages would be in inactive LRU for a
> long
> > time. It means many of pages in there would mark access bit again. So
> access
> > bit hot/code separation would be pointless.
> >
> > This patch prevents unnecessary anon pages demotion in not-swapon and
> > non-configured swap system. Of course, it could make side effect that
> > hot anon pages could swap out when admin does swap on.
> > But I think sooner or later it would be steady state.
> > So it's not a big problem.
> > We could lose someting but gain more thing(TLB flush and unnecessary
> > function call to demote anon pages).
> >
> > I used total_swap_pages because we want to age anon pages
> > even though swap full happens.
>
> We don't have any quantitative data on the effect of these excess tlb
> flushes, which makes it difficult to decide which kernel versions
> should receive this patch.
>
> Help?
>

Andrew:

We observed the degradation on 2.6.34 compared to 2.6.26 kernel. The
workload we are running is doing 4k-random-write which runs about 3-4
minutes. We captured the TLB shootsdowns before/after:

Before the change:
TLB: 29435 22208 37146 25332 47952 43698 43545 40297 49043 44843 46127 50959
47592 46233 43698 44690 TLB shootdowns [HSUM =  662798 ]

After the change:
TLB: 2340 3113 1547 1472 2944 4194 2181 1212 2607 4373 1690 1446 2310 3784
1744 1134 TLB shootdowns [HSUM =  38091 ]

Also worthy to mention, we are running in fake numa system where each fake
node is 128M size. That makes differences on the check inactive_anon_is_low()
since the active/inactive ratio falls to 1.

--Ying

--0016363b84da408b99048f61dae9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Fri, Sep 3, 2010 at 2:06 PM, Andrew M=
orton <span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org">ak=
pm@linux-foundation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex;">
<div><div></div><div class=3D"h5">On Mon, 30 Aug 2010 00:43:48 +0900<br>
Minchan Kim &lt;<a href=3D"mailto:minchan.kim@gmail.com">minchan.kim@gmail.=
com</a>&gt; wrote:<br>
<br>
&gt; Ying Han reported that backing aging of anon pages in no swap system<b=
r>
&gt; causes unnecessary TLB flush.<br>
&gt;<br>
&gt; When I sent a patch(69c8548175), I wanted this patch but Rik pointed o=
ut<br>
&gt; and allowed aging of anon pages to give a chance to promote from inact=
ive<br>
&gt; to active LRU.<br>
&gt;<br>
&gt; It has a two problem.<br>
&gt;<br>
&gt; 1) non-swap system<br>
&gt;<br>
&gt; Never make sense to age anon pages.<br>
&gt;<br>
&gt; 2) swap configured but still doesn&#39;t swapon<br>
&gt;<br>
&gt; It doesn&#39;t make sense to age anon pages until swap-on time.<br>
&gt; But it&#39;s arguable. If we have aged anon pages by swapon, VM have m=
oved<br>
&gt; anon pages from active to inactive. And in the time swapon by admin,<b=
r>
&gt; the VM can&#39;t reclaim hot pages so we can protect hot pages swapout=
.<br>
&gt;<br>
&gt; But let&#39;s think about it. When does swap-on happen? It depends on =
admin.<br>
&gt; we can&#39;t expect it. Nonetheless, we have done aging of anon pages =
to<br>
&gt; protect hot pages swapout. It means we lost run time overhead when<br>
&gt; below high watermark but gain hot page swap-[in/out] overhead when VM<=
br>
&gt; decide swapout. Is it true? Let&#39;s think more detail.<br>
&gt; We don&#39;t promote anon pages in case of non-swap system. So even th=
ough<br>
&gt; VM does aging of anon pages, the pages would be in inactive LRU for a =
long<br>
&gt; time. It means many of pages in there would mark access bit again. So =
access<br>
&gt; bit hot/code separation would be pointless.<br>
&gt;<br>
&gt; This patch prevents unnecessary anon pages demotion in not-swapon and<=
br>
&gt; non-configured swap system. Of course, it could make side effect that<=
br>
&gt; hot anon pages could swap out when admin does swap on.<br>
&gt; But I think sooner or later it would be steady state.<br>
&gt; So it&#39;s not a big problem.<br>
&gt; We could lose someting but gain more thing(TLB flush and unnecessary<b=
r>
&gt; function call to demote anon pages).<br>
&gt;<br>
&gt; I used total_swap_pages because we want to age anon pages<br>
&gt; even though swap full happens.<br>
<br>
</div></div>We don&#39;t have any quantitative data on the effect of these =
excess tlb<br>
flushes, which makes it difficult to decide which kernel versions<br>
should receive this patch.<br>
<br>
Help?<br></blockquote><div><br></div><div>Andrew:</div><div><br></div><div>=
We observed the=A0degradation=A0on 2.6.34 compared to 2.6.26 kernel. The wo=
rkload we are running is doing 4k-random-write=A0which runs=A0about=A03-4 m=
inutes. We captured the TLB shootsdowns before/after:</div>
<div><br></div><div><font class=3D"Apple-style-span" face=3D"arial, sans-se=
rif"><span class=3D"Apple-style-span" style=3D"border-collapse: collapse; -=
webkit-border-horizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px=
; font-size: 13px; ">Before the change:</span></font></div>
<div><font class=3D"Apple-style-span" face=3D"arial, sans-serif"><span clas=
s=3D"Apple-style-span" style=3D"border-collapse: collapse; -webkit-border-h=
orizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px; "></span><spa=
n class=3D"Apple-style-span" style=3D"border-collapse: collapse; -webkit-bo=
rder-horizontal-spacing: 2px; -webkit-border-vertical-spacing: 2px; "><span=
 class=3D"Apple-style-span" style=3D"font-size: 13px; ">TLB: 29435 22208 37=
146 25332 47952 43698 43545 40297 49043 44843 46127 50959 47592 46233 43698=
 44690 TLB shootdowns [HSUM =3D =A0662798 ]</span></span></font></div>
<div><span class=3D"Apple-style-span" style=3D"font-family: arial, sans-ser=
if; font-size: 13px; border-collapse: collapse; -webkit-border-horizontal-s=
pacing: 2px; -webkit-border-vertical-spacing: 2px; "><br></span></div><div>
<span class=3D"Apple-style-span" style=3D"font-family: arial, sans-serif; f=
ont-size: 13px; border-collapse: collapse; -webkit-border-horizontal-spacin=
g: 2px; -webkit-border-vertical-spacing: 2px; ">After the change:</span></d=
iv>
<div><span class=3D"Apple-style-span" style=3D"font-family: arial, sans-ser=
if; font-size: 13px; border-collapse: collapse; -webkit-border-horizontal-s=
pacing: 2px; -webkit-border-vertical-spacing: 2px; ">TLB: 2340 3113 1547 14=
72 2944 4194 2181 1212 2607 4373 1690 1446 2310 3784 1744 1134 TLB shootdow=
ns [HSUM =3D =A038091 ]</span>=A0</div>
<div><br></div><div>Also worthy to mention, we are running in fake numa sys=
tem where each fake node is 128M size. That makes differences on the check=
=A0<span class=3D"Apple-style-span" style=3D"font-family: arial, sans-serif=
; font-size: 13px; border-collapse: collapse; ">inactive_anon_is_low() sinc=
e the active/inactive ratio falls to 1.=A0</span></div>
<div><span class=3D"Apple-style-span" style=3D"font-family: arial, sans-ser=
if; font-size: 13px; border-collapse: collapse; "><br></span></div><div><sp=
an class=3D"Apple-style-span" style=3D"font-family: arial, sans-serif; font=
-size: 13px; border-collapse: collapse; ">--Ying</span></div>
</div><br>

--0016363b84da408b99048f61dae9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
