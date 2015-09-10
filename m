Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7778B6B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 04:48:28 -0400 (EDT)
Received: by qgez77 with SMTP id z77so29678484qge.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 01:48:28 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id w184si12436871qkw.97.2015.09.10.01.48.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 01:48:27 -0700 (PDT)
Received: by qgt47 with SMTP id 47so29499415qgt.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 01:48:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55F1259C.3020006@suse.cz>
References: <BLU436-SMTP171766343879051ED4CED0A2520@phx.gbl>
	<55F072EA.4000703@redhat.com>
	<CAMJBoFNsCuktUC0aZF6Xw05v4g_2eK1G183KkSkhQYkztEVHCA@mail.gmail.com>
	<55F1259C.3020006@suse.cz>
Date: Thu, 10 Sep 2015 10:48:26 +0200
Message-ID: <CAMJBoFP9Psyciga-oS_7phSstHCmc_M88vu03dJzmVXys=oLKQ@mail.gmail.com>
Subject: Re: [PATCH/RFC] mm: do not regard CMA pages as free on watermark check
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: multipart/alternative; boundary=001a1135c678a90672051f60a9c2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Laura Abbott <labbott@redhat.com>, Vitaly Wool <vwool@hotmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>

--001a1135c678a90672051f60a9c2
Content-Type: text/plain; charset=UTF-8

On Thu, Sep 10, 2015 at 8:39 AM, Vlastimil Babka <vbabka@suse.cz> wrote:

> [CC Joonsoo, Mel]
>
> On 09/09/2015 08:31 PM, Vitaly Wool wrote:
> > Hi Laura,
> >
> > On Wed, Sep 9, 2015 at 7:56 PM, Laura Abbott <labbott@redhat.com> wrote:
> >
> >> (cc-ing linux-mm)
> >> On 09/09/2015 07:44 AM, Vitaly Wool wrote:
> >>
> >>> __zone_watermark_ok() does not corrrectly take high-order
> >>> CMA pageblocks into account: high-order CMA blocks are not
> >>> removed from the watermark check. Moreover, CMA pageblocks
> >>> may suddenly vanish through CMA allocation, so let's not
> >>> regard these pages as free in __zone_watermark_ok().
> >>>
> >>> This patch also adds some primitive testing for the method
> >>> implemented which has proven that it works as it should.
> >>>
> >>>
> >> The choice to include CMA as part of watermarks was pretty deliberate.
> >> Do you have a description of the problem you are facing with
> >> the watermark code as is? Any performance numbers?
> >>
> >>
> > let's start with facing the fact that the calculation in
> > __zone_watermark_ok() is done incorrectly for the case when ALLOC_CMA is
> > not set. While going through pages by order it is implicitly considered
>
> You're not the first who tried to fix it, I think Joonsoo tried as well?
> I think the main objection was against further polluting fastpaths due to
> CMA.
>

I believe Joonsoo was calculating free_pages incorrectly, too, but in a
different way: he was subtracting CMA pages twice.


