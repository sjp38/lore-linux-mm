Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 500936B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:59:16 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 129-v6so2088349itb.2
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:59:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 6-v6sor2187485jaf.63.2018.06.27.17.59.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 17:59:13 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1530018818.git.andreyknvl@google.com> <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
 <CAN=P9pivApAo76Kjc0TUDE0kvJn0pET=47xU6e=ioZV2VqO0Rg@mail.gmail.com>
In-Reply-To: <CAN=P9pivApAo76Kjc0TUDE0kvJn0pET=47xU6e=ioZV2VqO0Rg@mail.gmail.com>
From: Vishwath Mohan <vishwath@google.com>
Date: Wed, 27 Jun 2018 17:59:00 -0700
Message-ID: <CAEZpscCcP6=O_OCqSwW8Y6u9Ee99SzWN+hRcgpP2tK=OEBFnNw@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: multipart/alternative; boundary="00000000000054e431056fa93d49"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>
Cc: akpm@linux-foundation.org, andreyknvl@google.com, aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, mark.rutland@arm.com, Nick Desaulniers <ndesaulniers@google.com>, marc.zyngier@arm.com, dave.martin@arm.com, ard.biesheuvel@linaro.org, ebiederm@xmission.com, mingo@kernel.org, Paul Lawrence <paullawrence@google.com>, geert@linux-m68k.org, arnd@arndb.de, kirill.shutemov@linux.intel.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, rppt@linux.vnet.ibm.com, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Evgenii Stepanov <eugenis@google.com>, Lee.Smith@arm.com, Ramana.Radhakrishnan@arm.com, Jacob.Bramley@arm.com, Ruben.Ayrapetyan@arm.com, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, cpandya@codeaurora.org

--00000000000054e431056fa93d49
Content-Type: text/plain; charset="UTF-8"

On Wed, Jun 27, 2018 at 5:04 PM Kostya Serebryany <kcc@google.com> wrote:

> On Wed, Jun 27, 2018 at 4:08 PM Andrew Morton <akpm@linux-foundation.org>
> wrote:
> >
> > On Tue, 26 Jun 2018 15:15:10 +0200 Andrey Konovalov <
> andreyknvl@google.com> wrote:
> >
> > > This patchset adds a new mode to KASAN [1], which is called KHWASAN
> > > (Kernel HardWare assisted Address SANitizer).
> > >
> > > The plan is to implement HWASan [2] for the kernel with the incentive,
> > > that it's going to have comparable to KASAN performance, but in the
> same
> > > time consume much less memory, trading that off for somewhat imprecise
> > > bug detection and being supported only for arm64.
> >
> > Why do we consider this to be a worthwhile change?
> >
> > Is KASAN's memory consumption actually a significant problem?  Some
> > data regarding that would be very useful.
>
> On mobile, ASAN's and KASAN's memory usage is a significant problem.
> Not sure if I can find scientific evidence of that.
> CC-ing Vishwath Mohan who deals with KASAN on Android to provide
> anecdotal evidence.
>
Yeah, I can confirm that it's an issue. Like Kostya mentioned, I don't have
data on-hand, but anecdotally both ASAN and KASAN have proven problematic
to enable for environments that don't tolerate the increased memory
pressure well. This includes,
(a) Low-memory form factors - Wear, TV, Things, lower-tier phones like Go
(c) Connected components like Pixel's visual core
<https://www.blog.google/products/pixel/pixel-visual-core-image-processing-and-machine-learning-pixel-2/>


These are both places I'd love to have a low(er) memory footprint option at
my disposal.


