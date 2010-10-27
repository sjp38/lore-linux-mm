Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0280A6B00A5
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 16:35:08 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o9RKZ4Zo008068
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:35:05 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by wpaz13.hot.corp.google.com with ESMTP id o9RKYfxg006786
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:35:03 -0700
Received: by qwc9 with SMTP id 9so255013qwc.39
        for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:35:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>
References: <1288200090-23554-1-git-send-email-yinghan@google.com>
	<4CC869F5.2070405@redhat.com>
	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>
	<AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>
	<alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>
Date: Wed, 27 Oct 2010 13:35:02 -0700
Message-ID: <AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=0016363b7e3ef35e1504939f28c4
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--0016363b7e3ef35e1504939f28c4
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Oct 27, 2010 at 12:13 PM, Hugh Dickins <hughd@google.com> wrote:

> On Wed, 27 Oct 2010, Nick Piggin wrote:
> > On Wed, Oct 27, 2010 at 12:22 PM, Nick Piggin <npiggin@gmail.com> wrote:
> > > On Wed, Oct 27, 2010 at 12:05 PM, Rik van Riel <riel@redhat.com>
> wrote:
> > >> On 10/27/2010 01:21 PM, Ying Han wrote:
> > >>>
> > >>> kswapd's use case of hardware PTE accessed bit is to approximate page
> LRU.
> > >>>  The
> > >>> ActiveLRU demotion to InactiveLRU are not base on accessed bit, while
> it
> > >>> is only
> > >>> used to promote when a page is on inactive LRU list.  All of the
> state
> > >>> transitions
> > >>> are triggered by memory pressure and thus has weak relationship with
> > >>> respect to
> > >>> time.  In addition, hardware already transparently flush tlb whenever
> CPU
> > >>> context
> > >>> switch processes and given limited hardware TLB resource, the time
> period
> > >>> in
> > >>> which a page is accessed but not yet propagated to struct page is
> very
> > >>> small
> > >>> in practice. With the nature of approximation, kernel really don't
> need to
> > >>> flush TLB
> > >>> for changing PTE's access bit.  This commit removes the flush
> operation
> > >>> from it.
>
> It should at least add a comment there in page_referenced_one(), that
> a TLB flush ought to be done, but is now judged not worth the effort.
>

I will make the change here.

>
> (I'd expect architectures to differ on whether it's worth the effort.)
>

Right :)  I would like hear from upstream if the problem is general enough
to solve, and thus
we can plan put further effort into it.

> >>>
> > >>> Signed-off-by: Ying Han<yinghan@google.com>
> > >>> Singed-off-by: Ken Chen<kenchen@google.com>
>
> Hey, Ken, switch off those curling tongs :)
>
> > However, it's a scary change -- higher chance of reclaiming a TLB covered
> page.
>
> Yes, I was often tempted to make such a change in the past;
> but ran away when it appeared to be in danger of losing the pte
> referenced bit of precisely the most intensively referenced pages.
>
> Ying's point (about what the pte referenced bit is being used for in our
> current implementation) is interesting, and might have tipped the balance;
> but that's not clear to me - and the flush is only done when mm is on CPU.
>

The initial patch is from Ken, and I am helping out here to get feedback
from
upstream and further improvement. :)

>
> > I had a vague memory of this problem biting someone when this flush
> wasn't
> > actually done properly... maybe powerpc.
> >
> > But anyway, same solution could be possible, by flushing every N pages
> scanned.
>
> Yes, batching seems safer.
>

I might be able to take a look at it.

--Ying

>
> Hugh

