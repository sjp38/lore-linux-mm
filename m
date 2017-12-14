Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D477D6B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 20:35:51 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a22so8212745wme.0
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 17:35:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k76sor964720wmh.39.2017.12.13.17.35.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 17:35:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171213163210.6a16ccf8753b74a6982ef5b6@linux-foundation.org>
References: <20171213092550.2774-1-mhocko@kernel.org> <20171213163210.6a16ccf8753b74a6982ef5b6@linux-foundation.org>
From: David Goldblatt <davidtgoldblatt@gmail.com>
Date: Wed, 13 Dec 2017 17:35:48 -0800
Message-ID: <CAHD6eXccNCJDMPEhrYkYUO-+GH3GLseoYSVE375OcKMNYJKm-A@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm: introduce MAP_FIXED_SAFE
Content-Type: multipart/alternative; boundary="001a11424216604b00056042e777"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@suse.com>, trasz@freebsd.org, Jason Evans <jasone@canonware.com>

--001a11424216604b00056042e777
Content-Type: text/plain; charset="UTF-8"

(+cc the jemalloc jasone; -cc,+bcc the Google jasone).

The only time we would want MAP_FIXED (or rather, a non-broken variant) is
in the middle of trying to expand an allocation in place; "atomic address
range probing in the multithreaded programs" describes our use case pretty
well. That's in a pathway that usually fails; it's pretty far down on our
kernel mmap enhancements wish-list.

