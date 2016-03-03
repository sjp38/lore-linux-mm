Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f52.google.com (mail-vk0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1076B007E
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 20:56:58 -0500 (EST)
Received: by mail-vk0-f52.google.com with SMTP id c3so7475115vkb.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 17:56:58 -0800 (PST)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id 65si23998749vkj.49.2016.03.02.17.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 17:56:57 -0800 (PST)
Received: by mail-vk0-x230.google.com with SMTP id e6so7533554vkh.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 17:56:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D6F6D7.50103@foxmail.com>
References: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
	<56D6F6D7.50103@foxmail.com>
Date: Thu, 3 Mar 2016 09:56:57 +0800
Message-ID: <CAKQB+fso7XvRXrPdpD9L18pq0sVy7BbM1d5cZQMJ77wT-v-1PQ@mail.gmail.com>
Subject: Re: kswapd consumes 100% CPU when highest zone is small
From: Jerry Lee <leisurelysw24@gmail.com>
Content-Type: multipart/alternative; boundary=001a114406ea3f4986052d1b50a2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chen feng <puck.chen@foxmail.com>
Cc: linux-mm@kvack.org, puck.chen@huawei.com

--001a114406ea3f4986052d1b50a2
Content-Type: text/plain; charset=UTF-8

Hi,

Thanks for sharing the same experience and workaround with me.
But it's kind of hard for me to set all the possible processes to no-kswapd
flag
in advance so that they would not trigger kswapd in the future.

Cheers,
- Jerry

On 2 March 2016 at 22:21, chen feng <puck.chen@foxmail.com> wrote:

>
>
> On 2016/3/2 14:20, Jerry Lee wrote:
> > Hi,
> >
> > I have a x86_64 system with 2G RAM using linux-3.12.x.  During copying
> > large
> > files (e.g. 100GB), kswapd easily consumes 100% CPU until the file is
> > deleted
> > or the page cache is dropped.  With setting the min_free_kbytes from
> 16384
> > to
> > 65536, the symptom is mitigated but I can't totally get rid of the
> problem.
> >
> > After some trial and error, I found that highest zone is always
> unbalanced
> > with
> > order-0 page request so that pgdat_blanaced() continuously return false
> and
> > kswapd can't sleep.
> >
> > Here's the watermarks (min_free_kbytes = 65536) in my system:
> > Node 0, zone      DMA
> >   pages free     2167
> >         min      138
> >         low      172
> >         high     207
> >         scanned  0
> >         spanned  4095
> >         present  3996
> >         managed  3974
> >
> > Node 0, zone    DMA32
> >   pages free     215375
> >         min      16226
> >         low      20282
> >         high     24339
> >         scanned  0
> >         spanned  1044480
> >         present  490971
> >         managed  464223
> >
> > Node 0, zone   Normal
> >   pages free     7
> >         min      18
> >         low      22
> >         high     27
> >         scanned  0
> >         spanned  1536
> >         present  1536
> >         managed  523
> >
> > Besides, when the kswapd crazily spins, the value of the following
> entries
> > in vmstat increases quickly even when I stop copying file:
> >
> > pgalloc_dma 17719
> > pgalloc_dma32 3262823
> > slabs_scanned 937728
> > kswapd_high_wmark_hit_quickly 54333233
> > pageoutrun 54333235
> >
> > Is there anything I could do to totally get rid of the problem?
> > \
> Yes, I have the same issue on arm64 platform.
>
> I think you can increase the normal ZONE size. And I think there will be a
> memory alloc process
> in your system which tigger the kswapd too frequently.
>
> You can set this process to no-kswapd flag will also solve this issue.
> > Thanks
> >
>

--001a114406ea3f4986052d1b50a2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div><div>Hi,<br><br></div>Thanks for sharing the sam=
e experience and workaround with me.<br></div>But it&#39;s kind of hard for=
 me to set all the possible processes to no-kswapd flag <br>in advance so t=
hat they would not trigger kswapd in the future.<br><br></div><div>Cheers,<=
br></div><div>- Jerry<br></div><div></div><div><div><div><div><div class=3D=
"gmail_extra"><br><div class=3D"gmail_quote">On 2 March 2016 at 22:21, chen=
 feng <span dir=3D"ltr">&lt;<a href=3D"mailto:puck.chen@foxmail.com" target=
=3D"_blank">puck.chen@foxmail.com</a>&gt;</span> wrote:<br><blockquote clas=
s=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pad=
ding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5"><br>
<br>
On 2016/3/2 14:20, Jerry Lee wrote:<br>
&gt; Hi,<br>
&gt;<br>
&gt; I have a x86_64 system with 2G RAM using linux-3.12.x.=C2=A0 During co=
pying<br>
&gt; large<br>
&gt; files (e.g. 100GB), kswapd easily consumes 100% CPU until the file is<=
br>
&gt; deleted<br>
&gt; or the page cache is dropped.=C2=A0 With setting the min_free_kbytes f=
rom 16384<br>
&gt; to<br>
&gt; 65536, the symptom is mitigated but I can&#39;t totally get rid of the=
 problem.<br>
&gt;<br>
&gt; After some trial and error, I found that highest zone is always unbala=
nced<br>
&gt; with<br>
&gt; order-0 page request so that pgdat_blanaced() continuously return fals=
e and<br>
&gt; kswapd can&#39;t sleep.<br>
&gt;<br>
&gt; Here&#39;s the watermarks (min_free_kbytes =3D 65536) in my system:<br=
>
&gt; Node 0, zone=C2=A0 =C2=A0 =C2=A0 DMA<br>
&gt;=C2=A0 =C2=A0pages free=C2=A0 =C2=A0 =C2=A02167<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min=C2=A0 =C2=A0 =C2=A0 138<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low=C2=A0 =C2=A0 =C2=A0 172<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0high=C2=A0 =C2=A0 =C2=A0207<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scanned=C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spanned=C2=A0 4095<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0present=C2=A0 3996<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0managed=C2=A0 3974<br>
&gt;<br>
&gt; Node 0, zone=C2=A0 =C2=A0 DMA32<br>
&gt;=C2=A0 =C2=A0pages free=C2=A0 =C2=A0 =C2=A0215375<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min=C2=A0 =C2=A0 =C2=A0 16226<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low=C2=A0 =C2=A0 =C2=A0 20282<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0high=C2=A0 =C2=A0 =C2=A024339<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scanned=C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spanned=C2=A0 1044480<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0present=C2=A0 490971<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0managed=C2=A0 464223<br>
&gt;<br>
&gt; Node 0, zone=C2=A0 =C2=A0Normal<br>
&gt;=C2=A0 =C2=A0pages free=C2=A0 =C2=A0 =C2=A07<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min=C2=A0 =C2=A0 =C2=A0 18<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low=C2=A0 =C2=A0 =C2=A0 22<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0high=C2=A0 =C2=A0 =C2=A027<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scanned=C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spanned=C2=A0 1536<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0present=C2=A0 1536<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0managed=C2=A0 523<br>
&gt;<br>
&gt; Besides, when the kswapd crazily spins, the value of the following ent=
ries<br>
&gt; in vmstat increases quickly even when I stop copying file:<br>
&gt;<br>
&gt; pgalloc_dma 17719<br>
&gt; pgalloc_dma32 3262823<br>
&gt; slabs_scanned 937728<br>
&gt; kswapd_high_wmark_hit_quickly 54333233<br>
&gt; pageoutrun 54333235<br>
&gt;<br>
&gt; Is there anything I could do to totally get rid of the problem?<br>
</div></div>&gt; \<br>
Yes, I have the same issue on arm64 platform.<br>
<br>
I think you can increase the normal ZONE size. And I think there will be a =
memory alloc process<br>
in your system which tigger the kswapd too frequently.<br>
<br>
You can set this process to no-kswapd flag will also solve this issue.<br>
&gt; Thanks<br>
&gt;<br>
</blockquote></div><br></div></div></div></div></div></div>

--001a114406ea3f4986052d1b50a2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