> There are several other benefits too:
> * HWASAN more reliably detects non-linear-buffer-overflows compared to
> ASAN (same for kernel-HWASAN vs kernel-ASAN)
> * Same for detecting use-after-free (since HWASAN doesn't rely on
> quarantine).
> * Much easier to implement stack-use-after-return detection (which
> IIRC KASAN doesn't have yet, because in KASAN it's too hard)
>
> > If it is a large problem then we still have that problem on x86, so the
> > problem remains largely unsolved?
>
> The problem is more significant on mobile devices than on desktop/server.
> I'd love to have [K]HWASAN on x86_64 as well, but it's less trivial since
> x86_64
> doesn't have an analog of aarch64's top-byte-ignore hardware feature.
>
>
> >
> > > ====== Benchmarks
> > >
> > > The following numbers were collected on Odroid C2 board. Both KASAN and
> > > KHWASAN were used in inline instrumentation mode.
> > >
> > > Boot time [1]:
> > > * ~1.7 sec for clean kernel
> > > * ~5.0 sec for KASAN
> > > * ~5.0 sec for KHWASAN
> > >
> > > Slab memory usage after boot [2]:
> > > * ~40 kb for clean kernel
> > > * ~105 kb + 1/8th shadow ~= 118 kb for KASAN
> > > * ~47 kb + 1/16th shadow ~= 50 kb for KHWASAN
> > >
> > > Network performance [3]:
> > > * 8.33 Gbits/sec for clean kernel
> > > * 3.17 Gbits/sec for KASAN
> > > * 2.85 Gbits/sec for KHWASAN
> > >
> > > Note, that KHWASAN (compared to KASAN) doesn't require quarantine.
> > >
> > > [1] Time before the ext4 driver is initialized.
> > > [2] Measured as `cat /proc/meminfo | grep Slab`.
> > > [3] Measured as `iperf -s & iperf -c 127.0.0.1 -t 30`.
> >
> > The above doesn't actually demonstrate the whole point of the
> > patchset: to reduce KASAN's very high memory consumption?
> >
> > --
> > You received this message because you are subscribed to the Google
> Groups "kasan-dev" group.
> > To unsubscribe from this group and stop receiving emails from it, send
> an email to kasan-dev+unsubscribe@googlegroups.com.
> > To post to this group, send email to kasan-dev@googlegroups.com.
> > To view this discussion on the web visit
> https://groups.google.com/d/msgid/kasan-dev/20180627160800.3dc7f9ee41c0badbf7342520%40linux-foundation.org
> .
> > For more options, visit https://groups.google.com/d/optout.
>

--00000000000054e431056fa93d49
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br><div class=3D"gmail_quote"><div dir=3D"ltr">On Wed=
, Jun 27, 2018 at 5:04 PM Kostya Serebryany &lt;<a href=3D"mailto:kcc@googl=
e.com" target=3D"_blank">kcc@google.com</a>&gt; wrote:<br></div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">On Wed, Jun 27, 2018 at 4:08 PM Andrew Morton &lt;<a hr=
ef=3D"mailto:akpm@linux-foundation.org" target=3D"_blank">akpm@linux-founda=
tion.org</a>&gt; wrote:<br>
&gt;<br>
&gt; On Tue, 26 Jun 2018 15:15:10 +0200 Andrey Konovalov &lt;<a href=3D"mai=
lto:andreyknvl@google.com" target=3D"_blank">andreyknvl@google.com</a>&gt; =
wrote:<br>
&gt;<br>
&gt; &gt; This patchset adds a new mode to KASAN [1], which is called KHWAS=
AN<br>
&gt; &gt; (Kernel HardWare assisted Address SANitizer).<br>
&gt; &gt;<br>
&gt; &gt; The plan is to implement HWASan [2] for the kernel with the incen=
tive,<br>
&gt; &gt; that it&#39;s going to have comparable to KASAN performance, but =
in the same<br>
&gt; &gt; time consume much less memory, trading that off for somewhat impr=
ecise<br>
&gt; &gt; bug detection and being supported only for arm64.<br>
&gt;<br>
&gt; Why do we consider this to be a worthwhile change?<br>
&gt;<br>
&gt; Is KASAN&#39;s memory consumption actually a significant problem?=C2=
=A0 Some<br>
&gt; data regarding that would be very useful.<br>
<br>
On mobile, ASAN&#39;s and KASAN&#39;s memory usage is a significant problem=
.<br>
Not sure if I can find scientific evidence of that.<br>
CC-ing Vishwath Mohan who deals with KASAN on Android to provide<br>
anecdotal evidence.<br></blockquote><div>Yeah, I can confirm that it&#39;s =
an issue. Like Kostya mentioned,=C2=A0<span style=3D"background-color:rgb(2=
55,255,255);text-decoration-style:initial;text-decoration-color:initial;flo=
at:none;display:inline">I don&#39;t have data on-hand, but anecdotally b</s=
pan>oth ASAN and KASAN have proven problematic to enable for environments t=
hat don&#39;t tolerate the increased memory pressure well. This includes,<b=
r class=3D"m_4206382866232652720gmail-Apple-interchange-newline"></div><div=
>(a) Low-memory form factors - Wear, TV, Things, lower-tier phones like Go=
=C2=A0=C2=A0</div><div>(c) Connected components like Pixel&#39;s <a href=3D=
"https://www.blog.google/products/pixel/pixel-visual-core-image-processing-=
and-machine-learning-pixel-2/" target=3D"_blank">visual core</a>=C2=A0=C2=
=A0<br></div><div><br></div><div>These are both places I&#39;d love to have=
 a low(er) memory footprint option at my disposal.=C2=A0</div><div><br></di=