--0016363b7e3ef35e1504939f28c4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Wed, Oct 27, 2010 at 12:13 PM, Hugh D=
ickins <span dir=3D"ltr">&lt;<a href=3D"mailto:hughd@google.com">hughd@goog=
le.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On Wed, 27 Oct 2010, Nick Piggin wrote:<br>
&gt; On Wed, Oct 27, 2010 at 12:22 PM, Nick Piggin &lt;<a href=3D"mailto:np=
iggin@gmail.com">npiggin@gmail.com</a>&gt; wrote:<br>
&gt; &gt; On Wed, Oct 27, 2010 at 12:05 PM, Rik van Riel &lt;<a href=3D"mai=
lto:riel@redhat.com">riel@redhat.com</a>&gt; wrote:<br>
&gt; &gt;&gt; On 10/27/2010 01:21 PM, Ying Han wrote:<br>
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; kswapd&#39;s use case of hardware PTE accessed bit is to =
approximate page LRU.<br>
&gt; &gt;&gt;&gt; =A0The<br>
&gt; &gt;&gt;&gt; ActiveLRU demotion to InactiveLRU are not base on accesse=
d bit, while it<br>
&gt; &gt;&gt;&gt; is only<br>
&gt; &gt;&gt;&gt; used to promote when a page is on inactive LRU list. =A0A=
ll of the state<br>
&gt; &gt;&gt;&gt; transitions<br>
&gt; &gt;&gt;&gt; are triggered by memory pressure and thus has weak relati=
onship with<br>
&gt; &gt;&gt;&gt; respect to<br>
&gt; &gt;&gt;&gt; time. =A0In addition, hardware already transparently flus=
h tlb whenever CPU<br>
&gt; &gt;&gt;&gt; context<br>
&gt; &gt;&gt;&gt; switch processes and given limited hardware TLB resource,=
 the time period<br>
&gt; &gt;&gt;&gt; in<br>
&gt; &gt;&gt;&gt; which a page is accessed but not yet propagated to struct=
 page is very<br>
&gt; &gt;&gt;&gt; small<br>
&gt; &gt;&gt;&gt; in practice. With the nature of approximation, kernel rea=
lly don&#39;t need to<br>
&gt; &gt;&gt;&gt; flush TLB<br>
&gt; &gt;&gt;&gt; for changing PTE&#39;s access bit. =A0This commit removes=
 the flush operation<br>
&gt; &gt;&gt;&gt; from it.<br>
<br>
</div>It should at least add a comment there in page_referenced_one(), that=
<br>
a TLB flush ought to be done, but is now judged not worth the effort.<br></=
blockquote><div><br></div><div>I will make the change here. =A0</div><block=
quote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc=
 solid;padding-left:1ex;">

<br>
(I&#39;d expect architectures to differ on whether it&#39;s worth the effor=
t.)<br></blockquote><div><br></div><div>Right :) =A0I would like hear from =
upstream if the problem is general=A0enough to solve, and thus=A0</div><div=
>
we can plan put further effort into it.</div><div><br></div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex;"><div class=3D"im">
&gt; &gt;&gt;&gt;<br>
&gt; &gt;&gt;&gt; Signed-off-by: Ying Han&lt;<a href=3D"mailto:yinghan@goog=
le.com">yinghan@google.com</a>&gt;<br>
&gt; &gt;&gt;&gt; Singed-off-by: Ken Chen&lt;<a href=3D"mailto:kenchen@goog=
le.com">kenchen@google.com</a>&gt;<br>
<br>
</div>Hey, Ken, switch off those curling tongs :)<br>
<div class=3D"im"><br>
&gt; However, it&#39;s a scary change -- higher chance of reclaiming a TLB =
covered page.<br>
<br>
</div>Yes, I was often tempted to make such a change in the past;<br>
but ran away when it appeared to be in danger of losing the pte<br>
referenced bit of precisely the most intensively referenced pages.<br>
<br>
Ying&#39;s point (about what the pte referenced bit is being used for in ou=
r<br>
current implementation) is interesting, and might have tipped the balance;<=
br>
but that&#39;s not clear to me - and the flush is only done when mm is on C=
PU.<br></blockquote><div><br></div><div>The initial patch is from Ken, and =
I am=A0helping=A0out here to get feedback from</div><div>upstream and furth=
er improvement. :)</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;"><div class=3D"im">
&gt;<br>
&gt; I had a vague memory of this problem biting someone when this flush wa=
sn&#39;t<br>
&gt; actually done properly... maybe powerpc.<br>
&gt;<br>
&gt; But anyway, same solution could be possible, by flushing every N pages=
 scanned.<br>
<br>
</div>Yes, batching seems safer.<br></blockquote><div><br></div><div>I migh=
t be able to take a look at it.</div><div><br></div><div>--Ying=A0</div><bl=
ockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #=
ccc solid;padding-left:1ex;">

<font color=3D"#888888"><br>
Hugh</font></blockquote></div><br>

--0016363b7e3ef35e1504939f28c4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
