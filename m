Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8499D6B6815
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 09:30:43 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id 51-v6so504208wra.18
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 06:30:43 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0044.outbound.protection.outlook.com. [104.47.2.44])
        by mx.google.com with ESMTPS id h1-v6si16020764wrv.332.2018.09.03.06.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 03 Sep 2018 06:30:41 -0700 (PDT)
Subject: Re: [PATCH v6 11/11] arm64: annotate user pointers casts detected by
 sparse
References: <cover.1535629099.git.andreyknvl@google.com>
 <5d54526e5ff2e5ad63d0dfdd9ab17cf359afa4f2.1535629099.git.andreyknvl@google.com>
 <20180831081123.6mo62xnk54pvlxmc@ltop.local>
 <20180831134244.GB19965@ZenIV.linux.org.uk>
 <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <4368e5b0-4bb8-5bc2-0ad9-9d8f9d3325d7@arm.com>
Date: Mon, 3 Sep 2018 14:30:36 +0100
MIME-Version: 1.0
In-Reply-To: <CAAeHK+w86m6YztnTGhuZPKRczb-+znZ1hiJskPXeQok4SgcaOw@mail.gmail.com>
Content-Type: multipart/alternative;
 boundary="------------BA1EE84733EE38E13F32C147"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

--------------BA1EE84733EE38E13F32C147
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On 03/09/18 13:34, Andrey Konovalov wrote:
> On Fri, Aug 31, 2018 at 3:42 PM, Al Viro <viro@zeniv.linux.org.uk><mailto=
:viro@zeniv.linux.org.uk> wrote: >> On Fri, Aug 31, 2018 at 10:11:24AM +020=
0, Luc Van Oostenryck wrote: >>> On Thu, Aug 30, 2018 at 01:41:16PM +0200, =
Andrey Konovalov wrote: >>>> This patch adds __force annotations for __user=
 pointers casts detected by >>>> sparse with the -Wcast-from-as flag enable=