v><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex">
<br>
There are several other benefits too:<br>
* HWASAN more reliably detects non-linear-buffer-overflows compared to<br>
ASAN (same for kernel-HWASAN vs kernel-ASAN)<br>
* Same for detecting use-after-free (since HWASAN doesn&#39;t rely on quara=
ntine).<br>
* Much easier to implement stack-use-after-return detection (which<br>
IIRC KASAN doesn&#39;t have yet, because in KASAN it&#39;s too hard)<br>
<br>
&gt; If it is a large problem then we still have that problem on x86, so th=
e<br>
&gt; problem remains largely unsolved?<br>
<br>
The problem is more significant on mobile devices than on desktop/server.<b=
r>
I&#39;d love to have [K]HWASAN on x86_64 as well, but it&#39;s less trivial=
 since x86_64<br>
doesn&#39;t have an analog of aarch64&#39;s top-byte-ignore hardware featur=
e.<br>
<br>
<br>
&gt;<br>
&gt; &gt; =3D=3D=3D=3D=3D=3D Benchmarks<br>
&gt; &gt;<br>
&gt; &gt; The following numbers were collected on Odroid C2 board. Both KAS=
AN and<br>
&gt; &gt; KHWASAN were used in inline instrumentation mode.<br>
&gt; &gt;<br>
&gt; &gt; Boot time [1]:<br>
&gt; &gt; * ~1.7 sec for clean kernel<br>
&gt; &gt; * ~5.0 sec for KASAN<br>
&gt; &gt; * ~5.0 sec for KHWASAN<br>
&gt; &gt;<br>
&gt; &gt; Slab memory usage after boot [2]:<br>
&gt; &gt; * ~40 kb for clean kernel<br>
&gt; &gt; * ~105 kb + 1/8th shadow ~=3D 118 kb for KASAN<br>
&gt; &gt; * ~47 kb + 1/16th shadow ~=3D 50 kb for KHWASAN<br>
&gt; &gt;<br>
&gt; &gt; Network performance [3]:<br>
&gt; &gt; * 8.33 Gbits/sec for clean kernel<br>
&gt; &gt; * 3.17 Gbits/sec for KASAN<br>
&gt; &gt; * 2.85 Gbits/sec for KHWASAN<br>
&gt; &gt;<br>
&gt; &gt; Note, that KHWASAN (compared to KASAN) doesn&#39;t require quaran=
tine.<br>
&gt; &gt;<br>
&gt; &gt; [1] Time before the ext4 driver is initialized.<br>
&gt; &gt; [2] Measured as `cat /proc/meminfo | grep Slab`.<br>
&gt; &gt; [3] Measured as `iperf -s &amp; iperf -c 127.0.0.1 -t 30`.<br>
&gt;<br>
&gt; The above doesn&#39;t actually demonstrate the whole point of the<br>
&gt; patchset: to reduce KASAN&#39;s very high memory consumption?<br>
&gt;<br>
&gt; --<br>
&gt; You received this message because you are subscribed to the Google Gro=
ups &quot;kasan-dev&quot; group.<br>
&gt; To unsubscribe from this group and stop receiving emails from it, send=
 an email to <a href=3D"mailto:kasan-dev%2Bunsubscribe@googlegroups.com" ta=
rget=3D"_blank">kasan-dev+unsubscribe@googlegroups.com</a>.<br>
&gt; To post to this group, send email to <a href=3D"mailto:kasan-dev@googl=
egroups.com" target=3D"_blank">kasan-dev@googlegroups.com</a>.<br>
&gt; To view this discussion on the web visit <a href=3D"https://groups.goo=
gle.com/d/msgid/kasan-dev/20180627160800.3dc7f9ee41c0badbf7342520%40linux-f=
oundation.org" rel=3D"noreferrer" target=3D"_blank">https://groups.google.c=
om/d/msgid/kasan-dev/20180627160800.3dc7f9ee41c0badbf7342520%40linux-founda=
tion.org</a>.<br>
&gt; For more options, visit <a href=3D"https://groups.google.com/d/optout"=
 rel=3D"noreferrer" target=3D"_blank">https://groups.google.com/d/optout</a=
>.<br>
</blockquote></div></div>

--00000000000054e431056fa93d49--