> Note that Mel has a patchset removing high-order watermark checks (in the
> last
> patch of https://lwn.net/Articles/655406/ ) so this will be moot
> afterwards.
>

I am not quite convinced that nested loops are a better solution than what
I suggest.


>
> > that CMA pages can be used and this impacts the result of the function.
> >
> > This can be solved in a slightly different way compared to what I
> proposed
> > but it needs per-order CMA pages accounting anyway. Then it would have
> > looked like:
> >
> >         for (o = 0; o < order; o++) {
> >                 /* At the next order, this order's pages become
> unavailable
> > */
> >                 free_pages -= z->free_area[o].nr_free << o;
> > #ifdef CONFIG_CMA
> >                 if (!(alloc_flags & ALLOC_CMA))
> >                         free_pages -= z->free_area[o].nr_free_cma << o;
> >                 /* Require fewer higher order pages to be free */
> >                 min >>= 1;
> > ...
> >
> > But what we have also seen is that CMA pages may suddenly disappear due
> to
> > CMA allocator work so the whole watermark checking was still unreliable,
> > causing compaction to not run when it ought to and thus leading to
>
> Well, watermark checking is inherently racy. CMA pages disappearing is no
> exception, non-CMA pages may disappear as well.
>

Right, that is why I decided to play on the safe side.

 ~vitaly

--001a1135c678a90672051f60a9c2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Thu, Sep 10, 2015 at 8:39 AM, Vlastimil Babka <span dir=3D"ltr">&lt;=
<a href=3D"mailto:vbabka@suse.cz" target=3D"_blank">vbabka@suse.cz</a>&gt;<=
/span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex">[CC Joonsoo, Mel]<br>
<span class=3D""><br>
On 09/09/2015 08:31 PM, Vitaly Wool wrote:<br>
&gt; Hi Laura,<br>
&gt;<br>
&gt; On Wed, Sep 9, 2015 at 7:56 PM, Laura Abbott &lt;<a href=3D"mailto:lab=
bott@redhat.com">labbott@redhat.com</a>&gt; wrote:<br>
&gt;<br>
&gt;&gt; (cc-ing linux-mm)<br>
&gt;&gt; On 09/09/2015 07:44 AM, Vitaly Wool wrote:<br>
&gt;&gt;<br>
&gt;&gt;&gt; __zone_watermark_ok() does not corrrectly take high-order<br>
&gt;&gt;&gt; CMA pageblocks into account: high-order CMA blocks are not<br>
&gt;&gt;&gt; removed from the watermark check. Moreover, CMA pageblocks<br>
&gt;&gt;&gt; may suddenly vanish through CMA allocation, so let&#39;s not<b=
r>
&gt;&gt;&gt; regard these pages as free in __zone_watermark_ok().<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; This patch also adds some primitive testing for the method<br>
&gt;&gt;&gt; implemented which has proven that it works as it should.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt;<br>
&gt;&gt; The choice to include CMA as part of watermarks was pretty deliber=
ate.<br>
&gt;&gt; Do you have a description of the problem you are facing with<br>
&gt;&gt; the watermark code as is? Any performance numbers?<br>
&gt;&gt;<br>
&gt;&gt;<br>
&gt; let&#39;s start with facing the fact that the calculation in<br>
&gt; __zone_watermark_ok() is done incorrectly for the case when ALLOC_CMA =
is<br>
&gt; not set. While going through pages by order it is implicitly considere=
d<br>
<br>
</span>You&#39;re not the first who tried to fix it, I think Joonsoo tried =
as well?<br>
I think the main objection was against further polluting fastpaths due to C=
MA.<br></blockquote><div><br></div><div>I believe Joonsoo was calculating f=
ree_pages incorrectly, too, but in a different way: he was subtracting CMA =
pages twice.</div><div><br></div><blockquote class=3D"gmail_quote" style=3D=
"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
Note that Mel has a patchset removing high-order watermark checks (in the l=
ast<br>
patch of <a href=3D"https://lwn.net/Articles/655406/" rel=3D"noreferrer" ta=
rget=3D"_blank">https://lwn.net/Articles/655406/</a> ) so this will be moot=
 afterwards.<br></blockquote><div><br></div><div>I am not quite convinced t=
hat nested loops are a better solution than what I suggest.</div><div>=C2=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex">
<span class=3D""><br>
&gt; that CMA pages can be used and this impacts the result of the function=
.<br>
&gt;<br>
&gt; This can be solved in a slightly different way compared to what I prop=
osed<br>
&gt; but it needs per-order CMA pages accounting anyway. Then it would have=
<br>
&gt; looked like:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for (o =3D 0; o &lt; order; o++) {<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* At the=
 next order, this order&#39;s pages become unavailable<br>
&gt; */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0free_page=
s -=3D z-&gt;free_area[o].nr_free &lt;&lt; o;<br>
&gt; #ifdef CONFIG_CMA<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!(all=
oc_flags &amp; ALLOC_CMA))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0free_pages -=3D z-&gt;free_area[o].nr_free_cma &lt;&lt;=
 o;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Requir=
e fewer higher order pages to be free */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min &gt;&=
gt;=3D 1;<br>
&gt; ...<br>
&gt;<br>
&gt; But what we have also seen is that CMA pages may suddenly disappear du=
e to<br>
&gt; CMA allocator work so the whole watermark checking was still unreliabl=
e,<br>
&gt; causing compaction to not run when it ought to and thus leading to<br>
<br>
</span>Well, watermark checking is inherently racy. CMA pages disappearing =
is no<br>
exception, non-CMA pages may disappear as well.<br></blockquote><div><br></=
div><div>Right, that is why I decided to play on the safe side.</div><div><=
br></div><div>=C2=A0~vitaly</div></div></div></div>

--001a1135c678a90672051f60a9c2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
