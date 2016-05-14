Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8686B0005
	for <linux-mm@kvack.org>; Sat, 14 May 2016 06:34:49 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so20990310wme.1
        for <linux-mm@kvack.org>; Sat, 14 May 2016 03:34:49 -0700 (PDT)
Received: from mail-lf0-x234.google.com (mail-lf0-x234.google.com. [2a00:1450:4010:c07::234])
        by mx.google.com with ESMTPS id i204si14002244lfg.219.2016.05.14.03.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 May 2016 03:34:48 -0700 (PDT)
Received: by mail-lf0-x234.google.com with SMTP id y84so99334228lfc.0
        for <linux-mm@kvack.org>; Sat, 14 May 2016 03:34:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57369BC8.7000602@emindsoft.com.cn>
References: <1462167374-6321-1-git-send-email-chengang@emindsoft.com.cn>
	<CACT4Y+Z7Yfsq9wjJuoeegEvPBvJs9iX6wN2VO1scA7HA4TVLmQ@mail.gmail.com>
	<572735EB.8030300@emindsoft.com.cn>
	<CACT4Y+Yrq4mt6c8wQKU7WcTnN7k28T3hM1V6_DWF-NpmuMH7Gw@mail.gmail.com>
	<572747C2.5040009@emindsoft.com.cn>
	<CAG_fn=VGJAGb71HU4rC9MNboqPqPs4EPgcWBfaiBpcgNQ2qFqA@mail.gmail.com>
	<57275B71.8000907@emindsoft.com.cn>
	<CAG_fn=WBPcQ8HgG13RksM=v833Q4GmM4dXhFNa9ihhMnOWKLmA@mail.gmail.com>
	<57276E95.1030201@emindsoft.com.cn>
	<CAG_fn=W76ArZumUwM-fqsAZC2ksoi8azMPah+1aopigmrEWSNQ@mail.gmail.com>
	<57277EEA.6070909@emindsoft.com.cn>
	<57278294.3060006@emindsoft.com.cn>
	<57369BC8.7000602@emindsoft.com.cn>
Date: Sat, 14 May 2016 12:34:47 +0200
Message-ID: <CAG_fn=U9v3MrBNfyqR_aXvK_yL-7oCShtB=2HOB2WFPgz1BU6w@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan.h: Fix boolean checking issue for kasan_report_enabled()
From: Alexander Potapenko <glider@google.com>
Content-Type: multipart/alternative; boundary=001a113f21dac403bc0532caf0ba
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Chen Gang <gang.chen.5i5j@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

--001a113f21dac403bc0532caf0ba
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Don't bother, I'll refactor {en,dis}able_current().

sent from phone
On May 14, 2016 5:30 AM, "Chen Gang" <chengang@emindsoft.com.cn> wrote:

