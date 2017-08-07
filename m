Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7429B6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 14:26:59 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id c13so17345254ywa.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:26:59 -0700 (PDT)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id j74si2386000ybj.426.2017.08.07.11.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 11:26:58 -0700 (PDT)
Received: by mail-yw0-x235.google.com with SMTP id u207so7806286ywc.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 11:26:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
From: Kostya Serebryany <kcc@google.com>
Date: Mon, 7 Aug 2017 11:26:57 -0700
Message-ID: <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: multipart/alternative; boundary="f403045dc138f37d2d05562dfdf2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Daniel Micay <danielmicay@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, eugenis@google.com

--f403045dc138f37d2d05562dfdf2
Content-Type: text/plain; charset="UTF-8"

+eugenis@ for msan

On Mon, Aug 7, 2017 at 10:33 AM, Kees Cook <keescook@google.com> wrote:

> On Mon, Aug 7, 2017 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > The recent "binfmt_elf: use ELF_ET_DYN_BASE only for PIE" patch:
> > https://github.com/torvalds/linux/commit/eab09532d40090698b05a07c1c87f3
> 9fdbc5fab5
> > breaks user-space AddressSanitizer. AddressSanitizer makes assumptions
> > about address space layout for substantial performance gains. There
> > are multiple people complaining about this already:
> > https://github.com/google/sanitizers/issues/837
> > https://twitter.com/kayseesee/status/894594085608013825
> > https://bugzilla.kernel.org/show_bug.cgi?id=196537
> > AddressSanitizer maps shadow memory at [0x00007fff7000-0x10007fff7fff]
> > expecting that non-pie binaries will be below 2GB and pie
> > binaries/modules will be at 0x55 or 0x7f. This is not the first time
> > kernel address space shuffling breaks sanitizers. The last one was the
> > move to 0x55.
>
> What are the requirements for 32-bit and 64-bit memory layouts for
> ASan currently, so we can adjust the ET_DYN base to work with existing
> ASan?
>


64-bit asan shadow is 0x00007fff8000 - 0x10007fff8000
32-bit asan shadow is 0x20000000 - 0x40000000


% cat dummy.c
int main(){}
% clang -fsanitize=address dummy.c && ASAN_OPTIONS=verbosity=1 ./a.out
 2>&1 | grep '||'
|| `[0x10007fff8000, 0x7fffffffffff]` || HighMem    ||
|| `[0x02008fff7000, 0x10007fff7fff]` || HighShadow ||
|| `[0x00008fff7000, 0x02008fff6fff]` || ShadowGap  ||
|| `[0x00007fff8000, 0x00008fff6fff]` || LowShadow  ||
|| `[0x000000000000, 0x00007fff7fff]` || LowMem     ||
%

% clang -fsanitize=address dummy.c -m32 && ASAN_OPTIONS=verbosity=1 ./a.out
 2>&1 | grep '||'
|| `[0x40000000, 0xffffffff]` || HighMem    ||
|| `[0x28000000, 0x3fffffff]` || HighShadow ||
|| `[0x24000000, 0x27ffffff]` || ShadowGap  ||
|| `[0x20000000, 0x23ffffff]` || LowShadow  ||
|| `[0x00000000, 0x1fffffff]` || LowMem     ||
%





>
> I would note that on 64-bit the ELF_ET_DYN_BASE adjustment avoids the
> entire 2GB space


Correct, but sadly it overlaps with the asan shadow (see above)


> to stay out of the way of 32-bit address-using VMs,
> for example.
>
> What ranges should be avoided currently? We need to balance this
> against the need to keep the PIE away from a growing heap...
>

See above.


>
> > Is it possible to make this change less aggressive and keep the
> > executable under 2GB?
>
> _Under_ 2GB? It's possible we're going to need some VM tunable to
> adjust these things if we're facing incompatible requirements...
>
> ASan does seem especially fragile about these kinds of changes. Can
> future versions of ASan be more dynamic about this?
>