On Wed, Dec 13, 2017 at 4:32 PM, Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Wed, 13 Dec 2017 10:25:48 +0100 Michal Hocko <mhocko@kernel.org> wrote:
>
> >
> > Hi,
> > I am resending with some minor updates based on Michael's review and
> > ask for inclusion. There haven't been any fundamental objections for
> > the RFC [1] nor the previous version [2].  The biggest discussion
> > revolved around the naming. There were many suggestions flowing
> > around MAP_REQUIRED, MAP_EXACT, MAP_FIXED_NOCLOBBER, MAP_AT_ADDR,
> > MAP_FIXED_NOREPLACE etc...
>
> I like MAP_FIXED_CAREFUL :)
>
> > I am afraid we can bikeshed this to death and there will still be
> > somebody finding yet another better name. Therefore I've decided to
> > stick with my original MAP_FIXED_SAFE. Why? Well, because it keeps the
> > MAP_FIXED prefix which should be recognized by developers and _SAFE
> > suffix should also be clear that all dangerous side effects of the old
> > MAP_FIXED are gone.
> >
> > If somebody _really_ hates this then feel free to nack and resubmit
> > with a different name you can find a consensus for. I am sorry to be
> > stubborn here but I would rather have this merged than go over few more
> > iterations changing the name just because it seems like a good idea
> > now. My experience tells me that chances are that the name will turn out
> > to be "suboptimal" anyway over time.
> >
> > Some more background:
> > This has started as a follow up discussion [3][4] resulting in the
> > runtime failure caused by hardening patch [5] which removes MAP_FIXED
> > from the elf loader because MAP_FIXED is inherently dangerous as it
> > might silently clobber an existing underlying mapping (e.g. stack). The
> > reason for the failure is that some architectures enforce an alignment
> > for the given address hint without MAP_FIXED used (e.g. for shared or
> > file backed mappings).
> >
> > One way around this would be excluding those archs which do alignment
> > tricks from the hardening [6]. The patch is really trivial but it has
> > been objected, rightfully so, that this screams for a more generic
> > solution. We basically want a non-destructive MAP_FIXED.
> >
> > The first patch introduced MAP_FIXED_SAFE which enforces the given
> > address but unlike MAP_FIXED it fails with EEXIST if the given range
> > conflicts with an existing one. The flag is introduced as a completely
> > new one rather than a MAP_FIXED extension because of the backward
> > compatibility. We really want a never-clobber semantic even on older
> > kernels which do not recognize the flag. Unfortunately mmap sucks wrt.
> > flags evaluation because we do not EINVAL on unknown flags. On those
> > kernels we would simply use the traditional hint based semantic so the
> > caller can still get a different address (which sucks) but at least not
> > silently corrupt an existing mapping. I do not see a good way around
> > that. Except we won't export expose the new semantic to the userspace at
> > all.
> >
> > It seems there are users who would like to have something like that.
> > Jemalloc has been mentioned by Michael Ellerman [7]
>
> http://lkml.kernel.org/r/87efp1w7vy.fsf@concordia.ellerman.id.au.
>
> It would be useful to get feedback from jemalloc developers (please).
> I'll add some cc's.
>
>
> > Florian Weimer has mentioned the following:
> > : glibc ld.so currently maps DSOs without hints.  This means that the
> kernel
> > : will map right next to each other, and the offsets between them a
> completely
> > : predictable.  We would like to change that and supply a random address
> in a
> > : window of the address space.  If there is a conflict, we do not want
> the
> > : kernel to pick a non-random address. Instead, we would try again with a
> > : random address.
> >
> > John Hubbard has mentioned CUDA example
> > : a) Searches /proc/<pid>/maps for a "suitable" region of available
> > : VA space.  "Suitable" generally means it has to have a base address
> > : within a certain limited range (a particular device model might
> > : have odd limitations, for example), it has to be large enough, and
> > : alignment has to be large enough (again, various devices may have
> > : constraints that lead us to do this).
> > :
> > : This is of course subject to races with other threads in the process.
> > :
> > : Let's say it finds a region starting at va.
> > :
> > : b) Next it does:
> > :     p = mmap(va, ...)
> > :
> > : *without* setting MAP_FIXED, of course (so va is just a hint), to
> > : attempt to safely reserve that region. If p != va, then in most cases,
> > : this is a failure (almost certainly due to another thread getting a
> > : mapping from that region before we did), and so this layer now has to
> > : call munmap(), before returning a "failure: retry" to upper layers.
> > :
> > :     IMPROVEMENT: --> if instead, we could call this:
> > :
> > :             p = mmap(va, ... MAP_FIXED_SAFE ...)
> > :
> > :         , then we could skip the munmap() call upon failure. This
> > :         is a small thing, but it is useful here. (Thanks to Piotr
> > :         Jaroszynski and Mark Hairgrove for helping me get that detail
> > :         exactly right, btw.)
> > :
> > : c) After that, CUDA suballocates from p, via:
> > :
> > :      q = mmap(sub_region_start, ... MAP_FIXED ...)
> > :
> > : Interestingly enough, "freeing" is also done via MAP_FIXED, and
> > : setting PROT_NONE to the subregion. Anyway, I just included (c) for
> > : general interest.
> >
> > Atomic address range probing in the multithreaded programs in general
> > sounds like an interesting thing to me.
> >
> > The second patch simply replaces MAP_FIXED use in elf loader by
> > MAP_FIXED_SAFE. I believe other places which rely on MAP_FIXED should
> > follow. Actually real MAP_FIXED usages should be docummented properly
> > and they should be more of an exception.
>
>

