Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 197836B0645
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 19:49:40 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id 91so22543588uau.10
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 16:49:40 -0700 (PDT)
Received: from mail-vk0-x243.google.com (mail-vk0-x243.google.com. [2607:f8b0:400c:c05::243])
        by mx.google.com with ESMTPS id l29si4822808uai.166.2017.08.02.16.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 16:49:39 -0700 (PDT)
Received: by mail-vk0-x243.google.com with SMTP id i133so2901315vka.5
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 16:49:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170802160716.f5d1072873799a3a420f6538@linux-foundation.org>
References: <20170802122505.e41d5c778a873375bcb0cc19@gmail.com> <20170802160716.f5d1072873799a3a420f6538@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Thu, 3 Aug 2017 01:49:38 +0200
Message-ID: <CAMJBoFNtACzBwBxtQf4OqiVs8drjq5_cte2sF3CVn=izwuqcag@mail.gmail.com>
Subject: Re: [PATCH] z3fold: use per-cpu unbuddied lists
Content-Type: multipart/alternative; boundary="001a114dbac8bfdef50555cdea5b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleksiy.Avramchenko@sony.com, Linux-MM <linux-mm@kvack.org>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org

--001a114dbac8bfdef50555cdea5b
Content-Type: text/plain; charset="UTF-8"

On Aug 3, 2017 01:07, "Andrew Morton" <akpm@linux-foundation.org> wrote:

On Wed, 2 Aug 2017 12:25:05 +0200 Vitaly Wool <vitalywool@gmail.com> wrote:

> z3fold is operating on unbuddied lists in a simple manner: in fact,
> it only takes the first entry off the list on a hot path. So if the
> z3fold pool is big enough and balanced well enough, considering
> only the lists local to the current CPU won't be an issue in any
> way, while random I/O performance will go up.

Has the performance benefit been measured?  It's a large patch.


Yes, mostly by running fio in randrw mode. We can see the performance more
than doubling on a 8-core ARM64 system.


> This patch also introduces two worker threads which: one for async
> in-page object layout optimization and one for releasing freed
> pages.

Why?  What are the runtime effects of this change?  Does this turn
currently-synchronous operations into now-async operations?  If so,
what are the implications of this if, say, the workqueue doesn't get
serviced for a while?


The biggest benefit is that it usually ends up with one call to
compact_page instead of two. Also, we use z3fold as a zram backend and zram
likes to free pages on a critical path so removing compaction from this
critical path is definitely a nice thing.

If compaction workqueue doesn't get serviced for a significant while, the
ratio will go down a bit, no bad things will happen. And z3fold_alloc tries
to take new pages from the stale list first, so even if release workqueue
is not called, the pages will be reused by z3fold_alloc.


etc.  Sorry, but I'm not seeing anywhere near enough information and
testing results to justify merging such a large and intrusive patch.

I understand. Would it help if I add fio results and some explanations from
this reply to the commit message?.

Thanks,
  Vitaly

--001a114dbac8bfdef50555cdea5b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div><br><div class=3D"gmail_extra"><br><div class=3D"gma=
il_quote">On Aug 3, 2017 01:07, &quot;Andrew Morton&quot; &lt;<a href=3D"ma=
ilto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt; wrote:<br=
 type=3D"attribution"><blockquote class=3D"quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex"><div class=3D"quoted-text">O=
n Wed, 2 Aug 2017 12:25:05 +0200 Vitaly Wool &lt;<a href=3D"mailto:vitalywo=
ol@gmail.com">vitalywool@gmail.com</a>&gt; wrote:<br>
<br>
&gt; z3fold is operating on unbuddied lists in a simple manner: in fact,<br=
>
&gt; it only takes the first entry off the list on a hot path. So if the<br=
>
&gt; z3fold pool is big enough and balanced well enough, considering<br>
&gt; only the lists local to the current CPU won&#39;t be an issue in any<b=
r>
&gt; way, while random I/O performance will go up.<br>
<br>
</div>Has the performance benefit been measured?=C2=A0 It&#39;s a large pat=
ch.<br></blockquote></div></div></div><div dir=3D"auto"><br></div><div dir=
=3D"auto">Yes, mostly by running fio in randrw mode. We can see the perform=
ance more than doubling on a 8-core ARM64 system.=C2=A0</div><div dir=3D"au=
to"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blockquote class=
=3D"quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-le=
ft:1ex">
<div class=3D"quoted-text"><br>
&gt; This patch also introduces two worker threads which: one for async<br>
&gt; in-page object layout optimization and one for releasing freed<br>
&gt; pages.<br>
<br>
</div>Why?=C2=A0 What are the runtime effects of this change?=C2=A0 Does th=
is turn<br>
currently-synchronous operations into now-async operations?=C2=A0 If so,<br=
>
what are the implications of this if, say, the workqueue doesn&#39;t get<br=
>
serviced for a while?<br></blockquote></div></div></div><div dir=3D"auto"><=
br></div><div dir=3D"auto">The biggest benefit is that it usually ends up w=
ith one call to compact_page instead of two. Also, we use z3fold as a zram =
backend and zram likes to free pages on a critical path so removing compact=
ion from this critical path is definitely a nice thing.=C2=A0</div><div dir=
=3D"auto"><br></div><div dir=3D"auto">If compaction workqueue doesn&#39;t g=
et serviced for a significant while, the ratio will go down a bit, no bad t=
hings will happen. And z3fold_alloc tries to take new pages from the stale =
list first, so even if release workqueue is not called, the pages will be r=
eused by z3fold_alloc.=C2=A0</div><div dir=3D"auto"><div class=3D"gmail_ext=
ra"><div class=3D"gmail_quote"><blockquote class=3D"quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
etc.=C2=A0 Sorry, but I&#39;m not seeing anywhere near enough information a=
nd<br>
testing results to justify merging such a large and intrusive patch.<br>
<br>
</blockquote></div>I understand. Would it help if I add fio results and som=
e explanations from this reply to the commit message?.=C2=A0</div><div clas=
s=3D"gmail_extra" dir=3D"auto"><br></div><div class=3D"gmail_extra" dir=3D"=
auto">Thanks,=C2=A0</div><div class=3D"gmail_extra" dir=3D"auto">=C2=A0 Vit=
aly</div></div></div>

--001a114dbac8bfdef50555cdea5b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
