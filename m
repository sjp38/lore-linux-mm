Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 97D79900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 12:05:45 -0400 (EDT)
Received: by vws14 with SMTP id 14so1182985vws.9
        for <linux-mm@kvack.org>; Tue, 13 Sep 2011 09:05:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1315902583.31737.848.camel@debian>
References: <1315188460.31737.5.camel@debian>
	<alpine.DEB.2.00.1109061914440.18646@router.home>
	<1315357399.31737.49.camel@debian>
	<alpine.DEB.2.00.1109062022100.20474@router.home>
	<4E671E5C.7010405@cs.helsinki.fi>
	<6E3BC7F7C9A4BF4286DD4C043110F30B5D00DA333C@shsmsx502.ccr.corp.intel.com>
	<alpine.DEB.2.00.1109071003240.9406@router.home>
	<1315442639.31737.224.camel@debian>
	<alpine.DEB.2.00.1109081336320.14787@router.home>
	<1315557944.31737.782.camel@debian>
	<1315902583.31737.848.camel@debian>
Date: Tue, 13 Sep 2011 10:04:13 -0500
Message-ID: <CALmdxiMuF6Q0W4ZdvhK5c4fQs8wUjcVGWYGWBjJi7WOfLYX=Gw@mail.gmail.com>
Subject: Re: [PATCH] slub Discard slab page only when node partials > minimum setting
From: Christoph Lameter <christoph@lameter.com>
Content-Type: multipart/alternative; boundary=90e6ba4fc724ec008004acd3f4f2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Huang, Ying" <ying.huang@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--90e6ba4fc724ec008004acd3f4f2
Content-Type: text/plain; charset=ISO-8859-1

Sorry to be that late with a response but my email setup is screwed up.

I was more thinking about the number of slab pages in the partial caches
rather than the size of the objects itself being an issue. I believe that
was /sys/kernel/slab/*/cpu_partial.

That setting could be tuned further before merging. An increase there causes
additional memory to be caught in the partial list. But it reduces the node
lock pressure further.

On Tue, Sep 13, 2011 at 3:29 AM, Alex,Shi <alex.shi@intel.com> wrote:

>
> > > Hmmm... The sizes of the per cpu partial objects could be varied a bit
> to
> > > see if more would make an impact.
> >
> >
> > I find almost in one time my kbuilding.
> > size 384, was alloced in fastpath about 2900k times
> > size 176, was alloced in fastpath about 1900k times
> > size 192, was alloced in fastpath about 500k times
> > anon_vma, was alloced in fastpath about 560k times
> > size 72, was alloced in fastpath about 600k times
> > size 512, 256, 128, was alloced in fastpath about more than 100k for
> > each of them.
> >
> > I may give you objects size involved in my netperf testing later.
> > and which test case do you prefer to? If I have, I may collection data
> > on them.
>
> I write a short script to collect different size object usage of
> alloc_fastpath.  The output is following, first column is the object
> name and second is the alloc_fastpath called times.
>
> :t-0000448 62693419
> :t-0000384 1037746
> :at-0000104 191787
> :t-0000176 2051053
> anon_vma 953578
> :t-0000048 2108191
> :t-0008192 17858636
> :t-0004096 2307039
> :t-0002048 21601441
> :t-0001024 98409238
> :t-0000512 14896189
> :t-0000256 96731409
> :t-0000128 221045
> :t-0000064 149505
> :t-0000032 638431
> :t-0000192 263488
> -----
>
> Above output shows size 448/8192/2048/512/256 are used much.
>
> So at least both kbuild(with 4 jobs) and netperf loopback (one server on
> CPU socket 1, and one client on CPU socket 2) testing have no clear
> performance change on our machine
> NHM-EP/NHM-EX/WSM-EP/tigerton/core2-EP.
>
>
>
>
>
>

--90e6ba4fc724ec008004acd3f4f2
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Sorry to be that late with a response but my email setup is screwed up.<br>=
<br>I was more thinking about the number of slab pages in the partial cache=
s rather than the size of the objects itself being an issue. I believe that=
 was /sys/kernel/slab/*/cpu_partial.<br>
<br>That setting could be tuned further before merging. An increase there c=
auses additional memory to be caught in the partial list. But it reduces th=
e node lock pressure further.<br><br><div class=3D"gmail_quote">On Tue, Sep=
 13, 2011 at 3:29 AM, Alex,Shi <span dir=3D"ltr">&lt;<a href=3D"mailto:alex=
.shi@intel.com">alex.shi@intel.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; borde=
r-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;"><br>
&gt; &gt; Hmmm... The sizes of the per cpu partial objects could be varied =
a bit to<br>
&gt; &gt; see if more would make an impact.<br>
&gt;<br>
&gt;<br>
&gt; I find almost in one time my kbuilding.<br>
&gt; size 384, was alloced in fastpath about 2900k times<br>
&gt; size 176, was alloced in fastpath about 1900k times<br>
&gt; size 192, was alloced in fastpath about 500k times<br>
&gt; anon_vma, was alloced in fastpath about 560k times<br>
&gt; size 72, was alloced in fastpath about 600k times<br>
&gt; size 512, 256, 128, was alloced in fastpath about more than 100k for<b=
r>
&gt; each of them.<br>
&gt;<br>
&gt; I may give you objects size involved in my netperf testing later.<br>
&gt; and which test case do you prefer to? If I have, I may collection data=
<br>
&gt; on them.<br>
<br>
I write a short script to collect different size object usage of<br>
alloc_fastpath. =A0The output is following, first column is the object<br>
name and second is the alloc_fastpath called times.<br>
<br>
:t-0000448 62693419<br>
:t-0000384 1037746<br>
:at-0000104 191787<br>
:t-0000176 2051053<br>
anon_vma 953578<br>
:t-0000048 2108191<br>
:t-0008192 17858636<br>
:t-0004096 2307039<br>
:t-0002048 21601441<br>
:t-0001024 98409238<br>
:t-0000512 14896189<br>
:t-0000256 96731409<br>
:t-0000128 221045<br>
:t-0000064 149505<br>
:t-0000032 638431<br>
:t-0000192 263488<br>
-----<br>
<br>
Above output shows size 448/8192/2048/512/256 are used much.<br>
<br>
So at least both kbuild(with 4 jobs) and netperf loopback (one server on<br=
>
CPU socket 1, and one client on CPU socket 2) testing have no clear<br>
performance change on our machine<br>
NHM-EP/NHM-EX/WSM-EP/tigerton/core2-EP.<br>
<br>
<br>
<br>
<br>
<br>
</blockquote></div><br>

--90e6ba4fc724ec008004acd3f4f2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
