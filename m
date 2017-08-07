Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2856B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:56:09 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id n83so17706538ywn.10
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:56:09 -0700 (PDT)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id h130si1790082ywc.399.2017.08.07.11.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:56:08 -0700 (PDT)
Received: by mail-yw0-x235.google.com with SMTP id s143so8276218ywg.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:56:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
 <1502131739.1803.12.camel@gmail.com> <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
From: Kostya Serebryany <kcc@google.com>
Date: Mon, 7 Aug 2017 11:56:06 -0700
Message-ID: <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: multipart/alternative; boundary="001a114da36242645205562e669f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

--001a114da36242645205562e669f
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 7, 2017 at 11:52 AM, Kees Cook <keescook@google.com> wrote:

> On Mon, Aug 7, 2017 at 11:48 AM, Daniel Micay <danielmicay@gmail.com>
> wrote:
> > On Mon, 2017-08-07 at 11:39 -0700, Kees Cook wrote:
> >> On Mon, Aug 7, 2017 at 11:26 AM, Kostya Serebryany <kcc@google.com>
> >> wrote:
> >> > +eugenis@ for msan
> >> >
> >> > On Mon, Aug 7, 2017 at 10:33 AM, Kees Cook <keescook@google.com>
> >> > wrote:
> >> > >
> >> > > On Mon, Aug 7, 2017 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com
> >> > > > wrote:
> >> > > > The recent "binfmt_elf: use ELF_ET_DYN_BASE only for PIE" patch:
> >> > > >
> >> > > > https://github.com/torvalds/linux/commit/eab09532d40090698b05a07
> >> > > > c1c87f39fdbc5fab5
> >> > > > breaks user-space AddressSanitizer. AddressSanitizer makes
> >> > > > assumptions
> >> > > > about address space layout for substantial performance gains.
> >> > > > There
> >> > > > are multiple people complaining about this already:
> >> > > > https://github.com/google/sanitizers/issues/837
> >> > > > https://twitter.com/kayseesee/status/894594085608013825
> >> > > > https://bugzilla.kernel.org/show_bug.cgi?id=196537
> >> > > > AddressSanitizer maps shadow memory at [0x00007fff7000-
> >> > > > 0x10007fff7fff]
> >> > > > expecting that non-pie binaries will be below 2GB and pie
> >> > > > binaries/modules will be at 0x55 or 0x7f. This is not the first
> >> > > > time
> >> > > > kernel address space shuffling breaks sanitizers. The last one
> >> > > > was the
> >> > > > move to 0x55.
> >> > >
> >> > > What are the requirements for 32-bit and 64-bit memory layouts for
> >> > > ASan currently, so we can adjust the ET_DYN base to work with
> >> > > existing
> >> > > ASan?
> >> >
> >> >
> >> > 32-bit asan shadow is 0x20000000 - 0x40000000
> >> >
> >> > % clang -fsanitize=address dummy.c -m32 && ASAN_OPTIONS=verbosity=1
> >> > ./a.out
> >> > 2>&1 | grep '||'
> >> > > > `[0x40000000, 0xffffffff]` || HighMem    ||
> >> > > > `[0x28000000, 0x3fffffff]` || HighShadow ||
> >> > > > `[0x24000000, 0x27ffffff]` || ShadowGap  ||
> >> > > > `[0x20000000, 0x23ffffff]` || LowShadow  ||
> >> > > > `[0x00000000, 0x1fffffff]` || LowMem     ||
> >> >
> >> > %
> >>
> >> For 32-bit, it looks like the new PIE base is fine, yes? 0x000400000UL
> >
> > Need to consider the ASLR shift which is up to 1M with a default kernel
> > configuration but up to 256M with the maximum configurable entropy.
> >
> > On 64-bit, it's a lot larger... and the goal is also tying the stack
> > base to that so that's a further significant change, increasing the
> > address space used when the maximum configurable entropy is used.
>
> We've got two things to do upstream:
>
> - fix the default kernel for ASan
>
> - maximize the entropy optionally
>