d (added in [1]). >>>> >>>> [1] https://github.com/lucvoo/sparse-dev/commit=
/5f960cb10f56ec2017c128ef9d16060e0145f292 >>> >>> Hi, >>> >>> It would be n=
ice to have some explanation for why these added __force >>> are useful. > =
> I'll add this in the next version, thanks! > >> It would be even more use=
ful if that series would either deal with >> the noise for real ("that's wh=
at we intend here, that's what we intend there, >> here's a primitive for s=
uch-and-such kind of cases, here we actually >> ought to pass __user pointe=
r instead of unsigned long", etc.) or left it >> unmasked. >> >> As it is, =
__force says only one thing: "I know the code is doing >> the right thing h=
ere". That belongs in primitives, and I do *not* mean the >> #define cast_t=
o_ulong(x) ((__force unsigned long)(x)) >> kind. >> >> Folks, if you don't =
want to deal with that - leave the warnings be. >> They do carry more infor=
mation than "someone has slapped __force in that place". >> >> Al, very ann=
oyed by that kind of information-hiding crap... > > This patch only adds __=
force to hide the reports I've looked at and > decided that the code does t=
he right thing. The cases where this is > not the case are handled by the p=
revious patches in the patchset. I'll > this to the patch description as we=
ll. Is that OK? > I think as well that we should make explicit the informat=
ion that
__force is hiding.
A possible solution could be defining some new address spaces and use
them where it is relevant in the kernel. Something like:

# define __compat_ptr __attribute__((noderef, address_space(5)))
# define __tagged_ptr __attribute__((noderef, address_space(6)))

In this way sparse can still identify the casting and trigger a warning.

We could at that point modify sparse to ignore these conversions when a
specific flag is passed (i.e. -Wignore-compat-ptr, -Wignore-tagged-ptr)
to exclude from the generated warnings the ones we have already dealt
with.

What do you think about this approach?
> _______________________________________________ > linux-arm-kernel mailin=
g list > linux-arm-kernel@lists.infradead.org<mailto:linux-arm-kernel@lists=
.infradead.org> > http://lists.infradead.org/mailman/listinfo/linux-arm-ker=
nel

IMPORTANT NOTICE: The contents of this email and any attachments are confid=
ential and may also be privileged. If you are not the intended recipient, p=
lease notify the sender immediately and do not disclose the contents to any=
 other person, use it for any purpose, or store or copy the information in =
any medium. Thank you.

--------------BA1EE84733EE38E13F32C147
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf-8">
</head>
<body text=3D"#000000" bgcolor=3D"#FFFFFF">
On 03/09/18 13:34, Andrey Konovalov wrote:<br>
<span style=3D"white-space: pre-wrap; display: block; width: 98vw;">&gt; On=
 Fri, Aug 31, 2018 at 3:42 PM, Al Viro
<a class=3D"moz-txt-link-rfc2396E" href=3D"mailto:viro@zeniv.linux.org.uk">=
&lt;viro@zeniv.linux.org.uk&gt;</a> wrote: &gt;&gt; On Fri, Aug 31, 2018 at=
 10:11:24AM &#43;0200, Luc Van Oostenryck wrote: &gt;&gt;&gt; On Thu, Aug 3=
0, 2018 at 01:41:16PM &#43;0200, Andrey Konovalov wrote: &gt;&gt;&gt;&gt; T=
his
 patch adds __force annotations for __user pointers casts detected by &gt;&=
gt;&gt;&gt; sparse with the -Wcast-from-as flag enabled (added in [1]). &gt=
;&gt;&gt;&gt; &gt;&gt;&gt;&gt; [1]
<a class=3D"moz-txt-link-freetext" href=3D"https://github.com/lucvoo/sparse=
-dev/commit/5f960cb10f56ec2017c128ef9d16060e0145f292">
https://github.com/lucvoo/sparse-dev/commit/5f960cb10f56ec2017c128ef9d16060=
e0145f292</a> &gt;&gt;&gt; &gt;&gt;&gt; Hi, &gt;&gt;&gt; &gt;&gt;&gt; It wo=
uld be nice to have some explanation for why these added __force &gt;&gt;&g=
t; are useful. &gt; &gt; I'll add this in the next version, thanks! &gt; &g=
t;&gt; It would be
 even more useful if that series would either deal with &gt;&gt; the noise =
for real (&quot;that's what we intend here, that's what we intend there, &g=
t;&gt; here's a primitive for such-and-such kind of cases, here we actually=
 &gt;&gt; ought to pass __user pointer instead of unsigned
 long&quot;, etc.) or left it &gt;&gt; unmasked. &gt;&gt; &gt;&gt; As it is=
, __force says only one thing: &quot;I know the code is doing &gt;&gt; the =
right thing here&quot;. That belongs in primitives, and I do *not* mean the=
 &gt;&gt; #define cast_to_ulong(x) ((__force unsigned long)(x)) &gt;&gt; ki=
nd. &gt;&gt; &gt;&gt;
 Folks, if you don't want to deal with that - leave the warnings be. &gt;&g=
t; They do carry more information than &quot;someone has slapped __force in=
 that place&quot;. &gt;&gt; &gt;&gt; Al, very annoyed by that kind of infor=
mation-hiding crap... &gt; &gt; This patch only adds __force to hide
 the reports I've looked at and &gt; decided that the code does the right t=
hing. The cases where this is &gt; not the case are handled by the previous=
 patches in the patchset. I'll &gt; this to the patch description as well. =
Is that OK? &gt;
</span>I think as well that we should make explicit the information that<br=
>
__force is hiding.<br>
A possible solution could be defining some new address spaces and use<br>
them where it is relevant in the kernel. Something like:<br>
<br>
# define __compat_ptr __attribute__((noderef, address_space(5)))<br>
# define __tagged_ptr __attribute__((noderef, address_space(6)))<br>
<br>
In this way sparse can still identify the casting and trigger a warning.<br=
>
<br>
We could at that point modify sparse to ignore these conversions when a<br>
specific flag is passed (i.e. -Wignore-compat-ptr, -Wignore-tagged-ptr)<br>
to exclude from the generated warnings the ones we have already dealt<br>
with.<br>
<br>
What do you think about this approach?<br>
<span style=3D"white-space: pre-wrap; display: block; width: 98vw;">&gt; __=
_____________________________________________ &gt; linux-arm-kernel mailing=
 list &gt;
<a class=3D"moz-txt-link-abbreviated" href=3D"mailto:linux-arm-kernel@lists=
.infradead.org">
linux-arm-kernel@lists.infradead.org</a> &gt; <a class=3D"moz-txt-link-free=
text" href=3D"http://lists.infradead.org/mailman/listinfo/linux-arm-kernel"=
>
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel</a> </span><br=
>
<br>
IMPORTANT NOTICE: The contents of this email and any attachments are confid=
ential and may also be privileged. If you are not the intended recipient, p=
lease notify the sender immediately and do not disclose the contents to any=
 other person, use it for any purpose,
 or store or copy the information in any medium. Thank you.
</body>
</html>

--------------BA1EE84733EE38E13F32C147--
