Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 992566B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 12:26:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b80so895851wme.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:26:23 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id x8si25320002wjv.166.2016.10.18.09.26.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 09:26:22 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id c78so2949749wme.0
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:26:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONCSBC+gxDHrCrQkyx0+eUwejLJJBvzsnPBtiKr58LJtLA@mail.gmail.com>
References: <20161015135632.541010b55bec496e2cae056e@gmail.com>
 <20161015140520.ee52a80c92c50214a6614977@gmail.com> <CALZtONBWyX0OjJUcyyj23vqpJtbx-8fHakdDzrywvgZDZyVq6w@mail.gmail.com>
 <CAMJBoFPORDkVnpX5tf6zoYPxQWXA1Aayvff5s8iRWw0mLSg7OQ@mail.gmail.com>
 <CALZtONC4_aJwqhQ5W9AzHZS6_yUQk-w50E+gY=xHuwCYpi2Jfg@mail.gmail.com>
 <CAMJBoFPnpdG7ddR7LTKNYNZZzNo0t3tP+o0004gf7x26BOWNVQ@mail.gmail.com> <CALZtONCSBC+gxDHrCrQkyx0+eUwejLJJBvzsnPBtiKr58LJtLA@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 18 Oct 2016 18:26:20 +0200
Message-ID: <CAMJBoFNRFPYkcX05jZWjO21V9xzCipbBBtsq9CQbTU1EOK2hyg@mail.gmail.com>
Subject: [PATCH v5] z3fold: add shrinker
Content-Type: multipart/alternative; boundary=001a114b168a269d9f053f2627f8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>

--001a114b168a269d9f053f2627f8
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

18 =D0=BE=D0=BA=D1=82. 2016 =D0=B3. 18:29 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=
=BE=D0=B2=D0=B0=D1=82=D0=B5=D0=BB=D1=8C "Dan Streetman" <ddstreet@ieee.org
<javascript:_e(%7B%7D,'cvml','ddstreet@ieee.org');>> =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0=D0=BB:
>
> On Tue, Oct 18, 2016 at 10:51 AM, Vitaly Wool <vitalywool@gmail.com
<javascript:_e(%7B%7D,'cvml','vitalywool@gmail.com');>> wrote:
> > On Tue, Oct 18, 2016 at 4:27 PM, Dan Streetman <ddstreet@ieee.org
<javascript:_e(%7B%7D,'cvml','ddstreet@ieee.org');>> wrote:
> >> On Mon, Oct 17, 2016 at 10:45 PM, Vitaly Wool <vitalywool@gmail.com
<javascript:_e(%7B%7D,'cvml','vitalywool@gmail.com');>> wrote:
> >>> Hi Dan,
> >>>
> >>> On Tue, Oct 18, 2016 at 4:06 AM, Dan Streetman <ddstreet@ieee.org
<javascript:_e(%7B%7D,'cvml','ddstreet@ieee.org');>> wrote:
> >>>> On Sat, Oct 15, 2016 at 8:05 AM, Vitaly Wool <vitalywool@gmail.com
<javascript:_e(%7B%7D,'cvml','vitalywool@gmail.com');>> wrote:
> >>>>> This patch implements shrinker for z3fold. This shrinker
> >>>>> implementation does not free up any pages directly but it allows
> >>>>> for a denser placement of compressed objects which results in
> >>>>> less actual pages consumed and higher compression ratio therefore.
> >>>>>
> >>>>> This update removes z3fold page compaction from the freeing path
> >>>>> since we can rely on shrinker to do the job. Also, a new flag
> >>>>> UNDER_COMPACTION is introduced to protect against two threads
> >>>>> trying to compact the same page.
> >>>>
> >>>> i'm completely unconvinced that this should be a shrinker.  The
> >>>> alloc/free paths are much, much better suited to compacting a page
> >>>> than a shrinker that must scan through all the unbuddied pages.  Why
> >>>> not just improve compaction for the alloc/free paths?
> >>>
> >>> Basically the main reason is performance, I want to avoid compaction
on hot
> >>> paths as much as possible. This patchset brings both performance and
> >>> compression ratio gain, I'm not sure how to achieve that with
improving
> >>> compaction on alloc/free paths.
> >>
> >> It seems like a tradeoff of slight improvement in hot paths, for
> >> significant decrease in performance by adding a shrinker, which will
> >> do a lot of unnecessary scanning.  The alloc/free/unmap functions are
> >> working directly with the page at exactly the point where compaction
> >> is needed - when adding or removing a bud from the page.
> >
> > I can see that sometimes there are substantial amounts of pages that
> > are non-compactable synchronously due to the MIDDLE_CHUNK_MAPPED
> > bit set. Picking up those seems to be a good job for a shrinker, and
those
> > end up in the beginning of respective unbuddied lists, so the shrinker
is set
> > to find them. I can slightly optimize that by introducing a
> > COMPACT_DEFERRED flag or something like that to make shrinker find
> > those pages faster, would that make sense to you?
>
> Why not just compact the page in z3fold_unmap()?