ASan already has the dynamic shadow as an option, and it's default mode
on 64-bit windows, where the kernel is actively hostile to asan.
On Linux, we could enable it by
  clang -fsanitize=address -O dummy.cc -mllvm -asan-force-dynamic-shadow=1
(not heavily tested though).

The problem is that this comes at a cost that we are very reluctant to pay.
Dynamic shadow means one extra load and one extra register stolen per
function,
which increases the CPU usage and code size.



--kcc




>
> -Kees
>
> --
> Kees Cook
> Pixel Security
>

--f403045dc138f37d2d05562dfdf2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">+eugenis@ for msan<br><div class=3D"gmail_extra"><br><div =
class=3D"gmail_quote">On Mon, Aug 7, 2017 at 10:33 AM, Kees Cook <span dir=
=3D"ltr">&lt;<a href=3D"mailto:keescook@google.com" target=3D"_blank">keesc=
ook@google.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);pad=
ding-left:1ex"><span class=3D"gmail-">On Mon, Aug 7, 2017 at 10:24 AM, Dmit=
ry Vyukov &lt;<a href=3D"mailto:dvyukov@google.com">dvyukov@google.com</a>&=
gt; wrote:<br>
</span><span class=3D"gmail-">&gt; The recent &quot;binfmt_elf: use ELF_ET_=
DYN_BASE only for PIE&quot; patch:<br>
&gt; <a href=3D"https://github.com/torvalds/linux/commit/eab09532d40090698b=
05a07c1c87f39fdbc5fab5" rel=3D"noreferrer" target=3D"_blank">https://github=
.com/torvalds/<wbr>linux/commit/<wbr>eab09532d40090698b05a07c1c87f3<wbr>9fd=
bc5fab5</a><br>
&gt; breaks user-space AddressSanitizer. AddressSanitizer makes assumptions=
<br>
&gt; about address space layout for substantial performance gains. There<br=
>
&gt; are multiple people complaining about this already:<br>
&gt; <a href=3D"https://github.com/google/sanitizers/issues/837" rel=3D"nor=
eferrer" target=3D"_blank">https://github.com/google/<wbr>sanitizers/issues=
/837</a><br>
&gt; <a href=3D"https://twitter.com/kayseesee/status/894594085608013825" re=
l=3D"noreferrer" target=3D"_blank">https://twitter.com/kayseesee/<wbr>statu=
s/894594085608013825</a><br>
&gt; <a href=3D"https://bugzilla.kernel.org/show_bug.cgi?id=3D196537" rel=
=3D"noreferrer" target=3D"_blank">https://bugzilla.kernel.org/<wbr>show_bug=
.cgi?id=3D196537</a><br>
&gt; AddressSanitizer maps shadow memory at [0x00007fff7000-<wbr>0x10007fff=
7fff]<br>
&gt; expecting that non-pie binaries will be below 2GB and pie<br>
&gt; binaries/modules will be at 0x55 or 0x7f. This is not the first time<b=
r>
&gt; kernel address space shuffling breaks sanitizers. The last one was the=
<br>
&gt; move to 0x55.<br>
<br>
</span>What are the requirements for 32-bit and 64-bit memory layouts for<b=
r>
ASan currently, so we can adjust the ET_DYN base to work with existing<br>
ASan?<br></blockquote><div><br></div><div><br></div><div><div>64-bit asan s=
hadow is 0x00007fff8000 - 0x10007fff8000</div><div>32-bit asan shadow is 0x=
20000000 - 0x40000000</div><div><br></div></div><div><br></div><div><div>% =
cat dummy.c=C2=A0</div><div>int main(){}</div><div>% clang -fsanitize=3Dadd=
ress dummy.c &amp;&amp; ASAN_OPTIONS=3Dverbosity=3D1 ./a.out =C2=A02&gt;&am=
p;1 | grep &#39;||&#39;</div><div>|| `[0x10007fff8000, 0x7fffffffffff]` || =
HighMem =C2=A0 =C2=A0||</div><div>|| `[0x02008fff7000, 0x10007fff7fff]` || =
HighShadow ||</div><div>|| `[0x00008fff7000, 0x02008fff6fff]` || ShadowGap =
=C2=A0||</div><div>|| `[0x00007fff8000, 0x00008fff6fff]` || LowShadow =C2=
=A0||</div><div>|| `[0x000000000000, 0x00007fff7fff]` || LowMem =C2=A0 =C2=
=A0 ||</div><div>%=C2=A0</div></div><div><br></div><div><div>% clang -fsani=
tize=3Daddress dummy.c -m32 &amp;&amp; ASAN_OPTIONS=3Dverbosity=3D1 ./a.out=
 =C2=A02&gt;&amp;1 | grep &#39;||&#39;</div><div>|| `[0x40000000, 0xfffffff=
