Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1F516B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:10:30 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id l82so18875305ywc.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:10:30 -0700 (PDT)
Received: from mail-yw0-x229.google.com (mail-yw0-x229.google.com. [2607:f8b0:4002:c05::229])
        by mx.google.com with ESMTPS id o83si2170705yba.634.2017.08.07.12.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:10:29 -0700 (PDT)
Received: by mail-yw0-x229.google.com with SMTP id l82so8489199ywc.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:10:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jL49a=xLa_giZyAfvXTHkuYdAw77zXMG3vPDm8SJr2KrQ@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAFKCwrjkonmdZ+WC9Vt_xSBgWrJLtQCN812fyxroNNpA-x4TZg@mail.gmail.com>
 <CAGXu5j+dF_2QENUfKB9qTKBgU1V9QEWnXHAaE+66rPw+cAFTYA@mail.gmail.com>
 <CAFKCwrgp6HDdNJoAUwVdg7szJhZSj26NXF38UOJpp7tWxoXZUg@mail.gmail.com>
 <CAGXu5jLrsVLoG-Q8dd=UNJqpNPi90nJqcFPGB4G6fM9U1XLxeQ@mail.gmail.com>
 <CAN=P9pjDDM3QzmO0PEYZKPE3SxYWWrbN0kx6SgF+u2s9BD+-yA@mail.gmail.com> <CAGXu5jL49a=xLa_giZyAfvXTHkuYdAw77zXMG3vPDm8SJr2KrQ@mail.gmail.com>
From: Kostya Serebryany <kcc@google.com>
Date: Mon, 7 Aug 2017 12:10:28 -0700
Message-ID: <CAN=P9phH0xnu0bfNbA2RjvZHLyyAAXk7g4Y5Jf+rt4nm7kBUbQ@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: multipart/alternative; boundary="001a114c8b569bb05005562e99e2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Evgenii Stepanov <eugenis@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Micay <danielmicay@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>

--001a114c8b569bb05005562e99e2
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 7, 2017 at 12:06 PM, Kees Cook <keescook@google.com> wrote:

> On Mon, Aug 7, 2017 at 12:03 PM, Kostya Serebryany <kcc@google.com> wrote:
> >
> >
> > On Mon, Aug 7, 2017 at 11:57 AM, Kees Cook <keescook@google.com> wrote:
> >>
> >> On Mon, Aug 7, 2017 at 11:51 AM, Evgenii Stepanov <eugenis@google.com>
> >> wrote:
> >> > On Mon, Aug 7, 2017 at 11:40 AM, Kees Cook <keescook@google.com>
> wrote:
> >> >> On Mon, Aug 7, 2017 at 11:36 AM, Evgenii Stepanov <
> eugenis@google.com>
> >> >> wrote:
> >> >>> MSan is 64-bit only and does not allow any mappings _outside_ of
> these
> >> >>> regions:
> >> >>> 000000000000 - 010000000000 app-1
> >> >>> 510000000000 - 600000000000 app-2
> >> >>> 700000000000 - 800000000000 app-3
> >> >>>
> >> >>> https://github.com/google/sanitizers/issues/579
> >> >>>
> >> >>> It sounds like the ELF_ET_DYN_BASE change should not break MSan.
> >> >>
> >> >> Hah, so the proposed move to 0x1000 8000 0000 for ASan would break
> >> >> MSan. Lovely! :P
> >> >
> >> > That's unfortunate.
> >> > This will not help existing binaries, but going forward the mapping
> >> > can be adjusted at runtime to anything like
> >> > 000000000000 .. A
> >> > 500000000000 + A .. 600000000000
> >> > 700000000000 .. 800000000000
> >> > i.e. we can look at where the binary is mapped and set A to anything
> >> > in the range of [0, 1000 0000 0000). That's still not compatible with
> >> > 0x1000 8000 0000 though.
> >>
> >> So A is considered to be < 0x1000 0000 0000? And a future MSan could
> >> handle a PIE base of 0x2000 0000 0000? If ASan an TSan can handle that
> >> too, then we could use that as the future PIE base. Existing systems
> >> will need some sort of reversion.
> >>
> >> The primary concerns with the CVEs fixed with the PIE base commit was
> >> for 32-bit. While it is possible to collide on 64-bit, it is much more
> >> rare. As long as we have no problems with the new 32-bit PIE base, we
> >> can revert the 64-bit base default back to 0x5555 5555 4000.
> >
> >
> > Yes, please!!
> >
> > Also, would it be possible to introduce some kind of regression testing
> into
> > the kernel testing process to avoid such breakages in future?
> > It would be as simple as running a handful of commands like this (for gcc
> > and clang, for asan/tsan/msan, for 32-bit and 64-bit)
> >      echo "int main(){}" |  clang  -x c++ -   -fsanitize=address &&
> ./a.out
>
> I was actually going to ask why the *San developers didn't notice the
> change? It lived in linux-next for months. :P


