Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8A26B0286
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 14:04:38 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t83so450550029oie.0
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 11:04:38 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id n6si10478853otn.273.2016.09.25.11.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 11:04:37 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id t83so185472926oie.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 11:04:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALXu0UfuwGM+H0YnfSNW6O=hgcUrmws+ihHLVB=OJWOp8YCwgw@mail.gmail.com>
References: <1474570415-14938-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1474570415-14938-3-git-send-email-mawilcox@linuxonhyperv.com>
 <CALXu0Ucx-6PeEk9nTD-4nZvwyVr9LLXcFGFzhctX-ucKfCygGA@mail.gmail.com>
 <CA+55aFyRG=us-EKnomo=QPE0GR1Qdxyw1Ozmuzw0EJcSr7U3hQ@mail.gmail.com> <CALXu0UfuwGM+H0YnfSNW6O=hgcUrmws+ihHLVB=OJWOp8YCwgw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 25 Sep 2016 11:04:36 -0700
Message-ID: <CA+55aFzge97L-JLKZq0CTW1wtMOsnt8QzOw3b5qCMmzbKxZ5aw@mail.gmail.com>
Subject: Re: [PATCH 2/2] radix-tree: Fix optimisation problem
Content-Type: multipart/alternative; boundary=001a113d35aa364de1053d58d878
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

--001a113d35aa364de1053d58d878
Content-Type: text/plain; charset=UTF-8

On Sep 25, 2016 10:59 AM, "Cedric Blancher" <cedric.blancher@gmail.com>
wrote:
> >
> > The use of "int" is perfectly valid, since it's limited by
> > RADIX_TREE_MAP_SIZE, so it's going to be a small integer.
>
> A specific data type would be wise (aka radtr_mapsz_t) to prevent a
> disaster as SystemV had early during development.

Actually, you're right that the code is shit and shouldn't use an "int"
there.

The value range is indeed just up to RADIX_TREE_MAP_SIZE, but since the
code actually can get entries that are *not* sibling entries, it could
overflow

The more I look at that particular piece of code, the less I like it. It's
buggy shit. It needs to be rewritten entirely too actually check for
sibling entries, not that ad-hoc arithmetic crap.

     Linus

--001a113d35aa364de1053d58d878
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"></p>
<p dir=3D"ltr">On Sep 25, 2016 10:59 AM, &quot;Cedric Blancher&quot; &lt;<a=
 href=3D"mailto:cedric.blancher@gmail.com">cedric.blancher@gmail.com</a>&gt=
; wrote:<br>
&gt; &gt;<br>
&gt; &gt; The use of &quot;int&quot; is perfectly valid, since it&#39;s lim=
ited by<br>
&gt; &gt; RADIX_TREE_MAP_SIZE, so it&#39;s going to be a small integer.<br>
&gt;<br>
&gt; A specific data type would be wise (aka radtr_mapsz_t) to prevent a<br=
>
&gt; disaster as SystemV had early during development.</p>
<p dir=3D"ltr">Actually, you&#39;re right that the code is shit and shouldn=
&#39;t use an &quot;int&quot; there. </p>
<p dir=3D"ltr">The value range is indeed just up to RADIX_TREE_MAP_SIZE, bu=
t since the code actually can get entries that are *not* sibling entries, i=
t could overflow </p>
<p dir=3D"ltr">The more I look at that particular piece of code, the less I=
 like it. It&#39;s buggy shit. It needs to be rewritten entirely too actual=
ly check for sibling entries, not that ad-hoc arithmetic crap.</p>
<p dir=3D"ltr">=C2=A0=C2=A0=C2=A0=C2=A0 Linus</p>

--001a113d35aa364de1053d58d878--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