That would give a huge performance penalty (checked).

> >> Sorry if I missed it in earlier emails, but have you done any
> >> performance measurements comparing with/without the shrinker?  The
> >> compression ratio gains may be possible with only the
> >> z3fold_compact_page() improvements, and performance may be stable (or
> >> better) with only a per-z3fold-page lock, instead of adding the
> >> shrinker...?
> >
> > I'm running some tests with per-page locks now, but according to the
> > previous measurements the shrinker version always wins on multi-core
> > platforms.
>
> But that comparison is without taking the spinlock in map/unmap right?

Right, but from the recent measurements it looks like per-page locks don't
slow things down that much.

~vitaly

--001a114b168a269d9f053f2627f8
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"></p>
<p dir=3D"ltr">18 =D0=BE=D0=BA=D1=82. 2016 =D0=B3. 18:29 =D0=BF=D0=BE=D0=BB=
=D1=8C=D0=B7=D0=BE=D0=B2=D0=B0=D1=82=D0=B5=D0=BB=D1=8C &quot;Dan Streetman&=
quot; &lt;<a href=3D"javascript:_e(%7B%7D,&#39;cvml&#39;,&#39;ddstreet@ieee=
.org&#39;);" target=3D"_blank">ddstreet@ieee.org</a>&gt; =D0=BD=D0=B0=D0=BF=
=D0=B8=D1=81=D0=B0=D0=BB:<br>
&gt;<br>
&gt; On Tue, Oct 18, 2016 at 10:51 AM, Vitaly Wool &lt;<a href=3D"javascrip=
t:_e(%7B%7D,&#39;cvml&#39;,&#39;vitalywool@gmail.com&#39;);" target=3D"_bla=
nk">vitalywool@gmail.com</a>&gt; wrote:<br>
&gt; &gt; On Tue, Oct 18, 2016 at 4:27 PM, Dan Streetman &lt;<a href=3D"jav=
ascript:_e(%7B%7D,&#39;cvml&#39;,&#39;ddstreet@ieee.org&#39;);" target=3D"_=
blank">ddstreet@ieee.org</a>&gt; wrote:<br>
&gt; &gt;&gt; On Mon, Oct 17, 2016 at 10:45 PM, Vitaly Wool &lt;<a href=3D"=
javascript:_e(%7B%7D,&#39;cvml&#39;,&#39;vitalywool@gmail.com&#39;);" targe=
t=3D"_blank">vitalywool@gmail.com</a>&gt; wrote:<br>
&gt; &gt;&gt;&gt; Hi Dan,<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; On Tue, Oct 18, 2016 at 4:06 AM, Dan Streetman &lt;<a hre=
f=3D"javascript:_e(%7B%7D,&#39;cvml&#39;,&#39;ddstreet@ieee.org&#39;);" tar=
get=3D"_blank">ddstreet@ieee.org</a>&gt; wrote:<br>
&gt; &gt;&gt;&gt;&gt; On Sat, Oct 15, 2016 at 8:05 AM, Vitaly Wool &lt;<a h=
ref=3D"javascript:_e(%7B%7D,&#39;cvml&#39;,&#39;vitalywool@gmail.com&#39;);=
" target=3D"_blank">vitalywool@gmail.com</a>&gt; wrote:<br>
&gt; &gt;&gt;&gt;&gt;&gt; This patch implements shrinker for z3fold. This s=
hrinker<br>
&gt; &gt;&gt;&gt;&gt;&gt; implementation does not free up any pages directl=
y but it allows<br>
&gt; &gt;&gt;&gt;&gt;&gt; for a denser placement of compressed objects whic=
h results in<br>
&gt; &gt;&gt;&gt;&gt;&gt; less actual pages consumed and higher compression=
 ratio therefore.<br>
&gt; &gt;&gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt;&gt; This update removes z3fold page compaction from t=
he freeing path<br>
&gt; &gt;&gt;&gt;&gt;&gt; since we can rely on shrinker to do the job. Also=
, a new flag<br>
&gt; &gt;&gt;&gt;&gt;&gt; UNDER_COMPACTION is introduced to protect against=
 two threads<br>
&gt; &gt;&gt;&gt;&gt;&gt; trying to compact the same page.<br>
&gt; &gt;&gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt;&gt; i&#39;m completely unconvinced that this should be a =
shrinker.=C2=A0 The<br>
&gt; &gt;&gt;&gt;&gt; alloc/free paths are much, much better suited to comp=
acting a page<br>
&gt; &gt;&gt;&gt;&gt; than a shrinker that must scan through all the unbudd=
ied pages.=C2=A0 Why<br>
&gt; &gt;&gt;&gt;&gt; not just improve compaction for the alloc/free paths?=
<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; Basically the main reason is performance, I want to avoid=
 compaction on hot<br>
&gt; &gt;&gt;&gt; paths as much as possible. This patchset brings both perf=
ormance and<br>
&gt; &gt;&gt;&gt; compression ratio gain, I&#39;m not sure how to achieve t=
hat with improving<br>
&gt; &gt;&gt;&gt; compaction on alloc/free paths.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; It seems like a tradeoff of slight improvement in hot paths, =
for<br>
&gt; &gt;&gt; significant decrease in performance by adding a shrinker, whi=
ch will<br>
&gt; &gt;&gt; do a lot of unnecessary scanning.=C2=A0 The alloc/free/unmap =
functions are<br>
&gt; &gt;&gt; working directly with the page at exactly the point where com=
paction<br>
&gt; &gt;&gt; is needed - when adding or removing a bud from the page.<br>
&gt; &gt;<br>
&gt; &gt; I can see that sometimes there are substantial amounts of pages t=
hat<br>
&gt; &gt; are non-compactable synchronously due to the MIDDLE_CHUNK_MAPPED<=
br>
&gt; &gt; bit set. Picking up those seems to be a good job for a shrinker, =
and those<br>
&gt; &gt; end up in the beginning of respective unbuddied lists, so the shr=
inker is set<br>
&gt; &gt; to find them. I can slightly optimize that by introducing a<br>
&gt; &gt; COMPACT_DEFERRED flag or something like that to make shrinker fin=
d<br>
&gt; &gt; those pages faster, would that make sense to you?<br>
&gt;<br>
&gt; Why not just compact the page in z3fold_unmap()?<br><br>That would giv=
e a huge performance penalty (checked).<br><br>
&gt; &gt;&gt; Sorry if I missed it in earlier emails, but have you done any=
<br>
&gt; &gt;&gt; performance measurements comparing with/without the shrinker?=
=C2=A0 The<br>
&gt; &gt;&gt; compression ratio gains may be possible with only the<br>
&gt; &gt;&gt; z3fold_compact_page() improvements, and performance may be st=
able (or<br>
&gt; &gt;&gt; better) with only a per-z3fold-page lock, instead of adding t=
he<br>
&gt; &gt;&gt; shrinker...?<br>
&gt; &gt;<br>
&gt; &gt; I&#39;m running some tests with per-page locks now, but according=
 to the<br>
&gt; &gt; previous measurements the shrinker version always wins on multi-c=
ore<br>
&gt; &gt; platforms.<br>
&gt;<br>
&gt; But that comparison is without taking the spinlock in map/unmap right?=
<br><br>Right, but from the recent measurements it looks like per-page lock=
s don&#39;t slow things down that much.</p><p dir=3D"ltr">~vitaly</p>

--001a114b168a269d9f053f2627f8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