:)


> Can you please add a
> test for what you need to the tools/testing/selftests/ tree? A
>
We'll do it, thanks for the pointer (Dmitry, could you do this, please?)


> gcc-based test would be preferred, of course.
>

gcc implementation lags behind.
Namely,
gcc has: asan, tsan
gcc does not have msan, asan with dynamic shadow base, dfsan

So, while having a gcc-only testing would have prevented this particular
regression, it wouldn't solve some similar ones.

--kcc




>
> -Kees
>
> --
> Kees Cook
> Pixel Security
>

--001a114c8b569bb05005562e99e2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Aug 7, 2017 at 12:06 PM, Kees Cook <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:keescook@google.com" target=3D"_blank">keescook@google.com</a>&=
gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px =
0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><div=
 class=3D"gmail-HOEnZb"><div class=3D"gmail-h5">On Mon, Aug 7, 2017 at 12:0=
3 PM, Kostya Serebryany &lt;<a href=3D"mailto:kcc@google.com">kcc@google.co=
m</a>&gt; wrote:<br>
&gt;<br>
&gt;<br>
&gt; On Mon, Aug 7, 2017 at 11:57 AM, Kees Cook &lt;<a href=3D"mailto:keesc=
ook@google.com">keescook@google.com</a>&gt; wrote:<br>
&gt;&gt;<br>
&gt;&gt; On Mon, Aug 7, 2017 at 11:51 AM, Evgenii Stepanov &lt;<a href=3D"m=
ailto:eugenis@google.com">eugenis@google.com</a>&gt;<br>
&gt;&gt; wrote:<br>
&gt;&gt; &gt; On Mon, Aug 7, 2017 at 11:40 AM, Kees Cook &lt;<a href=3D"mai=
lto:keescook@google.com">keescook@google.com</a>&gt; wrote:<br>
&gt;&gt; &gt;&gt; On Mon, Aug 7, 2017 at 11:36 AM, Evgenii Stepanov &lt;<a =
href=3D"mailto:eugenis@google.com">eugenis@google.com</a>&gt;<br>
&gt;&gt; &gt;&gt; wrote:<br>
&gt;&gt; &gt;&gt;&gt; MSan is 64-bit only and does not allow any mappings _=
outside_ of these<br>
&gt;&gt; &gt;&gt;&gt; regions:<br>
&gt;&gt; &gt;&gt;&gt; 000000000000 - 010000000000 app-1<br>
&gt;&gt; &gt;&gt;&gt; 510000000000 - 600000000000 app-2<br>
&gt;&gt; &gt;&gt;&gt; 700000000000 - 800000000000 app-3<br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; <a href=3D"https://github.com/google/sanitizers/issue=
s/579" rel=3D"noreferrer" target=3D"_blank">https://github.com/google/<wbr>=
sanitizers/issues/579</a><br>
&gt;&gt; &gt;&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; It sounds like the ELF_ET_DYN_BASE change should not =
break MSan.<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; Hah, so the proposed move to 0x1000 8000 0000 for ASan wo=
uld break<br>
&gt;&gt; &gt;&gt; MSan. Lovely! :P<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; That&#39;s unfortunate.<br>
&gt;&gt; &gt; This will not help existing binaries, but going forward the m=
apping<br>
&gt;&gt; &gt; can be adjusted at runtime to anything like<br>
&gt;&gt; &gt; 000000000000 .. A<br>
&gt;&gt; &gt; 500000000000 + A .. 600000000000<br>
&gt;&gt; &gt; 700000000000 .. 800000000000<br>
&gt;&gt; &gt; i.e. we can look at where the binary is mapped and set A to a=
nything<br>
&gt;&gt; &gt; in the range of [0, 1000 0000 0000). That&#39;s still not com=
patible with<br>
&gt;&gt; &gt; 0x1000 8000 0000 though.<br>
&gt;&gt;<br>
&gt;&gt; So A is considered to be &lt; 0x1000 0000 0000? And a future MSan =
could<br>
&gt;&gt; handle a PIE base of 0x2000 0000 0000? If ASan an TSan can handle =
that<br>
&gt;&gt; too, then we could use that as the future PIE base. Existing syste=
ms<br>
&gt;&gt; will need some sort of reversion.<br>
&gt;&gt;<br>
&gt;&gt; The primary concerns with the CVEs fixed with the PIE base commit =
was<br>
&gt;&gt; for 32-bit. While it is possible to collide on 64-bit, it is much =
more<br>
&gt;&gt; rare. As long as we have no problems with the new 32-bit PIE base,=
 we<br>