f]` || HighMem =C2=A0 =C2=A0||</div><div>|| `[0x28000000, 0x3fffffff]` || H=
ighShadow ||</div><div>|| `[0x24000000, 0x27ffffff]` || ShadowGap =C2=A0||<=
/div><div>|| `[0x20000000, 0x23ffffff]` || LowShadow =C2=A0||</div><div>|| =
`[0x00000000, 0x1fffffff]` || LowMem =C2=A0 =C2=A0 ||</div><div>%=C2=A0</di=
v></div><div><br></div><div><br></div><div><br></div><div>=C2=A0</div><bloc=
kquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:=
1px solid rgb(204,204,204);padding-left:1ex">
<br>
I would note that on 64-bit the ELF_ET_DYN_BASE adjustment avoids the<br>
entire 2GB space </blockquote><div><br></div><div>Correct, but sadly it ove=
rlaps with the asan shadow (see above)</div><div>=C2=A0</div><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid=
 rgb(204,204,204);padding-left:1ex">to stay out of the way of 32-bit addres=
s-using VMs,<br>
for example.<br>
<br>
What ranges should be avoided currently? We need to balance this<br>
against the need to keep the PIE away from a growing heap...<br></blockquot=
e><div><br></div><div>See above.=C2=A0</div><div>=C2=A0</div><blockquote cl=
ass=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid=
 rgb(204,204,204);padding-left:1ex">
<span class=3D"gmail-"><br>
&gt; Is it possible to make this change less aggressive and keep the<br>
&gt; executable under 2GB?<br>
<br>
</span>_Under_ 2GB? It&#39;s possible we&#39;re going to need some VM tunab=
le to<br>
adjust these things if we&#39;re facing incompatible requirements...<br>
<br>
ASan does seem especially fragile about these kinds of changes. Can<br>
future versions of ASan be more dynamic about this?<br></blockquote><div><b=
r></div><div>ASan already has the dynamic shadow as an option, and it&#39;s=
 default mode</div><div>on 64-bit windows, where the kernel is actively hos=
tile to asan.=C2=A0</div><div>On Linux, we could enable it by</div><div>=C2=
=A0 clang -fsanitize=3Daddress -O dummy.cc -mllvm -asan-force-dynamic-shado=
w=3D1<br></div><div>(not heavily tested though).=C2=A0</div><div><br></div>=
<div>The problem is that this comes at a cost that we are very reluctant to=
 pay.=C2=A0</div><div>Dynamic shadow means one extra load and one extra reg=
ister stolen=C2=A0per function,=C2=A0</div><div>which increases the CPU usa=
ge and code size.</div><div><br></div><div><br></div><div><br></div><div>--=
kcc=C2=A0</div><div><br></div><div><br></div><div>=C2=A0</div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px soli=
d rgb(204,204,204);padding-left:1ex">
<span class=3D"gmail-HOEnZb"><font color=3D"#888888"><br>
-Kees<br>
<br>
--<br>
Kees Cook<br>
Pixel Security<br>
</font></span></blockquote></div><br></div></div>

--f403045dc138f37d2d05562dfdf2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
