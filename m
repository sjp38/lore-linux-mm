Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB7E6B0005
	for <linux-mm@kvack.org>; Sun,  4 Mar 2018 15:18:50 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id t67so4454782lfe.21
        for <linux-mm@kvack.org>; Sun, 04 Mar 2018 12:18:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i18sor2423829ljd.31.2018.03.04.12.18.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Mar 2018 12:18:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180216162809.30b2278f0cacefa66c95c1aa@linux-foundation.org>
References: <47ab51e7-e9c1-d30e-ab17-f734dbc3abce@gmail.com> <20180216162809.30b2278f0cacefa66c95c1aa@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sun, 4 Mar 2018 12:18:47 -0800
Message-ID: <CAMJBoFNLF6__MnHEqOqPQpRucsp3hrSba6qSSjorEVttGx=LyA@mail.gmail.com>
Subject: Re: [PATCH] z3fold: limit use of stale list for allocation
Content-Type: multipart/alternative; boundary="001a11471dfebce4fb05669bea24"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleksiy.Avramchenko@sony.com

--001a11471dfebce4fb05669bea24
Content-Type: text/plain; charset="UTF-8"

[sorry for answering only now, this email slipped through somehow]

2018-02-16 16:28 GMT-08:00 Andrew Morton <akpm@linux-foundation.org>:

> On Sat, 10 Feb 2018 12:02:52 +0100 Vitaly Wool <vitalywool@gmail.com>
> wrote:
>
> > Currently if z3fold couldn't find an unbuddied page it would first
> > try to pull a page off the stale list. The problem with this
> > approach is that we can't 100% guarantee that the page is not
> > processed by the workqueue thread at the same time unless we run
> > cancel_work_sync() on it, which we can't do if we're in an atomic
> > context. So let's just limit stale list usage to non-atomic
> > contexts only.
>
> This smells like a bugfix.  What are the end-user visible effects of
> the bug?
>
>
I have only seen this happening in real life once, and then z3fold ended up
using a page which had been already freed and got blocked on a spinlock.

~Vitaly

--001a11471dfebce4fb05669bea24
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">[sorry for answering only now, this email slipped through =
somehow]<br><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">2018-=
02-16 16:28 GMT-08:00 Andrew Morton <span dir=3D"ltr">&lt;<a href=3D"mailto=
:akpm@linux-foundation.org" target=3D"_blank">akpm@linux-foundation.org</a>=
&gt;</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Sat, 10 =
Feb 2018 12:02:52 +0100 Vitaly Wool &lt;<a href=3D"mailto:vitalywool@gmail.=
com">vitalywool@gmail.com</a>&gt; wrote:<br>
<br>
&gt; Currently if z3fold couldn&#39;t find an unbuddied page it would first=
<br>
&gt; try to pull a page off the stale list. The problem with this<br>
&gt; approach is that we can&#39;t 100% guarantee that the page is not<br>
&gt; processed by the workqueue thread at the same time unless we run<br>
&gt; cancel_work_sync() on it, which we can&#39;t do if we&#39;re in an ato=
mic<br>
&gt; context. So let&#39;s just limit stale list usage to non-atomic<br>
&gt; contexts only.<br>
<br>
</span>This smells like a bugfix.=C2=A0 What are the end-user visible effec=
ts of<br>
the bug?<br>
<br>
</blockquote></div><br></div><div class=3D"gmail_extra">I have only seen th=
is happening in real life once, and then z3fold ended up using a page which=
 had been already freed and got blocked on a spinlock.</div><div class=3D"g=
mail_extra"><br></div><div class=3D"gmail_extra">~Vitaly</div></div>

--001a11471dfebce4fb05669bea24--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