&gt;&gt; can revert the 64-bit base default back to 0x5555 5555 4000.<br>
&gt;<br>
&gt;<br>
&gt; Yes, please!!<br>
&gt;<br>
&gt; Also, would it be possible to introduce some kind of regression testin=
g into<br>
&gt; the kernel testing process to avoid such breakages in future?<br>
&gt; It would be as simple as running a handful of commands like this (for =
gcc<br>
&gt; and clang, for asan/tsan/msan, for 32-bit and 64-bit)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 echo &quot;int main(){}&quot; |=C2=A0 clang=C2=A0 =
-x c++ -=C2=A0 =C2=A0-fsanitize=3Daddress &amp;&amp; ./a.out<br>
<br>
</div></div>I was actually going to ask why the *San developers didn&#39;t =
notice the<br>
change? It lived in linux-next for months. :P </blockquote><div><br></div><=
div>:)=C2=A0</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=
=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding=
-left:1ex">Can you please add a<br>
test for what you need to the tools/testing/selftests/ tree? A<br></blockqu=
ote><div>We&#39;ll do it, thanks for the pointer (Dmitry, could you do this=
, please?)</div><div>=C2=A0<br></div><blockquote class=3D"gmail_quote" styl=
e=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);paddin=
g-left:1ex">
gcc-based test would be preferred, of course.<br></blockquote><div><br></di=
v><div>gcc implementation lags behind.=C2=A0</div><div>Namely,=C2=A0</div><=
div>gcc has: asan, tsan</div><div>gcc does not have msan, asan with dynamic=
 shadow base, dfsan</div><div><br></div><div>So, while having a gcc-only te=
sting would have prevented this particular regression, it wouldn&#39;t solv=
e some similar ones.=C2=A0</div><div><br></div><div>--kcc=C2=A0</div><div><=
br></div><div><br></div><div>=C2=A0</div><blockquote class=3D"gmail_quote" =
style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);pa=
dding-left:1ex">
<div class=3D"gmail-HOEnZb"><div class=3D"gmail-h5"><br>
-Kees<br>
<br>
--<br>
Kees Cook<br>
Pixel Security<br>
</div></div></blockquote></div><br></div></div>

--001a114c8b569bb05005562e99e2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