--001a11424216604b00056042e777
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">(+cc the jemalloc jasone; -cc,+bcc the Google jasone).<div=
><br></div><div>The only time we would want MAP_FIXED (or rather, a non-bro=
ken variant) is in the middle of trying to expand an allocation in place; &=
quot;<span style=3D"font-size:12.8px">atomic address range probing in the m=
ultithreaded programs&quot; describes our use case pretty well. That&#39;s =
in a pathway that usually fails; it&#39;s pretty far down on our kernel mma=
p enhancements wish-list.</span></div></div><div class=3D"gmail_extra"><br>=
<div class=3D"gmail_quote">On Wed, Dec 13, 2017 at 4:32 PM, Andrew Morton <=
span dir=3D"ltr">&lt;<a href=3D"mailto:akpm@linux-foundation.org" target=3D=
"_blank">akpm@linux-foundation.org</a>&gt;</span> wrote:<br><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex">On Wed, 13 Dec 2017 10:25:48 +0100 Michal Hocko &lt;<a href=
=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wrote:<br>
<br>
&gt;<br>
&gt; Hi,<br>
&gt; I am resending with some minor updates based on Michael&#39;s review a=
nd<br>
&gt; ask for inclusion. There haven&#39;t been any fundamental objections f=
or<br>
&gt; the RFC [1] nor the previous version [2].=C2=A0 The biggest discussion=
<br>
&gt; revolved around the naming. There were many suggestions flowing<br>
&gt; around MAP_REQUIRED, MAP_EXACT, MAP_FIXED_NOCLOBBER, MAP_AT_ADDR,<br>
&gt; MAP_FIXED_NOREPLACE etc...<br>
<br>
I like MAP_FIXED_CAREFUL :)<br>
<br>
&gt; I am afraid we can bikeshed this to death and there will still be<br>
&gt; somebody finding yet another better name. Therefore I&#39;ve decided t=
o<br>
&gt; stick with my original MAP_FIXED_SAFE. Why? Well, because it keeps the=
<br>
&gt; MAP_FIXED prefix which should be recognized by developers and _SAFE<br=
>
&gt; suffix should also be clear that all dangerous side effects of the old=
<br>
&gt; MAP_FIXED are gone.<br>
&gt;<br>
&gt; If somebody _really_ hates this then feel free to nack and resubmit<br=
>
&gt; with a different name you can find a consensus for. I am sorry to be<b=
r>
&gt; stubborn here but I would rather have this merged than go over few mor=
e<br>
&gt; iterations changing the name just because it seems like a good idea<br=
>
&gt; now. My experience tells me that chances are that the name will turn o=
ut<br>
&gt; to be &quot;suboptimal&quot; anyway over time.<br>
&gt;<br>
&gt; Some more background:<br>
&gt; This has started as a follow up discussion [3][4] resulting in the<br>
&gt; runtime failure caused by hardening patch [5] which removes MAP_FIXED<=
br>
&gt; from the elf loader because MAP_FIXED is inherently dangerous as it<br=
>
&gt; might silently clobber an existing underlying mapping (e.g. stack). Th=
e<br>
&gt; reason for the failure is that some architectures enforce an alignment=
<br>
&gt; for the given address hint without MAP_FIXED used (e.g. for shared or<=
br>
&gt; file backed mappings).<br>
&gt;<br>
&gt; One way around this would be excluding those archs which do alignment<=
br>
&gt; tricks from the hardening [6]. The patch is really trivial but it has<=
br>
&gt; been objected, rightfully so, that this screams for a more generic<br>
&gt; solution. We basically want a non-destructive MAP_FIXED.<br>
&gt;<br>
&gt; The first patch introduced MAP_FIXED_SAFE which enforces the given<br>
&gt; address but unlike MAP_FIXED it fails with EEXIST if the given range<b=
r>
&gt; conflicts with an existing one. The flag is introduced as a completely=
<br>
&gt; new one rather than a MAP_FIXED extension because of the backward<br>
&gt; compatibility. We really want a never-clobber semantic even on older<b=
r>
&gt; kernels which do not recognize the flag. Unfortunately mmap sucks wrt.=
<br>
&gt; flags evaluation because we do not EINVAL on unknown flags. On those<b=
r>
&gt; kernels we would simply use the traditional hint based semantic so the=
<br>
&gt; caller can still get a different address (which sucks) but at least no=
t<br>
&gt; silently corrupt an existing mapping. I do not see a good way around<b=
r>
&gt; that. Except we won&#39;t export expose the new semantic to the usersp=
ace at<br>
&gt; all.<br>
&gt;<br>
&gt; It seems there are users who would like to have something like that.<b=
r>
&gt; Jemalloc has been mentioned by Michael Ellerman [7]<br>
<br>
<a href=3D"http://lkml.kernel.org/r/87efp1w7vy.fsf@concordia.ellerman.id.au=
" rel=3D"noreferrer" target=3D"_blank">http://lkml.kernel.org/r/<wbr>87efp1=
w7vy.fsf@concordia.<wbr>ellerman.id.au</a>.<br>
<br>
It would be useful to get feedback from jemalloc developers (please).<br>
I&#39;ll add some cc&#39;s.<br>
<br>
<br>
&gt; Florian Weimer has mentioned the following:<br>
&gt; : glibc ld.so currently maps DSOs without hints.=C2=A0 This means that=
 the kernel<br>