Is it possible to implement some userspace<=>kernel interface that will
allow applications (sanitizers)
to request *fixed* address ranges from the kernel at startup (so that the
kernel couldn't refuse)?

--kcc



>
> I.e. the first is a userspace regression that needs to be fixed for
> existing ASan user. The second is developing a future path to
> maximizing the non-default entropy, for which new versions of *San
> would want to detect and use.
>
> -Kees
>
> --
> Kees Cook
> Pixel Security
>

--001a114da36242645205562e669f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Aug 7, 2017 at 11:52 AM, Kees Cook <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:keescook@google.com" target=3D"_blank">keescook@google.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><=
div class=3D"h5">On Mon, Aug 7, 2017 at 11:48 AM, Daniel Micay &lt;<a href=
=3D"mailto:danielmicay@gmail.com">danielmicay@gmail.com</a>&gt; wrote:<br>
&gt; On Mon, 2017-08-07 at 11:39 -0700, Kees Cook wrote:<br>
&gt;&gt; On Mon, Aug 7, 2017 at 11:26 AM, Kostya Serebryany &lt;<a href=3D"=
mailto:kcc@google.com">kcc@google.com</a>&gt;<br>
&gt;&gt; wrote:<br>
&gt;&gt; &gt; +eugenis@ for msan<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; On Mon, Aug 7, 2017 at 10:33 AM, Kees Cook &lt;<a href=3D"mai=
lto:keescook@google.com">keescook@google.com</a>&gt;<br>
&gt;&gt; &gt; wrote:<br>
&gt;&gt; &gt; &gt;<br>
&gt;&gt; &gt; &gt; On Mon, Aug 7, 2017 at 10:24 AM, Dmitry Vyukov &lt;<a hr=
ef=3D"mailto:dvyukov@google.com">dvyukov@google.com</a><br>
&gt;&gt; &gt; &gt; &gt; wrote:<br>
&gt;&gt; &gt; &gt; &gt; The recent &quot;binfmt_elf: use ELF_ET_DYN_BASE on=
ly for PIE&quot; patch:<br>
&gt;&gt; &gt; &gt; &gt;<br>
&gt;&gt; &gt; &gt; &gt; <a href=3D"https://github.com/torvalds/linux/commit=
/eab09532d40090698b05a07" rel=3D"noreferrer" target=3D"_blank">https://gith=
ub.com/torvalds/<wbr>linux/commit/<wbr>eab09532d40090698b05a07</a><br>
&gt;&gt; &gt; &gt; &gt; c1c87f39fdbc5fab5<br>
&gt;&gt; &gt; &gt; &gt; breaks user-space AddressSanitizer. AddressSanitize=
r makes<br>
&gt;&gt; &gt; &gt; &gt; assumptions<br>
&gt;&gt; &gt; &gt; &gt; about address space layout for substantial performa=
nce gains.<br>
&gt;&gt; &gt; &gt; &gt; There<br>
&gt;&gt; &gt; &gt; &gt; are multiple people complaining about this already:=
<br>
&gt;&gt; &gt; &gt; &gt; <a href=3D"https://github.com/google/sanitizers/iss=
ues/837" rel=3D"noreferrer" target=3D"_blank">https://github.com/google/<wb=
r>sanitizers/issues/837</a><br>
&gt;&gt; &gt; &gt; &gt; <a href=3D"https://twitter.com/kayseesee/status/894=
594085608013825" rel=3D"noreferrer" target=3D"_blank">https://twitter.com/k=
ayseesee/<wbr>status/894594085608013825</a><br>
&gt;&gt; &gt; &gt; &gt; <a href=3D"https://bugzilla.kernel.org/show_bug.cgi=
?id=3D196537" rel=3D"noreferrer" target=3D"_blank">https://bugzilla.kernel.=
org/<wbr>show_bug.cgi?id=3D196537</a><br>
&gt;&gt; &gt; &gt; &gt; AddressSanitizer maps shadow memory at [0x00007fff7=
000-<br>
&gt;&gt; &gt; &gt; &gt; 0x10007fff7fff]<br>
&gt;&gt; &gt; &gt; &gt; expecting that non-pie binaries will be below 2GB a=
nd pie<br>
&gt;&gt; &gt; &gt; &gt; binaries/modules will be at 0x55 or 0x7f. This is n=
ot the first<br>
&gt;&gt; &gt; &gt; &gt; time<br>
&gt;&gt; &gt; &gt; &gt; kernel address space shuffling breaks sanitizers. T=
he last one<br>
&gt;&gt; &gt; &gt; &gt; was the<br>
&gt;&gt; &gt; &gt; &gt; move to 0x55.<br>
&gt;&gt; &gt; &gt;<br>
&gt;&gt; &gt; &gt; What are the requirements for 32-bit and 64-bit memory l=
ayouts for<br>
&gt;&gt; &gt; &gt; ASan currently, so we can adjust the ET_DYN base to work=
 with<br>
&gt;&gt; &gt; &gt; existing<br>
&gt;&gt; &gt; &gt; ASan?<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; 32-bit asan shadow is 0x20000000 - 0x40000000<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; % clang -fsanitize=3Daddress dummy.c -m32 &amp;&amp; ASAN_OPT=
IONS=3Dverbosity=3D1<br>
&gt;&gt; &gt; ./a.out<br>
&gt;&gt; &gt; 2&gt;&amp;1 | grep &#39;||&#39;<br>
&gt;&gt; &gt; &gt; &gt; `[0x40000000, 0xffffffff]` || HighMem=C2=A0 =C2=A0 =
||<br>
&gt;&gt; &gt; &gt; &gt; `[0x28000000, 0x3fffffff]` || HighShadow ||<br>
&gt;&gt; &gt; &gt; &gt; `[0x24000000, 0x27ffffff]` || ShadowGap=C2=A0 ||<br=
>
&gt;&gt; &gt; &gt; &gt; `[0x20000000, 0x23ffffff]` || LowShadow=C2=A0 ||<br=
>
&gt;&gt; &gt; &gt; &gt; `[0x00000000, 0x1fffffff]` || LowMem=C2=A0 =C2=A0 =
=C2=A0||<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; %<br>
&gt;&gt;<br>
&gt;&gt; For 32-bit, it looks like the new PIE base is fine, yes? 0x0004000=
00UL<br>
&gt;<br>
&gt; Need to consider the ASLR shift which is up to 1M with a default kerne=
l<br>
&gt; configuration but up to 256M with the maximum configurable entropy.<br=
>
&gt;<br>
&gt; On 64-bit, it&#39;s a lot larger... and the goal is also tying the sta=
ck<br>
&gt; base to that so that&#39;s a further significant change, increasing th=
e<br>
&gt; address space used when the maximum configurable entropy is used.<br>
<br>
</div></div>We&#39;ve got two things to do upstream:<br>
<br>
- fix the default kernel for ASan<br>
<br>
- maximize the entropy optionally<br></blockquote><div><br></div><div>Is it=
 possible to implement some userspace&lt;=3D&gt;kernel interface that will =
allow applications (sanitizers)<br></div><div>to request *fixed* address ra=
nges from the kernel at startup (so that the kernel couldn&#39;t refuse)?=
=C2=A0</div><div><br></div><div>--kcc=C2=A0</div><div><br></div><div>=C2=A0=
</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex">
<br>
I.e. the first is a userspace regression that needs to be fixed for<br>
existing ASan user. The second is developing a future path to<br>
maximizing the non-default entropy, for which new versions of *San<br>
would want to detect and use.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
-Kees<br>
<br>
--<br>
Kees Cook<br>
Pixel Security<br>
</div></div></blockquote></div><br></div></div>

--001a114da36242645205562e669f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