> Hello all:
>
> Shall I send patch v2 for it? (if really need, please let me know, and I
> shall try).
>
> Default, I shall continue to try to find and send another patches for mm
> in "include/linux/*.h".
>
> Thanks.
>
> On 5/3/16 00:38, Chen Gang wrote:
> > On 5/3/16 00:23, Chen Gang wrote:
> >> On 5/2/16 23:35, Alexander Potapenko wrote:
> >>> On Mon, May 2, 2016 at 5:13 PM, Chen Gang <chengang@emindsoft.com.cn>
> wrote:
> >>>>
> >>>> OK. But it does not look quite easy to use kasan_disable_current() f=
or
> >>>> INIT_KASAN which is used in INIT_TASK.
> >>>>
> >>>> If we have to set "kasan_depth =3D=3D 1", we have to use kasan_depth=
-- in
> >>>> kasan_enable_current().
> >>> Agreed, decrementing the counter in kasan_enable_current() is more
> natural.
> >>> I can fix this together with the comments.
> >>
> >> OK, thanks. And need I also send patch v2 for include/linux/kasan.h? (=
or
> >> you will fix them together).
> >>
> >>>>
> >>>> If we don't prevent the overflow, it will have negative effect with
> the
> >>>> caller. When we issue an warning, it means the caller's hope fail, b=
ut
> >>>> can not destroy the caller's original work. In our case:
> >>>>
> >>>>  - Assume "kasan_depth-- for kasan_enable_current()", the first enab=
le
> >>>>    will let kasan_depth be 0.
> >>> Sorry, I'm not sure I follow.
> >>> If we start with kasan_depth=3D0 (which is the default case for every
> >>> task except for the init, which also gets kasan_depth=3D0 short after
> >>> the kernel starts),
> >>> then the first call to kasan_disable_current() will make kasan_depth
> >>> nonzero and will disable KASAN.
> >>> The subsequent call to kasan_enable_current() will enable KASAN back.
> >>>
> >>> There indeed is a problem when someone calls kasan_enable_current()
> >>> without previously calling kasan_disable_current().
> >>> In this case we need to check that kasan_depth was zero and print a
> >>> warning if it was.
> >>> It actually does not matter whether we modify kasan_depth after that
> >>> warning or not, because we are already in inconsistent state.
> >>> But I think we should modify kasan_depth anyway to ease the debugging=
.
> >>>
> >
> > Oh, sorry, I forgot one of our original discussing content:
> >
> >  - If we use signed int kasan_depth, and kasan_depth <=3D 0 means enabl=
e, I
> >    guess, we can always modify kasan_depth.
> >
> >  - When overflow/underflow (singed int overflow), we can use BUG_ON(),
> >    since it should be rarely happen.
> >
> > Thanks.
> >
> >>
> >> For me, BUG_ON() will be better for debugging, but it is really not we=
ll
> >> for using.  For WARN_ON(), it already print warnings, so I am not quit=
e
> >> sure "always modifying kasan_depth will be ease the debugging".
> >>
> >> When we are in inconsistent state, for me, what we can do is:
> >>
> >>  - Still try to do correct things within our control: "when the caller
> >>    make a mistake, if kasan_enable_current() notices about it, it need
> >>    issue warning, and prevent itself to make mistake (causing disable)=
.
> >>
> >>  - "try to let negative effect smaller to user", e.g. let users "loose
> >>    hope" (call enable has no effect) instead of destroying users'
> >>    original work (call enable, but get disable).
> >>
> >> Thanks.
> >>
> >
>
> --
> Chen Gang (=E9=99=88=E5=88=9A)
>
> Managing Natural Environments is the Duty of Human Beings.
>