&gt; : will map right next to each other, and the offsets between them a co=
mpletely<br>
&gt; : predictable.=C2=A0 We would like to change that and supply a random =
address in a<br>
&gt; : window of the address space.=C2=A0 If there is a conflict, we do not=
 want the<br>
&gt; : kernel to pick a non-random address. Instead, we would try again wit=
h a<br>
&gt; : random address.<br>
&gt;<br>
&gt; John Hubbard has mentioned CUDA example<br>
&gt; : a) Searches /proc/&lt;pid&gt;/maps for a &quot;suitable&quot; region=
 of available<br>
&gt; : VA space.=C2=A0 &quot;Suitable&quot; generally means it has to have =
a base address<br>
&gt; : within a certain limited range (a particular device model might<br>
&gt; : have odd limitations, for example), it has to be large enough, and<b=
r>
&gt; : alignment has to be large enough (again, various devices may have<br=
>
&gt; : constraints that lead us to do this).<br>
&gt; :<br>
&gt; : This is of course subject to races with other threads in the process=
.<br>
&gt; :<br>
&gt; : Let&#39;s say it finds a region starting at va.<br>
&gt; :<br>
&gt; : b) Next it does:<br>
&gt; :=C2=A0 =C2=A0 =C2=A0p =3D mmap(va, ...)<br>
&gt; :<br>
&gt; : *without* setting MAP_FIXED, of course (so va is just a hint), to<br=
>
&gt; : attempt to safely reserve that region. If p !=3D va, then in most ca=
ses,<br>
&gt; : this is a failure (almost certainly due to another thread getting a<=
br>
&gt; : mapping from that region before we did), and so this layer now has t=
o<br>
&gt; : call munmap(), before returning a &quot;failure: retry&quot; to uppe=
r layers.<br>
&gt; :<br>
&gt; :=C2=A0 =C2=A0 =C2=A0IMPROVEMENT: --&gt; if instead, we could call thi=
s:<br>
&gt; :<br>
&gt; :=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0p =3D mmap(va, ... MA=
P_FIXED_SAFE ...)<br>
&gt; :<br>
&gt; :=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0, then we could skip the munmap() c=
all upon failure. This<br>
&gt; :=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0is a small thing, but it is useful =
here. (Thanks to Piotr<br>
&gt; :=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Jaroszynski and Mark Hairgrove for =
helping me get that detail<br>
&gt; :=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0exactly right, btw.)<br>
&gt; :<br>
&gt; : c) After that, CUDA suballocates from p, via:<br>
&gt; :<br>
&gt; :=C2=A0 =C2=A0 =C2=A0 q =3D mmap(sub_region_start, ... MAP_FIXED ...)<=
br>
&gt; :<br>
&gt; : Interestingly enough, &quot;freeing&quot; is also done via MAP_FIXED=
, and<br>
&gt; : setting PROT_NONE to the subregion. Anyway, I just included (c) for<=
br>
&gt; : general interest.<br>
&gt;<br>
&gt; Atomic address range probing in the multithreaded programs in general<=
br>
&gt; sounds like an interesting thing to me.<br>
&gt;<br>
&gt; The second patch simply replaces MAP_FIXED use in elf loader by<br>
&gt; MAP_FIXED_SAFE. I believe other places which rely on MAP_FIXED should<=
br>
&gt; follow. Actually real MAP_FIXED usages should be docummented properly<=
br>
&gt; and they should be more of an exception.<br>
<br>
</blockquote></div><br></div>

--001a11424216604b00056042e777--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