--001a113f21dac403bc0532caf0ba
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">Don&#39;t bother, I&#39;ll refactor {en,dis}able_current().<=
/p>
<p dir=3D"ltr">sent from phone</p>
<div class=3D"gmail_quote">On May 14, 2016 5:30 AM, &quot;Chen Gang&quot; &=
lt;<a href=3D"mailto:chengang@emindsoft.com.cn">chengang@emindsoft.com.cn</=
a>&gt; wrote:<br type=3D"attribution"><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">Hello =
all:<br>
<br>
Shall I send patch v2 for it? (if really need, please let me know, and I<br=
>
shall try).<br>
<br>
Default, I shall continue to try to find and send another patches for mm<br=
>
in &quot;include/linux/*.h&quot;.<br>
<br>
Thanks.<br>
<br>
On 5/3/16 00:38, Chen Gang wrote:<br>
&gt; On 5/3/16 00:23, Chen Gang wrote:<br>
&gt;&gt; On 5/2/16 23:35, Alexander Potapenko wrote:<br>
&gt;&gt;&gt; On Mon, May 2, 2016 at 5:13 PM, Chen Gang &lt;<a href=3D"mailt=
o:chengang@emindsoft.com.cn">chengang@emindsoft.com.cn</a>&gt; wrote:<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt; OK. But it does not look quite easy to use kasan_disable_c=
urrent() for<br>
&gt;&gt;&gt;&gt; INIT_KASAN which is used in INIT_TASK.<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt; If we have to set &quot;kasan_depth =3D=3D 1&quot;, we hav=
e to use kasan_depth-- in<br>
&gt;&gt;&gt;&gt; kasan_enable_current().<br>
&gt;&gt;&gt; Agreed, decrementing the counter in kasan_enable_current() is =
more natural.<br>
&gt;&gt;&gt; I can fix this together with the comments.<br>
&gt;&gt;<br>
&gt;&gt; OK, thanks. And need I also send patch v2 for include/linux/kasan.=
h? (or<br>
&gt;&gt; you will fix them together).<br>
&gt;&gt;<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt; If we don&#39;t prevent the overflow, it will have negativ=
e effect with the<br>
&gt;&gt;&gt;&gt; caller. When we issue an warning, it means the caller&#39;=
s hope fail, but<br>
&gt;&gt;&gt;&gt; can not destroy the caller&#39;s original work. In our cas=
e:<br>
&gt;&gt;&gt;&gt;<br>
&gt;&gt;&gt;&gt;=C2=A0 - Assume &quot;kasan_depth-- for kasan_enable_curren=
t()&quot;, the first enable<br>
&gt;&gt;&gt;&gt;=C2=A0 =C2=A0 will let kasan_depth be 0.<br>
&gt;&gt;&gt; Sorry, I&#39;m not sure I follow.<br>
&gt;&gt;&gt; If we start with kasan_depth=3D0 (which is the default case fo=
r every<br>
&gt;&gt;&gt; task except for the init, which also gets kasan_depth=3D0 shor=
t after<br>
&gt;&gt;&gt; the kernel starts),<br>
&gt;&gt;&gt; then the first call to kasan_disable_current() will make kasan=
_depth<br>
&gt;&gt;&gt; nonzero and will disable KASAN.<br>
&gt;&gt;&gt; The subsequent call to kasan_enable_current() will enable KASA=
N back.<br>
&gt;&gt;&gt;<br>
&gt;&gt;&gt; There indeed is a problem when someone calls kasan_enable_curr=
ent()<br>
&gt;&gt;&gt; without previously calling kasan_disable_current().<br>
&gt;&gt;&gt; In this case we need to check that kasan_depth was zero and pr=
int a<br>
&gt;&gt;&gt; warning if it was.<br>
&gt;&gt;&gt; It actually does not matter whether we modify kasan_depth afte=
r that<br>
&gt;&gt;&gt; warning or not, because we are already in inconsistent state.<=
br>
&gt;&gt;&gt; But I think we should modify kasan_depth anyway to ease the de=
bugging.<br>
&gt;&gt;&gt;<br>
&gt;<br>
&gt; Oh, sorry, I forgot one of our original discussing content:<br>
&gt;<br>
&gt;=C2=A0 - If we use signed int kasan_depth, and kasan_depth &lt;=3D 0 me=
ans enable, I<br>
&gt;=C2=A0 =C2=A0 guess, we can always modify kasan_depth.<br>
&gt;<br>
&gt;=C2=A0 - When overflow/underflow (singed int overflow), we can use BUG_=
ON(),<br>
&gt;=C2=A0 =C2=A0 since it should be rarely happen.<br>
&gt;<br>
&gt; Thanks.<br>
&gt;<br>
&gt;&gt;<br>
&gt;&gt; For me, BUG_ON() will be better for debugging, but it is really no=
t well<br>
&gt;&gt; for using.=C2=A0 For WARN_ON(), it already print warnings, so I am=
 not quite<br>
&gt;&gt; sure &quot;always modifying kasan_depth will be ease the debugging=
&quot;.<br>
&gt;&gt;<br>
&gt;&gt; When we are in inconsistent state, for me, what we can do is:<br>
&gt;&gt;<br>
&gt;&gt;=C2=A0 - Still try to do correct things within our control: &quot;w=
hen the caller<br>
&gt;&gt;=C2=A0 =C2=A0 make a mistake, if kasan_enable_current() notices abo=
ut it, it need<br>
&gt;&gt;=C2=A0 =C2=A0 issue warning, and prevent itself to make mistake (ca=
using disable).<br>
&gt;&gt;<br>
&gt;&gt;=C2=A0 - &quot;try to let negative effect smaller to user&quot;, e.=
g. let users &quot;loose<br>
&gt;&gt;=C2=A0 =C2=A0 hope&quot; (call enable has no effect) instead of des=
troying users&#39;<br>
&gt;&gt;=C2=A0 =C2=A0 original work (call enable, but get disable).<br>
&gt;&gt;<br>
&gt;&gt; Thanks.<br>
&gt;&gt;<br>
&gt;<br>
<br>
--<br>
Chen Gang (=E9=99=88=E5=88=9A)<br>
<br>
Managing Natural Environments is the Duty of Human Beings.<br>
</blockquote></div>

--001a113f21dac403bc0532caf0ba--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
